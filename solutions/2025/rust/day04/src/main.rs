use crate::{error::Error, grid::Grid, tile::Tile};
use std::{env::args, fs};

mod error;
mod grid;
mod tile;

fn part1(input: &str) -> Result<usize, Error> {
    Ok(input.parse::<Grid>()?.accessible_rolls().count())
}

fn part2(input: &str) -> Result<usize, Error> {
    let mut grid = input.parse::<Grid>()?;
    let mut result = 0usize;

    loop {
        let positions_to_remove = grid.accessible_rolls().collect::<Vec<_>>();

        if positions_to_remove.is_empty() {
            break;
        }

        for &position in &positions_to_remove {
            grid[position] = Tile::Floor;
        }

        result += positions_to_remove.len();
    }

    Ok(result)
}

fn main() -> Result<(), Error> {
    let file_path = args()
        .skip(1)
        .next()
        .expect("expected single argument for input file path");

    let input = fs::read_to_string(file_path).unwrap();

    println!("part 1: {}", part1(&input)?);
    println!("part 2: {}", part2(&input)?);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = include_str!("../data/example-input.txt");
    const ACTUAL_INPUT: &str = include_str!("../../../../../inputs/2025/day04.txt");

    mod part1 {
        use super::*;

        #[test]
        fn it_works_with_example_input() {
            assert_eq!(part1(EXAMPLE_INPUT), Ok(13));
        }

        #[test]
        fn it_works_with_actual_input() {
            assert_eq!(part1(ACTUAL_INPUT), Ok(1493));
        }
    }

    mod part2 {
        use super::*;

        #[test]
        fn it_works_with_example_input() {
            assert_eq!(part2(EXAMPLE_INPUT), Ok(43));
        }

        #[test]
        fn it_works_with_actual_input() {
            assert_eq!(part2(ACTUAL_INPUT), Ok(9194));
        }
    }
}
