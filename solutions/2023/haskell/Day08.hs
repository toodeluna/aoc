-- I may have cheated on this one (looked at the subreddit) and I'm glad I did because I would've never figured this out by myself.
-- This is also only the solution to part 2.

import Data.List (stripPrefix)
import Data.List.Extra (stripSuffix)
import Data.List.Split (endBy, endsWith)
import qualified Data.Map as Map
import Data.Maybe (catMaybes, fromJust, isJust, isNothing, mapMaybe)
import Debug.Trace (traceShowId)
import Utils.StringUtils (trimString)

-- I still don't understand why this works :3
lcmm :: [Int] -> Int
lcmm = foldr lcm 1

parseNode :: String -> (String, (String, String))
parseNode line = (label, (fromJust $ stripPrefix "(" left, fromJust $ stripSuffix ")" right))
  where
    [label, directionsInput] = endBy " = " line
    [left, right] = map trimString $ endBy "," directionsInput

countSteps :: String -> String -> Map.Map String (String, String) -> Int
countSteps instructions startingNode nodes = if null instructions then 0 else countSteps' instructions startingNode
  where
    countSteps' :: String -> String -> Int
    countSteps' _ [_, _, 'Z'] = 0
    countSteps' [] startingNode = countSteps' instructions startingNode
    countSteps' (instruction : rest) startingNode = case instruction of
      'L' -> 1 + countSteps' rest (fst node)
      'R' -> 1 + countSteps' rest (snd node)
      _ -> 0
      where
        node = fromJust $ Map.lookup startingNode nodes

main :: IO ()
main = do
  input <- readFile "./Inputs/Day8.txt"

  let (instructions : nodesInput) = filter (not . null) $ lines input
  let nodes = map parseNode nodesInput
  let startingNodes = filter (isJust . stripSuffix "A") $ map fst nodes
  let nodesMap = Map.fromList nodes

  print $ lcmm $ map (\start -> countSteps instructions start nodesMap) startingNodes
