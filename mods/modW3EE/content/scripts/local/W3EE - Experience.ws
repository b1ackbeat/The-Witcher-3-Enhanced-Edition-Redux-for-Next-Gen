/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

struct SMutationRequirements
{
	var skillPaths : array<ESkillSubPath>;
	var requiredPoints : array<int>;
}

struct SSkillPathEntry
{
	var expValue, maxPoints : int;
	var totalID, spentID, progressID : string;
}

class W3EEExperienceHandler
{
	private var skillPathEntries : array<SSkillPathEntry>;
	private var playerWitcher : W3PlayerWitcher;
	
	public function FactsSetValue( ID : string, value : int )
	{
		FactsRemove(ID);
		FactsAdd(ID, value, -1);
	}
	
	private function GetPathData( skillPath : ESkillSubPath ) : SSkillPathEntry
	{
		var pathEntry : SSkillPathEntry;
		switch(skillPath)
		{
			case ESSP_Sword_StyleFast:
				pathEntry.totalID = "FastAttackPoints";
				pathEntry.spentID = "FastAttackPointsSpent";
				pathEntry.progressID = "FastAttackProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(30 * Options().GetSkillRateFast());
			break;
			
			case ESSP_Sword_StyleStrong:
				pathEntry.totalID = "HeavyAttackPoints";
				pathEntry.spentID = "HeavyAttackPointsSpent";
				pathEntry.progressID = "HeavyAttackProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(50 * Options().GetSkillRateStrong());
			break;
			
			case ESSP_Sword_Utility:
				pathEntry.totalID = "DefensePoints";
				pathEntry.spentID = "DefensePointsSpent";
				pathEntry.progressID = "DefenseProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(30 * Options().GetSkillRateUtility());
			break;
			
			case ESSP_Sword_Crossbow:
				pathEntry.totalID = "RangedPoints";
				pathEntry.spentID = "RangedPointsSpent";
				pathEntry.progressID = "RangedProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(300 * Options().GetSkillRateCrossbow());
			break;
			
			case ESSP_Sword_BattleTrance:
				pathEntry.totalID = "TrancePoints";
				pathEntry.spentID = "TrancePointsSpent";
				pathEntry.progressID = "TranceProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(180 * Options().GetSkillRateTrance());
			break;
			
			case ESSP_Signs_Aard:
				pathEntry.totalID = "AardPoints";
				pathEntry.spentID = "AardPointsSpent";
				pathEntry.progressID = "AardProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(170 * Options().GetSkillRateAard());
			break;
			
			case ESSP_Signs_Igni:
				pathEntry.totalID = "IgniPoints";
				pathEntry.spentID = "IgniPointsSpent";
				pathEntry.progressID = "IgniProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(170 * Options().GetSkillRateIgni());
			break;
			
			case ESSP_Signs_Yrden:
				pathEntry.totalID = "YrdenPoints";
				pathEntry.spentID = "YrdenPointsSpent";
				pathEntry.progressID = "YrdenProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(200 * Options().GetSkillRateYrden());
			break;
			
			case ESSP_Signs_Quen:
				pathEntry.totalID = "QuenPoints";
				pathEntry.spentID = "QuenPointsSpent";
				pathEntry.progressID = "QuenProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(200 * Options().GetSkillRateQuen());
			break;
			
			case ESSP_Signs_Axi:
				pathEntry.totalID = "AxiiPoints";
				pathEntry.spentID = "AxiiPointsSpent";
				pathEntry.progressID = "AxiiProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(225 * Options().GetSkillRateAxii());
			break;
			
			case ESSP_Alchemy_Potions:
				pathEntry.totalID = "BrewingPoints";
				pathEntry.spentID = "BrewingPointsSpent";
				pathEntry.progressID = "BrewingProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(500 * Options().GetSkillRatePotions());
			break;
			
			case ESSP_Alchemy_Oils:
				pathEntry.totalID = "OilingPoints";
				pathEntry.spentID = "OilingPointsSpent";
				pathEntry.progressID = "OilingProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(625 * Options().GetSkillRateOils());
			break;
			
			case ESSP_Alchemy_Bombs:
				pathEntry.totalID = "BombPoints";
				pathEntry.spentID = "BombPointsSpent";
				pathEntry.progressID = "BombProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(750 * Options().GetSkillRateBombs());
			break;
			
			case ESSP_Alchemy_Mutagens:
				pathEntry.totalID = "MutationPoints";
				pathEntry.spentID = "MutationPointsSpent";
				pathEntry.progressID = "MutationProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(625 * Options().GetSkillRateMutagens() * (1.f + 0.15f * playerWitcher.GetMasterMutationStage()));
			break;
			
			case ESSP_Alchemy_Grasses:
				pathEntry.totalID = "TrialPoints";
				pathEntry.spentID = "TrialPointsSpent";
				pathEntry.progressID = "TrialProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(625 * Options().GetSkillRateGrasses() * (1.f + 0.1f * playerWitcher.GetMasterMutationStage()));
			break;
			
			case ESSP_Perks:
			case ESSP_Perks_col1:
			case ESSP_Perks_col2:
			case ESSP_Perks_col3:
			case ESSP_Perks_col4:
			case ESSP_Perks_col5:
				pathEntry.totalID = "GeneralPoints";
				pathEntry.spentID = "GeneralPointsSpent";
				pathEntry.progressID = "GeneralProgress";
				pathEntry.maxPoints = 20;
				pathEntry.expValue = RoundMath(200 * Options().GetSkillRateGeneral());
			break;
		}
		return pathEntry;
	}
	
