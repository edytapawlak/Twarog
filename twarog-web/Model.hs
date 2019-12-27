module Model
  ( Model(..)
  , character
  , currentStage
  , availableStages
  , currentAttribBounce
  , currentRoll1
  , currentRoll2
  , Msg (..)
  , Stage (..)
  , AttribBounce (..)
  , MaxCheckbox (..)
  , printBounce
  , initialModel
  , nextStage
  , getNextButtonText
  ) where

import       Control.Lens
import       Miso
import       Miso.String
import       Data.Char as C
import       Data.Set as S
import       Twarog

data Stage = OwnerStage 
           | NameStage 
           | AttribStage (Maybe AttribBounce) 
           | RaceStage 
           | BirthStage
           | AttitudeStage 
           | GodStage 
           | SexStage 
           | HamingjaStage
           | FlawsAndTalentsStage Bool
           | RoleStage
           | SkilsStage 
           deriving (Eq)

instance Show Stage where
  show OwnerStage = "Your name"
  show NameStage = "Character name"
  show (AttribStage _) = "Attributes"
  show RaceStage = "Race"
  show BirthStage = "Birthday"
  show AttitudeStage = "Attitude"
  show GodStage = "Life stance"
  show SexStage = "Sex" 
  show HamingjaStage = "Hamingja"
  show (FlawsAndTalentsStage _) = "Talents & Flaws"
  show RoleStage = "Character's role"
  show SkilsStage = "Skills"

data AttribBounce = Every 
                  | Charisma 
                  | Constitution 
                  | Dexterity 
                  | Inteligence 
                  | Strength 
                  | WillPower 
                  deriving (Show, Eq)

nextStage :: Stage -> Stage
nextStage s = case s of 
  NameStage            -> AttribStage Nothing
  AttribStage _        -> BirthStage
  BirthStage           -> RaceStage 
  RaceStage            -> SexStage
  GodStage             -> SexStage
  SexStage             -> AttitudeStage
  AttitudeStage        -> FlawsAndTalentsStage False
  RoleStage            -> SkilsStage
  FlawsAndTalentsStage  _ -> RoleStage

getNextButtonText s = case s of
  NameStage               -> ""
  AttribStage _           -> "Go to Attributes"
  BirthStage              -> "Go to Birthday"
  SexStage                -> "Go to Sex" 
  RaceStage               -> "Go to Race" 
  AttitudeStage           -> "Go to Attitude"
  RoleStage               -> "Go to Role"
  FlawsAndTalentsStage _  -> "Go to Flaws & Talents"
  GodStage                -> "Go to Life Stance"


printBounce :: Maybe AttribBounce -> String
printBounce b = case b of
  Just a -> C.toLower <$> show a
  Nothing -> ""
  
data Model = Model
  { _currentStage :: Stage
  , _availableStages :: [Stage]
  , _currentAttribBounce :: Maybe AttribBounce
  , _currentRoll1 :: Int
  , _currentRoll2 :: Int
  , _character  :: NewCharacter
  } deriving (Show, Eq)
makeLenses ''Model

data Msg =  Name MisoString
      -- Checkbox msgs
      | TalentChecked Talent (Maybe Int) Checked
      | FlawChecked Flaw (Maybe Int) Checked
      -- Radiobox msgs
      | SexChecked (Maybe Sex) Checked
      | RaceChecked (Maybe Race) Checked
      -- Character related msgs
      | AskName
      | AskRace
      | AskTalents
      | SetAttribute Int (Maybe AttribBounce)
      | SetAllAttributes Attributes
      | SetRandomAttr
      | SetBirth Birthday
      | SetRandomBirth
      | SetRandomRace 
      | SetRace Race
      | SetRandomSex
      | SetSex Sex
      | SetRandomFlawsAndTalents
      | SetFlawsAndTalents (S.Set Talent) (S.Set Flaw)
      | SetRandomLifeStance
      | SetLifeStance LifeStance
      -- No character related msgs
      | NoOp
      | ChangeStage Stage
      | AddAvailableStage Stage
      | SetCurrentRoll1 MisoString
      | SetCurrentRoll2 MisoString
      | SetAttrBounce AttribBounce
      deriving (Show, Eq)

data MaxCheckbox = TalentsMax Int | NoLimit

initialModel :: Model
initialModel =
  let _currentStage = NameStage 
      _currentAttribBounce = Nothing 
      _availableStages = []
      _currentRoll1 = 0
      _currentRoll2 = 0
      _character = emptyNewCharacter
   in Model{..}

