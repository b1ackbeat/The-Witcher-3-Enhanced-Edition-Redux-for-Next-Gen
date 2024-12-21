/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SQuenEffects
{
	editable var lastingEffectUpgNone	: name;
	editable var lastingEffectUpg1		: name;
	editable var lastingEffectUpg2		: name;
	editable var lastingEffectUpg3		: name;
	editable var castEffect				: name;
	editable var cameraShakeStranth		: float;
}



statemachine class W3QuenEntity extends W3SignEntity
{
	editable var effects : array< SQuenEffects >;
	editable var hitEntityTemplate : CEntityTemplate;
		
	
	protected var shieldDuration	: float;
	protected var shieldHealth		: float;
	protected var initialShieldHealth : float;
	protected var dischargePercent	: float;
	protected var ownerBoneIndex	: int;
	protected var blockedAllDamage  : bool;
	protected var shieldStartTime	: EngineTime;
	private var hitEntityTimestamps : array<EngineTime>;
	private const var MIN_HIT_ENTITY_SPAWN_DELAY : float;
	private var hitDoTEntities : array<W3VisualFx>;
	public var showForceFinishedFX : bool;
	public var freeFromBearSetBonus	: bool;
	
	default skillEnum = S_Magic_4;
	default MIN_HIT_ENTITY_SPAWN_DELAY = 0.25f;
	
	public function GetSignType() : ESignType
	{
		return ST_Quen;
	}
	
	public function SetBlockedAllDamage(b : bool)
	{
		blockedAllDamage = b;
	}
	
	public function GetBlockedAllDamage() : bool
	{
		return blockedAllDamage;
	}
	
	// W3EE - Begin
	protected function DestroyQuen()
	{
		if( owner.GetPlayer() )
			owner.GetPlayer().AddTimer('DestroyQuen', 0.1f, false);
	}
	
	public function KillPlayerForLulz()
	{
		var player : W3PlayerWitcher = owner.GetPlayer();
		var rotation : EulerAngles = player.GetWorldRotation();
		var fx : CEntity;
		
		player.PlayEffect('hit_electric_quen');
		/*player.PlayEffect('hit_electric_quen');
		player.PlayEffect('quen_force_discharge_bear_abl2_armour');
		player.PlayEffect('quen_force_discharge_bear_abl2_armour');
		PlayHitEffect('quen_rebound_sphere_bear_abl2', rotation);
		rotation.Yaw -= 90.f;
		PlayHitEffect('quen_rebound_sphere_bear_abl2', rotation);
		rotation.Yaw += 180.f;
		PlayHitEffect('quen_rebound_sphere_bear_abl2', rotation);
		rotation.Yaw += 90.f;
		PlayHitEffect('quen_rebound_sphere_bear_abl2', rotation);
		fx = player.CreateFXEntityAtPelvis('mutation2_critical', true);
		fx.PlayEffect('critical_quen');
		fx.PlayEffect('critical_quen');
		fx.PlayEffect('critical_quen');
		fx = player.CreateFXEntityAtPelvis('mutation1_hit', true);
		fx.PlayEffect('mutation_1_hit_quen');
		fx.PlayEffect('mutation_1_hit_quen');
		GCameraShake(2.f);*/
		
		//player.Kill('Retardation', true);
		DestroyQuen();
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool, optional isFreeCast : bool ) : bool
	// W3EE - End
	{
		var oldQuen : W3QuenEntity;
		
		CacheSignStats(inOwner);
		
		ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'pelvis' );
		if(ownerBoneIndex == -1)
			ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'k_pelvis_g' );
			
		if( inOwner.GetPlayer() )
		{
			oldQuen = (W3QuenEntity)prevInstance;
			//Plasticmetal - Quen Fixes
			if(oldQuen)
            {
                oldQuen.OnSignAborted(true);
                if(!inOwner.GetPlayer().HasBuff(EET_Mutation11Buff) && oldQuen.shieldStartTime > 0 && (( !theInput.LastUsedPCInput() && theInput.GetActionValue( 'CastSignHold' ) == 0.f )|| theInput.IsActionPressed('DistanceModifier')))
                {
                    oldQuen.CleanUp();
                    oldQuen.Destroy();
                    CleanUp();
                    Destroy();
                    inOwner.GetPlayer().OnBasicQuenFinishing();
                    return false;
                }
            }
		}
		hitEntityTimestamps.Clear();
		
		// W3EE - Begin
		return super.Init( inOwner, prevInstance, skipCastingAnimation, notPlayerCast, isFreeCast );
		// W3EE - End
	}
	
	event OnTargetHit( out damageData : W3DamageAction )
	{
		if(owner.GetActor() == thePlayer && !damageData.IsDoTDamage() && !damageData.WasDodged())
			theGame.VibrateControllerHard();
	}
		
	protected function GetSignStats()
	{
		var min, max : SAbilityAttributeValue;
		// W3EE - Begin
		var spellPower : SAbilityAttributeValue;
		var sp : float;
		// W3EE - End
		
		super.GetSignStats();
		
		// W3EE - Begin
		shieldDuration = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true)) * 1.5f;
		//Kolaris - Prolongation
		if( (W3PlayerWitcher)owner.GetActor() )
			shieldDuration *= ((W3PlayerWitcher)owner.GetActor()).GetPlayerSignDurationMod();
		
		/*
		if ( owner.CanUseSkill(S_Magic_s14, this))
		{			
			dischargePercent = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s14, 'discharge_percent', false, true)) * owner.GetSkillLevel(S_Magic_s14, this);
			if( owner.GetPlayer().IsSetBonusActive( EISB_Bear_2 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_2 ), 'quen_dmg_boost', min, max );
				dischargePercent *= 1 + min.valueMultiplicative;
			}
		}
		else
		{
			dischargePercent = 0;
		}
		*/
		
		spellPower = super.GetTotalSignIntensity();
		sp = spellPower.valueMultiplicative;
		//Kolaris - Quen Shield
		if( (W3PlayerWitcher)owner.GetActor() )
			shieldHealth = 1000 * sp;
		else
			shieldHealth = 10000;
		
		initialShieldHealth = shieldHealth;
		shieldDuration *= sp;
		// W3EE - End
	}
	
	//Kolaris - Renewing Shield
	public final function RegenerateQuen(dt : float)
	{
		shieldHealth = ClampF(shieldHealth + 5 * owner.GetPlayer().GetSkillLevel(S_Magic_s14) * dt, 0, GetInitialShieldHealth());
	}
	
	// W3EE - Begin
	public final function AddBuffImmunities(useDoTs : bool)
	// W3EE - End
	{
		var actor : CActor;
		// W3EE - Begin
		var i,size : int;
		var crits : array<CBaseGameplayEffect>;
		var dots : array<EEffectType>;
		// W3EE - End
		var effectType : EEffectType;
		
		actor = owner.GetActor();
		
		// W3EE - Begin
		crits = actor.GetBuffs();	
		for(i=0; i<crits.Size(); i+=1)
		{
			effectType = crits[i].GetEffectType();
			
			
			if( effectType == EET_SnowstormQ403 || effectType == EET_Snowstorm )
			{
				actor.FinishQuen( false );
				return;
			}
		}
		
		//dots.PushBack(EET_Bleeding);
		dots.PushBack(EET_Burning);
		//dots.PushBack(EET_Poison);
		dots.PushBack(EET_PoisonCritical);
		dots.PushBack(EET_Swarm);
		//dots.PushBack(EET_Snowstorm);
		//dots.PushBack(EET_SnowstormQ403);
		
		if(useDoTs)
		{
			for(i=0; i<dots.Size(); i+=1)
			{
				actor.AddBuffImmunity(dots[i], 'Quen', true );
			}			
		}		
		
		size = EnumGetMax('EEffectType')+1;
		for(i=0; i<size; i+=1)
		{
			if( i == 8 || i == 7 )
				continue;
			
			if(IsCriticalEffectType(i) && !dots.Contains(i))
				actor.AddBuffImmunity(i, 'Quen', true);
		}
		// W3EE - End
	}
	
	// W3EE - Begin
	public final function RemoveBuffImmunities(useDoTs : bool)
	{
		var actor : CActor;
		var i, size : int;
		var dots : array<EEffectType>;
		
		actor = owner.GetActor();
		
		//dots.PushBack(EET_Bleeding);
		dots.PushBack(EET_Burning);
		//dots.PushBack(EET_Poison);
		dots.PushBack(EET_PoisonCritical);
		dots.PushBack(EET_Swarm);
		
		if(useDoTs)
		{
			for(i=0; i<dots.Size(); i+=1)
			{
				actor.RemoveBuffImmunity(dots[i], 'Quen' );
			}			
		}		
		
		size = EnumGetMax('EEffectType')+1;
		for(i=0; i<size; i+=1)
		{
			if(IsCriticalEffectType(i) && !dots.Contains(i))
				actor.RemoveBuffImmunity(i, 'Quen');
		}
	}
	// W3EE - End
	
	event OnStarted() 
	{
		var isAlternate		: bool;
		var witcherOwner	: W3PlayerWitcher;
		
		owner.ChangeAspect( this, S_Magic_s04 );
		isAlternate = IsAlternateCast();
		witcherOwner = owner.GetPlayer();
		
		if(isAlternate)
		{
			
			CreateAttachment( owner.GetActor(), 'quen_sphere' );
			
			if((CPlayer)owner.GetActor())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
		else
		{
			super.OnStarted();
			
			// W3EE - Begin
			if( owner.GetPlayer().IsSwimming() )
				KillPlayerForLulz();
				
			//Kolaris - Electrocution
			Combat().QuenJoltSkill(this);
			// W3EE - End
		}
		
		
		if(owner.GetActor() == thePlayer && ShouldProcessTutorial('TutorialSelectQuen'))
		{
			FactsAdd("tutorial_quen_cast");
		}
		
		if((CPlayer)owner.GetActor())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
				
		if( isAlternate || !owner.IsPlayer() )
		{
			if( owner.IsPlayer() && GetWitcherPlayer().HasBuff( EET_Mutation11Immortal ) )
			{
				PlayEffect( 'quen_second_life' );
			}
			else
			{
				PlayEffect( effects[1].castEffect );
			}
			
			//Kolaris - Retribution Fx - Electric Spark Loops
			if( witcherOwner && (witcherOwner.HasAbility('Glyphword 20 _Stats', true) || witcherOwner.HasAbility('Glyphword 21 _Stats', true)) )
			{
				PlayEffect( 'default_fx_bear_abl2' );
				witcherOwner.PlayEffect( 'quen_lasting_shield_bear_abl2' );
			}
			
			CacheActionBuffsFromSkill();
			GotoState( 'QuenChanneled' );
		}
		else
		{
			PlayEffect( effects[0].castEffect );
			GotoState( 'QuenShield' );
		}
	}
	
	public final function IsAnyQuenActive() : bool
	{
		
		if(GetCurrentStateName() == 'QuenChanneled' || (GetCurrentStateName() == 'ShieldActive' && shieldHealth > 0) )
		{
			return true;
		}
				
		return false;
	}
	
	event OnSignAborted( optional force : bool ){}
	
	public final function PlayHitEffect(fxName : name, rot : EulerAngles, optional isDoT : bool)
	{
		var hitEntity : W3VisualFx;
		var currentTime : EngineTime;
		var dt : float;
		
		currentTime = theGame.GetEngineTime();
		if(hitEntityTimestamps.Size() > 0)
		{
			dt = EngineTimeToFloat(currentTime - hitEntityTimestamps[0]);
			if(dt < MIN_HIT_ENTITY_SPAWN_DELAY)
				return;
		}
		hitEntityTimestamps.Erase(0);
		hitEntityTimestamps.PushBack(currentTime);
		
		hitEntity = (W3VisualFx)theGame.CreateEntity(hitEntityTemplate, GetWorldPosition(), rot);
		if(hitEntity)
		{
			
			hitEntity.CreateAttachment(owner.GetActor(), 'quen_sphere', , rot);
			hitEntity.PlayEffect(fxName);
			hitEntity.DestroyOnFxEnd(fxName);
			
			if(isDoT)
				hitDoTEntities.PushBack(hitEntity);
		}
	}
	
	public function EraseFirstTimeStamp()
	{
		hitEntityTimestamps.Erase(0);
	}
	
	timer function RemoveDoTFX(dt : float, id : int)
	{
		RemoveHitDoTEntities();
	}
	
	public final function RemoveHitDoTEntities()
	{
		var i : int;
		
		for(i=hitDoTEntities.Size()-1; i>=0; i-=1)
		{
			if(hitDoTEntities[i])
				hitDoTEntities[i].Destroy();
		}
	}
	
	public final function GetShieldHealth() : float 		{return shieldHealth;}
	public final function GetInitialShieldHealth() : float 		{return initialShieldHealth;}
	
	public final function GetShieldRemainingDuration() : float
	{
		return shieldDuration - EngineTimeToFloat( theGame.GetEngineTime() - shieldStartTime );
	}
	
	public function GetReflectWindow() : bool
	{
		if( shieldDuration - GetShieldRemainingDuration() <= 0.3f )
			return true;
		else
			return false;
	}
	
	public final function SetDataFromRestore(health : float, duration : float)
	{
		shieldHealth = health;
		shieldDuration = duration;
		shieldStartTime = theGame.GetEngineTime();
		AddTimer('Expire', shieldDuration, false, , , true, true);
	}
	
	timer function Expire( deltaTime : float , id : int)
	{		
		GotoState( 'Expired' );
	}
		
	public final function ForceFinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		var min, max : SAbilityAttributeValue;
		var player : W3PlayerWitcher;
		
		player = owner.GetPlayer();
		
		// W3EE - Begin
		/*
		if( !forceNoBearSetBonus && player && player.IsSetBonusActive( EISB_Bear_1 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_1), 'quen_reapply_chance', min, max );
			
			min.valueMultiplicative *= player.GetSetPartsEquipped( EIST_Bear );
			
			
			min.valueMultiplicative /= player.m_quenReappliedCount;
			if( player.m_quenReappliedCount > 4 )
			{
				min.valueMultiplicative = 0;
			}	
			
			if( min.valueMultiplicative >= RandF() )
			{
				player.PlayEffect( 'quen_lasting_shield_back' );
				player.AddTimer( 'BearSetBonusQuenReapply', 0.9, true );
			}
			
			else
			{
				player.m_quenReappliedCount = 1;
			}
		}
		*/
		// W3EE - End
		
		if(IsAlternateCast())
		{
			OnEnded();
			
			if(!skipVisuals)
				owner.GetActor().PlayEffect('hit_electric_quen');
		}
		else
		{
			showForceFinishedFX = !skipVisuals;
			GotoState('Expired');
		}
	}
}


