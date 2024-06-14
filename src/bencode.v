module main

const cln_mark = u8(0x3A) // `:`
const end_mark = u8(0x65) // `e`

fn parse_int(data []u8, start int) !int {
	i := start + 1
	mut j := i

	for ; j < data.len && data[j].is_digit() && data[j] != end_mark; j += 1 {
	}

	if j >= data.len || data[j] != end_mark {
		return error('Invalid int at ${i}:${j}')
	}

	return data[i..j].bytestr().int()
}

fn parse_str(data []u8, start int) !string {
	mut i := start
	mut j := i + 1

	for ; j < data.len && data[j].is_digit() && data[j] != cln_mark; j += 1 {
	}

	if j >= data.len || data[j] != cln_mark {
		return error('Invalid string length at ${i}:${j}')
	}

	len := data[i..j].bytestr().int()

	if (j + 1 + len) > data.len {
		return error('Invalid string length at ${i}:${j}')
	}

	i = j + 1
	j = i + len
	return data[i..j].bytestr()
}

fn get_string(data []u8, id string, after int) ?string {
	i := data.bytestr().index_after(id, after)

	if i < 0 {
		return none
	}

	return parse_str(data, i + id.len) or { none }
}

fn get_int(data []u8, id string, after int) ?int {
	index := data.bytestr().index_after(id, after)

	if index < 0 {
		return none
	}

	return parse_int(data, index + id.len) or { none }
}
