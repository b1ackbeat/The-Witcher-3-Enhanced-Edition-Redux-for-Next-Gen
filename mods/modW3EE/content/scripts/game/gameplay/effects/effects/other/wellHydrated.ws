/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_WellHydrated extends CBaseGameplayEffect
{
	private var level : int;

	default effectType = EET_WellHydrated;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		// W3EE - Begin
		//Kolaris - Gourmet
		if( isOnPlayer && target.HasBuff(EET_WellFed) && ((W3PlayerWitcher)target).CanUseSkill(S_Perk_15) )
			target.AddAbility('wellfedhydrated', false);
		// W3EE - End
	}
	
	event OnEffectRemoved()
	{
		if( isOnPlayer )
			target.RemoveAbilityAll('wellfedhydrated');
			
		super.OnEffectRemoved();
	}
	
	//Kolaris - Gourmet
	event OnUpdate(dt : float)
	{
		if( isOnPlayer && ((W3PlayerWitcher)target).CanUseSkill(S_Perk_15) )
		timeLeft += dt / 3;
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect ) : EEffectInteract
	{
		return EI_Override;
	}
}