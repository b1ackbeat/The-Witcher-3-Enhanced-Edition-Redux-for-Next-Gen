/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SAxiiEffects
{
	editable var castEffect		: name;
	editable var throwEffect	: name;
}

statemachine class W3AxiiEntity extends W3SignEntity
{
	editable var effects		: array< SAxiiEffects >;	
	editable var projTemplate	: CEntityTemplate;
	editable var distance		: float;	
	editable var projSpeed		: float;
	
	default skillEnum = S_Magic_5;
	
	protected var targets		: array<CActor>;
	protected var orientationTarget : CActor;
	
	public function GetSignType() : ESignType
	{
		return ST_Axii;
	}
	
	// W3EE - Begin
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool, optional isFreeCast : bool ) : bool
	// W3EE - End
	{	
		var ownerActor : CActor;
		var prevSign : W3SignEntity;
		
		ownerActor = inOwner.GetActor();
		
		CacheSignStats(inOwner);
		
		if( (CPlayer)ownerActor )
		{
			prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
			if(prevSign)
				prevSign.OnSignAborted(true);
		}
		
		ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
		//Kolaris - Lethargy
		//if ( inOwner.CanUseSkill(S_Magic_s17, this) && inOwner.GetSkillLevel(S_Magic_s17, this) >= 2 )
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 1.f );
		//else
			//ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f );
		
		// W3EE - Begin
		return super.Init( inOwner, prevInstance, skipCastingAnimation, notPlayerCast, isFreeCast );
		// W3EE - End
	}
		
	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'axii_ready' )
		{
			PlayEffect( effects[fireMode].throwEffect );
		}
		else if ( eventName == 'horse_cast_begin' )
		{
			OnHorseStarted();
		}
		else
		{
			return super.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		var i : int;
		
		SelectTargets();
		// W3EE - Begin
		if( !super.IsAlternateCast() )
			Combat().CacheAxiiLinkActors(targets);
		// W3EE - End
		
		for(i=0; i<targets.Size(); i+=1)
		{
			AddMagic17Effect(targets[i]);
		}
		
		Attach(true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
			
		PlayEffect( effects[fireMode].castEffect );
		
		if ( owner.ChangeAspect( this, S_Magic_s05 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AxiiChanneled' );
		}
		else
		{
			GotoState( 'AxiiCast' );
		}		
	}
	
	
	function OnHorseStarted()
	{
		Attach(true);
		PlayEffect( effects[fireMode].castEffect );
	}
	
	
	private final function IsTargetValid(actor : CActor, isAdditionalTarget : bool) : bool
	{
		var npc : CNewNPC;
		var horse : W3HorseComponent;
		var attitude : EAIAttitude;
		
		if(!actor)
			return false;
			
		if(!actor.IsAlive())
			return false;
		
				
		attitude = GetAttitudeBetween(owner.GetActor(), actor);
		
		
		if(isAdditionalTarget && attitude != AIA_Hostile)
			return false;
		
		npc = (CNewNPC)actor;
		
	
		if(attitude == AIA_Friendly)
		{
			
			if(npc.GetNPCType() == ENGT_Quest && !actor.HasTag(theGame.params.TAG_AXIIABLE_LOWER_CASE) && !actor.HasTag(theGame.params.TAG_AXIIABLE))
				return false;
		}
					
		
		if(npc)
		{
			horse = npc.GetHorseComponent();				
			if(horse && !horse.IsDismounted())	
			{
				if(horse.GetCurrentUser() != owner.GetActor())	
					return false;
			}
		}
		
		return true;
	}
	
	private function SelectTargets()
	{
		// W3EE - Begin
		var projCount, i, j : int;
		var actors, finalActors : array<CActor>;
		var ownerPos : Vector;
		var ownerActor : CActor;
		var actor : CActor;
		
		if( owner.CanUseSkill(S_Magic_s18, this) && !owner.ChangeAspect( this, S_Magic_s05 ) )
		{
			projCount = 1 + owner.GetSkillLevel(S_Magic_s18, this);
		}
		else
		{
			projCount = 1;
		}
		
		targets.Clear();
		actor = (CActor)thePlayer.slideTarget;	
		
		if(actor && IsTargetValid(actor, false))
		{
			targets.PushBack(actor);
			projCount -= 1;
			
			if(projCount == 0)
				return;
		}
		
		ownerActor = owner.GetActor();
		ownerPos = ownerActor.GetWorldPosition();
		
		
		actors = ownerActor.GetNPCsAndPlayersInCone(15, VecHeading(ownerActor.GetHeadingVector()), 150, 20, , FLAG_OnlyAliveActors);
					
		
		for(i=actors.Size()-1; i>=0; i-=1)
		{
			
			if(ownerActor == actors[i] || actor == actors[i] || !IsTargetValid(actors[i], true))
				actors.Erase(i);
		}
		
		
		if(actors.Size() > 0)
			finalActors.PushBack(actors[0]);
					
		for(i=1; i<actors.Size(); i+=1)
		{
			for(j=0; j<finalActors.Size(); j+=1)
			{
				if(VecDistance(ownerPos, actors[i].GetWorldPosition()) < VecDistance(ownerPos, finalActors[j].GetWorldPosition()))
				{
					finalActors.Insert(j, actors[i]);
					break;
				}
			}
			
			
			if(j == finalActors.Size())
				finalActors.PushBack(actors[i]);
		}
		
		
		if(finalActors.Size() > 0)
		{
			for(i=0; i<projCount; i+=1)
			{
				if(finalActors[i])
					targets.PushBack(finalActors[i]);
				else
					break;	
			}
		}
	}
	
	protected function ProcessThrow()
	{
		var proj : W3AxiiProjectile;
		var i : int;				
		var spawnPos : Vector;
		var spawnRot : EulerAngles;		
		
		
		
				
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		
		
		StopEffect( effects[fireMode].castEffect );
		PlayEffect('axii_sign_push');
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			proj = (W3AxiiProjectile)theGame.CreateEntity( projTemplate, spawnPos, spawnRot );
			proj.PreloadEffect( proj.projData.flyEffect );
			proj.ExtInit( owner, skillEnum, this );			
			proj.PlayEffect(proj.projData.flyEffect );				
			proj.ShootProjectileAtNode(0, projSpeed, targets[i]);
		}		
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var buff : EEffectInteract;
		var conf : W3ConfuseEffect;
		var i : int;
		// W3EE - Begin
		var axiiPower : SAbilityAttributeValue;
		// W3EE - End
		var casterActor : CActor;
		var dur, durAnimals : float;
		var params, staggerParams : SCustomEffectParams;
		var npcTarget : CNewNPC;
		var jobTreeType : EJobTreeType;
		// W3EE - Begin
		var sp, pts, prc, raw, chance, reductionLevel : float;
		// W3EE - End
		
		casterActor = owner.GetActor();		
		ProcessThrow();
		StopEffect(effects[fireMode].throwEffect);
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		
		
		RemoveMagic17Effect(orientationTarget);
				
		if(IsAlternateCast())
		{
			thePlayer.LockToTarget( false );
			thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
		}
		
		
		if (targets.Size() > 0 )
		{
			durAnimals = 30.f;
			if(IsAlternateCast())
				dur = 60.f;
			else
				dur = 10.f;
			
			//Kolaris - Prolongation
			if( ((W3PlayerWitcher)owner.GetActor()) )
				dur *= ((W3PlayerWitcher)owner.GetActor()).GetPlayerSignDurationMod();
			
			params.creator = casterActor;
			params.sourceName = "axii_" + skillEnum;			
			params.customPowerStatValue = super.GetTotalSignIntensity();
			params.isSignEffect = true;
			
			// W3EE - Begin
			if( owner.CanUseSkill(S_Magic_s19, this) )
				dur *= 1.f + (owner.GetSkillLevel(S_Magic_s19, this) * 0.2f);
				
			if( !IsAlternateCast() )
				chance = 0.75f + owner.GetSkillLevel(S_Magic_s19, this) * 0.05f;
			else
				chance = 0.5f + (owner.GetSkillLevel(S_Magic_s19, this) * 0.05f) + (owner.GetSkillLevel(S_Magic_s05, this) * 0.05f);
				
			axiiPower = super.GetTotalSignIntensity();
				
			if( owner.CanUseSkill(S_Magic_s18, this) && targets.Size() > 1)
			{
				reductionLevel = (0.11f - owner.GetSkillLevel(S_Magic_s18, this) * 0.01f) * (targets.Size() - 1);
				chance -= reductionLevel;
			}
			
			// W3EE - End
			
			for(i=0; i<targets.Size(); i+=1)
			{
				npcTarget = (CNewNPC)targets[i];
				
				prc = npcTarget.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL);
				
				//Kolaris - Posession
				if( ((W3PlayerWitcher)casterActor).HasAbility('Glyphword 29 _Stats', true) || ((W3PlayerWitcher)casterActor).HasAbility('Glyphword 30 _Stats', true) )
					prc *= 0.5f;
				
				chance *= axiiPower.valueMultiplicative * (1 - prc);
				
				if( npcTarget.HasTag('WeakToAxii') )
				{
					dur *= 1.25f;
					chance *= 1.25f;
				}
				
				//Kolaris - Axii Vitality Scaling
				if( npcTarget.UsesEssence() )
				{
					chance *= 0.5f + npcTarget.GetStatPercents(BCS_Essence) / 2.f;
					dur *= 1.5f - npcTarget.GetStatPercents(BCS_Essence) / 2.f;
				}
				else
				{
					chance *= 0.5f + npcTarget.GetStatPercents(BCS_Vitality) / 2.f;
					dur *= 1.5f - npcTarget.GetStatPercents(BCS_Vitality) / 2.f;
				}
				
				if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				{
					params.duration = durAnimals;
				}
				else
				{
					params.duration = dur;
				}
				
				jobTreeType = npcTarget.GetCurrentJTType();	
					
				if ( jobTreeType == EJTT_InfantInHand )
				{
					params.effectType = EET_AxiiGuardMe;
				}
				
				else if(IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly)
				{
					params.effectType = EET_Confusion;
				}
				else
				{
					params.effectType = actionBuffs[0].effectType;
				}
			
				
				RemoveMagic17Effect(targets[i]);
			
				// W3EE - Begin
				if(owner == thePlayer && GetWitcherPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
				{
					chance += 0.5f;
				}
				
				if( targets[i].IsAnimal() || npcTarget.IsHorse() || (owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly) )
				{
					chance = 1;
				}
				
				//Kolaris - Puppet
				if(IsAlternateCast())
				{
					chance -= 0.1f * Combat().GetPuppetCount();
					if( npcTarget.HasBuff(EET_Confusion) )
					{
						chance *= 2.f;
					}
				}
				
				//Kolaris - Axii
				chance *= 1 - 0.25f * npcTarget.GetAxiiHitCounter();
				
				if( ((W3Effect_NPCPoise)targets[i].GetBuff(EET_NPCPoise)).IsPoiseBroken() )
				{
					chance = 1.f;
					params.duration *= 3.f;
				}
				
				//Kolaris - posession
				if(IsAlternateCast() && ((W3PlayerWitcher)casterActor).HasAbility('Glyphword 30 _Stats', true))
					params.duration = -1;
				
				if(RandF() < chance)
				{
					buff = targets[i].AddEffectCustom(params);
					//Kolaris - Vampire Set
					if( ((W3PlayerWitcher)casterActor).IsSetBonusActive(EISB_Vampire_Alt_2) && (W3Effect_Bleeding)targets[i].GetBuff(EET_Bleeding) )
					{
						casterActor.PlayEffect('drain_energy_caretaker_shovel');
						casterActor.GainStat( BCS_Vitality, 500 * ((W3Effect_Bleeding)targets[i].GetBuff(EET_Bleeding)).GetStacks() );
						((W3Effect_Bleeding)targets[i].GetBuff(EET_Bleeding)).RemoveStack(15);
					}
					//Kolaris - Viper Set
					if( !IsAlternateCast() && ((W3PlayerWitcher)casterActor).IsSetBonusActive(EISB_Viper2) )
						targets[i].ApplyPoisoning(RandRange(((W3PlayerWitcher)casterActor).GetSetPartsEquipped(EIST_Viper), 0), casterActor, "Viper Set", true);
				}
				else
				{
					buff = EI_Deny;
					targets[i].IncAxiiHitCounter(-1.f);
				}
					
				if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
				{
					targets[i].OnAxiied( casterActor );
					conf = (W3ConfuseEffect)(targets[i].GetBuff(params.effectType, "axii_" + skillEnum));
						
					//Kolaris - Axii vs Sirens
					if( npcTarget.IsFlying() && !npcTarget.HasAbility('mon_siren_base') )
					{
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						params.duration = 0;	
						targets[i].AddEffectCustom(staggerParams);
					}
				}
				else
				{
					//Kolaris - Lethargy
					if( !(targets[i].IsImmuneToBuff(EET_Stagger) || npcTarget.IsFlying()) )
					{
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						params.duration = 0;	
						targets[i].AddEffectCustom(staggerParams);					
					}
					else
					{
						
						owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
					}
				}
				
				Combat().CullAxiiLinkActors(targets[i], buff);
				// W3EE - End
			}
		}
		
		casterActor.OnSignCastPerformed(ST_Axii, fireMode);
		
		super.OnEnded();
	}
	
	event OnSignAborted( optional force : bool )
	{
		HAXX_AXII_ABORTED();
		super.OnSignAborted(force);
	}
	
	
	public function HAXX_AXII_ABORTED()
	{
		var i : int;
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		RemoveMagic17Effect(orientationTarget);
	}
	
	
	public function OnDisplayTargetChange(newTarget : CActor)
	{
		var buffParams : SCustomEffectParams;
	
		//Kolaris - Lethargy
		/*if(!owner.CanUseSkill(S_Magic_s17, this) || owner.GetSkillLevel(S_Magic_s17, this) == 0)
			return;*/
	 
		if(newTarget == orientationTarget)
			return;
			
		RemoveMagic17Effect(orientationTarget);
		orientationTarget = newTarget;
		
		AddMagic17Effect(orientationTarget);			
	}
	
	private function AddMagic17Effect(target : CActor)
	{
		var buffParams : SCustomEffectParams;
		
		//Kolaris - Lethargy
		if( !target || ((CNewNPC)target).IsFlying() )
			return;
		
		buffParams.effectType = EET_SlowdownAxii;
		buffParams.creator = this;
		buffParams.sourceName = "axii_immobilize";
		buffParams.duration = 10;
		buffParams.effectValue.valueAdditive = 0.999f;
		buffParams.isSignEffect = true;
		
		target.AddEffectCustom(buffParams);
	}
	
	private function RemoveMagic17Effect(target : CActor)
	{
		if(target)
			target.RemoveBuff(EET_SlowdownAxii, true, "axii_immobilize");
	}
}

