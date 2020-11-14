module tokenize

struct Expected {
	kind TokenKind
	str  string
}

fn test_tokenize() {
	input := '1 + 42 * (9- 3) / 4 < 6 <= 10 == 0 >= 0 > 0'

	actual := tokenize(input) or {
		eprintln(err)
		exit(1)
	}

	tests := [
		Expected{kind: .num,      str: '1'},
		Expected{kind: .reserved, str: '+'},
		Expected{kind: .num,      str: '42'},
		Expected{kind: .reserved, str: '*'},
		Expected{kind: .reserved, str: '('},
		Expected{kind: .num,      str: '9'},
		Expected{kind: .reserved, str: '-'},
		Expected{kind: .num,      str: '3'},
		Expected{kind: .reserved, str: ')'},
		Expected{kind: .reserved, str: '/'},
		Expected{kind: .num,      str: '4'},
		Expected{kind: .reserved, str: '<'},
		Expected{kind: .num,      str: '6'},
		Expected{kind: .reserved, str: '<='},
		Expected{kind: .num,      str: '10'},
		Expected{kind: .reserved, str: '=='},
		Expected{kind: .num,       str: '0'},
		Expected{kind: .reserved, str: '>='},
		Expected{kind: .num,      str: '0'},
		Expected{kind: .reserved, str: '>'},
		Expected{kind: .num,      str: '0'},
		Expected{kind: .eof, str: ''}
	]

	assert actual.len == tests.len

	for i, test in tests {
		assert actual[i].kind == test.kind
		assert actual[i].str == test.str
	}
}
