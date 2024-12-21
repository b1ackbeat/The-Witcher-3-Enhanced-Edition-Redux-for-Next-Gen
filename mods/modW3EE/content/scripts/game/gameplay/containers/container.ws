/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




import class W3Container extends W3LockableEntity 
{
	editable 			var isDynamic				: bool;					
																			
	editable 			var skipInventoryPanel		: bool;					
	editable saved		var focusModeHighlight		: EFocusModeVisibility;
	editable			var factOnContainerOpened	: string;
						var usedByCiri				: bool;
	editable			var allowToInjectBalanceItems : bool;
					default allowToInjectBalanceItems = false;					
	editable			var disableLooting			: bool;
	
	editable			var disableStealing			: bool;
					default	disableStealing			= true;
	
	protected saved 	var checkedForBonusMoney	: bool;					
	public	  saved 	var addedBonusHerbs			: bool;					
	
	private	saved		var	usedByClueStash 		: EntityHandle;
	private 			var disableFocusHighlightControl : bool;		
					default disableFocusHighlightControl = false;

	protected optional autobind 	inv							: CInventoryComponent = single;
	protected optional autobind 	lootInteractionComponent 	: CInteractionComponent = "Loot";
	protected var isPlayingInteractionAnim : bool; default isPlayingInteractionAnim = false;
	private const var QUEST_HIGHLIGHT_FX : name;							
	private saved var spoonCollectorTested : bool;
	
	// W3EE - Begin
	private var wasContainerChanged : bool;
	private var wasSpecial : bool;
	
	//Kolaris - Artifact Placement
	private saved var wasArtifactContainer	: bool;
	private saved var artifactCommentCooldown : bool;
	default wasArtifactContainer = false;
	default artifactCommentCooldown = false;

	hint skipInventoryPanel = "If set then the inventory panel will not be shown upon looting";
	hint isDynamic = "set to true if you want to destroy container when empty";
	hint focusModeHighlight = "FMV_Interactive: White, FMV_Clue: Red";
	
	default wasSpecial = false;
	default wasContainerChanged = false;
	// W3EE - End
	default skipInventoryPanel = false;	
	default usedByCiri = false;	
	default focusModeHighlight = FMV_Interactive;
	default QUEST_HIGHLIGHT_FX = 'quest_highlight_fx';
	default disableLooting = false;
	
	import function SetIsQuestContainer( isQuest : bool );
	
	private const var SKIP_NO_DROP_NO_SHOW : bool;
	default SKIP_NO_DROP_NO_SHOW = true;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{		
		EnableVisualDebug( SHOW_Containers, true );
		super.OnSpawned(spawnData);
		
		
		if(disableLooting)
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( FMV_None );
			}
			StopQuestItemFx();
			if( lootInteractionComponent )
			{
				lootInteractionComponent.SetEnabled(false);
			}
			CheckLock();
		}
		else
		{
			UpdateContainer();
		}
	}
	
		
	event OnStreamIn()
	{
		
		super.OnStreamIn();
		
		UpdateContainer();
		
		//Kolaris - Artifact Placement
		if( IsArtifactContainer() )
		{
			UpdateContainer();
			RebalanceItems();
			RemoveUnwantedItems();
			CheckArtifacts();
		}
		
	}
	
	event OnSpawnedEditor( spawnData : SEntitySpawnData )
	{
		EnableVisualDebug( SHOW_Containers, true );
		super.OnSpawned( spawnData );	
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		frame.DrawText( GetName(), GetWorldPosition() + Vector( 0, 0, 1.0f ), Color( 255, 0, 255 ) );
		frame.DrawSphere( GetWorldPosition(), 1.0f, Color( 255, 0, 255 ) );
		return true;
	}
	
	function UpdateFactItems()
	{
		var i,j : int;
		var items : array<SItemUniqueId>;
		var tags : array<name>;
		var factName : string;
		
		
		if( inv && !disableLooting)
		{
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			tags.Clear();
			inv.GetItemTags(items[i], tags);	
			for(j=0; j<tags.Size(); j+=1)
			{
				factName = StrAfterLast(NameToString(tags[j]), "fact_hidden_");
				if(StrLen(factName) > 0)
				{
					if(FactsQuerySum(factName) > 0)
					{
						inv.RemoveItemTag(items[i], theGame.params.TAG_DONT_SHOW);
					}
					else
					{
						inv.AddItemTag(items[i], theGame.params.TAG_DONT_SHOW);
					}
						
					break;
				}
			}
		}
	}
	
	function InjectItemsOnLevels()
	{
		
	}
	
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		//Kolaris - Artifact Placement
		if( !IsArtifactContainer() )
		{
			UpdateContainer();
			RebalanceItems();
			RemoveUnwantedItems();
		}
		if ( DisableIfEmpty() )
		{
			
			return false;
		}
		
		super.OnInteractionActivated(interactionComponentName, activator);
		if(activator == thePlayer)
		{
			if ( inv && !disableLooting)
			{
				inv.UpdateLoot();
				if(!checkedForBonusMoney)
				{
					checkedForBonusMoney = true;
					CheckForBonusMoney(0);
				}
			}
			if(!disableLooting && (!thePlayer.IsInCombat() || IsEnabledInCombat()) )
				HighlightEntity();
			
			//Kolaris - Artifact Placement
			if ( (interactionComponentName == "Medallion" && isMagicalObject) || IsArtifactContainer() )
				SenseMagic();
			
			if( (!IsEmpty() && !disableLooting) || lockedByKey)	
			{
				ShowInteractionComponent();
			}
		}
	}
	
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionDeactivated(interactionComponentName, activator);
		
		if(activator == thePlayer)
		{
			UnhighlightEntity();
		}
	}
	
	
	public final function IsEnabledInCombat() : bool
	{
		if( !lootInteractionComponent || disableLooting)
		{
			return false;
		}
		
		return lootInteractionComponent.IsEnabledInCombat();
	}
	
	public function InformClueStash()
	{
		var clueStash : W3ClueStash;
		clueStash = ( W3ClueStash )EntityHandleGet( usedByClueStash );
		if( clueStash )
		{
			clueStash.OnContainerEvent();
		}
	}
	
	event OnItemGiven(data : SItemChangedData)
	{
		super.OnItemGiven(data);
		
		if(isEnabled)
			UpdateContainer();
			
		InformClueStash();
	}
	
	function ReadSchematicsAndRecipes()
	{
	}
	
	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		super.OnItemTaken(itemId, quantity);
		
		if(!HasQuestItem())
		{
			StopQuestItemFx();
		}
		
		//modNoDuplicates - Begin
		if(inv.ItemHasTag(itemId,'modNoDuplicatesCoin'))
			ModNoDuplicatesRemoveInventoryComponentDuplicates(inv);
		//modNoDuplicates - End
		
		//Kolaris - Artifact Placement
		if( inv.ItemHasTag(itemId,'Artifact_weapon') )
		{
			wasArtifactContainer = true;
		}
		
		InformClueStash();
	}
	
	event OnUpdateContainer()
	{
		
	}
	
	public function RequestUpdateContainer()
	{
		UpdateContainer();
	}
	
	// W3EE - Begin
	private function IsSpecialContainer() : bool
	{
		if( wasSpecial || GetInventory().HasItemByTag('Quest') || HasSpecialItem() || focusModeHighlight == FMV_Clue || factOnContainerOpened != "" || IsLocked() || isDynamic )
			return true;
			
		return false;	
	}

	private function CheckSpecialStatusChange()
	{
		if( !wasSpecial && IsSpecialContainer() )
		{
			UnhideContainerItems();
			wasSpecial=true;
		}
	}
	
	private function HideContainerItems()
	{
		var inv	: CInventoryComponent = GetInventory();
		var items : array<SItemUniqueId>;
		var id : SItemUniqueId;
		var i : int;
		
		inv.GetAllItems(items);
		wasContainerChanged = true;
		for(i=0; i<items.Size(); i+=1)
		{
			if( !(inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW)) && !(inv.ItemHasTag(items[i], 'hiddenItemW3EE')) ) 
			{
				inv.AddItemTag(items[i], theGame.params.TAG_DONT_SHOW);
				inv.AddItemTag(items[i], 'hiddenItemW3EE');
			}
		}
	}
	
	private function UnhideContainerItems()
	{
		var inv	: CInventoryComponent = GetInventory();
		var allItems : array<SItemUniqueId>;
		var i : int;
		
		wasContainerChanged = false;
		allItems = inv.GetItemsByTag(theGame.params.TAG_DONT_SHOW);
		for(i=0; i<allItems.Size(); i+=1)
		{
			inv.RemoveItemTag(allItems[i], theGame.params.TAG_DONT_SHOW);
			inv.RemoveItemTag(allItems[i], 'hiddenItemW3EE');
		}
	}
	
	private function HasSpecialItem() : bool
	{
		var inv	: CInventoryComponent = GetInventory();
		var items : array<SItemUniqueId>;
		var i : int;
		
		if( HasQuestItem() )
			return true; 
		
		items = inv.GetItemsByName('Crowns');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) ) 
				return true;
		}
		
		items = inv.GetItemsByCategory('gwint');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('ReadableItem'); 
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('mod_crafting');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('mod_alchemy');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('mod_valuable'); 
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('Weapon');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) && !FactsDoesExist('modNoDuplicates' + NameToString(inv.GetItemName(items[i]))) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('Armor');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) && !FactsDoesExist('modNoDuplicates' + NameToString(inv.GetItemName(items[i]))) ) 
				return true;
		}
		
		items = inv.GetItemsByTag('mod_horse');
		for(i=0; i<items.Size(); i+=1)
		{
			if( !inv.ItemHasTag(items[i], theGame.params.TAG_DONT_SHOW) && !FactsDoesExist('modNoDuplicates' + StrReplace(NameToString(inv.GetItemName(items[i])), '_crafted', "")) )
				return true;
		}
		
		return false;
	}
	
	private function IsDecorativeContainer(): bool
	{
		var meshComps : array<CComponent>;
		var meshComp : CMeshComponent;
		var i : int;
		var hadMesh : bool = false;
		var contInv	: CInventoryComponent = GetInventory();
		var allItems : array<SItemUniqueId>;
		
		if( IsSpecialContainer() )
		{
			if( !wasSpecial )
				UnhideContainerItems();
				
			wasSpecial = true;
			return false;
		}
		
		if( StrContains(ToString(), "levels\novigrad\quests\sq305_scoiatael\phase_1\scoiatael\waypoints\sq305_scoiatael_attack.w2l") )
		{
			wasSpecial = true;
			return false;
		}
		
		meshComps = GetComponentsByClassName('CMeshComponent');
		for(i=0; i<meshComps.Size(); i+=1)
		{
			meshComp = (CMeshComponent)meshComps[i];
			if( meshComp )
			{
				hadMesh = true;
				if(
					//TRASHY FURNITURE VELEN WHITE ORCHARD VIZIMA
					   StrFindFirst(meshComp.mesh,"\barrel_closed_rope.w2mesh") >= 0	
					|| StrFindFirst(meshComp.mesh,"\bundle.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\crate_cloth.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\sack.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\simple_cupboard.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\crate_cage.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\crate.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_tall.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\washtub_large.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\wall_shelf_board.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\shelf_medium.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\platform_side_plank_whole1.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\platform_side_plank_whole2.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\tool_rack_wall.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_short.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\baron_tallboy_bottom_open.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\medium_simple_cupboard.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\fish_basket_2.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\barrel_closed_metal.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\sack_with_holes.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\fish_crate.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\sack_carry.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\detailed_dresser_base_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\decorated_bookshelf_big_double.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\big_decorative_cupboard_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\decorated_bookshelf_small_double.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\detailed_dresser_rich_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\medium_decorative_cupboard_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\basic_bookshelf_med_simple.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\small_simple_cupboard_door_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\simple_dresser_drawer_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\medium_simple_cupboard_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\crate_rope.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\shipping_crate_box_old.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\boxes_crate_e.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\boxes_crate_d.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\boxes_crate_f.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_small.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\barrel_closed_metal_dirty.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\crate_snow.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\wall_shelf_large.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\barrel_shelf.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\barrel_broken_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\fish_basket_1.w2mesh") >= 0
					
					//KAER MORHEN
					|| StrFindFirst(meshComp.mesh,"\shipping_crate_box.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\basic_bookshelf_big_double.w2mesh") >= 0
					
					//NOVIGRAD
					|| StrFindFirst(meshComp.mesh,"\rich_shelves_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\basic_bookshelf_med_double.w2mesh") >= 0
					
					//SKELLIGE
					|| StrFindFirst(meshComp.mesh,"\wardrobe_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\barrel_closed_metal_snow.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\crate_cage_snow.w2mesh") >= 0
					
					//OXENFURT
					|| StrFindFirst(meshComp.mesh,"\decorated_bookshelf_med_double.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\decorated_bookshelf_small_simple.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\simple_dresser_table.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\chest_shelf.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\sack_grain.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\stone_coffin_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\stone_coffin_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\stone_coffin_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\stone_coffin_d.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_shelves_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\baron_tallboy_bottom.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\decorated_bookshelf_big_simple.w2mesh") >= 0
					
					//TOUSSAINT
					|| StrFindFirst(meshComp.mesh,"\gen_barrel_closed_rope.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_barrel_closed_metal.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cupboard_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cupboard_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cupboard_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cupboard_d.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_a.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_c.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_d.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_cloth_barrel_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_commode_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_commode_b.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\poor_commode_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_commode_d.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_commode_e.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_commode_f.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_basket_tall.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_crate_open_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_crate_open_b.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\gen_crate_open_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_crate_close_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_crate_close_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_shelf_tall_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_bundle.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_wall_shelf_g.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cabinet_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cabinet_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_sack_open_c.w2mesh") >= 0 //grain sack
					|| StrFindFirst(meshComp.mesh,"\gen_sack_closed.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_sack_carry.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_cabinet_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_barrel_destroyed_a.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\gen_barrel_destroyed_b.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\gen_barrel_destroyed_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\poor_box_a_close.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\poor_box_b_close.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\bob_catacombs_altar_01.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\bob_catacombs_altar_02.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_large_pot_e.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_cloth_pile_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_cloth_pile_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_cloth_pile_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\gen_stone_coffin.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\q703_item__wooden_hammer.w2mesh") >= 0 //vanishing hammer used during "Wine is Sacred" quest
					
					//TOUSSAINT RICH FURNITURE
					|| StrFindFirst(meshComp.mesh,"\rich_shelf_tall_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_shelf_tall_b.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\rich_shelf_tall_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_shelf_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_cupboard_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_cupboard_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_cupboard_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_cupboard_d.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_side_table_a.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_side_table_b.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_side_table_c.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_side_table_d.w2mesh") >= 0 //assumed
					|| StrFindFirst(meshComp.mesh,"\rich_side_table_e.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_side_table_f.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\rich_wardrobe_a.w2mesh") >= 0
					
					//QUESTIONABLE SMALL CHESTS
					|| StrFindFirst(meshComp.mesh,"\medium_circular_chest_body.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\metal_casket_rusty.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\old_chest_small_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\small_round_chest.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\small_round_chest_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\medium_circular_chest_container.w2mesh") >= 0
					|| StrFindFirst(meshComp.mesh,"\drakkar_chest.w2mesh") >= 0
					
					//QUESTIONABLE SMALL CHESTS TOUSSAINT
					|| StrFindFirst(meshComp.mesh,"\poor_chest_a_close.w2mesh") >= 0 //kinda shitty looking
					|| StrFindFirst(meshComp.mesh,"\poor_chest_b_close.w2mesh") >= 0 //medium shitty looking
					|| StrFindFirst(meshComp.mesh,"\poor_chest_c_close.w2mesh") >= 0 //looks like shit
				)
				return true;
			}
		}
		
		if( hadMesh )
			wasSpecial = true;
			
		return false;	
	}
	
	protected final function UpdateContainer()
	{
		var medalion		: CComponent;
		var foliageComponent : CSwitchableFoliageComponent;
		var itemCategory : name;
		
		foliageComponent = ( CSwitchableFoliageComponent ) GetComponentByClassName( 'CSwitchableFoliageComponent' );
		
		if(!disableLooting)
			UpdateFactItems();
		
		if( inv && !disableLooting )
		{
			inv.UpdateLoot();
		}
		
		if( !theGame.IsActive() || (inv && !disableLooting && !inv.IsEmpty(false)) )
			CheckSpecialStatusChange();
		
		if ( !theGame.IsActive() || ( inv && !disableLooting && isEnabled && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) ) )
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( focusModeHighlight );
			}
			AddTag('HighlightedByMedalionFX');
			
			if ( foliageComponent )
				foliageComponent.SetAndSaveEntry( 'full' );
			else
				ApplyAppearance("1_full");			
				
			if( HasQuestItem() )
			{
				SetIsQuestContainer( true );
				PlayQuestItemFx();
			}
			
			if( IsDecorativeContainer() )
				HideContainerItems();
		}
		else
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( FMV_None );
			}
			
			
			if ( !isEnabled && inv && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) )
			{
				if ( foliageComponent && !disableLooting )
					foliageComponent.SetAndSaveEntry( 'full' );
				else
					ApplyAppearance("1_full");						
			}
			else
			{
				if ( foliageComponent && !disableLooting )
					foliageComponent.SetAndSaveEntry( 'empty' );
				else
				if( !wasContainerChanged || inv.IsEmpty(false) )
					ApplyAppearance("2_empty");
			}
				
			StopQuestItemFx();
		}
		
		if ( !isMagicalObject ) 
		{
			medalion = GetComponent("Medallion");
			if(medalion)
			{
				medalion.SetEnabled( false );
			}
		}
		
		if(lootInteractionComponent)
		{
			if(disableLooting)
			{
				lootInteractionComponent.SetEnabled(false);
			}
			else
			{
				lootInteractionComponent.SetEnabled( inv && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) ) ; 
			}
		}
		
		if(!disableLooting)
			OnUpdateContainer();
			
		CheckForDimeritium();
		CheckLock();
		
	}
	// W3EE - End
	
	function RebalanceItems()
	{
		var i : int;
		var items : array<SItemUniqueId>;
	
		if( inv && !disableLooting)
		{
			inv.AutoBalanaceItemsWithPlayerLevel();
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			
			if ( inv.GetItemModifierInt(items[i], 'ItemQualityModified') > 0 )
					continue;
					
			inv.AddRandomEnhancementToItem(items[i]);
		}
	}
	
	protected final function HighlightEntity()
	{
		isHighlightedByMedallion = true;
	}
	
	protected final function UnhighlightEntity()
	{
		StopEffect('medalion_detection_fx');
		StopEffect('medalion_fx');
		isHighlightedByMedallion = false;
	}
	
	public final function HasQuestItem() : bool
	{
		if( !inv || disableLooting)
		{
			return false;
		}			

		return inv.HasQuestItem();
	}
	
	public function CheckForDimeritium()
	{
		if (inv && !disableLooting)
		{
			if ( inv.HasItemByTag('Dimeritium'))
			{
				if (!this.HasTag('Potestaquisitor')) this.AddTag('Potestaquisitor');
			}
			else
			{
				if (this.HasTag('Potestaquisitor')) this.RemoveTag('Potestaquisitor');
			}
		}
		else
		{
			if (this.HasTag('Potestaquisitor')) this.RemoveTag('Potestaquisitor');
		}
	}
	
	
	public final function OnTryToGiveItem( itemId : SItemUniqueId ) : bool 
	{
		return true; 
	}
	
	
	//Loud Loot Fix
	public function TakeAllItems(optional j : int)
	{
		var allItems	: array< SItemUniqueId >;
		var ciriEntity  : W3ReplacerCiri;
		var i, quantity : int;
		var itemsCategories : array< name >;
		var category : name;
		var playerInv, horseInv : CInventoryComponent;
		
		playerInv = thePlayer.inv;
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		
		if( !inv || !playerInv )
		{
			return;
		}
		
		inv.GetAllItems( allItems );

		LogChannel( 'ITEMS___', ">>>>>>>>>>>>>> TakeAllItems " + allItems.Size() );
		
		for(i=0; i<allItems.Size(); i+=1)
		{						
			if( inv.ItemHasTag(allItems[i], 'Lootable' ) || !inv.ItemHasTag(allItems[i], 'NoDrop') && !inv.ItemHasTag(allItems[i], theGame.params.TAG_DONT_SHOW))
			{
				//Kolaris - Mutation EXP
				if( !(this.HasTag('lootbag')) && inv.ItemHasTag(allItems[i], 'MutagenIngredient') )
					Experience().AwardAlchemyBrewingXP(1, false, false, false, false, false, true);
				
				//Kolaris - Artifact Placement
				if( inv.ItemHasTag(allItems[i],'Artifact_weapon') )
					wasArtifactContainer = true;
				
				inv.NotifyItemLooted( allItems[ i ] );
				
				if( inv.ItemHasTag(allItems[i], 'HerbGameplay') )
				{
					category = 'herb';
				}
				else
				{
					category = inv.GetItemCategory(allItems[i]);
				}
				
				if( itemsCategories.FindFirst( category ) == -1 )
				{
					itemsCategories.PushBack( category );
				}
				if( inv.IsItemSingletonItem(allItems[i]) )
					quantity = inv.SingletonItemGetAmmo(allItems[i]);
				else
					quantity = inv.GetItemQuantity(allItems[i]);
					
				if( inv.ShouldHorseLootItem(allItems[i]) && horseInv.HorseCanTakeItem(allItems[i], quantity, inv) )
					inv.GiveItemTo( horseInv, allItems[i], quantity, true, false, true );
				else
					inv.GiveItemTo( playerInv, allItems[i], quantity, true, false, true );
			}
		}
		if(!j || j==0)
		{
		if( itemsCategories.Size() == 1 )
		{
			PlayItemEquipSound(itemsCategories[0]);
		}
		else
		{
			PlayItemEquipSound('generic');
		}
		
		LogChannel( 'ITEMS___', "<<<<<<<<<<<<<< TakeAllItems");
		}
		
		InformClueStash();
	}
	//Loud Loot Fix
	
	public function Unlock( )
	{
		if( IsNameValid(keyItemName) && removeKeyOnUse )
		{
			
			SetIsQuestContainer( true );
		}
		super.Unlock();
	}
	
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var processed : bool;
		var i,j : int;
		var m_schematicList, m_recipeList : array< name >;
		var itemCategory : name;
		var attr : SAbilityAttributeValue;
		
		if ( activator != thePlayer || isInteractionBlocked || IsEmpty() )
			return false;
			
		if ( activator == (W3ReplacerCiri)thePlayer )
		{
			skipInventoryPanel = true;
			usedByCiri = true;
		}
		
		if ( StrLen( factOnContainerOpened ) > 0 && !FactsDoesExist ( factOnContainerOpened ) && ( actionName == "Container" || actionName == "Unlock" ) )
		{
			FactsAdd ( factOnContainerOpened, 1, -1 );
		}
		
		
		m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
		m_schematicList = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			AddWolfNewGamePlusSchematics();
			KeepWolfWitcherSetSchematics(m_schematicList);
		}
		
		
		ProcessSpoonCollector( activator );		
		
		InjectItemsOnLevels();
		
		processed = super.OnInteraction(actionName, activator);
		if(processed)
			return true;		
							
		if(actionName != "Container" && actionName != "GatherHerbs")
			return false;		
					
		ProcessLoot ();
		
		return true;
	}
	
	function RemoveUnwantedItems()
	{
		var allItems : array< SItemUniqueId >;
		var i,j : int;
		var m_schematicList, m_recipeList : array< name >;
		var itemName : name;
		
		//modNoDuplicates - Begin
		if(!((W3SwordStand)this) && !((W3ArmorStand)this))
			ModNoDuplicatesHideContainerDuplicates(inv);
		//modNoDuplicates - End
		
		if ( !HasTag('lootbag') )
		{
			m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
			m_schematicList  = GetWitcherPlayer().GetCraftingSchematicsNames();

			inv.GetAllItems( allItems );
			for ( i=0; i<allItems.Size(); i+=1 )
			{
				itemName = inv.GetItemName( allItems[i] );
			
				if ( GetWitcherPlayer().GetLevel() - 1 > 1 && inv.GetItemLevel( allItems[i] ) == 1 && inv.ItemHasTag(allItems[i], 'Autogen') )
				{ 
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_steel_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_silver_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_armor_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_pants_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_gloves_base');
					inv.GenerateItemLevel(allItems[i], false);
				}
				
				
				if ( inv.GetItemCategory(allItems[i]) == 'gwint' )
				{
					inv.ClearGwintCards();
				}
				
				if(inv.IsItemSingletonItem(allItems[i]))
				{
					inv.SingletonItemSetAmmo(allItems[i], 0);
					inv.SingletonItemAddAmmo(allItems[i], 1);
					inv.UpdateLoot();
				}
			}
		}
	}
	
	function ProcessLoot()
	{
		if(disableLooting)
			return;
		
		//Plasticmetal - LootTweak ++		
		if(skipInventoryPanel || usedByCiri || ((W3Herb)this && !Options().GetUseHerbAnimation() ) ) 
		{
			
			if( !thePlayer.IsAnyWeaponHeld() && !thePlayer.IsHoldingItemInLHand() )
				thePlayer.RaiseEvent('LootHerb');
			

			if((W3Herb)this && !usedByCiri)
				Equipment().LootHerb(this);
			else
		//Plasticmetal - LootTweak --
			TakeAllItems();
			OnContainerClosed();			
		}
		else
		{
			ShowLoot();
		}
	}
	
	private function KeepWolfWitcherSetSchematics(out m_schematicList : array< name >)
	{
		var index : int;
		
		
		index = m_schematicList.FindFirst('Wolf Armor schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Gloves schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Pants schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Boots schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf School steel sword schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf School silver sword schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
	}
	
	private function AddWolfNewGamePlusSchematics()
	{
		var allItems		: array< SItemUniqueId >;
		var m_schematics	: array< name >;
		var i	 			: int;
		var itemName		: name;
		
		inv.GetAllItems( allItems );
		m_schematics  = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		for ( i=0; i<allItems.Size(); i+=1 )
		{	
			itemName = inv.GetItemName( allItems[i] );
		
			
			if ( itemName == 'Wolf Armor schematic' && !inv.HasItem('NGP Wolf Armor schematic') && m_schematics.FindFirst('NGP Wolf Armor schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Armor schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Jacket Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Jacket Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Jacket Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 3', 1, true, true);
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf Gloves schematic' && !inv.HasItem('NGP Wolf Gloves schematic') && m_schematics.FindFirst('NGP Wolf Gloves schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Gloves schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Gloves Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Gloves Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Gloves Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 3', 1, true, true);
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf Pants schematic' && !inv.HasItem('NGP Wolf Pants schematic') && m_schematics.FindFirst('NGP Wolf Pants schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Pants schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Pants Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Pants Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Pants Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 3', 1, true, true);
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf Boots schematic' && !inv.HasItem('NGP Wolf Boots schematic') && m_schematics.FindFirst('NGP Wolf Boots schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Boots schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Boots Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Boots Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Boots Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 3', 1, true, true);	
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf School steel sword schematic' && !inv.HasItem('NGP Wolf School steel sword schematic') && m_schematics.FindFirst('NGP Wolf School steel sword schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School steel sword Upgrade schematic 1' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 1') && m_schematics.FindFirst('NGP Wolf School steel sword Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School steel sword Upgrade schematic 2' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 2') && m_schematics.FindFirst('NGP Wolf School steel sword Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School steel sword Upgrade schematic 3' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 3') && m_schematics.FindFirst('NGP Wolf School steel sword Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 3', 1, true, true);	
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf School silver sword schematic' && !inv.HasItem('NGP Wolf School silver sword schematic') && m_schematics.FindFirst('NGP Wolf School silver sword schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School silver sword Upgrade schematic 1' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 1') && m_schematics.FindFirst('NGP Wolf School silver sword Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School silver sword Upgrade schematic 2' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 2') && m_schematics.FindFirst('NGP Wolf School silver sword Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School silver sword Upgrade schematic 3' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 3') && m_schematics.FindFirst('NGP Wolf School silver sword Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 3', 1, true, true);	
				SetIsQuestContainer( true );
			}
		}
	}
	
	
	private final function ProcessSpoonCollector( activator : CEntity)
	{
		var contentsOk : bool;
		var i, weapons, armors, alchemy, food, crafting : int;
		var items : array<SItemUniqueId>;
		var owner : CActor;
		var tags : array< name >;
		
		
		
		if( spoonCollectorTested )
		{
			return;
		}
		
		
		if( !( (W3PlayerWitcher)activator ) || !GetWitcherPlayer().GetHorseManager().IsItemEquippedByName( 'q702_wicht_trophy' ) )
		{
			return;
		}
		
		spoonCollectorTested = true;
		
		
		if( HasQuestItem() || HasTag('Quest') || HasTag('quest') )
		{
			return;
		}
		
		
		if( RandF() > 0.1f )
		{
			return;
		}
		
		
		if( HasTag( 'lootbag' ) )
		{
			return;
		}		
		
		
		owner = ( ( W3ActorRemains )this ).GetOwner();		
		if( owner )
		{
			tags = owner.GetTags();
			if( tags.Contains( 'animal' ) )
			{
				return;
			}
		}
	
		
		inv.GetAllItems( items );		
		
		
		
		
		contentsOk = false;
		for( i=0; i<items.Size(); i+=1 )
		{
			if( ( inv.IsItemJunk( items[i] ) || inv.IsItemUpgrade( items[i] ) || inv.IsItemTool( items[i] ) || inv.IsItemHorseItem( items[i] ) || inv.IsItemDye( items[i] ) ) && !inv.IsItemReadable( items[i] ) )
			{
				contentsOk = true;
				break;
			}
			
			if( !weapons && inv.IsItemWeapon( items[i] ) )
			{
				weapons = 1;
			}
			else if( !armors && inv.IsItemAnyArmor( items[i] ) )
			{
				armors = 1;
			}
			else if( !alchemy && inv.IsItemAlchemyIngredient( items[i] ) )
			{
				alchemy = 1;
			}
			else if( !food && inv.IsItemFood( items[i] ) )
			{
				food = 1;
			}
			else if( !crafting && inv.IsItemCraftingIngredient( items[i] ) )
			{
				crafting = 1;
			}
			
			if( weapons + armors + alchemy + food + crafting >= 2 )
			{
				contentsOk = true;
				break;
			}			
		}
		
		if( !contentsOk )
		{
			return;
		}
		
		AddSpoons();
	}
	
	private final function AddSpoons( optional dontAddMultiple : bool )
	{
		var spoonType : int;
		var spoonName : name;
		
		spoonType = RandRange(100);
		
		if( spoonType > 70 )
		{
			spoonName = 'Spoon wooden';
		}
		else if( spoonType > 40 )
		{
			spoonName = 'Spoon wooden 2';
		}
		else if( spoonType > 30 )
		{
			spoonName = 'Spoon metal';
		}
		else if( spoonType > 20 )
		{
			spoonName = 'Spoon metal 2';
		}
		else if( spoonType > 15 )
		{
			spoonName = 'Spoon silver';
		}
		else if( spoonType > 10 )
		{
			spoonName = 'Spoon silver 2';
		}
		else if( spoonType > 5 )
		{
			spoonName = 'Spoon gold';
		}
		else
		{
			spoonName = 'Spoon gold 2';
		}
		
		inv.AddAnItem( spoonName, 1, true, true, false );
		
		
		if( !dontAddMultiple && RandRange(100) < 10 )
		{
			AddSpoons( true );
		}
	}
	
	event OnStateChange( newState : bool )
	{
		if( lootInteractionComponent )
		{
			lootInteractionComponent.SetEnabled( newState );
		}
		
		super.OnStateChange( newState );
	}
	
    public final function ShowLoot()
    {
        var lootData : W3LootPopupData;
        // W3EE - Begin
        if( !GetWitcherPlayer().GetAnimManager().PerformLootingAnimation(this) )
        {
            lootData = new W3LootPopupData in this;
            
            lootData.targetContainer = this;
            
            theGame.RequestPopup('LootPopup', lootData);
        }
        // W3EE - End        
    }
	
	public function IsEmpty() : bool				{ return !inv || inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ); }
	
	public function Enable(e : bool, optional skipInteractionUpdate : bool, optional questForcedEnable : bool)
	{
		if( !(e && questForcedEnable) )
		{
			
			if(e && IsEmpty() )
			{
				return;
			}
			else
			{
				UpdateContainer();
			}
		}
		
		super.Enable(e, skipInteractionUpdate);
	}
	
	
	public function OnContainerClosed()
	{
		if(!HasQuestItem())
			StopQuestItemFx();
		
		DisableIfEmpty();
	}
	
	private function DisableIfEmpty() : bool
	{
		if(IsEmpty())
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( FMV_None );
			}
			
			RemoveTag('HighlightedByMedalionFX');
			
			
			UnhighlightEntity();
			
			
			Enable(false);
			
			// W3EE - Begin
			if( !wasContainerChanged || inv.IsEmpty(false) )
				ApplyAppearance("2_empty");
			// W3EE - End
			
			if(isDynamic)
			{
				Destroy();
				return true;
			}
		}
		return false;
	}
	
	
	protected final function CheckForBonusMoney(oldMoney : int)
	{
		var money, bonusMoney : int;
		
		if( !inv )
		{
			return;
		}
		
		money = inv.GetMoney() - oldMoney;
		if(money <= 0)
		{
			return;
		}
			
		bonusMoney = RoundMath(money * CalculateAttributeValue(thePlayer.GetAttributeValue('bonus_money')));
		if(bonusMoney > 0)
		{
			inv.AddMoney(bonusMoney);
		}
	}
	
	public final function PlayQuestItemFx()
	{
		PlayEffectSingle(QUEST_HIGHLIGHT_FX);
	}
	
	public final function StopQuestItemFx()
	{
		StopEffect(QUEST_HIGHLIGHT_FX);
	}
	
	public function GetSkipInventoryPanel():bool
	{
		return skipInventoryPanel;
	}
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return inv && !disableLooting && isEnabled && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW );
	}
	
	public function RegisterClueStash( clueStash : W3ClueStash )
	{
		EntityHandleSet( usedByClueStash, clueStash );
	}
	
	//Kolaris - Artifact Placement
	private function IsArtifactContainer() : bool
	{
		if( StrContains(ToString(), "gameplay\containers\_container_definitions\_unique_containers\_artifact_containers") && !( StrContains(ToString(), "ironbound_chest_container__treasure__q2__novigrad") && FactsQuerySum("mq3037_opened_once") > 0 ) )
			return true;
		else
			return false;
	}
	
	private timer function ResetCommentCooldown( dt : float, id : int)
	{
		artifactCommentCooldown = false;
	}
	
	private function CheckArtifacts()
	{
		var i : int;
		var items : array<SItemUniqueId>;
		var artifactFound : bool;
		
		if( inv )
		{
			//theGame.GetGuiManager().ShowNotification("Artifact Nearby");
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			//theGame.witcherLog.AddMessage("Item: " + GetLocStringByKeyExt(inv.GetItemLocalizedNameByUniqueID(items[i])));
			if ( inv.ItemHasTag(items[i],'Artifact_weapon') && !inv.ItemHasTag(items[i],'modNoDuplicatesHide') )
			{
				artifactFound = true;
				focusModeHighlight = FMV_Clue;
				SetFocusModeVisibility(FMV_Clue);
			}
		}
		
		if( artifactFound && !IsEmpty() && !disableLooting )
		{
			theGame.VibrateControllerLight(); 
			GetWitcherPlayer().GetMedallion().Activate( true, 5.0f );
			if ( !Options().DisableArtifactChatter() && !artifactCommentCooldown && !GetWitcherPlayer().IsSpeaking() && !GetWitcherPlayer().IsCombatMusicEnabled() && !GetWitcherPlayer().IsInNonGameplayCutscene() && !GetWitcherPlayer().IsInGameplayScene() && !theGame.IsDialogOrCutscenePlaying() && !theGame.IsCurrentlyPlayingNonGameplayScene() )
			{
				thePlayer.PlayVoiceset( 100, "MiscInvestigateArea" );
				artifactCommentCooldown = true;
				AddTimer('ResetCommentCooldown', 60.f);
			}
		}
	}	
}
