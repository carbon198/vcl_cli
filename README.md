# VCL

CLI for manipulating VCLs. Intended to create a workflow around VCL editing. The end goal will be to support development -> staging -> production deployment and Github integration. 

Specifically for admins, there are several commands like clone and move that are much easier to use that interacting with the API directly.

## Dependencies

 * Ruby 2.2+
 * diff (installed on most unix systems by default)
 * Bundler 

## Installation

Clone the repo and then run the following command while in the vcl_cli directory:

```
sudo gem build vcl.gemspec && sudo gem install ./vcl-0.2.1.gem && sudo gem cleanup vcl
```

The same command also works to update to a new version.

## Usage

The following commands are available:

```
$ vcl
Commands:
  vcl activate                                                    # Activates a service version. Options: --service, --version
  vcl clone SERVICE_ID TARGET_SERVICE_ID                          # Clone a service version to another service.
  vcl create_service CUSTOMER_ID SERVICE_NAME DOMAIN ORIGIN       # Create a blank service for a customer.
  vcl dictionary ACTION DICTIONARY_NAME=none KEY=none VALUE=none  # Manipulate edge dictionaries. Actions: create, delete, list, add, update, remove, list_...
  vcl diff SERVICE_ID VERSION1 VERSION2                           # Diff two versions on the same service. Options: --generated
  vcl diff_local                                                  # Diff VCL on Fastly with local VCL. Options: --version
  vcl diff_services SERVICE_ID1 VERSION1 SERVICE_ID2 VERSION2     # Diff versions on two different services. Options: --generated
  vcl download VCL_NAME=all                                       # Download VCLs. Options: --service, --version
  vcl help [COMMAND]                                              # Describe available commands or one specific command
  vcl login                                                       # Logs into the app. Required before doing anything else.
  vcl move SERVICE_ID TARGET_CUSTOMER                             # Move a service to a new customer
  vcl open DOMAIN                                                 # Find the service ID for a domain and open the Fastly app. Options: --sierra
  vcl services CUSTOMER_ID                                        # Lists services for a customer.
  vcl upload                                                      # Uploads VCL in the current directory to the service. Options: --version
  vcl version                                                     # Displays version of the VCL gem.
  vcl waf                                                         # Download WAF VCLs
```

`vcl download` pulls down all vcls for a service and puts them in a directory for the service. Once you navigate into the directory, the context of that service is assumed by several commands. 

## Contributing

Submit a pull request. Don't break anything.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

