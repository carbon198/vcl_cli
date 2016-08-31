module VCL
  class CLI < Thor
    desc "skeleton NAME", "Create a skeleton VCL file with the current boilerplate. Options: --service"
    option :service
    def skeleton(name="main")
      id = VCL::Utils.parse_directory unless options[:service]
      id ||= options[:service]
      abort "could not parse service id from directory" unless id

      filename = "#{name}.vcl"
      version = VCL::Fetcher.get_active_version(id)
      boilerplate = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{version}/boilerplate")

      if (File.exist?(filename))
        say("#{filename} exists, please delete it if you want this command to overwrite it.")
        abort
      end

      File.open(filename , 'w+') {|f| f.write(boilerplate) }

      say("Boilerplate written to #{filename}.")
    end
  end
end
