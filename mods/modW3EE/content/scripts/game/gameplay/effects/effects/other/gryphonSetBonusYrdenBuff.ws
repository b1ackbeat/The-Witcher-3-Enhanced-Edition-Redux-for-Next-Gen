/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_GryphonSetBonusYrden extends CBaseGameplayEffect
{
	default effectType = EET_GryphonSetBonusYrden;
	default isPositive = true;
	
	// Lazarus - Gryphon Set Bonus
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	// Lazarus - End
}