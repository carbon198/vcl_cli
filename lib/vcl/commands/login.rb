module VCL
  class CLI < Thor
    desc "login", "Logs into the app. Required before doing anything else."
    def login
      if VCL::Token
        abort unless yes?("You already have an access token, are you sure you want to authenticate again?")
      end

      login_results = VCL::Fetcher.login

      File.open(VCL::COOKIE_JAR , 'w+') {|f| f.write(JSON.dump(VCL::Cookies)) }
      File.chmod(0600, VCL::COOKIE_JAR)

      say("Creating root scoped token...")

      scope = login_results[:user].include?("@fastly.com") ? "root" : "global"

      o = {
        user: login_results[:user],
        pass: login_results[:pass],
        code: login_results[:code],
        scope: scope,
        name: "vcl_cli_token"
      }

      resp = VCL::Fetcher.create_token(o)

      token = resp["access_token"]
      token_id = resp["id"]

      File.open(VCL::TOKEN_FILE , 'w+') {|f| f.write(token) }
      File.chmod(0600, VCL::TOKEN_FILE)

      resp = VCL::Fetcher.api_request(:get, "/tokens", { headers: {"Fastly-Key" => token}})
      abort unless resp.count > 0

      resp.each do |t|
        next unless (t["name"] == "vcl_cli_token" && t["id"] != token_id)

        if yes?("There was already a token created with the name vcl_cli_token. To avoid creating multiple tokens, should it be deleted?")
          VCL::Fetcher.api_request(:delete, "/tokens/#{t["id"]}", {headers: {"Fastly-Key" => token}, expected_responses: [204]})
          say("Token with id #{t["id"]} deleted.")
        end
      end
    end
  end
end
