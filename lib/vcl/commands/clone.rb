module VCL
  class CLI < Thor
    desc "clone SERVICE_ID TARGET_SERVICE_ID", "[ADMIN] Clone a service version to another service."
    option :version
    def clone(id,target_id)
      version = VCL::Fetcher.get_active_version(id) unless options[:version]
      version ||= options[:version]

      result = VCL::Fetcher.api_request(:put, "/service/#{id}/version/#{version}/copy/to/#{target_id}")

      say("#{id} version #{version} copied to #{target_id} version #{result["number"]}")

      active_version = VCL::Fetcher.get_active_version(target_id)

      domain_count = VCL::Fetcher.api_request(:get,"/service/#{target_id}/version/#{result["number"]}/domain").count
      domains = VCL::Fetcher.api_request(:get,"/service/#{target_id}/version/#{active_version}/domain")
      abort if domain_count > 0

      say("Restoring domains that were lost during cloning.")
      domains.each do |d|
        VCL::Fetcher.api_request(:post,"/service/#{target_id}/version/#{result["number"]}/domain", {
            params: { name: name, comment: comment }
          })
      end
    end
  end
end
