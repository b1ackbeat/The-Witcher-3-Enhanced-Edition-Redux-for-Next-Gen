/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_AxiiGuardMe extends CBaseGameplayEffect
{
	//Kolaris - Lethargy
	private var lethargyLevel : int;
	private var witcher : W3PlayerWitcher;
	private var sp : SAbilityAttributeValue;
	private var targetPoise : W3Effect_NPCPoise;
	private var npc : CNewNPC;
	//Kolaris - Puppet
	private var scaredOfMonsters : bool;
	
	default effectType = EET_AxiiGuardMe;
	default resistStat = CDS_WillRes;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var bonusAbilityName : name;
		var skillLevel, i : int;
		
		super.OnEffectAdded(customParams);
		
		//Kolaris - Lethargy
		witcher = (W3PlayerWitcher)GetCreator();
		sp = witcher.GetTotalSignSpellPower(S_Magic_5);
		lethargyLevel = witcher.GetSkillLevel(S_Magic_s17);
		targetPoise = (W3Effect_NPCPoise)target.GetBuff(EET_NPCPoise);
		
		npc = (CNewNPC)target;
		
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		//Kolaris - Puppet
		if( !target.HasAbility('IsNotScaredOfMonsters') )
		{
			target.AddAbility('IsNotScaredOfMonsters');
			scaredOfMonsters = true;
		}
		
		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			npc.ResetAttitude( thePlayer );
		}
		
		if ( npc.HasTag('animal') || npc.IsHorse() )
		{
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
		}
		else
		{
			//Kolaris - posession
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
			//npc.SetBaseAttitudeGroup( witcher.GetBaseAttitudeGroup() );
			if( witcher.HasAbility('Glyphword 30 _Stats', true) )
				target.PlayEffect( 'demonic_possession' );
		}
		
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		
		// Lazarus - Magic_s05
		Combat().SetPuppetCount(1);
		// Lazarus - End
		
		//Kolaris - Puppet Overwrites Axii
		target.RemoveAllBuffsOfType(EET_Confusion);
		
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		for(i=0; i<skillLevel; i+=1)
			target.AddAbility(bonusAbilityName, true);
			
		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
	}
	
	//Kolaris - Puppet Fix
	event OnUpdate(deltaTime : float)
	{
		npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
	}
	
	event OnEffectRemoved()
	{
		var bonusAbilityName : name;
		//Kolaris - Lethargy
		var drainPercent : float;
		var slowdownEffect : SCustomEffectParams;
		//Kolaris - posession
		var possessionAction : W3DamageAction;
		
		super.OnEffectRemoved();
		
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
			((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		}
		
		//Kolaris - Puppet
		if( scaredOfMonsters )
		{
			target.RemoveAbility('IsNotScaredOfMonsters');
		}
		
		//Kolaris - Lethargy
		if( isSignEffect && lethargyLevel > 0 )
		{
			drainPercent = 0.1f * lethargyLevel * sp.valueMultiplicative;
			
			if( target.UsesEssence() )
			{
				drainPercent *= MinF(1.f, 5000.f / target.GetStatMax(BCS_Essence));
			}
			else
			{
				drainPercent *= MinF(1.f, 5000.f / target.GetStatMax(BCS_Vitality));
			}
			
			target.DrainStamina(ESAT_FixedValue, target.GetStatMax(BCS_Stamina) * drainPercent);
			targetPoise.ReducePoise(targetPoise.GetPoise() / targetPoise.GetPoisePercentage() * drainPercent, 5.f);
			
			slowdownEffect.effectType = EET_SlowdownAxii;
			slowdownEffect.creator = witcher;
			slowdownEffect.sourceName = "S_Magic_s17";
			slowdownEffect.duration = 20.f * drainPercent * witcher.GetPlayerSignDurationMod();
			slowdownEffect.effectValue.valueAdditive = 0.4f * drainPercent;
			target.AddEffectCustom(slowdownEffect);
		}
		
		// Lazarus - Magic_s05
		Combat().SetPuppetCount(-1);
		// Lazarus - End
		
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);		
		while(target.HasAbility(bonusAbilityName))
			target.RemoveAbility(bonusAbilityName);
			
		//Kolaris - posession
		if( isSignEffect && (witcher.HasAbility('Glyphword 28 _Stats', true) || witcher.HasAbility('Glyphword 29 _Stats', true) || witcher.HasAbility('Glyphword 30 _Stats', true) ) )
		{
			//npc.Kill('Possession', false, witcher);
			possessionAction = new W3DamageAction in theGame.damageMgr;
			possessionAction.Initialize( witcher, target, NULL, "Possession", EHRT_Heavy, CPS_Undefined, false, false, true, false );
			possessionAction.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, 10000.f * sp.valueMultiplicative * (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL)) );
			GCameraShake(0.5);
			possessionAction.SetForceExplosionDismemberment();
			theGame.damageMgr.ProcessAction( possessionAction );
			delete possessionAction;
			
			target.PlayEffect( 'demonic_possession' );
			target.StopEffect( 'demonic_possession' );
		}
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		if ( duration > 0 )
			duration = MaxF(8.f,duration);
	}
}