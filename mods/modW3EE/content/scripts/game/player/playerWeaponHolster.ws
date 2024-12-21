/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
statemachine class WeaponHolster
{
	private	saved	var currentMeleeWeapon	: EPlayerWeapon;
	// W3EE - Begin
	private saved	var currentWeaponID		: SItemUniqueId;
	// W3EE - End
	
	protected 		var queuedMeleeWeapon	: EPlayerWeapon;
	protected 		var isQueuedMeleeWeapon	: bool;
	
	protected saved var ownerHandle			: EntityHandle;
	
	public			var automaticUnholster	: bool;			default	automaticUnholster	= true;
	
	protected 		var isMeleeWeaponReady	: bool;
	
	
	
	
	event OnEquipMeleeWeapon( weapontype : EPlayerWeapon, ignoreActionLock : bool, optional sheatheIfAlreadyEquipped : bool, optional forceHolster : bool ){}
	
	event OnEquippedMeleeWeapon( weapontype : EPlayerWeapon ) {}
	
	event OnWeaponDrawReady(){}
	
	event OnWeaponHolsterReady(){}
	
	event OnHolsterLeftHandItem(){}
	
	
	
	
	public function Initialize( _owner : CActor, restored : bool )
	{
		var item : SItemUniqueId;
		
		EntityHandleSet(ownerHandle,_owner);
		if( !restored )
		{
			SetCurrentMeleWeapon( PW_None );
			queuedMeleeWeapon	= PW_None;
			isQueuedMeleeWeapon	= false;
			isMeleeWeaponReady	= true;
			
			
			
			PushState( 'SelectingWeapon' );
		}
		else
		{
			isQueuedMeleeWeapon	= false;
			isMeleeWeaponReady	= true;
			queuedMeleeWeapon	= PW_None;
			
			
			
			
			
			
			PushState( 'SelectingWeapon' );
			
		}
	}
	
	protected function SetCurrentMeleWeapon( weapon : EPlayerWeapon )
	{
		var playerWitcher : W3PlayerWitcher;
		
		if( currentMeleeWeapon != weapon )
		{
			currentMeleeWeapon	= weapon;
			
			// W3EE - Begin
			playerWitcher = (W3PlayerWitcher)EntityHandleGet(ownerHandle);
			Equipment().HandleRelicAbilities(playerWitcher, currentWeaponID, false);
			//Kolaris - Enchantment Overhaul
			Equipment().ManageEnchantmentAbilities(currentWeaponID, playerWitcher.inv.GetEnchantment(currentWeaponID), false);
			playerWitcher.inv.GetItemEntityUnsafe(currentWeaponID).StopAllEffects();
			if( weapon == PW_Steel )
				playerWitcher.inv.GetItemEquippedOnSlot(EES_SteelSword, currentWeaponID);
			else
			if( weapon == PW_Silver )
				playerWitcher.inv.GetItemEquippedOnSlot(EES_SilverSword, currentWeaponID);
			else
				currentWeaponID = GetInvalidUniqueId();
			Equipment().HandleRelicAbilities(playerWitcher, currentWeaponID, true);
			//Kolaris - Enchantment Overhaul
			Equipment().ManageEnchantmentAbilities(currentWeaponID, playerWitcher.inv.GetEnchantment(currentWeaponID), true);
			
			// W3EE - End
			//---=== modFriendlyHUD ===---
			if ( ( weapon == PW_Steel || weapon == PW_Silver ) && GetFHUDConfig().enableCombatModulesOnUnsheathe )
			{
				ToggleCombatModules( true, "OnUnsheathe" );
			}
			else if ( GetFHUDConfig().enableCombatModulesOnUnsheathe )
			{
				ToggleCombatModules( false, "OnUnsheathe" );
			}
			//---=== modFriendlyHUD ===---
		}
	}
	
	public function UpdateRealWeapon()
	{
		var weaponHeld		: EPlayerWeapon;
		
		
		if( thePlayer.IsWeaponHeld( 'fist' ) )
		{
			weaponHeld = PW_Fists;
		}
		else if( thePlayer.IsWeaponHeld( 'silversword' ) )
		{
			weaponHeld = PW_Silver;
		}
		else if( thePlayer.IsWeaponHeld( 'steelsword' ) || thePlayer.IsWeaponHeld( 'playerSecondary' )  )
		{
			weaponHeld = PW_Steel;
		}
		else
		{
			weaponHeld = PW_None;
		}
		
		if( weaponHeld != PW_None && (W3ReplacerCiri)thePlayer  )
		{
			weaponHeld = PW_Steel;
		}
		
		SetCurrentMeleWeapon( weaponHeld );
	}
	
	protected function GetOwner() : CActor
	{
		return (CActor)EntityHandleGet(ownerHandle);
	}
	
	public function HolsterWeapon(ignoreActionLock : bool, optional forceHolster : bool )
	{
		var curWeapon : EPlayerWeapon;
		
		curWeapon	= GetCurrentMeleeWeapon();
		
		if( curWeapon == PW_None )
		{
			return;
		}
		
		DischargePhantomWeapon();
		OnEquipMeleeWeapon( curWeapon, ignoreActionLock, true, forceHolster );
	}
	
	
	event OnForcedHolsterWeapon()
	{
		DischargePhantomWeapon();
		SetCurrentMeleWeapon( PW_None );
		UpdateBehGraph();
	}
	
	public function GetCurrentMeleeWeapon() : EPlayerWeapon
	{
		return currentMeleeWeapon;
	}
	
	public function GetCurrentMeleeWeaponName() : name
	{
		return GetWeaponCategoryName ( currentMeleeWeapon );
	}
	
	public function TryToPrepareMeleeWeaponToAttack() : bool
	{
		if( isMeleeWeaponReady )
		{
			
			thePlayer.RaiseEvent( 'SwitchWeaponEnd' );
		}
		
		return isMeleeWeaponReady;
	}
	
	public function IsOnTheMiddleOfHolstering() : bool
	{
		return !isMeleeWeaponReady;
	}
	
	public function IsMeleeWeaponReady() : bool
	{
		return isMeleeWeaponReady;
	}
	
	public function EndedCombat()
	{
		
		if( GetCurrentMeleeWeapon() == PW_Fists )
		{
			OnEquipMeleeWeapon( PW_None, true );
		}
	}
	
	public function GetMostConvenientMeleeWeapon( targetToDrawAgainst : CActor, optional ignoreActionLock : bool ) : EPlayerWeapon
	{
		var ret : EPlayerWeapon;
		var inv : CInventoryComponent;
		var heldItems	: array<name>;
		var mountedItems	: array<name>;
		var hasPhysicalWeapon, disableAutoSheathe : bool;
		var i : int;
		var npc : CNewNPC;
		var inGameConfigWrapper : CInGameConfigWrapper;
		// W3EE - Begin
		var oppType : EMonsterCategory;
		// W3EE - End
		
		if ( (W3ReplacerCiri)thePlayer  )
		{
			if ( targetToDrawAgainst )
				return PW_Steel;
			else
				return PW_None;
		}
		
		
		
		if( !automaticUnholster )
		{
			return PW_Fists;
		}
		
		
		if ( !targetToDrawAgainst )
		{
			return PW_Fists;
		}
		
		
		targetToDrawAgainst.GetInventory().GetAllHeldAndMountedItemsCategories( heldItems, mountedItems );
		
		if ( heldItems.Size() > 0 )
		{
			for ( i = 0; i < heldItems.Size(); i += 1 )
			{
				if ( heldItems[i] != 'fist' )
				{
					hasPhysicalWeapon = true;
					break;
				}
			}
		}
		
		if ( !hasPhysicalWeapon && targetToDrawAgainst.GetInventory().HasHeldOrMountedItemByTag( 'ForceMeleeWeapon' ) )
		{
			hasPhysicalWeapon = true;
		}
		
		npc = (CNewNPC)targetToDrawAgainst;
		
		if ( targetToDrawAgainst.IsHuman() && ( !hasPhysicalWeapon || ( targetToDrawAgainst.GetAttitude( thePlayer ) != AIA_Hostile ) ) ) 
		{
			ret = PW_Fists;
		}
		else if ( npc.IsHorse() && !npc.GetHorseComponent().IsDismounted() ) 
		{
			ret = PW_Fists;
		}
		else
		{
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
			disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Gameplay', 'DisableAutomaticSwordSheathe' );
			
			if( disableAutoSheathe )
			{
				ret = PW_Fists;
			}
			else
			{
				// W3EE - Begin
				oppType = ((CNewNPC)targetToDrawAgainst).GetOpponentType();
				if( oppType == MC_Specter || oppType == MC_Vampire || oppType == MC_Cursed  )
				{
					ret = PW_Silver;
				}
				else
				{
					ret = PW_Steel;
				}
				/*else
				{
					LogAssert(false, "CR4Player.weaponHolsterSelectWeaponToDraw: target has neither vitality nor essesnce - don't know which weapon to use!");
					ret = PW_Fists;
				}*/
				// W3EE - End
			}
		}
		
		inv = GetOwner().GetInventory();
		if(ret == PW_Steel && !GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
		{
			ret = PW_Fists;
		}
		else if(ret == PW_Silver && !GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
		{
			ret = PW_Fists;
		}
		
		if ( thePlayer.IsWeaponActionAllowed( ret ) || ignoreActionLock )
		{
			return ret;
		}
		else
		{
			return PW_None;
		}
	}	
	
	
	
	
	
	
	protected function IsThisWeaponAlreadyEquipped( weaponType : EPlayerWeapon ) : bool
	{
		
		if ( weaponType == GetCurrentMeleeWeapon() )
		{
			return true;
		}
		
		return false;
	}
	
	
	protected function GetWeaponCategoryName( weaponType : EPlayerWeapon ) : name
	{
		switch( weaponType )
		{
			case PW_Steel:
				return 'steelsword';
			case PW_Silver:
				return 'silversword';
			case PW_Fists :
				return 'fist';
			case PW_None :
			default : 
				return 'None';
		}
	}
	
	protected function DischargePhantomWeapon()
	{
		if( thePlayer.GetPhantomWeaponMgr() )
			thePlayer.GetPhantomWeaponMgr().DischargeWeapon();
	}
	
	
	
	
	
	protected function QueueMeleeWeapon( weapontype : EPlayerWeapon, optional sheatheIfAlreadyEquipped : bool )
	{
		
		if( sheatheIfAlreadyEquipped && ( weapontype == PW_Silver || weapontype == PW_Steel ) )
		{
			
			if( IsThisWeaponAlreadyEquipped( weapontype ) )
			{
				weapontype	= PW_None;
			}
		}
		
		queuedMeleeWeapon	= weapontype;
		isQueuedMeleeWeapon	= true;
	}
	
	protected function IsWeaponQueued() : bool
	{
		return isQueuedMeleeWeapon;
	}
	
	protected function UnqueueMeleeWeapon()
	{
		isQueuedMeleeWeapon	= false;
	}
	
	protected function EquipQueuedMeleeWeaponIfAny() : bool
	{
		if( !isQueuedMeleeWeapon )
		{
			return false;
		}
		
		if( queuedMeleeWeapon == GetCurrentMeleeWeapon() )
		{
			isQueuedMeleeWeapon	= false;
			return false;
		}
		
		
		
		
		OnEquipMeleeWeapon( queuedMeleeWeapon, true );
		
		return true;
	}
	
	function UpdateBehGraph( optional init : bool )
	{
		var weapontype : EPlayerWeapon;
		var item : SItemUniqueId;
		var res : bool;
		var inv : CInventoryComponent;
		var tags : array<name>;
		
		weapontype = GetCurrentMeleeWeapon();
		
		if ( weapontype == PW_None )
		{
			weapontype = PW_Fists;
		}
		
		thePlayer.SetBehaviorVariable( 'WeaponType', 0);
		
		
		if ( !GetWitcherPlayer() && weapontype == PW_Fists && thePlayer.IsInCombat()  )
		{
			thePlayer.SetBehaviorVariable( 'playerWeapon', (int) PW_Steel );
			thePlayer.SetBehaviorVariable( 'playerWeaponForOverlay', (int) PW_Steel );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'playerWeapon', (int) weapontype );
			thePlayer.SetBehaviorVariable( 'playerWeaponForOverlay', (int) weapontype );
		}
		
		if ( thePlayer.IsUsingHorse() )
		{
			thePlayer.SetBehaviorVariable( 'isOnHorse', 1.0 );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'isOnHorse', 0.0 );
		}
		
		if ( GetWitcherPlayer() )
		{
			inv = thePlayer.GetInventory();
			if ( GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item) )
			{
				inv.GetItemTags(item,tags);
				if ( tags.Contains('SecondaryWeapon') )
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',1.f );
				else
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',0.f );
			}
			else
			{
				item = inv.GetItemFromSlot('r_weapon');
				inv.GetItemTags(item,tags);
				if ( inv.IsIdValid(item) && tags.Contains('SecondaryWeapon') )
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',1.f );
				else
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',0.f );
			}
		}
		
		switch ( weapontype )
		{
			case PW_Steel:
				thePlayer.SetBehaviorVariable( 'SelectedWeapon', 0, true);
				thePlayer.SetBehaviorVariable( 'isHoldingWeaponR', 1.0, true );
				if ( init )
					res = thePlayer.RaiseEvent('DrawWeaponInstant');
				break;
			case PW_Silver:
				thePlayer.SetBehaviorVariable( 'SelectedWeapon', 1, true);
				thePlayer.SetBehaviorVariable( 'isHoldingWeaponR', 1.0, true );
				if ( init )
					res = thePlayer.RaiseEvent('DrawWeaponInstant');
				break;
			default:
				thePlayer.SetBehaviorVariable( 'isHoldingWeaponR', 0.0, true );
				break;
		}
	}
	
	function UpdateScabbardsBehGraph()
	{
		var weapontype : EPlayerWeapon;
		var scabbardsComp : CAnimatedComponent;
		
		weapontype = GetCurrentMeleeWeapon();
		scabbardsComp = (CAnimatedComponent)( thePlayer.GetComponent( "scabbards_skeleton" ) );
		
		switch ( weapontype )
		{
			case PW_Steel:
				scabbardsComp.SetBehaviorVariable( 'isHoldingWeaponR', 1.f );
				break;
			case PW_Silver:
				scabbardsComp.SetBehaviorVariable( 'isHoldingWeaponR', 1.f );
				break;
			default:
				scabbardsComp.SetBehaviorVariable( 'isHoldingWeaponR', 0.f );
				break;
		}
	}
}


