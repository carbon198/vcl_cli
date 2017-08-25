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
ruby build.rb
```

The same command also works to update to a new version.

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

You may find it useful to keep a Github repo with one folder created by this command for each service. This way you can version your VCL files.

## Command Reference

### activate

Activates a service version. 

Usage:

```
vcl activate
```

Flags: 
  * --s: The service ID to activate. Current working directory is assumed.
  * --v: The version to activate. Latest writable version is assumed.
 
### clone

[Admin only] Clones a service version to a new version on another service. 

Usage: 

```
vcl clone [sid_1] [sid_2]
```

Flags
  * --v: The version to clone. The currently active version is assumed.
  
### create_service

Creates a new service.

Usage:

```
vcl create_service [name]
```

Flags:
  * --c: [Admin only] The customer ID to create the service on. Requires entering your password.

### dictionary

Manipulate edge dictionaries on a service.

Usage:

```
vcl dictionary [action] [dictionary_name] [key] [value]
```

Available Actions:
  * create: Creates a new dictionary. Key and value parameters are omitted.
  * delete: Deletes a dictionary. Key and value parameters are omitted.
  * list: Lists all dictionaries. Key and value parameters are omitted.
  * upsert: Inserts a new item into a dictionary. If the item exists, its value will be updated.
  * remove: Removes an item from a dictionary.
  * list_items: Lists all items in a dictionary.
  * bulk_add: Adds multiple items to a dictionary. See [this documentation](https://docs.fastly.com/api/config#dictionary_item_dc826ce1255a7c42bc48eb204eed8f7f) for information on the format.

Flags:
  * --s: The service ID to use. Current working directory is assumed.
  * --v: The version to use. Latest writable version is assumed.

### diff

Provides a diff of two service versions. You may optionally specify which two service IDs and which two versions to diff. If you do not provide service IDs, the context of the current working directory is assumed. If you only provide one version, the current directory's VCL will be diffed against the specified version. If no versions are specified, the current directory's VCL will be diffed against the active version.

Usage:

```
vcl diff
```

  * --s1: The first service to diff against. The current working directory is assumed.
  * --v1: The version to diff. The currently active version is assumed.
  * --s2: The second service to diff against. The value of --s1 is assumed.
  * --v2: The second service's version to diff. The currently active version is assumed.
  * --g: Diffs the generated VCL instead of the custom VCL.

### domain

Manipulate domains on a service.

Usage:

```
vcl domain [action] [hostname]
```

Available Actions:
  * create: Create a new domain.
  * delete: Delete a domain.
  * list: List all domains.
  * check: Check the DNS of all domains on a service and print the status.

Flags:
  * --s: The service ID to use. Current working directory is assumed.
  * --v: The version to use. Latest writable version is assumed.

### download

Download the VCLs and snippets on a service. If you are not in a service directory already, a new directory will be created.

Usage:

```
vcl download
```

Flags:
  * --s: The service ID to download. Current working directory is assumed.
  * --v: The version to download. The currently active version is assumed.

### login

Login to the Fastly app and create an API token. This token will be stored in your home directory for the CLI to use for all requests.

Usage:

```
vcl login
```

### move

[Admin only] Move a service from one customer to another. Multiple service IDs may be comma separated.

Usage:

```
vcl move [sid] [cid]
```

### open

Opens the Fastly app for a service for a hostname of a service ID.

Usage:

```
vcl open [hostname]
```

Flags:
  * --s: The service ID to open. Current working directory is assumed.

### purge_all

Perform a purge all on a service.

Usage:

```
vcl purge_all
```
Flags:
  * --s: The service ID to purge. Current working directory is assumed.

### skeleton

Download the VCL boilerplate into the current directory.

Usage

```
vcl skeleton [local_filename]
```

### snippet

Manipulate snippets on a service.

Usage:

```
vcl snippet [action] [snippet_name]
```

Available Actions:
  * create: Create a new snippet
  * delete: Delete a snippet
  * list: List all snippets

Flags:
  * --s: The service ID to use. Current working directory is assumed.
  * --v: The version to use. Latest writable version is assumed.
  * --t: The type of snippet to create. Types are named after subroutines--for instance a snippet for `vcl_recv` would be of type `recv`. Use `init` for snippets outside of a subroutine.

### token

Manipulate tokens for an account.

Usage:

```
vcl token [action]
```

Available Actions:
  * create: Create a token
  * delete: Delete a token
  * list: List all tokens on the account

Flags:
  * --scope: Scope of the token. See Fastly's public API documentation for a [list of scopes](https://docs.fastly.com/api/auth#scopes).
  * --s: The services to restrict this token to. The token cannot be used to modify any services not on this list if this option is specified.

### upload

Upload VCLs and snippets to a service.

Usage:

```
vcl upload
```

Flags:
  * --v: The version to upload the VCL to. The latest writable version is assumed.

### watch

Watch live stats on a service.

Usage:

```
vcl watch [pop]
```

Flags:
  * --s: The service ID to watch. Current working directory is assumed.

## Contributing

Submit a pull request. Don't break anything.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

