/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3LootPopupData extends CObject
{
	var targetContainer : W3Container;
}

class CR4LootPopup extends CR4PopupBase
{
	private const var KEY_LOOT_ITEM_LIST :string; default KEY_LOOT_ITEM_LIST = "LootItemList";
	
	private var _container 				: W3Container;
	private var m_fxSetWindowTitle 		: CScriptedFlashFunction;
	private var m_fxSetSelectionIndex	: CScriptedFlashFunction;
	private var m_fxSetWindowScale		: CScriptedFlashFunction;
	private var m_fxResizeBackground	:CScriptedFlashFunction;
	private var m_indexToSelect			: int; 							default m_indexToSelect = 0;
	private var safeLock 				: int;							default safeLock = -1;
	private var inputContextSet			: bool; 						default inputContextSet = false;
	// W3EE - Begin
	private var activeContainers		: array<W3Container>;
	private var inventoryComponents		: array<CInventoryComponent>;
	// W3EE - End
	
	event  OnConfigUI()
	{
		var lootPopupData : W3LootPopupData;
		var targetSize : float;
		
		super.OnConfigUI();
		
		setupFunctions();
		
		lootPopupData = (W3LootPopupData)GetPopupInitData();
		
		theGame.ForceUIAnalog(true);
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		
		
		if (lootPopupData && lootPopupData.targetContainer && !theGame.IsDialogOrCutscenePlaying() && !theGame.GetGuiManager().IsAnyMenu())
		{
			theInput.StoreContext( 'EMPTY_CONTEXT' );
			inputContextSet = true;
			
			
			
			theSound.SoundEvent("gui_loot_popup_open");
			
			_container = lootPopupData.targetContainer;
			
			// W3EE - Begin
			ContainerSetup();
			// W3EE - End
			
			PopulateData();
			
			SignalLootingReactionEvent();
			
			if (StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('Hud', 'HudSize'), 0) == 0)
			{
				targetSize = 0.85;
				if (theInput.LastUsedPCInput())
				{
					theGame.MoveMouseTo(0.4, 0.63);
				}
			}
			else
			{
				targetSize = 1;
				if (theInput.LastUsedPCInput())
				{
					theGame.MoveMouseTo(0.4, 0.58);
				}
			}
			
			m_fxSetWindowScale.InvokeSelfOneArg(FlashArgNumber(targetSize));
		}
		else
		{
			ClosePopup();
		}
	}
	
	// W3EE -  Begin
	private function GetContainerItemsCount() : int
	{
		var itemCount, totalCount, i, j : int;
		var containerItems : array<SItemUniqueId>;
		
		for(i=0; i<activeContainers.Size(); i+=1)
		{
			activeContainers[i].GetInventory().GetAllItems(containerItems);
			for(j=0; j<containerItems.Size(); j+=1)
			{
				if( activeContainers[i].GetInventory().ItemHasTag(containerItems[j], theGame.params.TAG_DONT_SHOW) && !activeContainers[i].GetInventory().ItemHasTag(containerItems[j], 'Lootable') )
					itemCount += 1;
			}
			totalCount += containerItems.Size() - itemCount;
		}
		
		return totalCount;
	}
	
	private function ContainerSetup()
	{
		var gameplayEntity : array<CGameplayEntity>;
		var containers : array<W3Container>;
		var container  : W3Container;
		var herbs : array<SItemUniqueId>;
		var schematicName : name;
		var bonusQuantity : int;
		var initialHeight, containerHeight : Vector;
		var ent : CEntity;
		var i, j : int;
		var skip : bool;
		
		activeContainers.Clear();
		activeContainers.PushBack(_container);
		
		if( (W3HouseDecorationBase)_container )
			return;
			
		if( (W3Herb)_container )
			FindGameplayEntitiesInRange(gameplayEntity, thePlayer, Options().AreaLootingRadius(), 100,, FLAG_ExcludePlayer,, 'W3Herb');
		else
		if( (W3ActorRemains)_container )
			FindGameplayEntitiesInRange(gameplayEntity, thePlayer, Options().AreaLootingRadius(), 100,, FLAG_ExcludePlayer,, 'W3ActorRemains');
		else
		{
			skip = true;
			FindGameplayEntitiesInRange(gameplayEntity, thePlayer, Options().AreaLootingRadius(), 100,, FLAG_ExcludePlayer,, 'W3Container');
		}
		
		initialHeight = _container.GetWorldPosition();
		for(i=0; i<gameplayEntity.Size(); i+=1)
		{
			ent = (CEntity)gameplayEntity[i];
			container = (W3Container)ent;
			if( !container.disableStealing || container.GetInventory() == _container.GetInventory() || container.lockedByKey || container.focusModeHighlight == FMV_Clue || container.factOnContainerOpened != "" || container.HasQuestItem() || container.disableLooting || !container.GetComponent('Loot').IsEnabled() )
				continue;
				
			if( !((CActor)ent) && gameplayEntity[i].GetInventory().GetItemCount() > 0 )
			{
				if( skip && ((W3Herb)container || (W3ActorRemains)container) )
					continue;
					
				containerHeight = container.GetWorldPosition();
				if( initialHeight.Z - containerHeight.Z > 2.f || initialHeight.Z - containerHeight.Z < -2.f )
					continue;
					
				activeContainers.PushBack(container);
				container.OnInteractionActivated("Loot", thePlayer);
			}
		}
		
		if( (W3Herb)_container )
		{
			for(i=0; i<activeContainers.Size(); i+=1)
			{
				if( !activeContainers[i].addedBonusHerbs )
				{
					activeContainers[i].addedBonusHerbs = true;
					activeContainers[i].GetInventory().GetAllItems(herbs);
					for(j=0; j<herbs.Size(); j+=1)
					{
						bonusQuantity = RandRange(3,1) + RandRange(2,1) - RandRange(2,0) + RandRange(4,0);
						//Kolaris - Alchemical Studies
						if( thePlayer.CanUseSkill(S_Perk_04) )
							bonusQuantity += RandRange(3,1);
						activeContainers[i].GetInventory().AddAnItem(activeContainers[i].GetInventory().GetItemName(herbs[j]), bonusQuantity);
					}
				}
			}
		}
		//Kolaris - Alchemical Studies
		if( (W3ActorRemains)_container && thePlayer.CanUseSkill(S_Perk_04) )
		{
			for(i=0; i<activeContainers.Size(); i+=1)
			{
				if( !activeContainers[i].addedBonusHerbs )
				{
					activeContainers[i].addedBonusHerbs = true;
					activeContainers[i].GetInventory().GetAllItems(herbs);
					for(j=0; j<herbs.Size(); j+=1)
					{
						if( activeContainers[i].GetInventory().ItemHasTag(herbs[j], 'primer_monstrous') || activeContainers[i].GetInventory().ItemHasTag(herbs[j], 'InertMutagen') )
						{
							if( RandRange(100) > 75)
								activeContainers[i].GetInventory().AddAnItem(activeContainers[i].GetInventory().GetItemName(herbs[j]), 1);
						}
					}
				}
			}
		}
	}
	
	private function GetContainerIndexByInventory( inv : CInventoryComponent ) : int
	{
		var i : int;
		for(i=0; i<activeContainers.Size(); i+=1)
		{
			if( activeContainers[i].GetInventory() == inv )
				return i;
		}
		
		return -1;
	}
	
	private function GetItemIndexByID( ID : int ) : int
	{
		var i, idx : int;
		for(i=0; i<inventoryComponents.Size(); i+=1)
		{
			if( inventoryComponents[i] != inventoryComponents[ID] )
				idx += 1;
			else
				return (ID - idx);
		}
		
		return -1;
	}
	
	private function UpdateContainers( inv : CInventoryComponent )
	{
		var i : int;
		for(i=0; i<activeContainers.Size(); i+=1)
		{
			if( activeContainers[i].GetInventory() == inv )
				activeContainers.Erase(i);
		}		
	}
	// W3EE - End
	
	private function setupFunctions():void
	{
		m_fxSetWindowTitle = m_flashModule.GetMemberFlashFunction( "SetWindowTitle" );
		m_fxSetSelectionIndex = m_flashModule.GetMemberFlashFunction( "SetSelectionIndex" );
		m_fxSetWindowScale = m_flashModule.GetMemberFlashFunction( "SetWindowScale" );
		m_fxResizeBackground = m_flashModule.GetMemberFlashFunction( "resizeBackground" );
		
	}
	
	event  OnClosingPopup()
	{
		var i : int;
		
		theSound.SoundEvent("gui_loot_popup_close");
		super.OnClosingPopup();
		if (theInput.GetContext() == 'EMPTY_CONTEXT' && inputContextSet)
		{
			theInput.RestoreContext( 'EMPTY_CONTEXT', false );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(false);
		theGame.ForceUIAnalog(false);

		SignalContainerClosedEvent();
		
		
		if(ShouldProcessTutorial('TutorialLootWindow'))
		{
			FactsAdd("tutorial_container_close", 1, 1 );	
		}
		
		// W3EE - Begin
		GetWitcherPlayer().GetAnimatedState().StopAnimationLoop();
		for(i=0; i<activeContainers.Size(); i+=1)
			activeContainers[i].OnContainerClosed();
		// W3EE - End
	}
	
	public function UpdateInputContext():void
	{
		var currentContext : name;
		
		currentContext = theInput.GetContext();
		if (inputContextSet && currentContext != 'EMPTY_CONTEXT')
		{
			theInput.RestoreContext(currentContext, true);
			if (theInput.GetContext() == 'EMPTY_CONTEXT') 
			{
				theInput.RestoreContext('EMPTY_CONTEXT', true);
			}
			
			theInput.StoreContext(currentContext);
			
			ClosePopup();
		}
	}
	
	private function ColorString( color : string, text : string ) : string
	{
		return "<font color='#" + color + "'>" + text + "</font>";
	}
	
	private function GetItemNameColor( inv : CInventoryComponent, item : SItemUniqueId, itemName : string ) : string
	{
		var itemQuality  : int;
		var resultString : string;
		
		itemQuality = inv.GetItemQuality(item);
		switch(itemQuality)
		{
			case 1:
				resultString = ColorString("a2a2a2", itemName);
			break;
			
			case 2:
				resultString = ColorString("2b7bff", itemName);
			break;
			
			case 3:
				resultString = ColorString("e1d401", itemName);
			break;
			
			case 4:
				resultString = ColorString("ca610c", itemName);
			break;
			
			case 5:
				resultString = ColorString("01b701", itemName);
			break;
			
			default:
				return "";
		}
		
		return resultString;
	}
	
	private function GetCrossbowPrimatyStat(itemId : SItemUniqueId, itemInvComponent : CInventoryComponent, out primaryStatLabel : string, out primaryStatValue : float):void
	{
		var itemOnSlot 			  : SItemUniqueId;
		var crossbowPower         : SAbilityAttributeValue;
		var crossbowStatValueMult : float;
		
		crossbowPower = itemInvComponent.GetItemAttributeValue(itemId, 'attack_power');
		crossbowStatValueMult = crossbowPower.valueMultiplicative;
		if (crossbowStatValueMult == 0)
		{
			
			crossbowStatValueMult = 1;
		}
		GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, itemOnSlot);
		if (itemInvComponent.IsIdValid(itemOnSlot))
		{
			itemInvComponent.GetItemPrimaryStat(itemOnSlot, primaryStatLabel, primaryStatValue);
			primaryStatValue = primaryStatValue * crossbowStatValueMult;
		}
		else
		{
			itemInvComponent.GetItemStatByName('Bodkin Bolt', 'PiercingDamage', primaryStatValue);
			primaryStatValue = primaryStatValue * crossbowStatValueMult;
		}
		primaryStatLabel = GetLocStringByKeyExt("panel_inventory_tooltip_damage");
	}
	
	private function ApplyStatModifiers( wplayer : W3PlayerWitcher, inv : CInventoryComponent, item : SItemUniqueId, out primaryStat : float )
	{
		var attackPower			: SAbilityAttributeValue;
		var attackPower2		: SAbilityAttributeValue;
		
		//Kolaris - Armor System
		if(inv.GetItemCategory(item) == 'silversword')
		{
			primaryStat = CeilF(primaryStat * 0.754f);
		}
		
		if( inv.IsItemWeapon(item) && !inv.IsItemCrossbow(item) )
		{
			attackPower = inv.GetItemAttributeValue(item, 'attack_power');
			attackPower.valueMultiplicative += 1.f;
			attackPower2 = inv.GetItemAttributeValue(item, 'attack_power_fast_style') + inv.GetItemAttributeValue(item, 'attack_power_heavy_style');
			attackPower.valueMultiplicative += (attackPower2.valueMultiplicative / 2.f);
			primaryStat *= attackPower.valueMultiplicative;
		}
	}
	
	private const var commonColor : string;
	private const var masterColor : string;
	private const var magicColor : string;
	private const var relicColor : string;
	private const var witcherColor : string;
	
	default commonColor	 = "8e8b8a";
	default masterColor	 = "4e75e5";
	default magicColor	 = "c1b601";
	default relicColor 	 = "ca610c";
	default witcherColor = "186618";
	private function GetWeaponLootInfo( inv : CInventoryComponent, item : SItemUniqueId ) : string
	{
		var resultString : string;
		var stat : float;
		var itemQuality : int;
		
		itemQuality = inv.GetItemQuality(item);
		if( inv.IsItemCrossbow(item) )
			GetCrossbowPrimatyStat(item, inv, resultString, stat);
		else
			inv.GetItemPrimaryStat(item, resultString, stat);
			
		ApplyStatModifiers(GetWitcherPlayer(), inv, item, stat);
		switch(itemQuality)
		{
			case 1:
				resultString = ColorString(commonColor, GetLocStringByKeyExt("loot_popup_damage") + ": ") + ColorString("ffffff", RoundMath(stat * 0.9f) + "-" + RoundMath(stat * 1.1f)) + " / " + ColorString(commonColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(commonColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 2:
				resultString = ColorString(masterColor, GetLocStringByKeyExt("loot_popup_damage") + ": ") + ColorString("ffffff", RoundMath(stat * 0.9f) + "-" + RoundMath(stat * 1.1f)) + " / " + ColorString(masterColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(masterColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 3:
				resultString = ColorString(magicColor, GetLocStringByKeyExt("loot_popup_damage") + ": ") + ColorString("ffffff", RoundMath(stat * 0.9f) + "-" + RoundMath(stat * 1.1f)) + " / " + ColorString(magicColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(magicColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 4:
				resultString = ColorString(relicColor, GetLocStringByKeyExt("loot_popup_damage") + ": ") + ColorString("ffffff", RoundMath(stat * 0.9f) + "-" + RoundMath(stat * 1.1f)) + " / " + ColorString(relicColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(relicColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 5:
				resultString = ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_damage") + ": ") + ColorString("ffffff", RoundMath(stat * 0.9f) + "-" + RoundMath(stat * 1.1f)) + " / " + ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			default:
				return "";
		}
		
		return resultString;
	}
	
	private function GetArmorLootInfo( inv : CInventoryComponent, item : SItemUniqueId ) : string
	{
		var resultString : string;
		var stat : float;
		var itemQuality : int;
		
		itemQuality = inv.GetItemQuality(item);
		inv.GetItemPrimaryStat(item, resultString, stat);
		ApplyStatModifiers(GetWitcherPlayer(), inv, item, stat);
		switch(itemQuality)
		{
			case 1:
				resultString = ColorString(commonColor, GetLocStringByKeyExt("loot_popup_armor") + ": ") + ColorString("ffffff", RoundMath(stat)) + " / " + ColorString(commonColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(commonColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 2:
				resultString = ColorString(masterColor, GetLocStringByKeyExt("loot_popup_armor") + ": ") + ColorString("ffffff", RoundMath(stat)) + " / " + ColorString(masterColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / "  + ColorString(masterColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 3:
				resultString = ColorString(magicColor, GetLocStringByKeyExt("loot_popup_armor") + ": ") + ColorString("ffffff", RoundMath(stat)) + " / " + ColorString(magicColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / "  + ColorString(magicColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 4:
				resultString = ColorString(relicColor, GetLocStringByKeyExt("loot_popup_armor") + ": ") + ColorString("ffffff", RoundMath(stat)) + " / " + ColorString(relicColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / "  + ColorString(relicColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			case 5:
				resultString = ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_armor") + ": ") + ColorString("ffffff", RoundMath(stat)) + " / " + ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / "  + ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 1)));
			break;
			
			default:
				return "";
		}
		
		return resultString;
	}
	
	private function GetRandomLootInfo( inv : CInventoryComponent, item : SItemUniqueId ) : string
	{
		var resultString, initString : string;
		var itemQuality : int;
		
		itemQuality = inv.GetItemQuality(item);
		switch(itemQuality)
		{
			case 1:
				resultString = ColorString(commonColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(commonColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 2)));
			break;
			
			case 2:
				resultString = ColorString(masterColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(masterColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 2)));
			break;
			
			case 3:
				resultString = ColorString(magicColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(magicColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 2)));
			break;
			
			case 4:
				resultString = ColorString(relicColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(relicColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 2)));
			break;
			
			case 5:
				resultString = ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_value") + ": ") + ColorString("ffffff", NoTrailZeros(inv.GetItemBasePriceModified(item))) + " / " + ColorString(witcherColor, GetLocStringByKeyExt("loot_popup_weight") + ": ") + ColorString("ffffff", NoTrailZeros(RoundTo(inv.GetItemEncumbrance(item), 2)));
			break;
			
			default:
				return "";
		}
		
		return resultString;
	}
	
	function PopulateData()
	{
		var i, j, length					: int;
		var l_lootItemsFlashArray			: CScriptedFlashArray;
		var l_lootItemsDataFlashObject 		: CScriptedFlashObject;
		var l_lootItemStatsFlashArray		: CScriptedFlashArray;
		var l_lootItemStatsDataFlashObject	: CScriptedFlashObject;
		
		var l_containerInv 					: CInventoryComponent;
		var l_item 							: SItemUniqueId;
		var l_itemName						: string;
		var l_itemIconPath					: string;
		var l_itemQuantity					: int;
		var l_itemPrice						: float;
		var l_weight 						: float;
		var itemUIData						: SInventoryItemUIData;
		
		var l_name						    : name;
		var l_isBookRead					: bool;
		var l_isQuest	 					: bool;
		
		var l_allItems						: array<SItemUniqueId>;
		
		// W3EE - Begin
		var alchemy_menu					: CR4AlchemyMenu;
		var l_primaryStatLabel 				: string;
		var containerIdx, itemIdx			: int;
		// W3EE - End
		var l_primaryStatValue    			: float;
		
		var l_statsList						: CScriptedFlashArray;
		var l_itemStats 					: array<SAttributeTooltip>;
		var l_compareItem 					: SItemUniqueId;
		var l_compareItemStats				: array<SAttributeTooltip>;
		var l_itemTags 						: array<name>;
		var l_typeStr 						: string;
		var l_questTag						: string;
		var _value							: string;
		
		// W3EE - Begin
		alchemy_menu = new CR4AlchemyMenu in this;
		alchemy_menu.SetAlchemyCategories();
		
		l_lootItemsFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_lootItemsFlashArray.SetLength(GetContainerItemsCount());
		
		inventoryComponents.Clear();
		for(containerIdx=0; containerIdx<activeContainers.Size(); containerIdx+=1)
		{
			l_containerInv = activeContainers[containerIdx].GetInventory(); 
			l_containerInv.GetAllItems(l_allItems);		
			
			for(i=l_allItems.Size()-1; i>=0; i-=1)
			{
				if( l_containerInv.ItemHasTag(l_allItems[i], theGame.params.TAG_DONT_SHOW ) && !l_containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
					l_allItems.Erase(i);
			}
			
			length = l_allItems.Size();
			if(length > 4)
				m_fxResizeBackground.InvokeSelfOneArg(FlashArgBool(true));
			else
				m_fxResizeBackground.InvokeSelfOneArg(FlashArgBool(false));
				
			for(i=0; i<length; i+=1)
			{
				l_item = l_allItems[i];
				l_name = l_containerInv.GetItemName(l_item);
				l_itemName = l_containerInv.GetItemLocNameByID(l_item);
				
				// l_itemName = GetLocStringByKeyExt(l_itemName);
				if ( l_itemName == "" )
					l_itemName = " ";
					
				if( l_containerInv.IsItemSingletonItem(l_item) )
					l_itemQuantity = l_containerInv.SingletonItemGetAmmo(l_item); 
				else
					l_itemQuantity = l_containerInv.GetItemQuantity( l_item );
					
				l_itemIconPath	= l_containerInv.GetItemIconPathByUniqueID( l_item );
				/*if( l_containerInv.ItemHasTag(l_item, 'Quest') || l_containerInv.IsItemIngredient(l_item) || l_containerInv.IsItemAlchemyItem(l_item) ) 
					l_weight = 0;
				else*/
					l_weight = l_containerInv.GetItemEncumbrance(l_item);
					
				l_questTag = "";
				l_isQuest = false;
				if(l_containerInv.ItemHasTag(l_item, 'Quest'))
				{
					l_questTag = "Quest";
					l_isQuest = true;
				}
				
				if (l_containerInv.ItemHasTag(l_item, 'QuestEP1'))
				{
					l_questTag = "QuestEP1";
					l_isQuest = true;
				}
				
				if (l_containerInv.ItemHasTag(l_item, 'QuestEP2'))
				{
					l_questTag = "QuestEP2";
					l_isQuest = true;
				}
				
				l_lootItemsDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				l_isBookRead = l_containerInv.IsBookReadByName(l_name);
				
				l_lootItemsDataFlashObject.SetMemberFlashString ( "WeightValue", NoTrailZeros(l_weight));
				l_lootItemsDataFlashObject.SetMemberFlashString	( "label", l_itemName );
				l_lootItemsDataFlashObject.SetMemberFlashInt	( "quantity", l_itemQuantity );
				l_lootItemsDataFlashObject.SetMemberFlashNumber	( "PriceValue", l_itemPrice );
				l_lootItemsDataFlashObject.SetMemberFlashString ( "iconPath", l_itemIconPath );
				l_lootItemsDataFlashObject.SetMemberFlashInt	( "quality", l_containerInv.GetItemQuality( l_item ) );
				l_lootItemsDataFlashObject.SetMemberFlashBool	( "isRead", l_isBookRead );
				l_lootItemsDataFlashObject.SetMemberFlashBool   ( "isQuestItem", l_isQuest );
				l_lootItemsDataFlashObject.SetMemberFlashString ( "questTag", l_questTag );
				
				l_containerInv.GetItemTags(l_item,l_itemTags);
				GetWitcherPlayer().GetItemEquippedOnSlot(GetSlotForItem(l_containerInv.GetItemCategory(l_item),l_itemTags, true), l_compareItem);
				
				if( l_containerInv.GetItemName(l_item) != GetWitcherPlayer().GetInventory().GetItemName(l_compareItem) ) 
				{
					GetWitcherPlayer().GetInventory().GetItemStats(l_compareItem, l_compareItemStats);
				}
				l_statsList = m_flashValueStorage.CreateTempFlashArray();
				l_containerInv.GetItemStats(l_item, l_itemStats);
				CompareItemsStats(l_itemStats, l_compareItemStats, l_statsList);
				
				l_lootItemsDataFlashObject.SetMemberFlashArray("StatsList", l_statsList);
				
				l_typeStr = alchemy_menu.GetIngredientCategoryForLoot(l_name,, true, true);
				if( l_typeStr != "" )
					l_typeStr = "<font color='#8B4C96'>" + l_typeStr + "</font>";
				else
				if( l_containerInv.IsItemWeapon(l_item) )
					l_typeStr = GetWeaponLootInfo(l_containerInv, l_item);
				else
				if( l_containerInv.IsItemAnyArmor(l_item) )
					l_typeStr = GetArmorLootInfo(l_containerInv, l_item);
				else
					l_typeStr = GetRandomLootInfo(l_containerInv, l_item);
					
				l_lootItemsDataFlashObject.SetMemberFlashString("itemType", l_typeStr );
				
				if(l_containerInv.HasItemDurability(l_item))
				{
					l_lootItemsDataFlashObject.SetMemberFlashString("DurabilityValue", NoTrailZeros(l_containerInv.GetItemDurability(l_item)/l_containerInv.GetItemMaxDurability(l_item) * 100));
				}
				else
				{
					l_lootItemsDataFlashObject.SetMemberFlashString("DurabilityValue", "");
				}
				l_containerInv.GetItemPrimaryStat(l_item, l_primaryStatLabel, l_primaryStatValue);
				
				l_lootItemsDataFlashObject.SetMemberFlashString("PrimaryStatLabel", l_primaryStatLabel);
				l_lootItemsDataFlashObject.SetMemberFlashNumber("PrimaryStatValue", l_primaryStatValue);	
				
				l_lootItemsFlashArray.SetElementFlashObject( itemIdx, l_lootItemsDataFlashObject );
				inventoryComponents.PushBack(l_containerInv);
				itemIdx += 1;
			}
		}
		// W3EE - End
		
		m_flashValueStorage.SetFlashArray(KEY_LOOT_ITEM_LIST, l_lootItemsFlashArray);
		m_fxSetWindowTitle.InvokeSelfOneArg(FlashArgString(_container.GetDisplayName()));		
	}
	
	function CompareItemsStats(itemStats : array<SAttributeTooltip>, compareItemStats : array<SAttributeTooltip>, out compResult : CScriptedFlashArray)
	{
		var l_flashObject	: CScriptedFlashObject;
		var attributeVal 	: SAbilityAttributeValue;
		var strDifference 	: string;		
		var percentDiff 	: float;
		var nDifference 	: float;
		var i, j, price 	: int;
		
		strDifference = "none";
		for( i = 0; i < itemStats.Size(); i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);
			l_flashObject.SetMemberFlashString("color",itemStats[i].attributeColor);
			
			
			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					nDifference = itemStats[j].value - compareItemStats[i].value;
					percentDiff = AbsF(nDifference/itemStats[j].value);
					
					
					if(nDifference > 0)
					{
						if(percentDiff < 0.25) 
							strDifference = "better";
						else if(percentDiff > 0.75) 
							strDifference = "wayBetter";
						else						
							strDifference = "reallyBetter";
					}
					
					else if(nDifference < 0)
					{
						if(percentDiff < 0.25) 
							strDifference = "worse";
						else if(percentDiff > 0.75) 
							strDifference = "wayWorse";
						else						
							strDifference = "reallyWorse";					
					}
					break;					
				}
			}
			l_flashObject.SetMemberFlashString("icon", strDifference);
			
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value * 100 ) +" %");
			}
			else
			{
				if(itemStats[i].value < 0)
					l_flashObject.SetMemberFlashString("value",NoTrailZeros(itemStats[i].value));
				else
					l_flashObject.SetMemberFlashString("value","+" + NoTrailZeros(itemStats[i].value));				
			}
			compResult.PushBackFlashObject(l_flashObject);
		}	
	}
	
	function GetItemRarityDescription( item : SItemUniqueId, tooltipInv : CInventoryComponent ) : string
	{
		var itemQuality : int;
		
		itemQuality = tooltipInv.GetItemQuality(item);
		return GetItemRarityDescriptionFromInt(itemQuality);
	}
	
	event  OnPopupTakeAllItems( ) : void
	{
		GetWitcherPlayer().StartInvUpdateTransaction();
		// W3EE - Begin
		SignalStealingReactionEvent(-1);
		// W3EE - End
		TakeAllAction();
		GetWitcherPlayer().FinishInvUpdateTransaction();
		
		OnCloseLootWindow();
	}
	
	// W3EE - Begin
	event  OnPopupTakeItem( Id : int ) : void
	{
		var containerInv 		: CInventoryComponent;
		var playerInv 			: CInventoryComponent;
		var horseInv 			: CInventoryComponent;
		var item 				: SItemUniqueId;
		var invalidatedItems 	: array< SItemUniqueId >;
		var itemName 			: name;
		var itemQuantity, i		: int;
		var category			: name;
		var containerIdx		: int;
		var l_allItems			: array<SItemUniqueId>;
		
		containerIdx = GetContainerIndexByInventory(inventoryComponents[Id]);
		SignalStealingReactionEvent(containerIdx);
		m_indexToSelect = Id;
		containerInv = inventoryComponents[Id];
		playerInv = GetWitcherPlayer().inv;
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		containerInv.GetAllItems( l_allItems );
		
		for( i = l_allItems.Size() - 1; i >= 0; i -= 1 )
		{
			if( ( containerInv.ItemHasTag(l_allItems[i],theGame.params.TAG_DONT_SHOW) || containerInv.ItemHasTag(l_allItems[i],'NoDrop') ) && !containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
			{
				l_allItems.Erase(i);
			}
		}
		
		item = l_allItems[GetItemIndexByID(Id)];
		itemName = containerInv.GetItemName(item);
		if( containerInv.IsItemSingletonItem(item) )
			itemQuantity = containerInv.SingletonItemGetAmmo(item);
		else
			itemQuantity = containerInv.GetItemQuantity(item);
		if( containerInv.ItemHasTag(item, 'HerbGameplay') )
		{
			category	 	= 'herb';
		}
		else
		{
			category	 	= containerInv.GetItemCategory(item);
		}
		
		//Kolaris - Mutation EXP
		if( !(_container.HasTag('lootbag')) && containerInv.ItemHasTag(item, 'MutagenIngredient') )
			Experience().AwardAlchemyBrewingXP(1, false, false, false, false, false, true);
				
		containerInv.NotifyItemLooted( item );
		if( containerInv.ShouldHorseLootItem(item) && horseInv.HorseCanTakeItem(item, itemQuantity, containerInv) )
			containerInv.GiveItemTo( horseInv, item, itemQuantity, true, false, true );
		else
			containerInv.GiveItemTo( playerInv, item, itemQuantity, true, false, true );
		PlayItemEquipSound( category );
		
		containerInv.GetAllItems( l_allItems );
		for( i = l_allItems.Size() - 1; i >= 0; i -= 1 )
		{
			if( (containerInv.ItemHasTag(l_allItems[i],theGame.params.TAG_DONT_SHOW) || containerInv.ItemHasTag(l_allItems[i],'NoDrop') ) && !containerInv.ItemHasTag(l_allItems[i], 'Lootable' ) )
			{
				l_allItems.Erase(i);
			}
		}
		
	    activeContainers[containerIdx].InformClueStash(); 
		if( !l_allItems.Size() )		
		{
			activeContainers[containerIdx].Enable(false);
			activeContainers[containerIdx].OnContainerClosed();	
			UpdateContainers(containerInv);
		}
		
		if( !GetContainerItemsCount() )
			OnCloseLootWindow();
		else
		{
			m_fxSetSelectionIndex.InvokeSelfOneArg(FlashArgInt(m_indexToSelect));		
			PopulateData();	
		}
	}
	// W3EE - End
	
	event  OnCloseLootWindow()
	{
		ClosePopup();
	}
	
	// W3EE - Begin
	function TakeAllAction() : void
	{
		var i : int;
		for(i=0; i<activeContainers.Size(); i+=1)
			activeContainers[i].TakeAllItems();
	}
	
	protected function SignalLootingReactionEvent()
	{
		var i : int;
		for(i=0; i<activeContainers.Size(); i+=1)
		{
			if( activeContainers[i].disableStealing || activeContainers[i].HasQuestItem() || (W3Herb)activeContainers[i] || (W3ActorRemains)activeContainers[i] )
				continue;
			else
			{
				theGame.CreateNoSaveLock("Stealing",safeLock,true);		
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible(thePlayer, 'LootingAction', -1, 10.0f, -1.f, -1, true); 
			}
		}
	}
	
	protected function SignalStealingReactionEvent( containerIdx : int )
	{
		var i : int;
		if( containerIdx )
		{
			if( activeContainers[i].disableStealing || activeContainers[i].HasQuestItem() || (W3Herb)activeContainers[i] || (W3ActorRemains)activeContainers[i] )
				return;
			else
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible(thePlayer, 'StealingAction', -1, 10.0f, -1.f, -1, true);
				
			return;
		}
		
		for(i=0; i<activeContainers.Size(); i+=1)
		{
			if( activeContainers[i].disableStealing || activeContainers[i].HasQuestItem() || (W3Herb)activeContainers[i] || (W3ActorRemains)activeContainers[i] )
				continue;
			else
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible(thePlayer, 'StealingAction', -1, 10.0f, -1.f, -1, true); 
		}
	}
	
	protected function SignalContainerClosedEvent()
	{
		var i : int;
		
		theGame.ReleaseNoSaveLock(safeLock);
		for(i=0; i<activeContainers.Size(); i+=1)
		{
			if( activeContainers[i].disableStealing || activeContainers[i].HasQuestItem() || (W3Herb)activeContainers[i] || (W3ActorRemains)activeContainers[i] )
				continue;
			else
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible(thePlayer, 'ContainerClosed', 10, 15.0f, -1.f, -1, true); 
		}
	}
	// W3EE - End
}

exec function CloseLootPopup()
{
	theGame.ClosePopup('LootPopup');
}