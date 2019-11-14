import Control.Monad (replicateM)
import Data.List (foldl')
import System.Random

data Flip
  = H
  | T
  deriving (Bounded, Enum, Show)

instance Random Flip where
  randomR (a, b) g =
    case randomR (fromEnum a, fromEnum b) g of
      (r, g') -> (toEnum r, g')
  random = randomR (H, T)

genSequence :: IO [Flip]
genSequence = go []
  where
    go stack =
      randomIO >>=
      (\flip ->
         case flip : stack of
           s@(H:T:T:H:_) -> return s
           s -> go s)

sim :: IO Int
sim = length <$> genSequence

mean :: (Fractional a) => [a] -> a
mean =
  (\(n, sum) -> sum / n) . (foldl' (\(n, sum) x -> (n + 1, sum + x)) (0, 0))

main = do
  n <- (mean . map fromIntegral) <$> replicateM 10000 sim
  putStrLn "Hello world!"
  print n
