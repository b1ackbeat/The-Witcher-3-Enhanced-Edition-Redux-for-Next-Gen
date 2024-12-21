state W3EEAlchemy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INITIAL, CATEGORIES, OPEN_POTIONS, SELECT_RECIPE, COOKED_ITEM_DESC, INGREDIENTS, SELECT_INGREDIENT, INGREDIENT_TYPES, INGREDIENT_SECONDARY, ALCHEMY_HELPERS, BREWING_PROCESS : name;	
	private const var POTIONS_JOURNAL : name;
	private var selectedRecipe : SAlchemyRecipe;
	private var ingredientIndex : int;
	private var isClosing : bool;
		
		default INITIAL 				= 'AlchemyTutorialStart';
		default CATEGORIES 				= 'AlchemyTutorialCategories';
		default OPEN_POTIONS			= 'AlchemyTutorialOpenTab'; 
		default SELECT_RECIPE 			= 'AlchemyTutorialSelectRecipe';
		default COOKED_ITEM_DESC 		= 'AlchemyTutorialItemDescription';
		default INGREDIENTS 			= 'AlchemyTutorialIngredients';
		default SELECT_INGREDIENT 		= 'AlchemyTutorialSelectIngredient';
		default INGREDIENT_TYPES 		= 'AlchemyTutorialIngredientTypes';
		default INGREDIENT_SECONDARY 	= 'AlchemyTutorialIngredientSecondaries';
		default ALCHEMY_HELPERS 		= 'AlchemyTutorialHelpers';
		default BREWING_PROCESS 		= 'AlchemyTutorialBrewingProcess';
		default POTIONS_JOURNAL			= 'TutorialJournalPotions';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		BlockPanels(true);
		isClosing = false;
		
		ShowHint(INITIAL,,,,, true);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		BlockPanels(false);
		isClosing = true;
		
		CloseStateHint(CATEGORIES);
		CloseStateHint(OPEN_POTIONS);
		CloseStateHint(SELECT_RECIPE);
		CloseStateHint(COOKED_ITEM_DESC);
		CloseStateHint(INGREDIENTS);
		CloseStateHint(SELECT_INGREDIENT);
		CloseStateHint(INGREDIENT_TYPES);
		CloseStateHint(INGREDIENT_SECONDARY);
		CloseStateHint(ALCHEMY_HELPERS);
		CloseStateHint(BREWING_PROCESS);
		
		theGame.GetTutorialSystem().ActivateJournalEntry(POTIONS_JOURNAL);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(CATEGORIES);
		theGame.GetTutorialSystem().MarkMessageAsSeen(OPEN_POTIONS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_RECIPE);
		theGame.GetTutorialSystem().MarkMessageAsSeen(COOKED_ITEM_DESC);
		theGame.GetTutorialSystem().MarkMessageAsSeen(INGREDIENTS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_INGREDIENT);
		theGame.GetTutorialSystem().MarkMessageAsSeen(INGREDIENT_TYPES);
		theGame.GetTutorialSystem().MarkMessageAsSeen(INGREDIENT_SECONDARY);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ALCHEMY_HELPERS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(BREWING_PROCESS);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var menu : CR4AlchemyMenu;
		
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == INITIAL )
		{
			ShowHint(CATEGORIES, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyList());
		}
		else
		if( hintName == CATEGORIES )
		{
			ShowHint(OPEN_POTIONS, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite, GetHighlightAlchemyList());
		}
		else
		if( hintName == OPEN_POTIONS )
		{
			ShowHint(SELECT_RECIPE, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite, GetHighlightAlchemyList());
		}
		else
		if( hintName == SELECT_RECIPE )
		{
			ShowHint(COOKED_ITEM_DESC, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyItemDesc(), true);
		}
		else
		if( hintName == COOKED_ITEM_DESC )
		{
			ShowHint(INGREDIENTS, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyIngredients(), true);
		}
		else
		if( hintName == INGREDIENTS )
		{
			ShowHint(SELECT_INGREDIENT, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite, GetHighlightAlchemyIngredients());
		}
		else
		if( hintName == SELECT_INGREDIENT )
		{
			ShowHint(INGREDIENT_TYPES, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyItemDesc(), true);
		}
		else
		if( hintName == INGREDIENT_TYPES )
		{
			ShowHint(INGREDIENT_SECONDARY, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyItemDesc(), true);
		}
		else
		if( hintName == INGREDIENT_SECONDARY )
		{
			menu = (CR4AlchemyMenu)((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
			menu.TutorialRestoreIngredient();
			
			ShowHint(ALCHEMY_HELPERS, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyHelpers(), true);
		}
		else
		if( hintName == ALCHEMY_HELPERS )
		{
			ShowHint(BREWING_PROCESS, POS_ALCHEMY_X, POS_ALCHEMY_Y, , , true);
		}
		else
		if( hintName == BREWING_PROCESS )
		{		
			QuitState();
		}
	}
	
	private function IsCorrectRecipe() : bool
	{
		return selectedRecipe.cookedItemType == EACIT_Potion;
	}
	
	private function IsCorrectCategory( categoryName : name, opened : bool ) : bool
	{
		return (categoryName == 'potion' && opened);
	}
	
	private function IsCorrectIngredient( isModuleSelected : bool ) : bool
	{
		return isModuleSelected;
	}
	
	public function SelectRecipe( recipe : SAlchemyRecipe )
	{
		selectedRecipe = recipe;
		if( IsCurrentHint(SELECT_RECIPE) && IsCorrectRecipe() )
			CloseStateHint(SELECT_RECIPE);
	}
	
	public function SelectCategory( categoryName : name, opened : bool )
	{
		if( IsCurrentHint(OPEN_POTIONS) && IsCorrectCategory(categoryName, opened) )
			CloseStateHint(OPEN_POTIONS);
	}
	
	public function SelectIngredient( isModuleSelected : bool, index : int )
	{
		var menu : CR4AlchemyMenu;
		
		ingredientIndex = index;
		if( IsCurrentHint(SELECT_INGREDIENT) && IsCorrectIngredient(isModuleSelected) )
		{
			CloseStateHint(SELECT_INGREDIENT);
			
			menu = (CR4AlchemyMenu)((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
			menu.TutorialReplaceIngredient();
		}
	}
	
	public function IsSelectingIngredient() : bool
	{
		return IsCurrentHint(SELECT_INGREDIENT) || IsCurrentHint(INGREDIENT_TYPES) || IsCurrentHint(INGREDIENT_SECONDARY) || IsCurrentHint(ALCHEMY_HELPERS);
	}
	
	private function BlockPanels( block : bool )
	{
		if( block && !isClosing )
		{
			thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_OpenGwint, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_OpenFastMenu, 'tutorial_alchemy');
			thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_alchemy');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_FastTravel, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_OpenMap, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_OpenJournal, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_OpenGwint, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_OpenFastMenu, 'tutorial_alchemy');
			thePlayer.UnblockAction(EIAB_OpenGlossary, 'tutorial_alchemy');
		}
	}
}

state W3EECrafting in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INTRO, DIAGRAMS, INGREDIENTS, ITEM_STATS, SET_BONUSES, ABILITY_SETS, CRAFTING_PRICE, CONTEXTUAL : name;	
	private var selectedRecipe : SAlchemyRecipe;
	private var ingredientIndex : int;
	private var isClosing : bool;
	private var menu : CR4CraftingMenu;
		
		default INTRO 				= 'CraftingTutorialIntro';
		default DIAGRAMS 			= 'CraftingTutorialDiagrams';
		default INGREDIENTS			= 'CraftingTutorialIngredients'; 
		default ITEM_STATS 			= 'CraftingTutorialItemStats';
		default SET_BONUSES 		= 'CraftingTutorialSetBonuses';
		default ABILITY_SETS 		= 'CraftingTutorialAbilitySets';
		default CRAFTING_PRICE 		= 'CraftingTutorialPrice';
		default CONTEXTUAL 			= 'CraftingTutorialContextual';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		BlockPanels(true);
		isClosing = false;
		
		menu = (CR4CraftingMenu)((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
		menu.TutorialUpdateName();
		ShowHint(INTRO,,,,, true);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		BlockPanels(false);
		isClosing = true;
		
		CloseStateHint(INTRO);
		CloseStateHint(DIAGRAMS);
		CloseStateHint(INGREDIENTS);
		CloseStateHint(ITEM_STATS);
		CloseStateHint(SET_BONUSES);
		CloseStateHint(ABILITY_SETS);
		CloseStateHint(CRAFTING_PRICE);
		CloseStateHint(CONTEXTUAL);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(INTRO);
		theGame.GetTutorialSystem().MarkMessageAsSeen(DIAGRAMS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(INGREDIENTS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ITEM_STATS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SET_BONUSES);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ABILITY_SETS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(CRAFTING_PRICE);
		theGame.GetTutorialSystem().MarkMessageAsSeen(CONTEXTUAL);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == INTRO )
		{
			ShowHint(DIAGRAMS, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightCraftingList());
		}
		else
		if( hintName == DIAGRAMS )
		{
			ShowHint(INGREDIENTS, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite, GetHighlightCraftingIngredients(), true);
		}
		else
		if( hintName == INGREDIENTS )
		{
			ShowHint(ITEM_STATS, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite, GetHighlightCraftingItemDescription(), true);
		}
		else
		if( hintName == ITEM_STATS )
		{
			ShowHint(SET_BONUSES, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightCraftingSetBonuses(), true);
		}
		else
		if( hintName == SET_BONUSES )
		{
			menu.TutorialShowAbility();
			
			ShowHint(ABILITY_SETS, POS_ALCHEMY_X, POS_ALCHEMY_Y, , GetHighlightAlchemyItemDesc(), true);
		}
		else
		if( hintName == ABILITY_SETS )
		{
			menu.TutorialHideAbility();
			ShowHint(CRAFTING_PRICE, POS_ALCHEMY_X, POS_ALCHEMY_Y, ETHDT_Infinite, GetHighlightCraftingPrice(), true);
			menu.TutorialUpdateName();
		}
		else
		if( hintName == CRAFTING_PRICE )
		{
			ShowHint(CONTEXTUAL, POS_ALCHEMY_X, POS_ALCHEMY_Y, , , true);
		}
		else
		if( hintName == CONTEXTUAL )
		{
			QuitState();
		}
	}
	
	public function ShouldShowNames() : bool
	{
		return !(IsCurrentHint(CONTEXTUAL) || IsCurrentHint(CRAFTING_PRICE));
	}
	
	private function BlockPanels( block : bool )
	{
		if( block && !isClosing )
		{
			thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenGwint, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenFastMenu, 'tutorial_crafting');
			thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_crafting');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_FastTravel, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenMap, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenJournal, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenAlchemy, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenGwint, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenFastMenu, 'tutorial_crafting');
			thePlayer.UnblockAction(EIAB_OpenGlossary, 'tutorial_crafting');
		}
	}
}

