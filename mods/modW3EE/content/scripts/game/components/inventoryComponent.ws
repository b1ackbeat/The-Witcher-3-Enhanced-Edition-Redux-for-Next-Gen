/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




struct SItemAttributes
{
	var abilityName, attributeName : name;
	var buffType : EEffectType;
}

class IInventoryScriptedListener
{
	event OnInventoryScriptedEvent( eventType : EInventoryEventType, itemId : SItemUniqueId, quantity : int, fromAssociatedInventory : bool ) {}
}

import struct SItemNameProperty
{
	import editable var itemName : name;
};

import struct SR4LootNameProperty
{
	import editable var lootName : name;
};

struct SItemExt
{
	editable var itemName : SItemNameProperty;
	editable var quantity : int;
		default quantity = 1;
};

struct SCardSourceData
{
	var cardName 	: name;
	var source 		: string;
	var originArea	: string;
	var originQuest	: string;
	var details		: string;
	var coords		: string;
};


import struct SItemChangedData
{
	import const var itemName : name;				
	import const var quantity : int;				
	import const var informGui : bool;				
	import const var ids : array< SItemUniqueId >;	
};

import class CInventoryComponent extends CComponent
{
	editable 		var priceMult			: float;
	editable 		var priceRepairMult		: float;
	editable 		var priceRepair			: float;
	editable 		var fundsType 			: EInventoryFundsType;

	private 		var recentlyAddedItems 	: array<SItemUniqueId>;
	private			var fundsMax			: int;
	private			var daysToIncreaseFunds	: int;

	default	priceMult = 1.0;
	default	priceRepairMult = 1.0;
	default	priceRepair = 10.0;
	default fundsType = EInventoryFunds_Avg;
	default daysToIncreaseFunds = 5;

	
	
	
	public function GetFundsType() : EInventoryFundsType
	{
		return fundsType;
	}

	public function GetDaysToIncreaseFunds() : int
	{
		return daysToIncreaseFunds;
	}

	// W3EE - Begin
	public function GetFundsMax() : float
	{
		if ( EInventoryFunds_Broke == fundsType )
		{
			return 20;
		}
		else if ( EInventoryFunds_Avg == fundsType )
		{
			return 300;
		}
		else if ( EInventoryFunds_Poor == fundsType )
		{
			return 100;
		}
		else if ( EInventoryFunds_Rich == fundsType )
		{
			return 1000;
		}
		else if ( EInventoryFunds_RichQuickStart == fundsType )
		{
			return 2500;
		}
		return -1;
	}

	public function SetupFunds()
	{
		if ( EInventoryFunds_Broke == fundsType )
		{
			AddMoney( (int)( 10 * GetFundsModifier() ) );
		}
		else if ( EInventoryFunds_Poor == fundsType )
		{
			AddMoney( (int)( 50 * GetFundsModifier() ) );
		}
		else if ( EInventoryFunds_Avg == fundsType )
		{
			AddMoney( (int)( 150 * GetFundsModifier() ) );
		}
		else if ( EInventoryFunds_Rich == fundsType )
		{
			AddMoney( (int)( 500 * GetFundsModifier() ) );
		}
		else if ( EInventoryFunds_RichQuickStart == fundsType )
		{
			AddMoney( (int)( 1250 * GetFundsModifier() ) );
		}
	}
	
	public function IncreaseFunds()
	{
		if ( GetMoney() < GetFundsMax() )
		{
			if ( EInventoryFunds_Broke == fundsType )
			{
				AddMoney( (int)( 2 * GetFundsModifier()) );
			}
			else if ( EInventoryFunds_Avg == fundsType )
			{
				AddMoney( (int)( 30 * GetFundsModifier()) );
			}
			else if ( EInventoryFunds_Poor == fundsType )
			{
				AddMoney( (int)( 10 * GetFundsModifier() ) );
			}
			else if ( EInventoryFunds_Rich == fundsType )
			{
				AddMoney( (int)( 100 * GetFundsModifier() ) );
			}
			else if ( EInventoryFunds_RichQuickStart == fundsType )
			{
				AddMoney( 100 + (int)( 250 * GetFundsModifier() ) );
			}
		}
	}

	public function GetMoney() : int
	{
		/*if( thePlayer == GetEntity() && (Equipment().GetHorseDistance() <= 81 || Options().InvEverywhere()) )
		{*/
		if( GetEntity() == thePlayer )
			return GetItemQuantityByName('Crowns') + GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemQuantityByName('Crowns');
		else
		if( this == GetWitcherPlayer().GetHorseManager().GetInventoryComponent() )
			return GetItemQuantityByName('Crowns') + GetWitcherPlayer().inv.GetItemQuantityByName('Crowns');
		else
			return GetItemQuantityByName('Crowns');
		/*}
		else
		{
			return GetItemQuantityByName( 'Crowns' );
		}*/
	}
	// W3EE - End
	
	public function SetMoney( amount : int )
	{
		var currentMoney : int;
		
		if ( amount >= 0 )
		{
			currentMoney = GetMoney();
			RemoveMoney( currentMoney );

			AddAnItem( 'Crowns', amount );
		}
	}

	public function AddMoney( amount : int )
	{
		if ( amount > 0 )
		{
			AddAnItem( 'Crowns', amount );
			
			if ( thePlayer == GetEntity() )
			{
				theTelemetry.LogWithValue( TE_HERO_CASH_CHANGED, amount );
			}
		}
	}
	
	// W3EE - Begin
	public function RemoveMoney( amount : int )
	{
		var money, diff : int;
		
		if ( amount > 0 )
		{
			money = GetItemQuantityByName('Crowns');
			if( GetEntity() == thePlayer && amount > money )
			{
				diff = amount - money;
				RemoveItemByName('Crowns', money);
				GetWitcherPlayer().GetHorseManager().GetInventoryComponent().RemoveItemByName('Crowns', diff);
			}
			else
			if( GetEntity() == GetWitcherPlayer().GetHorseManager() && amount > money )
			{
				diff = amount - money;
				RemoveItemByName('Crowns', money);
				GetWitcherPlayer().inv.RemoveItemByName('Crowns', diff);
			}
			else RemoveItemByName( 'Crowns', amount );
			
			if ( thePlayer == GetEntity() )
			{
				theTelemetry.LogWithValue( TE_HERO_CASH_CHANGED, -amount );
			}
		}
	}
	// W3EE - End

	
	
	
	
	import final function GetItemAbilityAttributeValue( itemId : SItemUniqueId, attributeName : name, abilityName : name) : SAbilityAttributeValue;
	
	import final function GetItemFromSlot( slotName : name ) : SItemUniqueId;
		
	
	import final function IsIdValid( itemId : SItemUniqueId ) : bool;

	
	import final function GetItemCount( optional useAssociatedInventory : bool  ) : int;
	
	
	import final function GetItemsNames() : array< name >;
	
	
	import final function GetAllItems( out items : array< SItemUniqueId > );
	
	
	import public function GetItemId( itemName : name ) : SItemUniqueId;
	
	
	import public function GetItemsIds( itemName : name ) : array< SItemUniqueId >;
	
	
	import final function GetItemsByTag( tag : name ) : array< SItemUniqueId >;
	
	
	import final function GetItemsByCategory( category : name ) : array< SItemUniqueId >;
	
	
	import final function GetSchematicIngredients(itemName : SItemUniqueId, out quantity : array<int>, out names : array<name>); 
	
	
	import final function GetSchematicRequiredCraftsmanType(craftName : SItemUniqueId) : name; 
	
	
	import final function GetSchematicRequiredCraftsmanLevel(craftName : SItemUniqueId) : name; 
    
    
    import final function GetNumOfStackedItems( itemUniqueId: SItemUniqueId ) : int;
	
	import final function InitInvFromTemplate( resource : CEntityTemplate );
	
	
	
	
	import final function SplitItem( itemID : SItemUniqueId, quantity : int ) : SItemUniqueId;
	
	
	
	import final function SetItemStackable( itemID : SItemUniqueId, flag : bool );
	
	
	import final function GetCategoryDefaultItem( category : name ) : name;
	
	
	
	
	
	
	import final function GetItemLocalizedNameByName( itemName : CName ) : string;
	
	
    import final function GetItemLocalizedDescriptionByName( itemName : CName ) : string;
    
	
	import final function GetItemLocalizedNameByUniqueID( itemUniqueId : SItemUniqueId ) : string;
	
	// W3EE - Begin
	public final function GetItemLocNameByID( item : SItemUniqueId ) : string
	{
		//Kolaris - Inventory Options
		if ( Options().DetailedItemNames() )
			return GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item)) + " (" + GetItemName(item) + ")" ;
		
		if( !IsItemAnyArmor(item) && !IsItemWeapon(item) )
			return GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item));
			
		return GetItemNameWithPrefix(item);
	}
	
	private function GetItemNameWithPrefix( item : SItemUniqueId ) : string
	{
		var attributeValue : SAbilityAttributeValue;
		var abilityArray, arr : array<name>;
		var itemPrefix, itemName : string;
		var temp, textLanguage : string;
		var i : int;
		
		abilityArray.Clear();
		theGame.GetGameLanguageName(temp, textLanguage);
		if( IsItemWeapon(item) )
		{
			if( GetItemQuality(item) >= 1 )
			{
				arr = theGame.params.GetCommonWeaponAbilityArray();
				ArrayOfNamesAppend(abilityArray, arr);
			}
			if( GetItemQuality(item) >= 2 )
			{
				arr = theGame.params.GetMasterworkWeaponAbilityArray();
				ArrayOfNamesAppend(abilityArray, arr);
			}
			if( GetItemQuality(item) >= 3 )
			{
				arr = theGame.params.GetMagicalWeaponAbilityArray();
				ArrayOfNamesAppend(abilityArray, arr);
			}
		}
		else
		if( IsItemAnyArmor(item) )
		{
			if( GetItemCategory(item) == 'armor' )
			{
				if( GetItemQuality(item) >= 2 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMasterLightArmorAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMasterMediumArmorAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMasterHeavyArmorAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
				if( GetItemQuality(item) >= 3 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMagicalLightArmorAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMagicalMediumArmorAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMagicalHeavyArmorAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
			}
			else
			if( GetItemCategory(item) == 'boots' )
			{
				if( GetItemQuality(item) >= 2 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMasterLightBootsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMasterMediumBootsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMasterHeavyBootsAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
				if( GetItemQuality(item) >= 3 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMagicalLightBootsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMagicalMediumBootsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMagicalHeavyBootsAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
			}
			else
			if( GetItemCategory(item) == 'pants' )
			{
				if( GetItemQuality(item) >= 2 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMasterLightPantsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMasterMediumPantsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMasterHeavyPantsAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
				if( GetItemQuality(item) >= 3 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMagicalLightPantsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMagicalMediumPantsAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMagicalHeavyPantsAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
			}
			else
			if( GetItemCategory(item) == 'gloves' )
			{
				if( GetItemQuality(item) >= 2 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMasterLightGlovesAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMasterMediumGlovesAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMasterHeavyGlovesAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
				if( GetItemQuality(item) >= 3 )
				{
					if( GetArmorType(item) == EAT_Light )
						arr = theGame.params.GetMagicalLightGlovesAbilityArray();
					else
					if( GetArmorType(item) == EAT_Medium )
						arr = theGame.params.GetMagicalMediumGlovesAbilityArray();
					else
					if( GetArmorType(item) == EAT_Heavy )
						arr = theGame.params.GetMagicalHeavyGlovesAbilityArray();
						
					ArrayOfNamesAppend(abilityArray, arr);
				}
			}
		}
		
		itemName = GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item));
		for(i=0; i<abilityArray.Size(); i+=1)
		{
			attributeValue = GetItemAttributeValue(item, abilityArray[i]);
			if( attributeValue.valueBase > 0 )
			{
				itemPrefix = GetLocStringByKeyExt(NameToString(abilityArray[i]));
				if( itemPrefix != "" )
				{
					if( textLanguage == "IT" || textLanguage == "FR" || textLanguage == "BR" )
						return itemName + " " + itemPrefix;
					else
						return itemPrefix + " " + itemName;
				}
				
				break;
			}
		}
		
		return itemName;
	}
	// W3EE - End
	
    import final function GetItemLocalizedDescriptionByUniqueID( itemUniqueId : SItemUniqueId ) : string;
    
    
    import final function GetItemIconPathByUniqueID( itemUniqueId : SItemUniqueId ) : string;
    
    
    import final function GetItemIconPathByName( itemName : CName ) : string;
    
    import final function AddSlot( itemUniqueId : SItemUniqueId ) : bool;
    
	import final function GetSlotItemsLimit( itemUniqueId : SItemUniqueId ) : int;
	
    import private final function BalanceItemsWithPlayerLevel( playerLevel : int );
    
    public function ForceSpawnItemOnStart( itemId : SItemUniqueId ) : bool	
	{
		return ItemHasTag(itemId, 'MutagenIngredient');
	}
    
    public final function GetItemArmorTotal(item : SItemUniqueId) : SAbilityAttributeValue
    {
		var armor, armorBonus : SAbilityAttributeValue;
		var durMult : float;
		
		armor = GetItemAttributeValue(item, theGame.params.ARMOR_VALUE_NAME);
		armorBonus = GetRepairObjectBonusValueForArmor(item);
		durMult = theGame.params.GetDurabilityMultiplier( GetItemDurabilityRatio(item), false);
		
		return armor * durMult + armorBonus;
    }
    
    public final function GetItemLevel(item : SItemUniqueId) : int
    {
		var itemCategory : name;
		// W3EE - Begin
		var itemAttributes, itemAttributes2 : array<SAbilityAttributeValue>;
		var itemName : name;
		var level, baseLevel, levelDiff, itemQuality, i, altLevel : int;
		var canItemScale : bool = false;
		var itemTags : array <name>;
		
		itemQuality = RoundMath( CalculateAttributeValue( GetItemAttributeValue(item, 'quality' ) ) );
		itemCategory = GetItemCategory(item);
		itemName = GetItemName(item);
		
		switch(itemCategory)
		{
			case 'armor' :
			case 'boots' :
			case 'gloves' :
			case 'pants' :
				itemAttributes.PushBack( GetItemAttributeValue(item, 'armor') );
				if( itemAttributes[0].valueBase > 0 ) canItemScale = true;
				break;
				
			case 'silversword' :
				itemAttributes.PushBack( GetItemAttributeValue(item, 'SilverDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'BludgeoningDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'RendingDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'ElementalDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'FireDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'PiercingDamage') );
				canItemScale = true;
				break;
				
			case 'steelsword' :
				itemAttributes.PushBack( GetItemAttributeValue(item, 'SlashingDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'BludgeoningDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'RendingDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'ElementalDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'FireDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'SilverDamage') );
				itemAttributes.PushBack( GetItemAttributeValue(item, 'PiercingDamage') );
				canItemScale = true;
				break;
				
			case 'crossbow' :
				itemAttributes.PushBack( GetItemAttributeValue(item, 'attack_power') );
				canItemScale = false;
				break;
				
			default :
				break;
		}
		level = theGame.params.GetItemLevel(itemCategory, itemAttributes, itemName, baseLevel);
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			if ( baseLevel > GetWitcherPlayer().GetMaxLevel() ) 
			{
				level = baseLevel;
			}
		}
		
		if ( itemQuality == 5 ) level = level - 2;
		if ( itemQuality == 4 ) level = level - 1;
		//if ( level < 1 ) level = 1;
		if ( ItemHasTag(item, 'OlgierdSabre') ) level = level - 3;
		if ( (itemQuality == 4 || itemQuality == 5) && ItemHasTag(item, 'EP1') ) level = level - 1;
		if ( level < 1 ) level = 1;
		
		if( canItemScale )
		{
			switch( GetArmorTypeOriginal(item) )
			{
				case EAT_Heavy: levelDiff = 90; break;
				case EAT_Medium: levelDiff = 60; break;
				case EAT_Light: levelDiff = 40; break;
				default : levelDiff = 90; break;
			}
			
			if( ItemHasTag(item, 'Wooden') )
				levelDiff = 40;
			else
			if( ItemHasTag(item, 'DamagedWeapon') )
				levelDiff = 55;
			else
			if( ItemHasTag(item, 'TypeBattleaxe') )
				levelDiff = 100;
			else
			if( ItemHasTag(item, 'TypeBattlemace') )
				levelDiff = 95;
			else
			if( ItemHasTag(item, 'SecondaryWeapon') )
				levelDiff = 78;
			
			if( itemName == 'Aerondight EP2' )
				levelDiff = 95;
			
			switch( itemQuality )
			{
				case 1: levelDiff -= 7; break;
				case 2: levelDiff -= 5; break;
				case 3: levelDiff -= 3; break;
			}
			
			levelDiff -= level;
			
			if( levelDiff > 0 )
			{
				switch(itemCategory)
				{
					case 'armor' :
						for (i=0; i<levelDiff; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true);
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'armor') );
					break;
					
					case 'boots' :
						for (i=0; i<levelDiff; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true);
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'armor') );
					break;
					
					case 'gloves' :
						for (i=0; i<levelDiff; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true);
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'armor') );
					break;
					
					case 'pants' :
						for (i=0; i<levelDiff; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true);
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'armor') );
					break;
					
					case 'silversword' :
						altLevel = (levelDiff + level) / 4;
						
						for (i=0; i<levelDiff; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true);
						for (i=0; i<altLevel; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true);
						
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'SilverDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'BludgeoningDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'RendingDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'ElementalDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'FireDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'PiercingDamage') );
					break;
					
					case 'steelsword' :
						altLevel = levelDiff + level - 4;
						
						for (i=0; i<levelDiff; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true);
						for (i=0; i<altLevel; i+=1)
							AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true);
						
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'SlashingDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'BludgeoningDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'RendingDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'ElementalDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'FireDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'SilverDamage') );
						itemAttributes2.PushBack( GetItemAttributeValue(item, 'PiercingDamage') );
					break;
					
					default : break;
				}
				level = theGame.params.GetItemLevel(itemCategory, itemAttributes2, itemName);
			}
		}
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			if ( level > GetWitcherPlayer().GetMaxLevel() ) 
			{
				level = GetWitcherPlayer().GetMaxLevel();
			}
		}
		// W3EE - End
		return level;
    }
    
    public function GetItemLevelColorById( itemId : SItemUniqueId ) : string
    {
		var color : string;
		
		//W3EE - Begin
		

		/*
		if (GetItemLevel(itemId) <= thePlayer.GetLevel())
		{
			color = "<font color = '#66FF66'>"; // green		
		}
		else
		{
			color = "<font color = '#9F1919'>"; // red
		}
		*/
		
		Equipment().LevelRequirementIndicator(color, itemId, this);
		//W3EE - End
		
		return color;
    }
	
  	public function GetItemLevelColor( lvl_item : int ) : string
	{
		var color : string;

		//W3EE - Begin	
		

		/*
		if ( lvl_item > thePlayer.GetLevel() ) 
		{
			color = "<font color = '#9F1919'>"; // red	
		} 
		else
		{
			color = "<font color = '#66FF66'>"; // green
		}
		*/
		
		Equipment().LevelRequirementIndicator2(color, lvl_item, this);
		//W3EE - End
		
		return color;
	}	
	
    public final function AutoBalanaceItemsWithPlayerLevel()
    {
		var playerLevel : int;

		playerLevel = thePlayer.GetLevel();

		if( playerLevel < 0 )
		{
			playerLevel = 0;
		}
		
		BalanceItemsWithPlayerLevel( playerLevel );
    }
    
    public function GetItemsByName(itemName : name) : array<SItemUniqueId>
    {
		var ret : array<SItemUniqueId>;
		var i : int;
    
		if(!IsNameValid(itemName))
			return ret;
			
		GetAllItems(ret);
		
		for(i=ret.Size()-1; i>=0; i-=1)
		{
			if(GetItemName(ret[i]) != itemName)
			{
				ret.EraseFast( i );
			}
		}
				
		return ret;
    }
    
    public final function GetSingletonItems() : array<SItemUniqueId>
    {
		return GetItemsByTag(theGame.params.TAG_ITEM_SINGLETON);
	}
	
	
	import final function GetItemQuantityByName( itemName : name, optional useAssociatedInventory : bool , optional ignoreTags : array< name > ) : int;
	
	
	import final function GetItemQuantityByCategory( itemCategory : name, optional useAssociatedInventory : bool , optional ignoreTags : array< name > ) : int;

	
	import final function GetItemQuantityByTag( itemTag : name, optional useAssociatedInventory : bool , optional ignoreTags : array< name > ) : int;

	
	import final function GetAllItemsQuantity( optional useAssociatedInventory : bool , optional ignoreTags : array< name > ) : int;

	public function IsEmpty(optional bSkipNoDropNoShow : bool) : bool
	{
		var i : int;
		var itemIds : array<SItemUniqueId>;
		
		if(bSkipNoDropNoShow)
		{
			GetAllItems( itemIds );
			for(i=0; i<itemIds.Size(); i+=1)
			{
				if( !ItemHasTag( itemIds[ i ],theGame.params.TAG_DONT_SHOW ) && !ItemHasTag( itemIds[ i ], 'NoDrop' ) )
				{
					return false;
				}
				else if ( ItemHasTag( itemIds[ i ], 'Lootable') )
				{
					return false;
				}
			}
			
			return true;
		}

		return GetItemCount() <= 0;
	}
	
	public function GetAllHeldAndMountedItemsCategories( out heldItems : array<name>, optional out mountedItems : array<name> )
	{
		var allItems : array<SItemUniqueId>;
		var i : int;
		
		GetAllItems(allItems);
		for(i=allItems.Size()-1; i >= 0; i-=1)
		{
			if ( IsItemHeld(allItems[i]) )
				heldItems.PushBack(GetItemCategory(allItems[i]));
			else if ( IsItemMounted(allItems[i]) )
				mountedItems.PushBack(GetItemCategory(allItems[i]));
		}
	}
	
	public function GetAllHeldItemsNames( out heldItems : array<name> )
	{
		var allItems : array<SItemUniqueId>;
		var i : int;
		
		GetAllItems(allItems);
		for(i=allItems.Size()-1; i >= 0; i-=1)
		{
			if ( IsItemHeld(allItems[i]) )
				heldItems.PushBack(GetItemName(allItems[i]));
		}
	}
	
	public function HasMountedItemByTag(tag : name) : bool
	{
		var i : int;
		var allItems : array<SItemUniqueId>;
		
		if(!IsNameValid(tag))
			return false;
			
		allItems = GetItemsByTag(tag);
		for(i=0; i<allItems.Size(); i+=1)
			if(IsItemMounted(allItems[i]))
				return true;
				
		return false;
	}
	
	public function HasHeldOrMountedItemByTag(tag : name) : bool
	{
		var i : int;
		var allItems : array<SItemUniqueId>;
		
		if(!IsNameValid(tag))
			return false;
			
		allItems = GetItemsByTag(tag);
		for(i=0; i<allItems.Size(); i+=1)
			if( IsItemMounted(allItems[i]) || IsItemHeld(allItems[i]) )
				return true;
				
		return false;
	}
	
	
	import final function GetItem( itemId : SItemUniqueId ) : SInventoryItem;
	
	
	import final function GetItemName( itemId : SItemUniqueId ) : name;
	
	
	import final function GetItemCategory( itemId : SItemUniqueId ) : name;
	
	
	import final function GetItemClass( itemId : SItemUniqueId ) : EInventoryItemClass; 
	
	
	import final function GetItemTags( itemId : SItemUniqueId, out tags : array<name> ) : bool;

	
	import final function GetCraftedItemName( itemId : SItemUniqueId ) : name; 
	
	
	import final function TotalItemStats( invItem : SInventoryItem ) : float;

	import final function GetItemPrice( itemId : SItemUniqueId ) : int;

	import final function GetItemPriceModified( itemId : SItemUniqueId, optional playerSellingItem : bool ) : int;
	
	import final function GetInventoryItemPriceModified( invItem : SInventoryItem, optional playerSellingItem : bool ) : int;
	
	import final function GetItemPriceRepair( invItem : SInventoryItem, out costRepairPoint : int, out costRepairTotal : int );	
	
	import final function GetItemPriceRemoveUpgrade( invItem : SInventoryItem ) : int;
	
	import final function GetItemPriceDisassemble( invItem : SInventoryItem ) : int;
	
	import final function GetItemPriceAddSlot( invItem : SInventoryItem ) : int;

	import final function GetItemPriceCrafting( invItem : SInventoryItem ) : int;

	import final function GetItemPriceEnchantItem( invItem : SInventoryItem ) : int;
	
	import final function GetItemPriceRemoveEnchantment( invItem : SInventoryItem ) : int;
	
	// W3EE - Begin
	public function GetItemBasePrice( item : SItemUniqueId ) : int
	{
		var i : int;
		var price : int;
		var invItem : SInventoryItem;
		var baseAbilities : array<name>;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var durabilityMult, categoryMult, qualityMult : float;
		
		durabilityMult = LFEGetDurabilityMult(GetItemDurabilityRatio(item));
		categoryMult = LFEGetCategoryMult(GetItemCategory(item));
		if( IsItemJewelry(item) )
			categoryMult = 1;
		qualityMult = LFEGetQualityMult(GetItemQuality(item));
		if( !IsItemAnyArmor(item) && (!IsItemWeapon(item) || IsItemCrossbow(item) || IsItemBolt(item)) )
			price = GetItemPrice(item);
		else
		{
			invItem = GetItem(item);
			GetItemAbilities(item, baseAbilities);
			for(i=0; i<baseAbilities.Size(); i+=1)
			{
				if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
					continue;
					
				if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
				{
					RemoveItemCraftedAbility(item, baseAbilities[i]);
					removedCrafted.PushBack(baseAbilities[i]);
				}
				else
				{
					RemoveItemBaseAbility(item, baseAbilities[i]);
					removedBase.PushBack(baseAbilities[i]);
				}
			}
			
			price = GetItemPrice(item);
			GetItemAbilities(item, remainingAbilities);
			for(i=0; i<removedBase.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedBase[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
					continue;
				}
				
				AddItemBaseAbility(item, removedBase[i]);
			}
			
			for(i=0; i<removedCrafted.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedCrafted[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
					continue;
				}
				
				AddItemCraftedAbility(item, removedCrafted[i], true);
			}
		}
		
		return CeilF(price * durabilityMult * categoryMult * qualityMult);
	}
	
	public function GetItemSellPrice( item : SItemUniqueId ) : int
	{
		var areaMult, sellingMult : float;
		
		areaMult = GetAreaPriceMult(item, GetItemQuality(item));
		//Kolaris - Difficulty Settings
		sellingMult = LFEGetSellingMult(false) * Options().GetDifficultySettingMod();
		
		return Max(1, CeilF(GetItemBasePrice(item) * areaMult * sellingMult));
	}
	
	public function GetItemBasePriceRepair( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var price : int;
		var repairMult : float;
		
		repairMult = LFEGetRepairMult();
		price = CeilF(originalInventory.GetItemBasePrice(invItem.uniqueId) * 0.4f * (1.f - originalInventory.GetItemDurability(invItem.uniqueId) / originalInventory.GetItemMaxDurability(invItem.uniqueId)));
		
		return Max(1, CeilF(price * repairMult));
	}
	
	public function GetItemBasePriceRemoveUpgrade( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var price : int;
		var removeUpgradeMult : float;
		var temp : array<name>;
		
		removeUpgradeMult = LFEGetRemoveUpgradeMult();
		originalInventory.GetItemEnhancementItems(invItem.uniqueId, temp);
		price = temp.Size() * 20;
		
		return Max(1, CeilF(price * removeUpgradeMult));
	}
	
	public function GetItemBasePriceAddSlot( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		return 75;
	}
	
	public function GetItemBasePriceDisassemble( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var i : int;
		var price : int;
		var baseAbilities : array<name>;
		var unleveledItem : SInventoryItem;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var disassembleMult : float;
		
		disassembleMult = LFEGetDisassembleMult();
		originalInventory.GetItemAbilities(invItem.uniqueId, baseAbilities);
		for(i=0; i<baseAbilities.Size(); i+=1)
		{
			if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
				continue;
				
			if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
			{
				originalInventory.RemoveItemCraftedAbility(invItem.uniqueId, baseAbilities[i]);
				removedCrafted.PushBack(baseAbilities[i]);
			}
			else
			{
				originalInventory.RemoveItemBaseAbility(invItem.uniqueId, baseAbilities[i]);
				removedBase.PushBack(baseAbilities[i]);
			}
		}
		
		unleveledItem = originalInventory.GetItem(invItem.uniqueId);
		price = GetItemPriceDisassemble(unleveledItem);
		originalInventory.GetItemAbilities(invItem.uniqueId, remainingAbilities);
		for(i=0; i<removedBase.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedBase[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
				continue;
			}
			
			originalInventory.AddItemBaseAbility(invItem.uniqueId, removedBase[i]);
		}
		
		for(i=0; i<removedCrafted.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedCrafted[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
				continue;
			}
			
			originalInventory.AddItemCraftedAbility(invItem.uniqueId, removedCrafted[i], true);
		}
		
		return Max(1, CeilF(price * disassembleMult));
	}
	
	public function GetItemBasePriceCrafting( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var i : int;
		var price : int;
		var baseAbilities : array<name>;
		var unleveledItem : SInventoryItem;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var craftingMult : float;
		
		craftingMult = LFEGetCraftMult();
		originalInventory.GetItemAbilities(invItem.uniqueId, baseAbilities);
		for(i=0; i<baseAbilities.Size(); i+=1)
		{
			if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
				continue;
				
			if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
			{
				originalInventory.RemoveItemCraftedAbility(invItem.uniqueId, baseAbilities[i]);
				removedCrafted.PushBack(baseAbilities[i]);
			}
			else
			{
				originalInventory.RemoveItemBaseAbility(invItem.uniqueId, baseAbilities[i]);
				removedBase.PushBack(baseAbilities[i]);
			}
		}
		
		unleveledItem = originalInventory.GetItem(invItem.uniqueId);
		price = GetItemPriceCrafting(unleveledItem);
		originalInventory.GetItemAbilities(invItem.uniqueId, remainingAbilities);
		for(i=0; i<removedBase.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedBase[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
				continue;
			}
			
			originalInventory.AddItemBaseAbility(invItem.uniqueId, removedBase[i]);
		}
		
		for(i=0; i<removedCrafted.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedCrafted[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
				continue;
			}
			
			originalInventory.AddItemCraftedAbility(invItem.uniqueId, removedCrafted[i], true);
		}
		
		return Max(1, CeilF(price * craftingMult));
	}
	
	public function GetItemBasePriceModified( item : SItemUniqueId, optional playerSelling : bool ) : int
	{
		var i : int;
		var price : int;
		var invItem : SInventoryItem;
		var baseAbilities : array<name>;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var durabilityMult, categoryMult, qualityMult, areaMult, sellingMult : float;
		
		durabilityMult = LFEGetDurabilityMult(GetItemDurabilityRatio(item));
		categoryMult = LFEGetCategoryMult(GetItemCategory(item));
		if( IsItemJewelry(item) )
			categoryMult = 1;
		qualityMult = LFEGetQualityMult(GetItemQuality(item));
		areaMult = GetAreaPriceMult(item, GetItemQuality(item));
		sellingMult = LFEGetSellingMult(playerSelling);
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
			sellingMult *= 1.25f;
		//Kolaris - Huntsman
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_19) && IsItemTrophy(item))
			sellingMult *= 1.5f;
		//Kolaris - Difficulty Settings
		if( playerSelling )
			sellingMult /= Options().GetDifficultySettingMod();
		else
			sellingMult *= Options().GetDifficultySettingMod();
			
		if( !IsItemAnyArmor(item) && (!IsItemWeapon(item) || IsItemCrossbow(item) || IsItemBolt(item)) )
			price = GetItemPriceModified(item, playerSelling);
		else
		{
			invItem = GetItem(item);
			GetItemAbilities(item, baseAbilities);
			for(i=0; i<baseAbilities.Size(); i+=1)
			{
				if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
					continue;
					
				if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
				{
					RemoveItemCraftedAbility(item, baseAbilities[i]);
					removedCrafted.PushBack(baseAbilities[i]);
				}
				else
				{
					RemoveItemBaseAbility(item, baseAbilities[i]);
					removedBase.PushBack(baseAbilities[i]);
				}
			}
			
			price = GetItemPriceModified(item, playerSelling);
			GetItemAbilities(invItem.uniqueId, remainingAbilities);
			for(i=0; i<removedBase.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedBase[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
					continue;
				}
				
				AddItemBaseAbility(item, removedBase[i]);
			}
			
			for(i=0; i<removedCrafted.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedCrafted[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
					continue;
				}
				
				AddItemCraftedAbility(item, removedCrafted[i], true);
			}
		}
		
		if( playerSelling )
			return Abs(FloorF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult));
		else
			return Abs(CeilF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult));
	}
	
	public function GetInventoryItemBasePriceModified( invItem : SInventoryItem, originalInventory : CInventoryComponent, optional playerSelling : bool, optional merchantEntity : CEntity ) : int
	{
		var i : int;
		var price : int;
		var baseAbilities : array<name>;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var unleveledItem : SInventoryItem;
		var durabilityMult, categoryMult, qualityMult, areaMult, sellingMult, merchantMult : float;
		
		durabilityMult = LFEGetDurabilityMult(originalInventory.GetItemDurabilityRatio(invItem.uniqueId));
		categoryMult = LFEGetCategoryMult(originalInventory.GetItemCategory(invItem.uniqueId));
		if( originalInventory.IsItemJewelry(invItem.uniqueId) )
			categoryMult = 1;
		qualityMult = LFEGetQualityMult(originalInventory.GetItemQuality(invItem.uniqueId));
		areaMult = originalInventory.GetAreaPriceMult(invItem.uniqueId, originalInventory.GetItemQuality(invItem.uniqueId));
		sellingMult = LFEGetSellingMult(playerSelling);
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
			sellingMult *= 1.25f;
		//Kolaris - Huntsman
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_19) && originalInventory.IsItemTrophy(invItem.uniqueId))
			sellingMult *= 1.5f;
		//Kolaris - Difficulty Settings
		if( playerSelling )
			sellingMult /= Options().GetDifficultySettingMod();
		else
			sellingMult *= Options().GetDifficultySettingMod();
		if( playerSelling && merchantEntity )
			merchantMult = originalInventory.GetMerchantMult(invItem.uniqueId, merchantEntity);
		else
			merchantMult = 1;
			
		if( !originalInventory.IsItemAnyArmor(invItem.uniqueId) && (!originalInventory.IsItemWeapon(invItem.uniqueId) || originalInventory.IsItemCrossbow(invItem.uniqueId) || originalInventory.IsItemBolt(invItem.uniqueId)) )
			price = originalInventory.GetInventoryItemPriceModified(invItem, playerSelling);
		else
		{
			originalInventory.GetItemAbilities(invItem.uniqueId, baseAbilities);
			for(i=0; i<baseAbilities.Size(); i+=1)
			{
				if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
					continue;
					
				if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
				{
					originalInventory.RemoveItemCraftedAbility(invItem.uniqueId, baseAbilities[i]);
					removedCrafted.PushBack(baseAbilities[i]);
				}
				else
				{
					originalInventory.RemoveItemBaseAbility(invItem.uniqueId, baseAbilities[i]);
					removedBase.PushBack(baseAbilities[i]);
				}
			}
			
			unleveledItem = originalInventory.GetItem(invItem.uniqueId);
			price = originalInventory.GetInventoryItemPriceModified(unleveledItem, playerSelling);
			originalInventory.GetItemAbilities(invItem.uniqueId, remainingAbilities);
			for(i=0; i<removedBase.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedBase[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
					continue;
				}
				
				originalInventory.AddItemBaseAbility(invItem.uniqueId, removedBase[i]);
			}
			
			for(i=0; i<removedCrafted.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedCrafted[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
					continue;
				}
				
				originalInventory.AddItemCraftedAbility(invItem.uniqueId, removedCrafted[i], true);
			}
		}
		
		if( playerSelling )
			return Abs(FloorF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult * merchantMult));
		else
			return Abs(CeilF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult * merchantMult));
	}
	
	public function GetAreaPriceMultByName( item : name ) : float
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var area : EAreaName = theGame.GetCommonMapManager().GetCurrentArea();
		var itemRarity : int;
		var worldPos : Vector;
		
		itemRarity = dm.GetItemQuality(item);
		switch(area)
		{
			case AN_NMLandNovigrad:
				worldPos = GetWitcherPlayer().GetWorldPosition();
				
				if( worldPos.X > 1650.f || worldPos.Y > 1400.f )
				{
					return 1;
				}
				else
				{
					if( dm.IsItemFood(item) )
						return 2;
					else
					if( dm.IsItemJewelry(item) )
						return 0.5;
					else
					if( dm.IsItemReadable(item) )
						return 0.5;
					else
					if( dm.IsItemTrophy(item) )
						return 0.5;
					else
					if( dm.IsItemHerb(item) )
						return 0.5;
					else
					if( dm.IsItemJunk(item) )
						return 0.5f;
					else
						return 1;
				}
			break;
			
			case AN_Skellige_ArdSkellig:
				if( dm.IsItemFood(item) )
					return 1.5;
				else
				if( dm.IsItemAlchemicalAlcohol(item) )
					return 1.5;
				else
				if( dm.IsItemTrophy(item) )
					return 1.5;
				else
				if( dm.IsItemJewelry(item) )
					return 0.5;
				else
				if( dm.IsItemHorseItem(item) )
					return 0.5;
				else
				if( dm.IsItemWeapon(item) )
				{
					switch( itemRarity )
					{
						case 1: return 0.7;
						case 2: return 0.85;
						case 3: return 1;
						case 4: return 1.2;
						case 5: return 1.2;
					}
				}
				else
					return 1;
			break;
			
			case AN_Prologue_Village:
				if( dm.IsItemHerb(item) )
					return 0.5;
				else
				if( dm.IsItemTrophy(item) )
					return 0.5;
				else
				if( dm.IsItemWeapon(item) )
					return 0.75;
				else
				if( dm.IsItemJewelry(item) )
					return 0.5f;
				else
				if( dm.IsItemUpgrade(item) )
					return 0.5f;
				else
				if( dm.IsItemFood(item) )
					return 1.5f;
				else
				if( dm.IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case AN_Prologue_Village_Winter:
				if( dm.IsItemHerb(item) )
					return 0.5;
				else
				if( dm.IsItemTrophy(item) )
					return 0.5;
				else
				if( dm.IsItemWeapon(item) )
					return 0.75;
				else
				if( dm.IsItemJewelry(item) )
					return 0.5f;
				else
				if( dm.IsItemUpgrade(item) )
					return 0.5f;
				else
				if( dm.IsItemFood(item) )
					return 1.5f;
				else
				if( dm.IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case (EAreaName)AN_Dlc_Bob:
				if( dm.IsItemTrophy(item) )
					return 1.5;
				else
				if( dm.IsItemJewelry(item) )
					return 1.5;
				else
				if( dm.IsItemAlchemicalAlcohol(item) )
					return 0.5;
				else
				if( dm.IsItemFood(item) )
					return 0.5;
				else
				if( dm.IsItemHorseItem(item) )
					return 1.5;
				else
					return 1;
			break;
			
			default : return 1;
		}
	}
	
	private function GetAreaPriceMult( item : SItemUniqueId, itemRarity : int ) : float
	{
		var area : EAreaName = theGame.GetCommonMapManager().GetCurrentArea();
		var worldPos : Vector;
		
		switch(area)
		{
			case AN_NMLandNovigrad:
				worldPos = GetWitcherPlayer().GetWorldPosition();
				
				if( worldPos.X > 1650.f || worldPos.Y > 1400.f )
				{
					return 1;
				}
				else
				{
					if( IsItemFood(item) )
						return 2;
					else
					if( IsItemJewelry(item) )
						return 0.5;
					else
					if( IsItemReadable(item) )
						return 0.5;
					else
					if( IsItemTrophy(item) )
						return 0.5;
					else
					if( IsItemHerb(item) )
						return 0.5;
					else
					if( IsItemJunk(item) )
						return 0.5f;
					else
						return 1;
				}
			break;
			
			case AN_Skellige_ArdSkellig:
				if( IsItemFood(item) )
					return 1.5;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.5;
				else
				if( IsItemTrophy(item) )
					return 1.5;
				else
				if( IsItemJewelry(item) )
					return 0.5;
				else
				if( IsItemHorseItem(item) )
					return 0.5;
				else
				if( IsItemWeapon(item) )
				{
					switch( itemRarity )
					{
						case 1: return 0.7;
						case 2: return 0.85;
						case 3: return 1;
						case 4: return 1.2;
						case 5: return 1.2;
					}
				}
				else
					return 1;
			break;
			
			case AN_Prologue_Village:
				if( IsItemHerb(item) )
					return 0.5;
				else
				if( IsItemTrophy(item) )
					return 0.5;
				else
				if( IsItemWeapon(item) )
					return 0.75;
				else
				if( IsItemJewelry(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 0.5f;
				else
				if( IsItemFood(item) )
					return 1.5f;
				else
				if( IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case AN_Prologue_Village_Winter:
				if( IsItemHerb(item) )
					return 0.5;
				else
				if( IsItemTrophy(item) )
					return 0.5;
				else
				if( IsItemWeapon(item) )
					return 0.75;
				else
				if( IsItemJewelry(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 0.5f;
				else
				if( IsItemFood(item) )
					return 1.5f;
				else
				if( IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case (EAreaName)AN_Dlc_Bob:
				if( IsItemTrophy(item) )
					return 1.5;
				else
				if( IsItemJewelry(item) )
					return 1.5;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.5;
				else
				if( IsItemFood(item) )
					return 0.5;
				else
				if( IsItemHorseItem(item) )
					return 1.5;
				else
					return 1;
			break;
			
			default : return 1;
		}
	}
	
	public function GetMerchantMult( item : SItemUniqueId, merchantEntity : CEntity ) : float
	{
		var merchantComponent : W3MerchantComponent;
		var merchantType : name;
		var merchant : CNewNPC;
		
		merchant = (CNewNPC)merchantEntity;
		merchantComponent = (W3MerchantComponent)merchant.GetComponentByClassName('W3MerchantComponent');
		merchantType = merchantComponent.GetMapPinType();
		if( GetItemName(item) == 'Honeycomb' && theGame.GetCommonMapManager().GetCurrentArea() == AN_Prologue_Village && merchantType == 'Herbalist' )
			return 5.f;
		switch( merchantType )
		{
			case 'Shopkeeper':
				if( IsItemWeapon(item) )
					return 0.5f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.5f;
				else
				if( IsItemChestArmor(item) )
					return 0.5f;
				else
				if( IsItemPants(item) )
					return 0.5f;
				else
				if( IsItemBoots(item) )
					return 0.5f;
				else
				if( IsItemGloves(item) )
					return 0.5f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.5f;
				else
				if( IsItemJewelry(item) )
					return 1.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.5f;
				else
				if( IsItemHerb(item) )
					return 0.25f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.5f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.25f;
				else
				if( IsItemFood(item) )
					return 0.5f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemJunk(item) )
					return 1.f;
				else
				if( IsItemReadable(item) )
					return 1.f;
				else
				if( IsItemHorseItem(item) )
					return 1.f;
				else
				if( IsItemUpgrade(item) )
					return 0.5f;
				else
				if( IsItemTrophy(item) )
					return 1.f;
				else
					return 1.f;
			break;
			case 'Blacksmith':
				if( IsItemWeapon(item) )
					return 1.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 1.f;
				else
				if( IsItemChestArmor(item) )
					return 0.75f;
				else
				if( IsItemPants(item) )
					return 0.75f;
				else
				if( IsItemBoots(item) )
					return 0.75f;
				else
				if( IsItemGloves(item) )
					return 0.75f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.75f;
				else
				if( IsItemJewelry(item) )
					return 0.25f;
				else
				if( IsItemCraftingIngredient(item) )
					return 1.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemJunk(item) )
					return 0.25f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 1.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			case 'Armorer':
				if( IsItemWeapon(item) )
					return 0.75f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.75f;
				else
				if( IsItemChestArmor(item) )
					return 1.f;
				else
				if( IsItemPants(item) )
					return 1.f;
				else
				if( IsItemBoots(item) )
					return 1.f;
				else
				if( IsItemGloves(item) )
					return 1.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 1.f;
				else
				if( IsItemJewelry(item) )
					return 0.25f;
				else
				if( IsItemCraftingIngredient(item) )
					return 1.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemJunk(item) )
					return 0.25f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 1.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			case 'Herbalist':
				if( IsItemWeapon(item) )
					return 0.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.f;
				else
				if( IsItemChestArmor(item) )
					return 0.f;
				else
				if( IsItemPants(item) )
					return 0.f;
				else
				if( IsItemBoots(item) )
					return 0.f;
				else
				if( IsItemGloves(item) )
					return 0.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.f;
				else
				if( IsItemJewelry(item) )
					return 0.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.f;
				else
				if( IsItemHerb(item) )
					return 1.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.5f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 1.f;
				else
				if( IsItemFood(item) )
					return 0.5f;
				else
				if( IsItemAlchemyItem(item) )
					return 1.f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 0.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			case 'Alchemic':
				if( IsItemWeapon(item) )
					return 0.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.f;
				else
				if( IsItemChestArmor(item) )
					return 0.f;
				else
				if( IsItemPants(item) )
					return 0.f;
				else
				if( IsItemBoots(item) )
					return 0.f;
				else
				if( IsItemGloves(item) )
					return 0.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.f;
				else
				if( IsItemJewelry(item) )
					return 0.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.f;
				else
				if( IsItemHerb(item) )
					return 0.5f;
				else
				if( IsItemMonsterPart(item) )
					return 1.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 1.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 2.f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.5f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 0.75f;
				else
				if( IsItemTrophy(item) )
					return 0.5f;
				else
					return 1.f;
			break;
			case 'Innkeeper':
				if( IsItemWeapon(item) )
					return 0.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.f;
				else
				if( IsItemChestArmor(item) )
					return 0.f;
				else
				if( IsItemPants(item) )
					return 0.f;
				else
				if( IsItemBoots(item) )
					return 0.f;
				else
				if( IsItemGloves(item) )
					return 0.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.f;
				else
				if( IsItemJewelry(item) )
					return 0.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 1.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 0.f;
				else
				if( IsItemTrophy(item) )
					return 1.0f;
				else
					return 1.f;
			break;
			case 'Enchanter':
				if( IsItemWeapon(item) )
					return 0.5f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.5f;
				else
				if( IsItemChestArmor(item) )
					return 0.5f;
				else
				if( IsItemPants(item) )
					return 0.5f;
				else
				if( IsItemBoots(item) )
					return 0.5f;
				else
				if( IsItemGloves(item) )
					return 0.5f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.5f;
				else
				if( IsItemJewelry(item) )
					return 1.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 1.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 1.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 1.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			default : return 1.f;
		}
	}
	// W3EE - End
	
	import final function GetFundsModifier() : float;

	
	import final function GetItemQuantity( itemId : SItemUniqueId ) : int;
	
	
	import final function ItemHasTag( itemId : SItemUniqueId, tag : name ) : bool;

	
	import final function AddItemTag( itemId : SItemUniqueId, tag : name ) : bool;

	
	import final function RemoveItemTag( itemId : SItemUniqueId, tag : name ) : bool;
	
	
	public final function ManageItemsTag( items : array<SItemUniqueId>, tag : name, add : bool )
	{
		var i		: int;
		
		if( add )
		{
			for( i = 0 ; i < items.Size() ; i += 1 )
			{
				AddItemTag( items[ i ], tag );
			}
		}
		else
		{
			for( i = 0 ; i < items.Size() ; i += 1 )
			{
				RemoveItemTag( items[ i ], tag );
			}
		}
	}

	
	import final function GetItemByItemEntity( itemEntity : CItemEntity ) : SItemUniqueId;  
		
	
	public function ItemHasAbility(item : SItemUniqueId, abilityName : name) : bool
	{
		var abilities : array<name>;
		
		GetItemAbilities(item, abilities);
		return abilities.Contains(abilityName);
	}
	
	import final function GetItemAttributeValue( itemId : SItemUniqueId, attributeName : name, optional abilityTags : array< name >, optional withoutTags : bool ) : SAbilityAttributeValue;
	
	
	import final function GetItemBaseAttributes( itemId : SItemUniqueId, out attributes : array<name> );
	
	
	import final function GetItemAttributes( itemId : SItemUniqueId, out attributes : array<name> );
	
	
	import final function GetItemAbilities( itemId : SItemUniqueId, out abilities : array<name> );
	
	
	import final function GetItemContainedAbilities( itemId : SItemUniqueId, out abilities : array<name> );
	
	
	public function GetItemAbilitiesWithAttribute(id : SItemUniqueId, attributeName : name, attributeVal : float) : array<name>
	{
		var i : int;
		var abs, ret : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var val : float;
		var min, max : SAbilityAttributeValue;
	
		GetItemAbilities(id, abs);
		dm = theGame.GetDefinitionsManager();
		
		for(i=0; i<abs.Size(); i+=1)
		{
			dm.GetAbilityAttributeValue(abs[i], attributeName, min, max);
			val = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			
			if(val == attributeVal)
				ret.PushBack(abs[i]);
		}
		
		return ret;
	}
	public function GetItemAbilitiesWithTag( itemId : SItemUniqueId, tag : name, out abilities : array<name> )
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var allAbilities : array<name>;
		
		dm = theGame.GetDefinitionsManager();
		GetItemAbilities(itemId, allAbilities);
		
		for(i=0; i<allAbilities.Size(); i+=1)
		{
			if(dm.AbilityHasTag(allAbilities[i], tag))
			{
				abilities.PushBack(allAbilities[i]);
			}
		}
	}
	
	
	
	
	import private final function GiveItem( otherInventory : CInventoryComponent, itemId : SItemUniqueId, optional quantity : int ) : array<SItemUniqueId>;
	
	public final function GiveMoneyTo(otherInventory : CInventoryComponent, optional quantity : int, optional informGUI : bool )
	{
		var moneyId : array<SItemUniqueId>;
		var wasAdded : bool;
		
		moneyId = GetItemsByName('Crowns');
		if( !IsIdValid(moneyId[0]) && (GetEntity() == thePlayer || GetEntity() == thePlayer.GetHorseWithInventory()) )
		{
			wasAdded = true;
			moneyId = AddAnItem('Crowns', 1, true, true, false);
		}
		
		GiveItemTo(otherInventory, moneyId[0], quantity, false, true, informGUI);
		
		if( wasAdded )
			RemoveMoney(1);
	}
	
	public final function GiveItemTo( otherInventory : CInventoryComponent, itemId : SItemUniqueId, optional quantity : int, optional refreshNewFlag : bool, optional forceTransferNoDrops : bool, optional informGUI : bool ) : SItemUniqueId
	{
		var arr : array<SItemUniqueId>;
		var itemName : name;
		var i : int;
		var uiData : SInventoryItemUIData;
		var isQuestItem : bool;
		//Plasticmetal - LootTweak ++
		var hud : CR4ScriptedHud;
		var message : string;
		//Plasticmetal - LootTweak --
		
		
		if(quantity == 0)
			quantity = 1;
		//Plasticmetal - LootTweak ++
		hud = (CR4ScriptedHud)theGame.GetHud();
		if(hud && otherInventory==GetWitcherPlayer().GetHorseManager().GetInventoryComponent() && this!=GetWitcherPlayer().GetInventory())
		{
			//message = GetLocStringByKeyExt("panel_common_item_received") + ": " + this.GetItemLocNameByID(itemId);
			message = GetLocStringByKeyExt("panel_common_item_received") + ": " +  AlchemyColor(itemId);
			if(quantity > 1)
				message += " x" + quantity;
			message += AlchemySecondary(itemId);
			hud.HudConsoleMsg(message);
		}
		//Plasticmetal - LootTweak --
		
		itemName = GetItemName(itemId);
		if( itemName == 'Crowns' )
			quantity = Clamp(quantity, 0, GetMoney());
		else
		{
			if( IsItemSingletonItem(itemId) )
				quantity = Clamp(quantity, 0, SingletonItemGetAmmo(itemId));
			else
				quantity = Clamp(quantity, 0, GetItemQuantity(itemId));
		}
		if(quantity == 0)
			return GetInvalidUniqueId();
			
		
		if(!forceTransferNoDrops && ( ItemHasTag(itemId, 'NoDrop') && !ItemHasTag(itemId, 'Lootable') ))
		{
			LogItems("Cannot transfer item <<" + itemName + ">> as it has the NoDrop tag set!!!");
			return GetInvalidUniqueId();
		}
		
		if( this == GetWitcherPlayer().GetInventory() || (FactsQuerySum("NewGamePlus") > 0 && (this == GetWitcherPlayer().GetHorseManager().GetInventoryComponent() || (W3SwordStand)this.GetEntity() || (W3ArmorStand)this.GetEntity())) ) 
			ModNoDuplicatesAddItemAboutToGiveModifiers(this,itemId);
			
		if( IsItemSingletonItem(itemId) )
		{
			arr = otherInventory.AddAnItem(itemName, quantity, false, true, false);
			if( quantity >= SingletonItemGetAmmo(itemId) )
				RemoveItem(itemId);
			else
				SingletonItemRemoveAmmo(itemId, quantity);
		}
		else
		{
			// W3EE - Begin
			if ( CanItemHaveOil(itemId) )
				RemoveAllOilsFromItem(itemId);
				
			if( GetEntity() == thePlayer )
				((W3PlayerWitcher)GetEntity()).RemoveRepairBuffs(itemId);
				
			if( itemName == 'Crowns' && (GetEntity() == thePlayer || GetEntity() == thePlayer.GetHorseWithInventory()) )
			{
				RemoveMoney(quantity);
				arr = otherInventory.AddAnItem('Crowns', quantity);
			}
			else
			{
				//Kolaris - Fixed Stashes
				if( ItemHasTag(itemId, 'NoShow') && this == GetWitcherPlayer().GetHorseManager().GetInventoryComponent() && Equipment().IsStashableItem(this, itemId) )
				{
					if( !ItemHasTag(itemId, 'NoDrop') && !ItemHasTag(itemId, 'NoUse') && !ItemHasTag(itemId, 'EncumbranceOff') && !ItemHasTag(itemId, 'Quest') )
						RemoveItemTag(itemId, 'NoShow');
				}
				if( GameplayFactsQuerySum("inFixedStash") > 0 )
				{
					if( this == thePlayer.inv && otherInventory == GetWitcherPlayer().GetHorseManager().GetInventoryComponent() && Equipment().IsStashableItem(this, itemId) && !ItemHasTag(itemId, 'Quest') )
					{
						AddItemTag(itemId, 'NoShow');
					}
					if( Equipment().IsStashableIngredient(itemName) )
					{
						arr = otherInventory.AddAnItem(Equipment().GetItemStashVariant(itemName), quantity, false, true, false);
						this.RemoveItem(itemId, quantity);
					}
					else
						arr = GiveItem(otherInventory, itemId, quantity);
				}
				else if( !((CActor)GetEntity()) && otherInventory == GetWitcherPlayer().GetHorseManager().GetInventoryComponent() && Options().HorseDestination() == 2 && Equipment().IsStashableIngredient(itemName) )
				{
					arr = otherInventory.AddAnItem(Equipment().GetItemStashVariant(itemName), quantity, false, true, false);
					this.RemoveItem(itemId, quantity);
				}
				else
					arr = GiveItem(otherInventory, itemId, quantity);
			}
			// W3EE - End
		}
		
		if(otherInventory == thePlayer.inv)
		{
			isQuestItem = this.IsItemQuest( itemId );
			theTelemetry.LogWithLabelAndValue(TE_INV_ITEM_PICKED, itemName, quantity);
			
			if ( !theGame.AreSavesLocked() && ( isQuestItem || this.GetItemQuality( itemId ) >= 4 ) )
			{
				theGame.RequestAutoSave( "item gained", false );
			}
		}
		
		if (refreshNewFlag)
		{
			for (i = 0; i < arr.Size(); i += 1)
			{
				uiData = otherInventory.GetInventoryItemUIData( arr[i] );
				uiData.isNew = true;
				otherInventory.SetInventoryItemUIData( arr[i], uiData );
			}
		}
		
		return arr[0];
	}
	
	public final function GiveAllItemsTo(otherInventory : CInventoryComponent, optional forceTransferNoDrops : bool, optional informGUI : bool)
	{
		var items : array<SItemUniqueId>;
		
		GetAllItems(items);
		GiveItemsTo(otherInventory, items, forceTransferNoDrops, informGUI);
	}
	
	public final function GiveItemsTo(otherInventory : CInventoryComponent, items : array<SItemUniqueId>, optional forceTransferNoDrops : bool, optional informGUI : bool) : array<SItemUniqueId>
	{
		var i : int;
		var ret : array<SItemUniqueId>;
		
		for( i = 0; i < items.Size(); i += 1 )
		{
			ret.PushBack(GiveItemTo(otherInventory, items[i], GetItemQuantity(items[i]), true, forceTransferNoDrops, informGUI));
		}
		
		return ret;
	}
		
	
	import final function HasItem( item : name ) : bool;
	
	
	
	final function HasItemById(id : SItemUniqueId) : bool
	{		
		var arr : array<SItemUniqueId>;
		
		GetAllItems(arr);
		return arr.Contains(id);
	}
	
	public function HasItemByTag(tag : name) : bool
	{
		var quantity : int;
		
		quantity = GetItemQuantityByTag( tag );
		return quantity > 0;
	}

	public function HasItemByCategory(category : name) : bool
	{
		var quantity : int;
		
		quantity = GetItemQuantityByCategory( category );
		return quantity > 0;
	}
	
	
	public function HasInfiniteBolts() : bool
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		
		ids = GetItemsByTag(theGame.params.TAG_INFINITE_AMMO);
		for(i=0; i<ids.Size(); i+=1)
		{
			if(IsItemBolt(ids[i]))
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	public function HasGroundBolts() : bool
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		
		ids = GetItemsByTag(theGame.params.TAG_GROUND_AMMO);
		for(i=0; i<ids.Size(); i+=1)
		{
			if(IsItemBolt(ids[i]))
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	public function HasUnderwaterBolts() : bool
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		
		ids = GetItemsByTag(theGame.params.TAG_UNDERWATER_AMMO);
		for(i=0; i<ids.Size(); i+=1)
		{
			if(IsItemBolt(ids[i]))
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	
	import private final function AddMultiItem( item : name, optional quantity : int, optional informGui : bool , optional markAsNew : bool , optional lootable : bool  ) : array<SItemUniqueId>;
	import private final function AddSingleItem( item : name, optional informGui : bool , optional markAsNew : bool , optional lootable : bool   ) : SItemUniqueId;
	
	
	public final function AddAnItem(item : name, optional quantity : int, optional dontInformGui : bool, optional dontMarkAsNew : bool, optional showAsRewardInUIHax : bool) : array<SItemUniqueId>
	{
		var arr : array<SItemUniqueId>;
		var i : int;
		var isReadableItem : bool;
		
		if( theGame.GetDefinitionsManager().IsItemSingletonItem(item) /*&& GetEntity() == thePlayer*/)			
		{
			// W3EE - Begin
			if( !quantity )
				quantity = 1;
			// W3EE - End
			
			if(GetItemQuantityByName(item) > 0)
			{
				arr = GetItemsIds(item);
				// W3EE - Begin
				SingletonItemAddAmmo(arr[0], quantity);
				// W3EE - End
			}
			else
			{
				arr.PushBack(AddSingleItem(item, !dontInformGui, !dontMarkAsNew));
				// W3EE - Begin
				SingletonItemSetAmmo(arr[0], 0);
				SingletonItemAddAmmo(arr[0], quantity);
				// W3EE - End
			}
			
			quantity = 1;
		}
		else
		{
			if(quantity < 2 ) 
			{
				arr.PushBack(AddSingleItem(item, !dontInformGui, !dontMarkAsNew));
			}
			else	
			{
				arr = AddMultiItem(item, quantity, !dontInformGui, !dontMarkAsNew);
			}
		}
		
		
		if(this == thePlayer.GetInventory())
		{
			if(ItemHasTag(arr[0],'ReadableItem'))
				UpdateInitialReadState(arr[0]);
			
			if( IsItemCrossbow(arr[0]) )
				AddAndEquipItem('Bodkin Bolt', EES_Bolt, 60);
			
			if(showAsRewardInUIHax || ItemHasTag(arr[0],'GwintCard'))
				thePlayer.DisplayItemRewardNotification(GetItemName(arr[0]), quantity );
		}
		
		return arr;
	}
		
	
	// W3EE - Begin
	public function AddAndEquipItem( item : name, slot : EEquipmentSlots, optional quantity : int ) : SItemUniqueId
	{
		var items : array <SItemUniqueId>;
		
		if( quantity < 1 )
			quantity = 1;
		items = AddAnItem(item, quantity);
		if( this == thePlayer.GetInventory() )
			thePlayer.EquipItem(items[0], slot);
			
		return items[0];
	}
	// W3EE - End
	
	import final function RemoveItem( itemId : SItemUniqueId, optional quantity : int ) : bool;
	
	
	private final function InternalRemoveItems(ids : array<SItemUniqueId>, quantity : int)
	{
		var i, currQuantityToTake : int;
	
		
		for(i=0; i<ids.Size(); i+=1 )
		{			
			
			currQuantityToTake = Min(quantity, GetItemQuantity(ids[i]) );
			
			
			if( GetEntity() == thePlayer )
			{
				GetWitcherPlayer().RemoveGwentCard( GetItemName(ids[i]) , currQuantityToTake);
			}			
			
			
			RemoveItem(ids[i], currQuantityToTake);
			
			
			quantity -= currQuantityToTake;
			
			
			if ( quantity == 0 )
			{
				return;
			}
			
			
			LogAssert(quantity>0, "CInventoryComponent.InternalRemoveItems(" + GetItemName(ids[i]) + "): somehow took too many items! Should be " + (-quantity) + " less... Investigate!");
		}
	}
	
	
	
	public function RemoveItemByName(itemName : name, optional quantity : int) : bool
	{
		var totalItemCount : int;
		var ids : array<SItemUniqueId>;
	
		
		totalItemCount = GetItemQuantityByName(itemName);
		if(totalItemCount < quantity || quantity == 0)
		{
			return false;
		}
		
		if(quantity == 0)
		{
			quantity = 1;
		}
		else if(quantity < 0)
		{
			quantity = totalItemCount;
		}
		
		ids = GetItemsIds(itemName);
		
		if(GetEntity() == thePlayer && thePlayer.GetSelectedItemId() == ids[0] )
		{
			thePlayer.ClearSelectedItemId();
		}
		
		InternalRemoveItems(ids, quantity);
		
		return true;
	}
	
	
	
	public function RemoveItemByCategory(itemCategory : name, optional quantity : int) : bool
	{
		var totalItemCount : int;
		var ids : array<SItemUniqueId>;
		var selectedItemId : SItemUniqueId;
		var i : int;
	
		
		totalItemCount = GetItemQuantityByCategory(itemCategory);
		if(totalItemCount < quantity)
		{
			return false;
		}
		
		if(quantity == 0)
		{
			quantity = 1;
		}
		else if(quantity < 0)
		{
			quantity = totalItemCount;
		}
		
		ids = GetItemsByCategory(itemCategory);
		
		if(GetEntity() == thePlayer)
		{
			selectedItemId = thePlayer.GetSelectedItemId();
			for(i=0; i<ids.Size(); i+=1)
			{
				if(selectedItemId == ids[i] )
				{
					thePlayer.ClearSelectedItemId();
					break;
				}
			}
		}
			
		InternalRemoveItems(ids, quantity);
		
		return true;
	}
	
	
	
	public function RemoveItemByTag(itemTag : name, optional quantity : int) : bool
	{
		var totalItemCount : int;
		var ids : array<SItemUniqueId>;
		var i : int;
		var selectedItemId : SItemUniqueId;
	
		
		totalItemCount = GetItemQuantityByTag(itemTag);
		if(totalItemCount < quantity)
		{
			return false;
		}
		
		if(quantity == 0)
		{
			quantity = 1;
		}
		else if(quantity < 0)
		{
			quantity = totalItemCount;
		}
		
		ids = GetItemsByTag(itemTag);
		
		if(GetEntity() == thePlayer)
		{
			selectedItemId = thePlayer.GetSelectedItemId();
			for(i=0; i<ids.Size(); i+=1)
			{				
				if(selectedItemId == ids[i] ) 
				{
					thePlayer.ClearSelectedItemId();
					break;
				}
			}
		}
		
		InternalRemoveItems(ids, quantity);
		
		return true;
	}
	
	
	import final function RemoveAllItems();
	
	
	import final function GetItemEntityUnsafe( itemId : SItemUniqueId ) : CItemEntity;
	
	
	import final function GetDeploymentItemEntity( itemId : SItemUniqueId, optional position : Vector, optional rotation : EulerAngles, optional allocateIdTag : bool ) : CEntity;
	
	
	import final function MountItem( itemId : SItemUniqueId, optional toHand : bool, optional force : bool ) : bool;
	
	
	import final function UnmountItem( itemId : SItemUniqueId, optional destroyEntity : bool ) : bool;
	
	
	
	import final function IsItemMounted(  itemId : SItemUniqueId ) : bool;	
	
	
	
	import final function IsItemHeld(  itemId : SItemUniqueId ) : bool;	
	
	
	import final function DropItem( itemId : SItemUniqueId, optional removeFromInv  : bool );
	
	
	import final function GetItemHoldSlot( itemId : SItemUniqueId ) : name;
	
	
	import final function PlayItemEffect( itemId : SItemUniqueId, effectName : name );
	import final function StopItemEffect( itemId : SItemUniqueId, effectName : name );
	
	
	import final function ThrowAwayItem( itemId : SItemUniqueId, optional quantity : int ) : bool;
	
	
	import final function ThrowAwayAllItems() : CEntity; 
	
	
	import final function ThrowAwayItemsFiltered( excludedTags : array< name > ) : CEntity;

	
	import final function ThrowAwayLootableItems( optional skipNoDropNoShow : bool ) : CEntity;
	
	
	import final function GetItemRecyclingParts( itemId : SItemUniqueId ) : array<SItemParts>;
	
	import final function GetItemWeight( id : SItemUniqueId ) : float;

	
	public final function HasQuestItem() : bool
	{
		var allItems		: array< SItemUniqueId >;
		var i				: int;
		
		allItems = GetItemsByTag('Quest');
		for ( i=0; i<allItems.Size(); i+=1 )
		{
			if(!ItemHasTag(allItems[i], theGame.params.TAG_DONT_SHOW))
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	
	
	
	
	import final function HasItemDurability( itemId : SItemUniqueId ) : bool;
	import final function GetItemDurability( itemId : SItemUniqueId ) : float;
	import private final function SetItemDurability( itemId : SItemUniqueId, durability : float );
	import final function GetItemInitialDurability( itemId : SItemUniqueId ) : float;
	import final function GetItemMaxDurability( itemId : SItemUniqueId ) : float;
	import final function GetItemGridSize( itemId : SItemUniqueId ) : int;
		
		
	import final function NotifyItemLooted( item : SItemUniqueId );
	import final function ResetContainerData();
		
	public function SetItemDurabilityScript( itemId : SItemUniqueId, durability : float )
	{
		var oldDur : float;
	
		oldDur = GetItemDurability(itemId);
		
		if(oldDur == durability)
			return;
			
		if(durability < oldDur)
		{
			//Kolaris - Repair Buffs
			if ( ItemHasAbility( itemId, 'MA_Indestructible' ) /*|| ItemHasTag(itemId, 'ItemEnhanced')*/ )
			{
				return;
			}

			if(GetEntity() == thePlayer && ShouldProcessTutorial('TutorialDurability'))
			{
				if ( durability <= theGame.params.ITEM_DAMAGED_DURABILITY && oldDur > theGame.params.ITEM_DAMAGED_DURABILITY )
				{
					FactsAdd( "tut_item_damaged", 1 );
				}
			}
		}
			
		SetItemDurability( itemId, durability );		
	}
	
	
	public function ReduceItemDurability(itemId : SItemUniqueId, optional forced : bool, optional oilInfos : SOilInfo) : bool
	{
		var dur, value, durabilityDiff, itemToughness, indestructible, oilStrength : float;
		var chance, i : int;
		//var weaponId : SItemUniqueId;
		var oils : array<W3Effect_Oil>;
		var appliedOilName : name;
		
		//Kolaris - Repair Buffs
		if(!IsIdValid(itemId) || !HasItemDurability(itemId) || ItemHasAbility(itemId, 'MA_Indestructible') /*|| ItemHasTag(itemId, 'ItemEnhanced')*/)
		{
			return false;
		}
		
		
		if( IsItemWeapon(itemId) )
		{
			// W3EE - Begin
			//chance = theGame.params.DURABILITY_WEAPON_LOSE_CHANCE;
			
			//Kolaris - Weapon Durability Loss
			//value = theGame.params.GetWeaponDurabilityLoseValue();
			
			//Kolaris - Aerondight Silver
			if( IsItemSilverSwordUsableByPlayer(itemId) )
			{
				if( (W3Effect_Aerondight)GetWitcherPlayer().GetBuff(EET_Aerondight) )
				{
					value = 0;
					chance = 0;
				}
				else
				{
					value = 0.2f;
					chance = 50;
				}
			}
			else
			{
				value = 0.05f;
				chance = 40;
			}
			
			//Kolaris - Fortification
			if( thePlayer.HasAbility('Runeword 53 _Stats', true) || thePlayer.HasAbility('Runeword 54 _Stats', true) )
			{
				value *= 0;
				chance = 0;
			}
			
			if( oilInfos.isActive )
			{
				//Kolaris - Fixative
				if( thePlayer.CanUseSkill(S_Alchemy_s05) )
				{
					value *= 1.f - (0.2f * thePlayer.GetSkillLevel(S_Alchemy_s05) * oils[i].GetAmmoPercentage());
				}
				if( oilInfos.activeIndex[0] )
				{
					oilStrength = 3.f * (1.f - PowF(1.f - oils[i].GetAmmoPercentage(), 2));
					value *= oilStrength;
				}
				if( oilInfos.activeIndex[6] && IsItemSilverSwordUsableByPlayer(itemId) )
				{
					value *= 0;
					chance = 0;
				}
			}
			// W3EE - End
		}
		else if(IsItemAnyArmor(itemId))
		{
			// W3EE - Begin
			//chance = theGame.params.DURABILITY_ARMOR_LOSE_CHANCE;
			
			switch( GetArmorTypeOriginal(itemId) )
			{
				case EAT_Heavy: chance = 40; break;
				case EAT_Medium: chance = 50; break;
				case EAT_Light: chance = 60; break;
			}
			//W3EE - End
			
			value = theGame.params.DURABILITY_ARMOR_LOSE_VALUE;
			
			//Kolaris - Protection
			if( thePlayer.HasAbility('Glyphword 32 _Stats', true) || thePlayer.HasAbility('Glyphword 33 _Stats', true) )
			{
				value *= 0;
				chance = 0;
			}
		}
		
		dur = GetItemDurability(itemId);
		
		if ( dur == 0 )
		{
			return false;
		}

		
		if ( forced || RandRange( 100 ) < chance )
		{
			itemToughness = CalculateAttributeValue( GetItemAttributeValue( itemId, 'toughness' ) );
			indestructible = CalculateAttributeValue( GetItemAttributeValue( itemId, 'indestructible' ) );
			
			value = value * ( 1 - indestructible );
			//Kolaris - Difficulty Settings
			value /= Options().EquipmentDurabilityMod()();
			//Kolaris - Repair Buffs
			if( ItemHasTag(itemId, 'ItemEnhanced') )
				value *= 0.5f;
			//Kolaris - Tiger Set
			if( thePlayer.IsSetBonusActive(EISB_Tiger_2) && thePlayer.HasBuff(EET_AlbedoDominance) )
				value *= 0.5f;
			
			if ( itemToughness > 0.0f && itemToughness <= 1.0f )
			{
				durabilityDiff = ( dur - value ) * itemToughness;
				
				SetItemDurabilityScript( itemId, MaxF(durabilityDiff, 0 ) );
			}
			else
			{
				SetItemDurabilityScript( itemId, MaxF( dur - value, 0 ) );
			}
		}

		return true;
	}

	public function GetItemDurabilityRatio(itemId : SItemUniqueId) : float
	{	
		if ( !IsIdValid( itemId ) || !HasItemDurability( itemId ) )
			return -1;
			
		return GetItemDurability(itemId) / GetItemMaxDurability(itemId);
	}
	
	
	
	
	
	
	public function GetItemResistStatWithDurabilityModifiers(itemId : SItemUniqueId, stat : ECharacterDefenseStats, out points : SAbilityAttributeValue, out percents : SAbilityAttributeValue)
	{
		var mult : float;
		var null : SAbilityAttributeValue;
		
		points = null;
		percents = null;
		if(!IsItemAnyArmor(itemId))
			return;
	
		mult = theGame.params.GetDurabilityMultiplier(GetItemDurabilityRatio(itemId), false);
		
		points = GetItemAttributeValue(itemId, ResistStatEnumToName(stat, true));
		percents = GetItemAttributeValue(itemId, ResistStatEnumToName(stat, false));		
		
		points = points * mult;
		percents = percents * mult;
	}
	
	
	public function GetItemResistanceTypes(id : SItemUniqueId) : array<ECharacterDefenseStats>
	{
		var ret : array<ECharacterDefenseStats>;
		var i : int;
		var stat : ECharacterDefenseStats;
		var atts : array<name>;
		var tmpBool : bool;
	
		if(!IsIdValid(id))
			return ret;
			
		GetItemAttributes(id, atts);
		for(i=0; i<atts.Size(); i+=1)
		{
			stat = ResistStatNameToEnum(atts[i], tmpBool);
			if(stat != CDS_None && !ret.Contains(stat))
				ret.PushBack(stat);
		}
		
		return ret;
	}
	
	import final function GetItemModifierFloat( itemId : SItemUniqueId, modName : name, optional defValue : float ) : float;
	import final function SetItemModifierFloat( itemId : SItemUniqueId, modName : name, val : float);
	import final function GetItemModifierInt  ( itemId : SItemUniqueId, modName : name, optional defValue : int ) : int;	
	import final function SetItemModifierInt  ( itemId : SItemUniqueId, modName : name, val : int );
	
	
	import final function ActivateQuestBonus();

	
	import final function GetItemSetName( itemId : SItemUniqueId ) : name;
	
	
	import final function AddItemCraftedAbility( itemId : SItemUniqueId, abilityName : name, optional allowDuplicate : bool );
	
	
	import final function RemoveItemCraftedAbility( itemId : SItemUniqueId, abilityName : name );
	
	
	import final function AddItemBaseAbility(item : SItemUniqueId, abilityName : name);
	
	
	import final function RemoveItemBaseAbility(item : SItemUniqueId, abilityName : name);
		
	
	import final function DespawnItem( itemId : SItemUniqueId ); 
	
	
	
	
	
	
	import final function GetInventoryItemUIData( item : SItemUniqueId ) : SInventoryItemUIData;
	
	
	import final function SetInventoryItemUIData( item : SItemUniqueId, data : SInventoryItemUIData );
	
	import final function SortInventoryUIData(); 
	
	
	
	
	
	
	import final function PrintInfo();

	
	
	

	
	import final function EnableLoot( enable : bool );

	
	import final function UpdateLoot();
	
	
	import final function AddItemsFromLootDefinition( lootDefinitionName : name );
		
	
	import final function IsLootRenewable() : bool;
	
	
	import final function IsReadyToRenew() : bool;
	
	
	
	
	
	
	function Created()
	{		
		LoadBooksDefinitions();
	}
	
	function ClearGwintCards()
	{
		var attr : SAbilityAttributeValue;
		var allItems : array<SItemUniqueId>;
		var card : array<SItemUniqueId>;
		var iHave, shopHave, cardLimit, delta : int;
		var curItem : SItemUniqueId;
		var i : int;
		
		allItems = GetItemsByCategory('gwint');
		for(i=allItems.Size()-1; i >= 0; i-=1)
		{	
			curItem = allItems[i];
			
			attr = GetItemAttributeValue( curItem, 'max_count');
			card = thePlayer.GetInventory().GetItemsByName( GetItemName( curItem ) );
			iHave = thePlayer.GetInventory().GetItemQuantity( card[0] );
			cardLimit = RoundF(attr.valueBase);
			shopHave = GetItemQuantity( curItem );
			
			if (iHave > 0 && shopHave > 0)
			{
				delta = shopHave - (cardLimit - iHave);
				
				if ( delta > 0 )
				{
					RemoveItem( curItem, delta );
				}
			}
		}
	}
	
	function ClearTHmaps()
	{
		var attr : SAbilityAttributeValue;
		var allItems : array<SItemUniqueId>;
		var map : array<SItemUniqueId>;
		var i : int;
		var thCompleted : bool;
		var iHave, shopHave : int;
		
		allItems = GetItemsByTag('ThMap');
		for(i=allItems.Size()-1; i >= 0; i-=1)
		{	
			attr = GetItemAttributeValue( allItems[i], 'max_count');
			map = thePlayer.GetInventory().GetItemsByName( GetItemName( allItems[i] ) );
			thCompleted = FactsDoesExist(GetItemName(allItems[i]));
			iHave = thePlayer.GetInventory().GetItemQuantity( map[0] );
			shopHave = RoundF(attr.valueBase);
			
			if ( iHave >= shopHave || thCompleted )
			{
				RemoveItem( allItems[i], GetItemQuantity(  allItems[i] ) );
			}
		}
	}
	
	
	public final function ClearKnownRecipes()
	{
		var witcher : W3PlayerWitcher;
		var recipes, craftRecipes : array<name>;
		var i : int;
		var itemName : name;
		var allItems : array<SItemUniqueId>;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
			return;	
		
		
		recipes = witcher.GetAlchemyRecipes();
		craftRecipes = witcher.GetCraftingSchematicsNames();
		ArrayOfNamesAppend(recipes, craftRecipes);
		
		
		GetAllItems(allItems);
		
		
		for(i=allItems.Size()-1; i>=0; i-=1)
		{
			itemName = GetItemName(allItems[i]);
			if(recipes.Contains(itemName))
				RemoveItem(allItems[i], GetItemQuantity(allItems[i]));
		}
	}

	
	
	

	function LoadBooksDefinitions() : void 
	{
		var readableArray : array<SItemUniqueId>;
		var i : int;
		
		readableArray = GetItemsByTag('ReadableItem');
		
		for( i = 0; i < readableArray.Size(); i += 1 )
		{
			if( IsBookRead(readableArray[i]))
			{
				continue;
			}
			UpdateInitialReadState(readableArray[i]);
		}
	}
	
	function UpdateInitialReadState( item : SItemUniqueId ) 
	{
		var abilitiesArray : array<name>;
		var i : int;
		GetItemAbilities(item,abilitiesArray);
			
		for( i = 0; i < abilitiesArray.Size(); i += 1 )
		{
			if( abilitiesArray[i] == 'WasRead' )
			{
				ReadBook(item);
				break;
			}
		}
	}
	
	function IsBookRead( item : SItemUniqueId ) : bool 
	{
		var bookName : name;
		var bResult : bool;
		
		bookName = GetItemName( item );
		
		bResult = IsBookReadByName( bookName ); 
		return bResult;
	}
	
	function IsBookReadByName( bookName : name ) : bool 
	{
		var bookFactName : string;
		
		bookFactName = GetBookReadFactName( bookName );
		if( FactsDoesExist(bookFactName) )
		{
			return FactsQuerySum( bookFactName );
		}
		
		return false;
	}

	function ReadBook( item : SItemUniqueId, optional noNotification : bool ) 
	{
		
		var bookName : name;
		var abilitiesArray : array<name>;
		var i : int;
		var commonMapManager : CCommonMapManager = theGame.GetCommonMapManager();		
		
		bookName = GetItemName( item );
		
		// W3EE - Begin
		if( !IsBookRead(item) )
			Equipment().ProcessDecoctionFormulas(thePlayer.inv.GetItemName(item));
		// W3EE - End
		
		if ( !IsBookRead ( item ) && ItemHasTag ( item, 'FastTravel' ))
		{
			GetItemAbilities(item, abilitiesArray);
			
			for ( i = 0; i < abilitiesArray.Size(); i+=1 )
			{
				commonMapManager.SetEntityMapPinDiscoveredScript(true, abilitiesArray[i], true );
			}
		}
		ReadBookByNameId( bookName, item, false, noNotification );
		
		
		
		
		if(ItemHasTag(item, 'PerkBook'))
		{
			
		}	
	}
	
	public function GetBookText(item : SItemUniqueId) : string 
	{
		if ( GetItemName( item ) != 'Gwent Almanac' )
		{
			return ReplaceTagsToIcons(GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item)+"_text")); 
		}
		else
		{
			return GetGwentAlmanacContents();
		}
	}
	
	public function GetBookTextByName( bookName : name ) : string
	{
		if( bookName != 'Gwent Almanac' ) 
		{
			return ReplaceTagsToIcons( GetLocStringByKeyExt( GetItemLocalizedNameByName( bookName ) + "_text" ) );
		}
		else
		{
			return GetGwentAlmanacContents();
		}
	}
	
	function ReadSchematicsAndRecipes( item : SItemUniqueId )
	{
		var itemCategory : name;
		var itemName : name;
		var player : W3PlayerWitcher;
		
		//Kolaris - Dynamic Witcher Schematics
		//ReadBook( item );
		
		player = GetWitcherPlayer();
		if ( !player )
		{
			return;
		}

		itemName = GetItemName( item );
		itemCategory = GetItemCategory( item );
		if ( itemCategory == 'alchemy_recipe' )
		{
			if ( player.CanLearnAlchemyRecipe( itemName ) )
			{
				player.AddAlchemyRecipe( itemName );
				player.GetInventory().AddItemTag(item, 'NoShow');
				//---=== modFriendlyHUD ===---	
				if (!thePlayer.newCraftables.Contains(itemName))
				{
					thePlayer.newCraftables.PushBack(itemName);
				}
				//---=== modFriendlyHUD ===---	
				
			}
		}
		else if ( itemCategory == 'crafting_schematic' )
		{
			//Kolaris - Dynamic Witcher Schematics
			if( player.GetInventory().GetItemQuality(item) >= 5 )
			{
				player.AddCraftingSchematic( itemName, player.GetInventory().ItemHasTag(item, 'NoNotification') );
				if( Equipment().IsDWSInstalled() )
				{
					Equipment().ManageWitcherSchematics(itemName);
				}
			}
			else
			{
				player.AddCraftingSchematic( itemName, player.GetInventory().ItemHasTag(item, 'NoNotification') );
				//---=== modFriendlyHUD ===---	
				if (!thePlayer.newCraftables.Contains(itemName))
				{
					thePlayer.newCraftables.PushBack(itemName);
				}
				//---=== modFriendlyHUD ===---
			}
			player.GetInventory().AddItemTag(item, 'NoShow');
			
		}
		
		//Kolaris - Dynamic Witcher Schematics
		ReadBook( item );
		
	}
	
	function ReadBookByName( bookName : name , unread : bool, optional noNotification : bool ) 
	{
		var defMgr		 : CDefinitionsManagerAccessor;
		var bookFactName : string;
		
		if( IsBookReadByName( bookName ) != unread )
		{
			return;
		}
		
		bookFactName = "BookReadState_"+bookName;
		bookFactName = StrReplace(bookFactName," ","_");
		
		if( unread )
		{
			FactsSubstract( bookFactName, 1 );
		}
		else
		{
			FactsAdd( bookFactName, 1 );
			
			
			defMgr = theGame.GetDefinitionsManager();
			if(!IsAlchemyRecipe(bookName) && !IsCraftingSchematic(bookName) && !defMgr.ItemHasTag( bookName, 'Painting' ) )
			{
				theGame.GetGamerProfile().IncStat(ES_ReadBooks);
				
				if( !noNotification )
				{
					theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "notification_book_moved" ), 0, false );
				}
			}
			
			
			if ( AddBestiaryFromBook(bookName) )
				return;
			
				
			
		}
	}
	
	function ReadBookByNameId( bookName : name, itemId:SItemUniqueId, unread : bool, optional noNotification : bool ) 
	{
		var bookFactName : string;
		
		if( IsBookReadByName( bookName ) != unread )
		{
			return;
		}
		
		bookFactName = "BookReadState_"+bookName;
		bookFactName = StrReplace(bookFactName," ","_");
		
		if( unread )
		{
			FactsSubstract( bookFactName, 1 );
		}
		else
		{
			FactsAdd( bookFactName, 1 );
			
			
			if( !IsAlchemyRecipe( bookName ) && !IsCraftingSchematic( bookName ) )
			{
				theGame.GetGamerProfile().IncStat(ES_ReadBooks);
				
				if( !noNotification )
				{					
					
					GetWitcherPlayer().AddReadBook( bookName );
				}
			}
			
			
			if ( AddBestiaryFromBook(bookName) )
				return;
			else
			//Kolaris - Dynamic Witcher Schematics
			if( ItemHasTag(itemId, 'NoShow') ) 
				return;
			else
				ReadSchematicsAndRecipes( itemId );
		}
	}
	
	
	private function AddBestiaryFromBook( bookName : name ) : bool
	{
		var i, j, r, len : int;
		var manager : CWitcherJournalManager;
		var resource : array<CJournalResource>;
		var entryBase : CJournalBase;
		var childGroups : array<CJournalBase>;
		var childEntries : array<CJournalBase>;
		var descriptionGroup : CJournalCreatureDescriptionGroup;
		var descriptionEntry : CJournalCreatureDescriptionEntry;
	
		manager = theGame.GetJournalManager();
		
		switch ( bookName )
		{
			case 'Beasts vol 1': 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWolf" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryDog" ) ); 
				break;
			case 'Beasts vol 2': 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryBear" ) ); 
				break;
			case 'Cursed Monsters vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWerewolf" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryLycanthrope" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 24');
				break;
			case 'Cursed Monsters vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWerebear" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryMiscreant" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 11');
				break;
			case 'Draconides vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryCockatrice" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryBasilisk" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 3');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 23');
				break;
			case 'Draconides vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWyvern" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryForktail" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 10');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 17');
				break;
			case 'Hybrid Monsters vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryHarpy" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryErynia" ) );
				resource.PushBack( (CJournalResource)LoadResource( "BestiarySiren" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiarySuccubus" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 14');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 21');
				break;
			case 'Hybrid Monsters vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryGriffin" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 4');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 27');
				break;
			case 'Insectoids vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryEndriagaWorker" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryEndriagaTruten" ) );
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryEndriaga" ) );
				break;
			case 'Insectoids vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryCrabSpider" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryArmoredArachas" ) );
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryPoisonousArachas" ) );
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 2');
				break;
			case 'Magical Monsters vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryGolem" ) ); 
				break;
			case 'Magical Monsters vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryElemental" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryIceGolem" ) );
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryFireElemental" ) );
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWhMinion" ) );
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 20');
				break;
			case 'Necrophage vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryGhoul" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryAlghoul" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryGreaterRotFiend" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryDrowner" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 15');
				break;
			case 'Necrophage vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryGraveHag" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWaterHag" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryFogling" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 5');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 9');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 18');
				break;
			case 'Relict Monsters vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryBies" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryCzart" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 8');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 16');
				break;
			case 'Relict Monsters vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryLeshy" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiarySilvan" ) );
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 22');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 26');
				break;
			case 'Specters vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryMoonwright" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryNoonwright" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryPesta" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 6');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 13');
				break;
			case 'Specters vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWraith" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryHim" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 19');
				break;
			case 'Ogres vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryNekker" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryIceTroll" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryCaveTroll" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 12');
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 25');
				break;
			case 'Ogres vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryCyclop" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryIceGiant" ) ); 
				break;
			case 'Vampires vol 1':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryEkkima" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryHigherVampire" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 7');
				break;
			case 'Vampires vol 2':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryKatakan" ) ); 
				GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 1');
				break;
			
			case 'bestiary_sharley_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiarySharley" ) ); 
				break;
			case 'bestiary_barghest_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryBarghest" ) ); 
				break;
			case 'bestiary_garkain_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryGarkain" ) ); 
				break;
			case 'bestiary_alp_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryAlp" ) ); 
				break;
			case 'bestiary_bruxa_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryBruxa" ) ); 
				break;
			case 'bestiary_spriggan_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiarySpriggan" ) ); 
				break;
			case 'bestiary_fleder_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryFleder" ) ); 
				break;
			case 'bestiary_wight_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryWicht" ) ); 
				break;
			case 'bestiary_dracolizard_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryDracolizard" ) ); 
				break;
			case 'bestiary_panther_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryPanther" ) ); 
				break;
			case 'bestiary_kikimore_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryKikimoraWarrior" ) ); 
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryKikimoraWorker" ) ); 
				break;
			case 'bestiary_scolopendromorph_book':
			case 'mq7023_fluff_book_scolopendromorphs':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryScolopendromorph" ) ); 
				break;
			case 'bestiary_archespore_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryArchespore" ) ); 
				break;
			case 'bestiary_protofleder_book':
				resource.PushBack( (CJournalResource)LoadResource( "BestiaryProtofleder" ) ); 
				break;
			default: 
				return false;
		}
		
		
		
		
		len = resource.Size();
		if( len > 0)
		{
			
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "panel_hud_journal_entry_bestiary_new" ), 0, true );
			theSound.SoundEvent("gui_ingame_new_journal");
		}
		
		for (r=0; r < len; r += 1 )
		{
			if ( !resource[ r ] )
			{
				
				continue;
			}
			entryBase = resource[r].GetEntry();
			if ( entryBase )
			{
				manager.ActivateEntry( entryBase, JS_Active );
				manager.SetEntryHasAdvancedInfo( entryBase, true );
				
				
				manager.GetAllChildren( entryBase, childGroups );
				for ( i = 0; i < childGroups.Size(); i += 1 )
				{	
					descriptionGroup = ( CJournalCreatureDescriptionGroup )childGroups[ i ];
					if ( descriptionGroup )
					{
						manager.GetAllChildren( descriptionGroup, childEntries );
						for ( j = 0; j < childEntries.Size(); j += 1 )
						{
							descriptionEntry = ( CJournalCreatureDescriptionEntry )childEntries[ j ];
							if ( descriptionEntry )
							{
								manager.ActivateEntry( descriptionEntry, JS_Active );
							}
						}
						break;
					}
				}
			}
		}	
		
		if ( resource.Size() > 0 )
			return true;
		else
			return false;
	}
	
	
	
	
	
	

	
	function GetWeaponDTNames( id : SItemUniqueId, out dmgNames : array< name > ) : int
	{
		var attrs : array< name >;
		var i, size : int;
	
		dmgNames.Clear();
	
		if( IsIdValid(id) )
		{
			GetItemAttributes( id, attrs );
			size = attrs.Size();
			
			for( i = 0; i < size; i += 1 )
				if( IsDamageTypeNameValid(attrs[i]) )
					dmgNames.PushBack( attrs[i] );
			
			if(dmgNames.Size() == 0)
				LogAssert(false, "CInventoryComponent.GetWeaponDTNames: weapon <<" + GetItemName(id) + ">> has no damage types defined!");
		}
		return dmgNames.Size();
	}
	
	public function GetWeapons() : array<SItemUniqueId>
	{
		var ids, ids2 : array<SItemUniqueId>;
	
		ids = GetItemsByCategory('monster_weapon');
		ids2 = GetItemsByTag('Weapon');
		ArrayOfIdsAppend(ids, ids2);
		
		return ids;
	}
	
	public function GetHeldWeapons() : array<SItemUniqueId>
	{
		var i : int;
		var w : array<SItemUniqueId>;
	
		w = GetWeapons();
		
		for(i=w.Size()-1; i>=0; i-=1)
		{
			if(!IsItemHeld(w[i]))
			{
				w.EraseFast( i );
			}
		}
		
		return w;
	}
	
	public function GetCurrentlyHeldWeapon() : SItemUniqueId
	{
		var w : array<SItemUniqueId> = GetHeldWeapons();
		
		return w[0];
	}
	
	public function GetCurrentlyHeldSword() : SItemUniqueId
	{
		var i	: int;
		var w	: array<SItemUniqueId>;
		
		w = GetHeldWeapons();
		
		for( i = 0 ; i < w.Size() ; i+=1 )
		{
			if( IsItemSteelSwordUsableByPlayer( w[i] ) || IsItemSilverSwordUsableByPlayer( w[i] ) )
			{
				return w[i];
			}
		}
		
		return GetInvalidUniqueId();		
	}
	
	public function GetCurrentlyHeldSwordEntity( out ent : CItemEntity ) : bool
	{
		var id		: SItemUniqueId;
		
		id = GetCurrentlyHeldSword();
		
		if( IsIdValid( id ) )
		{
			ent = GetItemEntityUnsafe( id );
			
			if( ent )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		return false;
	}
	
	public function GetHeldWeaponsWithCategory( category : name, out items : array<SItemUniqueId> )
	{
		var i : int;
	
		items = GetItemsByCategory( category );
		
		for ( i = items.Size()-1; i >= 0; i -= 1)
		{
			if ( !IsItemHeld( items[i] ) )
			{
				items.EraseFast( i );
			}
		}
	}
		
	public function GetPotionItemBuffData(id : SItemUniqueId, out type : EEffectType, out customAbilityName : name) : bool
	{
		var size, i : int;
		var arr : array<name>;
	
		if(IsIdValid(id))
		{
			GetItemContainedAbilities( id, arr );
			size = arr.Size();
			
			for( i = 0; i < size; i += 1 )
			{
				if( IsEffectNameValid(arr[i]) )
				{
					EffectNameToType(arr[i], type, customAbilityName);
					return true;
				}
			}
		}
		
		return false;
	}

	
	public function RecycleItem( id : SItemUniqueId, level : ECraftsmanLevel ) :  array<SItemUniqueId>
	{
		var itemsAdded : array<SItemUniqueId>;
		var currentAdded : array<SItemUniqueId>;
		
		var parts : array<SItemParts>;
		var i : int;
		
		parts = GetItemRecyclingParts( id );
		
		for ( i = 0; i < parts.Size(); i += 1 )
		{
			if ( ECL_Grand_Master == level || ECL_Arch_Master == level )
			{
				if( !((GetItemName(id) == 'Shell' || GetItemName(id) == 'Seashell') && RandF() < 0.9) )
					currentAdded = AddAnItem( parts[i].itemName, parts[i].quantity );
			}
			else if ( ECL_Master == level && parts[i].quantity > 1 )
			{
				if( !((GetItemName(id) == 'Shell' || GetItemName(id) == 'Seashell') && RandF() < 0.9) )
					currentAdded = AddAnItem( parts[i].itemName, parts[i].quantity );
			}
			else
			{
				if( !((GetItemName(id) == 'Shell' || GetItemName(id) == 'Seashell') && RandF() < 0.9) )
					currentAdded = AddAnItem( parts[i].itemName, parts[i].quantity );
			}
			itemsAdded.PushBack(currentAdded[0]);
		}

		RemoveItem(id);
		
		return itemsAdded;
	}
		
	
	
	
	
	
	public function GetItemBuffs( id : SItemUniqueId, out buffs : array<SEffectInfo>) : int
	{
		var attrs, abs, absFast : array< name >;
		var i, k : int;
		var type : EEffectType;
		var abilityName : name;
		var buff : SEffectInfo;
		var dm : CDefinitionsManagerAccessor;
		
		buffs.Clear();
		
		if( !IsIdValid(id) )
			return 0;
		
		
		GetItemContainedAbilities(id, absFast);
		if(absFast.Size() == 0)
			return 0;
		
		GetItemAbilities(id, abs);
		dm = theGame.GetDefinitionsManager();
		for(k=0; k<abs.Size(); k+=1)
		{
			dm.GetContainedAbilities(abs[k], attrs);
			buff.applyChance = CalculateAttributeValue(GetItemAbilityAttributeValue(id, 'buff_apply_chance', abs[k])) * ArrayOfNamesCount(abs, abs[k]);
			
			for( i = 0; i < attrs.Size(); i += 1 )
			{
				if( IsEffectNameValid(attrs[i]) )
				{
					EffectNameToType(attrs[i], type, abilityName);
					
					buff.effectType = type;
					buff.effectAbilityName = abilityName;					
					
					buffs.PushBack(buff);
					
					
					if(absFast.Size() == 1)
						return buffs.Size();
					else
						absFast.EraseFast(0);					
				}
			}
		}
		
		return buffs.Size();
	}	
	
	
	public function DropItemInBag( item : SItemUniqueId, quantity : int ) 
	{
		var entities : array<CGameplayEntity>;
		var i : int;
		var owner : CActor;
		var bag : W3ActorRemains;
		var template : CEntityTemplate;
		var bagtags : array <name>;
		var bagPosition : Vector;
		var tracedPosition, tracedNormal : Vector;
		
		//Kolaris - Inventory Options
		if(ItemHasTag(item, 'NoDrop') && !(Options().DropQuestItems())) 
			return;		
			
		if(Options().DeleteDroppedItems())
		{
			RemoveItem(item, quantity);
			return;
		}
		
		owner = (CActor)GetEntity();
		FindGameplayEntitiesInRange(entities, owner, 0.5, 100);
		
		for(i=0; i<entities.Size(); i+=1)
		{
			bag = (W3ActorRemains)entities[i];
			
			if(bag)
				break;
		}
		
		
		if(!bag)
		{
			template = (CEntityTemplate)LoadResource("lootbag");
			bagtags.PushBack('lootbag');
			
			
			bagPosition = owner.GetWorldPosition();
			if ( theGame.GetWorld().StaticTrace( bagPosition, bagPosition + Vector( 0.0f, 0.0f, -10.0f, 0.0f ), tracedPosition, tracedNormal ) )
			{
				bagPosition = tracedPosition;
			}
			bag = (W3ActorRemains)theGame.CreateEntity(template, bagPosition, owner.GetWorldRotation(), true, false, false, PM_Persist,bagtags);
		}
	
		
		GiveItemTo(bag.GetInventory(), item, quantity, false);
		
		
		if(bag.GetInventory().IsEmpty())
		{
			delete bag;
			return;
		}		
		
		bag.LootDropped();		
		theTelemetry.LogWithLabelAndValue(TE_INV_ITEM_DROPPED, GetItemName(item), quantity);
		
		
		if( thePlayer.IsSwimming() )
		{
			bag.PlayPropertyAnimation( 'float', 0 );
		}
	}
	
	public function HorseDropItemInBag( item : SItemUniqueId, quantity : int ) 
	{
		var entities : array<CGameplayEntity>;
		var i : int;
		var owner : CActor;
		var bag : W3ActorRemains;
		var template : CEntityTemplate;
		var bagtags : array <name>;
		var bagPosition : Vector;
		var tracedPosition, tracedNormal : Vector;
		
		//Kolaris - Inventory Options
		if(ItemHasTag(item, 'NoDrop') && !(Options().DropQuestItems())) 
			return;		
			
		if(Options().DeleteDroppedItems())
		{
			RemoveItem(item, quantity);
			return;
		}
			
		owner = thePlayer;
		FindGameplayEntitiesInRange(entities, owner, 0.5, 100);
		for(i=0; i<entities.Size(); i+=1)
		{
			bag = (W3ActorRemains)entities[i];
			
			if(bag)
				break;
		}
		
		if(!bag)
		{
			template = (CEntityTemplate)LoadResource("lootbag");
			bagtags.PushBack('lootbag');
			
			
			bagPosition = owner.GetWorldPosition();
			if ( theGame.GetWorld().StaticTrace( bagPosition, bagPosition + Vector( 0.0f, 0.0f, -10.0f, 0.0f ), tracedPosition, tracedNormal ) )
			{
				bagPosition = tracedPosition;
			}
			bag = (W3ActorRemains)theGame.CreateEntity(template, bagPosition, owner.GetWorldRotation(), true, false, false, PM_Persist,bagtags);
		}
		
		GiveItemTo(bag.GetInventory(), item, quantity, false);
		if( bag.GetInventory().IsEmpty() )
		{
			delete bag;
			return;
		}		
		
		bag.LootDropped();		
		theTelemetry.LogWithLabelAndValue(TE_INV_ITEM_DROPPED, GetItemName(item), quantity);
		if( thePlayer.IsSwimming() )
		{
			bag.PlayPropertyAnimation( 'float', 0 );
		}
	}
	
	
	
	
	
	
	public final function AddRepairObjectItemBonuses(buffArmor : bool, buffSwords : bool, ammoArmor : int, ammoWeapon : int) : bool
	{
		var upgradedSomething, isArmor : bool;
		var i, ammo, currAmmo : int;
		var items, items2 : array<SItemUniqueId>;
		
		
		if(buffArmor)
		{
			items = GetItemsByTag(theGame.params.TAG_ARMOR);
		}
		if(buffSwords)
		{
			items2 = GetItemsByTag(theGame.params.TAG_PLAYER_STEELSWORD);
			ArrayOfIdsAppend(items, items2);
			items2.Clear();
			items2 = GetItemsByTag(theGame.params.TAG_PLAYER_SILVERSWORD);
			ArrayOfIdsAppend(items, items2);
		}
		
		upgradedSomething = false;
		
		for(i=0; i<items.Size(); i+=1)
		{
			
			if(IsItemAnyArmor(items[i]))
			{
				isArmor = true;
				ammo = ammoArmor;
			}
			else
			{
				isArmor = false;
				ammo = ammoWeapon;
			}
			
			
			currAmmo = GetItemModifierInt(items[i], 'repairObjectBonusAmmo', 0);
			
			
			if(ammo > currAmmo)
			{
				SetItemModifierInt(items[i], 'repairObjectBonusAmmo', ammo);
				upgradedSomething = true;
				
				
				if(currAmmo == 0)
				{
					if(isArmor)
						AddItemCraftedAbility(items[i], theGame.params.REPAIR_OBJECT_BONUS_ARMOR_ABILITY, false);
					else
						AddItemCraftedAbility(items[i], theGame.params.REPAIR_OBJECT_BONUS_WEAPON_ABILITY, false);
				}
			}
		}
		
		return upgradedSomething;
	}
	
	public final function ReduceItemRepairObjectBonusCharge(item : SItemUniqueId)	
	{
		var currAmmo : int;
		
		currAmmo = GetItemModifierInt(item, 'repairObjectBonusAmmo', 0);
		
		if(currAmmo > 0)
		{
			SetItemModifierInt(item, 'repairObjectBonusAmmo', currAmmo - 1);
		
			if(currAmmo == 1)
			{
				if(IsItemAnyArmor(item))
					RemoveItemCraftedAbility(item, theGame.params.REPAIR_OBJECT_BONUS_ARMOR_ABILITY);
				else
					RemoveItemCraftedAbility(item, theGame.params.REPAIR_OBJECT_BONUS_WEAPON_ABILITY);
			}
		}
	}
	
	
	public final function GetRepairObjectBonusValueForArmor(armor : SItemUniqueId) : SAbilityAttributeValue
	{
		var retVal, bonusValue, baseArmor : SAbilityAttributeValue;
		
		if(GetItemModifierInt(armor, 'repairObjectBonusAmmo', 0) > 0)
		{
			bonusValue = GetItemAttributeValue(armor, theGame.params.REPAIR_OBJECT_BONUS);		
			baseArmor = GetItemAttributeValue(armor, theGame.params.ARMOR_VALUE_NAME);
			
			baseArmor.valueMultiplicative += 1;		
			retVal.valueAdditive = bonusValue.valueAdditive + CalculateAttributeValue(baseArmor) * bonusValue.valueMultiplicative;
		}
		
		return retVal;
	}
	
	
	
	
	
		
	public function CanItemHaveOil(id : SItemUniqueId) : bool
	{
		// W3EE - Begin
		//return IsItemSteelSwordUsableByPlayer(id) || IsItemSilverSwordUsableByPlayer(id);
		return GetItemCategory(id) == 'steelsword' || GetItemCategory(id) == 'silversword';
		// W3EE - End
	}
	
	public final function RemoveAllOilsFromItem( id : SItemUniqueId )
	{
		var i : int;
		var oils : array< W3Effect_Oil >;
		var actor : CActor;
		
		actor = ( CActor ) GetEntity();
		oils = GetOilsAppliedOnItem( id );
		for( i = oils.Size() - 1; i >= 0; i -= 1 )
		{
			actor.RemoveEffect( oils[ i ] );
		}
	}
	
	public final function GetActiveOilsAppliedOnItemCount( id : SItemUniqueId ) : int
	{
		var oils : array< W3Effect_Oil >;
		var i, count : int;
		
		count = 0;
		oils = GetOilsAppliedOnItem( id );
		for( i=0; i<oils.Size(); i+=1 )
		{
			if( oils[ i ].GetAmmoCurrentCount() > 0 )
			{
				count += 1;
			}
		}
		
		// W3EE - Begin
		if( count <= 0 )
			RemoveAllOilsFromItem(id);
		// W3EE - End
		
		return count;
	}
	
	public final function RemoveOldestOilFromItem( id : SItemUniqueId )
	{
		var buffToRemove : W3Effect_Oil;
		var actor : CActor;
		
		actor = ( CActor ) GetEntity();
		if(! actor )
			return;
			
		buffToRemove = GetOldestOilAppliedOnItem(id, false);
		
		if(buffToRemove)
		{
			actor.RemoveEffect( buffToRemove );
		}
	}
	
	public final function GetOilsAppliedOnItem( id : SItemUniqueId ) : array< W3Effect_Oil >
	{
		var i : int;
		var oils : array< CBaseGameplayEffect >;
		var buff : W3Effect_Oil;
		var ret : array < W3Effect_Oil >;
		var actor : CActor;
		
		actor = ( CActor ) GetEntity();
		if(! actor )
			return ret;
			
		oils = actor.GetBuffs( EET_Oil );
		for( i = oils.Size() - 1; i >= 0; i -= 1 )
		{
			buff = ( W3Effect_Oil ) oils[ i ];
			if(buff && buff.GetSwordItemId() == id )
			{
				ret.PushBack( buff );
			}
		}
		
		return ret;
	}
	
	public final function GetNewestOilAppliedOnItem( id : SItemUniqueId, onlyShowable : bool ) : W3Effect_Oil
	{
		return GetOilAppliedOnItemInternal( id, onlyShowable, true );
	}
	
	public final function GetOldestOilAppliedOnItem( id : SItemUniqueId, onlyShowable : bool ) : W3Effect_Oil
	{
		return GetOilAppliedOnItemInternal( id, onlyShowable, false );
	}
	
	private final function GetOilAppliedOnItemInternal( id : SItemUniqueId, onlyShowable : bool, newest : bool ) : W3Effect_Oil
	{
		var oils : array< W3Effect_Oil >;
		var i, lastIndex : int;
		
		oils = GetOilsAppliedOnItem( id );
		lastIndex = -1;
		
		for( i=0; i<oils.Size(); i+=1 )
		{
			if( onlyShowable && !oils[i].GetShowOnHUD() )
			{
				continue;
			}
			
			if( lastIndex == -1 )
			{
				lastIndex = i;
			}
			else if( newest && oils[i].GetQueueTimer() < oils[lastIndex].GetQueueTimer() )
			{
				lastIndex = i;
			}
			else if( !newest && oils[i].GetQueueTimer() > oils[lastIndex].GetQueueTimer() )
			{
				lastIndex = i;
			}
		}
		
		if( lastIndex == -1 )
		{
			return NULL;
		}
		
		return oils[lastIndex];
	}
	
	public final function ItemHasAnyActiveOilApplied( id : SItemUniqueId ) : bool
	{
		return GetActiveOilsAppliedOnItemCount( id );
	}
	
	/*
	public final function ItemHasActiveOilApplied( id : SItemUniqueId, monsterCategory : EMonsterCategory ) : bool
	{
		var i : int;
		var oils : array< W3Effect_Oil >;
		
		oils = GetOilsAppliedOnItem( id );
		for( i=0; i<oils.Size(); i+=1 )
		{
			if( oils[ i ].GetMonsterCategory() == monsterCategory && oils[ i ].GetAmmoCurrentCount() > 0 )
			{
				return true;
			}
		}
		
		return false;
	}
	*/
	
	
	
	
	public final function GetParamsForRunewordTooltip(runewordName : name, out i : array<int>, out f : array<float>, out s : array<string>)
	{
		var min, max, sp : SAbilityAttributeValue;
		var val : float;
		var attackRangeBase, attackRangeExt : CAIAttackRange;
		
		i.Clear();
		f.Clear();
		s.Clear();
		
		switch(runewordName)
		{
			// Kolaris - Enchantment Overhaul
			//Disintegration
			case 'Glyphword 1' :
				i.PushBack( 5 );
				i.PushBack( 100 );
				break;
			case 'Glyphword 2' :
				i.PushBack( 5 );
				i.PushBack( 200 );
				break;
			case 'Glyphword 3' :
				i.PushBack( 25 );
				i.PushBack( 1200 );
				i.PushBack( 300 );
				break;
			//Acceleration
			case 'Glyphword 4' :
				i.PushBack( 30 );
				i.PushBack( 2 );
				i.PushBack( 5 );
				break;
			case 'Glyphword 5' :
				i.PushBack( 10 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 6' :
				i.PushBack( 15 );
				break;
			//Immolation
			case 'Glyphword 7' :
				i.PushBack( 50 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 8' :
				i.PushBack( 20 );
				i.PushBack( 20 );
				break;
			case 'Glyphword 9' :
				i.PushBack( 5 );
				i.PushBack( 30 );
				break;
			//Purgation
			case 'Glyphword 10' :
				i.PushBack( 100 );
				break;
			case 'Glyphword 11' :
				i.PushBack( 1500 );
				i.PushBack( 200 );
				break;
			case 'Glyphword 12' :
				f.PushBack( 0.5f );
				f.PushBack( 2.f );
				i.PushBack( 300 );
				break;
			//Absorption
			case 'Glyphword 13' :
				i.PushBack( 1 );
				break;
			case 'Glyphword 14' :
				i.PushBack( 2 );
				break;
			case 'Glyphword 15' :
				i.PushBack( 3 );
				break;
			//Enervation
			case 'Glyphword 16' :
				i.PushBack( 10 );
				i.PushBack( 25 );
				i.PushBack( 1 );
				break;
			case 'Glyphword 17' :
				f.PushBack( 0.5f );
				i.PushBack( 2 );
				i.PushBack( 2 );
				break;
			case 'Glyphword 18' :
				f.PushBack( 0.5f );
				i.PushBack( 3 );
				break;
			//Retribution
			case 'Glyphword 19' :
				i.PushBack( 1000 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 20' :
				i.PushBack( 20 );
				break;
			case 'Glyphword 21' :
				i.PushBack( 1000 );
				i.PushBack( 30 );
				break;
			//Bastion
			case 'Glyphword 22' :
				i.PushBack( 50 );
				i.PushBack( 5 );
				break;
			case 'Glyphword 23' :
				i.PushBack( 200 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 24' :
				i.PushBack( 50 );
				i.PushBack( 15 );
				break;
			//Conjunction
			case 'Glyphword 25' :
				i.PushBack( 5 );
				break;
			case 'Glyphword 26' :
				i.PushBack( 10 );
				break;
			case 'Glyphword 27' :
				i.PushBack( 15 );
				break;
			//Posession
			case 'Glyphword 28' :
				i.PushBack( 10000 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 29' :
				i.PushBack( 50 );
				i.PushBack( 20 );
				break;
			case 'Glyphword 30' :
				i.PushBack( 30 );
				break;
			//Protection
			case 'Glyphword 31' :
				i.PushBack( 300 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 32' :
				i.PushBack( 20 );
				break;
			case 'Glyphword 33' :
				i.PushBack( 30 );
				break;
			//Deflection
			case 'Glyphword 34' :
				i.PushBack( 100 );
				break;
			case 'Glyphword 35' :
				i.PushBack( 200 );
				break;
			case 'Glyphword 36' :
				i.PushBack( 300 );
				break;
			//Regeneration
			case 'Glyphword 37' :
				i.PushBack( 5 );
				break;
			case 'Glyphword 38' :
				i.PushBack( 50 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 39' :
				i.PushBack( 10 );
				i.PushBack( 15 );
				break;
			//Perfection
			case 'Glyphword 40' :
				i.PushBack( 500 );
				break;
			case 'Glyphword 41' :
				i.PushBack( 5 );
				i.PushBack( 1000 );
				break;
			case 'Glyphword 42' :
				i.PushBack( 1 );
				i.PushBack( 10 );
				i.PushBack( 1 );
				i.PushBack( 100 );
				i.PushBack( 1500 );
				break;
			//Constitution
			case 'Glyphword 43' :
				i.PushBack( 20 );
				i.PushBack( 200 );
				i.PushBack( 20 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 44' :
				i.PushBack( 20 );
				i.PushBack( 2 );
				i.PushBack( 20 );
				i.PushBack( 20 );
				break;
			case 'Glyphword 45' :
				i.PushBack( 1 );
				i.PushBack( 500 );
				i.PushBack( 50 );
				i.PushBack( 30 );
				break;
			//Assimilation
			case 'Glyphword 46' :
				i.PushBack( 50 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 47' :
				i.PushBack( 20 );
				i.PushBack( 2 );
				i.PushBack( 20 );
				i.PushBack( 20 );
				break;
			case 'Glyphword 48' :
				i.PushBack( 5 );
				i.PushBack( 30 );
				break;
			//Elation
			case 'Glyphword 49' :
				i.PushBack( 20 );
				i.PushBack( 15 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 50' :
				i.PushBack( 50 );
				i.PushBack( 20 );
				break;
			case 'Glyphword 51' :
				i.PushBack( 30 );
				break;
			//Conservation
			case 'Glyphword 52' :
				i.PushBack( 1 );
				i.PushBack( RoundMath(50 * Options().StamCostGlobal()) );
				i.PushBack( 5 );
				break;
			case 'Glyphword 53' :
				i.PushBack( 50 );
				i.PushBack( 10 );
				break;
			case 'Glyphword 54' :
				i.PushBack( 25 );
				i.PushBack( 50 );
				i.PushBack( 15 );
				break;
			
			//Glaciation
			case 'Runeword 1' :
				i.PushBack( 5 );
				break;
			case 'Runeword 2' :
				i.PushBack( 10 );
				break;
			case 'Runeword 3' :
				i.PushBack( 50 );
				i.PushBack( 15 );
				break;
			//Exhaustion
			case 'Runeword 4' :
				i.PushBack( 10 );
				i.PushBack( 1 );
				i.PushBack( 5 );
				break;
			case 'Runeword 5' :
				i.PushBack( 40 );
				i.PushBack( 10 );
				break;
			case 'Runeword 6' :
				i.PushBack( 1 );
				i.PushBack( 15 );
				break;
			//Obliteration
			case 'Runeword 7' :
				i.PushBack( 20 );
				i.PushBack( 50 );
				break;
			case 'Runeword 8' :
				i.PushBack( 1 );
				i.PushBack( 1 );
				i.PushBack( 100 );
				break;
			case 'Runeword 9' :
				i.PushBack( 5 );
				i.PushBack( 1000 );
				i.PushBack( 2 );
				i.PushBack( 150 );
				break;
			//Cremation
			case 'Runeword 10' :
				f.PushBack( 0.5f );
				i.PushBack( 5 );
				break;
			case 'Runeword 11' :
				i.PushBack( 20 );
				i.PushBack( 10 );
				i.PushBack( 10 );
				break;
			case 'Runeword 12' :
				i.PushBack( 1 );
				i.PushBack( 15 );
				break;
			//Transmutation
			case 'Runeword 13' :
			i.PushBack( 10 );
				i.PushBack( 50 );
				break;
			case 'Runeword 14' :
				i.PushBack( 100 );
				break;
			case 'Runeword 15' :
				i.PushBack( 10 );
				i.PushBack( 150 );
				break;
			//Affliction
			case 'Runeword 16' :
				i.PushBack( 1 );
				i.PushBack( 2 );
				i.PushBack( 5 );
				break;
			case 'Runeword 17' :
				i.PushBack( 10 );
				break;
			case 'Runeword 18' :
				i.PushBack( 5 );
				i.PushBack( 100 );
				i.PushBack( 15 );
				break;
			//Exsanguination
			case 'Runeword 19' :
				i.PushBack( 1 );
				i.PushBack( 5 );
				break;
			case 'Runeword 20' :
				i.PushBack( 10 );
				break;
			case 'Runeword 21' :
				i.PushBack( 5 );
				i.PushBack( 600 );
				i.PushBack( 2 );
				i.PushBack( 15 );
				break;
			//Desperation
			case 'Runeword 22' :
				i.PushBack( 50 );
				i.PushBack( 1 );
				break;
			case 'Runeword 23' :
				i.PushBack( 2 );
				break;
			case 'Runeword 24' :
				f.PushBack( 0.05f );
				f.PushBack( 0.1f );
				i.PushBack( 3 );
				break;
			//Reflection
			case 'Runeword 25' :
				i.PushBack( 10 );
				break;
			case 'Runeword 26' :
				i.PushBack( 50 );
				i.PushBack( 50 );
				i.PushBack( 20 );
				break;
			case 'Runeword 27' :
				i.PushBack( 5 );
				i.PushBack( 30 );
				break;
			//Electrocution
			case 'Runeword 28' :
				i.PushBack( 10 );
				i.PushBack( 30 );
				break;
			case 'Runeword 29' :
				i.PushBack( 150 );
				i.PushBack( 60 );
				break;
			case 'Runeword 30' :
				i.PushBack( 10 );
				i.PushBack( 5 );
				i.PushBack( 200 );
				i.PushBack( 90 );
				break;
			//Exhilaration
			case 'Runeword 31' :
				i.PushBack( RoundMath(20 * Options().StamCostGlobal()) );
				i.PushBack( 5 );
				break;
			case 'Runeword 32' :
				i.PushBack( 2 );
				i.PushBack( 10 );
				break;
			case 'Runeword 33' :
				i.PushBack( 100 );
				i.PushBack( 15 );
				break;
			//Assassination
			case 'Runeword 34' :
				i.PushBack( 100 );
				i.PushBack( 10 );
				break;
			case 'Runeword 35' :
				i.PushBack( 20 );
				break;
			case 'Runeword 36' :
				i.PushBack( 200 );
				i.PushBack( 30 );
				break;
			//Prolongation
			case 'Runeword 37' :
				i.PushBack( 100 );
				i.PushBack( 10 );
				break;
			case 'Runeword 38' :
				i.PushBack( 50 );
				i.PushBack( 20 );
				break;
			case 'Runeword 39' :
				i.PushBack( 10 );
				i.PushBack( 30 );
				break;
			//Invocation
			case 'Runeword 40' :
				i.PushBack( 5 );
				break;
			case 'Runeword 41' :
				i.PushBack( 10 );
				break;
			case 'Runeword 42' :
				i.PushBack( 100 );
				i.PushBack( 5 );
				i.PushBack( 15 );
				break;
			//Resolution
			case 'Runeword 43' :
				f.PushBack( 0.5f );
				i.PushBack( 1000 );
				f.PushBack( 0.5f );
				i.PushBack( 10 );
				break;
			case 'Runeword 44' :
				i.PushBack( 25 );
				i.PushBack( 75 );
				i.PushBack( 20 );
				break;
			case 'Runeword 45' :
				i.PushBack( 150 );
				i.PushBack( 30 );
				i.PushBack( 30 );
				break;
			//Destruction
			case 'Runeword 46' :
				i.PushBack( 25 );
				i.PushBack( 10 );
				break;
			case 'Runeword 47' :
				i.PushBack( 50 );
				i.PushBack( 25 );
				i.PushBack( 5 );
				i.PushBack( 20 );
				break;
			case 'Runeword 48' :
				i.PushBack( 25 );
				i.PushBack( 50 );
				i.PushBack( 5 );
				i.PushBack( 30 );
				break;
			//Penetration
			case 'Runeword 49' :
				i.PushBack( 50 );
				i.PushBack( 10 );
				break;
			case 'Runeword 50' :
				i.PushBack( 20 );
				break;
			case 'Runeword 51' :
				i.PushBack( 10 );
				i.PushBack( 3 );
				i.PushBack( 5 );
				i.PushBack( 30 );
				break;
			//Fortification
			case 'Runeword 52' :
				i.PushBack( 20 );
				i.PushBack( 10 );
				break;
			case 'Runeword 53' :
				i.PushBack( 20 );
				break;
			case 'Runeword 54' :
				i.PushBack( 100000 );
				i.PushBack( 1 );
				i.PushBack( 30 );
				break;
			//Mutilation
			case 'Runeword 55' :
				i.PushBack( 5 );
				i.PushBack( 50 );
				i.PushBack( 10 );
				break;
			case 'Runeword 56' :
				i.PushBack( 100 );
				i.PushBack( 100 );
				i.PushBack( 20 );
				break;
			case 'Runeword 57' :
				i.PushBack( 10 );
				i.PushBack( 10 );
				i.PushBack( 30 );
				break;
			//Desolation
			case 'Runeword 58' :
				i.PushBack( 25 );
				i.PushBack( 10 );
				break;
			case 'Runeword 59' :
				i.PushBack( 1 );
				i.PushBack( 20 );
				break;
			case 'Runeword 60' :
				i.PushBack( 100 );
				i.PushBack( 30 );
				break;
			default:
				break;
		}
	}
	
	public final function GetPotionAttributesForTooltip( potionName : name, out tips : array<SAttributeTooltip> ) : void
	{
		var i, j : int;
		var buffType : EEffectType;
		var abilityName : name;
		var abs, temp : array<name>;
		var val, temp4 : SAbilityAttributeValue;
		var newAttr : SAttributeTooltip;
		var attrs : array<SItemAttributes>;
		var temp1 : array<float>;
		var temp2, temp3 : int;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var abIdx : int;
		
		//Kolaris - NextGen Update
		if( !(dm.IsItemPotion(potionName) || dm.IsItemFood(potionName) || potionName == 'Signs Enhancement') )
			return;
			
		abIdx = 0;
		dm.GetItemAbilitiesWithWeights(potionName, true, abs, temp1, temp2, temp3);
		if( dm.IsItemFood(potionName) )
		{
			for(i=0; i<abs.Size(); i+=1)
			{
				if( StrContains(abs[i], 'Quality') )
				{
					abIdx = i;
					break;
				}
			}
		}
		
		dm.GetContainedAbilities(abs[abIdx], abs);
		for(i=0; i<abs.Size(); i+=1)
		{
			EffectNameToType(abs[i], buffType, abilityName);
			if( buffType == EET_Undefined )
				continue;
				
			dm.GetAbilityAttributes(abs[i], temp);
			for(j=0; j<temp.Size(); j+=1)
			{
				if( temp[j] == 'duration' || temp[j] == 'level' )
					continue;
					
				switch(buffType)	// abilities from items that shouldn't be in the tooltips but are in the ability go here for exclusion
				{
					case EET_Cat:
						if( temp[j] == 'highlightObjectsRange' )
							continue;
					break;
					
					case EET_Swallow:
					case EET_WhiteRaffardDecoction:
						if( temp[j] == 'vitalityCombatRegen' )
							continue;
					break;
					
					case EET_Thunderbolt:
						if( temp[j] == 'critical_frenzy_chance' || temp[j] == 'critical_frenzy_duration' || temp[j] == 'critical_frenzy_slowdown' )
							continue;
					break;
				}
				attrs.PushBack(SItemAttributes(abs[i], temp[j], buffType));
			}
		}
		
		for(i=0; i<attrs.Size(); i+=1)
		{
			dm.GetAbilityAttributeValue(attrs[i].abilityName, attrs[i].attributeName, val, temp4);
			
			buffType = attrs[i].buffType;
			newAttr.originName = attrs[i].attributeName;
			newAttr.attributeName = GetAttributeNameLocStr(attrs[i].attributeName, false);
			//Kolaris - Decoctions & Mutagens
			if( buffType == EET_Decoction1 )
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if( buffType == EET_Decoction2 )
			{
				newAttr.value = val.valueAdditive;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'add';
			}
			else if( buffType == EET_Decoction3 )
			{
				newAttr.value = val.valueBase;
				newAttr.percentageValue = false;
				newAttr.attributeType = 'base';
			}
			else if( buffType == EET_Decoction4 )
			{
				newAttr.value = val.valueAdditive;
				newAttr.percentageValue = false;
				newAttr.attributeType = 'add';
			}
			else if( buffType == EET_Decoction5 )
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if( buffType == EET_Decoction6 )
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if( buffType == EET_Decoction7 )
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if( buffType == EET_Decoction8 )
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if( buffType == EET_Decoction9 )
			{
				newAttr.value = val.valueAdditive;
				newAttr.percentageValue = false;
				newAttr.attributeType = 'add';
			}
			else if( buffType == EET_Decoction10 )
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if(val.valueMultiplicative != 0)
			{
				newAttr.value = val.valueMultiplicative;
				newAttr.percentageValue = true;
				newAttr.attributeType = 'mult';
			}
			else if( val.valueAdditive != 0 )
			{
				if( buffType == EET_Thunderbolt )
				{
					newAttr.value = val.valueAdditive;
					newAttr.percentageValue = false;
					newAttr.attributeType = 'add';
				}
				else if( buffType == EET_BlackBlood )
				{
					newAttr.value = val.valueAdditive;
					newAttr.percentageValue = true;
					newAttr.attributeType = 'add';
				}
				else if( buffType == EET_Blizzard )
				{
					newAttr.value = 1 - val.valueAdditive;
					newAttr.percentageValue = true;
					newAttr.attributeType = 'add';
				}
				else
				{
					newAttr.value = val.valueAdditive;
					newAttr.percentageValue = false;
					newAttr.attributeType = 'add';
				}
			}
			else
			{
				if( buffType == EET_GoldenOriole )
				{
					newAttr.value = val.valueBase;
					newAttr.percentageValue = true;
					newAttr.attributeType = 'base';
				}
				else
				{
					newAttr.value = val.valueBase;
					newAttr.percentageValue = false;
					newAttr.attributeType = 'base';
				}
			}
			
			tips.PushBack(newAttr);
		}
	}
	
	public function GetItemRelativeTooltipType(id :SItemUniqueId, invOther : CInventoryComponent, idOther : SItemUniqueId) : ECompareType
	{	
		
		if( (GetItemCategory(id) == invOther.GetItemCategory(idOther)) ||
		    ItemHasTag(id, 'PlayerSteelWeapon') && invOther.ItemHasTag(idOther, 'PlayerSteelWeapon') ||
		    ItemHasTag(id, 'PlayerSilverWeapon') && invOther.ItemHasTag(idOther, 'PlayerSilverWeapon') ||
		    ItemHasTag(id, 'PlayerSecondaryWeapon') && invOther.ItemHasTag(idOther, 'PlayerSecondaryWeapon')
		)
		{
			return ECT_Compare;
		}
		return ECT_Incomparable;
	}
	
	
	private function FormatFloatForTooltip(fValue : float) : string
	{
		var valueInt, valueDec : int;
		var strValue : string;
		
		if(fValue < 0)
		{
			valueInt = CeilF(fValue);
			valueDec = RoundMath((fValue - valueInt)*(-100));
		}
		else
		{
			valueInt = FloorF(fValue);
			valueDec = RoundMath((fValue - valueInt)*(100));
		}
		strValue = valueInt+".";
		if(valueDec < 10)
			strValue += "0"+valueDec;
		else
			strValue += ""+valueDec;
		
		return strValue;
	}

	public function SetPriceMultiplier( mult : float )
	{
		priceMult = mult;
	}
	
	
	public function GetMerchantPriceModifier( shopNPC : CNewNPC, item : SItemUniqueId ) : float
	{
		var areaPriceMult		: float;
		var itemPriceMult		: float;
		var importPriceMult		: float;
		var finalPriceMult		: float;
		var tag					: name;
		var zoneName			: EZoneName;
		
		zoneName = theGame.GetCurrentZone();
		
		switch ( zoneName )
		{
			case ZN_NML_CrowPerch 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('crow_perch_price_mult'));
			case ZN_NML_SpitfireBluff 		: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('spitfire_bluff_price_mult'));
			case ZN_NML_TheMire 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('the_mire_price_mult'));
			case ZN_NML_Mudplough 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('mudplough_price_mult'));
			case ZN_NML_Grayrocks 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('grayrocks_price_mult'));
			case ZN_NML_TheDescent 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('the_descent_price_mult'));
			case ZN_NML_CrookbackBog 		: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('crookback_bog_price_mult'));
			case ZN_NML_BaldMountain 		: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('bald_mountain_price_mult'));
			case ZN_NML_Novigrad 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('novigrad_price_mult'));
			case ZN_NML_Homestead 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('homestead_price_mult'));
			case ZN_NML_Gustfields 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('gustfields_price_mult'));
			case ZN_NML_Oxenfurt 			: areaPriceMult = CalculateAttributeValue(thePlayer.GetAttributeValue('oxenfurt_price_mult'));
			case ZN_Undefined				: areaPriceMult = 1;
		}
		
		if 		(ItemHasTag(item,'weapon')) 	{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('weapon_price_mult')); }
		else if (ItemHasTag(item,'armor')) 		{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('armor_price_mult')); }
		else if (ItemHasTag(item,'crafting')) 	{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('crafting_price_mult')); }
		else if (ItemHasTag(item,'alchemy')) 	{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('alchemy_price_mult')); }
		else if (ItemHasTag(item,'alcohol')) 	{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('alcohol_price_mult')); }
		else if (ItemHasTag(item,'food')) 		{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('food_price_mult')); }
		else if (ItemHasTag(item,'fish')) 		{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('fish_price_mult')); }
		else if (ItemHasTag(item,'books')) 		{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('books_price_mult')); }
		else if (ItemHasTag(item,'valuables'))	{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('valuables_price_mult')); }
		else if (ItemHasTag(item,'junk')) 		{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('junk_price_mult')); }
		else if (ItemHasTag(item,'orens')) 		{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('orens_price_mult')); }
		else if (ItemHasTag(item,'florens')) 	{ itemPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('florens_price_mult')); }
		else { itemPriceMult = 1; }
		
		if 		(ItemHasTag(item,'novigrad')) 	{ importPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('novigrad_price_mult')); }
		else if (ItemHasTag(item,'nilfgard')) 	{ importPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('nilfgard_price_mult')); }
		else if (ItemHasTag(item,'nomansland'))	{ importPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('nomansland_price_mult')); }
		else if (ItemHasTag(item,'skellige')) 	{ importPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('skellige_price_mult')); }
		else if (ItemHasTag(item,'nonhuman')) 	{ importPriceMult = CalculateAttributeValue(shopNPC.GetAttributeValue('nonhuman_price_mult')); }
		else { importPriceMult = 1; }
		
		finalPriceMult = areaPriceMult*itemPriceMult*importPriceMult*priceMult;
		return  finalPriceMult;
	}	

	public function SetRepairPriceMultiplier( mult : float ) 
	{
		priceRepairMult = mult;
	}
	
	
	public function GetRepairPriceModifier( repairNPC : CNewNPC ) : float 
	{
		return priceRepairMult;
	}	
	
	public function GetRepairPrice( item : SItemUniqueId ) : float 
	{
		var currDiff : float;
		currDiff = GetItemMaxDurability(item) - GetItemDurability(item); 
		
		return priceRepair * currDiff;
	}
	
	
	public function GetTooltipData(itemId : SItemUniqueId, out localizedName : string, out localizedDescription : string, out price : int, out localizedCategory : string,
									out itemStats : array<SAttributeTooltip>, out localizedFluff : string)
	{
		if( !IsIdValid(itemId) )
		{
			return;
		}
		localizedName = GetItemLocNameByID(itemId);
		localizedDescription = GetItemLocalizedDescriptionByUniqueID(itemId);
		localizedFluff = "IMPLEMENT ME - fluff text";
		// W3EE - Begin
		price = GetItemBasePriceModified( itemId, false );
		// W3EE - End
		localizedCategory = GetItemCategoryLocalisedString(GetItemCategory(itemId));
		GetItemStats(itemId, itemStats);
	}
	
	
	public function GetItemBaseStats(itemId : SItemUniqueId, out itemStats : array<SAttributeTooltip>)
	{
		var attributes : array<name>;
		
		var dm	: CDefinitionsManagerAccessor;
		var oilAbilities, oilAttributes : array<name>;
		var weights : array<float>;
		var i, j : int;
		var tmpI, tmpJ : int;
		
		var idx			  : int;
		var oilStatsCount : int;
		var oilName  	  : name;
		var oilStats 	  : array<SAttributeTooltip>;
		var oilStatFirst  : SAttributeTooltip;
		var oils		  : array< W3Effect_Oil >;
		
		GetItemBaseAttributes(itemId, attributes);
		
		
		oils = GetOilsAppliedOnItem( itemId );
		dm = theGame.GetDefinitionsManager();
		for( i=0; i<oils.Size(); i+=1 )
		{
			oilName = oils[ i ].GetOilItemName();
			
			oilAbilities.Clear();
			weights.Clear();
			dm.GetItemAbilitiesWithWeights(oilName, GetEntity() == thePlayer, oilAbilities, weights, tmpI, tmpJ);
			
			oilAttributes.Clear();
			oilAttributes = dm.GetAbilitiesAttributes(oilAbilities);
			
			oilStatsCount = oilAttributes.Size();
			for (idx = 0; idx < oilStatsCount; idx+=1)
			{
				attributes.Remove(oilAttributes[idx]);
			}
		}
		
		GetItemTooltipAttributes(itemId, attributes, itemStats);
	}
	
	
	public function GetItemStats(itemId : SItemUniqueId, out itemStats : array<SAttributeTooltip>)
	{
		var attributes : array<name>;
		
		GetItemAttributes(itemId, attributes);
		GetItemTooltipAttributes(itemId, attributes, itemStats);
	}
	
	private function GetItemTooltipAttributes(itemId : SItemUniqueId, attributes : array<name>, out itemStats : array<SAttributeTooltip>):void
	{
		var itemCategory:name;
		var i, j, settingsSize : int;
		var attributeString : string;
		var attributeColor : string;
		var attributeName : name;
		var isPercentageValue : string;
		var primaryStatLabel : string;
		var statLabel		 : string;
		
		var stat : SAttributeTooltip;
		var attributeVal : SAbilityAttributeValue;
		
		settingsSize = theGame.tooltipSettings.GetNumRows();
		itemStats.Clear();
		itemCategory = GetItemCategory(itemId);
		for(i=0; i<settingsSize; i+=1)
		{
			
			attributeString = theGame.tooltipSettings.GetValueAt(0,i);
			if(StrLen(attributeString) <= 0)
				continue;						
			
			attributeName = '';
			
			
			for(j=0; j<attributes.Size(); j+=1)
			{
				if(NameToString(attributes[j]) == attributeString)
				{
					attributeName = attributes[j];
					break;
				}
			}
			if(!IsNameValid(attributeName))
				continue;
			
			if(itemCategory == 'silversword' && attributeName == 'SlashingDamage') continue;
			if(itemCategory == 'steelsword' && attributeName == 'SilverDamage') continue;
			if(itemCategory == 'bolt' && ItemHasTag(itemId, 'Steel_Bolt' ) && attributeName == 'SilverDamage') continue; //W3EE
			
			attributeColor = theGame.tooltipSettings.GetValueAt(1,i);
			
			isPercentageValue = theGame.tooltipSettings.GetValueAt(2,i);	
			
			
			attributeVal = GetItemAttributeValue(itemId, attributeName);
			stat.attributeColor = attributeColor;
			stat.percentageValue = isPercentageValue;			
			stat.primaryStat = IsPrimaryStatById(itemId, attributeName, primaryStatLabel);
			stat.value = 0;
			stat.originName = attributeName;
			if(attributeVal.valueBase != 0)
			{
				statLabel = GetAttributeNameLocStr(attributeName, false);
				stat.value = attributeVal.valueBase;
				stat.attributeType = 'base';
			}
			if(attributeVal.valueMultiplicative != 0)
			{				
				
				
				statLabel = GetAttributeNameLocStr(attributeName, false);
				stat.value = attributeVal.valueMultiplicative;
				stat.attributeType = 'mult';
				stat.percentageValue = true;
			}
			if(attributeVal.valueAdditive != 0)
			{				
				statLabel = GetAttributeNameLocStr(attributeName, false);
				//Kolaris - Tooltip Fix
				if( attributeVal.valueBase != 0 )
					stat.value += attributeVal.valueAdditive;
				else
					stat.value = attributeVal.valueAdditive;
				stat.attributeType = 'add';
			}
			if (stat.value != 0)
			{
				stat.attributeName = statLabel;
				
				itemStats.PushBack(stat);
			}
		}
	}
	
	
	public function GetItemStatsFromName(itemName : name, out itemStats : array<SAttributeTooltip>)
	{
		var itemCategory : name;
		var i, j, settingsSize : int;
		var attributeString : string;
		var attributeColor : string;
		var attributeName : name;
		var isPercentageValue : string;
		var attributes, itemAbilities, tmpArray : array<name>;
		var weights : array<float>;
		var stat : SAttributeTooltip;
		var attributeVal, min, max : SAbilityAttributeValue;
		var dm	: CDefinitionsManagerAccessor;
		var primaryStatLabel : string;
		var statLabel		 : string;
		
		settingsSize = theGame.tooltipSettings.GetNumRows();
		dm = theGame.GetDefinitionsManager();
		dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, itemAbilities, weights, i, j);
		attributes = dm.GetAbilitiesAttributes(itemAbilities);
		
		itemStats.Clear();
		itemCategory = dm.GetItemCategory(itemName);
		for(i=0; i<settingsSize; i+=1)
		{
			
			attributeString = theGame.tooltipSettings.GetValueAt(0,i);
			if(StrLen(attributeString) <= 0)
				continue;						
			
			attributeName = '';
			
			
			for(j=0; j<attributes.Size(); j+=1)
			{
				if(NameToString(attributes[j]) == attributeString)
				{
					attributeName = attributes[j];
					break;
				}
			}
			if(!IsNameValid(attributeName))
				continue;
			
			
			if(itemCategory == 'silversword' && attributeName == 'SlashingDamage') continue;
			if(itemCategory == 'steelsword' && attributeName == 'SilverDamage') continue;
			
			
			attributeColor = theGame.tooltipSettings.GetValueAt(1,i);
			
			isPercentageValue = theGame.tooltipSettings.GetValueAt(2,i);
			
			
			dm.GetAbilitiesAttributeValue(itemAbilities, attributeName, min, max);
			attributeVal = GetAttributeRandomizedValue(min, max);
			
			stat.attributeColor = attributeColor;
			stat.percentageValue = isPercentageValue;
			
			stat.primaryStat = IsPrimaryStat(itemCategory, attributeName, primaryStatLabel);
			
			stat.value = 0;
			stat.originName = attributeName;
			
			if(attributeVal.valueBase != 0)
			{
				stat.value = attributeVal.valueBase;
			}
			if(attributeVal.valueMultiplicative != 0)
			{
				stat.value = attributeVal.valueMultiplicative;
				stat.percentageValue = true;
			}
			if(attributeVal.valueAdditive != 0)
			{				
				statLabel = GetAttributeNameLocStr(attributeName, false);
				stat.value = attributeVal.valueBase + attributeVal.valueAdditive;
			}
			
			if (attributeName == 'toxicity_offset')
			{
				statLabel = GetAttributeNameLocStr('toxicity', false);
				stat.percentageValue = false;
			}
			else
			{
				statLabel = GetAttributeNameLocStr(attributeName, false);
			}
			
			if (stat.value != 0)
			{
				stat.attributeName = statLabel;
				
				itemStats.PushBack(stat);
			}
			
			
		}
	}
	
	public function IsThereItemOnSlot(slot : EEquipmentSlots) : bool
	{
		var player : W3PlayerWitcher;
			
		player = ((W3PlayerWitcher)GetEntity());
		if(player)
		{		
			return player.IsAnyItemEquippedOnSlot(slot);
		}
		else
		{
			return false;
		}
	}
	
	public function GetItemEquippedOnSlot(slot : EEquipmentSlots, out item : SItemUniqueId) : bool
	{
		var player : W3PlayerWitcher;
			
		player = ((W3PlayerWitcher)GetEntity());
		if(player)
		{
			return player.GetItemEquippedOnSlot(slot, item);
		}
		else
		{
			return false;
		}
	}
	
	public function IsItemExcluded ( itemID : SItemUniqueId, excludedItems : array < SItemNameProperty > ) : bool
	{
		var i 				: int;
		var currItemName 	: name;
		
		currItemName = GetItemName( itemID );
		
		for ( i = 0; i < excludedItems.Size(); i+=1 )
		{
			if ( currItemName == excludedItems[i].itemName )
			{
				return true;
			}
		}
		return false;
	}
	
	public function GetItemPrimaryStat(itemId : SItemUniqueId, out attributeLabel : string, out attributeVal : float ) : void
	{
		var attributeName : name;
		var attributeValue:SAbilityAttributeValue;
		
		GetItemPrimaryStatImplById(itemId, attributeLabel, attributeVal, attributeName);
		
		attributeValue = GetItemAttributeValue(itemId, attributeName);
		
		if(attributeValue.valueBase != 0)
		{
			attributeVal = attributeValue.valueBase;
		}
		if(attributeValue.valueMultiplicative != 0)
		{
			attributeVal = attributeValue.valueMultiplicative;
		}
		if(attributeValue.valueAdditive != 0)
		{
			//Kolaris - Tooltip Fix
			attributeVal += attributeValue.valueAdditive;
		}
	}
	
	public function GetItemStatByName(itemName : name, statName : name, out resultValue : float) : void
	{
		var dm : CDefinitionsManagerAccessor;
		var attributes, itemAbilities : array<name>;
		var min, max, attributeValue : SAbilityAttributeValue;
		var tmpInt : int;
		var tmpArray : array<float>;
		
		dm = theGame.GetDefinitionsManager();
		dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, itemAbilities, tmpArray, tmpInt, tmpInt);
		attributes = dm.GetAbilitiesAttributes(itemAbilities);
		
		dm.GetAbilitiesAttributeValue(itemAbilities, statName, min, max);
		attributeValue = GetAttributeRandomizedValue(min, max);
		
		if(attributeValue.valueBase != 0)
		{
			resultValue = attributeValue.valueBase;
		}
		if(attributeValue.valueMultiplicative != 0)
		{								
			resultValue = attributeValue.valueMultiplicative;
		}
		if(attributeValue.valueAdditive != 0)
		{
			resultValue = attributeValue.valueAdditive;
		}
	}
	
	public function GetItemPrimaryStatFromName(itemName : name, out attributeLabel : string, out attributeVal : float, out primAttrName : name) : void
	{
		var item : array<SItemUniqueId>;
		var attributes, itemAbilities : array<name>;
		var attributeValue, min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
		var attributeName, itemCategory : name;
		var tmpInt, itemQuality, level, baseLevel : int;
		var itemAttributes : array<SAbilityAttributeValue>;
		var i, levelDiff : int;
		var tmpArray : array<float>;
		
		dm = theGame.GetDefinitionsManager();
		if( dm.ItemHasTag(itemName, 'crossbow') )
			return;
			
		itemQuality = dm.GetItemQuality(itemName);
		itemCategory = dm.GetItemCategory(itemName);
		GetItemPrimaryStatImpl(dm.GetItemCategory(itemName), attributeLabel, attributeVal, attributeName);
		dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, itemAbilities, tmpArray, tmpInt, tmpInt);
		attributes = dm.GetAbilitiesAttributes(itemAbilities);
		for (tmpInt = 0; tmpInt < attributes.Size(); tmpInt += 1)
		{
			if (attributes[tmpInt] == attributeName)
			{
				dm.GetAbilitiesAttributeValue(itemAbilities, attributeName, min, max);
				attributeValue = GetAttributeRandomizedValue(min, max);
				primAttrName = attributeName;
				break;
			}
		}
		
		if(attributeValue.valueBase != 0)
			attributeVal = attributeValue.valueBase;
		if(attributeValue.valueMultiplicative != 0)
			attributeVal = attributeValue.valueMultiplicative;
		if(attributeValue.valueAdditive != 0)
			attributeVal = attributeValue.valueAdditive;
			
		switch(itemCategory)
		{
			case 'armor' :
			case 'boots' :
			case 'gloves' :
			case 'pants' :
			case 'silversword' :
			case 'steelsword' :
				itemAttributes.PushBack((SAbilityAttributeValue)(0, 0, attributeVal));
			break;
			
			default :
				break;
		}
		level = theGame.params.GetItemLevel(itemCategory, itemAttributes, itemName, baseLevel);
		
		if ( itemQuality == 5 ) level = level - 2;
		if ( itemQuality == 4 ) level = level - 1;
		if ( dm.ItemHasTag(itemName, 'OlgierdSabre') ) level = level - 3;
		if ( (itemQuality == 4 || itemQuality == 5) && dm.ItemHasTag(itemName, 'EP1') ) level = level - 1;
		if ( level < 1 ) level = 1;
		
		if( dm.ItemHasTag(itemName, 'LightArmor') )
			levelDiff = 40;
		else
		if( dm.ItemHasTag(itemName, 'MediumArmor') )
			levelDiff = 60;
		else
			levelDiff = 90;
			
		if( dm.ItemHasTag(itemName, 'Wooden') )
			levelDiff = 40;
		else
		if( dm.ItemHasTag(itemName, 'DamagedWeapon') )
			levelDiff = 55;
		else
		if( dm.ItemHasTag(itemName, 'TypeBattleaxe') )
			levelDiff = 100;
		else
		if( dm.ItemHasTag(itemName, 'TypeBattlemace') )
			levelDiff = 95;
		else
		if( dm.ItemHasTag(itemName, 'SecondaryWeapon') )
			levelDiff = 78;
			
		if( itemName == 'Aerondight EP2' )
			levelDiff = 95;
			
		switch( itemQuality )
		{
			case 1: levelDiff -= 7; break;
			case 2: levelDiff -= 5; break;
			case 3: levelDiff -= 3; break;
		}
		
		levelDiff -= level;
		
		switch(itemCategory)
		{
			//Kolaris - Armor System
			/*case 'armor' :
				for(i=0; i<levelDiff; i+=1)
					attributeVal += 5;
			break;
			
			case 'boots' :
				for(i=0; i<levelDiff; i+=1)
					attributeVal += 2;
			break;
			
			case 'gloves' :
				for(i=0; i<levelDiff; i+=1)
					attributeVal += 2;
			break;
			
			case 'pants' :
				for(i=0; i<levelDiff; i+=1)
					attributeVal += 2;
			break;*/
			
			case 'silversword' :
				for(i=0; i<levelDiff; i+=1)
					attributeVal += 10;
			break;
			
			case 'steelsword' :
				for(i=0; i<levelDiff; i+=1)
					attributeVal += 8;
			break;
		}
	}
	
	public function IsPrimaryStatById(itemId : SItemUniqueId, attributeName : name, out attributeLabel : string) : bool
	{
		var attrValue : float;
		var attrName  : name;
		
		GetItemPrimaryStatImplById(itemId, attributeLabel, attrValue, attrName);
		return attrName == attributeName;
	}
	
	private function GetItemPrimaryStatImplById(itemId : SItemUniqueId, out attributeLabel : string, out attributeVal : float, out attributeName : name ) : void
	{
		var itemOnSlot   : SItemUniqueId;
		var categoryName : name;
		var abList   	 : array<name>;
		
		attributeName = '';
		attributeLabel = "";
		categoryName = GetItemCategory(itemId);
		
		
		if (categoryName == 'bolt' || categoryName == 'petard')
		{
			GetItemAttributes(itemId, abList);
			if (abList.Contains('FireDamage'))
			{
				attributeName = 'FireDamage';
			}
			else if (abList.Contains('PiercingDamage'))
			{
				attributeName = 'PiercingDamage';
			}
			else if (abList.Contains('PiercingDamage'))
			{
				attributeName = 'PiercingDamage';
			}
			else if (abList.Contains('PoisonDamage'))
			{
				attributeName = 'PoisonDamage';
			}
			else if (abList.Contains('BludgeoningDamage'))
			{
				attributeName = 'BludgeoningDamage';
			}
			else			
			{
				attributeName = 'PhysicalDamage';
			}
			attributeLabel = GetAttributeNameLocStr(attributeName, false);
		}
		else if (categoryName == 'secondary')
		{
			GetItemAttributes(itemId, abList);
			if (abList.Contains('BludgeoningDamage'))
			{
				attributeName = 'BludgeoningDamage';
			}
			else
			{
				attributeName = 'PhysicalDamage';
			}
			attributeLabel = GetAttributeNameLocStr(attributeName, false);
		}
		else if (categoryName == 'steelsword')
		{
			GetItemAttributes(itemId, abList);
			if (abList.Contains('SlashingDamage'))
			{
				attributeName = 'SlashingDamage';
				attributeLabel = GetLocStringByKeyExt("panel_inventory_tooltip_damage");
			}
			else if (abList.Contains('BludgeoningDamage'))
			{
				attributeName = 'BludgeoningDamage';
			}
			else if (abList.Contains('PiercingDamage'))
			{
				attributeName = 'PiercingDamage';
			}
			else
			{
				attributeName = 'PhysicalDamage';
			}
			if (attributeLabel == "")
			{
				attributeLabel = GetAttributeNameLocStr(attributeName, false);
			}
		}
		else
		{
			GetItemPrimaryStatImpl(categoryName, attributeLabel, attributeVal, attributeName);
		}
	}
	
	public function IsPrimaryStat(categoryName : name, attributeName : name, out attributeLabel : string) : bool
	{
		var attrValue : float;
		var attrName  : name;
		
		GetItemPrimaryStatImpl(categoryName, attributeLabel, attrValue, attrName);
		return attrName == attributeName;
	}
	
	private function GetItemPrimaryStatImpl(categoryName : name,  out attributeLabel : string, out attributeVal : float, out attributeName : name ) : void
	{
		attributeName = '';
		attributeLabel = "";
		switch (categoryName)
		{
			case 'steelsword':
				attributeName = 'SlashingDamage';
				attributeLabel = GetLocStringByKeyExt("panel_inventory_tooltip_damage");
				break;
			case 'silversword':
				attributeName = 'SilverDamage';
				attributeLabel = GetLocStringByKeyExt("panel_inventory_tooltip_damage");
				break;
			case 'armor':
			case 'gloves':
			case 'gloves':
			case 'boots':
			case 'pants':
				attributeName = 'armor';
				break;
			case 'potion':
			case 'oil':
				
				break;
			case 'bolt':
			case 'petard':
				attributeName = 'PhysicalDamage';
				break;
			case 'crossbow':
			default:
				attributeLabel = "";
				attributeVal = 0;
				return;
				break;
		}
		
		if (attributeLabel == "")
		{
			attributeLabel = GetAttributeNameLocStr(attributeName, false);
		}
	}
	
	public function CanBeCompared(itemId : SItemUniqueId) : bool
	{
		var wplayer		     	: W3PlayerWitcher;
		var itemSlot     		: EEquipmentSlots;
		var equipedItem 		: SItemUniqueId;
		var horseManager		: W3HorseManager;
		
		var isArmorOrWeapon : bool;
		
		if (IsItemHorseItem(itemId))
		{
			horseManager = GetWitcherPlayer().GetHorseManager();
			
			if (!horseManager)
			{
				return false;
			}
			
			if (horseManager.IsItemEquipped(itemId))
			{
				return false;
			}
			
			itemSlot = GetHorseSlotForItem(itemId);
			equipedItem = horseManager.GetItemInSlot(itemSlot);
			if (!horseManager.GetInventoryComponent().IsIdValid(equipedItem))
			{
				return false;
			}
		}
		else
		{
			isArmorOrWeapon = IsItemAnyArmor(itemId) || IsItemWeapon(itemId);
			if (!isArmorOrWeapon)
			{
				return false;
			}
			
			wplayer = GetWitcherPlayer();
			if (wplayer.IsItemEquipped(itemId))
			{
				return false;
			}
			
			itemSlot = GetSlotForItemId(itemId);		
			wplayer.GetItemEquippedOnSlot(itemSlot, equipedItem);
			if (!wplayer.inv.IsIdValid(equipedItem))
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function GetHorseSlotForItem(id : SItemUniqueId) : EEquipmentSlots
	{
		var tags : array<name>;
		
		GetItemTags(id, tags);
		
		if(tags.Contains('Saddle'))				return EES_HorseSaddle;
		else if(tags.Contains('HorseBag'))		return EES_HorseBag;
		else if(tags.Contains('Trophy'))		return EES_HorseTrophy;
		else if(tags.Contains('Blinders'))		return EES_HorseBlinders;
		else									return EES_InvalidSlot;
	}
	
	public final function SingletonItemRefillAmmo( id : SItemUniqueId, optional alchemyTableUsed : bool )
	{
		// W3EE - Begin
		/*
		var l_bed		: W3WitcherBed;
		var refilledByBed : bool;
		
		refilledByBed = false;
		
		
		if( FactsQuerySum( "PlayerInsideOuterWitcherHouse" ) >= 1 && FactsQuerySum( "AlchemyTableExists" ) >= 1 && !IsItemMutagenPotion( id ) )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			
			if( l_bed.GetWasUsed() || alchemyTableUsed )
			{
				SetItemModifierInt( id, 'ammo_current', SingletonItemGetMaxAmmo(id) + theGame.params.QUANTITY_INCREASED_BY_ALCHEMY_TABLE ) ;
				refilledByBed = true;
				if( !l_bed.GetWereItemsRefilled() )
				{
					l_bed.SetWereItemsRefilled( true );
				}
			}			
		}
		
		
		if( !refilledByBed && SingletonItemGetAmmo( id ) < SingletonItemGetMaxAmmo( id ) )
		{
			SetItemModifierInt(id, 'ammo_current', SingletonItemGetMaxAmmo(id));
		}
		
		SetItemModifierInt(id, 'ammo_current', SingletonItemGetMaxAmmo(id));
		
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnAmmoChanged );
		*/
		// W3EE - End
	}
	
	public function SingletonItemSetAmmo(id : SItemUniqueId, quantity : int)
	{
		// W3EE - Begin
		
		var amount : int;
		/*
		if(ItemHasTag(id, theGame.params.TAG_INFINITE_AMMO))
		{
			amount = -1;
		}
		else
		{
			amount = Clamp(quantity, 0, SingletonItemGetMaxAmmo(id));
		}
		
		SetItemModifierInt(id, 'ammo_current', amount);
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnAmmoChanged );
		*/
		
		SetItemModifierInt(id, 'ammo_current', Max(SingletonItemGetAmmo(id), 0));
		SingletonItemAddAmmo(id, quantity);
		// W3EE - End
	}
	
	public function SingletonItemAddAmmo(id : SItemUniqueId, quantity : int)
	{
		var ammo : int;
		
		if(quantity <= 0)
			return;
			
		ammo = GetItemModifierInt(id, 'ammo_current');
		
		if(ammo == -1)
			return;	
			
		// W3EE - Begin
		//ammo = Clamp(ammo + quantity, 0, SingletonItemGetMaxAmmo(id));
		ammo += quantity;
		// W3EE - End
		SetItemModifierInt(id, 'ammo_current', ammo);
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnAmmoChanged );
	}
	
	public function SingletonItemsRefillAmmo( optional alchemyTableUsed : bool ) : bool
	{
		var i : int;
		var singletonItems : array<SItemUniqueId>;
		var alco : SItemUniqueId;
		var arrStr : array<string>;
		var witcher : W3PlayerWitcher;
		var itemLabel : string;
	
		witcher = GetWitcherPlayer();
		if(GetEntity() == witcher && HasNotFilledSingletonItem( alchemyTableUsed ) )
		{
			alco = witcher.GetAlcoholForAlchemicalItemsRefill();
		
			if(!IsIdValid(alco))
			{
				
				theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("message_common_alchemy_items_cannot_refill"));
				theSound.SoundEvent("gui_global_denied");
				
				return false;
			}
			else
			{
				
				arrStr.PushBack(GetItemName(alco));
				itemLabel = GetItemLocNameByID(alco);
				theGame.GetGuiManager().ShowNotification( itemLabel + " - " + GetLocStringByKeyExtWithParams("message_common_alchemy_items_refilled", , , arrStr));
				theSound.SoundEvent("gui_alchemy_brew");
				
				if(!ItemHasTag(alco, theGame.params.TAG_INFINITE_USE))
					RemoveItem(alco);
			}
		}
		
		singletonItems = GetSingletonItems();
		for(i=0; i<singletonItems.Size(); i+=1)
		{			
			SingletonItemRefillAmmo( singletonItems[i], alchemyTableUsed );
		}
		
		return true;
	}
	
	public function SingletonItemsRefillAmmoNoAlco(optional dontUpdateUI : bool)
	{
		var i : int;
		var singletonItems : array<SItemUniqueId>;
		var alco : SItemUniqueId;
		var arrStr : array<string>;
		var witcher : W3PlayerWitcher;
		var itemLabel : string;
	
		witcher = GetWitcherPlayer();
		if(!dontUpdateUI && GetEntity() == witcher && HasNotFilledSingletonItem())
		{
			
			arrStr.PushBack(GetItemName(alco));
			itemLabel = GetItemLocNameByID(alco);
			theGame.GetGuiManager().ShowNotification( itemLabel + " - " + GetLocStringByKeyExtWithParams("message_common_alchemy_items_refilled", , , arrStr));
			theSound.SoundEvent("gui_alchemy_brew");
		}
		
		singletonItems = GetSingletonItems();
		for(i=0; i<singletonItems.Size(); i+=1)
		{			
			SingletonItemRefillAmmo(singletonItems[i]);
		}
	}	
	
	
	private final function HasNotFilledSingletonItem( optional alchemyTableUsed : bool ) : bool
	{
		var i : int;
		var singletonItems : array<SItemUniqueId>;
		var hasLab : bool;
		var l_bed : W3WitcherBed;
		
		
		hasLab = false;
		if( FactsQuerySum( "PlayerInsideOuterWitcherHouse" ) >= 1 && FactsQuerySum( "AlchemyTableExists" ) >= 1 )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );			
			if( l_bed.GetWasUsed() || alchemyTableUsed )
			{
				hasLab = true;
			}
		}
		
		singletonItems = GetSingletonItems();
		for(i=0; i<singletonItems.Size(); i+=1)
		{			
			if( hasLab && !IsItemMutagenPotion( singletonItems[i] ) )
			{
				if(SingletonItemGetAmmo(singletonItems[i]) <= SingletonItemGetMaxAmmo(singletonItems[i]))
				{
					return true;
				}
			}
			else if(SingletonItemGetAmmo(singletonItems[i]) < SingletonItemGetMaxAmmo(singletonItems[i]))
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function SingletonItemRemoveAmmo(itemID : SItemUniqueId, optional quantity : int)
	{
		var ammo : int;
		
		if(!IsItemSingletonItem(itemID) || ItemHasTag(itemID, theGame.params.TAG_INFINITE_AMMO))
			return;
		
		if(quantity <= 0)
			quantity = 1;
			
		ammo = GetItemModifierInt(itemID, 'ammo_current');
		ammo = Max(0, ammo - quantity);
		SetItemModifierInt(itemID, 'ammo_current', ammo);
		
		
		if(ammo == 0 && ShouldProcessTutorial('TutorialAlchemyRefill') && FactsQuerySum("q001_nightmare_ended") > 0)
		{
			FactsAdd('tut_alch_refill', 1);
		}
		
		if( ammo <= 0 && IsItemPotion(itemID) )
		{
			if( GetWitcherPlayer().GetItemSlot(itemID) != EES_InvalidSlot )
				GetWitcherPlayer().UnequipItem(itemID);
			RemoveItem(itemID, 1);
		}
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnAmmoChanged );
	}
	
	public function SingletonItemGetAmmo(itemID : SItemUniqueId) : int
	{
		if(!IsItemSingletonItem(itemID))
			return 0;
		
		return GetItemModifierInt(itemID, 'ammo_current');
	}
	
	public function SingletonItemGetMaxAmmo(itemID : SItemUniqueId) : int
	{
		var ammo, i : int;
		
		return ammo;
	}
	
	public function ManageSingletonItemsBonus()
	{
		var l_items			: array<SItemUniqueId>;
		var l_i				: int;
		var l_haveBombOrPot	: bool;
		
		l_items = GetSingletonItems();

		for( l_i = 0 ; l_i < l_items.Size() ; l_i += 1 )
		{
			if( IsItemPotion( l_items[ l_i ] ) || IsItemBomb( l_items[ l_i ] ) )
			{
				l_haveBombOrPot = true;
				if( SingletonItemGetMaxAmmo( l_items[ l_i ] ) >= SingletonItemGetAmmo( l_items[ l_i ] ) )
				{
					if( SingletonItemsRefillAmmo( true ) )
					{
						theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_applied" ),, true );
					}
					
					return;
				}
			}
		}
		
		if( !l_haveBombOrPot )
		{
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_no_items" ),, true );
			return;
		}
		
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_already_on" ),, true );
	}
	
	
	
	
	
	public final function IsItemSteelSwordUsableByPlayer(item : SItemUniqueId) : bool
	{
		return ItemHasTag(item, theGame.params.TAG_PLAYER_STEELSWORD) && !ItemHasTag(item, 'SecondaryWeapon');
	}
	
	public final function IsItemSilverSwordUsableByPlayer(item : SItemUniqueId) : bool
	{
		return ItemHasTag(item, theGame.params.TAG_PLAYER_SILVERSWORD) && !ItemHasTag(item, 'SecondaryWeapon');
	}

	public final function IsItemFists(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'fist';}
	public final function IsItemWeapon(item : SItemUniqueId) : bool							{return ItemHasTag(item, 'Weapon') || ItemHasTag(item, 'WeaponTab');}
	public final function IsItemCrossbow(item : SItemUniqueId) : bool						{return GetItemCategory(item) == 'crossbow';}
	public final function IsItemChestArmor(item : SItemUniqueId) : bool						{return GetItemCategory(item) == 'armor';}
	public final function IsItemBody(item : SItemUniqueId) : bool							{return ItemHasTag(item, 'Body');}
	public final function IsRecipeOrSchematic( item : SItemUniqueId ) : bool				{return GetItemCategory(item) == 'alchemy_recipe' || GetItemCategory(item) == 'crafting_schematic'; } 
	public final function IsItemBoots(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'boots';}
	public final function IsItemGloves(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'gloves';}
	public final function IsItemPants(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'trousers' || GetItemCategory(item) == 'pants';}
	public final function IsItemTrophy(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'trophy';}
	public final function IsItemMask(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'mask';}
	public final function IsItemBomb(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'petard';}
	public final function IsItemBolt(item : SItemUniqueId) : bool							{return GetItemCategory(item) == 'bolt';}
	public final function IsItemUpgrade(item : SItemUniqueId) : bool						{return GetItemCategory(item) ==  'upgrade';}
	public final function IsItemTool(item : SItemUniqueId) : bool							{return GetItemCategory(item) ==  'tool';}
	// W3EE - Begin
	public final function IsItemPotion(item : SItemUniqueId) : bool							{return ItemHasTag(item, 'Potion') && !IsItemFood(item);}
	public final function IsItemJewelry(item : SItemUniqueId) : bool						{return ItemHasTag(item, 'jewelry');}
	public final function IsItemAlchemicalAlcohol( item : SItemUniqueId ) : bool			{return ItemHasTag(item, 'StrongAlcohol');}
	public final function IsItemHerb( item : SItemUniqueId ) : bool							{return ItemHasTag(item, 'primer_herb');}
	public final function IsItemMonsterPart( item : SItemUniqueId ) : bool					{return ItemHasTag(item, 'primer_monstrous');}
	public final function IsItemMineral( item : SItemUniqueId ) : bool						{return ItemHasTag(item, 'primer_mineral');}
	public final function IsItemMoney( item : SItemUniqueId ) : bool						{return ItemHasTag(item, 'crowns') || ItemHasTag(item, 'florens') || ItemHasTag(item, 'orens');}
	public final function IsItemUniqueMutagen( item : SItemUniqueId ) : bool				{return ItemHasTag(item, 'MutagenIngredient') && !ItemHasTag(item, 'InertMutagen');}
	public final function IsItemInertMutagen( item : SItemUniqueId ) : bool					{return ItemHasTag(item, 'InertMutagen');}
	// W3EE - End
	public final function IsItemOil(item : SItemUniqueId) : bool							{return ItemHasTag(item, 'SilverOil') || ItemHasTag(item, 'SteelOil');}
	public final function IsItemAnyArmor(item : SItemUniqueId) : bool						{return ItemHasTag(item, theGame.params.TAG_ARMOR);}
	public final function IsItemUpgradeable(item : SItemUniqueId) : bool					{return ItemHasTag(item, theGame.params.TAG_ITEM_UPGRADEABLE);}
	public final function IsItemIngredient(item : SItemUniqueId) : bool						{return ItemHasTag(item, 'AlchemyIngredient') || ItemHasTag(item, 'CraftingIngredient');}
	public final function IsItemDismantleKit(item : SItemUniqueId) : bool					{return ItemHasTag(item, 'DismantleKit');}
	public final function IsItemHorseBag(item : SItemUniqueId) : bool						{return ItemHasTag(item, 'HorseBag');}	
	public final function IsItemReadable(item : SItemUniqueId) : bool						{return ItemHasTag(item, 'ReadableItem');}
	public final function IsItemAlchemyItem(item : SItemUniqueId) : bool					{return IsItemOil(item) || IsItemPotion(item) || IsItemBomb(item);  }	
	public final function IsItemSingletonItem(item : SItemUniqueId) : bool 					{return ItemHasTag(item, theGame.params.TAG_ITEM_SINGLETON);}
	public final function IsItemQuest(item : SItemUniqueId) : bool							{return ItemHasTag(item, 'Quest');}
	public final function IsItemFood(item : SItemUniqueId) : bool							{return ItemHasTag(item, 'Edibles') || ItemHasTag(item, 'Drinks');}
	public final function IsItemSecondaryWeapon(item : SItemUniqueId) : bool				{return ItemHasTag(item, 'SecondaryWeapon');}
	public final function IsItemHorseItem(item: SItemUniqueId) : bool						{return ItemHasTag(item, 'Saddle') || ItemHasTag(item, 'HorseBag') || ItemHasTag(item, 'Trophy') || ItemHasTag(item, 'Blinders'); }
	public final function IsItemSaddle(item: SItemUniqueId) : bool							{return ItemHasTag(item, 'Saddle');}
	public final function IsItemBlinders(item: SItemUniqueId) : bool						{return ItemHasTag(item, 'Blinders');}
	public final function IsItemDye( item : SItemUniqueId ) : bool							{ return ItemHasTag( item, 'mod_dye' ); }
	public final function IsItemUsable( item : SItemUniqueId ) : bool 						{ return GetItemCategory( item ) == 'usable'; }
	public final function IsItemJunk( item : SItemUniqueId ) : bool							{ return ItemHasTag( item,'junk' ) || GetItemCategory( item ) == 'junk' ; }
	public final function IsItemAlchemyIngredient(item : SItemUniqueId) : bool				{ return ItemHasTag( item, 'AlchemyIngredient' ); }
	public final function IsItemCraftingIngredient(item : SItemUniqueId) : bool				{ return ItemHasTag( item, 'CraftingIngredient' ); }
	public final function IsItemArmorReapairKit(item : SItemUniqueId) : bool				{ return ItemHasTag( item, 'ArmorReapairKit' ); }
	public final function IsItemWeaponReapairKit(item : SItemUniqueId) : bool				{ return ItemHasTag( item, 'WeaponReapairKit' ); }
	public final function IsQuickSlotItem( item : SItemUniqueId ) : bool 					{ return ItemHasTag( item, 'QuickSlot' ); }
	
	public function ShouldHorseLootItem( item : SItemUniqueId ) : bool
	{
		return Options().HorseDestination() != 0 && (IsItemJunk(item) || IsItemAlchemyIngredient(item) || IsItemCraftingIngredient(item) || IsItemWeapon(item) || IsItemUpgrade(item) || IsItemMoney(item) || IsItemChestArmor(item) || IsItemBoots(item) || IsItemPants(item) || IsItemGloves(item)) && !ItemHasTag(item, 'Artifact_weapon') && !ItemHasTag(item, 'ThrowingKnife') && !ItemHasTag(item, 'FancyClothes') && !IsItemUniqueMutagen(item) && !IsItemQuest(item);
	}
	
	public final function IsItemNew( item : SItemUniqueId ) : bool
	{
		var uiData : SInventoryItemUIData;
		
		uiData = GetInventoryItemUIData( item );
		return uiData.isNew;
	}
	
	public final function IsItemMutagenPotion(item : SItemUniqueId) : bool
	{
		return IsItemPotion(item) && ItemHasTag(item, 'Decoction');
	}
	
	public final function CanItemBeColored( item : SItemUniqueId) : bool
	{
		if ( RoundMath( CalculateAttributeValue( GetItemAttributeValue( item, 'quality' ) ) ) == 5 && !ItemHasTag(item, 'noDye') ) 
		{
			return true;
		}
		return false;	
	}

	public final function IsItemGrandmasterItem( item : SItemUniqueId ) : bool
	{
		return ItemHasTag(item, theGame.params.ITEM_SET_TAG_BONUS);
	}

	//Kolaris - Armor Set Bonus Setup
	public final function IsItemSetItem(item : SItemUniqueId) : bool
	{
		return
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_BEAR) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_GRYPHON) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_LYNX) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_WOLF) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_RED_WOLF) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_VAMPIRE) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_VAMPIRE_ALT) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_TEMERIAN) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_NILFGAARD) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_SKELLIGE) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_OFIERI) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_NEW_MOON) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_VIPER) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_GOTHIC) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_DIMERITIUM) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_METEORITE) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_NETFLIX) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_ELVEN) ||
			ItemHasTag(item, theGame.params.ITEM_SET_TAG_TIGER);
	}
	
	public final function DetectTagOfASet(item : SItemUniqueId) : name
	{
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_BEAR) )
			return theGame.params.ITEM_SET_TAG_BEAR;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_GRYPHON) )
			return theGame.params.ITEM_SET_TAG_GRYPHON;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_LYNX) )
			return theGame.params.ITEM_SET_TAG_LYNX;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_WOLF) )
			return theGame.params.ITEM_SET_TAG_WOLF;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_RED_WOLF) )
			return theGame.params.ITEM_SET_TAG_RED_WOLF;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_VAMPIRE) )
			return theGame.params.ITEM_SET_TAG_VAMPIRE;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_VIPER) )
			return theGame.params.ITEM_SET_TAG_VIPER;
		if (ItemHasTag(item, theGame.params.ITEM_SET_TAG_NETFLIX) )
			return theGame.params.ITEM_SET_TAG_NETFLIX;
			
		return '';
	}
	
	// W3EE - Begin
	public function GetArmorType(item : SItemUniqueId) : EArmorType
	{
		var isItemEquipped : bool;
		
		isItemEquipped = GetWitcherPlayer().IsItemEquipped(item);
		
		//Kolaris - Remove Old Enchantments
		/*if( thePlayer.HasAbility('Glyphword 9 _Stats', true) && isItemEquipped )
		{
			if (ItemHasTag(item, 'HeavyArmor'))	return EAT_Medium;
			if (ItemHasTag(item, 'MediumArmor')) return EAT_Light;
		}
		
		if( thePlayer.HasAbility('Glyphword 2 _Stats', true) && isItemEquipped )
		{return EAT_Light;}
		if( thePlayer.HasAbility('Glyphword 3 _Stats', true) && isItemEquipped )
		{return EAT_Medium;}
		if( thePlayer.HasAbility('Glyphword 4 _Stats', true) && isItemEquipped )
		{return EAT_Heavy;}*/
	
		if(ItemHasTag(item, 'LightArmor'))
			return EAT_Light;
		else if(ItemHasTag(item, 'MediumArmor'))
			return EAT_Medium;
		else if(ItemHasTag(item, 'HeavyArmor'))
			return EAT_Heavy;
		
		return EAT_Undefined;
	}
	
	public function GetArmorTypeOriginal( item : SItemUniqueId ) : EArmorType
	{
		var isItemEquipped : bool;
		
		if(ItemHasTag(item, 'LightArmor'))
			return EAT_Light;
		else if(ItemHasTag(item, 'MediumArmor'))
			return EAT_Medium;
		else if(ItemHasTag(item, 'HeavyArmor'))
			return EAT_Heavy;
		
		return EAT_Undefined;
	}
	// W3EE - End
	
	public final function GetAlchemyCraftableItems() : array<SItemUniqueId>
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		GetAllItems(items);
		
		for(i=items.Size()-1; i>=0; i-=1)
		{
			if(!IsItemPotion(items[i]) && !IsItemBomb(items[i]) && !IsItemOil(items[i]))
				items.EraseFast(i);
		}
		
		return items;
	}
	
	public function IsItemEncumbranceItem(item : SItemUniqueId) : bool
	{
		// W3EE - Begin
		if( GetItemName(item) == 'Crowns' )
			return true;
		// W3EE - End
		
		if(ItemHasTag(item, theGame.params.TAG_ENCUMBRANCE_ITEM_FORCE_YES))
			return true;
			
		if(ItemHasTag(item, theGame.params.TAG_ENCUMBRANCE_ITEM_FORCE_NO))
			return false;
		
		//Kolaris - Fixed Stashes
		if (IsRecipeOrSchematic( item ) || IsItemBody( item ) || ItemHasTag( item, 'NoShow' ))
			return false;
		
		return true;
	}
	
	public function GetItemEncumbrance(item : SItemUniqueId, optional quantity : int) : float
	{
		var itemCategory : name;
		var weight : float;
		var armorEquipped : SItemUniqueId;
		
		if( !quantity )
		{
			if( !IsItemSingletonItem(item) )
				quantity = GetItemQuantity(item);
			else
				quantity = SingletonItemGetAmmo(item);
		}
		//Kolaris - Armor Encumbrance
		if ( IsItemEncumbranceItem( item ) )
		{
			weight = GetItemWeight( item );
			itemCategory = GetItemCategory( item );
			
			if ( GetItemName( item ) == 'Crowns' || GetItemName( item ) == 'Florens' || GetItemName( item ) == 'Orens' )
			{
				if( Options().WeightMoney() )
					return 0.01 * quantity;
				else
					return 0;
			}
			else if ( IsItemWeapon( item ) )
			{
				return weight * quantity;
			}
			else if ( itemCategory == 'armor' )
			{
				if( GetItemEquippedOnSlot( EES_Armor, armorEquipped ) && item == armorEquipped )

					return weight * 0.5;

				else
					return weight;
			}
			else if ( itemCategory == 'boots' )
			{
				if( GetItemEquippedOnSlot( EES_Boots, armorEquipped ) && item == armorEquipped )

					return weight * 0.5;

				else
					return weight;
			}
			else if ( itemCategory == 'gloves' )
			{
				if( GetItemEquippedOnSlot( EES_Gloves, armorEquipped ) && item == armorEquipped )

					return weight * 0.5;

				else
					return weight;
			}
			else if ( itemCategory == 'pants' )
			{
				if( GetItemEquippedOnSlot( EES_Pants, armorEquipped ) && item == armorEquipped )

					return weight * 0.5;

				else
					return weight;
			}
			else if ( IsItemQuest( item ) )
			{
				if( Options().WeightQuest() )
				{
					if ( GetItemName( item ) == 'Geralt robbery mask' )
					{
						return 0;
					}
					else if( weight > 0.1 )
					{
						return weight * quantity;
					}
					else
					{
						return 0.1 * quantity;
					}
				}
				else return 0;
			}	
			else if ( IsItemCraftingIngredient( item ) )
			{
				if( Options().WeightCrafting() )
				{
					if( weight > 0.1 )
					{
						return weight * quantity;
					}
					else
					{
						return 0.1 * quantity;
					}
				}
				else return 0;
			}
			else if ( IsItemAlchemyIngredient( item ) )
			{
				if( Options().WeightAlch() )
				{
					//Kolaris - Primary Essence Weight
					if( ItemHasTag(item, 'primer_primary') || ItemHasTag(item, 'MutagenIngredient') )
					{
						return 0.01 * quantity;
					}
					else 
					if( weight > 0.1 )
					{
						return weight * quantity;
					}
					else
					{
						return 0.1 * quantity;
					}
				}
				else
				{
					return 0;
				}
			}
			else if ( IsItemSingletonItem( item ) && IsItemAlchemyItem( item ) )
			{
				if ( IsItemOil( item ) || IsItemPotion( item ) )
				{
					return 0.3 * quantity;
				}
				else
				if( ItemHasTag(item, 'ThrowingKnife') )
				{
					return GetItemWeight(item) * quantity;
				}
				else if ( IsItemBomb( item ) )
				{
					//Kolaris - Delayed Charge, Kolaris - Cluster Bombs
					return quantity * (1.f + 0.1f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s10) + 0.1f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s11));
				}
			}
			else 
			{
				if( Options().WeightMisc() )
				{
					if( weight > 0.1 )
					{
						return weight * quantity;
					}
					else
					{
						return 0.1 * quantity;
					}
				}
				else
				{
					return 0;
				}
			}
		}
		
		return 0;
	}
	
	private function GetCurrentWeight() : float
	{
		var i: int;
		var currWeight : float;
		var items : array<SItemUniqueId>;
		
		GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
			if( !(IsItemHorseItem(items[i]) && GetWitcherPlayer().GetHorseManager().IsItemEquipped(items[i])) && IsItemEncumbranceItem(items[i]) ) //Kolaris - Trophy Weight Fix
				currWeight += GetItemEncumbrance( items[i] );
				
		return currWeight;
	}
	
	public function HorseCanTakeItem( item : SItemUniqueId, quantity : int, otherInventory : CInventoryComponent ) : bool
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var curWeight, maxWeight : int;
		
		if( this != witcher.GetHorseManager().GetInventoryComponent() )
			return false;
			
		maxWeight = (int)CalculateAttributeValue(witcher.GetHorseManager().GetHorseAttributeValue('encumbrance', false)) + Options().BaseCWRoach();
		curWeight = (int)GetCurrentWeight();
		//Kolaris - Fixed Stashes
		if( otherInventory.GetItemEncumbrance(item, quantity) + curWeight <= maxWeight || GameplayFactsQuerySum("inFixedStash") > 0 )
			return true;
			
		return false;
	}
	
	public function GetFilterTypeByItem( item : SItemUniqueId ) : EInventoryFilterType
	{
		var filterType : EInventoryFilterType;
		
		if( ItemHasTag( item, 'Quest' ) )
		{
			return IFT_QuestItems;
		}				
		else if( IsItemIngredient( item ) )
		{
			return IFT_Ingredients;
		}				
		else if( IsItemAlchemyItem(item) ) 
		{
			return IFT_AlchemyItems;
		}				
		else if( IsItemAnyArmor(item) )
		{
			return IFT_Armors;
		}				
		else if( IsItemWeapon( item ) )
		{
			return IFT_Weapons;
		}				
		else
		{
			return IFT_Default;
		}
	}	
	
	
	public function IsItemQuickslotItem(item : SItemUniqueId) : bool
	{
		return IsSlotQuickslot( GetSlotForItemId(item) );
	}
	
	public function GetCrossbowAmmo(id : SItemUniqueId) : int
	{
		if(!IsItemCrossbow(id))
			return -1;
			
		return (int)CalculateAttributeValue(GetItemAttributeValue(id, 'ammo'));
	}
		
	
	
	public function GetSlotForItemId(item : SItemUniqueId) : EEquipmentSlots
	{
		var tags : array<name>;
		var player : W3PlayerWitcher;
		var slot : EEquipmentSlots;
		
		player = ((W3PlayerWitcher)GetEntity());
		
		GetItemTags(item, tags);
		slot = GetSlotForItem( GetItemCategory(item), tags, player );
		
		if(!player)
			return slot;
		
		//Kolaris - NextGen (Disabled), Kolaris - Mask Slot
		/*if(IsItemMask( item ))
			slot = EES_Quickslot2;
			
		if(slot == EES_Petard2)
			slot == EES_Petard1;*/
		
		if(IsMultipleSlot(slot))
		{
			if(slot == EES_Petard1 && player.IsAnyItemEquippedOnSlot(slot))
			{
				if(!player.IsAnyItemEquippedOnSlot(EES_Petard2))
					slot = EES_Petard2;
				// -= WMK:modQuickSlots =-
				else if (!player.IsAnyItemEquippedOnSlot(EES_Petard3)) {
					slot = EES_Petard3;
				} else if (!player.IsAnyItemEquippedOnSlot(EES_Petard4)) {
					slot = EES_Petard4;
				}
				// -= WMK:modQuickSlots =-
			}
			else if(slot == EES_Quickslot1 && player.IsAnyItemEquippedOnSlot(slot))
			{
				if(!player.IsAnyItemEquippedOnSlot(EES_Quickslot2))
					slot = EES_Quickslot2;
			}
			else if(slot == EES_Potion1 && player.IsAnyItemEquippedOnSlot(EES_Potion1))
			{
				if(!player.IsAnyItemEquippedOnSlot(EES_Potion2))
				{
					slot = EES_Potion2;
				}
				else
				{
					if(!player.IsAnyItemEquippedOnSlot(EES_Potion3))
					{
						slot = EES_Potion3;
					}
					else
					{
						if(!player.IsAnyItemEquippedOnSlot(EES_Potion4))
						{
							slot = EES_Potion4;
						// -= WMK:modQuickSlots =-
						} else if (!player.IsAnyItemEquippedOnSlot(EES_Potion5)) {
							slot = EES_Potion5;
						} else if (!player.IsAnyItemEquippedOnSlot(EES_Potion6)) {
							slot = EES_Potion6;
						} else if (!player.IsAnyItemEquippedOnSlot(EES_Potion7)) {
							slot = EES_Potion7;
						} else if (!player.IsAnyItemEquippedOnSlot(EES_Potion8)) {
							slot = EES_Potion8;
						}
						// -= WMK:modQuickSlots =-
					}
				}
			}
			else if(slot == EES_PotionMutagen1 && player.IsAnyItemEquippedOnSlot(slot))
			{
				if(!player.IsAnyItemEquippedOnSlot(EES_PotionMutagen2))
				{
					slot = EES_PotionMutagen2;
				}
				else
				{
					if(!player.IsAnyItemEquippedOnSlot(EES_PotionMutagen3))
					{
						slot = EES_PotionMutagen3;
					}
					else
					{
						if(!player.IsAnyItemEquippedOnSlot(EES_PotionMutagen4))
						{
							slot = EES_PotionMutagen4;
						}
					}
				}
			}
			else if(slot == EES_SkillMutagen1 && player.IsAnyItemEquippedOnSlot(slot))
			{
				if(!player.IsAnyItemEquippedOnSlot(EES_SkillMutagen2))
				{
					slot = EES_SkillMutagen2;
				}
				else
				{
					if(!player.IsAnyItemEquippedOnSlot(EES_SkillMutagen3))
					{
						slot = EES_SkillMutagen3;
					}
					else
					{
						if(!player.IsAnyItemEquippedOnSlot(EES_SkillMutagen4))
						{
							slot = EES_SkillMutagen4;
						}
					}
				}
			}
		}
		
		return slot;
	}
	
	
	
	public function GetAllWeapons() : array<SItemUniqueId>
	{
		return GetItemsByTag('Weapon');	
	}
	
	
	public function GetSpecifiedPlayerItemsQuest(steelSword, silverSword, armor, boots, gloves, pants, trophy, mask, bombs, crossbow, secondaryWeapon, equippedOnly : bool) : array<SItemUniqueId>
	{	
		var items, allItems : array<SItemUniqueId>;
		var i : int;
	
		GetAllItems(allItems);
		
		for(i=0; i<allItems.Size(); i+=1)
		{
			if(
				(steelSword && IsItemSteelSwordUsableByPlayer(allItems[i])) ||
				(silverSword && IsItemSilverSwordUsableByPlayer(allItems[i])) ||
				(armor && IsItemChestArmor(allItems[i])) ||
				(boots && IsItemBoots(allItems[i])) ||
				(gloves && IsItemGloves(allItems[i])) ||
				(pants && IsItemPants(allItems[i])) ||
				(trophy && IsItemTrophy(allItems[i])) ||
				(mask && IsItemMask(allItems[i])) ||
				(bombs && IsItemBomb(allItems[i])) ||
				(crossbow && (IsItemCrossbow(allItems[i]) || IsItemBolt(allItems[i]))) ||
				(secondaryWeapon && IsItemSecondaryWeapon(allItems[i]))
			)
			{
				if(!equippedOnly || (equippedOnly && ((W3PlayerWitcher)GetEntity()) && GetWitcherPlayer().IsItemEquipped(allItems[i])) )
				{
					if(!ItemHasTag(allItems[i], 'NoDrop'))
						items.PushBack(allItems[i]);
				}
			}
		}
		
		return items;		
	}	
	

	event OnItemAboutToGive( itemId : SItemUniqueId, quantity : int )
	{
		if(GetEntity() == GetWitcherPlayer())
		{
			((W3PlayerWitcher)GetEntity()).RemoveRepairBuffs(itemId);
			if( IsItemWeapon(itemId) )
			{
				RemoveAllOilsFromItem( itemId );
			}
		}
	}
	
	
	event OnItemRemoved( itemId : SItemUniqueId, quantity : int )
	{
		var ent				: CGameplayEntity;
		var crossbows : array<SItemUniqueId>;
		var witcher : W3PlayerWitcher;
		var refill : W3RefillableContainer;
		
		witcher = GetWitcherPlayer();
		
		if(GetEntity() == witcher)
		{
			
			
			
			
			// W3EE - Begin
			/*
			if(IsItemCrossbow(itemId) && HasInfiniteBolts())
			{
				crossbows = GetItemsByCategory('crossbow');
				crossbows.Remove(itemId);
				
				if(crossbows.Size() == 0)
				{
					RemoveItemByName('Bodkin Bolt', GetItemQuantityByName('Bodkin Bolt'));
					RemoveItemByName('Harpoon Bolt', GetItemQuantityByName('Harpoon Bolt'));
				}
			}
			else*/
			// W3EE - End
			if(IsItemBolt(itemId) && witcher.IsItemEquipped(itemId) && witcher.inv.GetItemQuantity(itemId) == quantity)
			{
				
				witcher.UnequipItem(itemId);
			}
			
			
			if(IsItemCrossbow(itemId) && witcher.IsItemEquipped(itemId) && witcher.rangedWeapon)
			{
				witcher.rangedWeapon.ClearDeployedEntity(true);
				witcher.rangedWeapon = NULL;
			}
			if( GetItemCategory(itemId) == 'usable' )
			{
				if(witcher.IsHoldingItemInLHand() && itemId ==  witcher.currentlyEquipedItemL )
				{
					witcher.HideUsableItem(true);
				}
			}
			
			witcher.RemoveRepairBuffs(itemId);
			if( IsItemWeapon(itemId) )
			{
				RemoveAllOilsFromItem( itemId );
			}
			
			
			if(witcher.IsItemEquipped(itemId) && quantity >= witcher.inv.GetItemQuantity(itemId))
				witcher.UnequipItem(itemId);
		}
		
		
		if(GetEntity() == thePlayer && IsItemWeapon(itemId) && (IsItemHeld(itemId) || IsItemMounted(itemId) ))
		{
			thePlayer.OnHolsteredItem(GetItemCategory(itemId),'r_weapon');
		}
		
		
		ent = (CGameplayEntity)GetEntity();
		if(ent)
			ent.OnItemTaken( itemId, quantity );
			
		
		if(IsLootRenewable())
		{
			refill = (W3RefillableContainer)GetEntity();
			if(refill)
				refill.AddTimer('Refill', 20, true);
		}
	}
	
	
	function GenerateItemLevel( item : SItemUniqueId, rewardItem : bool )
	{
		var stat : SAbilityAttributeValue;
		var playerLevel : int;
		var lvl, i : int;
		var quality : int;
		var ilMin, ilMax : int;
		
		// W3EE - Begin
		playerLevel = 1;
		// playerLevel = GetWitcherPlayer().GetLevel();*/
		// W3EE - End
		
		lvl = playerLevel - 1;

		
		if ( ( W3MerchantNPC )GetEntity() )
		{
			lvl = RoundF( playerLevel + RandRangeF( 2, 0 ) );
			AddItemTag( item, 'AutogenUseLevelRange' );
		}
		else if ( rewardItem )
		{
			lvl = RoundF( playerLevel + RandRangeF( 1, 0 ) );
		}
		else if ( ItemHasTag( item, 'AutogenUseLevelRange') )
		{
			quality = RoundMath( CalculateAttributeValue( GetItemAttributeValue( item, 'quality' ) ) );
			ilMin = RoundMath(CalculateAttributeValue( GetItemAttributeValue( item, 'item_level_min' ) ));
			ilMax = RoundMath(CalculateAttributeValue( GetItemAttributeValue( item, 'item_level_max' ) ));
			
			lvl += 1; 
			if ( !ItemHasTag( item, 'AutogenForceLevel') )
				lvl += RoundMath(RandRangeF( 1, -1 ));
			
			if ( FactsQuerySum("NewGamePlus") > 0 )
			{
				if ( lvl < ilMin + theGame.params.GetNewGamePlusLevel() ) lvl = ilMin + theGame.params.GetNewGamePlusLevel();
				if ( lvl > ilMax + theGame.params.GetNewGamePlusLevel() ) lvl = ilMax + theGame.params.GetNewGamePlusLevel();
			}
			else
			{
				if ( lvl < ilMin ) lvl = ilMin;
				if ( lvl > ilMax ) lvl = ilMax;
			}
			
			if ( quality == 5 ) lvl += 2; 
			if ( quality == 4 ) lvl += 1;
			if ( (quality == 5 || quality == 4) && ItemHasTag(item, 'EP1') ) lvl += 1;
		}
		else if ( !ItemHasTag( item, 'AutogenForceLevel') )
		{
			quality = RoundMath( CalculateAttributeValue( GetItemAttributeValue( item, 'quality' ) ) );

			if ( quality == 5 )
			{
				lvl = RoundF( playerLevel + RandRangeF( 2, 0 ) );
			}
			else if ( quality == 4 )
			{
				lvl = RoundF( playerLevel + RandRangeF( 1, -2 ) );
			}
			else if ( quality == 3 )
			{
				lvl = RoundF( playerLevel + RandRangeF( -1, -3 ) );
				
				if ( RandF() > 0.9 )
				{
					lvl =  playerLevel;
				}
			}
			else if ( quality == 2 )
			{
				lvl = RoundF( playerLevel + RandRangeF( -2, -5 ) );
				
				if ( RandF() > 0.95 )
				{
					lvl =  playerLevel;
				}
			}
			else
			{
				lvl = RoundF( playerLevel + RandRangeF( -2, -8 ) );
				
				if ( RandF() == 0 )
				{
					lvl = playerLevel;
				}
			}
		}
		
		if (FactsQuerySum("StandAloneEP1") > 0)
			lvl = GetWitcherPlayer().GetLevel() - 1;
			
		
		if ( FactsQuerySum("NewGamePlus") > 0 && !ItemHasTag( item, 'AutogenUseLevelRange') )
		{	
			if ( quality == 5 ) lvl += 2; 
			if ( quality == 4 ) lvl += 1;
		}
			
		if ( lvl < 1 ) lvl = 1; 
		if ( lvl > GetWitcherPlayer().GetMaxLevel() ) lvl = GetWitcherPlayer().GetMaxLevel();
		
		if ( ItemHasTag( item, 'PlayerSteelWeapon' ) && !( ItemHasAbility( item, 'autogen_steel_base' ) || ItemHasAbility( item, 'autogen_fixed_steel_base' ) )  ) 
		{
			if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_steel_base') )
				return;
		
			if ( ItemHasTag(item, 'AutogenUseLevelRange') )
				AddItemCraftedAbility(item, 'autogen_fixed_steel_base' ); 
			else
				AddItemCraftedAbility(item, 'autogen_steel_base' );
				
			for( i=0; i<lvl; i+=1 ) 
			{
				if (FactsQuerySum("StandAloneEP1") > 0)
				{
					AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true );
					continue;
				}
				
				if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag(item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
					AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true );
				else
					AddItemCraftedAbility(item, 'autogen_steel_dmg', true ); 
			}
		}
		else if ( ItemHasTag( item, 'PlayerSilverWeapon' ) && !( ItemHasAbility( item, 'autogen_silver_base' ) || ItemHasAbility( item, 'autogen_fixed_silver_base' ) ) ) 
		{
			if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_silver_base') )
				return;
			
			if ( ItemHasTag(item, 'AutogenUseLevelRange') )
				AddItemCraftedAbility(item, 'autogen_fixed_silver_base' ); 
			else
				AddItemCraftedAbility(item, 'autogen_silver_base' ); 
				
			for( i=0; i<lvl; i+=1 ) 
			{
				if (FactsQuerySum("StandAloneEP1") > 0)
				{
					AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true ); 
					continue;
				}
			
				if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag(item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
					AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true ); 
				else
					AddItemCraftedAbility(item, 'autogen_silver_dmg', true ); 
			}
		}
		else if ( GetItemCategory( item ) == 'armor' && !( ItemHasAbility( item, 'autogen_armor_base' ) || ItemHasAbility( item, 'autogen_fixed_armor_base' ) ) ) 
		{
			if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_armor_base') )
				return;
				
			if ( ItemHasTag(item, 'AutogenUseLevelRange') )
				AddItemCraftedAbility(item, 'autogen_fixed_armor_base' ); 
			else
				AddItemCraftedAbility(item, 'autogen_armor_base' ); 
				
			for( i=0; i<lvl; i+=1 ) 
			{
				if (FactsQuerySum("StandAloneEP1") > 0)
				{
					AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true ); 
					continue;
				}
			
				if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag( item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
					AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true ); 
				else
					AddItemCraftedAbility(item, 'autogen_armor_armor', true );		
			}
		}
		else if ( ( GetItemCategory( item ) == 'boots' || GetItemCategory( item ) == 'pants' ) && !( ItemHasAbility( item, 'autogen_pants_base' ) || ItemHasAbility( item, 'autogen_fixed_pants_base' ) ) ) 
		{
			if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_pants_base') )
				return;
				
			if ( ItemHasTag(item, 'AutogenUseLevelRange') )
				AddItemCraftedAbility(item, 'autogen_fixed_pants_base' ); 
			else 
				AddItemCraftedAbility(item, 'autogen_pants_base' ); 
				
			for( i=0; i<lvl; i+=1 ) 
			{
				if (FactsQuerySum("StandAloneEP1") > 0)
				{
					AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true ); 
					continue;
				}
			
				if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag( item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
					AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true ); 
				else
					AddItemCraftedAbility(item, 'autogen_pants_armor', true ); 
			}
		}
		else if ( GetItemCategory( item ) == 'gloves' && !( ItemHasAbility( item, 'autogen_gloves_base' ) || ItemHasAbility( item, 'autogen_fixed_gloves_base' ) ) ) 
		{
			if ( ItemHasTag(item, 'AutogenUseLevelRange') && ItemHasAbility(item, 'autogen_fixed_gloves_base') )
				return;
				
			if ( ItemHasTag(item, 'AutogenUseLevelRange') )
				AddItemCraftedAbility(item, 'autogen_fixed_gloves_base' ); 
			else
				AddItemCraftedAbility(item, 'autogen_gloves_base' ); 
				
			for( i=0; i<lvl; i+=1 ) 
			{
				if (FactsQuerySum("StandAloneEP1") > 0)
				{
					AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true ); 
					continue;
				}
			
				if ( ItemHasTag( item, 'AutogenForceLevel') || ItemHasTag(item, 'AutogenUseLevelRange') || FactsQuerySum("NewGamePlus") > 0 ) 
					AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true ); 
				else
					AddItemCraftedAbility(item, 'autogen_gloves_armor', true );
			}
		}	
	}
		
	
	event OnItemAdded(data : SItemChangedData)
	{
		var i, j : int;
		var ent	: CGameplayEntity;
		var allCardsNames, foundCardsNames : array<name>;
		var allStringNamesOfCards : array<string>;
		var foundCardsStringNames : array<string>;
		var gwintCards : array<SItemUniqueId>;
		var itemName : name;
		var witcher : W3PlayerWitcher;
		var itemCategory : name;
		var dm : CDefinitionsManagerAccessor;
		var locKey : string;
		var leaderCardsHack : array<name>;
		
		var hud : CR4ScriptedHud;
		var journalUpdateModule : CR4HudModuleJournalUpdate;
		var itemId : SItemUniqueId;
		
		var isItemShematic : bool;
		
		var ngp : bool;
		
		ent = (CGameplayEntity)GetEntity();
		
		itemId = data.ids[0];
		
		
		if( data.informGui )
		{
			recentlyAddedItems.PushBack( itemId );
			if( ItemHasTag( itemId, 'FocusObject' ) )
			{
				GetWitcherPlayer().GetMedallion().Activate( true, 3.0);
			} 
		}
		
		
		if ( ItemHasTag(itemId, 'Autogen') ) 
		{
			GenerateItemLevel( itemId, false );
		}
		
		witcher = GetWitcherPlayer();
		
		
		if(ent == witcher || ((W3MerchantNPC)ent) )
		{
			ngp = FactsQuerySum("NewGamePlus") > 0;
			for(i=0; i<data.ids.Size(); i+=1)
			{
				
				if ( GetItemModifierInt(data.ids[i], 'ItemQualityModified') <= 0 )
					AddRandomEnhancementToItem(data.ids[i]);
				
				if ( ngp )
					SetItemModifierInt(data.ids[i], 'DoNotAdjustNGPDLC', 1);	
				
				itemName = GetItemName(data.ids[i]);
				
				if ( ngp && GetItemModifierInt(data.ids[i], 'NGPItemAdjusted') <= 0 && !ItemHasTag(data.ids[i], 'Autogen') )
				{
					IncreaseNGPItemlevel(data.ids[i]);
				}
				
			}
		}
		if(ent == witcher)
		{
			for(i=0; i<data.ids.Size(); i+=1)
			{	
				
				if( ItemHasTag( itemId, theGame.params.GWINT_CARD_ACHIEVEMENT_TAG ) || !FactsDoesExist( "fix_for_gwent_achievement_bug_121588" ) )
				{
					
					leaderCardsHack.PushBack('gwint_card_emhyr_gold');
					leaderCardsHack.PushBack('gwint_card_emhyr_silver');
					leaderCardsHack.PushBack('gwint_card_emhyr_bronze');
					leaderCardsHack.PushBack('gwint_card_foltest_gold');
					leaderCardsHack.PushBack('gwint_card_foltest_silver');
					leaderCardsHack.PushBack('gwint_card_foltest_bronze');
					leaderCardsHack.PushBack('gwint_card_francesca_gold');
					leaderCardsHack.PushBack('gwint_card_francesca_silver');
					leaderCardsHack.PushBack('gwint_card_francesca_bronze');
					leaderCardsHack.PushBack('gwint_card_eredin_gold');
					leaderCardsHack.PushBack('gwint_card_eredin_silver');
					leaderCardsHack.PushBack('gwint_card_eredin_bronze');
					
					dm = theGame.GetDefinitionsManager();
					
					allCardsNames = theGame.GetDefinitionsManager().GetItemsWithTag(theGame.params.GWINT_CARD_ACHIEVEMENT_TAG);
					
					
					gwintCards = GetItemsByTag(theGame.params.GWINT_CARD_ACHIEVEMENT_TAG);

					
					allStringNamesOfCards.PushBack('gwint_name_emhyr');
					allStringNamesOfCards.PushBack('gwint_name_emhyr');
					allStringNamesOfCards.PushBack('gwint_name_emhyr');
					allStringNamesOfCards.PushBack('gwint_name_foltest');
					allStringNamesOfCards.PushBack('gwint_name_foltest');
					allStringNamesOfCards.PushBack('gwint_name_foltest');
					allStringNamesOfCards.PushBack('gwint_name_francesca');
					allStringNamesOfCards.PushBack('gwint_name_francesca');
					allStringNamesOfCards.PushBack('gwint_name_francesca');
					allStringNamesOfCards.PushBack('gwint_name_eredin');
					allStringNamesOfCards.PushBack('gwint_name_eredin');
					allStringNamesOfCards.PushBack('gwint_name_eredin');
					
					
					for(j=0; j<allCardsNames.Size(); j+=1)
					{
						itemName = allCardsNames[j];
						locKey = dm.GetItemLocalisationKeyName(allCardsNames[j]);
						if (!allStringNamesOfCards.Contains(locKey))
						{
							allStringNamesOfCards.PushBack(locKey);
						}
					}
					
					
					if(gwintCards.Size() >= allStringNamesOfCards.Size())
					{
						foundCardsNames.Clear();
						for(j=0; j<gwintCards.Size(); j+=1)
						{
							itemName = GetItemName(gwintCards[j]);
							locKey = dm.GetItemLocalisationKeyName(itemName);
							
							if(!foundCardsStringNames.Contains(locKey) || leaderCardsHack.Contains(itemName))
							{
								foundCardsStringNames.PushBack(locKey);
							}
						}

						if(foundCardsStringNames.Size() >= allStringNamesOfCards.Size())
						{
							theGame.GetGamerProfile().AddAchievement(EA_GwintCollector);
							FactsAdd("gwint_all_cards_collected", 1, -1);
						}
						else 
						{
							theGame.GetGamerProfile().NoticeAchievementProgress(EA_GwintCollector, foundCardsStringNames.Size(), allStringNamesOfCards.Size());
						}
					}
					
					if(!FactsDoesExist("fix_for_gwent_achievement_bug_121588"))
						FactsAdd("fix_for_gwent_achievement_bug_121588", 1, -1);
				}
				
				itemCategory = GetItemCategory( itemId );
				isItemShematic = itemCategory == 'alchemy_recipe' ||  itemCategory == 'crafting_schematic';
				
				if( isItemShematic )
				{
					ReadSchematicsAndRecipes( itemId );
				}					
				
				
				if( ItemHasTag( data.ids[i], 'GwintCard'))
				{
					witcher.AddGwentCard(GetItemName(data.ids[i]), data.quantity);
				}
				
				
				
				if( !isItemShematic && ( this.ItemHasTag( itemId, 'ReadableItem' ) || this.ItemHasTag( itemId, 'Painting' ) ) && !this.ItemHasTag( itemId, 'NoNotification' ) )
				{
					hud = (CR4ScriptedHud)theGame.GetHud();
					if( hud )
					{
						journalUpdateModule = (CR4HudModuleJournalUpdate)hud.GetHudModule( "JournalUpdateModule" );
						if( journalUpdateModule )
						{
							journalUpdateModule.AddQuestBookInfo( itemId );
						}
					}
				}				
			}
		}
		
		
		if( IsItemSingletonItem( itemId ) )
		{
			for(i=0; i<data.ids.Size(); i+=1)
			{
				if(!GetItemModifierInt(data.ids[i], 'is_initialized', 0))
				{
					SingletonItemRefillAmmo(data.ids[i]);
					SetItemModifierInt(data.ids[i], 'is_initialized', 1);
				}
			}			
		}
		
		// W3EE - Begin
		GetItemLevel(itemId);
		// W3EE - End
		
		if(ent)
			ent.OnItemGiven(data);
	}
	
	// W3EE - Begin
	public function AddRandomEnhancementToItem(item : SItemUniqueId)
	{
		var itemCategory 	: name;
		var itemQuality		: int;
		var ability			: name;
		var ent				: CGameplayEntity;
		var itemType		: EArmorType;
		
		
		if( ItemHasTag(item, 'DoNotEnhance') || ItemHasTag(item, 'EP1') || ItemHasTag(item, 'Ofir') || StrContains(NameToString(GetItemName(item)), "crafted") )
		{
			SetItemModifierInt(item, 'ItemQualityModified', 1);
			return;
		}
		
		itemCategory = GetItemCategory(item);
		itemQuality = RoundMath(CalculateAttributeValue(GetItemAttributeValue(item, 'quality' )));
		itemType = GetArmorType(item);
		
		if ( itemCategory == 'armor' )
		{
			switch ( itemQuality )
			{
				case 2 : 
					ability = 'quality_masterwork_armor';
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkLightArmorAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkMediumArmorAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkHeavyArmorAbility(), true);
					break;
				case 3 : 
					ability = 'quality_magical_armor'; 	
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalLightArmorAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalMediumArmorAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalHeavyArmorAbility(), true);
					break;
				default : break;
			}
		}
		else if ( itemCategory == 'gloves' )
		{
			switch ( itemQuality )
			{
				case 2 : 
					ability = 'quality_masterwork_gloves'; 		
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkLightGlovesAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkMediumGlovesAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkHeavyGlovesAbility(), true);
					break;
				case 3 : 
					ability = 'quality_magical_gloves'; 	
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalLightGlovesAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalMediumGlovesAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalHeavyGlovesAbility(), true);
					break;
				default : break;
			}
		}
		else if ( itemCategory == 'pants' )
		{
			switch ( itemQuality )
			{
				case 2 : 
					ability = 'quality_masterwork_pants'; 			
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkLightPantsAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkMediumPantsAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkHeavyPantsAbility(), true);
					break;
				case 3 : 
					ability = 'quality_magical_pants'; 	
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalLightPantsAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalMediumPantsAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalHeavyPantsAbility(), true);
					break;
				default : break;
			}
		}
		else if ( itemCategory == 'boots' )
		{
			switch ( itemQuality )
			{
				case 2 : 
					ability = 'quality_masterwork_boots'; 			
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkLightBootsAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkMediumBootsAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkHeavyBootsAbility(), true);
					break;
				case 3 : 
					ability = 'quality_magical_boots'; 		
					if( itemType == EAT_Light )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalLightBootsAbility(), true);
					else
					if( itemType == EAT_Medium )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalMediumBootsAbility(), true);
					else
					if( itemType == EAT_Heavy )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalHeavyBootsAbility(), true);
					break;
				default : break;
			}
		}
		else if ( itemCategory == 'steelsword' )
		{
			switch ( itemQuality )
			{
				case 1 : 
					ability = 'quality_common_steelsword';
					if( RandRange(100, 0) <= 30 )
						AddItemCraftedAbility(item, theGame.params.GetRandomCommonWeaponAbility(), true);
				break;
				
				case 2 : 
					ability = 'quality_masterwork_steelsword';
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkWeaponAbility(), true);
				break;
				
				case 3 : 
					ability = 'quality_magical_steelsword';
					if( RandRange(100, 0) <= 90 )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalWeaponAbility(), true);
					else
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkWeaponAbility(), true);
				break;
				
				default : break;
			}
		}
		else if ( itemCategory == 'silversword' )
		{
			switch ( itemQuality )
			{
				case 1 : 
					ability = 'quality_common_silversword';	
					if( RandRange(100, 0) <= 80 )
						AddItemCraftedAbility(item, theGame.params.GetRandomCommonWeaponAbility(), true);
				break;
				
				case 2 : 
					ability = 'quality_masterwork_silversword';	
						AddItemCraftedAbility(item, theGame.params.GetRandomMasterworkWeaponAbility(), true);
				break;
				
				case 3 : 
					ability = 'quality_magical_silversword';
					if( RandRange(100, 0) <= 90 )
						AddItemCraftedAbility(item, theGame.params.GetRandomMagicalWeaponAbility(), true);
				break;
				
				default : break;
			}
		}
		/*
		else if ( itemCategory == 'mutagen' )
		{
			ability = 'quality_mutagen';
			AddItemCraftedAbility(item, theGame.params.GetRandomMutagenAbility(), true);
		}
		*/
			
		if(IsNameValid(ability))
		{
			AddItemCraftedAbility(item, ability, false);
			SetItemModifierInt(item, 'ItemQualityModified', 1);
		}
	}
	// W3EE - End
	
	public function IncreaseNGPItemlevel(item : SItemUniqueId)
	{
		var i, diff : int;
		
		diff = theGame.params.NewGamePlusLevelDifference();
		
		if (diff > 0)
		{
			if ( ItemHasTag( item, 'PlayerSteelWeapon' ) ) 
			{	
				for( i=0; i<diff; i+=1 ) 
				{
					AddItemCraftedAbility(item, 'autogen_fixed_steel_dmg', true );
				}
			}
			else if ( ItemHasTag( item, 'PlayerSilverWeapon' ) ) 
			{
				for( i=0; i<diff; i+=1 ) 
				{
					AddItemCraftedAbility(item, 'autogen_fixed_silver_dmg', true ); 
				}
			}
			else if ( IsItemChestArmor(item) ) 
			{	
				for( i=0; i<diff; i+=1 ) 
				{
					AddItemCraftedAbility(item, 'autogen_fixed_armor_armor', true );		
				}
			}
			else if ( IsItemBoots(item) || IsItemPants(item) ) 
			{				
				for( i=0; i<diff; i+=1 ) 
				{
					AddItemCraftedAbility(item, 'autogen_fixed_pants_armor', true ); 
				}
			}
			else if ( IsItemGloves(item) ) 
			{			
				for( i=0; i<diff; i+=1 ) 
				{
					AddItemCraftedAbility(item, 'autogen_fixed_gloves_armor', true );
				}
			}	
		}
		
		SetItemModifierInt(item, 'NGPItemAdjusted', 1);
	}
	
	public function GetItemQuality( itemId : SItemUniqueId ) : int
	{
		var itemQuality : float;
		var itemQualityAtribute	: SAbilityAttributeValue;
		var excludedTags : array<name>;
		var tempItemQualityAtribute	: SAbilityAttributeValue;
	
		
		excludedTags.PushBack(theGame.params.OIL_ABILITY_TAG);
		itemQualityAtribute = GetItemAttributeValue( itemId, 'quality', excludedTags, true );
		
		itemQuality = itemQualityAtribute.valueAdditive;
		if( itemQuality == 0 )
		{
			itemQuality = 1;
		}
		return RoundMath(itemQuality);
	}
	
	public function GetItemQualityFromName( itemName : name, out min : int, out max : int)
	{
		var dm : CDefinitionsManagerAccessor;
		var attributeName : name;
		var attributes, itemAbilities : array<name>;
		var attributeMin, attributeMax : SAbilityAttributeValue;
		
		var tmpInt : int;
		var tmpArray : array<float>;
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetItemAbilitiesWithWeights(itemName, GetEntity() == thePlayer, itemAbilities, tmpArray, tmpInt, tmpInt);
		attributes = dm.GetAbilitiesAttributes(itemAbilities);
		for (tmpInt = 0; tmpInt < attributes.Size(); tmpInt += 1)
		{
			if (attributes[tmpInt] == 'quality')
			{
				dm.GetAbilitiesAttributeValue(itemAbilities, 'quality', attributeMin, attributeMax);
				min = RoundMath(CalculateAttributeValue(attributeMin));
				max = RoundMath(CalculateAttributeValue(attributeMax));
				break;
			}
		}
	}
	
	public function GetRecentlyAddedItems() : array<SItemUniqueId> 
	{
		return recentlyAddedItems;
	}
	
	public function GetRecentlyAddedItemsListSize() : int 
	{
		return recentlyAddedItems.Size();
	}
	
	public function RemoveItemFromRecentlyAddedList( itemId : SItemUniqueId ) : bool 
	{
		var i : int;
		
		for( i = 0; i < recentlyAddedItems.Size(); i += 1 )
		{
			if( recentlyAddedItems[i] == itemId )
			{
				recentlyAddedItems.EraseFast( i );
				return true;
			}
		}
		
		return false;
	}
	
	
	
	
	import final function NotifyScriptedListeners( notify : bool );
	
	var listeners : array< IInventoryScriptedListener >;
	
	function AddListener( listener : IInventoryScriptedListener )
	{	
		if ( listeners.FindFirst( listener ) == -1 )
		{
			listeners.PushBack( listener );
			if ( listeners.Size() == 1 )
			{
				NotifyScriptedListeners( true );
			}		
		}	
	}
	
	function RemoveListener( listener : IInventoryScriptedListener )
	{	
		if ( listeners.Remove( listener ) )
		{
			if ( listeners.Size() == 0 )
			{
				NotifyScriptedListeners( false );
			}		
		}	
	}
	
	event OnInventoryScriptedEvent( eventType : EInventoryEventType, itemId : SItemUniqueId, quantity : int, fromAssociatedInventory : bool )
	{
		var i, size : int;
		
		size = listeners.Size();
		for (i=size-1; i>=0; i-=1 )		
		{
			listeners[i].OnInventoryScriptedEvent( eventType, itemId, quantity, fromAssociatedInventory );
		}
		
		
		if(GetEntity() == GetWitcherPlayer() && (eventType == IET_ItemRemoved || eventType == IET_ItemQuantityChanged) )
			GetWitcherPlayer().UpdateEncumbrance();
	}
	
	
	
	
	public final function GetMutationResearchPoints( color : ESkillColor, item : SItemUniqueId ) : int
	{
		var val : SAbilityAttributeValue;
		var colorAttribute : name;
		
		
		if( color == SC_None || color == SC_Yellow || !IsIdValid( item ) )
		{
			return 0;
		}
		
		
		switch( color )
		{
			case SC_Red:
				colorAttribute = 'mutation_research_points_red';
				break;
			case SC_Blue:
				colorAttribute = 'mutation_research_points_blue';
				break;
			case SC_Green:
				colorAttribute = 'mutation_research_points_green';
				break;
		}
		
		
		val = GetItemAttributeValue( item, colorAttribute );
		
		return ( int )val.valueAdditive;
	}
	
	public function GetSkillMutagenColor(item : SItemUniqueId) : ESkillColor
	{		
		var abs : array<name>;
	
		
		if(!ItemHasTag(item, 'MutagenIngredient'))
			return SC_None;
			
		GetItemAbilities(item, abs);
		
		if(abs.Contains('mutagen_color_green'))			return SC_Green;
		if(abs.Contains('mutagen_color_blue'))			return SC_Blue;
		if(abs.Contains('mutagen_color_red'))			return SC_Red;
		if(abs.Contains('lesser_mutagen_color_green'))	return SC_Green;
		if(abs.Contains('lesser_mutagen_color_blue'))	return SC_Blue;
		if(abs.Contains('lesser_mutagen_color_red'))	return SC_Red;
		if(abs.Contains('greater_mutagen_color_green'))	return SC_Green;
		if(abs.Contains('greater_mutagen_color_blue'))	return SC_Blue;
		if(abs.Contains('greater_mutagen_color_red'))	return SC_Red;
		
		return SC_None;
	}

	
	
	

	
	
	
	
	import final function GetItemEnhancementSlotsCount( itemId : SItemUniqueId ) : int;
	import final function GetItemEnhancementItems( itemId : SItemUniqueId, out names : array< name > );
	import final function GetItemEnhancementCount( itemId : SItemUniqueId ) : int;
	import final function GetItemColor( itemId : SItemUniqueId ) : name;
	import final function IsItemColored( itemId : SItemUniqueId ) : bool;
	import final function SetPreviewColor( itemId : SItemUniqueId, colorId : int );
	import final function ClearPreviewColor( itemId : SItemUniqueId ) : bool;
	import final function ColorItem( itemId : SItemUniqueId, dyeId : SItemUniqueId );
	import final function ClearItemColor( itemId : SItemUniqueId ) : bool;
	import final function EnchantItem( enhancedItemId : SItemUniqueId, enchantmentName : name, enchantmentStat : name ) : bool;
	import final function GetEnchantment( enhancedItemId : SItemUniqueId ) : name;
	import final function IsItemEnchanted( enhancedItemId : SItemUniqueId ) : bool;
	import final function UnenchantItem( enhancedItemId : SItemUniqueId ) : bool;
	import private function EnhanceItem( enhancedItemId : SItemUniqueId, extensionItemId : SItemUniqueId ) : bool;
	import private function RemoveItemEnhancementByIndex( enhancedItemId : SItemUniqueId, slotIndex : int ) : bool;
	import private function RemoveItemEnhancementByName( enhancedItemId : SItemUniqueId, extensionItemName : name ) : bool;
	import final function PreviewItemAttributeAfterUpgrade( baseItemId : SItemUniqueId, upgradeItemId : SItemUniqueId, attributeName : name, optional baseInventory : CInventoryComponent, optional upgradeInventory : CInventoryComponent ) : SAbilityAttributeValue;
	import final function HasEnhancementItemTag( enhancedItemId : SItemUniqueId, slotIndex : int, tag : name ) : bool;
	
	
	function NotifyEnhancedItem( enhancedItemId : SItemUniqueId )
	{
		var weapons : array<SItemUniqueId>;
		var sword : CWitcherSword;
		var i : int;
		
		sword = (CWitcherSword) GetItemEntityUnsafe( enhancedItemId );
		sword.UpdateEnhancements( this );
	}
	
	function EnhanceItemScript( enhancedItemId : SItemUniqueId, extensionItemId : SItemUniqueId ) : bool
	{
		var i : int;
		var enhancements : array<name>;
		var runeword : Runeword;
		
		if ( EnhanceItem( enhancedItemId, extensionItemId ) )
		{
			NotifyEnhancedItem( enhancedItemId );
			
			GetItemEnhancementItems( enhancedItemId, enhancements );
			if ( theGame.runewordMgr.GetRuneword( enhancements, runeword ) )
			{
				for ( i = 0; i < runeword.abilities.Size(); i+=1 )
				{
					AddItemBaseAbility( enhancedItemId, runeword.abilities[i] );
				}
			}
			return true;
		}
		return false;
	}
	
	function RemoveItemEnhancementByIndexScript( enhancedItemId : SItemUniqueId, slotIndex : int ) : bool
	{
		var i : int;
		var enhancements : array<name>;
		var runeword : Runeword;
		var hasRuneword : bool;
		var names : array< name >;

		GetItemEnhancementItems( enhancedItemId, enhancements );
		hasRuneword = theGame.runewordMgr.GetRuneword( enhancements, runeword );
		
		GetItemEnhancementItems( enhancedItemId, names );
		
		if ( RemoveItemEnhancementByIndex( enhancedItemId, slotIndex ) )
		{
			NotifyEnhancedItem( enhancedItemId );
			
			
			
			if ( hasRuneword )
			{
				
				for ( i = 0; i < runeword.abilities.Size(); i+=1 )
				{
					RemoveItemBaseAbility( enhancedItemId, runeword.abilities[i] );
				}
			}
			return true;
		}
		return false;
	}
	
	
	function RemoveItemEnhancementByNameScript( enhancedItemId : SItemUniqueId, extensionItemName : name ) : bool
	{
		var i : int;
		var enhancements : array<name>;
		var runeword : Runeword;
		var hasRuneword : bool;

		GetItemEnhancementItems( enhancedItemId, enhancements );
		hasRuneword = theGame.runewordMgr.GetRuneword( enhancements, runeword );
		
		
		if ( RemoveItemEnhancementByName( enhancedItemId, extensionItemName ) )
		{
			NotifyEnhancedItem( enhancedItemId );
			
			
			AddAnItem( extensionItemName, 1, true, true );
			if ( hasRuneword )
			{
				
				for ( i = 0; i < runeword.abilities.Size(); i+=1 )
				{
					RemoveItemBaseAbility( enhancedItemId, runeword.abilities[i] );
				}
			}
			return true;
		}
		return false;
	}
	
	function RemoveAllItemEnhancements( enhancedItemId : SItemUniqueId )
	{
		var count, i : int;
		
		count = GetItemEnhancementCount( enhancedItemId );
		for ( i = count - 1; i >= 0; i-=1 )
		{
			RemoveItemEnhancementByIndexScript( enhancedItemId, i );
		}
	}
	
	function GetHeldAndMountedItems( out items : array< SItemUniqueId > )
	{
		var allItems : array< SItemUniqueId >;
		var i : int;
		var itemName : name;
	
		GetAllItems( allItems );

		items.Clear();
		for( i = 0; i < allItems.Size(); i += 1 )
		{
			if ( IsItemHeld( allItems[ i ] ) || IsItemMounted( allItems[ i ] ) )
			{
				items.PushBack( allItems[ i ] );
			}
		}
	}
	
	
	public function GetHasValidDecorationItems( items : array<SItemUniqueId>, decoration : W3HouseDecorationBase ) : bool
	{
		var i, size : int;
		
		size = items.Size();
		
		
		if(size == 0 )
		{
			LogChannel( 'houseDecorations', "No items with valid tag were found!" );
			return false;
		}
		
		
		for( i=0; i < size; i+= 1 )
		{	
			
			if( GetWitcherPlayer().IsItemEquipped( items[i] ) )
			{
				LogChannel( 'houseDecorations', "Found item is equipped, erasing..." );
				continue;
			}
			
			
			if( IsItemQuest( items[i] ) && decoration.GetAcceptQuestItems() == false )
			{
				LogChannel( 'houseDecorations', "Found item is quest item, and quest items are not accepted, erasing..." );
				continue;
			}
			
			
			if( decoration.GetItemHasForbiddenTag( items[i] ) )
			{
				LogChannel( 'houseDecorations', "Found item has a forbidden tag, erasing..." );
				continue;
			}
			
			LogChannel( 'houseDecorations', "Item checks out: "+ GetItemName( items[i] ) );
			return true;
		}
		LogChannel( 'houseDecorations', "No valid items were found!" );
		
		return false;	
	}	
	
	
	function GetMissingCards() : array< name >
	{
		var defMgr 			: CDefinitionsManagerAccessor 	= theGame.GetDefinitionsManager();
		var allCardNames 	: array< name > 				= defMgr.GetItemsWithTag(theGame.params.GWINT_CARD_ACHIEVEMENT_TAG);
		var playersCards 	: array< SItemUniqueId > 		= GetItemsByTag(theGame.params.GWINT_CARD_ACHIEVEMENT_TAG);
		var playersCardLocs	: array< string >;
		var missingCardLocs	: array< string >;
		var missingCards 	: array< name >;
		var i, j 			: int;
		var found 			: bool;
		
		
		for ( i = 0; i < allCardNames.Size(); i+=1 )
		{
			found = false;
			
			for ( j = 0; j < playersCards.Size(); j+=1 )
			{
				if ( allCardNames[i] == GetItemName( playersCards[j] ) )
				{
					found = true;
					playersCardLocs.PushBack( defMgr.GetItemLocalisationKeyName ( allCardNames[i] ) );
					break;
				}
			}
			
			if ( !found )
			{
				missingCardLocs.PushBack( defMgr.GetItemLocalisationKeyName( allCardNames[i] ) );
				missingCards.PushBack( allCardNames[i] );
			}
		}
		
		if( missingCardLocs.Size() < 2 )
		{
			return missingCards;
		}
		
		
		for ( i = missingCardLocs.Size()-1 ; i >= 0 ; i-=1 )
		{
			for ( j = 0 ; j < playersCardLocs.Size() ; j+=1 )
			{
				if ( missingCardLocs[i] == playersCardLocs[j] 
					&& missingCardLocs[i] != "gwint_name_emhyr" && missingCardLocs[i] != "gwint_name_foltest"
					&& missingCardLocs[i] != "gwint_name_francesca" && missingCardLocs[i] != "gwint_name_eredin" )
				{
					missingCardLocs.EraseFast( i );
					missingCards.EraseFast( i );
					break;
				}
			}
		}
		
		return missingCards;
	}
	
	public function FindCardSources( missingCards : array< name > ) : array< SCardSourceData >
	{
		var sourceCSV 			: C2dArray;
		var sourceTable 		: array< SCardSourceData >;
		var sourceRemaining		: array< SCardSourceData >;
		var sourceCount, i, j	: int;
		
		if ( theGame.IsFinalBuild() )
		{
			sourceCSV = LoadCSV("gameplay\globals\card_sources.csv");
		}
		else
		{
			sourceCSV = LoadCSV("qa\card_sources.csv");
		}

		sourceCount = sourceCSV.GetNumRows();
		sourceTable.Resize(sourceCount);
		
		for ( i = 0 ; i < sourceCount ; i+=1 )
		{
			sourceTable[i].cardName = sourceCSV.GetValueAsName("CardName",i);
			sourceTable[i].source = sourceCSV.GetValue("Source",i);
			sourceTable[i].originArea = sourceCSV.GetValue("OriginArea",i);
			sourceTable[i].originQuest = sourceCSV.GetValue("OriginQuest",i);
			sourceTable[i].details = sourceCSV.GetValue("Details",i);
			sourceTable[i].coords = sourceCSV.GetValue("Coords",i);
		}
		
		for ( i = 0 ; i < missingCards.Size() ; i+=1 )
		{
			for ( j = 0 ; j < sourceCount ; j+=1 )
			{
				if ( sourceTable[j].cardName == missingCards[i] )
				{
					sourceRemaining.PushBack( sourceTable[j] );
				}
			}
		}
		
		return sourceRemaining;
	}
	
	public function GetGwentAlmanacContents() : string
	{
		var sourcesRemaining	: array< SCardSourceData >;
		var missingCards		: array< string >;
		var almanacContents		: string;
		var i 					: int;
		var NML, Novigrad, Skellige, Prologue, Vizima, KaerMorhen, Random : int;

		sourcesRemaining = FindCardSources( GetMissingCards() );
		
		for ( i = 0 ; i < sourcesRemaining.Size() ; i+=1 )
		{
			switch ( sourcesRemaining[i].originArea )
			{
				case "NML":
					NML += 1;
					break;
				case "Novigrad":
					Novigrad += 1;
					break;
				case "Skellige":
					Skellige += 1;
					break;
				case "Prologue":
					Prologue += 1;
					break;
				case "Vizima":
					Vizima += 1;
					break;
				case "KaerMorhen":
					KaerMorhen += 1;
					break;
				case "Random":
					Random += 1;
					break;
				default:
					break;
			}
		}
		
		if ( NML + Novigrad + Skellige + Prologue + Vizima + KaerMorhen + Random == 0 )
		{
			almanacContents = GetLocStringByKeyExt( "gwent_almanac_text" ) + "<br>";
			almanacContents += GetLocStringByKeyExt( "gwent_almanac_completed_text" );
		}
		else
		{
			almanacContents = GetLocStringByKeyExt( "gwent_almanac_text" ) + "<br>";
			if ( NML > 0 )
			{
				almanacContents += GetLocStringByKeyExt( "location_name_velen" ) + ": " + NML + "<br>";
			}
			if ( Novigrad > 0 )
			{
				almanacContents += GetLocStringByKeyExt( "map_location_novigrad" ) + ": " + Novigrad + "<br>";
			}
			if ( Skellige > 0 )
			{
				almanacContents += GetLocStringByKeyExt( "map_location_skellige" ) + ": " + Skellige + "<br>";
			}
			if ( Prologue > 0 )
			{
				almanacContents += GetLocStringByKeyExt( "map_location_prolog_village" ) + ": " + Prologue + "<br>";
			}
			if ( Vizima > 0 )
			{
				almanacContents += GetLocStringByKeyExt( "map_location_wyzima_castle" ) + ": " + Vizima + "<br>";
			}
			if ( KaerMorhen > 0 )
			{
				almanacContents += GetLocStringByKeyExt( "map_location_kaer_morhen" ) + ": " + KaerMorhen + "<br>";
			}
			almanacContents += GetLocStringByKeyExt( "gwent_source_random" ) + ": " + Random;
		}
		
		return almanacContents;
	}
	
	public function GetUnusedMutagensCount(itemName:name):int
	{
		var items  : array<SItemUniqueId>;
		var equippedOnSlot : EEquipmentSlots;
		var availableCount : int;
		var res, i : int = 0;
		
		items = thePlayer.inv.GetItemsByName(itemName);
		
		for(i=0; i<items.Size(); i+=1)
		{
			equippedOnSlot = GetWitcherPlayer().GetItemSlot( items[i] );			
			
			if(equippedOnSlot == EES_InvalidSlot)
			{
				availableCount = thePlayer.inv.GetItemQuantity( items[i] );
				res = res + availableCount;
			}
		}
		
		return res;
	}
	
	public function GetFirstUnusedMutagenByName( itemName : name ):SItemUniqueId
	{
		var items  : array<SItemUniqueId>;
		var equippedOnSlot : EEquipmentSlots;
		var availableCount : int;
		var res, i : int = 0;
		
		items = thePlayer.inv.GetItemsByName(itemName);
		
		for(i=0; i<items.Size(); i+=1)
		{
			equippedOnSlot = GetWitcherPlayer().GetItemSlot( items[i] );			
			
			if( equippedOnSlot == EES_InvalidSlot )
			{
				return items[i];
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	// W3EE - Begin
	public function RemoveUnusedMutagensCountById( itemId:SItemUniqueId, count:int ):bool
	{
		return RemoveUnusedMutagensCount( thePlayer.inv.GetItemName( itemId ), count );
	}
	
	public function RemoveUnusedMutagensCount( itemName:name, count:int ):bool
	{
		var items  			: array<SItemUniqueId>;
		var curItem 		: SItemUniqueId;
		var equippedOnSlot  : EEquipmentSlots;
		
		var i			 	   : int;
		var itemRemoved 	   : int;
		var availableToRemoved : int;
		var removedRes		   : bool;
		
		itemRemoved = 0;
		items = thePlayer.inv.GetItemsByName( itemName );
		
		for( i=0; i < items.Size(); i+=1 )
		{
			curItem = items[ i ];
			equippedOnSlot = GetWitcherPlayer().GetItemSlot( curItem );
			
			if( equippedOnSlot == EES_InvalidSlot )
			{
				availableToRemoved = Min( thePlayer.inv.GetItemQuantity( curItem ), ( count - itemRemoved ) );
				removedRes = thePlayer.inv.RemoveItem(items[i], availableToRemoved);
				
				if (removedRes)
				{
					itemRemoved = itemRemoved + availableToRemoved;
					
					if (itemRemoved >= count)
					{
						return true;
					}
				}
				
			}
		}		
		return false;
	}
	// W3EE - End
	
	//Plasticmetal - LootTweak ++
	function AlchemyColor( item: SItemUniqueId ) :string
	{
		var msg : string;
		
		msg = this.GetItemLocNameByID(item);
		
		if(this.ItemHasTag(item, 'primer_vitriol'))
			msg = "<font color=\"#1595b0\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_rebis'))
			msg = "<font color=\"#4db323\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_aether'))
			msg = "<font color=\"#7764a9\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_quebrith'))
			msg = "<font color=\"#be8728\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_hydragenum'))
			msg = "<font color=\"#b0b0b0\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_vermilion'))
			msg = "<font color=\"#d25212\">" +msg + "</font>";
		
		return msg;
		
	}
	
	function AlchemySecondary(item : SItemUniqueId ) :string
	{
		var msg: string;

		if(this.ItemHasTag(item, 'primer_albedo'))
			msg =" " + "<font color=\"#e0e0e0\">" +"[Albedo]" + "</font>";
		else if (this.ItemHasTag(item, 'primer_rubedo'))
			msg = " " +"<font color=\"#C52C34\">" +"[Rubedo]" + "</font>";
		else if (this.ItemHasTag(item, 'primer_nigredo'))
			msg = " " +"<font color=\"#4F4F4F\">" +"[Nigredo]" + "</font>";

		return msg;
	}
	//Plasticmetal - LootTweak --
}

exec function findMissingCards( optional card : name )
{
	var inv					: CInventoryComponent = thePlayer.GetInventory();
	var sourcesRemaining	: array< SCardSourceData >;
	var missingCards		: array< name >;
	var i 					: int;
	var sourceLogString		: string;
	
	if ( card != '' )
	{
		missingCards.PushBack( card );
	}
	else
	{
		missingCards = inv.GetMissingCards();
	}
	
	sourcesRemaining = inv.FindCardSources( missingCards );

	for ( i = 0 ; i < sourcesRemaining.Size() ; i+=1 )
	{
		sourceLogString = sourcesRemaining[i].cardName + " is a " + sourcesRemaining[i].source ;
		if ( sourcesRemaining[i].originArea == "Random" )
		{
			sourceLogString += " card from a random merchant.";
		}
		else
		{
			sourceLogString += " item in " + sourcesRemaining[i].originArea + " from ";
			
			if ( sourcesRemaining[i].originQuest != "" )
			{
				sourceLogString += sourcesRemaining[i].originQuest + " , ";
			}
			
			sourceLogString += sourcesRemaining[i].details;
		}
		Log( sourceLogString );
		
		if ( sourcesRemaining[i].coords != "" )
		{
			Log( sourcesRemaining[i].coords ); 
		}
	}
}

exec function slotTest()
{
	var inv : CInventoryComponent = thePlayer.inv;
	var weaponItemId : SItemUniqueId;
	var upgradeItemId : SItemUniqueId;
	var i : int;
	
	LogChannel('SlotTest', "----------------------------------------------------------------");

	
	inv.AddAnItem( 'Perun rune', 1);
	inv.AddAnItem( 'Svarog rune', 1);
	

	for ( i = 0; i < 2; i += 1 )
	{
		
		if ( !GetItem( inv, 'steelsword', weaponItemId ) ||
			 !GetItem( inv, 'upgrade', upgradeItemId ) )
		{
			return;
		}

		
		PrintItem( inv, weaponItemId );
	
		
		if ( inv.EnhanceItemScript( weaponItemId, upgradeItemId ) )
		{
			LogChannel('SlotTest', "Enhanced item");
		}
		else
		{
			LogChannel('SlotTest', "Failed to enhance item!");
		}
	}
	
	
	if ( !GetItem( inv, 'steelsword', weaponItemId ) )
	{
		return;
	}

	
	PrintItem( inv, weaponItemId );
	
	
	if ( inv.RemoveItemEnhancementByNameScript( weaponItemId, 'Svarog rune' ) )
	{
		LogChannel('SlotTest', "Removed enhancement");
	}
	else
	{
		LogChannel('SlotTest', "Failed to remove enhancement!");
	}

	
	if ( !GetItem( inv, 'steelsword', weaponItemId ) )
	{
		return;
	}

	
	PrintItem( inv, weaponItemId );

	
	if ( inv.RemoveItemEnhancementByIndexScript( weaponItemId, 0 ) )
	{
		LogChannel('SlotTest', "Removed enhancement");
	}
	else
	{
		LogChannel('SlotTest', "Failed to remove enhancement!");
	}
	
	
	if ( !GetItem( inv, 'steelsword', weaponItemId ) )
	{
		return;
	}

	
	PrintItem( inv, weaponItemId );
}

function GetItem( inv : CInventoryComponent, category : name, out itemId : SItemUniqueId ) : bool
{
	var itemIds : array< SItemUniqueId >;

	itemIds = inv.GetItemsByCategory( category );
	if ( itemIds.Size() > 0 )
	{
		itemId = itemIds[ 0 ];
		return true;
	}
	LogChannel( 'SlotTest', "Failed to get item with GetItemsByCategory( '" + category + "' )" );
	return false;
}

function PrintItem( inv : CInventoryComponent, weaponItemId : SItemUniqueId )
{
	var names : array< name >;
	var tags : array< name >;
	var i : int;
	var line : string;
	var attribute : SAbilityAttributeValue;

	LogChannel('SlotTest', "Slots:                         " + inv.GetItemEnhancementCount( weaponItemId ) + "/" + inv.GetItemEnhancementSlotsCount( weaponItemId ) );
	inv.GetItemEnhancementItems( weaponItemId, names );
	if ( names.Size() > 0 )
	{
		for ( i = 0; i < names.Size(); i += 1 )
		{
			if ( i == 0 )
			{
				line += "[";
			}
			line += names[ i ];
			if ( i < names.Size() - 1 )
			{
				line += ", ";
			}
			if ( i == names.Size() - 1 )
			{
				line += "]";
			}
		}
	}
	else
	{
		line += "[]";
	}
	LogChannel('SlotTest', "Upgrade item names             " + line );
	
	tags.PushBack('Upgrade');

	attribute = inv.GetItemAttributeValue( weaponItemId, 'PhysicalDamage' );
	LogChannel('SlotTest', "Attribute '" + 'PhysicalDamage' + "'      " + attribute.valueBase + " " + attribute.valueMultiplicative + " " + attribute.valueAdditive );
	attribute = inv.GetItemAttributeValue( weaponItemId, 'SilverDamage' );
	LogChannel('SlotTest', "Attribute '" + 'SilverDamage' + "'      " + attribute.valueBase + " " + attribute.valueMultiplicative + " " + attribute.valueAdditive );
	
	attribute = inv.GetItemAttributeValue( weaponItemId, 'PhysicalDamage', tags, true );
	LogChannel('SlotTest', "Attribute '" + 'PhysicalDamage' + "'      " + attribute.valueBase + " " + attribute.valueMultiplicative + " " + attribute.valueAdditive );
	attribute = inv.GetItemAttributeValue( weaponItemId, 'SilverDamage', tags, true  );
	LogChannel('SlotTest', "Attribute '" + 'SilverDamage' + "'      " + attribute.valueBase + " " + attribute.valueMultiplicative + " " + attribute.valueAdditive );

	attribute = inv.GetItemAttributeValue( weaponItemId, 'PhysicalDamage', tags );
	LogChannel('SlotTest', "Attribute '" + 'PhysicalDamage' + "'      " + attribute.valueBase + " " + attribute.valueMultiplicative + " " + attribute.valueAdditive );
	attribute = inv.GetItemAttributeValue( weaponItemId, 'SilverDamage', tags );
	LogChannel('SlotTest', "Attribute '" + 'SilverDamage' + "'      " + attribute.valueBase + " " + attribute.valueMultiplicative + " " + attribute.valueAdditive );

}

function PlayItemEquipSound( itemCategory : name ) : void 
{
	switch( itemCategory )
	{
		case 'steelsword' :
			theSound.SoundEvent("gui_inventory_steelsword_attach");
			return;
		case 'silversword' :
			theSound.SoundEvent("gui_inventory_silversword_attach");
			return;
		case 'secondary' :
			theSound.SoundEvent("gui_inventory_weapon_attach");
			return;
		case 'armor' :
			theSound.SoundEvent("gui_inventory_armor_attach");
			return;
		case 'pants' :
			theSound.SoundEvent("gui_inventory_pants_attach");
			return;
		case 'boots' :
			theSound.SoundEvent("gui_inventory_boots_attach");
			return;
		case 'gloves' :
			theSound.SoundEvent("gui_inventory_gauntlet_attach");
			return;
		case 'potion' :
			theSound.SoundEvent("gui_inventory_potion_attach");
			return;
		case 'petard' :
			theSound.SoundEvent("gui_inventory_bombs_attach");
			return;			
		case 'ranged' :
			theSound.SoundEvent("gui_inventory_ranged_attach");
			return;	
		case 'herb' :
			theSound.SoundEvent("gui_pick_up_herbs");
			return;
		case 'trophy' :
		case 'horse_bag' : 
			theSound.SoundEvent("gui_inventory_horse_bage_attach");
			return;
		case 'horse_blinder' :
			theSound.SoundEvent("gui_inventory_horse_blinder_attach");
			return;
		case 'horse_saddle'	: 	
			theSound.SoundEvent("gui_inventory_horse_saddle_attach");
			return;
		default :
			theSound.SoundEvent("gui_inventory_other_attach");
			return;
	}
}

function PlayItemUnequipSound( itemCategory : name ) : void 
{	
	switch( itemCategory )
	{
		case 'steelsword' :
			theSound.SoundEvent("gui_inventory_steelsword_back");
			return;
		case 'silversword' :
			theSound.SoundEvent("gui_inventory_silversword_back");
			return;
		case 'secondary' :
			theSound.SoundEvent("gui_inventory_weapon_back");
			return;
		case 'armor' :
			theSound.SoundEvent("gui_inventory_armor_back");
			return;
		case 'pants' :
			theSound.SoundEvent("gui_inventory_pants_back");
			return;
		case 'boots' :
			theSound.SoundEvent("gui_inventory_boots_back");
			return;
		case 'gloves' :
			theSound.SoundEvent("gui_inventory_gauntlet_back");
			return;
		case 'petard' :
			theSound.SoundEvent("gui_inventory_bombs_back");
			return;			
		case 'potion' :
			theSound.SoundEvent("gui_inventory_potion_back");
			return;
		case 'ranged' :
			theSound.SoundEvent("gui_inventory_ranged_back");
			return;
		case 'trophy' :
		case 'horse_bag' : 
			theSound.SoundEvent("gui_inventory_horse_bage_back");
			return;
		case 'horse_blinder' :
			theSound.SoundEvent("gui_inventory_horse_blinder_back");
			return;
		case 'horse_saddle'	: 	
			theSound.SoundEvent("gui_inventory_horse_saddle_back");
			return;
		default :
			theSound.SoundEvent("gui_inventory_other_back");
			return;
	}
}

function PlayItemConsumeSound( item : SItemUniqueId ) : void
{
	//W3EE - Begin
	if( thePlayer.GetInventory().ItemHasTag( item, 'Bandage' ) )
		return;
	//W3EE - End
	
	if( thePlayer.GetInventory().ItemHasTag( item, 'Drinks' ) || thePlayer.GetInventory().ItemHasTag( item, 'Alcohol' ) )
	{
		theSound.SoundEvent('gui_inventory_drink');
	}
	else
	{
		theSound.SoundEvent('gui_inventory_eat');
	}
}




