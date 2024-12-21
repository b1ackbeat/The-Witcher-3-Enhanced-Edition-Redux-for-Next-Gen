/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3AlchemyManager
{
	private var recipes : array<SAlchemyRecipe>;									
	private var isPlayerMounted  : bool;
	private var isPlayerInCombat : bool;
	
	public function Init(optional alchemyRecipes : array<name>)
	{		
		if(alchemyRecipes.Size() > 0)
		{
			LoadRecipesCustomXMLData( alchemyRecipes );
		}
		else
		{
			LoadRecipesCustomXMLData( GetWitcherPlayer().GetAlchemyRecipes() );
		}
		
		isPlayerMounted = thePlayer.GetUsedVehicle();
		isPlayerInCombat = thePlayer.IsInCombat();
	}
	
	public function GetRecipe(recipeName : name, out ret : SAlchemyRecipe) : bool
	{
		var i : int;
		
		for(i=0; i<recipes.Size(); i+=1)
		{
			if(recipes[i].recipeName == recipeName)
			{
				ret = recipes[i];
				return true;
			}
		}
		
		return false;
	}
	
	// W3EE - Begin
	public function ModRecipe( recipe : SAlchemyRecipe ) : void
	{
		var i : int;
		
		for(i=0; i<recipes.Size(); i+=1)
		{
			if( recipes[i].recipeName == recipe.recipeName )
			{
				recipes[i] = recipe;
				return;
			}
		}
	}
	// W3EE - End
	
	private function LoadRecipesCustomXMLData(recipesNames : array<name>)
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpBool : bool;
		var tmpName : name;
		var tmpString : string;
		var tmpInt : int;
		var rec : SAlchemyRecipe;
		var i, k, readRecipes : int;
		var ing : SItemParts;
		// W3EE - Begin
		var alchemyExtender : W3EEAlchemyExtender = Alchemy();
		var ingredientCount : int = -1;
		var primaryIndex : int = -1;
		var mutagenIndex : int = -1;
		// W3EE - End
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');
		readRecipes = 0;
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName) && IsNameValid(tmpName) && recipesNames.Contains(tmpName))
			{
				rec.recipeName = tmpName;
				
				if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', tmpName))
					rec.cookedItemName = tmpName;
				else
					rec.cookedItemName = '';
					
				if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
					rec.typeName = tmpName;
				else
					rec.typeName = '';
				
				if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
					rec.level = tmpInt;
				else
					rec.level = -1;
					
				if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'cookedItemType', tmpString))
					rec.cookedItemType = AlchemyCookedItemTypeStringToEnum(tmpString);
				else
					rec.cookedItemType = EACIT_Undefined;
					
				if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'cookedItemQuantity', tmpInt))
					rec.cookedItemQuantity = tmpInt;
				else
					rec.cookedItemQuantity = -1;
				
				// W3EE - Begin
				if( rec.recipeName == 'Recipe for Albedo' || rec.recipeName == 'Recipe for Rubedo' || rec.recipeName == 'Recipe for Nigredo' )
					continue;
				
				ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');
				rec.requiredIngredients.Clear();
				ingredientCount = ingredients.subNodes.Size() - 1;
				
				for(primaryIndex = alchemyExtender.primarySubstances.Size() - 1; primaryIndex >= 0; primaryIndex -= 1)
				{
					if( alchemyExtender.primarySubstances[primaryIndex].recipeName == rec.recipeName )
					{
						ingredientCount = alchemyExtender.primarySubstances[primaryIndex].requiredIngredients.Size() - 1;
						break;
					}
				}
				for(mutagenIndex = alchemyExtender.mutagens.Size() - 1; mutagenIndex >= 0; mutagenIndex -= 1)
				{
					if( alchemyExtender.mutagens[mutagenIndex].recipeName == rec.recipeName )
					{
						ingredientCount = alchemyExtender.mutagens[mutagenIndex].requiredIngredients.Size() - 1;
						break;
					}
				}					
				for(k = ingredientCount; k >= 0; k -= 1)
				{					
					if( mutagenIndex < 0 && primaryIndex < 0 )
					{
						if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
							ing.itemName = tmpName;
						else
							ing.itemName = '';
							
						if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
							ing.quantity = tmpInt;
						else
							ing.quantity = -1;						
					}
					else if (primaryIndex > -1)
					{
						ing.itemName = alchemyExtender.primarySubstances[primaryIndex].requiredIngredients[k].itemName;
						ing.quantity = alchemyExtender.primarySubstances[primaryIndex].requiredIngredients[k].quantity;
					}
					else if (mutagenIndex > -1)
					{
						ing.itemName = alchemyExtender.mutagens[mutagenIndex].requiredIngredients[k].itemName;
						ing.quantity = alchemyExtender.mutagens[mutagenIndex].requiredIngredients[k].quantity;
					}
					else
						continue;
					
					rec.requiredIngredients.PushBack(ing);						
				}
				// W3EE - End
				
				
				rec.cookedItemIconPath			= dm.GetItemIconPath( rec.cookedItemName );
				
				
				rec.recipeIconPath				= dm.GetItemIconPath( rec.recipeName );

				recipes.PushBack(rec);
				
				
				readRecipes += 1;
				if(readRecipes >= recipesNames.Size())
					break;
			}
		}
	}
	
	private final function GetItemNameWithoutLevelAsString(itemName : name) : string
	{
		var itemStr : string;
		
		itemStr = NameToString(itemName);
		if(StrEndsWith(itemStr, " 1") || StrEndsWith(itemStr, " 2") || StrEndsWith(itemStr, " 3"))
			return StrLeft(itemStr, StrLen(itemStr)-2);
		
		return itemStr;
	}
	
	// W3EE - Begin
	public function CanCookRecipe(recipeName : name, optional ignorePlayerState:bool, optional isAlchemist : bool ) : EAlchemyExceptions
	{
		var adjustedIngredientCount : array<int>;
		var i, j, availableIngredients : int;
		var recipe : SAlchemyRecipe;		
		var itemName : name;
		
		if( !GetRecipe(recipeName, recipe) )
			return EAE_NoRecipe;
		
		if( !ignorePlayerState )
		{
			if (isPlayerMounted) return EAE_CookNotAllowed;
			if (isPlayerInCombat) return EAE_InCombat;
		}		
		
		if( Alchemy().GetIsAmmoMaxed(recipe) )
			return EAE_CannotCookMore;
			
		adjustedIngredientCount.Resize(recipe.requiredIngredients.Size());
		for(i = recipe.requiredIngredients.Size() - 1; i >= 0; i-= 1)
		{
			for(j = i; j >= 0; j -= 1)
			{
				if( recipe.requiredIngredients[i].itemName == recipe.requiredIngredients[j].itemName )
					adjustedIngredientCount[i] += recipe.requiredIngredients[j].quantity;				
			}			
		}	
		
		for(i=0; i<recipe.requiredIngredients.Size(); i+=1)
		{
			availableIngredients = Equipment().GetItemQuantityByNameForCrafting(recipe.requiredIngredients[i].itemName);
			if( recipe.requiredIngredients[i].quantity <= 0 )
				return EAE_NotEnoughIngredients;
			
			if( availableIngredients < recipe.requiredIngredients[i].quantity || availableIngredients < adjustedIngredientCount[i] )
				return EAE_NotEnoughIngredients;		
		}
		
		if( !CampfireManager().CanPerformAlchemy(isAlchemist) && recipe.cookedItemName != 'Bandage' )
			return EAE_CookNotAllowed; 
			
		return EAE_NoException;
	}
	
	public function CookItem(recipe : SAlchemyRecipe, cookedItemName : name, quantity : int)
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();		
		var min, max : SAbilityAttributeValue;
		var ids : array<SItemUniqueId>;
		var items : array<SItemUniqueId>;
		var isPotion, isDistilling : bool;
		var witcher : W3PlayerWitcher;
		var itemToCook : name;
		var isIngredientUniqueMutagen : bool;
		var isDecoctionRecipe : bool;
		
		witcher = GetWitcherPlayer();
		isDistilling = Alchemy().GetIsDistillingPrimarySubstance(recipe.recipeName);
		itemToCook = cookedItemName;
		
		if( dm.IsItemSingletonItem(itemToCook) )
		{
			items = witcher.inv.GetItemsByName(itemToCook);
			if( items.Size() == 1 && witcher.inv.ItemHasTag(items[0], 'NoShow') )
				witcher.inv.RemoveItemTag(items[0], 'NoShow');
				
			ids = witcher.inv.AddAnItem(itemToCook, quantity);
		}		
		else ids = witcher.inv.AddAnItem(itemToCook, quantity);	
		
		//Kolaris - Alchemy EXP
		Experience().AwardAlchemyBrewingXP(ids.Size() * witcher.inv.GetItemQuality(ids[0]), witcher.inv.IsItemPotion(ids[0]), witcher.inv.IsItemOil(ids[0]), witcher.inv.IsItemBomb(ids[0]), isDistilling, witcher.inv.IsItemMutagenPotion(ids[0]), witcher.inv.ItemHasTag(ids[0], 'MutagenIngredient'));
		
		if( witcher.inv.IsItemPotion(ids[0]) || (items.Size() && witcher.inv.IsItemPotion(items[0])) )
			isPotion = true;	
		
		if( isPotion )
			theTelemetry.LogWithLabelAndValue( TE_ITEM_COOKED, itemToCook, 1 );		
		else		
			theTelemetry.LogWithLabelAndValue( TE_ITEM_COOKED, itemToCook, 0 );		
		
		LogAlchemy("Item <<" + itemToCook + ">> cooked x" + recipe.cookedItemQuantity);
	}
	// W3EE - End
	
	
	public function GetRecipes(forceAll : bool) : array<SAlchemyRecipe>
	{
		var ret : array<SAlchemyRecipe>;
		var i, j, cnt : int;
		var checkedRecipe, testedRecipe : string;
		var deletedCheckted : bool;
		var alchemyItems : array<SItemUniqueId>;
		var itemName : name;
		
		
		forceAll = true;
		
		
		if(forceAll)
			return recipes;
		
		alchemyItems = thePlayer.inv.GetAlchemyCraftableItems();
		
		
		
		
		ret.Resize(recipes.Size());
		for(i=0; i<recipes.Size(); i+=1)
		{
			ret[i] = recipes[i];
		}
		
		i=0;
		while(i < ret.Size())
		{
			j=i+1;
			deletedCheckted = false;
			
			
			checkedRecipe = NameToString(ret[i].cookedItemName);
			checkedRecipe = StrLeft(checkedRecipe, StrLen(checkedRecipe)-2);
						
			while(j<ret.Size())	
			{
				
				testedRecipe = NameToString(ret[j].cookedItemName);
				testedRecipe = StrLeft(testedRecipe, StrLen(testedRecipe)-2);
				
				
				if(checkedRecipe == testedRecipe)
				{				
					if(ret[i].level < ret[j].level)
					{
						if(ShouldRemoveRecipe(ret[i].cookedItemName, ret[i].level, alchemyItems))
						{
							
							ret.EraseFast(i);
							deletedCheckted = true;
							break;
						}
					}
					else
					{
						if(ShouldRemoveRecipe(ret[j].cookedItemName, ret[j].level, alchemyItems))
						{
							
							ret.EraseFast(j);
							continue;
						}
					}
				}
				
				
				j+=1;
			}
			
			
			if(!deletedCheckted)
				i+=1;
		}
		
		
		for(i=ret.Size()-1; i>=0; i-=1)
		{
			itemName = ret[i].cookedItemName;
			cnt = thePlayer.inv.GetItemQuantityByName(itemName);
			
			if(cnt <= 0)
				continue;
				
			
			if(ret[i].cookedItemType == EACIT_Potion && StrStartsWith(NameToString(ret[i].typeName), "Decoction"))
			{
				ret.EraseFast(i);
				continue;
			}
			
			
			if(ret[i].level == 3)
			{
				ret.EraseFast(i);
				continue;
			}
			
			
			if(itemName == 'Killer Whale 1' || itemName == 'Trial Potion Kit' || itemName == 'Pops Antidote' || itemName == 'mh107_czart_lure' || StrContains(NameToString(itemName), "Pheromone"))
			{
				ret.EraseFast(i);
				continue;
			}
		}
		
		return ret;
	}
	
	
	private final function ShouldRemoveRecipe(itemName : name, itemLevel : int, alchemyItems : array<SItemUniqueId>) : bool
	{
		var recipeItemType, checkedItemType : string;
		var i : int;
		
		recipeItemType = NameToString(itemName);
		recipeItemType = StrLeft(recipeItemType, StrLen(recipeItemType)-2);
		
		for(i=0; i<alchemyItems.Size(); i+=1)
		{
			checkedItemType = NameToString(thePlayer.inv.GetItemName(alchemyItems[i]));
			checkedItemType = StrLeft(checkedItemType, StrLen(checkedItemType)-2);
			
			if(recipeItemType == checkedItemType)
			{
				if( CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(alchemyItems[i], 'level')) >= itemLevel )
					return true;
			}
		}
		
		return false;
	}
	
	public function GetRequiredIngredients(recipeName : name) : array<SItemParts>
	{
		var rec : SAlchemyRecipe;
		var null : array<SItemParts>;
	
		if(GetRecipe(recipeName, rec))
			return rec.requiredIngredients;
			
		return null;
	}	
}

