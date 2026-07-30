import std/io

tor get-from-network {} -> string<tainted!>
get-from-network -> "Hello, World!"

tor validate-response { response: string<!tainted> } -> string
validate-response => response

get-from-network(): response
|> validate-response(response)
|> std/io:print.ln("From network: {{response:s}}")

// This should fail because the result is discharged(?)
// Is that an issue where `expr: Expression` needs to handle this specifically?
