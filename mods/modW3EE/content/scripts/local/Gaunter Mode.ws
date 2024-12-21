class GaunterModeManager
{
	public function ConfigEnabled() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMEnabled');
	}
	
	public function ConfigSkillsRequired() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMSkillReq'));
	}
	
	public function ConfigSpentSkillModifier() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMSkillMod'));
	}
	
	public function ConfigQuestMod() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMQuestMod'));
	}
	
	public function ConfigDeathMod() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMDeathMod'));
	}
	
	public function ConfigDeathLimit() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMDeathLimit'));
	}
	
	public function ConfigVitalityLoss() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMVitality'));
	}
	
	public function ConfigStaminaLoss() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMStamina'));
	}
	
	public function ConfigToxicityLoss() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMToxicity'));
	}
	
	public function ConfigIntensityLoss() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMIntensity'));
	}
	
	public function ConfigXPModifier() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMXPMod'));
	}
	
	public function ConfigDurabilityLoss() : int
	{
		return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMDurability'));
	}
	
	public function ConfigMark() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMMark');
	}
	
	public function ConfigLethalMark() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('GaunterMode', 'GMLethalMark');
	}
	
	public function CanActivate() : bool
	{
		var witcher : W3PlayerWitcher;
		var checkDeathLimit, checkSkillReq : bool;
		var expectedDeathCounter : int;
		
		witcher = GetWitcherPlayer();
		expectedDeathCounter = witcher.GetDeathCounter() + 1;
		
		if( witcher.GetBuff( EET_Mutation11Debuff, "GM Debuff" ) )
			expectedDeathCounter += ConfigDeathMod();
		
		if( ConfigDeathLimit() > 0 )
			checkDeathLimit = expectedDeathCounter <= ConfigDeathLimit();
		else
			checkDeathLimit = true;
		
		checkSkillReq = GetAvailableSkillPoints() + GetAvailablePathPoints() >= GetFinalSkillRequirements();
		
		if( checkDeathLimit && checkSkillReq )
			return true;
		else
			return false;
		
	}
	
	public function GetFinalSkillRequirements() : int
	{
		if( ConfigSpentSkillModifier() > 0 )
			return (ConfigSkillsRequired() + FloorF((Experience().GetTotalSkillPoints() - Experience().GetAllCurrentPoints()) / ConfigSpentSkillModifier())) * 100;
		else
			return ConfigSkillsRequired() * 100;
	}
	
	public function GetAvailableSkillPoints() : int
	{
		return Experience().GetAllCurrentPoints() * 100;
	}
	
	public function GetAvailablePathPoints() : int
	{
		return Experience().GetAllPathProgress();
	}
	
	public function ProcessSkillDrain()
	{
		var i, j, currentAmount, remainingAmount, targetAmount : int;
		var targetSkill : ESkillSubPath;
		
		if( GetFinalSkillRequirements() > 0 )
		{
			currentAmount = 0;
			targetAmount = GetFinalSkillRequirements();
			if( GetAvailableSkillPoints() >= targetAmount )
			{
				for(i=0; i<(targetAmount / 100); i+=1)
				{
					Experience().ModTotalPathPoints(Experience().GetRandomNotEmptySkill(false), -1.f, true);
				}
			}
			else
			{
				j = Experience().GetAllCurrentPoints();
				for(i=0; i<j; i+=1)
				{
					Experience().ModTotalPathPoints(Experience().GetRandomNotEmptySkill(false), -1.f, true);
					currentAmount += 100;
				}
				while( currentAmount < targetAmount )
				{
					remainingAmount = targetAmount - currentAmount;
					targetSkill = Experience().GetRandomNotEmptySkill(true);
					if( remainingAmount < Experience().GetPathProgress(targetSkill) )
					{
						Experience().ModPathProgressDirect(targetSkill, remainingAmount * -1);
						currentAmount += remainingAmount;
					}
					else
					{
						currentAmount += Experience().GetPathProgress(targetSkill);
						Experience().ModPathProgressDirect(targetSkill, Experience().GetPathProgress(targetSkill) * -100);
					}
				}
			}
		}
	}
	
	public function ProcessEquipmentDamage()
	{
		var witcher : W3PlayerWitcher;
		var equipment : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var damageAmount, i, j : int;
		var currentDurability, bonusDurability, oilDurability, oilPercentage : float;
		var oils : array<W3Effect_Oil>;
		
		damageAmount = ConfigDurabilityLoss();
		
		if( damageAmount > 0 )
		{
			witcher = GetWitcherPlayer();
			equipment = witcher.GetEquippedItems();
			inv = witcher.GetInventory();
			
			for(i=0; i<equipment.Size(); i+=1)
			{
				if ( !inv.IsIdValid( equipment[i] ) || !inv.HasItemDurability( equipment[i] ) || !(inv.IsItemAnyArmor( equipment[i] ) || inv.IsItemWeapon( equipment[i] )) )
					continue;
				if ( inv.ItemHasTag(equipment[i], 'Aerondight') && inv.IsItemWeapon( equipment[i] ) )
					continue;
				
				bonusDurability = MaxF( 0, 1 - CalculateAttributeValue( inv.GetItemAttributeValue( equipment[i], 'indestructible' ) ) );
				oilPercentage = 0.f;
				if( inv.IsItemWeapon( equipment[i] ) )
				{
					oils = inv.GetOilsAppliedOnItem( equipment[i] );
					if( oils.Size() > 0 )
					{
						for(j=0; j<oils.Size(); j+=1)
						{
							if(oils[j].GetAmmoPercentage() > oilPercentage)
							{
								oilPercentage = oils[j].GetAmmoPercentage();
							}
						}
					}
				}
				oilDurability = 1.f - (0.2f * witcher.GetSkillLevel(S_Alchemy_s05) * oilPercentage);
				currentDurability = inv.GetItemDurability(equipment[i]);
				witcher.RemoveRepairBuffs(equipment[i]);
				inv.SetItemDurabilityScript(equipment[i], currentDurability * ((100 - RandRange(damageAmount, 1) * bonusDurability * oilDurability) / 100.f) );
			}
		}
	}
	
	public function ProcessQuestRewards( rewardName : name )
	{
		var witcher : W3PlayerWitcher;
		var rewardString : string;
		var configVal : int;
		var toxEffect : W3Effect_Toxicity;
		
		witcher = GetWitcherPlayer();
		rewardString = NameToString(rewardName);
		configVal = ConfigQuestMod() * -1;
		
		if( rewardName == 'q605_mirror_finale_only_exp' )
			witcher.ResetDeathCounter();
		else if( StrContains(rewardString, "q605_mirror_finale") )
			witcher.UpdateDeathCounter(FloorF(witcher.GetDeathCounter() / -2));
		
		if( rewardName == 'mq7023_completed' )
			FactsAdd("TaFtSComplete", 1);
		
		if( ConfigQuestMod() > 0 )
		{
			if( rewardName == 'q103_08_completed' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q105_4_info_witches' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q302_05_completed' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q305_03b_dandelion_free' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q205_2_quest_completed' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q401_06_break_umas_curse' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q403_09_completed' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q111_3_killed_imlerith' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q310_9_lodge_gathered' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q210_2_vault_done' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q603_16_task_completed' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q605_olgierd_finale_reward' )
				witcher.UpdateDeathCounter(configVal);
			else if( StrContains(rewardString, "q605_mirror_finale") )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q702_10_done' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q704_ft_enter_fairytale' )
				witcher.UpdateDeathCounter(configVal);
			else if( rewardName == 'q705_beast_slayer' )
				witcher.UpdateDeathCounter(configVal);
		}
		
	}
	
	public function UpdateDeathEffects()
	{
		var witcher : W3PlayerWitcher;
		var i, currentCount, desiredCount, deathCount : int;
		
		witcher = GetWitcherPlayer();
		deathCount = witcher.GetDeathCounter();
		
		if(!ConfigEnabled() || deathCount < 1)
		{
			witcher.RemoveAllBuffsOfType(EET_DeathCounter);
			witcher.RemoveAllBuffsOfType(EET_GMDeathVitality);
			witcher.RemoveAllBuffsOfType(EET_GMDeathStamina);
			witcher.RemoveAllBuffsOfType(EET_GMDeathToxicity);
			witcher.RemoveAllBuffsOfType(EET_GMDeathIntensity);
			witcher.RemoveAbilityAll('GMDeathVitalityEffect');
			witcher.RemoveAbilityAll('GMDeathStaminaEffect');
			witcher.RemoveAbilityAll('GMDeathToxicityEffect');
			witcher.RemoveAbilityAll('GMDeathIntensityEffect');
		}
		else
		{
			if(!witcher.HasBuff(EET_DeathCounter))
				witcher.AddEffectDefault( EET_DeathCounter, witcher, "", false );
			
			currentCount = witcher.GetAbilityCount('GMDeathVitalityEffect');
			desiredCount = ConfigVitalityLoss() / 10 * deathCount;
			if( currentCount > desiredCount )
			{
				witcher.RemoveAllBuffsOfType(EET_GMDeathVitality);
				witcher.RemoveAbilityAll('GMDeathVitalityEffect');
				currentCount = 0;
			}
			for( i = 0; i < (desiredCount - currentCount); i += 1)
			{
				witcher.AddAbility('GMDeathVitalityEffect', true);
			}
			
			currentCount = witcher.GetAbilityCount('GMDeathStaminaEffect');
			desiredCount = ConfigStaminaLoss() * deathCount;
			if( currentCount > desiredCount )
			{
				witcher.RemoveAllBuffsOfType(EET_GMDeathStamina);
				witcher.RemoveAbilityAll('GMDeathStaminaEffect');
				currentCount = 0;
			}
			for( i = 0; i < (desiredCount - currentCount); i += 1)
			{
				witcher.AddAbility('GMDeathStaminaEffect', true);
			}
			
			currentCount = witcher.GetAbilityCount('GMDeathToxicityEffect');
			desiredCount = ConfigToxicityLoss() * deathCount;
			if( currentCount > desiredCount )
			{
				witcher.RemoveAllBuffsOfType(EET_GMDeathToxicity);
				witcher.RemoveAbilityAll('GMDeathToxicityEffect');
				currentCount = 0;
			}
			for( i = 0; i < (desiredCount - currentCount); i += 1)
			{
				witcher.AddAbility('GMDeathToxicityEffect', true);
			}
			
			currentCount = witcher.GetAbilityCount('GMDeathIntensityEffect');
			desiredCount = ConfigIntensityLoss() * deathCount;
			if( currentCount > desiredCount )
			{
				witcher.RemoveAllBuffsOfType(EET_GMDeathIntensity);
				witcher.RemoveAbilityAll('GMDeathIntensityEffect');
				currentCount = 0;
			}
			for( i = 0; i < (desiredCount - currentCount); i += 1)
			{
				witcher.AddAbility('GMDeathIntensityEffect', true);
			}
		}
	}
	
	public function UpdateDemonMark()
	{
		var acs : array< CComponent >;
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		acs = witcher.GetComponentsByClassName( 'CHeadManagerComponent' );
		
		if( ConfigEnabled() && ConfigMark() && !ConfigLethalMark() )
			( ( CHeadManagerComponent ) acs[0] ).SetDemonMark( true );
		else
		if( ConfigEnabled() && ConfigMark() && ConfigLethalMark() && CanActivate() )
			( ( CHeadManagerComponent ) acs[0] ).SetDemonMark( false );
		else
		if( ConfigEnabled() && ConfigMark() && ConfigLethalMark() && !CanActivate() )
			( ( CHeadManagerComponent ) acs[0] ).SetDemonMark( true );
	}
}
//Kolaris - Test
exec function CanGaunterModeActivate()
{
	if( GaunterMode().CanActivate() && GaunterMode().ConfigEnabled() )
		theGame.GetGuiManager().ShowNotification("Yes");
	else
		theGame.GetGuiManager().ShowNotification("No");
}

