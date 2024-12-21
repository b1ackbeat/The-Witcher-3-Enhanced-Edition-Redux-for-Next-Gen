/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_MariborForest extends CBaseGameplayEffect
{
	default effectType = EET_MariborForest;
	
	// W3EE - Begin
	/*event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		target.abilityManager.SetStatPointMax(BCS_Focus, Options().MaxFocus() );
		
		if(GetBuffLevel() == 3)
		{
			target.GainStat(BCS_Focus, 1);
		}
	}
	
	event OnEffectRemoved()
	{
		target.abilityManager.SetStatPointMax(BCS_Focus, Options().MaxFocus());
		
		super.OnEffectRemoved();
	}*/
	// W3EE - End
}
