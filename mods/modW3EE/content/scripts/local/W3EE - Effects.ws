class W3Effect_WolfSetParry extends CBaseGameplayEffect
{
	private saved var parryCount : int;
	private const var MAX_COUNT : int;
	
	default effectType = EET_WolfSetParry;	
	default isPositive = true;
	//Kolaris - Bear Set
	default MAX_COUNT = 10;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		parryCount = 0;
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		parryCount = 0;
		super.OnEffectRemoved();
		target.RemoveAbilityAll('WolvenParryAbility');
	}
	
	public function IncrementAbility( action : W3DamageAction )
	{
		if( parryCount < MAX_COUNT && (((W3Action_Attack)action).IsParried() || ((W3Action_Attack)action).IsCountered() || ((W3Action_Attack)action).IsPerfectParried()) )
		{
			parryCount += 1;
			target.AddAbility('WolvenParryAbility', true);
			if( parryCount < MAX_COUNT && (((W3Action_Attack)action).IsCountered() || ((W3Action_Attack)action).IsPerfectParried()) )
			{
				parryCount += 1;
				target.AddAbility('WolvenParryAbility', true);
			}
		}
	}
	
	public function OnTakeDamage( action : W3DamageAction )
	{
		if( parryCount > 0 && action.IsActionMelee() && action.DealsAnyDamage() && !(((W3Action_Attack)action).IsCountered() || ((W3Action_Attack)action).IsParried()) )
		{
			parryCount = Max(0, parryCount - 2);
			target.RemoveAbility('WolvenParryAbility');
			target.RemoveAbility('WolvenParryAbility');
		}
	}
	
	public function ResetCounter()
	{
		parryCount = 0;
	}
	
	public function GetStacks() : int
	{
		return parryCount;
	}
	
	public function GetMaxStacks() : int
	{
		return MAX_COUNT;
	}
}

class W3Effect_CombatAdrenaline extends CBaseGameplayEffect
{
	private saved var pointPool : float;
	private saved var currentAdrenaline : float;
	private var timeScale : float;
	private var maxAdrenaline : float;
	private var abilityTimer : float;
	private var degenTimer : float;
	private var lossModifier : float;
	private var abilityCount : int;
	private var abilityCountLast : int;
	private var speedMultID : int;
	private var playerWitcher : W3PlayerWitcher;
	private var minAdrenaline : float;
	private var exhilaration : bool;

	private const var ADRENALINE_COUNTER : float;
	private const var ADRENALINE_HIT : float;
	private const var ADRENALINE_ATTACK : float;
	private const var ADRENALINE_KILL : float;
	private const var ADRENALINE_EXECUTE : float;
	private const var DEGEN_DELAY : float;
	private const var ABILITY_CHECK_INTERVAL : float;

	default effectType = EET_CombatAdr;
	default isPositive = true;

	default speedMultID = -1;
	default pointPool = 0;
	default currentAdrenaline = 0;
	default abilityCount = 0;
	default abilityCountLast = 0;
	default minAdrenaline = 0;
	
	default ADRENALINE_COUNTER = 1.f;
	default ADRENALINE_HIT = 5.f;
	default ADRENALINE_ATTACK = 1.f;
	default ADRENALINE_KILL = 3.f;
	default ADRENALINE_EXECUTE = 5.f;
	default DEGEN_DELAY = 3.f;
	default ABILITY_CHECK_INTERVAL = 1.f;
	
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		playerWitcher = (W3PlayerWitcher)target;
		maxAdrenaline = GetMaximumAdrenaline();
		abilityTimer = ABILITY_CHECK_INTERVAL;
		degenTimer = DEGEN_DELAY;
		lossModifier = 1.f - playerWitcher.GetSkillLevel(S_Sword_s20) * 0.1f;
		//Kolaris - Resolution
		if( playerWitcher.IsRuneword44Active() )
			lossModifier *= 0.25f;
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		playerWitcher.RemoveAbilityAll('AdrenalineAbility');
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Adrenaline));
		
		//Kolaris - Immolation
		if( playerWitcher.IsEffectActive( 'critical_burning' ) && (playerWitcher.HasAbility('Glyphword 7 _Stats', true) || playerWitcher.HasAbility('Glyphword 8 _Stats', true) || playerWitcher.HasAbility('Glyphword 9 _Stats', true)) )
			playerWitcher.StopEffect( 'critical_burning' );
		//Kolaris - Exhilaration
		if( exhilaration )
		{
			exhilaration = false;
			playerWitcher.StopEffect('mq7017_hallucination');
		}
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		//Kolaris - Desperation
		if( playerWitcher.HasAbility('Runeword 22 _Stats', true) || playerWitcher.HasAbility('Runeword 23 _Stats', true) || playerWitcher.HasAbility('Runeword 24 _Stats', true) )
			minAdrenaline = (1.f - playerWitcher.GetStatPercents(BCS_Vitality)) * 50.f;
		else
			minAdrenaline = 0.f;
		
		if( currentAdrenaline <= pointPool )
			currentAdrenaline += dt * 6.f;
		else
		{
			if( exhilaration )
				currentAdrenaline -= dt * 15.f;
			else
				currentAdrenaline -= dt * 6.f;
		}
		currentAdrenaline = ClampF(currentAdrenaline, minAdrenaline, maxAdrenaline);
		
		//Kolaris - Exhilaration
		if( !exhilaration && playerWitcher.HasAbility('Runeword 33 _Stats', true) && currentAdrenaline == maxAdrenaline )
		{
			exhilaration = true;
			playerWitcher.PlayEffect('runeword_10_stamina');
			playerWitcher.PlayEffect('mq7017_hallucination');
		}
		else if( exhilaration && (currentAdrenaline == minAdrenaline || !playerWitcher.HasAbility('Runeword 33 _Stats', true)) )
		{
			exhilaration = false;
			playerWitcher.StopEffect('mq7017_hallucination');
		}
		
		abilityTimer -= dt;
		if( abilityTimer <= 0 )
		{
			ManageAdrenalineAbilities();
			abilityTimer = ABILITY_CHECK_INTERVAL;
			//Kolaris - Test
			//theGame.witcherLog.AddMessage("Morale: " + playerWitcher.GetTarget().GetStat(BCS_Morale));
			//theGame.witcherLog.AddMessage("Stamina Percents: " + playerWitcher.GetTarget().GetStatPercents(BCS_Stamina));
			//theGame.witcherLog.AddMessage(VecDistance2D(playerWitcher.GetWorldPosition(), playerWitcher.GetTarget().GetWorldPosition()));
		}
		
		//Kolaris - Mutation 3
		if( !playerWitcher.IsMutationActive(EPMT_Mutation3) )
			degenTimer -= dt;
		//Kolaris - Exhilaration
		if( (degenTimer <= 0 || exhilaration) && pointPool > 0 )
		{
			if( exhilaration )
				pointPool -= dt * 100.f * lossModifier;
			else
				pointPool -= dt * 25.f * lossModifier;
			pointPool = MaxF(pointPool, minAdrenaline);
		}
	}
	
	private function GetMaximumAdrenaline() : float
	{
		//Kolaris - Affinity, Kolaris - Wolf Set
		if( playerWitcher.IsSetBonusActive(EISB_Wolf_2) )
			return 150.f;
		else
			return 100.f;
	}
	
	public function GetAdrenalineGainMult() : float
	{
		var adrenalineGain : SAbilityAttributeValue = playerWitcher.GetAttributeValue('focus_gain');
		//Kolaris - Adrenaline Tweaks
		var adrenalineGainMult : float;
		var enemies : array< CActor >;
		
		//Kolaris - Adrenaline Tweaks
		adrenalineGainMult = 5.f * (1.f - 0.8f * playerWitcher.GetStatPercents(BCS_Vitality));
		//Kolaris - Perfection
		if( playerWitcher.HasAbility('Glyphword 40 _Stats', true) || playerWitcher.HasAbility('Glyphword 41 _Stats', true) || playerWitcher.HasAbility('Glyphword 42 _Stats', true) )
			adrenalineGainMult = MaxF(adrenalineGainMult, 5.f * playerWitcher.GetStatPercents(BCS_Vitality));
		adrenalineGainMult += ((adrenalineGain.valueAdditive + adrenalineGain.valueMultiplicative + adrenalineGain.valueBase) - 1.f);
		adrenalineGainMult += playerWitcher.GetSkillLevel(S_Sword_s19) * 0.05f;
		enemies = playerWitcher.GetEnemies();
		adrenalineGainMult += (enemies.Size() - 1) * 0.2f;
		if( playerWitcher.CanUseSkill(S_Alchemy_s16) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				adrenalineGainMult += playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				adrenalineGainMult += playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		//Kolaris - Mutation 3
		if( playerWitcher.IsMutationActive(EPMT_Mutation3) )
			adrenalineGainMult += 0.5f;
		
		return adrenalineGainMult;
	}
	
	private function ManageAdrenalineAbilities()
	{
		var diff : int;
		
		//Kolaris - Adrenaline Restoration
		abilityCount = FloorF(currentAdrenaline);
		diff = abilityCount - abilityCountLast;
		if( diff > 0 )
			playerWitcher.AddAbilityMultiple('AdrenalineAbility', diff);
		else
		if( diff < 0 )
			playerWitcher.RemoveAbilityMultiple('AdrenalineAbility', Abs(diff));
		abilityCountLast = abilityCount;
		
		//Kolaris - Adrenaline Tweaks, Kolaris - Elation, Kolaris - Exhilaration
		if( exhilaration )
			timeScale = 0.5f;
		else if( playerWitcher.HasAbility('Glyphword 51 _Stats', true) )
			timeScale = 1.f - (currentAdrenaline * 0.003f);
		else
			timeScale = 1.f - (currentAdrenaline * 0.003f * (1 - target.GetStatPercents(BCS_Vitality)));
		theGame.SetTimeScale(timeScale, theGame.GetTimescaleSource(ETS_Adrenaline), theGame.GetTimescalePriority(ETS_Adrenaline), false, true);
		speedMultID = playerWitcher.SetAnimationSpeedMultiplier(1.f / timeScale, speedMultID, true);
		
		//Kolaris - Immolation
		if( playerWitcher.HasAbility('Glyphword 7 _Stats', true) || playerWitcher.HasAbility('Glyphword 8 _Stats', true) || playerWitcher.HasAbility('Glyphword 9 _Stats', true) )
		{
			if( currentAdrenaline >= 50.f && !playerWitcher.IsEffectActive( 'critical_burning' ) )
				playerWitcher.PlayEffect( 'critical_burning' );
			else if( playerWitcher.IsEffectActive( 'critical_burning' ) )
				playerWitcher.StopEffect( 'critical_burning' );
			if( playerWitcher.HasAbility('Glyphword 9 _Stats', true) )
				DealImmolationDamage();
		}
	}
	
	//Kolaris - Immolation
	private function DealImmolationDamage()
	{
		var i : int;
		var targets : array<CActor>;
		var immolate : W3DamageAction;
		
		targets = GetActorsInRange(playerWitcher, 5, 100,, true);
		
		for(i=0; i<targets.Size(); i+=1)
		{
			if(IsRequiredAttitudeBetween(playerWitcher, targets[i], true, false, false))
			{
				if( RandRange(100, 1) <= currentAdrenaline )
					targets[i].PlayEffect( 'critical_burning' );
				immolate = new W3DamageAction in this;
				immolate.Initialize(playerWitcher, targets[i], NULL, "Glyphword 9", EHRT_None, CPS_Undefined, false, false, false, true);
				immolate.AddDamage(theGame.params.DAMAGE_NAME_FIRE, (6.f - VecDistance2D(playerWitcher.GetWorldPosition(), playerWitcher.GetTarget().GetWorldPosition())) * currentAdrenaline );
				immolate.SetHitAnimationPlayType(EAHA_ForceNo);
				immolate.SetCannotReturnDamage(true);
				immolate.SetSuppressHitSounds(true);
				immolate.SetCanPlayHitParticle(true);
				theGame.damageMgr.ProcessAction(immolate);
				delete immolate;
				targets[i].StopEffect( 'critical_burning' );
			}
		}
	}
	
	public function ResetDegenTimer()
	{
		degenTimer = DEGEN_DELAY;
		if( target.HasBuff(EET_Decoction2) )
			degenTimer += 2.f;
		//Kolaris - Desperation
		degenTimer += CalculateAttributeValue(playerWitcher.GetAttributeValue('adrenaline_delay_bonus'));
	}
	
	public function ManageAdrenaline( attackAction : W3Action_Attack )
	{
		var gain : float;
		
		if( (W3PlayerWitcher)attackAction.attacker )
		{
			if( !attackAction.IsActionMelee() )
				return;
				
			ResetDegenTimer();
			if( attackAction.DealsAnyDamage() )
			{
				gain = ADRENALINE_ATTACK * GetAdrenalineGainMult();
				
				//Kolaris - Reach of the Damned Fix
				if( playerWitcher.GetStatPercents(BCS_Vitality) <= 0.5f && playerWitcher.GetBuff(EET_SwordReachoftheDamned) )
					gain *= 1.5f;
			}
			
			WolfSetAdrenalineOverflow(gain);
			NetflixSetVigorGain(gain);
			Mutation5DrainToxFromAdrenaline(gain);
			pointPool = ClampF(pointPool + gain, 0.f, maxAdrenaline);
		}
		else
		if( (W3PlayerWitcher)attackAction.victim )
		{
			if( attackAction.IsDoTDamage() || !attackAction.attacker )
				return;
				
			ResetDegenTimer();
			//Kolaris - Adrenaline Burst
			if( attackAction.WasDodged() || attackAction.IsCountered() || attackAction.IsPerfectParried() ||(attackAction.IsParried() && playerWitcher.CanUseSkill(S_Perk_10)) )
			{
				gain = ADRENALINE_COUNTER * GetAdrenalineGainMult();
			}
			else
			if( attackAction.DealsAnyDamage() )
			{
				gain = ADRENALINE_HIT * GetAdrenalineGainMult();
				//Kolaris - Mutation 3
				if( playerWitcher.IsMutationActive(EPMT_Mutation3) )
				{
					if( target.HasBuff(EET_Decoction2) )
						gain *= 0.8f;
					gain *= 1.f - CalculateAttributeValue(playerWitcher.GetAttributeValue('adrenaline_delay_bonus')) / 10.f;
					RemoveAdrenaline(gain);
					return;
				}
			}
			
			WolfSetAdrenalineOverflow(gain);
			NetflixSetVigorGain(gain);
			Mutation5DrainToxFromAdrenaline(gain);
			pointPool = ClampF(pointPool + gain, 0.f, maxAdrenaline);
		}
	}
	
	public function AdrenalineGrantKill()
	{
		ResetDegenTimer();
		pointPool += ADRENALINE_KILL * GetAdrenalineGainMult();
		WolfSetAdrenalineOverflow(ADRENALINE_KILL * GetAdrenalineGainMult());
		NetflixSetVigorGain(ADRENALINE_KILL * GetAdrenalineGainMult());
		Mutation5DrainToxFromAdrenaline(ADRENALINE_KILL * GetAdrenalineGainMult());
		pointPool = ClampF(pointPool, 0.f, maxAdrenaline);
	}
	
	public function AdrenalineGrantFinisher()
	{
		ResetDegenTimer();
		pointPool += ADRENALINE_EXECUTE * GetAdrenalineGainMult();
		//Kolaris - Mutilation
		if( playerWitcher.HasAbility('Runeword 56 _Stats', true) || playerWitcher.HasAbility('Runeword 57 _Stats', true) )
		{
			pointPool += ADRENALINE_EXECUTE * GetAdrenalineGainMult();
			WolfSetAdrenalineOverflow(ADRENALINE_EXECUTE * GetAdrenalineGainMult());
			NetflixSetVigorGain(ADRENALINE_EXECUTE * GetAdrenalineGainMult());
			Mutation5DrainToxFromAdrenaline(ADRENALINE_EXECUTE * GetAdrenalineGainMult());
		}
		WolfSetAdrenalineOverflow(ADRENALINE_EXECUTE * GetAdrenalineGainMult());
		NetflixSetVigorGain(ADRENALINE_EXECUTE * GetAdrenalineGainMult());
		Mutation5DrainToxFromAdrenaline(ADRENALINE_EXECUTE * GetAdrenalineGainMult());
		pointPool = ClampF(pointPool, 0.f, maxAdrenaline);
	}
	
	public function AddAdrenaline( value : float )
	{
		ResetDegenTimer();
		pointPool += value;
		WolfSetAdrenalineOverflow(value * GetAdrenalineGainMult());
		NetflixSetVigorGain(value * GetAdrenalineGainMult());
		Mutation5DrainToxFromAdrenaline(value * GetAdrenalineGainMult());
		pointPool = ClampF(pointPool, 0.f, maxAdrenaline);
	}
	//Kolaris - Wolf Set
	public function AddAdrenalineWithMult( value : float )
	{
		ResetDegenTimer();
		pointPool += value * GetAdrenalineGainMult();
		WolfSetAdrenalineOverflow(value * GetAdrenalineGainMult());
		NetflixSetVigorGain(value * GetAdrenalineGainMult());
		Mutation5DrainToxFromAdrenaline(value * GetAdrenalineGainMult());
		pointPool = ClampF(pointPool, 0.f, maxAdrenaline);
	}
	
	public function RemoveAdrenaline( value : float )
	{
		pointPool -= value;
		currentAdrenaline -= value;
		pointPool = ClampF(pointPool, 0, maxAdrenaline);
		currentAdrenaline = ClampF(currentAdrenaline, 0, maxAdrenaline);
	}
	
	public function ResetAdrenaline()
	{
		pointPool = 0;
		currentAdrenaline = 0;
		abilityCount = 0;
		abilityCountLast = 0;
		playerWitcher.RemoveAbilityAll('AdrenalineAbility');
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Adrenaline));
	}
	
	public function GetValue() : float
	{
		return FloorF(currentAdrenaline) / 100.f;
	}
	
	public function GetFullValue() : float
	{
		return FloorF(currentAdrenaline);
	}
	
	public function GetDisplayCount() : int
	{
		//Kolaris - Wolf Set
		//return FloorF(currentAdrenaline / maxAdrenaline * 100.f);
		return FloorF(currentAdrenaline);
	}
	
	public function GetMaxDisplayCount() : int
	{
		//Kolaris - Wolf Set
		return FloorF(maxAdrenaline);
	}
	
	//Kolaris - Exhilaration
	public function GetExhilarationMode() : bool
	{
		return exhilaration;
	}
	
	//Kolaris - Wolf Set
	private function WolfSetAdrenalineOverflow( value : float )
	{
		if( playerWitcher.IsSetBonusActive(EISB_Wolf_1) && pointPool > 100.f )
		{
			playerWitcher.GainStat(BCS_Vitality, value * playerWitcher.GetSetPartsEquipped(EIST_Wolf));
			playerWitcher.GainStat(BCS_Stamina, value * 0.1f * playerWitcher.GetSetPartsEquipped(EIST_Wolf) * Options().StamCostGlobal());
		}
	}
	
	//Kolaris - Netflix Set
	private function NetflixSetVigorGain( value : float )
	{
		if( playerWitcher.IsSetBonusActive(EISB_Netflix_1) )
		{
			playerWitcher.GainStat(BCS_Focus, value * 0.0025f * playerWitcher.GetSetPartsEquipped(EIST_Netflix));
			//theGame.GetGuiManager().ShowNotification("Gaining Vigor: " + value * 0.0025f * playerWitcher.GetSetPartsEquipped(EIST_Netflix));
		}
	}
	
	//Kolaris - Mutation 5
	private function Mutation5DrainToxFromAdrenaline( value : float )
	{
		var toxEffect : W3Effect_Toxicity;
	
		if( playerWitcher.IsMutationActive(EPMT_Mutation5) )
		{
			toxEffect = (W3Effect_Toxicity)playerWitcher.GetBuff(EET_Toxicity);
			if( toxEffect )
				((CR4Player)target).DrainToxicity(value / -4.f * toxEffect.GetToxicityDrain() * playerWitcher.GetStatPercents(BCS_Toxicity));
		}
	}
}

