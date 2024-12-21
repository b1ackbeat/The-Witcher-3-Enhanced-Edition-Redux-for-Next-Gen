/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var projectileVictim : CProjectileTrajectory;
		
		projectileVictim = (CProjectileTrajectory)collidingComponent.GetEntity();
		
		if( projectileVictim )
		{
			projectileVictim.OnAardHit( this );
		}
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		// W3EE - Begin
		var dmgVal : float;
		var sp : SAbilityAttributeValue;
		var isFrostAard : bool;
		var effectParams : SCustomEffectParams;
		var victimNPC : CNewNPC;
		
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		
		
		hitEntities.PushBack( collider );
		super.ProcessCollision( collider, pos, normal );
		
		victimNPC = (CNewNPC) collider;
		if( IsRequiredAttitudeBetween(victimNPC, caster, true ) )
		{
			isFrostAard = ( ( W3PlayerWitcher )owner.GetPlayer() && owner.CanUseSkill(S_Magic_s12, GetSignEntity()) );
			
			if( owner.GetPlayer().IsSwimming() )
				action.AddDamage(theGame.params.DAMAGE_NAME_FORCE, 20000.f);
				
			if( isFrostAard )
			{
				action.SetBuffSourceName( "Magic_s12" );
			}		
			else
			{			
				dmgVal = 500.f;
				sp = GetSignEntity().GetTotalSignIntensity();
				if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 2)
					dmgVal += 125.f;
				if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 4)
					dmgVal += 125.f;
				
				//Kolaris - Disintegration
				dmgVal += CalculateAttributeValue(((W3PlayerWitcher)owner.GetPlayer()).GetAttributeValue('aard_damage_bonus'));
				
				dmgVal *= sp.valueMultiplicative;
				if( signEntity.IsAlternateCast() )
					dmgVal *= 0.25f + 0.05f * owner.GetSkillLevel(S_Magic_s01, GetSignEntity());
					
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
		}
		else
		{
			isFrostAard = false;
		}
		
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.SetProcessBuffsIfNoDamage(true);
		if( isFrostAard && victimNPC && victimNPC.IsAlive() )
		{
			ProcessFrostAard( victimNPC );
		}
		
		if ( !owner.IsPlayer() )
		{
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
		}
		
		theGame.damageMgr.ProcessAction( action );
		collider.OnAardHit( this );
		
		if (RandRange(100, 0) < (5 + owner.GetSkillLevel(S_Magic_s06, GetSignEntity()) * 3) * sp.valueMultiplicative)
		{
			effectParams.effectType = EET_Confusion;
			effectParams.creator = owner.GetPlayer();
			effectParams.sourceName = 'AardShockwave';
			//Kolaris - Prolongation
			effectParams.duration = 3.f * sp.valueMultiplicative * ((W3PlayerWitcher)owner.GetPlayer()).GetPlayerSignDurationMod();
			victimNPC.AddEffectCustom(effectParams);
		}
		
		//Kolaris - Disintegration
		if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 1 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 2 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 3 _Stats', true) )
		{
			victimNPC.ApplyBleeding(RoundMath(RandRange(5, 1) * sp.valueMultiplicative), owner.GetPlayer(), "Disintegration", false);
			((CActor)collider).CreateBloodSpill();
		}
		if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 2 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 3 _Stats', true) )
		{
			victimNPC.ModifyArmorValue(  -0.05f * sp.valueMultiplicative / (1.f + victimNPC.GetTotalArmorReduction('Sign')) , 'Sign' );
			victimNPC.ReduceNPCStat('force', 0.05f * sp.valueMultiplicative);
		}
	}
	
	private final function ProcessFrostAard( victimNPC : CNewNPC )
	{
		//Kolaris - Frostbite
		var dmgVal, frostDmgVal, slowDuration, prc : float;
		var sp : SAbilityAttributeValue;
		var chillParams : SCustomEffectParams;
		
		dmgVal = 500.f;
		sp = GetSignEntity().GetTotalSignIntensity();
		if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 2)
			dmgVal += 125.f;
		if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 4)
			dmgVal += 125.f;
		
		frostDmgVal = 50 * owner.GetSkillLevel(S_Magic_s12, GetSignEntity() );
		
		//Kolaris - Disintegration
		frostDmgVal += CalculateAttributeValue(((W3PlayerWitcher)owner.GetPlayer()).GetAttributeValue('aard_damage_bonus'));
		
		dmgVal *= sp.valueMultiplicative;
		frostDmgVal *= sp.valueMultiplicative;
		
		if( signEntity.IsAlternateCast() )
		{
			dmgVal *= 0.25f + 0.05f * owner.GetSkillLevel(S_Magic_s01, GetSignEntity());
			frostDmgVal *= 0.25f + 0.05f * owner.GetSkillLevel(S_Magic_s01, GetSignEntity());
		}
			
		prc = victimNPC.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FROST);
		action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
		action.AddDamage( theGame.params.DAMAGE_NAME_FROST, frostDmgVal );
		//Kolaris - Prolongation
		slowDuration = (1.f + owner.GetSkillLevel(S_Magic_s12, GetSignEntity() )) * sp.valueMultiplicative * (1 - prc) * ((W3PlayerWitcher)owner.GetPlayer()).GetPlayerSignDurationMod();
		//Kolaris - Disintegration
		if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 3 _Stats', true) )
		{
			if( RandF() < (0.75f + (0.5f - (victimNPC.GetStatPercents(BCS_Stamina) + ((W3Effect_NPCPoise)victimNPC.GetBuff(EET_NPCPoise)).GetPoisePercentage()) / 4) ) * sp.valueMultiplicative * (1 - prc) )
			{
				chillParams.effectType = EET_SlowdownFrost;
				chillParams.creator = owner.GetPlayer();
				chillParams.sourceName = "Magic_s12";
				chillParams.isSignEffect = true;
				chillParams.duration = slowDuration;
				victimNPC.AddEffectCustom(chillParams);
			}
		}
		else if( RandF() < (0.5f + (0.5f - (victimNPC.GetStatPercents(BCS_Stamina) + ((W3Effect_NPCPoise)victimNPC.GetBuff(EET_NPCPoise)).GetPoisePercentage()) / 4) ) * sp.valueMultiplicative * (1 - prc) )
		{
			chillParams.effectType = EET_SlowdownFrost;
			chillParams.creator = owner.GetPlayer();
			chillParams.sourceName = "Magic_s12";
			chillParams.isSignEffect = true;
			chillParams.duration = slowDuration;
			victimNPC.AddEffectCustom(chillParams);
		}
	}
	// W3EE - End
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		var sp : SAbilityAttributeValue;
		sp = GetSignEntity().GetTotalSignIntensity();
		staminaDrainPerc = p * sp.valueMultiplicative;
	}
}



