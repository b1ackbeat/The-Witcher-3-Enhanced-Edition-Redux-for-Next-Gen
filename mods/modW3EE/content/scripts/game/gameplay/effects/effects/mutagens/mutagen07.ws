/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



/*class W3Mutagen07_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen07;
	// W3EE - Begin
	default dontAddAbilityOnTarget = true;
	
	public function GetLeechPercent() : float
	{
		var lifeLeech, currentHealth : float;
		
		currentHealth = target.GetHealthPercents();
		lifeLeech = (2 / (currentHealth + 1) - 1) / 3;
		lifeLeech = RoundTo(lifeLeech, 2);
		LogChannel('mutagen07lifeLeech', lifeLeech);
		
		return lifeLeech;
	}
	// W3EE - End
}*/