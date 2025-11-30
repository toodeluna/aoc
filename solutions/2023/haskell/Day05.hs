-- This only contains the solution to part 2 because I had to restart this one like five times
-- because this problem was too hard for my tiny brain :3

import Data.Function (on)
import Data.List (sortBy, stripPrefix)
import Data.List.Split (endBy)
import Data.Maybe (catMaybes, fromJust, fromMaybe, isJust)
import Utils.StringUtils (trimString)

pairs :: [Int] -> [(Int, Int)]
pairs (start : length : rest) = (start, start + length) : pairs rest
pairs _ = []

triples :: [Int] -> (Int, Int, Int)
triples (dest : start : length : rest) = (start, start + length, dest)
triples _ = (0, 0, 0)

parseSeeds :: String -> [(Int, Int)]
parseSeeds line = pairs $ map read $ endBy " " $ trimString $ fromMaybe line $ stripPrefix "seeds:" line

parseRangeBlocks :: [String] -> [(Int, Int, Int)]
parseRangeBlocks = map parseBlock
  where
    parseBlock :: String -> (Int, Int, Int)
    parseBlock line = triples $ map read $ endBy " " line

convertRange :: [(Int, Int)] -> [(Int, Int, Int)] -> [(Int, Int)]
convertRange seeds ranges = convertRange' seeds ranges []
  where
    convertRange' :: [(Int, Int)] -> [(Int, Int, Int)] -> [(Int, Int)] -> [(Int, Int)]
    convertRange' [] _ result = result
    convertRange' seeds [] result = seeds ++ result
    convertRange' ((sstart, send) : seeds) ((rstart, rend, dest) : ranges) result = case overlap of
      Just o -> convertRange' (seeds ++ catMaybes [before, after]) ranges (o : result)
      Nothing -> convertRange' ((sstart, send) : seeds) ranges result
      where
        overlapStart = maximum [sstart, rstart]
        overlapEnd = minimum [send, rend]
        overlap = if overlapStart <= overlapEnd then Just (overlapStart - rstart + dest, overlapEnd - rstart + dest) else Nothing
        before = if overlapStart > sstart then Just (sstart, overlapStart) else Nothing
        after = if send > overlapEnd then Just (overlapEnd, send) else Nothing

convertRanges :: [(Int, Int)] -> [[(Int, Int, Int)]] -> [(Int, Int)]
convertRanges seeds [] = seeds
convertRanges seeds (range : ranges) = convertRanges nextSeeds ranges
  where
    nextSeeds = concatMap (\seed -> convertRange [seed] range) seeds

main :: IO ()
main = do
  input <- readFile "./Inputs/Day5.txt"

  let (seedLine : rangeBlocks) = endBy "\n\n" input
  let seeds = parseSeeds seedLine
  let rangeBlocksNoHeader = map (drop 1 . lines) rangeBlocks
  let ranges = map parseRangeBlocks rangeBlocksNoHeader
  let nextSeeds = map (\seed -> convertRange [seed] $ ranges !! 1) seeds
  let t = convertRanges seeds ranges

  print $ minimum $ map fst $ sortBy (compare `on` fst) t
