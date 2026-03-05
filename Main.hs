module Main where

-- Running: runaskell Main.hs path_to_test_file

import Interpret
import System.Environment
import Control.Monad (when)

main :: IO ()
main = do
    (fileName:tl) <- getArgs
    contents <- readFile fileName
    let (stack, output) = interpret contents 
    putStr output
    when (null output || last output /= '\n') (putStrLn "")
    if null stack
        then return ()
        else do
            putStrLn "Stack not empty at end of execution:"
            print stack
