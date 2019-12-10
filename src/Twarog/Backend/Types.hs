{-# LANGUAGE TemplateHaskell #-}
module Twarog.Backend.Types
  ( 
  -- * Character sheet
  -- ** Descriptive part
    Sex (..)
  , Height
  , Size (..)
  , LifeStance (..)
  , Age (..)
  , XP
  , Lvl
  , Hamingja
  , Mod
  -- ** Attributes
  , CHA
  , CON
  , DEX
  , STR
  , WIL
  , INT
  , Attributes (..)
  -- *** Attributes lenses
  , cha
  , con
  , dex
  , int
  , str
  , wil
  -- ** Modifiers
  , Cha
  , Con
  , Dex
  , Str
  , Wil
  , Modifiers (..)
  , toModifier 
  -- *** Modifiers lenses
  , chaMod
  , conMod
  , dexMod
  , intMod
  , strMod
  , wilMod
  -- ** Combat statistics
  , OvMe
  , OvMi
  , DvMe
  , DvMi
  , Dodging
  , TotalAv
  , MsPenality
  , ShieldDvMe
  , ShieldBlock
  -- ** Toughness
  , Cold
  , Electricity
  , Heat
  , Physical
  , Toughness
  -- ** Condition
  , Condition
  -- ** Encumbrance
  , Encumbrance
  -- ** Vitality
  , HP
  , SP
  -- ** Resistance
  , Resistance
  , Disease
  , Poison
  -- *** Resistance lenses
  , disease
  , poison 
  -- ** Morale
  , Morale
  -- * Item statistics
  -- ** Armour statistics
  , AV 
  , ArmourMs
  , StealthMod
  , SwimmingMod
  , EncumbranceMod
  , PerceptionMod -- For helmets only
  -- ** Shield statistics
  , ShieldMe
  , MiBlockChance
  , ShieldMs
  -- ** Weapon statistics
  , Damage
  , CutMod
  , ShockMod
  , BaseRange -- Bows and crossbows only
  ) where

import Control.Lens
import Twarog.Backend.Units

type AV = Int
type Damage = Int
type OvMe = Int        
type OvMi = Int        
type DvMe = Int        
type DvMi = Int        
type Dodging = Int     
type TotalAv = Int     
type MsPenality = Int  
type ShieldDvMe = Int  
type ShieldBlock = Int 

type Mod = Int

type Hamingja = Int
type BaseRange = Int

type ArmourMs = Int
type StealthMod = Int
type SwimmingMod = Int   
type EncumbranceMod = Int 
type PerceptionMod = Int

type ShieldMe = Int
type MiBlockChance = Int
type ShieldMs = Int

type CutMod = Int
type ShockMod = Int

-- | Resistance
type Disease = Int
type Poison = Int

-- | Toughness
type Cold = Int
type Electricity = Int  
type Heat = Int 
type Physical = Int

type XP = Int
type HP = Int
type SP = Int
data Age = Immortal | Mortal Int
  deriving (Show)
type Height = Distance Inch

type Size = Int -> Int
instance Show Size where
  show f = show $ f 0

-- newtype Size = Size { unSize :: Int -> Int }
-- instance Show Size where
--   show (Size f) = show $ f 0

type Cha = Int -> Int
type Con = Int -> Int
type Dex = Int -> Int
type Str = Int -> Int
type Wil = Int -> Int

type CHA = Int
type CON = Int
type DEX = Int
type STR = Int
type WIL = Int
type INT = Int

type Lvl = Int


data Sex = Male
         | Female
         | Non
         deriving (Eq, Show)

data LifeStance = Religious
                | Traditional
                deriving (Eq, Show)

data Toughness = Toughness Cold Electricity Heat Physical
  deriving (Show)

data Condition = Tired
               | Weary
               | Exhausted
               | Wet
               | SoakingWet
               deriving (Show)

data Morale = Nervous
            | Afraid
            | Anxious
            | Terrified
            | Panic
            deriving (Show)

data Encumbrance = LightLoad    -- ^ '0' MS mod
                 | MediumLoad   -- ^ '-1' MS mod
                 | HeavyLoad    -- ^ '-2' MS mod
                 deriving (Show)

data Resistance = Resistance
  { _disease :: Disease
  , _poison  :: Poison
  } deriving (Show)
makeLenses ''Resistance

data Attributes = Attributes
  { _cha :: CHA
  , _con :: CON
  , _dex :: DEX
  , _int :: INT
  , _str :: STR
  , _wil :: WIL
  } deriving (Show)
makeLenses ''Attributes  
              
data Modifiers = Modifiers
  { _chaMod :: Cha
  , _conMod :: Con
  , _dexMod :: Dex
  , _intMod :: Int -> Int
  , _strMod :: Str
  , _wilMod :: Wil
  } 
makeLenses ''Modifiers

toModifier :: Int -> Int -> Int
toModifier x  | x <= 1             = \x -> x - 5
              | x == 2             = \x -> x - 4
              | x == 3             = \x -> x - 3
              | x == 4 || x == 5   = \x -> x - 2
              | 6 <= x && x <= 8   = \x -> x - 1
              | 9 <= x && x <= 12  = id 
              | 13 <= x && x <= 15 = (+ 1)
              | 16 <= x && x <= 17 = (+ 2)
              | 18 <= x && x <= 19 = (+ 3)
              | x == 20            = (+ 4)
              | x == 21            = (+ 5)
              | x >= 22            = (+ 6)

-- | Convert Attributes to Modifiers
modifiers :: Attributes -> Modifiers 
modifiers (Attributes cha con dex int str wil) =
  let f = toModifier
   in Modifiers (f cha) (f con) (f dex) (f int) (f str) (f wil)      
