/**
* Called when items are added to the player's inventory.
* Adds those items' names to the facts library if they
* are new relics or new horse gear
* @param inventoryComponent: Player's inventory component.
* @param data: list of items just added to the player's inventory	
*/
function ModNoDuplicatesAddDuplicateItemFact(inventoryComponent : CInventoryComponent, data : SItemChangedData)
{
	var i, j : int;
	var itemUniqueId : SItemUniqueId;

	
	if(inventoryComponent)
	{
		for(i=0; i<data.ids.Size(); i+=1)
		{
			itemUniqueId = data.ids[i];
			
			if(ModNoDuplicatesIsItemDuplicateType(inventoryComponent,itemUniqueId) && !ModNoDuplicatesItemFactsDoesExist(inventoryComponent,itemUniqueId) && inventoryComponent.GetItemModifierInt(itemUniqueId, 'modNoDuplicatesDontAddFact')<1 && !inventoryComponent.ItemHasTag(itemUniqueId,theGame.params.TAG_DONT_SHOW))
			{
				if( inventoryComponent.ItemHasTag(itemUniqueId, 'Artifact_weapon') )
					Equipment().AddArtifactSchematic(itemUniqueId, inventoryComponent);
				FactsAdd('modNoDuplicates'+NameToString(inventoryComponent.GetItemName(itemUniqueId)));
				LogChannel('modNoDuplicates',NameToString(inventoryComponent.GetItemName(itemUniqueId)));
				inventoryComponent.SetItemModifierInt(itemUniqueId,'DontHide',1);
				inventoryComponent.SetItemModifierInt(itemUniqueId,'modNoDuplicatesDontAddFact',1);
				//Kolaris - NextGen Gear
				if( inventoryComponent.ItemHasTag(itemUniqueId, 'TigerSet') || inventoryComponent.ItemHasTag(itemUniqueId, 'ElvenSet') )
				{
					GetWitcherPlayer().SetItemToDamage(itemUniqueId);
					GetWitcherPlayer().AddTimer('DelayedReduceItemDurability', 0.5f);
				}
			}
		}
	}
}

/**
* Scans a given inventory component's items
* and adds their names to the facts library
* if they are a new relic or new horse gear
* @param inventoryComponent: inventory component to scan.	
*/
function ModNoDuplicatesAddInventoryComponentFacts(inventoryComponent: CInventoryComponent)
{
	var i : int;
	var allItems : array< SItemUniqueId >;
	
	inventoryComponent.GetAllItems(allItems);
	
	for ( i=0; i<allItems.Size(); i+=1 )
	{
		if(!inventoryComponent.ItemHasTag(allItems[i],theGame.params.TAG_DONT_SHOW) && ModNoDuplicatesIsItemDuplicateType(inventoryComponent,allItems[i]) && !ModNoDuplicatesItemFactsDoesExist(inventoryComponent,allItems[i]))
		{
			FactsAdd('modNoDuplicates'+NameToString(inventoryComponent.GetItemName(allItems[i])));
			LogChannel('modNoDuplicates',NameToString(inventoryComponent.GetItemName(allItems[i])));
			inventoryComponent.SetItemModifierInt(allItems[i],'DontHide',1);
			inventoryComponent.SetItemModifierInt(allItems[i],'modNoDuplicatesDontAddFact',1);
		}
	}
}	

/**
* Console command to scan the player's inventory for relics and
* and horsegear and add their names to the facts library.
* For use in new game plus where the default player inventory
* and horse inventory/stash scanning behavior is disabled.
*/
exec function ModNoDuplicatesAddInventoryItemFacts()
{
	ModNoDuplicatesAddInventoryComponentFacts(GetWitcherPlayer().GetInventory()); 
	thePlayer.DisplayHudMessage("Added player inventory item facts");
}

