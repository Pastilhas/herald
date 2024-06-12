import bencode

fn test_int() {
	b := bencode.decode('i123e'.bytes()) or { bencode.Token(0) }
	assert b is int
	assert b as int == 123
}

fn test_str() {
	b := bencode.decode('6:flower'.bytes()) or { bencode.Token(0) }
	assert b is []u8
	assert (b as []u8).bytestr() == 'flower'
}

fn test_lst() {
	a := 'l4:spami42ee'.bytes()
	b := bencode.decode(a) or { panic(err) }
	assert b is []bencode.Token
}
