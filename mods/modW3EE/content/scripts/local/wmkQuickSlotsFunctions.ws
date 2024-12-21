// Returns the WMkQuickInventory instance.
function WmkGetQuickInventoryInstance() : WmkQuickInventory {
	var quickInventory : WmkQuickInventory;

	if (theGame.GetHud()) {
		return (WmkQuickInventory) theGame.GetHud().GetHudModule("WatermarkModule");
	}

	return NULL;
}

// Returns the WmkQuickSlots instance.
function WmkGetQuickSlotsInstance() : WmkQuickSlots {
	var quickInventory : WmkQuickInventory = WmkGetQuickInventoryInstance();

	if (quickInventory) {
		return quickInventory.GetQuickSlotsInstance();
	}

	return NULL;
}

// Returns TRUE if the specified slot is reserved.
function WmkIsSlotReserved(slot : EEquipmentSlots) : bool {
	return (slot >= EES_ReservedPotion1) && (slot <= EES_ReservedPetard4);
}

function WmkIsNewPotionSlot(slot : EEquipmentSlots) : bool {
	return (slot == EES_Potion5) || (slot == EES_Potion6) || (slot == EES_Potion7) || (slot == EES_Potion8);
}
