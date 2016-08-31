module VCL
  class CLI < Thor
    desc "create_service CUSTOMER_ID SERVICE_NAME", "Create a blank service on behalf of a customer."
    def create_service(id, name)
      say("This command works by creating a service on your account and moving it to the target account. It will prompt you for your password.")
      service = VCL::Fetcher.api_request(:post, "/service", { body: "name=#{URI.escape(name)}"})

      self.move(service["id"],id)

      say("Service #{service["id"]} has been created. If you are already on the configure tab you may need to refresh.")
    end
  end
end
