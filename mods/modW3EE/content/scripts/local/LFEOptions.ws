function LFEGetCategoryMult( itemCategory : name ) : float {
	var option : name;
	switch(itemCategory){
		case 'steelsword':
			option = 'LFEcatSteel';
			break;
		case 'silversword':
			option = 'LFEcatSilver';
			break;
		case 'crossbow':
			option = 'LFEcatBow';
			break;
		case 'bolt':
			option = 'LFEcatBolt';
			break;
		case 'armor':
			option = 'LFEcatArmor';
			break;
		case 'pants':
			option = 'LFEcatPants';
			break;
		case 'boots':
			option = 'LFEcatBoots';
			break;
		case 'gloves':
			option = 'LFEcatGloves';
			break;
		case 'trophy':
			option = 'LFEcatTrophy';
			break;
		// Lazarus - LFE Horse Items
		case 'horse_bag':
			option = 'LFEcatHorseBag';
			break;
		case 'horse_blinder':
			option = 'LFEcatHorseBag';
			break;
		case 'horse_saddle':
			option = 'LFEcatHorseBag';
			break;
		// Lazarus - End
		case 'edibles':
			option = 'LFEcatFood';
			break;
		case 'potion':
			option = 'LFEcatPotion';
			break;
		case 'petard':
			option = 'LFEcatBomb';
			break;
		case 'usable':
			option = 'LFEcatUse';
			break;
		case 'dye':
			option = 'LFEcatDye';
			break;
		case 'tool':
			option = 'LFEcatTool';
			break;
		case 'oil':
			option = 'LFEcatOil';
			break;
		case 'misc':
			option = 'LFEcatMisc';
			break;
		case 'junk':
			option = 'LFEcatJunk';
			break;
		case 'book':
			option = 'LFEcatBook';
			break;
		case 'upgrade':
			option = 'LFEcatUpgrade';
			break;
		case 'crafting_ingredient':
			option = 'LFEcatCraft';
			break;
		case 'alchemy_ingredient':
			option = 'LFEcatAlchemy';
			break;
		case 'crafting_schematic':
			option = 'LFEcatDiagram';
			break;
		case 'alchemy_recipe':
			option = 'LFEcatDiagram';
			break;
		default:
			return 1.0;
			break;
	}
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEcat', option ));

}

function LFEGetQualityMult( itemQuality : int ) : float {
	var option : name;
	switch(itemQuality){
		case 1: // common
			option = 'LFEqCommon';
			break;
		case 2: // master
			option = 'LFEqMaster';
			break;
		case 3: // magic
			option = 'LFEqMagic';
			break;
		case 4: // relic
			option = 'LFEqRelic';
			break;
		case 5: // witcher
			option = 'LFEqWitcher';
			break;
		default:
			return 1.0;
			break;
	}
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEq', option ));

}

function LFEGetSellingMult( playerSellingItem : bool ) : float {
	var option : name;
	if ( playerSellingItem ) {
		option = 'LFEsbSell';
	} else {
		option = 'LFEsbBuy';
	}
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEsb', option ));
}

function LFEGetDurabilityMult( itemDurability : float ) : float {
	var option : name;
	if (itemDurability > 0 && itemDurability <= 0.5){
		option = 'LFEdur50';
	} else
	if (itemDurability > 0.5 && itemDurability <= 0.75){
		option = 'LFEdur75';
	} else
	if (itemDurability > 0.75 && itemDurability <= 0.9){
		option = 'LFEdur90';
	} else 
	if (itemDurability > 0.9 && itemDurability < 1){
		option = 'LFEdur100';
	} else return 1.0;
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEdur', option ));
}

function LFEGetGoldMult() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEmisc', 'LFEgold' ));
}

function LFEGetCraftMult() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEmisc', 'LFEcraftPrice' ));
}

function LFEGetDialogMult() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'LFEmisc', 'LFEdialog' ));
}

function LFENotify( text : string) {
	theGame.GetGuiManager().ShowNotification( text , 5000 );
}

function LFEGetVersion() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('LFEmisc', 'LFEversion'));
}

function LFEGetRepairMult() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('LFEmisc', 'LFErepair'));
}

function LFEGetRemoveUpgradeMult() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('LFEmisc', 'LFEremup'));
}

function LFEGetDisassembleMult() : float {
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('LFEmisc', 'LFEdiss'));
}