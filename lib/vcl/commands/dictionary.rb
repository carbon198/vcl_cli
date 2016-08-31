module VCL
  class CLI < Thor
    desc "dictionary ACTION DICTIONARY_NAME=none KEY=none VALUE=none", "Manipulate edge dictionaries. Actions: create: Create a dictionary\n
    delete: Delete a dictionary\n
    list: Provide a list of dictionaries on this service\n
    upsert: Update a key in a dictionary if it exists. Add the key if it does not.\n
    remove: Remove a key from a dictionary\n
    list_items: List all keys in the dictionary\n
    bulk_add: Perform operations on the dictionary in bulk. A list of operations in JSON format should be specified in the key field. Documentation on this format can be found here: https://docs.fastly.com/api/config#dictionary_item_dc826ce1255a7c42bc48eb204eed8f7f"
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
      when "upsert"
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
        abort "Must specify JSON blob of operations in key field. Documentation on this can be found here: https://docs.fastly.com/api/config#dictionary_item_dc826ce1255a7c42bc48eb204eed8f7f" unless key
        dict = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/dictionary/#{name}")
        VCL::Fetcher.api_request(:patch, "/service/#{id}/dictionary/#{dict["id"]}/items", {body: key, headers: {"Content-Type" => "application/json"}})

        say("Bulk add operation completed successfully.")
      else
        abort "#{action} is not a valid command"
      end
    end
  end
end
