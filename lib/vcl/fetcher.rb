module VCL
  module Fetcher
    def self.api_request(method, path, endpoint=:api, body="",extra_headers={})
      headers = {"Accept" => "application/json", "Connection" => "close"}

      if endpoint == :app
        headers["Referer"] = VCL::FASTLY_APP
        headers["X-CSRF-Token"] = VCL::Cookies["fastly.csrf"] if VCL::Cookies["fastly.csrf"]
      end

      if VCL::Token
        headers["Fastly-Key"] = VCL::Token
      else
        headers["Cookie"] = "" if VCL::Cookies.length > 0
        VCL::Cookies.each do |k,v|
          headers["Cookie"] << "#{k}=#{v};"
        end
      end

      headers["Content-Type"] = "application/x-www-form-urlencoded" if (method == :post || method == :put)

      if body.length > 0 && (body.is_a? String)
        headers["Content-Length"] = body.length
      end

      headers.merge!(extra_headers) if extra_headers.count > 0

      url = "#{endpoint == :api ? VCL::FASTLY_API : VCL::FASTLY_APP}#{path}"

      response = Typhoeus.send(method.to_s, url, body: body, headers: headers)

      case response.response_code
        when 200
          if response.headers["Set-Cookie"]
            response.headers["Set-Cookie"] = [response.headers["Set-Cookie"]] if response.headers["Set-Cookie"].is_a? String
            response.headers["Set-Cookie"].each do |c|
              name, value = c.match(/^([^=]*)=([^;]*).*/i).captures
              VCL::Cookies[name] = value
            end
          end
        when 400
          abort "400: Bad API request--got bad request response. Sometimes this means what you're looking for doesn't exist. Method: #{method.to_s}, Path: #{path}"
        when 403
          abort "403: Access Denied by API. Run login command to authenticate. Method: #{method.to_s}, Path: #{path}"
        when 404
          abort "404: Service does not exist or bad path requested. Method: #{method.to_s}, Path: #{path}"
        when 503
          abort "503: API is offline. Method: #{method.to_s}, Path: #{path}"
        else
          abort "API responded with status #{response.response_code}. Method: #{method.to_s}, Path: #{path}"
      end

      #puts JSON.pretty_generate(JSON.parse(response.response_body))

      if response.response_body.length > 1
        return JSON.parse(response.response_body) 
      else
        return {}
      end
    end

    def self.get_active_version(id)
      service = self.api_request(:get, "/service/#{id}")

      service["versions"].each do |v|
        if v["active"] == "1"
          return v["number"]
        end
      end
    end

    def self.get_writable_version(id)
      service = self.api_request(:get, "/service/#{id}")

      active = nil
      version = nil
      service["versions"].each do |v|
        if v["active"] == "1"
          active = v["number"].to_i
        end

        if active != nil && v["number"].to_i > active && v["locked"] == "0"
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

    def self.assume_account_owner(id)
      customer = self.api_request(:get, "/customer/#{id}")
      owner = customer["owner_id"]

      user = self.api_request(:get, "/user/#{owner}")
      user_login = user["login"]

      self.api_request(:post, "/admin/assume/#{URI.escape(user_login)}", :app)
    end

    def self.unassume
      self.api_request(:post, "/admin/unassume", :app)
    end
  end
end