module VCL
  class CLI < Thor
    desc "move SERVICE_ID TARGET_CUSTOMER", "Move a service to a new customer"
    def move(service_id, customer_id)
      pass = self.ask("This API endpoint requires your app.fastly.com password: ", :echo => false)

      resp = VCL::Fetcher.api_request(:put, "/service/#{service_id}/change_customer/#{customer_id}?password=#{url_encode(pass)}", :endpoint => :app)

      say("\nService successfully moved to #{customer_id}")
    end
  end
end
