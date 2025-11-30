import Data.Char (isSpace)
import Data.List (dropWhile, dropWhileEnd, stripPrefix)
import Data.List.Split (endBy)
import Data.Maybe (fromJust)
import Utils.StringUtils

data Game = Game Int [CubeSet]
  deriving (Show)

data CubeSet = CubeSet {red :: Int, green :: Int, blue :: Int}
  deriving (Show)

totalSet :: CubeSet
totalSet = CubeSet {red = 12, green = 13, blue = 14}

parseSets :: [String] -> [CubeSet]
parseSets = map parseSet

addSets :: CubeSet -> CubeSet -> CubeSet
addSets set1 set2 = CubeSet {red = red set1 + red set2, green = green set1 + green set2, blue = blue set1 + blue set2}

isSetPossible :: CubeSet -> Bool
isSetPossible set = red set <= red totalSet && green set <= green totalSet && blue set <= blue totalSet

getPowerOfSet :: CubeSet -> Int
getPowerOfSet set = red set * green set * blue set

parseSet :: String -> CubeSet
parseSet line = foldl (\acc -> addSets acc . getPartialCubeSet) CubeSet {red = 0, green = 0, blue = 0} amountAndColorPairs
  where
    splitByComma = map trimString $ endBy "," line
    amountAndColorPairs = map ((\(amount : color : _) -> (read amount :: Int, color)) . endBy " ") splitByComma

    getPartialCubeSet :: (Int, String) -> CubeSet
    getPartialCubeSet (amount, color) = case color of
      "red" -> CubeSet {red = amount, green = 0, blue = 0}
      "green" -> CubeSet {red = 0, green = amount, blue = 0}
      "blue" -> CubeSet {red = 0, green = 0, blue = amount}
      _ -> CubeSet {red = 0, green = 0, blue = 0}

parseGame :: String -> Maybe Game
parseGame line = case stripPrefix "Game " line of
  Nothing -> Nothing
  Just rest -> Just $ Game id sets
    where
      splitIdAndSets = endBy ":" rest
      id = read $ head splitIdAndSets :: Int
      setStrings = endBy ";" $ last splitIdAndSets
      sets = parseSets setStrings

isGamePossible :: Game -> Bool
isGamePossible (Game _ sets) = all isSetPossible sets

minimumAmountOfCubesRequired :: Game -> CubeSet
minimumAmountOfCubesRequired (Game _ sets) = CubeSet {red = maximum allReds, green = maximum allGreens, blue = maximum allBlues}
  where
    allReds = map red sets
    allGreens = map green sets
    allBlues = map blue sets

parseGamesFromInput :: String -> [Game]
parseGamesFromInput = map (fromJust . parseGame) . lines

part1 :: String -> Int
part1 = sum . map (\(Game id _) -> id) . filter isGamePossible . parseGamesFromInput

part2 :: String -> Int
part2 = sum . map (getPowerOfSet . minimumAmountOfCubesRequired) . parseGamesFromInput

main :: IO ()
main = do
  input <- readFile "./Inputs/Day2.txt"
  print $ part1 input
  print $ part2 input