state Expired in W3QuenEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.shieldHealth = 0;
		
		if(parent.showForceFinishedFX)
			parent.owner.GetActor().PlayEffect('quen_lasting_shield_hit');
			
		parent.DestroyAfter( 1.f );		
		
		if(parent.owner.GetActor() == thePlayer)
			theGame.VibrateControllerVeryHard();	
	}
}


state ShieldActive in W3QuenEntity extends Active
{
	// W3EE - Begin
	var cachedEffect : name;
	private function UpdateQuenShieldFx()
	{
		var currHP, maxHP, div : float;
		var cycledVisuals : array<name>;
		var initialVisual : name;
		var casterActor : CActor;
		var cycles, i : int;
		
		maxHP = parent.initialShieldHealth;
		currHP = parent.shieldHealth;
		initialVisual = GetLastingFxName();
		switch(initialVisual)
		{
			case parent.effects[0].lastingEffectUpg3:
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpg2);
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpg1);
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpgNone);
				cycles = 4;
			break;
			
			case parent.effects[0].lastingEffectUpg2:
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpg1);
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpgNone);
				cycles = 3;
			break;
			
			case parent.effects[0].lastingEffectUpg1:
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpgNone);
				cycles = 2;
			break;
			
			case parent.effects[0].lastingEffectUpgNone:
				return;
		}
		
		div = maxHP / cycles;
		casterActor = caster.GetActor();
		for(i=cycles-1; i>=1; i-=1)
		{
			if( currHP <= maxHP - i * div )
			{
				if( cachedEffect == cycledVisuals[i-1] )
					return;
				
				casterActor.StopEffect(parent.effects[0].lastingEffectUpg3);
				casterActor.StopEffect(parent.effects[0].lastingEffectUpg2);
				casterActor.StopEffect(parent.effects[0].lastingEffectUpg1);
				casterActor.StopEffect(parent.effects[0].lastingEffectUpgNone);
				casterActor.PlayEffect(cycledVisuals[i-1]);
				cachedEffect = cycledVisuals[i-1];
				
				return;
			}
		}
	}
	
	private final function GetLastingFxName() : name
	{
		var fx : CEntity;
		var spellPower : SAbilityAttributeValue;
		var sp, level : float;
		
		
		spellPower = parent.GetTotalSignIntensity();
		level = spellPower.valueMultiplicative;
		fx = GetWitcherPlayer().CreateFXEntityAtPelvis('mutation1_hit', true);
		fx.PlayEffect('mutation_1_hit_quen');
		
		if( level > 1.4 )
			return parent.effects[0].lastingEffectUpg3;
		else
		if( level > 1.2 )
			return parent.effects[0].lastingEffectUpg2;
		else
		if( level > 1.1 )
			return parent.effects[0].lastingEffectUpg1;
		else
			return parent.effects[0].lastingEffectUpgNone;
	}
	// W3EE - End
	
	event OnEnterState( prevStateName : name )
	{
		var witcher			: W3PlayerWitcher;
		var params 			: SCustomEffectParams;
		
		super.OnEnterState( prevStateName );
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		
		if(witcher)
		{
			witcher.SetUsedQuenInCombat();
			witcher.m_quenReappliedCount = 1;
			
			params.effectType = EET_BasicQuen;
			params.creator = witcher;
			params.sourceName = "sign cast";
			params.duration = parent.shieldDuration;
			
			witcher.AddEffectCustom( params );
		}
		
		caster.GetActor().PlayEffect(GetLastingFxName());
		
		//Kolaris - Retribution Fx - Electric Spark Loops
		if( witcher && (witcher.HasAbility('Glyphword 20 _Stats', true) || witcher.HasAbility('Glyphword 21 _Stats', true)) )
		{
			witcher.PlayEffect( 'quen_force_discharge_bear_abl2_armour' );
		}
		
		parent.AddTimer( 'Expire', parent.shieldDuration, false, , , true );
		
		// W3EE - Begin
		parent.AddBuffImmunities(true);
		// W3EE - End
		
		if( witcher )
		{
			if( !parent.freeFromBearSetBonus )
			{
				parent.ManagePlayerStamina();
				//Kolaris - Griffin Set
				//parent.ManageGryphonSetBonusBuff();
			}
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
		
		// W3EE - Begin
		/*if( !witcher.IsSetBonusActive( EISB_Bear_1 ) || ( !witcher.HasBuff( EET_HeavyKnockdown ) && !witcher.HasBuff( EET_Knockdown ) ) )
		{*/
			witcher.CriticalEffectAnimationInterrupted("basic quen cast");
		// }
		// W3EE - End
		
		witcher.AddTimer('HACK_QuenSaveStatus', 0, true);
		parent.shieldStartTime = theGame.GetEngineTime();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var witcher : W3PlayerWitcher;
		
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		if(witcher && parent == witcher.GetSignEntity(ST_Quen))
		{
			witcher.StopEffect(parent.effects[0].lastingEffectUpg1);
			witcher.StopEffect(parent.effects[0].lastingEffectUpg2);
			witcher.StopEffect(parent.effects[0].lastingEffectUpg3);
			witcher.StopEffect(parent.effects[0].lastingEffectUpgNone);
			witcher.StopEffect( 'quen_force_discharge_bear_abl2_armour' );
			witcher.RemoveBuff( EET_BasicQuen );
		}
	
		// W3EE - Begin
		parent.RemoveBuffImmunities(true);
		// W3EE - End
		
		parent.RemoveHitDoTEntities();
		
		if( parent.owner.GetActor() == thePlayer && parent.owner.GetPlayer().IsInCombat() )
		{
			//Kolaris - Exploding Shield
			/*if( parent.shieldHealth > 0 )
			{
				if ( parent.owner.CanUseSkill(S_Magic_s13, parent) )
				{
					caster.GetActor().PlayEffect('quen_lasting_shield_hit');	
					caster.GetActor().PlayEffect('quen_force_discharge');
					caster.GetActor().PlayEffect('lasting_shield_impulse');
					caster.GetPlayer().QuenImpulse(false, parent, "quen_impulse");
				}
			}*/
			caster.GetActor().PlayEffect( 'quen_lasting_shield_hit' );
			GetWitcherPlayer().OnBasicQuenFinishing();			
		}
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
	}
	
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var pos : Vector;
		var reducedDamage, drainedHealth, skillBonus, incomingDamage, directDamage : float;
		var spellPower, min, max : SAbilityAttributeValue;
		var physX : CEntity;
		var inAttackAction : W3Action_Attack;
		var action : W3DamageAction;
		var casterActor : CActor;
		var effectTypes : array < EEffectType >;
		var damageTypes : array<SRawDamage>;
		var i : int;
		var isBleeding : bool;

		// W3EE - Begin
		var wardingLevel : int;
		var staggerParams : SCustomEffectParams;
		var shieldDamage, originalShieldDamage, damageDifference, reflectedDamage : float;
		// W3EE - End
		
		if( damageData.WasDodged() || damageData.GetHitReactionType() == EHRT_Reflect || (W3Effect_Toxicity)damageData.causer )
		{
			return true;
		}
		
		parent.OnTargetHit(damageData);
		
		inAttackAction = (W3Action_Attack)damageData;
		if(inAttackAction && inAttackAction.CanBeParried() && (inAttackAction.IsParried() || inAttackAction.IsCountered()) )
			return true;
		
		casterActor = caster.GetActor();
		reducedDamage = 0;		
		
		damageData.GetDTs(damageTypes);
		for(i=0; i<damageTypes.Size(); i+=1)
		{
			if(damageTypes[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDamage = damageTypes[i].dmgVal;
				break;
			}
		}
		
		if( (W3Effect_Bleeding)damageData.causer )
		{
			incomingDamage = directDamage;
			isBleeding = true;
		}
		else
		{	
			isBleeding = false;
			incomingDamage = MaxF(0, damageData.GetDamageDealt() - directDamage);
		}
		//Kolaris - Quen Shield
		damageDifference = damageData.GetOriginalDamageDealt() / damageData.GetOriginalDamageDealtWithArmor();
		shieldDamage = damageData.GetOriginalDamageDealt() * 0.2f * damageData.GetDamageDealt() / damageData.GetOriginalDamageDealtWithArmor() / parent.GetTotalSignIntensityFloat();
		originalShieldDamage = shieldDamage;
		if( incomingDamage > parent.shieldHealth / damageDifference )
			reducedDamage = parent.shieldHealth / damageDifference;
		else
			reducedDamage = incomingDamage;
		
		wardingLevel = caster.GetPlayer().GetSkillLevel(S_Magic_s15);
		//Kolaris - Warding Shield
		if( parent.GetReflectWindow() )
		{
			caster.GetPlayer().GetAdrenalineEffect().AddAdrenalineWithMult(shieldDamage * 0.01f);
			shieldDamage *= 0.5f - 0.05f * wardingLevel;
			damageData.SetHitAnimationPlayType( EAHA_ForceNo );	
			reducedDamage = incomingDamage;
		}
		
		//Kolaris - Bastion
		if( caster.GetPlayer().HasAbility('Glyphword 22 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 23 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 24 _Stats', true) )
			shieldDamage *= 0.5f;
		
		if(!damageData.IsDoTDamage())
		{
			casterActor.PlayEffect( 'quen_lasting_shield_hit' );	
			GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
		}
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), action );
		}
		
		//Kolaris - Warding Shield
		//damageData.SetHitAnimationPlayType( EAHA_ForceNo );		
		damageData.SetCanPlayHitParticle( false );
		if(reducedDamage > 0)
		{
			parent.shieldHealth -= shieldDamage;
				
			//Kolaris - Exploding Shield
			if( caster.CanUseSkill(S_Magic_s13, parent) && originalShieldDamage > (parent.GetInitialShieldHealth() * (0.7f - 0.1f * caster.GetSkillLevel(S_Magic_s13, parent))) )
			{
				caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
				//caster.GetActor().PlayEffect('quen_lasting_shield_hit');
				//caster.GetActor().PlayEffect('quen_force_discharge');
				//caster.GetActor().PlayEffect('lasting_shield_impulse');
			}
			
			damageData.ClearEffects();
			damageData.processedDmg.vitalityDamage = incomingDamage - reducedDamage;
			
			if( damageData.processedDmg.vitalityDamage >= 20 )
				casterActor.RaiseForceEvent( 'StrongHitTest' );
			
			//Kolaris - Exploding Shield
			parent.dischargePercent = 0.15f + 0.03f * caster.GetSkillLevel(S_Magic_s13, parent) * parent.GetTotalSignIntensityFloat();
			//Kolaris - Retribution
			parent.dischargePercent += CalculateAttributeValue(((W3PlayerWitcher)caster.GetPlayer()).GetAttributeValue('quen_reflect_bonus'));
			
			if( damageData.attacker.HasTag('WeakToQuen') )
			{
				staggerParams.creator = casterActor;
				staggerParams.isSignEffect = true;
				staggerParams.sourceName = "quen";
				staggerParams.effectType = EET_Stagger;
				((CActor)damageData.attacker).AddEffectCustom(staggerParams);
				parent.dischargePercent *= 1.5f;
			}
			
			if( parent.GetReflectWindow() )
			{
				caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
				//caster.GetActor().PlayEffect('quen_lasting_shield_hit');
				caster.GetActor().PlayEffect('quen_force_discharge');
				//caster.GetActor().PlayEffect('lasting_shield_impulse');
				
				staggerParams.creator = casterActor;
				staggerParams.isSignEffect = true;
				staggerParams.sourceName = "quen";
				staggerParams.effectType = EET_LongStagger;
				((CActor)damageData.attacker).AddEffectCustom(staggerParams);
				
				parent.dischargePercent *= 1.5f;
				
				//Kolaris - Retribution, Kolaris - Retribution Fx - Shockwave in Attacker Direction
				if( caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
				{
					caster.GetPlayer().QuenImpulse( false, parent, "21", VecHeading(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition()) );
					parent.PlayHitEffect('quen_rebound_sphere_bear_abl2', VecToRotation(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition()));
				}
			}
			
			reflectedDamage = incomingDamage;
			if ( reflectedDamage > 0 && !damageData.IsDoTDamage() && casterActor == thePlayer && damageData.attacker != casterActor && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) //~3.5^2
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
				parent.InitSignDataForDamageAction( action );		
				action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * reflectedDamage );
				action.SetCanPlayHitParticle(true);
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				GCameraShake(parent.dischargePercent);
								
				//Kolaris - Retribution, Kolaris - Retribution Fx - Sparks on Target
				if( caster.GetPlayer().HasAbility('Glyphword 20 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
				{
					((CActor)damageData.attacker).AddEffectDefault(EET_Electroshock, caster.GetActor(), "Glyphword 20");
					action.SetForceExplosionDismemberment();
					physX = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation1_hit', true);
					physX.PlayEffect('mutation_1_hit_quen');
				}
				
				theGame.damageMgr.ProcessAction( action );		
				delete action;
			}
		}
		UpdateQuenShieldFx();
		
		if(reflectedDamage >= incomingDamage && (!damageData.DealsAnyDamage() || (isBleeding && reflectedDamage >= directDamage)) )
			parent.SetBlockedAllDamage(true);
		else
			parent.SetBlockedAllDamage(false);
		
		if(reflectedDamage > 0 && (!damageData.DealsAnyDamage() || (isBleeding && reflectedDamage >= directDamage)) )
			parent.SetBlockedAllDamage(true);
		else
			parent.SetBlockedAllDamage(false);
		
		if( parent.shieldHealth <= 0 )
		{
			//Kolaris - Exploding Shield
			caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
			//caster.GetActor().PlayEffect('quen_lasting_shield_hit');
			//caster.GetActor().PlayEffect('quen_force_discharge');
			//caster.GetActor().PlayEffect('lasting_shield_impulse');
			
			damageData.SetEndsQuen(true);
		}
	}
}


