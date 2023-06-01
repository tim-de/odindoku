package heapdoku

import "core:fmt"
import "../dway_heap"

SudokuCell :: struct {
	value : int,
	options : bit_set[0..=9],
	neighbours : [20]^SudokuCell,
}

cell_compare :: proc(parent, child: ^SudokuCell) -> bool {
	return card(child.options) < card(parent.options)
}

SudokuGrid :: [9][9]SudokuCell

get_neighbour_position :: proc(i, j, n: int) -> (int, int) {
	switch n {
	case 0..<8:
		offset := n
		if offset >= i {
			offset += 1
		}
		return offset, j
	case 8..<16:
		offset := n - 8
		if offset >= i {
			offset += 1
		}
		return i, offset
	case 16..<20:
		box_i := i / 3
		box_j := j / 3
		i_offset := (n - 16) / 2
		j_offset := (n - 16) % 2

		// Should maybe make this a switch statement
		if i % 3 == 0 do i_offset += 1
		if i % 3 == 1 do i_offset *= 2

		if j % 3 == 0 do j_offset += 1
		if j % 3 == 1 do j_offset *= 2

		return (3 * box_i) + i_offset, (3 * box_j) + j_offset
	case :
		return -1, -1
	}
}

grid_from_array :: proc(arr: [81]int) -> ^SudokuGrid {
	grid := new(SudokuGrid)
	for value, ix in arr {
		i: int = ix / 9
		j: int = ix % 9
		grid[i][j] = SudokuCell {value = value}
	}
	assign_neighbours(grid)
	return grid
}

assign_neighbours :: proc(grid: ^SudokuGrid) {
	for j in 0..<9 {
		for i in 0..<9 {
			for n in 0..<20 {
				k, l := get_neighbour_position(i, j, n)
				grid[j][i].neighbours[n] = &grid[l][k]
			}
		}
	}
}

print_sudoku_grid :: proc(grid: ^SudokuGrid) {
	for row, j in grid {
		if j % 3 == 0 {
			fmt.println()
		}
		for cell, i in row {
			if i % 3 == 0 {
				fmt.print(" ")
			}
			if cell.value == 0 {
				fmt.print(" .")
			}
			else {
				fmt.printf(" %d", cell.value)
			}
		}
		fmt.println()
	}
}

setup_grid_heap :: proc(grid: ^SudokuGrid) -> (heap: ^dway_heap.dwayHeap(^SudokuCell), ok: bool) {
	heap, ok = dway_heap.create_dwayHeap(^SudokuCell, 4, cell_compare, 81)
	for row, j in grid {
		for cell, i in row {
			set_cell_options(&grid[j][i])
			if cell.value == 0 {
				heap.store[heap.count] = &grid[j][i]
				heap.count += 1
			}
		}
	}
	if !dway_heap.heapify(heap) do fmt.println("Heapify failed")
	return
}

set_cell_options :: proc(cell: ^SudokuCell) {
	cell.options = {1, 2, 3, 4, 5, 6, 7, 8, 9} if cell.value == 0 else {}
	for neighbour, ix in cell.neighbours{
		if neighbour == nil {
			fmt.printf("Neighbour %d not set\n", ix)
		}
		else {
			cell.options -= {neighbour.value}
		}
	}
}

depth_first_search :: proc(heap: ^dway_heap.dwayHeap(^SudokuCell)) -> (ok: bool) {
	cell := dway_heap.pop(heap) or_return
	if card(cell.options) == 0 {
		dway_heap.push(heap, cell)
		return false
	}
	for option in 1..=9 {
		if option in cell.options {
			changed_cells := make([dynamic]^SudokuCell, 0, 20)
			defer delete(changed_cells)
			cell.value = option
			if heap.count == 0 do return true
			for neighbour in cell.neighbours {
				if neighbour.value == 0 && option in neighbour.options {
					append(&changed_cells, neighbour)
					neighbour.options -= {option}
				}
			}
			dway_heap.heapify(heap)
			if depth_first_search(heap) do return true
			cell.value = 0
			for neighbour in changed_cells {
				neighbour.options += {option}
			}
			dway_heap.heapify(heap)
		}
	}
	dway_heap.push(heap, cell)
	return false
}
