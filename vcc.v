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

//
// Tokenizer
//
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
		if s[loc].str() in '+-*/()' {
			tokens << new_token(TokenKind.reserved, s[loc].str(), loc)
			loc++
			continue
		}
		error_at(s, loc, 'unexpected character: $s[loc].str()')
	}
	tokens << new_token(TokenKind.eof, '', loc)
	return tokens
}

//
// Parser
//
enum NodeKind {
	add
	sub
	mul
	div
	num
}

struct Node {
	kind NodeKind
mut:
	val  int
	lhs  &Node = 0
	rhs  &Node = 0
}

fn new_node(kind NodeKind) Node {
	return Node{
		kind: kind
	}
}

fn new_binary(kind NodeKind, lhs &Node, rhs &Node) &Node {
	return &Node{
		kind: kind
		lhs: lhs
		rhs: rhs
	}
}

fn new_num(val int) &Node {
	return &Node{
		kind: .num
		val: val
	}
}

// expr = mul ("+" mul | "-" mul)*
fn expr(tokens []Token) ([]Token, &Node) {
	tok := tokens[0]
	mut rest, mut node := mul(tokens[1..])
	mut rhs := &Node{}
	for {
		if tok.str == '+' {
			rest, rhs = mul(rest)
			node = new_binary(.add, node, rhs)
			continue
		}
		if tok.str == '-' {
			rest, rhs = mul(rest)
			node = new_binary(.sub, node, rhs)
			continue
		}
		return rest, node
	}
}

// mul = primary ("*" primary | "/" primary)*
fn mul(tokens []Token) ([]Token, &Node) {
	tok := tokens[0]
	mut rest, mut node := primary(tokens[1..])
	mut rhs := &Node{}
	for {
		if tok.str == '*' {
			rest, rhs = mul(rest)
			node = new_binary(.mul, node, rhs)
			continue
		}
		if tok.str == '/' {
			rest, rhs = mul(rest)
			node = new_binary(.div, node, rhs)
			continue
		}
		return rest, node
	}
}

// primary = "(" expr ")" | num
fn primary(tokens []Token) ([]Token, &Node) {
	tok := tokens[0]
	if tok.str == '(' {
		rest, node := expr(tokens[1..])
		if tok.str == ')' {
			return rest, node
		} else {
			panic('hoge')
		}
	}
	node := new_num(tok.str.int())
	return tokens[1..], node
}
