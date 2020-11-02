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
					println('  mov \$$token.num, %rax')
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
						println('  add \$${tokens[i].num}, %rax')
					}
					'-' {
						i++
						println('  sub \$${tokens[i].num}, %rax')
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
mut:
	num  int
}

fn new_token(kind TokenKind, str string) &Token {
	return &Token{
		kind: kind
		str: str
	}
}

fn tokenize(input_str string) ?[]Token {
	mut s := input_str.clone()
	mut tokens := []Token{}
	mut str := ''
	mut i := 0
	for i < s.len {
		if s[i].is_space() {
			i++
			continue
		}
		if s[i].is_digit() {
			str = read_number(s[i..])
			tokens << new_token(TokenKind.num, str)
			tokens[tokens.len - 1].num = str.int()
			i += str.len
			continue
		}
		if s[i].str() in '+-' {
			tokens << new_token(TokenKind.reserved, s[i].str())
			i++
			continue
		}
		return error('unexpected character: ${s[i]}')
	}
	tokens << new_token(TokenKind.eof, '')
	return tokens
}
