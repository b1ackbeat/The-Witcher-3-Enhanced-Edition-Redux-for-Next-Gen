/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

enum EHairType
{
	EHT_Preview,
	EHT_HalfTail,
	EHT_ShavedTail,
	EHT_LongLoose,
	EHT_ShortLoose,
	EHT_Mohawk,
	EHT_Nilfgaard
}

struct SArmorCount
{
	var all : int;
	var upper : int;
};

class W3EEEquipmentHandler extends W3EEOptionHandler
{
	public final function LevelRequirementIndicator( out colour : string, itemId : SItemUniqueId, Inv : CInventoryComponent )
	{
		var checkLevel : int;
		
		checkLevel = thePlayer.GetLevel();
		
		if(thePlayer.HasBuff(EET_WolfHour))
			checkLevel += 2;
		
		if ( Inv.GetItemLevel(itemId) <= checkLevel ) 
			colour = "<font color = '#66FF66'>";	
		else
			colour = "<font color = '#9F1919'>";
	}
	
	public final function LevelRequirementIndicator2( out colour : string, lvl_item : int, Inv : CInventoryComponent )
	{
		var checkLevel : int;
		
		checkLevel = thePlayer.GetLevel();
		
		if(thePlayer.HasBuff(EET_WolfHour))
			checkLevel += 2;
		
		if ( lvl_item > checkLevel ) 
			colour = "<font color = '#9F1919'>";
		else
			colour = "<font color = '#66FF66'>";
	}
	
	public final function LevelRequirements( item : SItemUniqueId, inv : CInventoryComponent ) : bool
	{
		return true;
	}
	
	public final function UnableToEquip( out flashObject : CScriptedFlashObject, inv : CInventoryComponent, item : SItemUniqueId ) 
	{
	}
	
	private function HairTypeToName( hairType : EHairType ) : name
	{
		switch(hairType)
		{
			case EHT_Preview:		return 'Preview Hair';
			case EHT_HalfTail:		return 'Half With Tail Hairstyle';
			case EHT_ShavedTail:	return 'Shaved With Tail Hairstyle';
			case EHT_LongLoose:		return 'Long Loose Hairstyle';
			case EHT_ShortLoose:	return 'Short Loose Hairstyle';
			case EHT_Mohawk:		return 'Mohawk With Ponytail Hairstyle';
			case EHT_Nilfgaard:		return 'Nilfgaardian Hairstyle';
			default:	return 'Preview Hair';
		}
	}
	
	private function HairNameToType( hairName : name ) : EHairType
	{
		switch(hairName)
		{
			case 'Preview Hair':					return EHT_Preview;
			case 'Half With Tail Hairstyle':		return EHT_HalfTail;
			case 'Shaved With Tail Hairstyle':		return EHT_ShavedTail;
			case 'Long Loose Hairstyle':			return EHT_LongLoose;
			case 'Short Loose Hairstyle':			return EHT_ShortLoose;
			case 'Mohawk With Ponytail Hairstyle':	return EHT_Mohawk;
			case 'Nilfgaardian Hairstyle':			return EHT_Nilfgaard;
			default :	return EHT_Preview;
		}
	}
	
	public function GatherHerbs()
	{
		var herbs : array<CGameplayEntity>;
		var i : int;
		
		FindGameplayEntitiesInRange(herbs, GetWitcherPlayer(), Options().AreaLootingRadius(), 30,, FLAG_ExcludePlayer,, 'W3Herb');
		for(i=0; i<herbs.Size(); i+=1)
			LootHerb((W3Container)herbs[i]);
	}
	

	private function GetCurrentWeight( inv : CInventoryComponent ) : float
	{
		var i: int;
		var currWeight : float;
		var items : array<SItemUniqueId>;
		
		inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
			if( !inv.IsItemHorseItem(items[i]) && inv.IsItemEncumbranceItem(items[i]) )
				currWeight += inv.GetItemEncumbrance( items[i] );
				
		return currWeight;
	}

	public final function LootHerb( herb : W3Container )
	{
		var i, number, bonusNumber, curWeight, maxWeight : int;
		var witcher : W3PlayerWitcher;
		var herbs : array<SItemUniqueId>;
		var herbInventory, horseInventory : CInventoryComponent;
		
		witcher = GetWitcherPlayer();
		horseInventory = witcher.GetHorseManager().GetInventoryComponent();
		maxWeight = (int)CalculateAttributeValue(witcher.GetHorseManager().GetHorseAttributeValue('encumbrance', false)) + Options().BaseCWRoach();
		curWeight = (int)GetCurrentWeight(horseInventory);
		
		herbInventory = herb.GetInventory();
		herbInventory.GetAllItems(herbs);
		
		if( herbs.Size() )
			theSound.SoundEvent("gui_loot_popup_close");
			
		for(i=0; i < herbs.Size(); i+=1)
		{
			number = herbInventory.GetItemQuantity(herbs[i]);
			bonusNumber = RandRange(3,1) + RandRange(2,1) - RandRange(2,0) + RandRange(4,0);
			//Kolaris - Alchemical Studies
			if( witcher.CanUseSkill(S_Perk_04) )
				bonusNumber += RandRange(3,1);
			if( !witcher.IsSwimming() && herbInventory.ShouldHorseLootItem(herbs[i]) && herbInventory.GetItemEncumbrance(herbs[i]) * (bonusNumber + number) + curWeight <= maxWeight )//Plasticmetal - LootTweak
			{
				herbInventory.AddAnItem(herbInventory.GetItemName(herbs[i]), bonusNumber);//Plasticmetal - LootTweak
				herbInventory.NotifyItemLooted(herbs[i]);
				herbInventory.GiveItemTo(horseInventory, herbs[i], number + bonusNumber, true, false, true);//Plasticmetal - LootTweak
			}
			else
			{
				herbInventory.AddAnItem(herbInventory.GetItemName( herbs[i] ), bonusNumber);//Plasticmetal - LootTweak
				herbInventory.NotifyItemLooted(herbs[i]);
				herbInventory.GiveItemTo(witcher.inv, herbs[i], number + bonusNumber, true, false, true);//Plasticmetal - LootTweak
				witcher.FinishInvUpdateTransaction();
			}
		}
		
		herb.OnContainerClosed();
		herb.RequestUpdateContainer();
	}
	
	public function GetArmorTypeFromName( itemName : name ) : EArmorType
	{
		var armorType : EArmorType;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		
		if( !dm.IsItemAnyArmor(itemName) )
			return EAT_Undefined;
			
		if( dm.ItemHasTag(itemName, 'LightArmor') )
			armorType = EAT_Light;
		else
		if( dm.ItemHasTag(itemName, 'MediumArmor') )
			armorType = EAT_Medium;
		else
			armorType = EAT_Heavy;
			
		return armorType;
	}
	
