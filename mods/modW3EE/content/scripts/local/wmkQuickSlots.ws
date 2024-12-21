// More Quick Slots mod for Witcher 3, patch 1.31. Written by Wolfmark (wolfmark@gmx.com).
class WmkQuickSlots {
	// Settings.
	private var m_cfg : WmkQuickSlotsConfig;
	private var m_quickInventory : WmkQuickInventory;

	// The Item Info HUD module.
	private var m_moduleItemInfo : CR4HudModuleItemInfo;
	// The Radial Menu HUD module.
	private var m_radialMenu : CR4HudModuleRadialMenu;
	// This is set only while the inventory menu is opened, otherwise is null.
	private var m_inventoryMenu : CR4InventoryMenu;

	// Set the visibility on HUD for the new potion slots.
	private var m_fxShowNewSlotsOnHud : CScriptedFlashFunction;
	// Force the display of keyboard quick slots even if a gamepad is used.
	private var m_fxForceKbSlots : CScriptedFlashFunction;
	// Marks a keyboard quick slot as being the currently selected one.
	private var m_fxSelectKbSlot : CScriptedFlashFunction;

	// Can be used to block some input events while the radial menu is opened.
	private var m_fxSetRadialInputHandled : CScriptedFlashFunction;
	// Adds a new feedback button inside radial menu.
	private var m_fxAddRadialFeedbackButton : CScriptedFlashFunction;
	// Removes a feedback button from radial menu.
	private var m_fxRemoveRadialFeedbackButton : CScriptedFlashFunction;
	// Used to set the mouse position over a slot when the radial menu is opened.
	private var m_fxSetRadialMousePosition : CScriptedFlashFunction;
	// Used to change inside radial menu the navigation code for switch feedback button.
	private var m_fxSetSwitchBtnNavCode : CScriptedFlashFunction;
	// Sets the minimum required magnitute for the stick used for selecting the radial slot.
	private var m_fxSetMinStickMagnitude : CScriptedFlashFunction;
	// Shows / hides the radial menu flash module.
	private var m_fxShowRadialModule : CScriptedFlashFunction;

	// Updates the entries in hudModuleStateArray variable from Hud ActionScript class.
	private var m_fxUpdateModuleStateArray : CScriptedFlashFunction;
	// The list with pins that must not be displayed on minimap.
	private var m_minimapPinsToIgnore : CScriptedFlashArray;

	// The list with the actions for the the new potion quick slots.
	private var m_actionNames : array<name>;

	// True if the ingame menu is opened.
	private var m_ingameMenuOpened : bool; default m_ingameMenuOpened = false;
	// True if at least a mod's setting was changed while the ingame menu was opened.
	private var m_configChanged : bool; default m_configChanged = false;
	// True if the UpdateScale function was called at least once while the ingame menu was opened.
	private var m_updateScaleCalled : bool; default m_updateScaleCalled = false;

	// True if the "Alternative Quick Access Menu control mode" option is enabled in Control Settings menu.
	private var m_radialAlternativeInputMode : bool;

	// The base X offset on HUD for the new potion quick slots (relative to the default slots).
	private var m_newPotionSlotBaseXOffset : float;
	private var m_newPotionSlotBaseXOffsetValid : bool; default m_newPotionSlotBaseXOffsetValid = false;
	// True if the position for mcMaximViewAnchor sprite from Buffs Module was changed.
	private var m_updatedBuffMaximViewAnchorYPos : bool; default m_updatedBuffMaximViewAnchorYPos = false;
	private var m_defaultBuffMaximViewAnchorYPos : float;

	// This is 0 for the first consumables set or 1 for the alternate consumables set.
	private var m_activeSetIdx : int; default m_activeSetIdx = 0;

	// True if the user is viewing player's stats in inventory menu.
	private var m_playerStatsShown : bool; default m_playerStatsShown = false;
	// True if the shift key must be ignored when used inside inventory menu.
	private var m_ignoreShiftKey : bool; default m_ignoreShiftKey = false;
	// Milliseconds. If positive the current active set cannot be changed with the mouse wheel.
	private var m_mouseWheelToggleCooldown : float; default m_mouseWheelToggleCooldown = 0.0;

	// These are used to avoid calling a flash function when not required.
	private var m_lastRadialSwitchBtnNavCode : string; default m_lastRadialSwitchBtnNavCode = "";
	private var m_lastRadialMinStickMagnitude : float; default m_lastRadialMinStickMagnitude = 0.5;
	private var m_lastForceKbSlots : bool; default m_lastForceKbSlots = false;

	// True if the mouse position inside radial menu can be updated.
	private var m_canSetRadialMousePosition : bool; default m_canSetRadialMousePosition = false;
	// The index of last selected radial slot. Valid values are between 1 and 11, 0 meaning "unknown".
	private var m_lastSelectedRadialSlot : int; default m_lastSelectedRadialSlot = 0;
	// The currently selected quick slot. Used if all slots are visible when using the gamepad.
	private var m_currentSelectedKbSlot : int; default m_currentSelectedKbSlot = 1;

	// This is used only to know when ticking is restarted after a pause. The ticking is stopped if the new
	// quick slots are disabled or if the player is Ciri.
	private var m_newSlotsTickingEnabled : bool; default m_newSlotsTickingEnabled = true;
	// True if new potion slots are visible on HUD, false otherwise.
	private var m_currentShowOnHud : bool; default m_currentShowOnHud = false;
	// True to force an update during next tick for all standard quick slots.
	// When the radial menu is opened or closed the item IDs saved by Item Info module are reset to an invalid
	// value (see CR4HudModuleRadialMenu.ResetItemsModule and CR4HudModuleItemInfo.ResetItems). This doesn't work well
	// if the player has an item equipped in the pocket slot when the radial was opened, but activates an empty slot,
	// because the Item Info module will think that nothing changed and won't update the flash module.
	public var m_forceUpdateAllStdSlots : bool; default m_forceUpdateAllStdSlots = false;
	// True to force an update during next tick for all new potion quick slots. The new quick slots must be
	// updated at least once to set their background image.
	private var m_forceUpdateAllNewSlots : bool; default m_forceUpdateAllNewSlots = true;
	// True to force a tick for the Item Info module.
	private var m_forceItemInfoModuleTick : bool; default m_forceItemInfoModuleTick = false;

	// Invalid item ID.
	private var m_invalidItem : SItemUniqueId;

	// Data about the equipped items in the new potion quick slots.
	private var m_itemsInfo : array<SWmkHudItemInfo>;
	// Timers used when reusing the standard keys for using the items from new potion quick slots.
	private var m_drinkPotionTimers : array<float>;
	// Used for the new potion quick slots when there's no item equipped.
	private var m_invalidItemInfo : SWmkHudItemInfo;

	// Used to know when the player has changed.
	private var m_playerIsCiri : bool;
	// True if the player has the Dumplings runeword active. Whatever that means, because I have no idea...
	private var m_dumplingsRunewordActive : bool; default m_dumplingsRunewordActive = false;

	// Constants.
	private const var FIRST_POTION_SLOT : EEquipmentSlots; default FIRST_POTION_SLOT = EES_Potion1;
	private const var FIRST_NEW_POTION_SLOT : EEquipmentSlots; default FIRST_NEW_POTION_SLOT = EES_Potion5;
	private const var FIRST_RESERVED_POTION_SLOT : EEquipmentSlots; default FIRST_RESERVED_POTION_SLOT = EES_ReservedPotion1;
	private const var FIRST_PETARD_SLOT : EEquipmentSlots; default FIRST_PETARD_SLOT = EES_Petard1;
	private const var FIRST_RESERVED_PETARD_SLOT : EEquipmentSlots; default FIRST_RESERVED_PETARD_SLOT = EES_ReservedPetard1;

