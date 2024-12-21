// Replacement for default inventory menu class. I don't know if it was a smart idea...
class CR4InventoryMenu extends WmkCR4InventoryMenu
{
	event OnConfigUI() {
		super.OnConfigUI();
		WmkGetQuickSlotsInstance().OnMenuOpened(this);
	}

	event OnClosingMenu() {
		super.OnClosingMenu();
		WmkGetQuickSlotsInstance().OnMenuClosed(this);
	}

	public function AddGFxButton(buttonDef : SKeyBinding) {
		m_GFxInputBindings.PushBack(buttonDef);
	}

	event OnPlayerStatsShown() {
		super.OnPlayerStatsShown();
		WmkGetQuickSlotsInstance().OnInventoryPlayerStatsShown();
	}

	event OnPlayerStatsHidden() {
		super.OnPlayerStatsHidden();
		WmkGetQuickSlotsInstance().OnInventoryPlayerStatsHidden();
	}

	event OnTickEvent(delta : int) {
		super.OnTickEvent(delta);
		WmkGetQuickSlotsInstance().OnInventoryTick(delta);
	}

	event OnWmkShowTooltip(comparisonMode : bool) {
		WmkGetQuickSlotsInstance().OnInventoryShowTooltip(comparisonMode);
	}

	event OnWmkRemoveTooltip() {
		WmkGetQuickSlotsInstance().OnInventoryRemoveTooltip();
	}

	event OnWmkPaperdollMouseOver(oldValue : int, newValue : int) {
		WmkGetQuickSlotsInstance().OnInventoryPaperdollMouseOver(oldValue, newValue);
	}

	event OnWmkPaperdollMouseWheel(delta : int) {
		WmkGetQuickSlotsInstance().OnInventoryPaperdollMouseWheel(delta);
	}

	protected function ApplyOil(itemId : SItemUniqueId, targetSlot : int) {
		if (thePlayer.IsInCombat() && !theGame.m_quickSlotsConfig.CAN_APPLY_OILS_WHILE_IN_COMBAT) {
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		} else {
			super.ApplyOil(itemId, targetSlot);
		}
	}

	protected function ApplyRepairKit(itemId : SItemUniqueId, targetSlot : int) {
		if (thePlayer.IsInCombat() && !theGame.m_quickSlotsConfig.CAN_REPAIR_ITEMS_WHILE_IN_COMBAT) {
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		} else {
			super.ApplyRepairKit(itemId, targetSlot);
		}
	}
}
