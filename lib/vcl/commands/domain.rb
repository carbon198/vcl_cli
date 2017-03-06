module VCL
  class CLI < Thor
    desc "domain ACTION HOST", "Create and delete domains on a service."
    option :service
    option :version
    def domain(action,host)
      id = VCL::Utils.parse_directory unless options[:service]
      id ||= options[:service]

      abort "could not parse service id from directory" unless id

      version = VCL::Fetcher.get_writable_version(id) unless options[:version]
      version ||= options[:version].to_i

      case action
      when "create"
        VCL::Fetcher.api_request(:post,"/service/#{id}/version/#{version}/domain",{
          params: {
            name: host,
          }
        })
        puts "#{host} created on #{id} version #{version}"
      when "delete"
        VCL::Fetcher.api_request(:delete,"/service/#{id}/version/#{version}/domain/#{host}")
        puts "#{host} deleted on #{id} version #{version}"
      else
        abort "#{action} is not a valid command"
      end
    end
  end
end
