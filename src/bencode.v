module main

type Token = []Token | int | map[string]Token | string

const (
	colon = `:`.bytes()[0]
	endmk = `e`.bytes()[0]
	lstmk = `l`.bytes()[0]
	mapmk = `d`.bytes()[0]
	intmk = `i`.bytes()[0]
)

pub fn bdecode(bytes []u8) {
	mut buf := bytes.clone()

	for buf.len > 0 {
		if buf[0] == mapmk {
		}
	}
}

fn parse_int(bytes []u8) (Token, []u8) {
	mut i := 1
	for ; bytes[i] != endmk; i++ {}
	out := bytes[1..i].bytestr().int()
	res := bytes[i + 1..]
	return out, res
}

fn parse_str(bytes []u8) (Token, []u8) {
	mut i := 0
	for ; bytes[i] != colon; i++ {}
	size := bytes[..i].bytestr().int()
	i++
	out := bytes[i..i + size].bytestr()
	res := bytes[i + size..]
	return out, res
}