state AxiiCast in W3AxiiEntity extends NormalCast
{
	event OnEnded(optional isEnd : bool)
	{
		var player			: CR4Player;
		
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
			
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			//Kolaris - Griffin Set
			//parent.ManageGryphonSetBonusBuff();
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			// W3EE - Begin
			if( caster.GetPlayer() )
				Experience().AwardSignXP(parent.GetSignType());
			// W3EE - End
			caster.GetActor().SetBehaviorVariable( 'bStopSign', 1.f );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		
		super.OnSignAborted(force);
	}
}

state AxiiChanneled in W3AxiiEntity extends Channeling
{
	event OnEnded(optional isEnd : bool)
	{
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
		if( caster.GetPlayer() )
		{
			parent.ManagePlayerStamina();
			//Kolaris - Griffin Set
			//parent.ManageGryphonSetBonusBuff();
			Experience().AwardSignXP(parent.GetSignType());
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
		caster.OnDelayOrientationChange();
	}

	event OnProcessSignEvent( eventName : name )
	{
		if( eventName == 'axii_alternate_ready' )
		{
			
			
		}
		else
		{
			return parent.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		// W3EE - Begin
		{
			ChannelAxii();	
		}
		// W3EE - End
	}
		
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );

		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
	
		super.OnSignAborted( force );
	}
	
	// W3EE - Begin
	private var timeStamp : float;	default timeStamp = 0;
	private var DT : float; default DT = 0.006f;
	entry function ChannelAxii()
	{	
		timeStamp = theGame.GetEngineTimeAsSeconds();
		while( Update(DT) )
		{
			Sleep(DT);
			DT = MaxF(theGame.GetEngineTimeAsSeconds() - timeStamp, 0.002f);
			timeStamp = theGame.GetEngineTimeAsSeconds();
		}
	}
	// W3EE - End
}

