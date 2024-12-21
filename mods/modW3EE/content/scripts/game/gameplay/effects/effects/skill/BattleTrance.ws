/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_BattleTrance extends CBaseGameplayEffect
{
	private saved var currentFocusLevel : int;
	private var newLevel, delta : int;
	private var focus : float;
	
	default effectType = EET_BattleTrance;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;

	
	event OnUpdate(deltaTime : float)
	{
		super.OnUpdate(deltaTime);
		
		GetVigorLevel();
		if( delta != 0 )
		{
			if( delta < 0 )
			{
				target.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), Abs(delta));
				//Kolaris - Huntsman
				//if( thePlayer.CanUseSkill(S_Perk_19) )
					//target.RemoveAbilityMultiple(SkillEnumToName(S_Perk_19), Abs(delta));
			}
			else
			{
				target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), delta);
				//Kolaris - Huntsman
				//if( thePlayer.CanUseSkill(S_Perk_19) )
					//target.AddAbilityMultiple(SkillEnumToName(S_Perk_19), delta);
			}
			
			if( newLevel == 0 )
			{
				isActive = false;
				return true;
			}
			
			currentFocusLevel = newLevel;
		}
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var player : W3PlayerWitcher;
		
		player = (W3PlayerWitcher)target;
		if( !player )
		{
			LogEffects("W3Effect_BattleTrance.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
		
		super.OnEffectAdded(customParams);
		//Kolaris ++ Mutation Rework
		/*if( player.IsMutationActive(EPMT_Mutation1) )
			currentFocusLevel = FloorF(player.GetStatMax(BCS_Focus));
		else*/ //Kolaris -- Mutation Rework
			currentFocusLevel = FloorF(player.GetStat(BCS_Focus));
			
		player.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), currentFocusLevel);
		//Kolaris - Huntsman
		//if( player.CanUseSkill(S_Perk_19) )
			//player.AddAbilityMultiple(SkillEnumToName(S_Perk_19), currentFocusLevel);
	}
	
	event OnEffectRemoved()
	{
		var player : CR4Player;
		
		super.OnEffectRemoved();
		
		player = (CR4Player)target;
		player.RemoveAbilityAll(player.GetSkillAbilityName(S_Sword_5));
		//Kolaris - Huntsman
		//player.RemoveAbilityAll(SkillEnumToName(S_Perk_19));
	}
	
	private function GetVigorLevel()
	{
		//Kolaris ++ Mutation Rework
		/*if( ((W3PlayerWitcher)target).IsMutationActive(EPMT_Mutation1) )
			focus = target.GetStatMax(BCS_Focus);
		else*/ //Kolaris -- Mutation Rework
			focus = target.GetStat(BCS_Focus);
		newLevel = FloorF(focus);
		delta = newLevel - currentFocusLevel;
	}
}