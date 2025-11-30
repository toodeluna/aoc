{-# LANGUAGE TupleSections #-}

import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import Data.List.Split (endBy)
import qualified Data.Map as Map
import Data.Maybe (fromMaybe)
import Utils.StringUtils

type Multipliers = Map.Map Int Int

data Card = Card {winningNumbers :: [Int], myNumbers :: [Int]}
  deriving (Show)

parseCard :: String -> Card
parseCard input =
  Card
    { winningNumbers = readNumbers $ head splitNumbers,
      myNumbers = readNumbers $ splitNumbers !! 1
    }
  where
    allNumbers = endBy ":" input !! 1
    splitNumbers = map trimString $ endBy "|" allNumbers

    readNumbers :: String -> [Int]
    readNumbers = map read . filter (not . null) . endBy " "

myWinningNumbers :: Card -> [Int]
myWinningNumbers card = filter (`elem` winningNumbers card) $ myNumbers card

cardScore :: Card -> Int
cardScore = getScore . length . myWinningNumbers
  where
    getScore :: Int -> Int
    getScore 0 = 0
    getScore 1 = 1
    getScore x = 2 * getScore (x - 1)

part1 :: String -> Int
part1 = sum . map (cardScore . parseCard) . lines

part2 :: String -> Int
part2 input = processCards Map.empty $ zip [1 ..] (map parseCard $ lines input)
  where
    cards = zip [1 ..] (map parseCard $ lines input)

    cardsToMultiply :: (Int, Card) -> [Int]
    cardsToMultiply (id, card) = [id + 1 .. (id + length (myWinningNumbers card))]

    processCards :: Multipliers -> [(Int, Card)] -> Int
    processCards _ [] = 0
    processCards multipliers [(id, card)] = 1 + fromMaybe 0 (Map.lookup id multipliers)
    processCards multipliers (first : rest) = amountOfThisCard + processCards nextMultipliers rest
      where
        amountOfThisCard = 1 + fromMaybe 0 (Map.lookup (fst first) multipliers)
        nextCardsToMultiply = map (,amountOfThisCard) $ cardsToMultiply first
        nextMultipliers = foldl (\acc (id, amount) -> Map.insertWith (+) id amount acc) multipliers nextCardsToMultiply

main :: IO ()
main = do
  input <- readFile "./Inputs/Day4.txt"
  print $ part1 input
  print $ part2 input
