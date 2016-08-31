module VCL
  class CLI < Thor
    desc "diff", "Diff two service versions. By default, diffs the active version of the service assumed from the current directory with the local VCL in the current directory. Options allow you to specify different versions and different services."
    option :version1
    option :version2
    option :service1
    option :service2
    option :generated
    def diff
      if !options[:service1]
        service1 = VCL::Utils.parse_directory
        abort "Could not parse service id from directory" unless service1
      else
        service1 = options[:service1]
      end
      if !options[:service2]
        service2 = VCL::Utils.parse_directory
        abort "Could not parse service id from directory" unless service2
      else
        service2 = options[:service2]
      end

      # if both are specified, diff them
      if options[:version1] && options[:version2]
        version1 = options[:version1]
        version2 = options[:version2]
      end
      # if version1 is not specified, diff local with version 2
      if !options[:version1] && options[:version2]
        version1 = false
        version2 = options[:version2]
      end
      # if version2 is not specified, diff local with version 1
      if options[:version1] && !options[:version2]
        version1 = options[:version1]
        version2 = false
      end
      # if neither are specified, diff local with active version
      if !options[:version1] && !options[:version2]
        version1 = VCL::Fetcher.get_active_version(service2)
        version2 = false
      end

      say("Diffing#{options[:generated] ? " generated VCL for" : ""} #{service1} #{version1 ? "version "+version1.to_s : "local VCL"} with #{service2} #{version2 ? "version "+version2.to_s : "local VCL"}.")

      if version1
        v1_vcls = VCL::Fetcher.get_vcl(service1, version1,options[:generated])
      else
        abort "Cannot diff generated VCL with local VCL" if options[:generated]
        Dir.foreach(Dir.pwd) do |p|
          next unless File.file?(p)
          next unless p =~ /\.vcl$/

          v1_vcls ||= Array.new
          v1_vcls << {
            "name" => p.chomp(".vcl"),
            "content" => File.read(p)
          }
        end
      end

      if version2
        v2_vcls = VCL::Fetcher.get_vcl(service2, version2,options[:generated])
      else
        abort "Cannot diff generated VCL with local VCL" if options[:generated]
        Dir.foreach(Dir.pwd) do |p|
          next unless File.file?(p)
          next unless p =~ /\.vcl$/

          v2_vcls ||= Array.new
          v2_vcls << {
            "name" => p.chomp(".vcl"),
            "content" => File.read(p)
          }
        end
      end

      if options[:generated]
        say(VCL::Utils.diff_generated(v1_vcls,v2_vcls))
      else
        say(VCL::Utils.diff_versions(v1_vcls,v2_vcls))
      end

    end
  end
end