state Stash in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var STASH_INV, STASH_CONTEXT, STASH_GENERAL : name;
	private var isClosing : bool;
		
		default STASH_INV	 	= 'TutorialStashInventory';
		default STASH_CONTEXT 	= 'TutorialStashContext';
		default STASH_GENERAL 	= 'TutorialStash';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		BlockPanels(true);
		isClosing = false;
		ShowHint(STASH_GENERAL,,,,,true);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		BlockPanels(false);
		isClosing = true;
		
		CloseStateHint(STASH_GENERAL);
		CloseStateHint(STASH_INV);
		CloseStateHint(STASH_CONTEXT);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(STASH_GENERAL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(STASH_INV);
		theGame.GetTutorialSystem().MarkMessageAsSeen(STASH_CONTEXT);
		
		super.OnLeaveState(nextStateName);
	}
	
	private function BlockPanels( block : bool )
	{
		if( block && !isClosing )
		{
			thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == STASH_GENERAL)
		{
			highlights.Clear();
			highlights.PushBack( GetHighlightForPaperdoll() );
			ShowHint(STASH_INV, , , ETHDT_Input, highlights, true);
		}
		else if(hintName == STASH_INV)
		{
			ShowHint(STASH_CONTEXT, , , ETHDT_Input,,true);
		}
		else if(hintName == STASH_CONTEXT)
		{
			QuitState();
		}
	}
}

