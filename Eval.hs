module Eval where
-- This file contains definitions for functions and operators

import Val
import Data.Char (chr)

-- main evaluation function for operators and 
-- built-in FORTH functions with no output
-- takes a string and a stack and returns the stack
-- resulting from evaluation of the function
eval :: String -> [Val] -> [Val]
-- Multiplication
-- if arguments are integers, keep result as integer
eval "*" (Integer x: Integer y:tl) = Integer (x*y) : tl
-- if any argument is float, make result a float
eval "*" (x:y:tl) = (Real $ toFloat x * toFloat y) : tl 
-- any remaining cases are stacks too short
eval "*" _ = error("Stack underflow")

-- Addition
eval "+" (Integer x: Integer y:tl) = Integer (x+y) : tl
eval "+" (x:y:tl) = (Real $ toFloat x + toFloat y) : tl
eval "+" _ = error("Stack underflow")

-- Subtraction (second minus top)
eval "-" (Integer x: Integer y:tl) = Integer (y-x) : tl
eval "-" (x:y:tl) = (Real $ toFloat y - toFloat x) : tl
eval "-" _ = error("Stack underflow")

-- Division (second divided by top)
eval "/" (Integer 0:_:_) = error "Division by zero"
eval "/" (Real 0:_:_) = error "Division by zero"
eval "/" (Integer x: Integer y:tl) = Integer (div y x) : tl
eval "/" (x:y:tl) = (Real $ toFloat y / toFloat x) : tl
eval "/" _ = error("Stack underflow")

-- Power (second raised to top)
eval "^" (Integer x: Integer y:tl)
  | x >= 0 = Integer (y ^ x) : tl
  | otherwise = Real ((fromIntegral y) ** (fromIntegral x)) : tl
eval "^" (x:y:tl) = Real (toFloat y ** toFloat x) : tl
eval "^" _ = error("Stack underflow")

-- Duplicate the element at the top of the stack
eval "DUP" (x:tl) = (x:x:tl)
eval "DUP" [] = error("Stack underflow")

-- Convert top of stack to string
eval "STR" (x:tl) = Str (toText x) : tl
eval "STR" [] = error("Stack underflow")

-- Concatenate two strings
eval "CONCAT2" (Str x:Str y:tl) = Str (y ++ x) : tl
eval "CONCAT2" (_:_:_) = error "CONCAT2 expects strings"
eval "CONCAT2" _ = error("Stack underflow")

-- Concatenate three strings
eval "CONCAT3" (Str x:Str y:Str z:tl) = Str (z ++ y ++ x) : tl
eval "CONCAT3" (_:_:_:_) = error "CONCAT3 expects strings"
eval "CONCAT3" _ = error("Stack underflow")

-- this must be the last rule
-- it assumes that no match is made and preserves the string as argument
eval s l = Id s : l 


-- variant of eval with output
-- state is a stack and string pair
evalOut :: String -> ([Val], String) -> ([Val], String) 
-- print element at the top of the stack
evalOut "." (Id x:tl, out) = (tl, out ++ x)
evalOut "." (Integer i:tl, out) = (tl, out ++ (show i))
evalOut "." (Real x:tl, out) = (tl, out ++ (show x))
evalOut "." (Str x:tl, out) = (tl, out ++ x)
evalOut "." ([], _) = error "Stack underflow"

-- Emit ascii/unicode character from codepoint
evalOut "EMIT" (Integer i:tl, out)
  | i < 0 || i > 127 = error "Invalid ASCII code"
  | otherwise = (tl, out ++ [chr i])
evalOut "EMIT" (Real x:tl, out) = evalOut "EMIT" (Integer (truncate x):tl, out)
evalOut "EMIT" (_:_, _) = error "EMIT expects a number"
evalOut "EMIT" ([], _) = error "Stack underflow"

-- Newline
evalOut "CR" (stack, out) = (stack, out ++ "\n")

-- this has to be the last case
-- if no special case, ask eval to deal with it and propagate output
evalOut op (stack, out) = (eval op stack, out)
