module main

const cln_mark = u8(0x3A) // `:`
const end_mark = u8(0x65) // `e`

fn parse_int(data string, start int) !int {
	i := start + 1
	mut j := i

	for ; j < data.len && data[j].is_digit() && data[j] != end_mark; j += 1 {
	}

	if j >= data.len || data[j] != end_mark {
		return error('Invalid int at ${i}:${j}')
	}

	out := data[i..j].int()
	return out
}

fn parse_str(data string, start int) !string {
	mut i := start
	mut j := i + 1

	for ; j < data.len && data[j].is_digit() && data[j] != cln_mark; j += 1 {
	}

	if j >= data.len || data[j] != cln_mark {
		return error('Invalid string length at ${i}:${j}')
	}

	len := data[i..j].int()

	if (j + 1 + len) > data.len {
		return error('Invalid string length at ${i}:${j}')
	}

	i = j + 1
	j = i + len
	return data[i..j]
}

fn get_string(data string, id string, after int) ?string {
	index := data.index_after(id, after)

	if index < 0 {
		return none
	}

	return parse_str(data, index + id.len) or { none }
}

fn get_int(data string, id string, after int) ?int {
	index := data.index_after(id, after)

	if index < 0 {
		return none
	}

	return parse_int(data, index + id.len) or { none }
}
