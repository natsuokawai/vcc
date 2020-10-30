import os

fn main() {
  if os.args.len != 2 {
    eprintln('${os.args[0]}: inopid number of arguments')
    return
  }

  mut input_str := os.args[1]
  mut num := 0
  mut op  := ''

  println('.global main')
  println('main:')

  num, input_str = consume_number(input_str)
  println('  mov \$$num, %rax')

  for input_str.len > 0 {
    op, input_str = consume_operator(input_str) or { exit(1) }
    match op {
      '+' {
        num, input_str = consume_number(input_str)
        println('  add \$$num, %rax')
      }
      '-' {
        num, input_str = consume_number(input_str)
        println('  sub \$$num, %rax')
      }
      else {
        eprintln('unexpected character: $op')
        return
      }
    }
  }

  println('  ret')
  return
}

fn consume_number(s string) (int, string) {
  mut num := ''
  mut i   := 0
  for i < s.len && s[i].is_digit() {
    num += s[i].str()
    i++
  }
  return num.int(), s.substr(i, s.len)
}

fn consume_operator(s string) ?(string, string) {
  op := s[0].str()
  if op in '+-' {
    return op, s.substr(1, s.len)
  }
  return error('inopid operator: $op')
}

enum TokenKind {
  reserved
  num
  eof
}

struct Token {
  kind TokenKind
  char string
  len  int
mut:
	num  int
  next &Token
}

fn new_token(mut cur_token &Token, kind TokenKind, char string, len int) &Token {
	new := &Token{next: &Token{}, kind: kind, char: char, len: len}
  cur_token.next = new
  return &new
}

fn tokenize(s string) ?&Token {
  mut head := &Token{}
	mut num  := 0
	mut op   := ''
	mut rest := ''

  num, rest = consume_number(s)
  mut cur_token := new_token(mut head, TokenKind.num, num.str(), (s.len - rest.len))
	cur_token.num = num

  for rest.len > 0 {
    op, rest = consume_operator(rest) or { exit(1) }
		if rest[0].is_digit() {
      num, rest = consume_number(rest)
			cur_token = new_token(mut cur_token, TokenKind.num, num.str(), (s.len - rest.len))
			cur_token.num = num
		} else if rest[0].str() in '+=' {
			op, rest = consume_operator(rest) or { exit(1) }
			cur_token = new_token(mut cur_token, TokenKind.reserved, op, (s.len - rest.len))
		} else {
      return error('unexpected character: $op')
		}
  }

  cur_token = new_token(mut cur_token, TokenKind.eof, '', 0)

  return head.next
}

