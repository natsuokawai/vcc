import os
import parse
import tokenize
import codegen

fn main() {
	if os.args.len != 2 {
		eprintln('${os.args[0]}: invaid number of arguments')
		exit(1)
	}
	user_input := os.args[1]
	tokens := tokenize.tokenize(user_input) or {
		eprintln(err)
		exit(1)
	}
	_, node := parse.expr(tokens)
	codegen.gen(node)
}