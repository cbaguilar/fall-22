f [] = []
f [x] = [x]
f (x : xs : ys)
    | x == xs   = f (xs:ys)
    | otherwise = x : f (xs:ys)

q:: Int -> Int
q x = 5*x

foo::(Int -> Int) -> ([Int] -> Int)
foo g [] = 0
foo g (x:xs) = g x + foo g xs

bar = foo (\x -> 2*x)

data List =
  Nil | 
  Node Int List
 deriving Show


del item Nil = Nil
del item (Node val next)
 | item == val = next
 | otherwise = (Node val (del item next))
