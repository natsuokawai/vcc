import os

fn main() {
  if os.args.len != 2 {
    eprintln('${os.args[0]}: invalid number of arguments')
    return
  }

  println('.global main')
  println('main:')
  println('  mov \$${os.args[1]}, %rax')
  println('  ret')
  return 
}
