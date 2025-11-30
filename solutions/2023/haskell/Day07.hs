-- Set `enableJokers` to `False` for part one and `True` for part two.

import Data.Char (ord)
import Data.List (sort, sortBy)
import Data.List.Split (endBy)
import qualified Data.Map as Map

data HandType = FiveOfAKind | FourOfAKind | FullHouse | ThreeOfAKind | TwoPair | OnePair | HighCard
  deriving (Show)

enableJokers :: Bool
enableJokers = True

countOccurences :: (Eq a) => a -> [a] -> Int
countOccurences _ [] = 0
countOccurences value (first : rest) = (if first == value then 1 else 0) + countOccurences value rest

getAmountsInHand :: String -> Map.Map Char Int
getAmountsInHand input = getAmountsInHand' input Map.empty
  where
    getAmountsInHand' :: String -> Map.Map Char Int -> Map.Map Char Int
    getAmountsInHand' (first : rest) result = Map.insertWith (+) first 1 $ getAmountsInHand' rest result
    getAmountsInHand' [] result = result

matchHandType :: [Int] -> HandType
matchHandType values = case values of
  [5] -> FiveOfAKind
  [1, 4] -> FourOfAKind
  [2, 3] -> FullHouse
  [1, 1, 3] -> ThreeOfAKind
  [1, 2, 2] -> TwoPair
  [1, 1, 1, 2] -> OnePair
  _ -> HighCard

getHandType :: String -> HandType
getHandType hand = matchHandType values
  where
    amounts = Map.toList $ getAmountsInHand hand
    values = sort $ map snd amounts

getHandTypeWithJokers :: String -> HandType
getHandTypeWithJokers hand = matchHandType $ sort valueToCheck
  where
    amounts = Map.toList $ getAmountsInHand hand
    amountOfJokers = countOccurences 'J' hand

    (highest : rest) = if amountOfJokers == 5 then sort $ map snd amounts else reverse $ sort $ map snd $ filter (\(typ, _) -> typ /= 'J') amounts
    valueToCheck = if amountOfJokers == 5 then highest : rest else sort $ (highest + amountOfJokers) : rest

getHandTypeStrength :: HandType -> Int
getHandTypeStrength HighCard = 0
getHandTypeStrength OnePair = 1
getHandTypeStrength TwoPair = 2
getHandTypeStrength ThreeOfAKind = 3
getHandTypeStrength FullHouse = 4
getHandTypeStrength FourOfAKind = 5
getHandTypeStrength FiveOfAKind = 6

getCardStrength :: Char -> Int
getCardStrength ch = case ch of
  'T' -> 10
  'Q' -> 12
  'K' -> 13
  'A' -> 14
  'J' -> if enableJokers then 0 else 11
  _ -> ord ch - ord '0'

compareCards :: String -> String -> Ordering
compareCards (leftFirst : left) (rightFirst : right) = case compare (getCardStrength leftFirst) (getCardStrength rightFirst) of
  EQ -> compareCards left right
  o -> o
compareCards _ _ = EQ

compareHands :: String -> String -> Ordering
compareHands left right
  | leftStrength > rightStrength = GT
  | leftStrength < rightStrength = LT
  | otherwise = compareCards left right
  where
    leftStrength = getHandTypeStrength $ (if enableJokers then getHandTypeWithJokers else getHandType) left
    rightStrength = getHandTypeStrength $ (if enableJokers then getHandTypeWithJokers else getHandType) right

main :: IO ()
main = do
  input <- readFile "./Inputs/Day7.txt"

  let handsWithBids = map ((\[x, y] -> (x, read y :: Int)) . endBy " ") $ lines input
  print $ sum $ zipWith (curry (\(rank, (_, bid)) -> rank * bid)) [1 ..] $ sortBy (\a b -> compareHands (fst a) (fst b)) handsWithBids
