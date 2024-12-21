class WmkQuickSlotsConfig
{
	//
	// THIS FILE IS NOT USED IF YOU INSTALLED MOD'S MENU COMPONENT!
	//
	// If you installed mod's menu component then read this file only to get more details about available
	// options, but change the settings from OPTIONS => MODS => MORE QUICK SLOTS menu, because any change made here
	// will be ignored. The settings are stored into user.settings file from My Documents\The Witcher 3 folder. Open it
	// with a text editor and search for MoreQuickSlots and QuickInventory strings. There should be 5 sections,
	// one for common options, one for keyboard only options, one for gamepad only options, one for Quick Inventory
	// and one for additional settings.
	//
	// Set IGNORE_USER_SETTINGS_FILE to true if you want to ignore the user.settings file and to always use the
	// values from this file, even if you installed the mod's menu component. This means that any change made using
	// the menu will be ignored.
	//

	default IGNORE_USER_SETTINGS_FILE = false;

	// -----------------------------------------------------------------------------------------------------------------
	// By default the game centers the mouse cursor on screen when the Quick Access menu is opened. This
	// results in selection of the slot from bottom right, but slightly moving the mouse cursor will move the
	// selection to a slot from the opposite side. This is quite stupid.
	//
	// Valid values for this option:
	//
	//     QASI_Default      - no change, the default behavior
	//     QASI_EquippedSign - start with the slot for the equipped sign selected
	//     QASI_EquippedItem - start with the slot for the equipped item selected
	//     QASI_LastSelected - start with the last selected slot
	//
	// Also you can use QASI_Yrden, QASI_Quen, QASI_Igni, QASI_Axii, QASI_Aard, QASI_Crossbow, QASI_Petard1,
	// QASI_Petard2, QASI_Petard3, QASI_Petard4 or QASI_Pocket to force the selection of a specific slot
	// when the Quick Access menu is opened.
	//
	// For gamepad by default the game saves your last selection, so QASI_LastSelected is the same
	// as QASI_Default. But some may like QASI_EquippedItem or QASI_EquippedSign.
	// -----------------------------------------------------------------------------------------------------------------

	default KB_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN = QASI_EquippedItem;
	default GAMEPAD_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN = QASI_Default;

	// -----------------------------------------------------------------------------------------------------------------
	// In game version 1.12 (HoS) the player had to manually confirm the selection in the Quick Access menu to
	// equip an item. In game version 1.21+ (B&W) the last selected item is automatically equipped when
	// the Quick Access menu is closed, except when the ESC key or B gamepad button is pressed. Probably for gamepad
	// users this is a nice feature, but the ones using the keyboard & mouse may dislike it.
	//
	// Valid values for this option:
	//
	//     QAEI_Default        - the default behavior, the mod won't change anything
	//     QAEI_WhenGamePaused - equip the selected item on close only when the Quick Access menu is opened by
	//                           quick pressing the trigger key, i.e. when the game is paused
	//     QAEI_WhenGameSlowed - equip the selected item on close only when the Quick Access menu is opened in alternate
	//                           mode, i.e. the trigger button is kept pressed and the game is not paused, only the
	//                           timescale is changed
	//     QAEI_Manual  -        the item must be equipped manually, like in game version 1.12 or earlier, using
	//                           mouse click, E key or A gamepad button
	//
	// I recommend QAEI_WhenGameSlowed or QAEI_Manual for players using the mouse & keyboard. For players
	// using gamepad probably the default is the best.
	// -----------------------------------------------------------------------------------------------------------------

	default KB_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE = QAEI_WhenGameSlowed;
	default GAMEPAD_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE = QAEI_Default;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies the maximum number of items that can be equipped in the quick slots. Valid values:
	//
	//      MAXC_Vanilla         - 4 items, in the standard slots; this means the new quick slots are disabled;
	//                             the new quick slots won't be visible on HUD and in Quick Access menu, but will still
	//                             be visible in the Inventory menu
	//      MAXC_OneSet          - 8 items, 4 in the standard slots, 4 in the new quick slots
	//      MAXC_TwoSetsFixedStd - 12 items in two sets, but the first 4 items from standard slots are the same
	//      MAXC_TwoSets         - 16 items in two different sets
	//
	// Having 16 items assigned to quick slots may be too much for some, especially since Quick Inventory module
	// was added, because now all the potions can be accessed easily.
	// -----------------------------------------------------------------------------------------------------------------

	default MAX_EQUIPPED_CONSUMABLES = MAXC_TwoSets;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies the maximum number of bombs that can be equipped. Valid values:
	//
	//      MAXB_OneSet          - 4 bombs
	//      MAXB_TwoSetsFixedStd - 6 bombs in two sets, but the first 2 bombs are the same
	//      MAXB_TwoSets         - 8 bombs in two different sets
	//
	// Unlike the MAX_EQUIPPED_CONSUMABLES, this setting is somehow useless. The game has 8 bombs and having all
	// of them accessible from Quick Access menu is a nice feature. And the Quick Inventory doesn't help in this case.
	// -----------------------------------------------------------------------------------------------------------------

	default MAX_EQUIPPED_BOMBS = MAXB_TwoSets;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies if the new quick slots for consumables should be visible on HUD, next to the default ones.
	//
	// Valid values for this setting:
	//
	//      SNQS_Never - the new slots are never visible on HUD
	//      SNQS_OnlyWhenNotEmpty - show the new slots only when at least one has an item assigned
	//      SNQS_Always - show the new slots on HUD whenver the standard ones are visible
	//
	// Note that the slots are always visible when the Quick Access menu is opened.
	//
	// This setting is ignored for gamepad users, because the additional quick slots are not visible on HUD
	// when the Quick Access menu is not opened.
	// -----------------------------------------------------------------------------------------------------------------

	default SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD = SNQS_OnlyWhenNotEmpty;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies how to use the new consumables quick slots the keyboard. Valid options are:
	//
	//     PQSK_HoldStdKey - hold a standard key
	//     PQSK_QuickDoubleTapStdKey - quickly tap a standard key
	//     PQSK_BindNewKeys - bind new keys
	//
	// If set to PQSK_HoldStdKey or PQSK_QuickDoubleTapStdKey then the standard keys for quick slots (R, F, T and Y
	// by default) are also be used for the new potion quick slots. In this case you don't have to modify
	// the input.settings file.
	//
	// If set to PQSK_HoldStdKey then you must hold the key for a short interval to use the consumable from a
	// new slot. If set to PQSK_QuickDoubleTapStdKey then double tapping the key in a very short interval will use
	// the potion from a new slot.
	//
	// The PQSK_QuickDoubleTapStdKey option has one big disadvantage: if you don't double tap the key fast enough then
	// you'll use the potion from default quick slot twice instead using the potion from the new quick slot. So
	// I don't recommend it, but some may like this option.
	//
	// The best option is PQSK_BindNewKeys, but for this you must edit the input.settings file to bind 4 new keys
	// for DrinkPotion5, DrinkPotion6, DrinkPotion7 and DrinkPotion8 actions. Good options are F1, F2, F3
	// and F4 keys, except if they are already used by other mod.
	//
	// For more details see the README.txt file.
	// -----------------------------------------------------------------------------------------------------------------

	default NEW_POTION_QUICK_SLOTS_KEYS = PQSK_HoldStdKey;

	// -----------------------------------------------------------------------------------------------------------------
	// The interval in seconds if the existing quick slot keys are also used for the new quick slots.
	// -----------------------------------------------------------------------------------------------------------------

	default HOLD_KEY_INTERVAL_SECONDS = 0.3;
	default DOUBLE_TAP_KEY_INTERVAL_SECONDS = 0.5;

	// -----------------------------------------------------------------------------------------------------------------
	// By default when using a gamepad you can assign up to 4 potions to quick slots. With this mod you can
	// assign 4 more potions (as a second set), but this should still not be enough.
	//
	// If this option is true then all 8 quick slots will be visible when using the gamepad and the Quick Access menu
	// is opened, so up to 16 items can be assigned to quick slots. Like using a keyboard and mouse. You can select
	// a quick slot using d-pad buttons (see bellow) and use the consumable with RB button.
	//
	// Note that no changes are made when the Quick Access menu is not opened.
	//
	// The second option specifies if the first quick slot should be always selected when the Quick Access menu
	// is opened. If false the selected slot will be the same as the last time when the menu was opened.
	//
	// The third option specifies if d-pad buttons should be used for navigation. If false then the left or right
	// stick will be used (the one that is not used for selecting the slot from radial menu).
	// -----------------------------------------------------------------------------------------------------------------

	default SHOW_ALL_POTION_SLOTS_WHEN_USING_GAMEPAD = true;
	default SELECT_FIRST_POTION_SLOT_ON_QUICK_ACCESS_OPEN_WHEN_USING_GAMEPAD = false;
	default USE_DPAD_FOR_POTION_SLOTS_NAVIGATION = true;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies how much you must push / pull the stick used for selecting a slot from Quick Access menu.
	// This is the left stick if the "Alternative Quick Access Menu control mode" option from Control Settings menu
	// is enabled, otherwise is the right stick.
	//
	// In vanilla game the radial menu has only 8 slots. With this mod it has 11 slots. This means that the distance
	// between slots is now smaller and a slight change in stick's position may result in selecting another slot
	// than the one you want. And usually this slight change appears when you release the stick. Increasing the minimum
	// required magnitude will prevent such mistakes.
	//
	// Valid values are between 0.0 and 1.0.
	//
	// Since game version 1.21, when the Quick Access menu was redesigned, the default value is 0.5. Before,
	// when the Quick Access menu had 12 slots (only 10 being visible) the default value was 0.75.
	// -----------------------------------------------------------------------------------------------------------------

	default MIN_STICK_MAGNITUDE = 0.8;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies if the first consumables & bombs set will be restored back when the Quick Access menu
	// or inventory menu is closed.
	//
	// If true then during exploration or combat you'll always know what potions and bombs are equipped, because
	// the first set will always be the active one. If false then you may try to consume a potion from a set while the
	// other one remained active since radial or inventory menu was opened.
	// -----------------------------------------------------------------------------------------------------------------

	default RESTORE_FIRST_SET_ON_MENU_CLOSE = true;

	// -----------------------------------------------------------------------------------------------------------------
	// The bottom panel with keys & buttons help from Quick Access menu is now always aligned with the slot for the
	// currently equipped item (the last one). This was required because otherwise the panel would overlap with the new
	// quick slots for cosumables on some screen resolutions. Using this settings you may adjust a little bit the
	// Y coordinate: a positive value will move the panel down, while a negative value will move the panel up.
	//
	// The value is in pixels, but only for 1920x1080 screen resolution.
	// -----------------------------------------------------------------------------------------------------------------

	default QUICK_ACCESS_INPUT_FEEDBACK_PANEL_Y_OFFSET = 50;

	// -----------------------------------------------------------------------------------------------------------------
	// The new 4 additional quick slots for consumables are vertically aligned on HUD with the default quick slots,
	// but are moved to right with 290 units (which means 265 pixels for small HUD and 311 pixels for large
	// HUD for 1920x1080 resolution). This may be too much or may not be enough, depending on screen resolution, the
	// language, font size and the names of the items equipped in the default slots.
	//
	// Using this setting you may move the additional slots to left (if negative) or right (if possitive).
	//
	// For example setting this to -290 will move the new slots over the default one.
	// -----------------------------------------------------------------------------------------------------------------

	default NEW_POTION_SLOTS_X_OFFSET_ON_HUD = 0;

	// -----------------------------------------------------------------------------------------------------------------
	// The opacity for a black filled circle inside Quick Access menu.
	//
	// The vanilla game doesn't have this background image. Valid values are between 0 (fully transparent = vanilla)
	// and 100 (fully opaque).
	// -----------------------------------------------------------------------------------------------------------------

	default INNER_BACKGROUND_OPACITY = 66;

	// -----------------------------------------------------------------------------------------------------------------
	// By default the Wolf Head, minimap and data about currently tracked quest are removed from HUD when
	// the Quick Access menu is opened. Using these settings you can change this.
	// -----------------------------------------------------------------------------------------------------------------

	default SHOW_WOLFHEAD_INSIDE_QUICK_ACCESS_MENU = false;
	default SHOW_MINIMAP_INSIDE_QUICK_ACCESS_MENU = false;
	default SHOW_TRACKED_QUEST_INSIDE_QUICK_ACCESS_MENU = false;

	// -----------------------------------------------------------------------------------------------------------------
	// Using these you can hide the herb or enemy pins from minimap.
	// -----------------------------------------------------------------------------------------------------------------

	default HIDE_HERB_PINS_FROM_MINIMAP = false;
	default HIDE_ENEMY_PINS_FROM_MINIMAP = false;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies if items ca be repaired and oils can be applied while the player is in combat.
	//
	// Note that some restrictions existed before patch 1.10, but they were removed. If disabled the options affect
	// both game's main inventory menu and the new Quick Inventory menu.
	// -----------------------------------------------------------------------------------------------------------------

	default CAN_APPLY_OILS_WHILE_IN_COMBAT = true;
	default CAN_REPAIR_ITEMS_WHILE_IN_COMBAT = true;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies the actions for some input keys or buttons while the Quick Inventory is opened. Valid options are:
	//
	//      IACT_Nothing - do nothing
	//      IACT_Back - return back to Quick Access menu if opened, otherwise return back to game
	//      IACT_BackToGame - return back to game, even if the Quick Inventory was opened from Quick Access menu
	//      IACT_QuickAccessMenu - (re)open Quick Access menu
	// -----------------------------------------------------------------------------------------------------------------

	default QUICK_INVENTORY_ESC_ACTION = IACT_BackToGame;
	default QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION = IACT_Back;
	default QUICK_INVENTORY_RIGHT_TRIGGER_ACTION = IACT_BackToGame;
	default QUICK_INVENTORY_RIGHT_BUMPER_ACTION = IACT_Back;

	// -----------------------------------------------------------------------------------------------------------------
	// Specifies how equipped items appear in Quick Inventory. Valid options are:
	//
	//      ISEI_Hide - hide the equipped items
	//      ISEI_ShowDimmed - show the equipped items, but dimmed (only 30%), like read books
	//      ISEI_Show - show the equipped items
	// -----------------------------------------------------------------------------------------------------------------

	default QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS = ISEI_ShowDimmed;

	// -----------------------------------------------------------------------------------------------------------------
	// Sorting options for potions and oils. The valid options are:
	//
	//      IISO_ByName - sort the items alphabetically
	//      IISO_ByBaseName - sort the items by their base names
	//      IISO_ByQualityAndName - sort the items first by their quality, then by their name
	//      IISO_ByQualityAndBaseName - sort the items first by their quality, then by their base name
	//
	// The base name for an item is the name used for level 1 version. For example the base name for Enhanced Cat
	// potion is Cat, while the base name for Superior Black Blood is Black Blood. This means that Superior Black Blood
	// potion will be listed before Enhanced Cat potion because Black Blood < Cat.
	//
	// Note that decoctions are always sorted alphabetically because all of them have same quality.
	// -----------------------------------------------------------------------------------------------------------------

	default QUICK_INVENTORY_POTIONS_SORT_ORDER = IISO_ByBaseName;
	default QUICK_INVENTORY_OILS_SORT_ORDER = IISO_ByBaseName;

	// -----------------------------------------------------------------------------------------------------------------
	// If true then the books will be sorted alphabetically. If false (the recommended value) the books will
	// be sorted by their inventory ID, which means that the new ones will be listed first. Note that unread books or
	// the ones with *new flag will always be listed first.
	// -----------------------------------------------------------------------------------------------------------------

	default QUICK_INVENTORY_SORT_BOOKS_BY_NAME = false;

	// -----------------------------------------------------------------------------------------------------------------
	// The first option specifies if the Quick Inventory will contain a list with the latest received items.
	//
	// The second option specifies if the mod shows for each newest item the real time (not game time) elapsed since it
	// was added to player's inventory.
	//
	// The third option specifies if the list with latest items is saved between two gaming sessions. If false then
	// only the latest items received since the game was loaded will be displayed.
	// -----------------------------------------------------------------------------------------------------------------

	default QUICK_INVENTORY_SHOW_NEWEST_ITEMS = true;
	default QUICK_INVENTORY_SHOW_ELAPSED_TIME_FOR_NEWEST_ITEMS = true;
	default QUICK_INVENTORY_RESET_NEWEST_ITEMS_ON_LOAD = false;

	// -----------------------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------------------
	// DON'T CHANGE ANYTHING BELOW THIS LINE
	// -----------------------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------------------

	private var IGNORE_USER_SETTINGS_FILE  : bool;

	public var KB_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN : EWmkSelectedItemOnRadialOpen;
	public var GAMEPAD_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN : EWmkSelectedItemOnRadialOpen;
	public var KB_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE : EWmkEquipItemOnRadialClose;
	public var GAMEPAD_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE : EWmkEquipItemOnRadialClose;
	public var MAX_EQUIPPED_CONSUMABLES : EWmkMaxEquippedConsumables;
	public var MAX_EQUIPPED_BOMBS : EWmkMaxEquippedBombs;
	public var SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD : EWmkShowNewQuickSlotsOnHud;
	public var NEW_POTION_QUICK_SLOTS_KEYS : EWmkPotionQuickSlotKey;
	public var HOLD_KEY_INTERVAL_SECONDS : float;
	public var DOUBLE_TAP_KEY_INTERVAL_SECONDS : float;
	public var SHOW_ALL_POTION_SLOTS_WHEN_USING_GAMEPAD : bool;
	public var SELECT_FIRST_POTION_SLOT_ON_QUICK_ACCESS_OPEN_WHEN_USING_GAMEPAD : bool;
	public var USE_DPAD_FOR_POTION_SLOTS_NAVIGATION : bool;
	public var MIN_STICK_MAGNITUDE : float;
	public var RESTORE_FIRST_SET_ON_MENU_CLOSE : bool;
	public var QUICK_ACCESS_INPUT_FEEDBACK_PANEL_Y_OFFSET : int;
	public var NEW_POTION_SLOTS_X_OFFSET_ON_HUD : int;
	public var INNER_BACKGROUND_OPACITY : int;

	public var SHOW_WOLFHEAD_INSIDE_QUICK_ACCESS_MENU : bool;
	public var SHOW_MINIMAP_INSIDE_QUICK_ACCESS_MENU : bool;
	public var SHOW_TRACKED_QUEST_INSIDE_QUICK_ACCESS_MENU : bool;
	public var HIDE_HERB_PINS_FROM_MINIMAP : bool;
	public var HIDE_ENEMY_PINS_FROM_MINIMAP : bool;
	public var CAN_APPLY_OILS_WHILE_IN_COMBAT : bool;
	public var CAN_REPAIR_ITEMS_WHILE_IN_COMBAT : bool;

	public var QUICK_INVENTORY_ESC_ACTION : EWmkInventoryInputAction;
	public var QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION : EWmkInventoryInputAction;
	public var QUICK_INVENTORY_RIGHT_TRIGGER_ACTION : EWmkInventoryInputAction;
	public var QUICK_INVENTORY_RIGHT_BUMPER_ACTION : EWmkInventoryInputAction;

	public var QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS : EWmkInventoryShowEquippedItems;

	public var QUICK_INVENTORY_POTIONS_SORT_ORDER : EWmkInventoryItemsSortOrder;
	public var QUICK_INVENTORY_OILS_SORT_ORDER : EWmkInventoryItemsSortOrder;
	public var QUICK_INVENTORY_SORT_BOOKS_BY_NAME : bool;

	public var QUICK_INVENTORY_SHOW_NEWEST_ITEMS : bool;
	public var QUICK_INVENTORY_SHOW_ELAPSED_TIME_FOR_NEWEST_ITEMS : bool;
	public var QUICK_INVENTORY_RESET_NEWEST_ITEMS_ON_LOAD : bool;

	private var m_configWrapper : CInGameConfigWrapper;

	function SyncConfigVars() {
		m_configWrapper = theGame.GetInGameConfigWrapper();

		// COMMON

		MAX_EQUIPPED_CONSUMABLES = SyncEnum('MoreQuickSlots', 'Virtual_MaxEquippedConsumables', MAXC_TwoSets, MAX_EQUIPPED_CONSUMABLES);
		MAX_EQUIPPED_BOMBS = SyncEnum('MoreQuickSlots', 'Virtual_MaxEquippedBombs', MAXB_TwoSets, MAX_EQUIPPED_BOMBS);

		SyncBool('MoreQuickSlots', 'RestoreFirstSetOnMenuClose', RESTORE_FIRST_SET_ON_MENU_CLOSE);
		SyncInt('MoreQuickSlots', 'QuickAccessInputFeedbackPanelYOffset', -250, 150, QUICK_ACCESS_INPUT_FEEDBACK_PANEL_Y_OFFSET);
		SyncInt('MoreQuickSlots', 'NewPotionSlotsXOffsetOnHUD', -100, 300, NEW_POTION_SLOTS_X_OFFSET_ON_HUD);
		SyncInt('MoreQuickSlots', 'QuickAccessInnerBackgroundOpacity', 0, 100, INNER_BACKGROUND_OPACITY);

		// QUICK INVENTORY

		QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS = SyncEnum('QuickInventory', 'Virtual_ShowEquippedItems',
				ISEI_Show, QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS);

		QUICK_INVENTORY_POTIONS_SORT_ORDER = SyncEnum('QuickInventory', 'Virtual_PotionsSortOrder',
				IISO_ByQualityAndBaseName, QUICK_INVENTORY_POTIONS_SORT_ORDER);
		QUICK_INVENTORY_OILS_SORT_ORDER = SyncEnum('QuickInventory', 'Virtual_OilsSortOrder',
				IISO_ByQualityAndBaseName, QUICK_INVENTORY_OILS_SORT_ORDER);

		SyncBool('QuickInventory', 'SortBooksByName', QUICK_INVENTORY_SORT_BOOKS_BY_NAME);
		SyncBool('QuickInventory', 'ShowNewestItems', QUICK_INVENTORY_SHOW_NEWEST_ITEMS);
		SyncBool('QuickInventory', 'ShowElapsedTimeForNewestItems', QUICK_INVENTORY_SHOW_ELAPSED_TIME_FOR_NEWEST_ITEMS);
		SyncBool('QuickInventory', 'ResetNewestItemsOnLoad', QUICK_INVENTORY_RESET_NEWEST_ITEMS_ON_LOAD);

		// KEYBOARD

		KB_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN = SyncEnum('MoreQuickSlotsKeyboard', 'Virtual_SelectedItemOnQuickAccessOpen',
				QASI_Pocket, KB_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN);
		KB_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE = SyncEnum('MoreQuickSlotsKeyboard', 'Virtual_EquipSelectedItemOnQuickAccessClose',
				QAEI_Manual, KB_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE);
		SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD = SyncEnum('MoreQuickSlotsKeyboard', 'Virtual_ShowNewPotionQuickSlotsOnHud',
				SNQS_Always, SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD);
		NEW_POTION_QUICK_SLOTS_KEYS = SyncEnum('MoreQuickSlotsKeyboard', 'Virtual_NewPotionQuickSlotsKeys',
				PQSK_BindNewKeys, NEW_POTION_QUICK_SLOTS_KEYS);

		SyncFloat('MoreQuickSlotsKeyboard', 'HoldKeyIntervalSeconds', 0.1, 0.9, HOLD_KEY_INTERVAL_SECONDS);
		SyncFloat('MoreQuickSlotsKeyboard', 'DoubleTapKeyIntervalSeconds', 0.1, 0.9, DOUBLE_TAP_KEY_INTERVAL_SECONDS);

		QUICK_INVENTORY_ESC_ACTION = SyncEnum('MoreQuickSlotsKeyboard', 'Virtual_QuickInventoryEscAction',
				IACT_QuickAccessMenu, QUICK_INVENTORY_ESC_ACTION);
		QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION = SyncEnum('MoreQuickSlotsKeyboard', 'Virtual_QuickInventoryRightMouseButtonAction',
				IACT_QuickAccessMenu, QUICK_INVENTORY_RIGHT_MOUSE_BUTTON_ACTION);

		// GAMEPAD

		GAMEPAD_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN  = SyncEnum('MoreQuickSlotsGamepad', 'Virtual_SelectedItemOnQuickAccessOpen',
				QASI_Pocket, GAMEPAD_SELECTED_ITEM_ON_QUICK_ACCESS_OPEN);
		GAMEPAD_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE = SyncEnum('MoreQuickSlotsGamepad', 'Virtual_EquipSelectedItemOnQuickAccessClose',
				QAEI_Manual, GAMEPAD_EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE);

		SyncBool('MoreQuickSlotsGamepad', 'ShowAllPotionSlots', SHOW_ALL_POTION_SLOTS_WHEN_USING_GAMEPAD);
		SyncBool('MoreQuickSlotsGamepad', 'SelectFirstPotionSlotOnQuickAccessOpen', SELECT_FIRST_POTION_SLOT_ON_QUICK_ACCESS_OPEN_WHEN_USING_GAMEPAD);
		SyncBool('MoreQuickSlotsGamepad', 'UseDPadForPotionSlotsNavigation', USE_DPAD_FOR_POTION_SLOTS_NAVIGATION);
		SyncFloat('MoreQuickSlotsGamepad', 'MinStickMagnitude', 0.25, 0.95, MIN_STICK_MAGNITUDE);

		QUICK_INVENTORY_RIGHT_TRIGGER_ACTION = SyncEnum('MoreQuickSlotsGamepad', 'Virtual_QuickInventoryRightTriggerAction',
				IACT_QuickAccessMenu, QUICK_INVENTORY_RIGHT_TRIGGER_ACTION);
		QUICK_INVENTORY_RIGHT_BUMPER_ACTION = SyncEnum('MoreQuickSlotsGamepad', 'Virtual_QuickInventoryRightBumperAction',
				IACT_QuickAccessMenu, QUICK_INVENTORY_RIGHT_BUMPER_ACTION);

		// EXTRA

		SyncBool('MoreQuickSlotsExtra', 'ShowWolfHeadInsideQuickAccessMenu', SHOW_WOLFHEAD_INSIDE_QUICK_ACCESS_MENU);
		SyncBool('MoreQuickSlotsExtra', 'ShowMinimapInsideQuickAccessMenu', SHOW_MINIMAP_INSIDE_QUICK_ACCESS_MENU);
		SyncBool('MoreQuickSlotsExtra', 'ShowTrackedQuestInsideQuickAccessMenu', SHOW_TRACKED_QUEST_INSIDE_QUICK_ACCESS_MENU);
		SyncBool('MoreQuickSlotsExtra', 'HideHerbPinsFromMinimap', HIDE_HERB_PINS_FROM_MINIMAP);
		SyncBool('MoreQuickSlotsExtra', 'HideEnemyPinsFromMinimap', HIDE_ENEMY_PINS_FROM_MINIMAP);
		SyncBool('MoreQuickSlotsExtra', 'CanApplyOilsWhileInCombat', CAN_APPLY_OILS_WHILE_IN_COMBAT);
		SyncBool('MoreQuickSlotsExtra', 'CanRepairItemsWhileInCombat', CAN_REPAIR_ITEMS_WHILE_IN_COMBAT);
	}

	private function SyncBool(groupName : name, varName : name, out cfgValue : bool) {
		var value : string;

		if (!IGNORE_USER_SETTINGS_FILE) {
			value = m_configWrapper.GetVarValue(groupName, varName);
		}

		if ((value != "true") && (value != "false")) {
			m_configWrapper.SetVarValue(groupName, varName, cfgValue);
		} else {
			cfgValue = value == "true";
		}
	}

	private function SyncInt(groupName : name, varName : name, min : int, max : int, out cfgValue : int) {
		var value : int;

		if (!IGNORE_USER_SETTINGS_FILE) {
			value = StringToInt(m_configWrapper.GetVarValue(groupName, varName), (min - 1));
		} else {
			value = min - 1;
		}

		if ((value < min) || (value > max)) {
			m_configWrapper.SetVarValue(groupName, varName, cfgValue);
		} else {
			cfgValue = value;
		}
	}

	private function SyncEnum(groupName : name, varName : name, maxValue : int, defaultValue : int) : int {
		var value : int;

		if (!IGNORE_USER_SETTINGS_FILE) {
			value = StringToInt(m_configWrapper.GetVarValue(groupName, varName), -1);
		} else {
			value = -1;
		}

		if ((value < 0) || (value > maxValue)) {
			m_configWrapper.SetVarValue(groupName, varName, defaultValue);
			return defaultValue;
		} else {
			return value;
		}
	}

	// This is not too smart. Float values should be stored as integers, but is a game after all...
	private function SyncFloat(groupName : name, varName : name, min : float, max : float, out cfgValue : float) {
		var value : float;

		if (!IGNORE_USER_SETTINGS_FILE) {
			value = StringToFloat(m_configWrapper.GetVarValue(groupName, varName), (min - 1.0));
		} else {
			value = min - 1.0;
		}

		if ((value < min) || (value > max)) {
			m_configWrapper.SetVarValue(groupName, varName, cfgValue);
		} else {
			cfgValue = value;
		}
	}
}
