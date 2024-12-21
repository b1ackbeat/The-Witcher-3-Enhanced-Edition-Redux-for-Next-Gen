class W3EEBloodEffectsHandler
{
	private var bloodEffects : array<CName>;
	
	public function Init()
	{
		bloodEffects.Resize(3);
		bloodEffects.PushBack('cutscene_blood_trail');
		bloodEffects.PushBack('cutscene_blood_trail_02');
		bloodEffects.PushBack('blood_trail_finisher');
	}
	
	public function ShouldShowBlood( act : W3DamageAction, actorVictim : CActor, victim : EMonsterCategory, playerAttacker : CR4Player, attackAction : W3Action_Attack, isCriticalHit : bool ) : bool
	{
		if( Options().IsBloodActive() && playerAttacker && actorVictim && !actorVictim.HasTag('AerondightIgnore') && actorVictim.CanBleed() && actorVictim.IsAttackableByPlayer() && act.CanPlayHitParticle() && !thePlayer.IsWeaponHeld('fist') && ( !Options().IsBloodOnlyCrit() || isCriticalHit ) ) 
		{
			if( !Options().IsBloodActiveRanged() && attackAction.IsActionRanged() )
				return false;
			else 
				return true;
		}
		else return false;
	}

	private function ImpactBloodSpray( victim : CNewNPC )
	{
		var weaponEntity : CEntity;
		var weaponSlotMatrix : Matrix;
		var bloodFxPos : Vector;
		var bloodFxRot : EulerAngles;
		var tempEntity : CEntity;
		
		weaponEntity = thePlayer.GetInventory().GetItemEntityUnsafe(thePlayer.GetInventory().GetItemFromSlot('r_weapon'));
		weaponEntity.CalcEntitySlotMatrix('blood_fx_point', weaponSlotMatrix);
		
		bloodFxPos = MatrixGetTranslation(weaponSlotMatrix);
		bloodFxRot = weaponEntity.GetWorldRotation();
		
		tempEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource('finisher_blood'), bloodFxPos, bloodFxRot);
		tempEntity.PlayEffect(bloodEffects[RandRange(bloodEffects.Size())]);
	}
	
	public function ShowBlood( weaponID : SItemUniqueId, victim : CNewNPC, rangedAttack : bool )
	{
		if( Options().IsBloodTrailActive() )
		{
			if( victim.GetBloodType() == BT_Red )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect(bloodEffects[RandRange(bloodEffects.Size())]);
			}
			else
			if (victim.GetBloodType() == BT_Green )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect('aerondight_blood_green');
			}
			else
			if( victim.GetBloodType() == BT_Yellow )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect('aerondight_blood_yellow');
			}
			else
			if( victim.GetBloodType() == BT_Black )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect('aerondight_blood_black');
			}
		}
		
		if( victim.GetBloodType() == BT_Red )
		{
			if( !rangedAttack )
			{
				thePlayer.PlayEffect('covered_blood');
				thePlayer.AddTimer('RemoveBloodEffects', 45.f,,,,, true);
			}
			
			if( Options().IsBloodSprayActive() )
				ImpactBloodSpray(victim);
		}
	}
}

enum EInjuryType
{
	EFI_Head,
	EFI_Chest,
	EFI_Arms,
	EFI_Legs,
	EPI_Head,
	EPI_Spine,
	EPI_Arms,
	EPI_Legs,
	EIT_None
}

class W3EEInjurySystem
{
	private var EPIHorizontal				: array<EInjuryType>;
	private var EFIHorizontal 				: array<EInjuryType>;
	private var EFIVerticalUp				: array<EInjuryType>;
	private var EPIVerticalUp 				: array<EInjuryType>;
	private var EFIVerticalDown				: array<EInjuryType>;
	private var EPIVerticalDown 			: array<EInjuryType>;
	private var appliedInjuries 			: array<EInjuryType>;
	private var initInjuries 				: bool;
	private var cachedActor					: CActor;
	private var playerAttacker 				: W3PlayerWitcher;
	private var healthType					: EBaseCharacterStats;
	
