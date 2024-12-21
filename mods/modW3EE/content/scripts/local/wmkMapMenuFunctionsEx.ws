function WmkGetMapMenuInstance() : WmkMapMenuEx
{
	var wmkMapMenu : WmkMapMenuEx;
	var playerWitcher : W3PlayerWitcher = GetWitcherPlayer();

	if (playerWitcher) {
		if (!playerWitcher.wmkMapMenu) {
			playerWitcher.wmkMapMenu = new WmkMapMenuEx in playerWitcher;
			playerWitcher.wmkMapMenu.Initialize();
		}

		return playerWitcher.wmkMapMenu;
	}

	return wmkMapMenu;
}
