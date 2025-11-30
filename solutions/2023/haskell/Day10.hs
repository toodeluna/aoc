-- This code is cursed. Read at your own risk.

import Data.List (elemIndex, findIndex)
import Data.Maybe (fromJust)

-- hehe, i cheat :3
s :: Char
s = '7'

findStartPosition :: [String] -> (Int, Int)
findStartPosition lines = (startX, startY)
  where
    startY = fromJust $ findIndex (elem 'S') lines
    startX = fromJust $ elemIndex 'S' $ lines !! startY

followPath :: [String] -> (Int, Int) -> [(Int, Int)]
followPath grid pos = followPath' pos pos True
  where
    followPath' :: (Int, Int) -> (Int, Int) -> Bool -> [(Int, Int)]
    followPath' (px, py) current@(cx, cy) isInitial = if current == pos && not isInitial then [] else nextPosition : followPath' current nextPosition False
      where
        ch = grid !! cy !! cx
        actualCh = if ch == 'S' then s else ch
        nextPosition = case actualCh of
          '-' -> if px < cx then (cx + 1, cy) else (cx - 1, cy)
          '|' -> if py < cy then (cx, cy + 1) else (cx, cy - 1)
          'L' -> if px > cx then (cx, cy - 1) else (cx + 1, cy)
          'J' -> if px < cx then (cx, cy - 1) else (cx - 1, cy)
          'F' -> if px > cx then (cx, cy + 1) else (cx + 1, cy)
          '7' -> if px < cx then (cx, cy + 1) else (cx - 1, cy)
          _ -> (0, 0)

getCellsInLoop :: [String] -> [(Char, Int, Int)]
getCellsInLoop grid = getCellsInLoop' False (0, 0)
  where
    rowLength = length $ head grid
    firstChar = head $ head grid
    path = followPath grid $ findStartPosition grid

    isLoopStart :: Char -> Bool
    isLoopStart ch = ch == '|' || ch == 'J' || ch == 'L'

    getCellsInLoop' :: Bool -> (Int, Int) -> [(Char, Int, Int)]
    getCellsInLoop' isInLoop pos@(x, y)
      | x >= rowLength || y >= length grid = []
      | (pos `elem` path) && isLoopStart actualCh = getCellsInLoop' (not isInLoop) nextPosition
      | pos `elem` path = getCellsInLoop' isInLoop nextPosition
      | pos `notElem` path = if isInLoop then (actualCh, x, y) : getCellsInLoop' isInLoop nextPosition else getCellsInLoop' isInLoop nextPosition
      | otherwise = getCellsInLoop' isInLoop nextPosition
      where
        ch = grid !! y !! x
        actualCh = if ch == 'S' then s else ch
        nextPosition = if x + 1 >= rowLength then (0, y + 1) else (x + 1, y)

part1 :: [String] -> Int
part1 grid = length (followPath grid $ findStartPosition grid) `div` 2

part2 :: [String] -> Int
part2 = length . getCellsInLoop

main :: IO ()
main = do
  input <- readFile "./Inputs/Day10.txt"

  let grid = lines input

  print $ part1 grid
  print $ part2 grid
