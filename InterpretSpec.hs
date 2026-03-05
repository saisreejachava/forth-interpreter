-- HSpec tests for Interpret.hs
-- Execute: runhaskell InterpretSpec.hs

import Test.Hspec
import Val
import Interpret

main :: IO ()
main = hspec $ do
  describe "evalF" $ do
    it "preserves output for pushed values" $ do
      evalF ([], "x") (Real 3.0) `shouldBe` ([Real 3.0], "x")

    it "passes through operators" $ do
      evalF ([Real 2.2, Integer 2], "") (Id "*") `shouldBe` ([Real 4.4], "")

  describe "interpret base behavior" $ do
    it "evaluates RPN expressions" $ do
      interpret "2 3 + ." `shouldBe` ([], "5")
      interpret "2 6 * ." `shouldBe` ([], "12")

    it "supports STR/CONCAT output" $ do
      interpret "12 STR 34 STR CONCAT2 ." `shouldBe` ([], "1234")

    it "can leave items on the stack (covered by Main output handling)" $ do
      interpret "2 3 +" `shouldBe` ([Integer 5], "")

    it "supports backslash comments to end of line" $ do
      interpret "5 6 + \\ add numbers\n." `shouldBe` ([], "11")

    it "supports parenthesized comments" $ do
      interpret "( compute sum ) 5 6 + ." `shouldBe` ([], "11")

  describe "interpret bonus user-defined words" $ do
    it "defines and uses a function" $ do
      interpret ": SQR DUP * ; 7 SQR ." `shouldBe` ([], "49")

    it "supports multiple definitions and composition" $ do
      interpret ": SQR DUP * ; : CUBE DUP SQR * ; 2 CUBE ." `shouldBe` ([], "8")
