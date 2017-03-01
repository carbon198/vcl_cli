module VCL
  class CLI < Thor
    desc "token ACTION", "Manipulate API tokens. Available actions are list, create, and delete. Scope defaults to admin:write."
    option :customer
    option :scope
    def token(action)
      case action
      when "list"
        if options[:customer]
          tokens = VCL::Fetcher.api_request(:get, "/customer/#{options[:customer]}/tokens")
        else
          tokens = VCL::Fetcher.api_request(:get, "/tokens")
        end
        abort "No tokens to display!" unless tokens.length > 0

        pp tokens

      when "create"
        scope = options[:scope]
        scope ||= "admin:write"

        say("You must login again to create tokens.")

        login_results = VCL::Fetcher.login

        name = ask("What would you like to name your token?")

        resp = VCL::Fetcher.create_token(login_results[:user],login_results[:pass],login_results[:code],scope,name)

      when "delete"
        id = ask("What is the ID of the token you'd like to delete?")

        VCL::Fetcher.api_request(:delete, "/tokens/#{id}", expected_responses: [204])
        say("Token with id #{id} deleted.")
      else
        abort "#{action} is not a valid command"
      end
    end
  end
end
