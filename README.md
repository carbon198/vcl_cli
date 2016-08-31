# VCL

CLI for manipulating VCLs. Intended to create a workflow around VCL editing.

Specifically for admins, there are several commands like clone and move that are much easier to use that interacting with the API directly.

## Dependencies

 * Ruby 2.2+
 * diff (installed on most unix systems by default)
 * Bundler 

## Installation

Clone the repo and then run the following command while in the vcl_cli directory:

```
sudo gem build vcl.gemspec && sudo gem install ./vcl-1.0.0.gem && sudo gem cleanup vcl
```

The same command also works to update to a new version.

## Usage

The following commands are available:

```
  vcl activate                                                    
  vcl clone SERVICE_ID TARGET_SERVICE_ID                          
  vcl create_service SERVICE_NAME                                 
  vcl dictionary ACTION DICTIONARY_NAME=none KEY=none VALUE=none  
  vcl diff                                                        
  vcl download VCL_NAME=all                                       
  vcl help [COMMAND]                                              
  vcl login                                                       
  vcl move SERVICE_ID TARGET_CUSTOMER                             
  vcl open DOMAIN                                                 
  vcl purge_all                                                   
  vcl skeleton NAME                                               
  vcl upload                                                      
  vcl version                                                     
  vcl waf                                                         
```

## Workflow

Basic setup for a service:

```
$ vcl download --service 72rdJo8ipqaHRFYnn12G2q
No VCLs on this service, however a folder has been created. Create VCLs in this folder and upload.
$ cd Sandbox\ -\ 72rdJo8ipqaHRFYnn12G2q/
$ vcl skeleton
Boilerplate written to main.vcl.
$ vcl upload
VCL main does not currently exist on the service, would you like to create it? y
[You will see a diff here for the new VCL]
Given the above diff, are you sure you want to upload your changes? y
main uploaded to 72rdJo8ipqaHRFYnn12G2q
VCL(s) have been uploaded to version 286 and validated.
$ vcl activate
Version 286 on 72rdJo8ipqaHRFYnn12G2q activated.
```

Once you are past this point you can edit your VCLs and use the commmand `vcl upload && vcl activate`. The service ID will be automatically inferred from the folder you are currently in. In fact, all commands will attempt to assume the service ID of the current directory if it is relevant.

You may find it useful to keep a Github repo with one folder created by this command for each directory. This way you can version your VCL files.

## Contributing

Submit a pull request. Don't break anything.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

