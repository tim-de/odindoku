package main

import "core:os"
import "core:fmt"

main :: proc ()
{
	fname := "p096_sudoku.txt"
	if len(os.args) > 1 {
		fname = os.args[1]
	}
	grids := get_grids(fname)
	defer delete_grids(&grids)

	solved := 0
	//sum := 0

	for s in grids {
		//fmt.println("\n")
		//print_sudoku(s^)
		if dfs_solve(s) == .Solved {
			solved += 1
		}
		//fmt.println("===================")
		//print_sudoku(s^)
		//sum += get_corner_val(s)
	}
	fmt.println("Solved", solved, "out of", len(grids))
	//fmt.println("Sum of corners is", sum)
}