class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}

class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	// W3EE - Begin
	public function GetSignEntity() : W3SignEntity
	{
		return signEntity;
	}
	// W3EE - End
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var signPower, channelDmg : SAbilityAttributeValue;
		var burnChance : float;					
		var maxArmorReduction : float;			
		var applyNbr : int;						
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		// W3EE - Begin
		var armorRedAttr : SAbilityAttributeValue;
		var currentReduction, perHitReduction, armorRedVal, pts, prc, reductionFactor, maxReductionFactor : float;
		// W3EE - End
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
		
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
		
		signPower = signEntity.GetTotalSignIntensity();
		if(signEntity.IsAlternateCast())		
		{
			igniEntity = (W3IgniEntity)signEntity;
			// W3EE - Begin
			performBurningTest = false;
			if(!actorVictim.HasBuff(EET_Burning))
				performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			// W3EE - End
			
			
			
			// signPower = signEntity.GetTotalSignIntensity();
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				
				// W3EE - Begin
				// channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, true);
				//Kolaris - Pyromaniac
				dmg = 800.f + GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s09, GetSignEntity()) * 80;
				//Kolaris - Purgation
				dmg += CalculateAttributeValue(((W3PlayerWitcher)owner.GetPlayer()).GetAttributeValue('igni_damage_bonus'));
				dmg *= signPower.valueMultiplicative;
				//Kolaris - Firestream
				if(actorVictim.HasBuff(EET_Burning))
					dmg *= 0.5f + 0.1f * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s02, GetSignEntity());
				// W3EE - End
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);
				
				//Kolaris - Purgation
				if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 10 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 11 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 12 _Stats', true) )
					actorVictim.DrainMorale((dmg / 5) * (1.6f - Options().AggressionBehavior() * 0.2f));
				
				if(!collider)	
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
			
			if( !actorVictim.HasBuff(EET_SlowdownFirestream) && !actorVictim.HasBuff(EET_Burning) )
				actorVictim.AddEffectDefault(EET_SlowdownFirestream, ownerActor,,true);
				
			actorVictim.AddTimer('Runeword1DisableFireFX', 1.f, false,,,, true);
			if( !actorVictim.IsEffectActive('critical_burning') )
			{
				actorVictim.PlayEffect('critical_burning');
				actorVictim.PlayEffect('critical_burning_csx');
			}
		}
		//Kolaris - Purgation
		else if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 10 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 11 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 12 _Stats', true) )
		{
			actorVictim.DrainMorale(20.f * (1.6f - Options().AggressionBehavior() * 0.2f));
			actorVictim.CreateFXEntityAtPelvis('runeword_4', true);
		}
		
		
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}
		
		
		// signPower = ownerActor.GetTotalSignSpellPower(S_Magic_s02);

		
		if ( !owner.IsPlayer() )
		{
			signPower = ownerActor.GetTotalSignSpellPower(S_Magic_s02);
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			if(ownerActor.HasTag('mq1060_witcher'))
			{
				action.SetHitEffect('igni_cone_hit_red', false, false);
				action.SetHitEffect('igni_cone_hit_red', true, false);
			}
			else
			{
				action.SetHitEffect('igni_cone_hit', false, false);
				action.SetHitEffect('igni_cone_hit', true, false);
			}			
			action.SetHitReactionType(EHRT_Igni, false);
		}
		
		theGame.damageMgr.ProcessAction( action );	
		
		
		// W3EE - Begin
		if ( owner.CanUseSkill(S_Magic_s08, GetSignEntity()) && npc )
		{	
			prc = npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE);
			
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s08, GetSignEntity());
			maxReductionFactor = 0.02f * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s08, GetSignEntity()) * signPower.valueMultiplicative;
			if ( !npc.IsProtectedByArmor() )
			{
				maxArmorReduction *= 0.5f;
				maxReductionFactor *= 0.5f;
			}
			reductionFactor = MinF(1, maxReductionFactor * MaxF(0.25f, 1 - prc));
			if( signEntity.IsAlternateCast() )
			{
				reductionFactor = MinF(1, reductionFactor * dt);
			}
			
			reductionFactor = ClampF(reductionFactor, 0.f, maxArmorReduction - npc.GetTotalArmorReduction('Sign')) * -1.f;
			npc.ModifyArmorValue(reductionFactor);
		}
		// W3EE - End
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		
		if(!channelCollided)
		{			
			
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02;
	}
}