class W3Effect_ReflexBlast extends CBaseGameplayEffect
{
	private var reflexMultID 		: int;
	private var effectDur			: float;
	private var timePassed			: float;
	private var signPower			: float;
	private var timeScale			: float;
	private var speedDiff			: float;
	private var playerWitcher		: W3PlayerWitcher;
	private var powerStat			: SAbilityAttributeValue;
	
	default effectType = EET_ReflexBlast;
	default isPositive = true;
	default reflexMultID = -1;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		playerWitcher = GetWitcherPlayer();
		
		effectDur = 2.0f;
		timeScale = 0.7f;
		
		speedDiff = 1 / timeScale;
		theGame.SetTimeScale(timeScale, theGame.GetTimescaleSource(ETS_ReflexBlast), theGame.GetTimescalePriority(ETS_ReflexBlast), false, true);
		if( playerWitcher.HasAbility('Glyphword 6 _Stats', true) )
			reflexMultID = playerWitcher.SetAnimationSpeedMultiplier(speedDiff, reflexMultID, true);
		if( !target.HasBuff(EET_Blizzard) )
			target.PlayEffect('blizzard');
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		timePassed += dt * speedDiff;
		if( timePassed >= effectDur )
		{
			playerWitcher.RemoveBuff(EET_ReflexBlast, false, "AardReflexBlast");
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_ReflexBlast));
		if( playerWitcher.HasAbility('Glyphword 6 _Stats', true) )
			playerWitcher.ResetAnimationSpeedMultiplier(reflexMultID);
		if( !target.HasBuff(EET_Blizzard) )
			target.StopEffect('blizzard');
		super.OnEffectRemoved();
	}
	
	public function StackEffectDuration()
	{
		effectDur += MaxF(0.f, 2.f - (effectDur - timePassed));
	}
}

class W3Effect_AlbedoDominance extends CBaseGameplayEffect
{
	default effectType = EET_AlbedoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
}

class W3Effect_RubedoDominance extends CBaseGameplayEffect
{
	default effectType = EET_RubedoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;	
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
}

class W3Effect_NigredoDominance extends CBaseGameplayEffect
{
	default effectType = EET_NigredoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	public function Init(params : SEffectInitInfo)
	{	
		attributeName = PowerStatEnumToName(CPS_AttackPower);
		super.Init(params);
	}
	
}

class W3Effect_WinterBlade extends CBaseGameplayEffect
{
	private var hitsToCharge, hitCounter : int;
	private var vigorToCharge, dischargeTime, dischargeTimer : float;
	private var isCharged : bool;
	private var swordID : SItemUniqueId;
	private var inv : CInventoryComponent;
	private var effectName : name;
	private var witcher : W3PlayerWitcher;
	
	default effectType = EET_WinterBlade;
	default isPositive = true;
	default hitsToCharge = 5;
	default vigorToCharge = 1;
	default dischargeTime = 9;
	default effectName = 'runeword_aard';
	
