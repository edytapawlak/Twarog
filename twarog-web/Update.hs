module Update (updateModel) where

import       Control.Lens
import       Control.Monad.IO.Class
import       Data.Maybe
import qualified Data.Set as S
import       Miso
import       Miso.String
import       Model
import       Twarog
import qualified Twarog as T

-- | Updates model, optionally introduces side effects
updateModel :: Msg -> Model -> Effect Msg Model
updateModel (Name n) m = 
  noEff $ m & character . characterName .~ (Just $ fromMisoString n)

updateModel NoOp m = noEff m

updateModel (RaceChecked r (Checked True)) m = 
  (m & character . characterRace .~ r) <# do return $ SetRandomLifeStance

updateModel (ArchetypeChecked a (Checked True)) m = 
  noEff $ (m & character . characterAlignment .~ a)

updateModel (RoleChecked a (Checked True)) m = 
  noEff $ (m & character . characterRole .~ a)

updateModel (TalentChecked t max (Checked True)) m =  
  let 
    currTalents = m ^. character . characterTalent
    maxTalents = fromMaybe 0 max
  in
    noEff ( 
        if Prelude.length currTalents < maxTalents
        then m & character . characterTalent %~ S.insert t 
        else m 
        )
updateModel (TalentChecked r _ (Checked False)) m = 
  noEff $ m & character . characterTalent %~ S.delete r

updateModel (ChangeStage s) m = 
  let availableS = m ^. availableStages
      isNewStage = not $ elem s availableS
      current = m & currentStage .~ s
  in if isNewStage 
     then noEff $ current & availableStages .~ ( availableS ++ [s] )
     else noEff current

updateModel (SetCurrentRoll1 n) m = 
  let
    toString = fromMisoString n 
    result = case toString of
          "" -> 0
          _ -> read toString
  in
  noEff ( m & currentRoll1 .~ result)
                                                    
updateModel (SetCurrentRoll2 n) m = 
  let toString = fromMisoString n 
      result = case toString of
        "" -> 0
        _  -> read toString
  in noEff $ m & currentRoll2 .~  result

updateModel (SetAttribute n t) m =  
  let 
    action = 
      case t of
        Just Charisma -> cha
        Just Constitution -> con
        Just Dexterity -> dex
        Just Inteligence -> T.int
        Just Strength -> str
        Just WillPower -> wil
        Nothing -> cha

    next = 
      case t of 
        Just Every -> Just Charisma
        Just Charisma -> Just Constitution
        Just Constitution -> Just Dexterity
        Just Dexterity -> Just Inteligence
        Just Inteligence -> Just Strength
        Just Strength -> Just WillPower
        Just WillPower -> Nothing
        Nothing -> Nothing

    value = if n >= 18 then 18 else n
    attr = fromMaybe (Attributes 0 0 0 0 0 0) 
        (m ^. character . characterAttr)
    newModel = (((m & currentAttribBounce .~ t)
          & (character . characterAttr .~ Just (attr & action .~ value))
          & currentRoll1 .~ 0 )
          & currentRoll2 .~ 0 )
  in
    noEff $ newModel & currentStage .~ (AttribStage next)

updateModel (SexChecked s (Checked True)) m = 
  noEff $ m & character . characterSex .~ s
     
updateModel (FlawChecked f _ (Checked True)) m =  
  noEff 
    $ m & character . characterFlaws %~ S.insert f

updateModel (FlawChecked f _ (Checked False)) m = 
  noEff $ m & character . characterFlaws %~ S.delete f

updateModel (SetAllAttributes attr) m = 
  noEff  ((m & character . characterAttr .~ Just attr) 
        & currentAttribBounce .~ Just Every)
  
updateModel SetRandomAttr m = do
  m <# do
    attr <- sample $ genAttributes
    return $ SetAllAttributes attr

updateModel SetRandomBirth m = do
  m <# do
    birth <- sample $ genBirthday
    return $ SetBirth birth

updateModel (SetBirth b) m =
  noEff $ m & (character . characterBirth .~ Just b)
            . (character . characterTalent %~ if isMarked b
                                              then S.insert Marked
                                              else S.delete Marked)

updateModel SetRandomRace m = do
  m <# do
    race <- sample $ genRace
    return $ SetRace race

updateModel (SetRace b) m =
  (m & character . characterRace .~ Just b) <# do return $ SetRandomLifeStance

updateModel SetRandomSex m = do
  m <# do
    sex <- sample $ 
          (case m ^. character . characterRace of 
            Just r -> genSex' r 
            Nothing -> genSex
          ) 
    return $ SetSex sex

updateModel (SetSex s) m =
  noEff $ m & character . characterSex .~ Just s

updateModel SetRandomFlawsAndTalents m = do
  m <# do
    flaws <- sample $ genFlaws
    talents <- sample 
                $ genTalents 
                    (case (m ^. character . characterRace) of
                      Just t -> t
                      Nothing -> Elf)
                    flaws $ 
                          if isMarked 
                            $ fromMaybe (Birthday (CommonDay 1) Valaskjolf) (m ^. character . characterBirth)
                          then S.singleton Marked
                          else S.empty
    return $ SetFlawsAndTalents talents flaws

updateModel (SetFlawsAndTalents t f) m =
  noEff $ (m & character . characterFlaws .~ f)
            & character . characterTalent .~ t
  
updateModel SetRandomLifeStance m = do
  m <# do
    lifeStance <- sample $ 
                    case (m ^. character .characterRace) of 
                      Just a -> genLifeStance' a
                      Nothing -> genLifeStance    
    return $ SetLifeStance lifeStance

updateModel (SetLifeStance l) m =
  noEff $ m & character . characterLifeStance .~ Just l
            
updateModel (AddAvailableStage s) m =
  let 
    stages =  m ^. availableStages
  in
    noEff $ (m & availableStages .~ s : stages)

updateModel (SetSociability s) m =
  noEff $ setModelArchetype (m & sociability .~ s)

updateModel (SetSubmissiveness s) m =
  noEff $ setModelArchetype $ m & submissiveness .~ s

updateModel (SetOnthology o) m =
  noEff $ setModelArchetype $ m & ontology .~ o

updateModel (SetEmpathy e) m =
  noEff $ setModelArchetype $ m & empathy .~ e

updateModel SetRandomArchetype m = do
  m <# do
    arch <- sample $ genArchetype
    return $ SetArchetype arch

updateModel (SetArchetype a) m =
  noEff $ setModelAttitude (attitude a) $ m & character . characterAlignment .~ Just a


setModelArchetype m =
  let 
    soc = m ^. sociability
    sub = m ^. submissiveness
    ont = m ^. ontology
    emp = m ^. empathy
    whatAttitude :: Maybe Sociability -> Maybe Submissiveness -> Maybe Ontology -> Maybe Empathy -> Attitude
    whatAttitude (Just so) (Just su) (Just o) (Just e) = Attitude so su o e
    whatAttitude _ _ _ _ = Neutral
  in 
    m & character . characterAlignment .~ Just (archetype $ whatAttitude soc sub ont emp)

setModelAttitude (Attitude soc sub ont emp) m = 
  ((( m & sociability .~ Just soc)
    & submissiveness .~ Just sub)
    & ontology .~ Just ont)
    & empathy .~ Just emp
setModelAttitude Neutral m = m