/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class CR4CraftingMenu extends CR4ListBaseMenu
{	
	private var m_definitionsManager	: CDefinitionsManagerAccessor;
	private var bCouldCraft				: bool;
	protected var _inv       			: CInventoryComponent;
	private var _playerInv    	   		: W3GuiPlayerInventoryComponent;
	
	private var m_craftingManager		: W3CraftingManager;
	private var m_craftingSchematics	: array< name >;
	private var m_schematicList			: array< SCraftingSchematic >;
	private var m_npc		 			: CNewNPC;
	private var m_npcInventory  	    : CInventoryComponent;
	private var m_shopInvComponent 	    : W3GuiShopInventoryComponent;
	private var m_lastSelectedTag		: name;
	
	private var _craftsmanComponent		: W3CraftsmanComponent;	
	private var _quantityPopupData	    : QuantityPopupData;
	
	private var m_fxSetCraftingEnabled	: CScriptedFlashFunction;
	private var m_fxSetCraftedItem 		: CScriptedFlashFunction;
	private var m_fxHideContent	 		: CScriptedFlashFunction;
	private var m_fxSetFilters			: CScriptedFlashFunction;
	private var m_fxSetPinnedRecipe		: CScriptedFlashFunction;
	private var m_fxSetMerchantCheck	: CScriptedFlashFunction;
	private var m_fxSetModuleRarity		: CScriptedFlashFunction;
	private var m_fxSetDynamicItem		: CScriptedFlashFunction;
		
	default bCouldCraft 			= false;
	
	default DATA_BINDING_NAME			= "crafting.list";
	default DATA_BINDING_NAME_SUBLIST	= "crafting.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "crafting.item.description";
	
	var itemsQuantity, itemsQuantityOriginal 						: array< int >;
	event  OnConfigUI()
	{	
		var commonMenu 				: CR4CommonMenu;
		var l_obj		 			: IScriptable;
		
		var l_initData				: W3InventoryInitData;
		var l_craftingFilters		: SCraftingFilters;
		var pinnedTag				: int;
		var i : int;
		
		dontAutoCallOnOpeningMenuInOnConfigUIHaxxor = true;
		
		super.OnConfigUI();
		
		m_initialSelectionsToIgnore = 2;
		
		_inv = thePlayer.GetInventory();
		m_definitionsManager = theGame.GetDefinitionsManager();
		
		_playerInv = new W3GuiPlayerInventoryComponent in this;
		_playerInv.Initialize( _inv );
		
		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
		{
			m_npc = (CNewNPC)l_initData.containerNPC;
		}
		else
		{
			m_npc = (CNewNPC)l_obj;
		}
		_craftsmanComponent = (W3CraftsmanComponent)m_npc.GetComponentByClassName('W3CraftsmanComponent');
		
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu(GetMenuName());
		}
		
		theInput.RegisterListener(this,	'OnIngredientShiftAction', 'IngredientShift');
		CreateCraftingMenuContext();
		
		m_craftingManager = new W3CraftingManager in this;
		m_craftingManager.Init(_craftsmanComponent);		
		m_craftingSchematics = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		if(m_npc && (W3MerchantComponent)m_npc.GetComponentByClassName('W3MerchantComponent'))
		{
			m_npcInventory = m_npc.GetInventory();
			bCouldCraft = true;
			
			m_shopInvComponent = new W3GuiShopInventoryComponent in this;
			m_npcInventory.UpdateLoot();
			m_npcInventory.ClearGwintCards();
			m_npcInventory.ClearTHmaps();
			m_npcInventory.ClearKnownRecipes();
			m_shopInvComponent.Initialize( m_npcInventory );
			
			UpdateMerchantData(m_npc);
		}
		
		m_schematicListOriginal.Clear();
		m_schematicListOriginal.Resize(m_craftingSchematics.Size());
		for(i=0; i<m_craftingSchematics.Size(); i+=1)
			m_craftingManager.GetSchematic(m_craftingSchematics[i], m_schematicListOriginal[i]);
		m_schematicList = m_schematicListOriginal;
		
		m_fxSetCraftedItem = m_flashModule.GetMemberFlashFunction("setCraftedItem");
		m_fxSetCraftingEnabled = m_flashModule.GetMemberFlashFunction("setCraftingEnabled");
		m_fxHideContent = m_flashModule.GetMemberFlashFunction("hideContent");
		m_fxSetFilters = m_flashModule.GetMemberFlashFunction("SetFiltersValue");
		m_fxSetPinnedRecipe = m_flashModule.GetMemberFlashFunction("setPinnedRecipe");
		m_fxSetMerchantCheck = m_flashModule.GetMemberFlashFunction("setMerchantTypeCheck");
		m_fxSetModuleRarity = m_flashModule.GetMemberFlashFunction("setUIRarityColor");
		m_fxSetDynamicItem = m_flashModule.GetMemberFlashFunction("setDynamicItem");
		
		m_fxSetCraftingEnabled.InvokeSelfOneArg(FlashArgBool(true));
		
		l_craftingFilters = GetWitcherPlayer().GetCraftingFilters();
		m_fxSetFilters.InvokeSelfSixArgs(FlashArgString(GetLocStringByKeyExt("gui_panel_filter_has_ingredients")), FlashArgBool(l_craftingFilters.showCraftable), 
										 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_elements_missing")), FlashArgBool(l_craftingFilters.showMissingIngre), 
										 FlashArgString(GetLocStringByKeyExt("panel_crafting_exception_wrong_craftsman_type") + " / " + GetLocStringByKeyExt("panel_crafting_exception_too_low_craftsman_level")), FlashArgBool(l_craftingFilters.showAlreadyCrafted));
		
		pinnedTag = NameToFlashUInt(theGame.GetGuiManager().PinnedCraftingRecipe);
		m_fxSetPinnedRecipe.InvokeSelfOneArg(FlashArgUInt(pinnedTag));
		
		PopulateData();
		
		SetIngredientCategories();
		
		SelectFirstModule();
		
		m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
	}

	event OnClosingMenu()
	{
		super.OnClosingMenu();
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( GetMenuName() );
		
		if( craftingMenuContext )
		{
			craftingMenuContext.Deactivate();
			delete craftingMenuContext;
		}
		
		theInput.UnregisterListener(this, 'IngredientShift');
		
		if (_quantityPopupData)
		{
			delete _quantityPopupData;
		}
	}

	event  OnCloseMenu() 
	{
		var commonMenu : CR4CommonMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if(commonMenu)
		{
			commonMenu.ChildRequestCloseMenu();
		}
		
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
	}

	event  OnEntryRead( tag : name )
	{
		
		
		
	}
	
	event  OnStartCrafting()
	{
		OnPlaySoundEvent("gui_crafting_craft_item");
	}
	
	// W3EE - Begin
	private var playerMoney : int;
	event  OnCraftItem( tag : name )
	{
		var price, diff : int;
		
		GetWitcherPlayer().StartInvUpdateTransaction();
		CreateItem(tag);
		GetWitcherPlayer().FinishInvUpdateTransaction();
	}
	// W3EE - End
	
	event  OnEntryPress( tag : name )
	{
	}
	
	event  OnCraftingFiltersChanged( showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		GetWitcherPlayer().SetCraftingFilters(showHasIngre, showMissingIngre, showAlreadyCrafted);
	}
	
	event  OnEmptyCheckListCloseFailed()
	{
		showNotification(GetLocStringByKeyExt("gui_missing_filter_error"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnChangePinnedRecipe( tag : name )
	{
		if (tag != '')
		{
			showNotification(GetLocStringByKeyExt("panel_shop_pinned_recipe_action"));
		}
		theGame.GetGuiManager().SetPinnedCraftingRecipe(tag);
	}

	private function GetItemRarity( itemName : name ) : int
	{
		return (int)CalculateAttributeValue(m_definitionsManager.GetItemAttributeValue(itemName, true, 'quality'));
	}

	private function GetCurrentDisplayName() : string
	{
		var temp, textLanguage : string;
		
		theGame.GetGameLanguageName(temp, textLanguage);
		if( dynamicItem || ((W3TutorialManagerUIHandlerStateW3EECrafting)theGame.GetTutorialSystem().uiHandler.GetCurrentState()).ShouldShowNames() )
		{
			if( textLanguage == "IT" )
				return GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(selectedSchematic.craftedItemName)) + " " + GetLocStringByKeyExt(abilitiesArray[selectedAbilityIndex]);
			else
				return GetLocStringByKeyExt(abilitiesArray[selectedAbilityIndex]) + " " + GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(selectedSchematic.craftedItemName));
		}
		else
		{
			return GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(selectedSchematic.craftedItemName));
		}
	}

	public function IsCompareItem() : bool
	{
		return compareItem;
	}

	private function IsDynamicSchem( schem : SCraftingSchematic ) : bool
	{
		var groupTag : name;
		var itemQuality : int;
		var isCompareItem : bool;
		
		itemQuality = GetItemRarity(schem.craftedItemName);
		groupTag = m_definitionsManager.GetItemCategory(schem.craftedItemName);
 		switch(groupTag)
		{
			case 'armor':
			case 'gloves':
			case 'pants':
			case 'boots':
			case 'steelsword':
			case 'silversword':
				isCompareItem = true;
			break;
			
			default: isCompareItem = false; break;
		}
		
		return (itemQuality < 4 && isCompareItem && m_craftingManager.IsCraftsmanType(schem.requiredCraftsmanType));
	}

	private var itemAdjustedName : name;
	private var craftingItem, compareItem : bool;
	private function AdjustItemType()
	{
		var newName, groupTag : name;
		
		craftingItem = false;
		groupTag = m_definitionsManager.GetItemCategory(selectedSchematic.craftedItemName);
 		switch(groupTag)
		{
			case 'armor':
			case 'gloves':
			case 'pants':
			case 'boots':
			case 'steelsword':
			case 'silversword':
				compareItem = true;
			break;
			
			default: compareItem = false; break;
		}
		
		selectedItemQuality = GetItemRarity(selectedSchematic.craftedItemName);
		if( selectedItemQuality < 4 && compareItem )
		{
			selectedItemQuality = m_craftingManager.GetQualityLevel(selectedSchematic.ingredients);
			newName = m_craftingManager.GetCraftedItemNameFromQualityLevel(selectedSchematic.craftedItemName, selectedItemQuality);
			if( newName != itemAdjustedName )
			{
				dynamicItem = true;
				ReplaceRecipeRequirement();
				itemAdjustedName = newName;
				ShowSelectedItemInfo(selectedSchematic.schemName);
			}
		}
		else
		{
			dynamicItem = false;
			if( groupTag == 'crafting_ingredient' )
				craftingItem = true;
			itemAdjustedName = selectedSchematic.craftedItemName;
		}
		
		SetupAbilitiesArray();
		craftingMenuContext.UpdateContext();
		m_fxSetModuleRarity.InvokeSelfOneArg(FlashArgInt(selectedItemQuality));
	}
	
	private var selectedItemQuality : int;	default selectedItemQuality = 0;
	private var selectedAbilityIndex : int;	default selectedAbilityIndex = 0;
	private var abilitiesArray : array<name>;
	private function SetupAbilitiesArray()
	{
		var groupTag : name;
		var itemType : EArmorType;
		var temp : array<name>;
		
		abilitiesArray.Clear();
		abilitiesArray.PushBack('W3EE_Regular');
		m_craftingManager.SetAbilityName('W3EE_Regular');
		itemType = Equipment().GetArmorTypeFromName(selectedSchematic.craftedItemName);
		groupTag = m_definitionsManager.GetItemCategory(selectedSchematic.craftedItemName);
		switch(groupTag)
		{
			case 'armor':
				if( itemType == EAT_Light )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterLightArmorAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalLightArmorAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Medium )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterMediumArmorAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalMediumArmorAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Heavy )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterHeavyArmorAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalHeavyArmorAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
			break;
			
			case 'gloves':
				if( itemType == EAT_Light )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterLightGlovesAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalLightGlovesAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Medium )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterMediumGlovesAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalMediumGlovesAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Heavy )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterHeavyGlovesAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalHeavyGlovesAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
			break;
			
			case 'pants':
				if( itemType == EAT_Light )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterLightPantsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalLightPantsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Medium )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterMediumPantsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalMediumPantsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Heavy )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterHeavyPantsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalHeavyPantsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
			break;
			
			case 'boots':
				if( itemType == EAT_Light )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterLightBootsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalLightBootsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Medium )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterMediumBootsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalMediumBootsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
				else
				if( itemType == EAT_Heavy )
				{
					if( selectedItemQuality >= 2 )
					{
						temp = theGame.params.GetMasterHeavyBootsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
					if( selectedItemQuality >= 3 )
					{
						temp = theGame.params.GetMagicalHeavyBootsAbilityArray();
						ArrayOfNamesAppend(abilitiesArray, temp);
					}
				}
			break;
			
			case 'steelsword':
			case 'silversword':
				if( selectedItemQuality >= 1 )
				{
					temp = theGame.params.GetCommonWeaponAbilityArray();
					ArrayOfNamesAppend(abilitiesArray, temp);
				}
				if( selectedItemQuality >= 2 )
				{
					temp = theGame.params.GetMasterworkWeaponAbilityArray();
					ArrayOfNamesAppend(abilitiesArray, temp);
				}
				if( selectedItemQuality >= 3 )
				{
					temp = theGame.params.GetMagicalWeaponAbilityArray();
					ArrayOfNamesAppend(abilitiesArray, temp);
				}
			break;
		}
		
		if( selectedAbilityIndex > abilitiesArray.Size() - 1 )
			selectedAbilityIndex = abilitiesArray.Size() - 1;
	}
	
	event OnAbilityBackward()
	{
		selectedAbilityIndex -= 1;
		if( selectedAbilityIndex < 0 )
			selectedAbilityIndex = abilitiesArray.Size() - 1;
			
		m_craftingManager.SetAbilityName(abilitiesArray[selectedAbilityIndex]);
		UpdateItems(selectedSchematic.schemName);
		if( selectedAbilityIndex == 0 )
			ShowSelectedItemInfo(selectedSchematic.schemName);
		else
			SetBonusDescription();
		RefreshItemInfo();
	}
	
	event OnAbilityForward()
	{
		selectedAbilityIndex += 1;
		if( selectedAbilityIndex > abilitiesArray.Size() - 1 )
			selectedAbilityIndex = 0;
			
		m_craftingManager.SetAbilityName(abilitiesArray[selectedAbilityIndex]);
		UpdateItems(selectedSchematic.schemName);
		if( selectedAbilityIndex == 0 )
			ShowSelectedItemInfo(selectedSchematic.schemName);
		else
			SetBonusDescription();
		RefreshItemInfo();
	}
	
	private var prevIndex : int;
	public function TutorialShowAbility()
	{
		abilitiesArray.PushBack(theGame.params.GetRandomMagicalMediumArmorAbility());
		prevIndex = selectedAbilityIndex;
		selectedAbilityIndex = abilitiesArray.Size() - 1;
		m_craftingManager.SetAbilityName(abilitiesArray[selectedAbilityIndex]);
		UpdateItems(selectedSchematic.schemName);
		SetBonusDescription();
		RefreshItemInfo();
	}
	
	public function TutorialHideAbility()
	{
		abilitiesArray.Erase(abilitiesArray.Size() - 1);
		selectedAbilityIndex = prevIndex;
		m_craftingManager.SetAbilityName(abilitiesArray[selectedAbilityIndex]);
		ShowSelectedItemInfo(selectedSchematic.schemName);
		RefreshItemInfo();
	}
	
	public function TutorialUpdateName()
	{
		ShowSelectedItemInfo(selectedSchematic.schemName);
	}
	
	private var shouldCompareItems : bool;	default shouldCompareItems = false;
	event OnToggleItemComparison()
	{
		shouldCompareItems = !shouldCompareItems;
		ShowSelectedItemInfo(selectedSchematic.schemName);
	}
	
	private var dynamicItem : bool;
	private var shiftIndex : int;
	private var selectedIngredient : int;
	private var selectedSchematic : SCraftingSchematic;
	private var selectedSchematicIndex : int;
	private var craftingMenuContext : W3CraftingMenuContext;
	private var isModuleSelected : bool;
	private var m_schematicListOriginal : array<SCraftingSchematic>;
	private var craftingException : ECraftingException;
	private var previousException : ECraftingException;
	
	private function CreateCraftingMenuContext()
	{
		if( craftingMenuContext )
			delete craftingMenuContext;
		
		craftingMenuContext = new W3CraftingMenuContext in this;
		craftingMenuContext.SetCraftingMenuRef(this);
		ActivateContext(craftingMenuContext);
	}
	
	public function GetIsModuleSelected() : bool
	{
		return isModuleSelected;
	}
	
	private var canCycleIngredient : bool;
	public function CanCycleCurrentIngredient() : bool
	{
		return isModuleSelected && canCycleIngredient;
	}
	
	public function IsDynamicItemSelected() : bool
	{
		return dynamicItem;
	}
	
	private function SetCanCycleIngredient( idx : int )
	{
		canCycleIngredient = CanCycleIngredient(idx);
		craftingMenuContext.UpdateContext();
	}
	
	event OnModuleSelected( moduleID : int, moduleBindingName : string )
	{
		if( moduleID == 1 )
		{
			isModuleSelected = true;
			if( selectedAbilityIndex == 0 )
				ShowSelectedItemInfo(selectedSchematic.schemName);
			else
				SetBonusDescription();
		}
		else
		{
			isModuleSelected = false;
			if( selectedSchematic.schemName )
				ShowSelectedItemInfo(selectedSchematic.schemName);
		}
		craftingMenuContext.UpdateContext();
	}

	private function FindSchematicID( tag : name ) : int
	{
		var i : int;
		for(i=0; i<m_schematicList.Size(); i+=1)
		{
			if( m_schematicList[i].schemName == tag )
				return i;
		}
		
		return -1;
	}

	event OnIngredientShiftAction( action : SInputAction )
	{
		if( CanCycleCurrentIngredient() )
		{
			if( action.value < 0 )
				OnIngredientShiftBackward();
			else
			if( action.value > 0 )
				OnIngredientShiftForward();
		}
	}
	
	event OnIngredientShiftForward()
	{	
		shiftIndex = 1;
		IngredientShift();
	}
	
	event OnIngredientShiftBackward()
	{
		shiftIndex = -1;
		IngredientShift();
	}

	private function IngredientShift()
	{
		var ingredientName, ingredientNameNext : name;
		
		if( isModuleSelected )
		{
			ingredientName = itemsNames[selectedIngredient];
			ingredientNameNext = ReplaceGridIngredient(selectedIngredient);
			if( ingredientNameNext != ingredientName )
			{
				ReplaceRecipeIngredient(ingredientNameNext);
				previousException = craftingException;
				craftingException = m_craftingManager.CanCraftSchematic(selectedSchematic.schemName, bCouldCraft);
				if( craftingException != previousException )
					PopulateData();
				AdjustItemType();
			}
		}
	}
	
	private function SetBonusDescription()
	{
		var tooltipObject : CScriptedFlashObject;
		var attributeTooltipArray : CScriptedFlashArray;
		var attributeTooltip : CScriptedFlashObject;
		var min, max : SAbilityAttributeValue;
		var attributes : array<name>;
		var valueString, levelColor, crafterRequirements : string;
		var isMult : bool;
		var valMin, valMax : float;
		var i : int;
		
		tooltipObject = m_flashValueStorage.CreateTempFlashObject();
		_playerInv.GetCraftedItemInfo(itemAdjustedName, tooltipObject, false);
		attributeTooltipArray = tooltipObject.CreateFlashArray();
		m_definitionsManager.GetAbilityAttributes(abilitiesArray[selectedAbilityIndex], attributes);
		for(i=0; i<attributes.Size() - 1; i+=1)
		{
			m_definitionsManager.GetAbilityAttributeValue(abilitiesArray[selectedAbilityIndex], attributes[i], min, max);
			if( min.valueAdditive != 0 || max.valueAdditive != 0 )
			{
				valMin = min.valueAdditive;
				valMax = max.valueAdditive;
				isMult = false;
			}
			else
			if( min.valueMultiplicative != 0 || max.valueMultiplicative != 0 )
			{
				valMin = min.valueMultiplicative;
				valMax = max.valueMultiplicative;
				isMult = true;
			}
			else
			if( min.valueBase != 0 || max.valueBase != 0 )
			{
				valMin = min.valueBase;
				valMax = max.valueBase;
				isMult = false;
			}
			
			if( StrContains(attributes[i], "perc") || attributes[i] == 'critical_hit_damage_bonus' || attributes[i] == 'critical_hit_chance' )
				isMult = true;
				
			if( isMult )
			{
				valMin *= 100;
				valMax *= 100;
				if(	valMin < 0 )
					valueString = NoTrailZeros(RoundTo(valMin, 1));
				else
					valueString = "+" + NoTrailZeros(RoundTo(valMin, 1));
					
				valueString += "% ";
				if( valMin != valMax )
				{
					valueString += "/ ";
					if( valMax < 0 )
						valueString += NoTrailZeros(RoundTo(valMax, 1)) + "% ";
					else
						valueString += "+" + NoTrailZeros(RoundTo(valMax, 1)) + "% ";
				}
			}
			else
			{
				if(	valMin < 0 )
					valueString = NoTrailZeros(RoundTo(valMin, 1));
				else
					valueString = "+" + NoTrailZeros(RoundTo(valMin, 1));
					
				valueString += " ";
				if( valMin != valMax )
				{
					valueString += "/ ";
					if( valMax < 0 )
						valueString += NoTrailZeros(RoundTo(valMax, 1)) + " ";
					else
						valueString += "+" + NoTrailZeros(RoundTo(valMax, 1)) + " ";
				}
			}
			attributeTooltip = tooltipObject.CreateFlashObject();
			attributeTooltip.SetMemberFlashString("name", GetAttributeNameLocStr(attributes[i], isMult));
			attributeTooltip.SetMemberFlashString("value", valueString);
			attributeTooltipArray.PushBackFlashObject(attributeTooltip);
		}
		tooltipObject.SetMemberFlashArray("attributesList", attributeTooltipArray);
		
		crafterRequirements = GetLocStringByKeyExt( CraftsmanTypeToLocalizationKey( selectedSchematic.requiredCraftsmanType ) );
		if( bCouldCraft )
		{
			if( m_craftingManager.CanCraftSchematic(selectedSchematic.schemName, bCouldCraft) == ECE_TooLowCraftsmanLevel )
			{
				levelColor = "<font color='#E34040'>";
			}
			else
				levelColor = "<font color='#949494'>";
				
			crafterRequirements += (" / " + levelColor + GetLocStringByKeyExt( CraftsmanLevelToLocalizationKey( selectedSchematic.requiredCraftsmanLevel ) ) + "</font>" );
		}
		else crafterRequirements += (" / " + GetLocStringByKeyExt( CraftsmanLevelToLocalizationKey( selectedSchematic.requiredCraftsmanLevel ) ) );
		
		tooltipObject.SetMemberFlashString("itemName", GetCurrentDisplayName());
		tooltipObject.SetMemberFlashString("crafterRequirements", crafterRequirements);
		tooltipObject.SetMemberFlashString("itemDescription", GetLocStringByKeyExt("W3EE_AddAttr"));
		m_flashValueStorage.SetFlashObject("blacksmithing.menu.crafted.item.tooltip", tooltipObject);
	}
	
	private function ReplaceRecipeRequirement() : void
	{
		selectedSchematicIndex = FindSchematicID(selectedSchematic.schemName);
		selectedSchematic.requiredCraftsmanLevel = (ECraftsmanLevel)selectedItemQuality;
		m_schematicList[selectedSchematicIndex] = selectedSchematic;
		m_craftingManager.ModSchematic(selectedSchematic, selectedSchematicIndex);
	}
	
	private function ReplaceRecipeIngredient( ingredientNameNext : name ) : void
	{
		selectedSchematicIndex = FindSchematicID(selectedSchematic.schemName);
		selectedSchematic.ingredients[selectedIngredient].itemName = ingredientNameNext;
		selectedSchematic.ingredients[selectedIngredient].quantity = GetIngredientQuantity(ingredientNameNext, selectedIngredient);
		m_schematicList[selectedSchematicIndex] = selectedSchematic;
		m_craftingManager.ModSchematic(selectedSchematic, selectedSchematicIndex);
	}
	
	private var gems, steelMineral, steelOre, steelIngot, steelPlate, silverMineral, silverOre, silverIngot, silverPlate, otherMineral, otherOre, otherIngot, otherPlate, leather, scales, cloth, fitting, wood, feather, filling, oil, tool, whetstone : array<name>;
	private function SetIngredientCategories()
	{
		var dm : CDefinitionsManagerAccessor;
		var allIngredients : array<name>;
		var i : int;
		var bigName : string;
		
		dm = theGame.GetDefinitionsManager();
		gems = 				dm.GetItemsWithTag('craft_gem');
		steelMineral = 		dm.GetItemsWithTag('craft_steel_mineral');
		steelOre = 			dm.GetItemsWithTag('craft_steel_ore');
		steelIngot = 		dm.GetItemsWithTag('craft_steel_ingot');
		steelPlate = 		dm.GetItemsWithTag('craft_steel_plate');
		silverMineral = 	dm.GetItemsWithTag('craft_silver_mineral');
		silverOre = 		dm.GetItemsWithTag('craft_silver_ore');
		silverIngot = 		dm.GetItemsWithTag('craft_silver_ingot');
		silverPlate = 		dm.GetItemsWithTag('craft_silver_plate');
		otherMineral = 		dm.GetItemsWithTag('craft_other_mineral');
		otherOre = 			dm.GetItemsWithTag('craft_other_ore');
		otherIngot = 		dm.GetItemsWithTag('craft_other_ingot');
		otherPlate = 		dm.GetItemsWithTag('craft_other_plate');
		leather = 			dm.GetItemsWithTag('craft_leather');
		scales = 			dm.GetItemsWithTag('craft_scales');
		cloth = 			dm.GetItemsWithTag('craft_cloth');
		fitting = 			dm.GetItemsWithTag('craft_fittings');
		wood = 				dm.GetItemsWithTag('craft_wood');
		feather = 			dm.GetItemsWithTag('craft_feathers');
		filling = 			dm.GetItemsWithTag('craft_filling');
		oil = 				dm.GetItemsWithTag('craft_oils');
		tool = 				dm.GetItemsWithTag('craft_tools');
		whetstone = 		dm.GetItemsWithTag('craft_whetstone');
	}
	
	private function GetIngredientQuantity( ingredientName : name, ingredientIdx : int ) : int
	{
		var ingredientQuality : int = GetItemRarity(ingredientName);
		var attributeMult : float = 1.f;
		
		if( StrContains(abilitiesArray[selectedAbilityIndex], "Common") )
			attributeMult += 0.1f;
		else
		if( StrContains(abilitiesArray[selectedAbilityIndex], "Master") )
			attributeMult += 0.25f;
		else
		if( StrContains(abilitiesArray[selectedAbilityIndex], "Magic") )
			attributeMult += 0.35f;
			
		if( /*!*/dynamicItem )
		{
			switch(ingredientQuality)
			{
				case 1:
					return RoundMath(itemsQuantityOriginal[ingredientIdx] * 2 * attributeMult);
				case 2:
					return RoundMath(itemsQuantityOriginal[ingredientIdx] * 1.5 * attributeMult);
				case 3:
					return RoundMath(itemsQuantityOriginal[ingredientIdx] * attributeMult);
				case 4:
					return Max(1, RoundMath(itemsQuantityOriginal[ingredientIdx] * 0.5 * attributeMult));
			}
		}
		else return itemsQuantityOriginal[ingredientIdx];
	}
	
	private function ReplaceGridIngredient( ingredient : int ) : name
	{
		var ingredients : CScriptedFlashArray;
		var ingredientName : name;
		
		if( ingredient >= 0 )
		{
			ingredientName = PickCompatibleIngredient(ingredient);
			if( ingredientName )
			{
				if( itemsNames[ingredient] != ingredientName )
				{
					itemsNames[ingredient] = ingredientName;
					itemsQuantity[ingredient] = GetIngredientQuantity(ingredientName, ingredient);
					ingredients = CreateItems(itemsNames);
					if( ingredients )
						m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, ingredients);
				}
				else showNotification(GetLocStringByKeyExt("primer_noingredient"));
			}
			else showNotification(GetLocStringByKeyExt("primer_noingredient"));
		}
		
		return ingredientName;
	}
	
	private function CanCycleIngredient( ingredient : int ) : bool
	{
		if( dynamicItem )
		{
			if( gems.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( steelMineral.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( steelOre.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( steelIngot.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( steelPlate.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( silverMineral.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( silverOre.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( silverIngot.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( silverPlate.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( otherMineral.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( otherOre.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( otherIngot.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( otherPlate.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( leather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( scales.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( cloth.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( fitting.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( wood.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( feather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( filling.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( oil.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( tool.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
			if( whetstone.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				return true;
			else
				return false;
		}
		else
		{
			//Kolaris - Crafting Restrictions
			if( m_definitionsManager.GetItemCategory(m_schematicListOriginal[selectedSchematicIndex].craftedItemName) == 'tool' )
				return false;
			else if( GetItemRarity(m_schematicListOriginal[selectedSchematicIndex].craftedItemName) >= 4 )
				return false;
			else
			if( craftingItem )
			{
				if( wood.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( feather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( oil.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
					return false;
			}
			else
			{
				if( cloth.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( fitting.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( wood.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( feather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( filling.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( oil.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( tool.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
				if( whetstone.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					return true;
				else
					return false;
			}
		}
	}
	
	private function PickCompatibleIngredient( ingredient : int ) : name
	{	
		var ingredientName : name;
		
		if( dynamicItem )
		{
			if( gems.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(gems, ingredient);
			else
			if( steelMineral.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(steelMineral, ingredient);
			else
			if( steelOre.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(steelOre, ingredient);
			else
			if( steelIngot.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(steelIngot, ingredient);
			else
			if( steelPlate.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(steelPlate, ingredient);
			else
			if( silverMineral.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(silverMineral, ingredient);
			else
			if( silverOre.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(silverOre, ingredient);
			else
			if( silverIngot.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(silverIngot, ingredient);
			else
			if( silverPlate.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(silverPlate, ingredient);
			else
			if( otherMineral.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(otherMineral, ingredient);
			else
			if( otherOre.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(otherOre, ingredient);
			else
			if( otherIngot.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(otherIngot, ingredient);
			else
			if( otherPlate.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(otherPlate, ingredient);
			else
			if( leather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(leather, ingredient);
			else
			if( scales.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(scales, ingredient);
			else
			if( cloth.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(cloth, ingredient);
			else
			if( fitting.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(fitting, ingredient);
			else
			if( wood.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(wood, ingredient);
			else
			if( feather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(feather, ingredient);
			else
			if( filling.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(filling, ingredient);
			else
			if( oil.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(oil, ingredient);
			else
			if( tool.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(tool, ingredient);
			else
			if( whetstone.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
				ingredientName = GetArrayNextIngredient(whetstone, ingredient);
			else
				ingredientName = m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName;
		}
		else
		{
			if( craftingItem )
			{
				if( wood.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(wood, ingredient);
				else
				if( feather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(feather, ingredient);
				else
				if( oil.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(oil, ingredient);
				else
					ingredientName = m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName;
			}
			else
			{
				if( cloth.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(cloth, ingredient);
				else
				if( fitting.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(fitting, ingredient);
				else
				if( wood.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(wood, ingredient);
				else
				if( feather.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(feather, ingredient);
				else
				if( filling.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(filling, ingredient);
				else
				if( oil.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(oil, ingredient);
				else
				if( tool.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(tool, ingredient);
				else
				if( whetstone.Contains(m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName) )
					ingredientName = GetArrayNextIngredient(whetstone, ingredient);
				else
					ingredientName = m_schematicListOriginal[selectedSchematicIndex].ingredients[ingredient].itemName;
			}
		}
		
		return ingredientName;
	}
	
	private function GetArrayNextIngredient( source : array<name>, ingredient : int ) : name
	{
		var index, invCount, totalIngredients : int;
		var ingredients : array<name>;
		var inShop, invCheck, shouldSkip : bool;
		var vendorItems : array< SItemUniqueId >;
		var i : int;
		
		inShop = IsInShop();
		shouldSkip = true;
		
		ingredients = source;
		totalIngredients = ingredients.Size();
		index = ingredients.FindFirst(itemsNames[ingredient]);
		for(i=shiftIndex; shouldSkip; i+=shiftIndex)
		{
			if( shiftIndex > 0 && index >= totalIngredients )
				index = 0;
			else
			if( shiftIndex < 0 && index < 0 )
				index = ingredients.Size() - 1;
				
			invCount = Equipment().GetItemQuantityByNameForCrafting(ingredients[index]);
			if( inShop )
			{					
				vendorItems = m_npcInventory.GetItemsByName(ingredients[index]);
				invCheck = vendorItems.Size() > 0 || invCount > 0;
			}
			else invCheck = invCount > 0;
			
			shouldSkip = (!invCheck) || (itemsNames[ingredient] == ingredients[index]) || (selectedSchematic.craftedItemName == ingredients[index]);
			if( shouldSkip )
			{
				index += shiftIndex;
				if( Abs(i) == totalIngredients )
				{
					return itemsNames[ingredient];
				}
			}
		}
		
		return ingredients[index];
	}
	
	event OnEntrySelected( tag : name ) 
	{
		var craftBuy : W3TutorialManagerUIHandlerStateCraftingBuy;
		var i : int;
		
		if (tag != '')
		{
			selectedSchematicIndex = FindSchematicID(tag);
			if( selectedSchematic != m_schematicList[selectedSchematicIndex] )
			{
				selectedAbilityIndex = 0;
				selectedSchematic = m_schematicList[selectedSchematicIndex];
				craftingException = m_craftingManager.CanCraftSchematic(selectedSchematic.schemName, bCouldCraft);
				SetupAbilitiesArray();
				UpdateItems(tag);
			}
			m_fxHideContent.InvokeSelfOneArg(FlashArgBool(true));
			super.OnEntrySelected(tag);
		}
		else
		{		
			lastSentTag = '';
			currentTag = '';
			m_fxHideContent.InvokeSelfOneArg(FlashArgBool(false));
		}
		
		if( ShouldProcessTutorial( 'TutorialCraftingBuy' ) )
		{
			for( i=0; i<itemsNames.Size(); i+=1 )
			{
				if( m_npcInventory.GetItemQuantityByName( itemsNames[i] ) > 0 )
				{
					craftBuy = (W3TutorialManagerUIHandlerStateCraftingBuy) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
					if( craftBuy )
					{
						craftBuy.OnCanSellSomething();
					}
					break;
				}
			}
		}
	}
	
	event  OnShowCraftedItemTooltip( tag : name )
	{
	}
	
	event  OnBuyIngredient( item : int, isLastItem : bool ) : void
	{
		var vendorItemId   : SItemUniqueId;	
		var vendorItems    : array< SItemUniqueId >;
		
		
		var reqQuantity    : int;
		var itemName       : name;
		var newItemID      : SItemUniqueId;
		
		if( m_npcInventory )
		{
			itemName = itemsNames[ item - 1 ];
			vendorItems = m_npcInventory.GetItemsByName( itemName );
			
			if( vendorItems.Size() > 0 )
			{
				vendorItemId = vendorItems[0];
				
				
				
				
				BuyIngredient( vendorItemId, 1, isLastItem );
				OnPlaySoundEvent( "gui_inventory_buy" );
			}
		}
	}
	
	event OnCategoryOpened( categoryName : name, opened : bool )
	{
		var player : W3PlayerWitcher;
		var nullschem : SCraftingSchematic;
		
		player = GetWitcherPlayer();
		if ( !player )
		{
			return false;
		}
		if ( opened )
		{
			player.AddExpandedCraftingCategory( categoryName );
		}
		else
		{
			player.RemoveExpandedCraftingCategory( categoryName );
		}
		
		selectedSchematic = nullschem;
		selectedItemQuality = 0;
		
		super.OnCategoryOpened( categoryName, opened );
	}
	
	private function IsInShop() : bool
	{
		var l_obj		 			: IScriptable;		
		var l_initData				: W3InventoryInitData;
		var m_npc					: CNewNPC;
		
		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
		{
			m_npc = (CNewNPC)l_initData.containerNPC;
		}
		else
		{
			m_npc = (CNewNPC)l_obj;
		}
		
		return m_npc;
	}
	
	public function BuyIngredient( itemId : SItemUniqueId, quantity : int, isLastItem : bool ) : void
	{
		var newItemID   : SItemUniqueId;
		var result 		: bool;
		var itemName	: name;
		var notifText	: string;
		var itemLocName : string;
		
		itemLocName = m_npcInventory.GetItemLocNameByID( itemId );
		itemName = m_npcInventory.GetItemName( itemId );
		theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_BOUGHT, itemName, quantity );
		result = m_shopInvComponent.GiveItem( itemId, _playerInv, quantity, newItemID );
		
		if( result )
		{
			notifText = GetLocStringByKeyExt("panel_blacksmith_items_added") + ":" + quantity + " x " + itemLocName;
			
			if (isLastItem)
			{
				PopulateData();
			}
		}
		else
		{
			notifText = GetLocStringByKeyExt( "panel_shop_notification_not_enough_money" );
		}
		
		showNotification( notifText );
		
		UpdateMerchantData(m_npc);
		UpdateItemsCounter();
		
		previousException = craftingException;
		craftingException = m_craftingManager.CanCraftSchematic(selectedSchematic.schemName, bCouldCraft);
		if( craftingException != previousException )
			PopulateData();
		
		if (m_lastSelectedTag != '')
		{
			UpdateItems(m_lastSelectedTag);
		}
	}
	
	private function OpenQuantityPopup( itemId : SItemUniqueId, reqValue: int, maxValue : int )
	{
		var invItem : SInventoryItem;
		
		if ( _quantityPopupData )
		{
			delete _quantityPopupData;
		}
		
		_quantityPopupData = new QuantityPopupData in this;
		_quantityPopupData.itemId = itemId;		
		_quantityPopupData.currentValue = reqValue;
		_quantityPopupData.maxValue = maxValue;
		_quantityPopupData.craftingRef = this;
		_quantityPopupData.actionType = QTF_Buy;
		
		RequestSubMenu( 'PopupMenu', _quantityPopupData );
	}
	
	
	public function FillItemInformation(flashObject : CScriptedFlashObject, index:int) : void
	{		
		super.FillItemInformation( flashObject, index );
		
		if( m_npcInventory )
		{
			flashObject.SetMemberFlashInt( "vendorQuantity", m_npcInventory.GetItemQuantityByName( itemsNames[index] ) );
		}
		
		flashObject.SetMemberFlashInt( "reqQuantity", itemsQuantity[index] );
	}
	
	private function ColorStringRarity( str : string, rarity : int ) : string
	{
		var resultString : string;
		
		switch(rarity)
		{
			case 1:
				return "<font color='#8e8b8a'>" + GetLocStringById(2116943218) + "</font> - " + str;
			case 2:
				return "<font color='#4e75e5'>" + GetLocStringById(2116943219) + "</font> - " + str;
			case 3:
				return "<font color='#c1b601'>" + GetLocStringById(2116943220) + "</font> - " + str;
			case 4:
				return "<font color='#ca610c'>" + GetLocStringByKeyExt("panel_inventory_item_rarity_type_relic") + "</font> - " + str;
			case 5:
				return "<font color='#186618'>" + GetLocStringById(2116943221) + "</font> - " + str;
			default:
				return str;
		}
	}
	
	protected function GetTooltipData(item : int, compareItemType : int, out resultData : CScriptedFlashObject ) : void
	{
		var vendorItemId   : SItemUniqueId;		
		var vendorItems    : array< SItemUniqueId >;
		var itemQuality : int;
		var vendorQuantity : int;
		var vendorPrice    : int;
		var itemName       : name;
		var language 	   : string;
		var audioLanguage  : string;
		var locStringBuy   : string;
		var locStringPrice : string;
		
		// W3EE - Begin
		var itemCategory : name;
		
		selectedIngredient = item - 1;
		SetCanCycleIngredient(selectedIngredient);
		// W3EE - End
		
		theGame.GetGameLanguageName( audioLanguage, language);	
		
		super.GetTooltipData( item, compareItemType, resultData );
		
		item -= 1;
		itemQuality = GetItemRarity(itemsNames[item]);
		resultData.SetMemberFlashString("ItemType", ColorStringRarity(GetItemCategoryLocalisedString(m_definitionsManager.GetItemCategory(itemsNames[item])), itemQuality));
		if( m_npcInventory )
		{
			itemName = itemsNames[ item ];
			
			vendorItems = m_npcInventory.GetItemsByName( itemName );
			
			if( vendorItems.Size() > 0 )
			{
				vendorItemId = vendorItems[0];
				vendorQuantity = m_npcInventory.GetItemQuantity( vendorItemId );
				// W3EE - Begin
				vendorPrice = m_npcInventory.GetItemSellPrice( vendorItemId );
				// W3EE - End
				
				
				resultData.SetMemberFlashNumber( "vendorQuantity", vendorQuantity );
				resultData.SetMemberFlashNumber( "vendorPrice", vendorPrice );
				
				locStringBuy = GetLocStringByKeyExt( "panel_inventory_quantity_popup_buy" );
				
				if( language != "AR")
				{
					resultData.SetMemberFlashString( "vendorInfoText", locStringBuy + " (" +  vendorPrice + ")" );
				}
				else
				{
					locStringPrice = " *" +  vendorPrice + "*" ;
					resultData.SetMemberFlashString( "vendorInfoText", locStringPrice + locStringBuy  );
				}
			}
		}
	}

	function CreateItem( schematic : name  )
	{
		var item : SItemUniqueId;
		var result : ECraftingException;
		var craftedItemNameLoc : string;
		var actualSchematic : SCraftingSchematic;
		
		result = ECE_CookNotAllowed;
		
		if( bCouldCraft )
		{
			result = m_craftingManager.Craft( schematic, item, itemAdjustedName );
			
			if (result == ECE_NoException)
			{
				OnPlaySoundEvent("gui_crafting_craft_item_complete");
				if( selectedAbilityIndex != 0 )
					_inv.AddItemCraftedAbility(item, abilitiesArray[selectedAbilityIndex], false);
					
				PopulateData();
				UpdateItems(schematic);
				craftedItemNameLoc = GetLocStringByKeyExt(m_definitionsManager.GetItemLocalisationKeyName(itemAdjustedName));
				showNotification(GetLocStringByKeyExt("panel_crafting_successfully_crafted") + ": " + craftedItemNameLoc);
				if (m_npc)
				{
					UpdateMerchantData(m_npc);
				}
				UpdateItemsCounter();
			}
		}
		
		if (result != ECE_NoException)
		{
			showNotification(GetLocStringByKeyExt(CraftingExceptionToString(result)));
			OnPlaySoundEvent("gui_global_denied");
		}
	}
	
	private function UpdateItemsCounter()
	{		
		var commonMenu 	: CR4CommonMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if( commonMenu )
		{
			commonMenu.UpdateItemsCounter();
			commonMenu.UpdatePlayerOrens();
		}
	}

	private function PopulateData()
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_DataFlashArray 		: CScriptedFlashArray;
		
		var wrongCraftsmanItems		: array<CScriptedFlashObject>;
		var schematic				: SCraftingSchematic;
		var schematicName			: name;		
		var i, length				: int;		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		var canCraftResult			: ECraftingException;
		var minQuality, maxQuality  : int;
		var playerItems, horseItems  : int;
		var min, max : SAbilityAttributeValue;
		var sortString : string;
		var sortTier : int;
		
		length = m_schematicList.Size();
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		for(i=0; i<length; i+=1)
		{	
			schematicName = m_schematicList[i].schemName;
			if(	m_craftingManager.GetSchematic(schematicName, schematic) )
			{
				l_GroupTag = m_definitionsManager.GetItemCategory( schematic.craftedItemName );
				l_GroupTitle = GetLocStringByKeyExt(  "item_category_" + l_GroupTag  );
				l_Title = GetLocStringByKeyExt( m_definitionsManager.GetItemLocalisationKeyName( schematic.craftedItemName ) ) ;	
				m_definitionsManager.GetItemAttributeValueNoRandom(schematic.craftedItemName, false, 'quality', min, max );
				
				if( l_GroupTag == 'armor' || l_GroupTag == 'gloves' || l_GroupTag == 'pants' || l_GroupTag == 'boots' || l_GroupTag == 'steelsword' || l_GroupTag == 'silversword' ) 
				{
					if( min.valueAdditive == 5 )
					{
						sortString = "<font color=\"#a09d9a\">[</font><font color=\"#4db323\">W</font> | <font color=\"#EBEBEB\">";
						sortTier = StringToInt(StrRight(schematic.craftedItemName, 1));
						if( l_GroupTag == 'armor' || l_GroupTag == 'steelsword' || l_GroupTag == 'silversword' )
							sortTier += 1;
						sortString += sortTier + "</font>] ";
						
						l_Title = sortString + l_Title;
					}
					else
					if( min.valueAdditive == 4 )
						l_Title = "<font color=\"#a09d9a\">[</font><font color=\"#BF6813\">R</font>] " + l_Title;
					else
						l_Title = "<font color=\"#BFB0B0\"></font>" + l_Title;
				}
				
				if( l_GroupTag == 'upgrade' )
				{
					if( StrContains(schematic.craftedItemName, "Glyph") )
						sortString = "<font color=\"#000000\"></font>";
					else
						sortString = "<font color=\"#000001\"></font>";
						
					if( StrContains(schematic.craftedItemName, "lesser") )
						sortString += "<font color=\"#000000\"></font>";
					else
					if( StrContains(schematic.craftedItemName, "greater") )
						sortString += "<font color=\"#000002\"></font>";
					else
						sortString += "<font color=\"#000001\"></font>";
						
					l_Title = sortString + l_Title;
				}
				
				if( l_GroupTag == 'armor' )
					l_GroupTitle = "<font color=\"#0000000\"></font>" + l_GroupTitle;
				else
				if( l_GroupTag == 'gloves' )
					l_GroupTitle = "<font color=\"#0000001\"></font>" + l_GroupTitle;
				else
				if( l_GroupTag == 'pants' )
					l_GroupTitle = "<font color=\"#0000002\"></font>" + l_GroupTitle;
				else
				if( l_GroupTag == 'boots' )
					l_GroupTitle = "<font color=\"#0000003\"></font>" + l_GroupTitle;
				else
				if( l_GroupTag == 'steelsword' )
					l_GroupTitle = "<font color=\"#0000004\"></font>" + l_GroupTitle;
				else
				if( l_GroupTag == 'silversword' )
					l_GroupTitle = "<font color=\"#0000005\"></font>" + l_GroupTitle;
				else
					l_GroupTitle = "<font color=\"#000006\"></font>" + l_GroupTitle;
				
				l_IsNew	= false;
				l_Tag = schematic.schemName;
				l_IconPath = m_definitionsManager.GetItemIconPath(schematic.craftedItemName);
				canCraftResult = m_craftingManager.CanCraftSchematic(schematicName, bCouldCraft);
				thePlayer.inv.GetItemQualityFromName(schematic.craftedItemName, minQuality, maxQuality);
				if( GetFHUDConfig().showItemCountWhenCrafting )
				{
					if( theGame.GetDefinitionsManager().IsItemSingletonItem(schematic.craftedItemName) )
					{
						playerItems = thePlayer.inv.SingletonItemGetAmmo(thePlayer.inv.GetItemId(schematic.craftedItemName));
						horseItems = GetWitcherPlayer().GetHorseManager().GetInventoryComponent().SingletonItemGetAmmo(GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemId(schematic.craftedItemName));
					}
					else
					{
						playerItems = thePlayer.inv.GetItemQuantityByName(schematic.craftedItemName);
						horseItems = GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemQuantityByName(schematic.craftedItemName);
					}
					
					if( playerItems + horseItems > 0 ) 
					{
						l_Title += " (<font color=\"#EBEBEB\">" + IntToString(playerItems);
						if (horseItems > 0)
							l_Title += " + " + IntToString(horseItems);
						l_Title += "</font>)";
					}	
					
					if( schematic.craftedItemCount > 1 )
						l_Title += " | " + schematic.craftedItemCount + " |";
				}
				
				if( thePlayer.newCraftables.Contains(l_Tag) )
					l_IsNew = true;
					
				if( m_guiManager.GetShowItemNames() )
					l_Title = l_Title + "<br><font color=\"#FFDB00\">'" + schematic.schemName + "'</font>";
					
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", "" );
				l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
				l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
				l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_GroupTag) );
				l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened",  false );
				l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
				l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
				l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
				l_DataFlashObject.SetMemberFlashString(  "iconPath", l_IconPath );
				l_DataFlashObject.SetMemberFlashInt( "rarity", minQuality );
				l_DataFlashObject.SetMemberFlashBool( "isSchematic", true );
				l_DataFlashObject.SetMemberFlashInt( "canCookStatus", canCraftResult);
				l_DataFlashObject.SetMemberFlashBool("isDynamicItem", IsDynamicSchem(schematic));
				if( canCraftResult != ECE_NoException )
					l_DataFlashObject.SetMemberFlashString( "cantCookReason", GetLocStringByKeyExt(CraftingExceptionToString(canCraftResult)) );
				else
					l_DataFlashObject.SetMemberFlashString( "cantCookReason", "" );
					
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject); 
			}
		}
		
		if( l_DataFlashArray.GetLength() > 0 )
		{
			m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME, l_DataFlashArray );
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
	}
	
	function UpdateMerchantData(targetNpc : CNewNPC) : void
	{
		var l_merchantData	: CScriptedFlashObject;
		
		l_merchantData = m_flashValueStorage.CreateTempFlashObject();
		GetNpcInfo((CGameplayEntity)targetNpc, l_merchantData);
		m_flashValueStorage.SetFlashObject("crafting.merchant.info", l_merchantData);
	}

	function  UpdateDescription( tag : name )
	{
		var description : string;
		var title : string;
		
		var schematic : SCraftingSchematic;
		
		
		
		m_lastSelectedTag = tag;
		m_craftingManager.GetSchematic(tag,schematic);
		
		title = GetLocStringByKeyExt(m_definitionsManager.GetItemLocalisationKeyName(schematic.craftedItemName));	
		description = m_definitionsManager.GetItemLocalisationKeyDesc(schematic.craftedItemName);	
		if(description == "" || description == "<br>" || description == "#")
		{
			description = "panel_journal_quest_empty_description";
		}
		description = GetLocStringByKeyExt(description) + "BBBBBBB";	
		
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".title",title);
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".text",description);	
	}	
	
	// W3EE - Begin
	private function GetItemQuantity( id : int ) : int
	{
		return Equipment().GetItemQuantityByNameForCrafting(itemsNames[id]);
	}
	// W3EE - End
	
	function  UpdateItems( tag : name )
	{
		var itemsFlashArray			: CScriptedFlashArray;
		var i : int;
		
		itemsNames.Clear();
		itemsQuantity.Clear();
		itemsQuantityOriginal.Clear();
		
		selectedSchematicIndex = FindSchematicID(tag);
		selectedSchematic = m_schematicList[selectedSchematicIndex];
		for(i=0; i<selectedSchematic.ingredients.Size(); i+=1)
		{
			itemsNames.PushBack(selectedSchematic.ingredients[i].itemName);
			itemsQuantityOriginal.PushBack(m_schematicListOriginal[selectedSchematicIndex].ingredients[i].quantity);
			itemsQuantity.PushBack(GetIngredientQuantity(selectedSchematic.ingredients[i].itemName, i));
			selectedSchematic.ingredients[i].quantity = itemsQuantity[i];
		}
		m_schematicList[selectedSchematicIndex] = selectedSchematic;
		m_craftingManager.ModSchematic(selectedSchematic, selectedSchematicIndex);
		
		itemsFlashArray = CreateItems(itemsNames);
		
		if( itemsFlashArray )
		{
			m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME_SUBLIST, itemsFlashArray );
		}
		
		AdjustItemType();
		ShowSelectedItemInfo(tag);
	}
	
	protected function ShowSelectedItemInfo( tag : name ):void
	{
		var schematic 			: SCraftingSchematic;
		var l_DataFlashObject	: CScriptedFlashObject;
		var itemNameLoc			: string;
		var imgPath				: string;
		var canCraft			: bool;
		var itemType 			: EInventoryFilterType;
		var gridSize			: int;
		var itemName			: name;
		var itemCost			: int;
		var priceStr			: string;
		var crafterDesc			: string;
		var levelColor			: string;
		var crafterRequirements : string;
		var rarity				: int;
		var enhancementSlots	: int;
		var canCraftResult		: ECraftingException;
		var wrongCraftsmanLevel : bool;
		var wrongCraftsmanType  : bool;
		
		itemName = itemAdjustedName;
		m_craftingManager.GetSchematic(tag, schematic);
		
		CraftsmanTypeToLocalizationKey(schematic.requiredCraftsmanType);
		CraftsmanLevelToLocalizationKey(schematic.requiredCraftsmanLevel);
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		_playerInv.GetCraftedItemInfo(itemName, l_DataFlashObject, shouldCompareItems);
		
		canCraftResult = m_craftingManager.CanCraftSchematic(tag, bCouldCraft);
		canCraft = canCraftResult == ECE_NoException;
		
		crafterRequirements = GetLocStringByKeyExt( CraftsmanTypeToLocalizationKey( schematic.requiredCraftsmanType ) );
		
		wrongCraftsmanLevel = false;
		wrongCraftsmanType = false;
		if (bCouldCraft)
		{
			if(canCraftResult == ECE_TooLowCraftsmanLevel)
			{
				levelColor = "<font color='#E34040'>";
				wrongCraftsmanLevel = true;
			}
			else
			{
				levelColor = "<font color='#949494'>";
			}
			if (canCraftResult == ECE_WrongCraftsmanType)
			{
				wrongCraftsmanType = true;
			}
			crafterRequirements += (" / " + levelColor + GetLocStringByKeyExt( CraftsmanLevelToLocalizationKey( schematic.requiredCraftsmanLevel ) ) + "</font>" );
		}
		else
		{
			crafterRequirements += (" / " + GetLocStringByKeyExt( CraftsmanLevelToLocalizationKey( schematic.requiredCraftsmanLevel ) ) );
		}
		
		m_fxSetMerchantCheck.InvokeSelfTwoArgs(FlashArgBool(wrongCraftsmanLevel), FlashArgBool(wrongCraftsmanType));
		
		itemNameLoc = GetCurrentDisplayName();
		crafterDesc = l_DataFlashObject.GetMemberFlashString("itemDescription");
		l_DataFlashObject.SetMemberFlashString("itemName", itemNameLoc);
		l_DataFlashObject.SetMemberFlashString("crafterRequirements", crafterRequirements);
		l_DataFlashObject.SetMemberFlashString("itemDescription", crafterDesc);
		
		rarity = l_DataFlashObject.GetMemberFlashInt("rarityId");
		enhancementSlots = l_DataFlashObject.GetMemberFlashInt("enhancementSlots");
		
		m_flashValueStorage.SetFlashObject("blacksmithing.menu.crafted.item.tooltip", l_DataFlashObject);
		
		imgPath = m_definitionsManager.GetItemIconPath(itemName);
		itemType = m_definitionsManager.GetFilterTypeByItem(schematic.craftedItemName);
		if (itemType == IFT_Weapons || itemType == IFT_Armors)
			gridSize = 2;
		else
			gridSize = 1;
		
		if (bCouldCraft)
		{
			itemCost = m_craftingManager.GetCraftingCost(tag);
			
			if (thePlayer.GetMoney() < itemCost)
			{
				priceStr += "<font color=\"#d31717\">" + itemCost + "</font>";
			}
			else
			{
				priceStr += "<font color=\"#ffffff\">" + itemCost + "</font>";
			}
		}
		else
		{
			priceStr = "";
		}
		
		//---=== modFriendlyHUD ===---
		if (thePlayer.newCraftables.Contains(schematic.schemName))
		{
			thePlayer.newCraftables.Remove(schematic.schemName);
		}
		//---=== modFriendlyHUD ===---
		
		m_fxSetCraftedItem.InvokeSelfEightArgs(FlashArgUInt(NameToFlashUInt(schematic.schemName)), FlashArgString(itemNameLoc), FlashArgString(imgPath), FlashArgBool(canCraft), FlashArgInt(gridSize), FlashArgString(priceStr), FlashArgInt(rarity), FlashArgInt(enhancementSlots));
	}
	
	protected function RefreshItemInfo() : void
	{
		var l_DataFlashObject	: CScriptedFlashObject;
		var itemType 			: EInventoryFilterType;
		var gridSize			: int;
		var itemCost			: int;
		var rarity				: int;
		var enhancementSlots	: int;
		var priceStr			: string;
		var imgPath				: string;
		var itemNameLoc			: string;
		var schematic 			: SCraftingSchematic;
		var canCraftResult		: ECraftingException;
		var canCraft			: bool;
		
		m_craftingManager.GetSchematic(selectedSchematic.schemName, schematic);
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		_playerInv.GetCraftedItemInfo(itemAdjustedName, l_DataFlashObject, false);
		canCraftResult = m_craftingManager.CanCraftSchematic(selectedSchematic.schemName, bCouldCraft);
		canCraft = canCraftResult == ECE_NoException;
		
		itemNameLoc = GetCurrentDisplayName();
		imgPath = m_definitionsManager.GetItemIconPath(itemAdjustedName);
		itemType = m_definitionsManager.GetFilterTypeByItem(schematic.craftedItemName);
		if( itemType == IFT_Weapons || itemType == IFT_Armors )
			gridSize = 2;
		else
			gridSize = 1;
			
		rarity = l_DataFlashObject.GetMemberFlashInt("rarityId");
		enhancementSlots = l_DataFlashObject.GetMemberFlashInt("enhancementSlots");
		if (bCouldCraft)
		{
			itemCost = m_craftingManager.GetCraftingCost(schematic.schemName);
			if( thePlayer.GetMoney() < itemCost )
				priceStr += "<font color=\"#d31717\">" + itemCost + "</font>";
			else
				priceStr += "<font color=\"#ffffff\">" + itemCost + "</font>";
		}
		else priceStr = "";
		
		m_fxSetCraftedItem.InvokeSelfEightArgs(FlashArgUInt(NameToFlashUInt(schematic.schemName)), FlashArgString(itemNameLoc), FlashArgString(imgPath), FlashArgBool(canCraft), FlashArgInt(gridSize), FlashArgString(priceStr), FlashArgInt(rarity), FlashArgInt(enhancementSlots));
	}	
	
	public final function GetCraftsmanComponent() : W3CraftsmanComponent
	{
		return _craftsmanComponent;
	}
	
	event  OnSetMouseInventoryComponent(moduleBinding : string, slotId:int)
	{
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
}
