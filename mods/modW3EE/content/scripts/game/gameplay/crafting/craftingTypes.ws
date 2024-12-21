/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




enum ECraftsmanType
{
	ECT_Undefined,
	ECT_Smith,
    ECT_Armorer,
    ECT_Crafter,
	ECT_Enchanter
}

enum ECraftingException
{
	ECE_NoException,
	ECE_TooLowCraftsmanLevel,
	ECE_MissingIngredient,
	ECE_TooFewIngredients,
	ECE_WrongCraftsmanType,
	ECE_NotEnoughMoney,
	ECE_UnknownSchematic,
	ECE_CookNotAllowed
}

struct SCraftable
{
	var type : name;
	var cnt : int;
};

function CraftingExceptionToString( result : ECraftingException ) : string
{
	switch ( result )
	{
		case ECE_NoException:			return "panel_crafting_craft_item";
		case ECE_TooLowCraftsmanLevel:	return "panel_crafting_exception_too_low_craftsman_level";
		case ECE_MissingIngredient:		return "panel_crafting_exception_missing_ingridient";
		case ECE_TooFewIngredients:		return "panel_crafting_exception_missing_ingridients";
		case ECE_WrongCraftsmanType:	return "panel_crafting_exception_wrong_craftsman_type";
		case ECE_NotEnoughMoney:		return "panel_crafting_exception_not_enough_money";
		case ECE_UnknownSchematic:		return "panel_crafting_exception_unknown_schematic";
		case ECE_CookNotAllowed:		return "panel_crafting_exception_cook_not_allowed";
	}
	return "";
}


struct SCraftAttribute{
	var attributeName : name;		
	var valAdditive : float;		
	var valMultiplicative : float;	
	var displayPercMul : bool;		
	var displayPercAdd : bool;		
};


enum ECraftsmanLevel
{
	ECL_Undefined,
	ECL_Journeyman,
	ECL_Master,
	ECL_Grand_Master,
	ECL_Arch_Master
}

function ParseCraftsmanTypeStringToEnum(s : string) : ECraftsmanType
{
	switch(s)
	{
		case "Crafter" 	: return ECT_Crafter;
		case "Smith" 	: return ECT_Smith;
		case "Armorer" 	: return ECT_Armorer;
		case "Armourer"	: return ECT_Armorer; 
		case "Enchanter": return ECT_Enchanter; 
	}

	return ECT_Undefined;
}

function ParseCraftsmanLevelStringToEnum(s : string) : ECraftsmanLevel
{
	switch(s)
	{
		case "Journeyman" : return ECL_Journeyman;
		case "Master" : return ECL_Master;
		case "Grand Master" : return ECL_Grand_Master;
		case "Arch Master" : return ECL_Arch_Master;
	}
	
	return ECL_Undefined;
}

function CraftsmanTypeToLocalizationKey(type : ECraftsmanType) : string
{
	switch( type )
	{
		case ECT_Crafter : return "map_location_craftman";
		case ECT_Smith : return "map_location_blacksmith";
		case ECT_Armorer : return "Armorer";
		case ECT_Enchanter : return "map_location_alchemic";
		default: return "map_location_craftman";
	}
	return "map_location_craftman";
}

function CraftsmanLevelToLocalizationKey(type : ECraftsmanLevel) : string
{
	switch( type )
	{
		case ECL_Journeyman : return "panel_shop_crating_level_journeyman";
		case ECL_Master : return "panel_shop_crating_level_master";
		case ECL_Grand_Master: return "panel_shop_crating_level_grand_master";
		case ECL_Arch_Master: return "panel_shop_crating_level_arch_master";
		default: return "";
	}
	return "";
}


struct SCraftingSchematic
{
	var craftedItemName			: name;					
	var craftedItemCount 		: int;					
	var requiredCraftsmanType	: ECraftsmanType;
	var requiredCraftsmanLevel	: ECraftsmanLevel;		
	var baseCraftingPrice		: int;					
	var ingredients				: array<SItemParts>;	
	var schemName				: name;					
};

struct SEnchantmentSchematic
{
	var schemName				 : name;				
	var baseCraftingPrice		 : int;					
	var level					 : int;					
	var ingredients				 : array<SItemParts>;	
	var localizedName 			 : name;
	var localizedDescriptionName : string;
};

