/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

/*
// W3EE - Begin
class W3Mutagen03_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen03;
	default dontAddAbilityOnTarget = true;

	private var chainTimer, currentSlowdown : float;
	private var chainActive : bool;
	private var speedMultiplierID : int;

	private var slowdownStep, slowdownThreshold, chainDuration, damageAmplification : float;
	default slowdownStep = 0.02f;
	default slowdownThreshold = 0.5f;
	default chainDuration = 3.f;
	default damageAmplification = 0.05f;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded(customParams);	
		
		currentSlowdown = 1.f;		
	}

	event OnUpdate(time : float)
	{
		super.OnUpdate(time);
		
		if (chainActive)
		{
			chainTimer -= time / currentSlowdown;
			if (chainTimer <= 0)
				ResetChain();
		}
	}
	
	event OnEffectRemoved()
	{
		ResetChain();
		super.OnEffectRemoved();
	}

	public function AdvanceChain()
	{
		chainTimer = chainDuration;
		
		if (!chainActive)
			chainActive = true;
		
		if (currentSlowdown > slowdownThreshold)
			currentSlowdown -= slowdownStep;
		
		target.AddAbility(abilityName, true);
		
		RemoveSlowdown();
		
		theGame.SetTimeScale(currentSlowdown, theGame.GetTimescaleSource(ETS_CockatriceMutagen), theGame.GetTimescalePriority(ETS_CockatriceMutagen));
		speedMultiplierID = target.SetAnimationSpeedMultiplier(1 / currentSlowdown);
	}

	public function ResetChain()
	{
		var i : int;
		
		chainActive = false;
		currentSlowdown = 1.f;
		
		RemoveSlowdown();
		
		target.RemoveAbilityAll(abilityName);
	}

	public function GetAmplification() : float
	{
		var multiplier : float;
		multiplier = 1 + (target.GetAbilityCount(abilityName) * damageAmplification);
		
		return multiplier;
	}

	private function RemoveSlowdown()
	{
		target.ResetAnimationSpeedMultiplier(speedMultiplierID);
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_CockatriceMutagen));
	}
}
// W3EE - End
*/