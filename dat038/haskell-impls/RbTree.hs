module RbTree (Color(R, B), Node(E, Node), member, insert, checkTree) where

data Color = R | B
  deriving (Show, Eq)

data Node a = E | Node Color (Node a) a (Node a)
  deriving Show

{-
Returns whether x is a member of the tree rooted at the given node.
-}
member :: (Ord a) => a -> Node a -> Bool
member x E = False
member x (Node _ l y r)
  | x < y = member x l
  | x == y = True
  | otherwise = member x r

height :: Node a -> Int
height E = -1
-- height (Node B E _ E) = 0 -- The height of a leaf is zero
height (Node color l _ r) = (if color == B then 1 else 0)
  + max (height l) (height r)

checkRedColors :: Node a -> Node a
checkRedColors node =
  case node of
    E -> E
    Node B (Node R x lk y) k r
      -> Node B (Node R (checkRedColors x) lk (checkRedColors y)) k (checkRedColors r)
    Node B l k r -> Node B (checkRedColors l) k (checkRedColors r)
    _ -> error "Red node that is not left child of a black node!"

checkHeight :: Node a -> Node a
checkHeight node =
  case node of
    E -> E
    Node _ l _ r | height l == height r -> node
    _ -> error "Height of tree is unbalanced"

checkBstOrdering :: (Ord a) => Node a -> Node a
checkBstOrdering node =
  let go _ _ E = E
      go min max (Node color l k r)
        | (maybe True (<k) min) && (maybe True (k<) max)
        = Node color (go min (Just k) l) k (go (Just k) max r)
        | otherwise = error "Bad ordering"
  in go Nothing Nothing node

checkTree :: (Ord a) => Node a -> Node a
checkTree = checkHeight . checkRedColors . checkBstOrdering

insert :: (Ord a) => a -> Node a -> Node a
insert k E = Node B E k E
insert new root =
  let
    -- Newly inserted node is black so as to not affect the height
    go E = Node R E new E

    go node@(Node color l k r) = 
      -- Restore the invariant
      maybeSplit $ maybeSkew 
          -- Normal BST insertion
          (case compare new k of LT -> Node color (go l) k r
                                 EQ -> node
                                 GT -> Node color l k (go r))
      where
        maybeSkew node = case node of
          Node B a x (Node R b y c) -> Node B (Node R a x b) y c
          _ -> node
        maybeSplit node = case node of
          Node B (Node R (Node R a x b) y c) z d
            -> (Node R (Node B a x b) y (Node B c z d))
          _ -> node
    makeBlack (Node _ l k r) = Node B l k r
  in makeBlack $ go root