state SelectingWeapon in WeaponHolster
{
	event OnEquipMeleeWeapon( weapontype : EPlayerWeapon, ignoreActionLock : bool, optional sheatheIfAlreadyEquipped : bool, optional forceHolster : bool )
	{
		var canWeEquipNow : bool;
		
		
		
		
		
		canWeEquipNow	= parent.isMeleeWeaponReady;		
		if( canWeEquipNow && !ignoreActionLock && !thePlayer.IsWeaponActionAllowed( weapontype ) )
		{
			canWeEquipNow	= false;
		}
		
		
		if( canWeEquipNow )
		{
			EquipMeleeWeapon( weapontype, sheatheIfAlreadyEquipped );
		}
		
		else if ( ignoreActionLock )
		{
			parent.QueueMeleeWeapon( weapontype, sheatheIfAlreadyEquipped );
		}
	}
	
	event OnEquippedMeleeWeapon( weaponType : EPlayerWeapon )
	{
		// W3EE - Begin
		var witcher : W3PlayerWitcher;
		var item : SItemUniqueId;
		var weaponEnt : CEntity;
		var effectType : name;
		var signType : ESignType;
		// W3EE - End
		
		if( weaponType == PW_Steel || weaponType == PW_Silver )
		{
			thePlayer.ResumeOilBuffs( weaponType == PW_Steel );
			// W3EE - Begin
			//thePlayer.PlayRuneword4FX(weaponType);
			
			witcher = GetWitcherPlayer();
			
			if( weaponType == PW_Steel )
			{
				witcher.inv.GetItemEquippedOnSlot(EES_SteelSword, item);
				witcher.ResumeRepairBuffs(item);
			}
			else
			{
				witcher.inv.GetItemEquippedOnSlot(EES_SilverSword, item);
				witcher.ResumeRepairBuffs(item);
			}
			weaponEnt = witcher.inv.GetItemEntityUnsafe(item);
			
			//Kolaris - Invocation
			if( witcher.inv.GetEnchantment(item) == 'Runeword 40' || witcher.inv.GetEnchantment(item) == 'Runeword 41' || witcher.inv.GetEnchantment(item) == 'Runeword 42' )
			{
				weaponEnt.StopEffect('runeword_aard');
				weaponEnt.StopEffect('runeword_axii');
				weaponEnt.StopEffect('runeword_igni');
				weaponEnt.StopEffect('runeword_quen');
				weaponEnt.StopEffect('runeword_yrden');
				
				signType = witcher.GetRunewordInfusionType();
				
				if(signType == ST_Aard)
					effectType = 'runeword_aard';
				else if(signType == ST_Axii)
					effectType = 'runeword_axii';
				else if(signType == ST_Igni)
					effectType = 'runeword_igni';
				else if(signType == ST_Quen)
					effectType = 'runeword_quen';
				else if(signType == ST_Yrden)
					effectType = 'runeword_yrden';
				
				if( signType != ST_None )
					weaponEnt.PlayEffect(effectType);
			}
			//Kolaris - Assassination
			else
			if( witcher.inv.GetEnchantment(item) == 'Runeword 36' )
			{
				weaponEnt.StopEffect('bereavement_glow');
				weaponEnt.PlayEffect('bereavement_glow');
			}
			//Kolaris - Runeword Old Enchantment Fx
			/*else
			if( witcher.inv.GetEnchantment(item) == 'Runeword 4' && !Options().DisableSpecialSwordFx() )
			{
				weaponEnt.StopEffect('runeword_igni');
				weaponEnt.PlayEffect('runeword_igni');
			}
			else
			if( witcher.inv.GetEnchantment(item) == 'Runeword 12' || witcher.inv.GetEnchantment(item) == 'Runeword 11' && !Options().DisableSpecialSwordFx() )
			{
				weaponEnt.StopEffect('bereavement_glow');
				weaponEnt.PlayEffect('bereavement_glow');
			}*/
			thePlayer.GetBuff( EET_LynxSetBonus ).Resume( 'drawing weapon' );
		}
		//Kolaris - Aerondight Silver
		if( weaponType == PW_Silver )
		{
			thePlayer.ManageAerondightBuff( true );
		}
		// W3EE - End
		
		if ( parent.GetCurrentMeleeWeapon() != weaponType || weaponType == PW_Fists || weaponType == PW_None )
		{
			parent.UnqueueMeleeWeapon();
			parent.SetCurrentMeleWeapon( weaponType );
			parent.UpdateBehGraph();
			thePlayer.SetBehaviorVariable( 'playerWeaponLatent', thePlayer.GetBehaviorVariable( 'playerWeapon' ) );
		}
		
		if( weaponType == PW_None )
		{
			thePlayer.AddTimer( 'DelayedTryToReequipWeapon', 0.0f, false );
		}
	}
	
	event OnHolsterLeftHandItem()
	{
		HolsterLeftHandItem();
	}
	
	entry function EquipMeleeWeapon( weapontype : EPlayerWeapon, optional sheatheIfAlreadyEquipped : bool )
	{
		var isAWeapon	: bool;
		var fists : W3PlayerWitcherStateCombatFists;
		var item : SItemUniqueId;
		var items : array<SItemUniqueId>;
		var owner : CActor; 
		
		
		if( thePlayer.GetCurrentStateName() == 'PlayerDialogScene' )
		{
			return;
		}	
		
		
		
		thePlayer.SetBehaviorVariable( 'holsterReadyToSkip', 0.0f, true );
		
		
		parent.UnqueueMeleeWeapon( );
		
		
		isAWeapon	= weapontype == PW_Silver || weapontype == PW_Steel;	
		
		
		if( parent.IsThisWeaponAlreadyEquipped( weapontype ) )
		{
			if( sheatheIfAlreadyEquipped && isAWeapon )
			{
				if( thePlayer.IsInCombat() )
				{
					weapontype	= PW_Fists;
				}
				else
				{
					weapontype	= PW_None;
				}
				isAWeapon	= false;
			}
			else
			{
				return;
			}
		}	
		
		owner = parent.GetOwner();
		
		
		fists = ((W3PlayerWitcherStateCombatFists)owner.GetState('Combat'));
		if( fists )
		{
			fists.comboPlayer.StopAttack();
		}
		
		parent.SetCurrentMeleWeapon( weapontype );	
		
		Lock();
		
		parent.UpdateBehGraph();
		
		switch( weapontype )
		{
			case PW_None :
				thePlayer.SetRequiredItems('Any', 'None');
				thePlayer.ProcessRequiredItems();
				break;
			case PW_Fists : 
				if ( !thePlayer.inv.HasItem('Geralt fists') && !thePlayer.IsFistFightMinigameEnabled() )
				{
					thePlayer.inv.AddAnItem( 'Geralt fists', 1, true, true, false );
				}
				thePlayer.SetRequiredItems('Any', 'fist' );
				thePlayer.ProcessRequiredItems();
				break;
			case PW_Steel:
				if( GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item) )
				{
					thePlayer.DrawItemsLatent(item);
				}
				else if ( (W3ReplacerCiri)thePlayer )
				{
					items = thePlayer.GetInventory().GetItemsByName(theGame.params.CIRI_SWORD_NAME);
					if ( items.Size() > 0 )
					{
						thePlayer.DrawItemsLatent(items[0]);
					}
				}
				break;
			case PW_Silver:
				if( GetWitcherPlayer().GetItemEquippedOnSlot( EES_SilverSword, item) )
				{
					thePlayer.DrawItemsLatent(item);
				}
				break;
		}
		
		parent.UpdateRealWeapon();
		
		Unlock();		
		parent.SetCurrentMeleWeapon( weapontype );		
	}	
	
	entry function HolsterLeftHandItem()
	{
		Lock();
		
		
		thePlayer.SetRequiredItems( 'None', 'Any' );
		
		thePlayer.ProcessRequiredItems();
		
		Unlock();
	}
	
	event OnWeaponDrawReady()
	{
		
		Unlock();
		
		SignalDrawSwordAction();
		
		thePlayer.SetBehaviorVariable( 'holsterReadyToSkip', 1.0f, true );
		thePlayer.SetBehaviorVariable( 'playerWeaponLatent', thePlayer.GetBehaviorVariable( 'playerWeapon' ) );
	}
	event OnWeaponHolsterReady()
	{
		
		Unlock();
		
		SignalHolsterSwordAction();
		
		parent.DischargePhantomWeapon();
		
		thePlayer.SetBehaviorVariable( 'holsterReadyToSkip', 1.0f, true );
		thePlayer.SetBehaviorVariable( 'playerWeaponLatent', thePlayer.GetBehaviorVariable( 'playerWeapon' ) );
	}
	 
	 private latent function HideUsableItemL ()
	{
		while ( true )
		{
			if ( !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.OnUseSelectedItem( true );
				return;
			}
			Sleep( 0.01f );
		}
	}
	private function SignalDrawSwordAction()
	{
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'DrawSwordAction', -1, 8.0f, -1, 9999, true); 
	}
	
	private function SignalHolsterSwordAction()
	{
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'HolsterSwordAction', -1, 8.0f, -1, 9999, true); 
	}
	 
	private function Lock()
	{
		var actionBlockingExceptions : array<EInputActionBlock>;
		var horseComp : W3HorseComponent;
		
		
		
		
		
		
		
		
		
		actionBlockingExceptions.PushBack(EIAB_Movement);
		actionBlockingExceptions.PushBack(EIAB_RunAndSprint);
		actionBlockingExceptions.PushBack(EIAB_Signs);
		actionBlockingExceptions.PushBack(EIAB_CallHorse);
		actionBlockingExceptions.PushBack(EIAB_Jump);
		
		actionBlockingExceptions.PushBack(EIAB_Roll);		
		actionBlockingExceptions.PushBack(EIAB_Dodge);
		actionBlockingExceptions.PushBack(EIAB_Climb);
		actionBlockingExceptions.PushBack(EIAB_Slide);
		actionBlockingExceptions.PushBack(EIAB_ThrowBomb);
		actionBlockingExceptions.PushBack(EIAB_Crossbow);
		actionBlockingExceptions.PushBack(EIAB_UsableItem);
		actionBlockingExceptions.PushBack(EIAB_RadialMenu);
		actionBlockingExceptions.PushBack(EIAB_OpenInventory);
		actionBlockingExceptions.PushBack(EIAB_OpenCharacterPanel);
		actionBlockingExceptions.PushBack(EIAB_MeditationWaiting);
		actionBlockingExceptions.PushBack(EIAB_OpenMap);
		actionBlockingExceptions.PushBack(EIAB_OpenJournal);
		actionBlockingExceptions.PushBack(EIAB_OpenAlchemy);
		actionBlockingExceptions.PushBack(EIAB_OpenGlossary);
		actionBlockingExceptions.PushBack(EIAB_OpenGwint);
		actionBlockingExceptions.PushBack(EIAB_ExplorationFocus);
		actionBlockingExceptions.PushBack(EIAB_Sprint);
		actionBlockingExceptions.PushBack(EIAB_OpenMeditation);
		actionBlockingExceptions.PushBack(EIAB_QuickSlots);
		thePlayer.BlockAllActions( 'WeaponHolster', true, actionBlockingExceptions, false);
		
		
		parent.isMeleeWeaponReady	= false;
		
		horseComp = thePlayer.GetUsedHorseComponent();
		
		if ( horseComp )
		{
			horseComp.GetUserCombatManager().OnMeleeWeaponNotReady();
		}
	}
	
	private function Unlock()
	{
		var horseComp : W3HorseComponent;
		
		parent.UpdateScabbardsBehGraph();
		
		
		
		
		thePlayer.BlockAllActions( 'WeaponHolster', false);
		
		
		parent.isMeleeWeaponReady	= true;
		
		horseComp = thePlayer.GetUsedHorseComponent();
		
		if ( horseComp )
		{
			horseComp.GetUserCombatManager().OnMeleeWeaponReady();
		}
		
		
		
		
		
		parent.EquipQueuedMeleeWeaponIfAny();
	}
	
	timer function HideUsableItemLTimer ( dt : float, id : int )
	{
		if ( thePlayer.IsHoldingItemInLHand () )
		{
			if ( !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.OnUseSelectedItem( true );
				
			}
		}
	}
	
}
