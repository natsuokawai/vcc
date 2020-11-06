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
	_, node := expr(tokens)
	gen(node)
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
			panic('expected )')
		}
	}
	node := new_num(tok.str.int())
	return tokens[1..], node
}

//
// Code generator
//
fn gen(node &Node) {
	mut top := 0
	println('.global main')
	println('main:')
	println('  push %r12')
	println('  push %r13')
	println('  push %r14')
	println('  push %r15')

	top = gen_expr(node, top)

	println('  mov ${reg(top - 1)}, %rax')

	println('  pop %r15')
	println('  pop %r14')
	println('  pop %r13')
	println('  pop %r12')
	println('  ret')
}

fn gen_expr(node &Node, t int) int {
	mut top := t
	if node.kind == .num {
		top++
		println('  mov \$$node.val, ${reg(top)}')
	}

	top = gen_expr(node.lhs, top)
	top = gen_expr(node.rhs, top)
	
	rd := reg(top - 2)
	rs := reg(top - 1)
	top--

	match node.kind {
		.add { println('  add $rs, $rd') }
		.sub { println('  sub $rs, $rd') }
		.mul { println('  imul $rs, $rd') }
		.div {
			println('  mov $rd, %rax')
			println('  cqo')
			println('  idiv $rs')
			println('  mov %rax, $rd')
		}
		else { panic('invalid expression')}
	}

	return top
}

fn reg(idx int) string {
	r := ['r10', 'r11', 'r12', 'r13', '14', 'r15']
	if idx < 0 || r.len <= idx {
		panic('register out of index: $idx')
	}
	return r[idx]
}