use num::Integer;
use std::fs;

const EXAMPLE_INPUT: &str = "987654321111111
811111111111119
234234234234278
818181911112111";

fn part1(input: &str) -> usize {
    let mut sum = 0usize;

    for line in input.lines() {
        let digits = line
            .chars()
            .filter_map(|ch| ch.to_digit(10))
            .collect::<Vec<_>>();

        let mut digits = &digits[..];
        let mut number = 0usize;

        for end in (0..2).rev() {
            let (index, value) =
                find_largest_number(digits.iter().cloned().take(digits.len() - end)).unwrap();

            digits = &digits[(index + 1)..];
            number += value as usize * 10usize.pow(end as u32);
        }

        sum += number as usize;
    }

    sum
}

fn part2(input: &str) -> usize {
    let mut sum = 0usize;

    for line in input.lines() {
        let digits = line
            .chars()
            .filter_map(|ch| ch.to_digit(10))
            .collect::<Vec<_>>();

        let mut digits = &digits[..];
        let mut number = 0usize;

        for end in (0..12).rev() {
            let (index, value) =
                find_largest_number(digits.iter().cloned().take(digits.len() - end)).unwrap();

            digits = &digits[(index + 1)..];
            number += value as usize * 10usize.pow(end as u32);
        }

        sum += number as usize;
    }

    sum
}

fn find_largest_number<T: Integer>(iterator: impl IntoIterator<Item = T>) -> Option<(usize, T)> {
    let mut result = None;

    for (index, current) in iterator.into_iter().enumerate() {
        result = match result {
            Some((_, value)) if current > value => Some((index, current)),
            None => Some((index, current)),
            _ => result,
        };
    }

    result
}

fn main() {
    let input = fs::read_to_string("../../../inputs/2025/day03.txt").unwrap();
    println!("part 1: {}", part1(&input));
    println!("part 2: {}", part2(&input));
}

#[cfg(test)]
mod tests {
    use super::*;

    mod part1 {
        use super::*;

        #[test]
        fn it_works_on_example_input() {
            assert_eq!(part1(EXAMPLE_INPUT), 357);
        }

        #[test]
        fn it_works_on_actual_input() {
            let input = fs::read_to_string("../../../inputs/2025/day03.txt").unwrap();
            assert_eq!(part1(&input), 17405);
        }
    }

    mod part2 {
        use super::*;

        #[test]
        fn it_works_on_example_input() {
            assert_eq!(part2(EXAMPLE_INPUT), 3121910778619);
        }

        #[test]
        fn it_works_on_actual_input() {
            let input = fs::read_to_string("../../../inputs/2025/day03.txt").unwrap();
            assert_eq!(part2(&input), 171990312704598);
        }
    }
}