	private const var MOUSE_WHEEL_TOGGLE_COOLDOWN : float; default MOUSE_WHEEL_TOGGLE_COOLDOWN = 200; // milliseconds
	private const var KEY_CODE_MOUSE_SCROLL : int; default KEY_CODE_MOUSE_SCROLL = 1002;
	private const var INPUT_VALUE_KEY_UP : string; default INPUT_VALUE_KEY_UP = "keyUp";
	private const var INPUT_VALUE_KEY_DOWN : string; default INPUT_VALUE_KEY_DOWN = "keyDown";
	private const var DPAD_UP : string; default DPAD_UP = "dpad_up";
	private const var DPAD_RIGHT : string; default DPAD_RIGHT = "dpad_right";
	private const var DPAD_DOWN : string; default DPAD_DOWN = "dpad_down";
	private const var DPAD_LEFT : string; default DPAD_LEFT = "dpad_left";
	private const var GAMEPAD_LSTICK_TAB : string; default GAMEPAD_LSTICK_TAB = "gamepad_L_Tab";
	private const var GAMEPAD_RSTICK_TAB : string; default GAMEPAD_RSTICK_TAB = "gamepad_R_Tab";
	private const var GAMEPAD_L2 : string; default GAMEPAD_L2 = "gamepad_L2";
	private const var GAMEPAD_R1 : string; default GAMEPAD_R1 = "gamepad_R1";
	private const var GAMEPAD_Y : string; default GAMEPAD_Y = "gamepad_Y";
	private const var INVENTORY_TOGGLE_SET_FEEDBACK_BUTTON_ID : int; default INVENTORY_TOGGLE_SET_FEEDBACK_BUTTON_ID = -2048;
	private const var RADIAL_TOGGLE_SET_FEEDBACK_BUTTON_ID : int; default RADIAL_TOGGLE_SET_FEEDBACK_BUTTON_ID = 8;
	private const var RADIAL_USE_POTION_SLOT_FEEDBACK_BUTTON_ID : int; default RADIAL_USE_POTION_SLOT_FEEDBACK_BUTTON_ID = 9;
	private const var RADIAL_QUICK_INVENTORY_FEEDBACK_BUTTON_ID : int; default RADIAL_QUICK_INVENTORY_FEEDBACK_BUTTON_ID = 10;

	// Initialization.
	// Called from WmkQuickInventory::OnConfigUI after the instance is created.
	// All other HUD modules are already initialized.
	public function Initialize(quickInventory : WmkQuickInventory) {
		m_cfg = theGame.m_quickSlotsConfig;
		m_cfg.SyncConfigVars();

		m_quickInventory = quickInventory;

		m_moduleItemInfo = (CR4HudModuleItemInfo)theGame.GetHud().GetHudModule("ItemInfoModule");
		m_radialMenu = (CR4HudModuleRadialMenu)theGame.GetHud().GetHudModule("RadialMenuModule");

		m_fxShowNewSlotsOnHud = m_moduleItemInfo.GetModuleFlash().GetMemberFlashFunction("WmkShowNewSlots");
		m_fxForceKbSlots = m_moduleItemInfo.GetModuleFlash().GetMemberFlashFunction("WmkForceKbSlots");
		m_fxSelectKbSlot = m_moduleItemInfo.GetModuleFlash().GetMemberFlashFunction("WmkSelectKbSlot");
		m_fxSetRadialInputHandled = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkSetInputHandled");
		m_fxAddRadialFeedbackButton = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkAddFeedbackButton");
		m_fxRemoveRadialFeedbackButton = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkRemoveFeedbackButton");
		m_fxSetRadialMousePosition = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkSetMousePosition");
		m_fxSetSwitchBtnNavCode = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkSetSwitchBtnNavCode");
		m_fxSetMinStickMagnitude = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkSetMinStickMagnitude");
		m_fxShowRadialModule = m_radialMenu.GetModuleFlash().GetMemberFlashFunction("WmkShowModule");
		m_fxUpdateModuleStateArray = theGame.GetHud().GetHudFlash().GetMemberFlashFunction("WmkUpdateModuleStateArray");

		m_minimapPinsToIgnore = theGame.GetHud().GetHudModule("Minimap2Module").GetModuleFlash()
				.GetMemberFlashArray("WmkPinsToIgnore");
		UpdateMinimapPinsToIgnore();

		m_radialAlternativeInputMode =
				theGame.GetInGameConfigWrapper().GetVarValue('Controls', 'AlternativeRadialMenuInputMode');

		RegisterActionListeners();

		SetupRadialMenu();
		SetupNewQuickSlots();
		UpdateHudModuleStateArray();

		m_invalidItem = GetInvalidUniqueId();

		m_itemsInfo.Resize(4);
		m_drinkPotionTimers.Resize(4);

		m_playerIsCiri = thePlayer.IsCiri();
	}

	// Registers the listeners for the input actions supported by this mod.
	// This class is initialized after CPlayerInput, so it is possible to override the default action handlers.
	private function RegisterActionListeners() {
		var i : int;

		// The player may bind a key to change the active set while inside inventory & radial menus.
		if (CanToggleActiveSet()) {
			theInput.RegisterListener(this, 'OnToggleActiveSet', 'ToggleQuickSlotsActiveSet');
			theInput.RegisterListener(this, 'OnToggleActiveSet', 'MouseWheelToggleQuickSlotsActiveSet');
		}

		// Nothing to do if the new quick slots for consumables are disabled...
		if (m_cfg.MAX_EQUIPPED_CONSUMABLES == MAXC_Vanilla) {
			return;
		}

		m_actionNames.Clear();

		if (m_cfg.NEW_POTION_QUICK_SLOTS_KEYS != PQSK_BindNewKeys) {
			m_actionNames.PushBack('DrinkPotion1');
			m_actionNames.PushBack('DrinkPotion2');
			m_actionNames.PushBack('DrinkPotion3');
			m_actionNames.PushBack('DrinkPotion4');
		} else {
			m_actionNames.PushBack('DrinkPotion5');
			m_actionNames.PushBack('DrinkPotion6');
			m_actionNames.PushBack('DrinkPotion7');
			m_actionNames.PushBack('DrinkPotion8');
		}

		for (i = 0; i < m_actionNames.Size(); i += 1) {
			theInput.RegisterListener(this, 'OnCommDrinkPotion', m_actionNames[i]);
		}

		if (ShowAllPotionSlotsWhenUsingGamepad()) {
			theInput.RegisterListener(this, 'OnCommDrinkPotionFilter', 'DrinkPotionUpperHold');
			theInput.RegisterListener(this, 'OnCommDrinkPotionFilter', 'DrinkPotionLowerHold');

			if (m_cfg.NEW_POTION_QUICK_SLOTS_KEYS == PQSK_BindNewKeys) {
				theInput.RegisterListener(this, 'OnCommDrinkPotionFilter', 'DrinkPotion1');
				theInput.RegisterListener(this, 'OnCommDrinkPotionFilter', 'DrinkPotion2');
			}
		}
	}

	// Unregisters all mod's listeners.
	private function UnregisterActionListeners() {
		theInput.UnregisterListener(this, 'ToggleQuickSlotsActiveSet');

		theInput.RegisterListener(thePlayer.GetInputHandler(), 'OnCommDrinkPotion1', 'DrinkPotion1');
		theInput.RegisterListener(thePlayer.GetInputHandler(), 'OnCommDrinkPotion2', 'DrinkPotion2');
		theInput.RegisterListener(thePlayer.GetInputHandler(), 'OnCommDrinkPotion3', 'DrinkPotion3');
		theInput.RegisterListener(thePlayer.GetInputHandler(), 'OnCommDrinkPotion4', 'DrinkPotion4');
		theInput.UnregisterListener(this, 'DrinkPotion5');
		theInput.UnregisterListener(this, 'DrinkPotion6');
		theInput.UnregisterListener(this, 'DrinkPotion7');
		theInput.UnregisterListener(this, 'DrinkPotion8');

		theInput.RegisterListener(thePlayer.GetInputHandler(), 'OnCommDrinkpotionUpperHeld', 'DrinkPotionUpperHold');
		theInput.RegisterListener(thePlayer.GetInputHandler(), 'OnCommDrinkpotionLowerHeld', 'DrinkPotionLowerHold');
	}

	// Called from CR4IngameMenu::OnConfigUI, but only for ingame menu, not death screen menu.
	public function OnIngameMenuOpen(menu : CR4IngameMenu) {
		m_ingameMenuOpened = true;
		m_configChanged = false;
		m_updateScaleCalled = false;
	}

	// Called from CR4IngameMenu::OnOptionValueChanged function.
	public function OnOptionValueChanged(groupName : string, optionName: name, optionValue: string) {
		if (StrContains(groupName, "MoreQuickSlots") || (groupName == "QuickInventory")) {
			m_configChanged = true;
		}

		if ((groupName == "Controls") && (optionName == 'AlternativeRadialMenuInputMode')) {
			m_radialAlternativeInputMode = optionValue == "true";
		}
	}

	// Called from CR4IngameMenu::OnClosingMenu function, but only for ingame menu, not for death screen menu.
	public function OnClosingIngameMenu(menu : CR4IngameMenu) {
		m_ingameMenuOpened = false;

		if (m_configChanged) {
			m_cfg.SyncConfigVars();
		}

		if (m_configChanged || m_updateScaleCalled) {
			UpdateSprites();
		}

		if (!m_configChanged) {
			return;
		}

		SetupRadialMenu();
		SetupNewQuickSlots();

		UpdateHudModuleStateArray();
		UpdateMinimapPinsToIgnore();

		UnregisterActionListeners();
		RegisterActionListeners();

		m_forceUpdateAllNewSlots = true;
		ForceItemInfoModuleTick(true);

		m_quickInventory.OnConfigChanged();
	}