struct SItemUpgradeListElement
{
	var itemId : SItemUniqueId;
	var upgrade : SItemUpgrade;
};

struct SItemUpgrade
{
	var upgradeName : name;						
	var localizedName : name;					
	var localizedDescriptionName : name;		
	var cost : int;								
	var iconPath : string;						
	var ability : name;							
	var ingredients : array<SItemParts>;		
	var requiredUpgrades : array<name>;			
};

enum EItemUpgradeException
{
	EIUE_NoException,
	EIUE_NotEnoughGold,
	EIUE_MissingIngredient,
	EIUE_NotEnoughIngredient,
	EIUE_MissingRequiredUpgrades,
	EIUE_AlreadyPurchased,
	EIUE_ItemNotUpgradeable,
	EIUE_NoSuchUpgradeForItem
}


function IsCraftingSchematic(recipeName : name) : bool
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var i : int;

	if(!IsNameValid(recipeName))
		return false;

	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		if ( dm.GetSubNodeByAttributeValueAsCName( main.subNodes[i], 'crafting_schematics', 'name_name', recipeName ) && recipeName == recipeName )
		{
			return true;
		}
	}
	
	return false;
}

function getEnchamtmentStatName(enchantmentName:name):name
{
	switch (enchantmentName)
	{
		//Kolaris - Enchantment Overhaul
		case 'Glyphword 1':
			return 'Glyphword 1 _Stats';
			break;
		case 'Glyphword 2':
			return 'Glyphword 2 _Stats';
			break;
		case 'Glyphword 3':
			return 'Glyphword 3 _Stats';
			break;
		case 'Glyphword 4':
			return 'Glyphword 4 _Stats';
			break;
		case 'Glyphword 5':
			return 'Glyphword 5 _Stats';
			break;
		case 'Glyphword 6':
			return 'Glyphword 6 _Stats';
			break;
		case 'Glyphword 7':
			return 'Glyphword 7 _Stats';
			break;
		case 'Glyphword 8':
			return 'Glyphword 8 _Stats';
			break;
		case 'Glyphword 9':
			return 'Glyphword 9 _Stats';
			break;
		case 'Glyphword 10':
			return 'Glyphword 10 _Stats';
			break;
		case 'Glyphword 11':
			return 'Glyphword 11 _Stats';
			break;
		case 'Glyphword 12':
			return 'Glyphword 12 _Stats';
			break;
		case 'Glyphword 13':
			return 'Glyphword 13 _Stats';
			break;
		case 'Glyphword 14':
			return 'Glyphword 14 _Stats';
			break;
		case 'Glyphword 15':
			return 'Glyphword 15 _Stats';
			break;
		case 'Glyphword 16':
			return 'Glyphword 16 _Stats';
			break;
		case 'Glyphword 17':
			return 'Glyphword 17 _Stats';
			break;
		case 'Glyphword 18':
			return 'Glyphword 18 _Stats';
			break;
		case 'Glyphword 19':
			return 'Glyphword 19 _Stats';
			break;
		case 'Glyphword 20':
			return 'Glyphword 20 _Stats';
			break;
		case 'Glyphword 21':
			return 'Glyphword 21 _Stats';
			break;
		case 'Glyphword 22':
			return 'Glyphword 22 _Stats';
			break;
		case 'Glyphword 23':
			return 'Glyphword 23 _Stats';
			break;
		case 'Glyphword 24':
			return 'Glyphword 24 _Stats';
			break;
		case 'Glyphword 25':
			return 'Glyphword 25 _Stats';
			break;
		case 'Glyphword 26':
			return 'Glyphword 26 _Stats';
			break;
		case 'Glyphword 27':
			return 'Glyphword 27 _Stats';
			break;
		case 'Glyphword 28':
			return 'Glyphword 28 _Stats';
			break;
		case 'Glyphword 29':
			return 'Glyphword 29 _Stats';
			break;
		case 'Glyphword 30':
			return 'Glyphword 30 _Stats';
			break;
		case 'Glyphword 31':
			return 'Glyphword 31 _Stats';
			break;
		case 'Glyphword 32':
			return 'Glyphword 32 _Stats';
			break;
		case 'Glyphword 33':
			return 'Glyphword 33 _Stats';
			break;
		case 'Glyphword 34':
			return 'Glyphword 34 _Stats';
			break;
		case 'Glyphword 35':
			return 'Glyphword 35 _Stats';
			break;
		case 'Glyphword 36':
			return 'Glyphword 36 _Stats';
			break;
		case 'Glyphword 37':
			return 'Glyphword 37 _Stats';
			break;
		case 'Glyphword 38':
			return 'Glyphword 38 _Stats';
			break;
		case 'Glyphword 39':
			return 'Glyphword 39 _Stats';
			break;
		case 'Glyphword 40':
			return 'Glyphword 40 _Stats';
			break;
		case 'Glyphword 41':
			return 'Glyphword 41 _Stats';
			break;
		case 'Glyphword 42':
			return 'Glyphword 42 _Stats';
			break;
		case 'Glyphword 43':
			return 'Glyphword 43 _Stats';
			break;
		case 'Glyphword 44':
			return 'Glyphword 44 _Stats';
			break;
		case 'Glyphword 45':
			return 'Glyphword 45 _Stats';
			break;
		case 'Glyphword 46':
			return 'Glyphword 46 _Stats';
			break;
		case 'Glyphword 47':
			return 'Glyphword 47 _Stats';
			break;
		case 'Glyphword 48':
			return 'Glyphword 48 _Stats';
			break;
		case 'Glyphword 49':
			return 'Glyphword 49 _Stats';
			break;
		case 'Glyphword 50':
			return 'Glyphword 50 _Stats';
			break;
		case 'Glyphword 51':
			return 'Glyphword 51 _Stats';
			break;
		case 'Glyphword 52':
			return 'Glyphword 52 _Stats';
			break;
		case 'Glyphword 53':
			return 'Glyphword 53 _Stats';
			break;
		case 'Glyphword 54':
			return 'Glyphword 54 _Stats';
			break;
			
		case 'Runeword 1':
			return 'Runeword 1 _Stats';
			break;
		case 'Runeword 2':
			return 'Runeword 2 _Stats';
			break;
		case 'Runeword 3':
			return 'Runeword 3 _Stats';
			break;
		case 'Runeword 4':
			return 'Runeword 4 _Stats';
			break;
		case 'Runeword 5':
			return 'Runeword 5 _Stats';
			break;
		case 'Runeword 6':
			return 'Runeword 6 _Stats';
			break;
		case 'Runeword 7':
			return 'Runeword 7 _Stats';
			break;
		case 'Runeword 8':
			return 'Runeword 8 _Stats';
			break;
		case 'Runeword 9':
			return 'Runeword 9 _Stats';
			break;
		case 'Runeword 10':
			return 'Runeword 10 _Stats';
			break;
		case 'Runeword 11':
			return 'Runeword 11 _Stats';
			break;
		case 'Runeword 12':
			return 'Runeword 12 _Stats';
			break;
		case 'Runeword 13':
			return 'Runeword 13 _Stats';
			break;
		case 'Runeword 14':
			return 'Runeword 14 _Stats';
			break;
		case 'Runeword 15':
			return 'Runeword 15 _Stats';
			break;
		case 'Runeword 16':
			return 'Runeword 16 _Stats';
			break;
		case 'Runeword 17':
			return 'Runeword 17 _Stats';
			break;
		case 'Runeword 18':
			return 'Runeword 18 _Stats';
			break;
		case 'Runeword 19':
			return 'Runeword 19 _Stats';
			break;
		case 'Runeword 20':
			return 'Runeword 20 _Stats';
			break;
		case 'Runeword 21':
			return 'Runeword 21 _Stats';
			break;
		case 'Runeword 22':
			return 'Runeword 22 _Stats';
			break;
		case 'Runeword 23':
			return 'Runeword 23 _Stats';
			break;
		case 'Runeword 24':
			return 'Runeword 24 _Stats';
			break;
		case 'Runeword 25':
			return 'Runeword 25 _Stats';
			break;
		case 'Runeword 26':
			return 'Runeword 26 _Stats';
			break;
		case 'Runeword 27':
			return 'Runeword 27 _Stats';
			break;
		case 'Runeword 28':
			return 'Runeword 28 _Stats';
			break;
		case 'Runeword 29':
			return 'Runeword 29 _Stats';
			break;
		case 'Runeword 30':
			return 'Runeword 30 _Stats';
			break;
		case 'Runeword 31':
			return 'Runeword 31 _Stats';
			break;
		case 'Runeword 32':
			return 'Runeword 32 _Stats';
			break;
		case 'Runeword 33':
			return 'Runeword 33 _Stats';
			break;
		case 'Runeword 34':
			return 'Runeword 34 _Stats';
			break;
		case 'Runeword 35':
			return 'Runeword 35 _Stats';
			break;
		case 'Runeword 36':
			return 'Runeword 36 _Stats';
			break;
		case 'Runeword 37':
			return 'Runeword 37 _Stats';
			break;
		case 'Runeword 38':
			return 'Runeword 38 _Stats';
			break;
		case 'Runeword 39':
			return 'Runeword 39 _Stats';
			break;
		case 'Runeword 40':
			return 'Runeword 40 _Stats';
			break;
		case 'Runeword 41':
			return 'Runeword 41 _Stats';
			break;
		case 'Runeword 42':
			return 'Runeword 42 _Stats';
			break;
		case 'Runeword 43':
			return 'Runeword 43 _Stats';
			break;
		case 'Runeword 44':
			return 'Runeword 44 _Stats';
			break;
		case 'Runeword 45':
			return 'Runeword 45 _Stats';
			break;
		case 'Runeword 46':
			return 'Runeword 46 _Stats';
			break;
		case 'Runeword 47':
			return 'Runeword 47 _Stats';
			break;
		case 'Runeword 48':
			return 'Runeword 48 _Stats';
			break;
		case 'Runeword 49':
			return 'Runeword 49 _Stats';
			break;
		case 'Runeword 50':
			return 'Runeword 50 _Stats';
			break;
		case 'Runeword 51':
			return 'Runeword 51 _Stats';
			break;
		case 'Runeword 52':
			return 'Runeword 52 _Stats';
			break;
		case 'Runeword 53':
			return 'Runeword 53 _Stats';
			break;
		case 'Runeword 54':
			return 'Runeword 54 _Stats';
			break;
		case 'Runeword 55':
			return 'Runeword 55 _Stats';
			break;
		case 'Runeword 56':
			return 'Runeword 56 _Stats';
			break;
		case 'Runeword 57':
			return 'Runeword 57 _Stats';
			break;
		case 'Runeword 58':
			return 'Runeword 58 _Stats';
			break;
		case 'Runeword 59':
			return 'Runeword 59 _Stats';
			break;
		case 'Runeword 60':
			return 'Runeword 60 _Stats';
			break;
		
		default:
			break;
	}
	return '';
}

