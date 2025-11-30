module Utils.GridUtils where

getNeighbours :: (Int, Int) -> [[a]] -> [(Int, Int)]
getNeighbours (x, y) grid = filter isValidPosition allPossibleNeighbours
  where
    lineLength = length $ head grid
    allPossibleNeighbours = [(x - 1, y - 1), (x, y - 1), (x + 1, y - 1), (x - 1, y), (x + 1, y), (x - 1, y + 1), (x, y + 1), (x + 1, y + 1)]

    isValidPosition :: (Int, Int) -> Bool
    isValidPosition (nx, ny) = nx >= 0 && nx < lineLength && ny >= 0 && ny < length grid

elemAt :: (Int, Int) -> [[a]] -> a
elemAt (x, y) grid = grid !! y !! x
