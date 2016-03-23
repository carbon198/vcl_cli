require "typhoeus"
require "thor"
require "diffy"
require "json"
require "uri"

require "vcl/version"
require "vcl/fetcher"
require "vcl/utils"

module VCL
  COOKIE_JAR = ENV['HOME'] + "/vcl_cookie_jar"
  FASTLY_API = "https://api.fastly.com"
  FASTLY_APP = "https://app.fastly.com"

  Cookies = File.exist?(VCL::COOKIE_JAR) ? JSON.parse(File.read(VCL::COOKIE_JAR)) : {}
end
