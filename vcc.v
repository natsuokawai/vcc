import os

fn main() {
  if os.args.len != 2 {
    eprintln('${os.args[0]}: invalid number of arguments')
    return
  }

  input := os.args[1]

  println('.global main')
  println('main:')

  mut i   := 0
  mut num := ''
  for input[i].is_digit() {
    num += input[i]
    i++
  }
  println('  mov \$${num.int()}, %rax')

  for i < input.len {
    num = ''
    match input[i] {
      '+' {
        i++
        for input[i].is_digit() {
          num += input[i]
          i++
        }
        println('  add \$num, %rax')
      }
      '-' {
        i++
        for input[i].is_digit() {
          num += input[i]
          i++
        }
        println('  sub \$num, %rax')
      }
      else { eprintln('unexpected character: ${input[i]') }
    }
  }
  
  println('  ret')
  return 
}

