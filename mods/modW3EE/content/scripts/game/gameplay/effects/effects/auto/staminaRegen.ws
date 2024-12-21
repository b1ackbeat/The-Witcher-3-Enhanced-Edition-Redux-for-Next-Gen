/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_AutoStaminaRegen extends W3AutoRegenEffect
{
	private var regenModeIsCombat : bool;		
	private var cachedPlayer : CR4Player;
	private var wasLoaded : bool;
	
		default regenStat = CRS_Stamina;	
		default effectType = EET_AutoStaminaRegen;
		default regenModeIsCombat = true;		
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		regenModeIsCombat = true;
		
		if(isOnPlayer)
			cachedPlayer = (CR4Player)target;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		if(isOnPlayer)
			cachedPlayer = (CR4Player)target;
		wasLoaded = true;
	}
	
	event OnUpdate(dt : float)
	{
        if( wasLoaded )
        {
            SetEffectValue();
            wasLoaded = false;
        }
        
		if(isOnPlayer)
		{
			// W3EE - Begin
			/*if ( regenModeIsCombat != cachedPlayer.IsInCombat() )
			{
				regenModeIsCombat = !regenModeIsCombat;
				
				attributeName = RegenStatEnumToName(regenStat);
				
				SetEffectValue();
			}
			
			if ( cachedPlayer.IsInCombat() )
			{*/
				regenModeIsCombat = true;
				if ( thePlayer.IsGuarded() )
					effectValue = target.GetAttributeValue( 'staminaRegenGuarded' );
				else
				{
					attributeName = RegenStatEnumToName(regenStat);
					SetEffectValue();
				}
			//}
			// W3EE - End
		}

		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Stamina ) >= 1.0f )
		{
			target.StopStaminaRegen();
		}
	}
	
	protected function SetEffectValue()
	{
		effectValue = target.GetAttributeValue(attributeName);
		//Kolaris - Aggression Stamina
		if( !cachedPlayer )
			effectValue = effectValue * (1.f + Options().Aggression() * 0.5f);
		//Kolaris - Wild Hunt Stamina
		if( target.HasAbility('mon_wild_hunt_default') )
			effectValue += effectValue * 2.f;
		//Kolaris - Bastion
		if( ((W3PlayerWitcher)cachedPlayer).IsQuenActive(true) && (((W3PlayerWitcher)cachedPlayer).HasAbility('Glyphword 23 _Stats', true) || ((W3PlayerWitcher)cachedPlayer).HasAbility('Glyphword 24 _Stats', true)) )
			effectValue += effectValue * 2.f;
		//Kolaris - Mutation Rework
		if( FactsQuerySum("TaFtSComplete") > 0 && (((W3PlayerWitcher)cachedPlayer).GetEquippedMutationType() == EPMT_Mutation11 || ((W3PlayerWitcher)cachedPlayer).GetEquippedMutationType() == EPMT_Mutation12) )
			effectValue += effectValue * 0.2f;
		//Kolaris - Bleed
		if( target.HasAbility('BleedingStatDebuff') )
			effectValue = effectValue * MaxF(0.2f, (1.f - 0.05f * target.GetAbilityCount('BleedingStatDebuff')));
		//Kolaris - Injury Rework
		if( target.HasAbility('HeadInjuryEffect') || target.HasAbility('EnemyHeadInjuryAbility') )
			effectValue = effectValue * 0.8f;
		// W3EE - Begin
		if( target.CountEffectsOfType(EET_SlowdownFrost) > 0 )
			effectValue = effectValue * 0.5f;
		// W3EE - End
	}
}