	// Called from CR4HudModuleRadialMenu::UpdateScale function.
	// Is called when the game is loaded and the HUD modules are initialized or when
	// the user closes a panel with options from main menu. Is not called for intermediate menus, the ones that
	// only contain sub-menus. Actually is called twice, because RefreshHudConfiguration() calls twice the UpdateHudScale()
	// function, once directly and once through UpdateHudConfigs() function.
	public function UpdateScale(scale : float, radialFlashModule : CScriptedFlashSprite) {
		if (m_ingameMenuOpened) {
			m_updateScaleCalled = true;
		} else {
			UpdateSprites();
		}
	}

	// Updates some sprites using configured values.
	private function UpdateSprites() {
		var infoFlashModule, radialFlashModule, buffsFlashModule, quickInventoryFlashModule : CScriptedFlashSprite;
		var mcItemSlot, mcRadialInputFeedback, mcRadialInnerBackground, mcQuickInventoryInputFeedback : CScriptedFlashSprite;
		var mcKbPotion1, mcKbPotion2 : CScriptedFlashSprite;
		var mcMaximViewAnchor : CScriptedFlashSprite;
		var yPos, buffsYOffset : float;
		var i : int;

		infoFlashModule = m_moduleItemInfo.GetModuleFlash();
		radialFlashModule = m_radialMenu.GetModuleFlash();
		quickInventoryFlashModule = m_quickInventory.GetModuleFlash();
		buffsFlashModule = theGame.GetHud().GetHudModule("BuffsModule").GetModuleFlash();

		mcItemSlot = infoFlashModule.GetChildFlashSprite("mcItemSlot");
		mcRadialInputFeedback = radialFlashModule.GetChildFlashSprite("mcInputFeedback");
		mcRadialInnerBackground = radialFlashModule.GetChildFlashSprite("wmkInnerBackground");
		mcQuickInventoryInputFeedback = quickInventoryFlashModule.GetChildFlashSprite("mcInputFeedback");

		mcRadialInnerBackground.SetAlpha(m_cfg.INNER_BACKGROUND_OPACITY);

		// used Paint to find the "40" magic value :)
		yPos = mcItemSlot.GetY() + infoFlashModule.GetY() + 40 + m_cfg.QUICK_ACCESS_INPUT_FEEDBACK_PANEL_Y_OFFSET;
		mcRadialInputFeedback.SetY(yPos);
		mcQuickInventoryInputFeedback.SetY(yPos);

		for (i = 0; i < 4; i += 1) {
			mcKbPotion1 = infoFlashModule.GetChildFlashSprite("mcKbPotion" + (i + 1));
			mcKbPotion2 = infoFlashModule.GetChildFlashSprite("mcKbPotion" + (i + 5));

			if (!m_newPotionSlotBaseXOffsetValid) {
				m_newPotionSlotBaseXOffset = mcKbPotion2.GetX() - mcKbPotion1.GetX();
				m_newPotionSlotBaseXOffsetValid = true;
			}

			mcKbPotion2.SetX(mcKbPotion1.GetX() + m_newPotionSlotBaseXOffset
					+ m_cfg.NEW_POTION_SLOTS_X_OFFSET_ON_HUD);
		}

		mcMaximViewAnchor = buffsFlashModule.GetChildFlashSprite("mcMaximViewAnchor");

		if (m_cfg.SHOW_WOLFHEAD_INSIDE_QUICK_ACCESS_MENU) {
			if (!m_updatedBuffMaximViewAnchorYPos) {
				m_defaultBuffMaximViewAnchorYPos = mcMaximViewAnchor.GetY();
			}
			if (theGame.GetInGameConfigWrapper().GetVarValue('Hud', 'HudSize') == "1") {
				buffsYOffset = 100.0;
			} else {
				buffsYOffset = 66.0;
			}
			m_updatedBuffMaximViewAnchorYPos = true;
			mcMaximViewAnchor.SetY(m_defaultBuffMaximViewAnchorYPos + buffsYOffset);
		} else if (m_updatedBuffMaximViewAnchorYPos) {
			mcMaximViewAnchor.SetY(m_defaultBuffMaximViewAnchorYPos);
			m_updatedBuffMaximViewAnchorYPos = false;
		}
	}

	// Called from CInputManager::OnInputDeviceChanged whenever the input device is changed.
	public function UpdateInputDevice() {
		if (thePlayer.IsCiri()) {
			return;
		}

		if (m_inventoryMenu) {
			UpdateInventoryFeedbackButton(theInput.LastUsedGamepad());
		}

		SetupRadialMenu();
	}

	// Updates the list with pins that must not be displayed on minimap.
	private function UpdateMinimapPinsToIgnore() {
		m_minimapPinsToIgnore.ClearElements();

		if (m_cfg.HIDE_HERB_PINS_FROM_MINIMAP) {
			m_minimapPinsToIgnore.PushBackFlashString("Herb");
		}

		if (m_cfg.HIDE_ENEMY_PINS_FROM_MINIMAP) {
			m_minimapPinsToIgnore.PushBackFlashString("Enemy");
		}
	}

	// Called from CR4Player::DisplayHudMessage.
	// Must return TRUE to block the message, so it won't be displayed on HUD anymore.
	public function OnDisplayHudMessage(message : string) : bool {
		var str1, str2 : string;

		if (m_radialMenu.IsRadialMenuOpened() || m_quickInventory.IsShown()) {
			str1 = GetLocStringByKeyExt("menu_cannot_perform_action_now");
			str2 = GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");

			if (StrBeginsWith(message, str1 + " " + str2)) {
				message = StrReplace(message, str1 + " " + str2, str1 + "<br/>" + str2);
			}

			theGame.GetGuiManager().ShowNotification(message);
			return true;
		}

		return false;
	}

	// Called when the radial or inventory menu is opened.
	public function OnMenuOpened(menu : CObject) {
		if (thePlayer.IsCiri()) {
			return;
		}

		m_inventoryMenu = (CR4InventoryMenu) menu;

		m_playerStatsShown = false;
		m_ignoreShiftKey = false;
		m_mouseWheelToggleCooldown = 0;
		m_canSetRadialMousePosition = true;

		if (m_inventoryMenu && theInput.LastUsedGamepad()) {
			UpdateInventoryFeedbackButton(theInput.LastUsedGamepad());
		}

		if (m_radialMenu == menu) {
			if (ShowAllPotionSlotsWhenUsingGamepad()) {
				if (m_cfg.SELECT_FIRST_POTION_SLOT_ON_QUICK_ACCESS_OPEN_WHEN_USING_GAMEPAD) {
					m_currentSelectedKbSlot = 1;
				} else {
					m_currentSelectedKbSlot = 0;
				}
			}
			
			SetupRadialMenu();
			
			m_forceUpdateAllStdSlots = true;
			ForceItemInfoModuleTick();
		}
	}

	// Called when the radial or inventory menu is closed.
	public function OnMenuClosed(menu : CObject) {
		if (thePlayer.IsCiri()) {
			return;
		}

		if (m_cfg.RESTORE_FIRST_SET_ON_MENU_CLOSE && (m_activeSetIdx != 0)) {
			ToggleActiveSet(false, false);
		}

		if (m_radialMenu == menu) {
			if (m_lastForceKbSlots) {
				m_fxForceKbSlots.InvokeSelfTwoArgs(FlashArgBool(false), FlashArgInt(0));
				m_lastForceKbSlots = false;
			}

			m_forceUpdateAllStdSlots = true;
			ForceItemInfoModuleTick();
		} else {
			m_inventoryMenu = NULL;
		}
	}

	// Handler for OnWmkPaperdollMouseOver inventory event.
	// 0 = outside paperdoll, 1 = inside, but not over the potion & bomb slots, 2 = over the potion & bomb slots.
	// This is called only when the value is changed.
	public function OnInventoryPaperdollMouseOver(oldValue : int, newValue : int) {
		if (newValue == 2) {
			UpdateInventoryFeedbackButton(true);
		} else if (oldValue == 2) {
			UpdateInventoryFeedbackButton(false);
		}
	}

	// Handler for OnPlayerStatsShown inventory event.
	public function OnInventoryPlayerStatsShown() {
		m_playerStatsShown = true;
		UpdateInventoryFeedbackButton(false);
	}

	// Handler for OnPlayerStatsHidden inventory event.
	public function OnInventoryPlayerStatsHidden() {
		m_playerStatsShown = false;
		if (theInput.LastUsedGamepad()) {
			UpdateInventoryFeedbackButton(true);
		}
	}

	// Handler for OnWmkShowTooltip inventory event.
	public function OnInventoryShowTooltip(comparisonMode : bool) {
		m_ignoreShiftKey = comparisonMode;
	}

	// Handler for OnWmkRemoveTooltip inventory event.
	public function OnInventoryRemoveTooltip() {
		m_ignoreShiftKey = false;
	}