	protected function AddSkillEntry( skillName : string, startingPoints : int )
	{
		FactsAdd(skillName + "Points", startingPoints, -1);
		FactsAdd(skillName + "PointsSpent", 0, -1);
		FactsAdd(skillName + "Progress", 0, -1);
	}
	
	protected function ModSpentPathPoints( skillPath : ESkillSubPath, value : int )
	{
		var id : int;
		
		value *= 10;
		id = Min((int)skillPath, 16);
		FactsSetValue(skillPathEntries[id].spentID, FactsQueryLatestValue(skillPathEntries[id].spentID) + value);
	}
	
	public function ModTotalPathPoints( skillPath : ESkillSubPath, value : float, optional disallowMessages : bool )
	{
		var id, val : int;
		
		val = (int)(value * 10);
		id = Min((int)skillPath, 16);
		FactsSetValue(skillPathEntries[id].totalID, FactsQueryLatestValue(skillPathEntries[id].totalID) + val);
		FactsSetValue("TotalPoints", FactsQueryLatestValue("TotalPoints") + val);
		((W3PlayerAbilityManager)playerWitcher.abilityManager).OnLevelGained(1);
		
		if( !disallowMessages )
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt(SkillSubPathToLocalisationKey(skillPath)) + " " + GetLocStringByKeyExt("W3EE_SkillGain"));
	}
	
	public function ModPathProgress( skillPath : ESkillSubPath, mult : float )
	{
		var id, xp, skillValue : int;
		
		if( FactsQuerySum("q001_nightmare_ended") < 1 )
			return;
		
		id = Min((int)skillPath, 16);
		skillValue = (int)(Options().SkillPointsGained() * 10);
		//Kolaris - Gaunter Mode, Kolaris - Difficulty Settings, Kolaris - Seasoned Witcher Mode
		if( GaunterMode().ConfigEnabled() )
			mult *= 1.f + (GaunterMode().ConfigXPModifier() / 100.f) * playerWitcher.GetDeathCounter();
		if( FactsQuerySum("SeasonedWitcherMode") > 0 )
			mult *= 0.1f;
		xp = FactsQueryLatestValue(skillPathEntries[id].progressID) + FloorF(skillPathEntries[id].expValue * (1.f - (0.8f / skillPathEntries[id].maxPoints * GetTotalPathPoints(skillPath))) * mult / Options().GetDifficultySettingMod() );
		if( xp < 10000 )
		{
			FactsSetValue(skillPathEntries[id].progressID, xp);
		}
		else
		{
			while( xp >= 10000 )
			{
				xp = Max(0, xp - 10000);
				FactsSetValue(skillPathEntries[id].totalID, FactsQueryLatestValue(skillPathEntries[id].totalID) + skillValue);
				FactsSetValue("TotalPoints", FactsQueryLatestValue("TotalPoints") + skillValue);
				((W3PlayerAbilityManager)playerWitcher.abilityManager).OnLevelGained(1);
			}
			FactsSetValue(skillPathEntries[id].progressID, xp);
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt(SkillSubPathToLocalisationKey(skillPath)) + " " + GetLocStringByKeyExt("W3EE_SkillGain"));
		}
		//Kolaris - Gaunter Mode
		if( GaunterMode().ConfigEnabled() && GaunterMode().ConfigMark() && GaunterMode().ConfigLethalMark() )
			GaunterMode().UpdateDemonMark();
	}
	
	//Kolaris - Gaunter Mode
	public function ModPathProgressDirect( skillPath : ESkillSubPath, amount : int )
	{
		var id, xp, skillValue : int;
		
		id = Min((int)skillPath, 16);
		skillValue = (int)(Options().SkillPointsGained() * 10);
		xp = FactsQueryLatestValue(skillPathEntries[id].progressID) + amount;
		if( xp < 10000 )
		{
			FactsSetValue(skillPathEntries[id].progressID, xp);
		}
		else
		{
			while( xp >= 10000 )
			{
				xp = Max(0, xp - 10000);
				FactsSetValue(skillPathEntries[id].totalID, FactsQueryLatestValue(skillPathEntries[id].totalID) + skillValue);
				FactsSetValue("TotalPoints", FactsQueryLatestValue("TotalPoints") + skillValue);
				((W3PlayerAbilityManager)playerWitcher.abilityManager).OnLevelGained(1);
			}
			FactsSetValue(skillPathEntries[id].progressID, xp);
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt(SkillSubPathToLocalisationKey(skillPath)) + " " + GetLocStringByKeyExt("W3EE_SkillGain"));
		}
	}
	
	public function GetTotalSkillPoints() : int
	{
		return FloorF(FactsQueryLatestValue("TotalPoints") / 10);
	}
	
	public function GetTotalPathPoints( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF(FactsQueryLatestValue(skillPathEntries[id].totalID) / 10);
	}
	
	public function GetSpentPathPoints( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF(FactsQueryLatestValue(skillPathEntries[id].spentID) / 10);
	}
	
	public function GetCurrentPathPoints( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF((FactsQueryLatestValue(skillPathEntries[id].totalID) - FactsQueryLatestValue(skillPathEntries[id].spentID)) / 10);
	}
	
	public function GetPathProgress( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF(FactsQueryLatestValue(skillPathEntries[id].progressID) / 100);
	}
	
	public function InitializeSkills( player : W3PlayerWitcher )
	{
		var i : int;
		playerWitcher = player;
		
		if( !FactsQuerySum("LevelingInitialized") )
		{
			FactsAdd("LevelingInitialized", 1, -1);
			
			AddSkillEntry("FastAttack"	, 10);
			AddSkillEntry("HeavyAttack"	, 10);
			AddSkillEntry("Defense"		, 10);
			AddSkillEntry("Ranged"		, 10);
			AddSkillEntry("Trance"		, 10);
			
			AddSkillEntry("Aard"		, 0);
			AddSkillEntry("Igni"		, 0);
			AddSkillEntry("Yrden"		, 0);
			AddSkillEntry("Quen"		, 0);
			AddSkillEntry("Axii"		, 0);
			
			AddSkillEntry("Brewing"		, 10);
			AddSkillEntry("Oiling"		, 10);
			AddSkillEntry("Bomb"		, 10);
			AddSkillEntry("Mutation"	, 10);
			AddSkillEntry("Trial"		, 10);
			
			AddSkillEntry("General"		, 0);
			
			FactsAdd("TotalPoints", 100, -1);
		}
		
		skillPathEntries.Clear();
		skillPathEntries.PushBack(SSkillPathEntry(0, 0, "", "", ""));
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		{
			skillPathEntries.PushBack(GetPathData((ESkillSubPath)i));
		}
	}
	
	public function GetAllSpentPoints() : int
	{
		var i, ret : int;
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
			ret += GetSpentPathPoints((ESkillSubPath)i);
			
		return ret;
	}
	
	//Kolaris - Gaunter Mode
	public function GetAllCurrentPoints() : int
	{
		var i, ret : int;
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
			ret += FloorF((FactsQueryLatestValue(skillPathEntries[i].totalID) - FactsQueryLatestValue(skillPathEntries[i].spentID)) / 10);
		return ret;
	}
	
	public function GetAllPathProgress() : int
	{
		var i, ret : int;
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
			ret += FloorF(FactsQueryLatestValue(skillPathEntries[i].progressID) / 100);
		return ret;
	}
	
	public function GetRandomNotEmptySkill( optional pathProgress : bool ) : ESkillSubPath
	{
		var i, random : int;
		var validSkills : array<ESkillSubPath>;
		
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		{
			if(pathProgress && GetPathProgress( (ESkillSubPath)i ) > 0)
				validSkills.PushBack((ESkillSubPath)i);
			else if( GetCurrentPathPoints( (ESkillSubPath)i ) > 0 )
				validSkills.PushBack((ESkillSubPath)i);
		}
		random = FloorF(RandF() * validSkills.Size());
		return validSkills[random];
	}
	
	public function AwardGeneralXP( fromQuest : bool )
	{
		if( fromQuest )
			ModPathProgress(ESSP_Perks, 1.5f);
		else
			ModPathProgress(ESSP_Perks, 1);
	}	
	
	public function AwardCombatXP( attackAction : W3Action_Attack, playerAttacker, playerVictim : CR4Player )
	{
		var attribute : SAbilityAttributeValue;
		var mult : float;
		
		if( playerAttacker && !playerVictim )
		{
			if( ((CActor)attackAction.victim).IsHuman() )
				attribute = playerWitcher.GetAttributeValue('human_exp_bonus_when_fatal');
			else
				attribute = playerWitcher.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
			
			mult = 1 + CalculateAttributeValue(attribute);
			if( attackAction.DealsAnyDamage() )
			{
				if( attackAction.IsActionMelee() )
				{
					if( playerWitcher.IsLightAttack(attackAction.GetAttackName()) )
					{
						ModPathProgress(ESSP_Sword_StyleFast, mult);
					}
					else
					{
						ModPathProgress(ESSP_Sword_StyleStrong, mult);
					}
				}
				else
				if( attackAction.IsActionRanged() || (CThrowable)attackAction.causer )
				{
					if( (W3ThrowingKnife)attackAction.causer )
						mult += 1.5f;
					ModPathProgress(ESSP_Sword_Crossbow, mult);
				}
			}
		}
		else
		if( playerVictim && !playerAttacker )
		{
			if( ((CActor)attackAction.attacker).IsHuman() )
				attribute = playerWitcher.GetAttributeValue('human_exp_bonus_when_fatal');
			else
				attribute = playerWitcher.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
			
			mult = 1 + CalculateAttributeValue(attribute);
			//Kolaris - Defense EXP
			if( attackAction.IsPerfectParried() || attackAction.IsCountered() )
			{
				ModPathProgress(ESSP_Sword_Utility, mult * 1.5f);
			}
			else if( attackAction.IsParried() )
			{
				ModPathProgress(ESSP_Sword_Utility, mult);
			}
		}
	}
	
	public function AwardDodgingXP( witcher : CR4Player )
	{
		if( witcher.IsInCombat() )
			ModPathProgress(ESSP_Sword_Utility, 1.f);
	}
	
	public function AwardCombatAdrenalineXP( witcher : W3PlayerWitcher, kills : int, noHealthLost : bool )
	{
		if( kills <= 0 )
			return;
		
		//Kolaris - Battle Trance XP
		if( theGame.GetDifficultyMode() == EDM_Hard )
			ModPathProgress(ESSP_Sword_BattleTrance, PowF(kills / 70.f, 1.5f));
		else if( theGame.GetDifficultyMode() == EDM_Hardcore )
			ModPathProgress(ESSP_Sword_BattleTrance, PowF(kills / 90.f, 1.5f));
		else
			ModPathProgress(ESSP_Sword_BattleTrance, PowF(kills / 50.f, 1.5f));
		
		/*if( noHealthLost )
			ModPathProgress(ESSP_Sword_BattleTrance, 1.5f);
		else
			ModPathProgress(ESSP_Sword_BattleTrance, 1);*/
	}
	
	public function AwardNonCombatXP( attackName : name )
	{
		if( playerWitcher.IsInCombat() )
			return;
		
		if( playerWitcher.IsLightAttack(attackName) )
		{
			ModPathProgress(ESSP_Sword_StyleFast, 0.25f);
		}
		else
		if( playerWitcher.IsHeavyAttack(attackName) )
		{
			ModPathProgress(ESSP_Sword_StyleStrong, 0.25f);
		}
		else
		{
			ModPathProgress(ESSP_Sword_Crossbow, 0.25f);
		}
	}
	
	public function AwardSignXP( signType : ESignType )
	{
		switch(signType)
		{
			case ST_Aard:
				ModPathProgress(ESSP_Signs_Aard, 1);
			break;
			
			case ST_Yrden:
				ModPathProgress(ESSP_Signs_Yrden, 1);
			break;
			
			case ST_Igni:
				ModPathProgress(ESSP_Signs_Igni, 1);
			break;
			
			case ST_Quen:
				ModPathProgress(ESSP_Signs_Quen, 1);
			break;
			
			case ST_Axii:
				ModPathProgress(ESSP_Signs_Axi, 1);
			break;
		}
	}
	
	public function AwardAlchemyBrewingXP( quantity : int, isPotion, isOil, isBomb, isDistilling, isDecoction, isMutagenIngredient : bool )
	{
		if( isDistilling )
			ModPathProgress(ESSP_Alchemy_Potions, 1.f);
		else
		if( isDecoction )
		{
			ModPathProgress(ESSP_Alchemy_Potions, quantity);
			ModPathProgress(ESSP_Alchemy_Mutagens, quantity * 4.f);
		}
		else
		if( isPotion )
			ModPathProgress(ESSP_Alchemy_Potions, quantity);
		else
		if( isOil )
			ModPathProgress(ESSP_Alchemy_Oils, quantity * 1.5f);
		else
		if( isBomb )
			ModPathProgress(ESSP_Alchemy_Bombs, quantity);
		else
		if( isMutagenIngredient )
			ModPathProgress(ESSP_Alchemy_Mutagens, quantity);
	}
	
	public function AwardAlchemyUsageXP( isDecoction, isPotion, isOil, isBomb : bool )
	{
		if( isDecoction )
		{
			ModPathProgress(ESSP_Alchemy_Grasses, 4.f);
			ModPathProgress(ESSP_Alchemy_Mutagens, 4.f);
		}
		else
		if( isPotion )
			ModPathProgress(ESSP_Alchemy_Grasses, 1.5f);
		else
		if( isOil )
			ModPathProgress(ESSP_Alchemy_Oils, 1.5f);
		else
		if( isBomb )
			ModPathProgress(ESSP_Alchemy_Bombs, 1.f);
	}
	
	public function SpendSkillPoints( skill : ESkill, amount : int )
	{
		if( Options().NoSkillPointReq() )
			return;
		
		ModSpentPathPoints(playerWitcher.GetSkillSubPathType(skill), amount);
	}
	
	public function SpendSkillPointsMutation( skillPath : ESkillSubPath, amount : int )
	{
		if( Options().NoSkillPointReq() )
			return;
		
		ModSpentPathPoints(skillPath, amount);
	}
	
	public function ResetCharacterSkills()
	{
		FactsSetValue("FastAttackPointsSpent", 0);
		FactsSetValue("HeavyAttackPointsSpent", 0);
		FactsSetValue("DefensePointsSpent", 0);
		FactsSetValue("RangedPointsSpent", 0);
		FactsSetValue("TrancePointsSpent", 0);
		FactsSetValue("AardPointsSpent", 0);
		FactsSetValue("IgniPointsSpent", 0);
		FactsSetValue("YrdenPointsSpent", 0);
		FactsSetValue("QuenPointsSpent", 0);
		FactsSetValue("AxiiPointsSpent", 0);
		FactsSetValue("BrewingPointsSpent", 0);
		FactsSetValue("OilingPointsSpent", 0);
		FactsSetValue("BombPointsSpent", 0);
		FactsSetValue("MutationPointsSpent", 0);
		FactsSetValue("TrialPointsSpent", 0);
		FactsSetValue("GeneralPointsSpent", 0);
	}
	
	public function GetMutationPathPointTypes( mutationID : EPlayerMutationType ) : SMutationRequirements
	{
		var mutationRequirements : SMutationRequirements;
		switch(mutationID)
		{
			case EPMT_Mutation1:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Aard);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Igni);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Yrden);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Quen);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Axi);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation2:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Aard);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Igni);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Yrden);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Quen);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation3:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleFast);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleStrong);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation4:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation5:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Utility);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation6:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Yrden);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Aard);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Axi);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Quen);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Igni);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation7:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Igni);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleStrong);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation8:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Utility);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation9:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Crossbow);
				mutationRequirements.requiredPoints.PushBack(3);
			break;
			
			case EPMT_Mutation10:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation11:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Quen);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Utility);
				mutationRequirements.requiredPoints.PushBack(2);
			break;
			
			case EPMT_Mutation12:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleFast);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleStrong);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Potions);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
		}
		return mutationRequirements;
	}
	
	public function GetTotalMutationSkillpoints( requirement : SMutationRequirements ) : int
	{
		var i, totalPoints : int;
		for(i=0; i<requirement.skillPaths.Size(); i+=1)
		{
			if( Options().NoSkillPointReq() )
				totalPoints += requirement.requiredPoints[i];
			else
				totalPoints += Min(requirement.requiredPoints[i], GetCurrentPathPoints(requirement.skillPaths[i]));
		}
		
		return totalPoints;
	}
	
	public function GetRequiredPathsString( requirement : SMutationRequirements ) : string
	{
		var i : int;
		var ret : string;
		
		ret = "<font color=\"#aa9578\">";
		ret += "<br>" + GetLocStringByKeyExt("W3EE_Required")+ ": ";
		for(i=0; i<requirement.skillPaths.Size(); i+=1)
		{
			ret += requirement.requiredPoints[i] + " " + GetLocStringByKeyExt(SkillSubPathToLocalisationKey(requirement.skillPaths[i]));
			if( i < requirement.skillPaths.Size() - 1 )
				ret += ", ";
		}
		ret += "</font>";
		
		return ret;
	}
	
	//Kolaris - Seasoned Witcher Mode
	public function SWMSetup()
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		FactsSetValue("FastAttackPoints", 50);
		FactsSetValue("HeavyAttackPoints", 50);
		FactsSetValue("DefensePoints", 50);
		FactsSetValue("RangedPoints", 0);
		FactsSetValue("TrancePoints", 50);
		FactsSetValue("BrewingPoints", 50);
		FactsSetValue("OilingPoints", 50);
		FactsSetValue("BombPoints", 50);
		FactsSetValue("MutationPoints", 50);
		FactsSetValue("TrialPoints", 50);
		FactsSetValue("GeneralPoints", 30);
		witcher.AddSkill(S_Sword_s21, false);
		witcher.AddSkill(S_Sword_s21, false);
		witcher.AddSkill(S_Sword_s21, false);
		witcher.AddSkill(S_Sword_s21, false);
		witcher.AddSkill(S_Sword_s21, false);
		witcher.AddSkill(S_Sword_s04, false);
		witcher.AddSkill(S_Sword_s04, false);
		witcher.AddSkill(S_Sword_s04, false);
		witcher.AddSkill(S_Sword_s04, false);
		witcher.AddSkill(S_Sword_s04, false);
		witcher.AddSkill(S_Sword_s10, false);
		witcher.AddSkill(S_Sword_s10, false);
		witcher.AddSkill(S_Sword_s10, false);
		witcher.AddSkill(S_Sword_s10, false);
		witcher.AddSkill(S_Sword_s10, false);
		witcher.AddSkill(S_Sword_s18, false);
		witcher.AddSkill(S_Sword_s18, false);
		witcher.AddSkill(S_Sword_s18, false);
		witcher.AddSkill(S_Sword_s18, false);
		witcher.AddSkill(S_Sword_s18, false);
		witcher.AddSkill(S_Alchemy_s04, false);
		witcher.AddSkill(S_Alchemy_s04, false);
		witcher.AddSkill(S_Alchemy_s04, false);
		witcher.AddSkill(S_Alchemy_s04, false);
		witcher.AddSkill(S_Alchemy_s04, false);
		witcher.AddSkill(S_Alchemy_s07, false);
		witcher.AddSkill(S_Alchemy_s07, false);
		witcher.AddSkill(S_Alchemy_s07, false);
		witcher.AddSkill(S_Alchemy_s07, false);
		witcher.AddSkill(S_Alchemy_s07, false);
		witcher.AddSkill(S_Alchemy_s08, false);
		witcher.AddSkill(S_Alchemy_s08, false);
		witcher.AddSkill(S_Alchemy_s08, false);
		witcher.AddSkill(S_Alchemy_s08, false);
		witcher.AddSkill(S_Alchemy_s08, false);
		witcher.AddSkill(S_Alchemy_s19, false);
		witcher.AddSkill(S_Alchemy_s19, false);
		witcher.AddSkill(S_Alchemy_s19, false);
		witcher.AddSkill(S_Alchemy_s19, false);
		witcher.AddSkill(S_Alchemy_s19, false);
		witcher.AddSkill(S_Alchemy_s17, false);
		witcher.AddSkill(S_Alchemy_s17, false);
		witcher.AddSkill(S_Alchemy_s17, false);
		witcher.AddSkill(S_Alchemy_s17, false);
		witcher.AddSkill(S_Alchemy_s17, false);
		witcher.AddSkill(S_Perk_06, false);
		witcher.AddSkill(S_Perk_12, false);
		witcher.AddSkill(S_Perk_20, false);
	}
}

