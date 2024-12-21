/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



struct SToxicityEntry
{
	var effectType : EEffectType;
	var activeTox : float;
	var dormantTox : float;
	var totalTox : float;
	var duration : float;
}

class W3Effect_Toxicity extends CBaseGameplayEffect
{
	
	public var isUnsafe						: bool;
	private var witcher 					: W3PlayerWitcher;
	private var updateInterval				: float;
	private var maxStat						: float;
	
	private var updateCounter				: float;
	private var feverActive					: bool;
	private var feverMinimumInterval		: int;
	private var offset						: float;
	private var safeThreshold				: float;
	private var maxChance					: float;
	
	default effectType = EET_Toxicity;
	default attributeName = 'toxicityRegen';
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;	
		
	
	private saved var dmgTypeName 			: name;							
	private saved var toxThresholdEffect	: int;
	private var delayToNextVFXUpdate		: float;
		
	
	public function CacheSettings()
	{
		//dmgTypeName = theGame.params.DAMAGE_NAME_DIRECT;
		
		super.CacheSettings();
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		//var witcher : W3PlayerWitcher;
	
		if( !((W3PlayerWitcher)target) )
		{
			LogAssert(false, "W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
		
		witcher = GetWitcherPlayer();
	
		
		//if( witcher.GetStatPercents(BCS_Toxicity) >= witcher.GetToxicityDamageThreshold())
		if(witcher.HasBuff(EET_ToxicityFever))
			switchCameraEffect = true;
		else
			switchCameraEffect = false;
			
		
		super.OnEffectAdded(customParams);	
	}

	
	
	event OnUpdate(deltaTime : float)
	{
		var dmg, maxStat, toxicity, threshold, drainVal, toxicityOffset, toxicityPerc, gainVal, netVal, damageVal : float;
		var dmgValue, min, max : SAbilityAttributeValue;
		var currentStateName 	: name;
		var currentThreshold	: int;

		super.OnUpdate(deltaTime);
		
		
		
		//toxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false) / GetWitcherPlayer().GetStatMax(BCS_Toxicity);
		toxicity = witcher.GetStat(BCS_Toxicity, false);
		toxicityOffset = witcher.GetToxicityOffset();
		threshold = GetWitcherPlayer().GetToxicityDamageThreshold();
		toxicityPerc = toxicity / witcher.GetStatMax(BCS_Toxicity);

		
		/*
		if( toxicity >= threshold && !isPlayingCameraEffect)	
			switchCameraEffect = true;
		else if(toxicity < threshold && isPlayingCameraEffect)	
			switchCameraEffect = true;
		*/

		
		if( delayToNextVFXUpdate <= 0 )
		{				
			
			
			
			if(toxicityPerc <= 0.0f)		currentThreshold = 0;
			else if(toxicityPerc < 0.5f)	currentThreshold = 1;
			else if(toxicityPerc < 0.75f)	currentThreshold = 2;
			else if(toxicityPerc <= 1.0f)	currentThreshold = 3;
			if( target.HasBuff(EET_ToxicityFever) )
				currentThreshold += 1;
			/*
			if(toxicity <= 0.0f)		currentThreshold = 0;
			else if(toxicity < 0.25f)	currentThreshold = 1;
			else if(toxicity < 0.5f)	currentThreshold = 2;
			else if(toxicity < 0.75f)	currentThreshold = 3;
			else if(toxicity >= 0.75f)	currentThreshold = 4;*/

			
			//if(  toxThresholdEffect != currentThreshold &&  !target.IsEffectActive('invisible' ) )
			if( witcher.ShouldRefreshFace() || toxThresholdEffect != currentThreshold && !target.IsEffectActive('invisible') )
			{
				
				
				
				if (toxThresholdEffect < 0) 
					toxThresholdEffect = 0;
				
				switch ( toxThresholdEffect )
				{
					case 0: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_000_025'); 
							toxThresholdEffect += 1; 							
						} 
						break;
					case 1: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_025_050'); 
							toxThresholdEffect += 1; 
						} 
						else 
						{ 
							PlayHeadEffect('toxic_025_000'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 2: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_050_075'); 
							toxThresholdEffect += 1; 
						} 
						else 
						{ 
							PlayHeadEffect('toxic_050_025'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 3: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_075_100'); 
							toxThresholdEffect += 1; 
						}
						else 
						{ 
							PlayHeadEffect('toxic_075_050'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 4: 
						PlayHeadEffect('toxic_100_075'); 
						toxThresholdEffect -= 1; 
						break;
				}
				
				
				
				delayToNextVFXUpdate = 2;
				witcher.ResetRefreshFace();
			}		
			
		}
		else
		{
			delayToNextVFXUpdate -= deltaTime;
		}
				
		
		/*
		if(toxicity >= threshold)
		{
			currentStateName = thePlayer.GetCurrentStateName();
			if(currentStateName != 'Meditation' && currentStateName != 'MeditationWaiting')
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, dmgTypeName, min, max);	
			
				if(DamageHitsVitality(dmgTypeName))
					maxStat = target.GetStatMax(BCS_Vitality);
				else
					maxStat = target.GetStatMax(BCS_Essence);
				
				dmgValue = GetAttributeRandomizedValue(min, max);
				dmg = MaxF(0, deltaTime * ( dmgValue.valueAdditive + (dmgValue.valueMultiplicative * (maxStat + dmgValue.valueBase) ) ));
				
				
				
				
				
				
			
				if(dmg > 0)
					effectManager.CacheDamage(dmgTypeName,dmg,NULL,this,deltaTime,true,CPS_Undefined,false);
				else
					LogAssert(false, "W3Effect_Toxicity: should deal damage but deals 0 damage!");
			}
			
			
			if(thePlayer.CanUseSkill(S_Alchemy_s20) && !target.HasBuff(EET_IgnorePain))
				target.AddEffectDefault(EET_IgnorePain, target, 'IgnorePain');
		}
		else
		{
			
			target.RemoveBuff(EET_IgnorePain);
		}
			
		
		drainVal = deltaTime * (effectValue.valueAdditive + (effectValue.valueMultiplicative * (effectValue.valueBase + target.GetStatMax(BCS_Toxicity)) ) );
		
		
		if(!target.IsInCombat())
			drainVal *= 1.1; 
			
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
		*/
		updateInterval += deltaTime;
		if( updateInterval >= 1.0f )
		{
			UpdateEntries(updateInterval);
			updateCounter += updateInterval;
			updateInterval = 0;
			isUnsafe = toxicity > threshold;
			//Kolaris - Toxicity Rework
			drainVal = GetToxicityDrain();
			//Kolaris - Mutation 5
			if( witcher.IsMutationActive(EPMT_Mutation5) && witcher.GetCurrentStateName() != 'W3EEMeditation' )
				drainVal = 0.f;
			gainVal = GetToxicityGain();
			netVal = gainVal + drainVal;
			
			//Kolaris - Toxicity Rework
			if( !target.HasBuff(EET_ToxicityFever) && toxicityPerc >= 1 )
				StartFever();
			if( target.HasBuff(EET_ToxicityFever) && toxicityPerc <= 0.9f )
				target.RemoveBuff(EET_ToxicityFever);
			
			//Kolaris - Toxicity Rework
			effectManager.CacheStatUpdate(BCS_Toxicity, netVal);
			if( toxicityPerc >= 1 && netVal > 0 )
			{
				//Kolaris - Difficulty Settings
				damageVal = netVal / 25 * (1 - 0.1f * witcher.GetSkillLevel(S_Alchemy_s15)) * witcher.GetStatMax(BCS_Vitality) * Options().GetDifficultySettingMod();
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_POISON, damageVal, NULL, this, 1.0f, true, CPS_Undefined, false);
			}
			witcher.RemoveToxicityOffset(GetResidualToxicityDegen(toxicityOffset));
		}
	}
	
	function PlayHeadEffect( effect : name, optional stop : bool )
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i : int;
		
		inv = target.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				continue;
			}
			
			headId = headIds[i];
					
			if(!inv.IsIdValid( headId ))
			{
				LogAssert(false, "W3Effect_Toxicity : Can't find head item");
				return;
			}
			
			head = inv.GetItemEntityUnsafe( headId );
			
			if( !head )
			{
				LogAssert(false, "W3Effect_Toxicity : head item is null");
				return;
			}

			if ( stop )
			{
				if ( head.IsEffectActive( effect ) ) 	
					head.StopEffect( effect );
			}
			else
			{
				if ( head.IsEffectActive( effect ) ) 	
					head.StopEffect( effect );			
				head.PlayEffectSingle( effect );
			}
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		toxThresholdEffect = -1;
		witcher = (W3PlayerWitcher)t;
	}
	
	event OnEffectRemoved()
	{
		RemoveAllEntries();
		super.OnEffectRemoved();
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s20) && target.HasBuff(EET_IgnorePain))
			target.RemoveBuff(EET_IgnorePain);
			
		
		
		
		
