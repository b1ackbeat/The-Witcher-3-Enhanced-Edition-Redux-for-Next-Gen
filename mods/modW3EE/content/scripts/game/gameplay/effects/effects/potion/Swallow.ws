/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_Swallow extends W3Potion_VitalityRegen
{
	private var injuryTimer : float;
	
	default effectType = EET_Swallow;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		injuryTimer = 70 - 10 * GetBuffLevel();
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		((W3Effect_Bleeding)target.GetBuff(EET_Bleeding)).ResetStackTimer();
	}
	
	//Kolaris - Swallow
	public function OnTimeUpdated(deltaTime : float)
	{
		var level : int;
		
		if( isActive )
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				level = GetBuffLevel();	
				if(level < 3 || target.GetStatPercents(BCS_Vitality) < 0.99f )
					timeLeft -= deltaTime;
					
				if( timeLeft <= 0 )
					isActive = false;
			}
			
			OnUpdate(deltaTime);	
		}
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		if(((W3PlayerWitcher)target).GetInjuryManager().GetInjuryCount() > 0)
			injuryTimer -= dt;
		
		if( injuryTimer <= 0 )
		{
			target.GetInjuryManager().HealRandomInjury();
			injuryTimer = 70 - 10 * GetBuffLevel();
		}
	}
}