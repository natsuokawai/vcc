module parse

import tokenize as t

enum NodeKind {
	add
	sub
	mul
	div
	num
	eq
	ne
	lt
	le
}

struct Node {
pub:
	kind NodeKind
pub mut:
	val  int
	lhs  &Node = 0
	rhs  &Node = 0
}

pub fn parse(tokens []t.Token) ([]t.Token, &Node) {
	return expr(tokens)
}

// stmt = expr_stmt
fn stmt(tokens []t.Token) []&Node {
	return expr_stmt(tokens)
}

// expr_stmt = expr ";"
fn expr_stmt(tokens []t.Token) []&Node {
	mut nodes := []&Node{}
	mut rest := []t.Token{}
	mut node := &Node{}
	for rest.len > 0 {
		rest, node = expr(tokens)
		if rest[0].str() == ';' {
			nodes << node
			tokens = rest[1..]
		} else if rest[0].kind == .eof {
			return nodes
		} else{
			panic('expected ";"')
		}
	}
}

// expr = equality
fn expr(tokens []t.Token) ([]t.Token, &Node) {
	return equality(tokens)
}

// equality = relation ("==" relation | "!=" relation)
fn equality(tokens []t.Token) ([]t.Token, &Node) {
	mut tok := tokens[0]
	mut rest, mut node := relation(tokens)
	mut rhs := &Node{}
	for {
		if rest.len > 0 {
			tok = rest[0]
		}
		if tok.str == '==' {
			rest, rhs = relation(rest[1..])
			node = new_binary(.eq, node, rhs)
			continue
		}
		if tok.str == '!=' {
			rest, rhs = relation(rest[1..])
			node = new_binary(.ne, node, rhs)
			continue
		}
		return rest, node
	}
}

// relation = add ("<" add | "<=" add | ">" add | ">=" add)
fn relation(tokens []t.Token) ([]t.Token, &Node) {
	mut tok := tokens[0]
	mut rest, mut node := add(tokens)
	mut rhs := &Node{}
	for {
		if rest.len > 0 {
			tok = rest[0]
		}
		if tok.str == '<' {
			rest, rhs = add(rest[1..])
			node = new_binary(.lt, node, rhs)
			continue
		}
		if tok.str == '<=' {
			rest, rhs = add(rest[1..])
			node = new_binary(.le, node, rhs)
			continue
		}
		if tok.str == '>' {
			rest, rhs = add(rest[1..])
			node = new_binary(.lt, rhs, node)
			continue
		}
		if tok.str == '>=' {
			rest, rhs = add(rest[1..])
			node = new_binary(.le, rhs, node)
			continue
		}
		return rest, node
	}
}

// add = mul ("+" mul | "-" mul)*
fn add(tokens []t.Token) ([]t.Token, &Node) {
	mut tok := tokens[0]
	mut rest, mut node := mul(tokens)
	mut rhs := &Node{}
	for {
		if rest.len > 0 {
			tok = rest[0]
		}
		if tok.str == '+' {
			rest, rhs = mul(rest[1..])
			node = new_binary(.add, node, rhs)
			continue
		}
		if tok.str == '-' {
			rest, rhs = mul(rest[1..])
			node = new_binary(.sub, node, rhs)
			continue
		}
		return rest, node
	}
}

// mul = unary ("*" unary | "/" unary)*
fn mul(tokens []t.Token) ([]t.Token, &Node) {
	mut tok := tokens[0]
	mut rest, mut node := unary(tokens)
	mut rhs := &Node{}
	for {
		if rest.len > 0 {
			tok = rest[0]
		}
		if tok.str == '*' {
			rest, rhs = unary(rest[1..])
			node = new_binary(.mul, node, rhs)
			continue
		}
		if tok.str == '/' {
			rest, rhs = unary(rest[1..])
			node = new_binary(.div, node, rhs)
			continue
		}
		return rest, node
	}
}

// unary = ("+" | "-") unary
// | primary
fn unary(tokens []t.Token) ([]t.Token, &Node) {
	mut tok := tokens[0]
	if tok.str == '+' {
		return unary(tokens[1..])
	}
	if tok.str == '-' {
		rest, mut node := unary(tokens[1..])
		node = new_binary(.sub, new_num(0), node)
		return rest, node
	}
	return primary(tokens)
}

// primary = "(" expr ")" | num
fn primary(tokens []t.Token) ([]t.Token, &Node) {
	tok := tokens[0]
	if tok.str == '(' {
		rest, node := expr(tokens[1..])
		if rest[0].str == ')' {
			return rest[1..], node
		} else {
			panic('expected )')
		}
	}
	node := new_num(tok.str.int())
	rest := if tokens.len >= 2 { tokens[1..] } else { tokens[0..] }
	return rest, node
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