	public function Init( actor : CActor )
	{
		cachedActor = actor;
		if( cachedActor.UsesVitality() )
			healthType = BCS_Vitality;
		else
			healthType = BCS_Essence;
		
		// Dorsal Upper Body Injuries
		EPIVerticalDown.PushBack(EPI_Head);
		
		// Dorsal Lower Body Injuries
		EPIVerticalUp.PushBack(EPI_Legs);
		
		// Dorsal Middle Body Injuries
		EPIHorizontal.PushBack(EPI_Spine);
		EPIHorizontal.PushBack(EPI_Arms);
		
		// Frontal Upper Body Injuries
		EFIVerticalDown.PushBack(EFI_Head);
		
		// Frontal Lower Body Injuries
		EFIVerticalUp.PushBack(EFI_Legs);
		
		// Frontal Middle Body Injuries
		EFIHorizontal.PushBack(EFI_Chest);
		EFIHorizontal.PushBack(EFI_Arms);
	}
	
	//Kolaris - Injury Effects
	public function DamagedBlindness()
	{
		if( HasInjury(EFI_Head) || HasInjury(EPI_Head) )
			cachedActor.AddTimer('RollDamagedBlindness', RandRangeF(0.3f, 0.1f), false);
	}
	
	public function AttackStumbles()
	{
		if( HasInjury(EFI_Arms) || HasInjury(EPI_Arms) )
			cachedActor.AddTimer('RollRunningAttackStumble', RandRangeF(0.3f, 0.1f), false);
	}
	
	public function ParryStumbles()
	{
		if( HasInjury(EFI_Chest) || HasInjury(EPI_Spine) )
			cachedActor.AddTimer('RollParryStumble', RandRangeF(0.3f, 0.1f), false);
	}
	
	public function DodgeStumbles()
	{
		if( HasInjury(EFI_Legs) || HasInjury(EPI_Legs) )
			cachedActor.AddTimer('RollDodgeStumble', RandRangeF(0.3f, 0.1f), false);
	}
	
