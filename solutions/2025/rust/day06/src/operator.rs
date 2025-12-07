use crate::error::Error;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Operator {
    Add,
    Mul,
}

impl TryFrom<char> for Operator {
    type Error = Error;

    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            '+' => Ok(Self::Add),
            '*' => Ok(Self::Mul),
            _ => Err(Error::InvalidOperator(value.to_string())),
        }
    }
}

impl FromStr for Operator {
    type Err = Error;

    fn from_str(string: &str) -> Result<Self, Self::Err> {
        if string.len() > 1 {
            Err(Error::InvalidOperator(string.to_string()))
        } else {
            string
                .chars()
                .next()
                .ok_or(Error::InvalidOperator(String::new()))?
                .try_into()
        }
    }
}
