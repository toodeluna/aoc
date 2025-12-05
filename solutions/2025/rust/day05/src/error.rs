use thiserror::Error;

#[derive(Debug, Error, PartialEq, Eq, Clone)]
pub enum Error {
    #[error("invalid database value specified, expected range but got '{0}'")]
    InvalidRange(String),
    #[error("invalid range value specified, expected number but got '{0}'")]
    InvalidRangeValue(String),
    #[error("invalid ingredient id specified, expected number but got '{0}'")]
    InvalidIngredientId(String),
    #[error("invalid input specified, expected database and ingredients input")]
    InvalidInput,
}
