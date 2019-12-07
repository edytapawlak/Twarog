module Twarog.Types where

-- | Current Combat Statistics
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
type Age = Int
type Height = Int
type Size = Int

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
