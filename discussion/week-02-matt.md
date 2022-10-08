---
title: Week 2 Discussion (Matt)
week: 2
lecture_date: 2022-10-07
author: Matt Wang
layout: lecture
parent: Misc Content
---

{: .note }
Matt here! This note exists to supplement the material from the Week 2 discussion, where Matt ran out of time to go through all the material. It's not strictly necessary to review (since we did finish ADTs), but is helpful for studying, etc.!

[**Link to slides**](https://docs.google.com/presentation/d/1-AqpKlZ-w51Rh1e5eO-CqIkm_-YtmxeuAgPi9IcD8zc)

## Table of Contents
{: .no_toc }

{:toc}
- dummy item

## Answering Open Questions

### Restricting Binding Scope

Someone in discussion asked how we'd restrict the binding scope of a variable to just one line. This is a great question!

The motivating thought was: in this problem, `other_occurrences` is bound to *all* of the function body of `count_occurences`.

```hs
--- other stuff...
count_occurrences [] _ = 1
count_occurrences _ [] = 0
count_occurrences (x:xs) (y:ys)
  | x == y = count_occurrences xs ys + other_occurrences
  | otherwise = other_occurrences
  where other_occurrences = count_occurrences (x:xs) ys
```

How would we restrict a `where` clause to bind *just* to one line, like one of the guards?

There are two tl;dr answers:

1. Syntactically, `where` isn't an expression, so you can't put it everywhere!
2. We can use `let ... in` to bind locally, since it's an expression; simply wrap your line with the bind.

Here's an equivalent (if ugly) function that only binds within a guard:

```hs
--- other stuff...
count_occurrences [] _ = 1
count_occurrences _ [] = 0
count_occurrences (x:xs) (y:ys)
  | x == y = let other_occurrences = count_occurrences (x:xs) ys in count_occurrences xs ys + other_occurrences
  -- in theory, if we added `| x > y` or another condition here, it wouldn't have `other_occurrences`!
  | otherwise = let other_occurrences = count_occurrences (x:xs) ys in other_occurrences
```

I was hesitant to answer this question live since I wasn't sure what Haskell's shadowing semantics are (see below). But, hopefully this now clearly answers the question!


#### On Shadowing and Scope

{: .note }
This is more context - it's not necessary to understand the question at hand!

For context, [variable shadowing](https://en.wikipedia.org/wiki/Variable_shadowing) occurs when you re-use a variable name in a tighter scope.

In Python and JavaScript, shadowing occurs naturally with nested functions and blocks respectively. Let's look at some examples (from the Wikipedia page).

Python:

```py
x = 0
def outer():
  x = 1
  def inner():
    x = 2
    print("inner:", x)
  inner()
  print("outer:", x)
outer()
print("global:", x)
# prints
#   inner: 2
#   outer: 1
#   global: 0
```

JS (our language of the week!):

```js
function myFunc() {
  let my_var = 'test';
  if (true) {
    let my_var = 'new test';
    console.log(my_var);
  }
  console.log(my_var);
}
myFunc();
// prints
//   new test
//   test
```

Haskell also supports shadowing!

```hs
-- this compiles!
parent x = map (\x -> 2*x) x

-- breaking it down
parent x =
  map           -- here, x is the parent input
    (\x -> 2*x) -- here, and only here, x is the name of the lambda input
    x           -- here, x goes back to being the parent input value
```

What helped me here is understanding the syntactic sugar around function parameters, and then having a mental rule of "every time a lambda is defined, you can shadow / re-bind with no problems":

```hs
parent x = map (\x -> 2*x) x
-- is identical to
parent = (\x -> map (\x -> 2*x) x)
```

Whether or not a language supports shadowing could change the answer to the overall question. Now you know!

### Space Complexity of Reversing a List

{: .note }
I had to think about this one for a bit - I'm not actually sure *if* there's a 100% correct answer.

tl;dr: **in neither solution are we ever allocating a new persistent item, so both solutions are probably constant in space**.

I was a little rusty on space complexity. Someone asked, what is the space complexity of these two list-reversers for a list of size `n`?

Reasoning about space and laziness in Haskell is [notoriously hard](https://ro-che.info/articles/2012-04-08-space-usage-reasoning), so let's buckle up and make some assumptions.

#### Naive Solution (hard)

The `O(n^2)` time complexity solution:

```hs
reverse' :: [a] -> [a]
reverse' []     = []
reverse' (x:xs) = reverse' xs ++ [x]
```

The only case we really need to look at is the recursive one. Assuming the singly-linked-list model, note that:

- splitting `x:xs` is constant space - nothing is allocated
- `reverse' xs` has no allocations; `xs` already exists, it's the tail of the input

But, I'll note that `++ [x]` is the tricky one! Let's take a quick example to illustrate why it behaves strangely.

```hs
-- each line is one step of the recursive algorithm
reverse' [1,2,3]
  = reverse' (1: [2,3])
  = reverse' [2,3] ++ [1]
  = reverse' (2: [3]) ++ [1]
  = reverse' [3] ++ [2] ++ [1]
  = reverse' (3: []) ++ [2] ++ [1]
  = reverse' [] ++ [3] ++ [2] ++ [1]
  = [] ++ [3] ++ [2] ++ [1]
  = [3] ++ [2] ++ [1]
  = [3,2] ++ [1]
  = [3,2,1]
```

Now, there's a tension:

- on one hand, we have a line like `[3] ++ [2] ++ [1]`. This should be an immediate giveaway that we have `O(n)` space complexity, since we're allocating a new list for each item in the list, and they all could exist at once.
- on the other hand, Haskell is lazy. We may only initialize each list as we actually apply the append, and so we'd only ever be floating one additional list - `O(1)` space complexity.

The GHC implementation of Haskell has something called a "[strictness analyzer](https://wiki.haskell.org/Performance/Strictness)" that chooses when to be strict and when to be lazy. I am not an expert in how it works; however, my assumption is that this case is trivial enough that it can be optimized away properly (i.e., unboxing the singleton list for appending, and unboxing `Integer`). So, my guess is that it's `O(1)`, but I'm not actually sure!

#### Linear Solution (easy)

Now, let's look at the `O(n)` time complexity solution:

```hs
reverse l =  rev l []
  where
    rev []     a = a
    rev (x:xs) a = rev xs (x:a)
```

Again, we really only care about the recursive case. Assuming the singly-linked-list model, note that:

- splitting `x:xs` is still constant space - nothing is allocated
- `rev xs` is still constant space
- `(x:a)` also **has no allocations**: we're simply shuffling a pointer (since `a` is already initialized)
  - even if it was an allocation, because `rev` is tail-recursive, the stack gets dropped on the recursive step, so it would get cleaned up almost immediately

Similar to the other solution, there is no allocation  - so the space complexity is **also `O(1)`**.

## Week 2 Problems

### Concept: `foldl` and `foldr`

Instead of writing a long essay, I'll refer you to the [Learn You A Haskell page on fold](http://learnyouahaskell.com/higher-order-functions#folds)!

### `map` + `filter` problem

This problem checks your understanding of `map`, `filter`, and lambdas. It warms you up for the `map` and `filter` questions in HW2!

**Test time estimate**: ~ 2 minutes for you to implement it.

#### Problem Setup

Write a function with the following type signature that returns *only* the squares of the even numbers in the input array.

```hs
mf :: [Integer] -> [Integer]
```

#### Trying it Yourself

Try this one yourself first :)

Questions to ponder:

- please use `map` and `filter` - I promise it makes your life easier!
- which one should come first? does it matter?

#### The Answer:

```hs
mf :: [Integer] -> [Integer]
mf l = map
  (\x -> x*x)
  (filter (\x -> (mod x 2) == 0) l)
```

Here, we:

1. first, filter the list to only get even numbers
2. then, square each element in the list

I also want to highlight that we can use `x` as the variable name in both lambdas - this is because they're scoped to *just* the lambda, and not the entire function!

Interestingly, swapping the order also works - this is because the square of odd numbers is odd, while the square of even numbers is even. It is slightly less efficient.

```hs
mf :: [Integer] -> [Integer]
mf l = filter
  (\x -> (mod x 2) == 0)
  (map (\x -> x*x) l)
```

### tree sum

This next problem checks your understanding on basic ADTs. It also warms you up for the HW 2 questions on trees and ADTs!

**Test time estimate**: ~ 5 minutes for you to implement it.

#### Problem Setup

Assume you have the following ADT representing a tree of integers:

```hs
data Tree = Empty | Node Integer [Tree]
```

We want to define a function, `tsum`, that returns the sum of the values of **all nodes** in the tree.

First: let's define the type signature!

```hs
data Tree = Empty | Node Integer [Tree]

tsum :: Tree -> Integer
```

An example of the behavior we're looking for:

```hs
tsum (Node 3 [
  (Node 2 [Node 7 []]),
  (Node 5 [Node 4 []])
])
-- should return: 3 + 2 + 7 + 5 + 4 = 21
```

#### Trying it Yourself

I suggest you try making your own solution first! Some things to think about:

- how many children can a node have?
- how do we represent an empty tree? what about a tree with just one node?
- what's the base case(s)
- can we implement a linear (in children) recursive step?

#### The Answer

First, let's define the trivial base case, which also represents an empty tree - the sum should (vacuously) be zero!

```hs
data Tree = Empty | Node Integer [Tree]

tsum :: Tree -> Integer
tsum Empty = 0
```

Note that the above is **not** a leaf node, since there's *no value*.

Now, let's consider an alternate base case - a tree with just one node in it. More broadly, this is **any leaf node**. Here, the sum is the value of the node.

```hs
data Tree = Empty | Node Integer [Tree]

tsum :: Tree -> Integer
tsum Empty = 0
tsum (Node val []) = val
```

I argue that this resolves our two base cases. Now, all we need to do is handle our recursive step. Using what we've talked about earlier today - `map` comes in helpful!

```hs
data Tree = Empty | Node Integer [Tree]

tsum :: Tree -> Integer
tsum Empty = 0
tsum (Node val []) = val
tsum (Node val lst) = val + sum (map tsum lst)
```

Node that this gives us our desired functionality:

```console
ghci> data Tree = Empty | Node Integer [Tree]
ghci> :{
ghci| tsum :: Tree -> Integer
ghci| tsum Empty = 0
ghci| tsum (Node val []) = val
ghci| tsum (Node val lst) = val + sum (map tsum lst)
ghci| :}
ghci> :{
ghci| tsum (Node 3 [
ghci|   (Node 2 [Node 7 []]),
ghci|   (Node 5 [Node 4 []])
ghci| ])
ghci| :}
21
```

#### Extensions

1. Let's say we now *only* want to sum the leaf nodes. I argue that we only need to change a handful of characters in our solution. How would we do that?
2. Pedagogically, the line `tsum (Node val []) = val` is helpful since it's a good base case to start with. Is it strictly necessary? Why or why not?