		PlayHeadEffect( 'toxic_000_025', true );
		PlayHeadEffect( 'toxic_025_050', true );
		PlayHeadEffect( 'toxic_050_075', true );
		PlayHeadEffect( 'toxic_075_100', true );
		
		PlayHeadEffect( 'toxic_050_025', true );
		PlayHeadEffect( 'toxic_075_050', true );
		PlayHeadEffect( 'toxic_100_075', true );
		
		
		PlayHeadEffect( 'toxic_025_000', true ); 
		
		toxThresholdEffect = 0;
		if( theSound.SoundIsBankLoaded("fever02a.bnk") )
			theSound.SoundUnloadBank("fever02a.bnk");
		
		//Kolaris - Assimilation
		((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(0);
	}
	
	protected function SetEffectValue()
	{
		RecalcEffectValue();
	}
	
	public function RecalcEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s15))
			effectValue += thePlayer.GetSkillAttributeValue(S_Alchemy_s15, attributeName, false, true) * thePlayer.GetSkillLevel(S_Alchemy_s15);
			
		if(thePlayer.HasAbility('Runeword 8 Regen'))
			effectValue += thePlayer.GetAbilityAttributeValue('Runeword 8 Regen', 'toxicityRegen');
	}
	
	public function DisplayToxicity()
	{
		var i : int;
		var str : string;
		
		var messageData 	: W3MessagePopupData;
		var messagePopupRef : CR4MessagePopup;
		
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			str += "effect: " + toxicityEntries[i].effectType + "<br>total tox: " + toxicityEntries[i].totalTox + "<br>active tox: " + toxicityEntries[i].activeTox + "<br>dormant tox: " + toxicityEntries[i].dormantTox + "<br><br>";
		}
		
		theGame.GetGuiManager().ShowUserDialogAdv( 0, "Toxicity info", str, false, UDB_Ok );
		//theGame.GetGuiManager().ShowNotification( str, 8.f );
	}
	
	public function StartFever()
	{
		var effectParams	: SCustomEffectParams;
		var duration 		: float;
		
		//Kolaris - Toxicity Rework
		duration = -1;
		/*duration = 60.f + RandRangeF(60.f);
		duration *= Options().GetFeverDurationMult();*/
		
		effectParams.effectType = EET_ToxicityFever;
		effectParams.sourceName = "ToxicityFeverEffect";
		effectParams.duration = duration;
		
		target.AddEffectCustom(effectParams);
	}
	
	private saved var toxicityEntries : array<SToxicityEntry>;
	public function AddToxicityEntry( effect : EEffectType, toxicity: float, duration : float )
	{
		//Kolaris - Toxicity Rework
		toxicityEntries.PushBack(SToxicityEntry(effect, toxicity, 0, toxicity, duration));
		//Kolaris - Assimilation
		if( witcher.HasAbility('Glyphword 48 _Stats', true) )
			((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(toxicityEntries.Size());
	}
	
	//Kolaris - Toxicity Rework	
	public function GetToxicityEntryCount() : int
	{
		return toxicityEntries.Size();
	}
	
	public function ClearToxicityHoney( activeReduction : float, dormantReduction : float )
	{
		var i : int;
		var drainVal : float;
		
		//Kolaris - Toxicity Rework
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			//drainVal += toxicityEntries[i].activeTox * activeReduction + toxicityEntries[i].dormantTox * dormantReduction;
			toxicityEntries[i].activeTox -= toxicityEntries[i].activeTox * activeReduction;
			//toxicityEntries[i].dormantTox -= toxicityEntries[i].dormantTox * dormantReduction;
		}
		drainVal = witcher.GetStat(BCS_Toxicity, false) * dormantReduction;
		effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
	}
	
	public function ClearToxicityFever()
	{
		var i : int;
		var drainVal, reductionVal, sum : float;
		
		reductionVal = 15.f;
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].dormantTox <= reductionVal )
			{
				reductionVal -= toxicityEntries[i].dormantTox;
				drainVal += toxicityEntries[i].dormantTox;
				toxicityEntries[i].dormantTox = 0.f;
			}
			else
			{
				drainVal += reductionVal;
				toxicityEntries[i].dormantTox -= reductionVal;
				break;
			}
		}
		
		effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
	}
	
	private function RemoveAllEntries()
	{
		var i, size : int;
		var drainVal : float;
		
		size = toxicityEntries.Size();
		for(i=0; i<size; i+=1)
		{
			drainVal = toxicityEntries[i].activeTox + toxicityEntries[i].dormantTox;
			effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
			toxicityEntries.Erase(i);
		}
		//Kolaris - Assimilation
		if( witcher.HasAbility('Glyphword 48 _Stats', true) )
			((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(toxicityEntries.Size());
	}
	
	private function FindInertElement() : int
	{
		var i : int;
		
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].activeTox <= 0 && toxicityEntries[i].dormantTox <= 0 )
				return i;
		}
		
		return -1;
	}
	
	private function UpdateEntries( dt : float )
	{
		var idx : int;
		
		do
		{
			idx = FindInertElement();
			//Kolaris - Assimilation
			if( idx > -1 )
			{
				toxicityEntries.Erase(idx);
				if( witcher.HasAbility('Glyphword 48 _Stats', true) )
					((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(toxicityEntries.Size());
			}
		}
		while(idx > -1)
	}
	
	private function GetResidualToxicityDegen( toxicityOffset : float ) : float
	{
		var i : int;
		var drainVal, toxicity : float;
		
		toxicity = witcher.GetStat(BCS_Toxicity, true);
		for(i=0; i<toxicityEntries.Size(); i+=1)
			toxicity -= toxicityEntries[i].activeTox + toxicityEntries[i].dormantTox;
			
		drainVal = toxicity / 10.f;
		//effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
		
		drainVal = toxicityOffset / 10.f;
		//drainVal *= 1.f + witcher.GetMasterMutationStage() * 0.1f; //Kolaris - Mutation Rework
		drainVal *= Options().GetToxicityResidualDegenMult();
		
		return drainVal;
	}
	
	//Kolaris - Toxicity Rework
	public function GetToxicityDrain() : float
	{
		var drainVal, drainValMult : float;
		var toxicityDrain : SAbilityAttributeValue;
		
		toxicityDrain = witcher.GetAttributeValue('toxicity_drain');
		//Kolaris - Ofieri Set
		if( witcher.IsSetBonusActive(EISB_Ofieri) )
			toxicityDrain.valueMultiplicative += 0.1f * Combat().GetOfieriSetBonusCount("binding");
		drainValMult = 1.f + toxicityDrain.valueMultiplicative;
		//drainValMult += witcher.GetMasterMutationStage() * 0.1; //Kolaris - Mutation Rework
		drainValMult += witcher.GetSkillLevel(S_Alchemy_s17) * 0.1f;
		//Kolaris - Constitution
		if( witcher.HasBuff(EET_WellHydrated) && (witcher.HasAbility('Glyphword 44 _Stats', true) || witcher.HasAbility('Glyphword 45 _Stats', true)) )
			drainValMult += 0.2f;
		//Kolaris - Assimilation
		if( witcher.HasAbility('Glyphword 48 _Stats', true) )
			drainValMult += 0.05f * toxicityEntries.Size();
		if( witcher.HasBuff(EET_AlbedoDominance) )
			drainValMult += 0.5f + 0.1f * witcher.GetSkillLevel(S_Alchemy_s02);
		//Kolaris - Maribor
		if( witcher.HasBuff(EET_MariborForest) && witcher.GetPotionBuffLevel(EET_MariborForest) == 3 && witcher.GetStatPercents(BCS_Focus) >= 0.99f )
			drainValMult += 0.5f;
		//Kolaris - Mutation Rework
		if( FactsQuerySum("TaFtSComplete") > 0 && (witcher.GetEquippedMutationType() == EPMT_Mutation4 || witcher.GetEquippedMutationType() == EPMT_Mutation5 || witcher.GetEquippedMutationType() == EPMT_Mutation10) )
			drainValMult += 0.5f;
		drainVal = -0.2f * drainValMult;
		if( witcher.GetCurrentStateName() == 'W3EEMeditation' )
			drainVal *= 5.f;
		if( toxicityEntries.Size() == 0 && !witcher.HasBuff(EET_Poison) && Options().GetToxicityResidualDegenMult() > 0 )
			drainVal *= Options().GetToxicityResidualDegenMult();
		if( Options().GetToxicityActiveDegenMult() > 0 )
			drainVal *= Options().GetToxicityActiveDegenMult();
		drainVal *= MaxF(0.1f, witcher.GetStat(BCS_Toxicity, false) / witcher.GetStatMax(BCS_Toxicity));
		//Kolaris - Difficulty Settings
		drainVal /= Options().GetDifficultySettingMod();
		//Kolaris - Assimilation
		if( 0.001f >= GetToxicityGain(true) && witcher.GetCurrentStateName() != 'W3EEMeditation' && (witcher.HasAbility('Glyphword 46 _Stats', true) || witcher.HasAbility('Glyphword 47 _Stats', true) || witcher.HasAbility('Glyphword 48 _Stats', true)) )
			drainVal = 0;
		
		return drainVal;
	}
	
	public function GetToxicityGain(optional displayOnly : bool) : float
	{
		var i : int;
		var gainVal, resistPts, resistPerc : float;
		
		gainVal = 0;
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].effectType == EET_Swallow && witcher.GetPotionBuffLevel(EET_Swallow) == 3 && witcher.GetStatPercents(BCS_Vitality) > 0.99f)
				continue;
			else
			if( toxicityEntries[i].effectType == EET_TawnyOwl && witcher.GetPotionBuffLevel(EET_TawnyOwl) == 3 && GetDayPart(GameTimeCreate()) == EDP_Midnight )
				continue;
			else
			{
				gainVal += toxicityEntries[i].totalTox / toxicityEntries[i].duration;
				if( !displayOnly )
					toxicityEntries[i].activeTox -= toxicityEntries[i].totalTox / toxicityEntries[i].duration;
			}
		}
		
		if( witcher.HasBuff(EET_Poison) )
		{
			witcher.GetResistValue(CDS_PoisonRes, resistPts, resistPerc);
			gainVal += 0.5 * ((W3Effect_Poison)witcher.GetBuff(EET_Poison)).GetStacks() * (1.f - resistPerc);
		}
		
		return gainVal;
	}
}
