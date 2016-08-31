module VCL
  class CLI < Thor
    desc "dictionary ACTION DICTIONARY_NAME=none KEY=none VALUE=none", "Manipulate edge dictionaries. Actions: create, delete, list, add, update, remove, list_items, bulk_add. Options: --service --version"
    option :service
    option :version
    def dictionary(action, name=false, key=false, value=false)
      id = VCL::Utils.parse_directory unless options[:service]
      id ||= options[:service]

      abort "Could not parse service id from directory. Specify service id with --service or use from within service directory." unless id

      version = VCL::Fetcher.get_writable_version(id) unless options[:version]
      version ||= options[:version]

      case action
      when "create"
        abort "Must specify name for dictionary" unless name
        VCL::Fetcher.api_request(:post, "/service/#{id}/version/#{version}/dictionary", body: "name=#{URI.escape(name)}")

        say("Dictionary #{name} created.")
      when "delete"
        abort "Must specify name for dictionary" unless name
        VCL::Fetcher.api_request(:delete, "/service/#{id}/version/#{version}/dictionary/#{name}")

        say("Dictionary #{name} deleted.")
      when "list"
        resp = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary")

        say("No dictionaries on service in this version.") unless resp.length > 0

        resp.each do |d|
          puts "#{d["id"]} - #{d["name"]}"
        end
      when "add"
        abort "Must specify name for dictionary" unless name
        abort "Must specify key and value for dictionary item" unless (key && value)
        dict = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary/#{name}")
        VCL::Fetcher.api_request(:post, "/service/#{id}/dictionary/#{dict["id"]}/item", body: "item_key=#{key}&item_value=#{value}")

        say("Dictionary item #{key} created with value #{value}.")
      when "update"
        abort "Must specify name for dictionary" unless name
        abort "Must specify key and value for dictionary item" unless (key && value)
        dict = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary/#{name}")
        VCL::Fetcher.api_request(:put, "/service/#{id}/dictionary/#{dict["id"]}/item/#{key}", body: "item_value=#{value}")   

        say("Dictionary item #{key} set to #{value}.")   
      when "remove"
        abort "Must specify name for dictionary" unless name
        abort "Must specify key for dictionary item" unless key
        dict = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary/#{name}")
        VCL::Fetcher.api_request(:delete, "/service/#{id}/dictionary/#{dict["id"]}/item/#{key}")

        say("Item #{key} removed from dictionary #{name}.")
      when "list_items"
        abort "Must specify name for dictionary" unless name
        dict = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary/#{name}")
        resp = VCL::Fetcher.api_request(:get, "/service/#{id}/dictionary/#{dict["id"]}/items")

        say("No items in dictionary.") unless resp.length > 0
        resp.each do |i|
          puts "#{i["item_key"]} : #{i["item_value"]}"
        end
      when "bulk_add"
        abort "Must specify name for dictionary" unless name
        dict = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary/#{name}")

        items = JSON.parse(key)
        items.each do |k,v|
          VCL::Fetcher.api_request(:post, "/service/#{id}/dictionary/#{dict["id"]}/item", body: "item_key=#{k}&item_value=#{v}")

          say("#{k} added to #{name} with value #{v}")
        end
      end
    end
  end
end
