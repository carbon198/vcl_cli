module VCL
  class CLI < Thor
    desc "domain ACTION HOST", "Manipulate domains on a service. Available actions are create, delete, list and check. Create, delete and check take a host argument. Additionally, check can take the argument \"all\" to check all domains."
    method_option :service, :aliases => ["--s"]
    method_option :version, :aliases => ["--v"]
    def domain(action,host=false)
      id = VCL::Utils.parse_directory unless options[:service]
      id ||= options[:service]

      abort "Could not parse service id from directory. Use --s <service> to specify, vcl download, then try again." unless id

      version = VCL::Fetcher.get_writable_version(id) unless options[:version]
      version ||= options[:version].to_i

      case action
      when "create"
        VCL::Fetcher.api_request(:post,"/service/#{id}/version/#{version}/domain",{
          params: {
            name: host,
          }
        })
        say("#{host} created on #{id} version #{version}")
      when "delete"
        VCL::Fetcher.api_request(:delete,"/service/#{id}/version/#{version}/domain/#{host}")
        say("#{host} deleted on #{id} version #{version}")
      when "list"
        domains = VCL::Fetcher.api_request(:get,"/service/#{id}/version/#{version}/domain")
        say("Listing all domains for #{id} version #{version}")
        domains.each do |d|
          puts d["name"]
        end
      when "check"
        if host == "all"
          domains = VCL::Fetcher.api_request(:get,"/service/#{id}/version/#{version}/domain/check_all")
        else
          domains = [VCL::Fetcher.api_request(:get,"/service/#{id}/version/#{version}/domain/#{host}/check")]
        end

        domains.each do |d|
          say("#{d[0]["name"]} -> #{d[1]}")
        end
      else
        abort "#{action} is not a valid command"
      end
    end
  end
end
