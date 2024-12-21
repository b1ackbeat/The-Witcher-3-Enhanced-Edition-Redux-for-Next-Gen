class WmkQuickInventory extends CR4HudModuleBase {

	private var m_cfg : WmkQuickSlotsConfig;
	private var m_saveData : WmkQuickInventorySaveData;
	private const var MAX_SAVED_RECEIVED_ITEMS : int; default MAX_SAVED_RECEIVED_ITEMS = 30;
	private const var MAX_NEWEST_ITEMS : int; default MAX_NEWEST_ITEMS = 12; // !!! DON'T CHANGE THIS !!!

	private var m_flashModule : CScriptedFlashSprite;
	private var m_flashValueStorage : CScriptedFlashValueStorage;

	private var m_fxSetFocusedModule : CScriptedFlashFunction;
	private var m_fxSetTooltipState : CScriptedFlashFunction;
	private var m_fxPaperDollRemoveItem : CScriptedFlashFunction;
	private var m_fxInventoryRemoveItem : CScriptedFlashFunction;
	private var m_fxHideSelectionMode : CScriptedFlashFunction;
	private var m_fxSetInputFeedbackPanelVisibility : CScriptedFlashFunction;
	private var m_fxSetNewestItemsModuleVisibility : CScriptedFlashFunction;
	private var m_fxSetBuffsViewMode : CScriptedFlashFunction;

	private var m_quickSlots : WmkQuickSlots;
	private var m_radialMenu : CR4HudModuleRadialMenu;

	private var m_shown : bool;
	private var m_hideAction : EWmkInventoryHideAction;

	private var m_currentModule : EWmkInventoryModule; default m_currentModule = IMOD_Invalid;
	private var m_previousModule : EWmkInventoryModule; default m_previousModule = IMOD_Invalid;
	private var m_currentTab : EWmkInventoryTab; default m_currentTab = ITAB_Invalid;
	private var m_currentSelectedItem : SItemUniqueId;

	private var m_paperdollSlots : array<EEquipmentSlots>;
	private var m_paperdollItemInfo : array<SWmkPaperDollItemInfo>;
	private var m_paperdollInvalidItemInfo : SWmkPaperDollItemInfo;

	private var m_playerInv : W3GuiPlayerInventoryComponent;
	private var m_paperdollInv : W3GuiPaperdollInventoryComponent;
	private var m_tooltipDataProvider : W3TooltipComponent;

	private var m_selectionModeActive : bool;
	private var m_selectionModeItem : SItemUniqueId;

	// The feedback buttons are not updated when the HUD module is made visible until the data for
	// the active inventory tab is retrieved. This to avoid avoid multiple updates in a short period of time, which
	// sometimes are visible. Note that updating the feedback buttons from some event handlers doesn't work, so
	// the updates are done only when ticking...
	private var m_inputFeedbackButtons : array<SKeyBinding>;
	private var m_inputFeedbackUpdateStatus : EWmkInputFeedbackUpdateStatus;
	private var m_inputFeedbackPanelVisible : bool;
	private const var DEFAULT_ITEM_ACTION_BUTTON_ID : int; default DEFAULT_ITEM_ACTION_BUTTON_ID = -100;
	private const var SORT_ITEMS_BUTTON_ID : int; default SORT_ITEMS_BUTTON_ID = -101;
	private const var BACK_BUTTON_ID : int; default BACK_BUTTON_ID = -102;
	private const var BACK_TO_GAME_BUTTON_ID : int; default BACK_TO_GAME_BUTTON_ID = -103;
	private const var RADIAL_MENU_BUTTON_ID : int; default RADIAL_MENU_BUTTON_ID = -104;
	private var m_radialKeyPressed : bool;

	event OnConfigUI() {
		super.OnConfigUI();

		m_cfg = theGame.m_quickSlotsConfig;

		if (GetWitcherPlayer()) {
			OnPlayerWitcherSpawned();
		}

		m_flashModule = GetModuleFlash();
		m_flashValueStorage = GetModuleFlashValueStorage();

		m_fxSetFocusedModule = m_flashModule.GetMemberFlashFunction("SetFocusedModule");
		m_fxSetTooltipState = m_flashModule.GetMemberFlashFunction("SetTooltipState");
		m_fxPaperDollRemoveItem = m_flashModule.GetMemberFlashFunction("PaperDollRemoveItem");
		m_fxInventoryRemoveItem = m_flashModule.GetMemberFlashFunction("InventoryRemoveItem");
		m_fxHideSelectionMode = m_flashModule.GetMemberFlashFunction("HideSelectionMode");
		m_fxSetInputFeedbackPanelVisibility = m_flashModule.GetMemberFlashFunction("SetInputFeedbackPanelVisibility");
		m_fxSetNewestItemsModuleVisibility = m_flashModule.GetMemberFlashFunction("SetNewestItemsModuleVisibility");

		m_fxSetBuffsViewMode = theGame.GetHud().GetHudModule("BuffsModule").GetModuleFlash().GetMemberFlashFunction("WmkSetQuickInventoryViewMode");

		// For other modules the opacity is set in SnapToAnchorPosition, but this module doesn't use an anchor. The default
		// value is 0.8, which is hardcoded in the flash file...
		m_fxSetMaxOpacitySFF.InvokeSelfOneArg(FlashArgNumber(theGame.GetUIOpacity()));

		m_quickSlots = new WmkQuickSlots in this;
		m_quickSlots.Initialize(this);

		m_radialMenu = (CR4HudModuleRadialMenu)theGame.GetHud().GetHudModule("RadialMenuModule");

		theInput.RegisterListener(this, 'OnShowQuickInventory', 'QuickInventory');
	}

	// The event is dispatched after all components are initialized. For example the paperdoll module and the newest items module
	// are initialized when the first frame (and actually the only one) is played.
	event OnWmkConfigEnd() {
		setupInventory();
		setupPaperDollSlots();
		setupNewestItemsModule();
	}

	public function GetQuickSlotsInstance() : WmkQuickSlots {
		return m_quickSlots;
	}

	public function IsShown() : bool {
		return m_shown;
	}

	public function CanShow(showDisallowedMessage : bool) : bool {
		if (!m_shown) {
			if (!thePlayer.IsCiri() && thePlayer.IsActionAllowed(EIAB_OpenInventory)) {
				if (!theGame.IsDialogOrCutscenePlaying() && !theGame.IsBlackscreenOrFading()) {
					if (m_radialMenu.IsRadialMenuOpened() || !GetWitcherPlayer().IsUITakeInput()) {
						return true;
					}
				}
			} else if (showDisallowedMessage) {
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenInventory);
			}
		}

		return false;
	}

	public function ShowQuickInventory() {
		if (CanShow(true)) {
			m_fxShowElementSFF.InvokeSelfThreeArgs(FlashArgBool(true), FlashArgBool(true), FlashArgBool(true));
		}
	}

	public function HideQuickInventory(hideAction : EWmkInventoryHideAction) {
		if (m_shown && !m_selectionModeActive) {
			m_hideAction = hideAction;
			m_fxShowElementSFF.InvokeSelfThreeArgs(FlashArgBool(false), FlashArgBool(true), FlashArgBool(true));
		}
	}

	event OnShowQuickInventory(action : SInputAction) {
		if (IsReleased(action)) {
			if (m_shown) {
				HideQuickInventory(QIHA_HideRadialMenu);
			} else {
				ShowQuickInventory();
			}
		}
	}

	// Called from WmkQuickSlots when mod's configuration has changed.
	public function OnConfigChanged() {
		setupNewestItemsModule();
	}

	// Called from W3PlayerWitcher.OnSpawn event handler.
	// Note that usually the witcher is spawned before this HUD module is initialized. But I think at least once the
	// witcher is respawned during a game session (when going to Vizima for the first time?) and the witcher may be spawned
	// much later after a game is loaded if the initial active player is Ciri.
	public function OnPlayerWitcherSpawned() {
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();

		if (!witcherPlayer.m_quickInventorySaveData) {
			witcherPlayer.m_quickInventorySaveData = new WmkQuickInventorySaveData in witcherPlayer;
		}

		if (!m_saveData) {
			if (m_cfg.QUICK_INVENTORY_RESET_NEWEST_ITEMS_ON_LOAD) {
				witcherPlayer.m_quickInventorySaveData.m_lastReceivedItems.Clear();
			}
		}

		m_saveData = witcherPlayer.m_quickInventorySaveData;
	}

	// Called from W3PlayerWitcher.OnItemGiven, when a new item is added to player's inventory.
	public function RegisterNewItem(item : SItemUniqueId) {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var itemName : name;
		var data : SWmkReceivedItemSaveData;
		var tmpItem : SItemUniqueId;
		var i : int;

		if (!inv.IsIdValid(item)) {
			return;
		}

		if (inv.ItemHasTag(item, theGame.params.TAG_DONT_SHOW) || inv.ItemHasTag(item, theGame.params.TAG_DONT_SHOW_ONLY_IN_PLAYERS)) {
			return;
		}

		itemName = inv.GetItemName(item);
		if ((itemName == 'Bodkin Bolt') || (itemName == 'Harpoon Bolt')) {
			return;
		}

		for (i = m_saveData.m_lastReceivedItems.Size() - 1; i >= 0; i -= 1) {
			tmpItem = m_saveData.m_lastReceivedItems[i].m_item;
			if (!inv.IsIdValid(tmpItem) || (tmpItem == item)) {
				m_saveData.m_lastReceivedItems.Erase(i);
			}
		}

		while (m_saveData.m_lastReceivedItems.Size() >= MAX_SAVED_RECEIVED_ITEMS) {
			m_saveData.m_lastReceivedItems.Erase(m_saveData.m_lastReceivedItems.Size() - 1);
		}

		data.m_item = item;
		data.m_timestamp = m_flashModule.GetMemberFlashInt("unixTime");

		m_saveData.m_lastReceivedItems.Insert(0, data);

		if (m_shown) {
			UpdateNewestItems();
		}
	}

	// INVENTORY CONFIGURATION
	// This is easier to do directly in the flash module, but I moved the code here because in this way is more customizable.

	private function setupInventory() {
		var configData : CScriptedFlashObject = m_flashValueStorage.CreateTempFlashObject();
		configData.SetMemberFlashArray("tabData", createInventoryTabData());
		configData.SetMemberFlashArray("gridTabSections", createInventoryTabSections());
		m_flashValueStorage.SetFlashObject("inventory.config.data", configData);
	}

	private function createInventoryTabData() : CScriptedFlashArray {
		var result : CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();
		var item : CScriptedFlashObject;

		item = m_flashValueStorage.CreateTempFlashObject();
		item.SetMemberFlashString("icon", "POTIONS");
		item.SetMemberFlashString("locKey", "[[panel_inventory_filter_type_alchemy_items]]");
		result.PushBackFlashObject(item);

		item = m_flashValueStorage.CreateTempFlashObject();
		item.SetMemberFlashString("icon", "DEFAULT");
		item.SetMemberFlashString("locKey", "[[item_category_edibles]]");
		result.PushBackFlashObject(item);

		item = m_flashValueStorage.CreateTempFlashObject();
		item.SetMemberFlashString("icon", "BOOKS");
		item.SetMemberFlashString("locKey", "[[panel_glossary_books]]");
		result.PushBackFlashObject(item);

		return result;
	}

	private function createInventoryTabSections() : CScriptedFlashArray {
		var toolsLabel : string;
		var sectionsList : CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();

		// The label for tools can be too long for some languages. For example is "Ferramentas"
		// for BR or "Herramientas" for ES, but is ok for EN (Tools), FR (Outils), JP, KR and ZH. Is too much
		// to use two columns for tools just to fit the label. If the user starts the game with a language
		// for which the label is short then it will be used, otherwise ... bad luck.
		toolsLabel = GetLocStringByKey('item_category_tool');
		if (StrLen(toolsLabel) > 6) {
			toolsLabel = "-";
		}

		sectionsList.PushBackFlashObject(createItemSectionData(0, 0, 0, 2, "[[panel_alchemy_tab_potions]]"));
		sectionsList.PushBackFlashObject(createItemSectionData(0, 1, 3, 5, "[[panel_inventory_filter_type_decoctions]]"));
		sectionsList.PushBackFlashObject(createItemSectionData(0, 2, 6, 7, "[[panel_alchemy_tab_oils]]"));
		sectionsList.PushBackFlashObject(createItemSectionData(0, 3, 8, 8, toolsLabel));

		sectionsList.PushBackFlashObject(createItemSectionData(1, 0, 0, 2, ""));
		sectionsList.PushBackFlashObject(createItemSectionData(1, 1, 3, 5, "[[item_category_edibles]]"));
		sectionsList.PushBackFlashObject(createItemSectionData(1, 2, 6, 8, ""));

		sectionsList.PushBackFlashObject(createItemSectionData(2, 0, 0, 8, "[[panel_glossary_books]]"));

		return sectionsList;
	}

	private function createItemSectionData(tabIdx : int, sectionId : int, start : int, end : int, label : string) : CScriptedFlashObject {
		var result : CScriptedFlashObject = m_flashValueStorage.CreateTempFlashObject();
		var itemSectionData : CScriptedFlashObject =  m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.inventory_menu.ItemSectionData");

		itemSectionData.SetMemberFlashUInt("id", sectionId);
		itemSectionData.SetMemberFlashUInt("start", start);
		itemSectionData.SetMemberFlashUInt("end", end);
		itemSectionData.SetMemberFlashString("label", label);

		result.SetMemberFlashInt("tabIndex", tabIdx);
		result.SetMemberFlashObject("itemSectionData", itemSectionData);

		return result;
	}

	// PAPERDOLL CONFIGURATION

	private function setupPaperDollSlots() {
		m_paperdollSlots.PushBack(EES_SteelSword);
		m_paperdollSlots.PushBack(EES_SilverSword);
		m_paperdollSlots.PushBack(EES_Armor);
		m_paperdollSlots.PushBack(EES_Gloves);
		m_paperdollSlots.PushBack(EES_Pants);
		m_paperdollSlots.PushBack(EES_Boots);

		m_paperdollItemInfo.Resize(m_paperdollSlots.Size());
	}

	// NEWEST ITEMS MODULE

	private function setupNewestItemsModule() {
		m_fxSetNewestItemsModuleVisibility.InvokeSelfOneArg(FlashArgBool(m_cfg.QUICK_INVENTORY_SHOW_NEWEST_ITEMS));
	}

	// SHOW / HIDE event
	// Usually the module must be hidden by the user, but if the input context is changed then the module
	// may be hidden automatically. For example if somehow a scene is started...

	event OnWmkBeforeShowElementFromState(shown : bool) {
	}

	event OnWmkShowElementFromState(shown : bool) {
		this.log("OnWmkShowElementFromState: shown = " + shown);

		if (shown) {
			OnShow();
		} else {
			OnHide();
		}
	}

	private function OnShow() {
		m_quickSlots.OnQuickInventoryShow();
		m_fxSetBuffsViewMode.InvokeSelfOneArg(FlashArgBool(true));

		theGame.Pause("QuickInventory");
		theGame.GetGuiManager().RequestMouseCursor(true);

		if (!m_radialMenu.IsRadialMenuOpened()) {
			theGame.ForceUIAnalog(true);
			GetWitcherPlayer().SetUITakeInput(true);
		}

		// If the QuickInventory input context doesn't exist then StoreContext pushes something on a stack,
		// but doesn't actually change the input context. This means that RadialMenu input context may remain active
		// and bad things happen if the user presses the middle mouse button, uses the B controller
		// button etc... This is why the EMPTY_CONTEXT is stored first.
		theInput.StoreContext('EMPTY_CONTEXT');
		theInput.StoreContext('QuickInventory');

		m_playerInv = new W3GuiPlayerInventoryComponent in this;
		m_playerInv.Initialize(thePlayer.GetInventory());
		m_paperdollInv = new W3GuiPaperdollInventoryComponent in this;
		m_paperdollInv.Initialize(thePlayer.GetInventory());
		m_tooltipDataProvider = new W3TooltipComponent in this;
		m_tooltipDataProvider.initialize(m_playerInv.GetInventoryComponent(), m_flashValueStorage);

		m_fxSetTooltipState.InvokeSelfOneArg(
				FlashArgBool(GetWitcherPlayer().upscaledTooltipState));

		UpdatePaperDollSlots();

		if (m_cfg.QUICK_INVENTORY_SHOW_NEWEST_ITEMS) {
			UpdateNewestItems();
		}

		AddDefaultFeedbackButtons();

		m_inputFeedbackUpdateStatus = IFUS_Disabled;
		m_inputFeedbackPanelVisible = false;
		m_fxSetInputFeedbackPanelVisibility.InvokeSelfOneArg(FlashArgBool(false));

		m_hideAction = QIHA_Default;

		if (theInput.LastUsedPCInput()) {
			theGame.MoveMouseTo(0.50, 0.40);
		}

		m_radialKeyPressed = false;
		m_shown = true;
	}

	private function OnHide() {
		theGame.Unpause("QuickInventory");
		theGame.GetGuiManager().RequestMouseCursor(false);

		if (!m_radialMenu.IsRadialMenuOpened()) {
			theGame.ForceUIAnalog(false);
			GetWitcherPlayer().SetUITakeInput(false);
		}

		theInput.RestoreContext('QuickInventory', true);
		theInput.RestoreContext('EMPTY_CONTEXT', true);

		m_fxSetBuffsViewMode.InvokeSelfOneArg(FlashArgBool(false));
		m_quickSlots.OnQuickInventoryHide(m_hideAction);

		delete m_playerInv;
		delete m_paperdollInv;
		delete m_tooltipDataProvider;

		m_shown = false;
	}

	// Tick tick tick...

	event OnTick(timeDelta : float) {
		if (m_inputFeedbackUpdateStatus == IFUS_UpdateNextTick) {
			m_inputFeedbackUpdateStatus = IFUS_Default;
			UpdateFeedbackButtons();
		}
	}

	// INPUT HANDLING

	// Called when a mouse button is clicked: 0 = left, 1 == right, 2 == middle.
	event OnWmkMouseClick(buttonIdx : int) {
		if (!m_selectionModeActive && (buttonIdx == 1)) {
			HandleCloseInputAction(m_cfg.QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION);
		}
	}

	event OnWmkHandleInput(handled : bool, value : string, navEquivalent : string, code : float, fromJoystick : bool, details : string) {
		var nextFocusedModule : EWmkInventoryModule = IMOD_Invalid;

		if (handled || m_selectionModeActive) {
			return false;
		} else if ((value == "keyDown") || (value == "keyHold")) {
			if ((navEquivalent == "left") || (navEquivalent == "rightStickLeft")) {
				if (m_currentModule == IMOD_PaperDoll) {
					nextFocusedModule = IMOD_PlayerInventory;
				}
			} else if ((navEquivalent == "right") || (navEquivalent == "rightStickRight")) {
				if (m_currentModule == IMOD_PlayerInventory) {
					nextFocusedModule = IMOD_PaperDoll;
				}
			} else if ((navEquivalent == "down") || (navEquivalent == "rightStickDown")) {
				if (m_currentModule != IMOD_NewestItems) {
					nextFocusedModule = IMOD_NewestItems;
				}
			} else if ((navEquivalent == "up") || (navEquivalent == "rightStickUp")) {
				if (m_currentModule == IMOD_NewestItems) {
					if ((m_previousModule != IMOD_Invalid) && (m_previousModule != IMOD_NewestItems)) {
						nextFocusedModule = m_previousModule;
					} else {
						nextFocusedModule = IMOD_PlayerInventory;
					}
				}
			} else if ((value == "keyDown") && (RoundF(code) == IK_Tab) || (navEquivalent == "gamepad_L1")) {
				m_radialKeyPressed = true;
			}

			if (nextFocusedModule != IMOD_Invalid) {
				m_fxSetFocusedModule.InvokeSelfOneArg(FlashArgInt(nextFocusedModule));
			}
		} else if (value == "keyUp") {
			if (RoundF(code) == IK_Escape) {
				HandleCloseInputAction(m_cfg.QUICK_INVENTORY_ESC_ACTION);
			} else if (navEquivalent == "gamepad_R2") {
				HandleCloseInputAction(m_cfg.QUICK_INVENTORY_RIGHT_TRIGGER_ACTION);
			}  else if ((RoundF(code) == IK_Tab) || (navEquivalent == "gamepad_L1")) {
				if (m_radialKeyPressed) {
					HideQuickInventory(QIHA_ShowRadialMenu);
				}
			} else if (navEquivalent == "gamepad_R1") {
				HandleCloseInputAction(m_cfg.QUICK_INVENTORY_RIGHT_BUMPER_ACTION);
			} else if (navEquivalent == "escape-gamepad_B") {
				HideQuickInventory(QIHA_Default);
			} else if ((RoundF(code) == IK_Q) || (navEquivalent == "gamepad_R3")) {
				if (m_currentModule == IMOD_PlayerInventory) {
					SortInventoryItems();
				}
			}
		}
	}

	private function HandleCloseInputAction(action : EWmkInventoryInputAction) {
		switch (action) {
			case IACT_Nothing: return;
			case IACT_Back: HideQuickInventory(QIHA_Default); break;
			case IACT_BackToGame: HideQuickInventory(QIHA_HideRadialMenu); break;
			case IACT_QuickAccessMenu:
				HideQuickInventory(QIHA_ShowRadialMenu);
				break;
		}
	}

	// The event is dispatched when an inventory module is focused.
	// This may be called even if the module is already focused (prevModuleIdx == newModuleIdx).
	// Also may be called with newModuleIdx == -1 when no module is focused.

	event OnWmkModuleFocused(prevModuleIdx : int, newModuleIdx : int) {
		this.log("OnWmkModuleFocused: prevModuleIdx = " + prevModuleIdx + " newModuleIdx = " + newModuleIdx);

		// The previous module is required for navigation when the player is using a gamepad. Is set to a valid value
		// only when the focus is changed from one module to another.
		if ((prevModuleIdx != -1) && (newModuleIdx != -1) && (prevModuleIdx != newModuleIdx)) {
			m_previousModule = prevModuleIdx;
		} else {
			m_previousModule = IMOD_Invalid;
		}

		m_currentModule = newModuleIdx;
		ResetCurrentSelectedInventoryItem();
	}

	// INVENTORY EVENTS

	// Called when the current tab is changed.
	// This is dispatched for the first time when the HUD module is initialized.
	event OnTabChanged(tabIndex : int) {
		this.log("OnTabChanged: tabIndex = " + tabIndex);

		m_currentTab = tabIndex;
		ResetCurrentSelectedInventoryItem();
	}

	// Called when the ActionScript code needs the data for an inventory tab.
	// Dispatched once when the HUD module is initialized, so the event must not be handled if the HUD module is not shown.
	event OnTabDataRequested(tabIndex : int, isHorse : bool) {
		this.log("OnTabDataRequested: tabIndex = " + tabIndex + " isHorse = " + isHorse);

		if (m_shown) {
			PopulateTabData(tabIndex);
		}
	}

	// Called after the data for a tab was received and processed by the ActionScript code.
	event OnWmkTabDataReceived(tabIndex : int) {
		this.log("OnWmkTabDataReceived: tabIndex = " + tabIndex);

		if (m_shown && (m_inputFeedbackUpdateStatus == IFUS_Disabled)) {
			m_inputFeedbackUpdateStatus = IFUS_UpdateNextTick;
		}
	}

	// Called when the final grid position is different than the one specified.
	event OnSaveItemGridPosition(item : SItemUniqueId, gridPos : int) {
		if ((m_currentTab == ITAB_PotionsOilsAndTools) || (m_currentTab == ITAB_FoodAndDrinks)) {
			SaveItemGridPosition(item, gridPos);
		}
	}

	// Called when an inventory item is selected.
	// This event is also called for inventory tab elements, but the item parameter is invalid in this case.
	// The posX and posY are screen coordinates, not grid coordinates.
	event OnSelectInventoryItem(item : SItemUniqueId, slotType : int, posX : float, posY : float) {
		this.log("OnSelectInventoryItem: item = " + thePlayer.inv.GetItemName(item));
		SetCurrentSelectedInventoryItem(item);
	}

	// Called to clear the "new" flag for an inventory item.
	event OnClearSlotNewFlag(item : SItemUniqueId) {
		if (m_playerInv) {
			m_playerInv.ClearItemIsNewFlag(item);
		}
	}

	// Called when an inventory item is dragged and dropped over an empty inventory slot.
	event OnMoveItem(item : SItemUniqueId, moveToIndex : int) {
		if ((m_currentTab == ITAB_PotionsOilsAndTools) || (m_currentTab == ITAB_FoodAndDrinks)) {
			SaveItemGridPosition(item, moveToIndex);
			UpdateInventoryItem(m_currentTab, item);
		}
	}

	// Called when an inventory item is dropped over another inventory item.
	event OnMoveItems(firstItem : SItemUniqueId, firstIndex : int, secondItem : SItemUniqueId, secondIndex : int) {
		if ((m_currentTab == ITAB_PotionsOilsAndTools) || (m_currentTab == ITAB_FoodAndDrinks)) {
			SaveItemGridPosition(firstItem, firstIndex);
			SaveItemGridPosition(secondItem, secondIndex);
			UpdateTwoInventoryItems(m_currentTab, firstItem, secondItem);
		}
	}

	// Called for inventory items to execute the default action when the user double clicks the slot,
	// presses E, ENTER or SPACE keys, presses the A controller button etc... The default ActionScript code
	// sends different events, like OnConsumeItem, OnReadBook etc..., but the code is deprecated
	// and doesn't handle all item types, like oils, potions or repair tools.
	event OnWmkDefaultAction(item : SItemUniqueId) {
		switch (GetItemType(item)) {
			case ITEM_Oil: ShowOilSelectionMode(item); break;
			case ITEM_RepairKit: ShowRepairKitSelectionMode(item); break;
			case ITEM_Potion:
			case ITEM_Decoction:
				if (thePlayer.inv.SingletonItemGetAmmo(item) > 0) {
					DrinkPotion(item);
				}
				break;
			case ITEM_FoodOrDrink: ConsumeItem(item); break;
			case ITEM_Book: ReadBook(item); break;
		}
	}

	// PAPERDOLL EVENTS
	// The OnApplyOil and OnApplyRepairKit events are dispatched for drag & drop operations.

	event OnApplyOil(item : SItemUniqueId, targetSlot : int) {
		ApplyOil(item, targetSlot);
	}

	event OnApplyRepairKit(item : SItemUniqueId, targetSlot : int) {
		ApplyRepairKit(item, targetSlot);
	}

	event OnDropOnPaperdoll(item : SItemUniqueId, slot : int, quantity : int) {
		// nothing
	}

	event OnSelectPaperdollItem(item : SItemUniqueId, slotType : int, positionX : float, positionY : float) {
	}

	// TOOLTIP EVENTS

	event OnGetItemData(item : SItemUniqueId, compareItemType : int) {
		SetItemTooltipData(item);
	}

	event OnGetItemDataForMouse(item : SItemUniqueId, compareItemType : int) {
		SetItemTooltipData(item);
	}

	event OnTooltipScaleStateSave(isScaledUp : bool) {
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();
		witcherPlayer.upscaledTooltipState = isScaledUp;
	}

	event OnGetEmptyPaperdollTooltip(equipID : int, isLocked : bool) {
		// nothing
	}

	// SELECTION MODE EVENTS

	event OnSelectionModeTargetChosen(targetSlot : int) {
		HideSelectionMode();

		switch (GetItemType(m_selectionModeItem)) {
			case ITEM_Oil: ApplyOil(m_selectionModeItem, targetSlot); break;
			case ITEM_RepairKit: ApplyRepairKit(m_selectionModeItem, targetSlot); break;
		}
	}

	event OnSelectionModeCancelRequested() {
		HideSelectionMode();
	}

	// FEEDBACK BUTTONS
	// For menu modules these are implemented in CR4MenuBase class.

	event OnAppendGFxButton(actionId : int, gamepadNavCode : String, keyboardKeyCode : int, label : String, holdPrefix : bool) {
		if ((label != "inputfeedback_common_open_grid") && (label != "inputfeedback_common_close_grid")) {
			AddFeedbackButton(actionId, gamepadNavCode, keyboardKeyCode, label, holdPrefix);
		}
	}

	event OnRemoveGFxButton(actionId : int) {
		RemoveFeedbackButton(actionId);
	}

	event OnUpdateGFxButtonsList() {
		if (m_shown && (m_inputFeedbackUpdateStatus == IFUS_Default)) {
			m_inputFeedbackUpdateStatus = IFUS_UpdateNextTick;
		}
	}

	event OnWmkInputFeedbackUpdated() {
		if (m_shown && !m_inputFeedbackPanelVisible && (m_inputFeedbackUpdateStatus != IFUS_Disabled)) {
			m_fxSetInputFeedbackPanelVisibility.InvokeSelfOneArg(FlashArgBool(true));
			m_inputFeedbackPanelVisible = true;
		}
	}

	// OTHER EVENTS

	event OnWmkControllerChange(isGamepad : bool, platformType : int) {
		this.log("OnWmkControllerChange: isGamepad = " + isGamepad + " platformType = " + platformType);
	}

	// Probably for this mod the event is sent only when the current selected slot is changed.
	event OnPlaySoundEvent(soundName : string) {
		if (m_shown) {
			theSound.SoundEvent(soundName);
		}
	}

	// PAPERDOLL SLOTS DATA

	// To avoid flickering this only updates the paperdoll items that were changed since last update.
	private function UpdatePaperDollSlots(optional forceUpdateSlot : EEquipmentSlots) {
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();
		var itemsFlashArray   : CScriptedFlashArray;
		var flashObject  : CScriptedFlashObject;
		var item : SItemUniqueId;
		var itemInfo : SWmkPaperDollItemInfo;
		var appliedOilsList : array<W3Effect_Oil>;
		var i : int;

		itemsFlashArray = m_flashValueStorage.CreateTempFlashArray();

		for (i = 0; i < m_paperdollSlots.Size(); i += 1) {
			if (witcherPlayer.GetItemEquippedOnSlot(m_paperdollSlots[i], item)) {
				flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
				m_paperdollInv.SetInventoryFlashObjectForItem(item, flashObject);

				if (thePlayer.inv.IsItemWeapon(item)) {
					appliedOilsList = thePlayer.inv.GetOilsAppliedOnItem(item);
					if (appliedOilsList.Size() > 0) {
						//Kolaris - Oil Charges Display Fix
						//flashObject.SetMemberFlashString("charges", appliedOilsList[0].GetAmmoCurrentCount());
						flashObject.SetMemberFlashString("charges", CeilF(appliedOilsList[0].GetAmmoPercentage() * 100.f));
					}
				}

				itemInfo = GetPaperDollItemInfo(flashObject);

				if ((itemInfo != m_paperdollItemInfo[i]) || (m_paperdollSlots[i] == forceUpdateSlot)) {
					flashObject.SetMemberFlashBool("wmkCanDrag", false);
					flashObject.SetMemberFlashString("wmkSlotLabel", GetPaperDollSlotLabel(item));
					itemsFlashArray.PushBackFlashObject(flashObject);
					m_paperdollItemInfo[i] = itemInfo;
				}
			} else if (m_paperdollItemInfo[i] != m_paperdollInvalidItemInfo) {
				m_fxPaperDollRemoveItem.InvokeSelfOneArg(FlashArgUInt(m_paperdollItemInfo[i].m_id));
				m_paperdollItemInfo[i] = m_paperdollInvalidItemInfo;
			}
		}

		if (itemsFlashArray.GetLength() > 0) {
			m_flashValueStorage.SetFlashArray("inventory.grid.paperdoll.items.update", itemsFlashArray);
		}
	}

	private function GetPaperDollItemInfo(flashObject : CScriptedFlashObject) : SWmkPaperDollItemInfo {
		var info : SWmkPaperDollItemInfo;

		info.m_id = flashObject.GetMemberFlashUInt("id");

		info.m_iconPath = flashObject.GetMemberFlashString("iconPath");
		info.m_itemColor = flashObject.GetMemberFlashString("itemColor");

		info.m_enchanted = flashObject.GetMemberFlashBool("enchanted");
		info.m_socketsCount = flashObject.GetMemberFlashInt("socketsCount");
		info.m_socketsUsedCount = flashObject.GetMemberFlashInt("socketsUsedCount");
		info.m_isOilApplied = flashObject.GetMemberFlashBool("isOilApplied");
		info.m_durability = flashObject.GetMemberFlashNumber("durability");
		info.m_needRepair = flashObject.GetMemberFlashBool("needRepair");

		info.m_quantity = flashObject.GetMemberFlashInt("quantity");
		info.m_charges = flashObject.GetMemberFlashString("charges");

		return info;
	}

	private function GetPaperDollSlotLabel(item : SItemUniqueId) : string {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var durability : int;
		var fontColor : string;

		if (inv.HasItemDurability(item)) {
			durability = RoundMath(inv.GetItemDurability(item) / inv.GetItemMaxDurability(item) * 100);
			if (durability <= theGame.params.ITEM_DAMAGED_DURABILITY) { // 50
				fontColor = "E70000";
			} else {
				fontColor = "B4A68A";
			}

			return "<font color='#" + fontColor + "'>" + durability + " %</font>";
		}

		return "";
	}

	// LAST RECEIVED ITEMS DATA

	private function UpdateNewestItems() {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var itemsFlashArray   : CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();
		var flashObject  : CScriptedFlashObject;
		var itemData : SWmkReceivedItemSaveData;
		var slotLabel : string;
		var currentTimestamp : int;
		var i, count : int;

		count = 0;
		currentTimestamp = 0;

		for (i = 0; i < m_saveData.m_lastReceivedItems.Size(); i += 1) {
			itemData = m_saveData.m_lastReceivedItems[i];

			if (!inv.IsIdValid(itemData.m_item)) {
				continue;
			}

			flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
			m_playerInv.SetInventoryFlashObjectForItem(itemData.m_item, flashObject);
			flashObject.SetMemberFlashBool("wmkCanDrag", false);
			flashObject.SetMemberFlashInt("wmkDataIndex", count);
			flashObject.SetMemberFlashInt("equipped", 0);
			if (m_cfg.QUICK_INVENTORY_SHOW_ELAPSED_TIME_FOR_NEWEST_ITEMS) {
				if (currentTimestamp == 0) {
					currentTimestamp = m_flashModule.GetMemberFlashInt("unixTime");
				}
				slotLabel = GetElapsedTimeAsString(currentTimestamp, itemData.m_timestamp);
			} else {
				slotLabel = "";
			}
			flashObject.SetMemberFlashString("wmkSlotLabel", slotLabel);
			itemsFlashArray.PushBackFlashObject(flashObject);

			count += 1;
			if (count >= MAX_NEWEST_ITEMS) {
				break;
			}
		}

		m_flashValueStorage.SetFlashArray("inventory.newest.items", itemsFlashArray);
	}

	private function GetElapsedTimeAsString(currentTime : int, time : int) : string {
		var days, hours, minutes, seconds : int;
		var result : string;

		if (currentTime < time) {
			return "";
		}

		seconds = currentTime - time;
		days = seconds / 86400;

		if (days > 0) {
			return "+23h:59m";
		}

		seconds = seconds - days * 86400;
		hours = seconds / 3600;
		seconds = seconds - hours * 3600;
		minutes = seconds / 60;
		seconds = seconds - minutes * 60;

		if (hours > 0) {
			result = hours + "h:" + IntToStringTwoChars(minutes) + "m";
		} else if (minutes > 0) {
			result = minutes + "m:" + IntToStringTwoChars(seconds) + "s";
		} else {
			result = seconds + "s";
		}

		return result;
	}

	private function IntToStringTwoChars(value : int) : string {
		if (value < 9) {
			return "0" + IntToString(value);
		} else {
			return IntToString(value);
		}
	}

	// INVENTORY DATA

	private function PopulateTabData(tab : EWmkInventoryTab) {
		var itemsList : array<SItemUniqueId> = GetItemsForTab(tab, ITEM_Unknown, -1);
		var itemsFlashArray : CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();
		var result : CScriptedFlashObject;
		var i : int;

		for (i = 0; i < itemsList.Size(); i += 1) {
			itemsFlashArray.PushBackFlashObject(CreateFlashObjectForInventoryItem(tab, itemsList[i]));
		}

		if ((tab == ITAB_PotionsOilsAndTools) || (tab == ITAB_FoodAndDrinks)) {
			RemoveItemsSaveData(tab, ITEM_Unknown, -1, itemsList);
		}

		result = m_flashValueStorage.CreateTempFlashObject();
		result.SetMemberFlashInt("tabIndex", (int)tab);
		result.SetMemberFlashArray("tabData", itemsFlashArray);
		m_flashValueStorage.SetFlashObject("player.inventory.menu.tabs.data" + (int)tab, result);
	}

	private function UpdateInventoryItem(tab : EWmkInventoryTab, item : SItemUniqueId) {
		m_flashValueStorage.SetFlashObject("inventory.grid.player.itemUpdate", CreateFlashObjectForInventoryItem(tab, item));
	}

	private function UpdateTwoInventoryItems(tab : EWmkInventoryTab, firstItem : SItemUniqueId, secondItem : SItemUniqueId) {
		var itemsList : array<SItemUniqueId>;
		itemsList.PushBack(firstItem);
		itemsList.PushBack(secondItem);
		UpdateMultipleInventoryItems(tab, itemsList);
	}

	private function UpdateMultipleInventoryItems(tab : EWmkInventoryTab, itemsList : array<SItemUniqueId>) {
		var itemsFlashArray : CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();
		var i : int;

		for (i = 0; i < itemsList.Size(); i += 1) {
			itemsFlashArray.PushBackFlashObject(CreateFlashObjectForInventoryItem(tab, itemsList[i]));
		}

		m_flashValueStorage.SetFlashArray("inventory.grid.player.itemsUpdate", itemsFlashArray);
	}

	private function RemoveInventoryItemFromCurrentTab(item : SItemUniqueId, optional keepSelectionIdx : bool) {
		m_fxInventoryRemoveItem.InvokeSelfTwoArgs(FlashArgUInt(ItemToFlashUInt(item)), FlashArgBool(keepSelectionIdx));
	}

	private function CreateFlashObjectForInventoryItem(tab : EWmkInventoryTab, item : SItemUniqueId) : CScriptedFlashObject {
		var flashObject : CScriptedFlashObject;
		var gridPosition : int = -1;
		var canDrag : bool;

		flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.ItemDataStub");
		m_playerInv.SetInventoryFlashObjectForItem(item, flashObject);

		flashObject.SetMemberFlashInt("tabIndex", (int)tab);
		flashObject.SetMemberFlashInt("sectionId", Max(0, GetItemGridSection(item)));
		SetItemSortWeights(item, flashObject);

		if ((tab == ITAB_PotionsOilsAndTools) || (tab == ITAB_FoodAndDrinks)) {
			gridPosition = GetItemGridPosition(item);
			if ((m_cfg.QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS == ISEI_ShowDimmed) && GetWitcherPlayer().IsItemEquipped(item)) {
				flashObject.SetMemberFlashBool("isReaded", true);
			}
			canDrag = true;
		}

		flashObject.SetMemberFlashInt("gridPosition", gridPosition);
		flashObject.SetMemberFlashBool("wmkCanDrag", canDrag);

		return flashObject;
	}

	private function GetItemsForTab(tab : EWmkInventoryTab, itemType : EWmkItemType, gridSection : int) : array<SItemUniqueId> {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var rawItems, itemsList : array<SItemUniqueId>;
		var itemTagsList : array<name>;
		var i : int;

		inv.GetAllItems(rawItems);
		for (i = 0; i < rawItems.Size(); i += 1) {
			inv.GetItemTags(rawItems[i], itemTagsList);
			if (itemTagsList.Contains(theGame.params.TAG_DONT_SHOW) || itemTagsList.Contains(theGame.params.TAG_DONT_SHOW_ONLY_IN_PLAYERS)) {
				continue;
			}

			if (GetItemInventoryTab(rawItems[i]) != tab) {
				continue;
			}

			if ((itemType != ITEM_Unknown) && (itemType != GetItemType(rawItems[i]))) {
				continue;
			}

			if ((gridSection >= 0) && (GetItemGridSection(rawItems[i]) != gridSection)) {
				continue;
			}

			if (m_cfg.QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS == ISEI_Hide) {
				if ((tab == ITAB_PotionsOilsAndTools) || (tab == ITAB_FoodAndDrinks)) {
					if (GetWitcherPlayer().IsItemEquipped(rawItems[i])) {
						continue;
					}
				}
			}

			itemsList.PushBack(rawItems[i]);
		}

		return itemsList;
	}

	private function GetItemInventoryTab(item : SItemUniqueId) : EWmkInventoryTab {
		var itemName : name;

		switch (GetItemType(item)) {
			case ITEM_Oil:
			case ITEM_RepairKit:
				return ITAB_PotionsOilsAndTools;
			case ITEM_Potion:
				itemName = thePlayer.inv.GetItemName(item);
				if ((itemName == 'Clearing Potion') || (itemName == 'Wolf Hour')) {
					return ITAB_Invalid;
				}
			case ITEM_Decoction:
				return ITAB_PotionsOilsAndTools;
			case ITEM_FoodOrDrink:
				return ITAB_FoodAndDrinks;
			case ITEM_Book:
				return ITAB_Books;
		}

		return ITAB_Invalid;
	}

	private function GetItemGridSection(item : SItemUniqueId) : int {
		var buffs : array<SEffectInfo>;
		var tags : array<name>;
		var itemName : name;

		switch (GetItemType(item)) {
			case ITEM_Oil: return 2;
			case ITEM_RepairKit: return 3;
			case ITEM_Potion: return 0;
			case ITEM_Decoction: return 1;
			case ITEM_FoodOrDrink:
				thePlayer.inv.GetItemBuffs(item, buffs);
				if (buffs.Size() > 0) {
					switch (buffs[0].effectAbilityName) {
						case 'WellFedEffect_Level3':
							return 2;
						case 'WellFedEffect_Level2':
							return 1;
					}
				}
				return 0;
			case ITEM_Book: return 0;
		}

		return -1;
	}

	private function SetItemTooltipData(item : SItemUniqueId) {
		m_tooltipDataProvider.setCurrentInventory(thePlayer.GetInventory());
		m_flashValueStorage.SetFlashObject("context.tooltip.data", m_tooltipDataProvider.GetTooltipData(item, false, true));
	}

	// SORTING

	// The ActionScript function used to compare two items uses two sorting weights,
	// named wmkSortWeight1 and wmkSortWeight2. From ActionScript's point of view both weights can
	// be any basic type, but a weight must have same type for all items. Currently this function sets the first
	// weight as an integer and the second one as a string. If two items have same weights then they are
	// compared by their inventory ID, with newer items being listed first. Note that the items are actually
	// compared first by their section, so potions < decoctions < oils < tools, no matter their sorting
	// weights. Something like this:
	//
	// function compare(item1, item2) : int {
	//     if (item1.sectionId != item2.sectionId) return item1.sectionId - item2.sectionId;
	//     if (item1.wmkSortWeight1 < item2.wmkSortWeight1) return -1; // item1 < item2
	//     if (item1.wmkSortWeight1 > item2.wmkSortWeight1) return +1; // item1 > item2
	//     if (item1.wmkSortWeight2 < item2.wmkSortWeight2) return -1; // item1 < item2
	//     if (item1.wmkSortWeight2 > item2.wmkSortWeight2) return +1; // item1 > item2
	//     return item2.id - item1.id;
	// }
	private function SetItemSortWeights(item : SItemUniqueId, flashObject : CScriptedFlashObject) {
		var itemType : EWmkItemType = GetItemType(item);
		var sortOption : EWmkInventoryItemsSortOrder = IISO_Unspecified;
		var sortWeight1 : int = 0;
		var sortWeight2 : string = "";

		if (itemType == ITEM_Potion) {
			sortOption = m_cfg.QUICK_INVENTORY_POTIONS_SORT_ORDER;
		} else if (itemType == ITEM_Oil) {
			sortOption = m_cfg.QUICK_INVENTORY_OILS_SORT_ORDER;
		}

		if (sortOption != IISO_Unspecified) {
			if ((sortOption == IISO_ByQualityAndName) || (sortOption == IISO_ByQualityAndBaseName)) {
				sortWeight1 = -1 * thePlayer.inv.GetItemQuality(item);
			}

			sortWeight2 = GetItemLocalizedName(item, (sortOption == IISO_ByBaseName) || (sortOption == IISO_ByQualityAndBaseName));
		} else if ((itemType == ITEM_Decoction) || (itemType == ITEM_FoodOrDrink)) {
			sortWeight2 = GetItemLocalizedName(item, false);
		} else if (itemType == ITEM_Book) {
			if (flashObject.GetMemberFlashBool("isNew")) {
				sortWeight1 -= 2;
			}

			if (!thePlayer.inv.IsBookRead(item)) {
				sortWeight1 -= 1;
			}

			if (m_cfg.QUICK_INVENTORY_SORT_BOOKS_BY_NAME) {
				sortWeight2 = GetItemLocalizedName(item, false);
			}
		} else if (itemType == ITEM_RepairKit) {
			if (thePlayer.inv.ItemHasTag(item, 'WeaponReapairKit')) { // weapon tools first
				sortWeight1 = -1;
			}
			sortWeight2 = thePlayer.inv.GetItemName(item);
		}

		flashObject.SetMemberFlashInt("wmkSortWeight1", sortWeight1);
		flashObject.SetMemberFlashString("wmkSortWeight2", sortWeight2);
	}

	private function GetItemLocalizedName(item : SItemUniqueId, optional returnBaseName : bool) : string {
		var left, right, locKeyName : string;

		locKeyName = thePlayer.inv.GetItemLocNameByID(item);

		/*if (StrLen(locKeyName)) {
			if (returnBaseName && StrSplitLast(locKeyName, "_", left, right)) {
				if ((right == "2") || (right == "3")) {
					return GetLocStringByKey(left + "_" + "1");
				}
			}

			return GetLocStringByKey(locKeyName);
		}*/

		return locKeyName; //"";
	}

	// ITEMS SAVE DATA

	private function GetItemGridPosition(item : SItemUniqueId) : int {
		var i : int;

		for (i = 0; i < m_saveData.m_itemsData.Size(); i += 1) {
			if (m_saveData.m_itemsData[i].m_item == item) {
				return m_saveData.m_itemsData[i].m_gridPosition;
			}
		}

		return -1;
	}

	private function SaveItemGridPosition(item : SItemUniqueId, gridPosition : int) {
		var itemData : SWmkInventoryItemSaveData;
		var i : int;

		for (i = 0; i < m_saveData.m_itemsData.Size(); i += 1) {
			if (m_saveData.m_itemsData[i].m_item == item) {
				m_saveData.m_itemsData[i].m_gridPosition = gridPosition;
				return;
			}
		}

		itemData.m_item = item;
		itemData.m_tab = GetItemInventoryTab(item);
		itemData.m_gridSection = GetItemGridSection(item);
		itemData.m_type = GetItemType(item);
		itemData.m_gridPosition = gridPosition;
		m_saveData.m_itemsData.PushBack(itemData);
	}

	private function RemoveItemsSaveData(tab : EWmkInventoryTab, itemType : EWmkItemType, gridSection : int, optional keepList : array<SItemUniqueId>) {
		var i : int;

		for (i = m_saveData.m_itemsData.Size() - 1; i >= 0; i -= 1) {
			if (m_saveData.m_itemsData[i].m_tab == tab) {
				if ((itemType == ITEM_Unknown) || (m_saveData.m_itemsData[i].m_type == itemType)) {
					if ((gridSection == -1) || (gridSection == m_saveData.m_itemsData[i].m_gridSection)) {
						if (!keepList.Contains(m_saveData.m_itemsData[i].m_item)) {
							m_saveData.m_itemsData.Erase(i);
						}
					}
				}
			}
		}
	}

	private function SetCurrentSelectedInventoryItem(item : SItemUniqueId) {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var showSortButton : bool;
		var defaultActionLabel : string = "";

		if ((m_currentSelectedItem == item) && (item == GetInvalidUniqueId())) {
			return;
		}

		m_currentSelectedItem = item;

		switch (GetItemType(item)) {
			case ITEM_Oil: defaultActionLabel = "panel_button_inventory_upgrade"; break;
			case ITEM_RepairKit: defaultActionLabel = "panel_button_hud_interaction_useitem"; break;
			case ITEM_Potion:
			case ITEM_Decoction:
			case ITEM_FoodOrDrink:
				if (!inv.IsItemSingletonItem(item) || (inv.SingletonItemGetAmmo(item) > 0)) {
					defaultActionLabel = "panel_button_inventory_consume";
				}
				break;
			case ITEM_Book: defaultActionLabel = "panel_button_inventory_read"; break;
		}

		if (defaultActionLabel != "") {
			AddFeedbackButton(DEFAULT_ITEM_ACTION_BUTTON_ID, "enter-gamepad_A", IK_E, defaultActionLabel, false);
		} else {
			RemoveFeedbackButton(DEFAULT_ITEM_ACTION_BUTTON_ID);
		}

		if ((m_currentTab == ITAB_PotionsOilsAndTools) || (m_currentTab == ITAB_FoodAndDrinks)) {
			showSortButton = thePlayer.inv.IsIdValid(item);
		}

		if (showSortButton) {
			AddFeedbackButton(SORT_ITEMS_BUTTON_ID, "gamepad_R_Hold", IK_Q, "panel_button_common_quick_sort_items", false);
		} else {
			RemoveFeedbackButton(SORT_ITEMS_BUTTON_ID);
		}

		if (m_inputFeedbackUpdateStatus == IFUS_Default) {
			m_inputFeedbackUpdateStatus = IFUS_UpdateNextTick;
		}
	}

	private function ResetCurrentSelectedInventoryItem() {
		SetCurrentSelectedInventoryItem(GetInvalidUniqueId());
	}

	// SELECTION MODE

	private function ShowSelectionMode(sourceItem : SItemUniqueId, targetSlots : array<EEquipmentSlots>) {
		var flashArray : CScriptedFlashArray;
		var flashObject : CScriptedFlashObject;
		var i : int;

		if (m_selectionModeActive || (targetSlots.Size() == 0) || !m_playerInv.GetInventoryComponent().IsIdValid(sourceItem)) {
			return;
		}

		flashArray = m_flashValueStorage.CreateTempFlashArray();

		for (i = 0; i < targetSlots.Size(); i += 1) {
			flashArray.PushBackFlashInt(targetSlots[i]);
		}

		flashObject = m_flashValueStorage.CreateTempFlashObject();
		flashObject.SetMemberFlashInt("sourceItem", ItemToFlashUInt(sourceItem));
		flashObject.SetMemberFlashBool("isDyeApplyingMode", false);
		flashObject.SetMemberFlashArray("validSlots", flashArray);

		theSound.SoundEvent("gui_global_panel_open");

		m_selectionModeItem = sourceItem;
		m_selectionModeActive = true;

		m_flashValueStorage.SetFlashObject("inventory.selection.mode.show", flashObject);
	}

	private function HideSelectionMode() {
		if (m_selectionModeActive) {
			m_selectionModeActive = false;
			m_fxHideSelectionMode.InvokeSelf();
		}
	}

	private function ShowOilSelectionMode(item : SItemUniqueId) {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();
		var targetSlots : array<EEquipmentSlots>;
		var itemOnSlot : SItemUniqueId;

		if (inv.ItemHasTag(item, 'SteelOil') && witcherPlayer.GetItemEquippedOnSlot(EES_SteelSword, itemOnSlot)
				&& inv.IsItemSteelSwordUsableByPlayer(itemOnSlot)) {
			targetSlots.PushBack(EES_SteelSword);
			targetSlots.PushBack(EES_SilverSword);
		}

		if (inv.ItemHasTag(item, 'SilverOil') && witcherPlayer.GetItemEquippedOnSlot(EES_SilverSword, itemOnSlot)
				&& inv.IsItemSilverSwordUsableByPlayer(itemOnSlot)) {
			targetSlots.PushBack(EES_SteelSword);
			targetSlots.PushBack(EES_SilverSword);
		}

		if (targetSlots.Size() == 0) {
			theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("mqs_message_no_compatible_swords"));
			theSound.SoundEvent("gui_global_denied");
		} else {
			ShowSelectionMode(item, targetSlots);
		}
	}

	private function ShowRepairKitSelectionMode(item : SItemUniqueId) {
		var inv : CInventoryComponent = thePlayer.GetInventory();
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();
		var allSlots, targetSlots : array<EEquipmentSlots>;
		var itemOnSlot : SItemUniqueId;
		var i : int;

		if (inv.ItemHasTag(item, 'WeaponReapairKit')) {
			allSlots.PushBack(EES_SteelSword);
			allSlots.PushBack(EES_SilverSword);
		} else if (inv.ItemHasTag(item, 'ArmorReapairKit')) {
			allSlots.PushBack(EES_Armor);
			allSlots.PushBack(EES_Gloves);
			allSlots.PushBack(EES_Pants);
			allSlots.PushBack(EES_Boots);
		}

		for (i = 0; i < allSlots.Size(); i += 1) {
			if (witcherPlayer.GetItemEquippedOnSlot(allSlots[i], itemOnSlot)) {
				if (witcherPlayer.IsItemRepairAble(itemOnSlot)) {
					targetSlots.PushBack(allSlots[i]);
				}
			}
		}

		if (targetSlots.Size() == 0) {
			theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("panel_inventory_nothing_to_repair"));
			theSound.SoundEvent("gui_global_denied");
		} else {
			ShowSelectionMode(item, targetSlots);
		}
	}

	// FEEDBACK BUTTONS

	private function AddFeedbackButton(actionId : int, gamepadNavCode : String, keyboardKeyCode : int, label : String, holdPrefix : bool) {
		var keyBinding : SKeyBinding;

		RemoveFeedbackButton(actionId);

		keyBinding.ActionID = actionId;
		keyBinding.Gamepad_NavCode = gamepadNavCode;
		keyBinding.Keyboard_KeyCode = keyboardKeyCode;

		if (holdPrefix) {
			keyBinding.LocalizationKey = GetHoldLabel() + " " + GetLocStringByKeyExt(label);
			keyBinding.IsLocalized = true;
			keyBinding.IsHold = true;
		} else {
			keyBinding.LocalizationKey = label;
		}

		m_inputFeedbackButtons.PushBack(keyBinding);
	}

	private function RemoveFeedbackButton(actionId : int) : bool {
		var i : int;

		for (i = 0; i < m_inputFeedbackButtons.Size(); i += 1) {
			if (m_inputFeedbackButtons[i].ActionID == actionId) {
				m_inputFeedbackButtons.Erase(i);
				return true;
			}
		}

		return false;
	}

	private function UpdateFeedbackButtons() {
		var gfxDataList	: CScriptedFlashArray;
		var flashObject : CScriptedFlashObject;
		var keyBinding : SKeyBinding;
		var i : int;

		gfxDataList = m_flashValueStorage.CreateTempFlashArray();

		for (i = 0; i < m_inputFeedbackButtons.Size(); i += 1) {
			keyBinding = m_inputFeedbackButtons[i];

			flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.data.KeyBindingData");

			flashObject.SetMemberFlashString("gamepad_navEquivalent", keyBinding.Gamepad_NavCode);
			flashObject.SetMemberFlashInt("keyboard_keyCode", keyBinding.Keyboard_KeyCode);
			flashObject.SetMemberFlashBool("hasHoldPrefix", keyBinding.IsHold);
			if (keyBinding.IsLocalized) {
				flashObject.SetMemberFlashString("label", keyBinding.LocalizationKey );
			} else {
				flashObject.SetMemberFlashString("label", GetLocStringByKeyExt(keyBinding.LocalizationKey));
			}
			flashObject.SetMemberFlashInt("level", 0);

			gfxDataList.PushBackFlashObject(flashObject);
		}

		m_flashValueStorage.SetFlashArray("common.input.feedback.setup", gfxDataList);
	}

	private function AddDefaultFeedbackButtons() {
		var backNavCode, backToGameNavCode : string;
		var backKeyCode, backToGameKeyCode : int;

		if (m_cfg.QUICK_INVENTORY_RIGHT_BUMPER_ACTION == IACT_Back) {
			backNavCode = "gamepad_R1";
		} else if (m_cfg.QUICK_INVENTORY_RIGHT_TRIGGER_ACTION == IACT_Back) {
			backNavCode = "gamepad_R2";
		}

		if (m_cfg.QUICK_INVENTORY_RIGHT_BUMPER_ACTION == IACT_BackToGame) {
			backToGameNavCode = "gamepad_R1";
		} else if (m_cfg.QUICK_INVENTORY_RIGHT_TRIGGER_ACTION == IACT_BackToGame) {
			backToGameNavCode = "gamepad_R2";
		}

		if (m_cfg.QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION == IACT_Back) {
			backKeyCode = IK_RightMouse;
		} else if (m_cfg.QUICK_INVENTORY_ESC_ACTION == IACT_Back) {
			backKeyCode = IK_Escape;
		}

		if (m_cfg.QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION == IACT_BackToGame) {
			backToGameKeyCode = IK_RightMouse;
		} else if (m_cfg.QUICK_INVENTORY_ESC_ACTION == IACT_BackToGame) {
			backToGameKeyCode = IK_Escape;
		}

		if ((backNavCode != "") || (backKeyCode != IK_None)) {
			AddFeedbackButton(BACK_BUTTON_ID, backNavCode, backKeyCode, "panel_button_common_exit", false);
		} else {
			RemoveFeedbackButton(BACK_BUTTON_ID);
		}

		if ((backToGameNavCode != "") || (backToGameKeyCode != IK_None)) {
			AddFeedbackButton(BACK_TO_GAME_BUTTON_ID, backToGameNavCode, backToGameKeyCode, "panel_button_common_back_to_game", false);
		} else {
			RemoveFeedbackButton(BACK_TO_GAME_BUTTON_ID);
		}

		AddFeedbackButton(RADIAL_MENU_BUTTON_ID, "gamepad_L1", IK_Tab, "ControlLayout_RadialMenu", false);
	}

	// ACTIONS

	private function SortInventoryItems() {
		var selectedItemType : EWmkItemType;
		var gridSection : int;

		if ((m_currentTab == ITAB_PotionsOilsAndTools) || (m_currentTab == ITAB_FoodAndDrinks)) {
			selectedItemType = GetItemType(m_currentSelectedItem);
			if (selectedItemType != ITEM_Unknown) {
				gridSection = GetItemGridSection(m_currentSelectedItem);
				RemoveItemsSaveData(m_currentTab, selectedItemType, gridSection);
				UpdateMultipleInventoryItems(m_currentTab, GetItemsForTab(m_currentTab, selectedItemType,
						gridSection));
			}
		}
	}

	private function ApplyOil(item : SItemUniqueId, targetSlot : EEquipmentSlots) {
		var equippedItem : SItemUniqueId;
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();

		if (thePlayer.IsInCombat() && !m_cfg.CAN_APPLY_OILS_WHILE_IN_COMBAT) {
			theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			theSound.SoundEvent("gui_global_denied");
			return;
		}

		if (witcherPlayer.GetItemEquippedOnSlot(targetSlot, equippedItem)) {
			theSound.SoundEvent('gui_preparation_potion');
			
			//W3EE MQS merge Beginn
			if (!(witcherPlayer.IsMeditating() || !Options().GetUseOilAnimation()))
				HideQuickInventory(QIHA_Default);
			//W3EE MQS merge End

			witcherPlayer.ApplyOil(item, equippedItem);
			UpdateInventoryItem(m_currentTab, item); // this actually is not required because the oil item doesn't change...
			UpdatePaperDollSlots(targetSlot);
		}
	}

	private function ApplyRepairKit(item : SItemUniqueId, targetSlot : EEquipmentSlots) {
		var equippedItem : SItemUniqueId;
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();

		if (thePlayer.IsInCombat() && !m_cfg.CAN_REPAIR_ITEMS_WHILE_IN_COMBAT) {
			theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			theSound.SoundEvent("gui_global_denied");
			return;
		}

		if (witcherPlayer.GetItemEquippedOnSlot(targetSlot, equippedItem)) {
			if( thePlayer.inv.ItemHasTag(item, 'ArmorReapairKit_Weak') && (thePlayer.inv.ItemHasTag(equippedItem, 'MediumArmor') || thePlayer.inv.ItemHasTag(equippedItem, 'HeavyArmor')) ) {
				theSound.SoundEvent("gui_global_denied");
				return;
			} else if( thePlayer.inv.ItemHasTag(item, 'ArmorReapairKit_Medium') && (thePlayer.inv.ItemHasTag(equippedItem, 'LightArmor') || thePlayer.inv.ItemHasTag(equippedItem, 'HeavyArmor')) ) {
				theSound.SoundEvent("gui_global_denied");
				return;
			} else if( thePlayer.inv.ItemHasTag(item, 'ArmorReapairKit_Strong') && (thePlayer.inv.ItemHasTag(equippedItem, 'LightArmor') || thePlayer.inv.ItemHasTag(equippedItem, 'MediumArmor')) ) {
				theSound.SoundEvent("gui_global_denied");
				return;
			}
			theSound.SoundEvent("gui_inventory_repair");
			witcherPlayer.RepairItem(item, equippedItem);
			if (thePlayer.inv.IsIdValid(item)) {
				UpdateInventoryItem(m_currentTab, item);
			} else {
				RemoveInventoryItemFromCurrentTab(item);
			}
			UpdatePaperDollSlots(targetSlot);
		}
	}

	private function DrinkPotion(item : SItemUniqueId) {

		//W3EE Nitpicker+++
		var notificationText : string;
		var language : string;
		var audioLanguage : string;

		if (GetWitcherPlayer().ToxicityLowEnoughToDrinkPotion(EES_Potion1,item))	
			{
				// W3EE - Begin
				if( !Options().GetUseDrinkAnimation() )
				{
					GetWitcherPlayer().DrinkPreparedPotion(EES_Potion1, item);
					//Kolaris - Quick Inventory Consumable Fix
					if (thePlayer.inv.IsIdValid(item))
						UpdateInventoryItem(m_currentTab, item);
					else 
						RemoveInventoryItemFromCurrentTab(item);
				}
				else
				{
					HideQuickInventory(QIHA_Default);
					GetWitcherPlayer().GetAnimManager().PerformAnimation(EES_Potion1, item);
				}
				// W3EE - End
				
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
				theGame.GetGuiManager().ShowNotification(notificationText);
			}
			//W3EE Nitpicker---
	}

	private function ConsumeItem(item : SItemUniqueId) {
		
		//W3EE Nitpicker+++
		if( GetWitcherPlayer().inv.ItemHasTag(item, 'Consumable') )
		{
			GetWitcherPlayer().ConsumeItem(item);
			//Kolaris - Quick Inventory Consumable Fix
			if (thePlayer.inv.IsIdValid(item))
				UpdateInventoryItem(m_currentTab, item);
			else 
				RemoveInventoryItemFromCurrentTab(item);
		}
		else
		if( GetWitcherPlayer().inv.ItemHasTag(item, 'Edibles') && GetWitcherPlayer().inv.ItemHasTag(item, 'Drinks') )
		{
			if( !Options().GetUseDrinkAnimation() )
			{
				GetWitcherPlayer().ConsumeItem(item);
				//Kolaris - Quick Inventory Consumable Fix
				if (thePlayer.inv.IsIdValid(item))
					UpdateInventoryItem(m_currentTab, item);
				else 
					RemoveInventoryItemFromCurrentTab(item);
			}
			else 
			{
				HideQuickInventory(QIHA_Default);
				GetWitcherPlayer().GetAnimManager().PerformAnimation(EES_InvalidSlot, item);
			}
		}
		else
		{
			if( !Options().GetUseEatAnimation() )
			{
				GetWitcherPlayer().ConsumeItem(item);
				//Kolaris - Quick Inventory Consumable Fix
				if (thePlayer.inv.IsIdValid(item))
					UpdateInventoryItem(m_currentTab, item);
				else 
					RemoveInventoryItemFromCurrentTab(item);
			}
			else
			{
				HideQuickInventory(QIHA_Default);
				GetWitcherPlayer().GetAnimManager().PerformAnimation(EES_InvalidSlot, item);
			}
		}
		//W3EE Nitpicker---
	}

	private function ReadBook(item : SItemUniqueId) {
		var popupData : WmkBookPopupFeedback;
		popupData = new WmkBookPopupFeedback in this;

		popupData.Initialize(this, item);

		theSound.SoundEvent('gui_inventory_read');
		theGame.RequestMenu('PopupMenu', popupData);
	}

	// This is called from WmkBookPopupFeedback.UpdateAfterBookRead function.
	public function UpdateAfterBookRead(item : SItemUniqueId) {
		UpdateInventoryItem(m_currentTab, item);
	}

	// UTILS

	private function GetItemType(item : SItemUniqueId) : EWmkItemType {
		var inv : CInventoryComponent = thePlayer.GetInventory();

		if (inv.IsIdValid(item)) {
			if (inv.IsItemOil(item)) {
				return ITEM_Oil;
			} else if (inv.IsItemTool(item)) {
				if (inv.ItemHasTag(item, 'WeaponReapairKit') || inv.ItemHasTag(item, 'ArmorReapairKit')) {
					return ITEM_RepairKit;
				}
			} else if (inv.IsItemPotion(item) && !inv.IsItemFood(item)) {
				if (inv.ItemHasTag(item, 'Decoction')) {
					return ITEM_Decoction;
				} else {
					return ITEM_Potion;
				}
			} else if (inv.IsItemFood(item) && !inv.IsItemPotion(item)) {
				return ITEM_FoodOrDrink;
			} else if (inv.IsItemReadable(item)) {
				return ITEM_Book;
			}
		}

		return ITEM_Unknown;
	}

	// DEBUG

	event OnWmkDebug(message : string) {
		this.log("OnWmkDebug: " + message);
	}

	private function log(message : string) {
		if (true) {
			LogChannel('WMK', message);
		}
	}
}

class CR4HudModuleWatermark extends WmkQuickInventory { }
