import os

fn main() {
  if os.args.len != 2 {
    eprintln('${os.args[0]}: invalid number of arguments')
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
  return error('invalid operator: $op')
}

