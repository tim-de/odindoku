package main

import "core:os"
import "core:fmt"

get_line_at :: proc (data: ^[]u8, start: int) -> (line: []u8, next: int)
{
	pos := start
	if pos >= len(data) {
		next = -1
		return
	}

	for data[pos] != '\n' {
		pos += 1
		if pos >= len(data) {
			line = data[start:]
			next = -1
			return
		}
	}
	line = data[start:pos]
	next = pos + 1
	return
}

get_grids :: proc (fn: string) -> (grids: [dynamic]^Sudoku)
{
	data, ok := os.read_entire_file(fn)
	if !ok {
		fmt.println("Failed to read file:", fn)
		return
	}
	defer delete(data)

	s: ^Sudoku
	j, pos := 0, 0
	for pos != -1 {
		line, next := get_line_at(&data, pos)
		if len(line) == 0 {
			break
		}
		if line[0] >= 0x30 && line[0] <= 0x39 {
			for i in 0..<len(line) {
				s[j][i].num = int(line[i]) - 0x30
				s[j][i].opts = Nums{1, 2, 3, 4, 5, 6, 7, 8, 9}
			}
			j += 1
		}
		else {
			s = new(Sudoku)
			append(&grids, s)
			j = 0
		}
		pos = next
	}
	return
}

delete_grids :: proc (grids: ^[dynamic]^Sudoku)
{
	for s in grids^ {
		free(s)
	}
	delete(grids^)
}
