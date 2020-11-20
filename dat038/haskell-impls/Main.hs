module Main where

import RbTree

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  let tree =
        (insert 7) $ (insert 5) $ (insert 3) E
  putStrLn $ show tree
  putStrLn $ show $ checkTree tree
