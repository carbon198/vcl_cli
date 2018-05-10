module VCL
  class CLI < Thor
    desc "move SERVICE_ID TARGET_CUSTOMER", "[ADMIN] Move a service to a new customer. Multiple services may be comma separated."
    def move(service_id, customer_id)

      service_id = service_id.split(",")

      service_id.each do |id|
        resp = VCL::Fetcher.api_request(:put, "/service/#{id}/change_customer/#{customer_id}", :endpoint => :app)

        say("\nService #{id} successfully moved to #{customer_id}")
      end
    end
  end
end
