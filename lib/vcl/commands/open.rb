module VCL
  class CLI < Thor
    desc "open DOMAIN", "Find the service ID for a domain and open the Fastly app. You may also specify the service ID or assume the context of the directory you are in by omitting the domain. Options: --service"
    option :service
    def open(domain=false)
      if (options[:service] && domain)
        say("Both domain and service id supplied, using service id.")
        domain = false
      end

      if options[:service]
        id = options[:service]
      elsif domain
        id = VCL::Fetcher.domain_to_service_id(domain)
      else
        id = VCL::Utils.parse_directory

        abort "Could not parse service id from directory and no domain/service supplied" unless id
      end

      VCL::Utils.open_service(id)
    end
  end
end
