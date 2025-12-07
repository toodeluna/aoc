use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    #[error("invalid operator detected, expected '+' or '*' but got '{0}'")]
    InvalidOperator(String),
    #[error("invalid value detected, expected number but got '{0}'")]
    InvalidValue(String),
    #[error("invalid problem input: '{0:?}'")]
    InvalidProblem(Vec<String>),
}
