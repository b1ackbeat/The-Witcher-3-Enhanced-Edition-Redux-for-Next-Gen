/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_BlackBlood extends CBaseGameplayEffect
{
	default effectType = EET_BlackBlood;
	default attributeName = 'return_damage';
	
	// W3EE - Begin
	public function GetReturnDamageValue( incomingDamage : float ) : float
	{
		return incomingDamage * effectValue.valueMultiplicative;
	}
	// W3EE - End
}