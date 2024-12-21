/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



abstract class W3Effect_Shrine extends CBaseGameplayEffect
{
	default isPositive = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	public function OnTimeUpdated( dt : float )
	{
		
		if( target == GetWitcherPlayer() && GetWitcherPlayer().CanUseSkill( S_Perk_14 ) )
		{
			if( isActive && pauseCounters.Size() == 0)
			{
				timeActive += dt;	
			}
			
			timeLeft = -1.f;
			return;
		}
		else if( timeLeft == -1.f )
		{
			timeLeft = GetInitialDurationAfterResists() - timeActive;
		}
		
		super.OnTimeUpdated( dt );
	}
}

class W3ShrineEffectParams extends W3BuffCustomParams
{
}
