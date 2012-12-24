-- | This module contains code related to fitness evaluation.  The
--   main purpose of the code is to both evaluate fitnesses of individuals
--   and to sort individuals by fitness.  These are intended to all be
--   higher order functions that assume nothing about the purpose of the
--   individuals or the types of inputs being used for fitness testing.
--   The only assumption made currently is that the outputs for test cases
--   are floating point numbers.  That likely should change for general
--   purpose usage.
--
--   mjsottile\@computer.org
--
module GEP.Fitness
    ( FitnessFunction
    , TestCase
    , TestDict
    , TestOuts
    , fitness_tester
    , fitness_filter
    , sortByFitness
    ) where

import GEP.Types
import Data.Function
import Data.List (sortBy)

-- | Fitness function type
type FitnessFunction a b = a -> TestCase b -> Double -> Double -> Double

-- | A test case maps a list of terminals to float values
type TestCase a = SymTable a

-- | A test dictionary is a set of test cases
type TestDict a = [TestCase a]

-- | The set of outputs expected for each entry in the test dictionary
type TestOuts = [Double]

--
-- Sort a list of pairs by first element of each pair.
--
pairSort :: (Ord a) => [(a,b)] -> [(a,b)]
pairSort = sortBy (compare `on` fst)

--
-- |
--  Fitness evaluator for generic individuals.  This needs to go away
--  and use a more general approach like evaluateFitness above.
-- 
fitness_tester :: a                   -- ^ Expressed individual
               -> FitnessFunction a b -- ^ Fitness function
               -> TestDict b          -- ^ List of symbol tables for test cases
               -> TestOuts            -- ^ List of expected outputs for test cases
               -> Double              -- ^ Range of selection.  M in original
                                      --   GEP paper equations for fitness.
               -> Double              -- ^ Fitness value for given individual
fitness_tester who ffun inputDict outputs m = 
  sum tests
  where 
    tests = map (\(x,y) -> ffun who x y m) 
                (zip inputDict outputs)

-- |
--  Given a list of fitness values and a corresponding list of individuals,
--  return a list of tuples pairing the fitness value with the individuals for
--  only those individuals that have a valid fitness value.  This means those
--  that are +/- infinity or NaN are removed.
--
fitness_filter :: [Double]               -- ^ Fitness values
               -> [Chromosome]           -- ^ Individuals
               -> [(Double, Chromosome)] -- ^ Paired fitness/individuals after 
                                         --   filtering
fitness_filter fitnesses pop =
    filter (\(i,_) -> not ((isNaN i) || (isInfinite i))) 
           (zip fitnesses pop)

-- |
--  Sort a set of individuals with fitness values by their fitness
--
sortByFitness :: [(Double, Chromosome)] -> [(Double, Chromosome)]
sortByFitness xs = reverse (pairSort xs)
