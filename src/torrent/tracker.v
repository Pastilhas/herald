/*
* https://www.bittorrent.org/beps/bep_0015.html
*/

module torrent

import math
import net
import time
import rand
import encoding.hex
import encoding.binary

const (
	connect_request_prefix  = hex.decode('0x0000_0417_2710_1980_0000_0000')!
	announce_request_action = hex.decode('0x0000_0001')!
)

struct TrackerConn {
mut:
	retry          int = 0
	udp            net.UdpConn
	torr_file      Torrent
	transaction_id []u8   = []u8{}
	connection_id  []u8   = []u8{}
	peer_id        []u8   = []u8{}
	peers          []Peer = []Peer{}
}

fn TrackerConn.new(addr string, torr_file Torrent) TrackerConn {
	udp := net.dial_udp(addr) or { panic('Failed to dial UDP ${addr}') }
	mut tracker := TrackerConn{
		torrent: torr_file
		udp: udp
	}
	tracker.udp.set_read_timeout(time.Duration(15))

	return tracker
}

fn (mut conn TrackerConn) update_connection_timeout() {
	conn.retry += 1
	duration := time.Duration(15 * math.powi(2, conn.retry))
	conn.udp.set_read_timeout(duration)
}

fn (mut conn TrackerConn) reset_connection_timeout() {
	conn.retry = 0
	conn.udp.set_read_timeout(time.Duration(15))
}

fn (mut conn TrackerConn) send_connect() {
	conn.transaction_id = rand.bytes(4) or { []u8{len: 4} }
	conn.peer_id = '-HD0001-'.bytes()
	conn.peer_id << rand.bytes(20) or { []u8{len: 4} }

	mut packet := []u8{cap: 512}
	packet << torrent.connect_request_prefix.clone()
	packet << conn.transaction_id
	conn.udp.write(packet) or { panic('Error writting connect') }
}

fn (mut conn TrackerConn) send_announce() ! {
	conn.transaction_id = rand.bytes(4) or { []u8{len: 4} }
	key := rand.bytes(4) or { []u8{len: 4} }
	mut size := []u8{cap: 8}
	big_endian_put_u64(size, conn.torr_file.total_size)

	mut packet := []u8{cap: 512}
	packet << conn.connection_id.clone()
	packet << torrent.announce_request_action.clone()
	packet << conn.transaction_id.clone()
	packet << conn.torr_file.info_hash
	packet << conn.peer_id
	packet << []u8{len: 8}
	packet << size
	packet << []u8{len: 8}
	packet << []u8{len: 4}
	packet << []u8{len: 4}
	packet << key
	packet << hex.decode('0x80000001')!
	packet << hex.decode('0x1B39')!

	conn.udp.write(packet) or { panic('Error writting announce') }
}

fn (mut conn TrackerConn) wait_connect() bool {
	mut buf := []u8{cap: 512}
	len, _ := conn.udp.read(mut buf) or {
		println('Error reading')
		return false
	}

	if len < 16 {
		return false
	}

	action := binary.big_endian_u32(buf[..4])
	if action != 0 {
		return false
	}

	if buf[4..8] != conn.transaction_id {
		return false
	}

	conn.connection_id = buf[8..16].clone()
	return true
}

fn (mut conn TrackerConn) wait_announce() bool {
	mut buf := []u8{cap: 512}
	len, _ := conn.udp.read(mut buf) or {
		println('Error reading')
		return false
	}

	if len < 16 {
		return false
	}

	action := binary.big_endian_u32(buf[..4])
	if action != 1 {
		return false
	}

	if buf[4..8] != conn.transaction_id {
		return false
	}

	for i := 20; i < buf.len; i += 6 {
		ip := buf[i..i + 4].map(it.str()).join('.')
		port := binary.big_endian_u16(buf[i + 4..i + 6])

		conn.peers << Peer{ip, port}
	}

	return true
}

pub fn announce_to_tracker(addr string) {
	mut tracker := TrackerConn.new(addr, ''.bytes())

	for {
		for {
			tracker.send_connect()
			if tracker.wait_connect() {
				break
			} else {
				tracker.update_connection_timeout()
			}
		}

		tracker.reset_connection_timeout()

		tracker.send_announce() or { panic('Failed to announce') }
		if tracker.wait_announce() {
			break
		}
	}

	/*
	while not connected
		send connect request
		receive connect response, with timeout 15 * 2 ^ n, n >= 0, n <= 8

	while connected
		send announce request
		receive announce response
	*/
}
