# Sudoku solving in Odin

This is a repo to store a pair of sudoku solving projects
in [Odin](https://odin-lang.org). Both use a
[depth first search](https://en.wikipedia.org/wiki/Sudoku_solving_algorithms#Backtracking)
algorithm for solving, and prioritise cells with fewer possibilities,
but they differ in how they find those cells in the grid.

## First try
The first (just called [sudoku](/sudoku)) uses a simple linear search,
and was easy to implement, but is very inefficient, as many cells are
needlessly checked to see if they are the minimum.

## More optimal
My second approach utilises a [dway heap](https://github.com/tim-de/odin-dway-heap)
as a priority queue to find the cell with the minimum number of options at
each stage of the recursive algorithm.

## Comparison
When the two resulting programs are timed against one-another
using the 50 sudoku puzzles [here](/heapdoku/p096_sudoku.txt),
heapdoku is around 4 times faster, and when solving an example
[deigned to be hard for depth first search](https://en.wikipedia.org/wiki/File:Sudoku_puzzle_hard_for_brute_force.svg)
the difference is even more pronounced, with the heap-based algorithm running
at least 10 times faster.
