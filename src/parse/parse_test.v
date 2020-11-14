module parse

import tokenize as t

fn binary_operator_test(input string, op NodeKind, lvalue int, rvalue int) {
	tokens := t.tokenize(input) or {
		eprintln(err)
		exit(1)
	}
	_, actual := expr(tokens)
	assert actual.kind == op
	assert actual.lhs.kind == .num
	assert actual.lhs.val == lvalue
	assert actual.rhs.kind == .num
	assert actual.rhs.val == rvalue
}

fn test_add() {
	binary_operator_test('1 +3', .add, 1, 3)
	binary_operator_test('5 - 3', .sub, 5, 3)
}

fn test_mul() {
	binary_operator_test('4 * 3', .mul, 4, 3)
	binary_operator_test('4 / 2', .div, 4, 2)
}

fn test_relation() {
	binary_operator_test('0 >= 1', .le, 1, 0)
	binary_operator_test('0 <= 1', .le, 0, 1)
	binary_operator_test('0 > 1',  .lt, 1, 0)
	binary_operator_test('0 < 1',  .lt, 0, 1)
}

fn test_equality() {
	binary_operator_test('0 == 1', .eq, 0, 1)
	binary_operator_test('0 != 1', .ne, 0, 1)
}

fn test_unary() {
	tokens := t.tokenize('-1') or {
		eprintln(err)
		exit(1)
	}
	_, actual := expr(tokens)
	
	assert actual.kind == .sub
	assert actual.lhs.val == 0
	assert actual.rhs.val == 1
}

fn test_expr() {
	input := '6 - 9* 3'

	tokens := t.tokenize(input) or {
		eprintln(err)
		exit(1)
	}
	_, actual := expr(tokens)

	assert actual.kind == .sub
	
	assert actual.lhs.val == 6
	
	assert actual.rhs.kind == .mul
	assert actual.rhs.lhs.val == 9
	assert actual.rhs.rhs.val == 3
}
