module Advent.Day20 (day20a, day20b) where

  import Text.Parsec
  import Text.Parsec.String

  type X = Int
  type Y = Int
  type Z = Int

  data Position = Position X Y Z deriving (Show,Eq)
  data Velocity = Velocity X Y Z deriving (Show,Eq)
  data Acceleration = Acceleration X Y Z deriving (Show,Eq)

  data Particle = Particle Position Velocity Acceleration deriving (Show,Eq)

  day20a :: String -> [Particle]
  day20a s = map tick $ map (right . parseInput) $ lines s

  day20b :: String -> Int
  day20b s = 0

  tick :: Particle -> Particle
  tick (Particle (Position x y z) (Velocity x' y' z') (Acceleration x'' y'' z'')) =
    let v = (x'+x'')
        v' = (y'+y'')
        v'' = (z'+z'')
    in (Particle (Position (x+v) (y+v') (z+v'')) (Velocity v v' v'') (Acceleration x'' y'' z''))

  -- utility

  right :: Either ParseError Particle -> Particle
  right e = case e of
              (Left e) -> error $ show e
              (Right p) -> p

  -- parse

  parseInput :: String -> Either ParseError Particle
  parseInput = parse (choice [parseParticle]) ""

  parseParticle :: Parser Particle
  parseParticle = do
    _ <- string "p=<"
    (a:a':a'':[]) <- sepBy (many1 $ choice [try $ char '-', digit]) $ char ','
    _ <- string ">, v=<"
    (b:b':b'':[]) <- sepBy (many1 $ choice [try $ char '-', digit]) $ char ','
    _ <- string ">, a=<"
    (c:c':c'':[]) <- sepBy (many1 $ choice [try $ char '-', digit]) $ char ','
    _ <- char '>'
    return $ Particle
      (Position (read a) (read a') (read a''))
      (Velocity (read b) (read b') (read b''))
      (Acceleration (read c) (read c') (read c''))