	// Called when the user uses the mouse wheel while the cursor is over the potion or bomb inventory quick slots.
	public function OnInventoryPaperdollMouseWheel(delta : int) {
		if (m_mouseWheelToggleCooldown <= 0) {
			m_mouseWheelToggleCooldown = MOUSE_WHEEL_TOGGLE_COOLDOWN;
			ToggleActiveSet(true, false);
		}
	}

	// Called from CR4CommonMenu::OnHotkeyTriggered, but only for inventory menu.
	public function OnInventoryMenuHotkeyTriggered(inventoryMenu : CR4InventoryMenu, keyCode:EInputKey) {
		var toggle : bool = false;
		var outKeys	: array<EInputKey>;

		if (!m_playerStatsShown) {
			if (theInput.LastUsedGamepad()) {
				if ((keyCode == IK_Pad_LeftTrigger) && !m_ignoreShiftKey) {
					toggle = true;
				}
			} else if (((keyCode != IK_LShift) && (keyCode != IK_RShift)) || !m_ignoreShiftKey) {
				outKeys.Clear();
				theInput.GetCurrentKeysForAction('ToggleQuickSlotsActiveSet', outKeys);
				toggle = outKeys.Contains(keyCode);
			}
		}

		if (toggle) {
			this.ToggleActiveSet(true, false);
		}
	}

	// Called once every 100 ms (the time is hardcoded into SWF file) from CR4InventoryMenu::OnTickEvent function.
	public function OnInventoryTick(delta : int) {
		if (m_mouseWheelToggleCooldown > 0) {
			m_mouseWheelToggleCooldown -= delta;
		}
	}

	// Adds or removes the "Toggle Active Set" feedback button for inventory menu.
	//
	// Mod's inventory feedback button can be always added for gamepad input device, but it will be visible
	// only if the game doesn't have other feedback button for same navcode. This is ok if the navcode is L2 because in
	// this way the button will be visible only if there's no comparison data for currently selected item.
	private function UpdateInventoryFeedbackButton(show : bool) {
		var newButtonDef : SKeyBinding;

		if (!CanToggleActiveSet()) {
			return;
		}

		m_inventoryMenu.OnRemoveGFxButton(INVENTORY_TOGGLE_SET_FEEDBACK_BUTTON_ID);

		if (show) {
			m_inventoryMenu.OnAppendGFxButton(INVENTORY_TOGGLE_SET_FEEDBACK_BUTTON_ID, GAMEPAD_L2,
					KEY_CODE_MOUSE_SCROLL, "mqs_toggle_active_set", false);
		}

		m_inventoryMenu.OnUpdateGFxButtonsList();
	}

	// Setups the radial menu.
	// This is called when the mod is initialized, when mod's settings are changed, when the input
	// device is changed and when the radial menu is opened.
	private function SetupRadialMenu() {
		var switchBtnNavCode : string = "";
		var forceKbSlots : bool = false;

		if (ShowAllPotionSlotsWhenUsingGamepad() && !m_cfg.USE_DPAD_FOR_POTION_SLOTS_NAVIGATION) {
			switchBtnNavCode = "gamepad_dpad_lr";
		}

		if (switchBtnNavCode != m_lastRadialSwitchBtnNavCode) {
			m_fxSetSwitchBtnNavCode.InvokeSelfOneArg(FlashArgString(switchBtnNavCode));
			m_lastRadialSwitchBtnNavCode = switchBtnNavCode;
		}

		if (m_cfg.MIN_STICK_MAGNITUDE != m_lastRadialMinStickMagnitude) {
			m_fxSetMinStickMagnitude.InvokeSelfOneArg(FlashArgNumber(m_cfg.MIN_STICK_MAGNITUDE));
			m_lastRadialMinStickMagnitude = m_cfg.MIN_STICK_MAGNITUDE;
		}

		forceKbSlots = !thePlayer.IsCiri() && m_radialMenu.IsRadialMenuOpened()
				&& ShowAllPotionSlotsWhenUsingGamepad()
				&& theInput.LastUsedGamepad();

		if (forceKbSlots != m_lastForceKbSlots) {
			if (forceKbSlots) {
				m_fxForceKbSlots.InvokeSelfTwoArgs(FlashArgBool(true), FlashArgInt(m_currentSelectedKbSlot));
			} else {
				m_fxForceKbSlots.InvokeSelfTwoArgs(FlashArgBool(false), FlashArgInt(0));
			}
			m_lastForceKbSlots = forceKbSlots;
		}

		if (!thePlayer.IsCiri()) {
			UpdateRadialFeedbackButtons();
		}
	}

	private function ShowAllPotionSlotsWhenUsingGamepad() : bool {
		return m_cfg.SHOW_ALL_POTION_SLOTS_WHEN_USING_GAMEPAD && m_cfg.MAX_EQUIPPED_CONSUMABLES > MAXC_Vanilla;
	}

	// Updates the state entries for RadialMenu and QuickInventory in hudModuleStateArray variable
	// from Hud class. WmkUpdateModuleStateArray function expects 4 arguments: the key, which seems to be the input
	// context, state's name (Show, OnDemand, OnUpdate, Hide), the name of the other module and a boolean
	// specifying if the other module must be added or removed. I think OnDemand is not used.
	private function UpdateHudModuleStateArray() {
		var contexts, modules : array<string>;
		var values : array<bool>;
		var i, j : int;

		contexts.PushBack("RadialMenu");
		contexts.PushBack("QuickInventory");

		modules.PushBack("WolfHeadModule");
		values.PushBack(m_cfg.SHOW_WOLFHEAD_INSIDE_QUICK_ACCESS_MENU);
		modules.PushBack("Minimap2Module");
		values.PushBack(m_cfg.SHOW_MINIMAP_INSIDE_QUICK_ACCESS_MENU);
		modules.PushBack("QuestsModule");
		values.PushBack(m_cfg.SHOW_TRACKED_QUEST_INSIDE_QUICK_ACCESS_MENU);

		for (i = 0; i < contexts.Size(); i += 1) {
			for (j = 0; j < modules.Size(); j += 1) {
				m_fxUpdateModuleStateArray.InvokeSelfFourArgs(FlashArgString(contexts[i]), FlashArgString("Hide"),
						FlashArgString(modules[j]), FlashArgBool(!values[j]));
				m_fxUpdateModuleStateArray.InvokeSelfFourArgs(FlashArgString(contexts[i]), FlashArgString("Show"),
						FlashArgString(modules[j]), FlashArgBool(values[j]));
			}
		}
	}

	// Updates the feedback buttons for radial menu.
	private function UpdateRadialFeedbackButtons(optional onlyToggleSetButton : bool) {
		var showToggleSetHint : bool = theInput.LastUsedGamepad() || IsSignRadialSlotIndex(m_lastSelectedRadialSlot)
				|| IsBombRadialSlotIndex(m_lastSelectedRadialSlot);

		if (CanToggleActiveSet() && showToggleSetHint) {
			m_fxAddRadialFeedbackButton.InvokeSelfFiveArgs(FlashArgInt(RADIAL_TOGGLE_SET_FEEDBACK_BUTTON_ID),
					FlashArgString(GAMEPAD_L2),	FlashArgUInt(KEY_CODE_MOUSE_SCROLL),
					FlashArgString("[[mqs_toggle_active_set]]"),
					FlashArgBool(true));
		} else {
			m_fxRemoveRadialFeedbackButton.InvokeSelfTwoArgs(FlashArgInt(RADIAL_TOGGLE_SET_FEEDBACK_BUTTON_ID),
					FlashArgBool(true));
		}

		if (onlyToggleSetButton) {
			return;
		}

		if (ShowAllPotionSlotsWhenUsingGamepad() && theInput.LastUsedGamepad()) {
			m_fxAddRadialFeedbackButton.InvokeSelfFiveArgs(FlashArgInt(RADIAL_USE_POTION_SLOT_FEEDBACK_BUTTON_ID),
					FlashArgString(GAMEPAD_Y), FlashArgUInt(-1),
					FlashArgString("[[mqs_use_selected_consumable]]"),
					FlashArgBool(true));
		} else {
			m_fxRemoveRadialFeedbackButton.InvokeSelfTwoArgs(
					FlashArgInt(RADIAL_USE_POTION_SLOT_FEEDBACK_BUTTON_ID),
					FlashArgBool(true));
		}

		m_fxAddRadialFeedbackButton.InvokeSelfFiveArgs(FlashArgInt(RADIAL_QUICK_INVENTORY_FEEDBACK_BUTTON_ID),
					FlashArgString(GAMEPAD_R1), FlashArgUInt(IK_RightMouse),
					FlashArgString("[[mqs_quick_inventory]]"),
					FlashArgBool(true));
	}

