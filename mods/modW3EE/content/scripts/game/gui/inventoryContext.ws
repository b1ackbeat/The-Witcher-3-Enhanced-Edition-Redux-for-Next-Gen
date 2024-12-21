/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class  W3InventoryItemContext extends W3UIContext
{
	protected var currentItemId          : SItemUniqueId; 
	protected var currentSlot 			 : EEquipmentSlots;
	
	protected var invMenuRef	         : CR4InventoryMenu;
	protected var invComponentRef        : CInventoryComponent;
	protected var invSecondComponentRef	 : CInventoryComponent;
	protected var contextMenuPosition_x  : float;
	protected var contextMenuPosition_y  : float;
	
	public  function Init(ownerManager:W3ContextManager)
	{
		super.Init(ownerManager);		
		invComponentRef = invMenuRef.GetCurrentInventory(GetInvalidUniqueId());
	}
	
	public function SetSecondInventoryComponentRef(ref : CInventoryComponent):void
	{
		invSecondComponentRef = ref;
	}
	
	public function SetInventoryRef(TargetInvMenu : CR4InventoryMenu):void
	{
		invMenuRef = TargetInvMenu;
	}
	
	public function SetContextMenuData(posX:float, posY:float):void
	{
		contextMenuPosition_x = posX;
		contextMenuPosition_y = posY;
	}
	
	public function SetCurrentSlot(TargetSlot : EEquipmentSlots):void
	{
		currentSlot = TargetSlot;
	}
	
	public function SetCurrentItem(TargetItemId : SItemUniqueId):void
	{
		if (currentItemId != TargetItemId)
		{
			currentItemId = TargetItemId;
			
		}
		
		updateInputFeedback();
		
	}
	
	public function UpdateContext() 
	{
		invComponentRef = invMenuRef.GetCurrentInventory(GetInvalidUniqueId());
		updateInputFeedback();
	}
	
	protected function triggerTooltip():void
	{
		if (invComponentRef.IsIdValid(currentItemId))
		{
			invMenuRef.ShowItemTooltip(currentItemId, currentSlot);
		}
		else if (currentSlot > 0)
		{
			
		}
		else
		{
			invMenuRef.HideItemTooltip();
		}
	}
	
	protected function ShowContextMenu():void
	{
		var contextMenuData:W3ContextMenu;
		if (m_inputBindings.Size() > 0 && invMenuRef)
		{
			contextMenuData = new W3ContextMenu in this;
			contextMenuData.positionX = contextMenuPosition_x;
			contextMenuData.positionY = contextMenuPosition_y;
			contextMenuData.contextRef = this;
			contextMenuData.actionsList = m_contextBindings;
			invMenuRef.RequestSubMenu('PopupMenu', contextMenuData);
		}
	}
	
	public  function HandleUserFeedback(keyName:string):void 
	{
		var itemsCount   : int;
		var itemCategory : name;
		var isItemValid  : bool;
		var isSchematic  : bool;
		var isArmorOrWeapon : bool;
		var playerInv    : W3GuiBaseInventoryComponent;
		var notificationText : string;
		var language : string;
		var audioLanguage : string;
		var result : bool;
		
		isItemValid = invComponentRef.IsIdValid(currentItemId);
		
		if (!isItemValid && invSecondComponentRef && invSecondComponentRef.IsIdValid(currentItemId))
		{
			isItemValid = true;
		}
		
		if (!isItemValid)
		{
			return;
		}
		
		super.HandleUserFeedback(keyName);
		itemsCount = invComponentRef.GetItemQuantity( currentItemId );
		
		if( keyName == "gamepad_X" )
		{
			isArmorOrWeapon = invComponentRef.IsItemAnyArmor( currentItemId ) || invComponentRef.IsItemWeapon( currentItemId );
			
			if( isArmorOrWeapon )
			{
				if( invMenuRef.IsItemInPreview( currentItemId ) )
				{
					invMenuRef.UnPreviewItem( currentItemId );
				}
				else
				{
					invMenuRef.PreviewItem( currentItemId );
					return;
				}
			}
			if( invComponentRef.ItemHasTag(currentItemId, 'Edibles') || invComponentRef.ItemHasTag(currentItemId, 'Drinks') || invComponentRef.ItemHasTag(currentItemId, 'Consumable'))
			{
				//Kolaris - Shaving Razor
				if( !CampfireManager().CanPerformUpgrade() && invComponentRef.GetItemName(currentItemId) == 'Razor')
				{
					invMenuRef.showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
					theSound.SoundEvent("gui_global_denied");
					return;
				}
			
				// W3EE - Begin
				if( invComponentRef.ItemHasTag(currentItemId, 'Consumable') )
				{
					//Kolaris - Update Consumables in Menu
					invMenuRef.OnConsumeItem(currentItemId); //GetWitcherPlayer().ConsumeItem(currentItemId);
				}
				else
				if( invComponentRef.ItemHasTag(currentItemId, 'Edibles') && invComponentRef.ItemHasTag(currentItemId, 'Drinks') )
				{
					if( !Options().GetUseDrinkAnimation() )
						//Kolaris - Update Consumables in Menu
						invMenuRef.OnConsumeItem(currentItemId); //GetWitcherPlayer().ConsumeItem(currentItemId);
					else
						GetWitcherPlayer().GetAnimManager().PerformAnimation(EES_InvalidSlot, currentItemId);
				}
				else
				{
					if( !Options().GetUseEatAnimation() )
						//Kolaris - Update Consumables in Menu
						invMenuRef.OnConsumeItem(currentItemId); //GetWitcherPlayer().ConsumeItem(currentItemId);
					else
						GetWitcherPlayer().GetAnimManager().PerformAnimation(EES_InvalidSlot, currentItemId);
				}
				// W3EE - End
			} else
			if (invComponentRef.ItemHasTag(currentItemId, 'Potion'))
			{
				if (GetWitcherPlayer().ToxicityLowEnoughToDrinkPotion(EES_Potion1,currentItemId))	
				{
					// W3EE - Begin
					if( !Options().GetUseDrinkAnimation() )
						GetWitcherPlayer().DrinkPreparedPotion(EES_Potion1, currentItemId);
					else
						GetWitcherPlayer().GetAnimManager().PerformAnimation(EES_Potion1, currentItemId);
					// W3EE - End
					invMenuRef.InventoryUpdateItem(currentItemId);
					
					if(thePlayer.inv.GetItemName(currentItemId) == 'Mutagen 3')
					{
						invMenuRef.PaperdollUpdateAll();
						invMenuRef.PopulateTabData( InventoryMenuTab_Potions );
					}
					
					invMenuRef.UpdatePlayerStatisticsData();
				}
				else
				{
					notificationText = GetLocStringByKeyExt("menu_cannot_perform_action_now") + "<br/>" + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");
					theGame.GetGameLanguageName(audioLanguage,language);
					if (language == "AR")
					{
						notificationText += (int)(thePlayer.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(thePlayer.abilityManager.GetStatMax(BCS_Toxicity)) + " :";
					}
					else
					{
						notificationText += ": " + (int)(thePlayer.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(thePlayer.abilityManager.GetStatMax(BCS_Toxicity));
					}
					theSound.SoundEvent("gui_global_denied");
					invMenuRef.showNotification(notificationText);
				}
			}
			else if( invComponentRef.GetItemName( currentItemId ) == 'q705_tissue_extractor' )
			{
				
				result = thePlayer.TissueExtractorDischarge();
				
				if( result )
				{
					
					invMenuRef.ShowItemTooltip( currentItemId, 0 );
					
					
					invMenuRef.PopulateTabData(InventoryMenuTab_Ingredients);
					invMenuRef.InventoryUpdateItem( currentItemId );
					
					
					invMenuRef.OnPlaySoundEvent( "gui_character_buy_skill" );
				}
				else
				{
					
					invMenuRef.OnPlaySoundEvent( "gui_global_denied" );
				}
			}
			
			updateInputFeedback();
		}
		else
		if (keyName == "enter-gamepad_A")
		{
			if (!theInput.LastUsedPCInput() || IsPadBindingExist(keyName)) 
			{
				execurePrimaryAction();
			}
		}
		else
		if (keyName == "gamepad_Y")
		{
			invMenuRef.OnDropItem(currentItemId, itemsCount);
			
			
		}
		else
		if (keyName == "gamepad_L2")
		{
			itemCategory = invComponentRef.GetItemCategory(currentItemId); 
			isSchematic = itemCategory == 'alchemy_recipe' || itemCategory == 'crafting_schematic';
			if (isSchematic)
			{
				playerInv = invMenuRef.GetCurrentInventoryComponent();
				if (playerInv)
				{
					invMenuRef.ShowBookPopup( invComponentRef.GetItemLocNameByID( currentItemId ), playerInv.GetBookText( currentItemId ), currentItemId, true );
				}
			}
		}
	}
	
	protected function IsHorseItem(currentItemId : SItemUniqueId) : bool
	{
		if ((invComponentRef.ItemHasTag(currentItemId, 'Saddle')) ||
		   (invComponentRef.ItemHasTag(currentItemId, 'HorseBag')) ||
		   (invComponentRef.ItemHasTag(currentItemId, 'Trophy')) ||
		   (invComponentRef.ItemHasTag(currentItemId, 'Blinders')))
		{
			return true;
		}
		return false;
	}
	
	
	protected function updateInputFeedback():void {}
	protected function execurePrimaryAction():void {}
}

class W3InventoryGridContext extends W3InventoryItemContext
{
	protected  function updateInputFeedback():void
	{
		var currentInventoryState : EInventoryMenuState;
		var canDrop : bool;
		var isBodkinBolt : bool;
		var isQuestItem : bool;
		var curEquipedItem : SItemUniqueId;
		var cantUse : bool;
		var isArmorOrWeapon : bool;
		
		var buttonLabel : string;
		
		LogChannel('CONTEXT'," updateInputFeedback "+invMenuRef+"; "+invComponentRef);
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		if (!invMenuRef || !invComponentRef)
		{
			return;
		}
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		
		// W3EE - Begin
		if( currentInventoryState != IMS_Shop )
			AddInputBinding("w3ee_transfer", "gamepad_L2", IK_U, true);
		if( currentInventoryState == IMS_Stash || currentInventoryState == IMS_Shop )
			AddInputBinding("w3ee_sort_stash", "gamepad_R2", IK_T, true);
		
		if (invComponentRef.IsIdValid(currentItemId))
		{
			canDrop = !invComponentRef.ItemHasTag(currentItemId, 'NoDrop');
			isQuestItem = invComponentRef.ItemHasTag(currentItemId,'Quest');
			isBodkinBolt = false; //invComponentRef.GetItemName(currentItemId) == 'Bodkin Bolt';
		// W3EE - End
			
			
			
			cantUse = false; //FactsQuerySum("tut_forced_preparation") > 0 && invComponentRef.GetItemName(currentItemId) == 'Thunderbolt 1';
			if(canDrop && cantUse)
			{
				canDrop = false;
			}
			
			switch (currentInventoryState)
			{
				case IMS_Player:
					
					isArmorOrWeapon = invComponentRef.IsItemAnyArmor( currentItemId ) || invComponentRef.IsItemWeapon( currentItemId );	
					
					if( isArmorOrWeapon && !invComponentRef.IsItemCrossbow( currentItemId ) && !invComponentRef.IsItemBolt( currentItemId ) )
					{
						if( invMenuRef.IsItemInPreview( currentItemId ) )
						{
							AddInputBinding( "panel_button_unpreview_item", "gamepad_X", IK_X, true );
						}
						else
						{
							AddInputBinding( "panel_button_preview_item", "gamepad_X", IK_X, true );
						}
					}

					if (invComponentRef.ItemHasTag(currentItemId, 'mod_dye'))
					{
						AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
					}
					else if( invComponentRef.GetItemName( currentItemId ) == 'q705_tissue_extractor' )
					{
						AddInputBinding("panel_button_hud_interaction_useitem", "gamepad_X", IK_X, true);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'Painting'))
					{
						AddInputBinding("panel_button_common_examine", "enter-gamepad_A", IK_E, true);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
					{
						AddInputBinding("panel_button_inventory_read", "enter-gamepad_A", IK_E, true);
					}
					else if ((invComponentRef.ItemHasTag(currentItemId, 'Edibles')) ||
						    (invComponentRef.ItemHasTag(currentItemId, 'Drinks')) ||
							(invComponentRef.ItemHasTag(currentItemId, 'Potion')))
					{
						if (invComponentRef.IsItemSingletonItem(currentItemId) && thePlayer.inv.SingletonItemGetAmmo(currentItemId) == 0)
						{
							cantUse = true;
						}
						
						if (!cantUse)
						{
							AddInputBinding("panel_button_inventory_consume", "gamepad_X", IK_E, true);
						}
						if ( invComponentRef.GetItemName( currentItemId ) != 'q111_imlerith_acorn'  && !invComponentRef.ItemHasTag( currentItemId, 'NoEquip' ) ) 
						{
							AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
						}
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'Upgrade'))
					{
						AddInputBinding("panel_button_inventory_put_in_socket", "enter-gamepad_A", IK_E, true);
					}
					else if ((invComponentRef.ItemHasTag(currentItemId, 'SteelOil') && GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, curEquipedItem)) ||
							 (invComponentRef.ItemHasTag(currentItemId, 'SilverOil') && GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, curEquipedItem)))
					{
						
						AddInputBinding("panel_button_inventory_upgrade", "enter-gamepad_A", IK_E, true);
					}
					else if (invComponentRef.GetSlotForItemId(currentItemId) != EES_InvalidSlot) 
					{
						AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
					}
					else if ( invComponentRef.ItemHasTag(currentItemId, 'ArmorReapairKit') )
					{
						if ( GetWitcherPlayer().HasRepairAbleGearEquiped() )
						{
							AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
						}
					}
					else if ( invComponentRef.ItemHasTag(currentItemId, 'WeaponReapairKit') )
					{
						if ( GetWitcherPlayer().HasRepairAbleWaponEquiped() )
						{
							AddInputBinding("panel_button_hud_interaction_useitem", "enter-gamepad_A", IK_E, true);
						}
					}
					break;
				case IMS_Shop:
					if (!isBodkinBolt)
					{
						AddInputBinding("panel_inventory_quantity_popup_sell", "enter-gamepad_A", IK_Space, true);
					}
					break;
				case IMS_Container:
					AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
					break;
				case IMS_HorseInventory:
					if (IsHorseItem(currentItemId))
					{
						AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
					}
					else
					{
						AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
					}
					break;
				case IMS_Stash:
				// W3EE - Begin
					if (invComponentRef.ItemHasTag(currentItemId, 'Painting'))
					{
						AddInputBinding("panel_button_common_examine", "enter-gamepad_A", IK_E, true);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
					{
						AddInputBinding("panel_button_inventory_read", "enter-gamepad_A", IK_E, true);
					}
					else if ((invComponentRef.ItemHasTag(currentItemId, 'Edibles')) ||
						    (invComponentRef.ItemHasTag(currentItemId, 'Drinks')) ||
							(invComponentRef.ItemHasTag(currentItemId, 'Potion')))
					{
						if (invComponentRef.IsItemSingletonItem(currentItemId) && thePlayer.inv.SingletonItemGetAmmo(currentItemId) == 0)
						{
							cantUse = true;
						}
						
						if (!cantUse)
						{
							AddInputBinding("panel_button_inventory_consume", "gamepad_X", IK_E, true);
						}
						if ( invComponentRef.GetItemName( currentItemId ) != 'q111_imlerith_acorn'  && !invComponentRef.ItemHasTag( currentItemId, 'NoEquip' ) ) 
						{
							AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
						}
					}
					else if (invComponentRef.GetSlotForItemId(currentItemId) != EES_InvalidSlot) 
					{
						AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
					}
					AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
					break;
				// W3EE - End
				default:
					break;
			}
			//Kolaris - Inventory Options
			if (((canDrop && !isQuestItem) || Options().DropQuestItems()) && !isBodkinBolt && currentInventoryState != IMS_Shop)
			{
				AddInputBinding("panel_button_common_drop", "gamepad_Y", IK_R, true);
			}
			if (invComponentRef.CanBeCompared(currentItemId))
			{
				buttonLabel = GetHoldLabel() + " " + GetLocStringByKeyExt("panel_common_compare");
				AddInputBinding(buttonLabel, "gamepad_L2", -1, true, true);
			}
		}
		
		m_managerRef.updateInputFeedback();
	}
	
	// W3EE - Begin
	public  function HandleUserFeedback(keyName:string):void
	{
		var currentInventoryState : EInventoryMenuState;
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		if( ( currentInventoryState == IMS_Stash || currentInventoryState == IMS_Shop ) && keyName == "gamepad_R2" )
		{
			invMenuRef.SwitchShowStashItems();
		}
		if( /*( currentInventoryState == IMS_Stash ) &&*/ keyName == "gamepad_L2" )
		{
			invMenuRef.TransferMiscItems();
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
	// W3EE - End
	
	protected  function execurePrimaryAction():void
	{
		var currentInventoryState : EInventoryMenuState;
		var itemsCount : int;
		var newId  : SItemUniqueId;

		if ( invComponentRef.IsIdValid(currentItemId) )
		{
			currentInventoryState = invMenuRef.GetCurrentInventoryState();
			if( invComponentRef.IsItemSingletonItem(currentItemId) )
				itemsCount = invComponentRef.SingletonItemGetAmmo(currentItemId);
			else
				itemsCount = invComponentRef.GetItemQuantity(currentItemId);
				
			switch (currentInventoryState)
			{
				case IMS_Player:
					if (invComponentRef.ItemHasTag(currentItemId, 'mod_dye'))
					{
						invMenuRef.OnUseDye(currentItemId);
					}
					else if ( invComponentRef.ItemHasTag(currentItemId, 'Painting') )
					{
						invMenuRef.ShowPainting(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
					{
						invMenuRef.OnReadBook(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'Upgrade'))
					{
						invMenuRef.OnPutInSocket(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'WeaponReapairKit') || 
							 invComponentRef.ItemHasTag(currentItemId, 'ArmorReapairKit'))
					{
						invMenuRef.OnRepairItem(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'SteelOil') || 
						 invComponentRef.ItemHasTag(currentItemId, 'SilverOil'))
					{
						invMenuRef.ShowApplyOilMode(currentItemId);
					}
					else if (!invMenuRef.TryEquipToPockets(currentItemId, currentSlot))
					{
						invMenuRef.OnEquipItem(currentItemId, currentSlot, itemsCount);
					}
					break;
				case IMS_Shop:
					invMenuRef.OnSellItem(currentItemId, itemsCount);
					break;
				case IMS_Container:
					invMenuRef.OnTransferItem(currentItemId, itemsCount, -1);
					break;
				case IMS_HorseInventory:
					
					if (IsHorseItem(currentItemId))
					{
						newId = GetWitcherPlayer().GetHorseManager().MoveItemToHorse(currentItemId, itemsCount);
						GetWitcherPlayer().GetHorseManager().EquipItem(newId);
						invMenuRef.UpdateHorsePaperdoll();
						invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
					}
					else
					{
						GetWitcherPlayer().GetHorseManager().MoveItemToHorse(currentItemId, itemsCount);
						invMenuRef.UpdateHorseInventory();
						invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
					}
					break;
				case IMS_Stash:
					invMenuRef.MoveToStash(currentItemId);
					break;
				default:
					break;
			}
		}
	}
}

class W3ExternalGridContext extends W3InventoryItemContext
{
	protected  function updateInputFeedback():void
	{
		var currentInventoryState : EInventoryMenuState;
		var itemCategory : name;
		var canCompare : bool;
		var isSchematic : bool;
		var buttonLabel : string;
		
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		
		if (currentInventoryState == IMS_Stash)
		{
			// W3EE - Begin
			if( !invMenuRef || !invComponentRef )
			{
				return;
			}
			
			if( invComponentRef.IsIdValid(currentItemId) )
			{
				AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
				AddInputBinding("w3ee_transfer", "gamepad_L2", IK_U, true);
				AddInputBinding("w3ee_sort_stash", "gamepad_R2", IK_T, true);
				if( !invComponentRef.ItemHasTag(currentItemId, 'NoDrop') && !invComponentRef.ItemHasTag(currentItemId,'Quest') )
				{
					AddInputBinding("panel_button_common_drop", "gamepad_Y", IK_R, true);
				}
			}
			// W3EE - End
		}
		else
		{
			if (!invMenuRef || !invComponentRef)
			{
				return;
			}
			
			if (invComponentRef.IsIdValid(currentItemId))
			{
				switch (currentInventoryState)
				{
					case IMS_Shop:
						AddInputBinding("panel_inventory_quantity_popup_buy", "enter-gamepad_A", IK_Space, true);
						break;
					case IMS_Container:
					case IMS_HorseInventory:
					case IMS_Stash:
						AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
						break;
				}
				itemCategory = invComponentRef.GetItemCategory(currentItemId);
				isSchematic = itemCategory == 'alchemy_recipe' || itemCategory == 'crafting_schematic';
				if (invComponentRef.CanBeCompared(currentItemId))
				{
					buttonLabel = GetHoldLabel() + " " + GetLocStringByKeyExt("panel_common_compare");
					AddInputBinding(buttonLabel, "gamepad_L2", -1, true, true);
				}
				else
				if (isSchematic)
				{
					AddInputBinding("panel_button_inventory_item_info", "gamepad_L2", IK_E, true);
				}
			}
		}
		m_managerRef.updateInputFeedback();
	}
	
	// W3EE - Begin
	public  function HandleUserFeedback(keyName:string):void 
	{
		var currentInventoryState : EInventoryMenuState;
		var itemsCount : int;
		
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		itemsCount = invComponentRef.GetItemQuantity(currentItemId);
		
		if( currentInventoryState == IMS_Stash )
		{
			if( keyName == "enter-gamepad_A" )
			{
				if (!theInput.LastUsedPCInput() || IsPadBindingExist(keyName)) 
				{
					execurePrimaryAction();
				}
			}
			else if( keyName == "gamepad_R2" )
			{
				invMenuRef.SwitchShowStashItems();
			}
			else if( keyName == "gamepad_L2" )
			{
				invMenuRef.TransferMiscItems();
			}
			else if( keyName == "gamepad_Y" )
			{
				invMenuRef.HorseDropItem(invComponentRef, currentItemId, itemsCount);
			}
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
	// W3EE - End
	
	protected  function execurePrimaryAction():void
	{
		var currentInventoryState : EInventoryMenuState;
		var itemsCount:int;
		
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		if( invComponentRef.IsItemSingletonItem(currentItemId) )
			itemsCount = invComponentRef.SingletonItemGetAmmo(currentItemId);
		else
			itemsCount = invComponentRef.GetItemQuantity(currentItemId);
		switch (currentInventoryState)
		{
			case IMS_Shop:
				invMenuRef.OnBuyItem(currentItemId, itemsCount, -1);
				break;
			case IMS_Container:
				invMenuRef.OnTransferItem(currentItemId, itemsCount, -1);
				break;
			case IMS_HorseInventory:				
				GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(currentItemId, itemsCount);
				invMenuRef.UpdateInventoryFilter(IFT_AllExceptHorseItem);
				invMenuRef.UpdateHorseInventory();
				invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
				break;
			case IMS_Stash:
				invMenuRef.TakeItemFromStash(currentItemId);
				break;
		}
	}
}

class W3InventoryPaperdollContext extends W3InventoryItemContext
{
	protected  function updateInputFeedback():void
	{
		var horsePaperdollInv  	  : W3GuiHorseInventoryComponent;
		var currentInventoryState : EInventoryMenuState;
		
		var isBodkinBolt    : bool;
		var canDrop 	    : bool;
		var isQuestItem     : bool;
		var isSingletonItem : bool;
		var isHorseItem 	: bool;		
		
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		
		if (!invMenuRef || !invComponentRef)
		{
			return;
		}
		
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		// W3EE - Begin
		isBodkinBolt = false; //invComponentRef.GetItemName(currentItemId) == 'Bodkin Bolt';
		// W3EE - End
		canDrop = !invComponentRef.ItemHasTag(currentItemId, 'NoDrop');
		isQuestItem = invComponentRef.ItemHasTag(currentItemId,'Quest');
		isSingletonItem = invComponentRef.ItemHasTag(currentItemId, 'SingletonItem');
		
		horsePaperdollInv = (W3GuiHorseInventoryComponent)invMenuRef.GetCurrentInventoryComponent();
		if (horsePaperdollInv && horsePaperdollInv.GetInventoryComponent().IsIdValid(currentItemId) && horsePaperdollInv.isHorseItem(currentItemId))
		{
			isHorseItem = true;
		}
		else
		{
			isHorseItem = false;
		}
		
		if (invComponentRef.IsIdValid(currentItemId) && !isBodkinBolt )
		{
			if ( canDrop && !isQuestItem && !isSingletonItem && !isHorseItem && !IsMultipleSlot(currentSlot) && currentSlot != EES_Bolt ) AddInputBinding("panel_button_common_drop", "gamepad_Y", IK_R, true);
			AddInputBinding("panel_button_inventory_unequip", "enter-gamepad_A", IK_Space, true);
		}
		else if (invSecondComponentRef && invSecondComponentRef.IsIdValid(currentItemId))
		{
			AddInputBinding("panel_button_inventory_unequip", "enter-gamepad_A", IK_Space, true);
		}
		
		if( invMenuRef.IsSlotInPreview( currentSlot ) )
		{
			AddInputBinding( "panel_button_unpreview_item", "gamepad_X", IK_X, true );
		}		
		
		m_managerRef.updateInputFeedback();
	}
	
	public  function HandleUserFeedback( keyName : string ):void
	{
		if( keyName == "gamepad_X" )
		{
			
			if( invMenuRef.IsSlotInPreview( currentSlot ) )
			{
				invMenuRef.RemovePreviewFromSlot( currentSlot );
			}
		}
		else
		{
			super.HandleUserFeedback( keyName );
		}
	}
	
	protected  function execurePrimaryAction():void
	{
		if (invMenuRef.GetCurrentInventoryState() != IMS_HorseInventory)
		{
			invMenuRef.OnUnequipItem(currentItemId, -1);
		}
		else
		{
			GetWitcherPlayer().GetHorseManager().UnequipItem(currentSlot);
			invMenuRef.UpdateInventoryFilter(IFT_HorseItems);
			invMenuRef.UpdateHorsePaperdoll();
			invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
		}
	}
}

class W3PlayerStatsContext extends W3UIContext
{
	protected var invMenuRef : CR4InventoryMenu;
	protected var statName   : name;
	
	public function SetInventoryRef(TargetInvMenu : CR4InventoryMenu):void
	{
		invMenuRef = TargetInvMenu;
	}
	
	public function SetStatName(value:name):void
	{
		statName = value;
		invMenuRef.ShowStatTooltip(statName);
	}
	
	protected  function updateInputFeedback():void
	{
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		m_managerRef.updateInputFeedback();
		invMenuRef.ShowStatTooltip(statName);
	}
}

// W3EE - Begin
class W3StashGridContext extends W3InventoryItemContext
{
	protected  function updateInputFeedback():void
	{
		var currentInventoryState : EInventoryMenuState;
		var canDrop : bool;
		var isBodkinBolt : bool;
		var isQuestItem : bool;
		var curEquipedItem : SItemUniqueId;
		var cantUse : bool;
		
		var buttonLabel : string;
		
		LogChannel('CONTEXT'," updateInputFeedback "+invMenuRef+"; "+invComponentRef);
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		if (!invMenuRef || !invComponentRef)
		{
			return;
		}
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		
		if( currentInventoryState == IMS_Stash || currentInventoryState == IMS_Shop )
		{
			if( currentInventoryState != IMS_Shop )
			{
				AddInputBinding("w3ee_transfer", "gamepad_L2", IK_U, true);
			}
			AddInputBinding("w3ee_sort_stash", "gamepad_R2", IK_T, true);
		}
		
		if (invComponentRef.IsIdValid(currentItemId))
		{
			canDrop = !invComponentRef.ItemHasTag(currentItemId, 'NoDrop');
			isQuestItem = invComponentRef.ItemHasTag(currentItemId,'Quest');
			// W3EE - Begin
			isBodkinBolt = false; //invComponentRef.GetItemName(currentItemId) == 'Bodkin Bolt';
			// W3EE - End
			
			
			
			cantUse = false; //FactsQuerySum("tut_forced_preparation") > 0 && invComponentRef.GetItemName(currentItemId) == 'Thunderbolt 1';
			if(canDrop && cantUse)
			{
				canDrop = false;
			}
			
			switch (currentInventoryState)
			{
				case IMS_Player:
					
					if( invComponentRef.GetItemName( currentItemId ) == 'q705_tissue_extractor' )
					{
						AddInputBinding("panel_button_hud_interaction_useitem", "gamepad_X", IK_X, true);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'Painting'))
					{
						AddInputBinding("panel_button_common_examine", "enter-gamepad_A", IK_E, true);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
					{
						AddInputBinding("panel_button_inventory_read", "enter-gamepad_A", IK_E, true);
					}
					else if ((invComponentRef.ItemHasTag(currentItemId, 'Edibles')) ||
						    (invComponentRef.ItemHasTag(currentItemId, 'Drinks')) ||
							(invComponentRef.ItemHasTag(currentItemId, 'Potion')))
					{
						if (invComponentRef.IsItemSingletonItem(currentItemId) && thePlayer.inv.SingletonItemGetAmmo(currentItemId) == 0)
						{
							cantUse = true;
						}
						
						if (!cantUse)
						{
							AddInputBinding("panel_button_inventory_consume", "gamepad_X", IK_E, true);
						}
						if ( invComponentRef.GetItemName( currentItemId ) != 'q111_imlerith_acorn'  && !invComponentRef.ItemHasTag( currentItemId, 'NoEquip' ) ) 
						{
							AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
						}
					}
					else if (invComponentRef.GetSlotForItemId(currentItemId) != EES_InvalidSlot) 
					{
						AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
					}
					break;
				case IMS_Shop:
					if (!isBodkinBolt)
					{
						AddInputBinding("panel_inventory_quantity_popup_sell", "enter-gamepad_A", IK_Space, true);
					}
					break;
				case IMS_Container:
					AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
					break;
				case IMS_HorseInventory:
					if (IsHorseItem(currentItemId))
					{
						AddInputBinding("panel_button_inventory_equip", "enter-gamepad_A", IK_Space, true);
					}
					else
					{
						AddInputBinding("panel_button_inventory_transfer", "enter-gamepad_A", IK_Space, true);
					}
					break;
				case IMS_Stash:
					break;
				default:
					break;
			}
			if (canDrop && !isQuestItem && !isBodkinBolt && currentInventoryState != IMS_Shop)
			{
				AddInputBinding("panel_button_common_drop", "gamepad_Y", IK_R, true);
			}
			if (invComponentRef.CanBeCompared(currentItemId))
			{
				buttonLabel = GetHoldLabel() + " " + GetLocStringByKeyExt("panel_common_compare");
				AddInputBinding(buttonLabel, "gamepad_L2", -1, true, true);
			}
		}
		
		m_managerRef.updateInputFeedback();
	}
	
	public  function HandleUserFeedback(keyName:string):void
	{
		var currentInventoryState : EInventoryMenuState;
		currentInventoryState = invMenuRef.GetCurrentInventoryState();
		if( ( currentInventoryState == IMS_Stash || currentInventoryState == IMS_Shop ) && keyName == "gamepad_R2" )
		{
			invMenuRef.SwitchShowStashItems();
		}
		if( /*( currentInventoryState == IMS_Stash ) &&*/ keyName == "gamepad_L2" )
		{
			invMenuRef.TransferMiscItems();
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
		
	protected  function execurePrimaryAction():void
	{
		var currentInventoryState : EInventoryMenuState;
		var itemsCount : int;
		var newId  : SItemUniqueId;

		if ( invComponentRef.IsIdValid(currentItemId) )
		{
			currentInventoryState = invMenuRef.GetCurrentInventoryState();
			if( invComponentRef.IsItemSingletonItem(currentItemId) )
				itemsCount = invComponentRef.SingletonItemGetAmmo(currentItemId);
			else
				itemsCount = invComponentRef.GetItemQuantity(currentItemId);
				
			switch (currentInventoryState)
			{
				case IMS_Player:
					if (invComponentRef.ItemHasTag(currentItemId, 'mod_dye'))
					{
						invMenuRef.OnUseDye(currentItemId);
					}
					else if ( invComponentRef.ItemHasTag(currentItemId, 'Painting') )
					{
						invMenuRef.ShowPainting(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'ReadableItem'))
					{
						invMenuRef.OnReadBook(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'Upgrade'))
					{
						invMenuRef.OnPutInSocket(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'WeaponReapairKit') || 
							 invComponentRef.ItemHasTag(currentItemId, 'ArmorReapairKit'))
					{
						invMenuRef.OnRepairItem(currentItemId);
					}
					else if (invComponentRef.ItemHasTag(currentItemId, 'SteelOil') || 
						 invComponentRef.ItemHasTag(currentItemId, 'SilverOil'))
					{
						invMenuRef.ShowApplyOilMode(currentItemId);
					}
					else if (!invMenuRef.TryEquipToPockets(currentItemId, currentSlot))
					{
						invMenuRef.OnEquipItem(currentItemId, currentSlot, itemsCount);
					}
					break;
				case IMS_Shop:
					invMenuRef.OnSellItem(currentItemId, itemsCount);
					break;
				case IMS_Container:
					invMenuRef.OnTransferItem(currentItemId, itemsCount, -1);
					break;
				case IMS_HorseInventory:
					
					if (IsHorseItem(currentItemId))
					{
						newId = GetWitcherPlayer().GetHorseManager().MoveItemToHorse(currentItemId, itemsCount);
						GetWitcherPlayer().GetHorseManager().EquipItem(newId);
						invMenuRef.UpdateHorsePaperdoll();
						invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
					}
					else
					{
						GetWitcherPlayer().GetHorseManager().MoveItemToHorse(currentItemId, itemsCount);
						invMenuRef.UpdateHorseInventory();
						invMenuRef.PopulateTabData(invMenuRef.getTabFromItem(currentItemId));
					}
					break;
				case IMS_Stash:
					invMenuRef.MoveToStash(currentItemId);
					break;
				default:
					break;
			}
		}
	}
}
// W3EE - End