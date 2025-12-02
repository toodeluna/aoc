use std::fs;

const INPUT: &str = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82";

const MAX: i32 = 99;
const INITIAL_VALUE: i32 = 50;

fn part1(input: &str) -> usize {
    let mut value = INITIAL_VALUE;
    let mut amount_of_zeroes = 0;

    for (direction, amount_string) in input.lines().map(|line| line.split_at(1)) {
        let amount = amount_string.parse::<i32>().unwrap();

        let amount = match direction {
            "L" => -amount,
            "R" => amount,
            _ => panic!("invalid direction found"),
        };

        value += amount;
        value = value.rem_euclid(MAX + 1);

        if value == 0 {
            amount_of_zeroes += 1;
        }
    }

    amount_of_zeroes
}

fn part2(input: &str) -> i32 {
    let mut value = INITIAL_VALUE;
    let mut amount_of_zeroes = 0;

    for (direction, amount_string) in input.lines().map(|line| line.split_at(1)) {
        let previous = value;
        let amount = amount_string.parse::<i32>().unwrap();

        let amount = match direction {
            "L" => -amount,
            "R" => amount,
            _ => panic!("invalid direction found"),
        };

        value += amount;

        if value > 0 {
            amount_of_zeroes += value / 100;
        } else if previous == 0 {
            amount_of_zeroes += value.abs() / 100;
        } else {
            amount_of_zeroes += (value.abs() / 100) + 1;
        }

        value = value.rem_euclid(MAX + 1);
    }

    amount_of_zeroes
}

fn main() {
    let input = fs::read_to_string("../../../inputs/2025/day01.txt").unwrap();
    println!("part 1: {}", part1(&input));
    println!("part 2: {}", part2(&input));
}

#[cfg(test)]
mod tests {
    use super::*;

    mod part1 {
        use super::*;
        use std::fs;

        #[test]
        fn it_works_on_example_input() {
            assert_eq!(part1(&INPUT), 3);
        }

        #[test]
        fn it_works() {
            let input = fs::read_to_string("../../../inputs/2025/day01.txt").unwrap();
            assert_eq!(part1(&input), 964);
        }
    }

    mod part2 {
        use super::*;
        use std::fs;

        #[test]
        fn it_works_on_example_input() {
            assert_eq!(part2(&INPUT), 6);
        }

        #[test]
        fn it_works() {
            let input = fs::read_to_string("../../../inputs/2025/day01.txt").unwrap();
            assert_eq!(part2(&input), 5872);
        }
    }
}
