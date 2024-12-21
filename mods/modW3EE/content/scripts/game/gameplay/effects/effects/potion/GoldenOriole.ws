/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


// W3EE - Begin
class W3Potion_GoldenOriole extends CBaseGameplayEffect
{
	default effectType = EET_GoldenOriole;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var vitality : float;
		
		super.OnEffectAdded(customParams);
		
		//Kolaris - Golden Oriole, Kolaris - Full Moon
		if(GetBuffLevel() == 3)
		{
			vitality = thePlayer.GetStatMax(BCS_Vitality) * thePlayer.GetStatPercents(BCS_Toxicity);
			thePlayer.GainStat(BCS_Vitality, vitality);
		}
		
		if(GetBuffLevel() <= 3)
		{
			target.RemoveAllBuffsOfType(EET_PoisonCritical);
		}
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		((W3Effect_Poison)target.GetBuff(EET_Poison)).ResetStackTimer();
	}

	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		if(GetBuffLevel() <= 3)
		{
			target.RemoveAllBuffsOfType(EET_PoisonCritical);
		}
	}
	
	event OnUpdate(deltaTime : float)
	{
		var updateInterval : float;
		
		super.OnUpdate(deltaTime);
		
		updateInterval += deltaTime;
		
		if( updateInterval < 1.0f )
			return false;
		else
		{
			effectManager.CacheStatUpdate(BCS_Toxicity, CalculateAttributeValue(effectValue) );
			updateInterval = 0.f;
		}
	}
	
	
	/*
	protected function GetEffectStrength() : float
	{		
		var i : int;
		var val, tmp : SAbilityAttributeValue;
		var ret : float;
		var isPoint : bool;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		
		dm.GetAbilityAttributes(abilityName, atts);
		
		
		for(i=0; i<atts.Size(); i+=1)
		{
			if(IsNonPhysicalResistStat(ResistStatNameToEnum(atts[i], isPoint)))
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], val, tmp);
				
				if(isPoint)
					ret += CalculateAttributeValue(val);
				else
					ret += 100 * CalculateAttributeValue(val);
			}
		}

		return ret;
	}*/
}
// W3EE - End