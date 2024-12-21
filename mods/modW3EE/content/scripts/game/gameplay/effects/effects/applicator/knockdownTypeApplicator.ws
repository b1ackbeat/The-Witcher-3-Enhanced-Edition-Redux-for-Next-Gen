/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_KnockdownTypeApplicator extends W3ApplicatorEffect
{
	private saved var customEffectValue : SAbilityAttributeValue;		
	private saved var customDuration : float;							
	private saved var customAbilityName : name;							

	default effectType = EET_KnockdownTypeApplicator;
	default isNegative = true;
	default isPositive = false;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var aardPower	: float;
		var tags : array<name>;
		var i : int;
		var appliedType : EEffectType;
		var null : SAbilityAttributeValue;
		var npc : CNewNPC;
		var params : SCustomEffectParams;
		var min, max : SAbilityAttributeValue;
		// W3EE - Begin
		var sp : SAbilityAttributeValue;
		var effectArray : array<EEffectType>;
		var witcher : W3PlayerWitcher;
		var glyphwordAction : W3DamageAction;
		var aardReaction : W3DamageAction;
		// W3EE - End
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
		}
		
		
		// W3EE - Begin
		witcher = GetWitcherPlayer();
		if( effectValue.valueMultiplicative + effectValue.valueAdditive > 0 )
			sp = effectValue;
		else
		{
			if( isSignEffect && GetCreator() == witcher )
				sp = witcher.GetSignEntity(ST_Aard).GetTotalSignIntensity();
			else
				sp = creatorPowerStat;
		}
		
		//Kolaris - Aard
		npc = (CNewNPC)target;
		aardPower = RandRangeF(1.f, 0.5f);
		if( (W3Effect_NPCPoise)npc.GetBuff(EET_NPCPoise) )
			aardPower += 1.f - ((W3Effect_NPCPoise)npc.GetBuff(EET_NPCPoise)).GetPoisePercentage();
		aardPower *= sp.valueMultiplicative;
		//Kolaris - Whirlwind
		if( witcher.GetSignEntity(ST_Aard).IsAlternateCast() )
			aardPower *= 0.5f + (witcher.GetSkillLevel(S_Magic_s01) * 0.05f);
		if( isSignEffect && GetCreator() == witcher && witcher.GetPotionBuffLevel(EET_PetriPhiltre) == 3 )
		{
			aardPower += 0.5f;
		}
		aardPower *= (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FORCE));
		
		if( !(target.IsImmuneToBuff(EET_Knockdown) || target.HasAbility('mon_werewolf_base')) && (target.HasTag('WeakToAard') || target.HasAbility('WeakToAard') || ((W3Effect_NPCPoise)npc.GetBuff(EET_NPCPoise)).IsPoiseBroken()) )
		{
			appliedType = EET_HeavyKnockdown;
		}
		else
		if( npc && npc.HasShieldedAbility() )
		{
			if( aardPower >= 1.5f )
				appliedType = EET_Knockdown;
			else if( aardPower >= 1.f )
				appliedType = EET_LongStagger;
			else if( aardPower >= 0.5f )
				appliedType = EET_Stagger;
		}
		else
		if( target.IsHuge() )
		{
			if( aardPower >= 1.25f )
				appliedType = EET_LongStagger;
			else if( aardPower >= 0.75f )
				appliedType = EET_Stagger;
		}
		else
		{
			if( aardPower >= 2.f )
				appliedType = EET_HeavyKnockdown;
			else if( aardPower >= 1.5f )
				appliedType = EET_Knockdown;
			else if( aardPower >= 1.f )
				appliedType = EET_LongStagger;
			else if( aardPower >= 0.5f )
				appliedType = EET_Stagger;
		}
		// W3EE - End
		if( npc.IsFlying() || npc.GetUsedVehicle() )
			appliedType = EET_Knockdown;
			
		appliedType = ModifyHitSeverityBuff(target, appliedType);
		//Kolaris - Disintegration
		if( isSignEffect && GetCreator() == witcher && witcher.HasAbility('Glyphword 3 _Stats', true) && (target.CountEffectsOfType(EET_SlowdownFrost) > 1 || target.CountEffectsOfType(EET_Frozen) > 0) )
		{
			if( (appliedType == EET_HeavyKnockdown || appliedType == EET_Knockdown) && !npc.IsImmuneToInstantKill() )
			{
				npc.AddEffectDefault( EET_Frozen, witcher, "Glyphword 3", true );
				glyphwordAction = new W3DamageAction in theGame.damageMgr;
				glyphwordAction.Initialize( witcher, npc, this, "Glyphword 3", EHRT_None, CPS_Undefined, false, false, true, false );
				glyphwordAction.SetInstantKill();
				glyphwordAction.SetForceExplosionDismemberment();
				glyphwordAction.SetIgnoreInstantKillCooldown();
				theGame.damageMgr.ProcessAction( glyphwordAction );
				delete glyphwordAction;
			}
			else
			{
				glyphwordAction = new W3DamageAction in theGame.damageMgr;
				glyphwordAction.Initialize( witcher, npc, this, "Glyphword 3", EHRT_None, CPS_Undefined, false, false, true, false );
				glyphwordAction.AddDamage( theGame.params.DAMAGE_NAME_FROST, 1200 );
				theGame.damageMgr.ProcessAction( glyphwordAction );
				delete glyphwordAction;
			}
		}
		
		if( appliedType == EET_Undefined && !target.IsImmuneToBuff(EET_Stagger) )
		{
			aardReaction = new W3DamageAction in theGame.damageMgr;
			aardReaction.Initialize(GetCreator(), target, GetCreator(), "AardStun", EHRT_Reflect, CPS_Undefined, false, false, true, false);
			aardReaction.SetHitAnimationPlayType(EAHA_ForceYes);
			aardReaction.SetCanPlayHitParticle(false);
			aardReaction.SetCannotReturnDamage(true);
			aardReaction.SetSuppressHitSounds(true);
			
			theGame.damageMgr.ProcessAction(aardReaction);
			delete aardReaction;
		}
		else
		{
			params.effectType = appliedType;
			params.creator = GetCreator();
			params.sourceName = sourceName;
			params.isSignEffect = isSignEffect;
			params.customPowerStatValue = creatorPowerStat;
			params.customAbilityName = customAbilityName;
			params.duration = customDuration;
			params.effectValue = customEffectValue;	
			
			target.AddEffectCustom(params);
		}
		
		isActive = true;
		duration = 0;
	}
	
	public function Init(params : SEffectInitInfo)
	{
		customDuration = params.duration;
		customEffectValue = params.customEffectValue;
		customAbilityName = params.customAbilityName;
		
		super.Init(params);
	}
}