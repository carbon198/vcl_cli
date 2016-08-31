module VCL
  module Fetcher
    def self.api_request(method, path, options={})
      options[:endpoint] ||= :api
      options[:body] ||= ""
      options[:headers] ||= {}
      options[:force_session] ||= false
      options[:expected_responses] ||= [200]

      headers = {"Accept" => "application/json", "Connection" => "close", "User-Agent" => "For those about to POST, we salute you"}

      if options[:endpoint] == :app
        headers["Referer"] = VCL::FASTLY_APP
        headers["X-CSRF-Token"] = VCL::Cookies["fastly.csrf"] if VCL::Cookies["fastly.csrf"]
        headers["Fastly-API-Request"] = "true"
      end

      if VCL::Token && !options[:force_session]
        headers["Fastly-Key"] = VCL::Token
      else
        headers["Cookie"] = "" if VCL::Cookies.length > 0
        VCL::Cookies.each do |k,v|
          headers["Cookie"] << "#{k}=#{v};"
        end
      end

      headers["Content-Type"] = "application/x-www-form-urlencoded" if (method == :post || method == :put)

      headers.merge!(options[:headers]) if options[:headers].count > 0

      url = "#{options[:endpoint] == :api ? VCL::FASTLY_API : VCL::FASTLY_APP}#{path}"

      body = options[:body]

      if body.length > 0 && (body.is_a? String)
        headers["Content-Length"] = body.length
      end

      response = Typhoeus.send(method.to_s, url, body: body, headers: headers)

      if options[:expected_responses].include?(response.response_code)
        if response.headers["Set-Cookie"]
          response.headers["Set-Cookie"] = [response.headers["Set-Cookie"]] if response.headers["Set-Cookie"].is_a? String
          response.headers["Set-Cookie"].each do |c|
            name, value = c.match(/^([^=]*)=([^;]*).*/i).captures
            VCL::Cookies[name] = value
          end
        end
      else
        case response.response_code
          when 400
            error = "400: Bad API request--got bad request response. Sometimes this means what you're looking for doesn't exist."
          when 403
            error = "403: Access Denied by API. Run login command to authenticate."
          when 404
            error = "404: Service does not exist or bad path requested."
          when 503
            error = "503: API is offline."
          else
            error = "API responded with status #{response.response_code}."
        end

        error += " Method: #{method.to_s}, Path: #{path}\n"
        error += "Message from API: #{response.response_body}"

        abort error
      end

      return response.response_body if (response.headers["Content-Type"] != "application/json")

      if response.response_body.length > 1
        begin
          return JSON.parse(response.response_body)
        rescue JSON::ParserError
          abort "Failed to parse JSON response from Fastly API"
        end
      else
        return {}
      end
    end

    def self.domain_to_service_id(domain)
      response = Typhoeus::Request.new(VCL::FASTLY_APP, method:"FASTLYSERVICEMATCH", headers: { :host => domain}).run

      abort "Failed to fetch Fastly service ID or service ID does not exist" if response.response_code != 204

      abort "Fastly response did not contain service ID" unless response.headers["Fastly-Service-Id"]

      return response.headers["Fastly-Service-Id"]
    end

    def self.get_active_version(id)
      service = self.api_request(:get, "/service/#{id}")

      service["versions"].each do |v|
        if v["active"] == true
          return v["number"]
        end
      end
    end

    def self.get_writable_version(id)
      service = self.api_request(:get, "/service/#{id}")

      active = nil
      version = nil
      service["versions"].each do |v|
        if v["active"] == true
          active = v["number"].to_i
        end

        if active != nil && v["number"].to_i > active && v["locked"] == false     
          version = v["number"]
        end
      end

      version = self.api_request(:put, "/service/#{id}/version/#{active}/clone")["number"] if version == nil

      return version
    end

    def self.get_vcl(id, version, generated=false)
      if generated
        vcl = self.api_request(:get, "/service/#{id}/version/#{version}/generated_vcl")
      else
        vcl = self.api_request(:get, "/service/#{id}/version/#{version}/vcl?include_content=1")
      end

      if vcl.length == 0
        return false
      else
        return vcl
      end
    end

    def self.upload_vcl(service,version,content,name,is_main=true,is_new=false)
      body = "------TheBoundary\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n#{name}\r\n"
      body += "------TheBoundary\r\nContent-Disposition: form-data; name=\"content\"; filename=\"#{name}.vcl\"\r\n"
      body += "Content-Type: application/octet-stream\r\n\r\n#{content}\r\n"
      body += "------TheBoundary\r\nContent-Disposition: form-data; name=\"main\"\r\n\r\n"
      body += "#{is_main ? "1" : "0"}\r\n------TheBoundary--\r\n"

      headers = { "Content-Type" => "multipart/form-data; boundary=----TheBoundary" }

      # try to create, if that fails, update
      if is_new
        response = VCL::Fetcher.api_request(:post, "/service/#{service}/version/#{version}/vcl", {:endpoint => :api, body: body, headers: headers, expected_responses:[200,409]})
        if response["msg"] != "Duplicate record"
          return
        end
      end

      response = VCL::Fetcher.api_request(:put, "/service/#{service}/version/#{version}/vcl/#{name}", {:endpoint => :api, body: body, headers: headers})
    end
  end
end