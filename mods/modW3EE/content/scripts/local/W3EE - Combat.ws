/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/
enum EArmorInfusionType
{
	EAIT_Shock,
	EAIT_Fire,
	EAIT_Ice,
	EAIT_None
}

class W3EECombatHandler
{	
	private var countered : bool;
	//Kolaris - Temerian Set, Kolaris - Dol Blathanna Set
	public var Perk21Active : bool;
	private var Perk21TimerActive : bool;
	public var ElvenSetActive : bool;
	
	default Perk21Active = true;
	default Perk21TimerActive = false;
	default ElvenSetActive = false;
		
	public final function DamagePercentageTaken() : float
	{
		return (Options().EnemyDodgeDamageNegation() / 100);
	}

	public final function CanUseWhirl( key : SInputAction ) : bool
	{
		return ( IsPressed(key) );
	}	

	public final function CanUseRend( key : SInputAction ) : bool
	{
		return ( IsPressed(key) );
	}
	
	public final function CheckAutoFinisher() : bool
	{
		return Options().RSAutomaticFinisher();
	}
		
	public final function BlizzardDoubleDur() : bool
	{
		//return thePlayer.GetStat(BCS_Focus) >= thePlayer.GetStatMax(BCS_Focus) && GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3 && !FactsQuerySum("BlizzardCounter");
		return false;
	}
	
	public final function BlizzardCounter() : bool
	{
		//return thePlayer.HasBuff( EET_Blizzard ) && GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3 && thePlayer.GetStat(BCS_Focus) >= thePlayer.GetStatMax(BCS_Focus);
		return false;
	}
	
	public final function DismemberAdrenalineGain()
	{
		var staminaGain : SAbilityAttributeValue;
		
		staminaGain = thePlayer.GetAttributeValue('dismember_stamina_gain');
		thePlayer.GainStat(BCS_Stamina, (Options().DADRGain() + staminaGain.valueAdditive) * Options().StamCostGlobal());
		//Kolaris - Mutilation
		if( GetWitcherPlayer().HasAbility('Runeword 56 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 57 _Stats', true) )
			thePlayer.GainStat(BCS_Stamina, (Options().DADRGain() + staminaGain.valueAdditive) * Options().StamCostGlobal());
	}
	
	public final function SetMaximumAdrenaline()
	{
		/*if( thePlayer.HasBuff(EET_MariborForest) )
			thePlayer.abilityManager.SetStatPointMax( BCS_Focus, MaxFocus() + 1 );
		else
			thePlayer.abilityManager.SetStatPointMax( BCS_Focus, MaxFocus() );*/
		thePlayer.abilityManager.SetStatPointMax( BCS_Focus, Options().MaxFocus() );
	}
	
	public final function SetPerk21State( i : bool )
	{
		Perk21Active = i;
	}

	public final function SetPerk21TimerState( i : bool )
	{
		Perk21TimerActive = i;
	}
	
	//Kolaris - Dol Blathanna Set
	public final function SetElvenSetState( i : bool )
	{
		ElvenSetActive = i;
	}
	
	public final function CalcStaminaCost( action : EStaminaActionType, optional mult : float, optional dt : float, optional abilityName : name ) : float
	{
		//var armorPieces : array<SArmorCount>;
		var witcher : W3PlayerWitcher;
		var attributeStamEfficiency : SAbilityAttributeValue;
		var armorMovementEfficiency, armorAttackEfficiency, runningTotal : float;
		
		if( thePlayer.IsCiri() )
			return 0;
		
		witcher = GetWitcherPlayer();
		
		attributeStamEfficiency = witcher.GetAttributeValue('armor_stamina_efficiency');
		armorMovementEfficiency = attributeStamEfficiency.valueMultiplicative;
		armorAttackEfficiency = attributeStamEfficiency.valueMultiplicative;
		
		//Kolaris - Strong Back
		if( witcher.CanUseSkill(S_Perk_22) )
		{
			armorMovementEfficiency *= 0.8f;
			armorAttackEfficiency *= 0.8f;
		}
		
		//Kolaris - Elation
		armorMovementEfficiency *= 1.f - CalculateAttributeValue(witcher.GetAttributeValue('armor_penalty_bonus'));
		armorAttackEfficiency *= 1.f - CalculateAttributeValue(witcher.GetAttributeValue('armor_penalty_bonus'));
		
		//Kolaris - Conservation
		if( witcher.HasAbility('Glyphword 54 _Stats', true) )
			mult *= 1.f - ((W3Effect_Poise)witcher.GetBuff(EET_Poise)).GetPoisePercentage() / 4.f;
		
		switch(action)
		{
			case ESAT_Roll:
				runningTotal = Options().StamCostEvade();
				runningTotal *= 1.f - armorMovementEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_Jump:
				runningTotal = Options().StamCostEvade();
				runningTotal *= 1.f - armorMovementEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_Dodge:
				runningTotal = Options().StamCostEvade();
				runningTotal *= 1.f - armorMovementEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_LightAttack:
				runningTotal = Options().StamCostFast();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_HeavyAttack:
				runningTotal = Options().StamCostHeavy();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_Parry:
				runningTotal = Options().StamCostBlock();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_Counterattack:
				runningTotal = Options().StamCostCounter();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_CounterattackBash:
				runningTotal = Options().StamCostCounterBash();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_CounterattackKick:
				runningTotal = Options().StamCostCounterKick();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_SpecialAttackLight:
				runningTotal = Options().StamCostFast();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			case ESAT_SpecialAttackHeavy:
				runningTotal = Options().StamCostHeavy();
				runningTotal *= 1.f - armorAttackEfficiency;
				runningTotal *= mult * dt;
				return runningTotal;
			default : return mult * thePlayer.GetStaminaActionCost(action, abilityName, dt);
		}
		
		return 0;
	}	
	
	public final function CalcArmorPenalty( witcher : W3PlayerWitcher, isAttack : bool ) : float
	{
		
		//speed
		var attributeSpeed : SAbilityAttributeValue;
		var armorMovementSpeed, armorAttackSpeed : float;
		
		attributeSpeed = witcher.GetAttributeValue('armor_speed');
		armorMovementSpeed = attributeSpeed.valueMultiplicative;
		armorAttackSpeed = attributeSpeed.valueMultiplicative;
		
		//Kolaris - Strong Back
		if( witcher.CanUseSkill(S_Perk_22) )
		{
			armorMovementSpeed *= 0.8f;
			armorAttackSpeed *= 0.8f;
		}
		
		//Kolaris - Elation
		armorMovementSpeed *= 1.f - CalculateAttributeValue(witcher.GetAttributeValue('armor_penalty_bonus'));
		armorAttackSpeed *= 1.f - CalculateAttributeValue(witcher.GetAttributeValue('armor_penalty_bonus'));
		
		if( isAttack )
			return armorAttackSpeed;
		else
			return armorMovementSpeed;
	}	
	
	public function GetActionStaminaCost( actionType : EStaminaActionType, out regenDelay : float, optional mult : float, optional dt : float, optional abilityName : name, optional checkOnly : bool ) : float
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var costMult, delayReduction : SAbilityAttributeValue;
		var finalCost, runeword33bonus, mutation9bonus : float;
		
		//Kolaris - Exhilaration
		runeword33bonus = 1.f;
		if( witcher.GetAdrenalineEffect().GetExhilarationMode() )
			runeword33bonus = 0.f;
		
		//Kolaris - Mutation 9
		mutation9bonus = 1.f;
		if( witcher.IsMutationActive(EPMT_Mutation9) )
			mutation9bonus = 0.5f;
		
