module main

import rand
import net.urllib

fn tracker_url(announce string, hash []u8, left int, peer_id []u8, port int) !string {
	mut url := urllib.parse(announce)!

	mut query := urllib.new_values()
	query.add('info_hash', hash.bytestr())
	query.add('peer_id', peer_id.bytestr())
	query.add('port', port.str())
	query.add('uploaded', 0.str())
	query.add('downloaded', 0.str())
	query.add('compact', 1.str())
	query.add('left', left.str())

	url.raw_query = query.encode()

	return url.str()
}

fn peer_id() []u8 {
	return rand.bytes(20) or { panic(err) }
}