exec function PrintCurrentSkillPoints()
{
	theGame.GetGuiManager().ShowNotification(Experience().GetAllCurrentPoints());
}

exec function PrintCurrentPathPoints()
{
	theGame.GetGuiManager().ShowNotification(Experience().GetAllPathProgress());
}

exec function PrintCurrentSpentSkills()
{
	theGame.GetGuiManager().ShowNotification(Experience().GetTotalSkillPoints());
}

exec function PrintRandomNonEmptySkill(pathProgress : bool)
{
	theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt(SkillSubPathToLocalisationKey(Experience().GetRandomNotEmptySkill(pathProgress))));
}

exec function ModDeathCounter(amount : int)
{
	 GetWitcherPlayer().UpdateDeathCounter(amount);
}

exec function TestWeaponFx( fxName : name, optional disable : bool )
{
	GetWitcherPlayer().PlayEffectOnHeldWeapon(fxName, disable);
}

exec function TestPlayerFx( fxName : name, optional mode : name )
{
	if( mode == 'single' )
		GetWitcherPlayer().PlayEffectSingle(fxName);
	else if( mode == 'stop' )
		GetWitcherPlayer().StopEffect(fxName);
	else
		GetWitcherPlayer().PlayEffect(fxName);
}

exec function TestEnemyFx( fxName : name, optional subFxName : name )
{
	var fx : CEntity;
	
	fx = GetWitcherPlayer().GetTarget().CreateFXEntityAtPelvis(fxName, true);
	if( subFxName != '' )
		fx.PlayEffect(subFxName);
}

