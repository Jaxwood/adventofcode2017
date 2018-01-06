module Advent.Day18 (day18a, day18b) where

  import qualified Data.Map.Strict as M
  import Data.Char
  import Data.List
  import Data.Either (rights)
  import Text.Parsec
  import Text.Parsec.String

  data Value = Number Int | Register Char deriving (Show,Eq)
  data Instruction =
      Set Char Value
    | Add Char Value
    | Mul Char Value
    | Mod Char Value
    | Snd Char
    | Rcv Char
    | Jgz Char Value deriving (Show,Eq)

  day18a :: String -> Int
  day18a s = let is = rights $ map parseInput $ lines s
             in runInstruction M.empty is is

  day18b :: String -> Int
  day18b s = 0

  runInstruction :: M.Map Char Int -> [Instruction] -> [Instruction] -> Int
  runInstruction m s [] = 0
  runInstruction m s (s'@(Set c i):is) = runInstruction (M.insert c (lookup'' m i) m) s is
  runInstruction m s (s'@(Add c i):is) = runInstruction (update' m (+) c (lookup'' m i)) s is
  runInstruction m s (s'@(Mul c i):is) = runInstruction (update' m (*) c (lookup'' m i)) s is
  runInstruction m s (s'@(Mod c i):is) = runInstruction (update' m mod c (lookup'' m i)) s is
  runInstruction m s (s'@(Snd c):is) = runInstruction (M.insert '_' (lookup' m c) m) s is
  runInstruction m s (s'@(Rcv c):is) = if lookup' m c == 0 then runInstruction m s is else lookup' m '_'
  runInstruction m s (s'@(Jgz c i):is) = if lookup' m c > 0 then runJgz m s (lookup'' m i) s' is else runInstruction m s is

  runJgz :: M.Map Char Int -> [Instruction] -> Int -> Instruction -> [Instruction] -> Int
  runJgz m s v i is = let idx = findIndex' i s
                          s' = drop (idx + v) s
                      in runInstruction m s s'

  update' :: M.Map Char Int -> (Int -> Int -> Int) -> Char -> Int -> M.Map Char Int
  update' m fn c i = M.insert c (fn (lookup' m c) i) m

  lookup' :: M.Map Char Int -> Char -> Int
  lookup' m c = case M.lookup c m of
    (Just i) -> i
    Nothing -> 0

  lookup'' :: M.Map Char Int -> Value -> Int
  lookup'' m (Number i) = i
  lookup'' m (Register c) = case M.lookup c m of
                          (Just i) -> i
                          Nothing -> 0

  findIndex' :: Instruction -> [Instruction] -> Int
  findIndex' i is = case findIndex (==i) is of
    Nothing -> error "not found"
    (Just idx) -> idx

  parseInput :: String -> Either ParseError Instruction
  parseInput = parse (choice [try parseSet, try parseAdd, try parseMul, try parseMod, try parseJgz, try parseSnd, parseRcv]) ""

  parseSet :: Parser Instruction
  parseSet = do
    _ <- string "set"
    _ <- space
    id <- letter
    _ <- space
    val <- many1 $ choice [try $ char '-', try digit, letter]
    return $ Set id (if any isDigit val then Number $ read val else Register $ head val)

  parseAdd :: Parser Instruction
  parseAdd = do
    _ <- string "add"
    _ <- space
    id <- letter
    _ <- space
    val <- many1 $ choice [try $ char '-', try digit, letter]
    return $ Add id (if any isDigit val then Number $ read val else Register $ head val)

  parseMul :: Parser Instruction
  parseMul = do
    _ <- string "mul"
    _ <- space
    id <- letter
    _ <- space
    val <- many1 $ choice [try $ char '-', try digit, letter]
    return $ Mul id (if any isDigit val then Number $ read val else Register $ head val)

  parseMod :: Parser Instruction
  parseMod = do
    _ <- string "mod"
    _ <- space
    id <- letter
    _ <- space
    val <- many1 $ choice [try $ char '-', try digit, letter]
    return $ Mod id (if any isDigit val then Number $ read val else Register $ head val)

  parseJgz :: Parser Instruction
  parseJgz = do
    _ <- string "jgz"
    _ <- space
    id <- letter
    _ <- space
    val <- many1 $ choice [try $ char '-', try digit, letter]
    return $ Jgz id (if any isDigit val then Number $ read val else Register $ head val)

  parseSnd :: Parser Instruction
  parseSnd = do
    _ <- string "snd"
    _ <- space
    id <- letter
    return $ Snd id

  parseRcv :: Parser Instruction
  parseRcv = do
    _ <- string "rcv"
    _ <- space
    id <- letter
    return $ Rcv id