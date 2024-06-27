module main

import encoding.binary

const msg_choke = u8(0)
const msg_unchoke = u8(1)
const msg_interested = u8(2)
const msg_notinterested = u8(3)
const msg_have = u8(4)
const msg_bitfield = u8(5)
const msg_request = u8(6)
const msg_piece = u8(7)
const msg_cancel = u8(8)

fn send_request(index u32, start u32, end u32) ! {
	mut buf := []u8{len: 12}
	binary.big_endian_put_u32_at(mut buf, index, 0)
	binary.big_endian_put_u32_at(mut buf, index, 4)
	binary.big_endian_put_u32_at(mut buf, index, 8)

	binary.msg := write_message(msg_request, buf)
}

fn send_interested() ! {
	msg := write_message(msg_interested, [])
}

fn send_notinterested() ! {
	msg := write_message(msg_notinterested, [])
}

fn send_unchoke() ! {
	msg := write_message(msg_unchoke, [])
}

fn send_have(index u32) ! {
	mut buf := []u8{len: 12}
	binary.big_endian_put_u32_at(mut buf, index, 0)

	msg := write_message(msg_have, buf)
}
