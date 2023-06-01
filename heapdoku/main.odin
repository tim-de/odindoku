package heapdoku

import "core:os"
import "core:fmt"
import "../dway_heap"

main :: proc() {
	grids := get_grids("sudoku.txt")
	//grids := get_grids("p096_sudoku.txt")
	defer delete_grids(&grids)
	count := 0
	for grid in grids {
		heap, heapmade := setup_grid_heap(grid)
		if !heapmade {
			fmt.println("Failed to initialise heap")
			return
		}
		defer dway_heap.free_dwayHeap(heap)
		print_sudoku_grid(grid)
		if depth_first_search(heap) {
			fmt.println("Solve succeeded!")
			print_sudoku_grid(grid)
			count += 1
		}
		else {
			fmt.println("Solve failed")
		}
	}
	fmt.println("Solved", count, "puzzles")
}

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

get_grids :: proc (filename: string) -> (grids: [dynamic]^SudokuGrid) {
	data, ok := os.read_entire_file(filename)
	if !ok {
		fmt.println("Failed to read file:", filename)
		return
	}
	defer delete(data)

	nums: [81]int
	pos: int = 0
	line: []u8
	ix := 0
	start := true
	for pos != -1 {
		line, pos = get_line_at(&data, pos)
		if len(line) == 0 {
			break
		}
		if line[0] >= 0x30 && line[0] <= 0x39 {
			for char in line {
				nums[ix] = int(char) - 0x30
				ix += 1
			}
		}
		else {
			if !start {
				append(&grids, grid_from_array(nums))
			}
			ix = 0
		}
		start = false
	}
	append(&grids, grid_from_array(nums))
	return
}

delete_grids :: proc(grids: ^[dynamic]^SudokuGrid) {
	for grid in grids^ {
		free(grid)
	}
	delete(grids^)
}
