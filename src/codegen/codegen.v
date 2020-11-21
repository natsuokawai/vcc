module codegen

import parse as p

pub fn gen(nodes []&p.Node) {
	mut top := 0
	println('.global main')
	println('main:')
	println('  push %r12')
	println('  push %r13')
	println('  push %r14')
	println('  push %r15')
	top = gen_expr(node, top)

	for node in nodes {
		gem_stmt(node, top)
		assert top == 0
	}

	println('  mov ${reg(top - 1)}, %rax')
	println('  pop %r15')
	println('  pop %r14')
	println('  pop %r13')
	println('  pop %r12')
	println('  ret')
}

fn gen_stmt(node &p.Node, t int) {
	mut top := t
	match node.kind {
		.expr_stmt {
			gem_expr(node.lhs)
			top--
			println('  mov ${reg(top)}, %rax')
			return
		}
		else {
			panic('invalid stmt')
		}
	}
}

fn gen_expr(node &p.Node, t int) int {
	mut top := t
	if node.kind == .num {
		println('  mov \$$node.val, ${reg(top)}')
		top++
		return top
	}
	top = gen_expr(node.lhs, top)
	top = gen_expr(node.rhs, top)
	rd := reg(top - 2)
	rs := reg(top - 1)
	top--
	match node.kind {
		.add {
			println('  add $rs, $rd')
		}
		.sub {
			println('  sub $rs, $rd')
		}
		.mul {
			println('  imul $rs, $rd')
		}
		.div {
			println('  mov $rd, %rax')
			println('  cqo')
			println('  idiv $rs')
			println('  mov %rax, $rd')
		}
		.eq {
			println('  cmp $rs, $rd')
			println('  sete %al')
			println('  movzb %al, $rd')
		}
		.ne {
			println('  cmp $rs, $rd')
			println('  setne %al')
			println('  movzb %al, $rd')
		}
		.lt {
			println('  cmp $rs, $rd')
			println('  setl %al')
			println('  movzb %al, $rd')
		}
		.le {
			println('  cmp $rs, $rd')
			println('  setle %al')
			println('  movzb %al, $rd')
		}
		else {
			panic('invalid expression')
		}
	}
	return top
}

fn reg(idx int) string {
	r := ['%r10', '%r11', '%r12', '%r13', '%r14', '%r15']
	if idx < 0 || r.len <= idx {
		panic('register out of index: $idx')
	}
	return r[idx]
}