	private function InitEffect()
	{
		witcher = (W3PlayerWitcher)target;
		witcher.inv.GetItemEquippedOnSlot(EES_SteelSword, swordID);
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		InitEffect();
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( deltaTime : float )
	{
		if( dischargeTimer > 0 )
			dischargeTimer -= deltaTime;
		else
			DischargeWeapon(false);
			
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function IncreaseCounter()
	{
		if( witcher.GetStat(BCS_Focus) >= vigorToCharge )
		{
			if( !isCharged )
			{
				hitCounter += 1;
				if( hitCounter >= hitsToCharge )
					ChargeWeapon();
			}
			dischargeTimer = dischargeTime;
		}
	}
	
	private function ChargeWeapon()
	{
		var ent : CEntity;
		
		isCharged = true;
		inv.PlayItemEffect(swordID, effectName);
		ent = witcher.CreateFXEntityAtPelvis('mutation1_hit', true);
		ent.PlayEffect('mutation_1_hit_aard');
		witcher.PlayEffect('mutation_6_power');
		witcher.AddAbility('ForceDismemberment');
	}
	
	public function DischargeWeapon( attack : bool )
	{
		isCharged = false;
		hitCounter = 0;
		inv.StopItemEffect(swordID, effectName);
		if( attack )
			witcher.DrainFocus(1);
		witcher.RemoveAbility('ForceDismemberment');
	}
	
	public function DealDischargeDamage( attackAction : W3Action_Attack )
	{
		var winterDmg : W3DamageAction;
		var npc : CNewNPC;
		var ent, fx : CEntity;
		var entityTemplate : CEntityTemplate;
		var rot : EulerAngles;
		var i : int;
		var pos, basePos : Vector;
		var angle, radius : float;
		var damage : SAbilityAttributeValue;
		
		if( attackAction.attacker == witcher && IsWeaponCharged() && witcher.IsHeavyAttack(attackAction.GetAttackName()) )
		{
			npc = (CNewNPC)attackAction.victim;
			winterDmg = new W3DamageAction in theGame.damageMgr;
			winterDmg.Initialize( attackAction.attacker, attackAction.victim, attackAction.causer, "WinterBladeDamage", EHRT_None, CPS_Undefined, false, false, false, true );
			winterDmg.AddEffectInfo(EET_Frozen, 2);
			winterDmg.AddEffectInfo(EET_SlowdownFrost, 6);
			winterDmg.AddEffectInfo(EET_Immobilized, 2.5f);
			
			if( npc.IsShielded(witcher) )
			{
				npc.ProcessShieldDestruction();
				winterDmg.AddEffectInfo(EET_LongStagger);
			}
			
			winterDmg.SetHitAnimationPlayType(EAHA_ForceNo);
			winterDmg.SetCannotReturnDamage(true);
			winterDmg.SetCanPlayHitParticle(false);
			winterDmg.SetForceExplosionDismemberment();
			winterDmg.SetWasFrozen();
			
			winterDmg.AddDamage(theGame.params.DAMAGE_NAME_FROST, 700.f);
			
			npc.SoundEvent("sign_axii_release");
			npc.SoundEvent("bomb_white_frost_explo");
			
			theGame.damageMgr.ProcessAction(winterDmg);
			delete winterDmg;
			
			DischargeWeapon(true);
			witcher.PlayEffect('mutation_6_power');
			npc.PlayEffect('critical_frozen');
			npc.AddTimer('StopMutation6FX', 7.f);
			
			theGame.GetGameCamera().PlayEffect('frost');
			witcher.AddTimer('RemoveCameraEffect', 3.f, false);
			
			fx = npc.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_aard');
			fx.PlayEffect('critical_aard');
			fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_aard');
			fx.PlayEffect('mutation_1_hit_aard');
			GCameraShake(0.75f);
			
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(npc.GetWorldPosition(), 0.3f, 15, 5, 14, 0);
			
			entityTemplate = (CEntityTemplate)LoadResource("ice_spikes_large");	
			if ( entityTemplate )
			{
				pos = npc.GetWorldPosition();
				pos = TraceFloor(pos);
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				ent = theGame.CreateEntity(entityTemplate, pos, rot);
				ent.DestroyAfter(30.f);
			}
			
			entityTemplate = (CEntityTemplate)LoadResource("ice_spikes");
			basePos = npc.GetWorldPosition();
			for( i=0; i<3; i+=1 )
			{
				radius = RandF() + 1.0;
				
				angle = i * 2 *(Pi() / 3) + RandRangeF(Pi()/18, -Pi()/18);
				
				pos = basePos + Vector( radius * CosF( angle ), radius * SinF( angle ), 0 );
				pos = TraceFloor( pos );
				
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				ent = theGame.CreateEntity(entityTemplate, pos, rot);
				ent.DestroyAfter(30.f);
			}
		}
	}
	
	public function IsWeaponCharged() : bool
	{
		return isCharged;
	}
	
	public function GetHitCounter() : int
	{
		return hitCounter;
	}
	
	public function GetMaxHitCounter() : int
	{
		return hitsToCharge;
	}
	
	public function GetDisplayCount() : int
	{
		return GetHitCounter();
	}
	
	public function GetMaxDisplayCount() : int
	{
		return GetMaxHitCounter();
	}
}

class W3Effect_PhantomWeapon extends CBaseGameplayEffect
{
	default effectType = EET_PhantomWeapon;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( deltaTime : float )
	{
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function GetDisplayCount() : int
	{
		return GetWitcherPlayer().GetPhantomWeaponMgr().GetHitCounter();
	}
	
	public function GetMaxDisplayCount() : int
	{
		return GetWitcherPlayer().GetPhantomWeaponMgr().GetMaxHitCounter();
	}
}

class W3Effect_AlchemyTable extends CBaseGameplayEffect
{
	default effectType = EET_AlchemyTable;
	default dontAddAbilityOnTarget = true;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

//Kolaris - Argentia
class W3Effect_SilverBurn extends W3DamageOverTimeEffect
{
	default effectType = EET_SilverBurn;	
	default isPositive = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		target.PauseEffects(EET_AutoEssenceRegen, 'silver_dust');
		target.PlayEffect('transformation_block');
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		return EI_Cumulate;		
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.ResumeEffects(EET_AutoEssenceRegen, 'silver_dust');
		target.StopEffect('transformation_block');
	}
}

class W3Effect_MetabolicControl extends CBaseGameplayEffect
{
	default effectType = EET_MetabolicControl;	
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_MutagenTable extends CBaseGameplayEffect
{
	default effectType = EET_MutagenTable;	
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_W3EEHealthRegen extends CBaseGameplayEffect
{
	default effectType = EET_HealthRegen;
	default isPositive = true;
	
	private var healthRegenFactor : float;
	private var maximumHealth : float;
	private var npcTarget : CNewNPC;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		npcTarget = (CNewNPC)target;
		healthRegenFactor = npcTarget.GetHealthRegenFactor();
		if( target.UsesVitality() )
			maximumHealth = target.GetStatMax(BCS_Vitality);
		else
			maximumHealth = target.GetStatMax(BCS_Essence);
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	event OnUpdate( dt : float )
	{
		if( npcTarget.GetIsRegenActive() )
			target.Heal(maximumHealth * healthRegenFactor * dt);
		
		super.OnUpdate(dt);
	}
}

class W3Effect_YrdenAbilityEffect extends CBaseGameplayEffect
{
	default effectType = EET_YrdenAbilityEffect;
	default isPositive = true;
	
	private var npcTarget : CNewNPC;
	private var wasEffectAdded : bool;
	private var slowdownKey, shockKey : string;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		npcTarget = (CNewNPC)target;
	}
	
	event OnEffectRemoved()
	{
		EndYrdenEffects();
		super.OnEffectRemoved();
	}
	
	event OnUpdate( dt : float )
	{
		if( !wasEffectAdded && !npcTarget.IsFlying() )
			AddYrdenEffects();
		
		super.OnUpdate(dt);
	}
	
	private function BlockAbilities()
	{
		npcTarget.BlockAbility('Flying', true);
	}
	
	private function RestoreAbilities()
	{
		npcTarget.BlockAbility('Flying', false);
	}
	
	private function AddYrdenEffects()
	{
		var params, drainParams : SCustomEffectParams;
		var signPower : SAbilityAttributeValue;
		
		wasEffectAdded = true;
		BlockAbilities();
		
		shockKey = (string)RandRange(1000, 0);
		params.effectType = EET_YrdenHealthDrain;
		params.creator = super.GetCreator();
		params.sourceName = shockKey;
		params.isSignEffect = true;
		params.customAbilityName = '';
		params.duration = 1000;
		npcTarget.AddEffectCustom(params);
		
		if( npcTarget.HasTag('Vesemir') )
		{
			slowdownKey = (string)RandRange(2000, 0);
			params.effectType = EET_Slowdown;
			params.customPowerStatValue.valueBase = 0.f;
			params.customPowerStatValue.valueMultiplicative = 0.f;
			params.customPowerStatValue.valueAdditive = 0.f;
			params.creator = super.GetCreator();
			params.sourceName = slowdownKey;
			params.isSignEffect = true;
			params.customAbilityName = '';
			params.duration = 1000;
			npcTarget.AddEffectCustom(params);
		}
		//Kolaris - Enervation
		else if( ((W3PlayerWitcher)super.GetCreator()).HasAbility('Glyphword 18 _Stats', true) )
		{
			params.effectType = EET_Slowdown;
			params.customPowerStatValue.valueBase = 0.f;
			params.customPowerStatValue.valueMultiplicative = 0.f;
			params.customPowerStatValue.valueAdditive = 0.f;
			params.creator = super.GetCreator();
			params.sourceName = "Glyphword18";
			params.isSignEffect = true;
			params.duration = 1000;
			npcTarget.AddEffectCustom(params);
		}
	}
	
	private function EndYrdenEffects()
	{
		RestoreAbilities();
		npcTarget.RemoveAllBuffsWithSource(shockKey);
		npcTarget.RemoveAllBuffsWithSource(slowdownKey);
		npcTarget.RemoveAllBuffsWithSource("Glyphword18");
	}
}

class W3Effect_DimeritiumCharge extends CBaseGameplayEffect
{
    private var armorCharges : int;
	private var chargeTime : float;
    
	default effectType = EET_DimeritiumCharge;
	default isPositive = true;
 	default chargeTime = 5;
    
    private function ApplyCustomEffect( creator : CGameplayEntity, victim : CActor, source : string, effect : EEffectType, optional duration : float )
    {
		var customEffect : SCustomEffectParams;
		
		customEffect.creator = creator;
		customEffect.sourceName = source;
		customEffect.effectType = effect;
		if( duration != 0 )
			customEffect.duration = duration;
		victim.AddEffectCustom(customEffect);
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
					return true;
			}
		}
		
		return false;
    }
    
    private function IncreaseDimeritiumChargeTime()
    {
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		if( witcher.IsInCombat() )
		{
			armorCharges += 1;
			armorCharges = Min(armorCharges, 6);
			if( armorCharges < 6 )
				GetWitcherPlayer().PlayEffect('quen_force_discharge_bear_abl2_armour');
		}
    }
    
    public function SetDimeritiumCharge( nr : int )
    {
		armorCharges = nr;
    }
    
    public function IncreaseDimeritiumCharge( action : W3DamageAction )
    {
		var witcher : W3PlayerWitcher;
		var healthPerc : float;
		var i, diff, addCharges : int;
		
		witcher = (W3PlayerWitcher)action.victim;
		if( witcher && action.attacker && action.processedDmg.vitalityDamage > 0 && witcher.IsSetBonusActive(EISB_Dimeritium1) && !((W3Action_Attack)action).IsCountered() && IsDamageTypeCompatible(action) )
		{
			diff = armorCharges;
			healthPerc = witcher.GetStatMax(BCS_Vitality) / action.processedDmg.vitalityDamage;
			if( healthPerc < 15 )
				addCharges = 1;
			else
			if( healthPerc < 35 )
				addCharges = 2;
			else
				addCharges = 3;
			
			armorCharges = Min(armorCharges + addCharges, 6);
			diff = armorCharges - diff;
			for(i=0; i<diff; i+=1)
				witcher.PlayEffect('quen_force_discharge_bear_abl2_armour');
			
			ApplyCustomEffect(witcher, (CActor)action.attacker, "DimeritiumRepel", EET_Stagger);
		}
    }
    
    public function DischargeArmor( out action : W3DamageAction )
    {
		var dischargeEffect : W3DamageAction;
		var witcher : W3PlayerWitcher;
		var dischargeDamage : float;
		var actorAttacker : CActor;
		var surface	: CGameplayFXSurfacePost;
		var fx : CEntity;
		
		witcher = (W3PlayerWitcher)action.victim;
		actorAttacker = (CActor)action.attacker;
		if( witcher && actorAttacker && !((W3Action_Attack)action).IsCountered() && witcher.IsSetBonusActive(EISB_Dimeritium1) && action.IsActionMelee() && armorCharges >= 6 )
		{	
			dischargeDamage = 2250.f;
			dischargeEffect = new W3DamageAction in theGame.damageMgr;
			dischargeEffect.Initialize( witcher, action.attacker, witcher, 'DimeritiumDischarge', EHRT_Heavy, CPS_Undefined, false, true, false, false, 'hit_shock' );	
			dischargeEffect.AddDamage(theGame.params.DAMAGE_NAME_ELEMENTAL, dischargeDamage);
			dischargeEffect.SetCannotReturnDamage(true);
			dischargeEffect.SetCanPlayHitParticle(true);
			dischargeEffect.SetHitAnimationPlayType(EAHA_ForceNo);
			dischargeEffect.SetHitEffect('hit_electric_quen');
			dischargeEffect.SetHitEffect('hit_electric_quen', true);
			dischargeEffect.SetHitEffect('hit_electric_quen', false, true);
			dischargeEffect.SetHitEffect('hit_electric_quen', true, true);
			
			SetDimeritiumCharge(0);
			witcher.StopEffect('quen_force_discharge_bear_abl2_armour');
			actorAttacker.PlayEffect('hit_electric_quen');
			actorAttacker.PlayEffect('hit_electric_quen');
			fx = actorAttacker.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			ApplyCustomEffect(witcher, actorAttacker, "DimeritiumDischarge", EET_LongStagger);
			action.processedDmg.vitalityDamage /= 2;
			theGame.damageMgr.ProcessAction(dischargeEffect);
			
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(actorAttacker.GetWorldPosition(), 2, 40, 10, 5, 1);
			delete dischargeEffect;
		}
    }
	
	event OnUpdate( deltaTime : float )
	{
		if( chargeTime <= 0 )
		{
			IncreaseDimeritiumChargeTime();
			chargeTime = 3.5;
		}
		chargeTime -= deltaTime;
		
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectAddedPost()
	{
		var i : int;
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		super.OnEffectAddedPost();
		SetDimeritiumCharge(FactsQueryLatestValue("DimeritiumCharges"));
		for(i=0; i<armorCharges; i+=1)
			witcher.PlayEffect('quen_force_discharge_bear_abl2_armour');
	}
	
	event OnEffectRemoved()
	{
		FactsSet("DimeritiumCharges", armorCharges, -1);
		GetWitcherPlayer().StopEffect('quen_force_discharge_bear_abl2_armour');
		super.OnEffectRemoved();
	}
	
	public function GetDisplayCount() : int
	{
		return armorCharges;
	}
	
	public function GetMaxDisplayCount() : int
	{
		return 6;
	}
}

class W3Effect_SwordCritVigor extends CBaseGameplayEffect
{
	private var isReductionActive : bool;
	private var reductionTimer : float;
	private var weapon : CEntity;
	private var player : CR4Player;
	
	default reductionTimer = 0;
	default isReductionActive = false;
	default effectType = EET_SwordCritVigor;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isReductionActive )
		{
			reductionTimer -= dt;
			if( reductionTimer <= 0 )
				SetReductionActive(false, player);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		SetReductionActive(false, player);
		super.OnEffectRemoved();
	}
	
	public function SetReductionActive( b : bool, playerAttacker : CR4Player )
	{
		player = playerAttacker;
		weapon = player.GetInventory().GetItemEntityUnsafe(player.GetInventory().GetItemFromSlot('r_weapon'));
		
		if( b )
		{
			SetShowOnHUD( true );
			player.PlayEffect('free_cast');
			weapon.PlayEffect('runeword_yrden');
			reductionTimer = 10.f;
		}
		else
		{
			SetShowOnHUD( false );
			player.StopEffect('free_cast');
			weapon.StopEffect('runeword_yrden');
			reductionTimer = 0.f;
		}	
		isReductionActive = b;
	}
	
	public function GetReductionActive() : bool
	{
		return isReductionActive;
	}
}

class W3Effect_SwordRendBlast extends CBaseGameplayEffect
{
	private var burningTimer 	: float;
	private var burningActive 	: bool;
	private var weapon 			: CEntity;
	
	default effectType = EET_SwordRendBlast;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		if( burningTimer > 0 )
			burningTimer -= dt;
		
		if( burningTimer <= 0 && burningActive )
		{
			burningActive = false;
			burningTimer = 0.f;
			
			weapon.StopEffectIfActive('runeword_igni');
		}
	}	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function FireDischarge( attackAction : W3Action_Attack, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var surface	: CGameplayFXSurfacePost;
		var fireDamage : W3DamageAction;
		var damageValue : SAbilityAttributeValue;
		var npcVictim : CNewNPC;
		var fx : CEntity;
		
		if(	playerAttacker && attackAction.IsActionMelee() && attackAction.DealsAnyDamage() && ((W3PlayerWitcher)playerAttacker).IsInCombatAction_SpecialAttackHeavy() && playerAttacker.GetSpecialAttackTimeRatio() > 0.78f )
		{
			npcVictim = (CNewNPC)actorVictim;
			fireDamage = new W3DamageAction in theGame.damageMgr;
			fireDamage.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
			
			if( npcVictim.IsShielded( thePlayer ) )
			{
				npcVictim.ProcessShieldDestruction();
				fireDamage.AddEffectInfo(EET_Stagger);
			}
			else fireDamage.AddEffectInfo(EET_LongStagger);
			
			fireDamage.SetCannotReturnDamage(true);
			fireDamage.SetCanPlayHitParticle(false);
			fireDamage.SetForceExplosionDismemberment();
			
			//Kolaris - Rend Blast
			//damageValue = playerAttacker.GetInventory().GetItemAttributeValue(playerAttacker.GetInventory().GetItemFromSlot('r_weapon'), 'SlashingDamage');
			//fireDamage.AddDamage(theGame.params.DAMAGE_NAME_FIRE, damageValue.valueBase * (2.f + damageValue.valueMultiplicative) + damageValue.valueAdditive);
			fireDamage.AddDamage(theGame.params.DAMAGE_NAME_FIRE, 1500);
			fireDamage.SetHitAnimationPlayType(EAHA_ForceNo);
			theGame.damageMgr.ProcessAction(fireDamage);
			
			delete fireDamage;
			
			playerAttacker.SoundEvent('sign_igni_charge_begin');
			playerAttacker.SoundEvent('sign_igni_charge_begin');
			npcVictim.AddTimer('Runeword1DisableFireFX', 6);	
			npcVictim.PlayEffect('critical_burning');
			npcVictim.PlayEffect('critical_burning_csx');
			
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(npcVictim.GetWorldPosition(), 1.f, 30, 3, 6, 1);
			
			//Kolaris - Remove Old Enchantments
			//if( !playerAttacker.HasAbility('Runeword 4 _Stats', true) )
			if( !weapon )
				weapon = playerAttacker.GetInventory().GetItemEntityUnsafe(playerAttacker.GetInventory().GetItemFromSlot('r_weapon'));
			weapon.PlayEffectSingle('runeword_igni');
			burningActive = true;
			burningTimer = 7.f;
			
			fx = npcVictim.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_igni');
			fx.PlayEffect('critical_igni');
			fx = npcVictim.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_igni');
			fx.PlayEffect('mutation_1_hit_igni');
			GCameraShake(0.6f, false, thePlayer.GetWorldPosition(),,,, 0.85f);
		}
	}
}

class W3Effect_SwordInjuryHeal extends CBaseGameplayEffect
{
	default effectType = EET_SwordInjuryHeal;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function HealCombatInjury()
	{
		//Kolaris - Inis
		GetWitcherPlayer().GetInjuryManager().HealRandomInjury();
		RestorePoise();
	}
	
