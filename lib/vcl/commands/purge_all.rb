module VCL
  class CLI < Thor
    desc "purge_all", "Purge all content from a service."
    option :service
    def purge_all
      parsed_id = VCL::Utils.parse_directory

      id = VCL::Utils.parse_directory

      abort "could not parse service id from directory" unless (id || options[:service])

      VCL::Fetcher.api_request(:post, "/service/#{id}/purge_all")

      say("Purge all on #{id} completed.")
    end
  end
end
