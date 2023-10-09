module main

type Token = []Token | []u8 | int | map[string]Token

const (
	colon_mark = 0x3A // `:`
	end_mark   = 0x65 // `e`
	int_mark   = 0x69 // `i`
	list_mark  = 0x6C // `l`
	map_mark   = 0x64 // `d`
)

fn parse_any(bytes []u8) (Token, []u8) {
	if bytes[0] == int_mark {
		return parse_int(bytes)
	}
	if bytes[0] == map_mark {
		return parse_map(bytes)
	}
	if bytes[0] == list_mark {
		return parse_list(bytes)
	}
	return parse_str(bytes)
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
		tmp_out, buf = parse_any(buf)
		out << tmp_out
	}

	return out, buf
}

fn parse_map(bytes []u8) (Token, []u8) {
	mut out := map[string]Token{}

	mut buf := bytes.clone()[1..]
	mut tmp_key := Token(0)
	mut tmp_out := Token(0)

	for buf.len > 0 && buf[0] != end_mark {
		tmp_key, buf = parse_str(buf)
		tmp_out, buf = parse_any(buf)

		if mut tmp_key is []u8 {
			out[tmp_key.bytestr()] = tmp_out
		}
	}

	return out, buf
}
