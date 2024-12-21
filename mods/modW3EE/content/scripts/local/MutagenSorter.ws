enum EMutagenStatType
{
	EMS_Adrenaline,
	EMS_Attack_Speed,
	EMS_Attack_Power,
	EMS_Armor_Pierce,
	EMS_Crit_Chance,
	EMS_Crit_Damage,
	EMS_Flank_Damage,
	EMS_Poise_Damage,
	EMS_Armor,
	EMS_Poise_Max,
	EMS_Dodge_Angle,
	EMS_Evade_Speed,
	EMS_Vitality_Max,
	EMS_Vitality_Regen,
	EMS_Stamina_Regen,
	EMS_Stamina_Movement,
	EMS_Stamina_Defense,
	EMS_Stamina_Offense,
	EMS_Toxicity_Max,
	EMS_Toxicity_Drain,
	EMS_Resist_Bleed,
	EMS_Resist_Ethereal,
	EMS_Resist_Poison,
	EMS_Sign_Intensity_All,
	EMS_Sign_Intensity_Aard,
	EMS_Sign_Intensity_Igni,
	EMS_Sign_Intensity_Yrden,
	EMS_Sign_Intensity_Quen,
	EMS_Sign_Intensity_Axii,
	EMS_Vigor_Regen,
}

statemachine class CMutagenSorter
{
	public var sortedMutagens: array<SItemUniqueId>;
	
	public function Init()
	{
		
		GotoState('Sort');
	}

	public function Terminate()
	{
		var inv, horseInv: CInventoryComponent;
		var i: int;
		var items: array<SItemUniqueId>;
		
		inv = GetWitcherPlayer().GetInventory();
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		
		items = inv.GetItemsByTag('MutagenIngredient');
		for(i=0; i<items.Size(); i+=1)
		{
			if( GetWitcherPlayer().GetItemSlot(items[i]) == EES_InvalidSlot  )
				inv.GiveItemTo( horseInv, items[i], 1, false, true, false );
		}
		
		GotoState('Wait');
	}

	public function setSortedMutagens(arr: array<SItemUniqueId>)
	{
		sortedMutagens = arr;
	}
	
	public function End()
	{
		delete this;
	}

	public function refreshList()
	{
		( (CR4CharacterMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).PopulateDataForMutagenTab(true);
		
	}
	
	public function MutagenStatNameToEnum(n : name) : EMutagenStatType
	{
		switch(n)
		{

			case 'focus_gain':					return EMS_Adrenaline;			
			case 'attack_speed':				return EMS_Attack_Speed;			
			case 'attack_power':				return EMS_Attack_Power;			
			case 'armor_reduction':				return EMS_Armor_Pierce;			
			case 'critical_hit_chance':			return EMS_Crit_Chance;			
			case 'critical_hit_damage_bonus':	return EMS_Crit_Damage;			
			case 'damage_from_behind_off':		return EMS_Flank_Damage;			
			case 'poise_damage':				return EMS_Poise_Damage;			
			case 'armor':						return EMS_Armor;				
			case 'poise_bonus':					return EMS_Poise_Max;			
			case 'safe_dodge_angle_bonus':		return EMS_Dodge_Angle;			
			case 'evade_speed':					return EMS_Evade_Speed;			
			case 'vitality':					return EMS_Vitality_Max;			
			case 'vitalityRegen':				return EMS_Vitality_Regen;		
			case 'staminaRegen':				return EMS_Stamina_Regen;		
			case 'movement_stamina_efficiency':	return EMS_Stamina_Movement;		
			case 'parry_stamina_cost_bonus':	return EMS_Stamina_Defense;		
			case 'attack_stamina_cost_bonus':	return EMS_Stamina_Offense;		
			case 'toxicity':					return EMS_Toxicity_Max;			
			case 'toxicity_drain':				return EMS_Toxicity_Drain;		
			case 'bleeding_resistance_perc':	return EMS_Resist_Bleed;			
			case 'elemental_resistance_perc':	return EMS_Resist_Ethereal;		
			case 'poison_resistance_perc':		return EMS_Resist_Poison;		
			case 'spell_power':					return EMS_Sign_Intensity_All;	
			case 'spell_power_aard':			return EMS_Sign_Intensity_Aard;	
			case 'spell_power_igni':			return EMS_Sign_Intensity_Igni;	
			case 'spell_power_yrden':			return EMS_Sign_Intensity_Yrden;	
			case 'spell_power_quen':			return EMS_Sign_Intensity_Quen;	
			case 'spell_power_axii':			return EMS_Sign_Intensity_Axii;	
			case 'vigor_regen':					return EMS_Vigor_Regen;			
		}
	}

	public function MutagenStatEnumToName(s : EMutagenStatType) : name
	{
		switch(s)
		{
			case EMS_Adrenaline :				return 'focus_gain';
			case EMS_Attack_Speed :				return 'attack_speed';
			case EMS_Attack_Power :				return 'attack_power';
			case EMS_Armor_Pierce :				return 'armor_reduction';
			case EMS_Crit_Chance :				return 'critical_hit_chance';
			case EMS_Crit_Damage :				return 'critical_hit_damage_bonus';
			case EMS_Flank_Damage :				return 'damage_from_behind_off';
			case EMS_Poise_Damage :				return 'poise_damage';
			case EMS_Armor :					return 'armor';
			case EMS_Poise_Max :				return 'poise_bonus';
			case EMS_Dodge_Angle :				return 'safe_dodge_angle_bonus';
			case EMS_Evade_Speed :				return 'evade_speed';
			case EMS_Vitality_Max :				return 'vitality';
			case EMS_Vitality_Regen :			return 'vitalityRegen';
			case EMS_Stamina_Regen :			return 'staminaRegen';
			case EMS_Stamina_Movement :			return 'movement_stamina_efficiency';
			case EMS_Stamina_Defense :			return 'parry_stamina_cost_bonus';
			case EMS_Stamina_Offense :			return 'attack_stamina_cost_bonus';
			case EMS_Toxicity_Max :				return 'toxicity';
			case EMS_Toxicity_Drain :			return 'toxicity_drain';
			case EMS_Resist_Bleed :				return 'bleeding_resistance_perc';
			case EMS_Resist_Ethereal :			return 'elemental_resistance_perc';
			case EMS_Resist_Poison :			return 'poison_resistance_perc';
			case EMS_Sign_Intensity_All :		return 'spell_power';
			case EMS_Sign_Intensity_Aard :		return 'spell_power_aard';
			case EMS_Sign_Intensity_Igni :		return 'spell_power_igni';
			case EMS_Sign_Intensity_Yrden :		return 'spell_power_yrden';
			case EMS_Sign_Intensity_Quen :		return 'spell_power_quen';
			case EMS_Sign_Intensity_Axii :		return 'spell_power_axii';
			case EMS_Vigor_Regen :				return 'vigor_regen';

		}
	}
}


state Sort in CMutagenSorter
{
	public var array0, array1, array2, array3, array4, array5, array6, array7, array8,
	array9, array10, array11, array12, array13, array14, array15, array16,  
	array17, array18, array19, array20, array21, array22, array23, array24, array25, array26,  
	array27, array28, array29: array<SItemUniqueId>;
	
	var sortingcomplete: bool;
	var finalret : array<SItemUniqueId>;
	var arrayOfArrays : array<array<SItemUniqueId>>;
	var arrayOfStats : array<float>;
	var debugstr: string;
	
	event OnEnterState(prevStateName: name)
	{	
		beginSorting();	
	}
	
	entry function beginSorting()
	{
		var i : int;
		
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt( "metal_mutsorterbegin") );
		defineArrays();
		tagEquipped();
		transferMutagensToHorse();
		createUnsortedArrays();
		sortEach();
		cullMasterArray();
		combineArrays();
		transferMutagensToPlayer();
		restoreTagged();
		cleanUp();
	}

	latent function defineArrays()
	{
		var i : int;
		
		SleepOneFrame();
		array0 .Clear();
		array1 .Clear();
		array2 .Clear();
		array3 .Clear();
		array4 .Clear();
		array5 .Clear();
		array6 .Clear();
		array7 .Clear();
		array8 .Clear();
		array9 .Clear();
		array10.Clear();
		array11.Clear();
		array12.Clear();
		array13.Clear();
		array14.Clear();
		array15.Clear();
		array16.Clear();
		array17.Clear();
		array18.Clear();
		array19.Clear();
		array20.Clear();
		array21.Clear();
		array22.Clear();
		array23.Clear();
		array24.Clear();
		array25.Clear();
		array26.Clear();
		array27.Clear();
		array28.Clear();
		array29.Clear();
		for (i=0; i<arrayOfArrays.Size(); i+=1)
		{
			arrayOfArrays[i].Clear();
		}
		
		arrayOfArrays.Clear();
		arrayOfArrays.PushBack(array0 );
		arrayOfArrays.PushBack(array1 );
		arrayOfArrays.PushBack(array2 );
		arrayOfArrays.PushBack(array3 );
		arrayOfArrays.PushBack(array4 );
		arrayOfArrays.PushBack(array5 );
		arrayOfArrays.PushBack(array6 );
		arrayOfArrays.PushBack(array7 );
		arrayOfArrays.PushBack(array8 );
		arrayOfArrays.PushBack(array9 );
		arrayOfArrays.PushBack(array10);
		arrayOfArrays.PushBack(array11);
		arrayOfArrays.PushBack(array12);
		arrayOfArrays.PushBack(array13);
		arrayOfArrays.PushBack(array14);
		arrayOfArrays.PushBack(array15);
		arrayOfArrays.PushBack(array16);
		arrayOfArrays.PushBack(array17);
		arrayOfArrays.PushBack(array18);
		arrayOfArrays.PushBack(array19);
		arrayOfArrays.PushBack(array20);
		arrayOfArrays.PushBack(array21);
		arrayOfArrays.PushBack(array22);
		arrayOfArrays.PushBack(array23);
		arrayOfArrays.PushBack(array24);
		arrayOfArrays.PushBack(array25);
		arrayOfArrays.PushBack(array26);
		arrayOfArrays.PushBack(array27);
		arrayOfArrays.PushBack(array28);
		arrayOfArrays.PushBack(array29);
	}
	
	latent function tagEquipped()
	{
		var inv: CInventoryComponent;
		var item: SItemUniqueId;
		
		inv = GetWitcherPlayer().GetInventory();
		
		if( inv.GetItemEquippedOnSlot( EES_SkillMutagen1, item ) )
		{
			inv.AddItemTag(item, 'MutSlot1');
		}
		
		if( inv.GetItemEquippedOnSlot( EES_SkillMutagen2, item ) )
		{
			inv.AddItemTag(item, 'MutSlot2');
		}
		
		if( inv.GetItemEquippedOnSlot( EES_SkillMutagen3, item ) )
		{
			inv.AddItemTag(item, 'MutSlot3');
		}
		
		if( inv.GetItemEquippedOnSlot( EES_SkillMutagen4, item ) )
		{
			inv.AddItemTag(item, 'MutSlot4');
		}
	}
	
	latent function transferMutagensToHorse()
	{
		var i, j, size : int;
		var ret : array<SItemUniqueId>;
		var found : bool;
		var inv, horseInv: CInventoryComponent;
		var items, sortedMutagens: array<SItemUniqueId>;
		var curItem: SItemUniqueId;
		var equippedOnSlot  : EEquipmentSlots;
		var mutagenStats: array<SAttributeTooltip>;

		inv = GetWitcherPlayer().GetInventory();
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		items = inv.GetItemsByTag('MutagenIngredient');	
		
		for(i=0; i<items.Size(); i+=1)
		{
			SleepOneFrame();
			inv.GiveItemTo( horseInv, items[i], 1, false, true, false );
		}
	}
	
	latent function createUnsortedArrays()
	{
		var i : int;
		var ret : array<SItemUniqueId>;
		var horseInv: CInventoryComponent;
		var items, sortedMutagens: array<SItemUniqueId>;
		var curItem: SItemUniqueId;
		var mutagenStats: array<SAttributeTooltip>;
		var attrName : EMutagenStatType;

		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		items = horseInv.GetItemsByTag('MutagenIngredient');
		
		for(i=0; i<items.Size(); i+=1)
		{
			if( !horseInv.ItemHasTag(items[i], 'InertMutagen') )
			{
				ret.PushBack( items[i] );
			}
		}
		items.Clear();
		items = ret;
		ret.Clear();
		
		for(i=0; i<items.Size(); i+=1)
		{
			if (i % 4 <= 0) 
			{
				SleepOneFrame();
			}

			horseInv.GetItemStats(items[i], mutagenStats);
			attrName = parent.MutagenStatNameToEnum(mutagenStats[0].originName);
			
			switch (attrName)
			{
				case EMS_Adrenaline:				 arrayOfArrays[0 ].PushBack(items[i]) ; break;		
				case EMS_Attack_Speed:				 arrayOfArrays[1 ].PushBack(items[i]) ; break;		
				case EMS_Attack_Power:				 arrayOfArrays[2 ].PushBack(items[i]) ; break;		
				case EMS_Armor_Pierce:				 arrayOfArrays[3 ].PushBack(items[i]) ; break;		
				case EMS_Crit_Chance:				 arrayOfArrays[4 ].PushBack(items[i]) ; break;		
				case EMS_Crit_Damage:				 arrayOfArrays[5 ].PushBack(items[i]) ; break;		
				case EMS_Flank_Damage:				 arrayOfArrays[6 ].PushBack(items[i]) ; break;		
				case EMS_Poise_Damage:				 arrayOfArrays[7 ].PushBack(items[i]) ; break;		
				case EMS_Armor:						 arrayOfArrays[8 ].PushBack(items[i]) ; break;		
				case EMS_Poise_Max:					 arrayOfArrays[9 ].PushBack(items[i]) ; break;		
				case EMS_Dodge_Angle:				 arrayOfArrays[10].PushBack(items[i]) ; break;		
				case EMS_Evade_Speed:				 arrayOfArrays[11].PushBack(items[i]) ; break;		
				case EMS_Vitality_Max:				 arrayOfArrays[12].PushBack(items[i]) ; break;		
				case EMS_Vitality_Regen:			 arrayOfArrays[13].PushBack(items[i]) ; break;		
				case EMS_Stamina_Regen:				 arrayOfArrays[14].PushBack(items[i]) ; break;		
				case EMS_Stamina_Movement:			 arrayOfArrays[15].PushBack(items[i]) ; break;	
				case EMS_Stamina_Defense:			 arrayOfArrays[16].PushBack(items[i]) ; break;		
				case EMS_Stamina_Offense:			 arrayOfArrays[17].PushBack(items[i]) ; break;		
				case EMS_Toxicity_Max:				 arrayOfArrays[18].PushBack(items[i]) ; break;		
				case EMS_Toxicity_Drain:			 arrayOfArrays[19].PushBack(items[i]) ; break;		
				case EMS_Resist_Bleed:				 arrayOfArrays[20].PushBack(items[i]) ; break;		
				case EMS_Resist_Ethereal:			 arrayOfArrays[21].PushBack(items[i]) ; break;		
				case EMS_Resist_Poison:				 arrayOfArrays[22].PushBack(items[i]) ; break;		
				case EMS_Sign_Intensity_All:		 arrayOfArrays[23].PushBack(items[i]) ; break;	
				case EMS_Sign_Intensity_Aard:		 arrayOfArrays[24].PushBack(items[i]) ; break;	
				case EMS_Sign_Intensity_Igni:		 arrayOfArrays[25].PushBack(items[i]) ; break;	
				case EMS_Sign_Intensity_Yrden:		 arrayOfArrays[26].PushBack(items[i]) ; break;
				case EMS_Sign_Intensity_Quen:		 arrayOfArrays[27].PushBack(items[i]) ; break;	
				case EMS_Sign_Intensity_Axii:		 arrayOfArrays[28].PushBack(items[i]) ; break;	
				case EMS_Vigor_Regen:				 arrayOfArrays[29].PushBack(items[i]) ; break;

			}
		}
	}
	
	latent function sortEach()
	{
		var i: int;

		for(i=0; i<30; i+=1)
		{
			SleepOneFrame();
			sortMutagenArray(arrayOfArrays[i], i); 
		}
	}
	
	latent function sortMutagenArray( arr: array<SItemUniqueId>, id:int)
	{
		var i, j, size : int;
		var ret : array<SItemUniqueId>;
		var found : bool;
		var inv, horseInv: CInventoryComponent;
		var mutagenStats1, mutagenStats2: array<SAttributeTooltip>;
		
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();

		if(arr.Size() == 0)
			return;
			
		size = arr.Size();	
		ret.PushBack(arr[0]);
		
		for(i=1; i<size; i+=1)
		{
			if (i % 4 <= 0) 
			{
				SleepOneFrame();
			}
			found = false;
			
			for(j=0; j<ret.Size(); j+=1)
			{
				horseInv.GetItemStats(arr[i], mutagenStats1);
				horseInv.GetItemStats(ret[j], mutagenStats2);
				if( mutagenStats1[0].value> mutagenStats2[0].value)
				{
					ret.Insert(j, arr[i]);
					found = true;
					break;
				}
			}
			if ( !found )
			{
				ret.PushBack(arr[i]);
			}
		}
		
		arr.Clear();
		arrayOfArrays[id].Clear();
		arrayOfArrays[id] = ret;
		arr = ret;
	}
	
	latent function cullMasterArray()
	{
		var i : int;
		var ret : array< array<SItemUniqueId> >;
		
		for( i=0; i<arrayOfArrays.Size(); i+=1 )
		{
			if( arrayOfArrays[i].Size()>0 )
			{
				ret.PushBack( arrayOfArrays[i] );
			}
		}
		
		arrayOfArrays.Clear();
		arrayOfArrays= ret;
		ret.Clear();
		
	}

	latent function combineArrays()
	{
		var i : int;

		finalret.Clear();
		for(i=0; i<arrayOfArrays.Size(); i+=1)
		{
			if(arrayOfArrays[i].Size()>0)
			{
				AppendArray(finalret, arrayOfArrays[i]);
				
			}
		}
		
	}
	
	latent function AppendArray(out first : array<SItemUniqueId>, second : array<SItemUniqueId>)
	{
		var i, s : int;
		
		SleepOneFrame();
		s = second.Size();
		for(i=0; i<s; i+=1)
			first.PushBack(second[i]);
	}
	
	latent function transferMutagensToPlayer()
	{
		var i: int;
		var inv, horseInv: CInventoryComponent;
		var items: array<SItemUniqueId>;
		
		SleepOneFrame();

		inv = GetWitcherPlayer().GetInventory();
		horseInv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
		
		for(i=0; i<finalret.Size(); i+=1)
		{
			SleepOneFrame();//testing
			horseInv.GiveItemTo( inv, finalret[i], 1, false, true, false );
			
		}
		finalret.Clear();
		items = inv.GetItemsByTag('MutagenIngredient');
		
		for(i=0; i<items.Size(); i+=1)
		{
			if(!inv.ItemHasTag(items[i], 'InertMutagen'))
			{
				finalret.PushBack(items[i]);
			}
		}
		
		parent.setSortedMutagens(finalret);

	}
	
	latent function restoreTagged()
	{
		var inv: CInventoryComponent;
		var i : int;
		var items : array<SItemUniqueId>;
		inv = GetWitcherPlayer().GetInventory();
		
		items = inv.GetItemsByTag('MutagenIngredient');
		
		for(i=0; i<items.Size(); i+=1)
		{
			if( inv.ItemHasTag(items[i], 'MutSlot1' ) )
			{
				GetWitcherPlayer().EquipItemInGivenSlot(items[i], EES_SkillMutagen1, false);
				inv.RemoveItemTag(items[i], 'MutSlot1');
			}
			else if( inv.ItemHasTag(items[i], 'MutSlot2' ) )
			{
				GetWitcherPlayer().EquipItemInGivenSlot(items[i], EES_SkillMutagen2, false);
				inv.RemoveItemTag(items[i], 'MutSlot2');
			}
			else if( inv.ItemHasTag(items[i], 'MutSlot3' ) )
			{
				GetWitcherPlayer().EquipItemInGivenSlot(items[i], EES_SkillMutagen3, false);
				inv.RemoveItemTag(items[i], 'MutSlot3');
			}
			else if( inv.ItemHasTag(items[i], 'MutSlot4' ) )
			{
				GetWitcherPlayer().EquipItemInGivenSlot(items[i], EES_SkillMutagen4, false);
				inv.RemoveItemTag(items[i], 'MutSlot4');
			}
		}
	}
	
	latent function cleanUp()
	{
		( (CR4CharacterMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).UpdateData(true);
		finalret.Clear();
		SleepOneFrame();
		parent.GotoState('Null');
	}
	
	
	
}

state Null in CMutagenSorter
{
	event OnEnterState(prevStateName: name)
	{
		null();
	}
	
	entry function null()
	{
		SleepOneFrame();
		parent.refreshList();
		theGame.GetGuiManager().ClearNotificationsQueue();
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt( "metal_mutsorterend") );
		parent.GotoState('Wait');
	}
}

state Wait in CMutagenSorter
{
	event OnEnterState(prevStateName: name)
	{
	}
}