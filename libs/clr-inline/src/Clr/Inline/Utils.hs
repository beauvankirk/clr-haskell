{-# OPTIONS_GHC -fno-warn-name-shadowing #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE ViewPatterns        #-}
module Clr.Inline.Utils where

import           Control.Monad
import           Control.Monad.Trans.Writer
import           Data.Char
import           Data.List.Extra
import           Data.Text                  (Text)
import           Language.Haskell.TH        as TH
import           Language.Haskell.TH.Syntax as TH
import           Text.Printf

mangleModule :: String -> Module -> String
mangleModule name (Module (PkgName pkg) (ModName m)) =
  printf "Inline%s__%s_%s" name (filter isAlphaNum pkg) (map (\case '.' -> '_' ; x -> x) m)


yield :: Monad m => t -> WriterT [t] m ()
yield x = tell [x]
yieldAll :: Monad m => w -> WriterT w m ()
yieldAll xx = tell xx

-- | Fix different systems silly line ending conventions
--   https://ghc.haskell.org/trac/ghc/ticket/11215
normaliseLineEndings :: String -> String
normaliseLineEndings []            = []
normaliseLineEndings ('\r':'\n':s) = '\n' : normaliseLineEndings s -- windows
normaliseLineEndings ('\r':s)      = '\n' : normaliseLineEndings s -- old OS X
normaliseLineEndings (  c :s)      =   c  : normaliseLineEndings s

initAndLast :: String -> Maybe (String, Char)
initAndLast = loopInitAndLast id where
  loopInitAndLast _   [ ]    = Nothing
  loopInitAndLast acc [x]    = Just (acc "", x)
  loopInitAndLast acc (x:xx) = loopInitAndLast (acc . (x:)) xx

-- | Parses expressions of the form "ty{e}" and returns (e,ty)
parseBody :: String -> Either String (String, TypeQ)
parseBody (trim -> e) = do
  let (typeString, exp') = span ('{' /=) e
  (exp,last) <- maybe (Left "Expected {") Right $ initAndLast (drop 1 exp')
  unless (last == '}') $ Left $ "Expected }: " ++ [last]
  typ <- maybe (Left $ "Cannot parse type " ++ typeString) Right $ parseType typeString
  return (exp,typ)

-- | Rudimentary parser for stringy Haskell types
parseType :: String -> Maybe TypeQ
parseType (map toLower . trim -> s) =
  case s of
    "string" -> Just [t|String|]
    "text"   -> Just [t|Text|]
    "int"    -> Just [t|Int|]
    "double" -> Just [t|Double|]
    "float"  -> Just [t|Float|]
    "char"   -> Just [t|Char|]
    "word"   -> Just [t|Word|]
    "bool"   -> Just [t|Bool|]
    -- TODO add a parser for reference types
    _        -> Nothing