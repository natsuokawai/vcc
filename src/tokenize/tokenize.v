module tokenize

enum TokenKind {
	reserved
	num
	eof
}

struct Token {
pub:
	kind TokenKind
	str  string
	loc  int
}

pub fn tokenize(input_str string) ?[]Token {
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
			tokens << new_token(.num, str, loc)
			loc += str.len
			continue
		}
		if s[loc].str() in '+-*/();' {
			tokens << new_token(.reserved, s[loc].str(), loc)
			loc++
			continue
		}
		if s[loc].str() in '!=<>' {
			if s[loc..].len >= 2 && s[loc + 1].str() == '=' {
				tokens << new_token(.reserved, '${s[loc].str()}=', loc)
				loc += 2
				continue
			}
			tokens << new_token(.reserved, s[loc].str(), loc)
			loc++
			continue
		}
		error_at(s, loc, 'unexpected character: "${s[loc].str()}"')
	}
	tokens << new_token(TokenKind.eof, '', loc)
	return tokens
}

fn new_token(kind TokenKind, str string, loc int) &Token {
	return &Token{
		kind: kind
		str: str
		loc: loc
	}
}

fn error_at(current_input string, loc int, str string) {
	spaces := ' '.repeat(loc)
	eprintln(current_input)
	eprintln('$spaces^ $str')
	exit(1)
}

fn read_number(s string) string {
	mut loc := 0
	for loc < s.len && s[loc].is_digit() {
		loc++
	}
	return s[0..loc]
}
