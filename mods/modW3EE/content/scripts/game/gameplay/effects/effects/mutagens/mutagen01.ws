/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



/*class W3Mutagen01_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen01;
	
	// W3EE - Begin
	default dontAddAbilityOnTarget = true;

	private var currentHealth : float;
	private var currentStacks, delta : int;
	private var witcher : W3PlayerWitcher;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		witcher = GetWitcherPlayer();
		currentStacks = witcher.GetAbilityCount(abilityName);
		currentHealth = witcher.GetHealthPercents() * 100;
		
		if (currentStacks > 0)
			witcher.RemoveAbilityAll(abilityName);
		
		// W3EE - Begin
		delta = FloorF((100.f - currentHealth) / 2.f); // FloorF((20000 / (currentHealth + 100)) - 100);
		// W3EE - End
		
		if (delta > 0)
			witcher.AddAbilityMultiple(abilityName, delta);
		
		super.OnEffectAdded(customParams);
	}

	event OnUpdate(time : float)
	{
		currentStacks = witcher.GetAbilityCount(abilityName);
		currentHealth = witcher.GetHealthPercents() * 100;
		
		// W3EE - Begin
		delta = FloorF((100.f - currentHealth) / 2.f); // FloorF((20000 / (currentHealth + 100)) - 100);
		// W3EE - End
		
		if (currentStacks != delta)
		{
			delta -= currentStacks;
			if (delta > 0)
				witcher.AddAbilityMultiple(abilityName, delta);
			if (delta < 0)
				witcher.RemoveAbilityMultiple(abilityName, Abs(delta));
		}
		
		super.OnUpdate(time);
	}
	
	event OnEffectRemoved()
	{
		witcher.RemoveAbilityAll(abilityName);
		super.OnEffectRemoved();
	}
	// W3EE - End
}*/