	// Handler for an event sent from HudModuleRadialMenu.handleInput function from flash module.
	// Using WmkSetRadialInputHandled function the input can be blocked, but not in all cases. For example the actions
	// for drinking potions are executed before this handler, so is not possible to block them from here.
	//
	// For d-pad keys two events are dispatched, one with "dpad_xxx" code and one with "xxx" code, where "xxx"
	// is "up", "right", "down" or "left". The problem is that the "xxx" codes are also dispatched for left stick,
	// but it seems these have fromJoystick flag set to true.
	public function OnRadialMenuHandleInput(value : string, navEquivalent : string, code : float, fromJoystick : bool) {
		var updateSelectedKbSlot, setHandled : bool;
		var newSelectedKbSlot : int = 0;

		if (thePlayer.IsCiri()) {
			return;
		}

		if (navEquivalent == GAMEPAD_R1) {
			if (value == INPUT_VALUE_KEY_UP) {
				m_quickInventory.ShowQuickInventory();
			}
			setHandled = true;
		} else if (navEquivalent == GAMEPAD_L2) {
			if (value == INPUT_VALUE_KEY_DOWN) {
				ToggleActiveSet(false, true);
			}
			setHandled = true;
		} else if (!ShowAllPotionSlotsWhenUsingGamepad()) {
			return;
		} else if (navEquivalent == GAMEPAD_Y) {
			if (value == INPUT_VALUE_KEY_UP) {
				if (thePlayer.IsActionAllowed(EIAB_QuickSlots)) {
					if ((m_currentSelectedKbSlot >= 1) && (m_currentSelectedKbSlot <= 8)) {
						GetWitcherPlayer().OnPotionDrinkKeyboardsInput(
								GetEquipmentSlot(FIRST_POTION_SLOT, m_currentSelectedKbSlot - 1));
					}
				} else {
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
				}
			}
			setHandled = true;
		} else if (m_cfg.USE_DPAD_FOR_POTION_SLOTS_NAVIGATION) {
			updateSelectedKbSlot = IsDpadNavCode(navEquivalent)
					|| ((value == INPUT_VALUE_KEY_UP) && IsSimpleNavCode(navEquivalent) && !fromJoystick);
		} else if (m_radialAlternativeInputMode) {
			updateSelectedKbSlot = IsSimpleNavCode(navEquivalent) && fromJoystick;
		} else {
			updateSelectedKbSlot = IsRightStickNavCode(navEquivalent);
		}

		if (updateSelectedKbSlot) {
			if (value == INPUT_VALUE_KEY_DOWN) {
				newSelectedKbSlot = GetNewSelectedKbSlot(navEquivalent);

				if (newSelectedKbSlot != m_currentSelectedKbSlot) {
					m_fxSelectKbSlot.InvokeSelfOneArg(FlashArgInt(newSelectedKbSlot));
					m_currentSelectedKbSlot = newSelectedKbSlot;
				}
			}

			setHandled = true;
		}

		if (setHandled) {
			m_fxSetRadialInputHandled.InvokeSelfOneArg(FlashArgBool(true));
		}
	}

	// Returns true if the specified parameter is a code for a d-pad button.
	private function IsDpadNavCode(code : string) : bool {
		return (code == "dpad_up") || (code == "dpad_right") || (code == "dpad_down") || (code == "dpad_left");
	}

	// Returns true if the specified parameter is a navigation code. These are sent for both d-pad and left stick.
	private function IsSimpleNavCode(code : string) : bool {
		return (code == "up") || (code == "right") || (code == "down") || (code == "left");
	}

	// Returns true if the specified parameter is a code for right stick.
	private function IsRightStickNavCode(code : string) : bool {
		return (code == "rightStickUp") || (code == "rightStickRight") || (code == "rightStickDown") || (code == "rightStickLeft");
	}

	// Helper for OnRadialMenuHandleInput. Returns the new selected keyboard slot.
	private function GetNewSelectedKbSlot(code: string) : int {
		switch (code) {
			case "up":
			case "dpad_up":
			case "rightStickUp":
				if (m_currentSelectedKbSlot <= 4) {
					if (m_currentSelectedKbSlot > 1) {
						return m_currentSelectedKbSlot - 1;
					} else {
						return 4;
					}
				} else {
					if (m_currentSelectedKbSlot > 5) {
						return m_currentSelectedKbSlot - 1;
					} else {
						return 8;
					}
				}
			case "right":
			case "dpad_right":
			case "rightStickRight":
				if (m_currentSelectedKbSlot <= 4) {
					return m_currentSelectedKbSlot + 4;
				} else {
					break;
				}
			case "down":
			case "dpad_down":
			case "rightStickDown":
				if (m_currentSelectedKbSlot <= 4) {
					return (m_currentSelectedKbSlot % 4) + 1;
				} else {
					return ((m_currentSelectedKbSlot - 4) % 4) + 5;
				}
			case "left":
			case "dpad_left":
			case "rightStickLeft":
				if (m_currentSelectedKbSlot > 4) {
					return m_currentSelectedKbSlot - 4;
				} else {
					break;
				}
		}

		return m_currentSelectedKbSlot;
	}

	// Called when the radial flash module receives the data about player's items.
	//
	// Updating mouse position before the flash module has data about slots results in an exception. This
	// doesn't crash the game, but still is not ok. Also the exception occurs only when the radial menu is opened for
	// the first time after a save is loaded (and probably after a new game is started).
	public function OnRadialMenuHandleSetItemsList() {
		var slotIndex : int = -1;
		var option : EWmkSelectedItemOnRadialOpen;

		if (thePlayer.IsCiri() || !this.m_canSetRadialMousePosition) {
			return;
		}

		if (theInput.LastUsedGamepad()) {
			option = m_cfg.GAMEPAD_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN;
		} else {
			option = m_cfg.KB_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN;
		}

		switch (option) {
			case QASI_Default:
				return;
			case QASI_EquippedSign:
				slotIndex = GetRadialSlotIndexForSign(GetWitcherPlayer().GetEquippedSign());
				break;
			case QASI_EquippedItem:
				slotIndex = GetRadialSlotIndexForEquipmentSlot(GetWitcherPlayer().GetItemSlot(GetWitcherPlayer().GetSelectedItemId()));
				if (slotIndex > 0) {
					break;
				}
			case QASI_LastSelected:
				if (m_lastSelectedRadialSlot > 0) {
					slotIndex = m_lastSelectedRadialSlot;
				}
				break;
			default:
				slotIndex = 1 + (option - QASI_Yrden);
				break;
		}

		if ((slotIndex <= 0) || (slotIndex > 11)) {
			slotIndex = 3; // Igni
		}

		this.m_canSetRadialMousePosition = false;
		m_fxSetRadialMousePosition.InvokeSelfOneArg(FlashArgInt(slotIndex));
	}

	// Handler for OnRadialMenuItemSelected event.
	public function OnRadialMenuItemSelected(slotName : string, isDesaturated : bool) {
		m_lastSelectedRadialSlot = GetRadialSlotIndexForSlotName(slotName);

		if (theInput.LastUsedPCInput()) {
			UpdateRadialFeedbackButtons(true);
		}
	}

	// Handler for event dispatched when the user uses the mouse wheel while the radial menu is opened.
	public function OnRadialMouseWheel(delta : int) {
		if (!thePlayer.IsCiri()) {
			if (IsBombRadialSlotIndex(m_lastSelectedRadialSlot) || IsSignRadialSlotIndex(m_lastSelectedRadialSlot)) {
				if (m_mouseWheelToggleCooldown <= 0) {
					m_mouseWheelToggleCooldown = MOUSE_WHEEL_TOGGLE_COOLDOWN;
					ToggleActiveSet(false, true);
				}
			}
		}
	}

	// The handler for ToggleQuickSlotsActiveSet and MouseWheelToggleQuickSlotsActiveSet actions.
	event OnToggleActiveSet(action : SInputAction) {
		var toggle : bool = false;

		if (!thePlayer.IsCiri()) {
			if (action.aName == 'MouseWheelToggleQuickSlotsActiveSet') {
				if (m_mouseWheelToggleCooldown <= 0) {
					m_mouseWheelToggleCooldown = MOUSE_WHEEL_TOGGLE_COOLDOWN;
					toggle = AbsF(action.value) > 2.5f;
				}
			} else {
				toggle = IsReleased(action);
			}
		}

		if (toggle) {
			ToggleActiveSet(false, m_radialMenu.IsRadialMenuOpened());
		}
	}

	// Handler for OnWmkActivateSlot event.
	//
	// reason = 0 -> explicit (mouse click, ENTER, E)
	// reason = 1 -> the prev / next item from a radial menu slot was selected
	// reason = 2 -> tab key released (if the game was not paused) or pressed again (if the game was paused)
	public function OnRadialMenuActivateSlot(slotName : string, reason : int) {
		var option : EWmkEquipItemOnRadialClose;

		if (reason == 2) {
			if (theInput.LastUsedGamepad()) {
				option = m_cfg.GAMEPAD_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE;
			} else {
				option = m_cfg.KB_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE;
			}

			switch (option) {
				case QAEI_Default:
					break;
				case QAEI_WhenGamePaused:
					if (theGame.IsPausedForReason("FastMenu")) {
						break;
					}
					return;
				case QAEI_WhenGameSlowed:
					if (theGame.IsPausedForReason("FastMenu")) {
						return;
					}
					break;
				default:
					return;
			}
		}

		if (slotName != "") {
			thePlayer.OnRadialMenuItemChoose(slotName);
		}
	}

