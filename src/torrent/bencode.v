module torrent

const cln_mark = u8(0x3A) // `:`
const end_mark = u8(0x65) // `e`
const int_mark = u8(0x69) // `i`
const lst_mark = u8(0x6C) // `l`
const map_mark = u8(0x64) // `d`

pub type Token = []Token | []u8 | int | map[string]Token

pub fn decode(data []u8) !Token {
	mut p := Parser{
		bytes: data
		i: 0
	}
	return p.parse()
}

struct Parser {
	bytes []u8
mut:
	i int
}

fn (mut p Parser) parse() !Token {
	return if p.bytes[p.i] == torrent.int_mark {
		p.parse_int()!
	} else if p.bytes[p.i] == torrent.map_mark {
		p.parse_map()!
	} else if p.bytes[p.i] == torrent.lst_mark {
		p.parse_lst()!
	} else {
		p.parse_str()!
	}
}

fn (mut p Parser) parse_int() !Token {
	i := p.i + 1
	mut j := i

	for ; j < p.bytes.len && p.bytes[j] >= u8(0x30) && p.bytes[j] <= u8(0x39)
		&& p.bytes[j] != torrent.end_mark; j += 1 {
	}

	if j >= p.bytes.len || p.bytes[j] != torrent.end_mark {
		return error('Invalid int at ${i}:${j}')
	}

	out := p.bytes[i..j].bytestr().int()
	p.i = j + 1
	return out
}

fn (mut p Parser) parse_str() !Token {
	mut i := p.i
	mut j := p.i + 1

	for ; j < p.bytes.len && p.bytes[j] >= u8(0x30) && p.bytes[j] <= u8(0x39)
		&& p.bytes[j] != torrent.cln_mark; j += 1 {
	}

	if j >= p.bytes.len || p.bytes[j] != torrent.cln_mark {
		return error('Invalid string length at ${i}:${j}')
	}

	len := p.bytes[i..j].bytestr().int()

	if j + 1 + len > p.bytes.len {
		return error('Invalid string length at ${i}:${j}')
	}

	i = j + 1
	j = i + len
	p.i = j
	return p.bytes[i..j]
}

fn (mut p Parser) parse_lst() !Token {
	i := p.i
	mut out := []Token{}

	for p.i < p.bytes.len && p.bytes[p.i] != torrent.end_mark {
		out << p.parse() or { return error('${err}\nInvalid list at ${i}') }
	}

	if p.i >= p.bytes.len {
		return error('Invalid list at ${i}')
	}

	return out
}

fn (mut p Parser) parse_map() !Token {
	i := p.i
	mut out := map[string]Token{}

	for p.i < p.bytes.len && p.bytes[p.i] != torrent.end_mark {
		mut k := p.parse_str() or { return error('${err}\nInvalid map at ${i}') }
		v := p.parse() or { return error('${err}\nInvalid map at ${i}') }

		if mut k is []u8 {
			out[k.bytestr()] = v
		}
	}

	if p.i >= p.bytes.len {
		return error('Invalid map at ${i}')
	}

	return out
}