exec function TestSoundEvent( sfxName : string, optional soundBank : string )
{
	if( soundBank != "" && !theSound.SoundIsBankLoaded(soundBank) )
	{
		theSound.SoundLoadBank(soundBank, true);
		theSound.SoundEvent(sfxName);
		theSound.SoundUnloadBank(soundBank);
	}
	else
		theSound.SoundEvent(sfxName);
}

exec function PrintToxEntries()
{
	theGame.GetGuiManager().ShowNotification("Entries: " + ((W3Effect_Toxicity)GetWitcherPlayer().GetBuff(EET_Toxicity)).GetToxicityEntryCount());
}

exec function GetFactStatus( fact : string )
{
	theGame.GetGuiManager().ShowNotification(FactsQuerySum(fact));
}

exec function TestWeaponHolster( weaponType : EPlayerWeapon, ignoreActionLock : bool, optional sheatheIfAlreadyEquipped : bool )
{
	GetWitcherPlayer().OnEquipMeleeWeapon( weaponType, ignoreActionLock, sheatheIfAlreadyEquipped );
}

exec function TestAddAbility( abilityName : name )
{
	GetWitcherPlayer().AddAbility(abilityName, false);
}

exec function PrintPlayerPosition()
{
	theGame.GetGuiManager().ShowNotification("Position: " + VecToString(GetWitcherPlayer().GetWorldPosition()));
}

