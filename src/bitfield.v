module main

fn set_piece(mut buf []u8, id int) {
	i := id / 8
	j := 7 - id % 8

	mut b := buf[i]
	b = b | (1 << j)
	buf[i] = b
}

fn get_piece(buf []u8, id int) bool {
	i := id / 8
	j := 7 - id % 8

	b := buf[i]
	return (b & (1 << j)) != 0
}