	// This is called when when the right mouse button is clicked while the radial menu is opened. By default
	// the flash module sends the OnRequestCloseRadial, but this was changed.
	public function OnRadialRightMouseButtonClick() {
		m_quickInventory.ShowQuickInventory();
	}

	public function OnQuickInventoryShow() {
		if (m_radialMenu.IsRadialMenuOpened()) {
			m_fxShowRadialModule.InvokeSelfOneArg(FlashArgBool(false));

			if (!theGame.IsPausedForReason("FastMenu")) {
				theGame.Pause("FastMenu");
			}
		}
	}

	public function OnQuickInventoryHide(hideAction : EWmkInventoryHideAction) {
		var isRadialMenuOpened : bool = m_radialMenu.IsRadialMenuOpened();

		if (m_radialMenu.IsRadialMenuOpened()) {
			m_fxShowRadialModule.InvokeSelfOneArg(FlashArgBool(true));

			if (theInput.LastUsedPCInput()) {
				if (m_lastSelectedRadialSlot > 0) {
					m_fxSetRadialMousePosition.InvokeSelfOneArg(FlashArgInt(m_lastSelectedRadialSlot));
				}
			}

			if (hideAction == QIHA_HideRadialMenu) {
				m_radialMenu.HideRadialMenu();
			}
		} else if (hideAction == QIHA_ShowRadialMenu) {
			m_radialMenu.ShowRadialMenu();
		}

		// ShowRadialMenu / HideRadialMenu only change the input context. The CR4ScriptedHud.OnTick
		// method detects if the input context was changed and calls Hud.SetInputContext ActionScript method,
		// which updates the visibility for all hud modules. This is why calling OnTick here
		// will actually force an immediate update for the visibility of for radial menu.
		if (isRadialMenuOpened != m_radialMenu.IsRadialMenuOpened()) {
			((CR4ScriptedHud)theGame.GetHud()).OnTick(0.0);
		}
	}

	private function CanToggleActiveSet() : bool {
		return (m_cfg.MAX_EQUIPPED_CONSUMABLES > MAXC_OneSet) || (m_cfg.MAX_EQUIPPED_BOMBS > MAXB_OneSet);
	}

	// Toggles the potions & bombs active set.
	// If the inventory menu is openened then updates the paperdoll data for the potion & bomb slots.
	// If the radial menu is opened this forces a HUD tick to update the potion slots data.
	private function ToggleActiveSet(updatePaperdoll : bool, updateRadial : bool) {
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();
		var oldItem, newItem : SItemUniqueId;
		var invItemsToUpdate : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		var startIndex, i : int;

		if (!CanToggleActiveSet()) {
			return;
		}

		if (m_cfg.MAX_EQUIPPED_CONSUMABLES == MAXC_TwoSets) {
			startIndex = 0;
		} else if (m_cfg.MAX_EQUIPPED_CONSUMABLES == MAXC_TwoSetsFixedStd) {
			startIndex = 4;
		} else {
			startIndex = 8;
		}

		for (i = startIndex; i < 12; i += 1) {
			if (i >= 8) {
				if (m_cfg.MAX_EQUIPPED_BOMBS == MAXB_OneSet) {
					break;
				} else if ((m_cfg.MAX_EQUIPPED_BOMBS == MAXB_TwoSetsFixedStd) && (i <= 9)) {
					continue;
				}
			}

			slot = GetPotionBombEquipmentSlot(i);

			if (m_inventoryMenu && updatePaperdoll) {
				if (!witcherPlayer.GetItemEquippedOnSlot(slot, oldItem)) {
					oldItem = m_invalidItem;
				}
			}
			witcherPlayer.SwapEquippedItems(slot, GetPotionBombEquipmentSlot(i, true));
			if (m_inventoryMenu && updatePaperdoll) {
				if (witcherPlayer.GetItemEquippedOnSlot(slot, newItem)) {
					invItemsToUpdate.PushBack(newItem);
				} else if (oldItem != m_invalidItem) {
					m_inventoryMenu.PaperdollRemoveItem(oldItem);
				}
			}
		}

		if (invItemsToUpdate.Size() > 0) {
			m_inventoryMenu.PaperdollUpdateItemsList(invItemsToUpdate);
		} else if (m_radialMenu.IsRadialMenuOpened()) {
			ForceItemInfoModuleTick(false);
			if (updateRadial) {
				m_radialMenu.UpdateItemsIcons(true);
			}
		} else {
			ForceItemInfoModuleTick(false);
		}

		m_activeSetIdx = 1 - m_activeSetIdx;
	}

	// Called when the mod is initialized and whenever mod's settings are changed.
	private function SetupNewQuickSlots() {
		if (m_cfg.MAX_EQUIPPED_CONSUMABLES == MAXC_Vanilla) {
			SetNewQuickSlotsVisibility(false);
		}

		if (!thePlayer.IsCiri()) {
			UnequipItemsFromUnusedQuickSlots();
		}
	}

	private function SetNewQuickSlotsVisibility(visible : bool) {
		if (m_currentShowOnHud != visible) {
			m_fxShowNewSlotsOnHud.InvokeSelfOneArg(FlashArgBool(visible));
			m_currentShowOnHud = visible;
		}
	}

	// Unequips the items from the equipment slots that are not used, so the items will appear in player's inventory.
	private function UnequipItemsFromUnusedQuickSlots() {
		var witcherPlayer : W3PlayerWitcher = GetWitcherPlayer();
		var countNewPotionSlot : int = -1;
		var countReservedPotionSlot : int = -1;
		var countReservedPetardSlot : int = -1;
		var i : int;

		switch (m_cfg.MAX_EQUIPPED_CONSUMABLES) {
			case MAXC_Vanilla: countNewPotionSlot = 4; countReservedPotionSlot = 8;	break; // everything
			case MAXC_OneSet: countReservedPotionSlot = 8; break; // all reserved potion slots
			case MAXC_TwoSetsFixedStd: countReservedPotionSlot = 4;	break; // only first 4 reserved potion slots
		}

		switch (m_cfg.MAX_EQUIPPED_BOMBS) {
			case MAXB_OneSet: countReservedPetardSlot = 4; break; // all reserved petard slots
			case MAXB_TwoSetsFixedStd: countReservedPetardSlot = 2;	break; // only first 2 reserved petard slots
		}

		if (countNewPotionSlot > 0) {
			for (i = 0; i < countNewPotionSlot; i += 1) {
				witcherPlayer.UnequipItemFromSlot(GetEquipmentSlot(FIRST_NEW_POTION_SLOT, i));
			}
		}

		if (countReservedPotionSlot > 0) {
			for (i = 0; i < countReservedPotionSlot; i += 1) {
				witcherPlayer.UnequipItemFromSlot(GetEquipmentSlot(FIRST_RESERVED_POTION_SLOT, i));
			}
		}

		if (countReservedPetardSlot > 0) {
			for (i = 0; i < countReservedPetardSlot; i += 1) {
				witcherPlayer.UnequipItemFromSlot(GetEquipmentSlot(FIRST_RESERVED_PETARD_SLOT, i));
			}
		}
	}

	// Forces a tick for Items Info module.
	// If notNow = true then the tick is scheduled, but it will "happen" during next OnTick event.
	private function ForceItemInfoModuleTick(optional notNow : bool) {
		m_forceItemInfoModuleTick = true;
		if (!notNow) {
			m_moduleItemInfo.OnTick(0);
		}
	}

