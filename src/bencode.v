module main

type Token = []Token | []u8 | int | map[string]Token

const (
	colon_mark = `:`.bytes()[0]
	end_mark   = `e`.bytes()[0]
	list_mark  = `l`.bytes()[0]
	map_mark   = `d`.bytes()[0]
	int_mark   = `i`.bytes()[0]
)

pub fn bdecode(bytes []u8) {
	mut buf := bytes.clone()

	for buf.len > 0 {
		if buf[0] == map_mark {
		}
	}
}

fn parse_int(bytes []u8) (Token, []u8) {
	mut i := 1
	for ; bytes[i] != end_mark; i++ {}
	out := bytes[1..i].bytestr().int()
	res := bytes[i + 1..]
	return out, res
}

fn parse_str(bytes []u8) (Token, []u8) {
	mut i := 0
	for ; bytes[i] != colon_mark; i++ {}
	size := bytes[..i].bytestr().int()
	i++
	out := bytes[i..i + size]
	res := bytes[i + size..]
	return out, res
}

fn parse_list(bytes []u8) (Token, []u8) {
	mut out := []Token{}

	mut buf := bytes.clone()[1..]
	mut tmp_out := Token(0)

	for buf.len > 0 && buf[0] != end_mark {
		if buf[0] == int_mark {
			tmp_out, buf = parse_int(buf)
		} else if buf[0] == map_mark {
			tmp_out, buf = parse_map(buf)
		} else if buf[0] == list_mark {
			tmp_out, buf = parse_list(buf)
		} else {
			tmp_out, buf = parse_str(buf)
		}

		out << tmp_out
	}

	return out, buf
}