state Meditation in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var MEDITATION, MEDITATION2, MEDITATION3 : name;
	private var isClosing : bool;
		
		default MEDITATION = 'TutorialMeditation1';
		default MEDITATION2 = 'TutorialMeditation2';
		default MEDITATION3 = 'TutorialMeditation3';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		TutorialScript('characterDev', '');
		ShowHint(MEDITATION,,,,,true,,true);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == MEDITATION )
		{
			ShowHint(MEDITATION2,,,,,true,,true);
		}
		else if( hintName == MEDITATION2 )
		{
			ShowHint(MEDITATION3,,,,,true,,true);
		}
		else if( hintName == MEDITATION3 )
		{
			QuitState();
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint(MEDITATION);
		CloseStateHint(MEDITATION2);
		CloseStateHint(MEDITATION3);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(MEDITATION);
		theGame.GetTutorialSystem().MarkMessageAsSeen(MEDITATION2);
		theGame.GetTutorialSystem().MarkMessageAsSeen(MEDITATION3);
		
		super.OnLeaveState(nextStateName);
	}
}

state Bleeding in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var BLEEDING : name;
	private var isClosing : bool;
		
		default BLEEDING = 'TutorialBleeding';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(BLEEDING,,,,,true,,true);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == BLEEDING )
		{
			QuitState();
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		CloseStateHint(BLEEDING);
		theGame.GetTutorialSystem().MarkMessageAsSeen(BLEEDING);
		
		super.OnLeaveState(nextStateName);
	}
}

state Poisoning in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var POISONING : name;
	private var isClosing : bool;
		
		default POISONING = 'TutorialPoisoning';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(POISONING,,,,,true,,true);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == POISONING )
		{
			QuitState();
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		CloseStateHint(POISONING);
		theGame.GetTutorialSystem().MarkMessageAsSeen(POISONING);
		
		super.OnLeaveState(nextStateName);
	}
}

state Injury in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INJURY : name;
	private var isClosing : bool;
		
		default INJURY = 'TutorialInjury';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(INJURY,,,,,true,,true);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == INJURY )
		{
			QuitState();
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		CloseStateHint(INJURY);
		theGame.GetTutorialSystem().MarkMessageAsSeen(INJURY);
		
		super.OnLeaveState(nextStateName);
	}
}

state InjuredState in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INJUREDSTATE : name;
	private var isClosing : bool;
		
		default INJUREDSTATE = 'TutorialInjuredState';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(INJUREDSTATE,,,,,true,,true);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if( closedByParentMenu || isClosing )
			return true;
			
		if( hintName == INJUREDSTATE )
		{
			QuitState();
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		CloseStateHint(INJUREDSTATE);
		theGame.GetTutorialSystem().MarkMessageAsSeen(INJUREDSTATE);
		
		super.OnLeaveState(nextStateName);
	}
}
