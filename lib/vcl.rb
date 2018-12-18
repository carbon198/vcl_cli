require "typhoeus"
require "thor"
require "diffy"
require "json"
require "uri"
require "launchy"
require "erb"
require "pp"

require "vcl/version"
require "vcl/fetcher"
require "vcl/utils"
require "vcl/cli"

include ERB::Util

module VCL
  COOKIE_JAR = ENV['HOME'] + "/.vcl_cookie_jar"
  TOKEN_FILE = ENV['HOME'] + "/.vcl_token"
  FASTLY_API = "https://api.fastly.com"
  FASTLY_APP = "https://manage.fastly.com"
  TANGO_PATH = "/configure/services/"

  Cookies = File.exist?(VCL::COOKIE_JAR) ? JSON.parse(File.read(VCL::COOKIE_JAR)) : {}
  Token = File.exist?(VCL::TOKEN_FILE) ? File.read(VCL::TOKEN_FILE) : false
end