	public function ApplyCombatInjury( attackAction : W3Action_Attack, damageDealt : float, oilInfos : SOilInfo, causer : IScriptable )
	{
		var injuryChanceMult, min, max : SAbilityAttributeValue;
		var appliedInjury : EInjuryType;
		var injuryChance, injuryResist, bombLevel : float;
		var applyInjury : bool;
		var bombCauser : W3Petard;
		//Kolaris - Mutilation
		var npcPoise : W3Effect_NPCPoise;
		var mutilationAction : W3DamageAction;
		
		if( ((CPlayer)cachedActor && (Options().InjuryPlayerImmunity() || ((CActor)attackAction.attacker).HasTag('Vesemir'))) || cachedActor.GetImmortalityMode() == AIM_Invulnerable || cachedActor.GetDisplayName() == "Tree's Heart" )
			return;
		
		//Kolaris - Enemy Special Attacks, Kolaris - Bomb Injuries
		if( attackAction.IsActionWitcherSign() || attackAction.IsActionEnvironment() || (((!attackAction.DealsAnyDamage() && damageDealt < 10.f) || attackAction.IsCountered() || attackAction.IsParried()) && !(Combat().GetEnemyAoESpecialAttackType((CActor)attackAction.attacker) > 0)) )
			return;
		
		injuryChance = Options().InjuryChance();
		if( injuryChance > 0.f )
		{
			playerAttacker = (W3PlayerWitcher)attackAction.attacker;
			bombCauser = (W3Petard)causer;
			
			//Kolaris - Enemy Special Attacks
			if( (CNewNPC)cachedActor )
				injuryResist = ((CNewNPC)cachedActor).GetNPCCustomStat(theGame.params.DAMAGE_NAME_INJURY);
			else if( (W3PlayerWitcher)cachedActor )
			{
				injuryChanceMult = ((W3PlayerWitcher)cachedActor).GetAttributeValue('injury_resist');
				injuryChanceMult.valueMultiplicative += 0.1f * GetWitcherPlayer().GetSkillLevel(S_Sword_s10);
				injuryChanceMult.valueMultiplicative = ClampF(injuryChanceMult.valueMultiplicative, 0.f, 1.f);
				injuryResist = injuryChanceMult.valueMultiplicative;
				if( ((W3PlayerWitcher)cachedActor).IsQuenActive(true) )
					injuryResist = 1.f;
			}
			
			injuryChance *= (damageDealt / 1000.f);
			
			if( attackAction.GetForceInjury() )
				injuryChance = 100;
			else if( bombCauser )
			{
				//Kolaris - Transmutation
				if( (playerAttacker.HasAbility('Runeword 13 _Stats', true) || playerAttacker.HasAbility('Runeword 14 _Stats', true) || playerAttacker.HasAbility('Runeword 15 _Stats', true)) && oilInfos.activeIndex[7] )
					injuryChance += 100 * oilInfos.attributeValues[7].valueMultiplicative;
				
				if( (W3Samum)bombCauser )
				{
					theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(bombCauser.GetBombName(), true, 'level', min, max);
					bombLevel = CalculateAttributeValue(min);
					
					if( RoundMath(bombLevel) == 3 )
						injuryChance += 100;
					else if( RoundMath(bombLevel) == 2 )
						injuryChance += 75;
					else
						injuryChance += 50;
				}
				
				if( bombCauser.IsCluster() )
					injuryChance *= 0.1f;
			}
			else
			{
				if( playerAttacker )
				{
					injuryChanceMult = playerAttacker.GetAttributeValue('injury_chance');
					if( playerAttacker.inv.IsIdValid(attackAction.GetCrossbowID()) )
						injuryChanceMult = playerAttacker.inv.GetItemAttributeValue(attackAction.GetCrossbowID(), 'injury_chance');
						
                    if( playerAttacker.IsLightAttack(attackAction.GetAttackName()) )
                    {
                        injuryChanceMult.valueMultiplicative += 0.15f;
                        injuryChanceMult.valueMultiplicative += 0.1f * playerAttacker.GetSkillLevel(S_Sword_s05);
                    }
                    /*else 
						injuryChanceMult.valueMultiplicative -= 0.15f;*/
					
					//Kolaris - Transfusion
					if( oilInfos.activeIndex[7] )
					{
						if( playerAttacker.CanUseSkill(S_Alchemy_s06) && ((W3Effect_Bleeding)cachedActor.GetBuff(EET_Bleeding)).GetStacks() > 0 )
							injuryChanceMult.valueMultiplicative += (oilInfos.attributeValues[7].valueAdditive * (1.f + 0.01f * playerAttacker.GetSkillLevel(S_Alchemy_s06) * ((W3Effect_Bleeding)cachedActor.GetBuff(EET_Bleeding)).GetStacks()));
						else
							injuryChanceMult.valueMultiplicative += oilInfos.attributeValues[7].valueAdditive;
					}
					
					//Kolaris - Cat Set
					if( playerAttacker.HasBuff(EET_LynxSetAttack) )
						injuryChanceMult.valueMultiplicative += 0.1f * playerAttacker.GetSetPartsEquipped(EIST_Lynx);
					
					injuryChance *= 1.f + injuryChanceMult.valueMultiplicative;
						
					if( ((W3Effect_SwordBehead)playerAttacker.GetBuff(EET_SwordBehead)).GetBeheadEffectActive() )
						injuryChance *= 2.f;
				}
				
				//Kolaris - Coup de Grace
				if( attackAction.IsCriticalHit() )
				{
					if( playerAttacker && playerAttacker.CanUseSkill(S_Perk_11) )
						injuryChance *= 2.f;
					else
						injuryChance *= 1.5f;
				}
				
				injuryChance /= appliedInjuries.Size() + 1;
			}
			
			injuryChance *= (1.f - injuryResist);
			applyInjury = RandRange(100, 0) < injuryChance;
			//theGame.GetGuiManager().ShowNotification("Final Injury Chance: " + injuryChance);
			
			if( applyInjury )
			{
				appliedInjury = GetInjuryType(attackAction, bombCauser);
				if( appliedInjury != EIT_None )
				{
					ApplyInjuryType(appliedInjury, attackAction);
					SendInjuryMessage(appliedInjury, attackAction);
					
					//Kolaris - Cat Set
					if( playerAttacker && playerAttacker.IsSetBonusActive( EISB_Lynx_2 ) )
					{
						((CNewNPC)cachedActor).SetAnimationSpeedMultiplier(0.95f);
						((CNewNPC)cachedActor).CatReduceDamage(0.95f);
					}
					//Kolaris - Mutilation
					if( playerAttacker && (playerAttacker.HasAbility('Runeword 55 _Stats', true) || playerAttacker.HasAbility('Runeword 56 _Stats', true) || playerAttacker.HasAbility('Runeword 57 _Stats', true)) )
					{
						((CNewNPC)cachedActor).ReduceNPCArmorPen(0.1f);
						if( playerAttacker.HasAbility('Runeword 57 _Stats', true) )
						{
							cachedActor.CreateFXEntityAndPlayEffect('mutation9_hit', 'hit_refraction');
							npcPoise = (W3Effect_NPCPoise)((CNewNPC)cachedActor).GetBuff(EET_NPCPoise);
							npcPoise.ReducePoise(npcPoise.GetMaxPoise() * 0.1f);
							npcPoise.SetMaxPoise(npcPoise.GetMaxPoise() * 0.9f);
							
							mutilationAction = new W3DamageAction in theGame.damageMgr;
							mutilationAction.Initialize( playerAttacker, cachedActor, playerAttacker, "Runeword 57", EHRT_None, CPS_Undefined, false, false, false, true );
							mutilationAction.SetHitAnimationPlayType(EAHA_ForceNo);
							mutilationAction.SetCannotReturnDamage(true);
							mutilationAction.SetCanPlayHitParticle(false);
							if( ((CNewNPC)cachedActor).UsesVitality() )
								mutilationAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, ((CNewNPC)cachedActor).GetStatMax(BCS_Vitality) * 0.1f);
							else
								mutilationAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, ((CNewNPC)cachedActor).GetStatMax(BCS_Essence) * 0.1f);
							theGame.damageMgr.ProcessAction(mutilationAction);
							delete mutilationAction;
						}
					}
				}
				if( (CR4Player)cachedActor )
					theGame.GetTutorialSystem().uiHandler.GotoState('Injury');
				((W3PlayerWitcher)cachedActor).UpdateWoundedState();
			}
		}
	}
	
	public function GetInjuryCount() : int
	{
		return appliedInjuries.Size();
	}
	
	public function HasInjury( injuryType : EInjuryType ) : bool
	{
		return appliedInjuries.Contains(injuryType);
	}
	
	//Kolaris - Injury Effects
	public function HealRandomInjury()
	{
		var injuryHealed : int = RandRange(appliedInjuries.Size() - 1);
		
		if( !HasSimilarInjury(appliedInjuries[injuryHealed]) )
			cachedActor.RemoveAllBuffsOfType(InjuryTypeToEffect(appliedInjuries[injuryHealed]));
		
		appliedInjuries.Erase(injuryHealed);
		
		((W3PlayerWitcher)cachedActor).UpdateWoundedState();
	}
	
	public function ClearInjuries()
	{
		appliedInjuries.Clear();
		cachedActor.RemoveAllBuffsOfType(EET_InjuredArm);
		cachedActor.RemoveAllBuffsOfType(EET_InjuredLeg);
		cachedActor.RemoveAllBuffsOfType(EET_InjuredTorso);
		cachedActor.RemoveAllBuffsOfType(EET_InjuredHead);
		
		((W3PlayerWitcher)cachedActor).UpdateWoundedState();
	}
	
	private function InjuryTypeToEffect( injuryType : EInjuryType ) : EEffectType
	{
		switch(injuryType)
		{
			case EFI_Head:
			case EPI_Head:
				return EET_InjuredHead;
				
			case EFI_Chest:
			case EPI_Spine:
				return EET_InjuredTorso;
				
			case EFI_Arms:
			case EPI_Arms:
				return EET_InjuredArm;
				
			case EFI_Legs:
			case EPI_Legs:
				return EET_InjuredLeg;
				
			default : return EET_Undefined;
		}
	}
	
	private function HasSimilarInjury( injuryType : EInjuryType ) : bool
	{
		switch(injuryType)
		{
			case EFI_Head:	return HasInjury(EPI_Head);
			case EPI_Head:	return HasInjury(EFI_Head);
			
			case EFI_Chest:	return HasInjury(EPI_Spine);
			case EPI_Spine:	return HasInjury(EFI_Chest);
			
			case EFI_Arms:	return HasInjury(EPI_Arms);
			case EPI_Arms:	return HasInjury(EFI_Arms);
			
			case EFI_Legs:	return HasInjury(EPI_Legs);
			case EPI_Legs:	return HasInjury(EFI_Legs);
			
			default : return false;
		}
	}
	
	private function GetSwingType( attackAction : W3Action_Attack ) : name
	{
		var swingDirection, swingType : int;
		
		swingType = (int)attackAction.GetSwingType();
		swingDirection = (int)attackAction.GetSwingDirection();
		
		if( swingType == 2 || ((swingType == 1 || swingType == 4) && swingDirection == 1) )
			return 'Up';
		else
		if( swingType == 3 || ((swingType == 1 || swingType == 4) && swingDirection == 0) )
			return 'Down';
		else
			return 'Horizontal';
	}
	
	private function TryForInjuryType( injuryArray : array<EInjuryType> ) : EInjuryType
	{
		var tempInjuryArray : array<EInjuryType>;
		var injuryType : EInjuryType;
		var size, i, idx : int;
		
		size = injuryArray.Size();
		tempInjuryArray = injuryArray;
		idx = RandRange(size, 0);
		injuryType = tempInjuryArray[idx];
		for(i=0; i<size; i+=1)
		{
			if( InflictInjury(injuryType) )
				return injuryType;
			
			tempInjuryArray.Erase(idx);
			idx = RandRange(tempInjuryArray.Size(), 0);
			injuryType = tempInjuryArray[idx];
		} 
		
		return EIT_None;
	}
	
	private function GetInjuryType( attackAction : W3Action_Attack, optional bombCauser : W3Petard ) : EInjuryType
	{
		var appliedInjury : EInjuryType;
		var attackAngle : float;
		var swingType : name;
				
		//Kolaris - Enemy Special Attacks, Kolaris - Bomb Injuries
		if( Combat().GetEnemyAoESpecialAttackType((CActor)attackAction.attacker) == 2 || (W3Samum)bombCauser )
		{
			appliedInjury = TryForInjuryType(EFIVerticalDown);
			if( appliedInjury == EIT_None )
				appliedInjury = TryForInjuryType(EPIVerticalDown);
			
			return appliedInjury;
		}
		else if( Combat().GetEnemyAoESpecialAttackType((CActor)attackAction.attacker) == 1 || bombCauser )
		{
			appliedInjury = TryForInjuryType(EFIVerticalUp);
			if( appliedInjury == EIT_None )
				appliedInjury = TryForInjuryType(EPIVerticalUp);
			
			return appliedInjury;
		}
		
		attackAngle = AngleDistance(VecHeading(attackAction.attacker.GetWorldPosition() - cachedActor.GetWorldPosition()), cachedActor.GetHeading());
		swingType = GetSwingType(attackAction);
		if( AbsF(attackAngle) >= 130 )
		{
			if( swingType == 'Up' )
			{
				appliedInjury = TryForInjuryType(EPIVerticalUp);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EPIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Down' )
			{
				appliedInjury = TryForInjuryType(EPIVerticalDown);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EPIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Horizontal' )
			{
				appliedInjury = TryForInjuryType(EPIHorizontal);
				return appliedInjury;
			}
		}
		else
		{
			if( swingType == 'Up' )
			{
				appliedInjury = TryForInjuryType(EFIVerticalUp);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EFIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Down' )
			{
				appliedInjury = TryForInjuryType(EFIVerticalDown);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EFIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Horizontal' )
			{
				appliedInjury = TryForInjuryType(EFIHorizontal);
				return appliedInjury;
			}
		}
		
		return EIT_None;
	}
	
	public function InflictInjury( injuryType : EInjuryType ) : bool
	{
		//Kolaris - Injury Stacking
		if( HasInjury(injuryType) )
			return false;
		else
			appliedInjuries.PushBack(injuryType);
		
		return true;
	}
	
	private function GetAlternateNotificationText() : string
	{
		var enemyCategory : EMonsterCategory;
		var npcVictim : CNewNPC;
		
		npcVictim = (CNewNPC)cachedActor;
		enemyCategory = npcVictim.npcStats.opponentType;
		
		if( npcVictim.GetSfxTag() == 'sfx_ghoul' ) return GetLocStringByKeyExt("W3EE_Legs");
		switch(enemyCategory)
		{
			case MC_Beast:
			case MC_Insectoid:
			case MC_Relic:
			case MC_Animal:
				return GetLocStringByKeyExt("W3EE_Legs");
			
			case MC_Draconide:
			case MC_Hybrid:
				return GetLocStringByKeyExt("W3EE_Wings");
			
			default:	return GetLocStringByKeyExt("W3EE_Arms");
		}
	}
	
	private function SendInjuryMessage( injuryType : EInjuryType, optional attackAction : W3Action_Attack )
	{
		var injuryMessage, injuryMessageEnd : string;
		
		if( attackAction && !(((CPlayer)attackAction.attacker) || ((CPlayer)attackAction.victim)) )
			return;
		
		switch(injuryType)
		{
			case EPI_Head:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Head");		break;
			case EPI_Spine:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Spine");		break;
			case EPI_Arms:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Arms");		break;
			case EPI_Legs:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Legs");		break;
			case EFI_Head:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Head");		break;
			case EFI_Chest:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Chest");		break;
			case EFI_Arms:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Arms");		break;
			case EFI_Legs:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Legs");		break;
		}
		
		if( (CPlayer)attackAction.victim )
			injuryMessage += GetLocStringByKeyExt("W3EE_InjurySustained");
		else
			injuryMessage += GetLocStringByKeyExt("W3EE_InjuryInflicted");
		
		if( injuryMessageEnd == GetLocStringByKeyExt("W3EE_Arms") )
			injuryMessageEnd = GetAlternateNotificationText();
		
		injuryMessage += injuryMessageEnd;
		
		if( Options().InjuryMessages() )
			theGame.GetGuiManager().ShowNotification(injuryMessage, 1500.f, true);
		HudShowInjuryType(injuryMessageEnd + " " + GetLocStringByKeyExt("W3EE_Injury"));
	}
	
	private function HudShowInjuryType( injuryName : string )
	{
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleEnemyFocus;
		
		if( playerAttacker.GetTarget() == cachedActor )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				module = (CR4HudModuleEnemyFocus)hud.GetHudModule("EnemyFocusModule");
				if( module )
					module.ShowDamageType(EFVT_Buff, 0, , injuryName);
			}
		}
	}
	
	//Kolaris - Injury Effects
	private function ApplyInjuryType( injuryType : EInjuryType, attackAction : W3Action_Attack )
	{
		var effectParams : SCustomEffectParams;
		var playerWitcher : W3PlayerWitcher;
				
		playerWitcher = (W3PlayerWitcher)cachedActor;
		attackAction.SetHitReactionType(EHRT_Heavy);
		
		switch(injuryType)
		{
			case EFI_Head:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredHead) )
					playerWitcher.AddEffectDefault(EET_InjuredHead, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyHeadInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyHeadInjuryAbility', false);
					((CNewNPC)cachedActor).ReduceNPCStat('mental', 0.2f);
				}
				
				cachedActor.PlayEffect('heavy_hit');
				if( (CPlayer)cachedActor )
				{
					cachedActor.PlayEffect('stunned_ghost');
					cachedActor.AddTimer('StopHeadHitEffect', 5.f, false);
				}
				
				if( playerWitcher )
					effectParams.effectType = EET_Blindness;
				else
					effectParams.effectType = EET_Confusion;
				effectParams.creator = attackAction.attacker;
				effectParams.sourceName = 'CombatInjury';
				effectParams.duration = 5.f;
				cachedActor.AddEffectCustom(effectParams);
				
				cachedActor.ApplyBleeding(1, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.15f, 3.f);
				//attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EFI_Chest:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredTorso) )
					playerWitcher.AddEffectDefault(EET_InjuredTorso, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyTorsoInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyTorsoInjuryAbility', false);
					((CNewNPC)cachedActor).ReduceNPCStat('bleed', 0.25f);
				}
				
				cachedActor.PlayEffect('death_hit');
				
				cachedActor.ApplyBleeding(2, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.15f, 3.f);
				//attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EFI_Arms:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredArm) )
					playerWitcher.AddEffectDefault(EET_InjuredArm, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyArmInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyArmInjuryAbility', false);
					((CNewNPC)cachedActor).CatReduceDamage(0.9f);
				}
				
				cachedActor.PlayEffect('heavy_hit');
				
				cachedActor.ApplyBleeding(1, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.15f, 3.f);
				//attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EFI_Legs:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredLeg) )
					playerWitcher.AddEffectDefault(EET_InjuredLeg, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyLegInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyLegInjuryAbility', false);
					((CNewNPC)cachedActor).SetAnimationSpeedMultiplier(0.9f);
					((CNewNPC)cachedActor).ReduceNPCStat('force', 0.25f);
				}
				
				cachedActor.PlayEffect('heavy_hit');
				
				cachedActor.ApplyBleeding(1, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.15f, 3.f);
				//attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EPI_Head:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredHead) )
					playerWitcher.AddEffectDefault(EET_InjuredHead, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyHeadInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyHeadInjuryAbility', false);
					((CNewNPC)cachedActor).ReduceNPCStat('mental', 0.2f);
				}
				
				cachedActor.PlayEffect('heavy_hit');
				if( (CPlayer)cachedActor )
				{
					cachedActor.PlayEffect('stunned_ghost');
					cachedActor.AddTimer('StopHeadHitEffect', 5.f, false);
				}
				
				if( playerWitcher )
					effectParams.effectType = EET_Blindness;
				else
					effectParams.effectType = EET_Confusion;
				effectParams.creator = attackAction.attacker;
				effectParams.sourceName = 'CombatInjury';
				effectParams.duration = 5.f;
				cachedActor.AddEffectCustom(effectParams);
				
				cachedActor.ApplyBleeding(2, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.3f, 6.f);
				//attackAction.AddEffectInfo(EET_LongStagger);
			break;
			
			case EPI_Spine:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredTorso) )
					playerWitcher.AddEffectDefault(EET_InjuredTorso, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyTorsoInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyTorsoInjuryAbility', false);
					((CNewNPC)cachedActor).ReduceNPCStat('bleed', 0.25f);
				}
					
				cachedActor.PlayEffect('death_hit');
				
				cachedActor.ApplyBleeding(4, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.3f, 6.f);
				//attackAction.AddEffectInfo(EET_LongStagger);
			break;
			
			case EPI_Arms:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredArm) )
					playerWitcher.AddEffectDefault(EET_InjuredArm, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyArmInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyArmInjuryAbility', false);
					((CNewNPC)cachedActor).CatReduceDamage(0.9f);
				}
					
				cachedActor.PlayEffect('heavy_hit');
				
				cachedActor.ApplyBleeding(2, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.3f, 6.f);
				//attackAction.AddEffectInfo(EET_LongStagger);
			break;
			
			case EPI_Legs:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredLeg) )
					playerWitcher.AddEffectDefault(EET_InjuredLeg, playerWitcher, "injury", false);
				else if( !playerWitcher && !cachedActor.HasAbility('EnemyLegInjuryAbility') )
				{
					cachedActor.AddAbility('EnemyLegInjuryAbility', false);
					((CNewNPC)cachedActor).SetAnimationSpeedMultiplier(0.9f);
					((CNewNPC)cachedActor).ReduceNPCStat('force', 0.25f);
				}
				
				cachedActor.PlayEffect('heavy_hit');
				
				cachedActor.ApplyBleeding(2, attackAction.attacker, "CombatInjury", true);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.3f, 6.f);
				//attackAction.AddEffectInfo(EET_LongStagger);
			break;
		}
	}
}

exec function AddInjury( player : bool, type : EInjuryType )
{
	if( player )
		GetWitcherPlayer().GetInjuryManager().InflictInjury(type);
	else
		GetWitcherPlayer().GetTarget().GetInjuryManager().InflictInjury(type);
}

exec function RemoveInjuries( player : bool )
{
	if( player )
		GetWitcherPlayer().GetInjuryManager().ClearInjuries();
	else
		GetWitcherPlayer().GetTarget().GetInjuryManager().ClearInjuries();
}