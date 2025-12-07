use crate::{error::Error, operator::Operator};

#[derive(Debug, Clone)]
pub struct Problem {
    pub operator: Operator,
    pub values: Vec<usize>,
}

impl Problem {
    pub fn new(operator: Operator) -> Self {
        Self {
            operator,
            values: Default::default(),
        }
    }

    pub fn result(&self) -> usize {
        match self.operator {
            Operator::Add => self.values.iter().sum(),
            Operator::Mul => self.values.iter().product(),
        }
    }
}

impl<T: AsRef<str> + ToString> TryFrom<&[T]> for Problem {
    type Error = Error;

    fn try_from(value: &[T]) -> Result<Self, Self::Error> {
        let (values, operator_parts) = value.as_ref().split_at(value.len() - 1);
        let operator = operator_parts[0].as_ref().parse::<Operator>()?;
        let mut result = Problem::new(operator);

        for value in values {
            let number = value
                .as_ref()
                .parse::<usize>()
                .or(Err(Error::InvalidValue(value.to_string())))?;

            result.values.push(number);
        }

        Ok(result)
    }
}
