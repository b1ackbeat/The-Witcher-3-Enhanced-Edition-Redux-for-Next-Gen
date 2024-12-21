/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/
enum EMeleeWeaponType
{
	EMWT_None,
	EMWT_SwordWooden,
	EMWT_Sword1H,
	EMWT_Sword1HStrong,
	EMWT_Sword2H,
	EMWT_Spear,
	EMWT_Halberd,
	EMWT_Pike,
	EMWT_MetalPole,
	EMWT_FirePoker,
	EMWT_Staff,
	EMWT_Mace,
	EMWT_Club,
	EMWT_Axe,
	EMWT_Hatchet,
	EMWT_GreatAxe,
	EMWT_GreatHammerWood,
	EMWT_GreatHammerMetal
}

enum ERangedWeaponType
{
	ERWT_None,
	ERWT_ShortBow,
	ERWT_LongBow,
	ERWT_Crossbow
}

exec function gettargetarmor()
{
	var temp : name;
	
	temp = Scaling().GetArmorType(((CNewNPC)thePlayer.GetTarget()));
}

class W3EEScalingHandler extends W3EEOptionHandler
{
	public function GetArmorType( NPC : CNewNPC ) : name
    {
        var meshComps : array<CComponent>;
        var armorTypes : array<int>;
        var i, max : int;
        var mesh : CComponent;
        var meshName : string;
		
		armorTypes.Resize(4);
        meshComps = NPC.GetComponentsByClassName('CMeshComponent');
        for(i=0; i<meshComps.Size(); i+=1)
        {
            mesh = meshComps[i];
            meshName = mesh.GetName();
            if( StrContains(meshName, "knight") )
				armorTypes[0] += 1;
			else
			if( StrContains(meshName, "twals_01_ma__guard") )
				armorTypes[1] += 3;
			else
			if( StrContains(meshName, "guard") || StrContains(meshName, "baron_thug_lvl2") || StrContains(meshName, "squire") || StrContains(meshName, "hb_10_ma__dlc") || StrContains(meshName, "skellige_warrior_lvl3") || StrContains(meshName, "t2_02_ma__bob") || StrContains(meshName, "g_02_ma__bob") || StrContains(meshName, "a_03_ma__bob") || StrContains(meshName, "c_01_ma__bob") || StrContains(meshName, "_10_ma__dlc") )
				armorTypes[1] += 1;
			else
			if( StrContains(meshName, "skellige_warrior_lvl2") || StrContains(meshName, "inquisition") || StrContains(meshName, "iquisitor") || StrContains(meshName, "baron_thug") )
				armorTypes[2] += 1;
			else
			if( StrContains(meshName, "bandit") || StrContains(meshName, "skellige_warrior_lvl1") )
				armorTypes[3] += 1;
        }
		
		for(i=0; i<armorTypes.Size(); i+=1)
			if( armorTypes[i] > max )
				max = armorTypes[i];
				
		if( max > 1 )
		{
			if( max == armorTypes[0] )
				return 'Heavy';
			if( max == armorTypes[1] )
				return 'Mixed';
			if( max == armorTypes[2] )
				return 'Medium';
			if( max == armorTypes[3] )
				return 'Light';
		}
		else
		if( max == 1 )
		{
			if( armorTypes[0] + armorTypes[1] > 1 )
				return 'Mixed';
			if( armorTypes[1] + armorTypes[2] > 1 )
				return 'Medium';
			if( max == armorTypes[3] )
				return 'Light';
		}
        return 'None';
    }
    
    private function GetMeleeWeaponFromAbilities( NPC : CNewNPC, abilities : array<name> ) : EMeleeWeaponType
    {
		if( abilities.Contains('NPC Wooden sword _Stats') )
			return EMWT_SwordWooden;
		else
		if( abilities.Contains('Spear 1 _Stats') || abilities.Contains('Spear 2 _Stats') || abilities.Contains('NPC Wild Hunt Spear _Stats') || abilities.Contains('Pitchfork _Stats') )
			return EMWT_Spear;
		else
		if( abilities.Contains('Halberd 1 _Stats') || abilities.Contains('Halberd 2 _Stats') || abilities.Contains('NPC Wild Hunt Halberd _Stats') )
			return EMWT_Halberd;
		else
		if( abilities.Contains('Guisarme 1 _Stats') || abilities.Contains('Guisarme 2 _Stats') )
			return EMWT_Pike;
		else
		if( abilities.Contains('Long metal pole _Stats') || abilities.Contains('Shovel _Stats') || abilities.Contains('Scythe _Stats') )
			return EMWT_MetalPole;
		else
		if( abilities.Contains('Poker _Stats') || abilities.Contains('q308 Iron Poker _Stats') )
			return EMWT_FirePoker;
		else
 		if( abilities.Contains('Staff _Stats') || abilities.Contains('Oar _Stats') || abilities.Contains('Rake _Stats') )
			return EMWT_Staff;
		else
 		if( abilities.Contains('Mace 1 _Stats') || abilities.Contains('Mace 2 _Stats') || abilities.Contains('Plank _Stats') || abilities.Contains('Laundry stick _Stats') )
			return EMWT_Mace;
		else
 		if( abilities.Contains('Club _Stats') || abilities.Contains('Small Blackjack _Stats') || abilities.Contains('Blackjack _Stats') || abilities.Contains('Wand _Stats') || abilities.Contains('Scoop _Stats') || abilities.Contains('Paling _Stats') || abilities.Contains('Shepard stick _Stats') || abilities.Contains('NPC torch _Stats') )
			return EMWT_Club;
		else
 		if( abilities.Contains('Axe 1 _Stats') || abilities.Contains('Axe 2 _Stats') )
			return EMWT_Axe;
		else
 		if( abilities.Contains('Hatchet _Stats') )
			return EMWT_Hatchet;
		else
 		if( abilities.Contains('Great Axe 1 _Stats') || abilities.Contains('Great Axe 2 _Stats') || abilities.Contains('Dwarven Axe _Stats') || abilities.Contains('NPC Wild Hunt Axe _Stats') )
			return EMWT_GreatAxe;
		else
 		if( abilities.Contains('Dwarven Hammer _Stats') || abilities.Contains('NPC Wild Hunt Hammer _Stats') || abilities.Contains('Twohanded Hammer 2 _Stats') || abilities.Contains('Lucerne Hammer _Stats') || abilities.Contains('Pickaxe _Stats') )
			return EMWT_GreatHammerMetal;
		else
 		if( abilities.Contains('Twohanded Hammer 1 _Stats') )
			return EMWT_GreatHammerWood;
		else
		{
			if( NPC.HasAbility('SkillElite') || NPC.HasAbility('SkillBoss') || NPC.HasAbility('mon_wild_hunt_default') )
				return EMWT_Sword2H;
			else
			if( NPC.HasAbility('SkillOfficer') || NPC.HasAbility('SkillMercenary') || NPC.HasAbility('SkillGuard') || NPC.HasAbility('SkillSoldier') )
				return EMWT_Sword1HStrong;
			else
				return EMWT_Sword1H;
		}
	}
    
    private function GetRangedWeaponFromAbilities( abilities : array<name> ) : ERangedWeaponType
    {
 		if( abilities.Contains('Bow 1 _Stats') || abilities.Contains('Bow 2 _Stats') )
			return ERWT_ShortBow;
		else
 		if( abilities.Contains('Long bow 1 _Stats') || abilities.Contains('Long bow 2 _Stats') || abilities.Contains('Elven bow _Stats') )
			return ERWT_LongBow;
		else
 		if( abilities.Contains('Crossbow 01 _Stats') || abilities.Contains('Dwarven crossbow _Stats') || abilities.Contains('Nilfgaardian crossbow _Stats') )
			return ERWT_Crossbow;
		else
			return ERWT_None;
    }
    
    private function GetWeaponTypes( NPC : CNewNPC, out opponentStats : SOpponentStats )
    {
		var rangedWeapon : ERangedWeaponType;
		var meleeWeapon : EMeleeWeaponType;
		var weapons : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var tags, abilities : array<name>;
		var i : int;
		
		opponentStats.meleeWeapon = EMWT_Sword1H;
		opponentStats.rangedWeapon = ERWT_None;
		
		inv = NPC.GetInventory();
		weapons = inv.GetItemsByTag('mod_weapon');
		for(i=0; i<weapons.Size(); i+=1)
		{
			inv.GetItemTags(weapons[i], tags);
			inv.GetItemAbilities(weapons[i], abilities);
			
			meleeWeapon = GetMeleeWeaponFromAbilities(NPC, abilities);
			rangedWeapon = GetRangedWeaponFromAbilities(abilities);
			
			if( meleeWeapon > 0 )
				opponentStats.meleeWeapon = meleeWeapon;
			if( rangedWeapon > 0 )
				opponentStats.rangedWeapon = rangedWeapon;
			
			abilities.Clear();
		}
    }
    
    private function HasTwoHandedWeapon( opponentStats : SOpponentStats ) : bool
    {
		switch(opponentStats.meleeWeapon)
		{
			case EMWT_Spear:
			case EMWT_Halberd:
			case EMWT_Pike:
			case EMWT_MetalPole:
			case EMWT_Staff:
			case EMWT_GreatAxe:
			case EMWT_GreatHammerWood:
			case EMWT_GreatHammerMetal:
				return true;
			
			default : return false;
		}
		
		return false;
    }
    
    private function ApplyStatModifiers( NPC : CNewNPC, out opponentStats : SOpponentStats )
    {
		var armorType : name;
		var speedMult : float;
		
		//Kolaris - Extreme Cosplay Statue Nerf
		if( (GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest) && !(NPC.HasAbility('mon_qmq7007_statues')) )
			return;
		
		speedMult = 1.f + GetProgressionSpeedMod(NPC);
		armorType = GetArmorType(NPC);
		if( NPC.IsHuman() )
		{
			switch(armorType)
			{
				case 'Heavy':	speedMult -= 0.06f;	break;
				case 'Mixed':	speedMult -= 0.03f;	break;
				case 'Medium':	speedMult -= 0.02f;	break;
				case 'Light':
				default:							break;
			}
			
			if( HasTwoHandedWeapon(opponentStats) )
				speedMult -= 0.03f;
			if( opponentStats.meleeWeapon == EMWT_Club || opponentStats.meleeWeapon == EMWT_Mace )
				speedMult -= 0.1f;
			if( opponentStats.meleeWeapon == EMWT_Halberd )
				speedMult -= 0.1f;
			
			//Kolaris - Extreme Cosplay Statue Nerf
			if( NPC.HasAbility('mon_qmq7007_statues') )
				speedMult -= 0.1f;
			if( NPC.HasAbility('mon_qmq7007_mages') )
				speedMult -= 0.1f;
		}
		else
		{
			if( NPC.HasAbility('mon_lessog_base') )
				speedMult += 0.35f;
				
			if( NPC.HasAbility('mon_golem') )
				speedMult += 0.15f;
			else
			if( NPC.HasAbility('mon_golem_base') )
				speedMult += 0.12f;
			if( NPC.HasAbility('mon_cyclops') || NPC.HasAbility('mon_ice_giant') )
				speedMult += 0.10f;
			if( NPC.HasAbility('mon_fleder') )
				speedMult -= 0.15f;
			if( NPC.HasAbility('mon_garkain') )
				speedMult -= 0.10;
				
			if( NPC.HasAbility('mon_bies_base') )
				speedMult += 0.18f;
				
			if( NPC.HasAbility('mon_arachas_base') )
			{
				if( NPC.HasAbility('mon_arachas_armored') )
					speedMult -= 0.20f;
				else
				if( NPC.HasAbility('mon_poison_arachas') )
					speedMult -= 0.12f;
				else
					speedMult -= 0.15f;
			}
			if( NPC.HasAbility('mon_gravehag_base') && ! NPC.HasTag('fogling_doppelganger') )
				speedMult += 0.05f;
				
			if( NPC.HasAbility('mon_harpy_base') )
			{
				if(NPC.HasAbility('mon_erynia'))
					speedMult += 0.15f;
				else
					speedMult += 0.1f;
			}
			if( NPC.HasAbility('mon_siren_base') )
			{
				if(NPC.HasAbility('mon_lamia'))
					speedMult += 0.1f;
				else
					speedMult += 0.06f;
			}
			if( NPC.HasAbility('mon_wyvern_base') )
			{
				if( NPC.HasAbility('mon_wyvern') )
					speedMult += 0.1f;
				else
				if( NPC.HasAbility('mon_forktail') )
					speedMult += 0.15f;
				else
					speedMult += 0.05f;
			}
			
			if( NPC.HasAbility('mon_boar_base') || NPC.HasAbility('mon_boar_ep2_base') || NPC.HasAbility('mon_ft_boar_ep2_base') )
				speedMult -= 0.2f;
				
			if( NPC.HasAbility('mon_drowner_base') && !(NPC.GetInventory().HasItem('mon_drowned_dead_weapon')) )
				speedMult -= 0.05f;
				
			if( NPC.HasAbility('mon_rotfiend') )
				speedMult += 0.05f;
				
			if( NPC.HasAbility('mon_endriaga_worker') )
				speedMult += 0.05f;
			if( NPC.HasAbility('mon_endriaga_soldier_spikey') )
				speedMult -= 0.1f;
				
			if( NPC.HasAbility('mon_kikimore_small') )
				speedMult -= 0.1f;
				
			if (NPC.HasAbility('mon_archespor_base'))
				speedMult -= 0.05f;
				
			if( NPC.HasAbility('WildHunt_Eredin') )
				speedMult += 0.15f;
				
			if( NPC.HasAbility('mon_wild_hunt_default') && !NPC.HasTag('IsBoss') )
				speedMult += 0.05f;
				
			if( NPC.HasAbility('mon_gargoyle') )
				speedMult -= 0.1f;
				
			if( NPC.HasAbility('mon_nightwraith_iris') )
				speedMult -= 0.1f;
				
			if( NPC.HasTag('sq202_djinn') )
				speedMult -= 0.2f;
				
			if( NPC.HasAbility('mon_werewolf_base') )
				speedMult += 0.1f;
		}
		
		opponentStats.spdMultID = NPC.SetAnimationSpeedMultiplier(speedMult, opponentStats.spdMultID);
    }
    
