module Utils.StringUtils where

import Data.Char (isSpace)
import Data.List (dropWhileEnd)

trimString :: String -> String
trimString = dropWhile isSpace . dropWhileEnd isSpace
