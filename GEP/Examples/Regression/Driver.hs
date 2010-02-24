-- |
--  Haskell gene expression programming, regression example
-- 
--  Author: mjsottile\@computer.org
--
module Main (
    main
) where

import GEP.Params
import GEP.GenericDriver
import GEP.Util.ConfigurationReader
import GEP.Examples.Regression.ArithmeticIndividual
import GEP.Examples.Regression.FitnessInput
import GEP.Examples.Regression.MaximaClient
import System.Environment (getArgs)
import System.Exit

--
-- sanity check arguments to see if we have enough
--
validateArgs :: [String] -> IO ()
validateArgs s = do 
  if (length s < 2)  then do putStrLn "Must specify config file and fitness test data file names."
                             exitFailure
                     else do return ()

--
-- currently this is here to shut up whining tools who just really 
-- need a main nearby to make them feel good.  that means you haddock.
-- you're not even a linker - get over the lack of main already...
--
main :: IO ()
main = do
  -- read in parameters from specified file
  args <- getArgs

  -- sanity check
  validateArgs args

  -- give args nice names
  configFile <- return $ head args
  fitnessFile <- return $ head (tail args)

  -- if optional third argument is present, assume it is dot file
  dotfile <- if ((length args) == 3) then return $ Just $head (tail (tail args))
                                     else return $ Nothing
  
  -- read parameters
  (rs,gnome,params) <- readParameters configFile
  
  -- read fitness test data
  (testDict, ys) <- readFitnessInput fitnessFile

  -- call generic driver
  (best,pop) <- gepDriver params rs gnome testDict ys fitness_evaluate_absolute express_individual

  -- Express best individual
  bestExpressed <- return $ express_individual (head pop) gnome
  
  -- Flatten best individual via infix walk
  bestString <- return $ infixWalker bestExpressed

  -- report status
  putStrLn "-------------------------------------------------"
  putStrLn $ "DONE  : "++(show best)
  putStrLn $ "INFIX : "++bestString 

  putStrLn $ "MAXIMA OUTPUT :"
  -- send flattened individual to maxima for pretty printing
  maxOut <- maximaExpand bestString "qubu.net" 12777

  -- print lines that come back
  mapM putStrLn maxOut

  -- dump to dot file if one was specified
  dumpDotFile dotfile bestExpressed