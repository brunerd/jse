#!/usr/bin/env zsh
#!/usr/bin/env bash
#choose your shell with the first line, works in either

: <<-LICENSE_BLOCK
jse.min - JSON String Encoder (minified) (https://github.com/brunerd/jse) Copyright (c) 2024 Joel Bruner (https://github.com/brunerd)
Licensed under the MIT License. Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
LICENSE_BLOCK

#copy the function below to embed jse into your shell scripts
## jse function begin ##
function jse()(
{ set +x; } &> /dev/null;helpText='jse (v1.1) - JSON String Encoder (https://github.com/brunerd/jse)\nUsage: jse [-u] [-f] [argument]\n  -f file flag, treat argument as a filepath\n  -u encode Unicode characters with \\u escaping\n  argument – string or filepath to encode as JSON string\n  Input can also be via file redirection, piped input, here doc, or here string'
read -r -d '' JSCode <<-'EOT'
var argument=decodeURIComponent(escape(arguments[0]));var optionsArg = arguments[1] || '{}';var option = {};for (var i=0; i < optionsArg.length; i++) {switch (optionsArg.charAt(i)) { default: option[optionsArg.charAt(i)]=true; break; }};if (option.f) {try { var text = readFile(argument) } catch(error) { throw new Error(error); quit();};if (argument === "/dev/stdin") { text = text.slice(0,-1) }}else {var text=argument};print(JSON.stringify(text,null,0).replace((option.u ? /[\u0000-\u001f\u007f-\uffff]/g : /\u007f/g), function(chr) { return "\\u" + ("0000" + chr.charCodeAt(0).toString(16)).slice(-4)}))
EOT
jsc=$(find "/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/" -name 'jsc');[ -z "${jsc}" ] && jsc=$(which jsc);[ -n "$BASH_VERSION" ] && unset OPTIND OPTARG;while getopts ":fhu" optionArg; do case "${optionArg}" in 'h')echo -e "${helpText}" >&2;return 0;;*)optionArgs+="${optionArg}";;esac;done;[ $OPTIND -ge 2 ] && shift $((OPTIND-1));if ! [ -t '0' ]; then optionArgs+="f";"${jsc}" -e "${JSCode}" -- "/dev/stdin" "${optionArgs}" <<< "$(cat)";else argument="${1}";if [ -z "${argument}" ]; then echo -e "${helpText}">&2;exit 0;elif grep -q "f" <<< "${optionArgs}" && ! [ -f "${argument}" ]; then echo "File not found: \"${argument}\"" >&2;exit 1;fi;"${jsc}" -e "${JSCode}" -- "${argument}" "${optionArgs}";fi
)
## jse function end ##

#call jse() with all arguments
jse "$@" 
exit $?
