/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3CraftingManager
{
	protected var schematics : array<SCraftingSchematic>;		
	protected var craftMasterComp : W3CraftsmanComponent;		
	
	private var craftedAbilityName : name;	default craftedAbilityName = 'W3EE_Regular';
	
	public function Init( masterComp : W3CraftsmanComponent )
	{
		craftMasterComp = masterComp;
		LoadSchematicsXMLData( GetWitcherPlayer().GetCraftingSchematicsNames() );
	}
	
	// W3EE - Begin
	public function SetAbilityName( n : name )
	{
		craftedAbilityName = n;
	}
	
	public function ModSchematic( schem : SCraftingSchematic, idx : int ) : void
	{
		var i : int;
		
		for(i=0; i<schematics.Size(); i+=1)
		{
			if( schematics[i].schemName == schem.schemName )
			{
				schematics[i] = schem;
				return;
			}
		}
	}
	// W3EE - End
	
	protected function LoadSchematicsXMLData( schematicsNames : array<name> ) : void
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName : name;
		var tmpInt : int;
		var schem : SCraftingSchematic;
		var i,j,k, qualityLevelMin, qualityLevelMax : int;
		var ing : SItemParts;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('crafting_schematics');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			
			for(j=0; j<schematicsNames.Size(); j+=1)
			{
				if(tmpName == schematicsNames[j])
				{
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftedItem_name', tmpName))
						schem.craftedItemName = tmpName;
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanType_name', tmpName))
						schem.requiredCraftsmanType = ParseCraftsmanTypeStringToEnum(tmpName);
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'craftedItemQuantity', tmpInt))
						schem.craftedItemCount = tmpInt;
					if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanLevel_name', tmpName))
						schem.requiredCraftsmanLevel = ParseCraftsmanLevelStringToEnum(tmpName);
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'price', tmpInt))
						schem.baseCraftingPrice = tmpInt;	
					
					
					ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
					for(k=0; k<ingredients.subNodes.Size(); k+=1)
					{		
						ing.itemName = '';
						ing.quantity = -1;
					
						if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
							ing.itemName = tmpName;
						if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
							ing.quantity = tmpInt;
						thePlayer.GetInventory().GetItemQualityFromName(ing.itemName, qualityLevelMin, qualityLevelMax);
						if( qualityLevelMin < 4 && (theGame.GetDefinitionsManager().IsItemAnyArmor(schem.craftedItemName) || theGame.GetDefinitionsManager().IsItemWeapon(schem.craftedItemName)) )
						{
							if(theGame.GetDifficultyMode() == EDM_Hard)
								ing.quantity *= 2;
							else if(theGame.GetDifficultyMode() == EDM_Hardcore)
								ing.quantity *= 3;
						}
						schem.ingredients.PushBack(ing);						
					}
					
					schem.schemName = schematicsNames[j];
					
					schematics.PushBack(schem);		

					
					schem.baseCraftingPrice = -1;
					schem.craftedItemName = '';
					schem.ingredients.Clear();
					schem.requiredCraftsmanLevel = ECL_Undefined;
					schem.requiredCraftsmanType = ECT_Undefined;
					schem.schemName = '';
					schem.craftedItemCount = 0;
					break;
				}
			}
		}
	}
	
	public function GetQualityLevel( ingredients : array<SItemParts> ) : int
	{
		var i, qualityLevelMin, qualityLevelMax : int;
		var ingredientCount, qualityLevel : float;
		var dm : CDefinitionsManagerAccessor;
		var inv : CInventoryComponent;
		
		dm = theGame.GetDefinitionsManager();
		inv = thePlayer.GetInventory();
		for(i=ingredients.Size()-1; i>=0; i-=1)
		{
			if( !dm.IsItemCraftingIngredient(ingredients[i].itemName) )
				continue;
				
			inv.GetItemQualityFromName(ingredients[i].itemName, qualityLevelMin, qualityLevelMax);
			qualityLevel += qualityLevelMin;
			ingredientCount += 1;
		}
		
		if( ingredientCount )
		{
			if( qualityLevel / ingredientCount >= 3 )
				return 3;
			else
			if( qualityLevel / ingredientCount >= 2 )
				return 2;
		}
		
		return 1;
	}
	
	public function GetCraftedItemNameFromQualityLevel( itemToCraft : name, qualityLevel : int ) : name
	{
		var itemName : string;
		var items : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		
		itemName = StrLeft(itemToCraft, StrLen(itemToCraft) - 1) + qualityLevel;
		dm = theGame.GetDefinitionsManager();
		
		if( dm.IsItemAnyArmor(itemToCraft) )
		{
			items = dm.GetItemsWithTag('Armor');
			for(i=0; i<items.Size(); i+=1)
			{
				if( NameToString(items[i]) == itemName )
					return items[i];
			}
		}
		else
		if( dm.IsItemWeapon(itemToCraft) )
		{
			items = dm.GetItemsWithTag('Weapon');
			for(i=0; i<items.Size(); i+=1)
			{
				if( NameToString(items[i]) == itemName )
					return items[i];
			}
		}
		
 		return itemToCraft;
	}
	
	public function IsCraftsmanType( type : ECraftsmanType ) : bool
	{
		return craftMasterComp.IsCraftsmanType(type);
	}
	
	public function CanCraftSchematic(schematicName : name, checkMerchant : bool) : ECraftingException
	{
		var adjustedIngredientCount : array<int>;
		var i, j, availableIngredients : int;
		var schem : SCraftingSchematic;
		
		GetSchematic(schematicName, schem);
		
		if( checkMerchant )
		{
			if( !GetSchematic( schematicName, schem ) )
			{
				return ECE_UnknownSchematic;
			}
			
			if( !craftMasterComp.IsCraftsmanType( schem.requiredCraftsmanType ) )
			{
				return ECE_WrongCraftsmanType;
			}
			
			if( craftMasterComp.GetCraftsmanLevel( schem.requiredCraftsmanType ) < schem.requiredCraftsmanLevel )
			{
				return ECE_TooLowCraftsmanLevel;
			}
		}
		
		adjustedIngredientCount.Resize(schem.ingredients.Size());
		for(i=schem.ingredients.Size()-1; i>=0; i-=1)
		{
			for(j=i; j>=0; j-=1)
			{
				if( schem.ingredients[i].itemName == schem.ingredients[j].itemName )
					adjustedIngredientCount[i] += schem.ingredients[j].quantity;				
			}			
		}	
		
		for(i=0; i<schem.ingredients.Size(); i+=1)
		{
			availableIngredients = Equipment().GetItemQuantityByNameForCrafting(schem.ingredients[i].itemName);
			if( schem.ingredients[i].quantity <= 0 )
				return ECE_TooFewIngredients;
			
			if( availableIngredients < schem.ingredients[i].quantity || availableIngredients < adjustedIngredientCount[i] )
				return ECE_TooFewIngredients;		
		}
		
		if( checkMerchant )
		{
			if( thePlayer.GetMoney() < GetCraftingCost(schematicName) )
				return ECE_NotEnoughMoney;
		}
		
		return ECE_NoException;
	}
	
	
	public function GetSchematic(s : name, out ret : SCraftingSchematic) : bool
	{
		var i : int;
		
		for(i=0; i<schematics.Size(); i+=1)
		{
			if(schematics[i].schemName == s)
			{
				ret = schematics[i];
				return true;
			}
		}
		
		return false;
	}
	
	// W3EE - Begin
	public function GetCraftingCost(schematic : name) : int
	{
		var cost : int;
		var mult, areaMult : float;
		var isSchematic : bool;
		var schem : SCraftingSchematic;
		
		cost = 0; mult = 1.f;
		isSchematic = GetSchematic(schematic, schem);
		if ( isSchematic )
		{
			if( StrContains(craftedAbilityName, "Common") )
				mult += 0.1f;
			else
			if( StrContains(craftedAbilityName, "Master") )
				mult += 0.25f;
			else
			if( StrContains(craftedAbilityName, "Magic") )
				mult += 0.35f;
				
			areaMult = ((CGameplayEntity)craftMasterComp.GetEntity()).GetInventory().GetAreaPriceMultByName(schem.craftedItemName);
			cost = RoundMath(schem.baseCraftingPrice * LFEGetCraftMult() * mult * areaMult);
		}
		
		return cost;
	}
	// W3EE - End
	
	public function Craft(schemName : name, out item : SItemUniqueId, optional itemName : name) : ECraftingException
	{
		var error : ECraftingException;
		var i, j, size : int;
		var schem : SCraftingSchematic;
		var items, upgradeItem : array<SItemUniqueId>;
		var itemsingr : array<SItemUniqueId>;
		var equipAfterCrafting : bool;
		var tutStateSet : W3TutorialManagerUIHandlerStateCraftingSet;
		var craftsman : CGameplayEntity;
		var upgrades, temp : array<name>;

		var wasEnchanted 			: bool;
		var wasDyed					: bool;
		var enchantName, colorName	: name;
		var maxSlots				: int;
		var dye_ids					: array<SItemUniqueId>;	

		error = CanCraftSchematic(schemName, true);
		if(error != ECE_NoException)
		{
			item = GetInvalidUniqueId();
			LogCrafting("Cannot craft schematic <<" + schemName + ">>. Exception is <<" + error + ">>");
			return error;
		}
			
		GetSchematic(schemName, schem);
		
		
		craftsman = (CGameplayEntity)craftMasterComp.GetEntity();
		thePlayer.inv.GiveMoneyTo(craftsman.GetInventory(), GetCraftingCost(schemName), false);

		maxSlots = 0;
		wasEnchanted = false;
		wasDyed = false;

		
		equipAfterCrafting = false;
		for(i=0; i<schem.ingredients.Size(); i+=1)
		{
			itemsingr = thePlayer.inv.GetItemsByName( schem.ingredients[i].itemName );
			for(j=0; j<itemsingr.Size(); j+=1)
			{
				if ( thePlayer.inv.IsItemMounted( itemsingr[j] ) || thePlayer.inv.IsItemHeld( itemsingr[j] ) ) 
				{
					equipAfterCrafting = true;
				}
			}

			maxSlots = Max(maxSlots, thePlayer.inv.GetItemEnhancementSlotsCount( itemsingr[0] ));

			
			thePlayer.inv.GetItemEnhancementItems(itemsingr[0], temp);
			ArrayOfNamesAppend(upgrades, temp);
			temp.Clear();

			if ( thePlayer.inv.IsItemEnchanted( itemsingr[0] ) )
			{
				wasEnchanted = true;
				enchantName = thePlayer.inv.GetEnchantment( itemsingr[0] );
			}
			if (thePlayer.inv.IsItemColored( itemsingr[0] ))
			{
				wasDyed = true;
				colorName = thePlayer.inv.GetItemColor( itemsingr[0] );
			}

			// W3EE - Begin
			Equipment().RemoveItemByNameForCrafting(schem.ingredients[i].itemName, schem.ingredients[i].quantity);
			// W3EE - End
		}
		
		
		if( itemName != '' )
			items = thePlayer.inv.AddAnItem(itemName, schem.craftedItemCount);
		else
			items = thePlayer.inv.AddAnItem(schem.craftedItemName, schem.craftedItemCount);
		item = items[0];

		maxSlots = Min(maxSlots, thePlayer.inv.GetSlotItemsLimit( item ));
		while (thePlayer.inv.GetItemEnhancementSlotsCount(item) < maxSlots)
			thePlayer.inv.AddSlot(item);

		
		size = Min(thePlayer.inv.GetItemEnhancementSlotsCount(item), upgrades.Size());	
		for(i=0; i<size; i+=1)
		{
			upgradeItem = thePlayer.inv.AddAnItem(upgrades[i], 1, true, true);
			thePlayer.inv.EnhanceItemScript(item, upgradeItem[0]);
		}

		if ( wasEnchanted )
		{
			thePlayer.inv.EnchantItem( item, enchantName, getEnchamtmentStatName(enchantName) );
		}
		if ( wasDyed )
		{
			dye_ids = thePlayer.inv.AddAnItem( colorName, 1, true, true, false );
			thePlayer.inv.ColorItem( item, dye_ids[0] );
			thePlayer.inv.RemoveItem( dye_ids[0], 1 );
		}
		
		if ( equipAfterCrafting )
			thePlayer.EquipItem( item );

		LogCrafting("Item <<" + schem.craftedItemName + ">> crafted successfully");
		
		if(thePlayer.inv.IsItemSetItem(item) && ShouldProcessTutorial('TutorialCraftingSets'))
		{
			tutStateSet = (W3TutorialManagerUIHandlerStateCraftingSet)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStateSet)
			{
				tutStateSet.OnCraftedSetItem();
			}
		}
		
		return ECE_NoException;
	}
}

function getCraftingSchematicFromName(schematicName : name):SCraftingSchematic
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var tmpName : name;
	var tmpInt : int;
	var schem : SCraftingSchematic;
	var i,k : int;
	var ing : SItemParts;
	var schematicsNames : array<name>;
					
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('crafting_schematics');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
		if(tmpName == schematicName)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftedItem_name', tmpName))
				schem.craftedItemName = tmpName;
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanType_name', tmpName))
				schem.requiredCraftsmanType = ParseCraftsmanTypeStringToEnum(tmpName);
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'craftsmanLevel_name', tmpName))
				schem.requiredCraftsmanLevel = ParseCraftsmanLevelStringToEnum(tmpName);
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'price', tmpInt))
				schem.baseCraftingPrice = tmpInt;	
			
			
			ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
			for(k=0; k<ingredients.subNodes.Size(); k+=1)
			{		
				ing.itemName = '';
				ing.quantity = -1;
			
				if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
					ing.itemName = tmpName;
				if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
					ing.quantity = tmpInt;
					
				schem.ingredients.PushBack(ing);						
			}
			
			schem.schemName = schematicName;
			
			
			break;
		}
	}
		
	return schem;
}