	//Kolaris - Inis
	private function RestorePoise()
	{
		var poiseEffect : W3Effect_Poise;
		var maxPoise : float;
		
		poiseEffect = (W3Effect_Poise)GetWitcherPlayer().GetBuff(EET_Poise);
		maxPoise = poiseEffect.GetMaxPoise();
		poiseEffect.SetPoise(maxPoise);
	}
	
}
//Kolaris - Cat Set
class W3Effect_SwordDancing extends CBaseGameplayEffect
{
	//private var isSwordDanceActive : bool;
	//private var swordDanceDuration : float;
	
	//default isSwordDanceActive = false;
	//default swordDanceDuration = 0;
	default effectType = EET_SwordDancing;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var inv			: CInventoryComponent;
		var swEnt		: CItemEntity;
		
		inv = target.GetInventory();
		
		//Kolaris - Disable Sword Fx
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) && !Options().DisableSpecialSwordFx() ) 
		{
			swEnt.PlayEffect( 'fast_attack_buff' );
		}
	
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		
		//Kolaris - Disable Sword Fx
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) && !Options().DisableSpecialSwordFx() )
		{
			swEnt.PlayEffectSingle( 'fast_attack_buff_hit' );			
			swEnt.StopEffect( 'fast_attack_buff' );
		}
	
		super.OnEffectRemoved();
	}
	
	protected function OnPaused()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) )
		{
			swEnt.StopEffect( 'fast_attack_buff' );
		}
		
		super.OnPaused();
	}
	
	protected function OnResumed()
	{
		var inv		: CInventoryComponent;
		var swEnt	: CItemEntity;
		
		inv = target.GetInventory();
		//Kolaris - Disable Sword Fx
		if( inv.GetCurrentlyHeldSwordEntity( swEnt ) && !Options().DisableSpecialSwordFx() )
		{
			swEnt.PlayEffect( 'fast_attack_buff' );
		}
	
		super.OnResumed();
	}
}

class W3Effect_SwordQuen extends CBaseGameplayEffect
{
	default effectType = EET_SwordQuen;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function BashCounterImpulse()
	{
		var player : W3PlayerWitcher = GetWitcherPlayer();
		var action : W3DamageAction;
		var ents : array<CGameplayEntity>;
		var pos : Vector;
		var i : int;
		
		if( player.GetStat(BCS_Focus) > 0.5f )
		{
			FindGameplayEntitiesInRange(ents, player, 3.f, 1000, , FLAG_OnlyAliveActors + FLAG_ExcludePlayer + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral);
			for(i=0; i<ents.Size(); i+=1)
			{
				action = new W3DamageAction in theGame;
				action.Initialize(player, ents[i], player, "SwordQuenEffect", EHRT_Heavy, CPS_Undefined, true, false, false, false);
				action.SetCannotReturnDamage(true);
				action.SetProcessBuffsIfNoDamage(true);
				
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				if( RandRange(100, 0) <= 15 )
					action.AddEffectInfo(EET_Knockdown);
				else
				if( RandRange(100, 0) <= 50 )
					action.AddEffectInfo(EET_LongStagger);
				else
					action.AddEffectInfo(EET_Stagger);
				((CActor)ents[i]).PlayHitEffect(action);
				
				theGame.damageMgr.ProcessAction(action);
				delete action;
			}
			
			GCameraShake(0.5f);
			
			player.PlayEffect('lasting_shield_impulse');
			
			player.DrainFocus(0.5f);
		}
	}
}

class W3Effect_SwordWraithbane extends CBaseGameplayEffect
{
	default effectType = EET_SwordWraithbane;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function StopWraithHealthRegen( action : W3DamageAction, actorVictim : CActor, victimMonsterCategory : EMonsterCategory )
	{
		if( victimMonsterCategory == MC_Specter && action.DealsAnyDamage() )
		{
			actorVictim.RemoveTimer('AddHealthRegenEffect');
			actorVictim.RemoveBuff(EET_HealthRegen, true, "W3EEHealthRegen");
		}
	}
}

class W3Effect_SwordBloodFrenzy extends CBaseGameplayEffect
{
	private var isFrenzyActive : bool;
	private var frenzyDuration : float;
	
	default frenzyDuration = 0;
	default isFrenzyActive = false;
	default effectType = EET_SwordBloodFrenzy;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isFrenzyActive )
		{
			frenzyDuration -= dt;
			if( frenzyDuration <= 0 )
				SetFrenzyActive(false);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetFrenzyActive( b : bool )
	{
		isFrenzyActive = b;
		if( b )
		{
			SetShowOnHUD( true );
			frenzyDuration = 5.f;
			target.AddAbility('SwordBloodFrenzyAbility', false);
		}
		else
		{
			SetShowOnHUD( false );
			target.RemoveAbility('SwordBloodFrenzyAbility');
		}
	}
}

class W3Effect_SwordKillBuff extends CBaseGameplayEffect
{
	private var isKillBuffActive : bool;
	
	default isKillBuffActive = false;
	default effectType = EET_SwordKillBuff;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetKillBuffActive( b : bool )
	{
		isKillBuffActive = b;
		if( isKillBuffActive )
			SetShowOnHUD( true );
		else
			SetShowOnHUD( false );
	}
	
	public function IsKillBuffActive() : bool
	{
		return isKillBuffActive;
	}
	
	public function BuffAttackDamage( out action : W3Action_Attack )
	{
		if( action && action.attacker == thePlayer && action.IsActionMelee() && isKillBuffActive )
		{
			action.MultiplyAllDamageBy(2.f);
			isKillBuffActive = false;
		}
	}
}

class W3Effect_SwordBehead extends CBaseGameplayEffect
{
	private var isBeheadEffectActive : bool;
	private var beheadEffectDur : float;
	
	default beheadEffectDur = 0;
	default isBeheadEffectActive = false;
	default effectType = EET_SwordBehead;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isBeheadEffectActive )
		{
			beheadEffectDur -= dt;
			if( beheadEffectDur <= 0 )
				SetBeheadEffectActive(false);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetBeheadEffectActive( b : bool )
	{
		isBeheadEffectActive = b;
		if( b )
		{
			SetShowOnHUD( true );
			beheadEffectDur = 10.f;
		}
		else
		{
			SetShowOnHUD( false );
			beheadEffectDur = 0.f;
		}
	}
	
	public function GetBeheadEffectActive() : bool
	{
		return isBeheadEffectActive;
	}
}

class W3Effect_SwordGas extends CBaseGameplayEffect
{
	private var gasEntity : W3ToxicCloud;
	
	default effectType = EET_SwordGas;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SpawnGasCloud( action : W3DamageAction, playerAttacker : CR4Player )
	{
		var ent : CEntityTemplate;
		
		if( playerAttacker && action.IsActionMelee() && action.DealsAnyDamage() && RandRange(100, 0) <= 15 )
		{
			gasEntity = (W3ToxicCloud)theGame.CreateEntity((CEntityTemplate)LoadResource("items\weapons\projectiles\petards\petard_dragons_dream_gas.w2ent", true), playerAttacker.GetWorldPosition(), playerAttacker.GetWorldRotation());
			gasEntity.explosionDamage.valueAdditive = 1850.f;
			gasEntity.SetBurningChance(0.1f);
			gasEntity.SetFromBomb(playerAttacker);
			gasEntity.SetIsFromClusterBomb(false);
			gasEntity.SetFriendlyFire(true);
			gasEntity.DestroyAfter(30.f);
		}
	}
}

enum EStoredAction
{
	ESA_FastAttack,
	ESA_StrongAttack,
	ESA_Counter,
	ESA_Parry,
	ESA_Dodge,
	ESA_None
}

enum EBuffedSign
{
	EBS_Aard,
	EBS_Igni,
	EBS_Yrden,
	EBS_Quen,
	EBS_Axii,
	EBS_None
}

class W3Effect_SwordSignDancer extends CBaseGameplayEffect
{
	private var actionCount : int;
	private var effectTimer : float;
	private var buffedSignType : EBuffedSign;
	private var storedActionType : EStoredAction;
	