/**
* Called at the beginning of a NewGamePlus playthrough,
* adds modifiers to relics and horse gear in a given
* inventory in order to prevent them from registering as
* duplicates
* @param inventoryComponent: inventory component to have 
*							relics& horse gear modified
*/
function ModNoDuplicatesAddInventoryItemsModifiers(inventoryComponent : CInventoryComponent)
{

	var i : int;
	var allItems : array< SItemUniqueId >;
	
	inventoryComponent.GetAllItems(allItems);
	
	for ( i=0; i<allItems.Size(); i+=1 )
	{
		if(!inventoryComponent.ItemHasTag(allItems[i],theGame.params.TAG_DONT_SHOW) && ModNoDuplicatesIsItemDuplicateType(inventoryComponent,allItems[i]))
		{
			inventoryComponent.SetItemModifierInt(allItems[i],'DontHide',1);
			inventoryComponent.SetItemModifierInt(allItems[i],'modNoDuplicatesDontAddFact',1);
		}
	}
}


/**
* Called when the player is about to drop a relic or horse gear piece
* in a bag or sell it in a shop. Add a modifier tag to that item to prevent 
* it from being hidden. In new game plus also adds a modifier tag to prevent it from 
* adding its name to the facts library in case it's bought back/picked up again 
* on the offchance that it's a carried-over NG item.
* @param inventoryComponent: Player's inventory component.	
* @param itemUniqueId: ID of the item that's about to be sold/dropped
*/
function ModNoDuplicatesAddItemAboutToGiveModifiers(inventoryComponent: CInventoryComponent, itemUniqueId : SItemUniqueId)
{
	if(!ModNoDuplicatesIsItemDuplicateType(inventoryComponent,itemUniqueId))
		return;
	else 
		inventoryComponent.SetItemModifierInt(itemUniqueId,'DontHide',1);
	
	if( FactsQuerySum("NewGamePlus") > 0 && !ModNoDuplicatesItemFactsDoesExist(inventoryComponent, itemUniqueId) )
	{
		inventoryComponent.SetItemModifierInt(itemUniqueId,'modNoDuplicatesDontAddFact',1);
	}
}

/**
* Console command to scan the horse inventory/stash/corvo bianco armor stands for relics and
* and horsegear and add their names to the facts library.
* For use in new game plus where the default player inventory
* and horse inventory/stash scanning behavior is disabled.
*/
exec function ModNoDuplicatesAddStashItemFacts()
{
	ModNoDuplicatesAddInventoryComponentFacts(GetWitcherPlayer().GetHorseManager().GetInventoryComponent()); 
	thePlayer.DisplayHudMessage("Added stash inventory item facts");
}

/**
* Scans a container's inventory component's items.
* Hides them if they're relics or horse gear that 
* the player already previously obtained a copy of 
* and adds a coin as a replacement to prevent issues
* with empty containers.
* @param inventoryComponent: a container's inventory component
*							to have its duplicates relics/horse gear replaced
*/
function ModNoDuplicatesHideContainerDuplicates(inventoryComponent: CInventoryComponent)
{
	var addedCoinIds : array<SItemUniqueId>;
	var artifactName : name;
	
	//Kolaris - Artifact Placement
	if(ModNoDuplicatesHideInventoryComponentDuplicates(inventoryComponent))
	//if( ModNoDuplicatesReplaceArtifact(inventoryComponent) )
	{
		artifactName = Equipment().GetRandomArtifactName();
		if( artifactName != '' )
			addedCoinIds = inventoryComponent.AddAnItem(artifactName, 1, false, false, true);
		else
			addedCoinIds = inventoryComponent.AddAnItem(Equipment().GetRandomGemName(),1,false,false,true);
			
		inventoryComponent.AddItemTag(addedCoinIds[0], 'modNoDuplicatesCoin');
	}
}

//Kolaris - Artifact Placement
function ModNoDuplicatesReplaceArtifact(inventoryComponent: CInventoryComponent) : bool
{
	var i : int;
	var allItems : array< SItemUniqueId >;
	var hidDuplicate : bool;
	
	
	if(!inventoryComponent){return false;}
	
	hidDuplicate = false;
	
	inventoryComponent.GetAllItems(allItems);
	
	
	for ( i=0; i<allItems.Size(); i+=1 )
	{
		if(!inventoryComponent.ItemHasTag(allItems[i],theGame.params.TAG_DONT_SHOW) && ModNoDuplicatesIsItemDuplicateType(inventoryComponent,allItems[i]) && inventoryComponent.GetItemModifierInt(allItems[i],'DontHide')<1  && !inventoryComponent.ItemHasTag(allItems[i],'Quest'))
		{
			inventoryComponent.AddItemTag(allItems[i], 'modNoDuplicatesHide');
			inventoryComponent.AddItemTag(allItems[i], theGame.params.TAG_DONT_SHOW);
			hidDuplicate=true;
		}
	}
	
	return hidDuplicate;
}

