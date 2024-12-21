/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class W3DamageManagerProcessor extends CObject 
{
	
	private var playerAttacker				: CR4Player;				
	private var playerVictim				: CR4Player;				
	private var action						: W3DamageAction;
	private var attackAction				: W3Action_Attack;			
	private var weaponId					: SItemUniqueId;			
	private var actorVictim 				: CActor;					
	private var actorAttacker				: CActor;					
	private var dm 							: CDefinitionsManagerAccessor;
	private var attackerMonsterCategory		: EMonsterCategory;
	private var victimMonsterCategory		: EMonsterCategory;
	private var victimCanBeHitByFists		: bool;
	
	// ImmersiveCam++
	private var ic : icControl;
	// ImmersiveCam--
	
	public function ProcessAction(act : W3DamageAction)
	{
		var wasAlive, validDamage, isFrozen, autoFinishersEnabled : bool;
		var focusDrain : float;
		var npc : CNewNPC;
		var buffs : array<EEffectType>;
		var arrStr : array<string>;
		var aerondight	: W3Effect_Aerondight;
		var trailFxName : name;
		
		// ImmersiveCam++
		ic = thePlayer.ic;
		// ImmersiveCam--
		
		wasAlive = act.victim.IsAlive();		
		npc = (CNewNPC)act.victim;
		
		
 		InitializeActionVars(act);
		
		
		if( ((CNewNPC)actorAttacker).IsHorse() && actorVictim.HasAbility('mon_werewolf_base'))
		{
			action.SetHitReactionType(EHRT_Light);
		}
		
		//Kolaris - Skellige Set
		if(attackAction && playerVictim && playerVictim.IsSetBonusActive(EISB_Skellige) && playerVictim.IsInCombatAction_Attack() && (Combat().IsUsingBattleMace() || Combat().IsUsingBattleAxe()))
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				action.SetHitAnimationPlayType(EAHA_ForceNo);
			}
 		}
		
		//Kolaris - Penetration
		if(attackAction && playerAttacker && attackAction.IsActionMelee() && (GetWitcherPlayer().HasAbility('Runeword 49 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 50 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 51 _Stats', true)))
		{
			action.SetProcessBuffsIfNoDamage(true);
			attackAction.SetApplyBuffsIfParried(true);
		}
		
    	//W3EE - Begin
		/*if(playerVictim && attackAction && attackAction.IsActionMelee() && !attackAction.CanBeParried() && attackAction.IsParried())
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				action.SetParryStagger();
				action.SetCanPlayHitParticle(false);
				action.SetProcessBuffsIfNoDamage(true);
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				
				if( !Combat().BlockingStaggerImmunityCheck(playerVictim, action, attackAction) )
					action.AddEffectInfo(EET_Stagger);
				
				action.RemoveBuffsByType(EET_Poison);
				action.RemoveBuffsByType(EET_Bleeding);
				action.RemoveBuffsByType(EET_LongStagger);
			}
 		}*/
		// W3EE - End		
 		
 		if(actorAttacker && playerVictim && ((W3PlayerWitcher)playerVictim) && GetWitcherPlayer().IsAnyQuenActive())
			FactsAdd("player_had_quen");
		
		
		ProcessPreHitModifications();

		
		ProcessActionQuest(act);
		
		
		isFrozen = (actorVictim && actorVictim.HasBuff(EET_Frozen));
		
		validDamage = ProcessActionDamage();
		
		if(wasAlive && !action.victim.IsAlive())
		{
			arrStr.PushBack(action.victim.GetDisplayName());
			if(npc && npc.WillBeUnconscious())
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_unconscious", , , arrStr), NULL, action.victim);
			}
			else if(action.attacker && action.attacker.GetDisplayName() != "")
			{
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_killed", , , arrStr), action.attacker, action.victim);
			}
			else
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_dies", , , arrStr), NULL, action.victim);
			}
		}
		
		if( wasAlive && action.DealsAnyDamage() )
		{
			((CActor) action.attacker).SignalGameplayEventParamFloat(  'CausesDamage', MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage ) );
		}
		
		ProcessActionReaction(isFrozen, wasAlive);
		
		
		if(action.DealsAnyDamage() || action.ProcessBuffsIfNoDamage())
			ProcessActionBuffs();
		
		
		if(theGame.CanLog() && !validDamage && action.GetEffectsCount() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessAction: action deals no damage and gives no buffs - investigate!");
			if ( theGame.CanLog() )
			{
				LogDMHits("*** Action has no valid damage and no valid buffs - investigate!", action);
			}
		}
		
		
		if( actorAttacker && wasAlive )
			actorAttacker.OnProcessActionPost(action);

		// W3EE - Begin
		/*
		if(actorVictim == GetWitcherPlayer() && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			if(actorAttacker && attackAction)
			{
				if(actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain'));
				else if(actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain'));
				else 
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			else
			{
				
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			
			
			if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
				focusDrain *= 1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16));
				
			thePlayer.DrainFocus(focusDrain);
		}
		*/
		//W3EE - End
		
		if(actorAttacker == GetWitcherPlayer() && actorVictim && !actorVictim.IsAlive() && (action.IsActionMelee() || action.GetBuffSourceName() == "Kill"))
		{
			autoFinishersEnabled = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
			
			//W3EE - Begin
			if ( !Combat().CheckAutoFinisher() )
				autoFinishersEnabled = false;
			//W3EE - End
			
			if(!autoFinishersEnabled || !thePlayer.GetFinisherVictim())
			{
				// W3EE - Begin
				/*
				if(thePlayer.HasAbility('Runeword 10 _Stats', true))
					GetWitcherPlayer().Runeword10Triggerred();
				if(thePlayer.HasAbility('Runeword 12 _Stats', true))
					GetWitcherPlayer().Runeword12Triggerred();
				*/
				// W3EE - End
			}
		}
		
		if(action.EndsQuen() && actorVictim)
		{
			actorVictim.FinishQuen(false);			
		}

		
		if(actorVictim == thePlayer && attackAction && attackAction.IsActionMelee() && (ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter') || ShouldProcessTutorial('TutorialParry')) )
		{
			if(attackAction.IsCountered())
			{
				theGame.GetTutorialSystem().IncreaseCounters();
			}
			else if(attackAction.IsParried())
			{
				theGame.GetTutorialSystem().IncreaseParries();
			}
			
			if(attackAction.CanBeDodged() && !attackAction.WasDodged())
			{
				GameplayFactsAdd("tut_failed_dodge", 1, 1);
				GameplayFactsAdd("tut_failed_roll", 1, 1);
			}
		}
		
		if( playerAttacker && npc && action.IsActionMelee() && action.DealtDamage() && IsRequiredAttitudeBetween( playerAttacker, npc, true ) && !npc.HasTag( 'AerondightIgnore' ) )
		{			
			if( playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
			{
				
				aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
				aerondight.IncreaseAerondightCharges( attackAction.GetAttackName() );
				
				
				if( aerondight.GetCurrentCount() == aerondight.GetMaxCount() )
				{
					switch( npc.GetBloodType() )
					{
						case BT_Red : 
							trailFxName = 'aerondight_blood_red';
							break;
							
						case BT_Yellow :
							trailFxName = 'aerondight_blood_yellow';
							break;
						
						case BT_Black : 
							trailFxName = 'aerondight_blood_black';
							break;
						
						case BT_Green :
							trailFxName = 'aerondight_blood_green';
							break;
					}
					
					playerAttacker.inv.GetItemEntityUnsafe( attackAction.GetWeaponId() ).PlayEffect( trailFxName );
				}
			}
		}
		
		// W3EE - Begin
		if( playerAttacker && attackAction )
		{
			if( playerAttacker.IsHeavyAttack( attackAction.GetAttackName() ) )
			{
				//Kolaris - Penetration
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 51 _Stats', true) )
					((CNewNPC)actorVictim).ModifyArmorValue(-0.05f);
				
				//Kolaris - Desolation
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
					((CNewNPC)actorVictim).SetDesolationStacks(true);
				
				//Kolaris - Bear Set
				/*if( ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Bear_2) && ((W3PlayerWitcher)playerAttacker).IsInCombatAction_SpecialAttackHeavy() && Combat().GetWolvenEffect().GetStacks() >= 10 )
				{
					if( actorVictim.IsImmuneToBuff(EET_Knockdown) || actorVictim.HasAbility('mon_werewolf_base') )
					{
						if( actorVictim.IsImmuneToBuff(EET_Stagger) )
							attackAction.SetHitAnimationPlayType(EAHA_ForceYes);
						else
							actorVictim.AddEffectDefault(EET_Stagger, playerAttacker, "WolfSetBonus", false);
					}
					else
						actorVictim.AddEffectDefault(EET_Knockdown, playerAttacker, "WolfSetBonus", false);
					
					((CNewNPC)actorVictim).ReduceNPCArmorPen(0.05f + 0.1f * ((W3PlayerWitcher)playerAttacker).GetSpecialAttackTimeRatio());
				}
				else*/
				if( playerAttacker.CanUseSkill(S_Sword_s04) && !attackAction.IsCountered() )
				{
					if( attackAction.IsParried() )
					{
						if( RandRange(100, 0) <= playerAttacker.GetSkillLevel(S_Sword_s04) * 4 )
							actorVictim.AddTimer('PlayActorHitAnimation', 0.05f, false);
					}
					else
					{
						if( RandRange(100, 0) <= playerAttacker.GetSkillLevel(S_Sword_s04) * 4 )
						{
							if( actorVictim.IsImmuneToBuff(EET_Stagger) )
								attackAction.SetHitAnimationPlayType(EAHA_ForceYes);
							else
								actorVictim.AddEffectDefault(EET_Stagger, playerAttacker, "StrengthTraining", false);
						}
					}
				}
			}
			//Kolaris - Penetration
			else if( playerAttacker.IsLightAttack( attackAction.GetAttackName() ) )
			{
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 51 _Stats', true) && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0 )
				{
					((CNewNPC)actorVictim).Runeword51ModifyArmorValue(true);
					((CNewNPC)actorVictim).AddTimer('ResetRuneword51ModifyArmorValue', 3.f, false,,,,false);
				}
				
				//Kolaris - Desolation
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
					((CNewNPC)actorVictim).SetDesolationStacks(false);
			}
		}
		
		if ( Blood().ShouldShowBlood( act, actorVictim, victimMonsterCategory, playerAttacker, attackAction, attackAction.IsCriticalHit() ) )
			Blood().ShowBlood( attackAction.GetWeaponId(), (CNewNPC)actorVictim, attackAction.IsActionRanged() );
		// W3EE - End
	}
	
	private final function InitializeActionVars(act : W3DamageAction)
	{
		var tmpName : name;
		var tmpBool	: bool;
	
		action 				= act;
		playerAttacker 		= (CR4Player)action.attacker;
		playerVictim		= (CR4Player)action.victim;
		attackAction 		= (W3Action_Attack)action;		
		actorVictim 		= (CActor)action.victim;
		actorAttacker		= (CActor)action.attacker;
		dm 					= theGame.GetDefinitionsManager();
		
		if(attackAction)
			weaponId 		= attackAction.GetWeaponId();
			
		theGame.GetMonsterParamsForActor(actorVictim, victimMonsterCategory, tmpName, tmpBool, tmpBool, victimCanBeHitByFists);
		
		if(actorAttacker)
			theGame.GetMonsterParamsForActor(actorAttacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	}
	
	
	
	
	
	
	private function ProcessActionQuest(act : W3DamageAction)
	{
		var victimTags, attackerTags : array<name>;
		
		victimTags = action.victim.GetTags();
		
		if(action.attacker)
			attackerTags = action.attacker.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_weapon_hit" );
		
		
		if ((CGameplayEntity) action.victim) action.victim.OnWeaponHit(act);
	}
	
	
	
	
	
	private function ProcessActionDamage() : bool
	{
		var directDmgIndex, size, i : int;
		var dmgInfos : array< SRawDamage >;
		var immortalityMode : EActorImmortalityMode;
		var dmgValue : float;
		var anyDamageProcessed, fallingRaffard : bool;
		var victimHealthPercBeforeHit, frozenAdditionalDamage : float;		
		var powerMod : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var canLog : bool;
		var immortalityChannels : array<EActorImmortalityChanel>;
		// W3EE - Begin
		var mainDamageIdx : int = 0;
		//var dotDampen : float;
		var combatHandler : W3EECombatHandler = Combat();
		var damageHandler : W3EEDamageHandler = Damage();
		var oilInfos : SOilInfo;
		/* var NPC : CNewNPC;
		 var npcStats : CCharacterStats;
		 var abili : array< name >;*/
		// mc = victimMonsterCategory;
		// W3EE - End
		
		canLog = theGame.CanLog();
		
		action.SetAllProcessedDamageAs(0);
		size = action.GetDTs( dmgInfos );
		action.SetDealtFireDamage(false);		
		
		oilInfos = combatHandler.InitializeOilInfo(playerAttacker);
		
		// W3EE - Begin
		/* NPC = (CNewNPC)actorVictim;
		 npcStats = NPC.GetCharacterStats();
		
		 npcStats.GetAbilities(abili,false);*/
		damageHandler.HookBaseDamage(actorAttacker, action, dmgInfos);
		damageHandler.NPCSteelMonsterDamage(actorAttacker, dmgInfos, victimMonsterCategory);
		damageHandler.SteelMonsterDamage(actorAttacker, dmgInfos, victimMonsterCategory, oilInfos);
		damageHandler.GeraltFistDamage(attackAction, dmgInfos, victimMonsterCategory);
		((W3Effect_SwordReachoftheDamned)playerAttacker.GetBuff(EET_SwordReachoftheDamned)).ExpandDamageTypes(dmgInfos, action, playerAttacker, actorVictim);
		// W3EE - End
		
		//Kolaris - Exhaustion
		damageHandler.ExhaustionExpandDamage(dmgInfos, action, playerAttacker, actorVictim);
		//Kolaris - Electrocution
		damageHandler.ElectrocutionExpandDamage(dmgInfos, action, playerAttacker, actorVictim);
		//Kolaris - Invocation
		damageHandler.ProcessInvocationDamage(dmgInfos, action, playerAttacker);
		
		if(!actorVictim || (!actorVictim.UsesVitality() && !actorVictim.UsesEssence()) )
		{
			
			for(i=0; i<size; i+=1)
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE && dmgInfos[i].dmgVal > 0)
				{
					action.victim.OnFireHit( (CGameplayEntity)action.causer );
					break;
				}
			}
			
			if ( !actorVictim.abilityManager )
				actorVictim.OnDeath(action);
			
			return false;
		}
		
		
		if(actorVictim.UsesVitality())
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Essence);
				
		
		ProcessDamageIncrease( dmgInfos );
					
		
		if ( canLog )
		{
			LogBeginning();
		}
		
		
		ProcessCriticalHitCheck();
		
		//Kolaris - Transmutation
		if( playerAttacker && (W3Petard)action.causer && !action.IsDoTDamage() && (playerAttacker.HasAbility('Runeword 13 _Stats', true) || playerAttacker.HasAbility('Runeword 14 _Stats', true) || playerAttacker.HasAbility('Runeword 15 _Stats', true)) )
			combatHandler.ProcessOilEffects(attackAction, oilInfos, dmgInfos, size, actorVictim, victimMonsterCategory, true);
		else
			combatHandler.ProcessOilEffects(attackAction, oilInfos, dmgInfos, size, actorVictim, victimMonsterCategory);
		
		//ProcessOnBeforeHitChecks();
		
		damageHandler.WeatherDamageMultiplier(dmgInfos, actorVictim);			
		
		powerMod = GetAttackersPowerMod();
		
		//Kolaris - Assassination
		if( playerAttacker && !playerVictim && action.IsActionMelee() && playerAttacker.HasAbility('Runeword 36 _Stats', true) && playerAttacker.HasAbility('Runeword 36 Ability') )
		{
			((W3PlayerWitcher)playerAttacker).RemoveAbilityAll('Runeword 36 Ability');
			((W3PlayerWitcher)playerAttacker).AddTimer('ManageAssassinationVisuals', 0.5f,,,,,true);
		}
		
		anyDamageProcessed = false;
		directDmgIndex = -1;
		witcher = GetWitcherPlayer();
		size = dmgInfos.Size();			
		for( i = 0; i < size; i += 1 )
		{
			
			if(dmgInfos[i].dmgVal == 0)
				continue;
			
			// W3EE - Begin
			/*if( !playerVictim && ((W3Effect_Burning)action.causer || (W3Effect_Bleeding)action.causer || (W3Effect_Poison)action.causer) )
			{
				if(actorVictim.UsesVitality())
					dotDampen = actorVictim.GetStatPercents(BCS_Vitality);
				else
					dotDampen = actorVictim.GetStatPercents(BCS_Essence);
				
				dmgInfos[i].dmgVal *= dotDampen;
			}*/
			
			if( dmgInfos[i].dmgVal > dmgInfos[mainDamageIdx].dmgVal )
				mainDamageIdx = i;
			// W3EE - End
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDmgIndex = i;
				continue;
			}
			
			// W3EE - Begin
			/*if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON && witcher == actorVictim && witcher.HasBuff(EET_GoldenOriole) && witcher.GetPotionBuffLevel(EET_GoldenOriole) == 3)
			{
				witcher.GainStat(BCS_Vitality, dmgInfos[i].dmgVal / 2);
				
				if ( canLog )
				{
					LogDMHits("", action);
					LogDMHits("*** Player absorbs poison damage from level 3 Golden Oriole potion: " + dmgInfos[i].dmgVal, action);
				}
				
				
				dmgInfos[i].dmgVal = 0;
				
				continue;
			}*/
			// W3EE - End
			
			if ( canLog )
			{
				LogDMHits("", action);
				LogDMHits("*** Incoming " + NoTrailZeros(dmgInfos[i].dmgVal) + " " + dmgInfos[i].dmgType + " damage", action);
				if(action.IsDoTDamage())
					LogDMHits("DoT's current dt = " + NoTrailZeros(action.GetDoTdt()) + ", estimated dps = " + NoTrailZeros(dmgInfos[i].dmgVal / action.GetDoTdt()), action);
			}
			
			
			anyDamageProcessed = true;
				
			
			dmgValue = MaxF(0, CalculateDamage(dmgInfos[i], powerMod));
		
			
			if( DamageHitsEssence(  dmgInfos[i].dmgType ) )		action.processedDmg.essenceDamage  += dmgValue;
			if( DamageHitsVitality( dmgInfos[i].dmgType ) )		action.processedDmg.vitalityDamage += dmgValue;
			if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
			if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
		}
		
		if(size == 0 && canLog)
		{
			LogDMHits("*** There is no incoming damage set (probably only buffs).", action);
		}
		
		if ( canLog )
		{
			LogDMHits("", action);
			LogDMHits("Processing block, parry, immortality, signs and other GLOBAL damage reductions...", action);		
		}
		
		// W3EE - Begin
		if(actorVictim)
		{
			damageHandler.ColdBloodDamage(action, actorVictim);
			
			//Kolaris - Manticore Set
			damageHandler.ManticoreSetStatusDamage(action, playerAttacker, actorVictim);
			
			//Kolaris - Cremation
			damageHandler.CremationDamageAmp(action, actorVictim);
			
			//Kolaris - Resolution
			damageHandler.ResolutionDamageMod(action, playerAttacker);
			
			//Kolaris - Destruction
			damageHandler.DestructionDamageMod(action, playerAttacker, actorVictim);
			
			damageHandler.Perk10DamageBoost(action);
			
			if( action.IsDoTDamage() )
				damageHandler.DOTModule(action);
			else
			{
				damageHandler.PlayerModule(action);
				damageHandler.NPCModule(action, actorAttacker, actorVictim);
			}
			
			combatHandler.CounterAndParry(playerVictim, actorAttacker, attackAction, action);
			combatHandler.ApplyDamageModifiers(action, actorVictim);
			
			actorVictim.ReduceDamage(action);
			
			combatHandler.WhirlBlockingModule(playerVictim, attackAction, action);
			//combatHandler.RendBlockingModule(playerVictim, attackAction, action);
		}
		if( !action.IsDoTDamage() )
		{
			if( ((CNewNPC)actorVictim).GetNPCCustomStat(dmgInfos[mainDamageIdx].dmgType) >= 1.f )
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				
			combatHandler.ApplyPlayerStaggerMechanics(playerVictim, attackAction, action);
			combatHandler.ApplyNPCStaggerMechanics(playerVictim, attackAction, action);
			
			combatHandler.ProcessSecondaryEffects(attackAction, actorAttacker);
			combatHandler.SpecialAttackHeavy(attackAction);
			combatHandler.LightBashEffect(attackAction, action, actorVictim);
			
			combatHandler.ApplyBleedStack(attackAction, oilInfos, actorAttacker, actorVictim);
			
			//Kolaris - Transfusion
			//combatHandler.SilverOilBurn(actorVictim, playerAttacker, action, oilInfos);
			//Kolaris - Purgation
			//combatHandler.EruptionEffect(action);
			
			//actorVictim.GetInjuryManager().ApplyCombatInjury(attackAction, action.GetDamageDealt() / action.GetOriginalDamageDealt(), oilInfos);
			
			//combatHandler.AdrenalineDrainHits(actorAttacker, actorVictim, attackAction, action, action.GetDamageDealt() / action.GetOriginalDamageDealt());
			
			combatHandler.CripplingShotEffects(action);
			
			combatHandler.DealInfusionDamage(action);
			
			combatHandler.BlockingStaggerImmunity(playerVictim, action, attackAction);
			
			//combatHandler.BreakEnemyBlock(attackAction, playerAttacker, actorVictim); //Kolaris - Sundering Strikes
			
			//combatHandler.WolfQuenBonusAttack(attackAction, dmgInfos); //Kolaris - Wolf Set
			
			combatHandler.PlayHitDamageEffects(attackAction, dmgInfos, playerAttacker, actorVictim);
			
			witcher.GetAdrenalineEffect().ManageAdrenaline(attackAction);
			
			combatHandler.ProcessAxiiLink(action);
			
			((W3Effect_SwordRendBlast)playerAttacker.GetBuff(EET_SwordRendBlast)).FireDischarge(attackAction, playerAttacker, actorVictim);
			
			//combatHandler.ObliterationRunewordEffectAttack(attackAction); //Kolaris - Remove Old Enchantments
			//combatHandler.ObliterationRunewordEffectBlock(attackAction); //Kolaris - Remove Old Enchantments
			combatHandler.BereavementRunewordAttack(attackAction);
			
			//combatHandler.Mutation7Rend(action, playerAttacker, actorVictim); //Kolaris - Mutation Rework
			
			combatHandler.UndyingDamageReduction(action, playerVictim);
			
			combatHandler.AffinityDamageReduction(action, playerVictim, attackerMonsterCategory); //Kolaris - Affinity
			
			combatHandler.ArchmutagenDamageBonus(action, playerAttacker, victimMonsterCategory); //Kolaris - Hunter Instinct
			
			combatHandler.EndurePainDamageReduction(action, playerVictim); //Kolaris - Endure Pain
			
			combatHandler.ProcessPuppetMorale(action, actorVictim, actorAttacker); //Kolaris - Puppet
			
			if( playerAttacker && action.DealsAnyDamage() )
			{
				if( action.IsCriticalHit() && action.IsActionMelee() )
				{
					((W3Effect_SwordCritVigor)playerAttacker.GetBuff(EET_SwordCritVigor)).SetReductionActive(true, playerAttacker);
					((W3Effect_SwordInjuryHeal)playerAttacker.GetBuff(EET_SwordInjuryHeal)).HealCombatInjury();
					((W3PlayerWitcher)playerAttacker).StartFrenzy();
					combatHandler.ObliterationRunewordExplosion(attackAction, true); //Kolaris - Obliteration
				}
				
				combatHandler.AfflictionPoisonChance(action, playerAttacker, actorVictim); //Kolaris - Affliction
				
				combatHandler.AssassinationDamageBoost(action, playerAttacker, actorVictim); //Kolaris - Assassination
				
				combatHandler.ProcessInvocationEffects(action, playerAttacker, actorVictim); //Kolaris - Invocation
				
				((W3Effect_SwordWraithbane)playerAttacker.GetBuff(EET_SwordWraithbane)).StopWraithHealthRegen(action, actorVictim, victimMonsterCategory);
				((W3Effect_SwordKillBuff)playerAttacker.GetBuff(EET_SwordKillBuff)).BuffAttackDamage(attackAction);
				((W3Effect_SwordRedTear)playerAttacker.GetBuff(EET_SwordRedTear)).BoostAttackDamage(action, playerAttacker);
				((W3Effect_SwordGas)playerAttacker.GetBuff(EET_SwordGas)).SpawnGasCloud(action, playerAttacker);
				((W3Effect_SwordDarkCurse)playerAttacker.GetBuff(EET_SwordDarkCurse)).ResetCurseAttackTimer();
				
				if( action.GetAppliedBleeding() && RandRange(100) <= 25 )
					((W3Effect_SwordBloodFrenzy)playerAttacker.GetBuff(EET_SwordBloodFrenzy)).SetFrenzyActive(true);
				
				((W3Decoction1_Effect)playerAttacker.GetBuff(EET_Decoction1)).ApplySpeedBuff(action);
				((W3Decoction1_Effect)playerAttacker.GetBuff(EET_Decoction1)).ApplyDamageBuff(action, actorVictim);
				
				((W3Decoction5_Effect)playerAttacker.GetBuff(EET_Decoction5)).ApplyDamageBuff(action, playerAttacker);
				
				combatHandler.Mutation2RestoreVigor(attackAction); //Kolaris - Mutation 2
			}
			
			((W3Effect_DimeritiumCharge)playerVictim.GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).DischargeArmor(action);
			((W3Effect_DimeritiumCharge)playerVictim.GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).IncreaseDimeritiumCharge(action);
			
			((W3Effect_WolfSetParry)playerVictim.GetBuff(EET_WolfSetParry, "BearSetBonus2")).IncrementAbility(action);
			
			((W3Decoction3_Effect)playerVictim.GetBuff(EET_Decoction3)).ReduceDamage(action);
			
			((W3Decoction10_Effect)playerVictim.GetBuff(EET_Decoction10)).ApplyPoison(action);
			
			//Kolaris - Nilfgaard Set
			if( playerAttacker && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Nilfgaard) && action.IsActionMelee() )
				combatHandler.ProcessNilfgaardAbility(attackAction, playerAttacker, actorVictim);
			
			
			((W3Effect_RunewordObliteration)playerAttacker.GetBuff(EET_RunewordObliteration)).ProcessObliterationAbility(action); //Kolaris - Obliteration
			
			((W3Effect_RunewordElectrocution)playerAttacker.GetBuff(EET_RunewordElectrocution)).ProcessElectrocutionAbility(action); //Kolaris - Electrocution
			
			combatHandler.Mutation8StaggerCheck(playerVictim, action.GetDamageDealt(), action); //Kolaris - Mutation 8
			
			combatHandler.DealPoiseDamage(actorVictim, action);
			combatHandler.ProcessPoisebreak(actorVictim, actorAttacker, action);
			
			combatHandler.ProcessEnemyAoESpecialAttacks(attackAction, actorAttacker); //Kolaris - Enemy Special Attacks
			
			actorVictim.GetInjuryManager().ApplyCombatInjury(attackAction, action.GetDamageDealt(), oilInfos, action.causer);
			
			if( playerVictim && actorAttacker && action.DealsAnyDamage() )
				((W3PlayerWitcher)playerVictim).StartRegenTimer(3.f);
				
			ModifyHitSeverityReactionFromDamage(action);
			FinisherStunInvulnerability();
			Experience().AwardCombatXP(attackAction, playerAttacker, playerVictim);
		}
		// W3EE - End
		
		
		if(directDmgIndex != -1)
		{
			anyDamageProcessed = true;
			
			
			immortalityChannels = actorVictim.GetImmortalityModeChannels(AIM_Invulnerable);
			fallingRaffard = false; //immortalityChannels.Size() == 1 && immortalityChannels.Contains(AIC_WhiteRaffardsPotion) && action.GetBuffSourceName() == "FallingDamage";
			
			if(action.GetIgnoreImmortalityMode() || (!actorVictim.IsImmortal() && !actorVictim.IsInvulnerable() && !actorVictim.IsKnockedUnconscious()) || fallingRaffard)
			{
				action.processedDmg.vitalityDamage += dmgInfos[directDmgIndex].dmgVal;
				action.processedDmg.essenceDamage  += dmgInfos[directDmgIndex].dmgVal;
			}
			else if( actorVictim.IsInvulnerable() )
			{
				
			}
			else if( actorVictim.IsImmortal() )
			{
				
				action.processedDmg.vitalityDamage += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Vitality)-1 );
				action.processedDmg.essenceDamage  += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Essence)-1 );
			}
		}
		
		
		if( actorVictim.HasAbility( 'OneShotImmune' ) )
		{
			if( action.processedDmg.vitalityDamage >= actorVictim.GetStatMax( BCS_Vitality ) )
			{
				action.processedDmg.vitalityDamage = actorVictim.GetStatMax( BCS_Vitality ) - 1;
			}
			else if( action.processedDmg.essenceDamage >= actorVictim.GetStatMax( BCS_Essence ) )
			{
				action.processedDmg.essenceDamage = actorVictim.GetStatMax( BCS_Essence ) - 1;
			}
		}
		
		//Kolaris - Full Moon
		if( playerVictim && ((W3PlayerWitcher)playerVictim).HasBuff(EET_FullMoon) && ((W3PlayerWitcher)playerVictim).GetPotionBuffLevel(EET_FullMoon) == 3 )
		{
			if( GetDayPart(GameTimeCreate()) == EDP_Midnight )
			{
				if( GetCurMoonState() == EMS_Full || GetCurMoonState() == EMS_Red )
					action.processedDmg.vitalityDamage = MinF(action.processedDmg.vitalityDamage, RoundMath(playerVictim.GetStatMax(BCS_Vitality) / 6));
				else
					action.processedDmg.vitalityDamage = MinF(action.processedDmg.vitalityDamage, RoundMath(playerVictim.GetStatMax(BCS_Vitality) / 5));
			}
		}
		
		
		if(action.HasDealtFireDamage())
			action.victim.OnFireHit( (CGameplayEntity)action.causer );
			
		
		ProcessInstantKill();
			
		
		ProcessActionDamage_DealDamage();
		
		
		if(playerAttacker && witcher)
			witcher.SetRecentlyCountered(false);
		
		
		if( attackAction && !attackAction.IsCountered() && playerVictim && attackAction.IsActionMelee())
			theGame.GetGamerProfile().ResetStat(ES_CounterattackChain);
		
		
		ProcessActionDamage_ReduceDurability( oilInfos );
		
		if(playerAttacker && actorVictim)
		{
			// W3EE - Begin
			if( playerAttacker.inv.ItemHasAnyActiveOilApplied(weaponId) && (!(attackAction.IsParried() || attackAction.IsCountered()) || ((attackAction.IsParried() || attackAction.IsCountered()) && action.DealsAnyDamage()) ) /*&& (!playerAttacker.CanUseSkill(S_Alchemy_s06) || (playerAttacker.GetSkillLevel(S_Alchemy_s06) < 3))*/ )
			// W3EE - End
			{			
				//Kolaris - Transfusion
				if( playerAttacker.CanUseSkill(S_Alchemy_s06) && ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks() > 0 )
				{
					if( RandRange(100, 0) > (playerAttacker.GetSkillLevel(S_Alchemy_s06) * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks()))
						playerAttacker.ReduceAllOilsAmmo( weaponId, playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) );
				}
				else
					playerAttacker.ReduceAllOilsAmmo( weaponId, playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) );
				
				if(ShouldProcessTutorial('TutorialOilAmmo'))
				{
					FactsAdd("tut_used_oil_in_combat");
				}
			}
			
			
			playerAttacker.inv.ReduceItemRepairObjectBonusCharge(weaponId);
		}
		
		//Kolaris - Vampire Set
		if( playerVictim.IsSetBonusActive(EISB_Vampire) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() )
			{
				actorAttacker.ApplyBleeding(RandRange(3,1), actorVictim, "Bleeding");
			}
		}
		if( playerVictim.IsSetBonusActive(EISB_Vampire_Alt_1) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() )
			{
				((W3PlayerWitcher)playerVictim).VampiricSetAbilityCharm(actorAttacker);
			}
		}
		//Kolaris - Skellige Set
		if( playerVictim.IsSetBonusActive(EISB_Skellige) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() )
			{
				if( RandF() < action.processedDmg.vitalityDamage / 2000 * (1.f - ((CNewNPC)actorAttacker).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FROST)) )
					actorAttacker.AddEffectDefault(EET_SlowdownFrost, playerVictim, "SkelligeSet", false);
			}
		}
		//Kolaris - Immolation
		if( ((W3PlayerWitcher)playerVictim).GetAdrenalineEffect().GetFullValue() >= 50.f && (((W3PlayerWitcher)playerVictim).HasAbility('Glyphword 7 _Stats', true) || ((W3PlayerWitcher)playerVictim).HasAbility('Glyphword 8 _Stats', true) || ((W3PlayerWitcher)playerVictim).HasAbility('Glyphword 9 _Stats', true)) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() && RandF() > ((CNewNPC)actorAttacker).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE) / 2 )
			{
				actorAttacker.AddEffectDefault(EET_Burning, playerVictim, "Immolation", false);
			}
		}
		
		// W3EE - Begin
		if( playerAttacker )
			((W3PlayerWitcher)playerAttacker).ManageRepairBuffs(attackAction, weaponId, playerAttacker.IsHeavyAttack(attackAction.GetAttackName()));
			
		if( playerVictim )
			((W3PlayerWitcher)playerVictim).ManageRepairBuffs(attackAction, weaponId, !actorAttacker.IsLightAttack(attackAction.GetAttackName()));
			
		if(actorVictim && actorAttacker && !action.GetCannotReturnDamage() && !action.IsDoTDamage() )
			ProcessActionReturnedDamage();	
		// W3EE - End
		
		return anyDamageProcessed;
	}
	
	private function FinisherStunInvulnerability()
	{
		if( playerVictim.isInFinisher )
			action.SetHitAnimationPlayType(EAHA_ForceNo);
	}
	
	private function ProcessInstantKill()
	{
		var instantKill, focus : float;

		if( !actorVictim || !actorAttacker || actorVictim.IsImmuneToInstantKill() )
		{
			return;
		}
		
		
		if( action.WasDodged() || ( attackAction && ( attackAction.IsParried() || attackAction.IsCountered() ) ) )
		{
			return;
		}
		
		//Kolaris - Instant Kill Fix
		if( actorAttacker.HasAbility( 'ForceInstantKill' ) && actorVictim != thePlayer && !actorAttacker.HasBuff(EET_AxiiGuardMe) && !actorVictim.HasBuff(EET_AxiiGuardMe) )
		{
			action.SetInstantKill();
		}
		
		//Kolaris - Desolation
		if( action.IsCriticalHit() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).IsPoiseBroken() && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
		{
			action.SetInstantKill();
			actorVictim.CreateFXEntityAndPlayEffect('mutation_2_explode', 'mutation_2_yrden');
		}
		
		// W3EE - Begin
		if( actorAttacker == thePlayer )
			if(playerAttacker && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
				return;
		// W3EE - End
	
		
		if( !action.GetInstantKill() )
		{
			
			instantKill = CalculateAttributeValue( actorAttacker.GetInventory().GetItemAttributeValue( weaponId, 'instant_kill_chance' ) );
			
			// W3EE - Begin
			/*if( ( action.IsActionMelee() || action.IsActionRanged() ) && playerAttacker && action.DealsAnyDamage() && thePlayer.CanUseSkill( S_Sword_s03 ) && !playerAttacker.inv.IsItemFists( weaponId ) )
			{
				focus = thePlayer.GetStat( BCS_Focus );
				
				if( focus >= 1 )
				{
					instantKill += focus * CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s03, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s03 );
				}
			}*/
			// W3EE - End
		}
		
		
		if( action.GetInstantKill() || ( RandF() < instantKill ) )
		{
			if( theGame.CanLog() )
			{
				if( action.GetInstantKill() )
				{
					instantKill = 1.f;
				}
				LogDMHits( "Instant kill!! (" + NoTrailZeros( instantKill * 100 ) + "% chance", action );
			}
		
			action.processedDmg.vitalityDamage += actorVictim.GetStat( BCS_Vitality );
			action.processedDmg.essenceDamage += actorVictim.GetStat( BCS_Essence );
			action.SetCriticalHit();	
			action.SetInstantKillFloater();			
			
			
			if( playerAttacker )
			{
				thePlayer.SetLastInstantKillTime( theGame.GetGameTime() );
				theSound.SoundEvent( 'cmb_play_deadly_hit' );
				theGame.SetTimeScale( 0.2, theGame.GetTimescaleSource( ETS_InstantKill ), theGame.GetTimescalePriority( ETS_InstantKill ), true, true );
				thePlayer.AddTimer( 'RemoveInstantKillSloMo', 0.2 );
			}			
		}
	}
	
	/*
	private function ProcessOnBeforeHitChecks()
	{
		var effectAbilityName, monsterBonusType : name;
		var effectType : EEffectType;
		var null, monsterBonusVal : SAbilityAttributeValue;
		var oilLevel, skillLevel, i : int;
		var baseChance, perOilLevelChance, chance : float;
		var buffs : array<name>;
		// W3EE - Begin
		var temp, resistPerc : float;
		// W3EE - End
		
		if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s12) && playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
		{
			
			monsterBonusType = MonsterCategoryToCriticalDamageBonus(victimMonsterCategory);
			monsterBonusVal = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
			
			if(monsterBonusVal == null)
			{
				monsterBonusType = MonsterCategoryToCriticalChanceBonus(victimMonsterCategory);
				monsterBonusVal = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
			} 
		
			if(monsterBonusVal != null)
			{
				
				oilLevel = (int)CalculateAttributeValue(playerAttacker.inv.GetItemAttributeValue(weaponId, 'level')) - 1;				
				skillLevel = playerAttacker.GetSkillLevel(S_Alchemy_s12);
				baseChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'skill_chance', false, true));
				perOilLevelChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'oil_level_chance', false, true));						
				chance = baseChance * skillLevel + perOilLevelChance * oilLevel;
				// W3EE - Begin
				resistPerc = ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_POISON);
				chance = MaxF(0, chance * (1 - resistPerc));
				// W3EE - End
				
				if(RandF() < chance)
				{
					
					dm.GetContainedAbilities(playerAttacker.GetSkillAbilityName(S_Alchemy_s12), buffs);
					for(i=0; i<buffs.Size(); i+=1)
					{
						EffectNameToType(buffs[i], effectType, effectAbilityName);
						action.AddEffectInfo(effectType, , , effectAbilityName);
					}
				}
			}
		}
	}
	*/
	
	private function ProcessCriticalHitCheck()
	{
		// W3EE - Begin
		var critChance, critDamageBonus, rendLoad : float;
		
		var oilCritChance : SAbilityAttributeValue;
		var i : int;
		var weaponId : SItemUniqueId;
		var oils : array<W3Effect_Oil>;
		var appliedOilName : name;
		// W3EE - End
		var	canLog, meleeOrRanged, redWolfSet, isLightAttack, isHeavyAttack, mutation2 : bool;
		var arrStr : array<string>;
		var samum : CBaseGameplayEffect;
		var signPower, min, max : SAbilityAttributeValue;
		var aerondight : W3Effect_Aerondight;
		
		meleeOrRanged = playerAttacker && attackAction && ( attackAction.IsActionMelee() || attackAction.IsActionRanged() );
		redWolfSet = false; //( W3Petard )action.causer && ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 );
		mutation2 = false; //( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) && action.IsActionWitcherSign(); //Kolaris - Mutation Rework
		
		if( meleeOrRanged || redWolfSet || mutation2 )
		{
			canLog = theGame.CanLog();
		
			
			if( mutation2 )
			{
				if( FactsQuerySum('debug_fact_critical_boy') > 0 )
				{
					critChance = 1.f;
				}
				else
				{
					signPower = action.GetPowerStatValue();
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_chance_factor', min, max);
					critChance = min.valueAdditive + signPower.valueMultiplicative * min.valueMultiplicative;
				}
			} 			
			else
			{
				if( attackAction )
				{
					
					if( SkillEnumToName(S_Sword_s02) == attackAction.GetAttackTypeName() )
					{			
						rendLoad = GetWitcherPlayer().GetSpecialAttackTimeRatio(); //Kolaris - Rend Rebalance
						critChance += (0.1f + 0.03f * playerAttacker.GetSkillLevel(S_Sword_s02)) * rendLoad; //Kolaris - Rend Rebalance
					}
					
					// W3EE - Begin
					//Kolaris - Counterattack
					if( playerAttacker.CanUseSkill(S_Sword_s11) && playerAttacker && GetWitcherPlayer().HasRecentlyCountered() || playerAttacker.IsCounterAttack(attackAction.GetAttackName()) )
					{
						critChance += playerAttacker.GetSkillLevel(S_Sword_s11) * 0.05f;
					}
					
					isLightAttack = playerAttacker.IsLightAttack( attackAction.GetAttackName() );
					isHeavyAttack = playerAttacker.IsHeavyAttack( attackAction.GetAttackName() );
					critChance += playerAttacker.GetCriticalHitChance(isLightAttack, isHeavyAttack, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer || (W3ThrowingKnife)action.causer);
					
					//Kolaris - Bear Set
					/*if( ((W3PlayerWitcher)playerAttacker).IsInCombatAction_SpecialAttackHeavy() && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Bear_2) && Combat().GetWolvenEffect().GetStacks() >= 10 )
						critChance += 1.0f;*/
					// W3EE - End
					
					if(action.GetIsHeadShot())
					{
						critChance += theGame.params.HEAD_SHOT_CRIT_CHANCE_BONUS;
						actorVictim.SignalGameplayEvent( 'Headshot' );
					}
					
					
					if ( actorVictim && actorVictim.IsAttackerAtBack(playerAttacker) )
					{
						//Kolaris - Assassination
						if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 35 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 36 _Stats', true) )
							critChance += 1.f;
						else
							critChance += theGame.params.BACK_ATTACK_CRIT_CHANCE_BONUS;
					}
						
					
					if( action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
					{
						aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
						
						if( aerondight && aerondight.IsFullyCharged() )
						{
							
							min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'crit_chance_bonus' );
							critChance += min.valueAdditive;
						}
					}
					//Kolaris - Coup de Grace
					if( playerAttacker && playerAttacker.CanUseSkill(S_Perk_11) )
					{
						critChance += actorVictim.GetInjuryManager().GetInjuryCount() * 0.03f;
					}
					
					//Kolaris - Razor Focus
					if( playerAttacker && playerAttacker.CanUseSkill(S_Sword_s20) )
					{
						critChance += 0.005f * playerAttacker.GetSkillLevel(S_Sword_s20) * playerAttacker.GetStat(BCS_Focus);
					}
						
					//Kolaris - Temerian Set
					if( playerAttacker && playerAttacker.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
					{
						critChance += 0.2f;
					}
					
					//Kolaris - Dol Blathanna Set
					if( playerAttacker && playerAttacker.IsSetBonusActive(EISB_Elven_1) && attackAction.IsActionRanged() )
					{
						critChance += 0.1f;
					}
					
					//Kolaris - Viper Set
					if( playerAttacker && playerAttacker.IsSetBonusActive(EISB_Viper2) && actorVictim.HasBuff(EET_Poison) )
					{
						critChance += 0.0025f * ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped(EIST_Viper) * ((W3Effect_Poison)actorVictim.GetBuff(EET_Poison)).GetStacks();
					}
						
					//Kolaris - Desolation
					if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 58 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
					{
						if( action.IsActionMelee() )
						{
							if( actorVictim.UsesEssence() )
								critChance += 0.25f * MaxF(playerAttacker.GetStatPercents(BCS_Vitality) - actorVictim.GetStatPercents(BCS_Essence), actorVictim.GetStatPercents(BCS_Essence) - playerAttacker.GetStatPercents(BCS_Vitality));
							else
								critChance += 0.25f * MaxF(playerAttacker.GetStatPercents(BCS_Vitality) - actorVictim.GetStatPercents(BCS_Vitality), actorVictim.GetStatPercents(BCS_Vitality) - playerAttacker.GetStatPercents(BCS_Vitality));
						}
						if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
						{
							critChance += ((CNewNPC)actorVictim).GetDesolationStacks(true) * 0.01f;
						}
					}
				}
				else
				{
					
					critChance += playerAttacker.GetCriticalHitChance(false, false, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer || (W3ThrowingKnife)action.causer );
				}
				
				//Kolaris - Bomb Rescale
				/*samum = actorVictim.GetBuff(EET_Blindness, 'petard');
				if(samum && samum.GetBuffLevel() == 3)
				{
					critChance += 1.0f;
				}*/
				
				//Kolaris - Poisebreak
				if( !action.IsDoTDamage() && ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).IsPoiseBroken() && ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_INJURY) >= 1.f && ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_BLEEDING) >= 1.f )
					critChance += 1.0f;
			}
			
			
			if ( canLog )
			{
				
				critDamageBonus = 1 + CalculateAttributeValue(actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker)));
				critDamageBonus += CalculateAttributeValue(actorAttacker.GetAttributeValue('critical_hit_chance_fast_style'));
				critDamageBonus = 100 * critDamageBonus;
				
				
				LogDMHits("", action);				
				LogDMHits("Trying critical hit (" + NoTrailZeros(critChance*100) + "% chance, dealing " + NoTrailZeros(critDamageBonus) + "% damage)...", action);
			}
			
			
			// W3EE - Begin
			if(playerAttacker && playerAttacker == GetWitcherPlayer() && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
			{
				critChance = 0;
			}
			
			if(playerVictim && playerVictim == GetWitcherPlayer() && playerVictim.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerVictim.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
			{
				critChance = 0;
			}
			// W3EE - End
			
			if(RandF() < critChance)
			{
				
				action.SetCriticalHit();
								
				if ( canLog )
				{
					LogDMHits("********************", action);
					LogDMHits("*** CRITICAL HIT ***", action);
					LogDMHits("********************", action);				
				}
				
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(theGame.witcherLog.COLOR_GOLD_BEGIN + GetLocStringByKeyExtWithParams("hud_combat_log_critical_hit",,,arrStr) + theGame.witcherLog.COLOR_GOLD_END, action.attacker, NULL);
			}
			else if ( canLog )
			{
				LogDMHits("... nope", action);
			}
		}	
	}
	
	
	private function LogBeginning()
	{
		var logStr : string;
		
		if ( !theGame.CanLog() )
		{
			return;
		}
		
		LogDMHits("-----------------------------------------------------------------------------------", action);		
		logStr = "Beginning hit processing from <<" + action.attacker + ">> to <<" + action.victim + ">> via <<" + action.causer + ">>";
		if(attackAction)
		{
			logStr += " using AttackType <<" + attackAction.GetAttackTypeName() + ">>";		
		}
		logStr += ":";
		LogDMHits(logStr, action);
		LogDMHits("", action);
		LogDMHits("Target stats before damage dealt are:", action);
		if(actorVictim)
		{
			if( actorVictim.UsesVitality() )
				LogDMHits("Vitality = " + NoTrailZeros(actorVictim.GetStat(BCS_Vitality)), action);
			if( actorVictim.UsesEssence() )
				LogDMHits("Essence = " + NoTrailZeros(actorVictim.GetStat(BCS_Essence)), action);
			if( actorVictim.GetStatMax(BCS_Stamina) > 0)
				LogDMHits("Stamina = " + NoTrailZeros(actorVictim.GetStat(BCS_Stamina, true)), action);
			if( actorVictim.GetStatMax(BCS_Morale) > 0)
				LogDMHits("Morale = " + NoTrailZeros(actorVictim.GetStat(BCS_Morale)), action);
		}
		else
		{
			LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
		}
	}
	
	
	private function ProcessDamageIncrease(out dmgInfos : array< SRawDamage >)
	{
		var difficultyDamageMultiplier, rendBonus, overheal, rendRatio, focusCost : float;
		var i, bonusCount : int;
		var frozenBuff : W3Effect_Frozen;
		var frozenDmgInfo : SRawDamage;
		// W3EE - Begin
		//var hadFrostDamage : bool;
		var forceDamageIdx : int;
		var bonusDamagePercents : float;
		//var mpac : CMovingPhysicalAgentComponent;
		var rendBonusPerPoint, staminaRendBonus, perk20Bonus : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var damageVal, damageBonus, min, max : SAbilityAttributeValue;		
		var npcVictim : CNewNPC;
		var sword : SItemUniqueId;
		//var actionFreeze : W3DamageAction;
		var damageBonusStack : float = 0.f;
		var adrenalineEffect : W3Effect_CombatAdrenaline;
		//Kolaris - Cat Set
		var lynxEffect : W3Effect_SwordDancing;
		// var aerondight	: W3Effect_Aerondight;
		//Kolaris - Netflix Set
		//var aardDamage : SRawDamage;
		//var yrdens : array<W3YrdenEntity>;
		//var j, levelDiff : int;
		//var aardDamageF : float;
		//var spellPower, spellPowerAard, spellPowerYrden : float;
		//var spNetflix : SAbilityAttributeValue;
		
		
		if(playerAttacker && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
			damageBonusStack -= 0.2f;
		
		if(playerAttacker && playerAttacker.IsInCombatAction_SpecialAttack() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio(); //Kolaris - Rend Rebalance
			bonusDamagePercents = (0.5f + 0.1f * playerAttacker.GetSkillLevel(S_Sword_s02)) * rendRatio; //Kolaris - Rend Rebalance
			
			//Kolaris - Resolution
			if( rendRatio > 0.75f && witcherAttacker.HasAbility('Runeword 45 _Stats', true) )
			{
				bonusDamagePercents += witcherAttacker.GetStat(BCS_Focus) / 2;
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );
			}
			
			damageBonusStack += bonusDamagePercents * 1.f;
		}
		/*
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * difficultyDamageMultiplier;
			}
		}
		*/
		
		
		
		if(actorVictim && playerAttacker && !action.IsDoTDamage() && (actorVictim.HasBuff(EET_Frozen) || actorVictim.HasBuff(EET_SlowdownFrost)) && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer || action.DealsPhysicalOrSilverDamage()) )
		{
			damageBonusStack += 0.1f;
			/*action.SetWasFrozen();
			
			if( !( ( W3WhiteFrost )action.causer ) )
			{				
				damageBonusStack += 0.1f;
			}
			
			actorVictim.RemoveAllBuffsOfType(EET_Frozen);
			
			
			if( !( ( W3WhiteFrost )action.causer ) )
			{
				actionFreeze = new W3DamageAction in theGame;
				actionFreeze.Initialize( actorAttacker, actorVictim, action.causer, action.GetBuffSourceName(), EHRT_None, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
				actionFreeze.SetCannotReturnDamage( true );
				actionFreeze.SetCanPlayHitParticle( false );
				actionFreeze.SetHitAnimationPlayType( EAHA_ForceNo );
				actionFreeze.SetWasFrozen();		
				actionFreeze.AddDamage( theGame.params.DAMAGE_NAME_FROST, frozenDmgInfo.dmgVal );
				theGame.damageMgr.ProcessAction( actionFreeze );
				delete actionFreeze;
			}
			*/
		}
		
		//Kolaris - Netflix Set
		/*if(actorVictim && playerAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_Netflix_2 ) && !action.IsDoTDamage() && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer)) 
		{	
			yrdens = GetWitcherPlayer().yrdenEntities;
			
			if(yrdens.Size() > 0)
			{
				spellPowerAard = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('spell_power_aard'));
				spellPowerYrden = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('spell_power_yrden'));				
				spellPower = ClampF(1 + spellPowerAard + spellPowerYrden + CalculateAttributeValue(GetWitcherPlayer().GetPowerStatValue(CPS_SpellPower)), 1, 3); 				
			
				for(i=0; i<yrdens.Size(); i+=1)
				{
					for(j=0; j<yrdens[i].validTargetsInArea.Size(); j+=1)
					{			
						if(yrdens[i].validTargetsInArea[j] == actorVictim )
						{
							levelDiff = playerAttacker.GetLevel() - actorVictim.GetLevel();
							aardDamage.dmgType = theGame.params.DAMAGE_NAME_DIRECT;	
							if( GetWitcherPlayer().CanUseSkill(S_Magic_s06) )
								aardDamageF = (RandRangeF(375.0, 325.0) + (playerAttacker.GetLevel() * 1.8f) + (GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * 100) ) * spellPower;
							else
								aardDamageF = (RandRangeF(375.0, 325.0) + (playerAttacker.GetLevel() * 1.8f) ) * spellPower;
							
							if( actorVictim.GetCharacterStats().HasAbilityWithTag('Boss') || (W3MonsterHuntNPC)actorVictim || (levelDiff < 0 && Abs(levelDiff) > theGame.params.LEVEL_DIFF_HIGH))
							{
								aardDamage.dmgVal = aardDamageF * 0.75f;
							}					
							else
							{
								aardDamage.dmgVal = aardDamageF;
							}
							
							spNetflix = action.GetPowerStatValue();
							aardDamage.dmgVal += 3 * actorVictim.GetHealth() * ( 0.01 + 0.03 * LogF( spNetflix.valueMultiplicative ) );
							dmgInfos.PushBack(aardDamage);
						}
					}
				}
			}
		}*/
		
		/*
		if(actorVictim)
		{
			mpac = (CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent();
						
			if(mpac && mpac.IsDiving())
			{
				mpac = (CMovingPhysicalAgentComponent)actorAttacker.GetMovingAgentComponent();	
				
				if(mpac && mpac.IsDiving())
				{
					action.SetUnderwaterDisplayDamageHack();
				
					if(playerAttacker && attackAction && attackAction.IsActionRanged())
					{
						for(i=0; i<dmgInfos.Size(); i+=1)
						{
							if(FactsQuerySum("NewGamePlus"))
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP);
							}
							else
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS);
							}
						}
					}
				}
			}
		}
		
		if(playerAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			
			
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
			
			
			rendLoad = MinF(rendRatio * playerAttacker.GetStatMax(BCS_Focus), playerAttacker.GetStat(BCS_Focus));
			
			
			if(rendLoad >= 1)
			{
				rendBonusPerPoint = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, true);
				rendBonus = FloorF(rendLoad) * rendBonusPerPoint.valueMultiplicative;
				
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= (1 + rendBonus);
				}
			}
			
			
			staminaRendBonus = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true);
			
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal *= (1 + rendRatio * staminaRendBonus.valueMultiplicative);
			}
		}	
		
		if ( actorAttacker != thePlayer && action.IsActionRanged() && (int)CalculateAttributeValue(actorAttacker.GetAttributeValue('level',,true)) > 31)
		{
			damageVal = actorAttacker.GetAttributeValue('light_attack_damage_vitality',,true);
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal + CalculateAttributeValue(damageVal) / 2;
			}
		}
		
		
		if ( actorVictim && playerAttacker && attackAction && action.IsActionMelee() && thePlayer.HasAbility('Runeword 4 _Stats', true) && !attackAction.WasDodged() )
		{
			overheal = thePlayer.abilityManager.GetOverhealBonus() / thePlayer.GetStatMax(BCS_Vitality);
		
			if(overheal > 0.005f)
			{
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= 1.0f + overheal;
				}
			
				thePlayer.abilityManager.ResetOverhealBonus();
				
				
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );				
			}
		}
		*/
		
		//Kolaris - Cat Set
		if( playerAttacker && playerAttacker.HasBuff( EET_SwordDancing ) && !attackAction.WasDodged() ) 
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() )
			{
				lynxEffect = (W3Effect_SwordDancing)playerAttacker.GetBuff(EET_SwordDancing);
				if( lynxEffect.GetSourceName() == "HeavyAttack" && playerAttacker.IsLightAttack(attackAction.GetAttackName()) || lynxEffect.GetSourceName() == "LightAttack" && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
				{
					//damageBonus = playerAttacker.GetAttributeValue('lynx_dmg_boost');
					
					//damageBonus.valueAdditive *= ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped( EIST_Lynx );
					
					damageBonusStack += 0.15f;
				}
			}
		}
		
		//Kolaris - Cat Set
		/*if( playerAttacker && attackAction.IsActionMelee() && actorVictim.IsAttackerAtBack( playerAttacker ) && !actorVictim.HasAbility( 'CannotBeAttackedFromBehind' ) && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive( EISB_Lynx_2 ) && !attackAction.WasDodged() && ( playerAttacker.inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || playerAttacker.inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) )
		{
			adrenalineEffect = (W3Effect_CombatAdrenaline)playerAttacker.GetBuff(EET_CombatAdr);
			
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_adrenaline_cost', min, max );
			focusCost = min.valueAdditive * 100;
			
			if( !attackAction.IsParried() && !attackAction.IsCountered() && adrenalineEffect.GetDisplayCount() >= focusCost && !( thePlayer.IsInCombatAction() && ( thePlayer.GetCombatAction() == EBAT_SpecialAttack_Light || thePlayer.GetCombatAction() == EBAT_SpecialAttack_Heavy ) ) )
			{
				adrenalineEffect.RemoveAdrenaline(focusCost);
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_dmg_boost', min, max );
				
				damageBonusStack += min.valueAdditive;
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_stun_duration', min, max );
				attackAction.AddEffectInfo( EET_Confusion, min.valueAdditive );
				playerAttacker.SoundEvent( "ep2_setskill_lynx_activate" );
			}
		}*/
		
		/*
		if ( playerAttacker && action.IsActionRanged() && ((W3Petard)action.causer) && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
		{
			perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
			}
		}
		
		if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
		{
			sword = playerAttacker.inv.GetCurrentlyHeldSword();
			
			damageVal.valueBase = 0;
			damageVal.valueMultiplicative = 0;
			damageVal.valueAdditive = 0;
		
			if( playerAttacker.inv.GetItemCategory(sword) == 'steelsword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
			}
			else if( playerAttacker.inv.GetItemCategory(sword) == 'silversword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
			}
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);				
			
			damageVal.valueBase *= CalculateAttributeValue(min);
			
			if( action.IsDoTDamage() )
			{
				damageVal.valueBase *= action.GetDoTdt();
			}
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal += damageVal.valueBase;
			}
		}
		*/
		// W3EE - End
		
		
		npcVictim = (CNewNPC) actorVictim;
		//Kolaris ++ Mutation Rework
		/*if( playerAttacker && npcVictim && attackAction && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) && ( victimMonsterCategory != MC_Human || npcVictim.IsImmuneToMutation8Finisher() ) && attackAction.GetWeaponId() == GetWitcherPlayer().GetHeldSword() )
		{
			dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
			
			damageBonusStack += min.valueMultiplicative;
		}*/
		//Kolaris -- Mutation Rework
		if( damageBonusStack )
		{
			for(i=0; i<dmgInfos.Size(); i+=1)
				dmgInfos[i].dmgVal *= 1.f + damageBonusStack;
		}
		
		// W3EE - Begin
		/*
		if( playerAttacker && actorVictim && attackAction && action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
		{	
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );	
			
			if( aerondight )
			{
				min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'dmg_bonus' );
				bonusCount = aerondight.GetCurrentCount();
			
				if( bonusCount > 0 )
				{
					min.valueMultiplicative *= bonusCount;
					
					for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
					{
						dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
					}
				}				
			}
		}	
		*/
		//Kolaris - Enervation
		if( actorAttacker.HasBuff(EET_GlyphDebuff) && GetWitcherPlayer().CanUseSkill(S_Magic_s11) )
		{
			if( GetWitcherPlayer().HasAbility('Glyphword 18 _Stats', true) )
				dmgInfos[i].dmgVal *= 1.f - 0.06f * GetWitcherPlayer().GetSkillLevel(S_Magic_s11);
			else
				dmgInfos[i].dmgVal *= 1.f - 0.03f * GetWitcherPlayer().GetSkillLevel(S_Magic_s11);
		}
		// W3EE - End
	}
	
	
	private function ProcessActionReturnedDamage()
	{
		var witcher 			: W3PlayerWitcher;
		var quen 				: W3QuenEntity;
		var params 				: SCustomEffectParams;
		var processFireShield, canBeParried, canBeDodged, wasParried, wasDodged, returned : bool;
		var g5Chance			: SAbilityAttributeValue;
		var dist, checkDist		: float;
		
		
		if((W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !action.IsDoTDamage() && action.IsActionMelee() && (attackerMonsterCategory == MC_Necrophage || attackerMonsterCategory == MC_Vampire) && actorVictim.HasBuff(EET_BlackBlood))
		{
			returned = ProcessActionBlackBloodReturnedDamage();		
		}
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'Thorns' ) )
		{
			returned = ProcessActionThornDamage() || returned;
		}
		
		//Kolaris - Remove Old Enchantments
		/*if(actorVictim.HasAbility( 'Glyphword 5 _Stats', true))
		{			
			if( GetAttitudeBetween(actorAttacker, actorVictim) == AIA_Hostile)
			{
				if( !action.IsDoTDamage() )
				{
					g5Chance = actorVictim.GetAttributeValue('glyphword5_chance');
					
					if(RandF() <= g5Chance.valueAdditive)
					{
						canBeParried = attackAction.CanBeParried();
						canBeDodged = attackAction.CanBeDodged();
						wasParried = attackAction.IsParried() || attackAction.IsCountered();
						wasDodged = attackAction.WasDodged();
				
						if(!action.IsActionMelee() || (!canBeParried && canBeDodged && !wasDodged) || (canBeParried && !wasParried && !canBeDodged) || (canBeParried && canBeDodged && !wasDodged && !wasParried))
						{
							returned = ProcessActionReflectDamage() || returned;
						}
					}	
				}
			}			
			
		}*/
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'FireShield' ) )
		{
			witcher = GetWitcherPlayer();			
			processFireShield = true;			
			if(playerAttacker == witcher)
			{
				quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
				if(quen && quen.IsAnyQuenActive())
				{
					processFireShield = false;
				}
			}
			
			if(processFireShield)
			{
				params.effectType = EET_Burning;
				params.creator = actorVictim;
				params.sourceName = actorVictim.GetName();
				
				params.effectValue.valueMultiplicative = 0.01;
				actorAttacker.AddEffectCustom(params);
				returned = true;
			}
		}
		
		
		if(actorAttacker.UsesEssence())
		{
			returned = ProcessSilverStudsReturnedDamage() || returned;
		}
			
		//Kolaris ++ Mutation Rework
		/*if( (W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !action.IsDoTDamage() && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation4 ) )
		{
			
			dist = VecDistance( actorAttacker.GetWorldPosition(), actorVictim.GetWorldPosition() );
			checkDist = 3.f;
			if( actorAttacker.IsHuge() )
			{
				checkDist += 3.f;
			}
 
			if( dist <= checkDist )
			{
				returned = GetWitcherPlayer().ProcessActionMutation4ReturnedDamage( action.processedDmg.vitalityDamage, actorAttacker, EAHA_ForceYes, action ) || returned;
			}
		}*/
		//Kolaris -- Mutation Rework
		action.SetWasDamageReturnedToAttacker( returned );
	}
	
	private function ProcessSilverStudsReturnedDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage : float;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetAttributeValue('returned_silver_damage'));
		
		if(returnedDamage <= 0)
			return false;
		
		// W3EE - Begin
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "SilverStuds", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );	
		damageAction.SetPointResistIgnored( true );
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
		
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		// W3EE - End
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	
	private function ProcessActionBlackBloodReturnedDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var bb : W3Potion_BlackBlood;
		var potionLevel : int;
		var returnedDamage : float;
		var attackerPoise : W3Effect_NPCPoise;
	
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		bb = (W3Potion_BlackBlood)actorVictim.GetBuff(EET_BlackBlood);
		potionLevel = bb.GetBuffLevel();
		
		
		// W3EE - Begin
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, bb, "BlackBlood", EHRT_None, CPS_Undefined, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );
		returnedAction.SetPointResistIgnored( true );		
		
		returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
		returnedAction.AddEffectInfo(EET_Stagger);
		
		returnedDamage = bb.GetReturnDamageValue(action.processedDmg.vitalityDamage);
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		//Kolaris - Black Blood
		if( returnedDamage > 0)
		{
			attackerPoise = (W3Effect_NPCPoise)actorAttacker.GetBuff(EET_NPCPoise);
			attackerPoise.ReducePoise(returnedDamage / 50.f, 4.f);
			returnedAction.AddDamage(theGame.params.DAMAGE_NAME_MORALE, returnedDamage / 100.f);
			if( potionLevel == 3 )
				actorAttacker.ApplyPoisoning(CeilF(returnedDamage / 500.f), action.victim, "BlackBlood", true);
		}
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		// W3EE - End
		
		return true;
	}
	
	
	private function ProcessActionReflectDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal, min, max : SAbilityAttributeValue;
		var potionLevel : int;
		var returnedDamage : float;
		var template : CEntityTemplate;
		var fxEnt : CEntity;
		var boneIndex: int;
		var b : bool;
		var component : CComponent;
		
		
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		// W3EE - Begin
		returnedDamage = CalculateAttributeValue(actorVictim.GetTotalArmor());
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 5 _Stats', 'damage_mult', min, max);
		
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, NULL, "Glyphword5", EHRT_None, CPS_Undefined, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );
		returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
		returnedAction.SetHitReactionType(EHRT_Reflect);
		
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage * min.valueMultiplicative);
		// W3EE - End

		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		
		template = (CEntityTemplate)LoadResource('glyphword_5');
		
		
		
		
		
		
		component = action.attacker.GetComponent('torso3effect');
		if(component)
			thePlayer.PlayEffect('reflection_damge', component);
		else
			thePlayer.PlayEffect('reflection_damge', action.attacker);
		action.attacker.PlayEffect('yrden_shock');
		
		return true;
	}
	
	
	private function ProcessActionThornDamage() : bool
	{
		var damageAction 		: W3DamageAction;
		var damage				: float;
		
		damageAction	= new W3DamageAction in this;
		damageAction.Initialize( action.victim, action.attacker, NULL, "Thorns", EHRT_Light, CPS_AttackPower, true, false, false, false );
		
		// W3EE - Begin
		damage = ((CNewNPC)actorAttacker).GetScaledDamage() * RandRangeF(0.35f, 0.15f);
		damageAction.SetCannotReturnDamage(true);
		damageAction.SetPointResistIgnored(true);
		damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
		actorAttacker.ApplyBleeding(RandRange(4,1), actorVictim, "Bleeding");
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_PIERCING, damage);
		// W3EE - End
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	private function GetAttackersPowerMod() : SAbilityAttributeValue
	{		
		var powerMod, criticalDamageBonus, min, max, critReduction, sp, blockCrush : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var totalBonus : float;
		// W3EE - Begin
		var difficultyDamageMultiplier, overheal, rendRatio, armorPiercing : float;
		var staminaRendBonus : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		// W3EE - End
		
		powerMod = action.GetPowerStatValue();
		if ( powerMod.valueAdditive == 0 && powerMod.valueBase == 0 && powerMod.valueMultiplicative == 0 && theGame.CanLog() )
			LogDMHits("Attacker has power stat of 0!", action);
		
		// W3EE - Begin
		/*
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			powerMod.valueMultiplicative -= 0.833;
		
		if ( playerAttacker && (W3AardProjectile)action.causer )
			powerMod.valueMultiplicative = 1;
		*/
		
		if( playerAttacker && action.IsActionMelee() )
		{
			if( playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
				powerMod.valueMultiplicative += 0.25f;
			/*else
			if( playerAttacker.IsLightAttack(attackAction.GetAttackName()) )
				powerMod.valueMultiplicative += 0.2f;*/
		}
		
		/*
		if ( playerAttacker && (W3IgniProjectile)action.causer )
			powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.IGNI_SPELL_POWER_MILT;
		*/
		
		if(action.IsCriticalHit())
		{
			//Kolaris ++ Mutation Rework
			/*if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) )
			{
				sp = action.GetPowerStatValue();
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_damage_factor', min, max);				
				criticalDamageBonus.valueAdditive = sp.valueMultiplicative * min.valueMultiplicative;
			}
			else 
			{*///Kolaris -- Mutation Rework
				criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
				
				if(attackAction && playerAttacker)
				{
					if(playerAttacker.IsLightAttack(attackAction.GetAttackName()))
						criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
					if(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s08))
						criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s08);
					// W3EE - Begin
					//else if (!playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s17))
						//criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s17);
					// W3EE - End
					//Kolaris - Temerian Set
					if(((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Temerian))
						criticalDamageBonus.valueAdditive += ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL) / 2.f;
					//Kolaris - Assassination
					if( action.IsActionMelee() && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 36 _Stats', true) && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 36 Ability') )
					{
						criticalDamageBonus.valueAdditive += 2.f;
						actorVictim.CreateFXEntityAndPlayEffect('mutation9_hit', 'hit_refraction');
					}
					//Kolaris - Penetration
					if( action.IsActionMelee() && (((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 50 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 51 _Stats', true)) )
					{
						armorPiercing = 0.5f + ((W3PlayerWitcher)playerAttacker).GetPlayerArmorPiercingValue(action.IsActionMelee(), action.IsActionRanged(), (CThrowable)action.causer, attackAction.GetAttackName());
						if( !attackAction.IsParried() )
						{
							blockCrush = witcherAttacker.GetAttributeValue('damage_through_blocks');
							blockCrush.valueMultiplicative += witcherAttacker.GetSkillLevel(S_Sword_s06) * 0.05f;
							armorPiercing += blockCrush.valueMultiplicative / 2;
						}
						criticalDamageBonus.valueAdditive += MaxF(0, armorPiercing - ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL));
					}
					//Kolaris - Desolation
					if( action.IsActionMelee() && (((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true)) )
					{
						criticalDamageBonus.valueAdditive += ((CNewNPC)actorVictim).GetDesolationStacks(false) * 0.01f;
						if( ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).IsPoiseBroken() && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
							criticalDamageBonus.valueAdditive += 1.f;
					}
				}
			//} //Kolaris - Mutation Rework
			
			totalBonus = CalculateAttributeValue(criticalDamageBonus);
			critReduction = actorVictim.GetAttributeValue(theGame.params.CRITICAL_HIT_REDUCTION);
			totalBonus = totalBonus * ClampF(1 - critReduction.valueMultiplicative, 0.f, 1.f);
			
			powerMod.valueMultiplicative += totalBonus;
		}
		
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			if(playerVictim && playerVictim == thePlayer || actorVictim  && GetAttitudeBetween(actorVictim, thePlayer) == AIA_Friendly)
			{
				difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
				powerMod.valueMultiplicative += difficultyDamageMultiplier - 1;
			}
		}
		// W3EE - End
		
		return powerMod;
	}
	
	private function GetDamageResists(dmgType : name, out resistPts : float, out resistPerc : float)
	{
		var armorReduction, armorReductionPerc, skillArmorReduction : SAbilityAttributeValue;
		var bonusReduct, bonusResist : float;
		// W3EE - Begin
		// var appliedOilName, vsMonsterResistReduction : name;
		// var oils : array< W3Effect_Oil >;
		var i : int;
		var encumbranceBonus : float;
		var mutagen : CBaseGameplayEffect;
		var min, max : SAbilityAttributeValue;	

		if( actorAttacker.IsHuman() && actorAttacker.IsWeaponHeld('fist') && attackAction && attackAction.IsActionMelee() && dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING && actorVictim.IsHuman() && actorVictim.IsWeaponHeld('fist') )
			return;
		// W3EE - End		

		/*if(attackAction && attackAction.IsActionMelee() && actorAttacker.GetInventory().IsItemFists(weaponId) && !actorVictim.UsesEssence())
			return;*/
			
		
		if(actorVictim)
		{
			if( action.IsDoTDamage() )
			{
				if( playerVictim )
					actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
				else
				if( !((CNewNPC)actorVictim).IsProtectedByArmor() )
					resistPerc = ((CNewNPC)actorVictim).GetNPCCustomStat(dmgType);
				else
					resistPerc = 0;
					
				resistPts = 0;
				return;
			}
			else
			{
				if( playerVictim )
					actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
				else
					resistPerc = ((CNewNPC)actorVictim).GetNPCCustomStat(dmgType);
			}
			// W3EE - End
		}
		
		// W3EE - Begin
		if( !action.GetIgnoreArmor() && playerVictim )
			resistPts += CalculateAttributeValue( actorVictim.GetTotalArmor() );
			
		//Kolaris - Negative Resists
		resistPts = MaxF(0, resistPts);
		//resistPerc = MaxF(0, resistPerc);
		// W3EE - End
	}
	
	
	// W3EE - Begin
	private function CalculateDamage(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
	{
		var finalDamage, armorPiercing, tempDamage : float;
		var resistPoints, resistPercents, resistPointsTemp, resistPercentsTemp : float;
		var ptsString, percString : string;
		var mutagen : CBaseGameplayEffect;
		var min, max, blockCrush : SAbilityAttributeValue;
		var encumbranceBonus : float;
		var temp : bool;
		var fistfightDamageMult : float;
		var burning : W3Effect_Burning;
		var npcAttacker : CNewNPC;
		var witcherAttacker, witcherVictim : W3PlayerWitcher;
		var damageHandler : W3EEDamageHandler = Damage();
		var actionIgnoresArmor : bool;
		
		if( dmgInfo.dmgSplit == 0.f )
			dmgInfo.dmgSplit = 1.f; 
		GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);
		
		if( action.IsActionWitcherSign() )
			finalDamage = MaxF(0, dmgInfo.dmgVal + powerMod.valueBase + powerMod.valueAdditive);
		else
			finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase) * powerMod.valueMultiplicative + powerMod.valueAdditive);
		
		if( !action.IsDoTDamage() )
		{
			if( !playerAttacker && actorAttacker.IsHuman() && attackAction && attackAction.IsActionMelee() )
			{
				if( actorAttacker.IsWeaponHeld('fist') && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING )
				{
					finalDamage /= 2;
				}
				else
				if( actorAttacker.IsSwordWooden() || actorAttacker.IsWeaponDamaged() )
				{
					finalDamage /= 2;
				}
			}
			
			if( !playerAttacker && action.IsActionWitcherSign() )
			{
				finalDamage /= 3;
			}
			
			if( !playerAttacker && !playerVictim && actorAttacker && actorVictim )
			{
				finalDamage /= 3;
			}
			
			if( actorVictim.IsQuestActor() && !playerAttacker )
			{
				finalDamage /= 20;
			}
			
			if( actorAttacker.IsQuestActor() && action.IsActionRanged() && !playerVictim )
			{
				finalDamage /= 2;
			}
			
			//Kolaris - Transmutation
			if( playerAttacker && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_POISON && (playerAttacker.HasAbility('Runeword 14 _Stats', true) || playerAttacker.HasAbility('Runeword 15 _Stats', true)) )
			{
				if( victimMonsterCategory == MC_Specter || victimMonsterCategory == MC_Vampire || victimMonsterCategory == MC_Cursed )
				{
					GetDamageResists(theGame.params.DAMAGE_NAME_SILVER, resistPointsTemp, resistPercentsTemp);
					if( resistPercentsTemp < resistPercents )
					{
						resistPercents = resistPercentsTemp;
						dmgInfo.dmgType = theGame.params.DAMAGE_NAME_SILVER;
					}
				}
				else
				{
					GetDamageResists(theGame.params.DAMAGE_NAME_SLASHING, resistPointsTemp, resistPercentsTemp);
					if( resistPercentsTemp < resistPercents )
					{
						resistPercents = resistPercentsTemp;
						dmgInfo.dmgType = theGame.params.DAMAGE_NAME_SLASHING;
					}
				}
			}
		}
		
		if( action.IsPointResistIgnored() || action.IsDoTDamage() )
		{
			resistPoints = 0;
		}
		
		if( DamageHitsEssence(  dmgInfo.dmgType ) )		action.originalDamage.essenceDamage  += finalDamage;
		if( DamageHitsVitality( dmgInfo.dmgType ) )		action.originalDamage.vitalityDamage += finalDamage;
		if( DamageHitsMorale(   dmgInfo.dmgType ) )		action.originalDamage.moraleDamage   += finalDamage;
		if( DamageHitsStamina(  dmgInfo.dmgType ) )		action.originalDamage.staminaDamage  += finalDamage;
		
		witcherVictim = (W3PlayerWitcher)playerVictim;
		actionIgnoresArmor = action.GetIgnoreArmor();
		
		if( !action.IsDoTDamage() && !actionIgnoresArmor )
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			if( witcherAttacker )
			{
				if( action.IsActionMelee() || action.IsActionRanged() )
				{
					armorPiercing = witcherAttacker.GetPlayerArmorPiercingValue(action.IsActionMelee(), action.IsActionRanged(), (CThrowable)action.causer, attackAction.GetAttackName());
					
					//Kolaris - Critical Armor Pierce
					if( action.IsCriticalHit() )
						armorPiercing += 0.5f;
					
					//Kolaris - Penetration
					if( action.IsActionMelee() && !attackAction.IsParried() && (witcherAttacker.HasAbility('Runeword 49 _Stats', true) || witcherAttacker.HasAbility('Runeword 50 _Stats', true) || witcherAttacker.HasAbility('Runeword 51 _Stats', true)) )
					{
						blockCrush = witcherAttacker.GetAttributeValue('damage_through_blocks');
						blockCrush.valueMultiplicative += witcherAttacker.GetSkillLevel(S_Sword_s06) * 0.05f;
						armorPiercing += blockCrush.valueMultiplicative / 2;
					}
					
					armorPiercing = MinF(1.f, armorPiercing);
					
					//Kolaris - Negative Resists
					//resistPercents = MaxF(0.f, resistPercents * (1.f - armorPiercing));
					
					//Kolaris - Armor Pierce Fix
					if( dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SILVER )
					{
						resistPercents = MinF(resistPercents, resistPercents * (1.f - armorPiercing));
						resistPercents -= witcherAttacker.GetOilResistIgnore(victimMonsterCategory);
					}
					else if( (dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SLASHING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PIERCING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING) && !(victimMonsterCategory == MC_Specter || victimMonsterCategory == MC_Vampire || victimMonsterCategory == MC_Cursed) )
					{
						resistPercents = MinF(resistPercents, resistPercents * (1.f - armorPiercing));
						resistPercents -= witcherAttacker.GetOilResistIgnore(victimMonsterCategory);
					}
				}
			}
			else
			if( playerAttacker )
			{
				finalDamage = MaxF(830.f, finalDamage);
				resistPoints = 0;
				resistPercents = 0;
				armorPiercing = 1;
			}
			else
			{
				npcAttacker = (CNewNPC)actorAttacker;
				if( action.IsActionRanged() && npcAttacker.GetScaledRangedDamage() )
					armorPiercing = MinF(1.f, npcAttacker.GetNPCCustomStat(theGame.params.DAMAGE_NAME_ARMOR_PIERCE_RANGED));
				else
					armorPiercing = MinF(1.f, npcAttacker.GetNPCCustomStat(theGame.params.DAMAGE_NAME_ARMOR_PIERCE));
					
				if( npcAttacker.IsLightAttack(attackAction.GetAttackName()) )
					armorPiercing = MinF(1.f, armorPiercing * damageHandler.eapl);
				else
				if( npcAttacker.IsHeavyAttack(attackAction.GetAttackName()) || npcAttacker.IsSuperHeavyAttack(attackAction.GetAttackName()) )
					armorPiercing = MinF(1.f, armorPiercing * damageHandler.eaph);
				
				//Kolaris - Bear Set
				if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Bear_2) )
					armorPiercing *= MaxF(0.f, 1.f - ((W3Effect_Poise)playerVictim.GetBuff(EET_Poise)).GetCurrentPoise() * 0.002f);
			}
		}
		
		
		//Kolaris - Armor Formula
		if( playerVictim )
		{
			if( dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL )
			{
				resistPercents = MaxF(0.f, resistPercents * (1 - armorPiercing * 0.5f));
				resistPoints *= (1 - armorPiercing);
			}
			else
				resistPercents = MaxF(0.f, resistPercents * (1 - armorPiercing));
		}
			
		if( playerVictim )
			tempDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing) * dmgInfo.dmgSplit, finalDamage * 0.1f) * (1 - resistPercents);
		else
			tempDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing), finalDamage * 0.1f) * (1 - resistPercents);
			
		if( DamageHitsEssence(  dmgInfo.dmgType ) )		action.originalDamageArmor.essenceDamage  += tempDamage;
		if( DamageHitsVitality( dmgInfo.dmgType ) )		action.originalDamageArmor.vitalityDamage += tempDamage;
		if( DamageHitsMorale(   dmgInfo.dmgType ) )		action.originalDamageArmor.moraleDamage   += tempDamage;
		if( DamageHitsStamina(  dmgInfo.dmgType ) )		action.originalDamageArmor.staminaDamage  += tempDamage;
		
		if( actionIgnoresArmor )
		{
			if (playerVictim || !actorVictim.HasTag('IsBoss'))
			{
				resistPoints = 0;
				resistPercents = 0;
				armorPiercing = 1;
			}
			else
			{
				//Kolaris - Armor Pierce Fix
				if( dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SILVER )
				{
					resistPoints = 0;
					resistPercents = 0;
				}
				else if( (dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SLASHING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PIERCING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING) && !(victimMonsterCategory == MC_Specter || victimMonsterCategory == MC_Vampire || victimMonsterCategory == MC_Cursed) )
				{
					resistPoints = 0;
					resistPercents = 0;
				}
			}
		}
		
		//Kolaris - Armor Formula
		if( playerVictim )
			finalDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing) * dmgInfo.dmgSplit, finalDamage * 0.1f) * (1 - resistPercents);
		else
			finalDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing), finalDamage * 0.1f) * (1 - resistPercents);
		
		//Kolaris - Griffin Set
		if(playerAttacker && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Gryphon_2) && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL && finalDamage > 0 )
			((CNewNPC)actorVictim).GryphonReduceResists(finalDamage * ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped(EIST_Gryphon));
		
		//Kolaris - Elemental Decoction
		((W3Decoction5_Effect)playerAttacker.GetBuff(EET_Decoction5)).ReduceElementalResists(dmgInfo.dmgType, finalDamage, ((CNewNPC)actorVictim));
		
		//Kolaris - Exhaustion
		if(playerAttacker && (((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 4 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 5 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 6 _Stats', true)) && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST && finalDamage > 0 )
		{
			actorVictim.DrainStamina(ESAT_FixedValue, finalDamage / 10, 0);
		}
		
		if(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE && finalDamage > 0)
			action.SetDealtFireDamage(true);
			
		if(finalDamage == 0.f)
			action.SetArmorReducedDamageToZero(true);
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Single hit damage: initial damage = " + NoTrailZeros(dmgInfo.dmgVal), action);
			LogDMHits("Single hit damage: attack_power = base: " + NoTrailZeros(powerMod.valueBase) + ", mult: " + NoTrailZeros(powerMod.valueMultiplicative) + ", add: " + NoTrailZeros(powerMod.valueAdditive), action );
			if(action.IsPointResistIgnored())
				LogDMHits("Single hit damage: resistance pts and armor = IGNORED", action);
			else
				LogDMHits("Single hit damage: resistance pts and armor = " + NoTrailZeros(resistPoints), action);			
			LogDMHits("Single hit damage: resistance perc = " + NoTrailZeros(resistPercents * 100), action);
			LogDMHits("Single hit damage: final damage to sustain = " + NoTrailZeros(finalDamage), action);
		}
			
		return finalDamage;
	}
	// W3EE - End
	
	private function ProcessActionDamage_DealDamage()
	{
		var logStr : string;
		var hpPerc : float;
		var npcVictim : CNewNPC;
		
		if ( theGame.CanLog() )
		{
			logStr = "";
			if(action.processedDmg.vitalityDamage > 0)			logStr += NoTrailZeros(action.processedDmg.vitalityDamage) + " vitality, ";
			if(action.processedDmg.essenceDamage > 0)			logStr += NoTrailZeros(action.processedDmg.essenceDamage) + " essence, ";
			if(action.processedDmg.staminaDamage > 0)			logStr += NoTrailZeros(action.processedDmg.staminaDamage) + " stamina, ";
			if(action.processedDmg.moraleDamage > 0)			logStr += NoTrailZeros(action.processedDmg.moraleDamage) + " morale";
				
			if(logStr == "")
				logStr = "NONE";
			LogDMHits("Final damage to sustain is: " + logStr, action);
		}
		
		
		if(actorVictim)
		{
			hpPerc = actorVictim.GetHealthPercents();
			
			
			if(actorVictim.IsAlive())
			{
				npcVictim = (CNewNPC)actorVictim;
				if(npcVictim && npcVictim.IsHorse())
				{
					npcVictim.GetHorseComponent().OnTakeDamage(action);
				}
				else
				{
					actorVictim.OnTakeDamage(action);
				}
			}
			if(!actorVictim.IsAlive() && hpPerc == 1)
				action.SetWasKilledBySingleHit();
		}
			
		if ( theGame.CanLog() )
		{
			LogDMHits("", action);
			LogDMHits("Target stats after damage dealt are:", action);
			if(actorVictim)
			{
				if( actorVictim.UsesVitality())						LogDMHits("Vitality = " + NoTrailZeros( actorVictim.GetStat(BCS_Vitality)), action);
				if( actorVictim.UsesEssence())						LogDMHits("Essence = "  + NoTrailZeros( actorVictim.GetStat(BCS_Essence)), action);
				if( actorVictim.GetStatMax(BCS_Stamina) > 0)		LogDMHits("Stamina = "  + NoTrailZeros( actorVictim.GetStat(BCS_Stamina, true)), action);
				if( actorVictim.GetStatMax(BCS_Morale) > 0)			LogDMHits("Morale = "   + NoTrailZeros( actorVictim.GetStat(BCS_Morale)), action);
			}
			else
			{
				LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
			}
		}
	}
	
	
	private function ProcessActionDamage_ReduceDurability(oilInfos : SOilInfo)
	{		
		var witcherPlayer : W3PlayerWitcher;
		var reducedItemId, weapon : SItemUniqueId;
		var slot : EEquipmentSlots;
		var weapons : array<SItemUniqueId>;
		var armorStringName : string;
		var canLog, playerHasSword : bool;
		var i : int;
		
		canLog = theGame.CanLog();

		witcherPlayer = GetWitcherPlayer();
	
		//Kolaris - Bugfix
		if ( playerAttacker && playerAttacker.inv.IsIdValid( weaponId ) && playerAttacker.inv.HasItemDurability( weaponId ) )
		{		
			playerAttacker.inv.ReduceItemDurability(weaponId, , oilInfos);
		}
		
		else if(playerVictim && attackAction && attackAction.IsActionMelee() && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			weapons = playerVictim.inv.GetHeldWeapons();
			playerHasSword = false;
			for(i=0; i<weapons.Size(); i+=1)
			{
				weapon = weapons[i];
				if(playerVictim.inv.IsIdValid(weapon) && (playerVictim.inv.IsItemSteelSwordUsableByPlayer(weapon) || playerVictim.inv.IsItemSilverSwordUsableByPlayer(weapon)) )
				{
					playerHasSword = true;
					break;
				}
			}
			
			if(playerHasSword)
				playerVictim.inv.ReduceItemDurability(weapon, , oilInfos);
		}
		
		else if(action.victim == witcherPlayer && (action.IsActionMelee() || action.IsActionRanged()) && action.DealsAnyDamage())
		{
			//Kolaris - Repair Buffs
			/*if( witcherPlayer.GetItemEquippedOnSlot(EES_Armor, reducedItemId) && witcherPlayer.inv.ItemHasTag(reducedItemId, 'ItemEnhanced') )
				return;*/
			
			slot = GetWitcherPlayer().ReduceArmorDurability();
			witcherPlayer.GetItemEquippedOnSlot(slot, reducedItemId);
			if(slot != EES_InvalidSlot)
				thePlayer.inv.ReduceItemRepairObjectBonusCharge(reducedItemId);
		}
	}	
	
	
	
	
	
	
	private function ProcessActionReaction(wasFrozen : bool, wasAlive : bool)
	{
		var dismemberExplosion 			: bool;
		var damageName 					: name;
		var damage 						: array<SRawDamage>;
		var points, percents, hp, dmg 	: float;
		var counterAction 				: W3DamageAction;		
		var moveTargets					: array<CActor>;
		var i 							: int;
		var canPerformFinisher			: bool;
		var weaponName					: name;
		var npcVictim					: CNewNPC;
		var toxicCloud					: W3ToxicCloud;
		var playsNonAdditiveAnim		: bool;
		var bleedCustomEffect 			: SCustomEffectParams;
		
		if(!actorVictim)
			return;
		
		npcVictim = (CNewNPC)actorVictim;
		
		canPerformFinisher = CanPerformFinisher(actorVictim);
		
		if( actorVictim.IsAlive() && !canPerformFinisher )
		{
			
			if(!action.IsDoTDamage() && action.DealtDamage())
			{
				if ( actorAttacker && npcVictim)
				{
					npcVictim.NoticeActorInGuardArea( actorAttacker );
				}
				
				if ( !playerVictim )
				{
					//Kolaris - Axii
					if( playerAttacker && actorVictim.HasBuff(EET_Confusion) && ((W3ConfuseEffect)actorVictim.GetBuff(EET_Confusion)).IsSignEffect() )
						actorVictim.IncAxiiHitCounter(1);
					actorVictim.RemoveAllBuffsOfType(EET_Confusion);
				}
				
				// W3EE - Begin
				/*if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05))
				{
					bleedCustomEffect.effectType = EET_Bleeding;
					bleedCustomEffect.creator = playerAttacker;
					bleedCustomEffect.sourceName = SkillEnumToName(S_Sword_s05);
					bleedCustomEffect.duration = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'duration', false, true));
					bleedCustomEffect.effectValue.valueAdditive = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'dmg_per_sec', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
					actorVictim.AddEffectCustom(bleedCustomEffect);
				}*/
				// W3EE - End
			}
			
			
			if(actorVictim && wasAlive)
			{
				playsNonAdditiveAnim = actorVictim.ReactToBeingHit( action );
			}				
		}
		else
		{
			
			if( !canPerformFinisher && CanDismember( wasFrozen, dismemberExplosion, weaponName ) )
			{
				ProcessDismemberment(wasFrozen, dismemberExplosion);
				toxicCloud = (W3ToxicCloud)action.causer;
				
				if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
					ProcessToxicCloudDismemberExplosion(toxicCloud.GetExplodingTargetDamages());
					
				
				if(IsRequiredAttitudeBetween(thePlayer, action.victim, true))
				{
					moveTargets = thePlayer.GetMoveTargets();
					for ( i = 0; i < moveTargets.Size(); i += 1 )
					{
						//Kolaris - Mutilation
						if ( moveTargets[i].IsHuman() )
						{
							moveTargets[i].DrainMorale(20.f * (1.6f - Options().AggressionBehavior() * 0.2f));
							if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 56 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 57 _Stats', true) )
								moveTargets[i].DrainMorale(20.f * (1.6f - Options().AggressionBehavior() * 0.2f));
						}
					}
				}
				//W3EE - Begin
				Combat().DismemberAdrenalineGain();
				//W3EE - End
			}
			else if ( canPerformFinisher )
			{
				if ( actorVictim.IsAlive() )
					actorVictim.Kill( 'Finisher', false, thePlayer );
					
				thePlayer.AddTimer( 'DelayedFinisherInputTimer', 0.1f );
				thePlayer.SetFinisherVictim( actorVictim );
				thePlayer.CleanCombatActionBuffer();
				thePlayer.OnBlockAllCombatTickets( true );
				
				if( actorVictim.WillBeUnconscious() )
				{
					actorVictim.SetBehaviorVariable( 'prepareForUnconsciousFinisher', 1.0f );
					actorVictim.ActionRotateToAsync( thePlayer.GetWorldPosition() );
				}
				
				moveTargets = thePlayer.GetMoveTargets();
				
				for ( i = 0; i < moveTargets.Size(); i += 1 )
				{
					if ( actorVictim != moveTargets[i] )
						moveTargets[i].SignalGameplayEvent( 'InterruptChargeAttack' );
				}	
				
				// W3EE - Begin
				Combat().AllowAutoFinisher(actorVictim, playerAttacker);
				// W3EE - End
			} 
			else if ( weaponName == 'fists' && npcVictim )
			{
				npcVictim.DisableAgony();	
			}
			
			thePlayer.FindMoveTarget();
		}
		
		if( attackAction.IsActionMelee() )
		{
			actorAttacker.SignalGameplayEventParamObject( 'HitActionReaction', actorVictim );
			actorVictim.OnHitActionReaction( actorAttacker, weaponName );
		}
		
		
		actorVictim.ProcessHitSound(action, playsNonAdditiveAnim || !actorVictim.IsAlive());
		
		
		/*
		if(action.IsCriticalHit() && action.DealtDamage() && !actorVictim.IsAlive() && actorAttacker == thePlayer )
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10 );
		*/
		
		if( attackAction && npcVictim && npcVictim.IsShielded( actorAttacker ) && attackAction.IsParried() && attackAction.GetAttackName() == 'attack_heavy' &&  npcVictim.GetStaminaPercents() <= 0.1 )
		{
			npcVictim.ProcessShieldDestruction();
		}
		
		
		if( actorVictim && action.CanPlayHitParticle() && ( action.DealsAnyDamage() || (attackAction && attackAction.IsParried()) ) )
			actorVictim.PlayHitEffect(action);
			

		if( action.victim.HasAbility('mon_nekker_base') && !actorVictim.CanPlayHitAnim() && !((CBaseGameplayEffect) action.causer) ) 
		{
			
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
		}
		
		//W3EE - Begin
		Combat().PlayCommonHitEffect(action, actorVictim, playsNonAdditiveAnim);
		Combat().SwordCounterEffect(action, attackAction, actorVictim, playerAttacker);
		//W3EE - End
		
		if(actorVictim && playerAttacker && action.IsActionMelee() && thePlayer.inv.IsItemFists(weaponId) )
		{
			actorVictim.SignalGameplayEvent( 'wasHitByFists' );	
			
			//Kolaris - Brawler
			if(MonsterCategoryIsMonster(victimMonsterCategory) && !((W3PlayerWitcher)playerAttacker).CanUseSkill(S_Perk_21))
			{
				if(!victimCanBeHitByFists)
				{
					playerAttacker.ReactToReflectedAttack(actorVictim);
				}
				else
				{			
					actorVictim.GetResistValue(CDS_PhysicalRes, points, percents);
				
					if(percents >= theGame.params.MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS)
						playerAttacker.ReactToReflectedAttack(actorVictim);
				}
			}			
		}
		
		// W3EE - Begin
		// ProcessSparksFromNoDamage();
		// W3EE - End
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.IsCountered() && playerVictim == GetWitcherPlayer())
		{
			GetWitcherPlayer().SetRecentlyCountered(true);
		}
		
		
		
		
		if(attackAction && !action.IsDoTDamage() && (playerAttacker || playerVictim) && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			theGame.VibrateControllerLight();
		}
	}
	
	private function CanDismember( wasFrozen : bool, out dismemberExplosion : bool, out weaponName : name ) : bool
	{
		var dismember			: bool;
		var dismemberChance 	: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;
		var arrow 				: W3ArrowProjectile;
		var inv					: CInventoryComponent;
		var toxicCloud			: W3ToxicCloud;
		var witcher				: W3PlayerWitcher;
		var i					: int;
		var secondaryWeapon		: bool;

		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		arrow = (W3ArrowProjectile)action.causer;
		toxicCloud = (W3ToxicCloud)action.causer;
		
		dismemberExplosion = false;
		
		if(playerAttacker)
		{
			secondaryWeapon = playerAttacker.inv.ItemHasTag( weaponId, 'SecondaryWeapon' ) || playerAttacker.inv.ItemHasTag( weaponId, 'Wooden' );
		}
		
		if( actorVictim.HasAbility( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if( actorVictim.HasTag( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if (actorVictim.WillBeUnconscious())
		{
			dismember = false;		
		}
		// W3EE - Begin
		else if( playerAttacker && ((W3PlayerWitcher)playerAttacker).IsInCombatAction_SpecialAttackHeavy() && playerAttacker.GetSpecialAttackTimeRatio() > 0.78f && playerAttacker.inv.ItemHasTag(weaponId, 'SwordRendBlastEffect') )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if( Combat().IsUsingBattleMace() )
		{
			dismember = false;
		}
		else if( Combat().IsUsingBattleAxe() )
		{
			dismember = true;
		}
		else if( (((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL) > 0.5f && actorVictim.IsHuman()) )
		{
			dismember = false;
		}
		else if (playerAttacker && playerAttacker.inv.ItemHasTag(weaponId, 'Wooden') )
		{
			dismember = false;
		}
		// W3EE - End
		else if( arrow && !wasFrozen )
		{
			dismember = false;
		}		
		else if( actorAttacker.HasAbility( 'ForceDismemberment' ) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if(wasFrozen)
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}						
		else if( (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if( (W3Effect_YrdenHealthDrain)action.causer )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
		{
			dismember = true;
			dismemberExplosion = true;
		}
		// W3EE - Begin
		else if( (witcher.HasBuff(EET_WinterBlade) && ((W3Effect_WinterBlade)witcher.GetBuff(EET_WinterBlade)).IsWeaponCharged()) || (witcher.HasBuff(EET_PhantomWeapon) && witcher.GetPhantomWeaponMgr().IsWeaponCharged()) ) 
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if( action.IsActionWitcherSign() )
		{
			dismember = Combat().GetSignSkillDismember(action);
			dismemberExplosion = dismember || action.HasForceExplosionDismemberment();
		}
		// W3EE - End
		else
		{
			inv = actorAttacker.GetInventory();
			weaponName = inv.GetItemName( weaponId );
			
			if( attackAction 
				&& !inv.IsItemSteelSwordUsableByPlayer(weaponId) 
				&& !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
				&& weaponName != 'polearm'
				&& weaponName != 'fists_lightning' 
				&& weaponName != 'fists_fire' )
			{
				dismember = false;
			}			
			else if ( action.IsCriticalHit() )
			{
				dismember = true;
				dismemberExplosion = action.HasForceExplosionDismemberment();
			}
			else if ( action.HasForceExplosionDismemberment() )
			{
				dismember = true;
				dismemberExplosion = true;
			}
			else
			{
				
				//W3EE - Begin
				dismemberChance = Options().Dism();
				//W3EE - End
				
				
				if(playerAttacker && playerAttacker.forceDismember)
				{
					dismemberChance = thePlayer.forceDismemberChance;
					dismemberExplosion = thePlayer.forceDismemberExplosion;
				}
				
				
				if(attackAction)
				{
					dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
					dismemberExplosion = attackAction.HasForceExplosionDismemberment();
				}
					
				// W3EE - Begin
				//Kolaris - Remove Old Enchantments
				/*if( playerAttacker.HasAbility('Runeword 4 _Stats', true) )
				{
					dismemberExplosion = Combat().GetObliterationRunewordDism(action);
				}*/
				// W3EE - End
				
				witcher = (W3PlayerWitcher)actorAttacker;
				
				dismemberChance = Clamp(dismemberChance, 0, 100);
				
				if (RandRange(100) < dismemberChance)
					dismember = true;
				else
					dismember = false;
			}
		}		
		
		return dismember;
	}	
	
	
	public function CanPerformFinisher( actorVictim : CActor ) : bool
	{
		var finisherChance 			: int;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var b						: bool;
		var size					: int;
		var npc						: CNewNPC;
		
		if ( (W3ReplacerCiri)thePlayer || playerVictim || thePlayer.isInFinisher )
			return false;
		
		if ( actorVictim.IsAlive() && !CanPerformFinisherOnAliveTarget(actorVictim) )
			return false;
		
		
		if ( actorVictim.WillBeUnconscious() && !theGame.GetDLCManager().IsEP2Available() )
			return false;
		
		// W3EE - Begin
		if( Combat().GetShouldTargetExplode() || playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
			return false;
		// W3EE - End
		
		moveTargets = thePlayer.GetMoveTargets();
		size = moveTargets.Size();
		playerPos = thePlayer.GetWorldPosition();
		
		/*if ( size > 0 )
		{
			areEnemiesAttacking = false;			
			for(i=0; i<size; i+=1)
			{
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim )
				{
					areEnemiesAttacking = true;
					break;
				}
			}
		}*/
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		// W3EE - Begin
		if ( actorVictim.IsHuman() && !thePlayer.HasAbility('ForceDismemberment') && !actorVictim.IsFrozen() )
		{
			finisherChance = Options().FinishChance();
		}
		// W3EE - End
		else 
			finisherChance = 0;	
			
		if ( actorVictim.HasTag('ForceFinisher') )
		{
			finisherChance = 100;
			areEnemiesAttacking = false;
		}
			
		item = thePlayer.inv.GetItemFromSlot( 'l_weapon' );	
		
		if ( thePlayer.forceFinisher )
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
		}
		else
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && RandRange(100) < finisherChance;
			// b =	b && !areEnemiesAttacking;
			b =	b && AbsF( victimToPlayerVector.Z ) < 0.4f;
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && actorVictim.GetAttitude( thePlayer ) == AIA_Hostile;
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
			// b =	b && ( theGame.GetWorld().NavigationCircleTest( actorVictim.GetWorldPosition(), 2.f ) || actorVictim.HasTag('ForceFinisher') ) ;
			
		}

		if ( b  )
		{
			if ( !actorVictim.IsAlive() && !actorVictim.WillBeUnconscious() )
				actorVictim.AddAbility( 'DisableFinishers', false );
				
			return true;
		}
		
		return false;
	}
	
	// W3EE - Begin
	private function CanPerformFinisherOnAliveTarget( actorVictim : CActor ) : bool
	{
		return false;
		
		
		return actorVictim.IsHuman() 
		&& ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) )
		&& actorVictim.IsVulnerable()
		&& !actorVictim.HasAbility('DisableFinisher')
		&& !actorVictim.HasAbility('InstantKillImmune');
		
	}
	// W3EE - End
	
	
	
	
	
	
	private function ProcessActionBuffs() : bool
	{
		var inv : CInventoryComponent;
		var ret : bool;
	
		
		if(!action.victim.IsAlive() || action.WasDodged() || (attackAction && attackAction.IsActionMelee() && !attackAction.ApplyBuffsIfParried() && attackAction.CanBeParried() && attackAction.IsParried()) )
			return true;
			
		
		ApplyQuenBuffChanges();
	
		//Kolaris ++ Mutation Rework
		/*if( actorAttacker == thePlayer && action.IsActionWitcherSign() && action.IsCriticalHit() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation2 ) && action.HasBuff( EET_Burning ) )
		{
			action.SetBuffSourceName( 'Mutation2ExplosionValid' );
		}*/
		//Kolaris -- Mutation Rework
		
		if(actorVictim && action.GetEffectsCount() > 0)
			ret = actorVictim.ApplyActionEffects(action);
		else
			ret = false;
			
		
		if(actorAttacker && actorVictim)
		{
			inv = actorAttacker.GetInventory();
			actorAttacker.ProcessOnHitEffects(actorVictim, inv.IsItemSilverSwordUsableByPlayer(weaponId), inv.IsItemSteelSwordUsableByPlayer(weaponId), action.IsActionWitcherSign() );
		}
		
		return ret;
	}
	
	
	private function ApplyQuenBuffChanges()
	{
		var npc : CNewNPC;
		var protection : bool;
		var witcher : W3PlayerWitcher;
		var quenEntity : W3QuenEntity;
		var i : int;
		var buffs : array<EEffectType>;
	
		if(!actorVictim || !actorVictim.HasAlternateQuen())
			return;
		
		npc = (CNewNPC)actorVictim;
		if(npc)
		{
			if(!action.DealsAnyDamage())
				protection = true;
		}
		else
		{
			witcher = (W3PlayerWitcher)actorVictim;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					protection = true;
				}
			}
		}
		
		if(!protection)
			return;
			
		action.GetEffectTypes(buffs);
		for(i=buffs.Size()-1; i>=0; i -=1)
		{
			if(buffs[i] == EET_KnockdownTypeApplicator || IsKnockdownEffectType(buffs[i]))
				continue;
				
			action.RemoveBuff(i);
		}
	}
	
	
	
	
	private function ProcessDismemberment(wasFrozen : bool, dismemberExplosion : bool )
	{
		var hitDirection		: Vector;
		var usedWound			: name;
		var npcVictim			: CNewNPC;
		var wounds				: array< name >;
		var i					: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;		
		var forcedRagdoll		: bool;
		var isExplosion			: bool;
		var dismembermentComp 	: CDismembermentComponent;
		var specialWounds		: array< name >;
		var useHitDirection		: bool;
		var fxMask				: EDismembermentEffectTypeFlags;
		var template			: CEntityTemplate;
		var ent					: CEntity;
		var signType			: ESignType;
		
		if(!actorVictim)
			return;
			
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
			
		if(wasFrozen)
		{
			ProcessFrostDismemberment();
			return;
		}
		
		forcedRagdoll = false;
		
		
		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		
		if( dismemberExplosion || (attackAction && ( attackAction.GetAttackName() == 'attack_explosion' || attackAction.HasForceExplosionDismemberment() ))
			|| (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			isExplosion = true;
		}
		else
		{
			isExplosion = false;
		}
		
		
		if(playerAttacker && thePlayer.forceDismember && IsNameValid(thePlayer.forceDismemberName))
		{
			usedWound = thePlayer.forceDismemberName;
		}
		else
		{	
			
			if(isExplosion)
			{
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );	

				
				if( action.IsMutation2PotentialKill() )
				{
					
					for( i=wounds.Size()-1; i>=0; i-=1 )
					{
						if( !StrContains( wounds[ i ], "_ep2" ) )
						{
							wounds.EraseFast( i );
						}
					}
					
					signType = action.GetSignType();
					if( signType == ST_Aard )
					{
						fxMask = DETF_Aaard;
					}
					else if( signType == ST_Igni )
					{
						fxMask = DETF_Igni;
					}
					else if( signType == ST_Yrden )
					{
						fxMask = DETF_Yrden;
					}
					else if( signType == ST_Quen )
					{
						fxMask = DETF_Quen;
					}
				}
				else
				{
					fxMask = 0;
				}
				
				// W3EE - Begin
				fxMask = Combat().GetSkillDismemberType(action);
				fxMask = Combat().GetObliterationDismType(action);
				if( action.GetBuffSourceName() == "WinterBladeDamage" )
					fxMask = DETF_Aaard;
				// W3EE - End
				
				if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
				if ( usedWound )
					StopVO( actorVictim ); 
			}
			else if(attackAction || action.GetBuffSourceName() == "riderHit")
			{
				// W3EE - Begin
				if  ( attackAction.GetAttackTypeName() == 'sword_s2' || thePlayer.isInFinisher )
					useHitDirection = true;
				
				if( actorVictim.IsHuman() )
				{
					wounds = Combat().GetDismembermentTypes(attackAction);
					if( wounds.Size() > 0 )
						usedWound = wounds[RandRange(wounds.Size())];
				}
				else
				if ( useHitDirection ) 
				{
					hitDirection = actorAttacker.GetSwordTipMovementFromAnimation( attackAction.GetAttackAnimName(), attackAction.GetHitTime(), 0.1, attackAction.GetWeaponEntity() );
					usedWound = actorVictim.GetNearestWoundForBone( attackAction.GetHitBoneIndex(), hitDirection, WTF_Cut );
				}
				else
				{			
					dismembermentComp.GetWoundsNames( wounds );
					
					
					if(wounds.Size() > 0)
					{
						dismembermentComp.GetWoundsNames( specialWounds, WTF_Explosion );
						for ( i = 0; i < specialWounds.Size(); i += 1 )
						{
							wounds.Remove( specialWounds[i] );
						}
						
						if(wounds.Size() > 0)
						{
							
							dismembermentComp.GetWoundsNames( specialWounds, WTF_Frost );
							for ( i = 0; i < specialWounds.Size(); i += 1 )
							{
								wounds.Remove( specialWounds[i] );
							}
							
							
							if ( wounds.Size() > 0 )
								usedWound = wounds[ RandRange( wounds.Size() ) ];
						}
					}
					
				}
				// W3EE - End
			}
		}
		
		if ( usedWound )
		{
			npcVictim = (CNewNPC)action.victim;
			if(npcVictim)
				npcVictim.DisableAgony();			
			
			actorVictim.SetDismembermentInfo( usedWound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), forcedRagdoll, fxMask );
			actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
			actorVictim.SetBehaviorVariable( 'dismemberAnim', 1.0 );
			
			
			if ( usedWound == 'explode_02' || usedWound == 'explode2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2')
			{
				ProcessDismembermentDeathAnim( usedWound, true, EFDT_LegLeft );
				actorVictim.SetKinematic( false );
				
			}
			else
			{
				ProcessDismembermentDeathAnim( usedWound, false );
			}
			
			
			if( usedWound == 'explode_01_ep2' || usedWound == 'explode1_ep2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2' )
			{
				template = (CEntityTemplate) LoadResource( "explosion_dismember_force" );
				ent = theGame.CreateEntity( template, npcVictim.GetWorldPosition(), , , , true );
				ent.DestroyAfter( 5.f );
			}
			
			DropEquipmentFromDismember( usedWound, true, true );
			
			/*
			if( attackAction && actorAttacker == thePlayer )			
				GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
			*/
			if(playerAttacker)
				theGame.VibrateControllerHard();	
				
			
			if( dismemberExplosion && (W3AardProjectile)action.causer )
			{
				npcVictim.AddTimer( 'AardDismemberForce', 0.00001f );
			}
		}
		else
		{
			LogChannel( 'Dismemberment', "ERROR: No wound found to dismember on entity but entity supports dismemberment!!!" );
		}
	}
	
	function ApplyForce()
	{
		var size, i : int;
		var victim : CNewNPC;
		var fromPos, toPos : Vector;
		var comps : array<CComponent>;
		var impulse : Vector;
		
		victim = (CNewNPC)action.victim;
		toPos = victim.GetWorldPosition();
		toPos.Z += 1.0f;
		fromPos = toPos;
		fromPos.Z -= 2.0f;
		impulse = VecNormalize( toPos - fromPos.Z ) * 10;
		
		comps = victim.GetComponentsByClassName('CComponent');
		victim.GetVisualDebug().AddArrow( 'applyForce', fromPos, toPos, 1, 0.2f, 0.2f, true, Color( 0,0,255 ), true, 5.0f );
		size = comps.Size();
		for( i = 0; i < size; i += 1 )
		{
			comps[i].ApplyLocalImpulseToPhysicalObject( impulse );
		}
	}
	
	private function ProcessFrostDismemberment()
	{
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var wound				: name;
		var i, fxMask			: int;
		var npcVictim			: CNewNPC;
		
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
		
		dismembermentComp.GetWoundsNames( wounds, WTF_Frost );
		
		
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			fxMask = DETF_Mutation6;
			
			
			for( i=wounds.Size()-1; i>=0; i-=1 )
			{
				if( !StrContains( wounds[ i ], "_ep2" ) )
				{
					wounds.EraseFast( i );
				}
			}
		}
		else
		{
			fxMask = 0;
		}
		
		if ( wounds.Size() > 0 )
		{
			wound = wounds[ RandRange( wounds.Size() ) ];
		}
		else
		{
			return;
		}
		
		npcVictim = (CNewNPC)action.victim;
		if(npcVictim)
		{
			npcVictim.DisableAgony();
			StopVO( npcVictim );
		}
		
		actorVictim.SetDismembermentInfo( wound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), true, fxMask );
		actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
		if( wound == 'explode_02' || wound == 'explode2' || wound == 'explode_02_ep2' || wound == 'explode2_ep2' )
		{
			ProcessDismembermentDeathAnim( wound, true, EFDT_LegLeft );
			npcVictim.SetKinematic(false);
		}
		else
		{
			ProcessDismembermentDeathAnim( wound, false );
		}
		DropEquipmentFromDismember( wound, true, true );
		
		/*
		if( attackAction )			
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
		*/	
		if(playerAttacker)
			theGame.VibrateControllerHard();	
	}
	
	
	private function ProcessDismembermentDeathAnim( nearestWound : name, forceDeathType : bool, optional deathType : EFinisherDeathType )
	{
		var dropCurveName : name;
		
		if ( forceDeathType )
		{
			if ( deathType == EFDT_Head )
				StopVO( actorVictim );
				
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)deathType );
			
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( dropCurveName == 'head' )
		{
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Head );
			StopVO( actorVictim );
		}
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Torso );
		else if ( dropCurveName == 'arm_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmRight );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmLeft );
		else if ( dropCurveName == 'leg_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegLeft );
		else if ( dropCurveName == 'leg_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegRight );
		else 
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_None );
	}
	
	private function StopVO( actor : CActor )
	{
		actor.SoundEvent( "grunt_vo_death_stop", 'head' );
	}

	private function DropEquipmentFromDismember( nearestWound : name, optional dropLeft, dropRight : bool )
	{
		var dropCurveName : name;
		
		if( actorVictim.HasAbility( 'DontDropWeaponsOnDismemberment' ) )
		{
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( ChangeHeldItemAppearance() )
		{
			actorVictim.SignalGameplayEvent('DropWeaponsInDeathTask');
			return;
		}
		
		if ( dropLeft || dropRight )
		{
			
			if ( dropLeft )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if ( dropRight )
				actorVictim.DropItemFromSlot( 'r_weapon', true );			
			
			return;
		}
		
		if ( dropCurveName == 'arm_right' )
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.DropItemFromSlot( 'l_weapon', true );
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
		{
			actorVictim.DropItemFromSlot( 'l_weapon', true );
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		}			
		else if ( dropCurveName == 'head' || dropCurveName == 'leg_left' || dropCurveName == 'leg_right' )
		{
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'r_weapon', true );
		} 
	}
	
	function ChangeHeldItemAppearance() : bool
	{
		var inv : CInventoryComponent;
		var weapon : SItemUniqueId;
		
		inv = actorVictim.GetInventory();
		
		weapon = inv.GetItemFromSlot('l_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
		
		weapon = inv.GetItemFromSlot('r_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
	
		return false;
	}
	
	/*
	private function GetOilProtectionAgainstMonster(dmgType : name, out resist : float, out reduct : float)
	{
		var i : int;
		var heldWeapons : array< SItemUniqueId >;
		var weapon : SItemUniqueId;
		// W3EE - Begin
		var oils : array<W3Effect_Oil>;
		var currentOil : W3Effect_Oil;
		// W3EE - End
		
		resist = 0;
		reduct = 0;
		
		
		heldWeapons = thePlayer.inv.GetHeldWeapons();
		
		
		for( i=0; i<heldWeapons.Size(); i+=1 )
		{
			if( !thePlayer.inv.IsItemFists( heldWeapons[ i ] ) )
			{
				weapon = heldWeapons[ i ];
				break;
			}
		}
		
		
		if( !thePlayer.inv.IsIdValid( weapon ) )
		{
			return;
		}
	
		
		// W3EE - Begin
		if( !thePlayer.inv.ItemHasActiveOilApplied( weapon, attackerMonsterCategory ) )
		{
			return;
		}
		
		oils = thePlayer.inv.GetOilsAppliedOnItem(weapon);
		for(i=0; i<oils.Size(); i+=1)
		{
			if( oils[i].GetMonsterCategory() == attackerMonsterCategory && oils[i].GetAmmoCurrentCount() > 0 )
			{
				currentOil = oils[i];
				break;
			}
		}
		
		if( !currentOil || !currentOil.WasMeditationApplied() )
			return;
		// W3EE - End
		
		resist = CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Alchemy_s05, 'defence_bonus', false, true ) );		
	}
	*/
	
	private function ProcessToxicCloudDismemberExplosion(damages : array<SRawDamage>)
	{
		var act : W3DamageAction;
		var i, j : int;
		var ents : array<CGameplayEntity>;
		
		
		if(damages.Size() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessToxicCloudDismemberExplosion: trying to process but no damages are passed! Aborting!");
			return;
		}		
		
		
		FindGameplayEntitiesInSphere(ents, action.victim.GetWorldPosition(), 3, 1000, , FLAG_OnlyAliveActors);
		
		
		for(i=0; i<ents.Size(); i+=1)
		{
			act = new W3DamageAction in this;
			act.Initialize(action.attacker, ents[i], action.causer, 'Dragons_Dream_3', EHRT_Heavy, CPS_Undefined, false, false, false, true);
			
			for(j=0; j<damages.Size(); j+=1)
			{
				act.AddDamage(damages[j].dmgType, damages[j].dmgVal);
			}
			
			theGame.damageMgr.ProcessAction(act);
			delete act;
		}
	}
	
	
	private final function ProcessSparksFromNoDamage()
	{
		var sparksEntity, weaponEntity : CEntity;
		var weaponTipPosition : Vector;
		var weaponSlotMatrix : Matrix;
		
		
		if(!playerAttacker || !attackAction || !attackAction.IsActionMelee() || attackAction.DealsAnyDamage())
			return;
		
		
		if( ( !attackAction.DidArmorReduceDamageToZero() && !actorVictim.IsVampire() && ( attackAction.IsParried() || attackAction.IsCountered() ) ) 
			|| ( ( attackAction.IsParried() || attackAction.IsCountered() ) && !actorVictim.IsHuman() && !actorVictim.IsVampire() )
			|| actorVictim.IsCurrentlyDodging() )
			return;
		
		
		if(actorVictim.HasTag('NoSparksOnArmorDmgReduced'))
			return;
		
		
		if (!actorVictim.GetGameplayVisibility())
			return;
		
		
		weaponEntity = playerAttacker.inv.GetItemEntityUnsafe(weaponId);
		weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
		weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
		
		
		sparksEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource( 'sword_colision_fx' ), weaponTipPosition );
		sparksEntity.PlayEffect('sparks');
	}
	
	private function ProcessPreHitModifications()
	{
		var fireDamage, totalDmg, maxHealth, currHealth : float;
		var attribute, min, max : SAbilityAttributeValue;
		var infusion : ESignType;
		var hack : array< SIgniEffects >;
		var dmgValTemp : float;
		// W3EE - Begin
		//var igni : W3IgniEntity;
		var quen : W3QuenEntity;
		var fireEffect : W3DamageAction;
		var igni : W3IgniProjectile;
		var witcher : W3PlayerWitcher;
		var resist : float;
		// W3EE - End
		
		if( actorVictim.HasAbility( 'HitWindowOpened' ) && !action.IsDoTDamage() )
		{
			if( actorVictim.HasTag( 'fairytale_witch' ) )
			{
				
				
				
				
				
				
					((CNewNPC)actorVictim).SetBehaviorVariable( 'shouldBreakFlightLoop', 1.0 );
				
			}
			else
			{
				quen = (W3QuenEntity)action.causer; 
			
				if( !quen )
				{
					if( actorVictim.HasTag( 'dettlaff_vampire' ) )
					{
						actorVictim.StopEffect( 'shadowdash' );
					}
					
					action.ClearDamage();
					if( action.IsActionMelee() )
					{
						actorVictim.PlayEffect( 'special_attack_break' );
					}
					actorVictim.SetBehaviorVariable( 'repelType', 0 );
					
					actorVictim.AddEffectDefault( EET_CounterStrikeHit, thePlayer ); 
					action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				}
			}
			
			((CNewNPC)actorVictim).SetHitWindowOpened( false );
		}
		
		igni = (W3IgniProjectile)action.causer;
		resist = ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE);
		if( igni && !igni.GetSignEntity().IsAlternateCast() && resist < 1 )
		{
			action.victim.AddTimer('Runeword1DisableFireFX', 1.5f);
			action.victim.PlayEffect('critical_burning');
			action.victim.PlayEffect('critical_burning_csx');
		}
		
		/*
		if(playerAttacker && attackAction && attackAction.IsActionMelee() && witcher.HasAbility('Runeword 1 _Stats', true))
		{
			infusion = witcher.GetRunewordInfusionType();
			switch(infusion)
			{
				case ST_Aard:
					action.AddEffectInfo(EET_KnockdownTypeApplicator);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					actorVictim.CreateFXEntityAtPelvis( 'runeword_1_aard', false );
					break;
				case ST_Axii:
					action.AddEffectInfo(EET_Confusion);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				case ST_Igni:
					// W3EE - Begin
					totalDmg = action.GetDamageValueTotal();
					attribute = thePlayer.GetAttributeValue('runeword1_fire_dmg');
					fireDamage = totalDmg * attribute.valueMultiplicative;
					fireEffect = new W3DamageAction in theGame;
					fireEffect.Initialize( actorAttacker, actorVictim, action.causer, action.GetBuffSourceName(), EHRT_None, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
					fireEffect.SetCannotReturnDamage( true );
					fireEffect.SetCanPlayHitParticle( false );
					fireEffect.SetHitAnimationPlayType( EAHA_ForceNo );		
					fireEffect.AddDamage( theGame.params.DAMAGE_NAME_FIRE, fireDamage );
					action.victim.AddTimer('Runeword1DisableFireFX', 1.0f);
					action.victim.PlayEffect('critical_burning');
					action.SetHitReactionType(EHRT_Heavy);
					theGame.damageMgr.ProcessAction( fireEffect );
					delete fireEffect;
					// W3EE - End
					break;
				case ST_Yrden:
					attribute = thePlayer.GetAttributeValue('runeword1_yrden_duration');
					action.AddEffectInfo(EET_Slowdown, attribute.valueAdditive);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				default:		
					break;
			}
		}
		
		if( playerAttacker && actorVictim && (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) && (W3BoltProjectile)action.causer )
		{
			maxHealth = actorVictim.GetMaxHealth();
			currHealth = actorVictim.GetHealth();
			
			
			if( AbsF( maxHealth - currHealth ) < 1.f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'health_reduction', min, max);
				actorVictim.ForceSetStat( actorVictim.GetUsedHealthType(), maxHealth * ( 1 - min.valueMultiplicative ) );
			}
			
			attribute.valueMultiplicative = 0.5f;
			action.AddEffectInfo( EET_KnockdownTypeApplicator, 0.1f, attribute, , , 1.f );
		}
		*/
		// W3EE - End
	}
}

exec function ForceDismember( b: bool, optional chance : int, optional n : name, optional e : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forceDismember = b;
	temp.forceDismemberName = n;
	temp.forceDismemberChance = chance;
	temp.forceDismemberExplosion = e;
} 

exec function ForceFinisher( b: bool, optional n : name, optional rightStance : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forcedStance = rightStance;
	temp.forceFinisher = b;
	temp.forceFinisherAnimName = n;
} 
