module main

struct File {
	path   string
	length int
}

struct Torrent {
	name         string
	announce     string
	info_hash    []u8
	pieces       [][]u8
	piece_length int
	files        []File
}

fn Torrent.from(data string) !Torrent {
	name := get_string(data, '4:name', 0) or { return error('Required name') }
	announce := get_string(data, '8:announce', 0) or { return error('Required announce') }

	files := if _ := get_string(data, '4:path', 0) {
		get_files(data)
	} else {
		[File{
			path: name
			length: 0
		}]
	}

	piece_length := get_int(data, '12:piece length', 0) or { return error('Required piece length') }
	pieces := get_pieces(data) or { return error('Required pieces') }

	return Torrent{
		name: name
		announce: announce
		pieces: pieces
		piece_length: piece_length
		files: files
	}
}

fn get_files(data string) []File {
	mut files := []File{}
	mut i := 0
	for {
		i = data.index_after('6:length', i)
		if i < 0 {
			break
		}
		len := parse_int(data, i + 8) or { break }
		i = data.index_after('4:path', i) + 7

		mut path := []string{}
		for data[i] != end_mark {
			tmp := parse_str(data, i) or { break }
			path << tmp
			i = data.index_after(':', i) + 1
			i += tmp.len
		}

		files << File{
			path: path.join('/')
			length: len
		}
	}

	return files
}

fn get_pieces(data string) ?[][]u8 {
	index := data.index('6:pieces') or { -1 }

	if index < 0 {
		return none
	}

	str := parse_str(data, index + 8) or { '' }
	bytes := str.bytes()

	n := bytes.len / 20
	mut pieces := [][]u8{cap: n}
	for i := 0; i < n; i += 1 {
		pieces << bytes[(i * 20)..(i * 20) + 20]
	}

	return pieces
}
