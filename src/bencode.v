module main

fn parse_string(code string) (string, string) {
	colon := code.index(":") or { return "", code }
	size := code[..colon].int()
	
	output := code[colon+1..colon+1+size]
	result := code[colon+1+size..]

	return output, result
}

fn parse_integer(code string) (string, string) {
	end := code.index("e") or { return "", code }

	output := code[1..end]
	result := code[end..]

	return output, result
}
