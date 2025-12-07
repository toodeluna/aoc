// I'll look at part 2 of this one later cos I genuinally cannot be fucking bothered with this
// stupid puzzle right now.

use crate::{error::Error, problem::Problem};
use std::{env::args, fs};

mod error;
mod operator;
mod problem;

const EXAMPLE_INPUT: &str = include_str!("../data/example-input.txt");

fn part1(input: &str) -> Result<usize, Error> {
    let columns = read_input_columns(input);
    let mut result = 0;

    for column in columns {
        result += Problem::try_from(&column[..])?.result();
    }

    Ok(result)
}

fn part2(input: &str) -> Result<usize, Error> {
    let width = input.lines().nth(0).unwrap_or_default().len();
    let height = input.lines().count();

    Ok(0)
}

fn main() -> Result<(), Error> {
    let file_path = args()
        .skip(1)
        .next()
        .expect("expected single argument for input file path");

    let input = fs::read_to_string(file_path).unwrap();

    println!("part 1: {}", part1(EXAMPLE_INPUT)?);
    println!("part 2: {}", part2(EXAMPLE_INPUT)?);

    Ok(())
}

fn read_input_columns<'a>(input: &'a str) -> Vec<Vec<String>> {
    let mut columns = Vec::new();

    for line in input.lines() {
        for (problem_index, value) in line.split_whitespace().enumerate() {
            while columns.len() < problem_index + 1 {
                columns.push(Vec::new());
            }

            columns[problem_index].push(value.to_string());
        }
    }

    columns
}
