-- I hate this language more every day.
-- I had to solve this in python first to solve the problem without this dumb language getting in my way every five seconds.
-- I'm not salty at all :3

part2 :: Bool
part2 = True

expandAmount :: Int
expandAmount = if part2 then 1000000 else 1

main :: IO ()
main = do
  input <- readFile "./Inputs/Day11.txt"

  let grid = filter (not . null) $ lines input
  let height = length grid
  let width = length $ head grid

  let emptyColumns = filter (\x -> all ('.' ==) [grid !! y !! x | y <- [0 .. height - 1]]) [0 .. width - 1]
  let emptyRows = [y | y <- [0 .. height - 1], all (== '.') $ grid !! y]
  let galaxies = [(x, y) | y <- [0 .. height - 1], x <- [0 .. width - 1], grid !! y !! x == '#']

  let calcStepsX = (\x dx -> sum [if s `elem` emptyColumns then expandAmount else 1 | s <- [min x dx .. max x dx - 1]]) :: Int -> Int -> Int
  let calcStepsY = (\y dy -> sum [if s `elem` emptyRows then expandAmount else 1 | s <- [min y dy .. max y dy - 1]]) :: Int -> Int -> Int
  let steps = sum $ zipWith (\index (x, y) -> foldl (\acc (dx, dy) -> acc + calcStepsX x dx + calcStepsY y dy) 0 $ drop (index + 1) galaxies) [0 ..] galaxies

  print steps
