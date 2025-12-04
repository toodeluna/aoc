use num::Integer;
use std::{collections::HashSet, convert::identity, fs};

fn part1(input: &str) -> usize {
    let ranges = input
        .split(',')
        .map(|range_string| range_string.split_once('-'))
        .filter_map(identity);

    let mut invalid_ids = vec![];

    for (start_string, end_string) in ranges {
        let start = start_string.parse::<usize>().unwrap();
        let end = end_string.parse::<usize>().unwrap();

        for number in start..=end {
            if is_repeating_twice(number) {
                invalid_ids.push(number);
            }
        }
    }

    invalid_ids.iter().sum()
}

fn part2(input: &str) -> usize {
    let ranges = input
        .split(',')
        .map(|range_string| range_string.split_once('-'))
        .filter_map(identity);

    let mut invalid_ids = vec![];

    for (start_string, end_string) in ranges {
        let start = start_string.parse::<usize>().unwrap();
        let end = end_string.parse::<usize>().unwrap();

        for number in start..=end {
            if is_repeating(number) {
                invalid_ids.push(number);
            }
        }
    }

    invalid_ids.iter().sum()
}

fn is_repeating_twice(number: impl Integer + ToString) -> bool {
    let string = number.to_string();

    if string.len() % 2 != 0 {
        return false;
    }

    let split_part = string.len() / 2;
    let (first, second) = string.split_at(split_part);

    first == second
}

fn is_repeating(number: impl Integer + ToString) -> bool {
    let string = number.to_string();

    for index in (1..string.len()).filter(|index| string.len() % index == 0) {
        let parts = (0..string.len())
            .step_by(index)
            .map(|split| &string[split..(split + index)])
            .collect::<HashSet<_>>();

        if parts.len() == 1 {
            return true;
        }
    }

    false
}

fn main() {
    let input = fs::read_to_string("../../../inputs/2025/day02.txt").unwrap();
    println!("part 1: {}", part1(&input.trim()));
    println!("part 2: {}", part2(&input.trim()));
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE_INPUT: &str = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

    mod part1 {
        use super::*;

        #[test]
        fn it_works_on_example_input() {
            assert_eq!(part1(&EXAMPLE_INPUT), 1227775554);
        }

        #[test]
        fn it_works_on_actual_input() {
            let input = fs::read_to_string("../../../inputs/2025/day02.txt").unwrap();
            assert_eq!(part1(&input.trim()), 31210613313);
        }
    }

    mod part2 {
        use super::*;

        #[test]
        fn it_works_on_example_input() {
            assert_eq!(part2(&EXAMPLE_INPUT), 4174379265);
        }

        #[test]
        fn it_works_on_actual_input() {
            let input = fs::read_to_string("../../../inputs/2025/day02.txt").unwrap();
            assert_eq!(part2(&input.trim()), 41823587546);
        }
    }
}
