import os

fn main() {
	if os.args.len != 2 {
		eprintln('${os.args[0]}: invaid number of arguments')
		exit(1)
	}
	user_input := os.args[1]
	tokens := tokenize(user_input) or {
		eprintln(err)
		exit(1)
	}
	println('.global main')
	println('main:')
	for i := 0; i < tokens.len; i++ {
		token := tokens[i]
		match token.kind {
			.num {
				if token.kind == TokenKind.num {
					println('  mov \$$token.str, %rax')
				} else {
					error_tok(user_input, token, 'Number is expected.')
					exit(1)
				}
				continue
			}
			.reserved {
				match token.str {
					'+' {
						i++
						println('  add \$${tokens[i].str}, %rax')
					}
					'-' {
						i++
						println('  sub \$${tokens[i].str}, %rax')
					}
					else {
						error_tok(user_input, token, 'unexpected character: $token.str')
						exit(1)
					}
				}
			}
			.eof {
				break
			}
		}
	}
	println('  ret')
	return
}

fn error_at(current_input string, loc int, str string) {
	spaces := ' '.repeat(loc)
	eprintln(current_input)
	eprintln('$spaces^ $str')
	exit(1)
}

fn error_tok(current_input string, tok Token, str string) {
	error_at(current_input, tok.loc, str)
}

fn read_number(s string) string {
	mut loc := 0
	for loc < s.len && s[loc].is_digit() {
		loc++
	}
	return s[0..loc]
}

enum TokenKind {
	reserved
	num
	eof
}

struct Token {
	kind TokenKind
	str  string
	loc  int
}

fn new_token(kind TokenKind, str string, loc int) &Token {
	return &Token{
		kind: kind
		str: str
		loc: loc
	}
}

fn tokenize(input_str string) ?[]Token {
	mut s := input_str.clone()
	mut tokens := []Token{}
	mut str := ''
	mut loc := 0
	for loc < s.len {
		if s[loc].is_space() {
			loc++
			continue
		}
		if s[loc].is_digit() {
			str = read_number(s[loc..])
			tokens << new_token(TokenKind.num, str, loc)
			loc += str.len
			continue
		}
		if s[loc].str() in '+-' {
			tokens << new_token(TokenKind.reserved, s[loc].str(), loc)
			loc++
			continue
		}
		error_at(s, loc, 'unexpected character: $s[loc].str()')
	}
	tokens << new_token(TokenKind.eof, '', loc)
	return tokens
}