exec function AddPathPoints( skillPath : ESkillSubPath, amount : float )
{
	Experience().ModTotalPathPoints(skillPath, amount);
}

exec function AddPathPointsAll( amount : float, optional disallowMessages : bool )
{
	var i : int;
	for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		Experience().ModTotalPathPoints((ESkillSubPath)i, amount, disallowMessages);
}

exec function ResetTotalPoints()
{
	var i, count : int;
	
	Experience().FactsSetValue("TotalPoints", 0);
	for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		count += Experience().GetTotalPathPoints((ESkillSubPath)i);
	
	count *= 10;
	Experience().FactsSetValue("TotalPoints", count);
}

exec function IncreasePathXP( skillPath : ESkillSubPath, mult : float )
{
	Experience().ModPathProgress(skillPath, mult);
}

exec function fucktest()
{
	var a : Vector;
	
	a = GetWitcherPlayer().GetWorldPosition();
	a = GetWitcherPlayer().GetWorldPosition();
}

//Kolaris - Seasoned Witcher Mode
exec function SeasonedWitcherMode()
{
	if( FactsQuerySum("SWMIntroComplete") > 0 || FactsQuerySum("SeasonedWitcherMode") > 0 )
		return;
	
	FactsAdd("SeasonedWitcherMode", 1);
	Experience().SWMSetup();
}