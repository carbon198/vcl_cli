module VCL
  class CLI < Thor
    desc "waf", "Download WAF VCLs"
    method_option :service, :aliases => ["--s"]
    method_option :version, :aliases => ["--v"]
    def waf
      if !options[:service]
        id = VCL::Utils.parse_directory
        abort "Could not parse service id from directory. Use --s <service> to specify, vcl download, then try again." unless id
      else
        id = options[:service]
      end

      version = options[:version] ? options[:version] : VCL::Fetcher.get_active_version(id) 

      service = VCL::Fetcher.api_request(:get, "/service/#{id}/details")

      waf = service["active_version"]["wafs"]

      if waf
        waf_data = VCL::Fetcher.api_request(:get, "/service/#{id}/wafs/#{waf[0]["id"]}/ruleset")
        filename = "ruleset.waf"

        if File.exist?(filename)
          unless yes?("Are you sure you want to overwrite #{filename}")
            say("Skipping #{filename}")
            return
          end
        end

        File.open(filename, 'w+') {|f| f.write(JSON.parse(waf_data)["data"]["attributes"]["vcl"]) }

        say("WAF VCL content written to #{filename}")
      else
        say("WAF is not enabled on this service.")
      end
    end
  end
end