		delayReduction = witcher.GetAttributeValue('delayReduction');
		if( dt == 0.f )
			dt = 1.f;
		if( mult == 0.f )
			mult = 1.f;
		switch(actionType)
		{
			case ESAT_LightAttack:
				costMult = witcher.GetAttributeValue('attack_stamina_cost_bonus');
				costMult.valueMultiplicative += 0.02f * witcher.GetSkillLevel(S_Sword_s21);
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelay() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
			return finalCost;
			
			case ESAT_HeavyAttack:
				costMult = witcher.GetAttributeValue('attack_stamina_cost_bonus');
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayHeavy() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
			return finalCost;
			
			case ESAT_Dodge:
				//Kolaris - Movement Stamina Efficiency
				costMult = witcher.GetAttributeValue('movement_stamina_efficiency');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s09);
				//Kolaris - Cat Set
				if( witcher.HasBuff(EET_LynxSetDodge) )
					costMult.valueMultiplicative += 0.1f * witcher.GetSetPartsEquipped(EIST_Lynx);
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayDodge() * (1.f - delayReduction.valueMultiplicative) * mult;
				//Kolaris - Mutation 10
				if( witcher.IsMutationActive(EPMT_Mutation10) )
					regenDelay *= 2.f;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_Parry:
				costMult = witcher.GetAttributeValue('parry_stamina_cost_bonus');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s03);
				//Kolaris - Mutation 6
				if( witcher.IsMutationActive(EPMT_Mutation6) )
					costMult.valueMultiplicative -= 0.5f;
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				//Kolaris - Deadly Precision
				//mult -= 0.03f * witcher.GetSkillLevel(S_Sword_s03);
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayBlock() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_Counterattack:
				costMult = witcher.GetAttributeValue('parry_stamina_cost_bonus');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s03);
				//Kolaris - Mutation 6
				if( witcher.IsMutationActive(EPMT_Mutation6) )
					costMult.valueMultiplicative -= 0.5f;
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				//Kolaris - Deadly Precision
				//mult -= 0.03f * witcher.GetSkillLevel(S_Sword_s03);
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayCounter() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_CounterattackKick:
				costMult = witcher.GetAttributeValue('parry_stamina_cost_bonus');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s03);
				//Kolaris - Mutation 6
				if( witcher.IsMutationActive(EPMT_Mutation6) )
					costMult.valueMultiplicative -= 0.5f;
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				//Kolaris - Deadly Precision
				//mult -= 0.03f * witcher.GetSkillLevel(S_Sword_s03);
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayCounterKick() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_CounterattackBash:
				costMult = witcher.GetAttributeValue('parry_stamina_cost_bonus');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s03);
				//Kolaris - Mutation 6
				if( witcher.IsMutationActive(EPMT_Mutation6) )
					costMult.valueMultiplicative -= 0.5f;
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				//Kolaris - Deadly Precision
				//mult -= 0.03f * witcher.GetSkillLevel(S_Sword_s03);
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayCounterBash() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_Roll:
				//Kolaris - Movement Efficiency
				costMult = witcher.GetAttributeValue('movement_stamina_efficiency');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s09);
				//Kolaris - Cat Set
				if( witcher.HasBuff(EET_LynxSetDodge) )
					costMult.valueMultiplicative += 0.1f * witcher.GetSetPartsEquipped(EIST_Lynx);
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayDodge() * (1.f - delayReduction.valueMultiplicative) * mult;
				if( witcher.IsMutationActive(EPMT_Mutation10) )
					regenDelay *= 2.f;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_Jump:
				//Kolaris - Movement Efficiency
				costMult = witcher.GetAttributeValue('movement_stamina_efficiency');
				costMult.valueMultiplicative += 0.04f * witcher.GetSkillLevel(S_Sword_s09);
				//Kolaris - Cat Set
				if( witcher.HasBuff(EET_LynxSetDodge) )
					costMult.valueMultiplicative += 0.1f * witcher.GetSetPartsEquipped(EIST_Lynx);
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				if( !witcher.IsMutationActive(EPMT_Mutation8) )
					mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayDodge() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
				//Kolaris - Mutation 8
				if( witcher.IsMutationActive(EPMT_Mutation8) )
				{
					if( !checkOnly )
						witcher.GetPoiseEffect().ReducePoise(finalCost / witcher.GetStatMax(BCS_Stamina) * witcher.GetPoiseEffect().GetMaxPoise(), regenDelay, 'Dodge');
					regenDelay = 0.f;
					finalCost = 0.f;
				}
			return finalCost;
			
			case ESAT_SpecialAttackLight:
				costMult = witcher.GetAttributeValue('attack_stamina_cost_bonus');
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelay() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
			return finalCost;
			
			case ESAT_SpecialAttackHeavy:
				costMult = witcher.GetAttributeValue('attack_stamina_cost_bonus');
				costMult.valueMultiplicative *= MinF(1.f, (1.f / (1.f + costMult.valueMultiplicative)));
				mult -= costMult.valueMultiplicative;
				mult *= runeword33bonus;
				mult *= mutation9bonus;
				
				regenDelay = Options().StamRegenDelayHeavy() * (1.f - delayReduction.valueMultiplicative) * mult;
				finalCost = CalcStaminaCost(actionType, mult, dt, abilityName);
			return finalCost;
			
			default:
			return CalcStaminaCost(actionType, mult, dt, abilityName);
		}
	}
	
	public final function StaminaLoss( actionType : EStaminaActionType, optional mult : float )
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var staminaCost, regenDelay : float;
		
		//Kolaris - Brawler, Kolaris - Temerian Set, Kolaris - Dol Blathanna Set
		if( witcher.IsSetBonusActive(EISB_Temerian) && (actionType == ESAT_HeavyAttack || actionType == ESAT_LightAttack) /*&& Perk21Active*/ )
		{
			SetPerk21State(false);
			if( !Perk21TimerActive )
			{
				SetPerk21TimerState(true);
				witcher.AddTimer('ReactivatePerk21', 4, false);
			}
		}
		else if( witcher.IsSetBonusActive(EISB_Elven_2) && (actionType == ESAT_Dodge || actionType == ESAT_Roll) )
		{
			SetElvenSetState(true);
			witcher.AddTimer('DisableElvenSet', 3, false,,,,true);
		}
		staminaCost = GetActionStaminaCost(actionType, regenDelay, mult, 1.f, '');
		witcher.DrainStamina(ESAT_FixedValue, staminaCost, regenDelay);
	}
	
	public final function EnemyDodge( out damageData : W3DamageAction, actor : CActor )
	{
		if( !((CR4Player)actor) && actor.IsCurrentlyDodging() && damageData.CanBeDodged() && ( VecDistanceSquared(actor.GetWorldPosition(),damageData.attacker.GetWorldPosition()) > 1.7 || actor.HasAbility( 'IgnoreDodgeMinimumDistance' ) ) )
		{
			damageData.SetHitAnimationPlayType(EAHA_ForceNo);
			damageData.ClearEffects();
			
			if( ((W3PlayerWitcher)damageData.attacker).IsCounterAttack(((W3Action_Attack)damageData).GetAttackName()) )
			{
				damageData.AddEffectInfo(EET_Stagger);
				return;
			}
			
			if( Options().EnemyDodgeNegateDamage() )
			{
				// damageData.SetWasDodged();
				damageData.processedDmg.essenceDamage *= DamagePercentageTaken();
				damageData.processedDmg.vitalityDamage *= DamagePercentageTaken();
			}
		}
	}

	public final function PlayCommonHitEffect( action : W3DamageAction, actorVictim : CActor, hitAnim : bool )
	{
		if( ((CNewNPC)action.victim).GetNPCType() == ENGT_Commoner && !((CBaseGameplayEffect)action.causer) ) 
		{
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
			actorVictim.ProcessHitSound(action, hitAnim || !actorVictim.IsAlive());
		}
	}
	
	public final function AllowAutoFinisher( actorVictim : CActor, playerAttacker : CR4Player )
	{
		if( CheckAutoFinisher() )
		{
			if ( theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true" || actorVictim.WillBeUnconscious() )
				actorVictim.AddAbility( 'ForceFinisher', false );
			if ( actorVictim.HasTag( 'ForceFinisher' ) )
				actorVictim.AddAbility( 'ForceFinisher', false );
		}
		actorVictim.SignalGameplayEvent( 'ForceFinisher' );
	}
	
	public final function AllowAutoFinisher2( out autofinish : bool )
	{
		if ( Options().RSAutomaticFinisher() )
		{
			autofinish = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
		}
		else autofinish = false;
	}
	
	public function DealPoiseDamage( actorVictim : CActor, action : W3DamageAction )
	{
		var npcPoise : W3Effect_NPCPoise;
		var playerPoise : W3Effect_Poise;
		var npcVictim : CNewNPC;
		var playerVictim : W3PlayerWitcher;
		var physicalResist : float;
		var actionPoiseBonus : float;
		var poiseDamage : float;
		var regenDelay : float;
		var talentMult : float;
		var poiseMod : SAbilityAttributeValue;
		var sp : SAbilityAttributeValue;
		var witcherSign : W3SignEntity;
		var attackAction : W3Action_Attack;
		var actorAttacker : CActor;
		
		attackAction = (W3Action_Attack)action;
		actorAttacker = (CActor)action.attacker;
		npcPoise = (W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise);
		playerPoise = (W3Effect_Poise)actorVictim.GetBuff(EET_Poise);
		if( npcPoise )
		{
			playerVictim = (W3PlayerWitcher)action.attacker;
			if( (action.IsActionMelee() || action.IsActionRanged()) && action.GetOriginalDamageDealtWithArmor() )
			{
				npcVictim = (CNewNPC)actorVictim;
				physicalResist = npcVictim.GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL);
				
				//Kolaris - Puppet
				if( playerVictim && playerVictim.HasAbility('Glyphword 30 _Stats', true) && npcVictim.HasBuff(EET_AxiiGuardMe) )
					return;
				
				if( actorVictim.IsLightAttack(attackAction.GetAttackName()) )
					poiseDamage = 20.f;
				else
					poiseDamage = 30.f;
				
				//Kolaris - Flank Poise Damage
				if( actorVictim.IsAttackerAtBack(actorAttacker) )
					poiseDamage *= 1.5f;
				
				if( playerVictim )
				{
					poiseMod = playerVictim.GetAttributeValue('poise_damage');
					if( playerVictim.inv.IsIdValid(attackAction.GetCrossbowID()) )
						poiseMod = playerVictim.inv.GetItemAttributeValue(attackAction.GetCrossbowID(), 'poise_damage');
					
					//Kolaris - Resolution
					if( playerVictim.HasAbility('Runeword 43 _Stats', true) || playerVictim.HasAbility('Runeword 44 _Stats', true) || playerVictim.HasAbility('Runeword 45 _Stats', true) )
						poiseMod.valueMultiplicative += playerVictim.GetAdrenalineEffect().GetValue() / 2.f;
					
					poiseDamage *= 1.f + poiseMod.valueMultiplicative;
					if( actorVictim.IsHeavyAttack(attackAction.GetAttackName()) )
						poiseDamage += 3 * playerVictim.GetSkillLevel(S_Sword_s06);
					
					//Kolaris - Whirl Poise Damage
					if( playerVictim.IsInCombatAction_SpecialAttackLight() )
						poiseDamage *= 0.75f;
					
					//Kolaris - Rend Poise Damage
					if( playerVictim.IsInCombatAction_SpecialAttack() && playerVictim.IsHeavyAttack(attackAction.GetAttackName()) )
						poiseDamage *= 1.f + playerVictim.GetSpecialAttackTimeRatio();
					
					//Kolaris - Dol Blathanna Set
					if( playerVictim.IsSetBonusActive(EISB_Elven_1) && action.IsActionRanged() )
						poiseDamage *= 1.5f;
					
					//Kolaris - Mutation 6
					if( playerVictim.IsMutationActive(EPMT_Mutation6) && action.IsActionRanged() )
					{
						if( ((CNewNPC)actorVictim).IsAttacking() 
						|| actorVictim.HasBuff(EET_Confusion)
						|| actorVictim.HasBuff(EET_Knockdown)
						|| actorVictim.HasBuff(EET_HeavyKnockdown)
						|| actorVictim.HasBuff(EET_Blindness)
						|| actorVictim.HasBuff(EET_Paralyzed)
						|| actorVictim.HasBuff(EET_Hypnotized)
						|| actorVictim.HasBuff(EET_Frozen)
						|| actorVictim.HasBuff(EET_Immobilized)
						|| (actorVictim.HasBuff(EET_Burning) && ((CNewNPC)actorVictim).GetBehaviorVariable('CriticalStateType') == 0) )
						{
							poiseDamage *= 1.5f;
						}
					}
					
					if( ((CNewNPC)actorVictim).IsShielded(playerVictim) && actorVictim.IsLightAttack(attackAction.GetAttackName()) )
						poiseDamage = 0;
				}
				
				poiseDamage *= 1.f - physicalResist;
				if( attackAction.IsParried() )
				{
					poiseDamage *= 0.8f;
					//Kolaris - Injury Effects
					actorVictim.GetInjuryManager().ParryStumbles();
				}
				else
				if( attackAction.IsCountered() )
				{
					poiseDamage *= 0.6f;
					//Kolaris - Injury Effects
					actorVictim.GetInjuryManager().ParryStumbles();
				}
				else
				if( attackAction.WasDodged() )
				{
					poiseDamage *= 0.4f;
				}
				
				//Kolaris - Shadow Form Fix
				if( actorVictim.HasAbility( 'ShadowFormActive' ) && !playerVictim.HasBuff(EET_Decoction6) )
				{
					poiseDamage *= 0.1f;
				}
				
				//Kolaris - Injury Effects
				if( actorVictim.GetInjuryManager().HasInjury(EFI_Chest) || actorVictim.GetInjuryManager().HasInjury(EPI_Spine) )
				{
					poiseDamage *= 1.25f;
				}
				
				//Kolaris - Reflection
				if( playerVictim && (playerVictim.HasAbility('Runeword 26 _Stats', true) || playerVictim.HasAbility('Runeword 27 _Stats', true)) && playerVictim.IsCounterAttack(attackAction.GetAttackName()) )
				{
					poiseDamage *= 1.5f;
					playerPoise = (W3Effect_Poise)playerVictim.GetBuff(EET_Poise);
					playerPoise.SetPoise(MinF( playerPoise.GetCurrentPoise() + poiseDamage * 0.5f, playerPoise.GetMaxPoise()));
				}
				
				//Kolaris - Destruction
				if( playerVictim && (playerVictim.HasAbility('Runeword 47 _Stats', true) || playerVictim.HasAbility('Runeword 48 _Stats', true)) )
				{
					playerPoise = (W3Effect_Poise)playerVictim.GetBuff(EET_Poise);
					if( playerPoise.GetPoisePercentage() > 0.5f )
					{
						poiseDamage *= 1.25f;
						playerPoise.SetPoise(playerPoise.GetCurrentPoise() - playerPoise.GetMaxPoise() * 0.05f);
					}
				}
				
				regenDelay = 4.f;
				if( actorVictim.IsHeavyAttack(attackAction.GetAttackName()) )
					regenDelay *= 1.25f;
				else
				if( actorVictim.IsSuperHeavyAttack(attackAction.GetAttackName()) )
					regenDelay *= 1.5f;
					
				npcPoise.ReducePoise(poiseDamage, regenDelay, action.attacker);
			}
			else
			if( action.IsActionWitcherSign() )
			{
				witcherSign = (W3SignEntity)(((W3SignProjectile)action.causer).GetSignEntity());
				if( (W3AardEntity)witcherSign )
				{
					poiseDamage = 25.f  * (1.f - npcVictim.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FORCE));
					regenDelay = 2.f;
				}
				else
				if( (W3IgniEntity)witcherSign )
				{
					poiseDamage = 20.f * (1.f - npcVictim.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE));
					regenDelay = 2.f;
				}
				else
				if( (W3AxiiEntity)witcherSign )
				{
					poiseDamage = 15.f * (1.f - npcVictim.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL));
					regenDelay = 4.f;
				}
				else
				if( (W3QuenEntity)witcherSign )
				{
					poiseDamage = 10.f * (1.f - npcVictim.GetNPCCustomStat(theGame.params.DAMAGE_NAME_SHOCK));
					regenDelay = 2.f;
				}
				else
				if( (W3YrdenEntity)witcherSign )
				{
					poiseDamage = 2.f * (1.f - npcVictim.GetNPCCustomStat(theGame.params.DAMAGE_NAME_ELEMENTAL));
					regenDelay = 0.5f;
				}
				
				if( playerVictim )
				{
					sp = playerVictim.GetTotalSignSpellPower(witcherSign.GetSkill());
					poiseDamage *= sp.valueMultiplicative;
					//Kolaris - Shockwave
					if( (W3AardEntity)witcherSign )
						poiseDamage *= 1.f + 0.2f * playerVictim.GetSkillLevel(S_Magic_s06);
				}
				
				//Kolaris - Injury Effects
				if( actorVictim.GetInjuryManager().HasInjury(EFI_Chest) || actorVictim.GetInjuryManager().HasInjury(EPI_Spine) )
				{
					poiseDamage *= 1.25f;
				}
				
				npcPoise.ReducePoise(poiseDamage, regenDelay, action.attacker);
			}
		}
		else
		if( playerPoise )
		{
			playerVictim = (W3PlayerWitcher)actorVictim;
			
			if( attackAction.WasDodged() || action.attacker.HasTag('Vesemir') )
				return;
				
			talentMult = 1.f - (playerVictim.GetSkillLevel(S_Sword_s16) * 0.05);
			
			poiseDamage = 10 * GetEnemyAttackTier(actorAttacker, attackAction.GetAttackName(), (attackAction.CanBeParried() && !action.IsParryStagger()));
			regenDelay = 1;
			
			if( action.GetOriginalDamageDealtWithArmor() > 0 )
				poiseDamage *= (1.f + action.GetOriginalDamageDealtWithArmor() / 5000.f);
			
			//Kolaris - Poise Tweaks
			if( attackAction.IsCountered() )
			{
				poiseDamage *= 0.5f;
				//Kolaris - Nilfgaard Set
				if( playerVictim.IsSetBonusActive(EISB_Nilfgaard) )
					poiseDamage *= 0.5f;
				//Kolaris - Reflection
				if( (playerVictim.HasAbility('Runeword 26 _Stats', true) || playerVictim.HasAbility('Runeword 27 _Stats', true)) && (playerVictim.GetBehaviorVariable('repelType') == 0 || playerVictim.GetBehaviorVariable('repelType') == 1 || playerVictim.GetBehaviorVariable('repelType') == 2) )
					poiseDamage = 0;					
			}
			else
			if( attackAction.IsPerfectParried() )
			{
				poiseDamage *= 0.5f;
				//Kolaris - Injury Effects
				playerVictim.GetInjuryManager().ParryStumbles();
			}
			else
			//Kolaris - Resolve
			if( attackAction.IsParried() )
			{
				poiseDamage *= 0.75f;
				//Kolaris - Injury Effects
				playerVictim.GetInjuryManager().ParryStumbles();
			}
			else
			if( playerVictim.IsCurrentlyDodging() )
			{
				poiseDamage *= 0.5f;
			}
			
			if( playerVictim.IsQuenActive(false) )
			{
				//Kolaris - Warding Shield
				poiseDamage *= (0.8f - 0.04f * playerVictim.GetSkillLevel(S_Magic_s15));
			}
			
			regenDelay += MinF(9.f, poiseDamage / 10.f);
			
			if( playerVictim.IsQuenActive(true) || ((W3QuenEntity)playerVictim.GetSignEntity(ST_Quen)).GetReflectWindow() )
			{
				poiseDamage = 0.f;
				regenDelay = 0.f;
			}
			
			//Kolaris - Overexertion
			if(playerVictim.HasBuff(EET_Overexertion))
			{
				poiseDamage *= 2.f;
			}
			
			//Kolaris - Heightened Senses, Kolaris - Flank Poise Damage
			if( playerVictim.IsAttackerAtBack(actorAttacker) && !(attackAction.IsCountered() || attackAction.IsPerfectParried()) )
				poiseDamage *= 2.f - 0.1f * playerVictim.GetSkillLevel(S_Sword_s10);
			
			//Kolaris - Poise Tweaks
			if( attackAction.IsCountered() || attackAction.IsPerfectParried() )
				playerPoise.ReducePoise(poiseDamage, regenDelay, 'Counter');
			else if( attackAction.IsParried() )
				playerPoise.ReducePoise(poiseDamage, regenDelay, 'Parry');
			else
				playerPoise.ReducePoise(poiseDamage, regenDelay, 'Hit');
		}
	}
	
	public function ProcessPoisebreak( actorVictim : CActor, actorAttacker : CActor, out action : W3DamageAction )
	{
		var witcher : W3PlayerWitcher;
		var npcPoise : W3Effect_NPCPoise;
		var playerPoise : W3Effect_Poise;
		var npcAttacker : CNewNPC;
		var playerAttacker : W3PlayerWitcher;
		var attackAction : W3Action_Attack;
		var repelType : int;
		
		attackAction = (W3Action_Attack)action;
		npcPoise = (W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise);
		playerPoise = (W3Effect_Poise)actorVictim.GetBuff(EET_Poise);
		npcAttacker = (CNewNPC)actorAttacker;
		playerAttacker = (W3PlayerWitcher)actorAttacker;
		
		if( npcPoise && npcPoise.IsPoiseBroken() && action.DealsAnyDamage() && !actorVictim.GetWasPoiseBroken() && !( actorVictim.IsCurrentlyDodging() && action.CanBeDodged() ) )
		{
			//Kolaris - Immolation
			if( action.GetBuffSourceName() == "Glyphword 9" )
				return;
			//actorVictim.NotifyStaggerEnd();
			actorVictim.SetWasPoiseBroken(true);
			npcPoise.SetPoise(npcPoise.GetMaxPoise());
			actorVictim.AddTimer('NotifyStaggerEndTimed', 0.5f, false);
			if( npcAttacker )
			{
				action.MultiplyAllDamageBy(2.f);
				actorVictim.AddEffectDefault(EET_Knockdown, actorAttacker, "PoiseBreak");
			}
			else
			if( playerAttacker )
			{
				if( action.IsActionMelee() )
				{
					//Kolaris - Human Poise-break
					if( !Options().KDisableHumanPoiseFinish() && !IsImmuneToFinisher((CNewNPC)actorVictim) && !IsUsingSecondaryWeapon() && playerAttacker.IsDeadlySwordHeld() && attackAction.GetAttackName() != 'geralt_heavy_special1' && attackAction.GetAttackName() != 'geralt_heavy_special2' 
					&& !theInput.IsActionPressed('DistanceModifier') && !theInput.IsActionPressed('DistanceModifierMed') && !(theInput.LastUsedGamepad() && theInput.GetActionValue('GI_AxisLeftY') >= Options().GetPadDistanceMedium()) )
					{
						action.MultiplyAllDamageBy(0);
						if( !actorVictim.HasBuff(EET_CounterStrikeHit) )
						{
							playerAttacker.SetCustomRotation('PoiseBreak', VecHeading(actorVictim.GetWorldPosition() - playerAttacker.GetWorldPosition()), 1080.f, 0.3f, false);
							if( RandRange(100, 0) >= 50 )
								repelType = 4;
							else
								repelType = 2;
								
							actorAttacker.SetBehaviorVariable('repelType', repelType);
							
							playerAttacker.SetSlideTarget(actorVictim);
							playerAttacker.SetMoveTarget(actorVictim);
							playerAttacker.RaiseForceEvent('PerformCounter');
							playerAttacker.SetCachedAct(actorVictim);
							playerAttacker.ClearCustomOrientationInfoStack();
							playerAttacker.OnCombatActionStart();
						}
						else
						{
							playerAttacker.SetCachedAct(actorVictim);
							playerAttacker.AddTimer('FinishTarget', 0.05f, false);
							playerAttacker.ClearCustomOrientationInfoStack();
							playerAttacker.OnCombatActionStart();
						}
					}
					else
					{						
						if( actorVictim.IsLightAttack(((W3Action_Attack)action).GetAttackName()) )
						{
							//Kolaris - Poisebreak
							((W3Action_Attack)action).SetForceInjury(true);
							actorVictim.ApplyBleeding(3, playerAttacker, "Bleeding", true);
						}
						else
						{
							action.SetIgnoreArmor(true);
							//Kolaris - Poisebreak
							action.MultiplyAllDamageBy(2.f);
						}
						//Kolaris - Glaciation
						if( playerAttacker.HasAbility('Runeword 3 _Stats', true) )
						{
							if( !actorVictim.HasBuff(EET_SlowdownFrost) )
							{
								actorVictim.AddEffectDefault(EET_SlowdownFrost, playerAttacker, "Runeword 3");
								actorVictim.AddEffectDefault(EET_Frozen, playerAttacker, "Runeword 3");
								actorVictim.CreateFXEntityAndPlayEffect('mutation_2_explode', 'mutation_2_aard');
							}
							else
							{
								actorVictim.AddEffectDefault(EET_SlowdownFrost, playerAttacker, "Runeword 3");
								actorVictim.CreateFXEntityAndPlayEffect('mutation_2_explode', 'mutation_2_aard');
							}
						}
						//Kolaris - Resolution
						if( playerAttacker.IsRuneword44Active() )
						{
							action.MultiplyAllDamageBy(1.f + ((actorVictim.GetStatMax(BCS_Essence) + actorVictim.GetStatMax(BCS_Vitality)) / 50000));
							actorVictim.CreateFXEntityAndPlayEffect('mutation9_hit', 'hit_refraction');
						}
					}
				}
				else
				if( action.IsActionRanged() )
				{
					action.MultiplyAllDamageBy(2.f);
					actorVictim.ApplyBleeding(5, playerAttacker, "Bleeding", true);
					if( actorVictim.IsImmuneToBuff(EET_Knockdown) || actorVictim.HasAbility('mon_werewolf_base') )
						actorVictim.AddEffectDefault(EET_LongStagger, actorAttacker, "PoiseBreak");
					else
						actorVictim.AddEffectDefault(EET_Knockdown, actorAttacker, "PoiseBreak");
				}
				else
				if( action.IsActionWitcherSign() )
				{
					//Kolaris - Poisebreak
					action.MultiplyAllDamageBy(2.f);
					if( actorVictim.IsImmuneToBuff(EET_Knockdown) || actorVictim.HasAbility('mon_werewolf_base') )
						actorVictim.AddEffectDefault(EET_LongStagger, actorAttacker, "PoiseBreak");
					else
						actorVictim.AddEffectDefault(EET_Knockdown, actorAttacker, "PoiseBreak");
				}
				
				//Kolaris - Bear Set
				if( playerAttacker.IsSetBonusActive(EISB_Bear_1) )
					action.MultiplyAllDamageBy(1.f + 0.05f * playerAttacker.GetSetPartsEquipped(EIST_Bear));
			}
		}
		else
		if( playerPoise && playerPoise.IsPoiseBroken() && action.DealsAnyDamage() )
		{
			//Kolaris - Player Poisebreak
			action.SetIgnoreArmor(true);
			((W3Action_Attack)action).SetForceInjury(true);
			//action.MultiplyAllDamageBy(1.5f);
			actorVictim.NotifyStaggerEnd();
			//actorVictim.AddEffectDefault(EET_LongStagger, actorAttacker, "PoiseBreak");
			GCameraShake(0.35f, false, thePlayer.GetWorldPosition(), 10,,, 1.5f);
		}
	}
	
	//Kolaris - Poise Tweaks, Kolaris - Enemy Special Attacks
	public final function CounterAndParry( playerVictim : CR4Player, actorAttacker : CActor, out attackAction : W3Action_Attack, out action : W3DamageAction )
	{
		var buffs : array<EEffectType>;
		var damageReduction : SAbilityAttributeValue;
		var npcPoise : W3Effect_NPCPoise;
		var playerPoise : W3Effect_Poise;
		var attackTier : int;
		var chipDamageMult, staminaLossMult : float;
		
		if( playerVictim && attackAction && attackAction.IsActionMelee() && !(GetEnemyAoESpecialAttackType(actorAttacker) > 0) )
 		{
			npcPoise = (W3Effect_NPCPoise)actorAttacker.GetBuff(EET_NPCPoise);
			playerPoise = (W3Effect_Poise)playerVictim.GetBuff(EET_Poise);
			action.GetEffectTypes(buffs);
			
			damageReduction = playerVictim.GetAttributeValue('damage_negation_defense');
			//Kolaris - Deadly Precision
			damageReduction.valueMultiplicative += 0.04f * playerVictim.GetSkillLevel(S_Sword_s03);
			//Kolaris - Bear Set
			if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Bear_2) )
				damageReduction.valueMultiplicative += playerPoise.GetCurrentPoise() * 0.003f;
			//Kolaris - Glaciation, Kolars - Reflection
			if( (actorAttacker.HasBuff(EET_SlowdownFrost) && (playerVictim.HasAbility('Runeword 2 _Stats', true) || playerVictim.HasAbility('Runeword 3 _Stats', true))) || (playerVictim.HasAbility('Runeword 27 _Stats', true) && theGame.GameplayFactsQuerySum("reflectionCounter") == 1) )
				damageReduction.valueMultiplicative = 1.f;
			damageReduction.valueMultiplicative = MinF( 1.f, damageReduction.valueMultiplicative );
			
			attackTier = GetEnemyAttackTier(actorAttacker, attackAction.GetAttackName(), (attackAction.CanBeParried() && !action.IsParryStagger()));
			staminaLossMult = 1.f + 0.5f * (attackTier - 1);
			chipDamageMult = 0.2f * (attackTier - 2);
			
			if( attackAction.IsCountered() )
			{
				//Kolaris - Reflection
				if(  ((W3PlayerWitcher)playerVictim).HasAbility('Runeword 27 _Stats', true) && theGame.GameplayFactsQuerySum("reflectionCounter") == 1 )
				{
					((W3PlayerWitcher)playerVictim).PlayEffectOnHeldWeapon('heavy_block');
					((W3PlayerWitcher)playerVictim).PlayEffectOnHeldWeapon('heavy_block');
					if( !((W3PlayerWitcher)playerVictim).HasAbility('Runeword 27 Ability') )
						((W3PlayerWitcher)playerVictim).AddAbilityMultiple('Runeword 27 Ability', RoundMath(attackAction.GetOriginalDamageDealt() / 20));
				}
				
				if( chipDamageMult > 0.f )
				{
					action.MultiplyAllDamageBy(chipDamageMult / 4.f * (2.f - playerPoise.GetPoisePercentage()) * (1.f - damageReduction.valueMultiplicative));
				}
				else
				{
					action.SetAllProcessedDamageAs(0);
					action.SetCanPlayHitParticle(false);
				}
				
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetProcessBuffsIfNoDamage(false);
				action.ClearEffects();
			}
			else
			if( attackAction.IsPerfectParried() )
			{
				if( chipDamageMult > 0.f )
				{
					action.MultiplyAllDamageBy(chipDamageMult / 4.f * (2.f - playerPoise.GetPoisePercentage()) * (1.f - damageReduction.valueMultiplicative));
				}
				else
				{
					action.SetAllProcessedDamageAs(0);
					action.SetCanPlayHitParticle(false);
				}
				
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetProcessBuffsIfNoDamage(false);
				action.ClearEffects();
				
				//Kolaris - Bear Set
				if( playerVictim.IsSetBonusActive(EISB_Bear_1) )
					npcPoise.ReducePoise(20 + 2 * ((W3PlayerWitcher)playerVictim).GetSetPartsEquipped(EIST_Bear), 4, playerVictim);
				else
					npcPoise.ReducePoise(20, 4, playerVictim);
				//Kolaris - Glaciation
				if( actorAttacker.HasBuff(EET_SlowdownFrost) && (playerVictim.HasAbility('Runeword 2 _Stats', true) || playerVictim.HasAbility('Runeword 3 _Stats', true)) )
					npcPoise.ReducePoise(20, 4, playerVictim);

				StaminaLoss(ESAT_Parry, staminaLossMult / 2.f);
			}
			else
			if( attackAction.IsParried() )
			{
				//Kolaris - Glaciation
				if( actorAttacker.HasBuff(EET_SlowdownFrost) && (playerVictim.HasAbility('Runeword 2 _Stats', true) || playerVictim.HasAbility('Runeword 3 _Stats', true)) )
					npcPoise.ReducePoise(10, 4, playerVictim);
				
				if( attackTier >= 3 || !playerVictim.HasStaminaToUseAction(ESAT_Parry, , staminaLossMult))
				{
					action.SetCanPlayHitParticle(false);
					action.SetProcessBuffsIfNoDamage(true);
					action.SetHitAnimationPlayType(EAHA_ForceNo);
					
					if( chipDamageMult > 0.f )
						action.MultiplyAllDamageBy(chipDamageMult / 2.f * (2.f - playerPoise.GetPoisePercentage()) * (1.f - damageReduction.valueMultiplicative));
					
					if( !actorAttacker.IsHuge() && BlockingStaggerImmunityCheck(playerVictim, action, attackAction) )
					{
						action.ClearEffects();
					}
					else
					{
						playerVictim.AddEffectDefault(EET_Stagger, action.attacker, "Parry");
						action.RemoveBuffsByType(EET_Knockdown);
					}
					
					StaminaLoss(ESAT_Parry, staminaLossMult);
				}
				else
				{						
					action.SetCanPlayHitParticle(false);
					action.SetProcessBuffsIfNoDamage(false);
					action.SetHitAnimationPlayType(EAHA_ForceNo);
					action.ClearEffects();
					
					if( chipDamageMult > 0.f )
						action.MultiplyAllDamageBy(chipDamageMult * (1.f - playerPoise.GetPoisePercentage()) * (1.f - damageReduction.valueMultiplicative));
					else
						action.SetAllProcessedDamageAs(0);
					
					StaminaLoss(ESAT_Parry, staminaLossMult);
				}
			}
		}
		else if( playerVictim && attackAction && GetEnemyAoESpecialAttackType(actorAttacker) > 0 && !((W3PlayerWitcher)playerVictim).IsQuenActive(true) )
		{
			action.SetCanPlayHitParticle(false);
			action.SetProcessBuffsIfNoDamage(true);
			action.SetHitAnimationPlayType(EAHA_ForceYes);
			action.SetHitReactionType(EHRT_Heavy);
			playerVictim.AddEffectDefault(EET_LongStagger, action.attacker, "Parry");
		}
	}

	public final function WhirlBlockingModule( playerVictim : CR4Player, attackAction : W3Action_Attack, out act : W3DamageAction )
	{
		var skillLevel : int;
		var damageReduction : float;
		var armorPieces : array<SArmorCount>;
		var witcher : W3PlayerWitcher;
		var isSpecialAttack, isLightAttack : bool;
		
		if( act.attacker == act.victim || !(act.IsActionMelee() || act.IsActionRanged()) )
			return;
		
		witcher = (W3PlayerWitcher)playerVictim;
		skillLevel = witcher.GetSkillLevel(S_Sword_s01);
		isSpecialAttack = witcher.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0;
		isLightAttack = witcher.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light;
		
		if( witcher && isSpecialAttack && isLightAttack )
		{
			act.SetHitAnimationPlayType(EAHA_ForceNo);
			if( !((W3ArrowProjectile)act.causer) )
			{
				damageReduction = 0.05f * skillLevel;
				((CActor)act.attacker).ReactToReflectedAttack(act.attacker);
				act.processedDmg.vitalityDamage *= 1.f - damageReduction;
				act.processedDmg.essenceDamage *= 1.f - damageReduction;
			}
			//Kolaris - Whirl
			if( (RandRange(100) > skillLevel * 10) && act.DealsAnyDamage() && !act.IsDoTDamage() )
			{
				//act.SetHitAnimationPlayType(EAHA_ForceNo);
				act.AddEffectInfo(EET_LongStagger);
			}
		}
	}
	
	public final function RendBlockingModule( playerVictim : CR4Player, attackAction : W3Action_Attack, act : W3DamageAction )
	{
		var skillLevel : int;
		var damageReduction : float;
		var armorPieces : array<SArmorCount>;
		var witcher : W3PlayerWitcher;
		var isSpecialAttack, isHeavyAttack : bool;
		
		if( (W3Effect_Toxicity)act.causer )
			return;
		
		witcher = (W3PlayerWitcher)playerVictim;
		skillLevel = witcher.GetSkillLevel(S_Sword_s02);
		isSpecialAttack = witcher.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0;
		isHeavyAttack = witcher.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Heavy;
		
		if( witcher && isSpecialAttack && isHeavyAttack )
		{
			if( !((W3ArrowProjectile)act.causer) )
			{
				damageReduction = 0.05f * skillLevel;
				((CActor)act.attacker).ReactToReflectedAttack(act.attacker);
				act.processedDmg.vitalityDamage *= damageReduction;
				act.processedDmg.essenceDamage *= damageReduction;
			}
		}
	}	
	
	public final function BreakEnemyBlock( attackAction : W3Action_Attack, playerAttacker : CR4Player, actorVictim : CActor )
	{
		if( actorVictim.IsGuarded() && attackAction && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s06) && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && RandRange(100,0) <= (20 * playerAttacker.GetSkillLevel(S_Sword_s06)) )
		{
			actorVictim.ResetHitCounter(0, 0);
			actorVictim.ResetDefendCounter(0, 0);
			
			if( (CNewNPC)actorVictim )
				((CNewNPC)actorVictim).LowerGuardSunder();
		}
	}
	
	//Kolaris - Cat Set
	/*public function SetReducedGrazeDodge( set : bool )
	{
		if( set && ((W3Effect_SwordDancing)GetWitcherPlayer().GetBuff(EET_SwordDancing)).GetSwordDanceActive() )
			GetWitcherPlayer().AddAbility('SwordDancingAbility', false);
		else
			GetWitcherPlayer().RemoveAbility('SwordDancingAbility');
	}
	
	public function ActivateSwordDance()
	{
		((W3Effect_SwordDancing)GetWitcherPlayer().GetBuff(EET_SwordDancing)).SetSwordDanceActive(true);
	}*/

	public final function BaseActionSpeed( isAttack : bool ) : float
	{
		var attackSpeedMult, actionSpeedMult : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var baseSpeed : float;
		var feverDebuff : float;
		var staminaPenalties : float;
		var temp : bool;
		
		witcher = GetWitcherPlayer();
		baseSpeed = 1.08f;
		
		//Kolaris - Mutation 4
		if( !witcher.IsMutationActive(EPMT_Mutation4) )
		{
			if( witcher.HasBuff(EET_Overexertion) )
			{
				if( witcher.HasBuff(EET_Decoction8) )
					staminaPenalties = MinF(1.f, PowF(1.f - witcher.GetStat(BCS_Focus) / witcher.GetStatMax(BCS_Focus), 2)) * Options().StamRed() / 50.f * (1.f - (witcher.GetSkillLevel(S_Sword_s16) * 0.05f));
				else
					staminaPenalties = Options().StamRed() / 50.f * (1.f - (witcher.GetSkillLevel(S_Sword_s16) * 0.05f));
			}
			else
			{
				if( witcher.HasBuff(EET_Decoction8) )
					staminaPenalties = MinF(PowF(1.f - witcher.GetStatPercents(BCS_Stamina), 2), PowF(1 - witcher.GetStat(BCS_Focus) / witcher.GetStatMax(BCS_Focus), 2)) * Options().StamRed() / 100.f * (1.f - (witcher.GetSkillLevel(S_Sword_s16) * 0.05f));
				else
					staminaPenalties = PowF(1.f - witcher.GetStatPercents(BCS_Stamina), 2) * Options().StamRed() / 100.f * (1.f - (witcher.GetSkillLevel(S_Sword_s16) * 0.05f));
			}
		}
		
		//Kolaris - Elation
		if( witcher.HasAbility('Glyphword 50 _Stats', true) || witcher.HasAbility('Glyphword 51 _Stats', true) )
			staminaPenalties *= 0.5f * (1.f - witcher.GetAdrenalinePercMult());
		baseSpeed -= staminaPenalties;
		baseSpeed -= ( PowF(1 - witcher.GetStatPercents(BCS_Vitality), 2) * Options().HPRed() * (1 - (witcher.GetSkillLevel(S_Sword_s16) * 0.05f)) / 100 ) * witcher.GetAdrenalinePercMult();
		baseSpeed += CalcArmorPenalty(witcher, isAttack);
		
		actionSpeedMult = witcher.GetAttributeValue('action_speed');
		if( isAttack )
		{
			//Kolaris - Bear Set
			if( witcher.IsSetBonusActive(EISB_Bear_2) )
				baseSpeed += ((W3Effect_Poise)witcher.GetBuff(EET_Poise)).GetMissingPoiseWithMult() * 0.002f;
			attackSpeedMult = witcher.GetAttributeValue('attack_speed');
			//Kolaris - Attack Speed Stacking
			baseSpeed += attackSpeedMult.valueMultiplicative * MinF(1.f, (1.f / (1.f + attackSpeedMult.valueMultiplicative)));
		}
		
		baseSpeed += actionSpeedMult.valueMultiplicative;
		//Kolaris - Frenzy
		if( witcher.CanUseSkill(S_Alchemy_s16) )
		{
			if( witcher.IsSetBonusActive(EISB_RedWolf_2) )
				baseSpeed += witcher.GetSkillLevel(S_Alchemy_s16) * 0.03f * witcher.GetStat(BCS_Toxicity) / 100.f;
			else
				baseSpeed += witcher.GetSkillLevel(S_Alchemy_s16) * 0.03f * witcher.GetStatPercents(BCS_Toxicity);
		}
		
		//Kolaris - Elation
		if( witcher.HasAbility('Glyphword 49 _Stats', true) || witcher.HasAbility('Glyphword 50 _Stats', true) || witcher.HasAbility('Glyphword 51 _Stats', true) )
			baseSpeed += 0.15f * (1.f - witcher.GetEncumbrance() / witcher.GetMaxRunEncumbrance(temp));
		
		if( witcher.HasBuff(EET_ToxicityFever) )
		{
			if( ((W3Effect_ToxicityFever)witcher.GetBuff(EET_ToxicityFever)).IsFeverActive() )
			{
				//Kolaris - Toxicity Rework
				feverDebuff = 0.15f * witcher.GetFeverEffectReductionMult();
				
				/*if( isAttack )
					feverDebuff *= 0.5f;*/
				
				baseSpeed *= 1.f - feverDebuff;
			}
		}
		
		return baseSpeed;
	}
	
	private var lastPerformedAction : EBufferActionType;
	public function GetActionType( optional actionType : EBufferActionType )
	{
		switch( thePlayer.GetBehaviorVariable('combatActionType') )
		{
			case 0:
			case 1:
				if( thePlayer.GetBehaviorVariable('playerAttackType') == (int)PAT_Light )
				{
					if( GetWitcherPlayer().GetIsBashing() )
						lastPerformedAction = EBAT_EMPTY;
					else
						lastPerformedAction = EBAT_LightAttack;
				}
				else
					lastPerformedAction = EBAT_HeavyAttack;
			return;
			
			case 9:
				if( currentCounterType == 3 || currentCounterType == 4 )
					lastPerformedAction = EBAT_LightAttack;
				else
					lastPerformedAction = EBAT_EMPTY;
					
				if( (int)currentCounterType )
					((W3Effect_SwordSignDancer)thePlayer.GetBuff(EET_SwordSignDancer)).CountActionType(ESA_Counter);
				else
					((W3Effect_SwordSignDancer)thePlayer.GetBuff(EET_SwordSignDancer)).CountActionType(ESA_Parry);
				currentCounterType = 0;
			return;
			
			case 2:
				if( !GetWitcherPlayer().GetIsBashing() )
				{
					lastPerformedAction = EBAT_Dodge;
					((W3Effect_SwordSignDancer)thePlayer.GetBuff(EET_SwordSignDancer)).CountActionType(ESA_Dodge);
					((W3Decoction8_Effect)thePlayer.GetBuff(EET_Decoction8)).AddDodgeBuff();
				}
			return;
			
			case 3:
				lastPerformedAction = EBAT_Roll;
			return;
			
			default:
				lastPerformedAction = EBAT_EMPTY;
			return;
		}
	}
	
	public function SetCombatAction( actionType : EBufferActionType )
	{
		lastPerformedAction = actionType;
	}
	
	public function CombatSpeedModule()
	{
		switch(lastPerformedAction)
		{
			case EBAT_LightAttack:
				FastAttackSpeedModule();
				//theGame.witcherLog.AddMessage("Fast Attack");
				break;
			case EBAT_HeavyAttack:
				HeavyAttackSpeedModule();
				//theGame.witcherLog.AddMessage("Strong Attack");
				break;
			case EBAT_Dodge:
				EvadeSpeedModule();
				//theGame.witcherLog.AddMessage("Dodge");
				break;
			case EBAT_Roll:
				EvadeSpeedModule();
				//theGame.witcherLog.AddMessage("Roll");
				break;
			default:
				//theGame.witcherLog.AddMessage("Break");
				break;
		}
		SetCombatAction(EBAT_EMPTY);
	}
	
	private var playerSpeedMultID : int;
	public function RemovePlayerSpeedMult()
	{
		thePlayer.ResetAnimationSpeedMultiplier(playerSpeedMultID);
	}
	
	public final function FastAttackSpeedModule( optional returnOnly : bool ) : float
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var fastSpeedBonus : SAbilityAttributeValue;
		var finalAttackSpeed : float;
		var data : CPreAttackEventData;
		var info : SAnimationEventAnimInfo;
		var animName : name;
		
		if( witcher.IsWeaponHeld('fist') )
			return 1.f;
		
		fastSpeedBonus = witcher.GetAttributeValue('attack_speed_fast_style');
		finalAttackSpeed = BaseActionSpeed(true) + fastSpeedBonus.valueMultiplicative + FloorF(witcher.GetSkillLevel(S_Sword_s21) * 2.f) / 100.f;
		//Kolaris - New Moon Set
		if(witcher.IsSetBonusActive(EISB_New_Moon) && GetDayPart(GameTimeCreate()) == EDP_Midnight)
			finalAttackSpeed += 0.1f;
		//Kolaris - Secondary Weapon Speed
		if( !returnOnly && (IsUsingBattleMace() || IsUsingBattleAxe()) )
			finalAttackSpeed += 0.15f;
		if( !returnOnly )
			playerSpeedMultID = witcher.SetAnimationSpeedMultiplier(finalAttackSpeed, playerSpeedMultID);
			
		return finalAttackSpeed;
	}

	public final function HeavyAttackSpeedModule( optional returnOnly : bool ) : float
	{	
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var strongSpeedBonus : SAbilityAttributeValue;
		var finalAttackSpeed : float;
	
		strongSpeedBonus = witcher.GetAttributeValue('attack_speed_heavy_style');
		finalAttackSpeed = BaseActionSpeed(true) + strongSpeedBonus.valueMultiplicative + FloorF(witcher.GetSkillLevel(S_Sword_s04) * 2.f) / 100.f;
		//Kolaris - New Moon Set
		if(witcher.IsSetBonusActive(EISB_New_Moon) && GetDayPart(GameTimeCreate()) == EDP_Midnight)
			finalAttackSpeed += 0.1f;
		//Kolaris - Secondary Weapon Speed
		if( !returnOnly && (IsUsingBattleMace() || IsUsingBattleAxe()) )
			finalAttackSpeed += 0.15f;
		if( !returnOnly )
			playerSpeedMultID = witcher.SetAnimationSpeedMultiplier(finalAttackSpeed, playerSpeedMultID);
			
		return finalAttackSpeed;
	}
	
	public final function EvadeSpeedModule( optional returnOnly : bool, optional sprintOnly : bool ) : float
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var finalEvadeSpeed : float;
		var evadeSpeedBonus : SAbilityAttributeValue;
		
		evadeSpeedBonus = witcher.GetAttributeValue('evade_speed');
		//Kolaris - Footwork, Kolaris - Fleet Footed, Kolaris - New Moon Set
		finalEvadeSpeed = BaseActionSpeed(false) + evadeSpeedBonus.valueMultiplicative;
		if(witcher.CanUseSkill(S_Perk_13))
			finalEvadeSpeed += 0.15f;
		if(witcher.IsSetBonusActive(EISB_New_Moon) && GetDayPart(GameTimeCreate()) == EDP_Midnight)
			finalEvadeSpeed += 0.1f;
		if( sprintOnly )
			finalEvadeSpeed = (finalEvadeSpeed + 1.f) / 2.f;
		if( !returnOnly )
			playerSpeedMultID = witcher.SetAnimationSpeedMultiplier(finalEvadeSpeed, playerSpeedMultID);
			
		return finalEvadeSpeed;
	}
	
	public final function ReaperFinisher()
	{
		thePlayer.GainStat( BCS_Stamina, Options().FADRGain() * Options().StamCostGlobal() );
		//Kolaris - Mutilation
		if( GetWitcherPlayer().HasAbility('Runeword 56 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 57 _Stats', true) )
			thePlayer.GainStat( BCS_Stamina, Options().FADRGain() * Options().StamCostGlobal() );
		
		if ( !Options().RSFinishVulnerability() )
		{
			thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_SyncedAnim );
		}
	}

	public final function SwordCounterEffect( out action : W3DamageAction, attackAction : W3Action_Attack, actorVictim : CActor, playerAttacker : CR4Player )
	{
		var effectValue : SAbilityAttributeValue;
		var damageAction : W3DamageAction;
		var npcVictim : CNewNPC;
		var skillLevel, bleedsToApply : int;
		
		npcVictim = (CNewNPC)actorVictim;
		if( playerAttacker && playerAttacker.IsCounterAttack(attackAction.GetAttackName()) )
		{
			skillLevel = playerAttacker.GetSkillLevel(S_Sword_s11);
			action.SetIsCounterAttack(true);
			//Kolaris - Counterattack
			bleedsToApply = 2;
			if( skillLevel )
			{
				if( RandRange(100,0) <= 50 )
					bleedsToApply += RandRange(skillLevel, 1);
				/*if( RandRange(100,0) <= 5 * skillLevel )
				{
					if( npcVictim && npcVictim.IsShielded(playerAttacker) )
					{
						npcVictim.ProcessShieldDestruction();
						action.AddEffectInfo(EET_Stagger);
					}
				}*/
			}
			actorVictim.ApplyBleeding(bleedsToApply, playerAttacker, "Bleeding", true);
			
			if( attackAction.IsParried() )
				actorVictim.AddTimer('PlayActorHitAnimation', 0.05f, false);
			else
				action.SetHitReactionType(EHRT_Heavy);
		}
	}
	
	private function IsHeavyWeapon( weaponTags : array<name> ) : bool
	{
		return (weaponTags.Contains('spear2h') || weaponTags.Contains('hammer2h') || weaponTags.Contains('axe2h') || weaponTags.Contains('halberd2h') || weaponTags.Contains('sword2h'));
	}
	
	private function SetCounterType( parryInfo: SParryInfo, isHeavyWeapon : bool ) : EPlayerRepelType
	{
		if( theInput.IsActionPressed('DistanceModifier') || (theInput.LastUsedGamepad() && theInput.GetActionValue('GI_AxisLeftY') >= Options().GetPadDistanceLong()) )
			return PRT_SideStepSlash;
		else
		if( theInput.IsActionPressed('DistanceModifierMed') || (theInput.LastUsedGamepad() && theInput.GetActionValue('GI_AxisLeftY') >= Options().GetPadDistanceMedium()) )
			return PRT_Random;
			
		return PRT_SideStepSlash;
	}
	
	private var currentCounterType : EPlayerRepelType;
	public final function PerformCounter( causer : CR4Player, out counterCollisionGroupNames : array<name>, out parryInfo: SParryInfo, out weaponTags : array<name>, out hitNormal : Vector, out repelType : EPlayerRepelType, out ragdollTarget : CActor, isMutation8 : bool, npc : CNewNPC )
	{
		var thisPos, attackerPos, tracePosStart, tracePosEnd, playerToAttackerVector, hitPos : Vector;
		var bleeding : SCustomEffectParams;
		var playerToTargetRot : EulerAngles;
		var useKnockdown, isHeavyWeapon : bool;
		var zDifference, mult, counterDamageMult : float;
		var witcher : W3PlayerWitcher;
		var adrGain, counterDamageAtt : SAbilityAttributeValue;
		var poiseEffect : W3Effect_Poise;
		var npcPoise : W3Effect_NPCPoise;
		
		witcher = GetWitcherPlayer();
		witcher.SetCountAct((CActor)parryInfo.attacker);
		
		//Kolaris - Poise Tweaks
		mult = 1.f + 0.5f * (Combat().GetEnemyAttackTier(parryInfo.attacker, parryInfo.attackActionName, parryInfo.canBeParried) - 1);
			
		poiseEffect = (W3Effect_Poise)witcher.GetBuff(EET_Poise);
		npcPoise = (W3Effect_NPCPoise)parryInfo.attacker.GetBuff(EET_NPCPoise);
		
		//Kolaris - Counter Damage
		counterDamageAtt = witcher.GetAttributeValue( 'counter_damage_bonus' );
		counterDamageMult = 1.f + counterDamageAtt.valueMultiplicative;
		
		parryInfo.attacker.GetInventory().PlayItemEffect(parryInfo.attackerWeaponId, 'counterattack');
		
		if ( weaponTags.Contains('spear2h') )
		{
			parryInfo.attacker.SignalGameplayEvent( 'SpearDestruction');
			((CNewNPC)parryInfo.attacker).ProcessSpearDestruction();
		}
		
		if ( parryInfo.attacker.HasAbility('mon_gravehag') )
		{
			repelType = PRT_Slash;
			parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
		}
		else
		if( isMutation8 && npc && !npc.IsImmuneToMutation8Finisher() )
		{
			repelType = PRT_RepelToFinisher;
			((W3PlayerWitcher)causer).SetCachedAct(npc);
			npc.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
			
			//causer.SetTarget(npc, true);
			//causer.AddTimer('PerformFinisher', 1.f, false);
		}
		else
		{
			isHeavyWeapon = IsHeavyWeapon(weaponTags) || npc.HasAbility('SkillElite') || npc.HasAbility('SkillWitcher') || npc.HasAbility('SkillBoss');
			repelType = SetCounterType(parryInfo, isHeavyWeapon);
			
			//Kolaris - Secondary Weapon Counter Type
			if( IsUsingBattleMace() || IsUsingBattleAxe() )
				repelType = PRT_Random;
			//Kolaris - Reflection, Kolaris - Elemental Decoction
			else if( npc.IsHuge() && !( /*witcher.HasBuff(EET_Decoction5) || */ witcher.HasAbility('Runeword 25 _Stats', true) || witcher.HasAbility('Runeword 26 _Stats', true) || witcher.HasAbility('Runeword 27 _Stats', true)) )
				repelType = PRT_SideStepSlash;
				
			if( npc.HasAbility('olgierd_default_stats') )
			{
				switch(repelType)
				{
					case PRT_Random:
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
						npc.DrainStamina(ESAT_FixedValue, 15.f * witcher.GetSkillLevel(S_Sword_s11) * counterDamageMult, 2.f);
						//Kolaris - Reflection
						if( witcher.HasAbility('Runeword 26 _Stats', true) || witcher.HasAbility('Runeword 27 _Stats', true) )
						{
							npcPoise.ReducePoise(60 * counterDamageMult, 5, parryInfo.target);
							if( witcher.IsSetBonusActive(EISB_Nilfgaard) )
								poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.1f, poiseEffect.GetMaxPoise()));
							else
								poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.2f, poiseEffect.GetMaxPoise()));
						}
						else
							npcPoise.ReducePoise(40 * counterDamageMult, 5, parryInfo.target);
						repelType = PRT_Kick;
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
			else
			if( isHeavyWeapon )
			{
				thisPos = causer.GetWorldPosition();
				attackerPos = parryInfo.attacker.GetWorldPosition();
				playerToTargetRot = VecToRotation( thisPos - attackerPos );
				zDifference = thisPos.Z - attackerPos.Z;
				
				if ( playerToTargetRot.Pitch < -5.f && zDifference > 0.35 )
				{
					repelType = PRT_Kick;
					ragdollTarget = parryInfo.attacker;
					witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
				}
				else
				switch(repelType)
				{
					case PRT_Random:
						//Kolaris - Bear School Techniques
						useKnockdown = witcher.CanUseSkill(S_Perk_07) && (!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown)) && RandRange(100, 0) < CalculateAttributeValue(witcher.GetAttributeValue('parryKnockdownChance'));
						if( useKnockdown )
						{
							ragdollTarget = parryInfo.attacker;
							witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
						}
						else
							witcher.AddTimer('SetNormalStagger', 0.3f, false ,,,, true);
						npc.DrainStamina(ESAT_FixedValue, 15.f * witcher.GetSkillLevel(S_Sword_s11) * counterDamageMult, 2.f);
						//Kolaris - Reflection
						if( witcher.HasAbility('Runeword 26 _Stats', true) || witcher.HasAbility('Runeword 27 _Stats', true) )
						{
							npcPoise.ReducePoise(60 * counterDamageMult, 5, parryInfo.target);
							if( witcher.IsSetBonusActive(EISB_Nilfgaard) )
								poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.1f, poiseEffect.GetMaxPoise()));
							else
								poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.2f, poiseEffect.GetMaxPoise()));
						}
						else
							npcPoise.ReducePoise(40 * counterDamageMult, 5, parryInfo.target);
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
			else
			if( !npc.IsHuman() )
			{
				if( !parryInfo.attacker.IsImmuneToBuff(EET_LongStagger) || !parryInfo.attacker.IsImmuneToBuff(EET_Stagger) )
				{
					switch(repelType)
					{
						case PRT_Random:
							//Kolaris - Bear School Techniques
							useKnockdown = witcher.CanUseSkill(S_Perk_07) && (!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown)) && RandRange(100, 0) < CalculateAttributeValue(witcher.GetAttributeValue('parryKnockdownChance'));
							if( useKnockdown )
							{
								ragdollTarget = parryInfo.attacker;
								witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
							}
							else
								witcher.AddTimer('SetNormalStagger', 0.3f, false ,,,, true);
							npc.DrainStamina(ESAT_FixedValue, 15.f * witcher.GetSkillLevel(S_Sword_s11) * counterDamageMult, 2.f);
							//Kolaris - Reflection
							if( witcher.HasAbility('Runeword 26 _Stats', true) || witcher.HasAbility('Runeword 27 _Stats', true) )
							{
								npcPoise.ReducePoise(60 * counterDamageMult, 5, parryInfo.target);
								if( witcher.IsSetBonusActive(EISB_Nilfgaard) )
									poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.1f, poiseEffect.GetMaxPoise()));
								else
									poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.2f, poiseEffect.GetMaxPoise()));
							}
							else
								npcPoise.ReducePoise(40 * counterDamageMult, 5, parryInfo.target);
						break;
						
						case PRT_SideStepSlash:
							repelType = PRT_SideStepSlash;
						break;
					}
				}
				else
					repelType = PRT_SideStepSlash;
			}
			else
			{
				thisPos = causer.GetWorldPosition();
				attackerPos = parryInfo.attacker.GetWorldPosition();
				playerToTargetRot = VecToRotation( thisPos - attackerPos );
				zDifference = thisPos.Z - attackerPos.Z;
				
				if ( playerToTargetRot.Pitch < -5.f && zDifference > 0.35 )
				{
					repelType = PRT_Kick;
					ragdollTarget = parryInfo.attacker;
					witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
				}
				else
				switch(repelType)
				{
					case PRT_Random:
						//Kolaris - Bear School Techniques
						useKnockdown = witcher.CanUseSkill(S_Perk_07) && (!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown)) && RandRange(100, 0) < CalculateAttributeValue(witcher.GetAttributeValue('parryKnockdownChance'));
						if( useKnockdown )
						{
							ragdollTarget = parryInfo.attacker;
							witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
						}
						else
							witcher.AddTimer('SetNormalStagger', 0.3f, false ,,,, true);
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
						npc.DrainStamina(ESAT_FixedValue, 15.f * witcher.GetSkillLevel(S_Sword_s11) * counterDamageMult, 2.f);
						//Kolaris - Reflection
						if( witcher.HasAbility('Runeword 26 _Stats', true) || witcher.HasAbility('Runeword 27 _Stats', true) )
						{
							npcPoise.ReducePoise(60 * counterDamageMult, 5, parryInfo.target);
							if( witcher.IsSetBonusActive(EISB_Nilfgaard) )
								poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.1f, poiseEffect.GetMaxPoise()));
							else
								poiseEffect.SetPoise(MinF( (poiseEffect.GetCurrentPoise() + 30 * counterDamageMult) - poiseEffect.GetMaxPoise() * 0.2f, poiseEffect.GetMaxPoise()));
						}
						else
							npcPoise.ReducePoise(40 * counterDamageMult, 5, parryInfo.target);
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
		}
		
		StaminaLoss(ESAT_Counterattack, mult);
		GCameraShake(0.35f, false, thePlayer.GetWorldPosition(), 10,,, 1.5f);
		
		currentCounterType = repelType;
		if( repelType == PRT_Random )
		{
			((W3Effect_SwordQuen)witcher.GetBuff(EET_SwordQuen)).BashCounterImpulse();
			if( !parryInfo.attacker.IsHuman() )
				repelType = PRT_Kick;
			else
			{
				if( RandRange(100, 0) > 50 )
					repelType = PRT_Kick;
				else
					repelType = PRT_Bash;
			}
		}
		
		//Kolaris - Counterattack
		/*if( repelType == PRT_Kick || repelType == PRT_Bash )
		{
			if ( !npc.IsImmuneToBuff(EET_Knockdown) && RandF() > (npc.GetStatPercents(BCS_Stamina) + npcPoise.GetPoisePercentage()))
			{
				witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
			}
			else if( npc.IsShielded(witcher) && (RandRange(100,0) <= 5 * witcher.GetSkillLevel(S_Sword_s11)) )
			{
				npc.ProcessShieldDestruction();
				witcher.AddTimer('SetNormalStagger', 0.3f, false ,,,, true);
			}
		}*/
		
		witcher.SetBehaviorVariable('repelType', (int)repelType);
		parryInfo.attacker.SetBehaviorVariable('repelType', (int)repelType);
	}
	
	public final function ArmorPoiseValue( armorPieces : array<SArmorCount> ) : float
	{
		if( GetWitcherPlayer().IsSetBonusActive(EISB_Gothic2) )
			return ( armorPieces[1].all * 0.03f + armorPieces[2].all * 0.06f + armorPieces[3].all * 0.1f ) + 0.3f;
		else
			return ( armorPieces[1].all * 0.03f + armorPieces[2].all * 0.06f + armorPieces[3].all * 0.1f );
	}
	
	public final function BaseStatsPoiseValue( witcher : W3PlayerWitcher ) : float
	{
		var poiseVal : float = 0.f;
		
		//Kolaris - Endure Pain
		if( witcher.GetSkillLevel(S_Alchemy_s20) )
			poiseVal = 0.1f * witcher.GetSkillLevel(S_Alchemy_s20) * witcher.GetStatPercents(BCS_Toxicity);
			
		return poiseVal;
	}
	
	//Kolaris - Mutation 8
	public function Mutation8StaggerCheck( playerVictim : CR4Player, damage : float, out act : W3DamageAction )
	{
		var witcherVictim : W3PlayerWitcher;
		var poiseEffect : W3Effect_Poise;
		
		witcherVictim = (W3PlayerWitcher)playerVictim;
		poiseEffect = (W3Effect_Poise)witcherVictim.GetBuff(EET_Poise);
		
		if( witcherVictim.IsMutationActive(EPMT_Mutation8) )
		{
			if( poiseEffect.GetPoisePercentage() > (damage / witcherVictim.GetStatMax(BCS_Vitality)) )
				act.SetHitAnimationPlayType(EAHA_ForceNo);
		}
	}
	
	//Kolaris - Poise Stagger
	public final function ApplyPlayerStaggerMechanics( playerVictim : CR4Player, attackAction : W3Action_Attack, out act : W3DamageAction )
	{
		var witcherVictim : W3PlayerWitcher;
		var poiseEffect : W3Effect_Poise;
		var chance, chanceMult : float;
		var temp : bool;
		
		witcherVictim = (W3PlayerWitcher)playerVictim;
		poiseEffect = (W3Effect_Poise)witcherVictim.GetBuff(EET_Poise);
		
		if( witcherVictim && attackAction && act.DealsAnyDamage() && act.GetHitReactionType() != EHRT_Reflect && act.GetHitAnimationPlayType() != EAHA_ForceYes )
		{
			chance = poiseEffect.GetCurrentPoise() * 0.01f;
			chance -= (attackAction.GetOriginalDamageDealt() + attackAction.GetDamageDealt()) / Options().GetDifficultySettingMod() * GetEnemyAttackTier(((CActor)attackAction.attacker), attackAction.GetAttackName(), (attackAction.CanBeParried() && !act.IsParryStagger())) * 0.0001f;			
			
			chanceMult = 1.f;
			chanceMult += witcherVictim.GetAdrenalineEffect().GetValue() * 0.005f;
			chanceMult += witcherVictim.GetStat(BCS_Toxicity) * 0.005f;
			if( playerVictim.GetIsSprinting() || playerVictim.IsCurrentlyDodging() )
				chanceMult += 0.5f;
			else if( playerVictim.GetIsRunning() )
				chanceMult += 0.2f;
			
			//Kolaris - Resolve
			chanceMult += witcherVictim.GetSkillLevel(S_Sword_s16) * 0.05f;
			
			//Kolaris - Resolution
			if( witcherVictim.IsInCombatAction_Attack() )
				chanceMult += (0.2f + CalculateAttributeValue(witcherVictim.GetAttributeValue('stagger_resist_bonus')));
			
			//Kolaris - Warding Shield
			if( witcherVictim.IsAnyQuenActive() )
				chanceMult += (0.25f + 0.05f * witcherVictim.GetSkillLevel(S_Magic_s15));
			
			//Kolaris - Ogroid Decoction
			if( witcherVictim.HasBuff(EET_Decoction3) )
				chanceMult += (0.05f * ((W3Decoction3_Effect)witcherVictim.GetBuff(EET_Decoction3)).GetHardeningStacks());
			
			//Kolaris - Constitution
			if( witcherVictim.HasAbility('Glyphword 43 _Stats', true) || witcherVictim.HasAbility('Glyphword 44 _Stats', true) || witcherVictim.HasAbility('Glyphword 45 _Stats', true) )
				chanceMult += (0.2 * witcherVictim.GetEncumbrance() / witcherVictim.GetMaxRunEncumbrance(temp));
			
			//Kolaris - Resolution
			if( witcherVictim.IsRuneword44Active() )
				chanceMult += 0.25f;
			
			chance *= chanceMult;
			chance *= (0.2f + witcherVictim.GetStatPercents(BCS_Vitality) * 0.8f);
			chance /= Options().GetDifficultySettingMod();
			if( act.GetHitReactionType() == EHRT_Heavy )
				chance *= 0.5f;
			
			if( RandRangeF(1,0) <= chance )
				act.SetHitAnimationPlayType(EAHA_ForceNo);
			//theGame.GetGuiManager().ShowNotification(chance);
		}
	}
	
	public final function ApplyNPCStaggerMechanics( playerVictim : CR4Player, attackAction : W3Action_Attack, out act : W3DamageAction )
	{
		var npc : CNewNPC;
		var witcherAttacker : W3PlayerWitcher;
		var poiseEffect : W3Effect_NPCPoise;
		var chance : float;
		
		npc = (CNewNPC)act.victim;
		witcherAttacker = (W3PlayerWitcher)attackAction.attacker;
		poiseEffect = (W3Effect_NPCPoise)npc.GetBuff(EET_NPCPoise);
		
		if( act.victim && !playerVictim && attackAction && ( attackAction.CanBeParried() || ((W3ArrowProjectile)act.causer) ) )
		{
			chance = poiseEffect.GetPoisePercentage() + 0.5f;
			chance *= npc.GetPoiseValue() + 0.5f;
			chance *= npc.GetHealthPercents() + 0.5f;
			//Kolaris - Difficulty Settings
			chance *= Options().GetDifficultySettingMod();
			chance *= 0.25f;
			
			if(witcherAttacker && witcherAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && witcherAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
				chance *= 5;
			
			if(witcherAttacker.IsCounterAttack(attackAction.GetAttackName()))
				chance = 0;
			
			if( RandRangeF(1,0) <= chance )
				act.SetHitAnimationPlayType(EAHA_ForceNo);
			//theGame.GetGuiManager().ShowNotification(chance);
		}
	}
	
	public final function CrippleEnemy( playerAttacker : CPlayer, enemy : CNewNPC, action : W3DamageAction )
	{
		var initialSlowdown : float;
		var skillLevel : int;
		
		skillLevel = thePlayer.GetSkillLevel(S_Sword_s05);
		
		if( !enemy.CanGetCrippled() )
			return;
		
		if( thePlayer.CanUseSkill(S_Sword_s05) && playerAttacker && enemy && action.IsActionMelee() && action.DealsAnyDamage() && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light )
		{
			//Kolaris - Crippling Strikes
			initialSlowdown = enemy.GetSlowdownFactor();
				
			if( initialSlowdown < 1 )
				enemy.SetSlowdownFactor( MinF( initialSlowdown + 0.01f, 0.1f ) );
				
			enemy.npcStats.spdMultID2 = enemy.SetAnimationSpeedMultiplier(1 - enemy.GetSlowdownFactor(), enemy.npcStats.spdMultID2);
			enemy.SetCrippled(true);
				
			//enemy.DrainStamina(ESAT_FixedValue, 0, 2);
			enemy.AddTimer('RemoveCripplingInjury', skillLevel * 2, false,,,,true);
		}		
	}
	
	public final function ApplyDamageModifiers( out action : W3DamageAction, actorVictim : CActor )
	{
		var victimHealth : float;
		var actorAttacker : CActor;
		var witcherAttacker : W3PlayerWitcher;
		
		if( !action || !action.attacker || !action.victim || !action.DealsAnyDamage() )
			return;
			
		if( !actorVictim.IsHuge() && !((CPlayer)actorVictim) && action.DealsAnyDamage() )
			actorVictim.DrainStamina(ESAT_FixedValue, 0, 1.f);
			
		if( (!action.IsActionMelee() && !action.IsActionRanged()) || action.IsDoTDamage() )
			return;
			
		witcherAttacker = (W3PlayerWitcher)action.attacker;
		actorAttacker = (CActor)action.attacker;
		
		if( actorVictim.UsesVitality() )
			victimHealth = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealth = actorVictim.GetStatPercents(BCS_Essence);
			
		//Kolaris - Counterattack
		/*if( witcherAttacker.IsCounterAttack(((W3Action_Attack)action).GetAttackName()) )
			action.MultiplyAllDamageBy(3.f);*/
			
		//Kolaris - Huntsman
		if( witcherAttacker && witcherAttacker.CanUseSkill(S_Perk_19) && ((W3MonsterHuntNPC)actorVictim || actorVictim.HasTag('ContractTarget')) )
			action.MultiplyAllDamageBy(1.1f);
			
		if( action.IsActionMelee() )
		{
			//Kolaris - Damage Penalty from Stamina, Kolaris - Mutation 4
			if( witcherAttacker && !witcherAttacker.IsInCombatAction_SpecialAttackHeavy() && !witcherAttacker.IsMutationActive(EPMT_Mutation4) )
			{
				if(witcherAttacker.HasBuff(EET_Overexertion))
				{
					if(witcherAttacker.HasBuff(EET_Decoction8))
						action.MultiplyAllDamageBy(1.f - MinF(1.f, PowF(1.f - actorAttacker.GetStat(BCS_Focus) / actorAttacker.GetStatMax(BCS_Focus), 2)) * Options().StamDamRed() / 50.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
					else
						action.MultiplyAllDamageBy(1.f - Options().StamDamRed() / 50.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
				}
				else
				{
					if(witcherAttacker.HasBuff(EET_Decoction8))
						action.MultiplyAllDamageBy(1.f - MinF(PowF(1 - actorAttacker.GetStatPercents(BCS_Stamina), 2), PowF(1.f - actorAttacker.GetStat(BCS_Focus) / actorAttacker.GetStatMax(BCS_Focus), 2)) * Options().StamDamRed() / 100.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
					else
						action.MultiplyAllDamageBy(1.f - PowF(1.f - actorAttacker.GetStatPercents(BCS_Stamina), 2) * Options().StamDamRed() / 100.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
				}
			}
			else
            if( !witcherAttacker )
			{
				//Kolaris - Enemy Damage From Stamina
                action.MultiplyAllDamageBy(1.f - PowF(1 - actorAttacker.GetStatPercents(BCS_Stamina), 2) * 0.5f); 
				//Kolaris - Mutation 4
				if( (W3PlayerWitcher)actorVictim && ((W3PlayerWitcher)actorVictim).IsMutationActive(EPMT_Mutation4) )
				{
					if(actorVictim.HasBuff(EET_Overexertion))
					{
						if(actorVictim.HasBuff(EET_Decoction8))
							action.MultiplyAllDamageBy(1.f + MinF(1.f, PowF(1.f - actorAttacker.GetStat(BCS_Focus) / actorAttacker.GetStatMax(BCS_Focus), 2)) * Options().StamDamRed() / 50.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
						else
							action.MultiplyAllDamageBy(1.f + Options().StamDamRed() / 25.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
					}
					else
					{
						if(actorVictim.HasBuff(EET_Decoction8))
							action.MultiplyAllDamageBy(1.f + MinF(PowF(1 - actorVictim.GetStatPercents(BCS_Stamina), 2), PowF(1.f - actorAttacker.GetStat(BCS_Focus) / actorAttacker.GetStatMax(BCS_Focus), 2)) * Options().StamDamRed() / 100.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
						else
							action.MultiplyAllDamageBy(1.f + PowF(1.f - actorVictim.GetStatPercents(BCS_Stamina), 2) * Options().StamDamRed() / 50.f * (1.f - (witcherAttacker.GetSkillLevel(S_Sword_s16) * 0.05f)));
					}
				}
			}
			//Kolaris - Mutation 1
			if( witcherAttacker && witcherAttacker.IsMutationActive(EPMT_Mutation1) )
				action.MultiplyAllDamageBy(0.5f);
		}
		
		//Kolaris - Vitality Damage Modifiers
		//action.MultiplyAllDamageBy(1.f + (0.3f * (1.f - victimHealth)) - 0.15f);
	}
	
	public function PerformLightBash() : bool
	{
		var kickAnim : name;
		var staminaCost, staminaRegenDelay : float; //Kolaris - Special Attack Stamina Costs
		var witcher : W3PlayerWitcher;
		var target : CActor;
		
		witcher = GetWitcherPlayer();
		target = witcher.GetTarget();
		
		staminaCost = GetActionStaminaCost(ESAT_SpecialAttackLight, staminaRegenDelay, 2, 1); //Kolaris - Special Attack Stamina Costs
		if( witcher && target && !witcher.GetIsBashing() && !target.IsHuge() && witcher.GetStat(BCS_Stamina) >= staminaCost && VecDistance(witcher.GetWorldPosition(), target.GetWorldPosition()) < 2.3f )
		{
			if( witcher.HasBuff(EET_Stagger) || witcher.HasBuff(EET_LongStagger) || witcher.HasBuff(EET_Knockdown) || witcher.HasBuff(EET_HeavyKnockdown) || witcher.HasBuff(EET_Pull) || witcher.HasBuff(EET_Mutation11Immortal) )
				return false;
			
			if ( witcher.GetCombatIdleStance() <= 0.f )
				kickAnim = 'geralt_special_kick_lp';
			else
				kickAnim = 'geralt_special_kick_rp';
			
			witcher.SetIsBashing(true);
			witcher.DrainStamina(ESAT_FixedValue, staminaCost, staminaRegenDelay); //Kolaris - Special Attack Stamina Costs
			witcher.OnCombatActionStart();
			witcher.ClearCustomOrientationInfoStack();
			witcher.SetSlideTarget(target);
			witcher.SetMoveTarget(target);
			//witcher.SetCustomRotation('SpecialAttackLight', VecHeading(target.GetWorldPosition() - witcher.GetWorldPosition()), 1080.f, 1.f, false);
			witcher.SetCustomRotationTowards( 'SpecialAttackLight', target, 1080.f, 1.f );
			//witcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', kickAnim, 0.15f, 1.f, true);
			thePlayer.GetRootAnimatedComponent().PlaySlotAnimationAsync( kickAnim, 'PLAYER_SLOT', SAnimatedComponentSlotAnimationSettings(0.15f, 1.f));
			witcher.AddTimer('RemoveBashing', 2.5f, false ,,,, true);
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	//Kolaris - Manual Kick
	public function LightBashEffect( attackAction : W3Action_Attack, action : W3DamageAction, actorVictim : CActor )
	{
		var effects : array<EEffectType>;
		var severity : float;
		
		if( attackAction.GetAttackName() == 'geralt_kick_special' )
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
			action.SetCanPlayHitParticle(false);
			action.SetCannotReturnDamage(true);
			attackAction.SetForceInjury(false);
			action.SetAllProcessedDamageAs(0);
			action.ClearEffects();
			
			severity = RandRange(100, 0) + ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).GetPoise() + actorVictim.GetStat(BCS_Stamina);
			if( actorVictim.HasBuff(EET_Stagger) || actorVictim.HasBuff(EET_CounterStrikeHit) || actorVictim.HasBuff(EET_LongStagger) )
				severity -= 50.f;
			
			if( severity < 0.f )
				effects.PushBack(EET_HeavyKnockdown);
			else if( severity < 50.f )
				effects.PushBack(EET_Knockdown);
			else if( severity < 100.f )
				effects.PushBack(EET_LongStagger);
			else
				effects.PushBack(EET_Stagger);
			
			//theGame.GetGuiManager().ShowNotification(severity);
			actorVictim.DrainStamina(ESAT_FixedValue, 30.f, 3.f);
			actorVictim.AddEffectDefault(effects[0], action.attacker, "SpecialAttackLight", false);
		}
	}
	
	public function IsImmuneToFinisher( npc : CNewNPC ) : bool
	{
		var str : string;
		
		if( !npc.IsHuman() || !npc.IsAlive() || !IsRequiredAttitudeBetween( thePlayer, npc, true ) )
		{
			return true;
		}
		
		if( npc.WillBeUnconscious() || npc.HasTag('olgierd_gpl') || npc.HasBuff(EET_Knockdown) || npc.HasBuff(EET_HeavyKnockdown) )
		{
			return true;
		}
		
		if( npc.HasAbility('Boss') || npc.HasAbility('SkillBoss') || npc.HasAbility('InstantKillImmune') || npc.HasAbility('DisableFinishers') || npc.HasAbility('mh305_doppler_geralt') )
		{
			return true;
		}
		
		str = npc.GetName();
		if( StrStartsWith( str, "rosa_var_attre" ) )
		{
			return true;
		}
		
		return false;
	}
	
	public function PerformHeavyBash() : bool
	{
		var staminaCost, staminaRegenDelay : float; //Kolaris - Special Attack Stamina Cost
		var witcher : W3PlayerWitcher;
		var target : CActor;
		
		witcher = GetWitcherPlayer();
		staminaCost = GetActionStaminaCost(ESAT_SpecialAttackHeavy, staminaRegenDelay, 2, 1); //Kolaris - Special Attack Stamina Cost
		if( witcher && !witcher.IsWeaponHeld('fist') && !witcher.GetIsBashing() && witcher.GetStat(BCS_Stamina) >= staminaCost )
		{
			if( witcher.HasBuff(EET_Stagger) || witcher.HasBuff(EET_LongStagger) || witcher.HasBuff(EET_Knockdown) || witcher.HasBuff(EET_HeavyKnockdown) || witcher.HasBuff(EET_Pull) || witcher.HasBuff(EET_Mutation11Immortal) )
				return false;
				
			target = witcher.GetTarget();
			witcher.SetIsBashing(true);
			witcher.ClearCustomOrientationInfoStack();
			witcher.DrainStamina(ESAT_FixedValue, staminaCost, staminaRegenDelay); //Kolaris - Special Attack Stamina Cost
			witcher.SetSlideTarget(target);
			witcher.SetMoveTarget(target);
			witcher.SetCustomRotation('SpecialHeavy', VecHeading(target.GetWorldPosition() - witcher.GetWorldPosition()), 1080.f, 1.6f, false);
			//witcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'geralt_heavy_special_attack', 0.15f, 0.25f, true);
			thePlayer.GetRootAnimatedComponent().PlaySlotAnimationAsync( 'geralt_heavy_special_attack', 'PLAYER_SLOT', SAnimatedComponentSlotAnimationSettings(0.15f, 0.45f));
			witcher.OnCombatActionStart();
			thePlayer.SetCombatIdleStance(1);
			witcher.AddTimer('RemoveBashing', 2.5f, false ,,,, true);
			
			return true;
		}
		else return false;
	}
	
	var firstHitHeavyBash : bool; default firstHitHeavyBash = false;
	var firstHitHeavyBashSuccess : bool; default firstHitHeavyBashSuccess = false;
	
	public function ResetSpecialHeavyFirstStage()
	{
		firstHitHeavyBashSuccess = false;
		firstHitHeavyBash = false;
	}
	
	public function SpecialAttackHeavy( action : W3Action_Attack )
	{
		var repelType : EPlayerRepelType = PRT_RepelToFinisher;
		var witcher : W3PlayerWitcher;
		var npcTarget : CNewNPC;
		var shieldBreakChance : int;
		
		witcher = (W3PlayerWitcher)action.attacker;
		
		if( !witcher )
			return;
			
		if( action.victim && action.GetAttackAnimName() == 'geralt_heavy_special_attack' )
		{
			npcTarget = (CNewNPC)action.victim;
			
			if( action.GetAttackName() == 'geralt_heavy_special1' )
			{
				if (!action.WasDodged())
				{
					if (!npcTarget.IsShielded(witcher))
						action.SetHitAnimationPlayType(EAHA_ForceYes);
						
					firstHitHeavyBash = true;					
					if ( action.GetOriginalDamageDealtWithArmor() != 0 && RandF() < (action.GetDamageDealt() / action.GetOriginalDamageDealtWithArmor()) )
						firstHitHeavyBashSuccess = true;
				}
				
				//Kolaris - Exsanguination
				if( firstHitHeavyBash && witcher.HasAbility('Runeword 21 _Stats', true) )
					 ((CActor)action.victim).ApplyBleeding(5, witcher, "Exsanguination");
				
				action.processedDmg.vitalityDamage *= 0.8f;
				action.processedDmg.essenceDamage *= 0.8f;
			}
			else
			if( action.GetAttackName() == 'geralt_heavy_special2' )
			{
				action.processedDmg.vitalityDamage *= 0.6f;
				action.processedDmg.essenceDamage *= 0.6f;
				
				if (action.WasDodged())
					return;
				
				action.SetHitAnimationPlayType(EAHA_ForceYes);				
				if( firstHitHeavyBash && npcTarget.HasShieldedAbility())
				{				
					if (npcTarget.HasAbility('SkillShieldHard'))
						shieldBreakChance = 15;
					else
						shieldBreakChance = 25;
					
					if (RandRange(100, 0) <= shieldBreakChance)
					{
						npcTarget.ProcessShieldDestruction();
						action.AddEffectInfo(EET_Stagger);
					}
				}
				
				if( action.DealsAnyDamage() )
				{
					if (firstHitHeavyBashSuccess)
					{
						if ( action.IsCriticalHit() || RandRange(100, 0) <= 50 )
							action.SetForceInjury(true);
					}
					else
					{
						if ( (action.IsCriticalHit() && RandRange(100, 0) <= 50) || (!action.IsCriticalHit() && RandRange(100, 0) <= 25 ) )
							action.SetForceInjury(true);
					}
					//Kolaris - Exsanguination
					if( firstHitHeavyBash && witcher.HasAbility('Runeword 21 _Stats', true) )
						ExsanguinateAction(action);
				}
				
				if( firstHitHeavyBash && action.DealsAnyDamage() && !IsImmuneToFinisher(npcTarget) && npcTarget.GetHealthPercents() < 0.25f && !IsUsingBattleAxe() && !IsUsingBattleMace() && !IsUsingSecondaryWeapon() )
				{
					npcTarget.AddEffectDefault(EET_CounterStrikeHit, witcher, "ReflexParryPerformed");
					witcher.SetCachedAct(npcTarget);
					witcher.AddTimer('FinishTarget', 0.3f, false);
					witcher.ClearCustomOrientationInfoStack();
					witcher.SetSlideTarget(npcTarget);
					witcher.SetMoveTarget(npcTarget);
					witcher.RaiseForceEvent('PerformCounter');
					witcher.OnCombatActionStart();
				}
				
				firstHitHeavyBashSuccess = false;				
				firstHitHeavyBash = false;
			}
		}
	}
	
	public function GetWolvenEffect() : W3Effect_WolfSetParry
	{
		return ((W3Effect_WolfSetParry)GetWitcherPlayer().GetBuff(EET_WolfSetParry, "BearSetBonus2"));
	}
	
	public function ProcessSecondaryEffects( out attackAction : W3Action_Attack, actorAttacker : CActor )
	{
		var blockCrushValue, disarmChance, disarmShieldChance : SAbilityAttributeValue;
		var npcTarget : CNewNPC;
		
		if( !actorAttacker || (CPlayer)attackAction.victim )
			return;
		
		disarmShieldChance = actorAttacker.GetAttributeValue('shield_disarm_chance');
		blockCrushValue = actorAttacker.GetAttributeValue('damage_through_blocks');
		disarmChance = actorAttacker.GetAttributeValue('disarm_chance');
		npcTarget = (CNewNPC)attackAction.victim;
		
		if( attackAction && attackAction.IsActionMelee() && (W3PlayerWitcher)actorAttacker )
		{
			//Kolaris - Sundering Strikes
			blockCrushValue.valueMultiplicative += 0.05f * ((W3PlayerWitcher)actorAttacker).GetSkillLevel(S_Sword_s06);
		}
		if( attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && !attackAction.IsCountered() )
		{
			if( npcTarget && (npcTarget.HasTwoHandedWeapon() || npcTarget.IsShielded(attackAction.attacker)) )
			{
				attackAction.SetAllProcessedDamageAs(0);
			}
			else
			{
				if( npcTarget && RandF() <= disarmChance.valueMultiplicative )
					npcTarget.ProcessWeaponDisarm();
				attackAction.MultiplyAllDamageBy(MinF(blockCrushValue.valueMultiplicative, 1.f));
				attackAction.SetHitAnimationPlayType(EAHA_ForceNo);
			}
			
			if( npcTarget && npcTarget.IsShielded(attackAction.attacker) && RandF() <= disarmShieldChance.valueMultiplicative )
			{
				npcTarget.ProcessShieldDestruction();
				attackAction.AddEffectInfo(EET_Stagger);
			}
		}
	}
	//Kolaris - Enemy Special Attacks
	public function ProcessEnemyAoESpecialAttacks( out attackAction : W3Action_Attack, actorAttacker : CActor )
	{
		if( GetEnemyAoESpecialAttackType(actorAttacker) > 0 )
		{
			attackAction.MultiplyAllDamageBy(0.2f);
			attackAction.SetIgnoreArmor(true);
			attackAction.RemoveBuffsByType(EET_Poison);
			if( !(actorAttacker.HasTag('sq202_djinn')) )
			{
				attackAction.SetForceInjury(true);
			}
		}
	}
	
	public function GetEnemyAoESpecialAttackType( actorAttacker : CActor ) : int
	{
		var npcAttacker : CNewNPC;
		var attackName : name;
		
		npcAttacker = (CNewNPC)actorAttacker;
		attackName = actorAttacker.GetLastAttackRangeName();
		//theGame.GetGuiManager().ShowNotification(attackName);
		
		if( npcAttacker.HasAbility('mon_vampiress_base') && (attackName == 'scream' || attackName == 'scream_blast') )
			return 2;
		else if( npcAttacker.HasAbility('mon_nightwraith_banshee') && (attackName == 'scream' || attackName == 'shout') )
			return 2;
		else if( (npcAttacker.HasAbility('mon_fleder') || npcAttacker.HasAbility('mon_garkain')) && attackName == 'aoeVeryFar' )
			return 2;
		else if( npcAttacker.HasAbility('mon_ghoul_base') && attackName == 'wideAreaOfEffect' )
			return 2;
		else if( npcAttacker.HasAbility('mon_gryphon_base') && attackName == 'wideAreaOfEffect' )
			return 2;
		else if( npcAttacker.HasAbility('mon_siren_base') && attackName == 'scream' )
			return 2;
		else if( npcAttacker.HasTag('sq202_djinn') && attackName == 'rangeVeryFar' )
			return 2;
		else if( npcAttacker.HasAbility('mon_golem_base') && attackName == 'wide_arc' )
			return 1;
		else if( (npcAttacker.HasAbility('mon_cyclops') || npcAttacker.HasAbility('mon_ice_giant') || npcAttacker.HasAbility('mon_q701_giant')) && attackName == 'stomp' )
			return 1;
		else
			return 0;
	}
	
	public function AttackCameraShake( attackName : name, shouldShake : bool )
	{
		if( !shouldShake )
			return;
			
		if( IsUsingBattleAxe() || IsUsingBattleMace() )
		{
			if( thePlayer.IsLightAttack(attackName) )
			{
				GCameraShake(0.2f, false, thePlayer.GetWorldPosition(), 10,,, 1.25f);
			}
			else
			if( thePlayer.IsHeavyAttack(attackName) )
			{
				GCameraShake(0.275f, false, thePlayer.GetWorldPosition(), 10,,, 1.25f);
			}
		}
		else
		{
			if( thePlayer.IsLightAttack(attackName) )
			{
				GCameraShake(0.125f, false, thePlayer.GetWorldPosition(), 10,,, 1.25f);
			}
			else
			if( thePlayer.IsHeavyAttack(attackName) )
			{
				GCameraShake(0.2f, false, thePlayer.GetWorldPosition(), 10,,, 1.25f);
			}
		}
	}
	
	private function GetHitArea( action : W3Action_Attack ) : name
	{
		var hitBoneIndex : int;
		
		hitBoneIndex = action.GetHitBoneIndex();
		switch(hitBoneIndex)
		{
			case 4:
			case 5:
			case 6:
			case 7:
			case 12:
				return 'UpperBody';
			
			case 3:
			case 8:
			case 9:
			case 10:
			case 11:
			case 13:
			case 14:
			case 15:
			case 16:
				return 'MidBody';
			
			case 0:
			case 1:
			case 2:
				return 'LowerBody';
				
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
			case 24:
				return 'Legs';
		}
	}
	
	public function GetDismembermentTypes( action : W3Action_Attack ) : array<name>
	{
		var dismembermentTypes : array<name>;
		var swingType, swingDir : int;
		var hitArea : name;
		
		hitArea = GetHitArea(action);
		swingType = action.GetSwingType();
		swingDir = action.GetSwingDirection();
		switch(swingType)
		{
			case 0:
				if(swingDir == 3)
				{
					if( hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_head');
						dismembermentTypes.PushBack('cut_neck');
						dismembermentTypes.PushBack('cut_head2');
					}
					if( hitArea == 'MidBody' || hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('gash_03');
						dismembermentTypes.PushBack('cut_forearm1_finisher');
					}
					if( hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('cut_torso2');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
				else
				if(swingDir == 2)
				{
					if( hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_head');
						dismembermentTypes.PushBack('cut_neck');
						dismembermentTypes.PushBack('cut_head2');
					}
					if( hitArea == 'MidBody' || hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('gash_03');
						dismembermentTypes.PushBack('cut_forearm2_finisher');
					}
					if( hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('cut_torso2');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
			return dismembermentTypes;
			
			case 1:
				if(swingDir == 1 || swingDir == 0)
				{
					if( hitArea == 'UpperBody' || hitArea == 'MidBody' )
					{
						dismembermentTypes.PushBack('gash_01');
						dismembermentTypes.PushBack('cut_arm');
						dismembermentTypes.PushBack('cut_arm2');
					}
				}
			return dismembermentTypes;
			
			case 2:
				if(swingDir == 3)
				{
					if( hitArea == 'MidBody' || hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('gash_03');
					}
					if( hitArea == 'MidBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_torso3');
						dismembermentTypes.PushBack('cut_torso4');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
				else
				if(swingDir == 2)
				{
					if( hitArea == 'MidBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_torso1');
						dismembermentTypes.PushBack('cut_torso5');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
					}
				}
			return dismembermentTypes;
			
			case 3:
				if(swingDir == 3)
				{
					if( hitArea == 'MidBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_torso1');
						dismembermentTypes.PushBack('cut_torso5');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
					}
				}
				else
				if(swingDir == 2)
				{
					if( hitArea == 'MidBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('gash_02');
						dismembermentTypes.PushBack('cut_torso3');
						dismembermentTypes.PushBack('cut_torso4');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
			return dismembermentTypes;
			
			case 4:
				if(swingDir == 1 || swingDir == 0)
				{
					if( hitArea == 'UpperBody' )
						dismembermentTypes.PushBack('gash_01');
				}
			return dismembermentTypes;
			
			default: return dismembermentTypes;
		}
	}
	
	private function GetFinisherDirection() : name
	{
		if( theInput.GetActionValue( 'GI_AxisLeftX' ) > 0 )
			return 'Right';
		else
		if( theInput.GetActionValue( 'GI_AxisLeftX' ) < 0 )
			return 'Left';
		else
		if( theInput.GetActionValue( 'GI_AxisLeftY' ) > 0 )
			return 'Forward';
		else
		if( theInput.GetActionValue( 'GI_AxisLeftY' ) < 0 )
			return 'Back';
		else
			return 'Static';
	}
	
	public function GetFinisherAnimsForDirection() : array<name>
	{
		var leftStance : bool;
		var direction : name;
		var finisherArray : array<name>;
		var headtakerEffect : W3Effect_SwordBehead;
		
		((W3Effect_SwordDesperateAct)GetWitcherPlayer().GetBuff(EET_SwordDesperateAct)).RestoreStatsExecution();
		headtakerEffect = (W3Effect_SwordBehead)GetWitcherPlayer().GetBuff(EET_SwordBehead);
		leftStance = thePlayer.GetCombatIdleStance() <= 0.f;
		direction = GetFinisherDirection();
		if( leftStance )
		{
			switch(direction)
			{
				case 'Left':
					finisherArray.PushBack('man_finisher_02_lp');
					finisherArray.PushBack('man_finisher_07_lp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Right':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_dlc_arm_lp');
						finisherArray.PushBack('man_finisher_dlc_head_rp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_dlc_head_rp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
				
				case 'Forward':
					finisherArray.PushBack('man_finisher_08_lp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Back':
					finisherArray.PushBack('man_finisher_dlc_legs_lp');
					finisherArray.PushBack('man_finisher_dlc_torso_lp');
				return finisherArray;
				
				case 'Static':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_01_rp');
						finisherArray.PushBack('man_finisher_04_lp');
						finisherArray.PushBack('man_finisher_06_lp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_01_rp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
			}
		}
		else
		{
			switch(direction)
			{
				case 'Left':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_02_lp');
						finisherArray.PushBack('man_finisher_07_lp');
						finisherArray.PushBack('man_finisher_dlc_arm_rp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_02_lp');
						finisherArray.PushBack('man_finisher_07_lp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
				
				case 'Right':
					finisherArray.PushBack('man_finisher_dlc_head_rp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Forward':
					finisherArray.PushBack('man_finisher_dlc_neck_rp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Back':
					finisherArray.PushBack('man_finisher_dlc_legs_rp');
					finisherArray.PushBack('man_finisher_dlc_torso_rp');
				return finisherArray;
				
				case 'Static':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_01_rp');
						finisherArray.PushBack('man_finisher_03_rp');
						finisherArray.PushBack('man_finisher_05_rp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_01_rp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
			}
		}
	}
	
	private var numberOfYrdens : int;
	private var slowdownID : int;
	private var isSlowdownActive : bool;
	default slowdownID = -1;
	public function EnchantedGlyphsSkill( yrden : W3YrdenEntity, activate : bool, entity : CEntity )
	{
		var witcher : W3PlayerWitcher;
		var npc : CNewNPC;
		var slowdownAmount, shakeAmount : float;
		var fx : CEntity;
		var sp : SAbilityAttributeValue;
		
		witcher = (W3PlayerWitcher)entity;
		npc = (CNewNPC)entity;
		
		if( activate )
		{
			if( npc )
			{
				npc.SoundEvent('sign_yrden_shock_activate');
				fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_yrden');
			}
			else
			if( witcher )
			{
				if( isSlowdownActive )
				{
					numberOfYrdens += 1;
				}
				else
				{
					numberOfYrdens = 1;
					isSlowdownActive = true;
					sp = ((W3SignEntity)yrden).GetTotalSignIntensity();
					slowdownAmount = 1 - 0.15f;
					//Kolaris - Griffin Set Bonus
					if( witcher.IsSetBonusActive(EISB_Gryphon_1) )
						slowdownAmount -= 0.1f;
					theGame.SetTimeScale(slowdownAmount, theGame.GetTimescaleSource(ETS_Yrden), theGame.GetTimescalePriority(ETS_Yrden));
					slowdownID = witcher.SetAnimationSpeedMultiplier(1, slowdownID);
					GCameraShake(0.06f);
				}
			}
		}
		else
		{
			if( witcher && isSlowdownActive )
			{
				if( numberOfYrdens > 1 )
				{
					numberOfYrdens -= 1;
				}
				else
				{
					numberOfYrdens = 0;
					isSlowdownActive = false;
					GetWitcherPlayer().ResetAnimationSpeedMultiplier(slowdownID);
					theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Yrden));
					GCameraShake(0.06f);
				}
			}
		}
	}
	
	public function ForceEndGlyphsSkill()
	{
		if( numberOfYrdens < 1 )
		{
			isSlowdownActive = false;
			GetWitcherPlayer().ResetAnimationSpeedMultiplier(slowdownID);
			theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Yrden));
		}
	}
	
	public function EnchantedGlyphsAlt( action : W3DamageAction, yrdenEntity : W3YrdenEntity )
	{
		var slowdownEffect : SCustomEffectParams;
		var witcher : W3PlayerWitcher;
		var actorVictim : CActor;
		var skillLevel : int;
		var fx : CEntity;
		var sp : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		actorVictim = ((CActor)action.victim);
		
		//Kolaris - Enervation
		if( witcher.HasAbility('Glyphword 16 _Stats', true) || witcher.HasAbility('Glyphword 17 _Stats', true) || witcher.HasAbility('Glyphword 18 _Stats', true) )
		{
			actorVictim.ApplyPoisoning(RoundMath(CalculateAttributeValue(witcher.GetAttributeValue('glyph_poison_bonus'))), witcher, "Enervation");
		}
		
		skillLevel = witcher.GetSignOwner().GetSkillLevel(S_Magic_s16, (W3SignEntity)yrdenEntity);
		sp = ((W3SignEntity)yrdenEntity).GetTotalSignIntensity();
		if( witcher && skillLevel >= 1)
		{
			slowdownEffect.effectType = EET_Slowdown;
			slowdownEffect.creator = witcher;
			slowdownEffect.sourceName = "S_Magic_s16";
			slowdownEffect.duration = 2.f * witcher.GetPlayerSignDurationMod();
			slowdownEffect.effectValue.valueAdditive = 0.03f * skillLevel * sp.valueMultiplicative;
			actorVictim.AddEffectCustom(slowdownEffect);
			
			fx = actorVictim.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_yrden');
			fx.PlayEffect('critical_yrden');
			fx = actorVictim.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_yrden');
			fx.PlayEffect('mutation_1_hit_yrden');
		}
	}
	
	public function EruptionEffect( action : W3DamageAction )
	{
		var witcher : W3PlayerWitcher;
		var actorVictim : CActor;
		
		witcher = GetWitcherPlayer();
		actorVictim = ((CActor)action.victim);
		//Kolaris - Purgation
		if( action.attacker == witcher && (witcher.HasAbility('Glyphword 11 _Stats', true) || witcher.HasAbility('Glyphword 12 _Stats', true)) && ((W3IgniProjectile)action.causer || actorVictim.HasBuff(EET_Burning)) )
		{
			if( !((W3IgniProjectile)action.causer).IsProjectileFromChannelMode() )
			{
				theGame.GetSurfacePostFX().AddSurfacePostFXGroup(actorVictim.GetWorldPosition(), 0.5f, 40, 10, 5, 1);
				actorVictim.AddTimer('Runeword1DisableFireFX', 4.f);
				actorVictim.PlayEffect('critical_burning');
				actorVictim.PlayEffect('critical_burning_csx');
				actorVictim.CreateFXEntityAndPlayEffect('mutation2_critical', 'critical_igni');
				actorVictim.CreateFXEntityAtPelvis('glyphword_20_explosion', true);
			}
		}
	}
	
	private var getShouldIgniExplode : bool;
	public function EruptionGlyphword( action : W3DamageAction )
	{
		var burning : SCustomEffectParams;
		var witcher : W3PlayerWitcher;
		var actors : array<CActor>;
		var actorVictim : CActor;
		var i : int;
		var explosion : W3DamageAction;
		var sp : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		actorVictim = ((CActor)action.victim);
		//Kolaris - Purgation
		if( action.attacker == witcher && (witcher.HasAbility('Glyphword 11 _Stats', true) || witcher.HasAbility('Glyphword 12 _Stats', true)) && ((W3IgniProjectile)action.causer || actorVictim.HasBuff(EET_Burning)) )
		{
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(actorVictim.GetWorldPosition(), 0.5f, 40, 10, 5, 1);
			actorVictim.AddTimer('Runeword1DisableFireFX', 4.f);
			actorVictim.PlayEffect('critical_burning');
			actorVictim.PlayEffect('critical_burning_csx');
			actorVictim.CreateFXEntityAndPlayEffect('mutation2_critical', 'critical_igni');
			actorVictim.CreateFXEntityAtPelvis('glyphword_20_explosion', true);
			
			getShouldIgniExplode = true;
			sp = ((W3IgniProjectile)action.causer).GetSignEntity().GetTotalSignIntensity();
			GCameraShake(0.4f);
			//actorVictim.SoundEvent("bomb_dancing_star_explo");
			actors = GetActorsInRange(actorVictim, 5, 100,, true);
			burning.effectType = EET_Burning;
			burning.creator = witcher;
			burning.sourceName = "Glyphword 11";
			burning.duration = 4.f * sp.valueMultiplicative;
			burning.effectValue.valueAdditive = 105.f * sp.valueMultiplicative;
			action.SetForceExplosionDismemberment();
			
			for(i=0; i<actors.Size(); i+=1)
			{
				if(IsRequiredAttitudeBetween(thePlayer, actors[i], true, false, false))
				{
					actors[i].CreateFXEntityAndPlayEffect('mutation2_critical', 'critical_igni');
					explosion = new W3DamageAction in this;
					explosion.Initialize(thePlayer, actors[i], action.causer, "Glyphword 11", EHRT_Heavy, CPS_SpellPower, false, false, true, false);
					explosion.AddDamage(theGame.params.DAMAGE_NAME_FIRE, 1500 * sp.valueMultiplicative);
					theGame.damageMgr.ProcessAction(explosion);
					delete explosion;
				
					if( !actors[i].HasBuff(EET_Burning) )
					{
						actors[i].AddEffectCustom(burning);
					}
				}
			}
		}
	}
	//Kolaris - Electrocution
	public function QuenJoltSkill( quen : W3QuenEntity )
	{
		var witcher : W3PlayerWitcher;
		var shock : W3DamageAction;
		var targets : array<CActor>;
		var damage : float;
		var i, chargeCount, range : int;
		var fx : CEntity;
		var sp, min, max : SAbilityAttributeValue;
		var electrocutionEffect : W3Effect_RunewordElectrocution;
		
		witcher = (W3PlayerWitcher)quen.GetOwner();
		electrocutionEffect = (W3Effect_RunewordElectrocution)witcher.GetBuff(EET_RunewordElectrocution);
		chargeCount = 0;
		chargeCount += electrocutionEffect.GetDisplayCount();
		
		if( witcher && witcher.HasAbility('Runeword 30 _Stats', true) && chargeCount > 0 )
		{
			sp = ((W3SignEntity)quen).GetTotalSignIntensity();
			damage = 200.f * sp.valueMultiplicative * chargeCount;
			
			range = 5;
			targets = GetActorsInRange(witcher, range, 100, , true);
			for(i=0; i<targets.Size(); i+=1)
			{
				if( (W3PlayerWitcher)targets[i] || targets[i].GetAttitude(witcher) == AIA_Friendly || targets[i].GetAttitude(witcher) == AIA_Neutral )
					continue;
					
				shock = new W3DamageAction in theGame.damageMgr;
				shock.Initialize(witcher, targets[i], quen, 'Runeword 30', EHRT_Heavy, CPS_SpellPower, false, false, true, false);	
				
				shock.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, damage);
				shock.SetForceExplosionDismemberment();
				shock.SetCannotReturnDamage(true);
				shock.SetCanPlayHitParticle(true);
				shock.SetHitEffect('hit_electric_quen');
				shock.SetHitEffect('hit_electric_quen', true);
				shock.SetHitEffect('hit_electric_quen', false, true);
				shock.SetHitEffect('hit_electric_quen', true, true);
				shock.AddEffectInfo(EET_Electroshock);
				GCameraShake(0.3f);
				fx = targets[i].CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_quen');
				fx = targets[i].CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_quen');
				
				theGame.damageMgr.ProcessAction(shock);
				delete shock;
			}
			
			quen.PlayEffect('quen_force_discharge');
			
			if( chargeCount == 10 )
			{
				witcher.PlayEffect('quen_force_discharge_bear_abl2_armour');
				witcher.QuenImpulse(false, quen, "Runeword 30" );
			}
			
			electrocutionEffect.ResetCounter();
		}
	}
	
	public function GetSignSkillDismember( action : W3DamageAction ) : bool
	{
		if( (W3PlayerWitcher)action.attacker && (W3IgniProjectile)action.causer /*&& !((W3IgniProjectile)action.causer).GetSignEntity().IsAlternateCast()*/ && getShouldIgniExplode )
			return true;
		else
		if( (W3YrdenEntityStateYrdenShock)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s11, (W3SignEntity)(((W3YrdenEntityStateYrdenShock)action.causer).GetParent())) )
			return true;
		else
		if( (W3QuenEntity)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s15, (W3QuenEntity)action.causer) )
			return true;
			
		return false;
	}
	
	public function GetSkillDismemberType( action : W3DamageAction ) : EDismembermentEffectTypeFlags
	{
		if( (W3PlayerWitcher)action.attacker && (W3IgniProjectile)action.causer && getShouldIgniExplode )
			return DETF_Igni;
		else
		if( (W3YrdenEntityStateYrdenShock)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s11, (W3SignEntity)(((W3YrdenEntityStateYrdenShock)action.causer).GetParent())) )
			return DETF_Yrden;
		else
		if( (W3QuenEntity)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s15, (W3QuenEntity)action.causer) )
			return DETF_Quen;
			
		return 0;
	}
	
	public function SeveranceRunewordStaminaAbsorb( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		//Kolaris - Exhilaration
		if( witcher.HasAbility('Runeword 31 _Stats', true) || witcher.HasAbility('Runeword 32 _Stats', true) || witcher.HasAbility('Runeword 33 _Stats', true) )
		{
			if( witcher.IsInCombatAction_SpecialAttack() )
			{
				witcher.GainStat(BCS_Stamina, witcher.GetStatMax(BCS_Stamina) * 0.2f * Options().StamCostGlobal());
				witcher.PlayEffect('runeword_10_stamina');
			}
		}
	}
	
	public function SeveranceRunewordRangeExtension() : bool
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if( witcher.HasAbility('Runeword 1 _Stats', true) )
		{
			return true;
		}
		return false;
	}
	//Kolaris - Invocation
	public function SeveranceRunewordSignEffect( infusion : ESignType )
	{
		var infusionType : ESignType;
		var witcher : W3PlayerWitcher;
		var weaponEntity : CEntity;
		var slotMatrix : Matrix;
		var actors : array<CActor>;
		var i : int;
		var yrden : W3YrdenEntity;
		var yrdenAlternate : W3YrdenEntityStateYrdenShock;
		
		witcher = GetWitcherPlayer();
		infusionType = infusion;
		if( witcher.HasAbility('Runeword 42 _Stats', true) )
		{
			if( witcher.IsInCombatAction_SpecialAttack())
			{
				weaponEntity = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
				if( witcher.IsInCombatAction_SpecialAttackHeavy() && RandF() < witcher.GetSpecialAttackTimeRatio() * 1.3f )
				{
					switch(infusionType)
					{
						case ST_Aard:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_aard');
						break;
						
						case ST_Axii:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							witcher.PlayEffectSingle('drain_energy_caretaker_shovel');
							actors = witcher.GetNPCsAndPlayersInCone(3, VecHeading(witcher.GetHeadingVector()), 90, 20, , FLAG_OnlyAliveActors);
							for(i=0; i<actors.Size(); i+=1)
							{
								if( !((W3PlayerWitcher)actors[i]) )
								{
									actors[i].DrainStamina(ESAT_FixedValue, actors[i].GetStat(BCS_Stamina) * 0.4f, 4.f);
									actors[i].AddEffectDefault(EET_Stagger, witcher, "Runeword 40", true);
									witcher.GainStat(BCS_Stamina, witcher.GetStatMax(BCS_Stamina) * 0.4f);
								}
							}
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_axii');
						break;
						
						case ST_Igni:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_igni');
						break;
						
						case ST_Quen:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							if( witcher.IsQuenActive(false) )
							{
								((W3QuenEntity)witcher.GetSignEntity(ST_Quen)).PlayHitEffect('quen_rebound_sphere_bear_abl2', witcher.GetWorldRotation());
								witcher.QuenImpulse( true, (W3QuenEntity)witcher.GetSignEntity(ST_Quen), "Runeword 40", VecHeading(MatrixGetTranslation(slotMatrix) - witcher.GetWorldPosition()) );
							}
							else
							{
								witcher.CastDesiredSign(infusionType, true, true, false, witcher.GetWorldPosition(), witcher.GetWorldRotation());
								((W3QuenEntity)witcher.GetSignEntity(ST_Quen)).PlayHitEffect('quen_rebound_sphere_bear_abl2', witcher.GetWorldRotation());
								witcher.QuenImpulse( true, (W3QuenEntity)witcher.GetSignEntity(ST_Quen), "Runeword 40", VecHeading(MatrixGetTranslation(slotMatrix) - witcher.GetWorldPosition()) );
							}
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_quen');
						break;
						
						case ST_Yrden:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, true, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							yrden = (W3YrdenEntity)GetWitcherPlayer().GetSignEntity(ST_Yrden);
							yrdenAlternate = (W3YrdenEntityStateYrdenShock)yrden.GetCurrentState();
							actors = witcher.GetNPCsAndPlayersInCone(5, VecHeading(witcher.GetHeadingVector()), 90, 20, , FLAG_OnlyAliveActors);
							for(i=0; i<actors.Size(); i+=1)
							{
								if( !((W3PlayerWitcher)actors[i]) )
								{
									((CNewNPC)actors[i]).SetCanGlyphHit(true);
									yrdenAlternate.SetWardingGlyphTargets((CNewNPC)actors[i]);
								}
							}
							//witcher.SetRunewordInfusionType(ST_None);
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_yrden');
							//weaponEntity.StopEffect('runeword_yrden');
						break;
					}
				}
				else if( RandF() < 0.05f )
				{
					switch(infusionType)
					{
						case ST_Aard:
							witcher.CastDesiredSign(infusionType, true, true, false, witcher.GetWorldPosition(), witcher.GetWorldRotation());
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_aard');
						break;
						
						case ST_Axii:
							actors = GetActorsInRange(witcher, 5, 10,, true);
							ApplyAxiiEffect(witcher, actors);
							witcher.PlayEffectSingle('drain_energy_caretaker_shovel');
							actors = witcher.GetNPCsAndPlayersInCone(3, VecHeading(witcher.GetHeadingVector()), 110, 20, , FLAG_OnlyAliveActors);
							for(i=0; i<actors.Size(); i+=1)
							{
								if( !((W3PlayerWitcher)actors[i]) )
								{
									actors[i].DrainStamina(ESAT_FixedValue, actors[i].GetStat(BCS_Stamina) * 0.2f, 2.f);
									actors[i].AddEffectDefault(EET_Stagger, witcher, "Runeword 40", true);
									witcher.GainStat(BCS_Stamina, witcher.GetStatMax(BCS_Stamina) * 0.1f);
								}
							}
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_axii');
						break;
						
						case ST_Igni:
							actors = GetActorsInRange(witcher, 5, 10,, true);
							ApplyIgniEffect(witcher, actors);
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_igni');
						break;
						
						case ST_Quen:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							if( witcher.IsQuenActive(false) )
							{
								witcher.PlayEffect('quen_force_discharge');
								witcher.QuenImpulse( false, (W3QuenEntity)witcher.GetSignEntity(ST_Quen), "Runeword 40");
							}
							else
							{
								witcher.CastDesiredSign(infusionType, true, true, false, witcher.GetWorldPosition(), witcher.GetWorldRotation());
								witcher.QuenImpulse( true, (W3QuenEntity)witcher.GetSignEntity(ST_Quen), "Runeword 40");
							}
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_quen');
						break;
						
						case ST_Yrden:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, true, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							yrden = (W3YrdenEntity)GetWitcherPlayer().GetSignEntity(ST_Yrden);
							yrdenAlternate = (W3YrdenEntityStateYrdenShock)yrden.GetCurrentState();
							actors = GetActorsInRange(witcher, 5, 20,, true);
							for(i=0; i<actors.Size(); i+=1)
							{
								if( !((W3PlayerWitcher)actors[i]) )
								{
									((CNewNPC)actors[i]).SetCanGlyphHit(true);
									yrdenAlternate.SetWardingGlyphTargets((CNewNPC)actors[i]);
								}
							}
							//witcher.SetRunewordInfusionType(ST_None);
							//weaponEntity.StopEffect('runeword_yrden');
						break;
					}
				}
			}
			//witcher.infusionCooldown = true;
			//witcher.AddTimer('InfusionCooldown', 15.f, false);
		}
	}
	
	public function ApplyAxiiEffect( witcher : W3PlayerWitcher, actors : array<CActor> )
	{
		var fx : CEntity;
		var i : int;
		
		fx = witcher.CreateFXEntityAtPelvis('glyphword_10_18', true);
		fx.PlayEffect('out');
		
		for(i=0; i<actors.Size(); i+=1)
		{
			if( witcher != actors[i] && RandRange(100, 0) > 50 )
			{
				actors[i].AddEffectDefault(EET_Confusion, witcher, "Runeword 40", true);
				fx = actors[i].CreateFXEntityAtPelvis('glyphword_10_18', true);
				fx.PlayEffect('axii_extra_time');
				fx.PlayEffect('in');
			}
		}
	}
	
	public function ApplyIgniEffect( witcher : W3PlayerWitcher, actors : array<CActor> )
	{
		var fireEffect : W3DamageAction;
		var fx : CEntity;
		var i : int;
		
		for(i=0; i<actors.Size(); i+=1)
		{
			if( witcher != actors[i] )
			{
				fireEffect = new W3DamageAction in theGame;
				fireEffect.Initialize(witcher, actors[i], witcher, "Runeword 40", EHRT_None, CPS_SpellPower, false, false, true, false);
				fireEffect.SetCannotReturnDamage(true);
				fireEffect.SetCanPlayHitParticle(false);
				fireEffect.SetHitAnimationPlayType(EAHA_ForceNo);		
				fireEffect.AddDamage(theGame.params.DAMAGE_NAME_FIRE, 500);
				theGame.damageMgr.ProcessAction(fireEffect);
				delete fireEffect;
				
				//actors[i].PlayEffect('demonic_possession');
				//((CNewNPC)actors[i]).AddTimer('StopPossessionEffect', 2.5f, false);
				actors[i].AddEffectDefault(EET_Burning, witcher, "Runeword 40", true);
				fx = actors[i].CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_igni');
				fx = actors[i].CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_igni');
			}
		}
	}
	
	public function ObliterationRunewordEffectAttack( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var fireEffect : W3DamageAction;
		var position : Vector;
		var totalDmg : float;
		var npc : CNewNPC;
		var weaponEntity, sparks, fx : CEntity;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.HasAbility('Runeword 7 _Stats', true) || witcher.HasAbility('Runeword 8 _Stats', true) || witcher.HasAbility('Runeword 9 _Stats', true) )
		{
			if( attackAction.IsActionMelee() && attackAction.DealsAnyDamage() )
			{
				npc = (CNewNPC)attackAction.victim;
				if( witcher.HasAbility('Runeword 6 _Stats', true) )
					totalDmg = attackAction.GetDamageDealt() * 0.05f;
				else
				if( witcher.HasAbility('Runeword 10 _Stats', true) )
					totalDmg = attackAction.GetDamageDealt() * 0.065f;
				else
				if( witcher.HasAbility('Runeword 4 _Stats', true) )
					totalDmg = attackAction.GetDamageDealt() * 0.075f;
				
				fireEffect = new W3DamageAction in theGame;
				fireEffect.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
				fireEffect.SetCannotReturnDamage(true);
				fireEffect.SetCanPlayHitParticle(false);
				fireEffect.SetHitAnimationPlayType(EAHA_ForceNo);		
				fireEffect.AddDamage(theGame.params.DAMAGE_NAME_FIRE, totalDmg);
				if( witcher.HasAbility('Runeword 6 _Stats', true) )
				{
					position = npc.GetWorldPosition();
					position.Z += 0.4f;
					sparks = theGame.CreateEntity((CEntityTemplate)LoadResource('sword_colision_fx'), position);
					sparks.PlayEffect('sparks');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
				}
				else
				if( witcher.HasAbility('Runeword 10 _Stats', true) )
				{
					attackAction.victim.AddTimer('Runeword1DisableFireFX', 1.f);	
					attackAction.victim.PlayEffect('critical_burning');
					attackAction.victim.PlayEffect('critical_burning_csx');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
				}
				else
				if( witcher.HasAbility('Runeword 4 _Stats', true) )
				{
					fx = npc.CreateFXEntityAtPelvis('mutation2_critical', true);
					fx.PlayEffect('critical_igni');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
					npc.SoundEvent('sign_igni_charge_begin');
				}
				
				theGame.damageMgr.ProcessAction(fireEffect);
				delete fireEffect;
			}
		}
	}
	
	public function ObliterationRunewordEffectBlock( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var fireEffect : W3DamageAction;
		var totalDmg : float;
		var npc : CNewNPC;
		var matrix : Matrix;
		var sparks, fx, weapon : CEntity;
		
		witcher = (W3PlayerWitcher)attackAction.victim;
		if( witcher.HasAbility('Runeword 7 _Stats', true) )
		{
			weapon = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
			weapon.CalcEntitySlotMatrix('blood_fx_point', matrix);
			sparks = theGame.CreateEntity((CEntityTemplate)LoadResource('sword_colision_fx'), MatrixGetTranslation(matrix));
			sparks.PlayEffect('sparks');
		}
		else
		if( witcher.HasAbility('Runeword 8 _Stats', true) || witcher.HasAbility('Runeword 9 _Stats', true) )
		{
			npc = (CNewNPC)attackAction.attacker;
			if( attackAction.IsParried() && attackAction.IsActionMelee() )
			{
				if( witcher.HasAbility('Runeword 8 _Stats', true) )
					totalDmg = 160.f;
				else
				if( witcher.HasAbility('Runeword 9 _Stats', true) )
					totalDmg = 220.f;
				
				fireEffect = new W3DamageAction in theGame;
				fireEffect.Initialize(attackAction.victim, attackAction.attacker, NULL, attackAction.GetBuffSourceName(), EHRT_Light, CPS_Undefined, false, false, false, true);
				fireEffect.SetCannotReturnDamage(true);
				fireEffect.SetCanPlayHitParticle(false);
				fireEffect.SetHitAnimationPlayType(EAHA_ForceNo);
				fireEffect.AddDamage(theGame.params.DAMAGE_NAME_FIRE, totalDmg);
				
				weapon = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
				weapon.CalcEntitySlotMatrix('blood_fx_point', matrix);
				sparks = theGame.CreateEntity((CEntityTemplate)LoadResource('sword_colision_fx'), MatrixGetTranslation(matrix));
				sparks.PlayEffect('sparks');
				sparks.DestroyAfter(2.f);
				
				if( witcher.HasAbility('Runeword 8 _Stats', true) )
				{
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
				}
				else
				{
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
					attackAction.attacker.AddTimer('Runeword1DisableFireFX', 0.5f);	
					attackAction.attacker.PlayEffect('critical_burning');
					attackAction.attacker.PlayEffect('critical_burning_csx');
				}
				
				theGame.damageMgr.ProcessAction(fireEffect);
				delete fireEffect;
			}
		}
	}
	
	public function ObliterationRunewordLvl1Flame(count : int)
	{
		var witcher : W3PlayerWitcher;
		var weaponEntity : CEntity;
		
		witcher = GetWitcherPlayer();
		if( witcher.HasAbility('Runeword 7 _Stats', true) || witcher.HasAbility('Runeword 8 _Stats', true) || witcher.HasAbility('Runeword 9 _Stats', true) )
		{
			weaponEntity = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
			weaponEntity.PlayEffectSingle('runeword_igni');
			weaponEntity.StopAllEffectsAfter(0.1f * count);
		}
	}
	
	private var getShouldRunewordExplode : bool;
	public function ObliterationRunewordExplosion( attackAction : W3Action_Attack, optional criticalHit : bool )
	{
		var witcher : W3PlayerWitcher;
		var actor : CActor;
		var actors : array<CActor>;
		var explosion : W3DamageAction;
		var i, chance : int;
		var effects : array<EEffectType>;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		chance = 5 * ((W3Effect_RunewordObliteration)witcher.GetBuff(EET_RunewordObliteration)).GetDisplayCount();
		if( criticalHit )
			chance = FloorF(chance * 0.4f);
		actor = (CActor)attackAction.victim;
		getShouldRunewordExplode = false;
		if( witcher && witcher.HasAbility('Runeword 9 _Stats', true) && attackAction.IsActionMelee() && RandRange(100, 0) < chance )
		{
			ObliterationRunewordGroundFX(attackAction);
			GCameraShake(1.f, false, thePlayer.GetWorldPosition(),,,, 0.85f);
			attackAction.SetForceExplosionDismemberment();
			actor.CreateFXEntityAndPlayEffect('mutation_2_explode', 'mutation_2_igni');
			actor.SoundEvent("bomb_dancing_star_explo");
			getShouldRunewordExplode = true;
			
			actors = GetActorsInRange(actor, 5, 20,, true);
			explosion = new W3DamageAction in theGame;
			effects.PushBack(EET_Stagger);
			effects.PushBack(EET_LongStagger);
			for(i=0; i<actors.Size(); i+=1)
			{
				if( witcher != actors[i] )
				{
					if( RandRange(2, 0) < 1 )
					{
						actors[i].AddTimer('Runeword1DisableFireFX', 5.f);
						actors[i].PlayEffect('critical_burning');
						actors[i].PlayEffect('critical_burning_csx');
					}
					else
					{
						actors[i].CreateFXEntityAndPlayEffect('mutation2_critical', 'critical_igni');
					}
					explosion.Initialize(witcher, actors[i], NULL, attackAction.GetBuffSourceName(), EHRT_Heavy, CPS_Undefined, false, false, false, true);
					explosion.SetCannotReturnDamage(true);
					explosion.SetCanPlayHitParticle(true);
					explosion.SetForceExplosionDismemberment();
					explosion.AddEffectInfo(effects[RandRange(effects.Size(), 0)]);
					explosion.AddDamage(theGame.params.DAMAGE_NAME_FIRE, 1000);
					theGame.damageMgr.ProcessAction(explosion);
				}
			}
			delete explosion;
		}
	}
	
	public function GetObliterationRunewordDism( action : W3DamageAction ) : bool
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)action.attacker;
		if( witcher && witcher.HasAbility('Runeword 4 _Stats', true) && action.IsActionMelee() && getShouldRunewordExplode )
			return true;
		
		return false;
	}
	
	public function GetObliterationDismType( action : W3DamageAction ) : EDismembermentEffectTypeFlags
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)action.attacker;
		if( witcher && witcher.HasAbility('Runeword 4 _Stats', true) && action.IsActionMelee() && getShouldRunewordExplode )
			return DETF_Igni;
		
		return 0;
	}
	
	public function ObliterationRunewordGroundFX( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var chargeCount : int;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		chargeCount = ((W3Effect_RunewordObliteration)witcher.GetBuff(EET_RunewordObliteration)).GetDisplayCount();
		
		theGame.GetSurfacePostFX().AddSurfacePostFXGroup(attackAction.victim.GetWorldPosition(), 0.5f, 40, 3 + chargeCount * 0.5f, 5, 1);
	}
	
	public function GetShouldTargetExplode() : bool
	{
		return getShouldRunewordExplode || getShouldIgniExplode;
	}
	
	//Kolaris - Prolongation
	public function BereavementRunewordAttack( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var shockEffect : W3DamageAction;
		var totalDmg : float;
		var npc : CNewNPC;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.HasAbility('Runeword 39 _Stats', true) )
		{
			if( attackAction.IsActionMelee() )
			{
				npc = (CNewNPC)attackAction.victim;
				totalDmg = attackAction.GetDamageDealt() * 0.1f;
				
				shockEffect = new W3DamageAction in theGame;
				shockEffect.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
				shockEffect.SetCannotReturnDamage(true);
				shockEffect.SetCanPlayHitParticle(false);
				shockEffect.SetHitAnimationPlayType(EAHA_ForceNo);
				shockEffect.AddDamage(theGame.params.DAMAGE_NAME_ELEMENTAL, totalDmg);
				
				theGame.damageMgr.ProcessAction(shockEffect);
				delete shockEffect;
			}
		}
	}
	
	public function WolfQuenBonusAttack( attackAction : W3Action_Attack, out dmgInfo : array<SRawDamage> )
	{
		var witcher : W3PlayerWitcher;
		var shockEffect : W3DamageAction;
		var totalDmg : float;
		var npc : CNewNPC;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.IsSetBonusActive(EISB_Wolf_2) && attackAction.IsActionMelee() && witcher.IsAnyQuenActive() )
		{
			dmgInfo.PushBack(SRawDamage(theGame.params.DAMAGE_NAME_SHOCK, 1, 1.f));
			npc = (CNewNPC)attackAction.victim;
			totalDmg = attackAction.GetDamageDealt() * 0.125f;
			
			shockEffect = new W3DamageAction in theGame;
			shockEffect.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
			shockEffect.SetCannotReturnDamage(true);
			shockEffect.SetCanPlayHitParticle(false);
			shockEffect.SetHitAnimationPlayType(EAHA_ForceNo);
			shockEffect.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, totalDmg);
			
			theGame.damageMgr.ProcessAction(shockEffect);
			delete shockEffect;
		}
	}
	
	public function SetPerkArmorBonuses()
	{
		var item : SItemUniqueId;
		var armors : array<SItemUniqueId>;
		var light, medium, heavy, i, cnt, j : int;
		var armorType : EArmorType;
		var witcher : W3PlayerWitcher;
		var inventory : CInventoryComponent;
		var skills : array<ESkill>;
		
		skills.PushBack(S_Perk_05);
		skills.PushBack(S_Perk_06);
		skills.PushBack(S_Perk_07);
		
		witcher = GetWitcherPlayer();
		for(j=0; j<3; j+=1)
		{
			if( !witcher.CanUseSkill( skills[j] ) )
			{
				cnt = 0;
			}
			else
			{
				
				armors.Resize(4);
				if( witcher.GetItemEquippedOnSlot(EES_Armor, item) )
					armors[0] = item;
					
				if( witcher.GetItemEquippedOnSlot(EES_Boots, item) )
					armors[1] = item;
					
				if( witcher.GetItemEquippedOnSlot(EES_Pants, item) )
					armors[2] = item;
					
				if( witcher.GetItemEquippedOnSlot(EES_Gloves, item) )
					armors[3] = item;
				
				light = 0;
				medium = 0;
				heavy = 0;
				inventory = witcher.GetInventory();
				for(i=0; i<armors.Size(); i+=1)
				{
					armorType = inventory.GetArmorTypeOriginal(armors[i]);
					if(armorType == EAT_Light)
						light += 1;
					else if(armorType == EAT_Medium)
						medium += 1;
					else if(armorType == EAT_Heavy)
						heavy += 1;
				}
				
				if( skills[j] == S_Perk_05 )
					cnt = light;
				else
				if( skills[j] == S_Perk_06 )
					cnt = medium;
				else
					cnt = heavy;
			}
			
			UpdateArmorPerks(skills[j], cnt);
			witcher.UpdateEncumbrance();
		}
	}
	
	private function UpdateArmorPerks( skill : ESkill, count : int )
	{
		var abilityName : name;
		var charStats : CCharacterStats;
		
		charStats = GetWitcherPlayer().GetCharacterStats();
		abilityName = GetWitcherPlayer().GetSkillAbilityName(skill);
		charStats.RemoveAbilityAll( abilityName );
		if( count > 0 )
			charStats.AddAbilityMultiple( abilityName, count );
	}
	
	public function IsUsingSecondaryWeapon() : bool
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		
		return inv.ItemHasTag(inv.GetItemFromSlot('r_weapon'), 'SecondaryWeapon');
	}
	
	public function IsUsingBattleAxe() : bool
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		
		return inv.ItemHasTag(inv.GetItemFromSlot('r_weapon'), 'TypeBattleaxe');
	}
	
	public function IsUsingBattleMace() : bool
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		
		return inv.ItemHasTag(inv.GetItemFromSlot('r_weapon'), 'TypeBattlemace');
	}
	
	public function IsUsingShield() : W3DLCShield
	{
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		
		return (W3DLCShield)inv.GetItemEntityUnsafe(inv.GetItemFromSlot('l_weapon'));
	}
	
	public function CripplingShotEffects( action : W3DamageAction )
	{
		var witcher : W3PlayerWitcher;
		var skillLevel : int;
		
		witcher = (W3PlayerWitcher)action.attacker;
		skillLevel = witcher.GetSkillLevel(S_Sword_s12);
		
		//Kolaris - New Moon Set
		if( witcher && witcher.IsSetBonusActive(EISB_New_Moon) && action.IsActionRanged() && action.DealsAnyDamage() && ((W3ThrowingKnife)(action.causer)) && (CNewNPC)action.victim && ((CNewNPC)action.victim).IsAttacking() )
		{
			action.AddEffectInfo(EET_Confusion);
		}
		
		if( witcher && action.IsActionRanged() && action.DealsAnyDamage() && skillLevel >= 1 )
		{
			if( skillLevel >= 1 && action.IsCriticalHit() )
			{
				if( RandRange(100, 0) <= 10.f * skillLevel )
					action.AddEffectInfo(EET_Stagger);
			}
		}
	}
	
	private var compatibleDamage : name;
	private var infusionDamage, dischargeTime : float;
    private var dimeritiumInfusion : EArmorInfusionType;
    
    default dischargeTime = 15;
    default dimeritiumInfusion = EAIT_None;
    
    private function InfusionTypeToDamage( infusion : EArmorInfusionType ) : name
    {
		switch(infusion)
		{
			case EAIT_Shock :	return theGame.params.DAMAGE_NAME_SHOCK;
			case EAIT_Fire :	return theGame.params.DAMAGE_NAME_FIRE;
			case EAIT_Ice :		return theGame.params.DAMAGE_NAME_FROST;
			default: return 'none';
		}
    }
    
    private function InfusionTypeToEffect( infusion : EArmorInfusionType ) : name
    {
		switch(infusion)
		{
			case EAIT_Shock :	return 'runeword_yrden';
			case EAIT_Fire :	return 'runeword_igni';
			case EAIT_Ice :		return 'runeword_aard';
			default: return 'none';
		}
    }
    
    private function SignTypeToInfusion( signType : ESignType ) : EArmorInfusionType
    {
		switch(signType)
		{
			case ST_Yrden :
			case ST_Quen :		return EAIT_Shock;
			
			case ST_Igni :		return EAIT_Fire;
			
			case ST_Axii :
			case ST_Aard :		return EAIT_Ice;
			
			case ST_None :
			default : return EAIT_None;
		}
    }
    
    private function IsDamageTypeCompatible( action : W3DamageAction ) : bool
    {
		var i, DTCount : int;
		var damages : array <SRawDamage>;
		
		DTCount = action.GetDTs(damages);
		for(i=0; i<DTCount; i+=1)
		{
			switch(damages[i].dmgType)
			{
				case theGame.params.DAMAGE_NAME_ELEMENTAL :
				case theGame.params.DAMAGE_NAME_SHOCK :
				case theGame.params.DAMAGE_NAME_FIRE :
				case theGame.params.DAMAGE_NAME_FROST :
					compatibleDamage = damages[i].dmgType; return true;
			}
		}
		
		return false;
    }
    
    private function PlayInfusionHitEffect( type : EArmorInfusionType, victim : CEntity )
    {
		var fx : CEntity;
		
		switch(type)
		{
			case EAIT_Shock :
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_yrden');
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_yrden');
			break;
			
			case EAIT_Fire :
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_igni');
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_igni');
				victim.AddTimer('Runeword1DisableFireFX', 2.5f);
				victim.PlayEffect('critical_burning');
				victim.PlayEffect('critical_burning_csx');
			break;
			
			case EAIT_Ice :
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_aard');
				victim.PlayEffect('critical_frozen');
				((CNewNPC)victim).AddTimer( 'StopMutation6FX', 4.f );
			break;
		}
    }
    
    private function SetInfusionType( type : EArmorInfusionType )
    {
		dimeritiumInfusion = type;
    }
    
    private function GetInfusionType() : EArmorInfusionType
    {
		return dimeritiumInfusion;
    }
    
    private function GetInfusionDamage() : float
    {
		return infusionDamage;
    }
    
	private function SignTypeToSkillType( signType : ESignType ) : ESkill
	{
		switch(signType)
		{
			case ST_Aard :		return S_Magic_1;
			case ST_Igni :		return S_Magic_2;
			case ST_Yrden :		return S_Magic_3;
			case ST_Quen : 		return S_Magic_4;
			case ST_Axii :		return S_Magic_5;
			default: return S_SUndefined;
		}
	}
	
    public function SetInfusionVariables( player : W3PlayerWitcher, signType : ESignType )
    {
		var spellPower : SAbilityAttributeValue;
		var infusionType : EArmorInfusionType;
		
		if( player.IsSetBonusActive(EISB_Dimeritium2) && ((W3Effect_DimeritiumCharge)player.GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).GetDisplayCount() >= 3 )
		{
			spellPower = player.GetTotalSignSpellPower(SignTypeToSkillType(signType));
			infusionDamage = 240.f * spellPower.valueMultiplicative;
			infusionType = SignTypeToInfusion(signType);
			
			SetInfusionType(infusionType);
			PlayInfusionEffect();
			player.AddTimer('RemoveWeaponCharge', dischargeTime, , , , , true);
		}
    }
    
    public function DealInfusionDamage( action : W3DamageAction )
    {
		var infusionDamage : W3DamageAction;
		var infusionType : EArmorInfusionType;
		var surface	: CGameplayFXSurfacePost;
		
		infusionType = GetInfusionType();
		if( (W3PlayerWitcher)action.attacker && action.IsActionMelee() && infusionType != EAIT_None && ((W3PlayerWitcher)action.attacker).IsSetBonusActive(EISB_Dimeritium2) )
		{
			infusionDamage = new W3DamageAction in theGame;
			infusionDamage.Initialize( action.attacker, action.victim, action.causer, action.GetBuffSourceName(), EHRT_Heavy, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
			infusionDamage.SetCannotReturnDamage(true);
			infusionDamage.SetCanPlayHitParticle(false);
			infusionDamage.SetHitAnimationPlayType(EAHA_ForceYes);
			infusionDamage.AddDamage(InfusionTypeToDamage(infusionType), GetInfusionDamage());
			
			surface = theGame.GetSurfacePostFX();
			switch(infusionType)
			{
				case EAIT_Shock :
					
				break;
				
				case EAIT_Fire :
					surface.AddSurfacePostFXGroup(action.victim.GetWorldPosition(), 5, 40, 10, 4, 1);
				break;
				
				case EAIT_Ice :
					surface.AddSurfacePostFXGroup(action.victim.GetWorldPosition(), 2, 40, 6, 3.5f, 0);
				break;
			}
			
			RemoveInfusionEffects();
			PlayInfusionHitEffect(infusionType, action.victim);
			PlayInfusionSound(infusionType, (CActor)GetWitcherPlayer());
			theGame.damageMgr.ProcessAction(infusionDamage);
			delete infusionDamage;
		}
    }
    
    public function PlayInfusionSound( type : EArmorInfusionType, actor : CActor )
    {
		switch(type)
		{
			case EAIT_Shock :
				actor.SoundEvent('sign_yrden_shock_activate');
			break;
			
			case EAIT_Fire :
				actor.SoundEvent('sign_igni_charge_begin');
			break;
			
			case EAIT_Ice :
				actor.SoundEvent('bomb_white_frost_explo');
			break;
		}
    }
    
    public function RemoveInfusionEffects()
    {
		var weapon : CItemEntity;
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		weapon = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('r_weapon'));
		weapon.StopEffect('runeword_aard');
		weapon.StopEffect('runeword_igni');
		weapon.StopEffect('runeword_yrden');
		SetInfusionType(EAIT_None);
    }
    
    public function PlayInfusionEffect()
    {
		var weapon : CItemEntity;
		var inv : CInventoryComponent;
		var infusionType : EArmorInfusionType;
		
		infusionType = GetInfusionType();
		if( infusionType != EAIT_None )
		{
			inv = GetWitcherPlayer().GetInventory();
			weapon = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('r_weapon'));
			weapon.StopEffect('runeword_aard');
			weapon.StopEffect('runeword_igni');
			weapon.StopEffect('runeword_yrden');
			weapon.PlayEffect(InfusionTypeToEffect(infusionType));
		}
    }
    
    public function BlockingStaggerImmunityCheck( playerVictim : CR4Player, out action : W3DamageAction, attackAction : W3Action_Attack ) : bool
    {
		if( playerVictim && attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && (((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Gothic1) || /*((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Bear_1) ||*/ (((W3PlayerWitcher)playerVictim).HasBuff(EET_Tiara) && ((W3PlayerWitcher)playerVictim).GetPotionBuffLevel(EET_Tiara) == 3) || RandRange(100, 1) < 10 * ((W3PlayerWitcher)playerVictim).GetSkillLevel(S_Sword_s03) ) )
			return true;
		
		return false;
    }
    
    public function BlockingStaggerImmunity( playerVictim : CR4Player, out action : W3DamageAction, attackAction : W3Action_Attack )
    {
		if( playerVictim && attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Gothic1) )
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
			action.processedDmg.vitalityDamage /= 2;
		}
    }
    
    public function KnockdownNegation( actor : CActor, out effectType : EEffectType )
    {
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if( actor == witcher && witcher.IsSetBonusActive(EISB_Gothic2) )
		{
			if( effectType == EET_Knockdown )
				effectType = EET_Stagger;
			else
			if( effectType == EET_HeavyKnockdown )
				effectType = EET_LongStagger;
		}
    }
    
    public function ShouldIgniStagger( action : W3DamageAction ) : bool
    {
		var npcVictim : CNewNPC;
		npcVictim = (CNewNPC)action.victim;
		
		return !(npcVictim.IsHuge() || RandRange(100,0) > 30 || npcVictim.GetOpponentType() == MC_Insectoid);
    }
    
    public function PlayHitDamageEffects( attackAction : W3Action_Attack, dmgInfos : array<SRawDamage>, playerAttacker : CR4Player, actorVictim : CActor )
    {
		var template : CEntityTemplate;
		var pos : Vector;
		var fx : CEntity;
		var i : int;
		
		if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && attackAction.DealsAnyDamage() && attackAction.GetAttackName() != 'geralt_kick_special' )
		{
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL )
				{
					actorVictim.PlayEffect('yrden_shock');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_SHOCK )
				{
					if( RandRange(100, 0) <= 5 || ( ( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 28 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 29 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 30 _Stats', true) ) && RandRange(100, 0) <= 10 ) )
						actorVictim.AddEffectDefault(EET_Electroshock, playerAttacker, "shockdamage");
					actorVictim.SoundEvent("sign_yrden_shock_activate");
					template = (CEntityTemplate)LoadResource('sword_colision_fx');
					pos = actorVictim.GetWorldPosition();
					pos.Z += 0.4f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.X += 0.1f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.Y -= 0.1f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.X -= 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.Y -= 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.Y += 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.X += 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE )
				{
					actorVictim.AddTimer('Runeword1DisableFireFX', 0.25f);
					actorVictim.PlayEffect('critical_burning');
					actorVictim.PlayEffect('critical_burning_csx');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FROST )
				{
					((CNewNPC)actorVictim).AddTimer('StopMutation6FX', 0.6f);
					actorVictim.PlayEffect('critical_frozen');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON )
				{
					actorVictim.AddTimer('DisablePoisonFX', 0.25f);
					actorVictim.PlayEffect('critical_poison');
				}
			}
		}
    }
    
    public function GetSafeDodgeAngle() : int
    {
		var angle : int;
		var angleBonus : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		angleBonus = witcher.GetAttributeValue('safe_dodge_angle_bonus');
		//Kolaris - Footwork, Kolaris - Positioning
		angle = 90 + 20 * witcher.GetSkillLevel(S_Perk_16) + (int)angleBonus.valueAdditive;
		
		return angle;
    }
    
    var linkedActors : array<CActor>;
    public function CacheAxiiLinkActors( finalTargets : array<CActor> )
    {
		var i : int;
		linkedActors.Clear();
		linkedActors.Resize(finalTargets.Size());
		for(i=0; i<finalTargets.Size(); i+=1)
			linkedActors[i] = finalTargets[i];
    }
    
    public function CullAxiiLinkActors( actor : CActor, effectInteraction : EEffectInteract )
    {
		var idx : int;
		if( effectInteraction == EI_Deny )
		{
			idx = linkedActors.FindFirst(actor);
			linkedActors.EraseFast(idx);
		}
    }
	
	//Kolaris - Conjunction
	public function DoesAxiiLinkContainActor(actor : CActor) : bool
	{
		if( linkedActors.Contains(actor) )
			return true;
		else
			return false;
	}
	
	public function ProcessConjunctionEffects( effect : CBaseGameplayEffect, originalTarget : CActor )
	{
		var i : int;
		
		if( GetWitcherPlayer().HasAbility('Glyphword 25 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 26 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 27 _Stats', true) )
		{
			for( i=0; i<linkedActors.Size(); i+=1 )
			{
				if( linkedActors[i] == originalTarget || effect.GetSourceName() == "Glyphword25" )
					continue;
				
				if( RandF() < 1.f / (linkedActors.Size() + 1) )
				{
					if( effect.GetEffectType() == EET_Bleeding )
						linkedActors[i].ApplyBleeding(1, GetWitcherPlayer(), "Glyphword25", false);
					else if( effect.GetEffectType() == EET_Poison )
						linkedActors[i].ApplyPoisoning(1, GetWitcherPlayer(), "Glyphword25", false);
					else if( effect.GetEffectType() == EET_Burning || effect.GetEffectType() == EET_Blindness || effect.GetEffectType() == EET_Confusion || effect.GetEffectType() == EET_Paralyzed || effect.GetEffectType() == EET_Hypnotized || effect.GetEffectType() == EET_Frozen || effect.GetEffectType() == EET_Immobilized )
						linkedActors[i].AddEffectDefault(effect.GetEffectType(), GetWitcherPlayer(), "Glyphword25", true);
				}
			}
		}
	}
	
	public function ProcessConjunctionDamage( action : W3DamageAction ) : float
	{
		var axiiDamage : W3DamageAction;
		var witcherVictim : W3PlayerWitcher;
		var enemyActors, targetActors : array<CActor>;
		var i : int;
		var outgoingDamage : float;
		
		witcherVictim = (W3PlayerWitcher)action.victim;
		for( i=0; i<linkedActors.Size(); i+=1 )
		{
			if(linkedActors[i].IsAlive())
				targetActors.PushBack(linkedActors[i]);
		}
		enemyActors = GetActorsInRange(witcherVictim, 25, 100, , true);
		for( i=0; i<enemyActors.Size(); i+=1 )
		{
			if(enemyActors[i].HasBuff(EET_AxiiGuardMe) && !targetActors.Contains(enemyActors[i]))
				targetActors.PushBack(enemyActors[i]);
		}
		
		outgoingDamage = action.processedDmg.vitalityDamage * (1.f - targetActors.Size() * 0.1f);
		
		if( targetActors.Size() > 0 )
		{
			for( i=0; i<targetActors.Size(); i+=1 )
			{
				axiiDamage = new W3DamageAction in theGame.damageMgr;
				axiiDamage.Initialize(action.attacker, targetActors[i], action.causer, "Conjunction", action.GetHitReactionType(), CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment());
				axiiDamage.SetCanPlayHitParticle(false);
				axiiDamage.SetCannotReturnDamage(true);
				axiiDamage.SetSuppressHitSounds(true);
				axiiDamage.AddDamage(theGame.params.DAMAGE_NAME_MENTAL, outgoingDamage * 0.1f );
				theGame.damageMgr.ProcessAction(axiiDamage);
				delete axiiDamage;
			}
		}
		
		return outgoingDamage;
	}
    
    public function ProcessAxiiLink( action : W3DamageAction )
    {
		var axiiLinkReaction : W3DamageAction;
		var witcherAttacker : W3PlayerWitcher;
		var effectTypes : array<EEffectType>;
		var npcVictim : CNewNPC;
		var size, i, j : int;
		
		witcherAttacker = (W3PlayerWitcher)action.attacker;
		if( !witcherAttacker || action.GetBuffSourceName() == "AxiiLink" || !witcherAttacker.CanUseSkill(S_Magic_s18) )
			return;
		
		npcVictim = (CNewNPC)action.victim;
		if( !linkedActors.Contains(npcVictim) )
			return;
		
		for(i=0; i<linkedActors.Size(); i+=1)
		{
			//Kolaris - Conjunction
			if( linkedActors[i] == npcVictim || !linkedActors[i].IsAlive() || (RandRange(100, 0) > witcherAttacker.GetSkillLevel(S_Magic_s18) * 15.f && !(witcherAttacker.HasAbility('Glyphword 26 _Stats', true) || witcherAttacker.HasAbility('Glyphword 27 _Stats', true))) )
				continue;
				
			axiiLinkReaction = new W3DamageAction in theGame.damageMgr;
			axiiLinkReaction.Initialize(action.attacker, linkedActors[i], action.causer, "AxiiLink", action.GetHitReactionType(), CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment());
			axiiLinkReaction.SetHitAnimationPlayType(EAHA_ForceYes);
			axiiLinkReaction.SetCanPlayHitParticle(false);
			axiiLinkReaction.SetCannotReturnDamage(true);
			axiiLinkReaction.SetSuppressHitSounds(true);
			
			action.GetEffectTypes(effectTypes);
			if( RandRange(100, 0) <= 10.f * witcherAttacker.GetSkillLevel(S_Magic_s18) && (effectTypes.Contains(EET_Stagger) || effectTypes.Contains(EET_LongStagger) || effectTypes.Contains(EET_Knockdown)) )
			{
				axiiLinkReaction.SetHitAnimationPlayType(EAHA_ForceNo);
				axiiLinkReaction.AddEffectInfo(EET_Stagger);
			}
			//Kolaris - Conjunction
			if(!action.GetCannotReturnDamage() && (witcherAttacker.HasAbility('Glyphword 26 _Stats', true) || witcherAttacker.HasAbility('Glyphword 27 _Stats', true)))
			{
				axiiLinkReaction.AddDamage(theGame.params.DAMAGE_NAME_MENTAL, action.processedDmg.vitalityDamage / linkedActors.Size() );
				for(j=0; j<linkedActors.Size(); j+=1)
				{
					if( !linkedActors[j].IsAlive() )
					{
						axiiLinkReaction.AddDamage(theGame.params.DAMAGE_NAME_MENTAL, action.processedDmg.vitalityDamage / linkedActors.Size() );
					}
				}
			}
			theGame.damageMgr.ProcessAction(axiiLinkReaction);
			delete axiiLinkReaction;
		}
		// Lazarus - End
    }
    
	var PuppetCount : int;	default PuppetCount = 0;
	public function SetPuppetCount( increment : int )
	{
		PuppetCount += increment;
	}
	
	public function GetPuppetCount() : int
	{
		return PuppetCount;
	}
	
	private function OilToRealDamageType( oilDamageType : name ) : name
    {
        switch(oilDamageType)
        {
			//Kolaris - Poisonous Oil
			case 'oil_poison_effect'	:		return theGame.params.DAMAGE_NAME_POISON;
            case 'oil_ethereal_damage'	:      	return theGame.params.DAMAGE_NAME_ELEMENTAL;
			case 'oil_stamina_damage'	:		return theGame.params.DAMAGE_NAME_STAMINA;
			case 'oil_frost_damage'		:		return theGame.params.DAMAGE_NAME_FROST;
            default: return 'None';
        }
    }
	
	public function SilverOilBurn( actorVictim : CActor, playerAttacker : CR4Player, action : W3DamageAction, oilInfo : SOilInfo )
	{
		if( playerAttacker && actorVictim && actorVictim.UsesEssence() && action.IsActionMelee() && action.DealsAnyDamage() && oilInfo.activeIndex[6] )
		{
			actorVictim.AddEffectDefault(EET_SilverBurn, playerAttacker, "ArgentiaOil", false);
		}
	}
	
	public function InitializeOilInfo( playerAttacker : CR4Player ) : SOilInfo
    {
        var i, j : int;
        var weaponId : SItemUniqueId;
        var oils : array<W3Effect_Oil>;
		var attributeValueEmpt : SAbilityAttributeValue;
        var appliedOilName : name;
		var npc : CNewNPC;
		var oilPotency : float;
		var oilInfos : SOilInfo;
		
        weaponId = ((W3PlayerWitcher)playerAttacker).inv.GetCurrentlyHeldWeapon();
        oils = ((W3PlayerWitcher)playerAttacker).inv.GetOilsAppliedOnItem(weaponId);
        if( oils.Size() > 0 )
        {			
			oilInfos.attributeNames.PushBack('oil_corrosive_armor_reduction'); 	//0 - corrosive
            oilInfos.attributeNames.PushBack('oil_poison_effect'); 				//1 - poisonous
			oilInfos.attributeNames.PushBack('oil_bleed_effect');				//2 - brown
            oilInfos.attributeNames.PushBack('oil_ethereal_damage');			//3 - veil
			oilInfos.attributeNames.PushBack('oil_stamina_damage');				//4 - paralysis
			oilInfos.attributeNames.PushBack('oil_frost_damage');				//5 - rime
			oilInfos.attributeNames.PushBack('oil_silver');						//6 - argentia
			oilInfos.attributeNames.PushBack('oil_falka_injury_chance');		//7 - falka's blood
			oilInfos.attributeNames.PushBack('oil_flammable_effect');			//8 - flammable
			
			for( i=0; i<oilInfos.attributeNames.Size(); i+=1 )
			{
				oilInfos.attributeValuesOriginal.PushBack(attributeValueEmpt);
				oilInfos.attributeValues.PushBack(attributeValueEmpt);
				oilInfos.activeIndex.PushBack(false);
			}
			
            for(i=0; i<oils.Size(); i+=1)
            {
				
                appliedOilName = oils[i].GetOilItemName();
                for(j=0; j<oilInfos.attributeNames.Size(); j+=1)
                {
                    if( oils[i].GetAmmoCurrentCount() > 0 && theGame.GetDefinitionsManager().ItemHasAttribute(appliedOilName, true, oilInfos.attributeNames[j]) ) 
                    {	
						//oilInfos.appliedOilAttributeNames.PushBack(oilInfos.attributeNames[j]);
						//Kolaris - Potency
						oilPotency = 1.f + (playerAttacker.GetSkillLevel(S_Alchemy_s12) * 0.05f );
						
						//Kolaris - Viper Set
						if( oils.Size() >= 2 )
						{
							if( GetWitcherPlayer().IsSetBonusActive(EISB_Viper1) )
								oilPotency *= 0.75f + (0.05f * playerAttacker.GetSkillLevel(S_Alchemy_s07));
							else
								oilPotency *= 0.50f + (0.05f * playerAttacker.GetSkillLevel(S_Alchemy_s07));
						}
							
						oilInfos.attributeValuesOriginal[j] = ( GetWitcherPlayer().inv.GetItemAttributeValue(weaponId, oilInfos.attributeNames[j]) ) * oilPotency ;
						oilInfos.attributeValues[j] = oilInfos.attributeValuesOriginal[j] * (1.f - PowF(1.f - oils[i].GetAmmoPercentage(), 2) * (1.f - 0.05f * thePlayer.GetSkillLevel(S_Alchemy_s12))) ;
						oilInfos.activeIndex[j] = true;
						oilInfos.isActive = true;
                    }
                }
            }
        }
		return oilInfos;
    }

    public function ProcessOilEffects( attackAction : W3Action_Attack, oilInfos : SOilInfo, out dmgInfo : array<SRawDamage>, out arrSize : int, out actorVictim : CActor, victimMonsterCategory : EMonsterCategory, optional transmutationBomb : bool )
	{
		var i, j, blockDuration : int;
		//Kolaris - Transfusion
		var maxArmorReduction, reductionFactor, maxFireResReduction, transfusionVal : float;
		var npc : CNewNPC;
		var effectParams : SCustomEffectParams;
		var effectValue : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		//Kolaris - Viper Set
        var weaponId : SItemUniqueId;
        var oils : array<W3Effect_Oil>;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		//Kolaris - Transmutation
		if( !transmutationBomb )
		{
			if( !witcher || !attackAction.IsActionMelee() || attackAction.IsParried() || (witcher.GetIsBashing() && !witcher.IsHeavyAttack(attackAction.GetAttackName())) )
				return;
		}
		
		npc = (CNewNPC)actorVictim;
		
		//Kolaris - Transfusion
		if( witcher.CanUseSkill(S_Alchemy_s06) && ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks() > 0 )
			transfusionVal = 1.f + (0.01f * witcher.GetSkillLevel(S_Alchemy_s06) * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks());
		else
			transfusionVal = 1.f;
		
		//Kolaris - Strong Attack Oil Effectiveness
		if( witcher.IsHeavyAttack(attackAction.GetAttackName()) )
			transfusionVal += 0.2;
			
		//Kolaris - Viper Set
		if( attackAction.IsCriticalHit() )
		{
			transfusionVal += 0.5;
			
			if( witcher.IsSetBonusActive(EISB_Viper1) )
			{
				weaponId = witcher.GetInventory().GetCurrentlyHeldWeapon();
				oils = witcher.GetInventory().GetOilsAppliedOnItem(weaponId);
				transfusionVal += 0.25f * oils.Size();
			}
		}
		
		//Kolaris - Transmutation
		if( ((W3Effect_Poison)actorVictim.GetBuff(EET_Poison)).GetStacks() > 0 && witcher.HasAbility('Runeword 15 _Stats', true) )
			transfusionVal += 0.1f * ((W3Effect_Poison)actorVictim.GetBuff(EET_Poison)).GetStacks();
		
		if( oilInfos.isActive )
		{	
			//Corrosive oil
			if( oilInfos.activeIndex[0] && npc.npcStats.opponentType != MC_Specter )
			{
				//Kolaris - Corrosive Oil
				maxArmorReduction = oilInfos.attributeValues[0].valueMultiplicative * -10.f * transfusionVal;
				reductionFactor = oilInfos.attributeValues[0].valueMultiplicative * -1.f * transfusionVal;
				if( maxArmorReduction >= npc.GetTotalArmorReduction('Oil') )
					reductionFactor *= PowF( maxArmorReduction / npc.GetTotalArmorReduction('Oil'), 2 );
				if( witcher.IsLightAttack(attackAction.GetAttackName()) && witcher.GetBehaviorVariable('isPerformingSpecialAttack') > 0 )
					reductionFactor *= 0.25f;
				else if( witcher.IsLightAttack(attackAction.GetAttackName()) )
					reductionFactor *= 0.5f;
				npc.ModifyArmorValue(reductionFactor);
			}
			if( oilInfos.activeIndex[1] )
			{
				//Poisonous oil
				//Kolaris - Poisonous Oil
				dmgInfo.PushBack(SRawDamage(OilToRealDamageType(oilInfos.attributeNames[1]), RoundMath(oilInfos.attributeValues[1].valueBase * transfusionVal)));
				arrSize += 1;
				
				if( RandRange(100, 0) < (oilInfos.attributeValues[1].valueMultiplicative * 100.f * transfusionVal ) )
				{
					npc.ApplyPoisoning(RoundMath(oilInfos.attributeValues[1].valueAdditive), thePlayer, "Poisoning");
				}
			}
			if( oilInfos.activeIndex[3] || oilInfos.activeIndex[4] || oilInfos.activeIndex[5] ) 
			{
				//Veil Oil
				if( oilInfos.activeIndex[3] ) 
				{
					dmgInfo.PushBack(SRawDamage(OilToRealDamageType(oilInfos.attributeNames[3]), RoundMath(oilInfos.attributeValues[3].valueAdditive * transfusionVal)));
					arrSize += 1;
					
					blockDuration = RoundMath(oilInfos.attributeValues[3].valueAdditive * 0.08f * transfusionVal);
					
					//Leshen
					npc.BlockAbility('Shapeshifter', true, blockDuration);
					npc.BlockAbility('Summon', true, blockDuration);
					npc.BlockAbility('Swarms', true, blockDuration);
					
					//Wraiths
					if( !(npc.HasAbility('SilverDustEffect_Level1') || npc.HasAbility('SilverDustEffect_Level2') || npc.HasAbility('SilverDustEffect_Level3')) )
					{
						npc.BlockAbility('ShadowForm', true, blockDuration);
					}
					npc.BlockAbility('Specter', true, blockDuration);
					npc.BlockAbility('DustCloud', true, blockDuration);
					npc.BlockAbility('ContactBlindness', true, blockDuration);
					npc.BlockAbility('FlashStep', true, blockDuration);
					
					//Golems & Elementals
					npc.BlockAbility('Wave', true, blockDuration);
					npc.BlockAbility('GroundSlam', true, blockDuration);
					npc.BlockAbility('SpawnArena', true, blockDuration);
					npc.BlockAbility('ThrowFire', true, blockDuration);
					
					//Vampires
					npc.BlockAbility('Flashstep', true, blockDuration);
					npc.BlockAbility('Teleport', true, blockDuration);
					npc.BlockAbility('Scream', true, blockDuration);
					npc.BlockAbility('Invisibility', true, blockDuration);
					npc.BlockAbility('Hypnosis', true, blockDuration);
					
					//Water Hag
					npc.BlockAbility('MudTeleport', true, blockDuration);
					
					//Fogling
					npc.BlockAbility('MistForm', true, blockDuration);
					
					//Fiend
					npc.BlockAbility('BiesHypnosis', true, blockDuration);
					
					//Sorceress
					npc.BlockAbility('ablTeleport', true, blockDuration);
					
					//Wight
					npc.BlockAbility('WightTeleport', true, blockDuration);
					
					//Various From Dimeritium Bombs
					npc.BlockAbility('Doppelganger', true, blockDuration);
					npc.BlockAbility('Fireball', true, blockDuration);
					npc.BlockAbility('Magical', true, blockDuration);
					npc.BlockAbility('SwarmTeleport', true, blockDuration);
					npc.BlockAbility('SwarmShield', true, blockDuration);
					npc.BlockAbility('Frost', true, blockDuration);
					
					//Various From Monster Abilities
					npc.BlockAbility('FireShield', true, blockDuration);
					npc.BlockAbility('IceArmor', true, blockDuration);
					npc.BlockAbility('MagicShield', true, blockDuration);
					npc.BlockAbility('MistCharge', true, blockDuration);
					npc.BlockAbility('Shout', true, blockDuration);
					npc.BlockAbility('Thorns', true, blockDuration);
					npc.BlockAbility('ThrowIce', true, blockDuration);
					npc.BlockAbility('Tornado', true, blockDuration);
				
				}
				//Paralysis oil
				if( oilInfos.activeIndex[4] && npc.npcStats.opponentType != MC_Specter && npc.npcStats.opponentType != MC_Magicals )
				{
					dmgInfo.PushBack(SRawDamage(OilToRealDamageType(oilInfos.attributeNames[4]), RoundMath(oilInfos.attributeValues[4].valueAdditive * transfusionVal)));
					arrSize += 1;
					if( npc.GetStaminaPercents() < 0.10f && npc.GetIsRecoveringFromParalysis() == false )
					{
						effectParams.effectType = EET_Paralyzed;
						effectParams.duration = RoundMath(oilInfos.attributeValues[4].valueBase * transfusionVal);
						npc.AddEffectCustom(effectParams);
						npc.npcStats.spdMultID2 = npc.SetAnimationSpeedMultiplier(0.95f, npc.npcStats.spdMultID2);
						npc.SetIsRecoveringFromParalysis(true);
						npc.AddTimer('ParalysisRecovery', 20.f - (10.f * oilInfos.attributeValues[4].valueMultiplicative * transfusionVal), false, , , , true);
					}
					/*
					npc.AddTimer('RemoveParalysisSlowdown', 2.f, false, , , , true);
					*/
				}
				//Rime oil
				if( oilInfos.activeIndex[5] ) 
				{
					//Kolaris - Transfusion
					if( RandRange(100, 0) < (oilInfos.attributeValues[5].valueMultiplicative * 100.f * transfusionVal * (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FROST))) )
					{
						npc.AddEffectDefault(EET_SlowdownFrost, witcher, "RimeOil", false);
						if( !npc.GetIsFrozenEffectPlaying() )
						{
							npc.SetIsFrozenEffectPlaying(true);
							npc.PlayEffect('critical_frozen');
							npc.AddTimer('RemoveFreezeEffects', 3, false, , , , );
						}
						else
							npc.PlayEffect('ice_armor_hit');
					}
					
					dmgInfo.PushBack(SRawDamage(OilToRealDamageType(oilInfos.attributeNames[5]), RoundMath(oilInfos.attributeValues[5].valueAdditive * transfusionVal)));
					arrSize += 1;
				}
			}
			//Kolaris - Transfusion, Kolaris - Argentia Oil
			//Argentia oil
			if( oilInfos.activeIndex[6] && (npc.npcStats.opponentType == MC_Specter || npc.npcStats.opponentType == MC_Cursed || npc.npcStats.opponentType == MC_Vampire) )
			{
				effectParams.effectType = EET_SilverBurn;
				effectParams.creator = witcher;
				effectParams.sourceName = "ArgentiaOil";
				effectParams.duration = RoundMath(oilInfos.attributeValues[6].valueBase * transfusionVal);
				effectParams.effectValue.valueAdditive = oilInfos.attributeValues[6].valueAdditive * transfusionVal;
				effectParams.isSignEffect = false;
				npc.AddEffectCustom(effectParams);
				
				if( npc.npcStats.healthRegenFactor > 0 && npc.npcStats.regenDelay > 0 )
				{
					npc.StartRegenTimer(RoundMath(oilInfos.attributeValues[6].valueBase * transfusionVal));
				}
			}
			//Kolaris - Falka Oil, Kolaris - Tranfusion
			//Falka Oil
			if( oilInfos.activeIndex[7] )
			{
				if( RandRange(100, 0) < (oilInfos.attributeValues[7].valueMultiplicative * 100.f * transfusionVal * (1 - npc.GetPoiseValue())) )
				{
					if( npc.IsImmuneToBuff(EET_Stagger) )
						attackAction.SetHitAnimationPlayType(EAHA_ForceYes);
					else
						npc.AddEffectDefault(EET_Stagger, witcher, "FalkaOil", false);
				}
			}
			//Kolaris - Flammable Oil
			//Flammable oil
			if( oilInfos.activeIndex[8] && !(npc.npcStats.fireResist == 1.f) ) 
			{
				if( npc.GetBurnCounter() > 0.f )
				{
					reductionFactor = ( MinF( oilInfos.attributeValues[8].valueBase, npc.GetBurnCounter() ) ) * -1.f * transfusionVal;
					npc.IncBurnCounter( reductionFactor );
				}
				
				maxFireResReduction = oilInfos.attributeValuesOriginal[8].valueAdditive * 20.f * transfusionVal;
				reductionFactor = oilInfos.attributeValues[8].valueAdditive * -1.f * transfusionVal;
				if( maxFireResReduction < npc.GetTotalFireResistReduction() )
					reductionFactor = 0.f;
				npc.ModifyFireResistance(reductionFactor);
				
				if( RandRange(100, 0) < (oilInfos.attributeValues[8].valueMultiplicative * 100.f * transfusionVal * (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE))) )
				{
					npc.AddEffectDefault(EET_Burning, witcher, "FlammableOil", false);
				}
			}
			//Kolaris - Transmutation
			if( ( RandRange(100, 0) < 10.f * transfusionVal ) && (witcher.HasAbility('Runeword 13 _Stats', true) || witcher.HasAbility('Runeword 14 _Stats', true) || witcher.HasAbility('Runeword 15 _Stats', true)) )
			{
				npc.ApplyPoisoning(1, thePlayer, "Runeword13");
			}
		}
	}
	
	public function ApplyBleedStack( out action : W3Action_Attack, oilInfos : SOilInfo, actorAttacker : CActor, actorVictim : CActor )
	{
		var bleedChance : float = 0.2f;
		var bleedChanceAdd : SAbilityAttributeValue;
		var bleedStacksAdd : SAbilityAttributeValue = actorAttacker.GetAttributeValue('num_bleed_stacks');
		var attackAction : W3Action_Attack;
		
		if( (W3Petard)action.causer && oilInfos.activeIndex[2] && (((W3PlayerWitcher)actorAttacker).HasAbility('Runeword 13 _Stats', true) || ((W3PlayerWitcher)actorAttacker).HasAbility('Runeword 14 _Stats', true) || ((W3PlayerWitcher)actorAttacker).HasAbility('Runeword 15 _Stats', true)) )
			actorVictim.ApplyBleeding(RoundMath(oilInfos.attributeValues[2].valueMultiplicative * RoundMath(oilInfos.attributeValues[2].valueAdditive)), actorAttacker, "Bleeding");
		
		if( action.IsDoTDamage() || action.GetWasPartiallyDoged() || (W3Petard)action.causer || action.GetAppliedBleeding() || !action.DealsAnyDamage() || action.IsCountered() || action.IsPerfectParried() || (!action.IsActionMelee() && !action.IsActionRanged()) )
			return;
			
		if( actorAttacker.IsQuestActor() || actorVictim.IsQuestActor() || ((W3PlayerWitcher)actorVictim).IsAnyQuenActive() || (((W3PlayerWitcher)actorAttacker).IsWeaponHeld('fist') && !action.causer) )
			return;
			
		//Kolaris - Player Bleed
		if( (W3PlayerWitcher)actorVictim )
			bleedChance *= 2.5f;
		
		if( action.IsActionRanged() )
			bleedChance += 0.04f * ((CR4Player)actorAttacker).GetSkillLevel(S_Sword_s12);
		if( action.IsActionMelee() )
		{
			if( (W3PlayerWitcher)actorAttacker && oilInfos.activeIndex[2] )
			{
				//Brown oil
				//Kolaris - Transfusion
				if( ((CR4Player)actorAttacker).CanUseSkill(S_Alchemy_s06) && ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks() > 0 )
					bleedChanceAdd.valueAdditive = oilInfos.attributeValues[2].valueMultiplicative * (1.f + 0.01f * ((CR4Player)actorAttacker).GetSkillLevel(S_Alchemy_s06) * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks());
				else
					bleedChanceAdd.valueAdditive = oilInfos.attributeValues[2].valueMultiplicative;
				bleedStacksAdd.valueAdditive += RoundMath(RandRangeF(oilInfos.attributeValues[2].valueAdditive, 1));
			}
			
			bleedChance += 0.04f * ((CR4Player)actorAttacker).GetSkillLevel(S_Sword_s17);
			if( actorAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
			{
				bleedStacksAdd.valueAdditive += 2;
				bleedChance -= 0.1f;
			}
			else
			if( actorAttacker.IsLightAttack(attackAction.GetAttackName()) )
				bleedStacksAdd.valueAdditive += 1;
		}
		
		if( ((W3PlayerWitcher)actorAttacker).IsInCombatAction_SpecialAttackLight() )
			bleedChance *= 0.35f;
		
		if( bleedChance + bleedChanceAdd.valueAdditive > RandRangeF(1.f) )
		{
			if( (CR4Player)actorAttacker )
			{
				if( RandRange(100) <= 25 )
					((W3Effect_SwordBloodFrenzy)actorAttacker.GetBuff(EET_SwordBloodFrenzy)).SetFrenzyActive(true);
			}
			actorVictim.ApplyBleeding(RoundMath(bleedStacksAdd.valueAdditive), actorAttacker, "Bleeding");
			action.SetAppliedBleeding();
		}	
	}
	
	public function Mutation7Rend( action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var witcher : W3PlayerWitcher;
		var healthPerc, adrPerc : float;
		var fxEntity : CEntity;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		if( witcher.IsInCombatAction_SpecialAttackHeavy() && actorVictim && action.IsActionMelee() && witcher.IsMutationActive(EPMT_Mutation7) )
		{
			adrPerc = witcher.GetAdrenalineEffect().GetValue();
			healthPerc = actorVictim.GetStatPercents(actorVictim.GetUsedHealthType());
			if( adrPerc >= healthPerc )
			{
				if( !actorVictim.IsHuge() )
				{
					action.processedDmg.vitalityDamage += actorVictim.GetStat(actorVictim.GetUsedHealthType());
					action.processedDmg.essenceDamage += actorVictim.GetStat(actorVictim.GetUsedHealthType());
					witcher.GetAdrenalineEffect().ResetAdrenaline();
					fxEntity = witcher.CreateFXEntityAtPelvis('mutation7_flash', false);
					fxEntity.PlayEffect('buff');
					fxEntity.DestroyAfter(1.f);
					witcher.PlayEffect('mutation_7_baff');
					witcher.StopEffect('mutation_7_baff');
				}
				else
				{
					if( healthPerc <= 0.5f )
					{
						action.processedDmg.vitalityDamage += actorVictim.GetStat(actorVictim.GetUsedHealthType()) * (adrPerc / 2.f);
						action.processedDmg.essenceDamage += actorVictim.GetStat(actorVictim.GetUsedHealthType()) * (adrPerc / 2.f);
						witcher.GetAdrenalineEffect().ResetAdrenaline();
						fxEntity = witcher.CreateFXEntityAtPelvis('mutation7_flash', false);
						fxEntity.PlayEffect('buff');
						fxEntity.DestroyAfter(1.f);
						witcher.PlayEffect('mutation_7_baff');
						witcher.StopEffect('mutation_7_baff');
					}
				}
			}
		}
	}
	
	public function UndyingDamageReduction( action : W3DamageAction, playerVictim : CR4Player )
	{
		var adrenalineValue : float;
		if( playerVictim.GetStatPercents(BCS_Vitality) <= 0.5f && !action.IsDoTDamage() )
		{
			adrenalineValue = ((W3PlayerWitcher)playerVictim).GetAdrenalineEffect().GetFullValue();
			action.processedDmg.vitalityDamage = MaxF(0, action.processedDmg.vitalityDamage - adrenalineValue * playerVictim.GetSkillLevel(S_Sword_s18) * (1.f - playerVictim.GetStatPercents(BCS_Vitality) * 2));
		}
	}
	//Kolaris - Affinity
	public function AffinityDamageReduction( action : W3DamageAction, playerVictim : CR4Player, attackerMonsterCategory : EMonsterCategory )
	{
		var witcherVictim : W3PlayerWitcher;
		if( playerVictim && playerVictim.CanUseSkill(S_Alchemy_s18) )
		{
			witcherVictim = (W3PlayerWitcher)playerVictim;
			switch(attackerMonsterCategory)
			{
				case MC_Vampire:
					if( playerVictim.CountEffectsOfType(EET_Decoction1) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation9 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation9) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Necrophage:
					if( playerVictim.CountEffectsOfType(EET_Decoction2) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation3 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation3) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Troll:
					if( playerVictim.CountEffectsOfType(EET_Decoction3) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation8 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation8) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Cursed:
					if( playerVictim.CountEffectsOfType(EET_Decoction4) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation7 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation7) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Magicals:
					if( playerVictim.CountEffectsOfType(EET_Decoction5) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation2 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation2) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Specter:
					if( playerVictim.CountEffectsOfType(EET_Decoction6) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation1 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation1) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Relic:
					if( playerVictim.CountEffectsOfType(EET_Decoction7) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation6 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation6) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Draconide:
					if( playerVictim.CountEffectsOfType(EET_Decoction8) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation4 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation4) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Hybrid:
					if( playerVictim.CountEffectsOfType(EET_Decoction9) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation10 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation10) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				case MC_Insectoid:
					if( playerVictim.CountEffectsOfType(EET_Decoction10) > 0 )
						action.processedDmg.vitalityDamage *= 1.f - 0.05f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					if( witcherVictim.GetEquippedMutationType() == EPMT_Mutation5 )
						action.processedDmg.vitalityDamage *= 1.f - 0.04f * playerVictim.GetSkillLevel(S_Alchemy_s18);
					else if( witcherVictim.IsMutationResearched(EPMT_Mutation5) )
						action.processedDmg.vitalityDamage *= 1.f - 0.02f * playerVictim.GetSkillLevel(S_Alchemy_s18);
				default:
					break;
			}
		}
	}
	//Kolaris - Hunter Instinct
	public function ArchmutagenDamageBonus( action : W3DamageAction, playerAttacker : CR4Player, victimMonsterCategory : EMonsterCategory )
	{
		var mutagens : array<SItemUniqueId>;
		var mutagen : SItemUniqueId;
		var skillLevel, i : int;
		var damageBonus : float;
		var witcher : W3PlayerWitcher;
		
		if( playerAttacker && playerAttacker.CanUseSkill(S_Alchemy_s13) )
		{
			mutagens.Resize(4);
			damageBonus = 0.f;
			skillLevel = playerAttacker.GetSkillLevel(S_Alchemy_s13);
			witcher = (W3PlayerWitcher)playerAttacker;
			if( witcher.inv.GetItemEquippedOnSlot(EES_SkillMutagen1, mutagen) && witcher.inv.ItemHasTag(mutagen, 'archetype_mutagen') )
				mutagens[0] = mutagen;
			if( witcher.inv.GetItemEquippedOnSlot(EES_SkillMutagen2, mutagen) && witcher.inv.ItemHasTag(mutagen, 'archetype_mutagen') )
				mutagens[1] = mutagen;
			if( witcher.inv.GetItemEquippedOnSlot(EES_SkillMutagen3, mutagen) && witcher.inv.ItemHasTag(mutagen, 'archetype_mutagen') )
				mutagens[2] = mutagen;
			if( witcher.inv.GetItemEquippedOnSlot(EES_SkillMutagen4, mutagen) && witcher.inv.ItemHasTag(mutagen, 'archetype_mutagen') )
				mutagens[3] = mutagen;
			for ( i = 0; i < mutagens.Size(); i += 1 )
			{
				switch(victimMonsterCategory)
				{
					case MC_Vampire:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Vampire' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Necrophage:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Necrophage' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Troll:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Ogroid' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Cursed:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Cursed' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Magicals:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Elemental' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Specter:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Spectre' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Relic:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Relic' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Draconide:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Draconid' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Hybrid:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Hybrid' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					case MC_Insectoid:
						if( StrContains((witcher.inv.GetItemName(mutagens[i])), 'Insectoid' ))
							damageBonus += 0.01f * (witcher.inv.GetItemQuality(mutagens[i]) - 1) * skillLevel;
					default:
						break;
				}
			}
			switch(victimMonsterCategory)
			{
				case MC_Vampire:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation9 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation9) )
						damageBonus += 0.02f * skillLevel;
				case MC_Necrophage:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation3 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation3) )
						damageBonus += 0.02f * skillLevel;
				case MC_Troll:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation8 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation8) )
						damageBonus += 0.02f * skillLevel;
				case MC_Cursed:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation7 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation7) )
						damageBonus += 0.02f * skillLevel;
				case MC_Magicals:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation2 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation2) )
						damageBonus += 0.02f * skillLevel;
				case MC_Specter:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation1 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation1) )
						damageBonus += 0.02f * skillLevel;
				case MC_Relic:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation6 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation6) )
						damageBonus += 0.02f * skillLevel;
				case MC_Draconide:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation4 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation4) )
						damageBonus += 0.02f * skillLevel;
				case MC_Hybrid:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation10 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation10) )
						damageBonus += 0.02f * skillLevel;
				case MC_Insectoid:
					if( witcher.GetEquippedMutationType() == EPMT_Mutation5 )
						damageBonus += 0.04f * skillLevel;
					else if( witcher.IsMutationResearched(EPMT_Mutation5) )
						damageBonus += 0.02f * skillLevel;
				default:
					break;
			}
			if( damageBonus > 0 )
			{
				action.processedDmg.vitalityDamage *= 1.f + damageBonus;
				action.processedDmg.essenceDamage *= 1.f + damageBonus;
			}
		}
	}
	//Kolaris - Endure Pain
	public function EndurePainDamageReduction( action : W3DamageAction, playerVictim : CR4Player )
	{
		if( playerVictim && playerVictim.CanUseSkill(S_Alchemy_s20) )
		{
			if( playerVictim.IsSetBonusActive(EISB_RedWolf_2) )
				action.processedDmg.vitalityDamage *= 1.f - 0.03f * playerVictim.GetSkillLevel(S_Alchemy_s20) * ((W3PlayerWitcher)playerVictim).GetStat(BCS_Toxicity) / 100.f;
			else
				action.processedDmg.vitalityDamage *= 1.f - 0.03f * playerVictim.GetSkillLevel(S_Alchemy_s20) * ((W3PlayerWitcher)playerVictim).GetStatPercents(BCS_Toxicity);
		}
	}
	//Kolaris - Puppet
	public function ProcessPuppetMorale( action : W3DamageAction, actorVictim : CActor, actorAttacker : CActor )
	{
		var targets : array<CActor>;
		var skillLevel, i : int;
		
		if( actorAttacker.HasBuff(EET_AxiiGuardMe) )
			targets = GetActorsInRange(actorAttacker, 15, 100,, true);
		else
		if( actorVictim.HasBuff(EET_AxiiGuardMe) )
			targets = GetActorsInRange(actorVictim, 15, 100,, true);
			
		skillLevel = GetWitcherPlayer().GetSkillLevel(S_Magic_s05);
		
		for(i=0; i<targets.Size(); i+=1)
		{
			if( IsRequiredAttitudeBetween(thePlayer, targets[i], true, false, false) && ((CNewNPC)targets[i]).GetOpponentType() != MC_Specter && ((CNewNPC)targets[i]).GetOpponentType() != MC_Magicals )
			{
				targets[i].DrainMorale((5.f + skillLevel) * (1.6f - Options().AggressionBehavior() * 0.2f));
			}
		}
		
	}
	//Kolaris - Nilfgaard Set
	public function ProcessNilfgaardAbility( action : W3Action_Attack, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var playerPoise : W3Effect_Poise;
		var targetPoise : W3Effect_NPCPoise;
		var cost, delay, poiseDifference : float;
		
		playerPoise = (W3Effect_Poise)playerAttacker.GetBuff(EET_Poise);
		targetPoise = (W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise);
		poiseDifference = playerPoise.GetPoisePercentage() - targetPoise.GetPoisePercentage();
		
		if( poiseDifference > 0 )
		{
			if( playerAttacker.IsLightAttack(action.GetAttackName()) )
			{
				cost = GetActionStaminaCost(ESAT_LightAttack, delay);
				cost *= Options().StamCostGlobal();
				cost *= poiseDifference / 2.5f + 0.1f;
				if( playerAttacker.GetBehaviorVariable('isPerformingSpecialAttack') > 0 )
					cost /= 2.f;
				playerAttacker.GainStat(BCS_Stamina, cost);
			}
			else
			if( playerAttacker.IsHeavyAttack(action.GetAttackName()) )
			{
				cost = GetActionStaminaCost(ESAT_HeavyAttack, delay);
				cost *= Options().StamCostGlobal();
				cost *= poiseDifference / 2.5f + 0.1f;
				playerAttacker.GainStat(BCS_Stamina, cost);
			}
		}
	}
	//Kolaris - Absorption
	public function AbsorptionStaminaRestore( npc : CNewNPC, optional cost : float)
	{
		if( npc.IsInsideYrden() && (GetWitcherPlayer().HasAbility('Glyphword 14 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 15 _Stats', true)) )
		{
			if( cost > 0 )
				GetWitcherPlayer().GainStat(BCS_Stamina, cost / 2 * Options().StamCostGlobal());
			else
				GetWitcherPlayer().GainStat(BCS_Stamina, 1 * Options().StamCostGlobal());
		}
	}
	
	//Kolaris - Regeneration
	public function GetPlayerStaminaRegen() : float
	{
		var witcher : W3PlayerWitcher;
		var inCombat : bool;
		var statValue : float;
		var attValue : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		attValue = witcher.GetAttributeValue('staminaRegen');
		statValue = attValue.valueAdditive + attValue.valueMultiplicative * witcher.GetStatMax(BCS_Stamina);
		
		statValue *= 1 + witcher.CalculatedArmorStaminaRegenBonus();
		
		statValue *= witcher.GetHPReductionMult();
		
		statValue *= 1.f + witcher.GetAdrenalineEffect().GetValue() / 5.f;
		
		if( witcher.HasAbility('BleedingStatDebuff') )
			statValue *= 1.f - 0.05f * witcher.GetAbilityCount('BleedingStatDebuff');
		
		if( witcher.HasAbility('HeadInjuryEffect') )
			statValue *= 0.8f;
		
		if( ((W3Effect_ToxicityFever)witcher.GetBuff(EET_ToxicityFever)).IsFeverActive() )
			statValue *= 1.f - 0.5f * witcher.GetFeverEffectReductionMult();
		
		if( witcher.IsSetBonusActive(EISB_Ofieri) )
			statValue += 0.5f * GetOfieriSetBonusCount("warding");
		
		if( witcher.GetStatPercents(BCS_Vitality) >= 0.999f && (witcher.HasAbility('Glyphword 41 _Stats', true) || witcher.HasAbility('Glyphword 42 _Stats', true)) )
			statValue += GetPlayerVitalityRegen(true) / 20;
		
		if( witcher.HasBuff(EET_WellFed) && (witcher.HasAbility('Glyphword 44 _Stats', true) || witcher.HasAbility('Glyphword 45 _Stats', true)) )
			statValue += 2.f;
		
		if( (witcher.HasAbility('Glyphword 47 _Stats', true) || witcher.HasAbility('Glyphword 48 _Stats', true)) && (witcher.HasBuff(EET_Decoction8) || witcher.HasBuff(EET_Decoction9) || witcher.HasBuff(EET_Decoction10)) )
			statValue += 2.f;
		
		if( FactsQuerySum("TaFtSComplete") > 0 && (witcher.GetEquippedMutationType() == EPMT_Mutation11 || witcher.GetEquippedMutationType() == EPMT_Mutation12) )
			statValue *= 1.2f;
		
		if( witcher.IsQuenActive(true) && (witcher.HasAbility('Glyphword 23 _Stats', true) || witcher.HasAbility('Glyphword 24 _Stats', true)) )
			statValue *= 3.f;
		
		if( !witcher.IsPlayerMoving() && (witcher.HasAbility('Glyphword 53 _Stats', true) || witcher.HasAbility('Glyphword 54 _Stats', true)) )
			statValue *= 1.5f;
		
		//Kolaris - Tiger Set
		if( witcher.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
			statValue *= 1.25f;
		
		//Kolaris - Netflix Set
		if( witcher.IsSetBonusActive(EISB_Netflix_1) && witcher.GetStatPercents(BCS_Focus) >= 0.999f )
			statValue += GetPlayerVigorRegen() * 10.f * witcher.GetSetPartsEquipped(EIST_Netflix);
		
		if( witcher.CountEffectsOfType(EET_SlowdownFrost) > 0 )
			statValue *= 0.5f;
		
		statValue *= Options().StamRegenGlobal();
		
		return statValue;
	}
	//Kolaris - Perfection
	public function GetPlayerVitalityRegen(combat : bool) : float
	{
		var witcher : W3PlayerWitcher;
		var statValue : float;
		
		witcher = GetWitcherPlayer();
		
		if( combat )
			statValue = CalculateAttributeValue(witcher.GetAttributeValue('vitalityCombatRegen'));
		else
			statValue = CalculateAttributeValue(witcher.GetAttributeValue('vitalityRegen'));
		
		if( witcher.GetStatPercents(BCS_Vitality) <= 0.5f && witcher.CanUseSkill(S_Sword_s18) )
			statValue += (0.3f * witcher.GetSkillLevel(S_Sword_s18)) * (1.f - witcher.GetStatPercents(BCS_Vitality) * 2) * (witcher.GetAdrenalineEffect().GetFullValue());
		
		if( witcher.IsSetBonusActive(EISB_RedWolf_2) )
			statValue += 0.3f * witcher.GetStat(BCS_Toxicity);
		
		if( witcher.CountEffectsOfType(EET_RubedoDominance) > 0 )
			statValue += 15.f + 3.f * witcher.GetSkillLevel(S_Alchemy_s03);
		
		if( FactsQuerySum("TaFtSComplete") > 0 && (witcher.GetEquippedMutationType() == EPMT_Mutation3 || witcher.GetEquippedMutationType() == EPMT_Mutation7 || witcher.GetEquippedMutationType() == EPMT_Mutation8 || witcher.GetEquippedMutationType() == EPMT_Mutation9) )
			statValue += 20.f;
		
		if( witcher.IsSetBonusActive(EISB_Ofieri) )
			statValue += 3.f * GetOfieriSetBonusCount("mending");
		
		if( (witcher.HasAbility('Glyphword 47 _Stats', true) || witcher.HasAbility('Glyphword 48 _Stats', true)) && (witcher.HasBuff(EET_Decoction1) || witcher.HasBuff(EET_Decoction2) || witcher.HasBuff(EET_Decoction3) || witcher.HasBuff(EET_Decoction4)) )
			statValue += 20.f;
		
		if(  witcher.HasAbility('Glyphword 37 _Stats', true) || witcher.HasAbility('Glyphword 38 _Stats', true) || witcher.HasAbility('Glyphword 39 _Stats', true) )
		{
			if( witcher.GetStat(BCS_Stamina) >= witcher.GetStatMax(BCS_Stamina) )
			{
				statValue += GetPlayerStaminaRegen() / Options().StamRegenGlobal() * 2.f;
				if( !witcher.IsPlayerMoving() && (witcher.HasAbility('Glyphword 38 _Stats', true) || witcher.HasAbility('Glyphword 39 _Stats', true)))
					statValue += GetPlayerStaminaRegen() / Options().StamRegenGlobal() * 2.f;
			}
			if( witcher.GetStat(BCS_Focus) >= witcher.GetStatMax(BCS_Focus) )
			{
				statValue += GetPlayerVigorRegen() * 200.f;
				if( !witcher.IsPlayerMoving() && (witcher.HasAbility('Glyphword 38 _Stats', true) || witcher.HasAbility('Glyphword 39 _Stats', true)))
					statValue += GetPlayerVigorRegen() * 200.f;
			}
		}
		
		if( witcher.HasAbility('Glyphword 38 _Stats', true) || witcher.HasAbility('Glyphword 39 _Stats', true) )
			statValue *= 1.f + (1.f - witcher.GetStatPercents(BCS_Vitality)) / 2;
		
		if( witcher.IsQuenActive(true) && (witcher.HasAbility('Glyphword 23 _Stats', true) || witcher.HasAbility('Glyphword 24 _Stats', true)) )
			statValue *= 3.f;
		
		if( witcher.GetCurrentStateName() == 'W3EEMeditation' )
			statValue *= 2;
		
		return statValue;
	}
	
	//Kolaris - Regeneration, Kolaris - Maribor Forest
	public function GetPlayerVigorRegen() : float
	{
		var witcher : W3PlayerWitcher;
		var attributeValue, mariborBonus : SAbilityAttributeValue;
		var statValue, reductionValue : float;
		
		witcher = GetWitcherPlayer();
		
		attributeValue = witcher.GetAttributeValue('vigor_regen');
		
		if( witcher.HasAbility('Glyphword 46 _Stats', true) || witcher.HasAbility('Glyphword 47 _Stats', true) || witcher.HasAbility('Glyphword 48 _Stats', true) )
			reductionValue = 0.25f - 0.05f * witcher.GetSkillLevel(S_Alchemy_s17);
		else
			reductionValue = 0.5f - 0.05f * witcher.GetSkillLevel(S_Alchemy_s17);
		
		if( witcher.HasBuff(EET_MariborForest) )
		{
			mariborBonus = witcher.GetAttributeValue('toxicity_vigor_penalty');
			reductionValue *= 1.f + mariborBonus.valueMultiplicative;
		}
		
		statValue = 0.1f * attributeValue.valueMultiplicative;
		
		if( witcher.IsQuenActive(false) )
		{			
			if( witcher.HasAbility('Glyphword 24 _Stats', true) )
				statValue *= 0.75f + 0.05f * witcher.GetSkillLevel(S_Magic_s14);
			else
				statValue *= 0.5f + 0.05f * witcher.GetSkillLevel(S_Magic_s14);
		}
		
		//Comment out for now, not sure how the game handles two functions that reference each other, even if their requirements can never be met simultaneously
		//if( witcher.GetStatPercents(BCS_Vitality) >= 0.999f && (witcher.HasAbility('Glyphword 41 _Stats', true) || witcher.HasAbility('Glyphword 42 _Stats', true)) )
			//statValue *= 1.f + Combat().GetPlayerVitalityRegen(true) / 200;
		
		if( witcher.HasBuff(EET_WellRested) && (witcher.HasAbility('Glyphword 44 _Stats', true) || witcher.HasAbility('Glyphword 45 _Stats', true)) )
			statValue *= 1.2f;
		
		if( (witcher.HasAbility('Glyphword 47 _Stats', true) || witcher.HasAbility('Glyphword 48 _Stats', true)) && (witcher.HasBuff(EET_Decoction5) || witcher.HasBuff(EET_Decoction6) || witcher.HasBuff(EET_Decoction7)) )
			statValue *= 1.2f;
		
		if( FactsQuerySum("TaFtSComplete") > 0 && (witcher.GetEquippedMutationType() == EPMT_Mutation1 || witcher.GetEquippedMutationType() == EPMT_Mutation2 || witcher.GetEquippedMutationType() == EPMT_Mutation6) )
			statValue *= 1.25f;
		
		//Kolaris - Tiger Set
		if( witcher.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
			statValue *= 1.25f;
		
		if( ((W3Effect_ToxicityFever)witcher.GetBuff(EET_ToxicityFever)).IsFeverActive() )
			statValue *= 1.f - 0.5f * witcher.GetFeverEffectReductionMult();
		
		statValue *= witcher.GetHPReductionMult();
		statValue *= 1.f + witcher.GetAdrenalineEffect().GetValue() / 5.f;
		statValue *= Options().AdrGenSpeedMult;
		statValue *= 1.f - (reductionValue * PowF(witcher.GetStatPercents(BCS_Toxicity), 2));
		return statValue;
	}
	
	//Kolaris - Affliction
	public function AfflictionPoisonChance( action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		if( witcher.HasAbility('Runeword 16 _Stats', true) || witcher.HasAbility('Runeword 17 _Stats', true) || witcher.HasAbility('Runeword 18 _Stats', true) )
		{
			if( action.IsActionMelee() && RandRange(100,0) < witcher.GetStat(BCS_Toxicity) / 2 )
			{
				actorVictim.ApplyPoisoning(1, witcher, "Affliction");
			}
		}
	}
	
	//Kolaris - Exsanguination
	private function ExsanguinateAction( action : W3Action_Attack )
	{
		var bleedout : W3DamageAction;
		var witcher : W3PlayerWitcher;
		var victim : CActor;
		var bleedEffect : W3Effect_Bleeding;
		var stacks : int;
		var fx : CEntity;
		
		witcher = (W3PlayerWitcher)action.attacker;
		victim = (CActor)action.victim;
		bleedEffect = (W3Effect_Bleeding)victim.GetBuff(EET_Bleeding);
		stacks = bleedEffect.GetStacks();
		
		bleedout = new W3DamageAction in this;
		bleedout.Initialize(witcher, victim, action.causer, "Runeword 21", EHRT_Heavy, CPS_Undefined, true, false, false, false);
		bleedout.AddDamage(theGame.params.DAMAGE_NAME_BLEEDING, 600 * stacks);
		theGame.damageMgr.ProcessAction(bleedout);
		
		Blood().ShowBlood( action.GetWeaponId(), (CNewNPC)victim, action.IsActionRanged() );
		if(victim.CanBleed())
		{
			victim.PlayEffectSingle( 'blood_spill' );
			victim.CreateBloodSpill();
		}
		fx = victim.CreateFXEntityAtPelvis('mutation9_hit', true);
		fx.PlayEffect('hit_refraction');
		
		bleedEffect.RemoveStack(stacks);
		((CNewNPC)victim).ReduceNPCStat('bleed', -0.02f * stacks);
	}
	
	//Kolaris - Assassination
	public function AssassinationDamageBoost( action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		if( action.IsActionMelee() && (witcher.HasAbility('Runeword 34 _Stats', true) || witcher.HasAbility('Runeword 35 _Stats', true) || witcher.HasAbility('Runeword 36 _Stats', true)) )
		{
			if(actorVictim.UsesEssence() && actorVictim.GetStatPercents(BCS_Essence) >= 0.999f )
				action.MultiplyAllDamageBy(2.f);
			else if(actorVictim.UsesVitality() && actorVictim.GetStatPercents(BCS_Vitality) >= 0.999f)
				action.MultiplyAllDamageBy(2.f);
		}
	}
	
	//Kolaris - Invocation
	public function ProcessInvocationEffects( action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var witcher : W3PlayerWitcher;
		var invocationType : ESignType;
		var sp : SAbilityAttributeValue;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		invocationType = witcher.GetRunewordInfusionType();
		if( playerAttacker && action.IsActionMelee() && invocationType != ST_None && (witcher.HasAbility('Runeword 40 _Stats', true) || witcher.HasAbility('Runeword 41 _Stats', true) || witcher.HasAbility('Runeword 42 _Stats', true)) )
		{
			switch(invocationType)
			{
				case ST_Aard:
					sp = witcher.GetTotalSignSpellPower( S_Magic_1 );
					if( RandF() < sp.valueMultiplicative / 10 )
						actorVictim.AddEffectDefault(EET_SlowdownFrost, witcher, "Runeword 42");
				break;
				case ST_Igni:
					sp = witcher.GetTotalSignSpellPower( S_Magic_2 );
					if( RandF() < sp.valueMultiplicative / 10 )
						actorVictim.AddEffectDefault(EET_Burning, witcher, "Runeword 42");
				break;
				case ST_Yrden:
					sp = witcher.GetTotalSignSpellPower( S_Magic_3 );
					if( RandF() < sp.valueMultiplicative / 10 )
						actorVictim.AddEffectDefault(EET_Confusion, witcher, "Runeword 42");
				break;
				case ST_Quen:
					sp = witcher.GetTotalSignSpellPower( S_Magic_4 );
					if( RandF() < sp.valueMultiplicative / 10 )
						actorVictim.AddEffectDefault(EET_Electroshock, witcher, "Runeword 42");
				break;
				case ST_Axii:
					sp = witcher.GetTotalSignSpellPower( S_Magic_5 );
					if( RandF() < sp.valueMultiplicative / 10 )
						actorVictim.ApplyPoisoning(1, witcher, "Runeword 42");
				break;
			}
		}
	}
	
	//Kolaris - Ofieri Set
	public function GetOfieriSetBonusCount(bonusType : string) : int
	{
		var witcher : W3PlayerWitcher;
		var item : SItemUniqueId;
		var glyphNames : array<name>;
		var enchantment : name;
		var count, i : int;
		
		witcher = GetWitcherPlayer();
		count = 0;
		witcher.inv.GetItemEquippedOnSlot( EES_Gloves, item );
		witcher.inv.GetItemEnhancementItems(item, glyphNames);
		for ( i = 0; i < glyphNames.Size(); i += 1 )
		{
			if( StrContains(NameToString(glyphNames[i]), bonusType) )
				count += 1;
		}
		witcher.inv.GetItemEquippedOnSlot( EES_Boots, item );
		witcher.inv.GetItemEnhancementItems(item, glyphNames);
		for ( i = 0; i < glyphNames.Size(); i += 1 )
		{
			if( StrContains(NameToString(glyphNames[i]), bonusType) )
				count += 1;
		}
		witcher.inv.GetItemEquippedOnSlot( EES_Pants, item );
		witcher.inv.GetItemEnhancementItems(item, glyphNames);
		for ( i = 0; i < glyphNames.Size(); i += 1 )
		{
			if( StrContains(NameToString(glyphNames[i]), bonusType) )
				count += 1;
		}
		witcher.inv.GetItemEquippedOnSlot( EES_Armor, item );
		witcher.inv.GetItemEnhancementItems(item, glyphNames);
		for ( i = 0; i < glyphNames.Size(); i += 1 )
		{
			if( StrContains(NameToString(glyphNames[i]), bonusType) )
				count += 1;
		}
		enchantment = witcher.inv.GetEnchantment(item);
		if( enchantment != '' )
			count += Equipment().GetComponentGlyphsFromEnchantment(enchantment, bonusType);
		
		//theGame.GetGuiManager().ShowNotification(count);
		return count;
	}
	
	public function GetEnemyAttackTier(actorAttacker : CActor, attackName : name, canBeParried : bool) : int
	{
		var tier : int;
		
		if( actorAttacker.IsHuge() )
		{
			if( GetEnemyAoESpecialAttackType(actorAttacker) > 0 || actorAttacker.IsSuperHeavyAttack(attackName) )
				tier = 5;
			else
			if( actorAttacker.IsHeavyAttack(attackName) )
				tier = 4;
			else
				tier = 3;
		}
		else
		{
			if( GetEnemyAoESpecialAttackType(actorAttacker) > 0 || actorAttacker.IsSuperHeavyAttack(attackName) || !canBeParried )
				tier = 3;
			else
			if( actorAttacker.IsHeavyAttack(attackName) )
				tier = 2;
			else
				tier = 1;
		}
		
		/*if( actorAttacker.IsMonster() )
			tier += 1;*/
		if( actorAttacker.HasTag('IsBoss') || actorAttacker.GetCharacterStats().HasAbilityWithTag('Boss') || actorAttacker.HasAbility('SkillBoss') || actorAttacker.HasAbility('Boss') || (W3MonsterHuntNPC)actorAttacker )
			tier += 1;
		
		return tier;
	}
	
	//Kolaris - Enemy Aggression Behavior
	public function GetEnemyAggressionChance() : int
	{
		var chance : float;
		var enemies : array< CActor >;
		
		chance = Options().AggressionBehavior() * 10;
		chance *= Options().GetDifficultySettingMod();
		if( Options().AggressionBehaviorScaling() )
		{
			enemies = GetWitcherPlayer().GetEnemies();
			chance /= enemies.Size();
		}
		return FloorF(chance);
	}
	
	//Kolaris - Mutation 7
	public function ManageMutation7(attacker : CGameplayEntity, victim : CGameplayEntity, damage : float)
	{
		var witcher : W3PlayerWitcher;
		var npc : CNewNPC;
		var witcherRegen : float = GetPlayerVitalityRegen(true);
		var amountAvailable, amountRestored : float;
		
		if( (W3PlayerWitcher)attacker && (CNewNPC)victim )
		{
			witcher = (W3PlayerWitcher)attacker;
			npc = (CNewNPC)victim;
			
			amountAvailable = npc.GetMutation7Amount() * (1.f - ClampF(((theGame.GetEngineTimeAsSeconds() - npc.GetMutation7Timestamp()) / (10.f + witcherRegen / 10.f)), 0.f, 1.f));
			amountRestored = MinF(damage / 2.f, amountAvailable / 2.f);
			if( npc.UsesEssence() )
				amountRestored += damage / npc.GetStatMax(BCS_Essence) * (amountAvailable / 2.f);
			else
				amountRestored += damage / npc.GetStatMax(BCS_Vitality) * (amountAvailable / 2.f);
			witcher.GainStat(BCS_Vitality, amountRestored);
			//theGame.GetGuiManager().ShowNotification("Total: " + npc.GetMutation7Amount() + "<br>Available: " + amountAvailable + "<br>Restored: " + amountRestored);
			npc.SetMutation7Amount(MaxF(0.f, amountAvailable - amountRestored));
		}
		else
		if( (W3PlayerWitcher)victim && (CNewNPC)attacker )
		{
			npc = (CNewNPC)attacker;
			
			npc.SetMutation7Amount(damage + npc.GetMutation7Amount() * (1.f - ClampF(((theGame.GetEngineTimeAsSeconds() - npc.GetMutation7Timestamp()) / (10.f + witcherRegen / 10.f)), 0.f, 1.f)));
			npc.SetMutation7Timestamp();
		}
	}
	
	//Kolaris - Mutation 5
	public function Mutation5DrainToxFromStamina( value : float )
	{
		var playerWitcher : W3PlayerWitcher = GetWitcherPlayer();
		var toxEffect : W3Effect_Toxicity;
		
		toxEffect = (W3Effect_Toxicity)playerWitcher.GetBuff(EET_Toxicity);
		if( toxEffect )
		{
			((CR4Player)playerWitcher).DrainToxicity(value / -4.f * toxEffect.GetToxicityDrain() * playerWitcher.GetStatPercents(BCS_Toxicity));
		}
	}
	
	//Kolaris - Mutation 4
	public function Mutation4DrainStamina(damage : float )
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var speedPenalties : float;
		
		speedPenalties = Options().StamRed() / 10.f * (1.f - (witcher.GetSkillLevel(S_Sword_s16) * 0.05f));

		if( witcher.HasBuff(EET_Overexertion) )
			speedPenalties *= 2.f;
		
		if( witcher.HasAbility('Glyphword 50 _Stats', true) || witcher.HasAbility('Glyphword 51 _Stats', true) )
			speedPenalties *= 0.5f * (1.f - witcher.GetAdrenalinePercMult());
	
		witcher.DrainStamina(ESAT_FixedValue, witcher.GetStatMax(BCS_Stamina) * damage / witcher.GetStatMax(BCS_Vitality) * speedPenalties);
	}
	
	//Kolaris - Mutation 2
	public function Mutation2RestoreVigor(attackAction : W3Action_Attack)
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var vigorRegen : float = GetPlayerVigorRegen();
		var attackName : name = attackAction.GetAttackName();
		
		if( witcher.IsMutationActive(EPMT_Mutation2) && attackAction.IsActionMelee() )
		{
			if( witcher.IsHeavyAttack(attackName) )
			{	
				if( witcher.IsInCombatAction_SpecialAttackHeavy() )
					witcher.GainStat(BCS_Focus, vigorRegen * (5.f + 5.f * witcher.GetSpecialAttackTimeRatio()));
				else
					witcher.GainStat(BCS_Focus, vigorRegen * 4.f);
			}
			else
			if( witcher.IsLightAttack(attackName) )
			{
				if( witcher.IsInCombatAction_SpecialAttack() )
					witcher.GainStat(BCS_Focus, vigorRegen);
				else
					witcher.GainStat(BCS_Focus, vigorRegen * 2.f);
			}
		}
	}
}

exec function taunt()
{
	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_taunt_far', 0.5, 0.5);
	thePlayer.AddTimer('ForceTaunt', 0.5f, false);
}

exec function applypoison(stack : int, optional target : bool)
{
	if( !target ) 
		thePlayer.ApplyPoisoning(stack, thePlayer, "olam");
	else
		thePlayer.GetTarget().ApplyPoisoning(stack, thePlayer, "olam");
}