/**
* Scans an inventory component's items and hides
* them if they're relics or horse gear that 
* the player already previously obtained a copy of 
* @param inventoryComponent: inventory component to have
*							 its duplicates relics/horse gear hidden
* @return true if an item was hidden, false otherwise
*/
function ModNoDuplicatesHideInventoryComponentDuplicates(inventoryComponent: CInventoryComponent):bool
{
	var i : int;
	var allItems : array< SItemUniqueId >;
	var hidDuplicate : bool;
	
	
	if(!inventoryComponent){return false;}
	
	hidDuplicate = false;
	
	inventoryComponent.GetAllItems(allItems);
	
	
	for ( i=0; i<allItems.Size(); i+=1 )
	{
		if(!inventoryComponent.ItemHasTag(allItems[i],theGame.params.TAG_DONT_SHOW) && ModNoDuplicatesIsItemDuplicateType(inventoryComponent,allItems[i]) && ModNoDuplicatesItemFactsDoesExist(inventoryComponent,allItems[i]) && inventoryComponent.GetItemModifierInt(allItems[i],'DontHide')<1  && !inventoryComponent.ItemHasTag(allItems[i],'Quest'))
		{
			inventoryComponent.AddItemTag(allItems[i], 'modNoDuplicatesHide');
			inventoryComponent.AddItemTag(allItems[i], theGame.params.TAG_DONT_SHOW);
			hidDuplicate=true;
		}
	}
	
	return hidDuplicate;
	
}

/**
* Checks if an item in an inventory is
* a relic-level weapon or armor, or horse gear.
* @param inventoryComponent: inventory component that has the item
* @param itemUniqueId: item's ID in its containing inventory
* @return true if the item is a relic or horse gear, false otherwise
*/
function ModNoDuplicatesIsItemDuplicateType(inventoryComponent : CInventoryComponent, itemUniqueId : SItemUniqueId) : bool
{

	return (/*inventoryComponent.ItemHasTag(itemUniqueId,'mod_horse') ||*/ ( (inventoryComponent.ItemHasTag(itemUniqueId,'Weapon') || /*inventoryComponent.ItemHasTag(itemUniqueId,'Armor') ||*/ inventoryComponent.ItemHasTag(itemUniqueId,'Artifact_weapon') )&& inventoryComponent.GetItemQuality(itemUniqueId)==4) ); //W3EE
	
}

/**
* Given an item inside an inventory, checks
* if the if the item's name is already in the facts
* library list of previously acquired relics/horse gear
* @param inventoryComponent: inventory component that has the item
* @param itemUniqueId: item's ID in its containing inventory
* @return true if a similarly named item was already acquired, false otherwise
*/
function ModNoDuplicatesItemFactsDoesExist(inventoryComponent : CInventoryComponent, itemUniqueId : SItemUniqueId): bool
{

	return FactsDoesExist('modNoDuplicates'+NameToString(inventoryComponent.GetItemName(itemUniqueId)));

}

/**
* Called when the player loots a replacement coin
* from a container where that coin was replacing a hidden
* duplicate relic/horse gear. Removes all the previously
* hidden duplicate relics/horse gear inside that container.
* @param inventoryComponent: inventory component to have its
*							hidden duplicates removed
*/
function ModNoDuplicatesRemoveInventoryComponentDuplicates(inventoryComponent : CInventoryComponent)
{
	var i : int;
	var hiddenDuplicates : array< SItemUniqueId >;
	
	if(!inventoryComponent)return;
	
	hiddenDuplicates = inventoryComponent.GetItemsByTag('modNoDuplicatesHide');
	
	for ( i=0; i<hiddenDuplicates.Size(); i+=1 )
	{
		inventoryComponent.NotifyItemLooted(hiddenDuplicates[i]);
		inventoryComponent.RemoveItem(hiddenDuplicates[i]);
	}
	
}