use crate::{error::Error, tile::Tile};
use std::{
    ops::{Index, IndexMut},
    str::FromStr,
};

type Position = (usize, usize);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Grid {
    width: usize,
    height: usize,
    tiles: Vec<Tile>,
}

impl Grid {
    pub fn tiles(&self) -> impl Iterator<Item = (Tile, Position)> {
        self.tiles.iter().cloned().zip(self.positions())
    }

    pub fn positions(&self) -> impl Iterator<Item = Position> {
        (0..(self.width * self.height)).map(|index| {
            let x = index % self.width;
            let y = (index - x) / self.height;

            (x, y)
        })
    }

    pub fn neighbor_positions(&self, (x, y): Position) -> Vec<Position> {
        let candidates = [
            (x as isize - 1, y as isize - 1),
            (x as isize, y as isize - 1),
            (x as isize + 1, y as isize - 1),
            (x as isize - 1, y as isize),
            (x as isize + 1, y as isize),
            (x as isize - 1, y as isize + 1),
            (x as isize, y as isize + 1),
            (x as isize + 1, y as isize + 1),
        ];

        let valid_positions = candidates.iter().filter_map(|(cx, cy)| {
            if *cx < 0 || *cx >= self.width as isize || *cy < 0 || *cy >= self.height as isize {
                None
            } else {
                Some((*cx as usize, *cy as usize))
            }
        });

        valid_positions.collect()
    }

    pub fn accessible_rolls(&self) -> impl Iterator<Item = Position> {
        self.tiles().filter_map(|(tile, position)| {
            if tile != Tile::Paper {
                return None;
            }

            let paper_count = self
                .neighbor_positions(position)
                .iter()
                .map(|&neighbour_position| self[neighbour_position])
                .filter(|&tile| tile == Tile::Paper)
                .count();

            if paper_count < 4 {
                Some(position)
            } else {
                None
            }
        })
    }
}

impl Index<Position> for Grid {
    type Output = Tile;

    fn index(&self, (x, y): Position) -> &Self::Output {
        &self.tiles[x + (y * self.width)]
    }
}

impl IndexMut<Position> for Grid {
    fn index_mut(&mut self, (x, y): Position) -> &mut Self::Output {
        &mut self.tiles[x + (y * self.width)]
    }
}

impl FromStr for Grid {
    type Err = Error;

    fn from_str(string: &str) -> Result<Self, Self::Err> {
        let mut width = 0usize;
        let mut height = 0usize;
        let mut tiles = vec![];

        for line in string.trim().lines() {
            if width == 0 {
                width = line.len();
            } else if width != line.len() {
                return Err(Error::JaggedInput);
            }

            for ch in line.chars() {
                tiles.push(Tile::try_from(ch)?);
            }

            height += 1;
        }

        Ok(Self {
            width,
            height,
            tiles,
        })
    }
}
