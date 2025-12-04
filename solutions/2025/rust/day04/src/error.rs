use thiserror::Error;

#[derive(Debug, Error, PartialEq, Eq)]
pub enum Error {
    #[error("invalid tile found, expected '.' or '@' but got '{0}'")]
    InvalidTile(char),
    #[error("grid cannot be parsed from jagged input")]
    JaggedInput,
}
