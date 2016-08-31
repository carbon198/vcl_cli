module VCL
  module Utils
    def self.open_service(id)
      Launchy.open(VCL::FASTLY_APP + VCL::TANGO_PATH + id)
    end

    def self.parse_directory(path=false)
      directory = Dir.pwd unless path
      directory = path if path

      id = directory.match(/.* \- ([^\-]*)$/i)
      id = id == nil ? false : id.captures[0]

      return id
    end

    def self.parse_name(path=false)
      directory = Dir.pwd unless path
      directory = path if path

      name = directory.match(/(.*) \- [^\-]*$/i)
      name = name == nil ? false : name.captures[0]

      return name
    end

    def self.get_diff(old_vcl,new_vcl)
      options = {
        include_diff_info: true, 
        diff: ["-E", "-p"],
        context: 3
      }
      return Diffy::Diff.new(old_vcl, new_vcl, options).to_s(:color)
    end

    def self.diff_generated(v1,v2)
      diff = ""

      diff << "\n" + self.get_diff(v1["content"], v2["content"])

      return diff
    end

    def self.diff_versions(v1,v2)
      diff = ""
      v1 ||= Array.new
      v2 ||= Array.new

      v1.each do |vcl1|
        v2_content = false

        v2.each do |vcl2|
          v2_content = vcl2["content"] if (vcl1["name"] == vcl2["name"])
          if (v2_content)
            vcl2["matched"] = true
            break
          end
        end

        v2_content = "" unless v2_content

        diff << "\n" + self.get_diff(vcl1["content"], v2_content)
      end

      v2.each do |vcl|
        diff << "\n" +  self.get_diff("", vcl["content"]) if !(vcl.has_key? "matched")
      end

      return diff
    end
  end
end