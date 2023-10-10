/*
* https://www.bittorrent.org/beps/bep_0015.html
*/

module main

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
	transaction_id []u8
	connection_id  []u8
	udp            net.UdpConn
	retry          int
}

fn TrackerConn.new(addr string) TrackerConn {
	udp := net.dial_udp(addr) or {
		println('eh')
		exit(1)
	}
	mut tracker := TrackerConn{[]u8{}, []u8{}, udp, 0}
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

	mut packet := connect_request_prefix.clone()
	packet << conn.transaction_id
	conn.udp.write(packet) or {
		println('Error writting')
		exit(1)
	}
}

fn (mut conn TrackerConn) send_announce() {
	conn.transaction_id = rand.bytes(4) or { []u8{len: 4} }

	mut packet := conn.connection_id.clone()
	packet << announce_request_action.clone()
	packet << conn.transaction_id
	packet << []u8{len: 20} // info_hash
	packet << []u8{len: 20} // peer_id
	packet << []u8{len: 8} // downloaded
	packet << []u8{len: 8} // left
	packet << []u8{len: 8} // uploaded
	packet << []u8{len: 4} // event
	packet << []u8{len: 4} // IP
	packet << []u8{len: 4} // key
	packet << []u8{len: 4} // num_want
	packet << []u8{len: 2} // port

	conn.udp.write(packet) or {
		println('Error writting')
		exit(1)
	}
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
	_, _ := conn.udp.read(mut buf) or {
		println('Error reading')
		exit(1)
	}

	return false
}

pub fn announce_to_tracker(addr string) {
	mut tracker := TrackerConn.new(addr)

	for {
		tracker.send_connect()
		if tracker.wait_connect() {
			break
		} else {
			tracker.update_connection_timeout()
		}
	}

	tracker.reset_connection_timeout()

	/*
	while not connected
		send connect request
		receive connect response, with timeout 15 * 2 ^ n, n >= 0, n <= 8

	while connected
		send announce request
		receive announce response
	*/
}
