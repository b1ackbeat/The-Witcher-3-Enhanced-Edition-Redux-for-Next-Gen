class WmkBookPopupFeedback extends BookPopupFeedback {

	private var m_quickInventory : WmkQuickInventory;
	private var m_backgroundUpdated : bool; default m_backgroundUpdated = false;

	private const var POPUP_WIDTH : float; default POPUP_WIDTH = 714.20;
	private const var POPUP_HEIGHT : float; default POPUP_HEIGHT = 738.85;
	private const var POPUP_X_OFFSET : float; default POPUP_X_OFFSET = -7.25;
	private const var POPUP_Y_OFFSET : float; default POPUP_Y_OFFSET = -35.30;

	public function Initialize(quickInventory : WmkQuickInventory, item : SItemUniqueId) {
		m_quickInventory = quickInventory;

		curInventory = thePlayer.inv;
		bookItemId = item;

		SetMessageTitle(curInventory.GetItemLocNameByID(item));
		SetMessageText(curInventory.GetBookText(item));
		singleBookMode = false;
		m_DisplayGreyBackground = false;
		ScreenPosY = 0.1;
		ScreenPosX = (((1920.0 - POPUP_WIDTH) / 2.0) + POPUP_X_OFFSET) / 1920.0;
	}

	public function SetupOverlayRef(target : CR4MenuPopup) {
		super.SetupOverlayRef(target);
	}

	public function UpdateAfterBookRead(bookItemId : SItemUniqueId) {
		var background : CScriptedFlashSprite;

		// OverlayPanel.configUI => CR4MenuPopup.OnConfigUI => W3PopupData.SetupOverlayRef, so this code
		// should be in SetupOverlayRef function. But the OverlayPanel.configUI function resizes the background
		// to fit the entire screen ... after dispatching the OnConfigUI event :(
		//
		// The background can be resized here because this function is actually called after the text for a book is
		// displayed on screen, which happens for the first one right after OnConfigUI event.

		if (!m_backgroundUpdated) {
			background = PopupRef.GetMenuFlash().GetChildFlashSprite("background");
			if (background) {
				background.SetMemberFlashNumber("width", POPUP_WIDTH);
				background.SetMemberFlashNumber("height", POPUP_HEIGHT);
				background.SetX(ScreenPosX * 1920 + POPUP_X_OFFSET);
				background.SetY(ScreenPosY * 1080 + POPUP_Y_OFFSET);
				background.SetVisible(true);
			}
			m_backgroundUpdated = true;
		}

		m_quickInventory.UpdateAfterBookRead(bookItemId);
	}
}
