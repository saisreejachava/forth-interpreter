module Interpret where
-- this file contains the FORTH interpreter

import Val
import Eval

-- inner function for foldl
-- Takes the current stack and an input and 
-- computes the next stack
evalF :: ([Val], String) -> Val -> ([Val], String)
evalF s (Id op) = evalOut op s
-- cannot run, put on the stack and preserve output
evalF (s, out) x = (x:s,out)

type Dict = [(String, [String])]

lookupDef :: String -> Dict -> Maybe [String]
lookupDef _ [] = Nothing
lookupDef key ((k, body):tl)
    | key == k = Just body
    | otherwise = lookupDef key tl

putDef :: String -> [String] -> Dict -> Dict
putDef key body [] = [(key, body)]
putDef key body ((k, oldBody):tl)
    | key == k = (k, body) : tl
    | otherwise = (k, oldBody) : putDef key body tl

parseDef :: [String] -> (String, [String], [String])
parseDef [] = error "Definition needs a name"
parseDef (name:tl) = go name [] tl
    where
        go _ _ [] = error "Missing ';' in definition"
        go n acc (";":rest) = (n, reverse acc, rest)
        go n acc (x:rest) = go n (x:acc) rest

runTokens :: Dict -> ([Val], String) -> [String] -> (Dict, ([Val], String))
runTokens dict state [] = (dict, state)
runTokens dict state (":":tl) =
    let (name, body, rest) = parseDef tl
        nextDict = putDef name body dict
    in runTokens nextDict state rest
runTokens dict state (tok:tl) =
    case lookupDef tok dict of
        Just body ->
            let (nextDict, nextState) = runTokens dict state body
            in runTokens nextDict nextState tl
        Nothing ->
            runTokens dict (evalF state (strToVal tok)) tl

-- function to interpret a string into a stack and 
-- an output string
interpret :: String -> ([Val], String)
interpret text =
    let (_, result) = runTokens [] ([], "") (words text)
    in result
