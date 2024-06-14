module main

import os

fn main() {
	data := os.read_file('test.torrent')!
	tor := Torrent.from(data)!
	println(tor.name)
}
