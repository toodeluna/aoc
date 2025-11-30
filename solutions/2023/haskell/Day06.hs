import Data.Char (isSpace)
import Data.List.Split (endBy)
import Utils.StringUtils (trimString)

getNumbers :: String -> [Int]
getNumbers line = map (read . trimString) $ filter (not . null) $ endBy " " $ trimString $ last $ endBy ":" line

getNumber :: String -> Int
getNumber line = read $ filter (not . isSpace) $ last $ endBy ":" line

calculateDistanceTraveled :: Int -> Int -> Int
calculateDistanceTraveled timeHeldDown timeLimit = millimetersTraveled
  where
    remainingTime = timeLimit - timeHeldDown
    millimetersTraveled = timeHeldDown * remainingTime

calculateOptions :: Int -> [(Int, Int)]
calculateOptions timeLimit = map (\timeHeldDown -> (timeHeldDown, calculateDistanceTraveled timeHeldDown timeLimit)) [0 .. timeLimit]

calculateOptionsForHighScore :: (Int, Int) -> [(Int, Int)]
calculateOptionsForHighScore (timeLimit, highScore) = filter (\(_, score) -> score > highScore) $ calculateOptions timeLimit

findFirstAndLastHighScore :: (Int, Int) -> (Int, Int)
findFirstAndLastHighScore (timeLimit, highScore) = (findFirstHighScore 0, findLastHighScore timeLimit)
  where
    findFirstHighScore :: Int -> Int
    findFirstHighScore value = if calculateDistanceTraveled value timeLimit > highScore then value else findFirstHighScore (value + 1)

    findLastHighScore :: Int -> Int
    findLastHighScore value = if calculateDistanceTraveled value timeLimit > highScore then value else findLastHighScore (value - 1)

part1 :: String -> Int
part1 input = product $ map (length . calculateOptionsForHighScore) races
  where
    [timeLine, distanceLine] = lines input
    races = zip (getNumbers timeLine) (getNumbers distanceLine)

part2 :: String -> Int
part2 input = last - first + 1
  where
    [timeLine, distanceLine] = lines input
    time = getNumber timeLine
    distance = getNumber distanceLine
    (first, last) = findFirstAndLastHighScore (time, distance)

main :: IO ()
main = do
  input <- readFile "./Inputs/Day6.txt"

  print $ part1 input
  print $ part2 input
