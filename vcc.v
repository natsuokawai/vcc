import os

fn main() {
	if os.args.len != 2 {
		eprintln('${os.args[0]}: invaid number of arguments')
		exit(1)
	}
	tokens := tokenize(os.args[1]) or {
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
					eprintln('Number is expected.')
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
						eprintln('unexpected character: $token.str')
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

fn read_number(s string) string {
	mut num := ''
	for char in s {
		if !char.is_digit() {
			break
		}
		num += char.str()
	}
	return num
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
		return error('unexpected character: ${s[loc]}')
	}
	tokens << new_token(TokenKind.eof, '', loc)
	return tokens
}