state QuenShield in W3QuenEntity extends NormalCast
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		caster.OnDelayOrientationChange();
		
		caster.GetActor().OnSignCastPerformed(ST_Quen, false);
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.CleanUp();	
			// W3EE - Begin
			if( caster.GetPlayer() )
				Experience().AwardSignXP(parent.GetSignType());
			// W3EE - End
			parent.GotoState( 'ShieldActive' );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		parent.GotoState( 'Expired' );
	}
}

state QuenChanneled in W3QuenEntity extends Channeling
{
	private const var STAMINA_FACTOR : float;		
	private const var HEALING_FACTOR : float;		
	
		// W3EE - Begin
		//Kolaris - Quen Active Shield
		default STAMINA_FACTOR = 0.002f;
		default HEALING_FACTOR = 0.5f;
		// W3EE - End

	event OnEnterState( prevStateName : name )
	{
		var casterActor : CActor;
		var witcher : W3PlayerWitcher;
		
		super.OnEnterState( prevStateName );
	
		casterActor = caster.GetActor();
		witcher = (W3PlayerWitcher)casterActor;
		
		if(witcher)
			witcher.SetUsedQuenInCombat();
							
		caster.OnDelayOrientationChange();
		
		parent.GetSignStats();
		
		//Kolaris - Bastion Fx
		if( witcher && (witcher.HasAbility('Glyphword 23 _Stats', true) || witcher.HasAbility('Glyphword 24 _Stats', true)) )
		{
			witcher.PlayEffect( 'runeword_8' );
		}
		
		casterActor.GetMovingAgentComponent().SetVirtualRadius( 'QuenBubble' );

		// W3EE - Begin
		parent.AddBuffImmunities(true);	
		// W3EE - End
		
		
		witcher.CriticalEffectAnimationInterrupted("quen channeled");
		
		casterActor.OnSignCastPerformed(ST_Quen, true);
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			ChannelQuen();
		}
	}
	
	private var HAXXOR_LeavingState : bool;
	event OnLeaveState( nextStateName : name )
	{
		HAXXOR_LeavingState = true;
		OnEnded(true);
		super.OnLeaveState(nextStateName);
		parent.DestroyQuen();
	}
	
	
	
	event OnEnded(optional isEnd : bool)
	{
		var casterActor : CActor;
		
		if(!HAXXOR_LeavingState)
			super.OnEnded();
			
		casterActor = caster.GetActor();
		casterActor.GetMovingAgentComponent().ResetVirtualRadius();
		casterActor.StopEffect('quen_shield');		
		casterActor.StopEffect( 'quen_lasting_shield_bear_abl2' );
		
		// W3EE - Begin
		parent.RemoveBuffImmunities(true);		
		// W3EE - End		
		
		parent.StopAllEffects();
		
		//Kolaris - Bastion Fx
		if( caster.GetPlayer() && (caster.GetPlayer().HasAbility('Glyphword 23 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 24 _Stats', true)) )
		{
			caster.GetPlayer().StopEffect( 'runeword_8' );
		}
		
		parent.RemoveHitDoTEntities();
		
		//Kolaris - Exploding Shield
		/*if(isEnd && caster.GetPlayer() && caster.GetPlayer().IsInCombat() && caster.CanUseSkill(S_Magic_s13, (W3SignEntity)parent) && (timeStamp - startTime >= 0.5f))
			caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );*/
	}
	
	event OnSignAborted( optional force : bool )
	{
		OnEnded();
	}
	
	private var timeStamp : float;	default timeStamp = 0;
	private var startTime: float;	default startTime = 0;
	private var DT : float; default DT = 0.006f;
	entry function ChannelQuen()
	{
		timeStamp = theGame.GetEngineTimeAsSeconds();
		startTime = theGame.GetEngineTimeAsSeconds();
		while( UpdateDrain(DT) )
		{
			ProcessQuenCollisionForRiders();
			Sleep(DT);
			DT = MaxF(theGame.GetEngineTimeAsSeconds() - timeStamp, 0.002f);
			timeStamp = theGame.GetEngineTimeAsSeconds();
		}
	}
	
	private function ProcessQuenCollisionForRiders()
	{
		var mac	: CMovingPhysicalAgentComponent;
		var collisionData : SCollisionData;
		var collisionNum : int;
		var i : int;
		var npc	: CNewNPC;
		var riderActor : CActor;
		var collidedWithRider : bool;
		var horseComp : W3HorseComponent;
		var riderToPlayerHeading, riderHeading : float;
		var angleDist : float;
		
		mac	= (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent();
		if( !mac )
		{
			return;
		}
		
		collisionNum = mac.GetCollisionCharacterDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData = mac.GetCollisionCharacterData( i );
			npc	= (CNewNPC)collisionData.entity;
			if( npc )
			{
				if( npc.IsUsingHorse() )
				{
					collidedWithRider = true;
					horseComp = npc.GetUsedHorseComponent();
				}
				else
				{
					horseComp = npc.GetHorseComponent();
					if( horseComp.user )
						collidedWithRider = true;
				}
			}
			
			if( collidedWithRider )
			{
				riderActor = horseComp.user;
				
				if( IsRequiredAttitudeBetween( riderActor, thePlayer, true ) )
				{
					riderToPlayerHeading = VecHeading( thePlayer.GetWorldPosition() - riderActor.GetWorldPosition() );
					riderHeading = riderActor.GetHeading();
					angleDist = AngleDistance( riderToPlayerHeading, riderHeading );
					
					if( AbsF( angleDist ) < 45.0 )
					{
						horseComp.ReactToQuen();
					}
				}
			}
		}
	}
	
	public function ShowHitFX(damageData : W3DamageAction, rot : EulerAngles)
	{
		var movingAgent : CMovingPhysicalAgentComponent;
		var inWater, hasFireDamage, hasElectricDamage, hasPoisonDamage, isDoT, isBirds : bool;
		var witcher	: W3PlayerWitcher;
		
		isBirds = (CFlyingCrittersLairEntityScript)damageData.causer;
		witcher = parent.owner.GetPlayer();
		
		if (isBirds)
		{
			
			parent.PlayHitEffect('quen_rebound_sphere_constant', rot, true);
			parent.AddTimer('RemoveDoTFX', 0.3, false, , , , true);
		}
		else
		{			
			isDoT = damageData.IsDoTDamage();
		
			if(!isDoT)
			{
				hasFireDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_FIRE) > 0;
				hasPoisonDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_POISON) > 0;		
				hasElectricDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_SHOCK) > 0;
				
				if (hasFireDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_fire', rot );
				}
				else if (hasPoisonDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_poison', rot );
				}
				else if (hasElectricDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_electricity', rot );
				}
				else
				{
					parent.PlayHitEffect( 'quen_rebound_sphere', rot );
				}
			}
		}
		
		
		movingAgent = (CMovingPhysicalAgentComponent)caster.GetActor().GetMovingAgentComponent();
		inWater = movingAgent.GetSubmergeDepth() < 0;
		if(!inWater)
		{
			parent.PlayHitEffect( 'quen_rebound_ground', rot );
		}
	}
		
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var reducedDamage , drainedVigor, reducibleDamage, directDamage, shieldFactor : float;		
		var spellPower, min, max : SAbilityAttributeValue;
		var drainAllVigor : bool;
		var casterActor : CActor;
		var attackerVictimEuler : EulerAngles;
		var action : W3DamageAction;		
		var shieldHP, sp : float;
		var player : W3PlayerWitcher;
		var staggerParams : SCustomEffectParams;
		var shieldDamage, returnDamage, incomingDamage, innerStrengthVal : float;
		var fx : CEntity;
		var wardingLevel : int;
		
		parent.OnTargetHit(damageData);
		casterActor = caster.GetActor();
		
		if( !((CBaseGameplayEffect)damageData.causer) )
		{
			attackerVictimEuler = VecToRotation(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition());
			attackerVictimEuler.Pitch = 0;
			attackerVictimEuler.Roll = 0;
			
			ShowHitFX(damageData, attackerVictimEuler);
		}
		
		if( damageData.GetDamageDealt() >= 20 )
			casterActor.RaiseForceEvent( 'StrongHitTest' );
		
		
		player = caster.GetPlayer();
		spellPower = parent.GetTotalSignIntensity();
		sp = spellPower.valueMultiplicative;
		
		//Kolaris - Exploding Shield
		parent.dischargePercent = 0.15f + 0.03f * caster.GetSkillLevel(S_Magic_s14, parent) * sp;
		
		//Kolaris - Retribution
		parent.dischargePercent += CalculateAttributeValue(player.GetAttributeValue('quen_reflect_bonus'));
		
		wardingLevel = caster.GetPlayer().GetSkillLevel(S_Magic_s15);
		if( damageData.attacker.HasTag('WeakToQuen') )
		{
			staggerParams.creator = casterActor;
			staggerParams.isSignEffect = true;
			staggerParams.sourceName = "quen";
			staggerParams.effectType = EET_Stagger;
			((CActor)damageData.attacker).AddEffectCustom(staggerParams);
			parent.dischargePercent *= 1.5f;
		}
		
		if( timeStamp - startTime <= 0.3f )
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
			//caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
			
			fx = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_quen');
			fx = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			
			staggerParams.creator = casterActor;
			staggerParams.isSignEffect = true;
			staggerParams.sourceName = "quen";
			staggerParams.effectType = EET_LongStagger;
			((CActor)damageData.attacker).AddEffectCustom(staggerParams);
			
			parent.dischargePercent *= 1.5f;
			
			//Kolaris - Retribution, Kolaris - Retribution Fx - Shockwave in Attacker Direction
			if( caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
			{
				caster.GetPlayer().QuenImpulse( false, parent, "21", VecHeading(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition()) );
				parent.EraseFirstTimeStamp();
				parent.PlayHitEffect('quen_rebound_sphere_bear_abl2', attackerVictimEuler);
			}
		}
		
		if( casterActor.HasBuff( EET_Mutation11Buff ) )
		{
			parent.shieldHealth = 1000000;
			parent.dischargePercent = 0.f;
		}
		else
		{
			if( player )
				//Kolaris - Active Shield
				parent.shieldHealth = (1500.f + (300.f * caster.GetSkillLevel(S_Magic_s04, parent))) * sp;
			else
				parent.shieldHealth = 100000.f;
		}
		
		//Kolaris - Active Shield Damage
		incomingDamage = damageData.GetOriginalDamageDealt();
		shieldDamage = incomingDamage * 0.2f;
		
		//Kolaris - Active Shield Explosion
		if( shieldDamage >= parent.shieldHealth / 3.f * (0.7f - 0.1f * caster.GetSkillLevel(S_Magic_s13, parent)) )
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
			caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
		}
		
		if( timeStamp - startTime <= 0.3f )
		{
			player.GetAdrenalineEffect().AddAdrenalineWithMult(shieldDamage * 0.01f);
			shieldDamage *= 0.5f - 0.05f * wardingLevel;
		}
		
		//Kolaris - Bastion
		if( caster.GetPlayer().HasAbility('Glyphword 22 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 23 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 24 _Stats', true) )
			shieldDamage *= 0.5f;		
		
		if( shieldDamage >= parent.shieldHealth )
		{
			drainAllVigor = true;
			drainedVigor = Options().MaxFocus() * (shieldDamage / parent.shieldHealth);
		}
		else
			drainedVigor = Options().MaxFocus() * (shieldDamage / parent.shieldHealth);
			
		if( !damageData.IsDoTDamage() )
			GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
			
		damageData.processedDmg.vitalityDamage = 0;
		if( !drainAllVigor )
		{
			damageData.SetHitAnimationPlayType(EAHA_ForceNo);
			damageData.SetCanPlayHitParticle(false);
			damageData.ClearEffects();
		}
		//returnDamage = damageData.GetOriginalDamageDealt() * MinF(1.f, player.GetStat(BCS_Focus) / drainedVigor) / 4.f;
		returnDamage = incomingDamage;
		if( casterActor == thePlayer && parent.dischargePercent > 0 && !damageData.IsActionRanged() && IsRequiredAttitudeBetween( thePlayer, damageData.attacker, true) && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) 
		{
			action = new W3DamageAction in theGame.damageMgr;
			action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
			parent.InitSignDataForDamageAction( action );		
			action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * returnDamage );
			action.SetCanPlayHitParticle(true);
			action.SetHitEffect('hit_electric_quen');
			action.SetHitEffect('hit_electric_quen', true);
			action.SetHitEffect('hit_electric_quen', false, true);
			action.SetHitEffect('hit_electric_quen', true, true);
			GCameraShake(parent.dischargePercent);
						
			//Kolaris - Retribution, Kolaris - Retribution Fx - Sparks on Target
			if( caster.GetPlayer().HasAbility('Glyphword 20 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
			{
				((CActor)damageData.attacker).AddEffectDefault(EET_Electroshock, caster.GetActor(), "Glyphword 20");
				action.SetForceExplosionDismemberment();
				fx = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_quen');
			}
			
			theGame.damageMgr.ProcessAction( action );		
			delete action;
			
			parent.PlayHitEffect('discharge', attackerVictimEuler);				
		}
		
		if( caster.GetPlayer() )
			Experience().AwardSignXP(parent.GetSignType());
		parent.SetBlockedAllDamage(true);
		if( !drainAllVigor )
		{
			if( player )
			{
				if( player.GetStat(BCS_Focus) > drainedVigor )
				{
					//Kolaris - Quen Active Shield
					player.GainStat(BCS_Stamina, incomingDamage * (1.f + 0.2f * caster.GetSkillLevel(S_Magic_s04, parent)) * STAMINA_FACTOR * sp * Options().StamCostGlobal());
				}
				//Kolaris - Quen Inner Strength Fix
				else if( player.GetStat(BCS_Focus) < drainedVigor )
				{
					player.GainStat(BCS_Stamina, incomingDamage * (1.f + 0.2f * caster.GetSkillLevel(S_Magic_s04, parent)) * STAMINA_FACTOR * sp * Options().StamCostGlobal() * player.GetStat(BCS_Focus) / drainedVigor);
					player.StartCustomVigorTimer(3.f + drainedVigor - player.GetStat(BCS_Focus));
					if( caster.GetSkillLevel(S_Perk_09) > 0 )
					{
						innerStrengthVal = (drainedVigor - player.GetStat(BCS_Focus)) * 35;
						if( player.GetStat(BCS_Stamina) >= innerStrengthVal * Options().StamCostGlobal() )
							player.DrainStamina(ESAT_FixedValue, innerStrengthVal / Options().StamCostGlobal());
						else
						{
							player.AddTimer('StunPlayer', 0.3f, false);
							player.DrainStamina(ESAT_FixedValue, player.GetStat(BCS_Stamina) / Options().StamCostGlobal());
						}
					}
					else
						player.AddTimer('StunPlayer', 0.3f, false);
				}
				
				player.DrainFocus(MinF(drainedVigor, player.GetStat(BCS_Focus)));
			}
			else
			{
				drainedVigor = casterActor.GetStatMax(BCS_Stamina) * (parent.shieldHealth / shieldDamage);
				casterActor.DrainStamina(ESAT_FixedValue, drainedVigor, 1);
			}
		}
		else
		{
			if( player )
			{
				//Kolaris - Quen Inner Strength Fix
				player.GainStat(BCS_Stamina, incomingDamage * (1.f + 0.2f * caster.GetSkillLevel(S_Magic_s04, parent)) * STAMINA_FACTOR * sp * Options().StamCostGlobal() * player.GetStat(BCS_Focus) / drainedVigor);
				if( caster.GetSkillLevel(S_Perk_09) > 0 )
				{
					innerStrengthVal = (drainedVigor - player.GetStat(BCS_Focus)) * 35;
					if( player.GetStat(BCS_Stamina) >= innerStrengthVal * Options().StamCostGlobal() )
						player.DrainStamina(ESAT_FixedValue, innerStrengthVal / Options().StamCostGlobal());
					else
					{
						player.AddTimer('StunPlayer', 0.3f, false);
						player.DrainStamina(ESAT_FixedValue, player.GetStat(BCS_Stamina) / Options().StamCostGlobal());
					}
				}
				else
				{
					player.AddTimer('StunPlayer', 0.3f, false);
					player.DrainFocus(player.GetStatMax(BCS_Focus));
					player.StartCustomVigorTimer(player.GetStatMax(BCS_Focus) * 2.f);
				}
			}
			else
			{
				casterActor.AddEffectDefault(EET_LongStagger, damageData.attacker, "QuenBroken");
				casterActor.DrainStamina(ESAT_FixedValue, casterActor.GetStat(BCS_Stamina), 4);
			}
		}
		
		if( ( caster.GetPlayer() && caster.GetPlayer().GetStat(BCS_Focus) <= 0 ) || ( !caster.GetPlayer() && casterActor.GetStat( BCS_Stamina ) <= 0 ) && !casterActor.HasBuff( EET_Mutation11Buff ) )
		{
			if ( caster.CanUseSkill(S_Magic_s13, (W3SignEntity)parent) )
			{
				parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
				caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
			}
			
			damageData.SetEndsQuen(true);			
		}
	}
}
