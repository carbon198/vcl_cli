require "vcl/commands/purge_all"
require "vcl/commands/open"
require "vcl/commands/download"
require "vcl/commands/diff"
require "vcl/commands/waf"
require "vcl/commands/upload"
require "vcl/commands/activate"
require "vcl/commands/skeleton"
require "vcl/commands/clone"
require "vcl/commands/move"
require "vcl/commands/create_service"
require "vcl/commands/dictionary"
require "vcl/commands/login"

module VCL
  class CLI < Thor
    desc "version", "Displays version of the VCL gem."
    def version
      say("VCL gem version is #{VCL::VERSION}")
    end

    # TODO: completely rework this command into something else
    #desc "services CUSTOMER_ID", "Lists services for a customer."
    #def services(customer_id)
    #  services = VCL::Fetcher.api_request(:get, "/customer/#{customer_id}/service_ids")

    #  abort "Customer has no services." if services.length == 0

    #  services.each do |s|
    #    service = VCL::Fetcher.api_request(:get, "/service/#{s}/details")
    #    say("#{service["name"]} - #{service["id"]}")
    #  end
    #end
  end
end
