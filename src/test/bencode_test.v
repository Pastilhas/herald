import torrent

fn test_int() {
	b := torrent.decode('i123e'.bytes()) or { torrent.Token(0) }
	assert b is int
	assert b as int == 123
}

fn test_str() {
	b := torrent.decode('6:flower'.bytes()) or { torrent.Token(0) }
	assert b is []u8
	assert (b as []u8).bytestr() == 'flower'
}
