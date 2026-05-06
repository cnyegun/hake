import System.Process ( callCommand )
import System.Directory ( doesFileExist, getModificationTime )
import Control.Monad ( filterM, when, unless )
import System.Exit ( exitFailure, exitSuccess )

build :: String -> IO ()
build action = do
    callCommand action
    putStrLn "Build complete."

checkFreshTarget :: FilePath -> [FilePath] -> IO Bool
checkFreshTarget target deps = do
    targetTime <- getModificationTime target
    depTimes <- traverse getModificationTime deps
    pure $ all (<= targetTime) depTimes

main :: IO ()
main = do
    let target = "test.out"
    let prerequisites = ["test.c"]
    let actionCmd = "gcc " ++ unwords prerequisites ++ " -o " ++ target

    missingFiles <- filterM (fmap not . doesFileExist) prerequisites

    unless (null missingFiles) $ do
        putStrLn ("Missing files: " ++ unwords missingFiles)
        exitFailure

    targetExist <- doesFileExist target
    
    when targetExist $ do
        targetIsFresh <- checkFreshTarget target prerequisites
        when targetIsFresh $ do
            putStrLn "Up to date."
            exitSuccess
    
    build actionCmd
