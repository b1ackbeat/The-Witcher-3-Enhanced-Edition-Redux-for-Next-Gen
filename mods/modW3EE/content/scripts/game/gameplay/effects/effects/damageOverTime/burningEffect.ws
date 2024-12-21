/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_Burning extends W3CriticalDOTEffect
{
	private var cachedMPAC : CMovingPhysicalAgentComponent;
	private var updateDelay : float;
	private var isWithGlyphword12 : bool;
	private var glyphword12Fx : W3VisualFx;
	private var glyphword12BurningChance : float;
	private var glyphword12NotBurnedEntities : array<CGameplayEntity>;
	private var skillLevel : int;
	private var range : float;
	private var criticalStateChecked : bool; //Kolaris - Burn Damage
	
	default criticalStateType = ECST_BurnCritical;
	default effectType = EET_Burning;
	default powerStatType = CPS_SpellPower;
	default resistStat = CDS_BurningRes;
	default canBeAppliedOnDeadTarget = true;
	default updateDelay = 0.f;
	default criticalStateChecked = false; //Kolaris - Burn Damage
	
	public function CacheSettings()
	{
		super.CacheSettings();
		
		allowedHits[EHRT_Igni] = false;
		
		
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_ThrowBomb);			
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Counter);
		
		
		vibratePadLowFreq = 0.1;
		vibratePadHighFreq = 0.2;
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{		
		var vec : Vector;
		var template : CEntityTemplate;
		var surface : CGameplayFXSurfacePost;
		
		if ( this.IsOnPlayer() && thePlayer.IsUsingVehicle() )
		{
			if ( blockedActions.Contains( EIAB_Crossbow ) )
				blockedActions.Remove(EIAB_Crossbow);
		}
		else
			blockedActions.PushBack(EIAB_Crossbow);
	
		super.OnEffectAdded(customParams);
		cachedMPAC = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent());
		
		if (isOnPlayer )
		{
			if ( thePlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
				thePlayer.AddCustomOrientationTarget(OT_CustomHeading, 'BurningEffect');
		}
		else
			target.IncBurnCounter();
		
		//Kolaris - Prolongation
		if( GetCreator() == thePlayer && isSignEffect )
			timeLeft *= ((W3PlayerWitcher)thePlayer).GetPlayerSignDurationMod();
		
		if(!target.IsAlive())
			timeLeft = 10;
		
		//Kolaris - Pyromaniac
		if(GetCreator() == thePlayer && isSignEffect && thePlayer.CanUseSkill(S_Magic_s09))
			effectValue.valueAdditive += thePlayer.GetSkillLevel(S_Magic_s09) * 20.f;
		
		//Kolaris - Purgation
		if( GetCreator() == thePlayer && ((W3PlayerWitcher)thePlayer).HasAbility('Glyphword 12 _Stats', true) )
			thePlayer.GainStat(BCS_Focus, 0.5f);
		
		if(EntityHandleGet(creatorHandle) == thePlayer && !isSignEffect)
			powerStatType = CPS_Undefined;
			
		if(!isOnPlayer && GetCreator() == thePlayer && thePlayer.CanUseSkill(S_Magic_s07) && isSignEffect && IsRequiredAttitudeBetween(thePlayer, target, true))
		{
			isWithGlyphword12 = true;
			skillLevel = thePlayer.GetSkillLevel(S_Magic_s07);
			template = (CEntityTemplate)LoadResource('glyphword_12');
			glyphword12Fx = (W3VisualFx)theGame.CreateEntity(template, target.GetWorldPosition(), target.GetWorldRotation(), , , true);
			glyphword12Fx.CreateAttachment(target, 'pelvis');
			//Kolaris - Combustion Chance
			glyphword12BurningChance = 0.1f * skillLevel;
			range = CeilF(1.f + skillLevel / 2.f);
			
			
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(target.GetWorldPosition(), 1, timeLeft, 1, range, 1);
		}
		else
		{
			isWithGlyphword12 = false;
		}
		
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		target.AddTag(theGame.params.TAG_OPEN_FIRE);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		cachedMPAC = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent());
	}
	
	event OnUpdate(deltaTime : float)
	{
		var player : CR4Player = thePlayer;	
		var i : int;
		var actor : CActor;
		var ents : array<CGameplayEntity>;
		var actors : array<CActor>;
		var params : SCustomEffectParams;
		var min, max : SAbilityAttributeValue;
		
		if ( this.isOnPlayer )
		{
			if ( player.bLAxisReleased )
				player.SetOrientationTargetCustomHeading( player.GetHeading(), 'BurningEffect' );
			else if ( player.GetPlayerCombatStance() == PCS_AlertNear )
				player.SetOrientationTargetCustomHeading( VecHeading( player.moveTarget.GetWorldPosition() - player.GetWorldPosition() ), 'BurningEffect' );
			else
				player.SetOrientationTargetCustomHeading( VecHeading( theCamera.GetCameraDirection() ), 'BurningEffect' );
		}
		else if(updateDelay >= 1.f)
		{
			if(isWithGlyphword12)
			{
				FindGameplayEntitiesInCylinder(ents, target.GetWorldPosition(), range, 2.f, 10,,FLAG_OnlyAliveActors + FLAG_ExcludePlayer + FLAG_ExcludeTarget, target);
				
				params.effectType = EET_Burning;
				params.creator = thePlayer;
				params.sourceName = 'glyphword 12';
				//params.isSignEffect = true;
				params.duration = 4;
				
				for(i=0; i<ents.Size(); i+=1)
				{
					actor = (CActor)ents[i];
					
					if(glyphword12NotBurnedEntities.Contains(ents[i]))
						continue;
					
					glyphword12NotBurnedEntities.PushBack(ents[i]);
					//Kolaris - Combustion Chance
					if(!IsRequiredAttitudeBetween(thePlayer, actor, true, false, false) || (RandF() > glyphword12BurningChance * (1.f - (((CNewNPC)actor).GetBurnCounter() * 0.1f)) * (1.f - ((CNewNPC)actor).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE))) || actor.HasBuff(EET_Burning))
						continue;
					
					actor.AddEffectCustom(params);
				}
			}
			
			//Kolaris - Purgation
			if( GetCreator() == thePlayer && ((W3PlayerWitcher)thePlayer).HasAbility('Glyphword 10 _Stats', true) || ((W3PlayerWitcher)thePlayer).HasAbility('Glyphword 11 _Stats', true) || ((W3PlayerWitcher)thePlayer).HasAbility('Glyphword 12 _Stats', true) )
			{
				actors = GetActorsInRange(target, 5, 1000);
				for(i=0; i<actors.Size(); i+=1)
				{
					if(!IsRequiredAttitudeBetween(thePlayer, actors[i], true, false, false))
					{
						continue;
					}
					actors[i].DrainMorale(1.f);
				}
				((CActor)target).DrainMorale(5.f);
			}
			
			//Kolaris - Cremation
			if(GetCreator() == thePlayer && (((W3PlayerWitcher)thePlayer).HasAbility('Runeword 11 _Stats', true) || ((W3PlayerWitcher)thePlayer).HasAbility('Runeword 12 _Stats', true)) )
			{
				effectValue.valueAdditive += 10;
				if( ((W3PlayerWitcher)thePlayer).HasAbility('Runeword 12 _Stats', true) )
					target.IncCremationCounter();
			}
				
			updateDelay = 0.f;
		}
		
		updateDelay += deltaTime;
		
		//Kolaris - Burn Damage
		if( target.GetBehaviorVariable('CriticalStateType') != (int)ECST_BurnCritical && !criticalStateChecked )
		{
			effectValue.valueAdditive *= 2.f;
			criticalStateChecked = true;
		}
		
		if(cachedMPAC && cachedMPAC.GetSubmergeDepth() <= -1)
			target.RemoveAllBuffsOfType(effectType);
		else
			super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		if ( isOnPlayer )	
			thePlayer.RemoveCustomOrientationTarget('BurningEffect');	
	
		target.RemoveTag(theGame.params.TAG_OPEN_FIRE);
		
		if(glyphword12Fx)
		{
			glyphword12Fx.StopAllEffects();
			glyphword12Fx.DestroyAfter(5.f);
		}
		
		super.OnEffectRemoved();
		
	}
	
	
	public function OnTargetDeath()
	{
		
		timeLeft = 10;
	}
	
	
	public function OnTargetDeathAnimFinished()
	{
		
		timeLeft = 10;
	}
	
	public final function IsFromMutation2() : bool
	{
		return sourceName == "Mutation2ExplosionValid";
	}
}