use crate::error::Error;
use std::{ops::RangeInclusive, str::FromStr};

#[derive(Debug, Clone)]
pub struct Database(Vec<RangeInclusive<usize>>);

impl Database {
    pub fn new(ranges: Vec<RangeInclusive<usize>>) -> Self {
        let mut result = Self(ranges);
        result.remove_overlaps();

        result
    }

    pub fn contains(&self, id: usize) -> bool {
        for range in &self.0 {
            if range.contains(&id) {
                return true;
            }
        }

        false
    }

    pub fn fresh_ingredient_count(&self) -> usize {
        self.0
            .iter()
            .map(|range| range.end() + 1 - range.start())
            .sum()
    }

    fn remove_overlaps(&mut self) {
        self.0.sort_by_key(|range| *range.start());
        let mut modified_ranges = self.0.clone();

        for (index, range) in self.0.iter().enumerate() {
            for other_range in modified_ranges.iter_mut().skip(index + 1) {
                if range.contains(other_range.start()) && range.contains(other_range.end()) {
                    *other_range = 0..=0;
                } else if range.contains(other_range.start()) {
                    let start = range.end().clone() + 1;
                    let end = other_range.end().clone().max(range.end().clone());
                    *other_range = start..=end;
                }
            }
        }

        self.0 = modified_ranges
            .iter()
            .cloned()
            .filter(|range| *range != (0..=0))
            .collect();
    }
}

impl FromStr for Database {
    type Err = Error;

    fn from_str(string: &str) -> Result<Self, Self::Err> {
        let mut values = vec![];

        for line in string
            .lines()
            .filter(|line| !line.is_empty())
            .map(str::trim)
        {
            let (from_string, to_string) = line
                .split_once('-')
                .ok_or(Error::InvalidRange(line.to_string()))?;

            let from = from_string
                .parse::<usize>()
                .or(Err(Error::InvalidRangeValue(from_string.to_string())))?;

            let to = to_string
                .parse::<usize>()
                .or(Err(Error::InvalidRangeValue(to_string.to_string())))?;

            values.push(from..=to);
        }

        Ok(Self::new(values))
    }
}
