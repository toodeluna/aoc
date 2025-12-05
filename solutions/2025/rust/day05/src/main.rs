use crate::{database::Database, error::Error, ingredients::parse_ingredients};
use std::{env::args, fs};

mod database;
mod error;
mod ingredients;

fn part1(input: &str) -> Result<usize, Error> {
    let (database_string, ingredients_string) = input
        .split_once("\n\n")
        .map(|(first, second)| (first.trim(), second.trim()))
        .ok_or(Error::InvalidInput)?;

    let database = database_string.parse::<Database>()?;

    Ok(parse_ingredients(ingredients_string)?
        .iter()
        .cloned()
        .filter(|&ingredient| database.contains(ingredient))
        .count())
}

fn part2(input: &str) -> Result<usize, Error> {
    Ok(input
        .split_once("\n\n")
        .map(|(first, _)| first.trim())
        .ok_or(Error::InvalidInput)?
        .parse::<Database>()?
        .fresh_ingredient_count())
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
    const ACTUAL_INPUT: &str = include_str!("../../../../../inputs/2025/day05.txt");

    mod part1 {
        use super::*;

        #[test]
        fn it_works_with_example_input() {
            assert_eq!(part1(EXAMPLE_INPUT), Ok(3));
        }

        #[test]
        fn it_works_with_actual_input() {
            assert_eq!(part1(ACTUAL_INPUT), Ok(811));
        }
    }

    mod part2 {
        use super::*;

        #[test]
        fn it_works_with_example_input() {
            assert_eq!(part2(EXAMPLE_INPUT), Ok(14));
        }

        #[test]
        fn it_works_with_actual_input() {
            assert_eq!(part2(ACTUAL_INPUT), Ok(338189277144473));
        }
    }
}
