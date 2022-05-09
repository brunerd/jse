# jse
JSON String Encoder for scripters

Properly encode arbitrary input into JSON strings.

Use in conjunction with [jpt](https://guthub.com/brunerd/jpt) to _quickly_ encode multiple user input into JSON strings that can be written en masse with a JSONPatch document.

```
$jse
Usage: jse [-f] [argument]
  [-f] file flag to treat argument as a filepath
  [argument] convert string or contents of filepath to JSON string
  Input can also be via file redirection, piped input, here doc, or here string
```
