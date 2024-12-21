class W3EEAbilityHandler
{
	private var activeWeather : SWeatherBonus;
	private var owner : CNewNPC;
	private var activateQueue, removeQueue : array<name>;
	
	public function Init( NPC : CNewNPC )
	{				
		owner = NPC;
		
		owner.AddTimer('RefreshWeatherBonus', 20.f, true);
		
		ModifyWeatherBonus();
	}
	
	public function ModifyWeatherBonus()
	{
		var i : int;
		
		activeWeather.dayPart = GetDayPart(GameTimeCreate());
		activeWeather.moonState  = GetCurMoonState();
		activeWeather.weather = GetCurWeather();
		
		SetWeatherQueues();
		
		for( i=0; i<removeQueue.Size(); i+=1 )
			ApplyWeatherBonus(removeQueue[i], true);
		removeQueue.Clear();
		
		for( i=0; i<activateQueue.Size(); i+=1 )
			ApplyWeatherBonus(activateQueue[i], false);
		activateQueue.Clear();
	}
	
	private function SetWeatherQueues()
	{
		var i : int;
		
		for(i=0; i<owner.weatherAbilities.Size(); i+=1)
		{
			if( (owner.weatherAbilities[i].dayPart == activeWeather.dayPart || owner.weatherAbilities[i].dayPart == EDP_Undefined) && (owner.weatherAbilities[i].weather == activeWeather.weather || owner.weatherAbilities[i].weather == EWE_Any) && (owner.weatherAbilities[i].moonState == activeWeather.moonState || owner.weatherAbilities[i].moonState == EMS_Any) && !owner.IsInInterior() )
			{
				if( owner.weatherAbilities[i].isActive == false )
				{
					activateQueue.PushBack(owner.weatherAbilities[i].ability);
					owner.weatherAbilities[i].isActive = true;
				}
			}
			else
			if( owner.weatherAbilities[i].isActive == true )
			{
				removeQueue.PushBack(owner.weatherAbilities[i].ability);
				owner.weatherAbilities[i].isActive = false;
			}
		}
	}
	
	private function ApplyWeatherBonus( abilityName : name, remove : bool )
    {
        var attributes : array<name>;
        var attributeValue, temp : SAbilityAttributeValue;
        var dm : CDefinitionsManagerAccessor;
        var i : int;
       
        dm = theGame.GetDefinitionsManager();
        dm.GetAbilityAttributes(abilityName, attributes);
		
        for(i=0; i<attributes.Size(); i+=1)
        {
            dm.GetAbilityAttributeValue(abilityName, attributes[i], attributeValue, temp);
            ModifyActorStats(attributes[i], attributeValue, remove);
        }
    }

	private function ModifyResistance( out npcStat : float, by : float )
	{
		if( npcStat == 1.f )
			return;
		else
			npcStat += by;
	}
	
	private function ModifyActorStats( abilityName : name, attributeValue : SAbilityAttributeValue, remove : bool )
	{
		var mod, adjustmentMult, adjustmentValue, currPerc : float;
		
		if( remove )
			mod = -1.f;
		else
			mod = 1.f;
			
		switch(abilityName)
		{
			case 'poise_value':			ModifyResistance(owner.npcStats.poiseValue,			attributeValue.valueAdditive * mod);
			break;
			case 'physical_resist':		ModifyResistance(owner.npcStats.physicalResist, 	attributeValue.valueAdditive * mod);
			break;
			case 'force_resist':		ModifyResistance(owner.npcStats.forceResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'frost_resist':		ModifyResistance(owner.npcStats.frostResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'fire_resist':			ModifyResistance(owner.npcStats.fireResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'shock_resist':		ModifyResistance(owner.npcStats.shockResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'elemental_resist':	ModifyResistance(owner.npcStats.elementalResist,	attributeValue.valueAdditive * mod);
			break;
			case 'slow_resist':			ModifyResistance(owner.npcStats.slowResist, 	 	attributeValue.valueAdditive * mod);
			break;
			case 'confusion_resist':	ModifyResistance(owner.npcStats.confusionResist, 	attributeValue.valueAdditive * mod);
			break;
			case 'bleeding_resist':		ModifyResistance(owner.npcStats.bleedingResist, 	attributeValue.valueAdditive * mod);
			break;
			case 'poison_resist':		ModifyResistance(owner.npcStats.poisonResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'stun_resist':			ModifyResistance(owner.npcStats.stunResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'injury_resist':		ModifyResistance(owner.npcStats.injuryResist,  		attributeValue.valueAdditive * mod);
			break;
			case 'armor_piercing':		ModifyResistance(owner.npcStats.armorPiercing,		attributeValue.valueAdditive * mod);
			break;
			
			
			case 'health_regen_factor':	owner.npcStats.healthRegenFactor 	+= attributeValue.valueAdditive * mod;
			break;
			case 'regen_delay':			owner.npcStats.regenDelay 			+= attributeValue.valueAdditive * mod;
			break;
			
			
			case 'health_perc':
				//currPerc = ClampF(1.f * (owner.abilityManager.GetStatPercents(BCS_Vitality) +  owner.abilityManager.GetStatPercents(BCS_Essence)), 0.f, 1.f);
				
				if( remove )
					owner.npcStats.healthValue /= 1.f + attributeValue.valueAdditive;
				else
					owner.npcStats.healthValue *= 1.f + attributeValue.valueAdditive;
				 /*
				if( owner.npcStats.healthType == BCS_Essence )
					owner.abilityManager.SetStatPointCurrent(BCS_Essence,	(owner.abilityManager.GetStatMax(BCS_Essence)  * currPerc) );
				else
					owner.abilityManager.SetStatPointCurrent(BCS_Vitality,	(owner.abilityManager.GetStatMax(BCS_Vitality) * currPerc) );
				*/
			break;

			case 'damage_dealt_perc':
				if( remove )
					owner.npcStats.damageValue 	/= 1.f + attributeValue.valueAdditive;
				else
					owner.npcStats.damageValue 	*= 1.f + attributeValue.valueAdditive;
			break;

			case 'damage_taken_perc':
				if( remove )
					owner.SetDamageTakenMultiplier(1.f);
				else
					owner.SetDamageTakenMultiplier(1.f + attributeValue.valueAdditive);
			break;
			
			case 'speed_perc':
				adjustmentValue = 1.f + attributeValue.valueAdditive;
				if( remove )
					owner.ResetAnimationSpeedMultiplier(owner.npcStats.spdMultID3);
				else					
					owner.npcStats.spdMultID3 = owner.SetAnimationSpeedMultiplier(adjustmentValue, owner.npcStats.spdMultID3);
			break;

			case 'stamina_perc':
				if( remove )
					owner.abilityManager.SetStatPointMax(BCS_Stamina, (owner.abilityManager.GetStatMax(BCS_Stamina) / (1.f + attributeValue.valueAdditive)) );
				else
					owner.abilityManager.SetStatPointMax(BCS_Stamina, (owner.abilityManager.GetStatMax(BCS_Stamina) * (1.f + attributeValue.valueAdditive)) );
				/*currPerc = ClampF(owner.abilityManager.GetStatPercents(BCS_Stamina), 0, 1);
				adjustmentValue = attributeValue.valueAdditive * mod;
				owner.abilityManager.SetStatPointMax(BCS_Stamina, (owner.abilityManager.GetStatMax(BCS_Stamina) + adjustmentValue) );*/
			break;

			case 'inc_burn_counter':
				owner.IncBurnCounter(attributeValue.valueAdditive * mod);
			break;
			
			/* not working correctly
			case 'add_health_regen_timer':
				if( remove )
				{
					owner.RemoveTimer('AddHealthRegenEffect');
					owner.RemoveBuff(EET_HealthRegen, true, "W3EEHealthRegen");
				}
				else
					owner.AddTimer('AddHealthRegenEffect', attributeValue.valueAdditive, false);
			break;
			*/
				
			default: break;
		}
	}
}