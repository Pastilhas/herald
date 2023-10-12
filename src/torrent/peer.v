module torrent

import net
import encoding.hex

struct Peer {
	ip_addr   string
	port      int
	torr_file Torrent
mut:
	tcp     net.TcpConn
	peer_id []u8 = []u8{}
}

fn (peer Peer) download() {
	peer.tcp = net.dial_tcp('${peer.ip_addr}:${peer.port}')
	peer.peer_id = '-HD0001-'.bytes()
	peer.peer_id << rand.bytes(20) or { []u8{len: 4} }

	peer.send_handshake()

	peer.wait_handshake()

	peer.send_interested()

	peer.wait_interested()
}

fn (peer Peer) send_handshake() {
	pstrlen := 19 as u8
	pstr := 'BitTorrent protocol'.bytes()

	mut packet := []u8{cap: 512}
	packet << pstrlen
	packet << pstr
	packet << []u8{len: 8}
	packet << peer.torr_file.info_hash
	packet << peer.peer_id

	peer.tcp.write(packet) or { panic('Error writting announce') }
}

fn (peer Peer) send_choke() {
	mut packet := hex.decode('0x0000_0001_00')!

	peer.tcp.write(packet) or { panic('Error writting announce') }
}

fn (peer Peer) send_unchoke() {
	mut packet := hex.decode('0x0000_0001_01')!

	peer.tcp.write(packet) or { panic('Error writting announce') }
}

fn (peer Peer) send_interested() {
	mut packet := hex.decode('0x0000_0001_02')!

	peer.tcp.write(packet) or { panic('Error writting announce') }
}

fn (peer Peer) send_uninterested() {
	mut packet := hex.decode('0x0000_0001_03')!

	peer.tcp.write(packet) or { panic('Error writting announce') }
}

fn (peer Peer) send_have() {
	mut packet := hex.decode('0x0000_0005_04')!
	

	peer.tcp.write(packet) or { panic('Error writting announce') }
}