	public final function ScaleItems( inv : CInventoryComponent )
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		inv.GetAllItems(items);
		for(i=0; i<=items.Size(); i+=1)
			switch( inv.GetItemCategory(items[i]) )
			{
				case 'steelsword': 	inv.GetItemLevel(items[i]); break;
				case 'silversword': inv.GetItemLevel(items[i]); break;
				case 'armor': 		inv.GetItemLevel(items[i]); break;
				case 'gloves': 		inv.GetItemLevel(items[i]); break;
				case 'gloves': 		inv.GetItemLevel(items[i]); break;
				case 'boots': 		inv.GetItemLevel(items[i]); break;
				case 'pants': 		inv.GetItemLevel(items[i]); break;
			}
	}
	
	public function HandleRelicAbilities( witcher : W3PlayerWitcher, item : SItemUniqueId, equip : bool )
	{
		var weaponTags 	: array<name>;
		var effectType 	: EEffectType;
		var abilityName : name;
		var i : int;
		
		if( !witcher.inv.IsItemWeapon(item) )
			return;
			
		witcher.inv.GetItemTags(item, weaponTags);
		if( equip )
		{
			for(i=0; i<weaponTags.Size(); i+=1)
			{
				EffectNameToType(weaponTags[i], effectType, abilityName);
				if( effectType != EET_Undefined )
					break;
			}
			
			if( effectType != EET_Undefined )
				witcher.AddEffectDefault(effectType, witcher, "RelicWeaponBuff", false);
		}
		else
		{
			for(i=0; i<weaponTags.Size(); i+=1)
			{
				EffectNameToType(weaponTags[i], effectType, abilityName);
				if( effectType != EET_Undefined )
					break;
			}
			
			if( effectType != EET_Undefined )
				witcher.RemoveBuff(effectType, false, "RelicWeaponBuff");
		}
	}
	
	public function SetStringWhite( str : string ) : string
	{
		return "<font color='#ffffff'>" + str + "</font>";
	}
	
	public function GetOilAbilityDescription( item : SItemUniqueId, inv : CInventoryComponent ) : string
	{
		var oilTags			: array<name>;
		var abilityString	: string;
		var stringParams	: array<string>;
		var i				: int;
		var attributeValue 	: SAbilityAttributeValue;
		
		inv.GetItemTags(item, oilTags);
		
		abilityString = "";
		
		for(i=0; i<oilTags.Size(); i+=1)
		{
			switch(oilTags[i])
			{
				case 'CorrosiveOil' :
					abilityString += GetLocStringByKeyExtWithParams("item_desc_corrosive_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'EtherealOil' :
					attributeValue = inv.GetItemAttributeValue(item, 'oil_ethereal_damage' );
					
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive * 0.08f)));
					
					abilityString += GetLocStringByKeyExtWithParams("item_desc_ethereal_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'BrownOil' :
					attributeValue = inv.GetItemAttributeValue(item, 'oil_bleed_effect' );
					
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueMultiplicative * 100.f) + "%"));
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive)));
					
					abilityString += GetLocStringByKeyExtWithParams("item_desc_brown_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'PoisonousOil' :
					attributeValue = inv.GetItemAttributeValue(item, 'oil_poison_effect' );
					
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueMultiplicative * 100.f) + "%"));
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive)));
					
					abilityString += GetLocStringByKeyExtWithParams("item_desc_poison_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'FalkaOil' :
					attributeValue = inv.GetItemAttributeValue(item, 'oil_falka_injury_chance' );
					
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive * 100.f) + "%"));
					abilityString += GetLocStringByKeyExtWithParams("item_desc_falka_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'RimingOil' :
					abilityString += GetLocStringByKeyExtWithParams("item_desc_riming_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'FlammableOil' :
					abilityString += GetLocStringByKeyExtWithParams("item_desc_flammable_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'ParalysisOil' :
					attributeValue = inv.GetItemAttributeValue(item, 'oil_stamina_damage' );
					
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueBase)));
					stringParams.PushBack(SetStringWhite(FloatToString(20.f - (10.f * attributeValue.valueMultiplicative))));

					abilityString += GetLocStringByKeyExtWithParams("item_desc_paralysis_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				case 'ArgentiaOil' :
					attributeValue = inv.GetItemAttributeValue(item, 'oil_silver' );
					
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueBase)));
					stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive)));
					
					abilityString += GetLocStringByKeyExtWithParams("item_desc_silver_oil", , , stringParams);
					abilityString += "<br>";
				break;
				
				default : abilityString += "";
			}
		}
		
		return abilityString;
	}
	
	public function GetItemNameToOilTag( itemName : name ) : name
	{
			 if( StrContains(itemName, 'Corrosive')) 	return 'CorrosiveOil';
		else if( StrContains(itemName, 'Ethereal'))		return 'EtherealOil';
		else if( StrContains(itemName, 'Brown'))		return 'BrownOil';
		else if( StrContains(itemName, 'Poison'))		return 'PoisonousOil';
		else if( StrContains(itemName, 'Falka'))		return 'FalkaOil';
		else if( StrContains(itemName, 'Riming'))		return 'RimingOil';
		else if( StrContains(itemName, 'Flammable'))	return 'FlammableOil';
		else if( StrContains(itemName, 'Paralysis'))	return 'ParalysisOil';
		else if( StrContains(itemName, 'Silver'))		return 'ArgentiaOil';
		else											return '';
	}
	
	public function GetOilAbilityDescriptionByName( itemName : name ) : string
	{
		var oilTag			: name;	
		var abilityString	: string;
		var stringParams	: array<string>;
		var i				: int;
		var attributeValue	: SAbilityAttributeValue;
		var temp 			: SAbilityAttributeValue;
		var dm				: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		
		if( !dm.IsItemOil(itemName) )
			return "";
			
		oilTag = GetItemNameToOilTag(itemName);
		abilityString = "";
		switch(oilTag)
		{
			case 'CorrosiveOil' :
				abilityString += GetLocStringByKeyExtWithParams("item_desc_corrosive_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'EtherealOil' :
				dm.GetItemAttributeValueNoRandom(itemName, false, 'oil_ethereal_damage', attributeValue, temp );
					
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive * 0.08f)));
					
				abilityString += GetLocStringByKeyExtWithParams("item_desc_ethereal_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'BrownOil' :
				dm.GetItemAttributeValueNoRandom(itemName, false, 'oil_bleed_effect', attributeValue, temp );
				
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueMultiplicative * 100.f) + "%"));
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive)));
				
				abilityString += GetLocStringByKeyExtWithParams("item_desc_brown_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'PoisonousOil' :
				dm.GetItemAttributeValueNoRandom(itemName, false, 'oil_poison_effect', attributeValue, temp );
				
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueMultiplicative * 100.f) + "%"));
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive)));
				
				abilityString += GetLocStringByKeyExtWithParams("item_desc_poison_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'FalkaOil' :
				dm.GetItemAttributeValueNoRandom(itemName, false, 'oil_falka_injury_chance', attributeValue, temp );
				
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive * 100.f) + "%"));
				abilityString += GetLocStringByKeyExtWithParams("item_desc_falka_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'RimingOil' :
				abilityString += GetLocStringByKeyExtWithParams("item_desc_riming_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'FlammableOil' :
				abilityString += GetLocStringByKeyExtWithParams("item_desc_flammable_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'ParalysisOil' :
				dm.GetItemAttributeValueNoRandom(itemName, false, 'oil_stamina_damage', attributeValue, temp );
				
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueBase)));
				stringParams.PushBack(SetStringWhite(FloatToString(20.f - (10.f * attributeValue.valueMultiplicative))));

				abilityString += GetLocStringByKeyExtWithParams("item_desc_paralysis_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			case 'ArgentiaOil' :
				dm.GetItemAttributeValueNoRandom(itemName, false, 'oil_silver', attributeValue, temp );
				
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueBase)));
				stringParams.PushBack(SetStringWhite(FloatToString(attributeValue.valueAdditive)));
				
				abilityString += GetLocStringByKeyExtWithParams("item_desc_silver_oil", , , stringParams);
				abilityString += "<br>";
			break;
			
			default : abilityString += "";
		}
		
		return abilityString;
	}
	//Kolaris - Relic Swords
	public function GetRelicAbilityDescription( itemName : name ) : string
	{
		var weaponTags 		: array<name>;
		var weaponTag 		: name;
		var effectType 		: EEffectType;
		var abilityString 	: string;
		var stringParams 	: array<string>;
		var abilityName		: name;
		var min, max		: SAbilityAttributeValue;
		var dm				: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var i				: int;
		
		effectType = EET_Undefined;
		if( !dm.IsItemWeapon(itemName) )
			return "";
			
		weaponTags.PushBack('SwordCritVigorEffect');
		weaponTags.PushBack('SwordRendBlastEffect');
		weaponTags.PushBack('SwordInjuryHealEffect');
		weaponTags.PushBack('SwordDancingEffect');
		weaponTags.PushBack('SwordQuenEffect');
		weaponTags.PushBack('SwordWraithbaneEffect');
		weaponTags.PushBack('SwordBloodFrenzyEffect');
		weaponTags.PushBack('SwordKillBuffEffect');
		weaponTags.PushBack('SwordBeheadEffect');
		weaponTags.PushBack('SwordGasEffect');
		weaponTags.PushBack('SwordSignDancerEffect');
		weaponTags.PushBack('SwordReachoftheDamnedEffect');
		weaponTags.PushBack('SwordDarkCurseEffect');
		weaponTags.PushBack('SwordDesperateActEffect');
		weaponTags.PushBack('SwordRedTearEffect');
		weaponTags.PushBack('WinterBladeEffect');
		weaponTags.PushBack('PhantomWeaponEffect');
		weaponTags.PushBack('AerondightEffect');
		for(i=0; i<weaponTags.Size(); i+=1)
		{
			if( dm.ItemHasTag(itemName, weaponTags[i]) )
			{
				EffectNameToType(weaponTags[i], effectType, abilityName);
				if( effectType != EET_Undefined )
				{
					weaponTag = weaponTags[i];
					break;
				}
			}
		}
		
		if( effectType == EET_Undefined )
			return "";
			
		abilityString = /*"<font color='#8e8b8a'>" + StrUpperUTF(GetLocStringByKeyExt("W3EE_UniqueWeaponAbility")) + "<br>" +*/ "<font color='#ca610c'>"; //Gwynbleidd TTTweak
		switch(effectType)
		{
			case EET_SwordCritVigor:
				stringParams.PushBack(SetStringWhite("40%"));
				stringParams.PushBack(SetStringWhite("10"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordRendBlast:
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordInjuryHeal:
				stringParams.PushBack(SetStringWhite("100%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordDancing:
				stringParams.PushBack(SetStringWhite("25%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordQuen:
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordWraithbane:
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordBloodFrenzy:
				stringParams.PushBack(SetStringWhite("25%"));
				
				dm.GetAbilityAttributeValue('SwordBloodFrenzyAbility', 'attack_stamina_cost_bonus', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueMultiplicative * 100)) + "%"));
				
				dm.GetAbilityAttributeValue('SwordBloodFrenzyAbility', 'attack_speed', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueMultiplicative * 100)) + "%"));
				
				stringParams.PushBack(SetStringWhite("5"));
				
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordKillBuff:
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordBehead:
				stringParams.PushBack(SetStringWhite("10"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordGas:
				stringParams.PushBack(SetStringWhite("15%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordSignDancer:
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordReachoftheDamned:
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("50"));
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("50"));
				stringParams.PushBack(SetStringWhite("50%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordDarkCurse:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordDesperateAct:
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("50%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_SwordRedTear:
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("100%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTag + "Descr", , , stringParams);
			break;
			
			case EET_WinterBlade:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByKeyExtWithParams("item_desc_winterblade", , , stringParams);
			break;
			
			case EET_PhantomWeapon:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByIdWithParams(2116942037, , , stringParams);
			break;
			
			case EET_Aerondight:
				dm.GetAbilityAttributeValue('AerondightEffect', 'crit_dam_bonus_stack', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueAdditive * 100)) + "%"));
				dm.GetAbilityAttributeValue('AerondightEffect', 'crit_chance_bonus', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueAdditive * 100)) + "%"));
				abilityString += GetLocStringByKeyExtWithParams("attribute_name_aerondight", , , stringParams);
				
				abilityString += "<br><br>" + GetLocStringByKeyExt("attribute_name_aerondight_abilities");
			break;
			
			default : return "";
		}
		abilityString += "</font>";
		
		return abilityString;
	}
	
	public function DisallowUnequip( slot : EEquipmentSlots, item : SItemUniqueId, inv : CInventoryComponent ) : bool
	{
		var helmItem : array<SItemUniqueId>;
		
		if( slot == EES_Quickslot1 || slot == EES_Quickslot2 )
		{
			switch(inv.GetItemName(item))
			{
				case 'kotw_helm_v1_1_usable':	helmItem = inv.GetItemsByName('kotw_helm_v1_1');	break;
				case 'kotw_helm_v2_1_usable':	helmItem = inv.GetItemsByName('kotw_helm_v2_1');	break;
				case 'kotw_helm_v3_1_usable':	helmItem = inv.GetItemsByName('kotw_helm_v3_1');	break;
			}
			
			if( inv.IsItemMounted(helmItem[0]) )
				return true;
		}
		
		return false;
	}
	
	var horseDistance : float;
	public function GetHorseDistance() : float
	{
		var distance : float;
		
		distance = VecDistanceSquared(GetWitcherPlayer().GetWorldPosition(), GetWitcherPlayer().GetHorseWithInventory().GetWorldPosition());
		if( theGame.IsPaused() )
		{
			if( distance )
				return distance;
			else
				return horseDistance;
		}
		else
			return VecDistanceSquared(GetWitcherPlayer().GetWorldPosition(), GetWitcherPlayer().GetHorseWithInventory().GetWorldPosition());
	}
	
	public function SetHorseDistance()
	{
		horseDistance = VecDistanceSquared(GetWitcherPlayer().GetWorldPosition(), GetWitcherPlayer().GetHorseWithInventory().GetWorldPosition());
	}
	
	public function GetItemQuantityByNameForCrafting( itemName : name ) : int
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var inv : CInventoryComponent = witcher.GetInventory();
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		if( dm.ItemHasTag(itemName, 'StashVariant') || dm.ItemHasTag(itemName, 'NoShow') )
			return 0;
		else if( !dm.ItemHasTag(itemName, 'MutagenIngredient') )
			return inv.GetItemQuantityByName(itemName) + witcher.GetHorseManager().GetInventoryComponent().GetItemQuantityByName(itemName) + witcher.GetHorseManager().GetInventoryComponent().GetItemQuantityByName(GetItemStashVariant(itemName));
		else
			return inv.GetUnusedMutagensCount(itemName) + witcher.GetHorseManager().GetInventoryComponent().GetItemQuantityByName(itemName) + witcher.GetHorseManager().GetInventoryComponent().GetItemQuantityByName(GetItemStashVariant(itemName));
	}
	
	public function RemoveItemByNameForCrafting( itemName : name, quantity : int ) : bool
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var inv : CInventoryComponent = witcher.GetInventory();
		var horseInv : CInventoryComponent = witcher.GetHorseManager().GetInventoryComponent();
		var playerQuantity, horseQuantity, quantityToRemove, removedQuantity : int;
		var alchIngredients  : array<SItemUniqueId>;
		var dm : CDefinitionsManagerAccessor;
		var equippedOnSlot : EEquipmentSlots;
		var i : int;
		
		dm = theGame.GetDefinitionsManager();
		if( dm.IsItemAlchemyItem(itemName) && !dm.IsItemFood(itemName) )
		{
			quantityToRemove = quantity;
			playerQuantity = inv.GetItemQuantityByName(itemName);
			if( playerQuantity < quantityToRemove )
			{
				quantityToRemove = playerQuantity;
			}
			
			alchIngredients = inv.GetItemsByName(itemName);
			for(i=0; i<alchIngredients.Size(); i+=1)
			{
				inv.SingletonItemRemoveAmmo(alchIngredients[i], quantityToRemove);			
				if( !inv.GetItemModifierInt(alchIngredients[i], 'ammo_current') )
				{
					equippedOnSlot = witcher.GetItemSlot(alchIngredients[i]);
					if(equippedOnSlot != EES_InvalidSlot)
						witcher.UnequipItem(alchIngredients[i]);
					
					inv.RemoveItem(alchIngredients[i]);
					break;
				}
				
				removedQuantity += 1;
				if(removedQuantity >= quantityToRemove)
					break;
			}
			
			quantityToRemove = quantity - removedQuantity;
			if( quantityToRemove > 0 )
			{
				removedQuantity = 0;
				horseQuantity = horseInv.GetItemQuantityByName(itemName);
				if( horseQuantity < quantityToRemove )
				{
					quantityToRemove = horseQuantity;
				}
				
				alchIngredients = horseInv.GetItemsByName(itemName);
				for(i=0; i<alchIngredients.Size(); i+=1)
				{
					horseInv.SingletonItemRemoveAmmo(alchIngredients[i], quantityToRemove);			
					if( !horseInv.GetItemModifierInt(alchIngredients[i], 'ammo_current') )
					{
						horseInv.RemoveItem(alchIngredients[i]);
						break;
					}
					
					removedQuantity += 1;
					if(removedQuantity >= quantityToRemove)
						break;
				}
			}
			if( removedQuantity == quantity )
			{
				return true;
			}
			return false;
		}
		else
		if( !dm.ItemHasTag(itemName, 'MutagenIngredient') )
		{
			quantityToRemove = quantity;
			playerQuantity = inv.GetItemQuantityByName(itemName);
			if( playerQuantity < quantityToRemove )
			{
				quantityToRemove = playerQuantity;
			}
			if( quantityToRemove > 0 && inv.RemoveItemByName(itemName, quantityToRemove) )
			{
				removedQuantity = quantityToRemove;
			}
			quantityToRemove = quantity - removedQuantity;
			if( quantityToRemove > 0 )
			{
				horseQuantity = horseInv.GetItemQuantityByName(itemName);
				if( horseQuantity < quantityToRemove )
				{
					quantityToRemove = horseQuantity;
				}
				if( quantityToRemove > 0 && horseInv.RemoveItemByName(itemName, quantityToRemove) )
				{
					removedQuantity += quantityToRemove;
				}
			}
			quantityToRemove = quantity - removedQuantity;
			if( quantityToRemove > 0 )
			{
				horseQuantity = horseInv.GetItemQuantityByName(GetItemStashVariant(itemName));
				if( horseQuantity < quantityToRemove )
				{
					quantityToRemove = horseQuantity;
				}
				if( quantityToRemove > 0 && horseInv.RemoveItemByName(GetItemStashVariant(itemName), quantityToRemove) )
				{
					removedQuantity += quantityToRemove;
				}
			}
			if( removedQuantity == quantity )
			{
				return true;
			}
			return false;
		}
		else
		{
			if( dm.ItemHasTag(itemName, 'InertMutagen') )
			{
				quantityToRemove = quantity;
				playerQuantity = inv.GetUnusedMutagensCount(itemName);
				if( playerQuantity < quantityToRemove )
				{
					quantityToRemove = playerQuantity;
				}
				if( quantityToRemove > 0 && inv.RemoveUnusedMutagensCount(itemName, quantityToRemove) )
				{
					removedQuantity = quantityToRemove;
				}
				quantityToRemove = quantity - removedQuantity;
				if( quantityToRemove > 0 )
				{
					horseQuantity = horseInv.GetItemQuantityByName(itemName);
					if( horseQuantity < quantityToRemove )
					{
						quantityToRemove = horseQuantity;
					}
					if( quantityToRemove > 0 && horseInv.RemoveItemByName(itemName, quantityToRemove) )
					{
						removedQuantity += quantityToRemove;
					}
				}
				quantityToRemove = quantity - removedQuantity;
				if( quantityToRemove > 0 )
				{
					horseQuantity = horseInv.GetItemQuantityByName(GetItemStashVariant(itemName));
					if( horseQuantity < quantityToRemove )
					{
						quantityToRemove = horseQuantity;
					}
					if( quantityToRemove > 0 && horseInv.RemoveItemByName(GetItemStashVariant(itemName), quantityToRemove) )
					{
						removedQuantity += quantityToRemove;
					}
				}
			}
			else removedQuantity = RemoveWorstMutagen(itemName, quantity);
			
			if( removedQuantity == quantity )
			{
				return true;
			}
			return false;
		}
	}
	
	public function RemoveWorstMutagen(itemName:name, quantity:int) :int
	{
		
		var items  			: array<SItemUniqueId>;
		var curItem 		: SItemUniqueId;
		var equippedOnSlot  : EEquipmentSlots;
		var i, j, size : int;
		var ret: array<SItemUniqueId>;
		var found : bool;
		var UnsortedMutagens : array<SItemUniqueId>;
		var SortedMutagens : array<SItemUniqueId>;
		var UnsortedInventories : array<CInventoryComponent>;
		var SortedInventories : array<CInventoryComponent>;
		var Mutagens : array<SItemUniqueId>;
		var Inventories, ret2  : array<CInventoryComponent>;
		var horseInv : CInventoryComponent;
		var mutagenStats1, mutagenStats2			: array<SAttributeTooltip>;
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		
		
		items = thePlayer.inv.GetItemsByName( itemName );	
		for( i=0; i < items.Size(); i+=1 )
		{
			curItem = items[ i ];
			equippedOnSlot = GetWitcherPlayer().GetItemSlot( curItem );
			
			if( equippedOnSlot == EES_InvalidSlot )
			{
				Mutagens.PushBack(curItem);
				Inventories.PushBack(GetWitcherPlayer().GetInventory());
			}
		}
		
		items.Clear();
		items = horseInv.GetItemsByName( itemName );
		for( i=0; i < items.Size(); i+=1 )
		{
			curItem = items[ i ];
			Mutagens.PushBack(curItem);
			Inventories.PushBack(horseInv);
		}
		
		if(Mutagens.Size() <= 0)
			return 0;
			
		size = Mutagens.Size();	
		ret.PushBack(Mutagens[0]);
		ret2.PushBack(Inventories[0]);
		for(i=1; i<size; i+=1)
		{
			found = false;
			
			for(j=0; j<ret.Size(); j+=1)
			{
				Inventories[i].GetItemStats(Mutagens[i], mutagenStats1);
				ret2[j].GetItemStats(ret[j], mutagenStats2);
				if( mutagenStats1[0].value < mutagenStats2[0].value)
				{
					ret.Insert(j, Mutagens[i]);
					ret2.Insert(j, Inventories[i]);
					found = true;
					break;
				}
			}
			
			if ( !found )
			{
				ret.PushBack(Mutagens[i]);
				ret2.PushBack(Inventories[i]);
			}
		}
		
		Mutagens.Clear();
		Mutagens = ret;
		Inventories.Clear();
		Inventories = ret2;
		for(i=0; i<quantity; i+=1)
		{
			Inventories[i].RemoveItem(Mutagens[i]);
		}
		return quantity;
	}
	
	public function GetSetCountStringColor( item : SItemUniqueId, str : string ) : string
	{
		switch(GetWitcherPlayer().inv.GetItemQuality(item))
		{
			case 1: 
				return "<font color='#8e8b8a'>" + str + "</font>";
			case 2:
				return "<font color='#4e75e5'>" + str + "</font>";
			case 3:
				return "<font color='#c1b601'>" + str + "</font>";
			case 4:
				return "<font color='#ca610c'>" + str + "</font>";	
			case 5:
			default:
				return "<font color='#186618'>" + str + "</font>";
		}
	}
	
	public function GetDescriptionColorByType( descr : string, setType : EItemSetType, abilityLevel : int, currentCount : int, isActive : bool ) : string
	{
		if( !isActive )
		{
			if( abilityLevel == 2 && currentCount >= Options().SetBonusCountSecond() )
				return "<font color=\"#9F1919\">" + descr + "</font>";
			else
				return descr;
		}
		
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return "<font color=\"#ffffff\">" + descr + "</font>";
				
			default:
				return "<font color='#186618'>" + descr + "</font>";
		}
	}
	
	public function GetSetTypeString( setType : EItemSetType ) : string
	{
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return "<font color=\"#8e8b8a\">" + GetLocStringByKeyExt("W3EE_GenericArmorAbility") + "</font>";
				
			default:
				return /*"<font color='#186618'>" + GetLocStringByKeyExt("W3EE_UniqueArmorAbility") + "</font>"*/""; //Gwynbleidd TTTWeak
		}
	}
	
	public function GetGeneralArmorAbilityDescr( item : SItemUniqueId ) : string
	{
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Light )
			return GetWitcherPlayer().GetSetBonusTooltipDescription(EISB_LightArmor);
		else
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Medium )
			return GetWitcherPlayer().GetSetBonusTooltipDescription(EISB_MediumArmor);
		else
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Heavy )
			return GetWitcherPlayer().GetSetBonusTooltipDescription(EISB_HeavyArmor);
		else
			return "";
	}
	
	public function GetGeneralArmorAbilityDescrByName( itemName : name ) : string
	{
		if( GetArmorTypeFromName(itemName) == EAT_Light )
			return GetWitcherPlayer().GetSetBonusTooltipDescription(EISB_LightArmor);
		else
		if( GetArmorTypeFromName(itemName) == EAT_Medium )
			return GetWitcherPlayer().GetSetBonusTooltipDescription(EISB_MediumArmor);
		else
		if( GetArmorTypeFromName(itemName) == EAT_Heavy )
			return GetWitcherPlayer().GetSetBonusTooltipDescription(EISB_HeavyArmor);
		else
			return "";
	}
	
	public function IsGeneralArmorAbilityActive( item : SItemUniqueId ) : bool
	{
		var armorCount : array<SArmorCount>;
		
		armorCount = GetWitcherPlayer().GetArmorCountOrig();
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Light )
			return armorCount[0].all + armorCount[1].all > 3;
		else
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Medium )
			return armorCount[2].all > 3;
		else
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Heavy )
			return armorCount[3].all > 3;
		else
			return 0;
	}
	
	public function GetMaximumSetItemsBySet( setType : EItemSetType ) : int
	{
		switch(setType)
		{
			//Kolaris - New Set Bonuses
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
			case EIST_Temerian:
			case EIST_Nilfgaard:
			case EIST_Skellige:
			case EIST_Ofieri:
			case EIST_New_Moon:
				return 4;
				
			case EIST_Gothic:
			case EIST_Dimeritium:
			case EIST_Meteorite:
				return 5;
				
			default:
				return 6;
		}
	}
	
	public function GetMinimumItemsReqBySet( setType : EItemSetType ) : int
	{
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return 4;
				
			case EIST_MinorLynx:
			case EIST_MinorGryphon:
			case EIST_MinorBear:
			case EIST_MinorWolf:
			case EIST_MinorRedWolf:
				return Options().SetBonusCountSecond();
				
			default:
				return Options().SetBonusCountFirst();
		}
	}
	
	public function HasPreviousTierRuneword( enchantName : name, itemID : SItemUniqueId ) : bool
	{
		var enchantment : name;
		
		enchantment = GetWitcherPlayer().GetInventory().GetEnchantment(itemID);
		//Kolaris - Enchantment Overhaul
		if( StrContains(NameToString(enchantName), "Glyphword") )
		{
			if( enchantName == 'Glyphword 2' && enchantment != 'Glyphword 1' )
				return false;
			else if( enchantName == 'Glyphword 3' && enchantment != 'Glyphword 2' )
				return false;
			else if( enchantName == 'Glyphword 5' && enchantment != 'Glyphword 4' )
				return false;
			else if( enchantName == 'Glyphword 6' && enchantment != 'Glyphword 5' )
				return false;
			else if( enchantName == 'Glyphword 8' && enchantment != 'Glyphword 7' )
				return false;
			else if( enchantName == 'Glyphword 9' && enchantment != 'Glyphword 8' )
				return false;
			else if( enchantName == 'Glyphword 11' && enchantment != 'Glyphword 10' )
				return false;
			else if( enchantName == 'Glyphword 12' && enchantment != 'Glyphword 11' )
				return false;
			else if( enchantName == 'Glyphword 14' && enchantment != 'Glyphword 13' )
				return false;
			else if( enchantName == 'Glyphword 15' && enchantment != 'Glyphword 14' )
				return false;
			else if( enchantName == 'Glyphword 17' && enchantment != 'Glyphword 16' )
				return false;
			else if( enchantName == 'Glyphword 18' && enchantment != 'Glyphword 17' )
				return false;
			else if( enchantName == 'Glyphword 20' && enchantment != 'Glyphword 19' )
				return false;
			else if( enchantName == 'Glyphword 21' && enchantment != 'Glyphword 20' )
				return false;
			else if( enchantName == 'Glyphword 23' && enchantment != 'Glyphword 22' )
				return false;
			else if( enchantName == 'Glyphword 24' && enchantment != 'Glyphword 23' )
				return false;
			else if( enchantName == 'Glyphword 26' && enchantment != 'Glyphword 25' )
				return false;
			else if( enchantName == 'Glyphword 27' && enchantment != 'Glyphword 26' )
				return false;
			else if( enchantName == 'Glyphword 29' && enchantment != 'Glyphword 28' )
				return false;
			else if( enchantName == 'Glyphword 30' && enchantment != 'Glyphword 29' )
				return false;
			else if( enchantName == 'Glyphword 32' && enchantment != 'Glyphword 31' )
				return false;
			else if( enchantName == 'Glyphword 33' && enchantment != 'Glyphword 32' )
				return false;
			else if( enchantName == 'Glyphword 35' && enchantment != 'Glyphword 34' )
				return false;
			else if( enchantName == 'Glyphword 36' && enchantment != 'Glyphword 35' )
				return false;
			else if( enchantName == 'Glyphword 38' && enchantment != 'Glyphword 37' )
				return false;
			else if( enchantName == 'Glyphword 39' && enchantment != 'Glyphword 38' )
				return false;
			else if( enchantName == 'Glyphword 41' && enchantment != 'Glyphword 40' )
				return false;
			else if( enchantName == 'Glyphword 42' && enchantment != 'Glyphword 41' )
				return false;
			else if( enchantName == 'Glyphword 44' && enchantment != 'Glyphword 43' )
				return false;
			else if( enchantName == 'Glyphword 45' && enchantment != 'Glyphword 44' )
				return false;
			else if( enchantName == 'Glyphword 47' && enchantment != 'Glyphword 46' )
				return false;
			else if( enchantName == 'Glyphword 48' && enchantment != 'Glyphword 47' )
				return false;
			else if( enchantName == 'Glyphword 50' && enchantment != 'Glyphword 49' )
				return false;
			else if( enchantName == 'Glyphword 51' && enchantment != 'Glyphword 50' )
				return false;
			else if( enchantName == 'Glyphword 53' && enchantment != 'Glyphword 52' )
				return false;
			else if( enchantName == 'Glyphword 54' && enchantment != 'Glyphword 53' )
				return false;
			else
				return true;
		}
		else
		{
			if( enchantName == 'Runeword 2' && enchantment != 'Runeword 1' )
				return false;
			else if( enchantName == 'Runeword 3' && enchantment != 'Runeword 2' )
				return false;
			else if( enchantName == 'Runeword 5' && enchantment != 'Runeword 4' )
				return false;
			else if( enchantName == 'Runeword 6' && enchantment != 'Runeword 5' )
				return false;
			else if( enchantName == 'Runeword 8' && enchantment != 'Runeword 7' )
				return false;
			else if( enchantName == 'Runeword 9' && enchantment != 'Runeword 8' )
				return false;
			else if( enchantName == 'Runeword 11' && enchantment != 'Runeword 10' )
				return false;
			else if( enchantName == 'Runeword 12' && enchantment != 'Runeword 11' )
				return false;
			else if( enchantName == 'Runeword 14' && enchantment != 'Runeword 13' )
				return false;
			else if( enchantName == 'Runeword 15' && enchantment != 'Runeword 14' )
				return false;
			else if( enchantName == 'Runeword 17' && enchantment != 'Runeword 16' )
				return false;
			else if( enchantName == 'Runeword 18' && enchantment != 'Runeword 17' )
				return false;
			else if( enchantName == 'Runeword 20' && enchantment != 'Runeword 19' )
				return false;
			else if( enchantName == 'Runeword 21' && enchantment != 'Runeword 20' )
				return false;
			else if( enchantName == 'Runeword 23' && enchantment != 'Runeword 22' )
				return false;
			else if( enchantName == 'Runeword 24' && enchantment != 'Runeword 23' )
				return false;
			else if( enchantName == 'Runeword 26' && enchantment != 'Runeword 25' )
				return false;
			else if( enchantName == 'Runeword 27' && enchantment != 'Runeword 26' )
				return false;
			else if( enchantName == 'Runeword 29' && enchantment != 'Runeword 28' )
				return false;
			else if( enchantName == 'Runeword 30' && enchantment != 'Runeword 29' )
				return false;
			else if( enchantName == 'Runeword 32' && enchantment != 'Runeword 31' )
				return false;
			else if( enchantName == 'Runeword 33' && enchantment != 'Runeword 32' )
				return false;
			else if( enchantName == 'Runeword 35' && enchantment != 'Runeword 34' )
				return false;
			else if( enchantName == 'Runeword 36' && enchantment != 'Runeword 35' )
				return false;
			else if( enchantName == 'Runeword 38' && enchantment != 'Runeword 37' )
				return false;
			else if( enchantName == 'Runeword 39' && enchantment != 'Runeword 38' )
				return false;
			else if( enchantName == 'Runeword 41' && enchantment != 'Runeword 40' )
				return false;
			else if( enchantName == 'Runeword 42' && enchantment != 'Runeword 41' )
				return false;
			else if( enchantName == 'Runeword 44' && enchantment != 'Runeword 43' )
				return false;
			else if( enchantName == 'Runeword 45' && enchantment != 'Runeword 44' )
				return false;
			else if( enchantName == 'Runeword 47' && enchantment != 'Runeword 46' )
				return false;
			else if( enchantName == 'Runeword 48' && enchantment != 'Runeword 47' )
				return false;
			else if( enchantName == 'Runeword 50' && enchantment != 'Runeword 49' )
				return false;
			else if( enchantName == 'Runeword 51' && enchantment != 'Runeword 50' )
				return false;
			else if( enchantName == 'Runeword 53' && enchantment != 'Runeword 52' )
				return false;
			else if( enchantName == 'Runeword 54' && enchantment != 'Runeword 53' )
				return false;
			else if( enchantName == 'Runeword 56' && enchantment != 'Runeword 55' )
				return false;
			else if( enchantName == 'Runeword 57' && enchantment != 'Runeword 56' )
				return false;
			else if( enchantName == 'Runeword 59' && enchantment != 'Runeword 58' )
				return false;
			else if( enchantName == 'Runeword 60' && enchantment != 'Runeword 59' )
				return false;
			else
				return true;
		}
	}
	
	public function GetEnchantmentAbilityFromName( enchantName : name ) : name
	{
		switch(enchantName)
		{			
			case 'Glyphword 1':
			case 'Glyphword 2':
			case 'Glyphword 3':
				return 'Enchant Ability Disintegration';
			
			case 'Glyphword 4':
			case 'Glyphword 5':
			case 'Glyphword 6':
				return 'Enchant Ability Acceleration';
			
			case 'Glyphword 7':
			case 'Glyphword 8':
			case 'Glyphword 9':
				return 'Enchant Ability Immolation';
			
			case 'Glyphword 10':
			case 'Glyphword 11':
			case 'Glyphword 12':
				return 'Enchant Ability Purgation';
			
			case 'Glyphword 13':
			case 'Glyphword 14':
			case 'Glyphword 15':
				return 'Enchant Ability Absorption';
			
			case 'Glyphword 16':
			case 'Glyphword 17':
			case 'Glyphword 18':
				return 'Enchant Ability Enervation';
			
			case 'Glyphword 19':
			case 'Glyphword 20':
			case 'Glyphword 21':
				return 'Enchant Ability Retribution';
			
			case 'Glyphword 22':
			case 'Glyphword 23':
			case 'Glyphword 24':
				return 'Enchant Ability Bastion';
			
			case 'Glyphword 25':
			case 'Glyphword 26':
			case 'Glyphword 27':
				return 'Enchant Ability Conjunction';
			
			case 'Glyphword 28':
			case 'Glyphword 29':
			case 'Glyphword 30':
				return 'Enchant Ability Posession';
			
			case 'Glyphword 31':
			case 'Glyphword 32':
			case 'Glyphword 33':
				return 'Enchant Ability Protection';
			
			case 'Glyphword 34':
			case 'Glyphword 35':
			case 'Glyphword 36':
				return 'Enchant Ability Deflection';
			
			case 'Glyphword 37':
			case 'Glyphword 38':
			case 'Glyphword 39':
				return 'Enchant Ability Regeneration';
			
			case 'Glyphword 40':
			case 'Glyphword 41':
			case 'Glyphword 42':
				return 'Enchant Ability Perfection';
			
			case 'Glyphword 43':
			case 'Glyphword 44':
			case 'Glyphword 45':
				return 'Enchant Ability Constitution';
			
			case 'Glyphword 46':
			case 'Glyphword 47':
			case 'Glyphword 48':
				return 'Enchant Ability Assimilation';
			
			case 'Glyphword 49':
			case 'Glyphword 50':
			case 'Glyphword 51':
				return 'Enchant Ability Elation';
			
			case 'Glyphword 52':
			case 'Glyphword 53':
			case 'Glyphword 54':
				return 'Enchant Ability Conservation';
			
			case 'Runeword 1':
			case 'Runeword 2':
			case 'Runeword 3':
				return 'Enchant Ability Glaciation';
			
			case 'Runeword 4':
			case 'Runeword 5':
			case 'Runeword 6':
				return 'Enchant Ability Exhaustion';
			
			case 'Runeword 7':
			case 'Runeword 8':
			case 'Runeword 9':
				return 'Enchant Ability Obliteration';
			
			case 'Runeword 10':
			case 'Runeword 11':
			case 'Runeword 12':
				return 'Enchant Ability Cremation';
			
			case 'Runeword 13':
			case 'Runeword 14':
			case 'Runeword 15':
				return 'Enchant Ability Transmutation';
			
			case 'Runeword 16':
			case 'Runeword 17':
			case 'Runeword 18':
				return 'Enchant Ability Affliction';
			
			case 'Runeword 19':
			case 'Runeword 20':
			case 'Runeword 21':
				return 'Enchant Ability Exsanguination';
			
			case 'Runeword 22':
			case 'Runeword 23':
			case 'Runeword 24':
				return 'Enchant Ability Desperation';
			
			case 'Runeword 25':
			case 'Runeword 26':
			case 'Runeword 27':
				return 'Enchant Ability Reflection';
			
			case 'Runeword 28':
			case 'Runeword 29':
			case 'Runeword 30':
				return 'Enchant Ability Electrocution';
			
			case 'Runeword 31':
			case 'Runeword 32':
			case 'Runeword 33':
				return 'Enchant Ability Exhilaration';
			
			case 'Runeword 34':
			case 'Runeword 35':
			case 'Runeword 36':
				return 'Enchant Ability Assassination';
			
			case 'Runeword 37':
			case 'Runeword 38':
			case 'Runeword 39':
				return 'Enchant Ability Prolongation';
			
			case 'Runeword 40':
			case 'Runeword 41':
			case 'Runeword 42':
				return 'Enchant Ability Invocation';
			
			case 'Runeword 43':
			case 'Runeword 44':
			case 'Runeword 45':
				return 'Enchant Ability Resolution';
			
			case 'Runeword 46':
			case 'Runeword 47':
			case 'Runeword 48':
				return 'Enchant Ability Destruction';
			
			case 'Runeword 49':
			case 'Runeword 50':
			case 'Runeword 51':
				return 'Enchant Ability Penetration';
			
			case 'Runeword 52':
			case 'Runeword 53':
			case 'Runeword 54':
				return 'Enchant Ability Fortification';
			
			case 'Runeword 55':
			case 'Runeword 56':
			case 'Runeword 57':
				return 'Enchant Ability Mutilation';
			
			case 'Runeword 58':
			case 'Runeword 59':
			case 'Runeword 60':
				return 'Enchant Ability Desolation';
			
			default: return '';
		}
	}
	
	public function GetEnchantmentLevel( enchantName : name ) : int
	{
		switch(enchantName)
		{			
			case 'Glyphword 1':
			case 'Glyphword 4':
			case 'Glyphword 7':
			case 'Glyphword 10':
			case 'Glyphword 13':
			case 'Glyphword 16':
			case 'Glyphword 19':
			case 'Glyphword 22':
			case 'Glyphword 25':
			case 'Glyphword 28':
			case 'Glyphword 31':
			case 'Glyphword 34':
			case 'Glyphword 37':
			case 'Glyphword 40':
			case 'Glyphword 43':
			case 'Glyphword 46':
			case 'Glyphword 49':
			case 'Glyphword 52':
			case 'Runeword 1':
			case 'Runeword 4':
			case 'Runeword 7':
			case 'Runeword 10':
			case 'Runeword 13':
			case 'Runeword 16':
			case 'Runeword 19':
			case 'Runeword 22':
			case 'Runeword 25':
			case 'Runeword 28':
			case 'Runeword 31':
			case 'Runeword 34':
			case 'Runeword 37':
			case 'Runeword 40':
			case 'Runeword 43':
			case 'Runeword 46':
			case 'Runeword 49':
			case 'Runeword 52':
			case 'Runeword 55':
			case 'Runeword 58':
				return 1;
			
			case 'Glyphword 2':
			case 'Glyphword 5':
			case 'Glyphword 8':
			case 'Glyphword 11':
			case 'Glyphword 14':
			case 'Glyphword 17':
			case 'Glyphword 20':
			case 'Glyphword 23':
			case 'Glyphword 26':
			case 'Glyphword 29':
			case 'Glyphword 32':
			case 'Glyphword 35':
			case 'Glyphword 38':
			case 'Glyphword 41':
			case 'Glyphword 44':
			case 'Glyphword 47':
			case 'Glyphword 50':
			case 'Glyphword 53':
			case 'Runeword 2':
			case 'Runeword 5':
			case 'Runeword 8':
			case 'Runeword 11':
			case 'Runeword 14':
			case 'Runeword 17':
			case 'Runeword 20':
			case 'Runeword 23':
			case 'Runeword 26':
			case 'Runeword 29':
			case 'Runeword 32':
			case 'Runeword 35':
			case 'Runeword 38':
			case 'Runeword 41':
			case 'Runeword 44':
			case 'Runeword 49':
			case 'Runeword 50':
			case 'Runeword 53':
			case 'Runeword 56':
			case 'Runeword 59':
				return 2;
			
			case 'Glyphword 3':
			case 'Glyphword 6':
			case 'Glyphword 9':
			case 'Glyphword 12':
			case 'Glyphword 15':
			case 'Glyphword 18':
			case 'Glyphword 21':
			case 'Glyphword 24':
			case 'Glyphword 27':
			case 'Glyphword 30':
			case 'Glyphword 33':
			case 'Glyphword 36':
			case 'Glyphword 39':
			case 'Glyphword 42':
			case 'Glyphword 45':
			case 'Glyphword 48':
			case 'Glyphword 51':
			case 'Glyphword 54':
			case 'Runeword 3':
			case 'Runeword 6':
			case 'Runeword 9':
			case 'Runeword 12':
			case 'Runeword 15':
			case 'Runeword 18':
			case 'Runeword 21':
			case 'Runeword 24':
			case 'Runeword 27':
			case 'Runeword 30':
			case 'Runeword 33':
			case 'Runeword 36':
			case 'Runeword 39':
			case 'Runeword 42':
			case 'Runeword 45':
			case 'Runeword 48':
			case 'Runeword 51':
			case 'Runeword 54':
			case 'Runeword 57':
			case 'Runeword 60':
				return 3;
			
			default: return 0;
		}
	}
	
	public function GetEnchantmentNames( runeword : bool ) : array<name>
	{
		var names : array<name>;
		
		if( runeword )
		{
			names.PushBack('Runeword 1 _Stats');
			names.PushBack('Runeword 2 _Stats');
			names.PushBack('Runeword 3 _Stats');
			names.PushBack('Runeword 4 _Stats');
			names.PushBack('Runeword 5 _Stats');
			names.PushBack('Runeword 6 _Stats');
			names.PushBack('Runeword 7 _Stats');
			names.PushBack('Runeword 8 _Stats');
			names.PushBack('Runeword 9 _Stats');
			names.PushBack('Runeword 10 _Stats');
			names.PushBack('Runeword 11 _Stats');
			names.PushBack('Runeword 12 _Stats');
			names.PushBack('Runeword 13 _Stats');
			names.PushBack('Runeword 14 _Stats');
			names.PushBack('Runeword 15 _Stats');
			names.PushBack('Runeword 16 _Stats');
			names.PushBack('Runeword 17 _Stats');
			names.PushBack('Runeword 18 _Stats');
			names.PushBack('Runeword 19 _Stats');
			names.PushBack('Runeword 20 _Stats');
			names.PushBack('Runeword 21 _Stats');
			names.PushBack('Runeword 22 _Stats');
			names.PushBack('Runeword 23 _Stats');
			names.PushBack('Runeword 24 _Stats');
			names.PushBack('Runeword 25 _Stats');
			names.PushBack('Runeword 26 _Stats');
			names.PushBack('Runeword 27 _Stats');
			names.PushBack('Runeword 28 _Stats');
			names.PushBack('Runeword 29 _Stats');
			names.PushBack('Runeword 30 _Stats');
			names.PushBack('Runeword 31 _Stats');
			names.PushBack('Runeword 32 _Stats');
			names.PushBack('Runeword 33 _Stats');
			names.PushBack('Runeword 34 _Stats');
			names.PushBack('Runeword 35 _Stats');
			names.PushBack('Runeword 36 _Stats');
			names.PushBack('Runeword 37 _Stats');
			names.PushBack('Runeword 38 _Stats');
			names.PushBack('Runeword 39 _Stats');
			names.PushBack('Runeword 40 _Stats');
			names.PushBack('Runeword 41 _Stats');
			names.PushBack('Runeword 42 _Stats');
			names.PushBack('Runeword 43 _Stats');
			names.PushBack('Runeword 44 _Stats');
			names.PushBack('Runeword 45 _Stats');
			names.PushBack('Runeword 46 _Stats');
			names.PushBack('Runeword 47 _Stats');
			names.PushBack('Runeword 48 _Stats');
			names.PushBack('Runeword 49 _Stats');
			names.PushBack('Runeword 50 _Stats');
			names.PushBack('Runeword 51 _Stats');
			names.PushBack('Runeword 52 _Stats');
			names.PushBack('Runeword 53 _Stats');
			names.PushBack('Runeword 54 _Stats');
			names.PushBack('Runeword 55 _Stats');
			names.PushBack('Runeword 56 _Stats');
			names.PushBack('Runeword 57 _Stats');
			names.PushBack('Runeword 58 _Stats');
			names.PushBack('Runeword 59 _Stats');
			names.PushBack('Runeword 60 _Stats');
		}
		else
		{
			names.PushBack('Glyphword 1 _Stats');
			names.PushBack('Glyphword 2 _Stats');
			names.PushBack('Glyphword 3 _Stats');
			names.PushBack('Glyphword 4 _Stats');
			names.PushBack('Glyphword 5 _Stats');
			names.PushBack('Glyphword 6 _Stats');
			names.PushBack('Glyphword 7 _Stats');
			names.PushBack('Glyphword 8 _Stats');
			names.PushBack('Glyphword 9 _Stats');
			names.PushBack('Glyphword 10 _Stats');
			names.PushBack('Glyphword 11 _Stats');
			names.PushBack('Glyphword 12 _Stats');
			names.PushBack('Glyphword 13 _Stats');
			names.PushBack('Glyphword 14 _Stats');
			names.PushBack('Glyphword 15 _Stats');
			names.PushBack('Glyphword 16 _Stats');
			names.PushBack('Glyphword 17 _Stats');
			names.PushBack('Glyphword 18 _Stats');
			names.PushBack('Glyphword 19 _Stats');
			names.PushBack('Glyphword 20 _Stats');
			names.PushBack('Glyphword 21 _Stats');
			names.PushBack('Glyphword 22 _Stats');
			names.PushBack('Glyphword 23 _Stats');
			names.PushBack('Glyphword 24 _Stats');
			names.PushBack('Glyphword 25 _Stats');
			names.PushBack('Glyphword 26 _Stats');
			names.PushBack('Glyphword 27 _Stats');
			names.PushBack('Glyphword 28 _Stats');
			names.PushBack('Glyphword 29 _Stats');
			names.PushBack('Glyphword 30 _Stats');
			names.PushBack('Glyphword 31 _Stats');
			names.PushBack('Glyphword 32 _Stats');
			names.PushBack('Glyphword 33 _Stats');
			names.PushBack('Glyphword 34 _Stats');
			names.PushBack('Glyphword 35 _Stats');
			names.PushBack('Glyphword 36 _Stats');
			names.PushBack('Glyphword 37 _Stats');
			names.PushBack('Glyphword 38 _Stats');
			names.PushBack('Glyphword 39 _Stats');
			names.PushBack('Glyphword 40 _Stats');
			names.PushBack('Glyphword 41 _Stats');
			names.PushBack('Glyphword 42 _Stats');
			names.PushBack('Glyphword 43 _Stats');
			names.PushBack('Glyphword 44 _Stats');
			names.PushBack('Glyphword 45 _Stats');
			names.PushBack('Glyphword 46 _Stats');
			names.PushBack('Glyphword 47 _Stats');
			names.PushBack('Glyphword 48 _Stats');
			names.PushBack('Glyphword 49 _Stats');
			names.PushBack('Glyphword 50 _Stats');
			names.PushBack('Glyphword 51 _Stats');
			names.PushBack('Glyphword 52 _Stats');
			names.PushBack('Glyphword 53 _Stats');
			names.PushBack('Glyphword 54 _Stats');
		}
		return names;
	}
	
	public function GetComponentGlyphsFromEnchantment(glyphword : name, glyph : string) : int
	{
		var aard,axii,igni,quen,yrden,bind,free,mend,ward : int;
		aard = 0; axii = 0; igni = 0; quen = 0; yrden = 0; bind = 0; free = 0; mend = 0; ward = 0;
		
		switch(glyphword)
		{
			case 'Glyphword 1': case 'Glyphword 2': case 'Glyphword 3': aard = 2; axii = 1; break;
			
			case 'Glyphword 4': case 'Glyphword 5': case 'Glyphword 6': aard = 2; free = 1; break;
			
			case 'Glyphword 7': case 'Glyphword 8': case 'Glyphword 9': igni = 2; ward = 1; break;
			
			case 'Glyphword 10': case 'Glyphword 11': case 'Glyphword 12': igni = 2; free = 1; break;
			
			case 'Glyphword 13': case 'Glyphword 14': case 'Glyphword 15': yrden = 2; mend = 1; break;
			
			case 'Glyphword 16': case 'Glyphword 17': case 'Glyphword 18': yrden = 2; bind = 1; break;
			
			case 'Glyphword 19': case 'Glyphword 20': case 'Glyphword 21': quen = 2; igni = 1; break;
			
			case 'Glyphword 22': case 'Glyphword 23': case 'Glyphword 24': quen = 2; ward = 1; break;
			
			case 'Glyphword 25': case 'Glyphword 26': case 'Glyphword 27': axii = 2; bind = 1; break;
			
			case 'Glyphword 28': case 'Glyphword 29': case 'Glyphword 30': axii = 2; yrden = 1; break;
			
			case 'Glyphword 31': case 'Glyphword 32': case 'Glyphword 33': ward = 2; bind = 1; break;
			
			case 'Glyphword 34': case 'Glyphword 35': case 'Glyphword 36': ward = 2; quen = 1; break;
			
			case 'Glyphword 37': case 'Glyphword 38': case 'Glyphword 39': mend = 2; bind = 1; break;
			
			case 'Glyphword 40': case 'Glyphword 41': case 'Glyphword 42': mend = 2; ward = 1; break;
			
			case 'Glyphword 43': case 'Glyphword 44': case 'Glyphword 45': bind = 2; axii = 1; break;
			
			case 'Glyphword 46': case 'Glyphword 47': case 'Glyphword 48': bind = 2; mend = 1; break;
			
			case 'Glyphword 49': case 'Glyphword 50': case 'Glyphword 51': free = 2; aard = 1; break;
				
			case 'Glyphword 52': case 'Glyphword 53': case 'Glyphword 54': free = 2; mend = 1; break;
		}
		switch(glyph)
		{
			case "aard": return aard;
			case "axii": return axii;
			case "igni": return igni;
			case "quen": return quen;
			case "yrden": return yrden;
			case "binding": return bind;
			case "warding": return free;
			case "mending": return mend;
			case "reinforcement": return ward;
			default: return 0;
		}
	}
	
	public function ManageEnchantmentAbilities( item : SItemUniqueId, enchantName : name, add : bool )
	{
		var i, targetCount : int;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var abilityName : name;
		var enchantString : string;
		
		if( enchantName == '' )
			return;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		enchantString = NameToString(enchantName);
		abilityName = GetEnchantmentAbilityFromName(enchantName);
		
		targetCount = GetEnchantmentLevel(enchantName);
		/*if( witcher.IsSetBonusActive(EISB_Ofieri) )
			targetCount += 2;*/
		
		if( StrContains(enchantString, "Glyphword") )
		{
			witcher.RemoveAbilityAll(abilityName);
			witcher.RemoveBuff(EET_GlyphwordPerfection);
			if( add )
			{
				//witcher.AddAbilityMultiple(abilityName, targetCount);
				//theGame.GetGuiManager().ShowNotification("Adding: " + targetCount + " " + NameToString(abilityName));
			}
		}
		if( StrContains(enchantString, "Runeword") )
		{
			inv.RemoveItemCraftedAbility(item, abilityName);
			inv.RemoveItemCraftedAbility(item, abilityName);
			inv.RemoveItemCraftedAbility(item, abilityName);
			inv.RemoveItemCraftedAbility(item, abilityName);
			inv.RemoveItemCraftedAbility(item, abilityName);
			witcher.RemoveBuff(EET_RunewordObliteration);
			witcher.RemoveBuff(EET_RunewordElectrocution);
			witcher.RemoveAbilityAll('Runeword 27 Ability');
			witcher.RemoveAbilityAll('Runeword 32 Ability');
			witcher.RemoveAbilityAll('Runeword 36 Ability');
			if( add )
			{
				/*for( i = 0; i < targetCount; i += 1)
				{
					inv.AddItemCraftedAbility(item, abilityName, true);
					//theGame.GetGuiManager().ShowNotification("Adding: " + targetCount + " " + NameToString(abilityName));
				}*/
				if( abilityName == 'Enchant Ability Obliteration' )
					witcher.AddEffectDefault(EET_RunewordObliteration, witcher, "Runeword7", false);
				if( enchantName == 'Runeword 30' )
					witcher.AddEffectDefault(EET_RunewordElectrocution, witcher, "Runeword30", false);
				if( enchantName == 'Runeword 36' )
					witcher.AddAbility('Runeword 36 Ability');
			}
			
			witcher.AddTimer('ManageDestructionVisuals', 1.5f,,,,,true);
		}
		
		//witcher.AddTimer('DelayedCheckEnchantmentabilities', 3.f,,,,,true);
	}
	
	public function CheckEnchantmentAbilities(optional fix : bool)
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var armor, sword : SItemUniqueId;
		var unarmed, errorFound : bool;
		var enchant : name;
		var allEnchantNames, currentEnchantNames, validEnchantNames, itemAbilityNames : array<name>;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		errorFound = false;
		
		inv.GetItemEquippedOnSlot( EES_Armor, armor );
		
		enchant = inv.GetEnchantment(armor);
		if( getEnchamtmentStatName(enchant) != '' )
			validEnchantNames.PushBack(getEnchamtmentStatName(enchant));
		
		currentEnchantNames = GetEnchantmentNames(false);
		ArrayOfNamesAppend(allEnchantNames, currentEnchantNames);
		
		inv.GetItemAbilities(armor, itemAbilityNames);
		
		for( i = 0; i < allEnchantNames.Size(); i += 1)
		{
			if( itemAbilityNames.Contains(allEnchantNames[i]) && !validEnchantNames.Contains(allEnchantNames[i]) )
			{
				if( fix )
					inv.RemoveItemBaseAbility(armor, allEnchantNames[i]);
				else
					//theGame.GetGuiManager().ShowNotification("Unexpected Enchantment Found on Armor: " + allEnchantNames[i]);
					theGame.GetGuiManager().ShowNotification("Unexpected enchantment found.<br>Reload with no swords drawn.");
				errorFound = true;
			}
		}
		
		if( witcher.GetCurrentMeleeWeaponType() == PW_Steel )
			inv.GetItemEquippedOnSlot( EES_SteelSword, sword );
		else if( witcher.GetCurrentMeleeWeaponType() == PW_Silver )
			inv.GetItemEquippedOnSlot( EES_SilverSword, sword );
		else
			unarmed = true;
		
		currentEnchantNames.Clear();
		currentEnchantNames = GetEnchantmentNames(true);
		ArrayOfNamesAppend(allEnchantNames, currentEnchantNames);
		itemAbilityNames.Clear();
		
		if( !unarmed )
		{
			enchant = inv.GetEnchantment(sword);
			if( getEnchamtmentStatName(enchant) != '' )
				validEnchantNames.PushBack(getEnchamtmentStatName(enchant));
			
			inv.GetItemAbilities(sword, itemAbilityNames);
			
			for( i = 0; i < allEnchantNames.Size(); i += 1)
			{
				if( itemAbilityNames.Contains(allEnchantNames[i]) && !validEnchantNames.Contains(allEnchantNames[i]) )
				{
					if( fix )
						inv.RemoveItemBaseAbility(sword, allEnchantNames[i]);
					else
						//theGame.GetGuiManager().ShowNotification("Unexpected Enchantment Found on Sword: " + allEnchantNames[i]);
						theGame.GetGuiManager().ShowNotification("Unexpected enchantment found.<br>Reload with no swords drawn.");
					errorFound = true;
				}
			}
		}
		
		for( i = 0; i < allEnchantNames.Size(); i += 1)
		{
			if( witcher.HasAbility(allEnchantNames[i], true) && !validEnchantNames.Contains(allEnchantNames[i]) )
			{
				if( fix )
					witcher.RemoveAbilityAll(allEnchantNames[i]);
				else
					//theGame.GetGuiManager().ShowNotification("Unexpected Enchantment Found on Player: " + allEnchantNames[i]);
					theGame.GetGuiManager().ShowNotification("Unexpected enchantment found.<br>Reload with no swords drawn.");
				errorFound = true;
			}
		}
		
		/*if( !errorFound && !fix )
			theGame.GetGuiManager().ShowNotification("All Valid");*/
	}
	
	//Kolaris - Protection
	public function GlyphwordProtectionCheck(damage : float) : bool
	{
		var armor : SItemUniqueId;
		var durability : float;
		var inv : CInventoryComponent;
		
		GetWitcherPlayer().GetItemEquippedOnSlot(EES_Armor, armor);
		inv = GetWitcherPlayer().GetInventory();
		durability = inv.GetItemDurability(armor);
		if( durability > damage / 75 )
		{
			GetWitcherPlayer().PlayEffect('glyphword_reflection');
			inv.SetItemDurabilityScript(armor, durability - damage / 75);
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function UpgradeMeteoriteArmor( upgradeType : EShrineBuffs )
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var meteoriteArmors : array <SItemUniqueId>;
		
		witcher = GetWitcherPlayer();
		if( witcher.IsSetBonusActive(EISB_Meteorite) )
		{
			inv = witcher.GetInventory();
			meteoriteArmors = inv.GetItemsByTag('MeteoriteSetTag');
			switch(upgradeType)
			{
				case ESB_Yrden:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteBoots') && !inv.ItemHasAbility(meteoriteArmors[i], 'MeteoriteYrdenUpgrade') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteYrdenUpgrade', false);
				break;
				
				case ESB_Quen:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoritePants') && !inv.ItemHasAbility(meteoriteArmors[i], 'MeteoriteQuenUpgrade') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteQuenUpgrade', false);
				break;
				
				case ESB_Igni:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmor') && !inv.ItemHasAbility(meteoriteArmors[i], 'MeteoriteIgniUpgrade') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteIgniUpgrade', false);
				break;
				
				case ESB_Axii:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmor') && !inv.ItemHasAbility(meteoriteArmors[i], 'MeteoriteAxiiUpgrade') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteAxiiUpgrade', false);
				break;
				
				case ESB_Aard:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteGloves') && !inv.ItemHasAbility(meteoriteArmors[i], 'MeteoriteAardUpgrade') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteAardUpgrade', false);
				break;
			}
		}
	}
	
	public function FactsSetValue( ID : string, value : int )
	{
		FactsRemove(ID);
		FactsAdd(ID, value, -1);
	}
	
	public function ProcessDecoctionFormulas( itemName : name )
	{
		switch(itemName)
		{
			case 'Cursed Monsters vol 1':
			case 'Cursed Monsters vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("CursedRead", FactsQueryLatestValue("CursedRead") + 1);
				if( FactsQueryLatestValue("CursedRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 4', false, false);
			break;
			
			case 'Draconides vol 1':
			case 'Draconides vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("DraconidesRead", FactsQueryLatestValue("DraconidesRead") + 1);
				if( FactsQueryLatestValue("DraconidesRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 8', false, false);
			break;
			
			case 'Hybrid Monsters vol 1':
			case 'Hybrid Monsters vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("HybridRead", FactsQueryLatestValue("HybridRead") + 1);
				if( FactsQueryLatestValue("HybridRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 9', false, false);
			break;
			
			case 'Insectoids vol 1':
			case 'Insectoids vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("InsectoidsRead", FactsQueryLatestValue("InsectoidsRead") + 1);
				if( FactsQueryLatestValue("InsectoidsRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 10', false, false);
			break;
			
			case 'Magical Monsters vol 1':
			case 'Magical Monsters vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("MagicalRead", FactsQueryLatestValue("MagicalRead") + 1);
				if( FactsQueryLatestValue("MagicalRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 5', false, false);
			break;
			
			case 'Necrophage vol 1':
			case 'Necrophage vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("NecrophageRead", FactsQueryLatestValue("NecrophageRead") + 1);
				if( FactsQueryLatestValue("NecrophageRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 2', false, false);
			break;
			
			case 'Relict Monsters vol 1':
			case 'Relict Monsters vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("RelictRead", FactsQueryLatestValue("RelictRead") + 1);
				if( FactsQueryLatestValue("RelictRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 7', false, false);
			break;
			
			case 'Specters vol 1':
			case 'Specters vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("SpectersRead", FactsQueryLatestValue("SpectersRead") + 1);
				if( FactsQueryLatestValue("SpectersRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 6', false, false);
			break;
			
			case 'Ogres vol 1':
			case 'Ogres vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("OgresRead", FactsQueryLatestValue("OgresRead") + 1);
				if( FactsQueryLatestValue("OgresRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 3', false, false);
			break;
			
			case 'Vampires vol 1':
			case 'Vampires vol 2':
				Experience().AwardAlchemyBrewingXP(2, false, false, false, false, false, true);
				FactsSetValue("VampiresRead", FactsQueryLatestValue("VampiresRead") + 1);
				if( FactsQueryLatestValue("VampiresRead") > 1 )
					GetWitcherPlayer().AddAlchemyRecipe('Recipe for Decoction 1', false, false);
			break;
			
			default : break;
		}
	}
	
	public function ArtifactNameToSchematicName(artifactName : name) : name
	{
		switch(artifactName)
		{
			case 'Arbitrator artifact'						: return 'Arbitrator schematic';
			case 'Devine artifact'							: return 'Devine schematic';
			case 'Longclaw artifact'						: return 'Longclaw schematic';
			case 'Beannshie artifact'						: return 'Beannshie schematic';
			case 'Blackunicorn artifact'					: return 'Blackunicorn schematic';
			case 'Inis artifact'							: return 'Inis schematic';
			case 'Ardaenye artifact'						: return 'Ardaenye schematic';
			case 'Barbersurgeon artifact'					: return 'Barbersurgeon schematic';
			case 'Caerme artifact'							: return 'Caerme schematic';
			case 'Deireadh artifact'						: return 'Deireadh schematic';
			case 'Gwyhyr artifact'							: return 'Gwyhyr schematic';
			case 'Princessxenthiasword artifact'			: return 'Princessxenthiasword schematic';
			case 'Robustswordofdolblathanna artifact'		: return 'Robustswordofdolblathanna schematic';
			case 'Headtaker artifact'						: return 'Headtaker schematic';
			case 'Ultimatum artifact'						: return 'Ultimatum schematic';
			case 'Lune artifact'							: return 'Lune schematic';
			case 'Gloryofthenorth artifact'					: return 'Gloryofthenorth schematic';
			case 'Torlara artifact'							: return 'Torlara schematic';
			case 'Harpy artifact'							: return 'Harpy schematic';
			case 'Negotiator artifact'						: return 'Negotiator schematic';
			case 'Weeper artifact'							: return 'Weeper schematic';
			case 'Azurewrath artifact'						: return 'Azurewrath schematic';
			case 'Bloodsword artifact'						: return 'Bloodsword schematic';
			case 'Naevdeseidhe artifact'					: return 'Naevdeseidhe schematic';
			case 'Zerrikanterment artifact'					: return 'Zerrikanterment schematic';
			case 'Reachofthedamned artifact'				: return 'Reachofthedamned schematic';
			case 'Havcaaren artifact'						: return 'Havcaaren schematic';
			case 'Virgin artifact'							: return 'Virgin schematic';
			case 'Tlareg artifact'							: return 'Tlareg schematic';
			case 'EP1 Crafted Witcher Silver Sword artifact': return 'EP1 Crafted Witcher Silver Sword schematic';
			case 'Knights steel sword 3 artifact'			: return 'Knights steel sword 3 schematic';
			default : return '';
		}
	}
	
	public function AddArtifactSchematic(itemID : SItemUniqueId, inv : CInventoryComponent)
	{	
		GetWitcherPlayer().AddCraftingSchematic(ArtifactNameToSchematicName(inv.GetItemName(itemID)));
	}

	public function GetRandomArtifactName() : name
	{
		var i : int;
		var artifactsArray, artifactArray : array<name>;
		
		artifactsArray.PushBack('Arbitrator artifact');
		artifactsArray.PushBack('Devine artifact');
		artifactsArray.PushBack('Longclaw artifact');
		artifactsArray.PushBack('Beannshie artifact');
		artifactsArray.PushBack('Blackunicorn artifact');
		artifactsArray.PushBack('Inis artifact');
		artifactsArray.PushBack('Ardaenye artifact');
		artifactsArray.PushBack('Barbersurgeon artifact');
		artifactsArray.PushBack('Caerme artifact');
		artifactsArray.PushBack('Deireadh artifact');
		artifactsArray.PushBack('Gwyhyr artifact');
		artifactsArray.PushBack('Princessxenthiasword artifact');
		artifactsArray.PushBack('Robustswordofdolblathanna artifact');
		artifactsArray.PushBack('Headtaker artifact');
		artifactsArray.PushBack('Ultimatum artifact');
		artifactsArray.PushBack('Lune artifact');
		artifactsArray.PushBack('Gloryofthenorth artifact');
		artifactsArray.PushBack('Torlara artifact');
		artifactsArray.PushBack('Harpy artifact');
		artifactsArray.PushBack('Negotiator artifact');
		artifactsArray.PushBack('Weeper artifact');
		artifactsArray.PushBack('Azurewrath artifact');
		artifactsArray.PushBack('Bloodsword artifact');
		artifactsArray.PushBack('Naevdeseidhe artifact');
		artifactsArray.PushBack('Zerrikanterment artifact');
		artifactsArray.PushBack('Reachofthedamned artifact');
		artifactsArray.PushBack('Havcaaren artifact');
		artifactsArray.PushBack('Virgin artifact');
		artifactsArray.PushBack('Tlareg artifact');
		//artifactsArray.PushBack('EP1 Crafted Witcher Silver Sword artifact');
		//artifactsArray.PushBack('Knights steel sword 3 artifact');
		
		for(i=0; i<artifactsArray.Size(); i+=1)
		{
			if( !FactsDoesExist('modNoDuplicates' + artifactsArray[i]) )
				artifactArray.PushBack(artifactsArray[i]);
		}
		
		if( artifactArray.Size() > 0 )
			return artifactArray[RandRange(artifactArray.Size(), 0)];
			
		return '';
	}
	
	public function GetRandomGemName() : name
	{
		var gemArray : array<name>; 
		
		gemArray.PushBack('Amber flawless');
		gemArray.PushBack('Diamond flawless');
		gemArray.PushBack('Amethyst flawless');
		gemArray.PushBack('Emerald flawless');
		gemArray.PushBack('Ruby flawless');
		gemArray.PushBack('Sapphire flawless');
		
		return gemArray[RandRange(gemArray.Size(), 0)];
	}
	
	//Kolaris - Fixed Stashes
	public function IsStashableItem(inv : CInventoryComponent, item : SItemUniqueId) : bool
	{
		if( inv.IsItemWeapon(item) || inv.IsItemAnyArmor(item) || inv.IsItemHorseItem(item) && !inv.ItemHasTag(item, 'RER_Trophy') )
			return true;
		else
			return false;
	}
	
	public function IsStashableIngredient(itemName : name) : bool
	{
		var upgradeListName : name;
		
		upgradeListName = theGame.GetDefinitionsManager().GetItemUpgradeListName(itemName, false);
		
		if( theGame.GetDefinitionsManager().IsItemIngredient(itemName) && theGame.GetDefinitionsManager().IsItemIngredient(upgradeListName) )
			return true;
		else
			return false;
	}
	
	public function GetItemStashVariant(itemName : name) : name
	{
		return theGame.GetDefinitionsManager().GetItemUpgradeListName( itemName, false );
	}
	
	//Kolaris - Dol Blathanna Set
	public function GetRandomHerbName() : name
	{
		var herbArray : array<name>;
		var nameCheck : name;
		
		herbArray = theGame.GetDefinitionsManager().GetItemsWithTag('primer_herb');
		nameCheck = herbArray[RandRange(herbArray.Size(), 0)];
		if( theGame.GetDefinitionsManager().ItemHasTag(nameCheck, 'StashVariant') )
			return GetItemStashVariant(nameCheck);
		else
			return nameCheck;
	}
	
	//Kolaris - Netflix Set
	public function GetNetflixPotionAbility(originalName : name) : name
	{
		switch(originalName)
		{
			case 'BlackBloodEffect_Level1': return 'BlackBloodEffectNetflix_Level1';
			case 'BlackBloodEffect_Level2': return 'BlackBloodEffectNetflix_Level2';
			case 'BlackBloodEffect_Level3': return 'BlackBloodEffectNetflix_Level3';
			case 'BlizzardEffect_Level1': return 'BlizzardEffectNetflix_Level1';
			case 'BlizzardEffect_Level2': return 'BlizzardEffectNetflix_Level2';
			case 'BlizzardEffect_Level3': return 'BlizzardEffectNetflix_Level3';
			case 'CatEffect_Level1': return 'CatEffectNetflix_Level1';
			case 'CatEffect_Level2': return 'CatEffectNetflix_Level2';
			case 'CatEffect_Level3': return 'CatEffectNetflix_Level3';
			case 'FullMoonEffect_Level1': return 'FullMoonEffectNetflix_Level1';
			case 'FullMoonEffect_Level2': return 'FullMoonEffectNetflix_Level2';
			case 'FullMoonEffect_Level3': return 'FullMoonEffectNetflix_Level3';
			case 'GoldenOrioleEffect_Level1': return 'GoldenOrioleEffectNetflix_Level1';
			case 'GoldenOrioleEffect_Level2': return 'GoldenOrioleEffectNetflix_Level2';
			case 'GoldenOrioleEffect_Level3': return 'GoldenOrioleEffectNetflix_Level3';
			case 'TiaraEffect_Level1': return 'TiaraEffectNetflix_Level1';
			case 'TiaraEffect_Level2': return 'TiaraEffectNetflix_Level2';
			case 'TiaraEffect_Level3': return 'TiaraEffectNetflix_Level3';
			case 'MariborForestEffect_Level1': return 'MariborForestEffectNetflix_Level1';
			case 'MariborForestEffect_Level2': return 'MariborForestEffectNetflix_Level2';
			case 'MariborForestEffect_Level3': return 'MariborForestEffectNetflix_Level3';
			case 'PetriPhiltreEffect_Level1': return 'PetriPhiltreEffectNetflix_Level1';
			case 'PetriPhiltreEffect_Level2': return 'PetriPhiltreEffectNetflix_Level2';
			case 'PetriPhiltreEffect_Level3': return 'PetriPhiltreEffectNetflix_Level3';
			case 'SwallowEffect_Level1': return 'SwallowEffectNetflix_Level1';
			case 'SwallowEffect_Level2': return 'SwallowEffectNetflix_Level2';
			case 'SwallowEffect_Level3': return 'SwallowEffectNetflix_Level3';
			case 'TawnyOwlEffect_Level1': return 'TawnyOwlEffectNetflix_Level1';
			case 'TawnyOwlEffect_Level2': return 'TawnyOwlEffectNetflix_Level2';
			case 'TawnyOwlEffect_Level3': return 'TawnyOwlEffectNetflix_Level3';
			case 'ThunderboltEffect_Level1': return 'ThunderboltEffectNetflix_Level1';
			case 'ThunderboltEffect_Level2': return 'ThunderboltEffectNetflix_Level2';
			case 'ThunderboltEffect_Level3': return 'ThunderboltEffectNetflix_Level3';
			case 'WhiteRaffardDecoctionEffect_Level1': return 'WhiteRaffardDecoctionEffectNetflix_Level1';
			case 'WhiteRaffardDecoctionEffect_Level2': return 'WhiteRaffardDecoctionEffectNetflix_Level2';
			case 'WhiteRaffardDecoctionEffect_Level3': return 'WhiteRaffardDecoctionEffectNetflix_Level3';
			case 'Decoction1Effect': return 'Decoction1EffectNetflix';
			case 'Decoction2Effect': return 'Decoction2EffectNetflix';
			case 'Decoction3Effect': return 'Decoction3EffectNetflix';
			case 'Decoction4Effect': return 'Decoction4EffectNetflix';
			case 'Decoction5Effect': return 'Decoction5EffectNetflix';
			case 'Decoction6Effect': return 'Decoction6EffectNetflix';
			case 'Decoction7Effect': return 'Decoction7EffectNetflix';
			case 'Decoction8Effect': return 'Decoction8EffectNetflix';
			case 'Decoction9Effect': return 'Decoction9EffectNetflix';
			case 'Decoction10Effect': return 'Decoction10EffectNetflix';
			default: return '';
		}
	}
	
	public function GetNetflixDecoctionAbility(itemName : name) : name
	{
		switch(itemName)
		{
			case 'Decoction 1': return 'Decoction1EffectNetflix';
			case 'Decoction 2': return 'Decoction2EffectNetflix';
			case 'Decoction 3': return 'Decoction3EffectNetflix';
			case 'Decoction 4': return 'Decoction4EffectNetflix';
			case 'Decoction 5': return 'Decoction5EffectNetflix';
			case 'Decoction 6': return 'Decoction6EffectNetflix';
			case 'Decoction 7': return 'Decoction7EffectNetflix';
			case 'Decoction 8': return 'Decoction8EffectNetflix';
			case 'Decoction 9': return 'Decoction9EffectNetflix';
			case 'Decoction 10': return 'Decoction10EffectNetflix';
			default: return '';
		}
	}
	
	public function SetStartingGear()
	{
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		
		//Kolaris - Mutation Rework
		witcher.MutationSystemEnable(true);
		
		witcher.inv.AddAnItem('ThrowingKnife schematic', 1);
		witcher.inv.AddAndEquipItem('Swallow 1', EES_Potion1, 1);
		witcher.inv.AddAndEquipItem('White Honey 1', EES_Potion2, 1);
		witcher.inv.AddAndEquipItem('Blizzard 2 Nigredo', EES_Potion3, 1);
		witcher.inv.AddAndEquipItem('Full Moon 2 Rubedo', EES_Potion4, 1);
		witcher.inv.AddAnItem('Tiara 2 Albedo', 1);
		witcher.inv.AddAnItem('Tawny Owl 3', 1);
		witcher.inv.AddAnItem('Swallow 3', 1);
		witcher.inv.AddAndEquipItem('Samum 1', EES_Petard1, 2);
		witcher.inv.AddAndEquipItem('Grapeshot 1', EES_Petard2, 1);
		witcher.SetSelectedItemId(witcher.inv.AddAndEquipItem('ThrowingKnife', EES_Petard3, 20));
		witcher.inv.AddAnItem('Bomb casing', 3);
		witcher.inv.AddAnItem('Brown Oil 1', 1);
		witcher.inv.AddAnItem('Poisonous Oil 2', 1);
		witcher.inv.AddAnItem('Silver Oil 1', 1);
		witcher.inv.AddAnItem('Ghoul mutagen', 1);

		
		//Kolaris - Seasoned Witcher Mode
		FactsAdd("SWMIntroComplete", 1);
		if( FactsQuerySum("SeasonedWitcherMode") > 0 )
		{
			witcher.inv.AddAndEquipItem('Long Steel Sword 1', EES_SteelSword, 1);
			witcher.inv.RemoveItemByName('Long Steel Sword', 1);
			witcher.inv.AddAndEquipItem('Witcher Silver Sword 1', EES_SilverSword, 1);
			witcher.inv.RemoveItemByName('Witcher Silver Sword', 1);
			witcher.inv.AddAndEquipItem('Starting Armor 1', EES_Armor, 1);
			witcher.inv.RemoveItemByName('Starting Armor', 1);
			witcher.inv.AddAndEquipItem('Starting Pants 1', EES_Pants, 1);
			witcher.inv.RemoveItemByName('Starting Pants', 1);
			witcher.inv.AddAndEquipItem('Starting Boots 1', EES_Boots, 1);
			witcher.inv.RemoveItemByName('Starting Boots', 1);
			witcher.inv.AddAndEquipItem('Starting Gloves 1', EES_Gloves, 1);
			witcher.inv.RemoveItemByName('Starting Gloves', 1);
			witcher.inv.AddAnItem('Clearing Potion');
		}
	}
	
	//Kolaris - Mutation Rework
	public function GetBaseMutagenForMutation(mutationID : EPlayerMutationType) : name
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		var horseInv : CInventoryComponent = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		var items, horseItems  : array<SItemUniqueId>;
		var baseMutagenName : name = 'None';
		
		switch(mutationID)
		{
			case EPMT_Mutation1:
			items = inv.GetItemsByName('Spectre mutagen greater');
			horseItems = horseInv.GetItemsByName('Spectre mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Spectre mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Spectre mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Spectre mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Spectre mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Spectre mutagen');
			horseItems = horseInv.GetItemsByName('Spectre mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Spectre mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenSpectre');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenSpectre');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation2:
			items = inv.GetItemsByName('Elemental mutagen greater');
			horseItems = horseInv.GetItemsByName('Elemental mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Elemental mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Elemental mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Elemental mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Elemental mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Elemental mutagen');
			horseItems = horseInv.GetItemsByName('Elemental mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Elemental mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenElemental');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenElemental');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation3:
			items = inv.GetItemsByName('Necrophage mutagen greater');
			horseItems = horseInv.GetItemsByName('Necrophage mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Necrophage mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Necrophage mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Necrophage mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Necrophage mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Necrophage mutagen');
			horseItems = horseInv.GetItemsByName('Necrophage mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Necrophage mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenNecrophage');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenNecrophage');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation4:
			items = inv.GetItemsByName('Draconid mutagen greater');
			horseItems = horseInv.GetItemsByName('Draconid mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Draconid mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Draconid mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Draconid mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Draconid mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Draconid mutagen');
			horseItems = horseInv.GetItemsByName('Draconid mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Draconid mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenDraconid');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenDraconid');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation5:
			items = inv.GetItemsByName('Insectoid mutagen greater');
			horseItems = horseInv.GetItemsByName('Insectoid mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Insectoid mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Insectoid mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Insectoid mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Insectoid mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Insectoid mutagen');
			horseItems = horseInv.GetItemsByName('Insectoid mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Insectoid mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenInsectoid');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenInsectoid');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation6:
			items = inv.GetItemsByName('Relic mutagen greater');
			horseItems = horseInv.GetItemsByName('Relic mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Relic mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Relic mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Relic mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Relic mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Relic mutagen');
			horseItems = horseInv.GetItemsByName('Relic mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Relic mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenRelic');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenRelic');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation7:
			items = inv.GetItemsByName('Cursed mutagen greater');
			horseItems = horseInv.GetItemsByName('Cursed mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Cursed mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Cursed mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Cursed mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Cursed mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Cursed mutagen');
			horseItems = horseInv.GetItemsByName('Cursed mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Cursed mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenCursed');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenCursed');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation8:
			items = inv.GetItemsByName('Ogroid mutagen greater');
			horseItems = horseInv.GetItemsByName('Ogroid mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Ogroid mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Ogroid mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Ogroid mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Ogroid mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Ogroid mutagen');
			horseItems = horseInv.GetItemsByName('Ogroid mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Ogroid mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenOgroid');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenOgroid');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation9:
			items = inv.GetItemsByName('Vampire mutagen greater');
			horseItems = horseInv.GetItemsByName('Vampire mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Vampire mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Vampire mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Vampire mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Vampire mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Vampire mutagen');
			horseItems = horseInv.GetItemsByName('Vampire mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Vampire mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenVampire');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenVampire');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			case EPMT_Mutation10:
			items = inv.GetItemsByName('Hybrid mutagen greater');
			horseItems = horseInv.GetItemsByName('Hybrid mutagen greater');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Hybrid mutagen greater';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Hybrid mutagen enhanced');
			horseItems = horseInv.GetItemsByName('Hybrid mutagen enhanced');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Hybrid mutagen enhanced';
				return baseMutagenName;
			}
			items = inv.GetItemsByName('Hybrid mutagen');
			horseItems = horseInv.GetItemsByName('Hybrid mutagen');
			if( items.Size() > 0 || horseItems.Size() > 0 )
			{
				baseMutagenName = 'Hybrid mutagen';
				return baseMutagenName;
			}
			items = inv.GetItemsByTag('MonsterMutagenHybrid');
			if( items.Size() > 0 )
			{
				baseMutagenName = inv.GetItemName(items[0]);
				return baseMutagenName;
			}
			horseItems = horseInv.GetItemsByTag('MonsterMutagenHybrid');
			if( horseItems.Size() > 0 )
			{
				baseMutagenName = horseInv.GetItemName(horseItems[0]);
				return baseMutagenName;
			}
			return baseMutagenName;
			
			default:
			return baseMutagenName;
		}
	}
	
	public function GetMutationCostMult(mutationID : EPlayerMutationType, baseMutagen : name) : float
	{
		var mult, baseMult : float;
		var playerWitcher : W3PlayerWitcher = GetWitcherPlayer();
		
		mult = 1.f;
		if( mutationID == EPMT_Mutation11 || mutationID == EPMT_Mutation12 )
			baseMult = 2.f;
		else if( baseMutagen == 'None' )
			baseMult = 5.f;
		else
		{
			baseMult = 5.f - theGame.GetDefinitionsManager().GetItemQuality(baseMutagen);
			if( !theGame.GetDefinitionsManager().ItemHasTag(baseMutagen, 'archetype_mutagen') )
				baseMult += 1.f;
		}
		
		switch(mutationID)
		{
			case EPMT_Mutation1:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation6) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation2:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation6) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation3:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation7) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation8) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation9) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation4:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation10) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation5:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation10) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation6:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation1) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation2) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation7) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation7:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation3) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation6) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation11) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation8:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation3) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation9:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation3) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation10) )
				mult -= 0.1f;
			if( playerWitcher.IsMutationResearched(EPMT_Mutation12) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation10:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation5) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation11:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation7) )
				mult -= 0.1f;
			break;
			
			case EPMT_Mutation12:
			if( playerWitcher.IsMutationResearched(EPMT_Mutation9) )
				mult -= 0.1f;
			break;
		}
		
		if( playerWitcher.GetSkillLevel(S_Alchemy_s19) >= 4 )
			mult -= 0.4f;
		else if( playerWitcher.GetSkillLevel(S_Alchemy_s19) >= 2 )
			mult -= 0.2f;
		
		return mult * baseMult;
	}
	
	public function GetRequiredMutagensString( baseMutagen : name ) : string
	{
		var ret : string;
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		var mult : int;
		
		if( baseMutagen == 'None' )
			mult = 5;
		else
		{
			mult = 5 - theGame.GetDefinitionsManager().GetItemQuality(baseMutagen);
			if( !theGame.GetDefinitionsManager().ItemHasTag(baseMutagen, 'archetype_mutagen') )
				mult += 1;
		}
		
		ret = "<font color=\"#aa9578\">";
		ret += "<br>" + GetLocStringByKeyExt("Redux_MutationBaseMutagen");
		if( baseMutagen != 'None' )
			ret += GetLocStringByKeyExt(inv.GetItemLocalizedNameByName(baseMutagen));
		else
			ret += GetLocStringByKeyExt("Redux_MutationNoneMutagen");
		if( mult > 1 )
			ret += "<br>" + GetLocStringByKeyExt("Redux_MutationMultMutagen") + (mult - 1) * 100 + "%";
		ret += "</font>";
		
		return ret;
	}
	
	//Kolaris - Dynamic Witcher Schematics
	public function IsDWSInstalled() : bool
	{
		var DWSTestItemIDs : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		DWSTestItemIDs = inv.AddAnItem('DWSTestItem', 1, true, true, false);
		
		if( inv.IsIdValid(DWSTestItemIDs[0]) )
		{
			inv.RemoveItem(DWSTestItemIDs[0], 1);
			return true;
		}
		else
			return false;
	}
	
	public function ManageOldSchematics(optional type : string)
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var knownSchematics : array< name >;
		
		dm = theGame.GetDefinitionsManager();
		knownSchematics = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		if( type != "" )
		{
			for(i=0; i<knownSchematics.Size(); i+= 1)
			{
				if( dm.GetItemQuality(knownSchematics[i]) >= 5 && StrContains(NameToString(knownSchematics[i]), type) )
				{
					ManageWitcherSchematics(knownSchematics[i]);
				}
			}
		}
		else
		{
			for(i=0; i<knownSchematics.Size(); i+= 1)
			{
				if( dm.GetItemQuality(knownSchematics[i]) >= 5 )
				{
					ManageWitcherSchematics(knownSchematics[i]);
				}
			}
		}
		
		FactsAdd("DWS_initialized", 1, -1);
	}
	
	public function ManageWitcherSchematics(itemName : name)
	{
		var witcher : W3PlayerWitcher;
		var knownSchematics : array< name >;
		var schematicToAdd : name;
		
		if(StrContains(NameToString(itemName), "Crossbow"))
			return;
		if(StrContains(NameToString(itemName), "EP1") && !StrContains(NameToString(itemName), "Viper"))
			return;
		if(StrContains(NameToString(itemName), "Red Wolf"))
			return;
		if(StrContains(NameToString(itemName), "Netflix"))
			return;
		
		witcher = GetWitcherPlayer();
		knownSchematics = witcher.GetCraftingSchematicsNames();
		
		if(StrContains(NameToString(itemName), "Viper"))
		{
			if(StrContains(NameToString(itemName), "teel"))
			{
				if( !(knownSchematics.Contains('Viper Steel sword schematic DWS')))
				{
					schematicToAdd = 'Viper Steel sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School steel sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Viper School steel sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School steel sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Viper School steel sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School steel sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Viper School steel sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School steel sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Viper School steel sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else if(StrContains(NameToString(itemName), "ilver"))
			{
				if( !(knownSchematics.Contains('Viper Silver sword schematic DWS')))
				{
					schematicToAdd = 'Viper Silver sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School silver sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Viper School silver sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School silver sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Viper School silver sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School silver sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Viper School silver sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Viper School silver sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Viper School silver sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
		}
		else if(StrContains(NameToString(itemName), "Lynx"))
		{
			if(StrContains(NameToString(itemName), "steel"))
			{
				if( !(knownSchematics.Contains('Lynx School steel sword schematic DWS')))
				{
					schematicToAdd = 'Lynx School steel sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School steel sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Lynx School steel sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School steel sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Lynx School steel sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School steel sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Lynx School steel sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School steel sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Lynx School steel sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "silver"))
			{
				if( !(knownSchematics.Contains('Lynx School silver sword schematic DWS')))
				{
					schematicToAdd = 'Lynx School silver sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School silver sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Lynx School silver sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School silver sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Lynx School silver sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School silver sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Lynx School silver sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Lynx School silver sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Lynx School silver sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Pants"))
			{
				if( !(knownSchematics.Contains('Lynx Pants schematic DWS')))
				{
					schematicToAdd = 'Lynx Pants schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Pants Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Pants Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Pants Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Pants Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Pants Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Pants Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Pants Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Pants Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Boots"))
			{
				if( !(knownSchematics.Contains('Lynx Boots schematic DWS')))
				{
					schematicToAdd = 'Lynx Boots schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Boots Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Boots Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Boots Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Boots Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Boots Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Boots Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Boots Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Boots Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Gloves"))
			{
				if( !(knownSchematics.Contains('Lynx Gloves schematic DWS')))
				{
					schematicToAdd = 'Lynx Gloves schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Gloves Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Gloves Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Gloves Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Gloves Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Gloves Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Gloves Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Gloves Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Gloves Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			{
				if( !(knownSchematics.Contains('Lynx Armor schematic DWS')))
				{
					schematicToAdd = 'Lynx Armor schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Jacket Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Jacket Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Jacket Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Jacket Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Jacket Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Jacket Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Lynx Jacket Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Witcher Lynx Jacket Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
		}
		else
		if(StrContains(NameToString(itemName), "Gryphon"))
		{
			if(StrContains(NameToString(itemName), "steel"))
			{
				if( !(knownSchematics.Contains('Gryphon School steel sword schematic DWS')))
				{
					schematicToAdd = 'Gryphon School steel sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School steel sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Gryphon School steel sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School steel sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Gryphon School steel sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School steel sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Gryphon School steel sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School steel sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Gryphon School steel sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "silver"))
			{
				if( !(knownSchematics.Contains('Gryphon School silver sword schematic DWS')))
				{
					schematicToAdd = 'Gryphon School silver sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School silver sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Gryphon School silver sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School silver sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Gryphon School silver sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School silver sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Gryphon School silver sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Gryphon School silver sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Gryphon School silver sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Pants"))
			{
				if( !(knownSchematics.Contains('Gryphon Pants schematic DWS')))
				{
					schematicToAdd = 'Gryphon Pants schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Pants Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Pants Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Pants Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Pants Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Pants Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Pants Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Pants Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Pants Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Boots"))
			{
				if( !(knownSchematics.Contains('Gryphon Boots schematic DWS')))
				{
					schematicToAdd = 'Gryphon Boots schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Boots Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Boots Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Boots Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Boots Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Boots Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Boots Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Boots Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Boots Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Gloves"))
			{
				if( !(knownSchematics.Contains('Gryphon Gloves schematic DWS')))
				{
					schematicToAdd = 'Gryphon Gloves schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Gloves Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Gloves Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Gloves Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Gloves Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Gloves Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Gloves Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Gloves Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Gloves Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			{
				if( !(knownSchematics.Contains('Gryphon Armor schematic DWS')))
				{
					schematicToAdd = 'Gryphon Armor schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Jacket Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Jacket Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Jacket Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Jacket Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Jacket Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Jacket Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Gryphon Jacket Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Witcher Gryphon Jacket Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
		}
		else
		if(StrContains(NameToString(itemName), "Bear"))
		{
			if(StrContains(NameToString(itemName), "steel"))
			{
				if( !(knownSchematics.Contains('Bear School steel sword schematic DWS')))
				{
					schematicToAdd = 'Bear School steel sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School steel sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Bear School steel sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School steel sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Bear School steel sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School steel sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Bear School steel sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School steel sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Bear School steel sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "silver"))
			{
				if( !(knownSchematics.Contains('Bear School silver sword schematic DWS')))
				{
					schematicToAdd = 'Bear School silver sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School silver sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Bear School silver sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School silver sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Bear School silver sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School silver sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Bear School silver sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Bear School silver sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Bear School silver sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Pants"))
			{
				if( !(knownSchematics.Contains('Bear Pants schematic DWS')))
				{
					schematicToAdd = 'Bear Pants schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Pants Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Bear Pants Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Pants Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Bear Pants Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Pants Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Bear Pants Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Pants Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Bear Pants Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Boots"))
			{
				if( !(knownSchematics.Contains('Bear Boots schematic DWS')))
				{
					schematicToAdd = 'Bear Boots schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Boots Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Bear Boots Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Boots Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Bear Boots Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Boots Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Bear Boots Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Boots Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Bear Boots Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Gloves"))
			{
				if( !(knownSchematics.Contains('Bear Gloves schematic DWS')))
				{
					schematicToAdd = 'Bear Gloves schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Gloves Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Bear Gloves Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Gloves Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Bear Gloves Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Gloves Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Bear Gloves Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Gloves Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Bear Gloves Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			{
				if( !(knownSchematics.Contains('Bear Armor schematic DWS')))
				{
					schematicToAdd = 'Bear Armor schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Jacket Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Bear Jacket Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Jacket Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Bear Jacket Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Jacket Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Bear Jacket Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Bear Jacket Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Witcher Bear Jacket Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
		}
		else
		if(StrContains(NameToString(itemName), "Wolf"))
		{
			if(StrContains(NameToString(itemName), "steel"))
			{
				if( !(knownSchematics.Contains('Wolf School steel sword schematic DWS')))
				{
					schematicToAdd = 'Wolf School steel sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School steel sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Wolf School steel sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School steel sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Wolf School steel sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School steel sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Wolf School steel sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School steel sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Wolf School steel sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "silver"))
			{
				if( !(knownSchematics.Contains('Wolf School silver sword schematic DWS')))
				{
					schematicToAdd = 'Wolf School silver sword schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School silver sword Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Wolf School silver sword Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School silver sword Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Wolf School silver sword Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School silver sword Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Wolf School silver sword Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Wolf School silver sword Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Wolf School silver sword Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Pants"))
			{
				if( !(knownSchematics.Contains('Wolf Pants schematic DWS')))
				{
					schematicToAdd = 'Wolf Pants schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Pants Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Pants Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Pants Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Pants Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Pants Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Pants Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Pants Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Pants Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Boots"))
			{
				if( !(knownSchematics.Contains('Wolf Boots schematic DWS')))
				{
					schematicToAdd = 'Wolf Boots schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Boots Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Boots Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Boots Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Boots Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Boots Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Boots Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Boots Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Boots Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			if(StrContains(NameToString(itemName), "Gloves"))
			{
				if( !(knownSchematics.Contains('Wolf Gloves schematic DWS')))
				{
					schematicToAdd = 'Wolf Gloves schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Gloves Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Gloves Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Gloves Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Gloves Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Gloves Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Gloves Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Gloves Upgrade schematic 5 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Gloves Upgrade schematic 5 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
			else
			{
				if( !(knownSchematics.Contains('Wolf Armor schematic DWS')))
				{
					schematicToAdd = 'Wolf Armor schematic DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Jacket Upgrade schematic 1 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Jacket Upgrade schematic 1 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Jacket Upgrade schematic 2 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Jacket Upgrade schematic 2 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Jacket Upgrade schematic 3 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Jacket Upgrade schematic 3 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
				if( !(knownSchematics.Contains('Witcher Wolf Jacket Upgrade schematic 4 DWS')))
				{
					schematicToAdd = 'Witcher Wolf Jacket Upgrade schematic 4 DWS' ;
					witcher.AddCraftingSchematic(schematicToAdd);
					thePlayer.newCraftables.PushBack(schematicToAdd);
				}
				else
					return;
			}
		}
		else
			return;
	}
}

exec function UpdateDWS(type : string)
{
	Equipment().ManageOldSchematics(type);
}

class kotwArmor extends CItemEntity
{
    event OnSpawned( spawnData : SEntitySpawnData )
    {
		super.OnSpawned(spawnData);
    }
}

class KOTWHelm_Base extends CItemEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
}

class KOTWUsableHelm extends W3QuestUsableItem
{
	protected function AddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	protected function RemoveHelm( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		FactsRemove("isWearingHelmet");
		witcher.SetCurrentHelmet(EIST_Undefined);
		ids = witcher.inv.GetItemsByTag('kotwHelm');
		for(i=0; i<ids.Size(); i+= 1)
			witcher.inv.RemoveItem(ids[i]);
	}
	
	protected function ToggleHair( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName(ids[i]) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem(ids[0], false);
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			if( inv.IsItemMounted(ids[i]) )
				inv.DespawnItem(ids[i]);
	}

	protected function ManageHelmet( helmName : name, visorUpName : name, visorDownName : name, witcher : W3PlayerWitcher )
	{
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var isHelmEquipped : bool;
		var inv : CInventoryComponent;
		
		inv = witcher.GetInventory();
		switch(helmName)
		{
			case 'kotw_helm_v1_1':
				witcher.SetCurrentHelmet(EIST_Gothic);
			break;
			
			case 'kotw_helm_v2_1':
				witcher.SetCurrentHelmet(EIST_Meteorite);
			break;
			
			case 'kotw_helm_v3_1':
				witcher.SetCurrentHelmet(EIST_Dimeritium);
				witcher.ManageActiveSetBonuses(EIST_Dimeritium);
			break;
		}
		
		if( !FactsDoesExist("isWearingHelmet") )
		{
			inv.AddAnItem(visorUpName, 1);
			AddAndEquipItem(helmName, witcher);
			AddAndEquipItem(visorDownName, witcher);
			AddAndEquipItem('kotw_helm_cap', witcher);
			FactsAdd("isWearingHelmet", 1);
			ToggleHair(false, witcher);
		}
		else
		if( FactsDoesExist("isWearingHelmet") )
		{				
			helm = inv.GetItemId(helmName);
			visorUp = inv.GetItemId(visorUpName);
			visorDown = inv.GetItemId(visorDownName);
			isVisorUp = inv.IsItemMounted(visorUp);
			isVisorDown = inv.IsItemMounted(visorDown);
			isHelmEquipped = inv.IsItemMounted(helm);
			if( isHelmEquipped && isVisorDown )
			{ 
				inv.UnmountItem(visorDown);
				inv.MountItem(visorUp);
				ToggleHair(false, witcher);
			} 
			else
			{ 
				RemoveHelm(witcher);
				ToggleHair(true, witcher);
			}
		}
		
		((W3Effect_Poise)witcher.GetBuff(EET_Poise)).UpdateMaxPoise();
	}
}

class KOTWHelm_V1_1 extends KOTWUsableHelm
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed(usedBy);
		super.ManageHelmet('kotw_helm_v1_1', 'kotw_visor_v1_1a', 'kotw_visor_v1_1', (W3PlayerWitcher)usedBy);
	}
}

class KOTWHelm_V2_1 extends KOTWUsableHelm
{		
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed(usedBy);
		super.ManageHelmet('kotw_helm_v2_1', 'kotw_visor_v2_1a', 'kotw_visor_v2_1', (W3PlayerWitcher)usedBy);
	}
}


class KOTWHelm_V3_1 extends KOTWUsableHelm
{		

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		super.OnUsed(usedBy);
		super.ManageHelmet('kotw_helm_v3_1', 'kotw_visor_v3_1a', 'kotw_visor_v3_1', (W3PlayerWitcher)usedBy);
	}
}

class W3DLCShield extends W3ShieldUsableItem
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var witcher : W3PlayerWitcher;
		
		super.OnSpawned(spawnData);
		
		witcher = GetWitcherPlayer();
		witcher.BlockAction(EIAB_Signs, 'dlcShield');
		witcher.AddBuffImmunity(EET_Stagger, 'dlcShield', false);
		witcher.AddBuffImmunity(EET_LongStagger, 'dlcShield', false);
	}
	
	event OnHidden( usedBy : CEntity )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		witcher.UnblockAction(EIAB_Signs, 'dlcShield');
		witcher.RemoveBuffImmunity(EET_Stagger, 'dlcShield');
		witcher.RemoveBuffImmunity(EET_LongStagger, 'dlcShield');
		DestroyProjectiles();
		
		super.OnHidden(usedBy);	
	}
	
	private var projArray : array<W3ArrowProjectile>;
	public function ProcessShieldParry( witcher : CR4Player, parryInfo : SParryInfo, optional proj : W3ArrowProjectile ) : bool
	{
		var position : Vector;
		var anims : array<name>;
		var projRot : EulerAngles;
		var guard, partialGuard : bool;
		var parryHeading, angle : float;
		var parryDir : EPlayerParryDirection;
		
		if( witcher.IsCurrentlyDodging() )
			return false;
		
		if( !proj )
			angle = AngleDistance(VecHeading(parryInfo.attacker.GetWorldPosition() - witcher.GetWorldPosition()), witcher.GetHeading());	
		else
			angle = AngleDistance(VecHeading(proj.GetWorldPosition() - witcher.GetWorldPosition()), witcher.GetHeading());	
		
		if( witcher.IsGuarded() && AbsF(angle) < 70 )
		{
			anims.PushBack('geralt_shield_block_1');
			anims.PushBack('geralt_shield_block_2');
			anims.PushBack('geralt_shield_block_3');
			guard = true;
		}
		else
		if( witcher.IsInCombatAction_Attack() && angle < 70 && angle > -30 )
		{
			anims.PushBack('geralt_shield_block_1');
			anims.PushBack('geralt_shield_block_2');
			partialGuard = true;
		}
		else
		if( angle < 110 && angle > 20 )
		{
			anims.PushBack('geralt_shield_block_3');
			partialGuard = true;
		}
		else return false;
		
		if( (guard || partialGuard) && witcher.HasStaminaToParry(parryInfo.attackActionName) )
		{
			parryHeading = witcher.GetParryHeading(parryInfo, parryDir) ;
			
			witcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', anims[RandRange(anims.Size(),0)], 0.2, 0.3);
			witcher.SetBehaviorVariable('parryDirection', (float)((int)(parryDir)));
			witcher.SetBehaviorVariable('parryDirectionOverlay', (float)((int)(parryDir)));
			witcher.SetBehaviorVariable('parryType', witcher.ChooseParryTypeIndex(parryInfo));
			
			witcher.OnCombatActionStart();
			witcher.ClearCustomOrientationInfoStack();
			witcher.SetSlideTarget(parryInfo.attacker);
			witcher.SetCustomRotation('Parry', parryHeading, 1080.f, 0.1f, false);
			witcher.IncDefendCounter();
			
			if( parryInfo.attackActionName != 'attack_heavy' )
				PlayEffect('light_block');
			else
				PlayEffect('heavy_block');
			
			if( proj )
			{
				proj.StopProjectile();
				proj.StopActiveTrail();
				projRot.Pitch = RandRange(15,-5);
				projRot.Yaw = ClampF(180 + angle, 155, 205);
				projRot.Roll = RandRange(360,1);
				position.Z = RandRangeF(0.5, -0.2);
				if( position.Z > 0 )
					position.X = RandRangeF(0.27, -0.1);
				else
					position.X = RandRangeF(0.12, -0.04);
				position.Y = RandRangeF(-0.08, -0.14);
				proj.CreateAttachment(this,, position, projRot);
				AddProjectile(proj);
				witcher.AddTimer('DestroyProj', 300, false,,,, true);
			}
		}
		else
		{
			witcher.AddEffectDefault(EET_Stagger, parryInfo.attacker, "Parry");
		}
		
		return true;
	}
	
	public function AddProjectile( proj : W3ArrowProjectile )
	{
		projArray.PushBack(proj);
	}
	
	public function DestroyProjectiles()
	{
		var i : int;
		
		for(i=0; i<projArray.Size(); i+=1)
			projArray[i].Destroy();
	}
}

class W3ShieldUsableItemDLC extends W3UsableItem
{
	editable var factAddedOnUse : string;
	editable var factValue : int;
	editable var factTimeValid : int;
	editable var removeFactOnHide : bool;
	
	var i : int;
	
	event OnUsed( usedBy : CEntity )
	{
		for(i=0; i<blockedActions.Size(); i+=1)
		{
			thePlayer.BlockAction(blockedActions[i], 'UsableItem');
		}
		FactsAdd(factAddedOnUse, factValue, factTimeValid);
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		if(removeFactOnHide)
		{
			FactsRemove(factAddedOnUse);		
		}
	}
}

class CHoodDLC extends CItemEntity
{
    event OnSpawned(spawnData : SEntitySpawnData)
    {
        var inv : CInventoryComponent;
        var ids : array<SItemUniqueId>;
        var size, i : int;
        var hair : CEntityTemplate;
        var l_comp : CComponent;        
        
        if(!StrContains(this, "dlc\kontusz\data\items\hoods"))
        {
            return false;
        }
        
        inv = thePlayer.GetInventory();
        ids = inv.GetItemsByCategory('hair');
        size = ids.Size();
        
        l_comp = thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
        
        if( size > 0 )
        {            
			for(i=0; i<size; i+=1)
				inv.UnmountItem(ids[i]);
        }
        
        super.OnSpawned(spawnData);
    }
    
    event OnDestroyed()
    {
        var l_comp : CComponent;   
        var hair : CEntityTemplate;
		
        var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = GetWitcherPlayer().GetInventory();
		ids = inv.GetItemsByCategory('hair');
		for(i=0; i<ids.Size(); i+= 1)
		{
			if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
			{
				if( hairApplied == false )
				{
					inv.MountItem(ids[i], false);
					hairApplied = true;
				}
			}
		}
		if( hairApplied == false )
		{
			ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
			inv.MountItem(ids[0], false);
		}
		
        if(StrContains(this, "dlc\kontusz\data\items\hoods"))
        {
            l_comp = thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
            hair = (CEntityTemplate)LoadResource("dlc\kontusz\data\items\hoods\hood_hair\hair_hood.w2ent", true);    
            ((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(hair);
        }
    }
}	

class CCatHoodDLC extends W3UsableItem
{
    event OnSpawned(spawnData : SEntitySpawnData)
    {
		var inv : CInventoryComponent;
		var witcher : W3PlayerWitcher;
		var ids : array<SItemUniqueId>;
		var size : int;
		var i : int;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory( 'hair' );
		size = ids.Size();
		
		if( size > 0 )
		{
			
			for( i = 0; i < size; i+=1 )
			{
				if(inv.IsItemMounted( ids[i] ) )
					inv.DespawnItem(ids[i]);
			}
			
		}
        
        super.OnSpawned(spawnData);
    }

    
	event OnDestroyed()
    {
        var ids : array<SItemUniqueId>;
        var i   : int;
        var itemName : name;
        var hairApplied : bool;
		var inv : CInventoryComponent;
		
		inv = thePlayer.GetInventory();
        ids = inv.GetItemsByCategory('hair');
        for(i=0; i<ids.Size(); i+= 1)
        {
            itemName = inv.GetItemName( ids[i] );
            
            if( itemName != 'Preview Hair' )
            {
                if( hairApplied == false )
                {
                    inv.MountItem( ids[i], false );
                    hairApplied = true;
                }
                else
                {
                    inv.RemoveItem( ids[i], 1 );
                }                
            }
        }
        
        if( hairApplied == false )
        {
            ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
            inv.MountItem( ids[0], false );
        }    
    
        super.OnDestroyed();        
    }
}

class W3ThrowingKnife extends W3ArrowProjectile 
{
	protected 				var snapCollisionGroupNames 			: array<name>;	
	private 				var targetPos 							: Vector;
	protected 				var itemName							: name;
	protected 				var loopDuration						: float;
	protected editable 		var dodgeable							: bool;
							var equippedOnSlot 						: EEquipmentSlots;
							var knifeMesh							: CComponent;
							var throwAngle							: float;
							var	wasInTutorialTrigger				: bool;			
							var cachedName							: name;
							var recoveryChance						: float;
							var colliderComponent					: CComponent;
							var poisonChance						: float;
							var bleedChance							: float;
							var counterBonus						: float;
							var qualityLevel						: int;
							var impactParams						: SPetardParams;
							var loopParams							: SPetardParams;
							var recoveryCheck						: bool;
	default shouldBeAttachedToVictim = true;
	default projDMG = 100;
	default projSilverDMG = 100;
	default ignoreArmor = false;
	default throwAngle = 3;
	default projSpeed = 50;
	default dodgeable = false;
	default recoveryChance = 0.8f;
	
	event OnSpawned ( spawnData : SEntitySpawnData )
	{
		var Component : CComponent;
		
		super.OnSpawned(spawnData);
		
		Component = GetComponentByClassName('CAppearanceComponent');
		Component.SetEnabled(false);
		Component = GetComponentByClassName('CDynamicColliderComponent');
		Component.SetEnabled(false);		
		Component = GetComponentByClassName('CTriggerActivatorComponent');
		Component.SetEnabled(false);
		Component = GetComponentByClassName('CEffectDummyComponent');
		Component.SetEnabled(false);
		Component = GetComponentByClassName('CSoundEmitterComponent');
		Component.SetEnabled(false);	
		
		AddTimer('KnifeMoveDelayed', 0.3, false);
		SetFocusModeVisibility( FMV_Clue );
	}
	
	protected function LoadDataFromItemXMLStats()
	{
		var atts, abs : array<name>;
		var j, i, iSize, jSize : int;
		var disabledAbility : SBlockedAbility;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		var isLoopAbility : bool;
		var dmgRaw : SRawDamage;
		var type : EEffectType;
		var customAbilityName : name;
		var inv : CInventoryComponent;
		var abilityDisableDuration : float;
		var min, max : SAbilityAttributeValue;
		
		inv = GetOwner().GetInventory();
		
		if(!inv)
			return;
			
		loopDuration = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, 'duration'));
		itemName = inv.GetItemName(itemId);
		qualityLevel = inv.GetItemQuality(itemId);
		
		inv.GetItemAbilities(itemId, abs);
		dm = theGame.GetDefinitionsManager();
		iSize = abs.Size();		
		for(i=0; i<iSize; i+=1)
		{
			isLoopAbility = dm.AbilityHasTag(abs[i], 'ThrownLoopParams');
			if( !isLoopAbility )
				if( !dm.AbilityHasTag(abs[i], 'ThrownImpactParams') )
					continue;
				
			dm.GetAbilityAttributeValue(abs[i], 'ability_disable_duration', min, max);
			abilityDisableDuration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			dm.GetContainedAbilities(abs[i], atts);
			jSize = atts.Size();
			for(j=0; j<jSize; j+=1)
			{
				if( IsEffectNameValid(atts[j]) )
				{
					EffectNameToType(atts[j], type, customAbilityName);
					
					buff.effectType = type;
					buff.effectAbilityName = customAbilityName;					
					dm.GetAbilityAttributeValue(abs[i], atts[j], min, max);
					buff.applyChance = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					
					if(isLoopAbility)
						loopParams.buffs.PushBack(buff);
					else
						impactParams.buffs.PushBack(buff);
				}
				else
				{
					disabledAbility.abilityName = atts[j];
					disabledAbility.timeWhenEnabledd = abilityDisableDuration;
					
					
					if(disabledAbility.timeWhenEnabledd == 0)
						disabledAbility.timeWhenEnabledd = -1;
					
					if(isLoopAbility)
						loopParams.disabledAbilities.PushBack(disabledAbility);
					else
						impactParams.disabledAbilities.PushBack(disabledAbility);
				}
			}
			
			dm.GetAbilityAttributes(abs[i], atts);
			jSize = atts.Size();
			for(j=0; j<jSize; j+=1)
			{
				if( atts[j] == 'oil_poison_tooltip' )
					poisonChance = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, atts[j]));
				else
				if( atts[j] == 'desc_bleedingchance_mult' )
					bleedChance = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, atts[j]));
				else
				if( IsDamageTypeNameValid(atts[j]) )
				{
					dmgRaw.dmgVal = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, atts[j]));
					if(dmgRaw.dmgVal == 0)
						continue;
						
					dmgRaw.dmgType = atts[j];
					if(isLoopAbility)
						loopParams.damages.PushBack(dmgRaw);
					else
						impactParams.damages.PushBack(dmgRaw);						
				}
			}
			
			dm.GetAbilityAttributeValue(abs[i], 'counter_damage_bonus', min, max);
			counterBonus = min.valueMultiplicative;
			if( isLoopAbility && loopParams.damages.Size() > 0 )
			{
				dm.GetAbilityAttributeValue(abs[i], 'armor_reduction', min, max);
				if( min.valueMultiplicative )
					loopParams.armorPierce = min.valueMultiplicative;
			}
			else if( !isLoopAbility && impactParams.damages.Size() > 0 )
			{
				dm.GetAbilityAttributeValue(abs[i], 'armor_reduction', min, max);
				if( min.valueMultiplicative )
					impactParams.armorPierce = min.valueMultiplicative;
			}
		}
		projDMG = impactParams.damages[0].dmgVal;
		projSilverDMG = impactParams.damages[1].dmgVal;
	}
	
	public function GetKnifeArmorPierce( isDoT : bool ) : float
	{
		if( isDoT )
			return loopParams.armorPierce;
			
		return impactParams.armorPierce;
	}
	
	public function GetKnifeCounterBonus() : float
	{
		return counterBonus;
	}
	
	timer function KnifeMoveDelayed( timeDelta : float , id : int)
	{		
		knifeMesh = GetComponentByClassName('CMeshComponent');
		knifeMesh.SetPosition(Vector(0.02, 0.01, 0.02, 1));
		
		colliderComponent = GetComponentByClassName('CDynamicColliderComponent');
		colliderComponent.SetScale( Vector(0.24267466, 0.36793393, 0.01858534, 0) );
	}	

	event OnProcessThrowEvent( animEventName : name )
	{
		var throwPos : Vector;
		var boneIndex : int;
		var orientationTarget	: EOrientationTarget;
		var slideTargetActor : CActor;
		
		if ( animEventName == 'ProjectileThrow' )
		{
			if ( GetOwner() == thePlayer )
			{
				//Lazarus - Throwing Knife Adjusted Aim
				if ( thePlayer.GetDisplayTarget() )
				{
					throwPos = thePlayer.GetLookAtPosition();
					if( ((CNewNPC)thePlayer.GetDisplayTarget()).HasAbility('mon_waterhag') || ((CNewNPC)thePlayer.GetDisplayTarget()).HasAbility('mon_waterhag_greater') )
						throwPos.Z += 0.5f;
					else
						throwPos.Z -= 0.2f;
				}
				else
				{
					orientationTarget = thePlayer.GetOrientationTarget();
					if (!GetOwner().HasBuff(EET_Hypnotized) && (orientationTarget == OT_Camera || orientationTarget == OT_CameraOffset) )
						throwPos = theCamera.GetCameraDirection() * 8 + GetOwner().GetWorldPosition();
					else
						throwPos = GetOwner().GetWorldForward() * 8 + GetOwner().GetWorldPosition();
				}
			}			
			else
			{
				slideTargetActor = (CActor)( GetOwner().slideTarget );
				if( GetOwner().slideTarget && !GetOwner().HasBuff(EET_Hypnotized) &&
					( !slideTargetActor || ( slideTargetActor && GetAttitudeBetween(GetOwner(), GetOwner().slideTarget) == AIA_Hostile ) ) )
				{
					boneIndex = GetOwner().slideTarget.GetBoneIndex( 'pelvis' );
					if ( boneIndex > -1 )
						throwPos = MatrixGetTranslation( GetOwner().slideTarget.GetBoneWorldMatrixByIndex( boneIndex ) );
					else
						throwPos = GetOwner().slideTarget.GetWorldPosition();
				}
				else
				{
					orientationTarget = thePlayer.GetOrientationTarget();
					if (!GetOwner().HasBuff(EET_Hypnotized) && (orientationTarget == OT_Camera || orientationTarget == OT_CameraOffset) )
						throwPos = theCamera.GetCameraDirection() * 8 + GetOwner().GetWorldPosition();
					else
						throwPos = GetOwner().GetWorldForward() * 8 + GetOwner().GetWorldPosition();		
				}
			}
			
			ThrowProjectile( throwPos );
		}
		
		return super.OnProcessThrowEvent( animEventName );
	}
	
	public function ThrowProjectile( targetPosIn : Vector )
	{		
		var phantom : CPhantomComponent;
		var inv : CInventoryComponent;		
		var wOwner : W3PlayerWitcher;
		
		inv = GetOwner().GetInventory();
		wOwner = (W3PlayerWitcher)GetOwner();
		phantom = (CPhantomComponent)GetComponent('snappingCollisionGroupNames');
		if(phantom)
		{
			phantom.GetTriggeringCollisionGroupNames(snapCollisionGroupNames);
		}
		else
		{
			snapCollisionGroupNames.PushBack('Terrain');
			snapCollisionGroupNames.PushBack('Static');
		}	
		
		LoadDataFromItemXMLStats();
		
		targetPos = targetPosIn;
		AddTimer('ReleaseProjectile', 0.01, false, , , true);
		cachedName = inv.GetItemName(itemId);
		
		recoveryCheck = false;
		
		if( inv.GetItemQuantity(itemId) > 1 )
			inv.RemoveItem(itemId, 1);
		else
			AddTimer('RemoveItemFromInventory', 0.1f, 0);
		/*inv.SingletonItemRemoveAmmo(itemId, 1);
		if( wOwner && !inv.GetItemModifierInt(itemId, 'ammo_current') )
		{
			if( wOwner.GetItemSlot(itemId) != EES_InvalidSlot )
				wOwner.UnequipItem(itemId);
			AddTimer('RemoveItemFromInventory', 1.f, 0);
		}*/	
	}
	
	timer function RemoveItemFromInventory (time : float, id : int)
	{
		var wOwner : W3PlayerWitcher;
		
		wOwner = (W3PlayerWitcher)GetOwner();
		wOwner.inv.RemoveItem(itemId, 1);
		if( wOwner.inv.GetItemQuantity(itemId) > 0 )
			AddTimer('RemoveItemFromInventory',0.1f, false);
	}
	
	timer function ReleaseProjectile( time : float , id : int)
	{
		var distanceToTarget, projectileFlightTime : float;
		var target : CActor = thePlayer.GetTarget();
		var actorsInAoE : array<CGameplayEntity>;
		var i : int;
		var collisionGroups : array<name>;
		var targethack : array< CGameplayEntity >;
		
		BreakAttachment();
		collisionGroups.PushBack('Character');
		collisionGroups.PushBack('Ragdoll');
		collisionGroups.PushBack('Terrain');
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Water');
		collisionGroups.PushBack('Destructible');			
		collisionGroups.PushBack('Foliage');
		collisionGroups.PushBack('Door');
		collisionGroups.PushBack('Corpse');
		collisionGroups.PushBack('Fence');
		collisionGroups.PushBack('Debris');
		collisionGroups.PushBack('Boat');
		collisionGroups.PushBack('Platforms');
		collisionGroups.PushBack('Dynamic');
		ShootProjectileAtPosition( throwAngle, projSpeed, targetPos, theGame.params.MAX_THROW_RANGE * 4, collisionGroups);
		
		if( isFromAimThrow && ShouldProcessTutorial('TutorialThrowHold') )
			wasInTutorialTrigger = (FactsQuerySum("tut_aim_in_trigger") > 0);				
			
		if( !((CNewNPC)target) )
		{
			FindGameplayEntitiesCloseToPoint(targethack, targetPos, 10, 100, '',FLAG_ExcludePlayer + FLAG_OnlyAliveActors);
			target = (CActor)targethack[0];
		}
		
		if( dodgeable && target )
		{
			distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );	
			projectileFlightTime = distanceToTarget / projSpeed;
			target.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', projectileFlightTime );
		}
		
		((CNewNPC)target).OnIncomingProjectile(true);
		ActivateTrail(defaultTrail);
		wasThrown = true;
		knifeMesh.SetPosition(Vector(0., -0.58, 0, 1));
		FindGameplayEntitiesInRange( actorsInAoE, GetOwner(), 15, 1000000,,FLAG_TestLineOfSight );
		for(i = 0; i < actorsInAoE.Size(); i += 1)
		{
			if(actorsInAoE[i] && ((CNewNPC)actorsInAoE[i]).GetNPCType() == ENGT_Guard && !((CNewNPC)actorsInAoE[i]).IsInCombat() )
			{
				((CNewNPC)actorsInAoE[i]).SignalGameplayEventParamObject('CastSignAction', GetOwner());
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( ((CNewNPC)actorsInAoE[i]), 'CastSignAction', 8.0, 1.0f, 999.0f, 1, false); 
			}
			if(actorsInAoE[i] && ((CNewNPC)actorsInAoE[i]).GetNPCType() == ENGT_Commoner && !((CNewNPC)actorsInAoE[i]).IsInCombat() )
			{
				((CNewNPC)actorsInAoE[i]).SignalGameplayEventParamObject('BombExplosionAction', GetOwner());
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( ((CNewNPC)actorsInAoE[i]), 'BombExplosionAction', 8.0, 1.0f, 999.0f, 1, false); 
			}
		}
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victiminv	: CInventoryComponent;	
		var template : CEntityTemplate;
		var actorsInAoE : array<CGameplayEntity>;
		var npchack : CNewNPC;
		var i : int;
		
		if( hitCollisionsGroups.Contains('Water') )
		{
			PlayEffect( 'fx_water_puddle' );
			template = (CEntityTemplate)LoadResource("water_splash_small");
			theGame.CreateEntity(template, GetWorldPosition(), GetWorldRotation());
		}
		
		npchack = (CNewNPC)collidingComponent.GetEntity();
		if( hitCollisionsGroups.Contains('Static') || hitCollisionsGroups.Contains('Dynamic') || hitCollisionsGroups.Contains('Terrain') )
		{
			FindGameplayEntitiesInRange(actorsInAoE, GetOwner(), 15, 1000000,,FLAG_TestLineOfSight);
			for(i = 0; i < actorsInAoE.Size(); i += 1)
			{
				if(actorsInAoE[i] && ((CNewNPC)actorsInAoE[i]).GetNPCType() == ENGT_Guard && !((CNewNPC)actorsInAoE[i]).IsInCombat() )
				{
					((CNewNPC)actorsInAoE[i]).SignalGameplayEventParamObject('CastSignAction', GetOwner());
					theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( ((CNewNPC)actorsInAoE[i]), 'CastSignAction', 8.0, 1.0f, 999.0f, 1, false); 
				}
				if(actorsInAoE[i] && ((CNewNPC)actorsInAoE[i]).GetNPCType() == ENGT_Commoner && !((CNewNPC)actorsInAoE[i]).IsInCombat() )
				{
					((CNewNPC)actorsInAoE[i]).SignalGameplayEventParamObject('BombExplosionAction', GetOwner());
					theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( ((CNewNPC)actorsInAoE[i]), 'BombExplosionAction', 8.0, 1.0f, 999.0f, 1, false); 
				}			
			}
			
			if( !recoveryCheck )
				SpawnContainer(pos);
			recoveryCheck = true;
			SmartDestroy();
		}
		
		if( collidingComponent.GetEntity() != this && collidingComponent.GetEntity() != GetOwner() && ((CNewNPC)collidingComponent.GetEntity()).GetNPCType() != ENGT_Commoner && GetAttitudeBetween(collidingComponent.GetEntity(), GetOwner()) != AIA_Friendly || !npchack )
		{
			super.OnProjectileCollision(pos,normal,collidingComponent,hitCollisionsGroups,actorIndex,shapeIndex);
			((CGameplayEntity)collidingComponent.GetEntity()).OnBoltHit();
			if( (CActor)victim )
			{
				if( RandRangeF(1.0, 0.009) <= recoveryChance && !recoveryCheck )
				{
					victiminv = ((CActor)victim).GetInventory();
					victiminv.AddAnItem(cachedName, 1, true, true);
					recoveryCheck = true;
				}
				else
				{
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");
					this.SoundEvent("cmb_arrow_impact_metal");					
				}
			}
		}		
	}
	
	protected function ProcessDamageAction( victim : CGameplayEntity, pos : Vector, boneName : name )
	{
		var action : W3Action_Attack;
		var actorVictim : CActor;
		var victimTags, attackerTags : array<name>;
		
		action = new W3Action_Attack in this;
		action.Init((CGameplayEntity)caster, victim, this, itemId, 'throwingknife', caster.GetName(), EHRT_Light, false, false, '', AST_NotSet, ASD_NotSet, false, true, false, false);
		
		action.ClearDamage();
		if( isOnFire )
		{
			action.AddEffectInfo(EET_Burning);
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, projDMG );
			action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projDMG * 1.05f );
		}
		else
		{
			action.AddDamage(theGame.params.DAMAGE_NAME_PIERCING, projDMG );
			action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projDMG * 1.05f );
		}
		
		if( this.projEfect != EET_Undefined )
			action.AddEffectInfo(this.projEfect);
			
		actorVictim = (CActor)victim;
		if( actorVictim )
		{
			if ( boneName == 'head' || boneName == 'neck' || boneName == 'hroll' || ( boneName == 'pelvis' && ((CNewNPC)victim).IsHuman() ) )
			{
				actorVictim.AddEffectDefault(EET_Stagger, GetOwner());
				actorVictim.ApplyBleeding(1, GetOwner(), 'Bleeding');
				action.SetHeadShot();
			}
		}
		
		if( RandRangeF(1, 0) <= poisonChance )
			actorVictim.ApplyPoisoning(2, GetOwner(), "Poisoning");
		if( RandRangeF(1, 0) <= bleedChance )
			actorVictim.ApplyBleeding(2, GetOwner(), "Bleeding");
			
		theGame.damageMgr.ProcessAction(action);
		collidedEntities.PushBack(victim);
		delete action;
		
		victimTags = victim.GetTags();
		attackerTags = caster.GetTags();
		AddHitFacts( victimTags, attackerTags, "_arrow_hit" );
	}

	
	function SpawnContainer( ipos : Vector )
	{
		var template 		: CEntityTemplate;
		var container		: CEntity;
		var containerInv	: CComponent;
		var lootComp		: CComponent;
		
		template = (CEntityTemplate)LoadResource("dlc\w3ee\data\items\weapons\throwingknives\throwingknife_container.w2ent", true);
		container = theGame.CreateEntity(template, ipos + RotForward(this.GetWorldRotation()) * 0.5f, GetWorldRotation(),,,true,PM_SaveStateOnly);
		
		if( qualityLevel > 1 ) 
			container.ApplyAppearance("ThrowingKnifeWitcher");
		else
			container.ApplyAppearance("ThrowingKnifeExpensive");
		containerInv = container.GetComponentByClassName('CInventoryComponent');
		lootComp = container.GetComponentByClassName('CInteractionComponent');
		((CInventoryComponent)containerInv).AddAnItem(cachedName);
		((W3Container)container).SetFocusModeVisibility(FMV_Clue);
		((CComponent)lootComp).SetPosition(Vector(0,-5,-1));
	}

	function AttachArrowToShield( victim : CActor, pos : Vector )
	{
		var bones 		: array<name>;
		var res 		: bool;
		var inv 		: CInventoryComponent;
		var shield		: CEntity;
		var rot			: EulerAngles;
		var meshcomp	: CComponent;
		var shieldBB	: Box;
		var shieldfield	: float;
		var shieldwidth : float;
		
		StopProjectile();
		StopActiveTrail();
		isActive = false;
		
		inv = victim.GetInventory();
		shield = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('l_weapon'));
		meshcomp = shield.GetComponentByClassName('CMeshComponent');
		shieldBB = ((CMeshComponent)meshcomp).GetBoundingBox();		
		
		shieldwidth = (shieldBB.Max.X - shieldBB.Min.X) / 2;
		shieldfield = ( Pi() * ( shieldwidth * shieldwidth ) ) * 0.27;
		
		pos = meshcomp.GetWorldPosition();
		pos.X = RandRangeF(shieldfield, -shieldfield);
		pos.Z = RandRangeF(shieldfield, -shieldfield);
		pos.Y = RandRangeF(0.27,0.18);
		
		rot = this.GetWorldRotation();
		rot.Yaw = RandRangeF(200,160);
		rot.Roll = RandRangeF(200,160);
		
		knifeMesh.SetRotation(EulerAngles(RandRangeF(45,-45),0,0));
		knifeMesh.SetPosition(Vector(0, 0, 0, 1));
		this.CreateAttachment( shield , , pos, rot );
	}
	
	function AttachArrowToRagdoll(victim : CActor, pos : Vector, boneName : name)
	{
		var bones 				: array<name>;
		var res 				: bool;
		var arrowHitPos 		: Vector;
		var timerAmount 		: float;
		var shouldPierceVictim 	: bool;
		
		var meshComponent		: CMeshComponent;
		var arrowSize			: Vector;
		var boundingBox			: Box;
		var rotMat				: Matrix;
		
		shouldPierceVictim = ShouldPierceVictim( victim );
		if( !shouldPierceVictim )
		{
			StopProjectile();
			StopActiveTrail();	
			isActive = false;
		}
		
		bones.PushBack( 'head' );
		bones.PushBack( 'hroll' );
		bones.PushBack( 'neck' );
		
		if( ( victim == thePlayer && bones.Contains(boneName) ) || ( ((CNewNPC)victim).IsHorse() && !shouldPierceVictim ) ) 
		{				
			SmartDestroy();
		}
		else if( !shouldPierceVictim )
		{
			arrowHitPos = pos;
			meshComponent = (CMeshComponent)GetComponentByClassName('CMeshComponent');
			if( meshComponent )
			{
				boundingBox = meshComponent.GetBoundingBox();
				arrowSize = boundingBox.Max - boundingBox.Min;
				
				rotMat = MatrixBuiltRotation( this.GetWorldRotation() );
				rotMat = MatrixGetInverted( rotMat );
				arrowSize = VecTransformDir( rotMat, arrowSize );
				
				if( arrowSize.Y > 0 )	
					arrowHitPos += RotForward(  this.GetWorldRotation() ) * arrowSize.Y * 0.1f; 
				else	
					arrowHitPos -= RotForward(  this.GetWorldRotation() ) * arrowSize.Y * 0.9f; 
			}
			
			if ( boneName )
				res = this.CreateAttachmentAtBoneWS(victim, boneName, arrowHitPos, this.GetWorldRotation());
			else
				res = this.CreateAttachmentAtBoneWS(victim, 'torso3', arrowHitPos, this.GetWorldRotation());
				
			if ( res )
			{
				if( victim == thePlayer && !GetShouldBeAttachedToVictim() )
					timerAmount = 0.01;
				else if( victim == thePlayer )
					timerAmount = 3;
				else
					timerAmount = 5;
					
				AddTimer('TimeDestroy', timerAmount, false);
				isScheduledForDestruction = true;
			}
			else
			{
				SmartDestroy();
			}
		}
	}
}

exec function hidehair()
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;
	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			if(inv.IsItemMounted( ids[i] ) )
				inv.DespawnItem(ids[i]);
		}
		
	}
	
	ids.Clear();
}

exec function addWandererArmor()
{
	thePlayer.inv.AddAnItem('Wanderer Armor',  1);
	thePlayer.inv.AddAnItem('Wanderer Boots',  1);
	thePlayer.inv.AddAnItem('Wanderer Pants',  1);
	thePlayer.inv.AddAnItem('Wanderer Gloves', 1);
}

exec function addWardenArmor()
{
	thePlayer.inv.AddAnItem('Warden Armor',  1);
	thePlayer.inv.AddAnItem('Warden Boots',  1);
	thePlayer.inv.AddAnItem('Warden Pants',  1);
	thePlayer.inv.AddAnItem('Warden Gloves', 1);
}

exec function addDLCShields(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Nilfgaardian Shield 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Shield 2', 1);
			thePlayer.inv.AddAnItem('Redanian Shield 1', 1);
			thePlayer.inv.AddAnItem('Temerian Shield 1', 1);
			thePlayer.inv.AddAnItem('Novigradian Shield 1', 1);
			thePlayer.inv.AddAnItem('Novigradian Shield 2', 1);					
			thePlayer.inv.AddAnItem('Rivian Shield 1', 1);
			thePlayer.inv.AddAnItem('Ravix Shield 1', 1);
			thePlayer.inv.AddAnItem('Velen Shield 1', 1);	
			thePlayer.inv.AddAnItem('Velen Shield 2', 1);	
			thePlayer.inv.AddAnItem('Velen Shield 3', 1);
			thePlayer.inv.AddAnItem('Velen Shield 4', 1);	
			thePlayer.inv.AddAnItem('Velen Shield 5', 1);
			thePlayer.inv.AddAnItem('Flaming Rose Shield 1', 1);	
			thePlayer.inv.AddAnItem('Ofieri Shield 1', 1);	
			thePlayer.inv.AddAnItem('Olgierd Shield 1', 1);	
			thePlayer.inv.AddAnItem('Borsodi Shield 1', 1);
			thePlayer.inv.AddAnItem('Skellige Shield 1', 1);
			thePlayer.inv.AddAnItem('Skellige Shield 2', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 3', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 4', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 5', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 6', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 1', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 2', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 3', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 4', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 5', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 6', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 7', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 8', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 9', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 10', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 11', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 12', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 13', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 14', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 15', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 16', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 17', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 18', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 19', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 20', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 21', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 22', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 23', 1);
			thePlayer.inv.AddAnItem('Imlerith Shield 1', 1);			
	
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}

exec function addDLCArmors(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Nilfgaardian Armor 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Boots 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Pants 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Gloves 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Armor 2', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Pants 2', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Helmet 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Helmet 2', 1);				
	
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}

exec function addDLCHoods(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Hood Red', 1);
			thePlayer.inv.AddAnItem('Hood Blue', 1);
			thePlayer.inv.AddAnItem('Hood Black', 1);
			thePlayer.inv.AddAnItem('Hood Green', 1);
			thePlayer.inv.AddAnItem('Hood Moss', 1);
			thePlayer.inv.AddAnItem('Hood Cream', 1);
			thePlayer.inv.AddAnItem('Hood Grey', 1);
			thePlayer.inv.AddAnItem('Hood White', 1);
			thePlayer.inv.AddAnItem('Hood Purple', 1);
			thePlayer.inv.AddAnItem('Hood Brown', 1);
			thePlayer.inv.AddAnItem('Hood Turquoise', 1);
			thePlayer.inv.AddAnItem('Hood Gold', 1);			
			
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}

exec function kotwAddArmor()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_armor_v1_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v1_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v1_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v1_1' );
	witcher.inv.AddAnItem( 'kotw_helm_v1_1_usable' );
}

exec function kotwAddArmor2()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_armor_v2_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v2_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v2_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v2_1' );
	witcher.inv.AddAnItem( 'kotw_helm_v2_1_usable' );
}

exec function kotwAddArmor3()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_armor_v3_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v3_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v3_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v3_1' );
	witcher.inv.AddAnItem( 'kotw_helm_v3_1_usable' );
}

exec function kotwAddSchematics()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem('Gothic armor schematic');
	witcher.inv.AddAnItem('Gothic boots schematic');
	witcher.inv.AddAnItem('Gothic pants schematic');
	witcher.inv.AddAnItem('Gothic gloves schematic');
	
	witcher.inv.AddAnItem('Meteorite armor schematic');
	witcher.inv.AddAnItem('Meteorite boots schematic');
	witcher.inv.AddAnItem('Meteorite pants schematic');
	witcher.inv.AddAnItem('Meteorite gloves schematic');
	
	witcher.inv.AddAnItem('Dimeritium armor schematic');
	witcher.inv.AddAnItem('Dimeritium boots schematic');
	witcher.inv.AddAnItem('Dimeritium pants schematic');
	witcher.inv.AddAnItem('Dimeritium gloves schematic');
	
	witcher.inv.AddAnItem('Gothic light armor schematic');
	witcher.inv.AddAnItem('Gothic light boots schematic');
	witcher.inv.AddAnItem('Gothic light pants schematic');
	witcher.inv.AddAnItem('Gothic light gloves schematic');
	
	witcher.inv.AddAnItem('Meteorite light armor schematic');
	witcher.inv.AddAnItem('Meteorite light boots schematic');
	witcher.inv.AddAnItem('Meteorite light pants schematic');
	witcher.inv.AddAnItem('Meteorite light gloves schematic');
	
	witcher.inv.AddAnItem('Dimeritium light armor schematic');
	witcher.inv.AddAnItem('Dimeritium light boots schematic');
	witcher.inv.AddAnItem('Dimeritium light pants schematic');
	witcher.inv.AddAnItem('Dimeritium light gloves schematic');
	
	witcher.inv.AddAnItem('Gothic helmet schematic');
	witcher.inv.AddAnItem('Meteorite helmet schematic');
	witcher.inv.AddAnItem('Dimeritium helmet schematic');
}

exec function fixhelmets()
{
	var i : int;
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	var ids : array< SItemUniqueId >;
	
	ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
	FactsRemove( "hair_removed" );
	for(i=0; i<ids.Size(); i+= 1)
	{
		witcher.inv.RemoveItem( ids[i] );
		witcher.SetCurrentHelmet(EIST_Undefined);
	}
}

exec function addtestingstuff()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.AddAndEquipItem('Bear School steel sword 4');
	witcher.AddAndEquipItem('Wanderer Armor');
	witcher.AddAndEquipItem('Wanderer Boots');
	witcher.AddAndEquipItem('Wanderer Pants');
	witcher.AddAndEquipItem('Warden Gloves');
	witcher.AddAndEquipItem('Hood Black');
}

exec function spawnfrompath(path : string, optional quantity : int, optional distance : float, optional isHostile : bool )
{
    var ent : CEntity;
    var pos, cameraDir, player, posFin, normal, posTemp : Vector;
    var rot : EulerAngles;
    var i, sign : int;
    var s,r,x,y : float;
    var template : CEntityTemplate;
    var resourcePath    : string;
    quantity = Max(quantity, 1);
    
    rot = thePlayer.GetWorldRotation();    
    rot.Yaw += 180;        
    
    
    cameraDir = theCamera.GetCameraDirection();
    
    if( distance == 0 ) distance = 3; 
    cameraDir.X *= distance;    
    cameraDir.Y *= distance;
    
    
    player = thePlayer.GetWorldPosition();
    
    
    pos = cameraDir + player;    
    pos.Z = player.Z;
    
    
    posFin.Z = pos.Z;            
    s = quantity / 0.2;            
    r = SqrtF(s/Pi());
    
    
    template = (CEntityTemplate)LoadResource(path,true);

    for(i=0; i<quantity; i+=1)
    {        
        x = RandF() * r;            
        y = RandF() * (r - x);        
        
        if(RandRange(2))                    
            sign = 1;
        else
            sign = -1;
            
        posFin.X = pos.X + sign * x;    
        
        if(RandRange(2))                    
            sign = 1;
        else
            sign = -1;
            
        posFin.Y = pos.Y + sign * y;    
        
            if(theGame.GetWorld().StaticTrace( posFin + Vector(0,0,5), posFin - Vector(0,0,5), posTemp, normal ))
            {
                posFin = posTemp;
            }
            
            ent = theGame.CreateEntity(template, posFin, rot);
            
        if( isHostile )
        {
            ((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
        }
    }
}

exec function addDecoctions()
{
	thePlayer.GetInventory().AddAnItem('Decoction 1', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 2', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 3', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 4', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 5', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 6', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 7', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 8', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 9', 1, true, true);
	thePlayer.GetInventory().AddAnItem('Decoction 10', 1, true, true);
}

exec function wtf()
{
	theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("skill_desc_bear_set_ability1"));
}

exec function rainthing( f : float )
{
	thePlayer.SetBehaviorVariable('bRainStormIdleAnim', f);
}

exec function movething( f : float ) // max 3
{
	thePlayer.SetBehaviorVariable('playerMoveType', f);
}

exec function runthing( f : float ) // max 3
{
	thePlayer.SetBehaviorVariable('runType', f);
}

exec function walkthing( f : float ) // max 2
{
	thePlayer.SetBehaviorVariable('alternateWalk', f);
}

exec function waterthing( f : float )
{
	thePlayer.SetBehaviorVariable('shallowWater', f);
}

exec function KKK()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	var item : SItemUniqueId;
	var invItem : SInventoryItem;
	
	witcher.GetItemEquippedOnSlot(EES_SteelSword, item);
	invItem = witcher.inv.GetItem(item);
	
	theGame.GetGuiManager().ShowNotification("Item Price: " + witcher.inv.GetItemBasePrice(item) + "<br>Modified Item Price: " + witcher.inv.GetItemBasePriceModified(item, false) + "<br>Modified Inventory Item Price: " + witcher.inv.GetInventoryItemBasePriceModified(invItem, witcher.inv, false), 5000.f, false);
}

exec function KKK2()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	var item : SItemUniqueId;
	var invItem : SInventoryItem;
	var actors : array<CActor>;
	var i : int;
	
	witcher.GetItemEquippedOnSlot(EES_SteelSword, item);
	invItem = witcher.inv.GetItem(item);
	
	//theGame.GetGuiManager().ShowNotification("Item Price: " + witcher.inv.GetItemBasePrice(item) + "<br>Modified Item Price: " + witcher.inv.GetItemBasePriceModified(item, false) + "<br>Modified Inventory Item Price: " + witcher.inv.GetInventoryItemBasePriceModified(invItem, false), 2000.f, true);
	actors = GetActorsInRange(witcher, 2, 100,, true);
	for(i=0;i<actors.Size(); i+=1)
		theGame.GetGuiManager().ShowNotification("Item Price: " + actors[i].GetInventory().GetItemBasePrice(item) + "<br>Modified Item Price: " + actors[i].GetInventory().GetItemBasePriceModified(item, false) + "<br>Modified Inventory Item Price: " + actors[i].GetInventory().GetInventoryItemBasePriceModified(invItem, witcher.inv, false) + "<br>Modified Inventory Item Price (selling): " + actors[i].GetInventory().GetInventoryItemBasePriceModified(invItem, witcher.inv, true), 2000.f, true);
}

exec function toxtest()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	var effects : array<CBaseGameplayEffect> = witcher.GetCurrentEffects();
	var i : int;
	
	for(i=0; i<effects.Size(); i+=1)
	{
		if( effects[i].IsPotionEffect() )
			witcher.RemoveEffect(effects[i]);
	}
}

exec function fixgearupgrades()
{
	var i : int;
	var temp : SItemUniqueId;
	var items, upgrade : array<SItemUniqueId>;
	var upgrades : array<name>;
	
	thePlayer.inv.GetItemEquippedOnSlot(EES_Armor, temp);	items.PushBack(temp);
	thePlayer.inv.GetItemEquippedOnSlot(EES_Boots, temp);	items.PushBack(temp);
	thePlayer.inv.GetItemEquippedOnSlot(EES_Pants, temp);	items.PushBack(temp);
	thePlayer.inv.GetItemEquippedOnSlot(EES_Gloves, temp);	items.PushBack(temp);
	thePlayer.inv.GetItemEquippedOnSlot(EES_SteelSword, temp);	items.PushBack(temp);
	thePlayer.inv.GetItemEquippedOnSlot(EES_SilverSword, temp);	items.PushBack(temp);
	
	for(i=0; i<items.Size(); i+=1)
	{
		thePlayer.inv.GetItemEnhancementItems(items[i], upgrades);
		for(i=0; i<upgrades.Size(); i+=1)
		{
			upgrade = thePlayer.inv.AddAnItem(upgrades[i], 1, true, true);
			thePlayer.inv.EnhanceItemScript(items[i], upgrade[0]);
		}
	}
}

exec function addallartifacts()
{
	var i : int;
	var artifactsArray : array<name>;
	
	artifactsArray.PushBack('Arbitrator artifact');
	artifactsArray.PushBack('Devine artifact');
	artifactsArray.PushBack('Longclaw artifact');
	artifactsArray.PushBack('Beannshie artifact');
	artifactsArray.PushBack('Blackunicorn artifact');
	artifactsArray.PushBack('Inis artifact');
	artifactsArray.PushBack('Ardaenye artifact');
	artifactsArray.PushBack('Barbersurgeon artifact');
	artifactsArray.PushBack('Caerme artifact');
	artifactsArray.PushBack('Deireadh artifact');
	artifactsArray.PushBack('Gwyhyr artifact');
	artifactsArray.PushBack('Princessxenthiasword artifact');
	artifactsArray.PushBack('Robustswordofdolblathanna artifact');
	artifactsArray.PushBack('Headtaker artifact');
	artifactsArray.PushBack('Ultimatum artifact');
	artifactsArray.PushBack('Lune artifact');
	artifactsArray.PushBack('Gloryofthenorth artifact');
	artifactsArray.PushBack('Torlara artifact');
	artifactsArray.PushBack('Harpy artifact');
	artifactsArray.PushBack('Negotiator artifact');
	artifactsArray.PushBack('Weeper artifact');
	artifactsArray.PushBack('Azurewrath artifact');
	artifactsArray.PushBack('Bloodsword artifact');
	artifactsArray.PushBack('Naevdeseidhe artifact');
	artifactsArray.PushBack('Zerrikanterment artifact');
	artifactsArray.PushBack('Reachofthedamned artifact');
	artifactsArray.PushBack('Havcaaren artifact');
	artifactsArray.PushBack('Virgin artifact');
	artifactsArray.PushBack('Tlareg artifact');
	artifactsArray.PushBack('EP1 Crafted Witcher Silver Sword artifact');
	artifactsArray.PushBack('Knights steel sword 3 artifact');
	
	for(i=0; i<artifactsArray.Size(); i+=1)
		GetWitcherPlayer().inv.AddAnItem(artifactsArray[i], 1, true, true, false);
}

//Kolaris - Add Glyphs
exec function addglyphs( amount : int )
{
	var i : int;
	var glyphArray : array<name>;
	
	glyphArray.PushBack('Glyph aard lesser');
	glyphArray.PushBack('Glyph aard');
	glyphArray.PushBack('Glyph aard greater');
	glyphArray.PushBack('Glyph igni lesser');
	glyphArray.PushBack('Glyph igni');
	glyphArray.PushBack('Glyph igni greater');
	glyphArray.PushBack('Glyph yrden lesser');
	glyphArray.PushBack('Glyph yrden');
	glyphArray.PushBack('Glyph yrden greater');
	glyphArray.PushBack('Glyph quen lesser');
	glyphArray.PushBack('Glyph quen');
	glyphArray.PushBack('Glyph quen greater');
	glyphArray.PushBack('Glyph axii lesser');
	glyphArray.PushBack('Glyph axii');
	glyphArray.PushBack('Glyph axii greater');
	glyphArray.PushBack('Glyph reinforcement lesser');
	glyphArray.PushBack('Glyph reinforcement');
	glyphArray.PushBack('Glyph reinforcement greater');
	glyphArray.PushBack('Glyph mending lesser');
	glyphArray.PushBack('Glyph mending');
	glyphArray.PushBack('Glyph mending greater');
	glyphArray.PushBack('Glyph binding lesser');
	glyphArray.PushBack('Glyph binding');
	glyphArray.PushBack('Glyph binding greater');
	glyphArray.PushBack('Glyph warding lesser');
	glyphArray.PushBack('Glyph warding');
	glyphArray.PushBack('Glyph warding greater');
	
	for(i=0; i<glyphArray.Size(); i+=1)
		GetWitcherPlayer().inv.AddAnItem(glyphArray[i], amount, true, true, false);
}

//Kolaris - Add Runes
exec function addrunes( amount : int )
{
	var i : int;
	var runeArray : array<name>;
	
	runeArray.PushBack('Rune morana lesser');
	runeArray.PushBack('Rune morana');
	runeArray.PushBack('Rune morana greater');
	runeArray.PushBack('Rune dazhbog lesser');
	runeArray.PushBack('Rune dazhbog');
	runeArray.PushBack('Rune dazhbog greater');
	runeArray.PushBack('Rune devana lesser');
	runeArray.PushBack('Rune devana');
	runeArray.PushBack('Rune devana greater');
	runeArray.PushBack('Rune triglav lesser');
	runeArray.PushBack('Rune triglav');
	runeArray.PushBack('Rune triglav greater');
	runeArray.PushBack('Rune zoria lesser');
	runeArray.PushBack('Rune zoria');
	runeArray.PushBack('Rune zoria greater');
	runeArray.PushBack('Rune stribog lesser');
	runeArray.PushBack('Rune stribog');
	runeArray.PushBack('Rune stribog greater');
	runeArray.PushBack('Rune veles lesser');
	runeArray.PushBack('Rune veles');
	runeArray.PushBack('Rune veles greater');
	runeArray.PushBack('Rune perun lesser');
	runeArray.PushBack('Rune perun');
	runeArray.PushBack('Rune perun greater');
	runeArray.PushBack('Rune svarog lesser');
	runeArray.PushBack('Rune svarog');
	runeArray.PushBack('Rune svarog greater');
	runeArray.PushBack('Rune elemental lesser');
	runeArray.PushBack('Rune elemental');
	runeArray.PushBack('Rune elemental greater');
	
	for(i=0; i<runeArray.Size(); i+=1)
		GetWitcherPlayer().inv.AddAnItem(runeArray[i], amount, true, true, false);
}

//Kolaris - Test
exec function CheckAbility(abilityName : name, optional withInventory : bool)
{
	if( GetWitcherPlayer().HasAbility(abilityName, withInventory) )
		theGame.GetGuiManager().ShowNotification("Found " + GetWitcherPlayer().GetAbilityCount(abilityName));
	else
		theGame.GetGuiManager().ShowNotification("Found None");
}

exec function CheckAllAbilities(optional withInventory : bool)
{
	var abilityNames : array<name>;
	var i : int;
	var outputString : string;
	
	GetWitcherPlayer().GetCharacterStats().GetAbilities(abilityNames, withInventory);
	for( i = 0; i < abilityNames.Size(); i += 1)
	{
		outputString += abilityNames[i] + "<br>";
	}
	
	theGame.GetGuiManager().ShowUserDialogAdv( 0, "Abilities", outputString, false, UDB_Ok );
}

exec function CheckHeldItems()
{
	var items : array< SItemUniqueId >;
	var i : int;
	var outputString : string;
	
	GetWitcherPlayer().GetInventory().GetHeldAndMountedItems(items);
	for( i = 0; i < items.Size(); i += 1)
	{
		outputString += GetWitcherPlayer().GetInventory().GetItemName(items[i]) + "<br>";
	}
	
	theGame.GetGuiManager().ShowUserDialogAdv( 0, "Items", outputString, false, UDB_Ok );
}

exec function CheckEnchantments(optional fix : bool)
{
	Equipment().CheckEnchantmentAbilities(fix);
}

exec function CheckAbilitiesOnSlot( slotString : string )
{
	var slot : EEquipmentSlots;
	var item : SItemUniqueId;
	var witcher : W3PlayerWitcher;
	var inv : CInventoryComponent;
	var abilityNames : array<name>;
	var i, autogen1, autogen2 : int;
	var outputString : string;
	
	if( slotString == "Armor" )
		slot = EES_Armor;
	else if( slotString == "SteelSword" )
		slot = EES_SteelSword;
	else if( slotString == "SilverSword" )
		slot = EES_SilverSword;
	
	if( thePlayer.IsCiri() )
	{
		if(slot == EES_SteelSword)
			item = GetCiriPlayer().GetEquippedSword(true);
		else
			item = GetCiriPlayer().GetEquippedSword(false);
		GetCiriPlayer().GetInventory().GetItemAbilities(item, abilityNames);
		outputString += GetCiriPlayer().GetInventory().GetItemName(item) + "<br><br>";
	}
	else
	{
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		inv.GetItemEquippedOnSlot(slot, item);
		inv.GetItemAbilities(item, abilityNames);
		outputString += inv.GetItemName(item) + "<br><br>";
	}
	autogen1 = 0;
	autogen2 = 0;
	for( i = 0; i < abilityNames.Size(); i += 1)
	{
		if( !StrContains(NameToString(abilityNames[i]), "autogen_") )
			outputString += abilityNames[i] + "<br>";
		else
		{
			if(StrContains(NameToString(abilityNames[i]), "autogen_fixed_silver_dmg"))
				autogen1 += 1;
			else if(StrContains(NameToString(abilityNames[i]), "autogen_fixed_steel_dmg"))
				autogen2 += 1;
		}
	}
	
	if( autogen1 > 0 )
		outputString += "autogen_fixed_silver_dmg x" + autogen1 + "<br>";
	if( autogen2 > 0 )
		outputString += "autogen_fixed_steel_dmg x" + autogen2 + "<br>";
	
	theGame.GetGuiManager().ShowUserDialogAdv( 0, "Item Abilities", outputString, false, UDB_Ok );
}

exec function ClearEnchantmentsOnSlot( slotString : string )
{
	var slot : EEquipmentSlots;
	var item : SItemUniqueId;
	var witcher : W3PlayerWitcher;
	var inv : CInventoryComponent;
	var enchantNames : array<name>;
	var i : int;
	
	if( slotString == "Armor" )
		slot = EES_Armor;
	else if( slotString == "SteelSword" )
		slot = EES_SteelSword;
	else if( slotString == "SilverSword" )
		slot = EES_SilverSword;
	
	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();
	
	if( inv.GetItemEquippedOnSlot(slot, item) )
	{
		witcher.UnequipItem(item);
		inv.UnenchantItem(item);
		
		if( slot == EES_Armor )
			enchantNames = Equipment().GetEnchantmentNames(false);
		else
			enchantNames = Equipment().GetEnchantmentNames(true);
		
		for( i = 0; i < enchantNames.Size(); i += 1)
		{
			inv.RemoveItemBaseAbility(item, enchantNames[i]);
		}
	}
}

exec function GetCurrentPlayerWeapon()
{
	theGame.GetGuiManager().ShowNotification(GetWitcherPlayer().GetCurrentMeleeWeaponName());
}

exec function TestSetPieces( set : EItemSetType )
{
	theGame.GetGuiManager().ShowNotification(GetWitcherPlayer().GetSetPartsEquipped(set));
}

exec function ClearSetCounts()
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	witcher.UnequipItemFromSlot(EES_SteelSword);
	witcher.UnequipItemFromSlot(EES_SilverSword);
	witcher.UnequipItemFromSlot(EES_Armor);
	witcher.UnequipItemFromSlot(EES_Boots);
	witcher.UnequipItemFromSlot(EES_Gloves);
	witcher.UnequipItemFromSlot(EES_Pants);
	witcher.UnequipItemFromSlot(EES_Quickslot1);
	witcher.UnequipItemFromSlot(EES_Quickslot2);
	
	witcher.ClearAllSetBonuses();
}

exec function ForceAddEnchantment(slot : EEquipmentSlots, enchant : name, enchantStat : name)
{
	var item : SItemUniqueId;
	var witcher : W3PlayerWitcher;
	var inv : CInventoryComponent;
	
	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();
	inv.GetItemEquippedOnSlot(slot, item);
	inv.EnchantItem( item, enchant, enchantStat );
}

exec function FixCiriSword()
{
	var item : SItemUniqueId;
	var inv : CInventoryComponent;
	
	if( thePlayer.IsCiri() )
	{
		inv = GetCiriPlayer().GetInventory();
		item = GetCiriPlayer().GetEquippedSword(true);
		if( !inv.IsIdValid(item) ) 
			item = GetCiriPlayer().GetEquippedSword(false);
		if( inv.IsIdValid(item) )
			inv.GenerateItemLevel(item, false);
	}
}

exec function TestItemUpgradeList(itemName : name)
{
	var upgradeListName : name;
	
	upgradeListName = theGame.GetDefinitionsManager().GetItemUpgradeListName( itemName, false );
	theGame.GetGuiManager().ShowNotification(upgradeListName);
}

struct bodyentry
{
	var bodyId : SItemUniqueId;
	var bodyName : name;
}

struct itementry
{
	var itemName : name;
	var quantity : int;
}

exec function checksave()
{
	var i : int;
	var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
	var allItems : array<SItemUniqueId>;
	var curItem : SItemUniqueId;
	var bodyParts : array<bodyentry>;
	var items : array<bodyentry>;
	var minId : int;
	var msg : string;
	var last : string;
	var body : string;
	
	minId = 0;
	inv.GetAllItems(allItems);
	for(i=0; i<allItems.Size(); i+=1)
	{
		curItem = allItems[i];
		if( minId < ItemToFlashUInt(curItem) )
			minId = ItemToFlashUInt(curItem);
			
		items.PushBack((bodyentry)(curItem, inv.GetItemName(curItem)));
		if( inv.ItemHasTag(curItem, 'Body') )
		{
			bodyParts.PushBack((bodyentry)(curItem, inv.GetItemName(curItem)));
			body += ItemToFlashUInt(curItem) + ": " + inv.GetItemName(curItem) + "<br>";
		}
		
		if( i > allItems.Size() - 10 )
			last += ItemToFlashUInt(curItem) + ": " + inv.GetItemName(curItem) + "<br>";
	}
	
	curItem = GetInvalidUniqueId();
	msg = "Bless Polaks<br><br>Number of items: " + allItems.Size() + "<br>Highest item ID: " + minId + "<br><br>Body parts:<br>" + body + "<br>Last ten items:<br>" + last;
	theGame.GetGuiManager().ShowUserDialogAdv(0, "Bless Polaks", msg, false, UDB_Ok);
}

exec function fixsave1()
{
	var i : int;
	var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
	var items, item : array<SItemUniqueId>;
	var curItem : SItemUniqueId;
	var minId, start, maxId : int;
	
	minId = 0;
	inv.GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
	{
		curItem = items[i];
		if( minId < ItemToFlashUInt(curItem) )
			minId = ItemToFlashUInt(curItem);
			
		inv.DropItemInBag(curItem, inv.GetItemQuantity(curItem));
	}
	
	inv.RemoveAllItems();
	
	start = 65543 - minId;
	for(i=0; i<start; i+=1)
	{
		item = inv.AddAnItem('Bottled water', 1);
		maxId = ItemToFlashUInt(item[0]);
		inv.RemoveItem(item[0], 1);
	}
	
	theGame.SaveGame(SGT_CheckPoint, -1);
	
	theGame.GetGuiManager().ShowUserDialogAdv(0, "done", "Pause the game and load the newest save.", false, UDB_Ok);
}

exec function fixsave2()
{
	var i, j : int;
	var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
	var bagInv : CInventoryComponent;
	var items, bodyParts, item : array<SItemUniqueId>;
	var curItem : SItemUniqueId;
	var savedItems : array<itementry>;
	var maxId : int;
	var bag : W3ActorRemains;
	var entities : array<CGameplayEntity>;
	
	FindGameplayEntitiesInRange(entities, GetWitcherPlayer(), 1, 100);
	for(i=0; i<entities.Size(); i+=1)
	{
		bag = (W3ActorRemains)entities[i];
		if( bag )
			break;
	}
	
	if( !bag )
	{
		theGame.GetGuiManager().ShowUserDialogAdv(0, "failure", "Stand over the dropped loot bag.", false, UDB_Ok);
		return;
	}
	
	inv.GetAllItems(bodyParts);
	item = inv.AddAnItem('Bottled water', 1);
	maxId = ItemToFlashUInt(item[0]);
	inv.RemoveItem(item[0], 1);
	if( maxId - 65536 < 7 )
	{
		for(i=0; i<7 - (maxId - 65536); i+=1);
		{
			item = inv.AddAnItem('Bottled water', 1);
			maxId = ItemToFlashUInt(item[0]);
			inv.RemoveItem(item[0], 1);
		}
	}
	
	bagInv = bag.GetInventory();
	bagInv.GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
	{
		curItem = items[i];
		if( !bagInv.ItemHasTag(curItem, 'Body') )
			savedItems.PushBack((itementry)(bagInv.GetItemName(curItem), bagInv.GetItemQuantity(curItem)));
	}
	
	for(i=0; i<savedItems.Size(); i+=1)
	{
		item = inv.AddAnItem(savedItems[i].itemName, savedItems[i].quantity, true, true, false);
		for(j=0; j<bodyParts.Size(); j+=1)
		{
			if( ItemToFlashUInt(item[0]) == ItemToFlashUInt(bodyParts[j]) )
			{
				inv.RemoveItem(item[0], savedItems[i].quantity);
				item = inv.AddAnItem(savedItems[i].itemName, savedItems[i].quantity, true, true, false);
			}
		}
	}
	
	bag.Destroy();
}