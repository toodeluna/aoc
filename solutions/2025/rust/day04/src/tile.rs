use crate::error::Error;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tile {
    Floor,
    Paper,
}

impl TryFrom<char> for Tile {
    type Error = Error;

    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            '.' => Ok(Self::Floor),
            '@' => Ok(Self::Paper),
            _ => Err(Error::InvalidTile(value)),
        }
    }
}
