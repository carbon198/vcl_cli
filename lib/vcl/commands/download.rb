module VCL
  class CLI < Thor
    desc "download VCL_NAME=all", "Download VCLs. If no name is specified, downloads all the VCLs on the service."
    option :service
    option :version
    option :generated
    def download(vcl_name=false)
      parsed_id = VCL::Utils.parse_directory

      if options[:service]
        abort "Already in a service directory, go up one level in order to specify"\
              "service id with --service." if parsed_id
        id = options[:service]
        parsed = false
      else
        abort "Could not parse service id from directory. Specify service id with "\
              "--service option or use from within service directory." unless parsed_id
        id = parsed_id
        parsed = true
      end

      service = VCL::Fetcher.api_request(:get, "/service/#{id}/details")

      version = VCL::Fetcher.get_active_version(id) unless options[:version]
      version ||= options[:version]

      if options[:generated]
        generated = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/generated_vcl")
        File.open("generated.vcl", 'w+') {|f| f.write(generated["content"]) }
        abort "Generated VCL for version #{version} written to generated.vcl."
      end

      vcl = VCL::Fetcher.get_vcl(id, version)

      folder_name = parsed ? "./" : "#{service["name"]} - #{service["id"]}/"
      Dir.mkdir(folder_name) unless (File.directory?(folder_name) || parsed)

      if vcl

      vcl.each do |v,k|
          next if (vcl_name && vcl_name != v["name"])

          filename = "#{folder_name}#{v["name"]}.vcl"

          if File.exist?(filename)
            unless yes?("Are you sure you want to overwrite #{filename}")
              say("Skipping #{filename}")
              next
            end
          end

          File.open(filename, 'w+') {|f| f.write(v["content"]) }

          say("VCL content for version #{version} written to #{filename}")
        end
      else
        say("No VCLs on this service, however a folder has been created. Create VCLs in this folder and upload.")
      end
    end
  end
end
