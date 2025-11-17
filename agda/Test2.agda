module Test2 where

open import Test3 as Test

-- Testing the inter-file goto facility.

test : ℕ
test = 12 + 34 + 56

-- Testing qualified names.

Eq = Test.Equiv {Test.ℕ}