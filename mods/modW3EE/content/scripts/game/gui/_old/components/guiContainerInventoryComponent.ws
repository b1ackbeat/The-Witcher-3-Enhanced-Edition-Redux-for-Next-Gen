/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
abstract class W3CommonContainerInventoryComponent extends W3GuiBaseInventoryComponent
{
	

	public function GiveAllItems( receiver : W3GuiBaseInventoryComponent )
	{
		
	
		
		
	}
		
	public function GetItemActionType( item : SItemUniqueId, optional bGetDefault : bool) : EInventoryActionType
	{
		return IAT_Transfer;
	}	

	public function HideAllItems( ) : void 
	{
		var i : int;
		var item : SItemUniqueId;
		var rawItems : array< SItemUniqueId >;
		var itemTags : array<name>;
		
		_inv.GetAllItems( rawItems );
		
		for ( i = 0; i < rawItems.Size(); i += 1 )
		{		
			item = rawItems[i];
			itemTags.Clear();
			_inv.GetItemTags( item, itemTags );
		
			if ( !itemTags.Contains( 'NoShowInContainer' ) )
			{
				_inv.AddItemTag(item,'NoShowInContainer');
			}
		}
	}
	
	protected function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		var itemTags : array<name>;
		
		_inv.GetItemTags( item, itemTags );
		
		
		if ( itemTags.Contains( 'NoShowInContainer' ) )
		{
			return false;
		}
		
		return super.ShouldShowItem( item );
	}
}

class W3GuiTakeOnlyContainerInventoryComponent extends W3CommonContainerInventoryComponent
{	
	public function ReceiveItem( item : SItemUniqueId, giver : W3GuiBaseInventoryComponent, optional quantity : int, optional newItemID : SItemUniqueId ) : bool
	{

		return false;
	}
}



class W3GuiContainerInventoryComponent extends W3CommonContainerInventoryComponent 
{
	// W3EE - Begin
	//public var dontShowEquipped:bool; default dontShowEquipped = false;
	public var syncWithPlayer : bool; default syncWithPlayer = false;
	public var playerTabIndex : int; default playerTabIndex = -1;
	
	public function ReceiveItem( item : SItemUniqueId, giver : W3GuiBaseInventoryComponent, optional quantity : int, optional newItemID : SItemUniqueId  ) : bool 
	{
		var invalidatedItems, newIds : array< SItemUniqueId >;
		var newItem : SItemUniqueId;
		var success: bool;
		var itemName : name;
		
		if( quantity  < 1 )
		{
			quantity = 1;
		}
		success = false;
		itemName = giver._inv.GetItemName(item);
		
		giver._inv.RemoveItem(item,quantity); 
		newIds = _inv.AddAnItem(itemName,quantity,true,true);
		newItem = newIds[0];
		if ( newItem != GetInvalidUniqueId() )
		{
			success = true;
		}
		
		return success;
	}
	
	protected function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		/*if (dontShowEquipped)
		{
			if (isHorseItem(item))
			{
				if (GetWitcherPlayer().GetHorseManager().IsItemEquipped(item))
				{
					return false;
				}
			}
			else
			{
				if ( _inv == GetWitcherPlayer().GetInventory() && GetWitcherPlayer().IsItemEquipped(item))
				{
					return false;
				}
			}
		}*/
		
		if( syncWithPlayer && playerTabIndex != -1 )
		{
			if( GetTabForItem( item ) != playerTabIndex )
			{
				return false;
			}
		}
		
		return super.ShouldShowItem( item );
	}
	
	function GetTabForItem( item : SItemUniqueId ) : int
	{
		var isJunk, isTrophy : bool;
		
		isTrophy = _inv.IsItemTrophy( item );
		isJunk = ( !isItemReadable(item) && !isFoodItem(item) && !isIngredientItem( item ) && !isWeaponItem( item ) && !isArmorItem( item ) && !isAlchemyItem( item ) && !isUpgradeItem( item ) && !isItemSchematic( item ) && !isToolItem(item) && !isHorseItem( item ) && !isTrophy );
		
		if( isIngredientItem( item ) && !IsItemDye( item ) )
		{
			return 0;
		}
		if( isQuestItem( item ) || ( ( isJunk || isItemReadable( item ) ) && !isQuickslotItem( item ) && !isTrophy ) )
		{
			return 1;
		}
		if( isFoodItem( item ) || isHorseItem( item ) )
		{
			return 2;
		}
		if( isWeaponItem( item ) || _inv.ItemHasTag(item, 'WeaponTab') || isArmorItem( item ) || isUpgradeItem( item ) || isToolItem( item ) || isItemUsable( item ) || isQuickslotItem( item ) || IsItemDye( item ) )
		{
			return 4;
		}
		if( isAlchemyItem( item ) && !isFoodItem( item ) && !isItemUsable( item ) && !IsItemDye( item ) )
		{
			return 3;
		}
		return 4;
	}
	// W3EE - End
	
	protected function GridPositionEnabled() : bool
	{
		return false;
	}
}


