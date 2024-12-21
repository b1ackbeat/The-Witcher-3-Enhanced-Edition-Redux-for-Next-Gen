enum WmkAreaPositionType
{
	WmkAreaPos_Unknown,		// no attempt to obtain the area & coordinates
	WmkAreaPos_Invalid,		// failed to obtain the area & coordinates
	WmkAreaPos_Valid		// valid area & coordinates
}

// The data about a quest map pin.
struct WmkQuestMapPin
{
	var tag : name;
	var questArea : EAreaName;
	var questObjective : CJournalQuestObjective;
	var position : Vector;
	var areaPosType : WmkAreaPositionType;
	var titleStringId : int;
	var descriptionStringId : int;
	var questLevel  : int;
}

enum WmkQuestDifficulty
{
	WmkQD_Unknown,
	WmkQD_Low,
	WmkQD_Normal,
	WmkQD_High,
	WmkQD_Deadly
}

struct WmkMerchantMapPin
{
	var entityIdTag : IdTag; // this should be named persistenceId or something like this
	var uniqueTag : name; // merchant's unique tag; is set to 'WmkNone' if the merchant doesn't have a unique tag
	var area : EAreaName;
	var pin : SCommonMapPinInstance;
	var entityTags : array<name>; // all merchant's tags, used only for debugging
}

// For data to be saved into save file(s).
class WmkMapMenuData
{
	var merchantPins : array<WmkMerchantMapPin>;

	// OBSOLETE, not used anymore
	var removedMerchantPins : array<WmkMerchantMapPin>;
	var replacedMerchantPins : array<WmkMerchantMapPin>;

	// Used only for debugging
	var deletedMerchantPins : array<WmkMerchantMapPin>;
	var removedSameUniqueTagMerchantPins : array<WmkMerchantMapPin>;
	var replacedSameTypePosMerchantPins : array<WmkMerchantMapPin>;
}
