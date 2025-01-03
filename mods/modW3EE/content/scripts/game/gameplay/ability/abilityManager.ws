/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




import abstract class W3AbilityManager extends IScriptable
{
	import var owner : CActor;												
	import var usedHealthType : EBaseCharacterStats;						
	import var charStats : CCharacterStats;									
	import saved var usedDifficultyMode : EDifficultyMode;					
	import var difficultyAbilities : array< array< name > >;				
	import var ignoresDifficultySettings : bool;							
	private var overhealBonus : float;
	
	protected var isInitialized : bool;										
	default isInitialized = false;											
	import protected saved var blockedAbilities : array<SBlockedAbility>;	
	
	

	import final function CacheStaticScriptData();
	import final function SetInitialStats( diff : EDifficultyMode ) : bool;
	import final function FixInitialStats( diff : EDifficultyMode ) : bool;
	
	import final function HasStat( stat : EBaseCharacterStats ) : bool;
	import final function StatAddNew( stat : EBaseCharacterStats, optional max : float );
	import final function RestoreStat( stat : EBaseCharacterStats );
	import final function RestoreStats();
	import		 function GetStat( stat : EBaseCharacterStats, optional skipLock : bool ) : float;
	import final function GetStatMax( stat : EBaseCharacterStats ) : float;
	import final function GetStatPercents( stat : EBaseCharacterStats ) : float;
	import final function GetStats( stat : EBaseCharacterStats, out current : float, out max : float ) : bool;
	import final function SetStatPointCurrent( stat : EBaseCharacterStats, val : float );
	import final function SetStatPointMax( stat : EBaseCharacterStats, val : float );
	import final function UpdateStatMax( stat : EBaseCharacterStats );
	
	import final function HasResistStat( stat : ECharacterDefenseStats ) : bool;
	import final function GetResistStat( stat : ECharacterDefenseStats, out resistStat: SResistanceValue ) : bool;
	import final function SetResistStat( stat : ECharacterDefenseStats, out resistStat: SResistanceValue );
	import final function ResistStatAddNew( stat : ECharacterDefenseStats );
	import		 function RecalcResistStat( stat : ECharacterDefenseStats );
	
	import		 function GetAttributeValueInternal( attributeName : name, optional tags : array< name > ) : SAbilityAttributeValue;
	
	import final function CacheDifficultyAbilities();
	import final function UpdateStatsForDifficultyLevel( diff : EDifficultyMode );
	import final function UpdateDifficultyAbilities( diff : EDifficultyMode );
	
	
	import final function GetAllStats_Debug( out stats : array< SBaseStat > ) : bool;
	import final function GetAllResistStats_Debug( out stats : array< SResistanceValue > ) : bool;

	
	public function PostInit();
		
	import private function SetCharacterStats( cStats : CCharacterStats ); 
	
	public function Init(ownr : CActor, cStats : CCharacterStats, isFromLoad : bool, diff : EDifficultyMode) : bool
	{
		var abs : array<name>;
		var i : int;
		var dm : CDefinitionsManagerAccessor;

		isInitialized = false;		
		difficultyAbilities.Clear();
		ignoresDifficultySettings = false;
		
		CacheStaticScriptData();
		SetCharacterStats( cStats );
		
		owner = ownr;
		dm = theGame.GetDefinitionsManager();
				
		
		cStats.GetAbilities(abs);
		for(i=0; i<abs.Size(); i+=1)
		{
			if(dm.AbilityHasTag(abs[i], theGame.params.DIFFICULTY_TAG_IGNORE))
			{
				ignoresDifficultySettings = true;
				break;
			}
		}
		
		
		if(!ignoresDifficultySettings)
			difficultyAbilities.Resize(EnumGetMax('EDifficultyMode')+1);
		
		
		if(!isFromLoad)
		{
			usedDifficultyMode = EDM_NotSet;
			
			if(!SetInitialStats(diff))
				return false;
		}
		else
		{
			if ( !FixInitialStats(diff) )
			{
				if(!ignoresDifficultySettings)
				{
					CacheDifficultyAbilities();
				}
			}
		}
		
		
		
		
		if(!ignoresDifficultySettings && usedDifficultyMode != diff)
		{
			UpdateStatsForDifficultyLevel(diff);
		}
		
		return true;
	}
	
	public final function IsInitialized() : bool 		{return isInitialized;}
	
	public function OnOwnerRevived()
	{
		var i : int;
		
		RestoreStats();
		
		for(i=blockedAbilities.Size()-1; i>=0; i-=1)
		{
			if(blockedAbilities[i].timeWhenEnabledd > 0)
				blockedAbilities.EraseFast(i);
		}
	}
	
	public final function UsesVitality() : bool
	{
		return usedHealthType == BCS_Vitality;
	}
	
	
	public function UsesEssence() : bool
	{
		return usedHealthType == BCS_Essence;
	}
	
	
	
	
	
	
	protected function CheckForbiddenAttribute(attName : name) : bool
	{
		if( theGame.params.IsForbiddenAttribute(attName) )
		{
			LogAssert(false, "W3AbilityManager.CheckForbiddenAttribute: you are trying to get attribute <<" + attName + ">> in a wrong way - use propper custom function instead!");
			return true;
		}
		
		return false;
	}
	
	
	public function GetAttributeValue(attributeName : name, optional tags : array<name>) : SAbilityAttributeValue
	{
		var val : SAbilityAttributeValue;
	
		// W3EE - Begin
		if(CheckForbiddenAttribute(attributeName) && attributeName != 'spell_power')
		// W3EE - End
		{
			val.valueBase = -9999;
			val.valueAdditive = -9999;
			val.valueMultiplicative = 100;
			return val;
		}
		
		return GetAttributeValueInternal(attributeName, tags);
	}
	
	public function GetAbilityAttributeValue(abilityName : name, attributeName : name) : SAbilityAttributeValue
	{
		var val : SAbilityAttributeValue;
	
		if(CheckForbiddenAttribute(attributeName))
		{
			val.valueBase = -9999;
			val.valueAdditive = -9999;
			val.valueMultiplicative = 100;
			return val;
		}
		
		return charStats.GetAbilityAttributeValue(attributeName, abilityName);
	}
		
	
	
	
	
	protected function GetNonBlockedSkillAbilitiesList(tags : array<name>) : array<name>
	{
		var null : array<name>;
		return null;
	}
	
	
	
	public function CheckBlockedAbilities(dt : float) : float
	{
		var i : int;
		var min : float;
		
		min = 1000000;
		for(i = blockedAbilities.Size()-1; i>=0; i-=1)
		{
			if(blockedAbilities[i].timeWhenEnabledd != -1)
			{
				blockedAbilities[i].timeWhenEnabledd = MaxF(blockedAbilities[i].timeWhenEnabledd - dt, 0);
				
				if(blockedAbilities[i].timeWhenEnabledd == 0)		
				{
					BlockAbility(blockedAbilities[i].abilityName, false);	
				}
				else
				{
					min = MinF(min, blockedAbilities[i].timeWhenEnabledd);
				}
			}
		}
		
		if(min == 1000000)
			min = -1;
			
		return min;
	}
	
	public function BlockAbility(abilityName : name, block : bool, optional cooldown : float) : bool
	{		
		var i : int;
		var ab : SBlockedAbility;
		var min, cnt : float;
		var ret : bool;
				
		if(!IsNameValid(abilityName))
			return false;
		
		//Kolaris - Block Ability Cleanup
		if(block)
		{
			ab.abilityName = abilityName;
			
			if(cooldown > 0)
			{
				ab.timeWhenEnabledd = cooldown;
				min = cooldown;
				for(i=0; i<blockedAbilities.Size(); i+=1)
				{
					if(blockedAbilities[i].timeWhenEnabledd > 0 && blockedAbilities[i].abilityName == abilityName)
					{
						min = MinF(min, blockedAbilities[i].timeWhenEnabledd);
						//theGame.GetGuiManager().ShowNotification("TimeWhenEnabledd: " + blockedAbilities[i].timeWhenEnabledd + "<br>Min: " + min);
					}
				}
				
				owner.AddTimer('CheckBlockedAbilities', min, , , , true);
			}
			else
			{
				ab.timeWhenEnabledd = -1;
			}
			
			
			ab.count = charStats.GetAbilityCount(abilityName);
			
			
			ret = charStats.RemoveAbility(abilityName);
			blockedAbilities.PushBack(ab);
			return ret;
		}
		else
		{
			for(i=0; i<blockedAbilities.Size(); i+=1)
			{
				if(blockedAbilities[i].abilityName == abilityName)
				{
					if(!block)
					{	
						cnt = blockedAbilities[i].count;
						blockedAbilities.Erase(i);					
						if(cnt > 0)									
							charStats.AddAbility(abilityName, cnt);					
						//theGame.GetGuiManager().ShowNotification("Unblocking Ability");
						return true;
					}
					else
					{
						return false;
					}
				}
			}
			
			return false;
		}
	}
	
	import public final function IsAbilityBlocked(abilityName : name) : bool;
		
	
	
	
	
	
	public function GetPowerStatValue(stat : ECharacterPowerStats, optional abilityTag : name) : SAbilityAttributeValue
	{
		var tags : array<name>;
		
		if(IsNameValid(abilityTag))
			tags.PushBack(abilityTag);
		// W3EE - Begin
/*		if ( stat == CPS_Spellpower )
		{
			(GetAttributeValueInternal(PowerStatEnumToName(stat), tags)).valueAdditive /= 2;
			(GetAttributeValueInternal(PowerStatEnumToName(stat), tags)).valueMultiplicative /= 2;
			return GetAttributeValueInternal(PowerStatEnumToName(stat), tags);
		}*/
		/*else */return GetAttributeValueInternal(PowerStatEnumToName(stat), tags);
		// W3EE - End
	}
	
	
	protected function MutliplyStatBy(stat : EBaseCharacterStats, val : float)
	{
		if(val > 0)
			SetStatPointCurrent(stat, MinF(val * GetStat(stat, true), GetStatMax(stat) ) );
	}
	
	
	public function GetResistValue(stat : ECharacterDefenseStats, out points : float, out percents : float)
	{
		var pts, prc, charPts, charPerc : SAbilityAttributeValue;
		var resistStat : SResistanceValue; 
		
		if ( GetResistStat( stat, resistStat ) )
		{
			charPts = resistStat.points;
			charPerc = resistStat.percents;		
		}
		
		points = CalculateAttributeValue(charPts);
		percents = MinF(1, CalculateAttributeValue(charPerc));		
		return;
	}
	
	
	public final function UsedHPType() : EBaseCharacterStats
	{
		return usedHealthType;
	}
	
		
	public final function ForceSetStat( stat : EBaseCharacterStats, val : float )
	{
		var prev : float;
			
		prev = GetStat(stat);
		SetStatPointCurrent(stat, MinF(GetStatMax(stat), MaxF(0, val)) );
		
		if(prev != GetStat(stat))
		{
			if( stat == BCS_Vitality )
			{
				OnVitalityChanged();				
			}
			else if( stat == BCS_Toxicity )
			{
				OnToxicityChanged();
			}
			else if( stat == BCS_Focus )
			{
				OnFocusChanged();
			}
			else if( stat == BCS_Air )
			{
				OnAirChanged();
			}
			else if( stat == BCS_Essence )
			{
				OnEssenceChanged();
			}
		}
	}
	
	
	protected final function InternalReduceStat(stat : EBaseCharacterStats, amount : float)
	{
		SetStatPointCurrent(stat, MaxF( 0, GetStat(stat, true) - MaxF( 0, amount ) ) );
	}
	
	public final function DrainAir(cost : float, optional delay : float )
	{
		
		if(cost > 0)
		{			
			InternalReduceStat(BCS_Air, cost);
			owner.StartAirRegen();
		}
		
		
		if(delay > 0)
			owner.PauseEffects(EET_AutoAirRegen, 'AirCostDelay', false, delay);		
	}
	
	public final function DrainSwimmingStamina(cost : float, optional delay : float )
	{
		if(cost > 0)
		{			
			InternalReduceStat(BCS_SwimmingStamina, cost);
			owner.StartSwimmingStaminaRegen();
		}
		
		
		if(delay > 0)
			owner.PauseEffects(EET_AutoSwimmingStaminaRegen, 'SwimmingStaminaCostDelay', false, delay);		
	}
	
	
	public function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float) : float
	{
		var cost, delay : float;
		
		GetStaminaActionCost(action, cost, delay, fixedCost, fixedDelay, abilityName, dt, costMult);
		
		//Kolaris - Stamina Options, Kolaris - Mutation 5
		if( owner == GetWitcherPlayer() )
		{
			if( GetWitcherPlayer().IsMutationActive(EPMT_Mutation5) && cost > 0 )
				Combat().Mutation5DrainToxFromStamina(cost);
			if( Options().StamCostGlobal() > 0 )
				cost *= Options().StamCostGlobal();
		}

		
		if(cost > 0)
		{
			InternalReduceStat(BCS_Stamina, cost);
			owner.StartStaminaRegen();
		}
		
		if(delay > 0)
		{
			if(IsNameValid(abilityName))
				owner.PauseStaminaRegen( abilityName, delay );
			else
				owner.PauseStaminaRegen( StaminaActionTypeToName(action), delay );
		}
		
		return cost;
	}
	
	public function GetStaminaActionCost(action : EStaminaActionType, out cost : float, out delay : float, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float)
	{
		var costAtt, delayAtt : SAbilityAttributeValue;
		
		if(action == ESAT_FixedValue)
		{
			cost = fixedCost;
			delay = MaxF(0, fixedDelay);
		}
		else
		{
			GetStaminaActionCostInternal(action, dt > 0.0f, costAtt, delayAtt, abilityName);
			cost = CalculateAttributeValue(costAtt);
			delay = CalculateAttributeValue(delayAtt);
		}
		
		//Kolaris - Injury Effects
		if( ((CNewNPC)owner).GetInjuryManager().HasInjury(EFI_Arms) || ((CNewNPC)owner).GetInjuryManager().HasInjury(EPI_Arms) )
		{
			if( action == ESAT_LightAttack || action == ESAT_HeavyAttack || action == ESAT_SuperHeavyAttack || action == ESAT_Counterattack )
				cost *= 1.2f;
		}
		
		if(costMult != 0)
		{
			cost *= costMult;
		}
		
		if(dt > 0)
		{			
			cost *= dt;
		}
	}
	
	protected function GetStaminaActionCostInternal(action : EStaminaActionType, isPerSec : bool, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, optional abilityName : name)
	{
		var costAttributeName, delayAttributeName, attribute : name;
		var tags : array<name>;
		var val : SAbilityAttributeValue;
	
		
		cost = val;
		delay = val;
	
		theGame.params.GetStaminaActionAttributes(action, isPerSec, costAttributeName, delayAttributeName);
		
		
		if(action == ESAT_Ability)
		{
			if(isPerSec)
				attribute = theGame.params.STAMINA_COST_PER_SEC_DEFAULT;
			else 
				attribute = theGame.params.STAMINA_COST_DEFAULT;
				
			cost = GetSkillAttributeValue(abilityName, attribute, false, true);
			delay = GetSkillAttributeValue(abilityName, theGame.params.STAMINA_DELAY_DEFAULT, false, true);
		}
		// W3EE - Begin
		else
		if( action == ESAT_Parry )
		{
			cost = owner.GetAttributeValue( 'parry_stamina_cost' );
			delay.valueBase = 0.5f;
			delay.valueMultiplicative = 1.f;
		}
		else
		if( action == ESAT_Counterattack )
		{
			cost = owner.GetAttributeValue( 'counter_stamina_cost' );
			delay.valueBase = 0.5f;
			delay.valueMultiplicative = 1.f;
		}
		// W3EE - End
		else
		{
			cost = GetAttributeValueInternal(costAttributeName);
			delay = GetAttributeValueInternal(delayAttributeName);
		}
		cost += GetAttributeValueInternal('stamina_cost_modifier');
		delay += GetAttributeValueInternal('stamina_delay_modifier');
	}
	
    public function DrainVigor( abilityName : name, optional dt : float, optional costMult : float, optional overrideValue : float, optional forceDrain : bool ) : bool
    {
        var cost, delay, curVigor: float;
        var ret : bool;
        
        curVigor = GetStat(BCS_Focus);
		GetVigorActionCost(cost, delay, abilityName, dt, costMult, overrideValue, forceDrain);
		
		ret = true;
        if( cost <= curVigor || (cost > curVigor && forceDrain) )
        {
            InternalReduceStat(BCS_Focus, cost);
            if( cost > curVigor )
				ret = false;
        }
        else
			return false;
			
		OnFocusChanged();
        if( delay )
			GetWitcherPlayer().StartRegenTimer(delay);
			
        return ret;
    }

    public function GetVigorActionCost( out cost : float, out delay : float, abilityName : name, optional dt : float, optional costMult : float, optional overrideValue : float, optional forceDrain : bool ) : float
    {
        var costAttr, delayAttr : SAbilityAttributeValue;
        
		GetVigorActionCostInternal(dt > 0.f, costAttr, delayAttr, abilityName);
		cost = CalculateAttributeValue(costAttr);
		delay = CalculateAttributeValue(delayAttr);
        
        if( forceDrain )
			cost = overrideValue;
			
        cost *= costMult;
        if( dt )
            cost *= dt;
			
        return cost;
    }
    
    protected function GetVigorActionCostInternal( perSec : bool, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, abilityName : name )
    {
        var attributeName : name;
        
        if( perSec )
            attributeName = 'vigor_cost_per_sec';
        else
            attributeName = 'vigor_cost';
            
        cost = GetSkillAttributeValue(abilityName, attributeName, false, true);
        delay = GetSkillAttributeValue(abilityName, 'vigor_delay', false, true);
        
        cost += GetAttributeValueInternal('vigor_cost_modifier');
        delay += GetAttributeValueInternal('vigor_delay_modifier');
    }
	
	public function GetSkillAttributeValue(abilityName: name, attributeName : name, addBaseCharAttribute : bool, addSkillModsAttribute : bool) : SAbilityAttributeValue
	{
		var min, max :SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, attributeName, min, max);
		return GetAttributeRandomizedValue(min, max);
	}
	
	// W3EE - Begin
	public final function DrainFocus(amount : float, optional dt : float )
	{		
		if ( dt > 0 )
			InternalReduceStat(BCS_Focus, amount * dt);
		else InternalReduceStat(BCS_Focus, amount);
	}
	// W3EE - End
	
	public final function DrainMorale(amount : float )
	{
		InternalReduceStat(BCS_Morale, amount);
		owner.StartMoraleRegen();
	}
	
	public final function DrainToxicity(amount : float )
	{
		InternalReduceStat(BCS_Toxicity, amount);
		OnToxicityChanged();
	}
	
	
	public final function DrainVitality(amount : float)
	{	
		SetStatPointCurrent(BCS_Vitality, MaxF( 0, GetStat(BCS_Vitality) - MaxF(0, amount) ));
		owner.StartVitalityRegen();
		
		if(GetStat(BCS_Vitality) <= 0 && UsesVitality())
		{
			owner.SignalGameplayEvent( 'Death' );
			owner.SetAlive(false);
		}
		
		OnVitalityChanged();
	}
	
	
	public final function DrainEssence(amount : float)
	{
		SetStatPointCurrent(BCS_Essence, MaxF( 0, GetStat(BCS_Essence) - MaxF(0, amount) ) );
		owner.StartEssenceRegen();
		
		if(GetStat(BCS_Essence) <= 0 && UsesEssence())
		{
			owner.SignalGameplayEvent( 'Death' );
			owner.SetAlive(false);
		}
		
		OnEssenceChanged();
	}
	
	public final function AddPanic( amount : float )
	{
		SetStatPointCurrent( BCS_Panic, RoundF(MaxF( 0, GetStat( BCS_Panic ) - amount )) );
		owner.StartPanicRegen();
	}
	
	
	public function GainStat( stat : EBaseCharacterStats, amount : float )
	{
		var statWithoutLock, statWithLock, lock, max : float;
		var hadOverheal : bool;
		var mi, ma : SAbilityAttributeValue;
		
		statWithoutLock = GetStat(stat, true);
		statWithLock = GetStat(stat, false);
		lock = statWithLock - statWithoutLock;
		max = GetStatMax(stat);
		
		// W3EE - Begin
		if( stat != BCS_Vitality )
			SetStatPointCurrent(stat, MinF( max - lock, statWithoutLock + MaxF(0, amount) ) );
		else
			SetStatPointCurrent(stat, MinF(max, statWithLock + MaxF(0, amount)));
		// W3EE - End
		
		if( stat == BCS_Vitality )
		{
			OnVitalityChanged();
			// W3EE - Begin
			/*
			if ( (W3PlayerAbilityManager)this && owner == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats') && GetWitcherPlayer().IsInCombat() && (statWithoutLock + amount) > max )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 4 _Stats', 'max_bonus', mi, ma);				
				hadOverheal = (overhealBonus > (0.005 * GetStatMax(BCS_Vitality)));
				overhealBonus += (statWithoutLock + amount) - GetStatMax(stat);
				overhealBonus = MinF(overhealBonus, max * ma.valueMultiplicative);
				thePlayer.PlayRuneword4FX();				
			}
			*/
			// W3EE - End
		}
		else if( stat == BCS_Toxicity )
			OnToxicityChanged();
		//Kolaris - Regeneration
		else if( stat == BCS_Essence )
			OnEssenceChanged();
		else if( stat == BCS_Focus )
		{
			OnFocusChanged();
			if( (W3PlayerAbilityManager)this && owner == GetWitcherPlayer() && amount > 1.f && (statWithoutLock + amount) > max && (GetWitcherPlayer().HasAbility('Glyphword 37 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 38 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 39 _Stats', true)) )
				GetWitcherPlayer().GainStat(BCS_Vitality, ((statWithoutLock + amount) - GetStatMax(stat)) * 200.f);
				//theGame.GetGuiManager().ShowNotification("Vitality Gained from Vigor: " + ((statWithoutLock + amount) - GetStatMax(stat)) * 200.f);
		}
		else if( stat == BCS_Stamina )
		{
			if( (W3PlayerAbilityManager)this && owner == GetWitcherPlayer() && amount > 1.f && (statWithoutLock + amount) > max && (GetWitcherPlayer().HasAbility('Glyphword 37 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 38 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 39 _Stats', true)) )
				GetWitcherPlayer().GainStat(BCS_Vitality, ((statWithoutLock + amount) - GetStatMax(stat)) * 2.f / Options().StamCostGlobal());
				//theGame.GetGuiManager().ShowNotification("Vitality Gained from Stamina: " + ((statWithoutLock + amount) - GetStatMax(stat)) * 2.f / Options().StamCostGlobal());
		}
	}
	
	public final function IgnoresDifficultySettings() : bool
	{
		return ignoresDifficultySettings;
	}
	
	
	
	
	
	protected function OnVitalityChanged();
	protected function OnEssenceChanged();
	protected function OnToxicityChanged();
	// W3EE - Begin
	protected function OnFocusChanged();
	// W3EE - End
	protected function OnAirChanged();
	
	
	public function OnAbilityAdded( abilityName : name )
	{
		OnAbilityChanged( abilityName );
	}
	
	
	public function OnAbilityRemoved( abilityName : name )
	{
		// W3EE - Begin
		/*
		if( abilityName == 'Runeword 4 _Stats' )
		{
			ResetOverhealBonus();
		}
		*/
		// W3EE - End
		
		OnAbilityChanged( abilityName );
	}
	
	
	protected function OnAbilityChanged( abilityName : name )
	{
		var atts, tags : array<name>;
		var attribute : name;
		var i,size,stat, j : int;
		var oldMax, maxVit, maxEss : float;
		var resistStatChanged, tmpBool : bool;
		var dm : CDefinitionsManagerAccessor;
		var val : SAbilityAttributeValue;
		var buffs : array<CBaseGameplayEffect>;
		var regenBuff : W3RegenEffect;
		
		if(!owner)
			return;		
				
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, atts);		
		resistStatChanged = false;
		size = atts.Size();
		
		
		if(dm.AbilityHasTag(abilityName, theGame.params.DIFFICULTY_TAG_IGNORE))
		{
			ignoresDifficultySettings = true;
			difficultyAbilities.Clear();
			usedDifficultyMode = EDM_NotSet;
		}
		
		for(i=0; i<size; i+=1)
		{					
			attribute = atts[ i ];
			if ( ( attribute == 'vitality' && UsesEssence() )
				|| ( attribute == 'essence' && UsesVitality() ) )
			{
				continue;
			}
		
			
			
			stat = StatNameToEnum( attribute );
			if(stat != BCS_Undefined)
			{
				if(!HasStat(stat))
				{
					
					StatAddNew(stat);
				}
				else
				{
					
					if(abilityName == theGame.params.GLOBAL_ENEMY_ABILITY || abilityName == theGame.params.GLOBAL_PLAYER_ABILITY || abilityName == theGame.params.ENEMY_BONUS_PER_LEVEL)
					{
						
						UpdateStatMax(stat);
						RestoreStat(stat);
					}
					else
					{
						
						oldMax = GetStatMax(stat);
						UpdateStatMax(stat);
						MutliplyStatBy(stat, GetStatMax(stat) / oldMax);
					}
				}
				continue;
			}
			
			
			stat = ResistStatNameToEnum(attribute, tmpBool);
			if(stat != CDS_None)
			{
				if ( HasResistStat( stat ) )
				{
					RecalcResistStat(stat);
					resistStatChanged = true;
				}								
				else
				{
					
					ResistStatAddNew(stat);
				}
				
				continue;
			}
			
			
			stat = RegenStatNameToEnum(attribute);
			if(stat != CRS_Undefined && stat != CRS_UNUSED)
			{
				buffs = owner.GetBuffs();
				
				for(j=0; j<buffs.Size(); j+=1)
				{
					regenBuff = (W3RegenEffect)buffs[j];
					if(regenBuff)
					{
						if(regenBuff.GetRegenStat() == stat && IsBuffAutoBuff(regenBuff.GetEffectType()))
						{
							regenBuff.UpdateEffectValue();
							break;
						}
					}
				}
				if( stat == CRS_Essence )
				{
					owner.StartEssenceRegen();
				}
			}
			
			
			if(!ignoresDifficultySettings && attribute == theGame.params.DIFFICULTY_HP_MULTIPLIER)
			{		
				

				maxVit = GetStatMax( BCS_Vitality );
				maxEss = GetStatMax( BCS_Essence );
				if(maxVit > 0)
				{
					oldMax = maxVit;
					UpdateStatMax(BCS_Vitality);					
					MutliplyStatBy(BCS_Vitality, GetStatMax(BCS_Vitality) / oldMax);
				}
				
				if(maxEss > 0)
				{
					oldMax = maxEss;
					UpdateStatMax(BCS_Essence);					
					MutliplyStatBy(BCS_Essence, GetStatMax(BCS_Essence) / oldMax);
				}
				
				continue;
			}		
		}
		
		if(resistStatChanged)
		{
			owner.RecalcEffectDurations();
		}
	}
	
	
	
	
	public final function GetOverhealBonus() : float
	{
		return overhealBonus;
	}
	
	public final function ResetOverhealBonus()
	{
		overhealBonus = 0;
		//Kolaris - Destruction
		//thePlayer.StopEffect('runeword_4');
	}
	
	
	
	
	
	public final function Debug_GetUsedDifficultyMode() : EDifficultyMode
	{
		return usedDifficultyMode;
	}
}
