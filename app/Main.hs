import System.Process ( callCommand )
import System.Directory ( doesFileExist, getModificationTime )
import Control.Monad ( filterM, when, unless )
import System.Exit ( exitFailure, exitSuccess )
import qualified Data.Map.Strict as Map

type Target = FilePath
type Dep = FilePath
type Action = String

data Rule = Rule
  { target :: Target
  , deps   :: [Dep]
  , action :: Action
  }

type BuildSpec = Map.Map Target Rule

checkFreshTarget :: Target -> [Dep] -> IO Bool
checkFreshTarget target deps = do
  targetTime <- getModificationTime target
  depTimes <- traverse getModificationTime deps
  pure $ all (<= targetTime) depTimes

ruleOut :: Rule 
ruleOut = Rule
          { target = "test.out"
          , deps = ["test.o"]
          , action = "gcc test.o -o test.out"
          }

ruleObj :: Rule
ruleObj = Rule
          { target = "test.o"
          , deps = ["test.c"]
          , action = "gcc -c test.c -o test.o"
          }

spec :: BuildSpec
spec = Map.fromList
      [ ("test.out", ruleOut)
      , ("test.o", ruleObj)
      ]

getRule :: Target -> BuildSpec -> Maybe Rule
getRule = Map.lookup

build :: Target -> BuildSpec -> IO ()
build t sp = do
  case getRule t sp of 
    Just rule -> do 
                mapM_ (`build` sp) (deps rule)
                targetExists <- doesFileExist t
                isFresh <- if targetExists then checkFreshTarget t (deps rule)
                            else pure False

                unless isFresh $ do
                      callCommand (action rule)

    Nothing   -> do 
                fileExists <- doesFileExist t
                unless fileExists $ do
                  putStrLn ("No rule found for " ++ t ++ ".")
                  exitFailure

main :: IO ()
main = do
  result <- build "test.out" spec
  exitSuccess