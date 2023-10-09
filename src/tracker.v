/*
* https://www.bittorrent.org/beps/bep_0015.html
*/

module main

import net
import rand
import encoding.binary
import encoding.hex

const (
	connect_request_prefix  = hex.decode('0x0000_0417_2710_1980_0000_0000')!
	announce_request_action = hex.decode('0x0000_0001')!
)

struct TrackerConn {
mut:
	transaction_id []u8
	connection_id  []u8
}

fn announce_to_tracker(addr string) ! {
	mut conn := net.dial_udp(addr)!

	/*
	while not connected
		send connect request
		receive connect response, with timeout 15 * 2 ^ n, n >= 0, n <= 8

	while connected
		send announce request
		receive announce response 
	*/
}

fn send_connect(mut conn net.UdpConn) ! {
	packet := []u8{len: 16}

	conn.write(packet)!
}

fn send_announce(mut conn net.UdpConn) ! {
	packet := []u8{len: 98}

	conn.write(packet)!
}