	default actionCount = 0;
	default effectTimer = 0.f;
	default buffedSignType = EBS_None;
	default storedActionType = ESA_None;
	default effectType = EET_SwordSignDancer;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( buffedSignType != EBS_None )
		{
			effectTimer -= dt;
			if( effectTimer <= 0 )
			{
				RemoveAbilities(GetWitcherPlayer());
				actionCount = 0;
			}
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	private function StopWeaponEffects( player : W3PlayerWitcher )
	{
		var weapon : CEntity =  player.inv.GetItemEntityUnsafe(player.inv.GetItemFromSlot('r_weapon'));
		
		weapon.StopEffect('runeword_aard');
		weapon.StopEffect('runeword_igni');
		weapon.StopEffect('runeword_axii');
		weapon.StopEffect('runeword_quen');
		weapon.StopEffect('runeword_yrden');
		buffedSignType = EBS_None;
	}
	
	private function RemoveAbilities( player : W3PlayerWitcher )
	{
		StopWeaponEffects(player);
		player.RemoveAbility('SignDancerAard');
		player.RemoveAbility('SignDancerIgni');
		player.RemoveAbility('SignDancerYrden');
		player.RemoveAbility('SignDancerQuen');
		player.RemoveAbility('SignDancerAxii');
	}
	
	private function HandleAbilities( actionType : EStoredAction, player : W3PlayerWitcher )
	{
		var weapon : CEntity =  player.inv.GetItemEntityUnsafe(player.inv.GetItemFromSlot('r_weapon'));
		
		RemoveAbilities(player);
		switch(actionType)
		{
			case ESA_FastAttack:
				if( actionCount > 1 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerAard', false);
					weapon.PlayEffect('runeword_aard');
					buffedSignType = EBS_Aard;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_StrongAttack:
				if( actionCount > 1 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerIgni', false);
					weapon.PlayEffect('runeword_igni');
					buffedSignType = EBS_Igni;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_Counter:
				if( actionCount > 1 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerAxii', false);
					weapon.PlayEffect('runeword_axii');
					buffedSignType = EBS_Axii;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_Parry:
				if( actionCount > 1 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerQuen', false);
					weapon.PlayEffect('runeword_quen');
					buffedSignType = EBS_Quen;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_Dodge:
				if( actionCount > 0 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerYrden', false);
					weapon.PlayEffect('runeword_yrden');
					buffedSignType = EBS_Yrden;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
		}
	}
	
	public function RemoveSignAbility( signType : ESignType, signOwner : W3SignOwner )
	{
		switch(signType)
		{
			case ST_Aard:
				if( buffedSignType == EBS_Aard )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Igni:
				if( buffedSignType == EBS_Igni )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Yrden:
				if( buffedSignType == EBS_Yrden )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Quen:
				if( buffedSignType == EBS_Quen )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Axii:
				if( buffedSignType == EBS_Axii )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
		}
	}
	
	private var lastActionCount : float;	default lastActionCount = 0.f;
	public function CountActionType( actionType : EStoredAction )
	{
		var player : W3PlayerWitcher = GetWitcherPlayer();
		
		if( theGame.GetEngineTimeAsSeconds() - lastActionCount > 0.15f )
		{
			if( storedActionType == actionType )
			{
				actionCount += 1;
			}
			else
			{
				storedActionType = actionType;
				actionCount = 1;
			}
			
			HandleAbilities(actionType, player);
		}
		lastActionCount = theGame.GetEngineTimeAsSeconds();
	}
}

class W3Effect_SwordReachoftheDamned extends CBaseGameplayEffect
{
	default effectType = EET_SwordReachoftheDamned;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ExpandDamageTypes( out damages : array<SRawDamage>, action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var i : int;
		var elementalIdx : int;
		var elementalDmg : SRawDamage;
		var damageValue : float;
		
		if( playerAttacker && action.IsActionMelee() )
		{
			elementalIdx = -1;
			for(i=0; i<damages.Size(); i+=1)
			{
				if( damages[i].dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL )
				{
					elementalIdx = i;
					break;
				}
			}
			
			damageValue = 0.f;
			if( playerAttacker.GetStatPercents(BCS_Vitality) <= 0.5f )
				damageValue += 100.f * playerAttacker.GetStatPercents(BCS_Vitality);
			if( actorVictim.GetHealthPercents() <= 0.5f )
				damageValue += 100.f * actorVictim.GetHealthPercents();
				
			if( elementalIdx != -1 )
			{
				damages[elementalIdx].dmgVal += damageValue;
			}
			else
			{
				elementalDmg.dmgType = theGame.params.DAMAGE_NAME_ELEMENTAL;
				elementalDmg.dmgVal = damageValue;
				damages.PushBack(elementalDmg);
			}
		}
	}
	
	public function MultiplyAdrenaline( out adrenalineVal : float )
	{
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) <= 0.5f )
			adrenalineVal *= 2.f;
	}
}

class W3Effect_SwordDarkCurse extends CBaseGameplayEffect
{
	private var effectTimer : float;
	
	default effectTimer = 0;
	default effectType = EET_SwordDarkCurse;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		effectTimer = 5.f;
	}
	
	event OnUpdate( dt : float )
	{
		effectTimer -= dt;
		if( effectTimer <= 0 )
		{
			target.DrainVitality(target.GetStatMax(BCS_Vitality) * 0.01f * dt);
			if( target.GetHealth() <= 10.0f )
				target.Kill('DarkCurse', true);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ResetCurseAttackTimer()
	{
		effectTimer = 5.f;
	}
}

class W3Effect_SwordDesperateAct extends CBaseGameplayEffect
{
	default effectType = EET_SwordDesperateAct;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) <= 0.5f )
			SetShowOnHUD( true );
		else
			SetShowOnHUD( false );
		
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function RestoreStatsExecution()
	{
		//Kolaris - Desperate Act
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) <= 0.5f )
		{
			GetWitcherPlayer().GainStat(BCS_Vitality, GetWitcherPlayer().GetStatMax(BCS_Vitality) * 0.5f);
			GetWitcherPlayer().GainStat(BCS_Stamina, GetWitcherPlayer().GetStatMax(BCS_Stamina) - GetWitcherPlayer().GetStat(BCS_Stamina));
		}
	}
}

class W3Effect_SwordRedTear extends CBaseGameplayEffect
{
	default effectType = EET_SwordRedTear;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function BoostAttackDamage( action : W3DamageAction, playerAttacker : CR4Player )
	{
		//Kolaris - Ultimatum
		if( playerAttacker && playerAttacker.GetStatPercents(BCS_Vitality) <= 0.5f && action.IsActionMelee() )
			action.MultiplyAllDamageBy(2.f - playerAttacker.GetStatPercents(BCS_Vitality) * 2.f);
	}
}

class W3Effect_InjuredArm extends CBaseGameplayEffect
{
	default effectType = EET_InjuredArm;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_InjuredLeg extends CBaseGameplayEffect
{
	default effectType = EET_InjuredLeg;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_InjuredTorso extends CBaseGameplayEffect
{
	default effectType = EET_InjuredTorso;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_InjuredHead extends CBaseGameplayEffect
{
	default effectType = EET_InjuredHead;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_GlyphDebuff extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_GlyphDebuff;
	default attributeName = 'glyphDebuff';
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	private function BlockAbilities(block: bool)
	{
		//Leshen
		target.BlockAbility('Shapeshifter', block);
		target.BlockAbility('Summon', block);
		target.BlockAbility('Swarms', block);
		
		//Wraiths
		target.BlockAbility('Specter', block);
		target.BlockAbility('ShadowForm', block);
		target.BlockAbility('DustCloud', block);
		target.BlockAbility('ContactBlindness', block);
		target.BlockAbility('FlashStep', block);
		
		//Golems & Elementals
		target.BlockAbility('Wave', block);
		target.BlockAbility('GroundSlam', block);
		target.BlockAbility('SpawnArena', block);
		target.BlockAbility('ThrowFire', block);
		
		//Vampires
		target.BlockAbility('Flashstep', block);
		target.BlockAbility('Teleport', block);
		target.BlockAbility('Scream', block);
		target.BlockAbility('Invisibility', block);
		target.BlockAbility('Hypnosis', block);
		
		//Water Hag
		target.BlockAbility('MudTeleport', block);
		
		//Fogling
		target.BlockAbility('MistForm', block);
		
		//Fiend
		target.BlockAbility('BiesHypnosis', block);
		
		//Sorceress
		target.BlockAbility('ablTeleport', block);
		
		//Wight
		target.BlockAbility('WightTeleport', block);
		
		//Various From Dimeritium Bombs
		target.BlockAbility('Doppelganger', block);
		target.BlockAbility('Fireball', block);
		target.BlockAbility('Magical', block);
		target.BlockAbility('SwarmTeleport', block);
		target.BlockAbility('SwarmShield', block);
		target.BlockAbility('Frost', block);
		
		//Various From Monster Abilities
		target.BlockAbility('FireShield', block);
		target.BlockAbility('IceArmor', block);
		target.BlockAbility('MagicShield', block);
		target.BlockAbility('MistCharge', block);
		target.BlockAbility('Shout', block);
		target.BlockAbility('Thorns', block);
		target.BlockAbility('ThrowIce', block);
		target.BlockAbility('Tornado', block);
	}
}

class W3Effect_Electroshock extends W3DamageOverTimeEffect
{
	private var updateFX : float;
	private var fx : CEntity;
	private var immobilize : SCustomEffectParams;
	
	default effectType = EET_Electroshock;
	default resistStat = CDS_ShockRes;
	default updateFX = 0.f;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		//Kolaris - Electrocution
		if( ((W3PlayerWitcher)GetCreator()).HasAbility('Runeword 28 _Stats', true) || ((W3PlayerWitcher)GetCreator()).HasAbility('Runeword 29 _Stats', true) || ((W3PlayerWitcher)GetCreator()).HasAbility('Runeword 30 _Stats', true) )
		{
			if( target.IsImmuneToBuff(EET_Immobilized) )
				immobilize.effectType = EET_Paralyzed;
			else
				immobilize.effectType = EET_Immobilized;
			immobilize.creator = GetCreator();
			immobilize.sourceName = "Runeword28";
			immobilize.duration = 3.f * (1.f - ((CNewNPC)target).GetNPCCustomStat(theGame.params.DAMAGE_NAME_SHOCK));
			target.AddEffectCustom(immobilize);
		}
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		updateFX -= dt;
		if( updateFX <= 0 )
		{
			updateFX = 0.6f;
			fx = target.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			target.SoundEvent("sign_yrden_shock_activate");
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_SlowdownFirestream extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_SlowdownFirestream;
	default attributeName = 'slowdownFirestream';
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var slowMagnitude : float;
		super.OnEffectAdded(customParams);
		
		//Kolaris - Purgation
		if( GetWitcherPlayer().HasAbility('Glyphword 10 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 11 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 12 _Stats', true) )
			target.CreateFXEntityAtPelvis('runeword_4', true);
		
		if( !target.IsHuge() )
			slowMagnitude = 1.f - 0.25f;
		else
			slowMagnitude = 1.f - 0.18f;
		slowdownCauserId = target.SetAnimationSpeedMultiplier(slowMagnitude);
	}
	
	event OnEffectRemoved()
	{
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
		super.OnEffectRemoved();
	}	
}

class W3Effect_HarmonyAard extends CBaseGameplayEffect
{
	default effectType = EET_HarmonyAard;
	default isPositive = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_HarmonyAxii extends CBaseGameplayEffect
{
	default effectType = EET_HarmonyAxii;
	default isPositive = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_HarmonyIgni extends CBaseGameplayEffect
{
	default effectType = EET_HarmonyIgni;
	default isPositive = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_HarmonyQuen extends CBaseGameplayEffect
{
	default effectType = EET_HarmonyQuen;
	default isPositive = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_HarmonyYrden extends CBaseGameplayEffect
{
	default effectType = EET_HarmonyYrden;
	default isPositive = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

abstract class W3Decoction_Effect extends CBaseGameplayEffect
{
	default isPositive = true;
	default isNegative = false;
	default isNeutral = false;
	default isPotionEffect = true;
	default isDecoctionEffect = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)target;
		if( !witcher )
		{
			isActive = false;
			return false;
		}
		
		super.OnEffectAdded(customParams);
	}
	
	public function OnLoad( target : CActor, effectManager : W3EffectManager )
	{
		super.OnLoad(target, effectManager);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Decoction1_Effect extends W3Decoction_Effect // more damage on bleeding enemies and bleed proc triggers speed
{
	private var decoctionAbilityName : name;
	private var isSpeedActive : bool;
	private var updateTime : float;
	
	default effectType = EET_Decoction1;
	default decoctionAbilityName = 'Decoction1EffectSpeed';
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		isSpeedActive = false;
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		if( isSpeedActive )
		{
			updateTime -= dt;
			if( updateTime <= 0 )
			{
				target.RemoveAbility(decoctionAbilityName);
				isSpeedActive = false;
			}
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility(decoctionAbilityName);
	}
	
	public function ApplySpeedBuff( action : W3DamageAction )
	{
		if( action.GetAppliedBleeding() && action.DealsAnyDamage() && (action.IsActionMelee() || action.IsActionRanged()) )
		{
			target.AddAbility(decoctionAbilityName, false);
			isSpeedActive = true;
			updateTime = 3.f;
		}
	}
	
	public function ApplyDamageBuff( out action : W3DamageAction, actorVictim : CActor )
	{
		if( action.DealsAnyDamage() && (action.IsActionMelee() || action.IsActionRanged()) )
		{
			if( actorVictim.UsesEssence() )
				action.processedDmg.essenceDamage *= 1.f + 0.02f * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks();
			else
				action.processedDmg.vitalityDamage *= 1.f + 0.02f * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks();
		}
	}
}

class W3Decoction2_Effect extends W3Decoction_Effect // healing on kills below 30% health and longer adrenaline degen delay
{
	default effectType = EET_Decoction2;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function HealPlayer( action : W3DamageAction, playerAttacker : CR4Player )
	{
		//Kolaris - Necrophage Decoction
		//if( action.DealsAnyDamage() && action.IsActionMelee() && playerAttacker.GetStatPercents(BCS_Vitality) < 0.3f )
			playerAttacker.GainStat(BCS_Vitality, (playerAttacker.GetStatMax(BCS_Vitality) - playerAttacker.GetStat(BCS_Vitality)) * 0.1f);
	}
}

class W3Decoction3_Effect extends W3Decoction_Effect // gives defense when hit
{
	private saved var hardeningStacks : int;
	private var updateTime : float;
	
	default effectType = EET_Decoction3;
	default updateTime = 5;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( hardeningStacks > 0 )
		{
			updateTime -= dt;
			if( updateTime <= 0 )
			{
				hardeningStacks = Max(0, hardeningStacks - 1);
			}
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ReduceDamage( out action : W3DamageAction )
	{
		if( action.IsActionMelee() )
		{
			action.processedDmg.vitalityDamage *= 1.f - 0.05f * hardeningStacks;
			hardeningStacks = Min(5, hardeningStacks + 1);
			updateTime = 5.f;
		}
	}
	
	//Kolaris - Ogroid Decoction
	public function GetHardeningStacks() : int
	{
		return hardeningStacks;
	}
}

class W3Decoction4_Effect extends W3Decoction_Effect
{
	private var injuryTimer : float;
	private var activeWeather : SWeatherBonus;
	
	default effectType = EET_Decoction4;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		injuryTimer = 10;
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		injuryTimer -= dt;
		if( injuryTimer <= 0 )
		{
			//Kolaris - Cursed Decoction
			/*if( RandRange(100, 0) <= 30 )
				target.GetInjuryManager().HealRandomInjury();*/
				
			//activeWeather.moonState  = GetCurMoonState();
			//if( (activeWeather.moonState == EMS_Full || activeWeather.moonState == EMS_Red) && (activeWeather.dayPart == EDP_Dawn || activeWeather.dayPart == EDP_Dusk || activeWeather.dayPart == EDP_Midnight) )
			activeWeather.dayPart = GetDayPart(GameTimeCreate());
			if( activeWeather.dayPart == EDP_Midnight )
			{
				target.AddAbility('Decoction4EffectFullMoon', false);
			}
			else target.RemoveAbility('Decoction4EffectFullMoon');
			
			injuryTimer = 10;
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility('Decoction4EffectFullMoon');
	}
}

class W3Decoction5_Effect extends W3Decoction_Effect // boosts fist damage and makes it do weird shit
{
	private saved var effectArray : array<EEffectType>;
	
	default effectType = EET_Decoction5;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		effectArray.PushBack(EET_SlowdownFrost);
		effectArray.PushBack(EET_Bleeding);
		effectArray.PushBack(EET_Burning);
		effectArray.PushBack(EET_Confusion);
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ApplyDamageBuff( out action : W3DamageAction, playerAttacker : CR4Player )
	{
		if( action.IsActionMelee() && playerAttacker.IsWeaponHeld('fist') )
		{
			action.processedDmg.essenceDamage *= 3.f;
			action.processedDmg.vitalityDamage *= 1.25f;
			if( RandRange(100, 0) <= 15 )
				action.AddEffectInfo(effectArray[RandRange(effectArray.Size(), 0)]);
		}
	}
	
	//Kolaris - Elemental Decoction
	public function ReduceElementalResists( dmgType : name, damage : float, npc : CNewNPC )
	{
		var amount : float;
		
		if( npc.UsesEssence() )
			amount = damage / npc.GetStatMax(BCS_Essence);
		else
			amount = damage / npc.GetStatMax(BCS_Vitality);
		
		switch ( dmgType )
		{
			case 'ElementalDamage' :
				npc.ReduceNPCStat( 'force', amount );
				npc.ReduceNPCStat( 'frost', amount );
				npc.ReduceNPCStat( 'fire', amount );
				npc.ReduceNPCStat( 'shock', amount );
				npc.ReduceNPCStat( 'poison', amount );
				break;
			case 'ForceDamage' :
				npc.ReduceNPCStat( 'ethereal', amount );
				npc.ReduceNPCStat( 'frost', amount );
				npc.ReduceNPCStat( 'fire', amount );
				npc.ReduceNPCStat( 'shock', amount );
				npc.ReduceNPCStat( 'poison', amount );
				break;
			case 'FrostDamage' :
				npc.ReduceNPCStat( 'ethereal', amount );
				npc.ReduceNPCStat( 'force', amount );
				npc.ReduceNPCStat( 'fire', amount );
				npc.ReduceNPCStat( 'shock', amount );
				npc.ReduceNPCStat( 'poison', amount );
				break;
			case 'FireDamage' :
				npc.ReduceNPCStat( 'ethereal', amount );
				npc.ReduceNPCStat( 'force', amount );
				npc.ReduceNPCStat( 'frost', amount );
				npc.ReduceNPCStat( 'shock', amount );
				npc.ReduceNPCStat( 'poison', amount );
				break;
			case 'ShockDamage' :
				npc.ReduceNPCStat( 'ethereal', amount );
				npc.ReduceNPCStat( 'force', amount );
				npc.ReduceNPCStat( 'frost', amount );
				npc.ReduceNPCStat( 'fire', amount );
				npc.ReduceNPCStat( 'poison', amount );
				break;
			case 'PoisonDamage' :
				npc.ReduceNPCStat( 'ethereal', amount );
				npc.ReduceNPCStat( 'force', amount );
				npc.ReduceNPCStat( 'frost', amount );
				npc.ReduceNPCStat( 'fire', amount );
				npc.ReduceNPCStat( 'shock', amount );
				break;
			default :
				break;
		}
	}
}

class W3Decoction6_Effect extends W3Decoction_Effect // ability to attack specters in shadow form, disable health regen on hit
{
	default effectType = EET_Decoction6;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		target.AddAbility('Decoction6Ability', false);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility('Decoction6Ability');
	}
}

class W3Decoction7_Effect extends W3Decoction_Effect // passive quen on hit - copy over from wraith
{
	private var updateTimer : float;
	private var activeWeather : SWeatherBonus;
	
	default effectType = EET_Decoction7;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		updateTimer = 10;
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		updateTimer -= dt;
		if( updateTimer <= 0 )
		{
			activeWeather.dayPart = GetDayPart(GameTimeCreate());
			
			if( activeWeather.dayPart == EDP_Dawn )
				target.AddAbility('Decoction7AbilityDawn', false);
			else
				target.RemoveAbility('Decoction7AbilityDawn');
			
			if( activeWeather.dayPart == EDP_Dusk )
				target.AddAbility('Decoction7AbilityDusk', false);
			else
				target.RemoveAbility('Decoction7AbilityDusk');
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility('Decoction7AbilityDawn');
		target.RemoveAbility('Decoction7AbilityDusk');
	}
	
	public function ActivateQuen( action : W3DamageAction, witcherPlayer : W3PlayerWitcher )
	{
		var quenShield : W3QuenEntity;
		
		if( RandRange(100, 0) <= 40 && action.DealsAnyDamage() && !action.IsDoTDamage() )
		{
			quenShield = (W3QuenEntity)theGame.CreateEntity(witcherPlayer.GetSignTemplate(ST_Quen), witcherPlayer.GetWorldPosition(), witcherPlayer.GetWorldRotation());
			quenShield.Init(witcherPlayer.GetSignOwner(), witcherPlayer.GetSignEntity(ST_Quen), true, false, true);
			quenShield.OnStarted();
			quenShield.OnThrowing();
			quenShield.OnEnded();
			
			if( !witcherPlayer.IsAnyQuenActive() )
			{
				quenShield = (W3QuenEntity)theGame.CreateEntity(witcherPlayer.GetSignTemplate(ST_Quen), witcherPlayer.GetWorldPosition(), witcherPlayer.GetWorldRotation());
				quenShield.Init(witcherPlayer.GetSignOwner(), witcherPlayer.GetSignEntity(ST_Quen), true, false, true);
				quenShield.OnStarted();
				quenShield.OnThrowing();
				quenShield.OnEnded();
			}
		}
	}
}

class W3Decoction8_Effect extends W3Decoction_Effect // attack speed and power buff right after dodge
{
	private var decoctionAbilityName : name;
	private var effectTimeLeft : float;
	private var isEffectActive : bool;
	
	default effectType = EET_Decoction8;
	default decoctionAbilityName = 'Decoction8EffectAttack';
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		isEffectActive = false;
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		if( isEffectActive )
		{
			effectTimeLeft -= dt;
			if( effectTimeLeft <= 0 )
			{
				isEffectActive = false;
				target.RemoveAbility(decoctionAbilityName);
			}
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility(decoctionAbilityName);
	}
	
	public function AddDodgeBuff()
	{
		target.AddAbility(decoctionAbilityName, false);
		effectTimeLeft = 2.1f;
		isEffectActive = true;
	}
}

class W3Decoction9_Effect extends W3Decoction_Effect // combining attacks raises attack power and sign power - copy over from forktail
{
	private var abilityNameLight, abilityNameHeavy, abilityNameSign : name;
	private var hasLightBoost, hasHeavyBoost, hasSignBoost : bool;
	private var pauseDuration, pauseDT : float;

	default effectType = EET_Decoction9;
	default hasLightBoost = false;
	default hasHeavyBoost = false;
	default hasSignBoost = false;
	default pauseDuration = 3.f;
	default abilityNameLight = 'Decoction9EffectLight';
	default abilityNameHeavy = 'Decoction9EffectHeavy';
	default abilityNameSign	= 'Decoction9EffectSign';

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		ClearBoost();
	}

	event OnUpdate(dt : float)
	{
		var chargeCount : int;
		var counters : array<int>;
		
		super.OnUpdate(dt);
		
		if( pauseDT > 0 )
			pauseDT -= dt;
		
		if( pauseDT <= 0 )
		{
			counters.PushBack(FactsQuerySum("decoction_9_attack_light") * 2);
			counters.PushBack(FactsQuerySum("decoction_9_attack_heavy") * 4);
			counters.PushBack(FactsQuerySum("decoction_9_sign") * 6);
			
			if( !hasLightBoost )
			{
				chargeCount = GetCount(counters, 0);
				if( chargeCount >= 12 )
				{
					AddBoost(abilityNameLight);
					hasLightBoost = true;
				}
			}
			
			if( !hasHeavyBoost )
			{
				chargeCount = GetCount(counters, 1);
				if( chargeCount >= 12 )
				{
					AddBoost(abilityNameHeavy);
					hasHeavyBoost = true;
				}
			}
			
			if( !hasSignBoost )
			{
				chargeCount = GetCount(counters, 2);
				if( chargeCount >= 12 )
				{
					AddBoost(abilityNameSign);
					hasSignBoost = true;
				}
			}
		}
	}
	
	private function GetCount( counters : array<int>, exclude : int) : int
	{
		var charges, nonZeros, i : int;
		
		charges = 0;
		nonZeros = 0;
		for(i=0; i<3; i+=1)
		{
			if( i == exclude )
				continue;
				
			if( counters[i] > 0 )
				nonZeros += 1;
				
			charges += counters[i];			
		}
		
		if( nonZeros >= 3 )
			charges *= 2;
		else
		if( nonZeros == 2 )
			charges = (int)RoundMath(charges * 1.5f);
			
		return charges;
	}

	private function AddBoost( boostName : name )
	{
		target.AddAbility(boostName, false);
		//theGame.witcherLog.AddMessage("Adding Boost: " + NameToString(boostName));
	}
	
	public function HasBoost( type : string ) : bool
	{
		switch (type) 
		{
			case "light"	:	return hasLightBoost;
			case "heavy"	:	return hasHeavyBoost;
			case "sign"		:	return hasSignBoost;
			default			:	return false;
		}
	}
	
	public function BlockBoost()
	{
		ClearBoost();
		pauseDT = pauseDuration;
	}

	public function ClearBoost()
	{
		hasSignBoost = false;
		hasLightBoost = false;
		hasHeavyBoost = false;
		FactsRemove("decoction_9_sign");
		FactsRemove("decoction_9_attack_light");
		FactsRemove("decoction_9_attack_heavy");
		target.RemoveAbility(abilityNameSign);
		target.RemoveAbility(abilityNameLight);
		target.RemoveAbility(abilityNameHeavy);
		//theGame.witcherLog.AddMessage("Clearing Boosts");
	}
	
	public function BoostSigns()
	{
		if( hasSignBoost )
		{
			ClearBoost();
		}
		
		FactsAdd("decoction_9_sign", 1);
	}
}

class W3Decoction10_Effect extends W3Decoction_Effect // disable poison weaken and proccing bleed plays mutation toxic blood thing and poison enemies
{
	default effectType = EET_Decoction10;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ApplyPoison( out action : W3DamageAction )
	{
		var customParams : SCustomEffectParams;
		var hitReactionType	: EHitReactionType;
		var damageValue : SAbilityAttributeValue;
		var isAtBack : bool;
		
		if( action.GetAppliedBleeding() )
		{
			hitReactionType = action.GetHitReactionType();
			isAtBack = ((CR4Player)action.victim).IsAttackerAtBack(action.attacker);
			
			customParams.duration = 2.f;
			customParams.effectType = EET_Acid;
			customParams.creator = action.victim;
			customParams.effectValue = damageValue;
			customParams.sourceName = 'Poisoning';
			((CActor)action.attacker).AddEffectCustom(customParams);
			action.attacker.SoundEvent('ep2_mutations_04_poison_blood_spray_enemy');
			((CActor)action.attacker).ApplyPoisoning(2, action.victim, "Poisoning", true);
			if( hitReactionType != EHRT_Heavy )
			{
				if( isAtBack )
					action.SetHitEffect('light_hit_back_toxic', true);
				else
					action.SetHitEffect('light_hit_toxic');
			}
			else
			{
				if( isAtBack )
					action.SetHitEffect('heavy_hit_back_toxic' ,true);
				else
					action.SetHitEffect('heavy_hit_toxic');
			}
			damageValue.valueAdditive = 55.f;
		}
	}
}

class W3Effect_ToxicityFever extends CBaseGameplayEffect
{
	var witcher 		: W3PlayerWitcher;
	var attributeValue 	: SAbilityAttributeValue;
	var toxicityPerc	: float;
	var toxicityMax		: float;
	var isFeverActive	: bool;	
	var updateInterval	: float;
	var updateCounter	: float;
	//var effectDur	: float;
	saved var signalDur	: float;
	//var alchemy_s15_lvl	: int;
	var feverCured		: bool; default feverCured = false;
	var isFeverSoundPlaying : bool;
	
	default effectType = EET_ToxicityFever;	
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		//Kolaris - Alchemy EXP
		Experience().AwardAlchemyUsageXP(false, true, false, false);
		super.OnEffectAdded(customParams);
		
		InitEffect();
	}
	
	event OnUpdate(deltaTime : float)
	{
		super.OnUpdate(deltaTime);
		
		updateInterval += deltaTime;
		
		if( updateInterval < 1.0f || isFeverActive )
			return false;
		else
		{
			updateCounter += updateInterval;
			updateInterval = 0.f;
		}
		
		if( updateCounter >= signalDur && !isFeverActive )
		{
			updateCounter = signalDur;
			ApplyFever();
		}
		else
		{
			theSound.SoundParameter("feverrate", updateCounter * (100.f * PowF(signalDur, -1)) );
		}
	}
	
	private function InitEffect()
	{
		toxicityPerc 	= target.GetStatPercents(BCS_Toxicity);
		toxicityMax 	= target.GetStatMax(BCS_Toxicity);
		
		//Kolaris - Toxicity Rework
		signalDur 		= 5.f;
		
		//isFeverSoundPlaying = true;
		if( !theSound.SoundIsBankLoaded("fever02a.bnk") )
			theSound.SoundLoadBank("fever02a.bnk", false);
		theSound.SoundEvent("play_fever_loop");
		//theSound.SetFeverSound(1.f);
		EnableDrunkFx(signalDur);
	}
	
	event OnEffectRemoved()
	{
		RemoveFeverEffects();
		super.OnEffectRemoved();
	}
	
	private function RemoveFeverEffects()
	{
		isFeverActive = false;
		
		if( !theSound.SoundIsBankLoaded("fever02a.bnk") )
			theSound.SoundLoadBank("fever02a.bnk", false);
			
		theSound.SoundEvent("stop_fever_loop");
		
		
		DisableDrunkFx(3.f);
		((W3PlayerWitcher)target).UpdateWoundedState(true);
		if( !feverCured )
			((W3Effect_Toxicity)target.GetBuff(EET_Toxicity)).ClearToxicityFever();
			
		target.RemoveAllBuffsWithSource('ToxicityFeverEffect');
	}
	
	private function ApplyFever()
	{
		var effectParams : SCustomEffectParams;
		
		isFeverActive = true;
		
		//Blindness
		effectParams.effectType = EET_Blindness;
		effectParams.sourceName = "ToxicityFeverEffect";
		effectParams.duration = 4.f;
		target.AddEffectCustom(effectParams);
		
		((W3PlayerWitcher)target).GetAdrenalineEffect().ResetAdrenaline();
		
		//Damage and delay stamina
		target.DrainStamina(ESAT_FixedValue, 100.f * MinF(target.GetStatPercents(BCS_Stamina), toxicityPerc * 0.1f), toxicityPerc * 3.f);
		
		//Drain and stop Vigor 
		((W3PlayerWitcher)target).DrainFocus(1.f * toxicityPerc);
	}
	
	public function CureFever()
	{
		feverCured = true;
		target.RemoveEffect(this);
	}

	public function IsFeverActive() : bool
	{
		return isFeverActive;
	}
}

class W3Effect_Poise extends CBaseGameplayEffect
{
	private saved var pauseTimer : float;
	private saved var maxPoise : float;
	private saved var poiseValue : float;
	private var poiseBreakTimer : float;
	private var debugTimer : float;
	private var swordSprite : CScriptedFlashSprite;
	private var playerTarget : W3PlayerWitcher;

	default effectType = EET_Poise;
	default poiseValue = 0.f;
	default pauseTimer = 0.f;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		UpdateMaxPoise();
		poiseValue = maxPoise;
		super.OnEffectAdded(customParams);
	}
	
	public final function ArmorPoiseValue() : float
	{
		var armorPieces : array<SArmorCount>;
		var poiseVal : float;
		
		armorPieces = playerTarget.GetArmorCountOrig();
		if( playerTarget.IsHelmetEquipped(EIST_Gothic) || playerTarget.IsHelmetEquipped(EIST_Meteorite) || playerTarget.IsHelmetEquipped(EIST_Dimeritium) )
			armorPieces[3].all += 1;
		
		poiseVal = armorPieces[1].all * 3.f + armorPieces[2].all * 6.f + armorPieces[3].all * 10.f;
		
		if( playerTarget.IsSetBonusActive(EISB_Gothic2) )
			poiseVal += 30.f;
		
		return poiseVal;
	}
	
	public final function BaseStatsPoiseValue() : float
	{
		//Kolaris - Endure Pain
		return 100.f /*+ 10.f * playerTarget.GetSkillLevel(S_Alchemy_s20) * playerTarget.GetStatPercents(BCS_Toxicity)*/;
	
	}
	
	public function UpdateMaxPoise()
	{
		var poiseVal : SAbilityAttributeValue;
		
		playerTarget = (W3PlayerWitcher)target;
		poiseVal = playerTarget.GetAttributeValue('poise_bonus');
		//Kolaris - Brawler
		maxPoise = 	poiseVal.valueAdditive + BaseStatsPoiseValue() + ArmorPoiseValue() + 10.f * playerTarget.GetSkillLevel(S_Perk_21);
		
		if( maxPoise < poiseValue )
			poiseValue = maxPoise;
	}
	
	private function AdrenalineSword()
	{
		var poise : float;
		
		if( !thePlayer.IsCiri() )
		{
			swordSprite = theGame.GetHud().GetHudModule('WolfHeadModule').GetModuleFlash().GetChildFlashSprite("mcSwordIcon");
			
			poise = GetPoisePercentage();
			swordSprite.SetVisible(true);
			if( poise > 0.801 )
				swordSprite.GotoAndStopFrameNumber(7);
			else
			if( poise > 0.65 )
				swordSprite.GotoAndStopFrameNumber(6);
			else
			if( poise > 0.5 )
				swordSprite.GotoAndStopFrameNumber(5);
			else
			if( poise > 0.35 )
				swordSprite.GotoAndStopFrameNumber(4);
			else
			if( poise > 0.2 )
				swordSprite.GotoAndStopFrameNumber(3);
			else
				swordSprite.GotoAndStopFrameNumber(2);
		}
		else swordSprite.SetVisible(false);
	}
	
	event OnUpdate( dt : float )
	{
		var regenMult : float;
		
		super.OnUpdate(dt);
		
		AdrenalineSword();
		
		//Kolaris - Renewing Shield
		if( playerTarget.IsQuenActive(true) && playerTarget.CanUseSkill(S_Magic_s14) )
			poiseValue = ClampF(poiseValue + GetMaxPoise() * 0.05f * playerTarget.GetSkillLevel(S_Magic_s14) * dt, 0, maxPoise);
		
		if( poiseBreakTimer >= 0 )
		{
			if( poiseBreakTimer - dt <= 0 )
				OnRecover();
				
			poiseBreakTimer -= dt;
		}
		
		if( poiseValue <= 0 && poiseBreakTimer <= 0 )
			BreakPoise();
			
		if( pauseTimer > 0 )
		{
			//Kolaris - Stationary Poise
			if( playerTarget.IsPlayerMoving() )
				pauseTimer -= dt;
			else
				pauseTimer -= dt * 1.5f;
			return true;
		}
		
		if( poiseValue < maxPoise )
		{
			//Kolaris - Bear School Techniques, Kolaris - Bear Set, Kolaris - Stationary Poise, Kolaris - Conservation, Kolaris - Tiger Set
			if( !playerTarget.IsSetBonusActive(EISB_Bear_2) || !playerTarget.IsPlayerMoving() || playerTarget.IsGuarded() )
			{
				if( playerTarget.IsPlayerMoving() )
					regenMult = 1.f;
				else if( playerTarget.HasAbility('Glyphword 53 _Stats', true) || playerTarget.HasAbility('Glyphword 54 _Stats', true) )
					regenMult = 2.f;
				else
					regenMult = 1.5f;
				
				if( playerTarget.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
					regenMult *= 1.25f;
			
				poiseValue = ClampF(poiseValue + (20 + CalculateAttributeValue(target.GetAttributeValue('poiseRegen'))) * dt * regenMult, 0, maxPoise);
			}
		}
	}

	event OnRecover()
	{
		//Kolaris - Poisebreak
		poiseValue = maxPoise;
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	private function BreakPoise()
	{
		if( playerTarget.IsSetBonusActive(EISB_HeavyArmor) && playerTarget.IsGuarded() )
		{
			poiseValue = 1.f;
			return;
		}
		
		//Kolaris - Ogroid Decoction
		if( playerTarget.HasBuff(EET_Decoction3) )
		{
			poiseValue = 1.f;
			return;
		}
		
		//Kolaris - Immolation
		if( playerTarget.HasAbility('Glyphword 8 _Stats', true) || playerTarget.HasAbility('Glyphword 9 _Stats', true) )
		{
			theGame.GameplayFactsSet( "ImmolationCast", 1);
			playerTarget.CastDesiredSign( ST_Igni, true, false, false, playerTarget.GetWorldPosition(), playerTarget.GetWorldRotation() );
			theGame.GameplayFactsSet( "ImmolationCast", 0);
		}
		
		poiseBreakTimer = 5.f;
		if( playerTarget.IsQuenActive(false) )
			playerTarget.FinishQuen(false);
		playerTarget.AddEffectDefault(EET_Stagger, target, "PoiseBreak");
	}
	
	public function SetPoiseBreakTimer( time : float )
	{
		poiseBreakTimer = time;
	}
	
	public function IsPoiseBroken(optional staggerRemoval : bool) : bool
	{
		if( staggerRemoval )
			return poiseBreakTimer > 0;
		else
			return poiseBreakTimer > 0 && (target.HasBuff(EET_Stagger) || target.HasBuff(EET_LongStagger));
	}
	
	public function PausePoiseRegen( time : float )
	{
		//Kolaris - Griffin School Techniques
		var delayReduction : SAbilityAttributeValue;
		
		delayReduction = playerTarget.GetAttributeValue('delayReductionPoise');
		time *= 1.f - delayReduction.valueMultiplicative;
		pauseTimer = MaxF(pauseTimer, time);
	}
	
	//Kolaris - Poise Tweaks
	public function ReducePoise( poise : float, optional pauseTime : float, optional source : name )
	{
		//Kolaris - Poise Efficiency
		var costReduction : SAbilityAttributeValue;
		
		//Kolaris - Test
		if(playerTarget.GetImmortalityMode() == AIM_Invulnerable)
			return;
		
		if( RandRange(100, 1) < CalculateAttributeValue(target.GetAttributeValue('freePoiseChance')) )
			return;
		
		//Kolaris - Dol Blathanna Set
		if( playerTarget.IsSetBonusActive(EISB_Elven_1) && source == 'Dodge' )
			return;
		if( playerTarget.IsSetBonusActive(EISB_Elven_2) && Combat().ElvenSetActive )
			return;
		
		//Kolaris - Poise Efficiency
		if( source == 'Parry' || source == 'Counter' )
		{
			costReduction = playerTarget.GetAttributeValue('parry_stamina_cost_bonus');
			costReduction.valueMultiplicative += 0.04f * playerTarget.GetSkillLevel(S_Sword_s03);
			//Kolaris - Mutation 6
			if( playerTarget.IsMutationActive(EPMT_Mutation6) )
				costReduction.valueMultiplicative -= 0.5f;
		}
		else if ( source == 'Dodge' )
		{
			costReduction = playerTarget.GetAttributeValue('movement_stamina_efficiency');
			costReduction.valueMultiplicative += 0.04f * playerTarget.GetSkillLevel(S_Sword_s09);
		}
		
		poise /= 1.f + costReduction.valueMultiplicative;
		pauseTime *= 1.f - costReduction.valueMultiplicative;
		
		//Kolaris - Endure Pain
		if( playerTarget.CanUseSkill(S_Alchemy_s20) )
		{
			if( playerTarget.IsSetBonusActive(EISB_RedWolf_2) )
			{
				if( playerTarget.GetStat(BCS_Toxicity) * playerTarget.GetSkillLevel(S_Alchemy_s20) <= 500 )
					poise *= 1.f - playerTarget.GetSkillLevel(S_Alchemy_s20) * 0.001f * playerTarget.GetStat(BCS_Toxicity);
				else
					poise /= playerTarget.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerTarget.GetStat(BCS_Toxicity) / 25.f;
			}
			else
				poise *= 1.f - playerTarget.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerTarget.GetStatPercents(BCS_Toxicity);
		}
		//Kolaris - Conservation
		if( playerTarget.HasAbility('Glyphword 54 _Stats', true) )
			poise *= 1.f - (0.5f - playerTarget.GetStatPercents(BCS_Stamina) / 2.f);
		
		//Kolaris - Mutation 9
		if( playerTarget.IsMutationActive(EPMT_Mutation9) )
			poise *= 0.5f;
		
		//Kolaris - Difficulty Settings
		poise *= Options().SetPoiseDamageEnemy();
		
		//Kolaris - Poise Tweaks, Kolaris - Razor Focus, Kolaris - Mutation 8
		if( source == 'Counter' )
			poiseValue = MaxF(poiseValue - poise, MinF(poiseValue, 1 + GetMaxPoise() * 0.05f * playerTarget.GetSkillLevel(S_Sword_s20)));
		else if( source == 'Dodge' || (source == 'Hit' && !(playerTarget.IsMutationActive(EPMT_Mutation8))) )
			poiseValue = MaxF(poiseValue - poise, 1);
		else
			poiseValue = MaxF(poiseValue - poise, 0);
		PausePoiseRegen(pauseTime);
	}
	
	public function SetPoise( poise : float, optional pauseTime : float )
	{
		poiseValue = poise;
		PausePoiseRegen(pauseTime);
	}
	
	public function GetMaxPoise() : float
	{
		return maxPoise;
	}
	
	public function GetCurrentPoise() : float
	{
		return poiseValue;
	}
	
	public function GetPoisePercentage() : float
	{
		return poiseValue / maxPoise;
	}
	
	//Kolaris - Bear Set
	public function GetMissingPoiseWithMult() : float
	{
		var defEfficiency : SAbilityAttributeValue;
		
		defEfficiency = playerTarget.GetAttributeValue('parry_stamina_cost_bonus');
		defEfficiency.valueMultiplicative += 0.04f * playerTarget.GetSkillLevel(S_Sword_s03);
		//Kolaris - Mutation 6
		if( playerTarget.IsMutationActive(EPMT_Mutation6) )
			defEfficiency.valueMultiplicative -= 0.5f;
		
		return (GetMaxPoise() - GetCurrentPoise()) * (1.f + defEfficiency.valueMultiplicative);
	}
}

class W3Effect_NPCPoise extends CBaseGameplayEffect
{
	private var poiseBreakTimer : float;
	private var pauseTimer : float;
	private var maxPoise : float;
	private var poiseValue : float;
	private var poiseMult : float;
	private var isHuge : bool;
	private var effectInteraction : EEffectInteract;
	
	default effectType = EET_NPCPoise;
	default poiseBreakTimer = 0.f;
	default pauseTimer = 0.f;
	default poiseMult = 1.f;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		isHuge = target.IsHuge();
		if( isHuge )
			poiseMult = 0.5f;
			
		UpdateMaxPoise();
		poiseValue = maxPoise;
		super.OnEffectAdded(customParams);
	}
	
	public function UpdateMaxPoise()
	{
		var startingPoise : float;
		var NPC : CNewNPC;
		
		NPC = (CNewNPC)target;
		//Kolaris - NPC Poise
		startingPoise = 50 /* + 100.f * NPC.GetPoiseValue()*/;
		if( !NPC.IsHuman() )
		{
			if( isHuge && NPC.HasTag('MonsterHuntTarget') )
				startingPoise *= 2.f;
			else if ( isHuge || NPC.HasTag('MonsterHuntTarget') )
				startingPoise *= 1.5f;
			else
				startingPoise *= 1.f;
		}
		else
		{
			if( NPC.HasAbility('SkillPeasant') || NPC.HasAbility('SkillSorceress') || NPC.HasAbility('SkillThug') || NPC.HasAbility('SkillBrigand') || NPC.HasAbility('SkillMage') )
			{
				startingPoise *= 0.9f;
			}
			else
			if( NPC.HasAbility('SkillElite') || NPC.HasAbility('SkillFistsHard') || NPC.HasAbility('SkillArchmage') || NPC.HasAbility('SkillMercenary') || NPC.HasAbility('SkillOfficer') || NPC.HasAbility('SkillFistsMedium') || NPC.HasAbility('SkillTwoHanded') || NPC.HasAbility('SkillWitcher') )
			{
				startingPoise *= 1.1f;
			}
			else
			if( NPC.HasAbility('SkillShield') || NPC.HasAbility('SkillShieldHard') )
			{
				startingPoise *= 1.2f;
			}
		}
		
		//Kolaris - Olgierd Poise
		if( NPC.HasTag('IsBoss') || NPC.HasTag('PlayerWolfCompanion')|| NPC.HasTag('olgierd') )
			startingPoise *= 2.f;
			
		maxPoise = startingPoise;
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		if( poiseBreakTimer >= 0 )
		{
			if( poiseBreakTimer - dt <= 0 )
				OnRecover();
				
			poiseBreakTimer -= dt;
		}
		
		//Kolaris - Cremation
		if( ((CNewNPC)target).HasBuff(EET_Burning) && ((CNewNPC)target).GetBehaviorVariable('CriticalStateType') == 0 && (GetWitcherPlayer().HasAbility('Runeword 11 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 12 _Stats', true)) )
			poiseValue = MaxF(poiseValue - 0.2f * maxPoise * poiseMult * dt, 0);
		
		if( poiseValue <= 0 && poiseBreakTimer <= 0 )
			BreakPoise();
			
		if( pauseTimer > 0 )
		{
			pauseTimer -= dt;
			return true;
		}
		
		//Kolaris - Disable Poise Regen
		if( poiseValue < maxPoise && !target.IsHelpless() )
		{
			if( ((CNewNPC)target).HasBuff(EET_SlowdownFrost) && GetWitcherPlayer().HasAbility('Runeword 3 _Stats', true) )
				poiseValue = ClampF(poiseValue + 5 * poiseMult * dt, 0, maxPoise);
			else
				poiseValue = ClampF(poiseValue + 10 * poiseMult * dt, 0, maxPoise);
		}
	}

	event OnRecover()
	{
		if( poiseValue < maxPoise / 4 )
			poiseValue = maxPoise / 4;
		effectInteraction = EI_Undefined;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	//Kolaris - Bear Set
	private function BreakPoise()
	{
		poiseBreakTimer = MaxF(4.f, pauseTimer);
			
		//Kolaris - Poisebreak
		if( ((CNewNPC)target).IsHuman() )
			((CNewNPC)target).ProcessShieldDestruction();
		
		//Kolaris - Rotfiend Poisebreak Fix
		if( !(target.HasBuff(EET_Stagger) || target.HasBuff(EET_LongStagger) || target.HasBuff(EET_CounterStrikeHit)) && !(target.HasAbility('mon_rotfiend') && target.GetStatPercents(BCS_Essence) < 0.5f) )
			effectInteraction = target.AddEffectDefault(EET_Stagger, target, "PoiseBreak");
	}
	
	public function IsPoiseBroken() : bool
	{
		return poiseBreakTimer > 0;
	}
	
	public function SetPoiseBreakTimer( time : float )
	{
		poiseBreakTimer = time;
	}
	
	public function PausePoiseRegen( optional time : float )
	{
		if( time )
		{
			pauseTimer = MaxF(pauseTimer, time);
			return;
		}
		
		pauseTimer = MaxF(pauseTimer, 3.f);
	}
	
	//Kolaris - NPC Poise, Kolaris - Difficulty Settings, Kolaris - Bear Set
	public function ReducePoise( poise : float, optional pauseTime : float, optional causer : CGameplayEntity )
	{
		if(target.GetImmortalityMode() == AIM_Invulnerable)
			return;
		
		poise /= 1.f + MaxF(-0.3f, ((CNewNPC)target).GetPoiseValue() * 2);
		poise *= Options().SetPoiseDamagePlayer();
		
		if( ((W3PlayerWitcher)causer).IsSetBonusActive(EISB_Bear_2) )
			poise *= 1.f + ((W3Effect_Poise)((W3PlayerWitcher)causer).GetBuff(EET_Poise)).GetMissingPoiseWithMult() * 0.003f;
		
		//theGame.GetGuiManager().ShowNotification("Poise Value: " + ((CNewNPC)target).GetPoiseValue() + "<br>Old Poise: " + RoundMath(poiseValue) + "<br>Poise Damage: " + RoundMath(poise));
		poiseValue = MaxF(poiseValue - poise, 0);
		
		if( ((W3PlayerWitcher)causer).IsSetBonusActive(EISB_Bear_1) && poiseValue == 0 && !IsPoiseBroken() )
			((W3PlayerWitcher)causer).GainStat(BCS_Stamina, 5 * ((W3PlayerWitcher)causer).GetSetPartsEquipped(EIST_Bear) * Options().StamCostGlobal());
		
		PausePoiseRegen(pauseTime);
	}
	
	public function SetPoise( poise : float )
	{
		poiseValue = poise;
	}
	
	public function GetPoise() : float
	{
		return poiseValue;
	}
	
	public function GetPoisePercentage() : float
	{
		return poiseValue / maxPoise;
	}
	
	//Kolaris - Poisebreak, Kolaris - Mutilation
	public function GetMaxPoise() : float
	{
		return maxPoise;
	}
	
	public function SetMaxPoise( newMax : float )
	{
		maxPoise = newMax;
	}
}

class W3Effect_Overexertion extends CBaseGameplayEffect
{
	var wasAddedWithMutation10 : bool;
	default effectType = EET_Overexertion;
	default isNegative = true;
	default wasAddedWithMutation10 = false;

	
	public function CacheSettings()
	{
		super.CacheSettings();

	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
		
		if( ((W3PlayerWitcher)target).IsMutationActive(EPMT_Mutation10) )
		{
			thePlayer.BlockAction(EIAB_Dodge, 'Mutation10');
			thePlayer.BlockAction(EIAB_Roll, 'Mutation10');
			wasAddedWithMutation10 = true;
		}
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		if( wasAddedWithMutation10 )
		{
			thePlayer.UnblockAction(EIAB_Dodge, 'Mutation10');
			thePlayer.UnblockAction(EIAB_Roll, 'Mutation10');
		}
	}

	protected function GetSelfInteraction( effect : CBaseGameplayEffect ) : EEffectInteract
	{
		return EI_Override;
	}
}

class W3Effect_DodgeExertion extends CBaseGameplayEffect
{
	default effectType = EET_DodgeExertion;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

//Kolaris - Cat Set
class W3Effect_LynxSetDodge extends CBaseGameplayEffect
{
	default effectType = EET_LynxSetDodge;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_LynxSetAttack extends CBaseGameplayEffect
{
	default effectType = EET_LynxSetAttack;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

//Kolaris - Perfection
class W3Effect_GlyphwordPerfection extends CBaseGameplayEffect
{
	private saved var currentCount : int;
	
	default effectType = EET_GlyphwordPerfection;	
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		currentCount = 0;
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		currentCount = 0;
		super.OnEffectRemoved();
		target.RemoveAbilityAll('Glyphword 42 Ability');
	}
	
	public function IncrementPerfectionAbility( amount : int )
	{
		if( currentCount + amount > 100 )
			amount = 100 - currentCount;
		
		if( amount > 0 )
		{
			currentCount += amount;
			target.AddAbilityMultiple('Glyphword 42 Ability', amount);
			target.PlayEffect('runeword_10_stamina');
		}
	}
	
	public function OnTakeDamage( action : W3DamageAction )
	{
		if( currentCount > 0 && action.DealsAnyDamage() && !(((W3Action_Attack)action).IsCountered() || ((W3Action_Attack)action).IsParried()) )
		{
			currentCount -= 1;
			target.RemoveAbility('Glyphword 42 Ability');
		}
	}
	
	public function GetDisplayCount() : int
	{
		return currentCount;
	}
	
	public function GetMaxDisplayCount() : int
	{
		return currentCount;
	}
}

//Kolaris - Obliteration
class W3Effect_RunewordObliteration extends CBaseGameplayEffect
{
	private saved var currentCount, i : int;
	private var degenTimer : float;
	private var witcher : W3PlayerWitcher;
	private var inv : CInventoryComponent;
	private var sword : SItemUniqueId;
	
	default effectType = EET_RunewordObliteration;	
	default isPositive = true;
	default degenTimer = 3.f;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		currentCount = 0;
		witcher = (W3PlayerWitcher)target;
		inv = witcher.GetInventory();
		sword = inv.GetCurrentlyHeldSword();
		inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
		inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		for( i=0; i < currentCount; i+=1 )
		{
			inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
			inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
		}
		currentCount = 0;
		super.OnEffectRemoved();
	}
	
	public function ProcessObliterationAbility( action : W3DamageAction )
	{
		var attackAction : W3Action_Attack;
		attackAction = (W3Action_Attack)action;
		
		if( (W3PlayerWitcher)attackAction.attacker && action.IsActionMelee() )
		{
			if( attackAction.DealsAnyDamage() || attackAction.IsParried() )
				IncrementCount();
		}
	}
	
	private function IncrementCount()
	{
		currentCount += 1;
		degenTimer = 3.f;
		Combat().ObliterationRunewordLvl1Flame(currentCount);
		
		inv.AddItemCraftedAbility(sword, 'Runeword 7 Ability', true);
		if( witcher.HasAbility('Runeword 8 _Stats', true) || witcher.HasAbility('Runeword 9 _Stats', true) )
			inv.AddItemCraftedAbility(sword, 'Runeword 8 Ability', true);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		if( degenTimer <= 0 && currentCount > 0 )
		{
			currentCount -= 1;
			inv.RemoveItemCraftedAbility(sword, 'Runeword 7 Ability');
			if( witcher.HasAbility('Runeword 8 _Stats', true) || witcher.HasAbility('Runeword 9 _Stats', true) )
				inv.RemoveItemCraftedAbility(sword, 'Runeword 8 Ability');
			degenTimer = 3.f;
		}
		
		degenTimer -= dt * (1 + 0.2f * currentCount);
	}
	
	public function GetDisplayCount() : int
	{
		return currentCount;
	}
	
	public function GetMaxDisplayCount() : int
	{
		return currentCount;
	}
}

//Kolaris - Electrocution
class W3Effect_RunewordElectrocution extends CBaseGameplayEffect
{
	private saved var currentCount : int;
	private const var MAX_COUNT : int;
	
	default effectType = EET_RunewordElectrocution;	
	default isPositive = true;
	default MAX_COUNT = 10;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		currentCount = 0;
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		currentCount = 0;
		super.OnEffectRemoved();
		target.RemoveAbilityAll('Runeword 30 Ability');
	}
	
	public function ProcessElectrocutionAbility( action : W3DamageAction )
	{
		var attackAction : W3Action_Attack;
		attackAction = (W3Action_Attack)action;
		
		if( currentCount < MAX_COUNT && (W3PlayerWitcher)attackAction.attacker && action.IsActionMelee() && ((CNewNPC)attackAction.victim).HasBuff(EET_Electroshock) )
		{
			((CNewNPC)attackAction.victim).CreateFXEntityAndPlayEffect('mutation2_critical', 'critical_quen');
			currentCount += 1;
			target.AddAbility('Runeword 30 Ability', true);
			if( currentCount < MAX_COUNT && ((W3PlayerWitcher)attackAction.attacker).IsHeavyAttack(attackAction.GetAttackName()) )
			{
				currentCount += 1;
				target.AddAbility('Runeword 30 Ability', true);
			}
		}
	}
	
	public function ResetCounter()
	{
		currentCount = 0;
		target.RemoveAbilityAll('Runeword 30 Ability');
	}
	
	public function GetDisplayCount() : int
	{
		return currentCount;
	}
	
	public function GetMaxDisplayCount() : int
	{
		return MAX_COUNT;
	}
}

//Kolaris - Deflection
class W3Effect_GlyphwordDeflectionCooldown extends CBaseGameplayEffect
{
	default effectType = EET_GlyphwordDeflectionCooldown;
	default isPositive = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

exec function addpoise()
{
	GetWitcherPlayer().AddEffectDefault(EET_Poise, GetWitcherPlayer(), "Poise");
}

exec function addexert()
{
	GetWitcherPlayer().AddEffectDefault(EET_Overexertion, GetWitcherPlayer(), "Overexertion");
}

exec function reducepoise( val : float )
{
	((W3Effect_Poise)thePlayer.GetBuff(EET_Poise, "Poise")).SetPoise(val);
	((W3Effect_Poise)thePlayer.GetBuff(EET_Poise, "Poise")).PausePoiseRegen(3.f);
}

exec function breakpoise()
{
	((W3Effect_NPCPoise)thePlayer.GetTarget().GetBuff(EET_NPCPoise)).SetPoise(0);
}