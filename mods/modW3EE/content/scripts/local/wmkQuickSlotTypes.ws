// Possible options for SELECTED_ITEM_ON_QUICK_ACCESS_OPEN setting.
enum EWmkSelectedItemOnRadialOpen
{
	QASI_Default,
	QASI_EquippedSign,
	QASI_EquippedItem,
	QASI_LastSelected,
	QASI_Yrden,
	QASI_Quen,
	QASI_Igni,
	QASI_Axii,
	QASI_Aard,
	QASI_Crossbow,
	QASI_Petard1,
	QASI_Petard2,
	QASI_Petard3,
	QASI_Petard4,
	QASI_Pocket
}

// Possible options for EQUIP_SELECTED_ITEM_ON_QUICK_ACCESS_CLOSE setting.
enum EWmkEquipItemOnRadialClose
{
	QAEI_Default,
	QAEI_WhenGamePaused,
	QAEI_WhenGameSlowed,
	QAEI_Manual
}

// Possible options for SHOW_NEW_POTION_QUICK_SLOTS_ON_HUD setting.
enum EWmkShowNewQuickSlotsOnHud
{
	SNQS_Never,
	SNQS_OnlyWhenNotEmpty,
	SNQS_Always
}

enum EWmkMaxEquippedConsumables
{
	MAXC_Vanilla,
	MAXC_OneSet,
	MAXC_TwoSetsFixedStd,
	MAXC_TwoSets
}

enum EWmkMaxEquippedBombs
{
	MAXB_OneSet,
	MAXB_TwoSetsFixedStd,
	MAXB_TwoSets
}

// Possible options for POTION_QUICKSLOT_KEYS setting.
enum EWmkPotionQuickSlotKey
{
	PQSK_HoldStdKey,
	PQSK_QuickDoubleTapStdKey,
	PQSK_BindNewKeys
}

// Used to avoid calling functions from flash module when the item from a new quick slot was not changed.
struct SWmkHudItemInfo
{
	var m_item		: SItemUniqueId;
	var m_ammo 		: int;
	var m_maxAmmo	: int;
}

enum EWmkInventoryModule {
	IMOD_Invalid = -1,
	IMOD_PlayerInventory,
	IMOD_PaperDoll,
	IMOD_NewestItems
}

enum EWmkInventoryTab {
	ITAB_Invalid = -1,
	ITAB_PotionsOilsAndTools,
	ITAB_FoodAndDrinks,
	ITAB_Books
}

enum EWmkItemType {
	ITEM_Unknown,
	ITEM_Oil,
	ITEM_RepairKit,
	ITEM_Potion, // no food, no decoction
	ITEM_Decoction,
	ITEM_FoodOrDrink,
	ITEM_Book
}

// What to do when the Quick Inventory is closed.
enum EWmkInventoryHideAction {
	QIHA_Default,
	QIHA_HideRadialMenu,
	QIHA_ShowRadialMenu
}

// What to do when the user presses a key or a gamepad button.
enum EWmkInventoryInputAction {
	IACT_Nothing,
	IACT_Back,
	IACT_BackToGame,
	IACT_QuickAccessMenu
}

enum EWmkInputFeedbackUpdateStatus {
	IFUS_Default,
	IFUS_Disabled,
	IFUS_UpdateNextTick
}

// Possible options for QUICK_INVENTORY_SHOW_EQUIPPED_ITEMS setting.
enum EWmkInventoryShowEquippedItems {
	ISEI_Hide,
	ISEI_ShowDimmed,
	ISEI_Show
}

// Sorting options, but only for potions and oils.
enum EWmkInventoryItemsSortOrder {
	IISO_Unspecified = -1,
	IISO_ByName,
	IISO_ByBaseName,
	IISO_ByQualityAndName,
	IISO_ByQualityAndBaseName
}

// Item's ID and all other properties that affect how the item is displayed and may change while the ID remains the same.
struct SWmkPaperDollItemInfo {
	var m_id : int;

	var m_iconPath : string;
	var m_itemColor: string;

	var m_enchanted : bool;
	var m_socketsCount : int;
	var m_socketsUsedCount : int;
	var m_isOilApplied : bool;
	var m_durability : float;
	var m_needRepair : bool;

	var m_quantity : int;
	var m_charges : string;
}

class WmkQuickInventorySaveData {
	var m_itemsData : array<SWmkInventoryItemSaveData>;
	var m_lastReceivedItems : array<SWmkReceivedItemSaveData>;
}

struct SWmkInventoryItemSaveData {
	var m_item : SItemUniqueId;
	var m_tab : EWmkInventoryTab;
	var m_gridSection : int;
	var m_type : EWmkItemType;
	var m_gridPosition : int;
}

struct SWmkReceivedItemSaveData {
	var m_item : SItemUniqueId;
	var m_timestamp : int;
}
