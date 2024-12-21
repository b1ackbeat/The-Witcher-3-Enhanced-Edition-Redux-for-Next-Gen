/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


/*
class W3Mutagen15_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen15;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		// W3EE - Begin
		GetWitcherPlayer().ForceSetMutagen15(0);
		// W3EE - End
	}
}*/