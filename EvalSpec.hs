-- HSpec tests for Eval.hs
-- Execute: runhaskell EvalSpec.hs

import Test.Hspec
import Control.Exception (evaluate)
import Val
import Eval

main :: IO ()
main = hspec $ do
  describe "eval arithmetic" $ do
    it "multiplies integers and reals" $ do
      eval "*" [Integer 2, Integer 3] `shouldBe` [Integer 6]
      eval "*" [Integer 2, Real 3.0] `shouldBe` [Real 6.0]

    it "adds values" $ do
      eval "+" [Integer 2, Integer 3] `shouldBe` [Integer 5]
      eval "+" [Integer 2, Real 3.0] `shouldBe` [Real 5.0]

    it "subtracts in stack order" $ do
      eval "-" [Integer 3, Integer 10] `shouldBe` [Integer 7]
      eval "-" [Real 2.5, Integer 10] `shouldBe` [Real 7.5]

    it "divides in stack order" $ do
      eval "/" [Integer 2, Integer 10] `shouldBe` [Integer 5]
      eval "/" [Integer 2, Real 9.0] `shouldBe` [Real 4.5]

    it "powers in stack order" $ do
      eval "^" [Integer 3, Integer 2] `shouldBe` [Integer 8]
      eval "^" [Real 0.5, Integer 9] `shouldBe` [Real 3.0]

    it "detects arithmetic errors" $ do
      evaluate (eval "*" []) `shouldThrow` errorCall "Stack underflow"
      evaluate (eval "/" [Integer 0, Integer 2]) `shouldThrow` errorCall "Division by zero"

  describe "eval stack/string helpers" $ do
    it "duplicates values" $ do
      eval "DUP" [Integer 2] `shouldBe` [Integer 2, Integer 2]
      eval "DUP" [Str "x"] `shouldBe` [Str "x", Str "x"]

    it "converts values to strings with STR" $ do
      eval "STR" [Integer 12] `shouldBe` [Str "12"]
      eval "STR" [Real 2.5] `shouldBe` [Str "2.5"]
      eval "STR" [Id "abc"] `shouldBe` [Str "abc"]

    it "concatenates strings with CONCAT2 and CONCAT3" $ do
      eval "CONCAT2" [Str "cd", Str "ab"] `shouldBe` [Str "abcd"]
      eval "CONCAT3" [Str "c", Str "b", Str "a"] `shouldBe` [Str "abc"]

    it "errors for bad concat arguments" $ do
      evaluate (eval "CONCAT2" [Integer 1, Str "a"]) `shouldThrow` errorCall "CONCAT2 expects strings"
      evaluate (eval "CONCAT3" [Str "a", Integer 1, Str "b"]) `shouldThrow` errorCall "CONCAT3 expects strings"

  describe "evalOut" $ do
    it "prints with ." $ do
      evalOut "." ([Id "x"], "") `shouldBe` ([], "x")
      evalOut "." ([Integer 2], "") `shouldBe` ([], "2")
      evalOut "." ([Real 2.2], "") `shouldBe` ([], "2.2")
      evalOut "." ([Str "abc"], "") `shouldBe` ([], "abc")

    it "handles EMIT and CR" $ do
      evalOut "EMIT" ([Integer 65], "") `shouldBe` ([], "A")
      evalOut "EMIT" ([Real 66.9], "") `shouldBe` ([], "B")
      evalOut "CR" ([Integer 1], "x") `shouldBe` ([Integer 1], "x\n")

    it "emits error when EMIT gets wrong input" $ do
      evaluate (evalOut "EMIT" ([Id "x"], "")) `shouldThrow` errorCall "EMIT expects a number"

    it "eval pass-through" $ do
      evalOut "*" ([Real 2.0, Integer 2], "blah") `shouldBe` ([Real 4.0], "blah")
