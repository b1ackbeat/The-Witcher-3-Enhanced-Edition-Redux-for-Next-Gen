/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

/*

class W3Mutagen17_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen17;
	default dontAddAbilityOnTarget = true;
	
	// W3EE - Begin
	private var lightCounter, heavyCounter, signCounter : int;
	private var hasLightBoost, hasHeavyBoost, hasSignBoost : bool;
	default hasLightBoost = false;
	default hasHeavyBoost = false;
	default hasSignBoost = false;

	private var pauseDuration, pauseDT : float;
	default pauseDuration = 3.f;

	private var abilityNameLight, abilityNameHeavy, abilityNameSign : name;
	default abilityNameLight	= 'Mutagen17EffectLight';
	default abilityNameHeavy	= 'Mutagen17EffectHeavy';
	default abilityNameSign		= 'Mutagen17EffectSign';

	event OnUpdate(dt : float)
	{
		var lightCount, heavyCount, signCount, counterCount, chargeCount : int;
		
		super.OnUpdate(dt);
		
		if (pauseDT > 0)
			pauseDT -= dt;
		
		if(!HasBoost("all") && pauseDT <= 0)
		{
			lightCount = FactsQuerySum("mutagen_17_attack_light");
			heavyCount = FactsQuerySum("mutagen_17_attack_heavy");
			signCount = FactsQuerySum("ach_sign");
			counterCount = FactsQuerySum("ach_counter");
		
			if (!hasLightBoost)
			{
				chargeCount = signCount * 3 + counterCount * 3 + heavyCount * 2;
				if (chargeCount >= 3)
				{
					AddBoost(abilityNameLight);
					hasLightBoost = true;
				}
			}
			if (!hasHeavyBoost)
			{
				chargeCount = signCount * 3 + counterCount * 3 + lightCount * 1;
				if (chargeCount >= 3)
				{
					AddBoost(abilityNameHeavy);
					hasHeavyBoost = true;
				}
			}
			if (!hasSignBoost)
			{
				chargeCount = counterCount * 3 + heavyCount * 2 + lightCount * 1;
				if (chargeCount >= 3)
				{
					AddBoost(abilityNameSign);
					hasSignBoost = true;
				}
			}
		}
	}

	private function AddBoost(boostName : name)
	{
		target.AddAbility(boostName, false);
	}
	
	public function HasBoost(optional type : string) : bool
	{
		switch (type) 
		{
			case "light"	:	return hasLightBoost;
			case "heavy"	:	return hasHeavyBoost;
			case "sign"		:	return hasSignBoost;
			case "all"		:	return hasLightBoost && hasHeavyBoost && hasSignBoost;
			default			:	return false;
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		target.RemoveAbility(abilityName);	
	}
	
	public function BlockBoost()
	{
		ClearBoost();
		pauseDT = pauseDuration;
	}

	public function ClearBoost(optional type : string)
	{
		FactsRemove("mutagen_17_attack_light");
		FactsRemove("mutagen_17_attack_heavy");
		FactsRemove("ach_sign");
		FactsRemove("ach_counter");
		
		switch (type) 
		{
			case "light" :
				target.RemoveAbility(abilityNameLight);
				hasLightBoost = false;
				break;
			case "heavy" :
				target.RemoveAbility(abilityNameHeavy);
				hasHeavyBoost = false;
				break;
			case "attack" :
				target.RemoveAbility(abilityNameLight);
				target.RemoveAbility(abilityNameHeavy);
				hasLightBoost = false;
				hasHeavyBoost = false;
				break;
			case "sign" :
				target.RemoveAbility(abilityNameSign);
				hasSignBoost = false;
				break;
			default:
				target.RemoveAbility(abilityNameLight);
				target.RemoveAbility(abilityNameHeavy);
				target.RemoveAbility(abilityNameSign);
				hasLightBoost = false;
				hasHeavyBoost = false;
				hasSignBoost = false;
				break;
		}
	}
	// W3EE - End
}
*/