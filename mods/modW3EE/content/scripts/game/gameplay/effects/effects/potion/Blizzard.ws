/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


// W3EE - Begin
class W3Potion_Blizzard extends CBaseGameplayEffect
{
	private saved var slowdownCauserIds : array<int>;		
	private var slowdownFactor : float;
	private var currentSlowMoDuration : float;
	private var SLOW_MO_DURATION : float;
	private const var SLOW_MO_DURATION_EXT : float;
	private var currentAdrenaline : float;
	private var playerWitcher		: W3PlayerWitcher;

	default effectType = EET_Blizzard;
	default attributeName = 'slow_motion';
	default SLOW_MO_DURATION_EXT = 4.f;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		playerWitcher = (W3PlayerWitcher)target;
		if( !theGame.IsDialogOrCutscenePlaying() )
		{
			super.OnEffectAdded(customParams);	
			
			slowdownFactor = CalculateAttributeValue(effectValue);
			SLOW_MO_DURATION = 0.5f / slowdownFactor;
		}
		else playerWitcher.RemoveEffect(this);
	}
	
	public final function IsSlowMoActive() : bool
	{
		return slowdownCauserIds.Size();
	}
	
	public function KilledEnemy()
	{
		if(slowdownCauserIds.Size() == 0)
		{
			theGame.SetTimeScale( slowdownFactor, theGame.GetTimescaleSource(ETS_PotionBlizzard), theGame.GetTimescalePriority(ETS_PotionBlizzard) );
			
			if(GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3)
			{
				currentAdrenaline = playerWitcher.GetAdrenalineEffect().GetValue();
				slowdownCauserIds.PushBack(target.SetAnimationSpeedMultiplier( 1 + ( (1 / slowdownFactor - 1) * (currentAdrenaline / 100.f) )));
			}
			else
				slowdownCauserIds.PushBack(target.SetAnimationSpeedMultiplier( 1 ));
		}
		
		currentSlowMoDuration = 0.f;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		RemoveSlowMo();
	}
	
	public function OnTimeUpdated(dt : float)
	{
		if(slowdownCauserIds.Size() > 0)
		{
			super.OnTimeUpdated(dt / slowdownFactor);
			
			currentSlowMoDuration += dt / slowdownFactor;
			if(currentSlowMoDuration > SLOW_MO_DURATION)
				RemoveSlowMo();
		}
		else
		{
			super.OnTimeUpdated(dt);
		}
	}
	
	event OnEffectRemoved()
	{
		RemoveSlowMo();
		
		super.OnEffectRemoved();
	}
	
	public final function RemoveSlowMo()
	{
		var i : int;
		
		for(i=0; i<slowdownCauserIds.Size(); i+=1)
		{
			target.ResetAnimationSpeedMultiplier(slowdownCauserIds[i]);
		}
		
		FactsRemove("BlizzardCounter");
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_PotionBlizzard));
		
		slowdownCauserIds.Clear();
	}
}
// W3EE - End