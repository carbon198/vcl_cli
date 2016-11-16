module VCL
  class CLI < Thor
    desc "login", "Logs into the app. Required before doing anything else."
    def login
      if VCL::Token
        abort unless yes?("You already have an access token, are you sure you want to authenticate again?")
      end

      user = self.ask("Username: ")
      pass = self.ask("Password: ", :echo => false)
      resp = VCL::Fetcher.api_request(:post, "/login", { :endpoint => :app, params: { user: user, password: pass}})

      if resp["needs_two_factor_auth"]
        two_factor = true

        say("\nTwo factor auth enabled on account, second factor needed.")
        code = ask('Please enter verification code:', echo: false)

        resp = VCL::Fetcher.api_request(:post, "/two_factor_auth/verify", {force_session: true, :endpoint => :app, params: { token: code }} )
      else
        say("\nTwo factor auth is NOT enabled. You should go do that immediately.")
      end

      File.open(VCL::COOKIE_JAR , 'w+') {|f| f.write(JSON.dump(VCL::Cookies)) }
      File.chmod(0600, VCL::COOKIE_JAR)

      say("Login successful!")
      say("Creating root scoped token...")

      headers = {}
      headers["Fastly-OTP"] = code if two_factor

      scope = user.include?("@fastly.com") ? "root" : "admin:write"

      VCL::Fetcher.api_request(:post, "/sudo", {force_session: true, :endpoint => :api, params: { user: user, password: pass}, headers: headers})
      resp = VCL::Fetcher.api_request(:post, "/tokens", {force_session: true, :endpoint => :api, params: { name: "vcl_cli_token", scope: scope, user: user, password: pass }, headers: headers})

      token = resp["access_token"]
      token_id = resp["id"]

      say("\n#{token_id} created.")

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
