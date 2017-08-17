module VCL
  class CLI < Thor
    desc "snippet ACTION NAME", "Manipulate snippets on a service. Available actions are create, delete, and list. Use upload command to update snippets."
    method_option :service, :aliases => ["--s"]
    method_option :version, :aliases => ["--v"]
    method_option :type, :aliases => ["--t"]
    def snippet(action,name=false)
      id = VCL::Utils.parse_directory unless options[:service]
      id ||= options[:service]

      abort "could not parse service id from directory" unless id

      version = VCL::Fetcher.get_writable_version(id) unless options[:version]
      version ||= options[:version].to_i

      filename = "#{name}.snippet"

      case action
      when "create"
        abort "Must supply a snippet name as second parameter" unless name

        content = "# Put snippet content here."

        VCL::Fetcher.api_request(:post,"/service/#{id}/version/#{version}/snippet",{
          params: {
            name: name,
            type: options[:type] ? options[:type] : "recv",
            content: content,
            dynamic: 0 # todo: support dynamic snippet creation/updating
          }
        })
        say("#{name} created on #{id} version #{version}")

        unless File.exists?(filename)
          File.open(filename, 'w+') {|f| content }
          say("Blank snippet file created locally.")
          return
        end

        if yes?("Local file #{filename} found. Would you like to upload its content?")
          VCL::Fetcher.upload_snippet(id,version,File.read(filename),name)
          say("Local snippet file content successfully uploaded.")
        end
      when "delete"
        abort "Must supply a snippet name as second parameter" unless name

        VCL::Fetcher.api_request(:delete,"/service/#{id}/version/#{version}/snippet/#{name}")
        say("#{name} deleted on #{id} version #{version}")

        return unless File.exists?(filename)

        if yes?("Would you like to delete the local file #{name}.snippet associated with this snippet?")
          File.delete(filename)
          say("Local snippet file #{filename} deleted.")
        end
      when "list"
        snippets = VCL::Fetcher.api_request(:get,"/service/#{id}/version/#{version}/snippet")
        say("Listing all snippets for #{id} version #{version}")
        snippets.each do |d|
          say("#{d["name"]}: Subroutine: #{d["type"]}, Dynamic: #{d["dynamic"]}")
        end
      else
        abort "#{action} is not a valid command"
      end
    end
  end
end
