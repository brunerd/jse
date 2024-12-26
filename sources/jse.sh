#!/usr/bin/env zsh
#!/usr/bin/env bash
#choose your shell with the first line, works in either

: <<-LICENSE_BLOCK
jse - JSON String Encoder (https://github.com/brunerd/jse) Copyright (c) 2024 Joel Bruner (https://github.com/brunerd)
Licensed under the MIT License. Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
LICENSE_BLOCK

#copy the function below to embed jse into your shell scripts, jse.min a minified version is also available
function jse()(
	{ set +x; } &> /dev/null
	helpText='jse (v1.1) - JSON String Encoder (https://github.com/brunerd/jse)\nUsage: jse [-u] [-f] [argument]\n  -f file flag, treat argument as a filepath\n  -u encode Unicode characters with \\u escaping\n  argument – string or filepath to encode as JSON string\n  Input can also be via file redirection, piped input, here doc, or here string'
	read -r -d '' JSCode <<-'EOT'
		//escape and decode needed to avoid emoji mangling
		var argument=decodeURIComponent(escape(arguments[0]));	
		//only expecting ascii no need to escape and decode
		var optionsArg = arguments[1] || '{}';
		//read in all the option characters, set each to true in option object
		var option = {};
		for (var i=0; i < optionsArg.length; i++) {
			switch (optionsArg.charAt(i)) { default: option[optionsArg.charAt(i)]=true; break; }
		};		
		if (option.f) {
			//load the file, throw if error but script should catch that
			try { var text = readFile(argument) } catch(error) { throw new Error(error); quit(); };
			//remove trailing newline that get appended
			if (argument === "/dev/stdin") { text = text.slice(0,-1) }
		}
		else { 
			var text=argument
		};
		//print JSON with either normal escaping or escape all unicode 0x7f and above
		print(JSON.stringify(text,null,0).replace((option.u ? /[\u0000-\u001f\u007f-\uffff]/g : /\u007f/g), function(chr) { return "\\u" + ("0000" + chr.charCodeAt(0).toString(16)).slice(-4)}))
	EOT
	
	#jsc changed location in 10.15, or perhaps this some other *nix
	jsc=$(find "/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/" -name 'jsc');[ -z "${jsc}" ] && jsc=$(which jsc);

	[ -n "$BASH_VERSION" ] && unset OPTIND OPTARG
	while getopts ":fhu" optionArg; do
		case "${optionArg}" in
			#-f file argument
			'h')echo -e "${helpText}" >&2;return 0;;
			#append option letters to each other
			*)optionArgs+="${optionArg}";;
		esac
	done
	#shift if we had args so $1 is our string
	[ $OPTIND -ge 2 ] && shift $((OPTIND-1))

	#something is coming in via pipe or file redirection
	if ! [ -t '0' ]; then
		#append f option (u option may be set)
		optionArgs+="f"
		"${jsc}" -e "${JSCode}" -- "/dev/stdin" "${optionArgs}" <<< "$(cat)"
	#nothing coming in via pipe or redirection
	else
		argument="${1}"

		#no argument
		if [ -z "${argument}" ]; then
			echo -e "${helpText}">&2
			exit 0
		#if we specify -f with invalid file path			
		elif grep -q "f" <<< "${optionArgs}" && ! [ -f "${argument}" ]; then
			echo "File not found: \"${argument}\"" >&2
			exit 1
		fi
		
		"${jsc}" -e "${JSCode}" -- "${argument}" "${optionArgs}"
	fi
)
## jse function end ##

#call jse() with all arguments
jse "$@" 
exit $?
