module VCL
  class CLI < Thor
    desc "upload", "Uploads VCL in the current directory to the service."
    option :version
    def upload
      id = VCL::Utils.parse_directory

      abort "could not parse service id from directory" unless id

      vcls = {}

      Dir.foreach(Dir.pwd) do |p|
        next unless File.file?(p)
        next unless p =~ /\.vcl$/
        vcls[p.chomp(".vcl")] = {"content" => File.read(p), "name" => p.chomp(".vcl")}
      end

      writable_version = VCL::Fetcher.get_writable_version(id) unless options[:version]
      writable_version ||= options[:version].to_i
      active_version = VCL::Fetcher.get_active_version(id);

      old_vcls = VCL::Fetcher.get_vcl(id, active_version)

      main_found = false

      old_vcls ||= {}
      old_vcls.each do |v|
        next unless vcls.has_key? v["name"]
        diff = VCL::Utils.get_diff(v["content"], vcls[v["name"]]["content"])

        vcls[v["name"]]["matched"] = true
        vcls[v["name"]]["new"] = false
        main_found = vcls[v["name"]]["main"] = v["main"] == true ? true : false
        vcls[v["name"]]["diff_length"] = diff.length

        next if diff.length < 2

        say(diff)
      end

      vcls.delete_if do |k,v|
        if (v["matched"] == true)
          #dont upload if the file isn't different from the old file
          if (v["diff_length"] > 1)
            false
          else
            true
          end
        elsif yes?("VCL #{v["name"]} does not currently exist on the service, would you like to create it?")
          v["new"] = true
          if !main_found
            v["main"] = true 
            main_found = true
          end
          say(VCL::Utils.get_diff("", v["content"]))
          false
        else 
          say("Not uploading #{v["name"]}")
          true
        end
      end

      abort unless yes?("Given the above diff, are you sure you want to upload your changes?")

      vcls.each do |k,v|
        VCL::Fetcher.upload_vcl(id, writable_version, v["content"], v["name"], v["main"], v["new"])

        say("#{v["name"]} uploaded to #{id}")
      end

      validation = VCL::Fetcher.api_request(:get, "/service/#{id}/version/#{writable_version}/validate")

      abort "Compiler reported the following error with the generated VCL: #{validation["msg"]}" if validation["status"] == "error"

      say("VCL(s) have been uploaded to version #{writable_version} and validated.")
    end
  end
end
