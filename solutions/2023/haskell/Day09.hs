import Data.List.Split (endBy)

parseSequence :: String -> [Int]
parseSequence = map read . endBy " "

findDifferences :: [Int] -> [Int]
findDifferences (first : second : rest) = second - first : findDifferences (second : rest)
findDifferences _ = []

findAllDifferences :: [Int] -> [[Int]]
findAllDifferences seq
  | all (0 ==) seq = []
  | otherwise = nextSequence : findAllDifferences nextSequence
  where
    nextSequence = findDifferences seq

findNextInSequence :: [Int] -> Int
findNextInSequence seq = findNextInSequence' (differences ++ [seq]) 0
  where
    differences = reverse $ findAllDifferences seq

    findNextInSequence' :: [[Int]] -> Int -> Int
    findNextInSequence' [first] valueToAdd = last first + valueToAdd
    findNextInSequence' (first : rest) valueToAdd = findNextInSequence' rest $ last first + valueToAdd
    findNextInSequence' [] _ = 0

findPrevInSequence :: [Int] -> Int
findPrevInSequence seq = findPrevInSequence' (differences ++ [reverse seq]) 0
  where
    differences = map reverse $ reverse $ findAllDifferences seq

    findPrevInSequence' :: [[Int]] -> Int -> Int
    findPrevInSequence' [first] valueToAdd = last first - valueToAdd
    findPrevInSequence' (first : rest) valueToAdd = findPrevInSequence' rest $ last first - valueToAdd
    findPrevInSequence' [] _ = 0

part1 :: String -> Int
part1 input = sum $ map findNextInSequence sequences
  where
    sequences = map parseSequence $ lines input

part2 :: String -> Int
part2 input = sum $ map findPrevInSequence sequences
  where
    sequences = map parseSequence $ lines input

main :: IO ()
main = do
  input <- readFile "./Inputs/Day9.txt"

  let sequences = map parseSequence $ lines input

  print $ part1 input
  print $ part2 input
