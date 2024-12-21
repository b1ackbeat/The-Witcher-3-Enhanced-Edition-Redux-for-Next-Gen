/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
import class CWitcherSword extends CItemEntity
{
	var runeCount : int;
	editable var padBacklightColor : Vector;
	private var waterColliderComp : CComponent;
	
	hint padBacklightColor = "PS4 backlight color. R,G,B [0-1]";
	
	import public function GetSwordType() : EWitcherSwordType;
	
	public function Initialize( actor : CActor )
	{
		var stateName : name;
		var swordCategory : name;
		var swordType : EWitcherSwordType;
		var newRuneCount : int;
		var oilBuff : W3Effect_Oil;
		var invComp : CInventoryComponent;
		var itemId : SItemUniqueId;
		
		swordType = GetSwordType();
		switch ( swordType )
		{
			case WST_Silver:
			{
				swordCategory = 'silversword';
				break;
			}
			case WST_Steel:
			{
				swordCategory = 'steelsword';
				break;
			}
		}
		
		invComp = actor.GetInventory();
		itemId = invComp.GetItemByItemEntity( this );
		
		
		runeCount = invComp.GetItemEnhancementCount( itemId );
		UpdateEnhancements( invComp );
		
		stateName = actor.GetCurrentStateName();
		
		if( ( swordType == WST_Silver && stateName == 'CombatSilver' ) || ( swordType == WST_Steel && stateName == 'CombatSteel' ) )
		{
			PlayEffect( 'rune_blast_loop' );
		}
		else
		{
			PlayEffect( 'rune_blast_long' );
		}
		
		waterColliderComp = GetComponent("sword_water_collider");
		if(waterColliderComp)
			waterColliderComp.SetEnabled(false);
	}
	
	event OnItemEnhanced()
	{
		var inv : CInventoryComponent;
		var myItemId : SItemUniqueId;
		var newRuneCount : int;
		
		inv = (CInventoryComponent)( ((CActor)GetParentEntity()).GetComponentByClassName( 'CInventoryComponent' ) );
		myItemId = inv.GetItemByItemEntity( this );
		
		newRuneCount = inv.GetItemEnhancementCount( myItemId );
		UpdateEnhancements( inv );
		
		PlayEffect('rune_blast_loop');
	}
	
	event OnGrab()
	{
		super.OnGrab();
		
		Initialize( (CActor)GetParentEntity() );
		GetWitcherPlayer().ResetPadBacklightColor();
		
		if(waterColliderComp)
			waterColliderComp.SetEnabled(true);
	}
	
	event OnPut()
	{
		super.OnPut();
		
		StopAllEffects();
		GetWitcherPlayer().ResetPadBacklightColor( true );
		
		if(waterColliderComp)
			waterColliderComp.SetEnabled(false);
	}
	
	public function ApplyOil( oilAbilityName : name )
	{
		PlayEffect( GetOilFxName( oilAbilityName ) );
	}
	
	public function RemoveOil( oilAbilityName : name )
	{
		var inv : CInventoryComponent;
		var id : SItemUniqueId;
		var oil : W3Effect_Oil;
		
		
		
		PlayEffect( 'oil_none' );
		
		
		inv = ( ( CActor ) GetParentEntity() ).GetInventory();
		id = inv.GetItemByItemEntity( this );
		oil = inv.GetNewestOilAppliedOnItem( id, true );
		
		if( oil )
		{
			ApplyOil( oil.GetOilAbilityName() );
		}
	}
	
	public function GetOilFxName( oilName : name ) : name
	{
		var oilFx : name;
		
		switch ( oilName )
		{	
			//W3EE - Begin
			/*
			case 'BeastOil_1':
			case 'BeastOil_2':
			case 'BeastOil_3':
			*/
			case 'BrownOil_1':
			case 'BrownOil_2':
			case 'BrownOil_3':
			{
				oilFx = 'oil_beast';
				break;
			}
			
			case 'CursedOil_1':
			case 'CursedOil_2':
			case 'CursedOil_3':
			case 'FlammableOil_1':
			case 'FlammableOil_2':
			case 'FlammableOil_3':
			{
				oilFx = 'oil_cursed';
				break;
			}
			
			/*
			case 'HangedManVenom_1':
			case 'HangedManVenom_2':
			case 'HangedManVenom_3':
			*/
			case 'PoisonousOil_1':
			case 'PoisonousOil_2':
			case 'PoisonousOil_3':
			{
				oilFx = 'oil_venom';
				break;
			}
			
			/*
			case 'HybridOil_1':
			case 'HybridOil_2':
			case 'HybridOil_3':
			{
				oilFx = 'oil_hybrid';
				break;
			}
			
			case 'InsectoidOil_1':
			case 'InsectoidOil_2':
			case 'InsectoidOil_3':
			*/
			case 'CorrosiveOil_1':
			case 'CorrosiveOil_2':
			case 'CorrosiveOil_3':
			{
				oilFx = 'oil_insectoid';
				break;
			}
			
			/*
			case 'MagicalsOil_1':
			case 'MagicalsOil_2':
			case 'MagicalsOil_3':
			*/
			case 'EtherealOil_1':
			case 'EtherealOil_2':
			case 'EtherealOil_3':
			{
				oilFx = 'oil_magical';
				break;
			}
			
			/*
			case 'NecrophageOil_1':
			case 'NecrophageOil_2':
			case 'NecrophageOil_3':
			{
				oilFx = 'oil_necrophage';
				break;
			}
			
			case 'SpecterOil_1':
			case 'SpecterOil_2':
			case 'SpecterOil_3':
			*/
			case 'RimingOil_1':
			case 'RimingOil_2':
			case 'RimingOil_3':
			{
				oilFx = 'oil_specter';
				break;
			}
			
			/*
			case 'VampireOil_1':
			case 'VampireOil_2':
			case 'VampireOil_3':
			*/
			case 'FalkaOil_1':
			case 'FalkaOil_2':
			case 'FalkaOil_3':
			{
				oilFx = 'oil_vampire';
				break;
			}
			
			/*
			case 'DraconideOil_1':
			case 'DraconideOil_2':
			case 'DraconideOil_3':
			
			{
				oilFx = 'oil_draconide';
				break;
			}
			
			case 'OgreOil_1':
			case 'OgreOil_2':
			case 'OgreOil_3':						
			*/
			case 'ParalysisOil_1':
			case 'ParalysisOil_2':
			case 'ParalysisOil_3':
			{
				oilFx = 'oil_ogre';
				break;
			}
			
			/*
			case 'RelicOil_1':
			case 'RelicOil_2':
			case 'RelicOil_3':
			*/
			case 'SilverOil_1':
			{
				oilFx = 'oil_relic';
				break;
			}
			//W3EE - End
		}
		return oilFx;
	}
	
	public function GetRuneFxName( runeName : name ) : name
	{
		var runeFx : name;
		
		switch ( runeName )
		{	
			case 'Rune stribog lesser':
			case 'Rune stribog':
			case 'Rune stribog greater':
			{
				runeFx = 'rune_stribog';
				break;
			}
			case 'Rune dazhbog lesser':
			case 'Rune dazhbog':
			case 'Rune dazhbog greater':
			{
				runeFx = 'rune_dazhbog';
				break;
			}
			case 'Rune devana lesser':
			case 'Rune devana':
			case 'Rune devana greater':
			{
				runeFx = 'rune_devana';
				break;
			}
			case 'Rune zoria lesser':
			case 'Rune zoria':
			case 'Rune zoria greater':
			{
				runeFx = 'rune_zoria';
				break;
			}
			case 'Rune morana lesser':
			case 'Rune morana':
			case 'Rune morana greater':
			{
				runeFx = 'rune_morana';
				break;
			}
			case 'Rune triglav lesser':
			case 'Rune triglav':
			case 'Rune triglav greater':
			{
				runeFx = 'rune_triglav';
				break;
			}
			case 'Rune svarog lesser':
			case 'Rune svarog':
			case 'Rune svarog greater':
			{
				runeFx = 'rune_svarog';
				break;
			}
			case 'Rune veles lesser':
			case 'Rune veles':
			case 'Rune veles greater':
			{
				runeFx = 'rune_veles';
				break;
			}
			case 'Rune perun lesser':
			case 'Rune perun':
			case 'Rune perun greater':
			{
				runeFx = 'rune_perun';
				break;
			}
			case 'Rune elemental lesser':
			case 'Rune elemental':
			case 'Rune elemental greater':
			{
				runeFx = 'rune_elemental';
				break;
			}
			case 'Rune pierog lesser':
			case 'Rune pierog':
			case 'Rune pierog greater':
			{
				runeFx = 'rune_pierog';
				break;
			}
			case 'Rune tvarog lesser':
			case 'Rune tvarog':
			case 'Rune tvarog greater':
			{
				runeFx = 'rune_tvarog';
				break;
			}
		}
		return runeFx;
	}

	public function GetRuneLevel( count : int ) : name
	{
		var runeLvl : name;

		switch ( count )
		{	
			case 0:
			{
				runeLvl = 'rune_lvl0';
				break;
			}
			case 1:
			{
				runeLvl = 'rune_lvl1';
				break;
			}
			case 2:
			{
				runeLvl = 'rune_lvl2';
				break;
			}
			case 3:
			{
				runeLvl = 'rune_lvl3';
				break;
		}
		}
		return runeLvl;
	}
	
	
	public function GetEnchantmentFxName( runeName : name ) : name
	{
		var enchantmentFx : name;
		
		//Kolaris - Enchantment Overhaul
		switch ( runeName )
		{	
			case 'Runeword 1':
			{
				enchantmentFx = 'rune_zoria';
				break;
			}
			case 'Runeword 2':
			{
				enchantmentFx = 'rune_zoria';
				break;
			}
			case 'Runeword 3':
			{
				enchantmentFx = 'rune_zoria';
				break;
			}
			case 'Runeword 4':
			{
				enchantmentFx = 'rune_zoria';
				break;
			}
			case 'Runeword 5':
			{
				enchantmentFx = 'rune_zoria';
				break;
			}
			case 'Runeword 6':
			{
				enchantmentFx = 'rune_zoria';
				break;
			}
			case 'Runeword 7':
			{
				enchantmentFx = 'rune_dazhbog';
				break;
			}
			case 'Runeword 8':
			{
				enchantmentFx = 'rune_dazhbog';
				break;
			}
			case 'Runeword 9':
			{
				enchantmentFx = 'rune_dazhbog';
				break;
			}
			case 'Runeword 10':
			{
				enchantmentFx = 'rune_dazhbog';
				break;
			}
			case 'Runeword 11':
			{
				enchantmentFx = 'rune_dazhbog';
				break;
			}
			case 'Runeword 12':
			{
				enchantmentFx = 'rune_dazhbog';
				break;
			}
			case 'Runeword 13':
			{
				enchantmentFx = 'rune_morana';
				break;
			}
			case 'Runeword 14':
			{
				enchantmentFx = 'rune_morana';
				break;
			}
			case 'Runeword 15':
			{
				enchantmentFx = 'rune_morana';
				break;
			}
			case 'Runeword 16':
			{
				enchantmentFx = 'rune_morana';
				break;
			}
			case 'Runeword 17':
			{
				enchantmentFx = 'rune_morana';
				break;
			}
			case 'Runeword 18':
			{
				enchantmentFx = 'rune_morana';
				break;
			}
			case 'Runeword 19':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 20':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 21':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 22':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 23':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 24':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 25':
			{
				enchantmentFx = 'rune_svarog';
				break;
			}
			case 'Runeword 26':
			{
				enchantmentFx = 'rune_svarog';
				break;
			}
			case 'Runeword 27':
			{
				enchantmentFx = 'rune_svarog';
				break;
			}
			case 'Runeword 28':
			{
				enchantmentFx = 'rune_svarog';
				break;
			}
			case 'Runeword 29':
			{
				enchantmentFx = 'rune_svarog';
				break;
			}
			case 'Runeword 30':
			{
				enchantmentFx = 'rune_svarog';
				break;
			}
			case 'Runeword 31':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 32':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 33':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 34':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 35':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 36':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 37':
			{
				enchantmentFx = 'rune_perun';
				break;
			}
			case 'Runeword 38':
			{
				enchantmentFx = 'rune_perun';
				break;
			}
			case 'Runeword 39':
			{
				enchantmentFx = 'rune_perun';
				break;
			}
			case 'Runeword 40':
			{
				enchantmentFx = 'rune_perun';
				break;
			}
			case 'Runeword 41':
			{
				enchantmentFx = 'rune_perun';
				break;
			}
			case 'Runeword 42':
			{
				enchantmentFx = 'rune_perun';
				break;
			}
			case 'Runeword 43':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 44':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 45':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 46':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 47':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 48':
			{
				enchantmentFx = 'rune_triglav';
				break;
			}
			case 'Runeword 49':
			{
				enchantmentFx = 'rune_veles';
				break;
			}
			case 'Runeword 50':
			{
				enchantmentFx = 'rune_veles';
				break;
			}
			case 'Runeword 51':
			{
				enchantmentFx = 'rune_veles';
				break;
			}
			case 'Runeword 52':
			{
				enchantmentFx = 'rune_veles';
				break;
			}
			case 'Runeword 53':
			{
				enchantmentFx = 'rune_veles';
				break;
			}
			case 'Runeword 54':
			{
				enchantmentFx = 'rune_veles';
				break;
			}
			case 'Runeword 55':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 56':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 57':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 58':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 59':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
			case 'Runeword 60':
			{
				enchantmentFx = 'rune_devana';
				break;
			}
		}
		return enchantmentFx;
	}

	public function UpdateEnhancements( invComp : CInventoryComponent )
	{
		var fx : name;
		var itemId : SItemUniqueId;
		var enhancements : array<name>;
		
		itemId = invComp.GetItemByItemEntity( this );
		
		invComp.GetItemEnhancementItems( itemId, enhancements );
		
		
		if ( runeCount > 0 && ( ( runeCount - 1 ) < enhancements.Size() ) )
		{
			StopEffect( GetRuneLevel( runeCount ) );
			StopEffect( GetRuneFxName( enhancements[ runeCount - 1 ] ) );
		}
		else if ( 3 == runeCount && 1 == enhancements.Size() )
		{
			StopEffect( GetRuneLevel( runeCount ) );
			StopEffect( GetEnchantmentFxName( enhancements[ 0 ] ) );
		}
		
		
		runeCount = invComp.GetItemEnhancementCount( itemId );
		
		if ( runeCount > 0 && ( ( runeCount - 1 ) < enhancements.Size() ) )
		{
			PlayEffect( GetRuneLevel( runeCount ) );
			PlayEffect( GetRuneFxName( enhancements[ runeCount - 1 ] ) );
		}
		else if ( 3 == runeCount && 1 == enhancements.Size() )
		{
			PlayEffect( GetRuneLevel( runeCount ) );
			PlayEffect( GetEnchantmentFxName( enhancements[ 0 ] ) );
		}
	}
}
