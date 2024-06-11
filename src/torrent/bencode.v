module torrent

const cln_mark = u8(0x3A) // `:`
const end_mark = u8(0x65) // `e`
const int_mark = u8(0x69) // `i`
const lst_mark = u8(0x6C) // `l`
const map_mark = u8(0x64) // `d`

type Token = []Token | []u8 | int | map[string]Token

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
	mut i := p.i + 1
	for ; i < p.bytes.len && p.bytes[i] >= u8(0x30) && p.bytes[i] <= u8(0x39)
		&& p.bytes[i] != torrent.end_mark; i += 1 {
	}

	if i == p.bytes.len || p.bytes[i] != torrent.end_mark {
		return error('Invalid int at ${p.i}')
	}

	out := p.bytes[p.i + 1..i].bytestr().int()
	p.i = i + 1
	return out
}

fn (mut p Parser) parse_str() !Token {
	mut i := p.i
	for ; i < p.bytes.len && p.bytes[i] >= u8(0x30) && p.bytes[i] <= u8(0x39)
		&& p.bytes[i] != torrent.cln_mark; i += 1 {
	}

	if i == p.bytes.len || p.bytes[i] != torrent.cln_mark {
		return error('Invalid string length at ${p.i}')
	}

	len := p.bytes[p.i..i].bytestr().int()
	i += 1
	p.i = i + len

	if p.i > p.bytes.len {
		return error('Invalid string length at ${i}')
	}

	return p.bytes[i..p.i]
}

fn (mut p Parser) parse_lst() !Token {
	mut out := []Torrent{}
	for p.i < p.bytes.len && p.bytes[p.i] != torrent.end_mark {
		tmp := p.parse()!
		out << tmp
	}

	if p.i == p.bytes.len {
		return error('Invalid list at ${p.i}')
	}

	return out
}

fn (mut p Parser) parse_map() !Token {
	mut out := map[string]Token{}

	for p.i < p.bytes.len && p.bytes[p.i] != torrent.end_mark {
		mut k := p.parse_str()!
		v := p.parse()!

		if mut k is []u8 {
			out[k.bytestr()] = v
		}
	}

	return out
}