function getAlchemyRecipeFromName(recipeName : name):SAlchemyRecipe
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var tmpBool : bool;
	var tmpName : name;
	var tmpString : string;
	var tmpInt : int;
	var ing : SItemParts;
	var i,k : int;
	var rec : SAlchemyRecipe;
	
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
		
		if (tmpName == recipeName)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', tmpName))
				rec.cookedItemName = tmpName;
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
				rec.typeName = tmpName;
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
				rec.level = tmpInt;	
			if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'cookedItemType', tmpString))
				rec.cookedItemType = AlchemyCookedItemTypeStringToEnum(tmpString);
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'cookedItemQuantity', tmpInt))
				rec.cookedItemQuantity = tmpInt;
			
			
			ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
			for(k=0; k<ingredients.subNodes.Size(); k+=1)
			{		
				ing.itemName = '';
				ing.quantity = -1;
			
				if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))						
					ing.itemName = tmpName;
				if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
					ing.quantity = tmpInt;
					
				rec.requiredIngredients.PushBack(ing);						
			}
			
			rec.recipeName = recipeName;
			
			
			rec.cookedItemIconPath			= dm.GetItemIconPath( rec.cookedItemName );
			rec.recipeIconPath				= dm.GetItemIconPath( rec.recipeName );
			break;
		}
	}
	
	return rec;
}