    private function EnemyDisparity( NPC : CNewNPC, out opponentStats : SOpponentStats )
    {
		if( GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest )
			return;
			
		opponentStats.healthValue *= RandRangeF(1.1f, 0.9f);
		opponentStats.damageValue *= RandRangeF(1.1f, 0.9f);
    }
	
	//Kolaris - Difficulty Settings
	private function ApplyDifficultyModifiers( NPC : CNewNPC, out opponentStats : SOpponentStats)
	{
		var difficultyMod : float;
		
		if( theGame.GetDifficultyMode() == EDM_Medium )
			return;
			
		if( GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest )
			return;
		
		difficultyMod = 1.f - Options().GetDifficultySettingMod();
			
		//opponentStats.physicalResist	= MinF(1.f, opponentStats.physicalResist - (AbsF(opponentStats.physicalResist) * difficultyMod));
		opponentStats.forceResist 		= MinF(1.f, opponentStats.forceResist - (AbsF(opponentStats.forceResist) * difficultyMod));
		opponentStats.frostResist 		= MinF(1.f, opponentStats.frostResist - (AbsF(opponentStats.frostResist) * difficultyMod));
		opponentStats.fireResist 		= MinF(1.f, opponentStats.fireResist - (AbsF(opponentStats.fireResist) * difficultyMod));
		opponentStats.shockResist 		= MinF(1.f, opponentStats.shockResist - (AbsF(opponentStats.shockResist) * difficultyMod));
		opponentStats.elementalResist 	= MinF(1.f, opponentStats.elementalResist - (AbsF(opponentStats.elementalResist) * difficultyMod));
		opponentStats.slowResist 		= MinF(1.f, opponentStats.slowResist - (AbsF(opponentStats.slowResist) * difficultyMod));
		opponentStats.confusionResist 	= MinF(1.f, opponentStats.confusionResist - (AbsF(opponentStats.confusionResist) * difficultyMod));
		opponentStats.bleedingResist 	= MinF(1.f, opponentStats.bleedingResist - (AbsF(opponentStats.bleedingResist) * difficultyMod));
		opponentStats.poisonResist 		= MinF(1.f, opponentStats.poisonResist - (AbsF(opponentStats.poisonResist) * difficultyMod));
		opponentStats.stunResist 		= MinF(1.f, opponentStats.stunResist - (AbsF(opponentStats.stunResist) * difficultyMod));
		opponentStats.injuryResist 		= MinF(1.f, opponentStats.injuryResist - (AbsF(opponentStats.injuryResist) * difficultyMod));
	}
	
