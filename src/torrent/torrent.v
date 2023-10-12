module torrent

import arrays
import crypto.sha1

[noinit]
pub struct Torrent {
pub:
	announce     string
	info_hash    []u8
	total_size   int
	file_size    []int
	file_path    []string
	piece_hash   []string
	piece_length int
}

fn get_files(info map[string]Token) ([]int, []string) {
	if files := info['files'] {
		lengths := files.map(it['length'])
		paths := files.map(it['path'])
		return length, paths
	}

	if files := info['length'] {
		return info['length'], info['name']
	}

	panic('Invalid torrent')
}

fn get_info_hash(raw []u8) []u8 {
	info_index := raw.bytestr().index('4:info')
	return sha1.sum(raw[info_index + 6..])
}

fn get_pieces(pieces_all string) []string {
	mut pieces := []string{}
	for i := 20; i <= pieces_all.len; i += 20 {
		pieces << pieces_all[i - 20..i]
	}
	return pieces
}

pub fn Torrent.new(raw []u8) Torrent {
	dict, _ := parse_any(raw)

	announce := dict['announce']
	info_hash := get_info_hash(raw)
	file_size, file_path := get_files(dict['info'])
	total_size := arrays.sum(file_size) or { 0 }
	pieces := get_pieces(dict['info']['pieces'])
	piece_length := dict['info']['piece length']

	return Torrent{announce, info_hash, total_size, file_size, file_path, pieces, piece_length}
}
