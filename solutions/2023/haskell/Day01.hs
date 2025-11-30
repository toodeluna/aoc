import Data.Char (isDigit)
import Data.List (find, isPrefixOf)

digitStrings :: [(String, Char)]
digitStrings = [("one", '1'), ("two", '2'), ("three", '3'), ("four", '4'), ("five", '5'), ("six", '6'), ("seven", '7'), ("eight", '8'), ("nine", '9')]

digitStringsReversed :: [(String, Char)]
digitStringsReversed = [(reverse str, ch) | (str, ch) <- digitStrings]

findDigitString :: [(String, Char)] -> String -> Maybe Char
findDigitString _ "" = Nothing
findDigitString strings str = case find (\(digit, _) -> digit `isPrefixOf` str) strings of
  Just (_, ch) -> Just ch
  Nothing -> if isDigit firstChar then Just firstChar else findDigitString strings $ tail str
  where
    firstChar = head str

findFirstDigit :: String -> Maybe Char
findFirstDigit = findDigitString digitStrings

findLastDigit :: String -> Maybe Char
findLastDigit = findDigitString digitStringsReversed . reverse

combineFirstAndLastDigit :: String -> Int
combineFirstAndLastDigit string = case (firstDigit, lastDigit) of
  (Nothing, _) -> 0
  (_, Nothing) -> 0
  (Just d1, Just d2) -> read [d1, d2]
  where
    firstDigit = findFirstDigit string
    lastDigit = findLastDigit string

collectNumbersFromInput :: String -> [Int]
collectNumbersFromInput = map combineFirstAndLastDigit . lines

main :: IO ()
main = do
  input <- readFile "./inputs/Day1.txt"
  print . sum $ collectNumbersFromInput input
