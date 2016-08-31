module VCL
  class CLI < Thor
    desc "waf", "Download WAF VCLs"
    def waf
      parsed_id = VCL::Utils.parse_directory

      if options[:service]
        abort "Already in a service directory, go up one level in order to specify"\
              "service id with --service." if parsed_id
        id = options[:service]
        parsed = false
      else
        abort "Could not parse service id from directory. Specify service id with "\
              "--service option or use from within service directory." unless parsed_id
        id = parsed_id
        parsed = true
      end

      service = VCL::Fetcher.api_request(:get, "/service/#{id}/details")

      customer_id = service["customer_id"]

      VCL::Fetcher.assume_account_owner(customer_id)

      waf = VCL::Fetcher.api_request(:get, "/service/#{id}/wafs/4o0eNn2qV1zmqfosNx4CwQ/ruleset", :endpoint => :app)
      
      VCL::Fetcher.unassume

      folder_name = parsed ? "./" : "#{service["name"]} - #{service["id"]}/"
      Dir.mkdir(folder_name) unless (File.directory?(folder_name) || parsed)

      if waf
        filename = "#{folder_name}ruleset.waf"

        if File.exist?(filename)
          unless yes?("Are you sure you want to overwrite #{filename}")
            say("Skipping #{filename}")
            return
          end
        end

        File.open(filename, 'w+') {|f| f.write(waf["data"]["attributes"]["vcl"]) }

        say("WAF VCL content written to #{filename}")
      else
        say("WAF is not enabled on this service.")
      end
    end
  end
end
