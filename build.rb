require_relative 'lib/vcl/version.rb'

system("sudo gem build vcl.gemspec && sudo gem install ./vcl-#{VCL::VERSION}.gem && sudo gem cleanup vcl")