exec function PrintBehaviorVariable( variable : name )
{
	theGame.GetGuiManager().ShowNotification(thePlayer.GetBehaviorVariable(variable));
}

exec function CheckCrossbowStatus()
{
	if( thePlayer.IsReloading() && thePlayer.ShouldCancelReload() )
		theGame.GetGuiManager().ShowNotification("Is Reloading: True<br>Should Cancel Reload: True");
	else if( !thePlayer.IsReloading() && thePlayer.ShouldCancelReload() )
		theGame.GetGuiManager().ShowNotification("Is Reloading: False<br>Should Cancel Reload: True");
	else if( thePlayer.IsReloading() && !thePlayer.ShouldCancelReload() )
		theGame.GetGuiManager().ShowNotification("Is Reloading: True<br>Should Cancel Reload: False");
	else
		theGame.GetGuiManager().ShowNotification("Is Reloading: False<br>Should Cancel Reload: False");
}

exec function PrintAttributeValue( attribute : name )
{
	theGame.GetGuiManager().ShowNotification(CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue(attribute)));
}

exec function PrintMutationResearchProgress(mutation : EPlayerMutationType)
{
	theGame.GetGuiManager().ShowNotification(GetWitcherPlayer().GetMutationResearchProgress(mutation));
}

class W3Effect_DeathCounter extends CBaseGameplayEffect
{
	default effectType = EET_DeathCounter;	
	default isPositive = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	public function GetDisplayCount() : int
	{
		return GetWitcherPlayer().GetDeathCounter();;
	}
	
	public function GetMaxDisplayCount() : int
	{
		return GetWitcherPlayer().GetDeathCounter();;
	}
	
}

class W3Effect_GMDeathVitality extends CBaseGameplayEffect
{
	default effectType = EET_GMDeathVitality;
	default isPositive = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_GMDeathStamina extends CBaseGameplayEffect
{
	default effectType = EET_GMDeathStamina;
	default isPositive = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_GMDeathToxicity extends CBaseGameplayEffect
{
	default effectType = EET_GMDeathToxicity;
	default isPositive = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_GMDeathIntensity extends CBaseGameplayEffect
{
	default effectType = EET_GMDeathIntensity;
	default isPositive = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}