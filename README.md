# jse
JSON String Encoder for scripters

Properly encode arbitrary input into JSON strings.

Use in conjunction with [jpt](https://guthub.com/brunerd/jpt) to _quickly_ encode strings into JSON strings that can be written en masse with a JSONPatch document.

## Usage:
```
% jse
jse (v1.1) - JSON String Encoder (https://github.com/brunerd/jse)
Usage: jse [-u] [-f] [argument]
  -f file flag, treat argument as a filepath
  -u encode Unicode characters with \u escaping
  argument – string or filepath to encode as JSON string
  Input can also be via file redirection, piped input, here doc, or here string
```

## Examples:
```
#input as a parameter
% jse 'Wow "cool" 😎' 
"Wow \"cool\" 😎"

#same with -u to escape unicode above 0x7e
% jse -u 'Wow "cool" 😎' 
"Wow \"cool\" \ud83d\ude0e"

#input via pipe
% echo 'Totally "rad" 🤙' | jse   
"Totally \"rad\" 🤙"

#input as a here doc
% jse <<EOT
This line
        tabbed line 2
EOT
"This line\n\ttabbed line 2"

#input from file
% jse -f /private/etc/shells 
"# List of acceptable shells for chpass(1).\n# Ftpd will not allow users to connect who are not using\n# one of these shells.\n\n/bin/bash\n/bin/csh\n/bin/dash\n/bin/ksh\n/bin/sh\n/bin/tcsh\n/bin/zsh\n"
```

### Requirements:
* macOS 10.11+ or \*nix with jsc installed

### Limitations:
* Max JSON input size is 2GB
* Max output is 720MB

### Installation
A macOS pkg is available in [Releases](https://github.com/brunerd/jse/releases) it will install both the commented `jse.sh` and the minified version `jse.min.sh` into `/usr/local/jse` and create the symlink `jse` in `/usr/local/bin`.