	private function ApplyProgressionModifiers( NPC : CNewNPC, out opponentStats : SOpponentStats)
	{
		var playerProgression : float;
		var healthScale, damageScale, resistScale : float;
		
		if( !theGame.GetInGameConfigWrapper().GetVarValue('SCOptionScaling', 'ScalingToggle') )
			return;
			
		if( GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest )
			return;
			
		playerProgression = MaxF(0.f, (Experience().GetAllSpentPoints() - 10) / 10.f);
		healthScale = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('SCOptionScaling', 'ScaleAmHealth')) / 100.f;
		damageScale = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('SCOptionScaling', 'ScaleAmDamage')) / 100.f;
		resistScale = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('SCOptionScaling', 'ScaleAmResist')) / 100.f;
		
		opponentStats.healthValue  		*= 1.f + playerProgression * healthScale;
		opponentStats.damageValue 		*= 1.f + playerProgression * damageScale;
		opponentStats.physicalResist	= MinF(1.f, opponentStats.physicalResist * (1.f + playerProgression * resistScale));
		opponentStats.forceResist 		= MinF(1.f, opponentStats.forceResist * (1.f + playerProgression * resistScale));
		opponentStats.frostResist 		= MinF(1.f, opponentStats.frostResist * (1.f + playerProgression * resistScale));
		opponentStats.fireResist 		= MinF(1.f, opponentStats.fireResist * (1.f + playerProgression * resistScale));
		opponentStats.shockResist 		= MinF(1.f, opponentStats.shockResist * (1.f + playerProgression * resistScale));
		opponentStats.elementalResist 	= MinF(1.f, opponentStats.elementalResist * (1.f + playerProgression * resistScale));
		opponentStats.slowResist 		= MinF(1.f, opponentStats.slowResist * (1.f + playerProgression * resistScale));
		opponentStats.confusionResist 	= MinF(1.f, opponentStats.confusionResist * (1.f + playerProgression * resistScale));
		opponentStats.bleedingResist 	= MinF(1.f, opponentStats.bleedingResist * (1.f + playerProgression * resistScale));
		opponentStats.poisonResist 		= MinF(1.f, opponentStats.poisonResist * (1.f + playerProgression * resistScale));
		opponentStats.stunResist 		= MinF(1.f, opponentStats.stunResist * (1.f + playerProgression * resistScale));
		opponentStats.injuryResist 		= MinF(1.f, opponentStats.injuryResist * (1.f + playerProgression * resistScale));
	}
	
	private function GetProgressionSpeedMod( NPC : CNewNPC ) : float
	{
		var playerProgression : float;
		var speedScale : float;
		
		if( !theGame.GetInGameConfigWrapper().GetVarValue('SCOptionScaling', 'ScalingToggle') )
			return 0;
			
		if( GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest )
			return 0;
			
		playerProgression = (Experience().GetTotalSkillPoints() - 10) / 10.f;
		speedScale = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('SCOptionScaling', 'ScaleAmSpeed')) / 100.f;
		
		return playerProgression * speedScale;
	}
    
	private function AddSpecterResistances( NPC : CNewNPC )
	{
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
	}
	
	private function AddUniversalWeatherAbilities( NPC : CNewNPC )
	{
		NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_wetness');
		NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_wetness');
		NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_dry');
	}
	
	public function CalculateStatsBoss2( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var weaponTags : array<name>;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( NPC.HasTag('sq701_gregoire') || NPC.HasTag('sq202_djinn') || NPC.HasTag('q701_sharley') || NPC.HasAbility('mon_witch1') || NPC.HasAbility('mon_witch2') || NPC.HasAbility('mon_witch3') || NPC.HasAbility('qth1003_kiyan') || NPC.HasTag('mq7017_knight') || NPC.HasTag('mq1060_witcher') || NPC.HasTag('mq1060_evil_spirit') )
		{
			NPC.AddTag('IsBoss');
			NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
			opponentStats.canGetCrippled = false;
			if( NPC.HasTag('q701_sharley') )
			{
				opponentStats.damageValue = 2860;
				opponentStats.healthValue = 32110;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.8f;
				opponentStats.physicalResist	= 0.45f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.4f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.3f;
				opponentStats.elementalResist 	= 0.3f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.3f;
				opponentStats.bleedingResist 	= 0.4f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.4f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.75f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('sq202_djinn') )
			{
				opponentStats.damageValue = 2175;
				opponentStats.rangedDamageValue = 910;
				opponentStats.healthValue = 21900;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.5f;
				opponentStats.physicalResist	= 0.8f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= 0.8f;
				opponentStats.elementalResist 	= -1.f;
				opponentStats.slowResist 		= 1.f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 1.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.7f;
				opponentStats.rangedArmorPiercing = 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('sq701_gregoire') )
			{
				opponentStats.damageValue = 4320;
				opponentStats.healthValue = 20130;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.9f;
				opponentStats.physicalResist	= 0.9f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.4f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.3f;
				opponentStats.bleedingResist 	= 0.6f;
				opponentStats.poisonResist 		= 0.4f;
				opponentStats.stunResist 		= 0.5f;
				opponentStats.injuryResist 		= 0.4f;
				opponentStats.armorPiercing 	= 0.65f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('mq7017_knight') )
			{
				opponentStats.damageValue = 4320;
				opponentStats.healthValue = 20130;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.isHuge            = true;
				opponentStats.dangerLevel       = 100;
				opponentStats.poiseValue        = 0.6f;
				opponentStats.physicalResist    = 0.f;
				opponentStats.forceResist       = 1.f;
				opponentStats.frostResist       = 1.f;
				opponentStats.fireResist        = 1.f;
				opponentStats.shockResist       = -0.3f;
				opponentStats.elementalResist   = -0.3f;
				opponentStats.slowResist        = 0.2f;
				opponentStats.confusionResist   = 1.f;
				opponentStats.bleedingResist    = 1.f;
				opponentStats.poisonResist      = 1.f;
				opponentStats.stunResist       	= 1.f;
				opponentStats.injuryResist      = 1.f;
				opponentStats.armorPiercing     = 0.65f;
				AddSpecterResistances(NPC);
			}
			else
			if( NPC.HasAbility('mon_witch1') )
			{
				opponentStats.damageValue = 1700;
				opponentStats.healthValue = 17500;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.3f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_witch2') )
			{
				opponentStats.damageValue = 1700;
				opponentStats.healthValue = 21900;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.3f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_witch3') )
			{
				opponentStats.damageValue = 1700;
				opponentStats.healthValue = 17500;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.3f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('qth1003_kiyan') )
			{
				NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 19680;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.95f;
				opponentStats.physicalResist	= 0.3f;
				opponentStats.forceResist 		= 0.15f;
				opponentStats.frostResist 		= 0.8f;
				opponentStats.fireResist 		= 0.8f;
				opponentStats.shockResist 		= 0.6f;
				opponentStats.elementalResist 	= -0.1f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.1f;
				opponentStats.bleedingResist 	= 0.7f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.3f;
				opponentStats.regenDelay 		= 2.f;
				opponentStats.healthRegenFactor = 0.005f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('mq1060_witcher') )
			{
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 19680;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.85f;
				opponentStats.physicalResist	= 0.4f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.6f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= 0.6f;
				opponentStats.elementalResist 	= -0.2f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 0.7f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.3f;
			}
			else
			if( NPC.HasTag('mq1060_evil_spirit') )
			{
				opponentStats.damageValue = 4060;
				opponentStats.healthValue = 40300;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.canGetCrippled 	= false;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 1.f;
				opponentStats.shockResist 		= -0.3f;
				opponentStats.elementalResist 	= -0.5f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 1.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.5f;
				AddSpecterResistances(NPC);
			}
			else
			{
				wasNotScaled = true;
				opponentStats.damageValue = 1;
				opponentStats.healthValue = 1;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 10;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.f;
			}
		}
	}
    
	public function CalculateStatsBoss( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var weaponTags : array<name>;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( npcStats.HasAbilityWithTag('Boss') || NPC.HasTag('dettlaff_minion') || NPC.HasAbility('olgierd_default_stats') || NPC.HasAbility('mon_cloud_giant') || NPC.HasAbility('mon_dettlaff_bossbar_dummy') || NPC.HasAbility('mon_fairytale_witch') || NPC.HasAbility('mon_broom_base') || NPC.HasAbility('mon_dettlaff_monster_base') || NPC.HasAbility('mon_dettlaff_vampire_base') || NPC.HasAbility('mon_nightwraith_iris') || NPC.HasAbility('mon_caretaker_ep1') || NPC.HasAbility('mon_EP2_SpoonCollector') || NPC.HasAbility('mon_q701_giant') || NPC.HasAbility('q104_whboss') || NPC.HasAbility('mon_toad_base') || NPC.HasTag('q103_big_botch') || NPC.HasTag('q704_dettlaff_bossbar') )
		{
			NPC.AddTag('IsBoss');
			NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
			opponentStats.canGetCrippled = false;
			if( NPC.HasAbility('q104_whboss') )
			{
				//Kolaris - Wild Hunt Poison Vulnerability
				NPC.RemoveBuffImmunity(EET_Bleeding, 'base');
				NPC.RemoveBuffImmunity(EET_BleedingTracking, 'base');
				NPC.RemoveBuffImmunity(EET_Poison, 'base');
				NPC.RemoveBuffImmunity(EET_PoisonCritical, 'base');
				opponentStats.damageValue = 3755;
				opponentStats.healthValue = 32500;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.90f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('WildHunt_Imlerith') )
			{
				//Kolaris - Wild Hunt Poison Vulnerability
				NPC.RemoveBuffImmunity(EET_Bleeding, 'base');
				NPC.RemoveBuffImmunity(EET_BleedingTracking, 'base');
				NPC.RemoveBuffImmunity(EET_Poison, 'base');
				NPC.RemoveBuffImmunity(EET_PoisonCritical, 'base');
				opponentStats.damageValue = 3775;
				opponentStats.healthValue = 43940;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.9f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('WildHunt_Caranthir') )
			{
				//Kolaris - Wild Hunt Poison Vulnerability
				NPC.RemoveBuffImmunity(EET_Bleeding, 'base');
				NPC.RemoveBuffImmunity(EET_BleedingTracking, 'base');
				NPC.RemoveBuffImmunity(EET_Poison, 'base');
				NPC.RemoveBuffImmunity(EET_PoisonCritical, 'base');
				opponentStats.damageValue = 2260;
				opponentStats.healthValue = 34420;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.9f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.8f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('WildHunt_Eredin') )
			{
				//Kolaris - Wild Hunt Poison Vulnerability
				NPC.RemoveBuffImmunity(EET_Bleeding, 'base');
				NPC.RemoveBuffImmunity(EET_BleedingTracking, 'base');
				NPC.RemoveBuffImmunity(EET_Poison, 'base');
				NPC.RemoveBuffImmunity(EET_PoisonCritical, 'base');
				opponentStats.damageValue = 2240;
				opponentStats.healthValue = 39940;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.9f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= -0.1f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.5f;
				
				opponentStats.rangedDamageValue = 6200;
				opponentStats.rangedArmorPiercing = 0.8f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('q103_big_botch') )
			{
				opponentStats.damageValue = 2850;
				opponentStats.healthValue = 21850;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.35f;
				opponentStats.physicalResist	= 0.4f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.2f;
				opponentStats.slowResist 		= 0.15f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 1.0f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.45f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
				NPC.AddWeatherAbility(EDP_Dusk, EWE_Any, EMS_Any, 'dusk_night_necrophage');
				NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'dusk_night_necrophage');
			}
			else
			if( NPC.HasAbility('olgierd_default_stats') )
			{
				NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 24680;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.75f;
				opponentStats.physicalResist	= 0.0f;
				opponentStats.forceResist 		= 0.15f;
				opponentStats.frostResist 		= 0.15f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.1f;
				opponentStats.confusionResist 	= 0.1f;
				opponentStats.bleedingResist 	= 0.3f;
				opponentStats.poisonResist 		= 0.3f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.3f;
				opponentStats.regenDelay 		= 2.f;
				opponentStats.healthRegenFactor = 0.005f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_toad_base') )
			{
				opponentStats.damageValue = 3410;
				opponentStats.healthValue = 48450;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.6f;
				opponentStats.physicalResist	= 0.3f;
				opponentStats.forceResist 		= 0.35f;
				opponentStats.frostResist 		= -0.3f;
				opponentStats.fireResist 		= -0.4f;
				opponentStats.shockResist 		= -0.3f;
				opponentStats.elementalResist 	= -0.3f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.60f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_q701_giant') )
			{
				NPC.RemoveBuffImmunity(EET_Frozen);
				opponentStats.damageValue = 3940;
				opponentStats.healthValue = 40990;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.8f;
				opponentStats.physicalResist	= 0.75f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.15f;
				opponentStats.armorPiercing 	= 0.65f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_EP2_SpoonCollector') )
			{
				opponentStats.damageValue = 2495;
				opponentStats.healthValue = 22880;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.25f;
				opponentStats.physicalResist	= 0.2f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.4f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.15f;
				opponentStats.confusionResist 	= 0.15f;
				opponentStats.bleedingResist 	= 0.1f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.45f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_caretaker_ep1') )
			{
				opponentStats.damageValue = 2460;
				opponentStats.healthValue = 34100;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.9f;
				opponentStats.physicalResist	= 0.3f;
				opponentStats.forceResist 		= 0.7f;
				opponentStats.frostResist 		= 0.7f;
				opponentStats.fireResist 		= 0.7f;
				opponentStats.shockResist 		= 0.7f;
				opponentStats.elementalResist 	= 0.7f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 1.f;
				opponentStats.injuryResist 		= 0.5f;
				opponentStats.armorPiercing 	= 0.55f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_nightwraith_iris') )
			{
				opponentStats.damageValue = 1355;
				opponentStats.healthValue = 23380;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.1f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 1.f;
				opponentStats.shockResist 		= -0.3f;
				opponentStats.elementalResist 	= -0.3f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.55f;
				AddSpecterResistances(NPC);
			}
			else
			if( NPC.HasAbility('mon_dettlaff_vampire_base') )
			{
				opponentStats.damageValue = 1855;
				opponentStats.healthValue = 40520;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.45f;
				opponentStats.physicalResist	= 0.7f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.5f;
				opponentStats.fireResist 		= 0.3f;
				opponentStats.shockResist 		= 0.3f;
				opponentStats.elementalResist 	= 0.3f;
				opponentStats.slowResist 		= 0.1f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 0.3f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.1f;
				opponentStats.injuryResist 		= 0.1f;
				opponentStats.armorPiercing 	= 0.75f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('q704_dettlaff_bossbar') )
			{
				opponentStats.damageValue = 0;
				opponentStats.healthValue = 57750;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.95f;
				opponentStats.forceResist 		= 0.8f;
				opponentStats.frostResist 		= 0.8f;
				opponentStats.fireResist 		= 0.8f;
				opponentStats.shockResist 		= 0.4f;
				opponentStats.elementalResist 	= 0.4f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 0.5f;
				opponentStats.bleedingResist 	= 0.6f;
				opponentStats.poisonResist 		= 1.0f;
				opponentStats.stunResist 		= 0.5f;
				opponentStats.injuryResist 		= 0.5f;
				opponentStats.armorPiercing 	= 0.8f;
				NPC.IncBurnCounter(3);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_dettlaff_monster_base') )
			{
				opponentStats.damageValue = 7820;
				opponentStats.healthValue = 57750;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.95f;
				opponentStats.forceResist 		= 0.5f;
				opponentStats.frostResist 		= 0.5f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= 0.5f;
				opponentStats.elementalResist 	= 0.5f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 0.5f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 1.0f;
				opponentStats.stunResist 		= 0.5f;
				opponentStats.injuryResist 		= 0.5f;
				opponentStats.armorPiercing 	= 0.8f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('dettlaff_minion') )
			{
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 5500;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.45f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 1.f;
				opponentStats.shockResist 		= 1.f;
				opponentStats.elementalResist 	= 1.f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.1f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.65f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_SHOCK);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_fairytale_witch') )
			{
				opponentStats.damageValue = 1670;
				opponentStats.healthValue = 9850;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.0f;
				opponentStats.physicalResist	= 0.1f;
				opponentStats.forceResist 		= 0.f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.5f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_broom_base') )
			{
				opponentStats.damageValue = 315;
				opponentStats.healthValue = 3100;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.15f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= -1.f;
				opponentStats.shockResist 		= 1.f;
				opponentStats.elementalResist 	= 1.f;
				opponentStats.slowResist 		= 1.f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.15f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_SHOCK);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
			}
			else
			if( NPC.HasAbility('mon_cloud_giant') )
			{
				NPC.RemoveBuffImmunity(EET_Frozen); 
				opponentStats.damageValue = 4060;
				opponentStats.healthValue = 40990;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.8f;
				opponentStats.physicalResist	= 0.75f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.15f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			{
				wasNotScaled = true;
				opponentStats.damageValue = 1;
				opponentStats.healthValue = 1;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 10;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.f;
			}
		}
	}
    
	public function CalculateStatsPartHalf( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var weapon : array<SItemUniqueId>;
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Human :
					if( NPC.HasAbility('th700_preacher_ghost') )
                    {
						NPC.AddTag('ScaledHuman');
                        opponentStats.damageValue = 1885;
                        opponentStats.healthValue = 8250;
                        opponentStats.healthType = BCS_Essence;
                        
                        opponentStats.isArmored         = true;
                        opponentStats.isHuge            = true;
                        opponentStats.dangerLevel       = 50;
                        opponentStats.poiseValue        = 0.65f;
                        opponentStats.physicalResist    = 0.7f;
                        opponentStats.forceResist       = 0.35f;
                        opponentStats.frostResist       = 0.f;
                        opponentStats.fireResist        = 0.6f;
                        opponentStats.shockResist       = 0.3f;
                        opponentStats.elementalResist   = 0.f;
                        opponentStats.slowResist        = 0.15f;
                        opponentStats.confusionResist   = 0.25f;
                        opponentStats.bleedingResist    = 0.8f;
                        opponentStats.poisonResist      = 0.65f;
                        opponentStats.stunResist        = 0.3f;
                        opponentStats.injuryResist      = 0.25f;
                        opponentStats.armorPiercing     = 0.65f;
                        NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
                    }
                    else
					if( NPC.HasAbility('mon_q703_BosekKnight') )
                    {
						NPC.AddTag('ScaledHuman');
                        opponentStats.damageValue = 3200;
                        opponentStats.healthValue = 10820;
                        opponentStats.healthType = BCS_Vitality;
                        
                        opponentStats.isArmored         = true;
                        opponentStats.isHuge            = true;
                        opponentStats.dangerLevel       = 50;
                        opponentStats.poiseValue        = 0.65f;
                        opponentStats.physicalResist    = 0.7f;
                        opponentStats.forceResist       = 0.35f;
                        opponentStats.frostResist       = 0.f;
                        opponentStats.fireResist        = 0.6f;
                        opponentStats.shockResist       = 0.3f;
                        opponentStats.elementalResist   = 0.f;
                        opponentStats.slowResist        = 0.15f;
                        opponentStats.confusionResist   = 0.25f;
                        opponentStats.bleedingResist    = 0.8f;
                        opponentStats.poisonResist      = 0.65f;
                        opponentStats.stunResist        = 0.3f;
                        opponentStats.injuryResist      = 0.25f;
                        opponentStats.armorPiercing     = 0.65f;
                        NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
                    }
                    else
					if( NPC.HasAbility('mon_ethereal_ep1') )
					{
						NPC.AddTag('ScaledHuman');
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 1975;
						opponentStats.healthValue = 18840;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.5f;
					}
					else
					if( NPC.HasAbility('mon_ghosts_ep1') )
					{
						NPC.AddTag('ScaledHuman');
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 1885;
						opponentStats.healthValue = 7250;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('sq209_brans_warrior') )
					{
						NPC.AddTag('ScaledHuman');
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 2950;
						opponentStats.healthValue = 10080;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('sq209_lugos_the_mad_vision') )
					{
						NPC.AddTag('ScaledHuman');
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 3325;
						opponentStats.healthValue = 21080;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('dandelion') )
					{
						NPC.AddTag('ScaledHuman');
						opponentStats.damageValue = 900;
						opponentStats.healthValue = 4720;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.2f;
					}
					else
					if( NPC.HasTag('mh303_succubus') || NPC.HasTag('sq205_succubus') )
					{
						NPC.AddTag('ScaledHuman');
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2370;
						opponentStats.healthValue = 10760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.2f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.6f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.75f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.8f;
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Any, 'night_magic_amplified');
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Full, 'night_fullmoon_magic_amplified');
					}
					else
					if( NPC.HasAbility('SkillSorceress') )
					{
						NPC.AddTag('ScaledHuman');
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2730;
						//Kolaris - Extreme Cosplay Statue Nerf
						if( NPC.HasAbility('mon_qmq7007_mages') )
							opponentStats.healthValue = 5220;
						else
							opponentStats.healthValue = 9760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.05f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.3f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.3f;
						opponentStats.elementalResist 	= 0.3f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.75f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Any, 'night_magic_amplified');
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Full, 'night_fullmoon_magic_amplified');
					}
				break;
					
				default : return;
			}
		}
	}
    
	public function CalculateStatsPart1( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var weapon : array<SItemUniqueId>;
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') && !NPC.HasTag('ScaledHuman') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Human :
					if( NPC.HasAbility('mh305_doppler_geralt') || NPC.HasAbility('mh305_doppler') )
					{
						opponentStats.damageValue = 1450;
						opponentStats.healthValue = 8720;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.25f;
						opponentStats.physicalResist	= 0.3f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.25f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.3f;
					}
					else
					if( NPC.HasAbility('SkillWitcher') )
					{
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 3200;
						opponentStats.healthValue = 10820;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.6f;
						opponentStats.physicalResist	= 0.35f;
						opponentStats.forceResist 		= 0.15f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.1f;
						opponentStats.shockResist 		= 0.1f;
						opponentStats.elementalResist 	= 0.1f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.25f;
						opponentStats.bleedingResist 	= 0.15f;
						opponentStats.poisonResist 		= 0.2f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.35f;
					}
					else
					if( NPC.HasTag('q601_ofir_mage') )
					{
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						NPC.RemoveTag('MonsterHuntTarget');
						opponentStats.damageValue = 2110;
						opponentStats.healthValue = 7525;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.15f;
						opponentStats.frostResist 		= 0.15f;
						opponentStats.fireResist 		= 0.15f;
						opponentStats.shockResist 		= 0.2f;
						opponentStats.elementalResist 	= 0.2f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.75f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
					}
					else
					if( NPC.HasAbility('mon_EP2_hermit') )
					{
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						NPC.AddBuffImmunity(EET_Knockdown, 'base', true);
						NPC.AddBuffImmunity(EET_HeavyKnockdown, 'base', true);
						NPC.AddBuffImmunity(EET_KnockdownTypeApplicator, 'base', true);
						NPC.AddAbility('DisableFinishers');
						NPC.AddAbility('InstantKillImmune');
						NPC.RemoveTag('MonsterHuntTarget');
						opponentStats.damageValue = 1715;
						opponentStats.healthValue = 7525;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.35f;
						opponentStats.frostResist 		= -0.25f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.2f;
						opponentStats.elementalResist 	= 0.2f;
						opponentStats.slowResist 		= 0.25f;
						opponentStats.confusionResist 	= 0.75f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
					}
					else
					if( NPC.HasAbility('mon_EP2_cystus') )
					{
						opponentStats.damageValue = 3300;
						opponentStats.healthValue = 20130;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isArmored			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.poiseValue 		= 0.6f;
						opponentStats.physicalResist	= 0.9f;
						opponentStats.forceResist 		= 0.4f;
						opponentStats.frostResist 		= 0.4f;
						opponentStats.fireResist 		= 0.6f;
						opponentStats.shockResist 		= -0.2f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.5f;
						opponentStats.bleedingResist 	= 0.6f;
						opponentStats.poisonResist 		= 0.4f;
						opponentStats.stunResist 		= 0.5f;
						opponentStats.injuryResist 		= 0.4f;
						opponentStats.armorPiercing 	= 0.4f;
					}
					else
					if( NPC.HasAbility('q604_shades') )
					{
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 0;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 0;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.f;
						AddSpecterResistances(NPC);
					}
					else
					{
						NPC.RemoveAbility('DisableFinishers'); //Kolaris - Finisher Immunity
						armorType = GetArmorType(NPC);
						GetWeaponTypes(NPC, opponentStats);
						
						if( opponentStats.meleeWeapon == EMWT_GreatAxe )
						{
							weapon = NPC.GetInventory().GetItemsByName('geralt_axe_01');
							if( !weapon.Size() )
								NPC.GetInventory().AddAnItem('geralt_axe_01', 1);
						}
						switch(opponentStats.meleeWeapon)
						{
							case EMWT_Sword1H:				opponentStats.damageValue = 2475;	opponentStats.armorPiercing = 0.20f;	break;
							case EMWT_Sword1HStrong:		opponentStats.damageValue = 2530;	opponentStats.armorPiercing = 0.25f;	break;
							case EMWT_Sword2H:				opponentStats.damageValue = 3200;	opponentStats.armorPiercing = 0.35f;	break;
							case EMWT_Hatchet:				opponentStats.damageValue = 2075;	opponentStats.armorPiercing = 0.35f;	break;
							case EMWT_Axe:					opponentStats.damageValue = 2220;	opponentStats.armorPiercing = 0.40f;	break;
							case EMWT_GreatAxe:				opponentStats.damageValue = 3560;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_Club:					opponentStats.damageValue = 1940;	opponentStats.armorPiercing = 0.20f;	break;
							case EMWT_Mace:					opponentStats.damageValue = 2125;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_GreatHammerWood:		opponentStats.damageValue = 3035;	opponentStats.armorPiercing = 0.30f;	break;
							case EMWT_GreatHammerMetal:		opponentStats.damageValue = 3035;	opponentStats.armorPiercing = 0.55f;	break;
							case EMWT_Halberd:				opponentStats.damageValue = 3235;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_Pike:					opponentStats.damageValue = 3235;	opponentStats.armorPiercing = 0.55f;	break;
							case EMWT_Spear:				opponentStats.damageValue = 2585;	opponentStats.armorPiercing = 0.50f;	break;
							case EMWT_Staff:				opponentStats.damageValue = 1835;	opponentStats.armorPiercing = 0.20f;	break;
							case EMWT_SwordWooden:			opponentStats.damageValue = 1335;	opponentStats.armorPiercing = 0.10f;	break;
							case EMWT_MetalPole:			opponentStats.damageValue = 2235;	opponentStats.armorPiercing = 0.25f;	break;
							case EMWT_FirePoker:			opponentStats.damageValue = 2310;	opponentStats.armorPiercing = 0.30f;	break;
							default :						opponentStats.damageValue = 2475;	opponentStats.armorPiercing = 0.20f;	break;
						}
						
						switch(opponentStats.rangedWeapon)
						{
							case ERWT_ShortBow:		opponentStats.rangedDamageValue = 2870;	opponentStats.rangedArmorPiercing = 0.25f;	break;
							case ERWT_LongBow:		opponentStats.rangedDamageValue = 3560;	opponentStats.rangedArmorPiercing = 0.35f;	break;
							case ERWT_Crossbow:		opponentStats.rangedDamageValue = 3285;	opponentStats.rangedArmorPiercing = 0.75f;	break;
							default :				opponentStats.rangedDamageValue = 0;	opponentStats.rangedArmorPiercing = 0.f;	break;
						}
						
						switch(armorType)
						{
							case 'Heavy':
								opponentStats.healthValue = 5220;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 50;
								opponentStats.canGetCrippled 	= false;
								opponentStats.poiseValue 		= 0.65f;
								opponentStats.physicalResist	= 0.90f;
								opponentStats.forceResist 		= 0.35f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.6f;
								opponentStats.shockResist 		= 0.3f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.15f;
								opponentStats.confusionResist 	= 0.25f;
								opponentStats.bleedingResist 	= 0.8f;
								opponentStats.poisonResist 		= 0.65f;
								opponentStats.stunResist 		= 0.3f;
								opponentStats.injuryResist 		= 0.25f;
							break;
							
							case 'Mixed':
								opponentStats.healthValue = 4770;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 50;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.4f;
								opponentStats.physicalResist	= 0.65f;
								opponentStats.forceResist 		= 0.25f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.35f;
								opponentStats.shockResist 		= 0.2f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.1f;
								opponentStats.confusionResist 	= 0.25f;
								opponentStats.bleedingResist 	= 0.7f;
								opponentStats.poisonResist 		= 0.55f;
								opponentStats.stunResist 		= 0.1f;
								opponentStats.injuryResist 		= 0.1f;
							break;
							
							case 'Medium':
								opponentStats.healthValue = 4470;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 50;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.25f;
								opponentStats.physicalResist	= 0.4f;
								opponentStats.forceResist 		= 0.1f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.2f;
								opponentStats.shockResist 		= 0.15f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.05f;
								opponentStats.confusionResist 	= 0.25f;
								opponentStats.bleedingResist 	= 0.45f;
								opponentStats.poisonResist 		= 0.3f;
								opponentStats.stunResist 		= 0.1f;
								opponentStats.injuryResist 		= 0.1f;
							break;
							
							case 'Light':
								opponentStats.healthValue = 4170;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 10;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.15f;
								opponentStats.physicalResist	= 0.2f;
								opponentStats.forceResist 		= 0.f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.05f;
								opponentStats.shockResist 		= 0.f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.0f;
								opponentStats.confusionResist 	= 0.25f;
								opponentStats.bleedingResist 	= 0.2f;
								opponentStats.poisonResist 		= 0.1f;
								opponentStats.stunResist 		= 0.f;
								opponentStats.injuryResist 		= 0.05f;
							break;
							
							default:
								opponentStats.healthValue = 3970;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 10;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.05f;
								opponentStats.physicalResist	= 0.0f;
								opponentStats.forceResist 		= -0.1f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.f;
								opponentStats.shockResist 		= 0.f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= -0.05f;
								opponentStats.confusionResist 	= 0.25f;
								opponentStats.bleedingResist 	= -0.2f;
								opponentStats.poisonResist 		= -0.15f;
								opponentStats.stunResist 		= -0.1f;
								opponentStats.injuryResist 		= -0.15f;
							break;
						}
						opponentStats.healthType = BCS_Vitality;
					}
				break;
				
				default : return;
			}
		}
	}
    
	public function CalculateStatsSpecter( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Specter :
					NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'base_specter');
					if( NPC.HasAbility('mon_ethereal_ep1') )
					{
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.damageValue = 1975;
						opponentStats.healthValue = 19840;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.5f;
					}
					else
					if( NPC.HasAbility('SkillGregoireGhost') )
                    {
                        opponentStats.damageValue = 4320;
                        opponentStats.healthValue = 20130;
                        opponentStats.healthType = BCS_Essence;
                        
                        opponentStats.isHuge            = true;
                        opponentStats.dangerLevel       = 100;
                        opponentStats.poiseValue        = 0.6f;
                        opponentStats.physicalResist    = 0.f;
                        opponentStats.forceResist       = 1.f;
                        opponentStats.frostResist       = 1.f;
                        opponentStats.fireResist        = 1.f;
                        opponentStats.shockResist       = -0.3f;
                        opponentStats.elementalResist   = -0.3f;
                        opponentStats.slowResist        = 0.2f;
                        opponentStats.confusionResist   = 1.f;
                        opponentStats.bleedingResist    = 1.f;
                        opponentStats.poisonResist      = 1.f;
                        opponentStats.stunResist       	= 1.f;
                        opponentStats.injuryResist      = 1.f;
                        opponentStats.armorPiercing     = 0.65f;
                        AddSpecterResistances(NPC);
                    }
                    else
					if( NPC.HasAbility('mon_ghoul_base') )
					{
						opponentStats.damageValue = 2210;
						opponentStats.healthValue = 7440;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_ghosts_ep1') )
					{
						opponentStats.damageValue = 1885;
						opponentStats.healthValue = 6650;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_barghest_base') )
					{
						opponentStats.damageValue = 2185;
						opponentStats.healthValue = 7630;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.5f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Full, 'fullmoon_barghest');
					}
					else
					if( NPC.HasAbility('mon_lessog_base') ) //hym
					{
						opponentStats.damageValue = 4840;
						opponentStats.healthValue = 40300;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 1.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.4f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mh207_wraith_boss') )
					{
						NPC.AddTag('WeakToQuen');
						//NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
						opponentStats.damageValue = 2935;
						opponentStats.healthValue = 325400;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.25f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						//opponentStats.regenDelay 		= 2.f;
						//opponentStats.healthRegenFactor = 0.003f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mh207_wraith') )
					{
						NPC.AddTag('WeakToQuen');
						FixMH207Facts();
						NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
						opponentStats.damageValue = 1950;
						opponentStats.healthValue = 4115;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= -0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.5f;
						opponentStats.regenDelay 		= 3.f;
						opponentStats.healthRegenFactor = 0.1f;
						AddSpecterResistances(NPC);
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_wraith');
					}
					else
					if( NPC.HasAbility('mon_wraith_base') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
						opponentStats.damageValue = 1950;
						opponentStats.healthValue = 4115;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= -0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.5f;
						opponentStats.regenDelay 		= 3.f;
						opponentStats.healthRegenFactor = 0.1f;
						AddSpecterResistances(NPC);
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_wraith');
					}
					else
					if( NPC.HasAbility('mon_nightwraith_banshee') )
					{
						opponentStats.damageValue = 1510;
						opponentStats.healthValue = 24953;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('skeleton') )
					{
						opponentStats.damageValue = 2435;
						opponentStats.healthValue = 3200;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.8f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.4f;
						opponentStats.armorPiercing 	= 0.30f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_noonwraith_base') )
					{
						NPC.AddTimer('AddHealthRegenEffect', 0.01f, false);
						opponentStats.damageValue = 3316;
						opponentStats.healthValue = 24953;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.75f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						opponentStats.healthRegenFactor = 0.0f;
						AddSpecterResistances(NPC);
						if( NPC.HasAbility('mon_nightwraith') )
						{
							NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_nightwraith');
							NPC.AddWeatherAbility(EDP_Noon, EWE_Any, EMS_Any, 'noon_nightwraith');
						}
						else
						if( !NPC.HasAbility('mon_pesta') )
						{
							NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_noonwraith');
							NPC.AddWeatherAbility(EDP_Noon, EWE_Any, EMS_Any, 'noon_noonwraith');
						}
					}
					else
					if( NPC.HasAbility('mon_noonwraith_doppelganger') )
					{
						NPC.AddTimer('AddHealthRegenEffect', 0.01f, false);
						opponentStats.damageValue = 3685;
						opponentStats.healthValue = 10;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.f;
						opponentStats.healthRegenFactor = 0.0f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_black_spider_base') || NPC.HasAbility('mon_black_spider_ep2_base') || NPC.HasAbility('mon_spiders604_ep1') )
					{
						AddSpecterResistances(NPC);
						if( NPC.HasAbility('mon_black_spider_large') || NPC.HasAbility('mon_black_spider_ep2_large') )
						{
							opponentStats.damageValue = 2125;
							opponentStats.healthValue = 17780;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 1.f;
							opponentStats.frostResist 		= 1.f;
							opponentStats.fireResist 		= 1.0f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.45f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 1335;
							opponentStats.healthValue = 6360;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 1.f;
							opponentStats.frostResist 		= 1.f;
							opponentStats.fireResist 		= 1.0f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.35f;
						}
					}
					else
					if( NPC.HasAbility('mon_panther_ghost') )
					{
						opponentStats.damageValue = 2410;
						opponentStats.healthValue = 11730;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.6f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('q210_WH_Ghost') )
					{
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						opponentStats.healthValue = 7130;
						opponentStats.healthType = BCS_Essence;
						
						GetWeaponTypes(NPC, opponentStats);
						switch(opponentStats.meleeWeapon)
						{
							case EMWT_Sword2H:				opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_GreatAxe:				opponentStats.damageValue = 4105;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_GreatHammerMetal:		opponentStats.damageValue = 4105;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_Halberd:				opponentStats.damageValue = 4235;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_Spear:				opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.55f;	break;
							default: 						opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.45f;	break;
						}
						
						opponentStats.isArmored			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.9f;
						opponentStats.physicalResist	= 0.7f;
						opponentStats.forceResist 		= 0.6f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.4f;
						opponentStats.shockResist 		= -0.4f;
						opponentStats.elementalResist 	= -0.2f;
						opponentStats.slowResist 		= 0.5f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('SkillThug') )
					{
						opponentStats.damageValue = 2080;
						opponentStats.healthValue = 4170;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.4f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.4f;
						opponentStats.fireResist 		= -0.4f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= -0.2f;
						opponentStats.slowResist 		= 0.0f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.3f;
						AddSpecterResistances(NPC);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				default : return;
			}
		}
	}
	
	public function CalculateStatsPart2( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Vampire :

					NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_vampire');
					NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Full, 'fullmoon_vampire');
					NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_vampire');
					if( NPC.HasAbility('mon_vampiress_base') )
					{
						opponentStats.damageValue = 1615;
						opponentStats.healthValue = 20750;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.45f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 0.65f;
						opponentStats.fireResist 		= 0.65f;
						opponentStats.shockResist 		= 0.35f;
						opponentStats.elementalResist 	= 0.35f;
						opponentStats.slowResist 		= 0.05f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.6f;
						opponentStats.stunResist 		= 0.1f;
						opponentStats.injuryResist 		= 0.1f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
						//NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
					}
					else
					if( NPC.HasAbility('mon_werewolf_base') )
					{
						NPC.AddAbility('DisableFinishers', false);
						if( NPC.HasAbility('mon_fleder') )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2605;
							opponentStats.healthValue = 26350;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.3f;
							opponentStats.physicalResist	= 0.55f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.7f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= -1.0f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.7f;
							opponentStats.armorPiercing 	= 0.35f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if (NPC.HasAbility('mon_garkain') )
						{
							//Kolaris - Garkain Poison Immunity Removal
							NPC.RemoveBuffImmunity(EET_Poison, 'base');
							NPC.RemoveBuffImmunity(EET_PoisonCritical, 'base');
							opponentStats.damageValue = 4185;
							opponentStats.healthValue = 17340;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.15f;
							opponentStats.physicalResist	= 0.3f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.7f;
							opponentStats.shockResist 		= 0.5f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.05f;
							opponentStats.confusionResist 	= 1.0f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.20f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							//NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_katakan') || NPC.HasAbility('mon_ekimma'))
						{
							NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
							opponentStats.damageValue = 3105;
							opponentStats.healthValue = 26470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.6f;
							opponentStats.regenDelay		= 8.f;
							opponentStats.healthRegenFactor = 0.005f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
							if( NPC.HasAbility('mon_katakan') )
							{
								NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_katakan');
							}
						}
						else
						if( NPC.HasAbility('mon_katakan_large') )
						{
							NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
							opponentStats.damageValue = 3330;
							opponentStats.healthValue = 27570;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.1f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.65f;
							opponentStats.regenDelay		= 8.f;
							opponentStats.healthRegenFactor = 0.005f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
							NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_katakan');
						}
						else
						{
							opponentStats.damageValue = 3105;
							opponentStats.healthValue = 26470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.2f;
							opponentStats.confusionResist 	= 0.25f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.65f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Magicals :
					if( NPC.HasAbility('mon_gargoyle') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2035;
						opponentStats.healthValue = 17870;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.90f;
						opponentStats.forceResist 		= 0.8f;
						opponentStats.frostResist 		= 0.85f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
					}
					else
					if( NPC.HasAbility('mon_fugas_base') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2835;
						opponentStats.healthValue = 20870;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.6f;
						opponentStats.physicalResist	= 0.90f;
						opponentStats.forceResist 		= 0.8f;
						opponentStats.frostResist 		= 0.85f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.8f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
					}
					else
					if( NPC.HasAbility('mon_golem_base') )
					{
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_elementa');
						NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_elementa');
						NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_elementa');
						NPC.AddWeatherAbility(EDP_Undefined, EWE_Any, EMS_Full, 'fullmoon_elementa');
						if (NPC.HasAbility('mon_ice_golem'))
						{
							opponentStats.damageValue = 4025;
							opponentStats.healthValue = 32540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.9f;
							opponentStats.physicalResist	= 0.9f;
							opponentStats.forceResist 		= 0.8f;
							opponentStats.frostResist 		= 0.85f;
							opponentStats.fireResist 		= -2.f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= -0.3f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 1.f;
							opponentStats.injuryResist 		= 1.0f;
							opponentStats.armorPiercing 	= 0.85f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Snow, EMS_Any, 'snow_ice_elementa');
						}
						else
						if (NPC.HasAbility('mon_elemental_fire') || NPC.HasAbility('mon_elemental_fire_q211'))
						{
							opponentStats.damageValue = 4025;
							opponentStats.healthValue = 32540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.9f;
							opponentStats.physicalResist	= 1.0f;
							opponentStats.forceResist 		= 0.8f;
							opponentStats.frostResist 		= 0.85f;
							opponentStats.fireResist 		= 1.f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= -0.3f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 1.f;
							opponentStats.injuryResist 		= 1.0f;
							opponentStats.armorPiercing 	= 0.85f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_fire_elementa');
						}
						else
						if (NPC.HasAbility('mon_elemental_dao') || NPC.HasAbility('mon_elemental_dao_lesser'))
						{
							opponentStats.damageValue = 4025;
							opponentStats.healthValue = 30540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.9f;
							opponentStats.physicalResist	= 1.0f;
							opponentStats.forceResist 		= 0.8f;
							opponentStats.frostResist 		= 0.85f;
							opponentStats.fireResist 		= 1.f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= -0.3f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 1.f;
							opponentStats.injuryResist 		= 1.0f;
							opponentStats.armorPiercing 	= 0.85f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Snow, EMS_Any, 'snow_earth_elementa');
						}
						else
						{
							opponentStats.damageValue = 4025;
							opponentStats.healthValue = 32540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.9f;
							opponentStats.physicalResist	= 1.0f;
							opponentStats.forceResist 		= 0.8f;
							opponentStats.frostResist 		= 0.85f;
							opponentStats.fireResist 		= 1.f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= -0.3f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 1.f;
							opponentStats.injuryResist 		= 1.0f;
							opponentStats.armorPiercing 	= 0.85f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_wild_hunt_default') )
					{
						//Kolaris - Wild Hunt Poison Vulnerability
						NPC.AddBuffImmunity(EET_Immobilized, 'base', true);
						NPC.RemoveBuffImmunity(EET_Bleeding, 'base');
						NPC.RemoveBuffImmunity(EET_BleedingTracking, 'base');
						NPC.RemoveBuffImmunity(EET_Poison, 'base');
						NPC.RemoveBuffImmunity(EET_PoisonCritical, 'base');
						opponentStats.healthValue = 7130;
						opponentStats.healthType = BCS_Vitality;
						
						GetWeaponTypes(NPC, opponentStats);
						switch(opponentStats.meleeWeapon)
						{
							case EMWT_Sword2H:				opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_GreatAxe:				opponentStats.damageValue = 4105;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_GreatHammerMetal:		opponentStats.damageValue = 4105;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_Halberd:				opponentStats.damageValue = 4235;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_Spear:				opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.55f;	break;
							default: 						opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.45f;	break;
						}
						
						opponentStats.isArmored			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.9f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.6f;
						opponentStats.shockResist 		= -0.2f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.1f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.8f;
						opponentStats.poisonResist 		= 0.3f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
					}
					else
					if( NPC.HasAbility('mon_ghoul_base') )
					{
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 2100;
						opponentStats.healthValue = 5200;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.55f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= -0.45f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= -0.8f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.4f;
						opponentStats.armorPiercing 	= 0.45f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddWeatherAbility(EDP_Undefined, EWE_Snow, EMS_Any, 'snow_wh_hound');
					}
					else
					if( NPC.HasAbility('mon_nekker_base') )
					{
						opponentStats.damageValue = 1775;
						opponentStats.healthValue = 4170;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.1f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.2f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.1f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.0f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.45f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Cursed :
					if( NPC.HasAbility('mon_archespor_base') )
					{
						opponentStats.damageValue = 1670;
						opponentStats.healthValue = 13030;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 0.3f;
						opponentStats.fireResist 		= -0.8f;
						opponentStats.shockResist 		= 0.5f;
						opponentStats.elementalResist 	= 0.5f;
						opponentStats.slowResist 		= 1.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.30f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_SLOW);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear__archespor');
					}
					else
					if( NPC.HasAbility('mon_bear_base') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2885;
						opponentStats.healthValue = 28380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.15f;
						opponentStats.fireResist 		= -0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.3f;
						opponentStats.poisonResist 		= 0.2f;
						opponentStats.stunResist 		= 0.3f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.55f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_werewolf_base') )
					{
						opponentStats.damageValue = 2975;
						opponentStats.healthValue = 26380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.65f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.2f;
						opponentStats.fireResist 		= -0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.3f;
						opponentStats.poisonResist 		= 0.3f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.6f;
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_werewolf');
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Full, 'fullmoon_werewolf');
						NPC.AddAbility('DisableFinishers', false);
					}
					//Kolaris - RER Compatibility
					else
					if( NPC.HasAbility('mon_greater_miscreant') )
					{
						opponentStats.damageValue = 2850;
						opponentStats.healthValue = 21850;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.poiseValue 		= 0.35f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.2f;
						opponentStats.fireResist 		= 0.2f;
						opponentStats.shockResist 		= 0.2f;
						opponentStats.elementalResist 	= 0.2f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.2f;
						opponentStats.poisonResist 		= 1.0f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.45f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddWeatherAbility(EDP_Dusk, EWE_Any, EMS_Any, 'dusk_night_necrophage');
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'dusk_night_necrophage');
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Insectoid :
					NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_insectoid');
					NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_insectoid');
					if( NPC.HasAbility('mon_arachas_base') )
					{
						if( NPC.HasAbility('mon_arachas_armored') )
						{
							opponentStats.damageValue = 2135;
							opponentStats.healthValue = 27670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.90f;
							opponentStats.forceResist 		= 0.15f;
							opponentStats.frostResist 		= 0.25f;
							opponentStats.fireResist 		= 0.75;
							opponentStats.shockResist 		= 0.25f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.4f;
							opponentStats.armorPiercing 	= 0.60f;
							opponentStats.rangedDamageValue = 100;
							opponentStats.rangedArmorPiercing = 1.f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						if( NPC.HasAbility('mon_poison_arachas') )
						{
							opponentStats.damageValue = 2135;
							opponentStats.healthValue = 30670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.15f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.60f;
							opponentStats.rangedDamageValue = 100;
							opponentStats.rangedArmorPiercing = 1.f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 2135;
							opponentStats.healthValue = 28670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.7f;
							opponentStats.forceResist 		= 0.15f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.60f;
							opponentStats.rangedDamageValue = 100;
							opponentStats.rangedArmorPiercing = 1.f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_black_spider_base') || NPC.HasAbility('mon_black_spider_ep2_base') )
					{
						NPC.AddTag('WeakToAard');
						if( NPC.HasAbility('mon_black_spider_large') || NPC.HasAbility('mon_black_spider_ep2_large') )
						{
							opponentStats.damageValue = 2125;
							opponentStats.healthValue = 17780;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.5f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= -1.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.45f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 1335;
							opponentStats.healthValue = 6360;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.5f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= -1.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.25f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_endriaga_base') )
					{
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						if( NPC.HasAbility('mon_endriaga_worker') )
						{
							opponentStats.damageValue = 885;
							opponentStats.healthValue = 4670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.15f;
							opponentStats.physicalResist	= 0.25f;
							opponentStats.forceResist 		= 0.1f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.8f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_endriaga_soldier_tailed') )
						{
							opponentStats.damageValue = 2065;
							opponentStats.healthValue = 6810;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.25f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.1f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.15f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.45f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_endriaga_soldier_spikey') )
						{
							opponentStats.damageValue = 1685;
							opponentStats.healthValue = 5220;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.65f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.60f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_scolopendromorph_base') )
					{
						opponentStats.damageValue = 2935;
						opponentStats.healthValue = 10330;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 1.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.6f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.4f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_kikimore_base') )
					{
						NPC.AddTag('WeakToAard');
						if( NPC.HasAbility('mon_kikimore_small') )
						{
							opponentStats.damageValue = 910;
							opponentStats.healthValue = 6630;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.6f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.3f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.8f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 2025;
							opponentStats.healthValue = 14250;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.75f;
							opponentStats.forceResist 		= 0.3f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.7f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.1f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.6f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				default : return;
			}
		}
	}
    
	public function CalculateStatsPart3( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Troll :
					if( NPC.HasAbility('mon_troll_base') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2985;
						opponentStats.healthValue = 17460;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.75f;
						opponentStats.physicalResist	= 0.65f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= -1.f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.6f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						if( NPC.HasAbility('mon_ice_troll') )
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Snow, EMS_Any, 'snow_ice_troll');
						if( NPC.HasAbility('mon_black_troll') )
						{
							opponentStats.healthValue		*= 1.11;
							opponentStats.physicalResist 	+= 0.07;
						}
						if( NPC.HasAbility('mon_cave_troll_young') )
						{
							opponentStats.damageValue		*= 0.93;
							opponentStats.physicalResist	-= 0.15;
						}
					}
					else
					if( NPC.HasAbility('mon_cyclops') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 3305;
						opponentStats.healthValue = 31710;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.5f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= -0.4f;
						opponentStats.bleedingResist 	= 0.2f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_ice_giant') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 3560;
						opponentStats.healthValue = 45550;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.8f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.2f;
						opponentStats.poisonResist 		= -0.3f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_nekker_base') )
					{
						if( NPC.HasAbility('mon_nekker_warrior') )
						{
							opponentStats.damageValue = 2055;
							opponentStats.healthValue = 5690;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= -0.1f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= -0.1f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= -0.1f;
							opponentStats.injuryResist 		= -0.1f;
							opponentStats.armorPiercing 	= 0.45f;
						}
						else
						{
							opponentStats.damageValue = 1655;
							opponentStats.healthValue = 3670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.15f;
							opponentStats.frostResist 		= -0.15f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.1f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= -0.15f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= -0.15f;
							opponentStats.injuryResist 		= -0.1f;
							opponentStats.armorPiercing 	= 0.4f;
						}
					}
					//Kolaris - RER Compatibility
					else
					if( NPC.HasAbility('mon_knight_giant') )
					{
						NPC.RemoveBuffImmunity(EET_Frozen);
						opponentStats.damageValue = 3940;
						opponentStats.healthValue = 40990;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.poiseValue 		= 0.8f;
						opponentStats.physicalResist	= 0.75f;
						opponentStats.forceResist 		= 0.4f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.2f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Necrophage :
					NPC.AddWeatherAbility(EDP_Dusk, EWE_Any, EMS_Any, 'dusk_night_necrophage');
					NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'dusk_night_necrophage');
					if( NPC.HasAbility('mon_ghoul_base') )
					{
						if( NPC.HasAbility('mon_alghoul') )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2665;
							opponentStats.healthValue = 6880;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.3f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.5f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.6f;
						}
						else
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2230;
							opponentStats.healthValue = 5980;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.15f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.5f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.5f;
						}
					}
					else
					if( NPC.HasAbility('mon_drowner_base') )
					{
						if ( NPC.GetInventory().HasItem('mon_drowned_dead_weapon') )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2230;
							opponentStats.healthValue = 6475;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.3f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= -0.4f;
							opponentStats.fireResist 		= 0.6f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= -0.4f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.35f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.IncBurnCounter(2);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_drowner');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'rain_drowner');
						}
						else
						if ( NPC.HasAbility('mon_drowner') )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2095;
							opponentStats.healthValue = 5630;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.15f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= -0.4f;
							opponentStats.fireResist 		= 0.6f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.4f;
							opponentStats.bleedingResist 	= -0.4f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= -0.3f;
							opponentStats.armorPiercing 	= 0.25f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.IncBurnCounter(2);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_drowner');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'rain_drowner');
						}
						else
						if ( NPC.HasAbility('mon_gravier') )
						{
							opponentStats.damageValue = 2320;
							opponentStats.healthValue = 6130;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.4f;
							opponentStats.fireResist 		= 0.0f;
							opponentStats.shockResist 		= 0.1f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.3f;
							opponentStats.poisonResist 		= 0.8f;
							opponentStats.stunResist 		= 0.0f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.5f;
							NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_rotfiend');
						}
						else
						{
							opponentStats.damageValue = 2320;
							opponentStats.healthValue = 6130;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.0f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.4f;
							opponentStats.fireResist 		= -0.4f;
							opponentStats.shockResist 		= 0.1f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.9f;
							opponentStats.stunResist 		= 0.0f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.30f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_rotfiend');
						}
					}
					else
					if( NPC.HasAbility('mon_fogling_doppelganger') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 835;
						opponentStats.healthValue = 10;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.25f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.1f;
						opponentStats.confusionResist 	= 0.1f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.5f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.6f;
					}
					else
					if( NPC.HasAbility('mon_gravehag_base') )
					{
						NPC.AddTag('WeakToQuen');
						if( NPC.HasAbility('mon_wight') )
						{
							opponentStats.damageValue = 2495;
							opponentStats.healthValue = 10480;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.2f;
							opponentStats.forceResist 		= 0.3f;
							opponentStats.frostResist 		= 0.3f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.15f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.40f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						}
						else
						if( NPC.HasAbility('mon_waterhag') || NPC.HasAbility('mon_waterhag_greater') )
						{
							opponentStats.damageValue = 2495;
							opponentStats.healthValue = 9280;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.2f;
							opponentStats.forceResist 		= 0.3f;
							opponentStats.frostResist 		= -0.6f;
							opponentStats.fireResist 		= 0.7f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.15f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.40f;
							opponentStats.rangedDamageValue = 10;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.IncBurnCounter(3);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_drowner');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'rain_drowner');
							if( NPC.HasAbility('mon_waterhag_greater') )
							{
								opponentStats.healthValue *= 1.25f;
								opponentStats.armorPiercing *= 1.1f;
							}
						}
						else
						if( NPC.HasAbility('mon_gravehag') )
						{
							opponentStats.damageValue = 2195;
							opponentStats.healthValue = 10280;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.1f;
							opponentStats.forceResist 		= 0.4f;
							opponentStats.frostResist 		= 0.5f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.15f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 0.8f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.40f;
							opponentStats.rangedDamageValue = 10;
							opponentStats.rangedArmorPiercing = 0.f;
							NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_gravehag');
						}
						else											//Fogling
						{
							opponentStats.damageValue = 2565;
							opponentStats.healthValue = 8780;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.1f;
							opponentStats.forceResist 		= 0.3f;
							opponentStats.frostResist 		= 0.3f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.15f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 0.5f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.40f;
							opponentStats.rangedDamageValue = 10;
							opponentStats.rangedArmorPiercing = 0.f;
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Fog, EMS_Any, 'fog_fogling');
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Hybrid :
					if( NPC.HasAbility('mon_gryphon_base') ) //actual griffin.
					{
						NPC.AddTag('WeakToAard');
						opponentStats.damageValue = 3425;
						opponentStats.healthValue = 43790;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.5f;
						opponentStats.physicalResist	= 0.35f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= -0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.3f;
						opponentStats.bleedingResist 	= 0.3f;
						opponentStats.poisonResist 		= -0.3f;
						opponentStats.stunResist 		= 0.35f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_harpy_base') )
					{
						if( NPC.HasAbility('mon_erynia') )
						{
							NPC.AddTag('WeakToAard');
							opponentStats.damageValue = 1445;
							opponentStats.healthValue = 6130;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.4f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.65f;
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_harpy');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_harpy');
						}
						else
						{
							NPC.AddTag('WeakToAard');
							opponentStats.damageValue = 1205;
							opponentStats.healthValue = 5380;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.4f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= -0.2f;
							opponentStats.injuryResist 		= -0.2f;
							opponentStats.armorPiercing 	= 0.55f;
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_harpy');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_harpy');
						}
					}
					else
					if( NPC.HasAbility('SkillSorceress') )
					{
						NPC.AddTag('WeakToAard');
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2370;
						opponentStats.healthValue = 10760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.2f;
						opponentStats.physicalResist	= 0.1f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.6f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.8f;
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Any, 'night_magic_amplified');
						NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Full, 'night_fullmoon_magic_amplified');
					}
					else
					if( NPC.HasAbility('mon_siren_base') )
					{
						if( NPC.HasAbility('mon_lamia') )
						{
							if( NPC.HasAbility('qmh210_lamia') )
							{
								NPC.AddAbility('DisableFinishers');
								NPC.AddAbility('InstantKillImmune');
							}
							NPC.AddTag('WeakToAard');
							opponentStats.damageValue = 1615;
							opponentStats.healthValue = 8005;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.2f;
							opponentStats.frostResist 		= -0.2f;
							opponentStats.fireResist 		= 0.65f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.65f;
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_siren');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_siren');
							NPC.IncBurnCounter(3);
						}
						else
						{
							NPC.AddTag('WeakToAard');
							opponentStats.damageValue = 1345;
							opponentStats.healthValue = 6960;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.2f;
							opponentStats.frostResist 		= -0.3f;
							opponentStats.fireResist 		= 0.55f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.55f;
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Rain, EMS_Any, 'rain_siren');
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_siren');
							NPC.IncBurnCounter(3);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				default : return;
			}
		}
	}
	
	public function CalculateStatsPart4( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Relic :
					NPC.AddWeatherAbility(EDP_Dawn, EWE_Any, EMS_Any, 'dawn_dusk_relict');
					NPC.AddWeatherAbility(EDP_Dusk, EWE_Any, EMS_Any, 'dawn_dusk_relict');
					if( NPC.HasAbility('mon_bies_base') )
					{
						if( NPC.HasAbility('mon_czart') )
						{
							NPC.AddTimer('AddHealthRegenEffect', .3f, false);
							opponentStats.damageValue = 3870;
							opponentStats.healthValue = 30560;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.8f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.45f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.15f;
							opponentStats.elementalResist 	= 0.15f;
							opponentStats.slowResist 		= 0.35f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= -0.1f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.70f;
							opponentStats.regenDelay		= 3.0f;
							opponentStats.healthRegenFactor	= 0.004f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							NPC.AddTimer('AddHealthRegenEffect', .3f, false);
							opponentStats.damageValue = 4185;
							opponentStats.healthValue = 36560;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.8f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.55f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.15f;
							opponentStats.elementalResist 	= 0.15f;
							opponentStats.slowResist 		= 0.3f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= -0.1f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.80f;
							opponentStats.regenDelay		= 3.0f;
							opponentStats.healthRegenFactor	= 0.006f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
							NPC.AddWeatherAbility(EDP_Undefined, EWE_Storm, EMS_Any, 'storm_fiend');
						}
					}
					else
					if( NPC.HasAbility('mon_lessog_base') )
					{
						opponentStats.damageValue = 3235;
						opponentStats.healthValue = 29760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.85f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.8f;
						opponentStats.frostResist 		= 1.0f;
						opponentStats.fireResist 		= -0.5f;
						opponentStats.shockResist 		= 1.f;
						opponentStats.elementalResist 	= 1.f;
						opponentStats.slowResist 		= 0.6f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.5f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.75f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_ELEMENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
					}
					else
					if( NPC.HasAbility('mon_sharley_base') )
					{
						NPC.AddTag('WeakToAard');
						opponentStats.damageValue = 2860;
						opponentStats.healthValue = 32110;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 1.0f;
						opponentStats.physicalResist	= 0.40f;
						opponentStats.forceResist 		= 0.4f;
						opponentStats.frostResist 		= 0.4f;
						opponentStats.fireResist 		= 0.25f;
						opponentStats.shockResist 		= 0.3f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= -0.2f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.4f;
						opponentStats.injuryResist 		= 0.3f;
						opponentStats.armorPiercing 	= 0.75f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_fugas_base') )
					{
						opponentStats.damageValue = 2760;
						opponentStats.healthValue = 25580;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.65f;
						opponentStats.physicalResist	= 0.10f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= -0.5f;
						opponentStats.fireResist 		= 0.7f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.5f;
						opponentStats.bleedingResist 	= -0.15f;
						opponentStats.poisonResist 		= -0.15f;
						opponentStats.stunResist 		= 0.2f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.4f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Beast :
					if( NPC.HasAbility('mon_bear_base') )
					{
						NPC.AddTag('WeakToQuen');
						if( NPC.HasTag('q201_stuffed_animal') )
						{
							opponentStats.damageValue = 75;
							opponentStats.healthValue = 5310;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 2985;
							opponentStats.healthValue = 20420;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.3f;
							opponentStats.forceResist 		= 0.25f;
							opponentStats.frostResist 		= 0.3f;
							opponentStats.fireResist 		= -0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.25f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.55f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_werewolf_base') )
					{
						opponentStats.damageValue = 2975;
						opponentStats.healthValue = 26380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.2f;
						opponentStats.fireResist 		= -0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.2f;
						opponentStats.poisonResist 		= 0.3f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.6f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddAbility('DisableFinishers', false);
					}
					else
					if( NPC.HasTag('PlayerWolfCompanion') )
					{
						opponentStats.damageValue = 4000;
						opponentStats.healthValue = 3500;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.5f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.5f;
						opponentStats.frostResist 		= 0.5f;
						opponentStats.fireResist 		= 0.5f;
						opponentStats.shockResist 		= 0.5f;
						opponentStats.elementalResist 	= 0.5f;
						opponentStats.slowResist 		= 0.5f;
						opponentStats.confusionResist 	= 0.5f;
						opponentStats.bleedingResist 	= 0.5f;
						opponentStats.poisonResist 		= 0.5f;
						opponentStats.stunResist 		= 0.5f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.5f;
					}
					else
					if( NPC.HasAbility('mon_wolf_base') )
					{
						if( NPC.HasTag('q201_stuffed_animal') )
						{
							opponentStats.damageValue = 25;
							opponentStats.healthValue = 870;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.05f;
						}
						else
						if( NPC.GetSfxTag() == 'sfx_wild_dog' )
						{
							opponentStats.damageValue = 1950;
							opponentStats.healthValue = 2850;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.3f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.25f;
						}
						else
						if( NPC.UsesVitality() )
						{
							opponentStats.damageValue = 2035;
							opponentStats.healthValue = 3050;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.3f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.3f;
							NPC.AddWeatherAbility(EDP_Midnight, EWE_Clear, EMS_Full, 'fullmoon_wolf');
						}
						else
						{
							opponentStats.damageValue = 2035;
							opponentStats.healthValue = 5150;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.3f;
						}
					}
					else
					if( NPC.HasAbility('mon_panther_ghost') )
					{
						opponentStats.damageValue = 2410;
						opponentStats.healthValue = 11730;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.6f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_panther_base') )
					{
						opponentStats.damageValue = 2350;
						opponentStats.healthValue = 7530;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= -0.2f;
						opponentStats.fireResist 		= -0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= -0.1f;
						opponentStats.confusionResist 	= -0.3f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.4f;
					}
					else
					if( NPC.HasAbility('mon_boar_base') || NPC.HasAbility('mon_boar_ep2_base') || NPC.HasAbility('mon_ft_boar_ep2_base') )
					{
						opponentStats.damageValue = 2350;
						opponentStats.healthValue = 6850;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.25f;
						opponentStats.fireResist 		= -0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= -0.4f;
						opponentStats.confusionResist 	= -0.3f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.5f;
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Unused :
					if( NPC.HasAbility('mon_troll_fistfight') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2700;
						opponentStats.healthValue = 9460;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.4f;
						opponentStats.physicalResist	= 0.6f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= -1.f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.5f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_NotSet :
					if( NPC.HasAbility('mon_bear_base') )
					{
						opponentStats.damageValue = 3075;
						opponentStats.healthValue = 14720;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.4f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.25f;
						opponentStats.frostResist 		= 0.3f;
						opponentStats.fireResist 		= -0.2f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.25f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.2f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.55f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Draconide :
					NPC.AddWeatherAbility(EDP_Noon, EWE_Clear, EMS_Any, 'noon_clear_draconid');
					NPC.AddWeatherAbility(EDP_Midnight, EWE_Any, EMS_Any, 'night_draconid');
					if( NPC.HasAbility('mon_draco_base') )
					{
						NPC.AddTag('WeakToAard');
						NPC.RemoveBuffImmunity(EET_Frozen);
						NPC.RemoveBuffImmunity(EET_SlowdownFrost);
						opponentStats.damageValue = 3085;
						opponentStats.healthValue = 28770;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.6f;
						opponentStats.forceResist 		= -0.2f;
						opponentStats.frostResist 		= -0.3f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.2f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_gryphon_base') )
					{
						NPC.AddTag('WeakToAard');
						if( NPC.HasAbility('mon_basilisk'))
						{
							opponentStats.damageValue = 3425;
							opponentStats.healthValue = 40790;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= -0.2f;
							opponentStats.frostResist 		= -0.3f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.3f;
							opponentStats.confusionResist 	= 0.3f;
							opponentStats.bleedingResist 	= 0.3f;
							opponentStats.poisonResist 		= 1.0f;
							opponentStats.stunResist 		= 0.35f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.7f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else											//Cockatrice
						{
							opponentStats.damageValue = 3425;
							opponentStats.healthValue = 43790;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.35f;
							opponentStats.forceResist 		= 0.0f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.3f;
							opponentStats.confusionResist 	= 0.3f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= 0.0f;
							opponentStats.stunResist 		= 0.35f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.7f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_wyvern_base') )
					{
						if( NPC.HasAbility('mon_wyvern') )
						{
							NPC.AddTag('WeakToAard');
							NPC.RemoveBuffImmunity(EET_Frozen);
							NPC.RemoveBuffImmunity(EET_SlowdownFrost);
							opponentStats.damageValue = 3260;
							opponentStats.healthValue = 24540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.35f;
							opponentStats.physicalResist	= 0.35f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= -0.15f;
							opponentStats.fireResist 		= 0.15f;
							opponentStats.shockResist 		= 0.2f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 0.35f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.4f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else											//forktail
						{
							NPC.RemoveBuffImmunity(EET_Frozen);
							NPC.RemoveBuffImmunity(EET_SlowdownFrost);
							opponentStats.damageValue = 3460;
							opponentStats.healthValue = 20440;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.5f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= -0.1f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.2f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.75f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Animal : return;
				default : return;
			}
		}
	}
	
	public function OpponentSetup( NPC : CNewNPC, out opponentAbilities : W3AbilityManager, out opponentStats : SOpponentStats, originalLevel : int, out displayLevel : int)
	{
		var npcStats : CCharacterStats;
		var ciriEntity : W3ReplacerCiri;
		var damageScale, healthScale : float;
		var playerLevel : int;
		var health : EBaseCharacterStats;
		var wasNotScaled : bool;
		var ab : array<CName>;
		
		if( NPC.GetWasScaled() || NPC.HasTag('q702_bloodlust_counter') || opponentStats.opponentType == MC_Animal ) return;
		
		NPC.SetWasScaled(true);
		npcStats = NPC.GetCharacterStats();
		npcStats.GetAbilities(ab, false);
		ab = NPC.GetTags();
		
		if( npcStats.HasAbility('VesemirDamage') )
			NPC.RemoveAbility('VesemirDamage');
		if( npcStats.HasAbility('CiriHardcoreDebuffMonster') )
			NPC.RemoveAbility('CiriHardcoreDebuffMonster');
		if( npcStats.HasAbility('CiriHardcoreDebuffMonster') )
			NPC.RemoveAbility('CiriHardcoreDebuffMonster');
		
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_BONUS_PER_LEVEL);
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_GROUP_BONUS_PER_LEVEL);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL);
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_BONUS_PER_LEVEL_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_GROUP_BONUS_PER_LEVEL_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_FIXED);
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		if( ciriEntity )
		{
			if( NPC.IsHuman() && NPC.GetStat(BCS_Essence, true) < 0 )
				npcStats.AddAbility('CirihardcoreDebuffHuman');
			else
				npcStats.AddAbility('CiriHardcoreDebuffMonster');
		}
		
		CalculateStatsBoss(NPC, opponentStats, wasNotScaled);
		CalculateStatsBoss2(NPC, opponentStats, wasNotScaled);
		CalculateStatsPartHalf(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart1(NPC, opponentStats, wasNotScaled);
		CalculateStatsSpecter(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart2(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart3(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart4(NPC, opponentStats, wasNotScaled);
		Enemies().CacheSkillValues(NPC, opponentStats);
		ApplyStatModifiers(NPC, opponentStats);
		EnemyDisparity(NPC, opponentStats);
		//Kolaris - Difficulty Settings
		ApplyDifficultyModifiers(NPC, opponentStats);
		ApplyProgressionModifiers(NPC, opponentStats);
		AddUniversalWeatherAbilities(NPC);
		Enemies().NPCStaminaSetup(NPC, opponentStats);
		
		if( NPC.HasAbility('mon_noonwraith_doppelganger') )
			return;
			
		if( NPC.UsesEssence() )
			health = BCS_Essence;
		else
			health = BCS_Vitality;
			
		opponentStats.armorPiercing *= Options().GetEnemyAPMult();
		if( NPC.HasTag('MonsterHuntTarget') )
		{
			opponentStats.healthValue *= 1.5f;
			opponentStats.damageValue *= 1.25f;
		}
		if( FactsQuerySum("NewGamePlus") > 0 )
		{
			opponentStats.healthValue *= 1.35f;
			opponentStats.damageValue *= 1.2f;
		}
		//Kolaris - Difficulty Settings
		switch(theGame.GetDifficultyLevel())
		{
			case EDM_Easy:
				opponentStats.healthValue *= 0.75f;
				opponentStats.damageValue *= 0.75f;
				opponentStats.rangedDamageValue *= 0.75;
			break;
			
			case EDM_Hard:
				opponentStats.healthValue *= 1.25f;
				opponentStats.damageValue *= 1.25f;
				opponentStats.rangedDamageValue *= 1.25f;
			break;
			
			case EDM_Hardcore:
				opponentStats.healthValue *= 1.5f;
				opponentStats.damageValue *= 1.5f;
				opponentStats.rangedDamageValue *= 1.5f;
			break;
		}
		
		if( !NPC.HasTag('failedFundamentalsAchievement') )
		{
			opponentAbilities.SetStatPointMax(health, opponentStats.healthValue);
			opponentAbilities.SetStatPointCurrent(health, opponentStats.healthValue);
		}
	}
	
	private function FixMH207Facts()
	{
		FactsRemove("actor_mh207_expiationer_escort_01_was_killed");
		FactsRemove("actor_mh207_expiationer_escort_02_was_killed");
		FactsRemove("actor_mh207_expiationer_escort_03_was_killed");
		FactsRemove("actor_mh207_expiationer_escort_04_was_killed");
	}
	
	public function StudyTarget()
	{
	var str : string;
	var npc : CNewNPC;
	var npcStats : SOpponentStats;
	
	npc = (CNewNPC)thePlayer.GetTarget();
	npcStats = npc.GetNPCStats();
	
	str += "Health Value: " + RoundMath(MaxF(npc.GetStat(BCS_Vitality), npc.GetStat(BCS_Essence))) + " / " + RoundMath(npcStats.healthValue);
	str += "<br>Health Mult: " + RoundMath(npcStats.healthMult * 100) + "%";
	str += "<br>Received Damage: " + RoundMath(npc.GetDamageTakenMultiplier() * 100) + "%";
	str += "<br>Stamina Value: " + RoundMath(npc.GetStat(BCS_Stamina)) + " / " + RoundMath(npc.GetStatMax(BCS_Stamina));
	str += "<br>Morale Value: " + RoundMath(npc.GetStat(BCS_Morale)) + " / " + RoundMath(npc.GetStatMax(BCS_Morale));
	str += "<br>Melee Damage: " + RoundMath(npcStats.damageValue);
	str += "<br>Melee AP: " + RoundMath(npcStats.armorPiercing * 100) + "%";
	str += "<br>Range Damage: " + RoundMath(npcStats.rangedDamageValue);
	str += "<br>Range AP: " + RoundMath(npcStats.rangedArmorPiercing * 100) + "%";
	str += "<br>Damage Mult: " + RoundMath(npcStats.damageMult * 100) +"%";
	str += "<br>Poise Resist: " + RoundMath(npcStats.poiseValue * 100) + "%";
	str += "<br>Physical Resist: " + RoundMath(npcStats.physicalResist * 100) + "%";
	str += "<br>Force Resist: " + RoundMath(npcStats.forceResist * 100) + "%";
	str += "<br>Frost Resist: " + RoundMath(npcStats.frostResist * 100) + "%";
	str += "<br>Fire Resist: " + RoundMath(npcStats.fireResist * 100) + "%";
	str += "<br>Shock Resist: " + RoundMath(npcStats.shockResist * 100) + "%";
	str += "<br>Ethereal Resist: " + RoundMath(npcStats.elementalResist * 100) + "%";
	str += "<br>Slow Resist: " + RoundMath(npcStats.slowResist * 100) + "%";
	str += "<br>Confusion Resist: " + RoundMath(npcStats.confusionResist * 100) + "%";
	str += "<br>Bleed Resist: " + RoundMath(npcStats.bleedingResist * 100) + "%";
	str += "<br>Poison Resist: " + RoundMath(npcStats.poisonResist * 100) + "%";
	str += "<br>Stun Resist: " + RoundMath(npcStats.stunResist * 100) + "%";
	str += "<br>Injury Resist: " + RoundMath(npcStats.injuryResist * 100) + "%";
	
	theGame.GetGuiManager().ShowUserDialogAdv( 0, npc.GetDisplayName(), str, false, UDB_Ok );
	}
}

exec function who()
{
	var ents : array< CGameplayEntity >;
	var arrNames, arrUniqueNames : array< name >;
	var i : int;
	var actor : CActor;
	var template : CEntityTemplate;
	var interactionTarget : CInteractionComponent;

	interactionTarget = theGame.GetInteractionsManager().GetActiveInteraction();
	if( interactionTarget )
	{
		theGame.witcherLog.AddMessage("Object template: " + interactionTarget.GetEntity().GetReadableName());
		theGame.witcherLog.AddMessage("Position: " + VecToString(interactionTarget.GetEntity().GetWorldPosition()));
	}

	if( !interactionTarget )
	{
		actor = thePlayer.GetTarget();
	}

	if( !actor )
	{
		FindGameplayEntitiesCloseToPoint( ents, thePlayer.GetWorldPosition(), 3, 1, , , , 'CNewNPC');
		if( ents.Size() > 0 )
		{
			actor = (CActor)ents[0];
		}
	}

	if( actor )
	{
		theGame.witcherLog.AddMessage("NPC template: " + actor.GetReadableName());
		
		actor.GetCharacterStats().GetAbilities( arrNames, true );
		
		ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
		if(arrUniqueNames.Size() > 0)
		{
			for( i = 0; i < arrUniqueNames.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Ability:" + arrUniqueNames[i]);
		}
		
		arrNames.Clear();
		arrNames = actor.GetTags();
		if(arrNames.Size() > 0)
		{
			for( i = 0; i < arrNames.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Tag:" + arrNames[i]);
		}
		
		template = (CEntityTemplate)LoadResource( actor.GetReadableName(), true );
		if(template.includes.Size() > 0)
		{
			for( i = 0; i < template.includes.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Includes:" + template.includes[i].GetPath());
		}
	}
}

exec function gettargetstat()
{
	var npcStats : CCharacterStats;
	var ab, tag : array<name>;
	
	npcStats = thePlayer.GetTarget().GetCharacterStats();
	npcStats.GetAbilities(ab, true);
	tag = thePlayer.GetTarget().GetTags();
	return;
}

//Kolaris - Test
exec function StudyTarget(optional includeAbilities : bool)
{
	var arrNames, arrUniqueNames : array< name >;
	var i : int;
	var str : string;
	var npc : CNewNPC;
	var npcStats : SOpponentStats;
	var messageData 	: W3MessagePopupData;
	var messagePopupRef : CR4MessagePopup;
	
	npc = (CNewNPC)thePlayer.GetTarget();
	npcStats = npc.GetNPCStats();
	
	str += "Health Value: " + RoundMath(MaxF(npc.GetStat(BCS_Vitality), npc.GetStat(BCS_Essence))) + " / " + RoundMath(npcStats.healthValue);
	str += "<br>Health Mult: " + RoundMath(npcStats.healthMult * 100) + "%";
	str += "<br>Received Damage: " + RoundMath(npc.GetDamageTakenMultiplier() * 100) + "%";
	str += "<br>Stamina Value: " + RoundMath(npc.GetStat(BCS_Stamina)) + " / " + RoundMath(npc.GetStatMax(BCS_Stamina));
	str += "<br>Morale Value: " + RoundMath(npc.GetStat(BCS_Morale)) + " / " + RoundMath(npc.GetStatMax(BCS_Morale));
	str += "<br>Melee Damage: " + RoundMath(npcStats.damageValue);
	str += "<br>Melee AP: " + RoundMath(npcStats.armorPiercing * 100) + "%";
	str += "<br>Range Damage: " + RoundMath(npcStats.rangedDamageValue);
	str += "<br>Range AP: " + RoundMath(npcStats.rangedArmorPiercing * 100) + "%";
	str += "<br>Damage Mult: " + RoundMath(npcStats.damageMult * 100) +"%";
	str += "<br>Poise Resist: " + RoundMath(npcStats.poiseValue * 100) + "%";
	str += "<br>Physical Resist: " + RoundMath(npcStats.physicalResist * 100) + "%";
	str += "<br>Force Resist: " + RoundMath(npcStats.forceResist * 100) + "%";
	str += "<br>Frost Resist: " + RoundMath(npcStats.frostResist * 100) + "%";
	str += "<br>Fire Resist: " + RoundMath(npcStats.fireResist * 100) + "%";
	str += "<br>Shock Resist: " + RoundMath(npcStats.shockResist * 100) + "%";
	str += "<br>Ethereal Resist: " + RoundMath(npcStats.elementalResist * 100) + "%";
	str += "<br>Slow Resist: " + RoundMath(npcStats.slowResist * 100) + "%";
	str += "<br>Confusion Resist: " + RoundMath(npcStats.confusionResist * 100) + "%";
	str += "<br>Bleed Resist: " + RoundMath(npcStats.bleedingResist * 100) + "%";
	str += "<br>Poison Resist: " + RoundMath(npcStats.poisonResist * 100) + "%";
	str += "<br>Stun Resist: " + RoundMath(npcStats.stunResist * 100) + "%";
	str += "<br>Injury Resist: " + RoundMath(npcStats.injuryResist * 100) + "%";
	
	if( includeAbilities )
	{
		str += "<br><br>";
		str += "NPC Template: " + npc.GetReadableName();
		npc.GetCharacterStats().GetAbilities( arrNames, true );
		ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
		if(arrUniqueNames.Size() > 0)
		{
			for( i = 0; i < arrUniqueNames.Size(); i += 1 )
				str += "<br>Ability: " + arrUniqueNames[i];
		}
		
		arrNames.Clear();
		arrUniqueNames.Clear();
		str += "<br><br>";
		
		arrNames = npc.GetTags();
		ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
		if(arrNames.Size() > 0)
		{
			for( i = 0; i < arrUniqueNames.Size(); i += 1 )
				str += "<br>Tag: " + arrUniqueNames[i];
		}
	}
	
	theGame.GetGuiManager().ShowUserDialogAdv( 0, npc.GetDisplayName(), str, false, UDB_Ok );
}

exec function StudyTargetWeatherAbilities()
{
	var i : int;
	var str : string;
	var npc : CNewNPC;
	var weatherAbilities : array<SWeatherBonus>;
	var messageData 	: W3MessagePopupData;
	var messagePopupRef : CR4MessagePopup;
	
	npc = (CNewNPC)thePlayer.GetTarget();
	weatherAbilities = npc.GetWeatherAbilities();
	
	for( i=0; i<weatherAbilities.Size(); i+=1 )
		str += weatherAbilities[i].ability + " " + weatherAbilities[i].isActive + "<br>";
	
	theGame.GetGuiManager().ShowUserDialogAdv( 0, npc.GetDisplayName(), str, false, UDB_Ok );
}

exec function bosstest()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.Debug_ClearCharacterDevelopment(true);
	witcher.inv.AddAnItem('Bear Armor', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Boots 1', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Pants 1', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Gloves 1', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Armor 4', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Boots 5', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Pants 5', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Gloves 5', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Armor', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Boots 1', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Pants 1', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Gloves 1', 1, false, false, false);
}