/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_VitalityDrain extends W3DamageOverTimeEffect
{
	
	default effectType 		= EET_VitalityDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	//Kolaris - Wraith Drain
	private var speedMultID : int;
	
	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		if( GetCreator().HasAbility( 'mon_nightwraith' ) )
		{
			speedMultID = target.SetAnimationSpeedMultiplier(0.8f, speedMultID);
			if( GetDayPart(GameTimeCreate()) == EDP_Midnight )
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_ELEMENTAL, 100, GetCreator(), this, 1.f, true, CPS_Undefined, false);
		}
		else if( GetCreator().HasAbility( 'mon_pesta' ) )
		{
			target.PlayEffect( 'critical_poison' );
			speedMultID = target.SetAnimationSpeedMultiplier(0.9f, speedMultID);
			if( (W3PlayerWitcher)target )
				target.GainStat(BCS_Toxicity, 1);
		}
		else if( GetCreator().HasAbility( 'mon_noonwraith_base' ) )
		{
			target.PlayEffect( 'critical_burning' );
			speedMultID = target.SetAnimationSpeedMultiplier(0.9f, speedMultID);
			if( GetDayPart(GameTimeCreate()) == EDP_Noon )
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_FIRE, 200, GetCreator(), this, 1.f, true, CPS_Undefined, false);
			else
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_FIRE, 100, GetCreator(), this, 1.f, true, CPS_Undefined, false);
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.ResetAnimationSpeedMultiplier(speedMultID);
		target.StopEffect( 'drain_energy' );
		target.StopEffect( 'critical_poison' );
		target.StopEffect( 'critical_burning' );
	}
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			PlayTargetFX();
		}
	}
}