function GetAllRunewordSchematics():array< CName >
{
	var resultList  : array< CName >;
	
	//Kolaris - Enchantment Overhaul
	resultList.PushBack( 'Glyphword 1' );
	resultList.PushBack( 'Glyphword 2' );
	resultList.PushBack( 'Glyphword 3' );
	resultList.PushBack( 'Glyphword 4' );
	resultList.PushBack( 'Glyphword 5' );
	resultList.PushBack( 'Glyphword 6' );
	resultList.PushBack( 'Glyphword 7' );
	resultList.PushBack( 'Glyphword 8' );
	resultList.PushBack( 'Glyphword 9' );
	resultList.PushBack( 'Glyphword 10' );
	resultList.PushBack( 'Glyphword 11' );
	resultList.PushBack( 'Glyphword 12' );
	resultList.PushBack( 'Glyphword 13' );
	resultList.PushBack( 'Glyphword 14' );
	resultList.PushBack( 'Glyphword 15' );
	resultList.PushBack( 'Glyphword 16' );
	resultList.PushBack( 'Glyphword 17' );
	resultList.PushBack( 'Glyphword 18' );
	resultList.PushBack( 'Glyphword 19' );
	resultList.PushBack( 'Glyphword 20' );
	resultList.PushBack( 'Glyphword 21' );
	resultList.PushBack( 'Glyphword 22' );
	resultList.PushBack( 'Glyphword 23' );
	resultList.PushBack( 'Glyphword 24' );
	resultList.PushBack( 'Glyphword 25' );
	resultList.PushBack( 'Glyphword 26' );
	resultList.PushBack( 'Glyphword 27' );
	resultList.PushBack( 'Glyphword 28' );
	resultList.PushBack( 'Glyphword 29' );
	resultList.PushBack( 'Glyphword 30' );
	resultList.PushBack( 'Glyphword 31' );
	resultList.PushBack( 'Glyphword 32' );
	resultList.PushBack( 'Glyphword 33' );
	resultList.PushBack( 'Glyphword 34' );
	resultList.PushBack( 'Glyphword 35' );
	resultList.PushBack( 'Glyphword 36' );
	resultList.PushBack( 'Glyphword 37' );
	resultList.PushBack( 'Glyphword 38' );
	resultList.PushBack( 'Glyphword 39' );
	resultList.PushBack( 'Glyphword 40' );
	resultList.PushBack( 'Glyphword 41' );
	resultList.PushBack( 'Glyphword 42' );
	resultList.PushBack( 'Glyphword 43' );
	resultList.PushBack( 'Glyphword 44' );
	resultList.PushBack( 'Glyphword 45' );
	resultList.PushBack( 'Glyphword 46' );
	resultList.PushBack( 'Glyphword 47' );
	resultList.PushBack( 'Glyphword 48' );
	resultList.PushBack( 'Glyphword 49' );
	resultList.PushBack( 'Glyphword 50' );
	resultList.PushBack( 'Glyphword 51' );
	resultList.PushBack( 'Glyphword 52' );
	resultList.PushBack( 'Glyphword 53' );
	resultList.PushBack( 'Glyphword 54' );
	
	resultList.PushBack( 'Runeword 1' );
	resultList.PushBack( 'Runeword 2' );
	resultList.PushBack( 'Runeword 3' );
	resultList.PushBack( 'Runeword 4' );
	resultList.PushBack( 'Runeword 5' );
	resultList.PushBack( 'Runeword 6' );
	resultList.PushBack( 'Runeword 7' );
	resultList.PushBack( 'Runeword 8' );
	resultList.PushBack( 'Runeword 9' );
	resultList.PushBack( 'Runeword 10' );
	resultList.PushBack( 'Runeword 11' );
	resultList.PushBack( 'Runeword 12' );
	resultList.PushBack( 'Runeword 13' );
	resultList.PushBack( 'Runeword 14' );
	resultList.PushBack( 'Runeword 15' );
	resultList.PushBack( 'Runeword 16' );
	resultList.PushBack( 'Runeword 17' );
	resultList.PushBack( 'Runeword 18' );
	resultList.PushBack( 'Runeword 19' );
	resultList.PushBack( 'Runeword 20' );
	resultList.PushBack( 'Runeword 21' );
	resultList.PushBack( 'Runeword 22' );
	resultList.PushBack( 'Runeword 23' );
	resultList.PushBack( 'Runeword 24' );
	resultList.PushBack( 'Runeword 25' );
	resultList.PushBack( 'Runeword 26' );
	resultList.PushBack( 'Runeword 27' );
	resultList.PushBack( 'Runeword 28' );
	resultList.PushBack( 'Runeword 29' );
	resultList.PushBack( 'Runeword 30' );
	resultList.PushBack( 'Runeword 31' );
	resultList.PushBack( 'Runeword 32' );
	resultList.PushBack( 'Runeword 33' );
	resultList.PushBack( 'Runeword 34' );
	resultList.PushBack( 'Runeword 35' );
	resultList.PushBack( 'Runeword 36' );
	resultList.PushBack( 'Runeword 37' );
	resultList.PushBack( 'Runeword 38' );
	resultList.PushBack( 'Runeword 39' );
	resultList.PushBack( 'Runeword 40' );
	resultList.PushBack( 'Runeword 41' );
	resultList.PushBack( 'Runeword 42' );
	resultList.PushBack( 'Runeword 43' );
	resultList.PushBack( 'Runeword 44' );
	resultList.PushBack( 'Runeword 45' );
	resultList.PushBack( 'Runeword 46' );
	resultList.PushBack( 'Runeword 47' );
	resultList.PushBack( 'Runeword 48' );
	resultList.PushBack( 'Runeword 49' );
	resultList.PushBack( 'Runeword 50' );
	resultList.PushBack( 'Runeword 51' );
	resultList.PushBack( 'Runeword 52' );
	resultList.PushBack( 'Runeword 53' );
	resultList.PushBack( 'Runeword 54' );
	resultList.PushBack( 'Runeword 55' );
	resultList.PushBack( 'Runeword 56' );
	resultList.PushBack( 'Runeword 57' );
	resultList.PushBack( 'Runeword 58' );
	resultList.PushBack( 'Runeword 59' );
	resultList.PushBack( 'Runeword 60' );
	
	return resultList;
}