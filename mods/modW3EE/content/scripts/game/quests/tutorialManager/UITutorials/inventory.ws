/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Inventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, EQUIP_OIL, OILS_JOURNAL_ENTRY : name;
	private const var PAPERDOLL, BAG, TABS, STATS, STATS_DETAILS, EQUIPPING : name;
	private const var CAN_EQUIP_OIL, SELECT_TAB, EQUIP_POTION, EQUIP_POTION_THUNDERBOLT, ON_EQUIPPED : name;
	private const var TAB_CRAFTING, TAB_QUEST, TAB_MISC, TAB_ALCHEMY, TAB_WEAPONS, TOOLTIPS, PREVIEW, PREVIEW2, SORTING, GEEKPAGE : name;
	private var skippingTabSelection : bool;
	private var isClosing : bool;
	
		default PAPERDOLL 		= 'TutorialInventoryPaperdoll';
		default BAG 			= 'TutorialInventoryBag';
		default TABS 			= 'TutorialInventoryTabs';
		default STATS 			= 'TutorialInventoryStats';
		default STATS_DETAILS 	= 'TutorialInventoryStatsMore';
		default EQUIPPING 		= 'TutorialInventoryEquipping';
		
		default CAN_EQUIP_OIL		= 'TutorialOilCanEquip1';
		default EQUIP_OIL 			= 'TutorialOilCanEquip3';
		default OILS_JOURNAL_ENTRY 	= 'TutorialJournalOils';
		
		default CAN_EQUIP	 	= 'TutorialPotionCanEquip1';
		default SELECT_TAB 		= 'TutorialPotionCanEquip2';
		default EQUIP_POTION 	= 'TutorialPotionCanEquip3';
		default ON_EQUIPPED 	= 'TutorialPotionEquipped';
		
		default TAB_CRAFTING 	= 'TutorialNewInvTabCrafting';
		default TAB_QUEST 		= 'TutorialNewInvTabQuest';
		default TAB_MISC 		= 'TutorialNewInvTabMisc';
		default TAB_ALCHEMY 	= 'TutorialNewInvTabAlchemy';
		default TAB_WEAPONS 	= 'TutorialNewInvTabWeapons';
		default TOOLTIPS 		= 'TutorialNewInvTooltips';
		default PREVIEW			= 'TutorialNewInvPreview';
		default PREVIEW2		= 'TutorialNewInvPreview2';
		default SORTING			= 'TutorialNewInvSorting';
		default GEEKPAGE		= 'TutorialNewInvGeekpage';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		BlockPanels(true);
		highlights.PushBack( GetHighlightForPaperdoll() );			
		ShowHint(PAPERDOLL, POS_INVENTORY_X, POS_INVENTORY_Y, , highlights);
		
		theGame.GameplayFactsAdd( 'panel_on_since_inv_tut' );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var invMenu : CR4InventoryMenu;
		
		isClosing = true;
		BlockPanels(false);
		
		CloseStateHint(PAPERDOLL);
		CloseStateHint(BAG);
		CloseStateHint(TABS);
		CloseStateHint(STATS);
		CloseStateHint(STATS_DETAILS);
		CloseStateHint(EQUIPPING);
		CloseStateHint(CAN_EQUIP);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_OIL);
		CloseStateHint(ON_EQUIPPED);
		CloseStateHint(CAN_EQUIP_OIL);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_POTION);
		CloseStateHint(TOOLTIPS);
		CloseStateHint(PREVIEW);
		CloseStateHint(PREVIEW2);
		CloseStateHint(SORTING);
		CloseStateHint(GEEKPAGE);
		
		if(!skippingTabSelection)
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
			
		theGame.GetTutorialSystem().MarkMessageAsSeen(PAPERDOLL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ON_EQUIPPED);
		
		FactsAdd("tut_ui_prep_oils");
		
		super.OnLeaveState(nextStateName);
	}
	
	private final function BlockPanels(block : bool)
	{
		if(block)
		{
			thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var itemOne, itemTwo, itemThree, itemFour : SItemUniqueId;
		var highlights : array<STutorialHighlight>;
		var witcher : W3PlayerWitcher;
		var currentTab : int;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		skippingTabSelection = false;
		if(hintName == PAPERDOLL)
		{
			highlights.Clear();
			highlights.PushBack( GetHighlightForItemsGrid() );
			ShowHint(BAG, POS_INVENTORY_X, POS_INVENTORY_Y, , highlights);
		}
		else if(hintName == BAG)
		{
			highlights.Resize(1);
			highlights[0].x = 0.805;
			highlights[0].y = 0.67;
			highlights[0].width = 0.13;
			highlights[0].height = 0.18;
			
			ShowHint(STATS, POS_INVENTORY_X, POS_INVENTORY_Y, , highlights);
		}
		else if(hintName == STATS)
		{
			ShowHint(EQUIPPING, POS_INVENTORY_X, POS_INVENTORY_Y);
		}
		else if(hintName == EQUIPPING)
		{
			highlights.Resize(1);
			highlights[0].x = 0.05f;
			highlights[0].y = 0.14f;
			highlights[0].width = 0.33f;
			highlights[0].height = 0.65f;
			
			ShowHint( TAB_CRAFTING, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabCrafting() );		
		}
		if( hintName == TAB_CRAFTING )
		{
			ShowHint( TAB_QUEST, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabQuest() );
		}
		else if( hintName == TAB_QUEST )
		{
			ShowHint( TAB_MISC, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabMisc() );
		}
		else if( hintName == TAB_MISC )
		{
			ShowHint( TAB_ALCHEMY, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabAlchemy() );
		}
		else if( hintName == TAB_ALCHEMY )
		{
			ShowHint( TAB_WEAPONS, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input, GetHighlightInvTabWeapons() );
		}
		else if( hintName == TAB_WEAPONS )
		{
			highlights.Clear();
			highlights.PushBack(GetHighlightForInventoryTabs());
			ShowHint(TABS, POS_INVENTORY_X, POS_INVENTORY_Y, , highlights);
		}
		else if(hintName == TABS)
		{
			ShowHint( TOOLTIPS, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == TOOLTIPS )
		{
			ShowHint( PREVIEW, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == PREVIEW )
		{
			ShowHint( PREVIEW2, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == PREVIEW2 )
		{
			ShowHint( SORTING, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == SORTING )
		{
			witcher = GetWitcherPlayer();
			witcher.GetItemEquippedOnSlot(EES_Potion1, itemOne);
			witcher.GetItemEquippedOnSlot(EES_Potion2, itemTwo);
			witcher.GetItemEquippedOnSlot(EES_Potion3, itemThree);
			witcher.GetItemEquippedOnSlot(EES_Potion4, itemFour);
			
			if(witcher.inv.IsItemPotion(itemOne) || witcher.inv.IsItemPotion(itemTwo) || witcher.inv.IsItemPotion(itemThree) || witcher.inv.IsItemPotion(itemFour))
			{
				skippingTabSelection = true;
				
				
				ShowHint(ON_EQUIPPED, POS_INVENTORY_X, POS_INVENTORY_Y-0.1);
				
				
				TutorialScript('secondPotionEquip', '');
			}
			else
			{
				currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
				if(currentTab == InventoryMenuTab_Potions)
				{
					skippingTabSelection = true;
					OnPotionTabSelected();
				}
				else
				{
					ShowHint(CAN_EQUIP, POS_INVENTORY_X, POS_INVENTORY_Y);
				}
			}
		}		
		if(hintName == CAN_EQUIP)
		{
			ShowHint( SELECT_TAB, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite, GetHighlightInvTabAlchemy() );
		}
		else if(hintName == ON_EQUIPPED)
		{
			ShowHint(CAN_EQUIP_OIL, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input);
		}
		else if(hintName == CAN_EQUIP_OIL)
		{
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
			ShowHint(EQUIP_OIL, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input);
		}
		else if(hintName == EQUIP_OIL)
		{
			ShowHint( GEEKPAGE, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input );
		}
		else if( hintName == GEEKPAGE )
		{
			QuitState();
		}
	}

	event OnPotionTabSelected()
	{
		CloseStateHint(SELECT_TAB);
		ShowHint(EQUIP_POTION, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnPotionEquipped(potionItemName : name)
	{
		CloseStateHint(EQUIP_POTION);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		ShowHint(ON_EQUIPPED, POS_INVENTORY_X, POS_INVENTORY_Y-0.1);
	}
}

exec function tut_inv()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('inventory', '');
}