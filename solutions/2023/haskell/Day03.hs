import Data.Char (isDigit)
import Data.List (nub)
import Data.Maybe (mapMaybe)

type Schematic = [String]

type Position = (Int, Int)

isSymbol :: Char -> Bool
isSymbol ch = ch /= '.' && not (isDigit ch)

getNeighbours :: Position -> Schematic -> [Position]
getNeighbours (x, y) schematic = filter isValidPosition allPossibleNeighbours
  where
    lineLength = length $ head schematic
    allPossibleNeighbours = [(x - 1, y - 1), (x, y - 1), (x + 1, y - 1), (x - 1, y), (x + 1, y), (x - 1, y + 1), (x, y + 1), (x + 1, y + 1)]

    isValidPosition :: (Int, Int) -> Bool
    isValidPosition (nx, ny) = nx >= 0 && nx < lineLength && ny >= 0 && ny < length schematic

readDigitInLine :: Int -> String -> Maybe (Int, Int)
readDigitInLine index line
  | not $ isDigit $ line !! index = Nothing
  | isPreviousInLineADigit = readDigitInLine (index - 1) line
  | otherwise = Just (read $ takeWhile isDigit . drop index $ line, index)
  where
    isPreviousInLineADigit = index /= 0 && isDigit (line !! (index - 1))

getNumberAt :: Position -> Schematic -> Maybe (Int, Position)
getNumberAt (x, y) schematic = if isDigit valueAtPosition then getResult $ readDigitInLine x $ schematic !! y else Nothing
  where
    valueAtPosition = schematic !! y !! x
    getResult :: Maybe (Int, Int) -> Maybe (Int, Position)
    getResult value = case value of
      Nothing -> Nothing
      Just (value, index) -> Just (value, (index, y))

findSymbolsInSchematic :: Schematic -> [(Char, Position)]
findSymbolsInSchematic = concatMap (\(line, y) -> findSymbolsInLine y line) . flip zip [0 ..]
  where
    findSymbolsInLine :: Int -> String -> [(Char, Position)]
    findSymbolsInLine y = map (\(value, x) -> (value, (x, y))) . filter (\(ch, _) -> isSymbol ch) . flip zip [0 ..]

part1 :: Schematic -> Int
part1 schematic = sum $ map fst $ nub $ mapMaybe (`getNumberAt` schematic) $ concatMap (\(ch, pos) -> getNeighbours pos schematic) $ findSymbolsInSchematic schematic

part2 :: Schematic -> Int
part2 schematic = sum $ map (product . map fst) $ filter (\positions -> length positions == 2) $ map (\(ch, pos) -> nub $ mapMaybe (`getNumberAt` schematic) $ getNeighbours pos schematic) $ filter (\(ch, _) -> ch == '*') $ findSymbolsInSchematic schematic

main :: IO ()
main = do
  input <- readFile "./Inputs/Day3.txt"
  print $ part1 $ lines input
  print $ part2 $ lines input
