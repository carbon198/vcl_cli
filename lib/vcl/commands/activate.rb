module VCL
  class CLI < Thor
    desc "activate", "Activates a service version. Options: --service, --version"
    option :service
    option :version
    def activate
      id = VCL::Utils.parse_directory unless options[:service]
      id ||= options[:service]

      abort "could not parse service id from directory" unless id

      writable_version = VCL::Fetcher.get_writable_version(id) unless options[:version]
      writable_version ||= options[:version].to_i

      VCL::Fetcher.api_request(:put, "/service/#{id}/version/#{writable_version}/activate")

      say("Version #{writable_version} on #{id} activated.")
    end
  end
end
