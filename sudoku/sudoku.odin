package main

import "core:fmt"

Nums :: bit_set[1..=9]

init_opts :: Nums{1, 2, 3, 4, 5, 6, 7, 8, 9}

Cell :: struct {
	num : int,
	opts : Nums,
}

Sudoku :: [9][9]Cell

SolveState :: enum {
	Ongoing,
	Failed,
	Solved,
}

get_corner_val :: proc (s: ^Sudoku) -> (val: int)
{
	val = 0
	for i in 0..<3 {
		val *= 10
		val += s[0][i].num
	}
	return
}

print_sudoku :: proc (s: Sudoku)
{
	for row in s {
		for cell in row {
			if cell.num == 0 {
				fmt.print(" .")
			}
			else {
				fmt.printf(" %d", cell.num)
			}
		}
		fmt.println()
	}
}

try_collapse_cell :: proc (c: Cell) -> int
{
	if c.num != 0 {
		return c.num
	}
	if card(c.opts) == 1 {
		for n in 1..=9 {
			if n in c.opts {
				return n
			}
		}
	}
	return 0
}

get_cell_opts :: proc (s: Sudoku, i, j: int) -> (opts: Nums)
{
	opts = s[j][i].opts
	for ind in 0..<9 {
		// Check row, column, and box in tandem
		if s[j][ind].num != 0 {
			excl(&opts, s[j][ind].num)
		}
		if s[ind][i].num != 0 {
			excl(&opts, s[ind][i].num)
		}
		if s[3*(j/3) + ind/3][3*(i/3) + ind%3].num != 0 {
			excl(&opts, s[3*(j/3) + ind/3][3*(i/3) + ind%3].num)
		}
	}
	return
}

solve_pass :: proc (s: ^Sudoku) -> (state: SolveState)
{
	set, preset := 0, 0
	state = .Ongoing
	for j in 0..<len(s^) {
		for i in 0..<len(s[j]) {
			if s[j][i].num != 0 {
				preset += 1
				continue }
			s[j][i].opts = get_cell_opts(s^, i, j)
			s[j][i].num = try_collapse_cell(s[j][i])
			if s[j][i].num != 0 {
				set += 1
			}
		}
	}
	if set == 0 {
		state = .Failed
	}
	if set + preset == 81 {
		state = .Solved
	}
	return
}

try_solve_sudoku :: proc (s: ^Sudoku) -> (state: SolveState)
{
	state = .Ongoing
	for state == .Ongoing {
		//fmt.println()
		//print_sudoku(s^)
		state = solve_pass(s)
	}
	return
}

solve_sudoku :: proc (s: ^Sudoku) -> SolveState
{
	if try_solve_sudoku(s) != .Solved {
		fmt.println("===================")
		print_sudoku(s^)
		i, j, _ := find_least_opts(s)
		return depth_first_search(s, i, j)
	}
	return .Solved
}

dfs_solve :: proc (grid: ^Sudoku) -> SolveState
{
	i, j, _ := find_least_opts(grid)
	return depth_first_search(grid, i, j)
}

find_least_opts :: proc (s: ^Sudoku) -> (i, j: int, set: bool)
{
	min := 20
	set = true

	for ind_i in 0..<9 {
		for ind_j in 0..<9 {
			if s[ind_j][ind_i].num != 0 {
				continue
			}
			set = false
			s[ind_j][ind_i].opts = init_opts
			s[ind_j][ind_i].opts = get_cell_opts(s^, ind_i, ind_j)
			c := card(s[ind_j][ind_i].opts)
			if c < min {
				min = c
				i, j = ind_i, ind_j
			}
		}
	}
	return
}

depth_first_search :: proc (s: ^Sudoku, i := 0, j := 0) -> (state: SolveState)
{
	s[j][i].opts = init_opts
	s[j][i].opts = get_cell_opts(s^, i, j)
	//fmt.println("Trying", i, j)

	if card(s[j][i].opts) == 0 {
			//fmt.printf("No options for %d, %d\n", i, j)
		return .Failed
	}

	for num in 1..=9 {
		if num in s[j][i].opts {
			s[j][i].num = num
			k, l, set := find_least_opts(s)
			if set {
				return .Solved
			}
			state = depth_first_search(s, k, l)
			if state == .Solved {
				break
			}
		}
	}
	if state == .Failed {
		s[j][i].num = 0
	}
	return
}