	// Called from CR4HudModuleItemInfo::OnTick function. Returns TRUE to force a tick.
	public function OnItemInfoModuleTick(timeDelta : float, canTick : bool) : bool {
		var i : int;
		var showNewQuickSlots : bool = false;

		if (thePlayer.IsCiri() != m_playerIsCiri) {
			m_playerIsCiri = thePlayer.IsCiri();

			if (m_playerIsCiri) {
				SetNewQuickSlotsVisibility(false);
				// In ActionScript the WmkShowNewSlots function calls UpdateHints, which sets the
				// visibility for all slots, even if the current player is Ciri. This is why the HideSlots is
				// also called, so the slots remain hidden.
				m_moduleItemInfo.m_fxHideSlotsSFF.InvokeSelfOneArg(FlashArgBool(!m_playerIsCiri));
			} else {
				// Maybe the initial player was Ciri, so SetupNewQuickSlots couldn't unequip the items from unused slots...
				UnequipItemsFromUnusedQuickSlots();
			}
		}

		if ((timeDelta > 0) && (m_mouseWheelToggleCooldown > 0)) {
			m_mouseWheelToggleCooldown -= (timeDelta * 1000);
		}

		// Nothing to do for the new quick slots if they are disabled or if the player is Ciri.
		if (m_playerIsCiri || (m_cfg.MAX_EQUIPPED_CONSUMABLES == MAXC_Vanilla)) {
			if (m_newSlotsTickingEnabled) {
				m_newSlotsTickingEnabled = false;
			}
			return false;
		}

		// Force an update for the new quick slots and reset the drinking timers if the new quick slots where enabled
		// or if the player changes from Ciri to Geralt...
		if (!m_newSlotsTickingEnabled) {
			m_newSlotsTickingEnabled = true;
			m_forceUpdateAllNewSlots = true;

			for (i = 0; i < m_drinkPotionTimers.Size(); i += 1) {
				m_drinkPotionTimers[i] = 0.0;
			}
		}

		// If a tick must be forced but canTick = false then return true. This function will be called
		// immediately again, but after the Item Info module does its things...
		if (m_forceItemInfoModuleTick) {
			m_forceItemInfoModuleTick = false;
			if (!canTick) {
				return true;
			}
		}

		// This function must be called as often as possible, because 0.25s (the tick interval) is way too much.
		if (m_cfg.NEW_POTION_QUICK_SLOTS_KEYS != PQSK_BindNewKeys) {
			OnDrinkPotionTick(timeDelta);
		}

		// Nothing to do if can't tick.
		if (!canTick) {
			return false;
		}

		if (m_dumplingsRunewordActive != GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats')) {
			m_dumplingsRunewordActive = !m_dumplingsRunewordActive;
			m_forceUpdateAllNewSlots = true;
		}

		for (i = 0; i < 4; i += 1) {
			UpdateNewPotionSlotData(i, m_forceUpdateAllNewSlots);
		}

		// The slots were updated if required, so the flags must be set back to false...
		m_forceUpdateAllStdSlots = false;
		m_forceUpdateAllNewSlots = false;

		if (m_radialMenu.IsRadialMenuOpened()) {
			showNewQuickSlots = theInput.LastUsedPCInput() || ShowAllPotionSlotsWhenUsingGamepad();
		} else if (theInput.LastUsedPCInput()) {
			if (m_cfg.SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD == SNQS_Always) {
				showNewQuickSlots = true;
			} else if (m_cfg.SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD == SNQS_OnlyWhenNotEmpty) {
				for (i = 0; i < 4; i += 1) {
					if (m_itemsInfo[i].m_item != m_invalidItem) {
						showNewQuickSlots = true;
						break;
					}
				}
			}
		}

		SetNewQuickSlotsVisibility(showNewQuickSlots);

		return false;
	}

	// Called from CR4HudModuleItemInfo.OnTick, but only for Geralt and only if a gamepad is used.
	public function CanFlipEquippedItems() : bool {
		return !m_radialMenu.IsRadialMenuOpened() || !ShowAllPotionSlotsWhenUsingGamepad();
	}

	// Called from CR4HudModuleItemInfo.GetKeyByBinding.
 	public function GetKeyByBindingForStdSlot(bindingName : HudItemInfoBinding, out outKeys : array<EInputKey>) : bool {
		if (!thePlayer.IsCiri() && m_radialMenu.IsRadialMenuOpened() && ShowAllPotionSlotsWhenUsingGamepad()) {
			outKeys.PushBack(-1);
			return true;
		}

		return false;
	}

	// Updates the data for a new potion quick slot.
	private function UpdateNewPotionSlotData(idx : int, forceUpdate : bool) {
		var item : SItemUniqueId;
		var icon, category, itemName, ammoStr : string;
		var btn, pcBtn : int;
		var inv : CInventoryComponent;

		if (UpdateNewPotionSlotItemInfo(idx) || forceUpdate) {
			item = m_itemsInfo[idx].m_item;
			if (item != m_invalidItem) {
				inv = thePlayer.GetInventory();
				if (inv.ItemHasTag(item, 'Edibles') && m_dumplingsRunewordActive) {
					icon = "icons/inventory/food/food_dumpling_64x64.png";
				} else {
					icon = inv.GetItemIconPathByUniqueID(item);
				}
				category = inv.GetItemCategory(item);
				itemName = DecorateTextWithFont(inv.GetItemLocNameByID(item), m_itemsInfo[idx].m_ammo <= 0);
				ammoStr = DecorateTextWithFont(GetAmmoStr(m_itemsInfo[idx].m_ammo), m_itemsInfo[idx].m_ammo <= 0);
				GetKeysForNewPotionSlot(idx, btn, pcBtn);
			} else  {
				icon = "";
				category = "";
				itemName = "";
				ammoStr = "";
				btn = 0; // must be 0
				pcBtn = -1;
			}

			m_moduleItemInfo.m_fxSetItemInfo.InvokeSelfSevenArgs(FlashArgInt(4 /* default slots */ + idx + 1),
					FlashArgString(icon), FlashArgString(category), FlashArgString(itemName),
					FlashArgString(ammoStr), FlashArgInt(btn), FlashArgInt(pcBtn));
		}
	}

	// Returns TRUE if the data about the item from specified new quick slot has changed.
	private function UpdateNewPotionSlotItemInfo(idx : int) : bool {
		var item : SItemUniqueId;
		var ammo, maxAmmo : int;

		if (!GetWitcherPlayer().GetItemEquippedOnSlot(GetEquipmentSlot(FIRST_NEW_POTION_SLOT, idx), item)) {
			item = m_invalidItem;
		}

		if (item != m_invalidItem) {
			GetItemAmmo(item, ammo, maxAmmo);
			if ((item != m_itemsInfo[idx].m_item) || (m_itemsInfo[idx].m_ammo != ammo) || (m_itemsInfo[idx].m_maxAmmo != maxAmmo)) {
				m_itemsInfo[idx].m_item = item;
				m_itemsInfo[idx].m_ammo = ammo;
				m_itemsInfo[idx].m_maxAmmo = maxAmmo;
				return true;
			}
		} else if (m_itemsInfo[idx].m_item != m_invalidItem) {
			m_itemsInfo[idx] = m_invalidItemInfo;
			return true;
		}

		return false;
	}

	// Doesn't support crossbows.
	// Also doesn't support edibles with infinite use.
	private function GetItemAmmo(item : SItemUniqueId, out ammo : int, out maxAmmo : int) {
		var inv : CInventoryComponent = thePlayer.GetInventory();

		if (inv.IsItemSingletonItem(item)) {
			ammo = inv.SingletonItemGetAmmo(item);
			maxAmmo = inv.SingletonItemGetMaxAmmo(item);
		} else if (inv.ItemHasTag(item, 'Edibles')) {
			ammo = inv.GetItemQuantity(item);
			maxAmmo = -1;
		} else {
			ammo = -1;
			maxAmmo = -1;
		}
	}

	private function DecorateTextWithFont(text : string, red : bool) : string {
		if (red) {
			return "<font color='#FF0000'>" + text + "</font>";
		} else {
			return "<font color='#FFFFFF'>" + text + "</font>";
		}
	}

	private function GetAmmoStr(ammo : int) : string {
		if (ammo >= 0) {
			return IntToString(ammo);
		} else {
			return "";
		}
	}

	private function GetKeysForNewPotionSlot(idx : int, out btn : int, out pcBtn : int) {
		var outKeys : array<EInputKey>;

		if ((idx >= 0) && (idx <= m_actionNames.Size())) {
			theInput.GetPCKeysForAction(m_actionNames[idx], outKeys);
		}

		if (outKeys.Size() > 0) {
			btn = -1; // must be != 0
			pcBtn = outKeys[0];
		} else {
			btn = 0;
			pcBtn = -1;
		}
	}

	// Handler for DrinkPotion actions.
	// This is not registered if the new quick slots are disabled.
	event OnCommDrinkPotion(action : SInputAction) {
		if (!thePlayer.IsCiri()) {
			// Don't change anything for gamepad users and standard drink actions. Except when the
			// actions must be blocked.
			if (theInput.LastUsedGamepad()) {
				if (!m_radialMenu.IsRadialMenuOpened() || !ShowAllPotionSlotsWhenUsingGamepad()) {
					switch (action.aName) {
						case 'DrinkPotion1': return thePlayer.GetInputHandler().OnCommDrinkPotion1(action);
						case 'DrinkPotion2': return thePlayer.GetInputHandler().OnCommDrinkPotion2(action);
						case 'DrinkPotion3': return thePlayer.GetInputHandler().OnCommDrinkPotion3(action);
						case 'DrinkPotion4': return thePlayer.GetInputHandler().OnCommDrinkPotion4(action);
					}
				} else {
					return true;
				}
			}

			// QuickDoubleTap and Hold options reuse the standard drink actions, so the input
			// device can't be the gamepad because this case was handled above. The following code
			// executes for gamepad users only for BindNewKeys option.

			if (thePlayer.IsActionAllowed(EIAB_QuickSlots)) {
				switch (m_cfg.NEW_POTION_QUICK_SLOTS_KEYS) {
					case PQSK_BindNewKeys: return OnDrinkPotion(action);
					case PQSK_QuickDoubleTapStdKey: return OnDrinkPotionDoubleTapKey(action);
					case PQSK_HoldStdKey: return OnDrinkPotionHoldKey(action);
				}
			} else {
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
			}
		}

		return false;
	}

