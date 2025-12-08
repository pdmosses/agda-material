module Test.Plain.Test2 where

open import Test.Plain.Test

-- Testing the inter-file goto facility.

test : ℕ
test = 12 + 34 + 56

-- Testing qualified names.

Eq = Test.Plain.Test.Equiv {Test.Plain.Test.ℕ}