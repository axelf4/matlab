-- Nusummafaktorn
--
-- Värdet av 1 krona som faller ut varje n år, vid räntan r%.
nusf :: (Integral a, Fractional b) => a -> b -> b
nusf n r = (1 - (1 + r) ^^ (-n)) / r

-- Annuitetsfaktorn
annf n r = 1 / nusf n r

-- Exercises
yearly = [500, 500, 600, 800, 600 + 400]

giandyearly = (-1500) : yearly

nettonuvalue r =
  sum $ map (\(i, v) -> v / ((1 + r) ** i)) (zip [0 ..] giandyearly)

nettonuvalue' r = map (\(i, v) -> v / ((1 + r) ** i)) (zip [0 ..] giandyearly)

r = 20 / 100

slutvalue r =
  sum $ map (\(i, v) -> v * (1.0 + r) ** i) (zip (reverse [0 .. 4]) yearly)

slutvalueInv r = (-1500) * (1.0 + r) ** (5.0)

slutvalueTot r = (slutvalue r, slutvalueInv r)

partialSums :: Num a => [a] -> [a]
partialSums = scanl1 (+)
