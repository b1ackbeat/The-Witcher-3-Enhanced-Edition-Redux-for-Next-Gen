// Replacement for the default radial menu class.
// In this way less changes are required to hudModuleRadialMenu.ws standard script file.
class CR4HudModuleRadialMenu extends WmkCR4HudModuleRadialMenu {

	function ShowRadialMenu() {
		if (!super.IsRadialMenuOpened()) {
			super.ShowRadialMenu();
			if (super.IsRadialMenuOpened()) {
				WmkGetQuickSlotsInstance().OnMenuOpened(this);
			}
		}
	}

	function HideRadialMenu() {
		if (super.IsRadialMenuOpened()) {
			super.HideRadialMenu();
			if (!super.IsRadialMenuOpened()) {
				WmkGetQuickSlotsInstance().OnMenuClosed(this);
			}
		}
	}

	// This is called once from CR4HudModuleRadialMenu::OnConfigUI, but before the WmkQuickSlots instance is
	// created. Actually even before the CR4HudModuleAnchors is created. But is not a problem because
	// will be called again when the anchors module is instantiated and configured.
	protected function UpdateScale(scale : float, flashModule : CScriptedFlashSprite) : bool {
		var instance : WmkQuickSlots = WmkGetQuickSlotsInstance();

		if (instance) {
			instance.UpdateScale(scale, flashModule);
		}

		return false;
	}

	event OnWmkHandleInput(value : string, navEquivalent : string, code : float, fromJoystick : bool, details : string) {
		WmkGetQuickSlotsInstance().OnRadialMenuHandleInput(value, navEquivalent, code, fromJoystick);
	}

	event OnWmkHandleSetItemsList() {
		WmkGetQuickSlotsInstance().OnRadialMenuHandleSetItemsList();
	}

	event OnRadialMenuItemSelected(choosenSymbol : string, isDesaturated : bool) {
		super.OnRadialMenuItemSelected(choosenSymbol, isDesaturated);
		WmkGetQuickSlotsInstance().OnRadialMenuItemSelected(choosenSymbol, isDesaturated);
	}

	event OnWmkMoveMouseTo(valueX : float, valueY : float) {
		theGame.MoveMouseTo(valueX, valueY);
	}

	event OnWmkMouseWheel(delta : int) {
		WmkGetQuickSlotsInstance().OnRadialMouseWheel(delta);
	}

	event OnWmkActivateSlot(slotName:string, reason : int) {
		WmkGetQuickSlotsInstance().OnRadialMenuActivateSlot(slotName, reason);
	}

	event OnWmkRightMouseButtonClick() {
		WmkGetQuickSlotsInstance().OnRadialRightMouseButtonClick();
	}

	event OnWmkDebug(message : string) {
		if (false) {
			LogChannel('WMK', "OnWmkDebug: message = " + message);
		}
	}
}
