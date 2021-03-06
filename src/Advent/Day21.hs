module Advent.Day21 (day21a, day21b) where

  import Data.List
  import qualified Data.List.Split as S
  import Text.Parsec
  import Text.Parsec.String

  data Rule = Rule [[[Char]]] [[Char]] deriving (Show,Eq)

  day21a :: String -> Int
  day21a s = let rs = rules s
                 itr = iterate (stich . expand rs . next) $ initial
             in on $ itr !! 2

  day21b :: String -> [Rule]
  day21b s = []

  rules :: String -> [Rule]
  rules = map (right . parseInput) . lines

  initial :: [[Char]]
  initial = [".#.", "..#", "###"]

  stich :: [[[Char]]] -> [[Char]]
  stich is = map concat $ transpose  $ map concat $ S.chunksOf (chunckSize is) is

  chunckSize :: [[[Char]]] -> Int
  chunckSize = floor . sqrt . fromIntegral . length

  next :: [[Char]] -> [[[Char]]]
  next iss
    | length iss `mod` 2 == 0 = divide 2 iss
    | length iss `mod` 3 == 0 = divide 3 iss
    | otherwise = error "not evenly sized"

  expand :: [Rule] -> [[[Char]]] -> [[[Char]]]
  expand _ [] = []
  expand rs (iss:isss) = case find' rs iss of
    Nothing -> error $ show iss
    (Just a) -> a:(expand rs isss)

  find' :: [Rule] -> [[Char]] -> Maybe [[Char]]
  find' [] iss = Nothing
  find' ((Rule from to):rs) iss = case find (==iss) from of
    (Just a) -> (Just to)
    Nothing -> find' rs iss

  divide :: Int -> [[Char]] -> [[[Char]]]
  divide i iss = concatMap (S.chunksOf i) $ transpose $ map (S.chunksOf i) iss

  pattern :: [[Char]] -> [[[Char]]]
  pattern iss = let rs = rotate iss
                    fp = map flip' rs
                    fp' = map flip'' rs
                in rmdups $ rs ++ fp ++ fp'

  rmdups :: (Ord a) => [a] -> [a]
  rmdups = map head . group . sort

  rotate :: [[Char]] -> [[[Char]]]
  rotate iss = take 4 $ iterate (map reverse . transpose) iss

  flip' :: [[Char]] -> [[Char]]
  flip' = reverse

  flip'' :: [[Char]] -> [[Char]]
  flip'' = map reverse

  on :: [[Char]] -> Int
  on = length . filter (=='#') . concat

  right :: Either ParseError Rule -> Rule
  right e = case e of
    (Right r) -> r
    (Left err) -> error $ show err

  -- parse

  parseInput :: String -> Either ParseError Rule 
  parseInput = parse (choice [parseRule]) ""

  parseRule :: Parser Rule
  parseRule = do
    from <- sepBy (many1 $ choice [try $ char '.', char '#']) $ char '/'
    _ <- space 
    _ <- string "=>"
    _ <- space
    to <- sepBy (many1 $ choice [try $ char '.', char '#']) $ char '/'
    return $ Rule (pattern from) to
