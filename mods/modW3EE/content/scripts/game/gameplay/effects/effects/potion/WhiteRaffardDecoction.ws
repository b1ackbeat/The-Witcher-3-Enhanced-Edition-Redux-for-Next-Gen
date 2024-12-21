/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_WhiteRaffardDecoction extends CBaseGameplayEffect
{
	default effectType = EET_WhiteRaffardDecoction;
	
	//Kolaris - White Raffard
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var vitality : float;
		
		super.OnEffectAdded(customParams);
		
		if(GetBuffLevel() == 3)
		{
			vitality = 0.3f * (thePlayer.GetStatMax(BCS_Vitality) - thePlayer.GetStat(BCS_Vitality));
			thePlayer.GainStat(BCS_Vitality, vitality);
		}
		
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		((W3Effect_Bleeding)target.GetBuff(EET_Bleeding)).ResetStackTimer();
	}
}