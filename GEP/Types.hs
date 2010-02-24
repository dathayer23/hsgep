{-|
   Types for GEP development.

   Author: mjsottile\@computer.org
-}

module GEP.Types (
    Symbol,
    Gene,
    SymTable,
    Genome(..),
    Chromosome,
    Individual,
    tailLength,
    geneLength,
    allsymbols,
    chromToGenes,
    genesToChrom,
    isNonterminal
) where

-- | A symbol in a chromosome
type Symbol     = Char

-- | A gene in a chromosome is a list of symbols
type Gene       = [Symbol]

-- | A chromosome is a list of symbols.  We avoided using a list of genes to
--   maintain the view of a chromosome as nothing more than a flattened,
--   linear sequence of genes.
type Chromosome = [Symbol]

-- | An individual is a chromosome
type Individual = Chromosome

-- | Symbol table used for fitness tests
type SymTable a = [(Symbol,a)]

-- | Data type representing a genome.  The genome contains all necessary
--   parameters to interpret a chromosome.  These include the alphabet (split
--   between terminal and nonterminal characters), connective characters for
--   multi-gene chromosomes, the maximum arity of any nonterminal, the length
--   of the head of a gene, and the number of genes per chromosome.
data Genome = Genome {
      terminals     :: [Symbol], -- ^ Set of terminal symbols
      nonterminals  :: [Symbol], -- ^ Set of nonterminal symbols
      geneConnector :: Symbol,   -- ^ Symbol connecting genes in a chromosome
      maxArity      :: Int,      -- ^ Highest arity nonterminal function
      headLength    :: Int,      -- ^ Length of gene head sequence
      numGenes      :: Int       -- ^ Number of genes per chromosome
} deriving Show

-- | Given a genome, provide the list of all symbols possible in a chromosome
allsymbols :: Genome -> [Symbol]
allsymbols g = (terminals g)++(nonterminals g)

-- | Return the length of the tail of a gene for a given genome
tailLength :: Genome -> Int
tailLength g = ((headLength g) * ((maxArity g)-1))+1

-- | Return length of a gene (tail + head) for a given genome
geneLength :: Genome -> Int
geneLength g = (headLength g) + (tailLength g)

-- | Test if a symbol is a nonterminal
isNonterminal :: Symbol -> Genome -> Bool
isNonterminal s g =
  let isNT []                 = False
      isNT (x:_)  | (s == x)  = True
      isNT (_:xs) | otherwise = (isNT xs)
  in
    isNT (nonterminals g)

-- | Fracture a chromosome into a set of genes
chromToGenes :: [Symbol] -> Int -> [[Symbol]]
chromToGenes [] _ = []
chromToGenes c  glen = (take glen c):(chromToGenes (drop glen c) glen)

-- | Assemble a chromosome from a set of genes
genesToChrom :: [[Symbol]] -> [Symbol]
genesToChrom genes = foldl (++) [] genes