	// Handler for the drink actions that must be blocked in some cases.
	event OnCommDrinkPotionFilter(action : SInputAction) {
		var block : bool = !thePlayer.IsCiri() && theInput.LastUsedGamepad() && m_radialMenu.IsRadialMenuOpened()
				&& ShowAllPotionSlotsWhenUsingGamepad();

		if (!block) {
			switch (action.aName) {
				case 'DrinkPotionUpperHold': return thePlayer.GetInputHandler().OnCommDrinkpotionUpperHeld(action);
				case 'DrinkPotionLowerHold': return thePlayer.GetInputHandler().OnCommDrinkpotionLowerHeld(action);
				case 'DrinkPotion1': return thePlayer.GetInputHandler().OnCommDrinkPotion1(action);
				case 'DrinkPotion2': return thePlayer.GetInputHandler().OnCommDrinkPotion2(action);
			}
		}

		return true;
	}

	// New actions are used for the new quick slots.
	private function OnDrinkPotion(action : SInputAction) : bool {
		var idx : int;

		if (IsReleased(action)) {
			GetWitcherPlayer().OnPotionDrinkKeyboardsInput(
					GetEquipmentSlot(FIRST_NEW_POTION_SLOT, m_actionNames.FindFirst(action.aName)));
		}

		return true;
	}

	// Double tap a key to drink a potion from the new quick slots.
	private function OnDrinkPotionDoubleTapKey(action : SInputAction) : bool {
		var idx : int;

		if (IsPressed(action)) {
			idx = m_actionNames.FindFirst(action.aName);

			if (m_drinkPotionTimers[idx] <= 0.0) { // first time
				m_drinkPotionTimers[idx] = m_cfg.DOUBLE_TAP_KEY_INTERVAL_SECONDS;
			} else { // second time, timer didn't expire
				m_drinkPotionTimers[idx] = 0.0;
				GetWitcherPlayer().OnPotionDrinkKeyboardsInput(GetEquipmentSlot(FIRST_NEW_POTION_SLOT, idx));
			}
		}

		return true;
	}

	// Hold key to drink a potion from the new quick slots.
	private function OnDrinkPotionHoldKey(action : SInputAction) : bool {
		var idx : int = m_actionNames.FindFirst(action.aName);

		if (IsPressed(action)) {
			m_drinkPotionTimers[idx] = m_cfg.HOLD_KEY_INTERVAL_SECONDS;
		} else if (IsReleased(action) && (m_drinkPotionTimers[idx] > 0.0)) { // released before the timer expired
			m_drinkPotionTimers[idx] = 0.0;
			GetWitcherPlayer().OnPotionDrinkKeyboardsInput(GetEquipmentSlot(FIRST_POTION_SLOT, idx));
		}

		return true;
	}

	// This is called from OnItemInfoModuleTick, but only for Geralt and
	// only if the actions for standard quick slots are also used for the new quick slots.
	private function OnDrinkPotionTick(timeDelta : float) {
		var i : int;

		for (i = 0; i < m_drinkPotionTimers.Size(); i += 1) {
			if (m_drinkPotionTimers[i] > 0.0) {
				m_drinkPotionTimers[i] -= timeDelta;

				if (m_drinkPotionTimers[i] <= 0.0) {
					if (thePlayer.IsActionAllowed(EIAB_QuickSlots)) {
						if (m_cfg.NEW_POTION_QUICK_SLOTS_KEYS == PQSK_QuickDoubleTapStdKey) {
							GetWitcherPlayer().OnPotionDrinkKeyboardsInput(GetEquipmentSlot(FIRST_POTION_SLOT, i));
						} else if (m_cfg.NEW_POTION_QUICK_SLOTS_KEYS == PQSK_HoldStdKey) {
							GetWitcherPlayer().OnPotionDrinkKeyboardsInput(GetEquipmentSlot(FIRST_NEW_POTION_SLOT, i));
						}
					} else {
						thePlayer.DisplayActionDisallowedHudMessage(EIAB_QuickSlots);
					}
				}
			}
		}
	}

	// Returns TRUE if the specified radial slot name is for signs.
	private function IsSignSlot(slotName : string) : bool {
		return (slotName == "Yrden") || (slotName == "Quen") || (slotName == "Igni")
				|| (slotName == "Axii") || (slotName == "Aard");
	}

	// Returns TRUE if the specified radial slot name is for bombs.
	private function IsBombSlot(slotName : string) : bool {
		return (slotName == "Slot1") || (slotName == "Slot2") || (slotName == "Slot5") || (slotName == "Slot6");
	}

	// The enumeration values for quick slots don't have consecutive values.
	// This should be the only function that "knows" the order of EEquipmentSlots elements. Except the next one :)
	private function GetEquipmentSlot(startSlot : EEquipmentSlots, offset : int) : EEquipmentSlots {
		if (startSlot == FIRST_POTION_SLOT) {
			switch (offset) {
				case 0: return EES_Potion1;
				case 1: return EES_Potion2;
				case 2: return EES_Potion3;
				case 3: return EES_Potion4;
				case 4: return EES_Potion5;
				case 5: return EES_Potion6;
				case 6: return EES_Potion7;
				case 7: return EES_Potion8;
			}
		} else if (((startSlot == FIRST_NEW_POTION_SLOT) && (offset >= 0) && (offset < 4))
				|| ((startSlot == FIRST_RESERVED_POTION_SLOT) && (offset >= 0) && (offset < 8))
				|| ((startSlot == FIRST_RESERVED_PETARD_SLOT) && (offset >= 0) && (offset < 4))) {
			return startSlot + offset;
		} else if (startSlot == FIRST_PETARD_SLOT) {
			switch (offset) {
				case 0: return EES_Petard1;
				case 1: return EES_Petard2;
				case 2: return EES_Petard3;
				case 3: return EES_Petard4;
			}
		}

		return EES_InvalidSlot;
	}

	// Useful when iterating all potion & bomb quick slots.
	private function GetPotionBombEquipmentSlot(offset : int, optional reserved : bool) : EEquipmentSlots {
		if ((offset >= 0) && (offset < 12)) {
			if (reserved) {
				return EES_ReservedPotion1 + offset;
			} else if (offset < 8) {
				return GetEquipmentSlot(FIRST_POTION_SLOT, offset);
			} else {
				return GetEquipmentSlot(FIRST_PETARD_SLOT, offset - 8);
			}
		}
		return EES_InvalidSlot;
	}

	// Returns the index of a sign radial slot.
	private function GetRadialSlotIndexForSign(sign : ESignType) : int {
		switch (sign) {
			case ST_Yrden:	return 1;
			case ST_Quen: 	return 2;
			case ST_Igni: 	return 3;
			case ST_Axii: 	return 4;
			case ST_Aard: 	return 5;
		}

		return -1;
	}

	// Returns the index of the radial slot for specified equipment slot.
	private function GetRadialSlotIndexForEquipmentSlot(equipmentSlot : EEquipmentSlots) : int {
		switch (equipmentSlot) {
			case EES_RangedWeapon:
				return 6;
			case EES_Petard1:
			case EES_ReservedPetard1:
				return 7;
			case EES_Petard2:
			case EES_ReservedPetard2:
				return 8;
			case EES_Petard3:
			case EES_ReservedPetard3:
				return 9;
			case EES_Petard4:
			case EES_ReservedPetard4:
				return 10;
			case EES_Quickslot1:
			case EES_Quickslot2:
				return 11;
		}

		return -1;
	}

	// Radial slot name to slot index.
	// Must be same as SlotsNames array from HudModuleRadialMenu ActionScript class.
	private function GetRadialSlotIndexForSlotName(slotName : string) : int {
		switch (slotName) {
			case "Yrden": 		return 1;
			case "Quen":		return 2;
			case "Igni":		return 3;
			case "Axii":		return 4;
			case "Aard":		return 5;
			case "Crossbow":	return 6;
			case "Slot1":		return 7;
			case "Slot2":		return 8;
			case "Slot5":		return 9;
			case "Slot6":		return 10;
			case "Slot3":
			case "Slot4":		return 11;
			default:
				return -1;
		}
	}

	private function IsSignRadialSlotIndex(idx : int) : bool {
		return (idx >= 1) && (idx <= 5);
	}

	private function IsBombRadialSlotIndex(idx : int) : bool {
		return (idx >= 7) && (idx <= 10);
	}
}
