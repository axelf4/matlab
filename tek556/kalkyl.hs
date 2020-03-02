-- Nusummafaktorn
--
-- Värdet av 1 krona som faller ut varje n år, vid räntan r%.
nusf :: (Integral a, Fractional b) => a -> b -> b
nusf n r = (1 - (1 + r) ^^ (-n)) / r

-- Annuitetsfaktorn
annf n r = 1 / nusf n r
