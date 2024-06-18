module main

import rand
import net.urllib
import net
import encoding.binary

fn tracker_url(announce string, hash []u8, peer_id []u8, port u16) !string {
	mut url := urllib.parse(announce)!

	mut query := urllib.new_values()
	query.add('info_hash', hash.bytestr())
	query.add('peer_id', peer_id.bytestr())
	query.add('port', port.str())
	query.add('uploaded', 0.str())
	query.add('downloaded', 0.str())
	query.add('left', 0.str())
	query.add('compact', 1.str())

	url.raw_query = query.encode()

	return url.str()
}

fn peer_id() []u8 {
	return rand.bytes(20) or { panic(err) }
}

fn parse_peers(data []u8) ![]net.Addr {
	if data.len % 6 != 0 {
		return error('Invalid peers')
	}

	n := data.len / 6
	mut peers := []net.Addr{cap: n}

	for i := 0; i < n; i += 1 {
		j := i * 6

		port := binary.big_endian_u16_at(data, j + 4)
		mut addr := [4]u8{}
		addr[0] = data[j + 0]
		addr[1] = data[j + 1]
		addr[2] = data[j + 2]
		addr[3] = data[j + 3]

		peers << net.new_ip(port, addr)
	}

	return peers
}

fn write_handshake(hash []u8, peer_id []u8) []u8 {
	mut data := []u8{cap: 68}

	data << 0x13
	data << 'BitTorrent protocol'.bytes()
	data << []u8{len: 8}
	data << hash
	data << peer_id

	return data
}

fn read_handshake(handshake []u8, hash []u8, peer []u8) ! {
	a := handshake[0]
	b := handshake[1..20].bytestr()
	c := handshake[28..48]
	d := handshake[48..68]

	if a != 0x13 || b != 'BitTorrent protocol' {
		return error('Invalid protocol')
	}

	if c != hash {
		return error('Invalid hash')
	}

	if d != peer {
		return error('Invalid peer id')
	}
}
