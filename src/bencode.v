module main

fn parse_string(code string) (string, string) {
	colon := code.index(":") or { return "", code }
	size := code[..colon].int()
	
	output := code[colon+1..colon+1+size]
	result := code[colon+1+size..]

	return output, result
}


