/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class CharacterStatsPopupData extends TextPopupData
{	
	var m_flashValueStorage : CScriptedFlashValueStorage;
	
	protected  function GetContentRef() : string 
	{
		return "StatisticsFullRef";
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("input_feedback_scroll_text", "gamepad_R_Scroll");
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "escape-gamepad_B") 
		{
			ClosePopup();
		}
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject 
	{
		var gfxData : CScriptedFlashObject;
		
		m_flashValueStorage = parentFlashValueStorage;
		
		gfxData = parentFlashValueStorage.CreateTempFlashObject();
		GetPlayerStatsGFxData(parentFlashValueStorage);
		gfxData.SetMemberFlashString("ContentRef", GetContentRef());
		
		return gfxData;
	}
}

function GetPlayerStatsGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
{ 
	var statsArray : CScriptedFlashArray;
	var gfxData    : CScriptedFlashObject;
	
	var gfxSilverDamage : CScriptedFlashObject;
	var gfxSteelDamage  : CScriptedFlashObject;
	var gfxArmor 		: CScriptedFlashObject;
	var gfxVitality 	: CScriptedFlashObject;
	var gfxSpellPower 	: CScriptedFlashObject;
	// W3EE - Begin
	var gfxVigorStat 	: CScriptedFlashObject;
	var gfxPoiseStat 	: CScriptedFlashObject;
	var gfxAtkSpdStat 	: CScriptedFlashObject;
	var gfxAdrenaline 	: CScriptedFlashObject;
	// W3EE - End
	var gfxToxicity 	: CScriptedFlashObject;
	var gfxStamina 		: CScriptedFlashObject;
	var gfxCrossbow  	: CScriptedFlashObject;
	var gfxAdditional  	: CScriptedFlashObject;
	
	var gfxSilverDamageSub : CScriptedFlashArray;
	var gfxSteelDamageSub  : CScriptedFlashArray;
	var gfxArmorSub 	   : CScriptedFlashArray;
	var gfxVitalitySub 	   : CScriptedFlashArray;
	var gfxSpellPowerSub   : CScriptedFlashArray;
	// W3EE - Begin
	var gfxVigorStatSub    : CScriptedFlashArray;
	var gfxPoiseStatSub    : CScriptedFlashArray;
	var gfxAtkSpdStatSub   : CScriptedFlashArray;
	var gfxAdrenalineSub   : CScriptedFlashArray;
	// W3EE - End
	var gfxToxicitySub 	   : CScriptedFlashArray;
	var gfxStaminaSub	   : CScriptedFlashArray;
	var gfxCrossbowSub     : CScriptedFlashArray;
	var gfxAdditionalSub   : CScriptedFlashArray;
	
	var gameTime		: GameTime;
	var gameTimeHours	: string;
	var gameTimeMinutes : string;
	
	gfxData = parentFlashValueStorage.CreateTempFlashObject();
	statsArray = parentFlashValueStorage.CreateTempFlashArray();
	
	
	
	
	
	
	
	
	
	

	
	
	gfxSilverDamage = AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dps", "attack_silver", statsArray, parentFlashValueStorage);
	gfxSilverDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	
	AddCharacterHeader("panel_common_statistics_tooltip_silver_dps", gfxSilverDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_LightAtk", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat1", 'silverFastDPS', "panel_common_statistics_tooltip_silver_fast_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat2", 'silverFastCritChance', "panel_common_statistics_tooltip_silver_fast_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat3", 'silverFastCritDmg', "panel_common_statistics_tooltip_silver_fast_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterHeader("W3EE_StrongAtk", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat4", 'silverStrongDPS', "panel_common_statistics_tooltip_silver_strong_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat5", 'silverStrongCritChance', "panel_common_statistics_tooltip_silver_strong_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat6", 'silverStrongCritDmg', "panel_common_statistics_tooltip_silver_strong_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 	
	AddCharacterHeader("W3EE_EffectCh", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("silverStat8", 'silver_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat9", 'silver_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat10", 'silver_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat11", 'silver_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat12", 'silver_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat13", 'silver_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage);
	gfxSilverDamage.SetMemberFlashArray("subStats", gfxSilverDamageSub);
	
	
	
	gfxSteelDamage = AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dps", "attack_steel", statsArray, parentFlashValueStorage);
	gfxSteelDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_tooltip_steel_dps", gfxSteelDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_LightAtk", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat1", 'steelFastDPS', "panel_common_statistics_tooltip_steel_fast_dps", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat2", 'steelFastCritChance', "panel_common_statistics_tooltip_steel_fast_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat3", 'steelFastCritDmg', "panel_common_statistics_tooltip_steel_fast_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterHeader("W3EE_StrongAtk", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat4", 'steelStrongDPS', "panel_common_statistics_tooltip_steel_strong_dps", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat5", 'steelStrongCritChance', "panel_common_statistics_tooltip_steel_strong_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat7", 'steelStrongCritDmg', "panel_common_statistics_tooltip_steel_strong_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_EffectCh", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat8", 'steel_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat9", 'steel_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat10", 'steel_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat11", 'steel_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat12", 'steel_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat13", 'steel_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	gfxSteelDamage.SetMemberFlashArray("subStats", gfxSteelDamageSub);
	
	
	
	gfxArmor = AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", statsArray, parentFlashValueStorage);
	gfxArmorSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_armor", gfxArmorSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_MeleeResist", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat2", 'slashing_resistance_perc', "slashing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat3", 'piercing_resistance_perc', "attribute_name_piercing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat4", 'bludgeoning_resistance_perc', "bludgeoning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_ElementResist", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat6", 'elemental_resistance_perc', "attribute_name_elemental_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_EffectResist", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat8", 'poison_resistance_perc', "attribute_name_poison_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat9", 'bleeding_resistance_perc', "attribute_name_bleeding_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat10", 'burning_resistance_perc', "attribute_name_burning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("defStat11", 'injury_resist', "attribute_name_injury_resist", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdArm", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("StamCostArm", 'StamCostArmor', "W3EE_StamCostArmMod", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("StamRegArm", 'StamRegArmor', "W3EE_StamRegArmMod", "", gfxArmorSub, parentFlashValueStorage);
	gfxArmor.SetMemberFlashArray("subStats", gfxArmorSub);
	
	
	
	gfxCrossbow = AddCharacterStat("majorStat4", 'crossbow', "item_category_crossbow", "crossbow", statsArray, parentFlashValueStorage);
	gfxCrossbowSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("item_category_crossbow", gfxCrossbowSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_DmgValues", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat18", 'crossbowSteelDmg', "attribute_name_piercingdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat19", 'crossbowSilverDmg', "attribute_name_silverdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat17", 'crossbowCritChance', "panel_common_statistics_tooltip_crossbow_crit_chance", "", gfxCrossbowSub, parentFlashValueStorage);
	gfxCrossbow.SetMemberFlashArray("subStats", gfxCrossbowSub);
	
	
	
	gfxVitality =  AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", statsArray, parentFlashValueStorage);
	gfxVitalitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("vitality", gfxVitalitySub, parentFlashValueStorage, true, "Green");
	AddCharacterHeader("W3EE_RegenRates", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat12", 'vitalityRegen', "panel_common_statistics_tooltip_outofcombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat13", 'vitalityCombatRegen', "panel_common_statistics_tooltip_incombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Maluses", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat17", 'healthSpeedRed', "W3EE_SpdRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vigorStat6", 'healthRegenRed', "W3EE_StamRegenRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vigorStat6", 'healthRegenRed', "W3EE_VigRegenRed", "", gfxVitalitySub, parentFlashValueStorage);
	gfxVitality.SetMemberFlashArray("subStats", gfxVitalitySub);
	
	
	
	gfxStamina = AddCharacterStat("majorStat3", 'stamina', "stamina", "stamina", statsArray, parentFlashValueStorage);
	gfxStaminaSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stamina", gfxStaminaSub, parentFlashValueStorage, true, "Green");
	AddCharacterHeader("W3EE_RegenRates", gfxStaminaSub, parentFlashValueStorage);
	//AddCharacterStat("defStat14", 'staminaOutOfCombatRegen', "attribute_name_staminaregen_out_of_combat", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat15", 'staminaRegen', "attribute_name_staminaregen", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_RegenMod", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat19", 'healthRegenRed', "W3EE_StamRegenRedHP", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat20", 'adrStamReg', "W3EE_StamRegenIncAdr", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Efficiency", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat22", 'staminaEffAtt', "W3EE_StamEffAtt", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat23", 'staminaEffDef', "W3EE_StamEffDef", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat24", 'staminaEffMov', "W3EE_StamEffMov", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Maluses", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat16", 'staminaSpeedRed', "W3EE_SpdRed", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat21", 'staminaDamageRed', "W3EE_MeleeDamRed", "", gfxStaminaSub, parentFlashValueStorage);
	gfxStamina.SetMemberFlashArray("subStats", gfxStaminaSub);
	
	
	gfxAdrenaline = AddCharacterStat("adrStat", 'adrenaline', "W3EE_Adr", "additional", statsArray, parentFlashValueStorage);
	gfxAdrenalineSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Adr", gfxAdrenalineSub, parentFlashValueStorage, true, "Green");
	AddCharacterHeader("W3EE_AdrGen", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGain", 'adrGain', "W3EE_AdrGain", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainCounter", 'adrGainCounter', "W3EE_AdrCount", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainAttack", 'adrGainAttack', "W3EE_AdrAtt", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainKill", 'adrGainKill', "W3EE_AdrKill", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainHit", 'adrGainHit', "W3EE_AdrHit", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Bonuses", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrStamReg", 'adrStamReg', "W3EE_StamRegenEffBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrVigReg", 'adrVigReg', "W3EE_VigRegenBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrDamBonus", 'adrDamBonus', "W3EE_DamBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrTimeSlow", 'adrTimeSlow', "W3EE_AdrTimeSlow", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrSignBonus", 'adrSignBonus', "W3EE_AdrSignBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	gfxAdrenaline.SetMemberFlashArray("subStats", gfxAdrenalineSub);
	
	
	gfxToxicity = AddCharacterStat("majorStat2", 'toxicity', "attribute_name_toxicity", "toxicity", statsArray, parentFlashValueStorage);
	gfxToxicitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_toxicity", gfxToxicitySub, parentFlashValueStorage, true, "Green");	
	//AddCharacterHeader("W3EE_Base", gfxToxicitySub, parentFlashValueStorage);
	//AddCharacterStatToxicity("toxicity", 'toxicity', "toxicity", "", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Rates", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicGain", 'toxicGain', "W3EE_ToxGain", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicDrain", 'toxicDrain', "W3EE_ToxDrain", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicDelta", 'toxicDelta', "W3EE_ToxDelta", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Bonuses", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicSpeed", 'toxicSpeed', "W3EE_ToxSpeed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicAdr", 'toxicAdr', "W3EE_ToxAdr", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicArm", 'toxicArm', "W3EE_ToxArm", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicPoise", 'toxicPoise', "W3EE_ToxPoise", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Maluses", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStat("toxicvigor", 'toxicRegenRed', "W3EE_VigRegenRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("feverVigor", 'feverVigor', "W3EE_FevVigRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("feverStam", 'feverStam', "W3EE_FevStamRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("feverSpeed", 'feverSpeed', "W3EE_FevSpdRed", "", gfxToxicitySub, parentFlashValueStorage);	
	gfxToxicity.SetMemberFlashArray("subStats", gfxToxicitySub);
	
	
	
	gfxSpellPower = AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", statsArray, parentFlashValueStorage);
	gfxSpellPowerSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stat_signs", gfxSpellPowerSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("Aard", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat1", 'spell_power_aard', "spell_power_aard", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat2", 'aard_damage', "attribute_name_forcedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat3", 'aard_frost_damage', "attribute_name_frostdamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Igni", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat1", 'spell_power_igni', "spell_power_igni", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat2", 'igni_damage', "attribute_name_firedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Quen", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat1", 'spell_power_quen', "spell_power_quen", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat3", 'quen_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Yrden", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat1", 'spell_power_yrden', "spell_power_yrden", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat3", 'yrden_damage', "attribute_name_elementaldamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat4", 'yrden_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Axii", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat1", 'spell_power_axii', "spell_power_axii", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat2", 'axii_duration_confusion', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	gfxSpellPower.SetMemberFlashArray("subStats", gfxSpellPowerSub);



	gfxVigorStat = AddCharacterStat("majorStat6", 'focus', "W3EE_Vigor", "toxicity", statsArray, parentFlashValueStorage);
	gfxVigorStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Vigor", gfxVigorStatSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("W3EE_RegenRates", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat1", 'vigorRegen', "W3EE_VigReg", "", gfxVigorStatSub, parentFlashValueStorage);
	//AddCharacterStatSigns("vigorStat2", 'vigorRegenDelay', "W3EE_VigDelay", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_RegenMod", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat6", 'healthRegenRed', "W3EE_VigRegenRedHP", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat7", 'toxicRegenRed', "W3EE_VigRegenRedTox", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat8", 'adrVigReg', "W3EE_VigRegenBonAdr", "", gfxVigorStatSub, parentFlashValueStorage);
	//AddCharacterHeader("W3EE_LossRate", gfxVigorStatSub, parentFlashValueStorage);
	gfxVigorStat.SetMemberFlashArray("subStats", gfxVigorStatSub);



	gfxPoiseStat = AddCharacterStat("majorStat7", 'poise', "W3EE_Poise", "armor", statsArray, parentFlashValueStorage);
	gfxPoiseStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_AvPoise", gfxPoiseStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStat("poiseStat1", 'poiseValue', "W3EE_CurPoise", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat2", 'poiseRegen', "W3EE_PoiseRegen", "", gfxPoiseStatSub, parentFlashValueStorage);
	
	AddCharacterHeader("W3EE_Modifiers", gfxPoiseStatSub, parentFlashValueStorage, true, "Brown");
	
	AddCharacterStat("poiseStat3", 'poiseStats', "W3EE_PoiseStats", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat4", 'poiseArmor', "W3EE_PoiseArmor", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat5", 'poiseGear', "W3EE_PoiseGear", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat6", 'poiseSkills', "W3EE_PoiseSkills", "", gfxPoiseStatSub, parentFlashValueStorage);

	/*AddCharacterHeader("W3EE_HP", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat3", 'healthPoiseRed', "W3EE_PoiseRed", "", gfxPoiseStatSub, parentFlashValueStorage);
	
	AddCharacterHeader("W3EE_Tox", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStatToxicity("poiseStat4", 'toxPoiseVal', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);
	
	AddCharacterHeader("W3EE_Mut", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat5", 'poiseMutBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);
	
	AddCharacterHeader("attribute_name_armor", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat6", 'armorPoiseBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);	
	
	AddCharacterHeader("W3EE_Moment", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat7", 'poiseMomBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);
	
	AddCharacterHeader("W3EE_Other", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat8", 'poiseDecBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);*/
	gfxPoiseStat.SetMemberFlashArray("subStats", gfxPoiseStatSub);



	gfxAtkSpdStat = AddCharacterStat("majorStat8", 'AtkSpdLight', "W3EE_AtkSpdL", "attack_silver", statsArray, parentFlashValueStorage);
	gfxAtkSpdStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_AtkSpd", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStat("AtkSpdStat1", 'AtkSpdBase', "W3EE_BaseAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat1", 'AtkSpdLightV', "W3EE_TotalAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_AtkSpdModH", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterHeader("W3EE_HP", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat3", 'healthSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Stam", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat4", 'staminaSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("attribute_name_armor", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat5", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Skill", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat6", 'AtkSpdMM', "W3EE_AtkSpdIncSk1", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	//AddCharacterStat("AtkSpdStat7", 'AtkSpdVigL', "W3EE_AtkSpdIncSk2", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Other", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat8", 'AtkSpdOtherL', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	gfxAtkSpdStat.SetMemberFlashArray("subStats", gfxAtkSpdStatSub);



	gfxAtkSpdStat = AddCharacterStat("majorStat9", 'AtkSpdHeavy', "W3EE_AtkSpdH", "attack_steel", statsArray, parentFlashValueStorage);
	gfxAtkSpdStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_AtkSpd", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStat("AtkSpdStat9", 'AtkSpdBase', "W3EE_BaseAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat10", 'AtkSpdHeavyV', "W3EE_TotalAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_AtkSpdModH", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterHeader("W3EE_HP", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat11", 'healthSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Stam", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat12", 'staminaSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("attribute_name_armor", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat13", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Skill", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat14", 'AtkSpdST', "W3EE_AtkSpdIncSk3", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	//AddCharacterStat("AtkSpdStat15", 'AtkSpdVigH', "W3EE_AtkSpdIncSk2", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Other", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat8", 'AtkSpdOtherH', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	gfxAtkSpdStat.SetMemberFlashArray("subStats", gfxAtkSpdStatSub);



	gfxAdditional = AddCharacterStat("majorStat5", 'additional', "panel_common_statistics_category_additional", "additional", statsArray, parentFlashValueStorage);
	gfxAdditionalSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_category_additional", gfxAdditionalSub, parentFlashValueStorage, true, "Brown");
	AddCharacterHeader("W3EE_AddStats", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStatF("extraStat1", 'bonus_herb_chance', "bonus_herb_chance", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStatU("extraStat3", 'human_exp_bonus_when_fatal', "human_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat4", 'nonhuman_exp_bonus_when_fatal', "nonhuman_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterHeader("W3EE_EvSpeedH", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("extraStat5", 'EvadeSpeed', "W3EE_EvSpeed", "", gfxAdditionalSub, parentFlashValueStorage);	
	AddCharacterStatU("extraStat2", 'safe_dodge_angle', "attribute_name_safe_dodge_angle_bonus", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterHeader("W3EE_DmgMult", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat1", 'sDamMult', "W3EE_MelDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat2", 'cDamMult', "W3EE_RangDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat3", 'siDamMult', "W3EE_SignDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat4", 'bDamMult', "W3EE_BombDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	gfxAdditional.SetMemberFlashArray("subStats", gfxAdditionalSub);
	
	
	
	gameTime =	theGame.CalculateTimePlayed();
	gameTimeHours = (string)(GameTimeDays(gameTime) * 24 + GameTimeHours(gameTime));
	gameTimeMinutes = (string)GameTimeMinutes(gameTime);
	
	gfxData.SetMemberFlashArray("stats", statsArray);
	gfxData.SetMemberFlashString("hoursPlayed", gameTimeHours);
	gfxData.SetMemberFlashString("minutesPlayed", gameTimeMinutes);
	
	return gfxData;
	
	
	
	
}

function AddCharacterHeader(locKey:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage, optional isSuperHeader : bool, optional color : string):void
{
	var statObject : CScriptedFlashObject;
	
	var finalname 		: string;
	finalname = GetLocStringByKeyExt(locKey); 

	if ( finalname == "#" || finalname == "" )
		finalname = locKey;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	statObject.SetMemberFlashString("name", finalname);
	statObject.SetMemberFlashString("value", "");
	
	if (isSuperHeader)
	{
		statObject.SetMemberFlashString("tag", "SuperHeader");
		statObject.SetMemberFlashString("backgroundColor", color);
	}
	else
	{
		statObject.SetMemberFlashString("tag", "Header");
	}
	
	statObject.SetMemberFlashString("iconTag", "");
	toArray.PushBackFlashObject(statObject);
}

function AddCharacterStat(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject 		: CScriptedFlashObject;
	var valueStr 		: string;
	var valueMaxStr 	: string;
	var valueAbility 	: float;
	var final_name 		: string;
	var sp 				: SAbilityAttributeValue;
	var itemColor		: string;
	
	var gameTime		: GameTime;
	var gameTimeDays	: string;
	var gameTimeHours	: string;
	var gameTimeMinutes	: string;
	var gameTimeSeconds	: string;

	// W3EE - Begin
	var playerWitcher : W3PlayerWitcher;
	var adrGain, min : SAbilityAttributeValue;
	var clampVal : float;	
	var lightAttackSpeed, heavyAttackSpeed, evadeSpeed : float;
	var adrenalineEffect : W3Effect_CombatAdrenaline;
	var poiseEffect : W3Effect_Poise;
	
	playerWitcher = GetWitcherPlayer();
	adrenalineEffect = playerWitcher.GetAdrenalineEffect();
	poiseEffect = playerWitcher.GetPoiseEffect();
	
	lightAttackSpeed = Combat().FastAttackSpeedModule(true) - 0.08f;
	heavyAttackSpeed = Combat().HeavyAttackSpeedModule(true) - 0.08f;
	evadeSpeed = Combat().EvadeSpeedModule(true) - 0.08f;
	// W3EE - End
	
	statObject			= 	flashMaster.CreateTempFlashObject();
	
	gameTime			=	theGame.CalculateTimePlayed();
	gameTimeDays 		= 	(string)GameTimeDays(gameTime);
	gameTimeHours 		= 	(string)GameTimeHours(gameTime);
	gameTimeMinutes 	= 	(string)GameTimeMinutes(gameTime);
	gameTimeSeconds 	= 	(string)GameTimeSeconds(gameTime);
	
	valueMaxStr = "";
	itemColor = "";

	if ( varKey == 'vitality' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Vitality, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Vitality));
		itemColor = "Green";
	}
	else if ( varKey == 'toxicity' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Toxicity, false));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Toxicity));
		itemColor = "Green";
	}
	else if ( varKey == 'stamina' ) 	
	{ 
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Stamina, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Stamina)); 
		itemColor = "Green";
	}
	// W3EE - Begin
	else if ( varKey == 'spell_power' )
	{
		sp = GetWitcherPlayer().GetTotalSpellPower(true);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
		
		itemColor = "Blue";
	}
	else if ( varKey == 'vitalityRegen' ) 
	{ 
		valueAbility = Combat().GetPlayerVitalityRegen(false);
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'vitalityCombatRegen' ) 
	{ 
		valueAbility = Combat().GetPlayerVitalityRegen(true);
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	// W3EE - Begin
	else if ( varKey == 'staminaRegen' ) 
	{
		valueAbility = Combat().GetPlayerStaminaRegen();
		valueStr = NoTrailZeros(RoundTo(valueAbility, 1)) + "/" + GetLocStringByKeyExt("per_second");
	}
	/*else if ( varKey == 'staminaOutOfCombatRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue('staminaRegen');
		valueAbility = sp.valueAdditive + sp.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina);
		
		valueAbility *= 1 + GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
		
		//Kolaris - Adrenaline
		valueAbility *= 1.f - PowF(1.f - GetWitcherPlayer().GetStatPercents(BCS_Vitality), 2) * 0.5f * GetWitcherPlayer().GetAdrenalinePercMult();
		
		valueAbility *= 1.f + GetWitcherPlayer().GetAdrenalineEffect().GetValue();
		
		// Lazarus - Regen Display
		valueStr = NoTrailZeros(RoundTo(valueAbility, 1)) + "/" + GetLocStringByKeyExt("per_second");
		// Lazarus - End
	}*/
	else if ( varKey == 'healthRegenRed' ) 
	{
		valueAbility = 1.f - GetWitcherPlayer().GetHPReductionMult();
		valueAbility *= 100.f;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'toxicRegenRed' ) 
	{
		//Kolaris - Metabolic Control, Kolaris - Maribor Forest
		if( GetWitcherPlayer().HasAbility('Glyphword 46 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 47 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 48 _Stats', true) )
			valueAbility =  (0.25f - 0.05f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s17)) * PowF(GetWitcherPlayer().GetStatPercents(BCS_Toxicity), 2) * 100;
		else
			valueAbility =  (0.5f - 0.05f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s17)) * PowF(GetWitcherPlayer().GetStatPercents(BCS_Toxicity), 2) * 100;
		sp = GetWitcherPlayer().GetAttributeValue('toxicity_vigor_penalty');
		valueAbility *= 1.f + sp.valueMultiplicative;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'staminaSpeedRed' ) 
	{
		valueAbility = Options().StamRed();
		if(playerWitcher.HasBuff(EET_Overexertion))
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( 1.f, PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			valueAbility *= 2;
		}
		else
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2), PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			else
				valueAbility *= PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2);
		}
		valueAbility *= 1 - thePlayer.GetSkillLevel(S_Sword_s16) * 0.05;
		if( playerWitcher.HasAbility('Glyphword 50 _Stats', true) || playerWitcher.HasAbility('Glyphword 51 _Stats', true) )
			valueAbility *= 0.5f * playerWitcher.GetAdrenalinePercMult();
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'staminaDamageRed' ) 
	{
		valueAbility = Options().StamDamRed();
		if(playerWitcher.HasBuff(EET_Overexertion))
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( 1.f, PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			valueAbility *= 2;
		}
		else
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2), PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			else
				valueAbility *= PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2);
		}
		valueAbility *= 1 - thePlayer.GetSkillLevel(S_Sword_s16) * 0.05;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'healthSpeedRed' ) 
	{
		valueAbility =  (1.f - GetWitcherPlayer().GetHPReductionMult()) * Options().HPRed() * ( 1 - (thePlayer.GetSkillLevel(S_Sword_s16) * 0.05) );
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'healthPoiseRed' ) 
	{
		valueAbility =  ( 1 - ClampF( thePlayer.GetStatPercents(BCS_Vitality) * 1.3f, 0.7f, 1.0f ) ) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'focus' )
	{
		valueStr = (string)NoTrailZeros(RoundTo(thePlayer.GetStat(BCS_Focus, true), 2));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Focus));
		itemColor = "Blue";
	}
	else if ( varKey == 'poise' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseEffect.GetCurrentPoise()));
		valueMaxStr = (string)RoundMath(poiseEffect.GetMaxPoise());
		itemColor = "Brown";
	}
	else if ( varKey == 'AtkSpdLight' )
	{
		valueAbility = lightAttackSpeed;
		
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
		itemColor = "Brown";
	}
	else if ( varKey == 'AtkSpdHeavy' )
	{
		valueAbility = heavyAttackSpeed;
		
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
		itemColor = "Brown";
	}
	else if ( varKey == 'AtkSpdLightV' )
	{
		valueAbility = lightAttackSpeed;
		
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'AtkSpdHeavyV' )
	{
		valueAbility = heavyAttackSpeed;
		
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'AtkSpdBase' )
	{
		valueStr = (string)NoTrailZeros(RoundMath((Combat().BaseActionSpeed(true) - 0.08f) * 100)) + "%";
	}
	else if ( varKey == 'AtkSpdVigH' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetStat(BCS_Focus) * playerWitcher.GetSkillLevel(S_Sword_s20) * 0.4f)) + "%";
	}
	else if ( varKey == 'AtkSpdVigL' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetStat(BCS_Focus) * playerWitcher.GetSkillLevel(S_Sword_s20) * 0.4f)) + "%";
	}
	else if ( varKey == 'AtkSpdMM' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetSkillLevel(S_Sword_s21) * 2.f)) + "%";
	}
	else if ( varKey == 'AtkSpdST' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetSkillLevel(S_Sword_s04) * 2.f)) + "%";
	}
	else if ( varKey == 'AtkSpdArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Combat().CalcArmorPenalty(GetWitcherPlayer(), true) * 100)) + "%";
	}
	else if ( varKey == 'AtkSpdOtherL' )
	{
		min = playerWitcher.GetAttributeValue('attack_speed_fast_style');
		valueAbility = min.valueMultiplicative;
		min = playerWitcher.GetAttributeValue('attack_speed');
		valueAbility += min.valueMultiplicative;
		valueStr = (string)NoTrailZeros(RoundTo(valueAbility * 100, 1)) + "%";
	}
	else if ( varKey == 'AtkSpdOtherH' )
	{
		min = playerWitcher.GetAttributeValue('attack_speed_heavy_style');
		valueAbility = min.valueMultiplicative;
		min = playerWitcher.GetAttributeValue('attack_speed');
		valueAbility += min.valueMultiplicative;
		valueStr = (string)NoTrailZeros(RoundTo(valueAbility * 100, 1)) + "%";
	}
	else if ( varKey == 'EvadeSpeed' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(evadeSpeed * 100)) + "%";
	}
	else if ( varKey == 'sDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdam * 100)) + "%";
	}
	else if ( varKey == 'cDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdamc * 100)) + "%";
	}
	else if ( varKey == 'siDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdams * 100)) + "%";
	}
	else if ( varKey == 'bDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdamb * 100)) + "%";
	}
	else if ( varKey == 'poiseValue' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseEffect.GetCurrentPoise()));
	}
	else if ( varKey == 'poiseRegen' )
	{
		if( playerWitcher.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
			valueStr = (string)NoTrailZeros(RoundMath((20.f + CalculateAttributeValue(playerWitcher.GetAttributeValue('poiseRegen'))) * 1.25f)) + "/" + GetLocStringByKeyExt("per_second");
		else
			valueStr = (string)NoTrailZeros(RoundMath(20.f + CalculateAttributeValue(playerWitcher.GetAttributeValue('poiseRegen')))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'poiseStats' )
	{
		valueAbility = 100.f;
		if( playerWitcher.IsQuenActive(false) )
			valueAbility *= 0.8f - 0.04f * playerWitcher.GetSkillLevel(S_Magic_s15);
		min = playerWitcher.GetAttributeValue('parry_stamina_cost_bonus');
		valueAbility /= (1.f + min.valueMultiplicative);
		if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
		{
			if( playerWitcher.GetStat(BCS_Toxicity) * playerWitcher.GetSkillLevel(S_Alchemy_s20) <= 500 )
				valueAbility *= 1.f - playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.001f * playerWitcher.GetStat(BCS_Toxicity);
			else
				valueAbility /= playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 25.f;
		}
		else
			valueAbility *= 1.f - playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'poiseArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseEffect.ArmorPoiseValue()));
	}
	else if ( varKey == 'poiseGear' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(CalculateAttributeValue(playerWitcher.GetAttributeValue('poise_bonus'))));
	}
	else if ( varKey == 'poiseSkills' )
	{
		//Kolaris - Brawler
		valueStr = (string)NoTrailZeros(RoundMath(10.f * playerWitcher.GetSkillLevel(S_Perk_21)));
	}
	else if ( varKey == 'poiseMutBon' )
	{
		// Lazarus - Mutagens
		sp = playerWitcher.GetAttributeValue('poise_bonus');
		valueAbility = (sp.valueAdditive + sp.valueMultiplicative + sp.valueBase);
		valueStr = NoTrailZeros(RoundMath(valueAbility));
		// Lazarus - End
	}
	else if ( varKey == 'adrenaline' )
	{
		valueStr = NoTrailZeros(adrenalineEffect.GetDisplayCount());
		//Kolaris - Affinity, Kolaris - Wolf Set
		valueMaxStr = IntToString(adrenalineEffect.GetMaxDisplayCount());
		itemColor = "Green";
	}
	else if ( varKey == 'adrGain' )
	{
		//Kolaris - Adrenaline
		valueAbility = 0;
		valueAbility += ((W3Effect_CombatAdrenaline)playerWitcher.GetBuff(EET_CombatAdr)).GetAdrenalineGainMult();
		valueStr = NoTrailZeros(Max(100,RoundMath(valueAbility * 100))) + "%";
	}
	else if ( varKey == 'adrGainCounter' || varKey == 'adrGainAttack' || varKey == 'adrGainKill' || varKey == 'adrGainHit' )
	{
		//Kolaris - Adrenaline
		valueAbility = MaxF(1.f,((W3Effect_CombatAdrenaline)playerWitcher.GetBuff(EET_CombatAdr)).GetAdrenalineGainMult());
		if( varKey == 'adrGainKill' )
			valueAbility *= 3.f;
		if( varKey == 'adrGainHit' )
			valueAbility *= 5.f;
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2));
	}
	else if ( varKey == 'adrStamReg' )
	{
		//Kolaris - Adrenaline
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() / 5)) + "%"; 
	}
	else if ( varKey == 'adrVigReg' )
	{
		//Kolaris - Adrenaline
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() / 5)) + "%"; 
	}
	else if( varKey == 'armor')
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetTotalArmor() );
		
		valueStr = IntToString( RoundMath(  valueAbility ) );
		itemColor = "Red";
	}
	// W3EE - End
	else if (varKey == 'crossbow')
	{
		valueStr = NoTrailZeros(RoundMath(GetEquippedCrossbowDamage() * Damage().pdamc));
		itemColor = "Red";
	}	
	else if (varKey == 'additional')
	{
		valueStr = "";
		itemColor = "Brown";
	}
	//Kolaris - Character Stats Popup
	else if ( varKey == 'StamCostArmor' )
	{
		min = playerWitcher.GetAttributeValue('armor_stamina_efficiency');
		if( playerWitcher.CanUseSkill(S_Perk_22) )
			min.valueMultiplicative *= 0.8f;
		valueStr = (string)NoTrailZeros(RoundMath(min.valueMultiplicative * 100)) + "%";
	}
	else if ( varKey == 'StamRegArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(playerWitcher.CalculatedArmorStaminaRegenBonus() * 100)) + "%";
	}
	else if ( varKey == 'staminaEffAtt' || varKey == 'staminaEffDef' || varKey == 'staminaEffMov' )
	{
		valueAbility = 1.f;
		min = playerWitcher.GetAttributeValue('armor_stamina_efficiency');
		valueAbility *= 1.f - min.valueMultiplicative;
		if( varKey == 'staminaEffAtt' )
		{
			min = playerWitcher.GetAttributeValue('attack_stamina_cost_bonus');
		}
		else if( varKey == 'staminaEffDef' )
		{
			min = playerWitcher.GetAttributeValue('parry_stamina_cost_bonus');
			min.valueMultiplicative += 0.04f * playerWitcher.GetSkillLevel(S_Sword_s03);
			//Kolaris - Mutation 6
			if( playerWitcher.IsMutationActive(EPMT_Mutation6) )
				min.valueMultiplicative -= 0.5f;
		}
		else
		{
			min = playerWitcher.GetAttributeValue('movement_stamina_efficiency');
			min.valueMultiplicative += 0.04f * playerWitcher.GetSkillLevel(S_Sword_s09);
		}
		min.valueMultiplicative *= MinF(1.f, (1.f / (1.f + min.valueMultiplicative)));
		valueAbility *= 1.f - min.valueMultiplicative;
		valueAbility = 1.f / valueAbility;
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if ( varKey == 'adrDamBonus' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() / 5)) + "%"; 
	}
	else if ( varKey == 'adrTimeSlow' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() * 0.3f * (1 - playerWitcher.GetStatPercents(BCS_Vitality)))) + "%"; 
	}
	else if ( varKey == 'adrSignBonus' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() * playerWitcher.GetSkillLevel(S_Sword_s19) / 10)) + "%"; 
	}
	else if ( varKey == 'injury_resist' ) 
	{
		min = playerWitcher.GetAttributeValue('injury_resist');
		min.valueMultiplicative = ClampF(min.valueMultiplicative, 0.f, 1.f);
		valueAbility = 1.f - (0.1f * playerWitcher.GetSkillLevel(S_Sword_s10));
		valueAbility *= 1.f - min.valueMultiplicative;
		valueStr = NoTrailZeros(RoundMath((1.f - valueAbility) * 100.f)) + "%"; 
	}
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundMath(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey);
	
	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("maxValue", valueMaxStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatToxicity(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	
	var playerWitcher : W3PlayerWitcher;
	var toxicityEffect : W3Effect_Toxicity;
	
	var toxicityLocked : float;
	var toxicityNoLock : float;
		
	var sp : SAbilityAttributeValue;
	var final_name 		: string;
	var itemColor		: string;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	playerWitcher = GetWitcherPlayer();
	toxicityEffect = (W3Effect_Toxicity)playerWitcher.GetBuff(EET_Toxicity);
	
	toxicityNoLock = playerWitcher.GetStat(BCS_Toxicity, true);
	toxicityLocked = playerWitcher.GetStat(BCS_Toxicity) - toxicityNoLock;
	
	// W3EE - Begin
	if ( varKey == 'lockedToxicity' )	
	{
		valueAbility = toxicityLocked;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else
	if ( varKey == 'toxPoiseVal' )
	{
		valueAbility = Combat().BaseStatsPoiseValue(GetWitcherPlayer()) * 100.f;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	//Kolaris - Character Stats Popup
	else if ( varKey == 'toxicGain' )
	{
		if( toxicityEffect )
			valueAbility = toxicityEffect.GetToxicityGain(true);
		else
			valueAbility = 0;
		valueStr = FloatToStringPrec( valueAbility, 2 );
	}
	else if ( varKey == 'toxicDrain' )
	{
		if( toxicityEffect )
			valueAbility = toxicityEffect.GetToxicityDrain() * -1.f;
		else
			valueAbility = 0;
		valueStr = FloatToStringPrec( valueAbility, 2 );
	}
	else if ( varKey == 'toxicDelta' )
	{
		if( toxicityEffect )
			valueAbility = toxicityEffect.GetToxicityGain(true) + toxicityEffect.GetToxicityDrain();
		else
			valueAbility = 0;
		valueStr = FloatToStringPrec( valueAbility, 2 );
	}
	else if ( varKey == 'toxicSpeed' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s16) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.03f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.03f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'toxicAdr' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s16) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'toxicArm' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s20) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.03f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.03f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'toxicPoise' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s20) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
			{
				if( playerWitcher.GetStat(BCS_Toxicity) * playerWitcher.GetSkillLevel(S_Alchemy_s20) <= 500 )
					valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.001f * playerWitcher.GetStat(BCS_Toxicity); 
				else
					valueAbility = 1.f - (1.f / (playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 25.f));
			}
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'feverVigor' ) 
	{
		if( playerWitcher.HasBuff(EET_ToxicityFever) )
			valueAbility = 0.5f * playerWitcher.GetFeverEffectReductionMult();
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'feverStam' ) 
	{
		if( playerWitcher.HasBuff(EET_ToxicityFever) )
			valueAbility = 0.5f * playerWitcher.GetFeverEffectReductionMult();
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'feverSpeed' ) 
	{
		if( playerWitcher.HasBuff(EET_ToxicityFever) )
			valueAbility = 0.15f * playerWitcher.GetFeverEffectReductionMult();
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else
	{
		valueAbility = toxicityNoLock;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	// W3EE - End
	

	final_name = GetLocStringByKeyExt(locKey);
	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatSigns(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	var final_name : string;
	var min, max : float;
	var sp, mutDmgMod, mutMin, mutMax : SAbilityAttributeValue;
	var sword : SItemUniqueId;
	var armorPieces : array<SArmorCount>;
	
	armorPieces = GetWitcherPlayer().GetArmorCountOrig();
	
	statObject = flashMaster.CreateTempFlashObject();
	//Kolaris ++ Mutation Rework
	/*if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		sword = thePlayer.inv.GetCurrentlyHeldSword();
			
		if( thePlayer.inv.GetItemCategory(sword) == 'steelsword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
		}
		else if( thePlayer.inv.GetItemCategory(sword) == 'silversword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
		}
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
			
		mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
	}*/
	//Kolaris -- Mutation Rework
	
	if ( varKey == 'aard_knockdownchance' )	
	{ 
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL;  
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	// W3EE - Begin
	else if ( varKey == 'spell_power_aard' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_igni' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_2);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_quen' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_4);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_yrden' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_3);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_axii' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_5);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	// W3EE - End
	else if ( varKey == 'aard_damage' ) 	
	{  
		// Kolaris - Frostbite
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = 500.f;
		if (GetWitcherPlayer().GetSkillLevel(S_Magic_s20) >= 2)
			valueAbility += 125.f;
		if (GetWitcherPlayer().GetSkillLevel(S_Magic_s20) >= 4)
			valueAbility += 125.f;
		//Kolaris - Disintegration
		if( !GetWitcherPlayer().CanUseSkill(S_Magic_s12) )
			valueAbility += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('aard_damage_bonus'));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	//Kolaris - Frostbite
	else if ( varKey == 'aard_frost_damage' ) 	
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = 50.f * GetWitcherPlayer().GetSkillLevel(S_Magic_s12);
		//Kolaris - Disintegration
		if( GetWitcherPlayer().CanUseSkill(S_Magic_s12) )
			valueAbility += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('aard_damage_bonus'));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'igni_damage' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		//Kolaris - Pyromaniac
		valueAbility = 200.f + GetWitcherPlayer().GetSkillLevel(S_Magic_s09) * 40.f;
		//Kolaris - Purgation
		valueAbility += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('igni_damage_bonus'));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'igni_burnchance' ) 	
	{  
		// Lazarus - Magic_s07
		valueAbility = 0.2f;
		if (GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s07))
		{
			valueAbility += 0.05f * GetWitcherPlayer().GetSkillLevel(S_Magic_s07);
		}
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility *= sp.valueMultiplicative;
		valueAbility += 0.3f;
		valueStr = (string)Min(100, RoundMath(valueAbility * 100)) + " %";
		// Lazarus
	}
	// W3EE - Begin
	else if ( varKey == 'quen_damageabs' )
	{
		// Lazarus - Quen Stats
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = 1000;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility );
		// Lazarus - End
	}
	else if ( varKey == 'quen_duration' )
	{
		// Lazarus - Quen Stats
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true));
		valueAbility *= sp.valueMultiplicative * 1.5f * GetWitcherPlayer().GetPlayerSignDurationMod();
		valueStr = RoundMath(valueAbility) /*FloatToStringPrec( valueAbility, 2 )*/ + GetLocStringByKeyExt("per_second");
		// Lazarus - End
	}
	else if ( varKey == 'yrden_slowdown' )
	{
		// Lazarus - Yrden Slowdown
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		min = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));
		valueAbility =  0.15f * sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
		// Lazarus - End
	}
	else if ( varKey == 'yrden_damage' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		valueAbility = 20 * (GetWitcherPlayer().GetSkillLevel(S_Magic_s11) + 1) * sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'yrden_duration' )
	{
		// Lazarus - Magic_s10
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		valueAbility = 40;
		if (GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s10))
			valueAbility += GetWitcherPlayer().GetSkillLevel(S_Magic_s10) * 4;
		valueAbility *= sp.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod();
		valueStr = FloatToStringPrec( valueAbility, 2 ) + GetLocStringByKeyExt("per_second");
		// Lazarus - End
	}
	else if ( varKey == 'axii_duration_confusion' )
	{
		// Lazarus - Axii Duration
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		valueAbility = 10 * (1 + GetWitcherPlayer().GetSkillLevel(S_Magic_s19) * 0.2f) * sp.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod();
		valueStr = RoundMath(valueAbility) + GetLocStringByKeyExt("per_second");
		// Lazarus - End
	}
	else if ( varKey == 'vigorRegen' ) 
	{
		valueAbility = Combat().GetPlayerVigorRegen();
		//Kolaris - Perfection
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) >= 0.999f  && (GetWitcherPlayer().HasAbility('Glyphword 41 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 42 _Stats', true)) )
			valueAbility *= 1.f + Combat().GetPlayerVitalityRegen(true) / 200;
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2)) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vigorRegenDelay' ) 
	{
		valueAbility = Options().AdrPerc * GetWitcherPlayer().GetStatPercents(BCS_Vitality) * Options().AdrGenSpeedMult * 100;
		valueStr = "1 " + GetLocStringByKeyExt("per_second");
	}
	// W3EE - End
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundF(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey);
	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Blue");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatF(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, pts, perc : float;
	var final_name : string;
	var witcher : W3PlayerWitcher;
	var isPointResist : bool;
	var stat : EBaseCharacterStats;
	var resist : ECharacterDefenseStats;
	var attributeValue : SAbilityAttributeValue;
	var powerStat : ECharacterPowerStats;
	
	statObject = flashMaster.CreateTempFlashObject();
		
	
	witcher = GetWitcherPlayer();
	stat = StatNameToEnum(varKey);
	if(stat != BCS_Undefined)
	{
		valueAbility = witcher.GetStat(stat);
	}
	else
	{
		resist = ResistStatNameToEnum(varKey, isPointResist);
		if(resist != CDS_None)
		{
			witcher.GetResistValue(resist, pts, perc);
			
			if(isPointResist)
				valueAbility = pts;
			else
				valueAbility = perc;
		}
		else
		{
			powerStat = PowerStatNameToEnum(varKey);
			if(powerStat != CPS_Undefined)
			{
				attributeValue = witcher.GetPowerStatValue(powerStat);
			}
			else
			{
				attributeValue = witcher.GetAttributeValue(varKey);
			}
			
			valueAbility = CalculateAttributeValue( attributeValue );
		}
	}
	
	
	valueStr = NoTrailZeros( RoundMath(valueAbility * 100) );
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr + " %");
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	//Kolaris - Dissolution
	var isNigredo : bool;
	var valueAbility, maxHealth, curHealth, nigredoLvl : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	if( GetWitcherPlayer().CountEffectsOfType(EET_NigredoDominance) > 0 )
	{
		isNigredo = true;
		nigredoLvl = 1.1f + 0.02f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s01);
	}
	
	if(varKey != 'safe_dodge_angle' && varKey != 'instant_kill_chance_mult' && varKey != 'human_exp_bonus_when_fatal' && varKey != 'nonhuman_exp_bonus_when_fatal' && varKey != 'area_nml' && varKey != 'area_novigrad' && varKey != 'area_skellige')
	{
		curStats = GetWitcherPlayer().GetOffenseStatsList();
	}
	
	// W3EE - Begin
	if ( varKey == 'silverdamage' ) { valueAbility = ((curStats.silverFastDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverFastDPS * Damage().pdam))+(curStats.silverStrongDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverStrongDPS * Damage().pdam))); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueAbility /= 2; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steeldamage' ) { valueAbility = ((curStats.steelFastDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelFastDPS * Damage().pdam))+(curStats.steelStrongDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelStrongDPS * Damage().pdam))); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueAbility /= 2; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverFastDPS' ) { valueAbility = curStats.silverFastDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverFastDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'silverFastCritChance' ) 	valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'silverFastCritDmg' ) { valueAbility = curStats.silverFastCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverFastCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverStrongDPS' )	{ valueAbility = curStats.silverStrongDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverStrongDmg * Damage().pdam) ; if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'silverStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'silverStrongCritDmg' ) { valueAbility = curStats.silverStrongCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverStrongCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelFastDPS' ) { valueAbility = curStats.steelFastDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelFastDmg * Damage().pdam) ; if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility));	}
	// W3EE - End
	else if ( varKey == 'steelFastCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'steelFastCritDmg' ) { valueAbility = curStats.steelFastCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelFastCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelStrongDPS' )	{ valueAbility = curStats.steelStrongDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelStrongDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'steelStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'steelStrongCritDmg' ) { valueAbility = curStats.steelStrongCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelStrongCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	//Kolaris - Dol Blathanna Set
	else if ( varKey == 'crossbowCritChance' )
	{
		if( thePlayer.IsSetBonusActive(EISB_Elven_1) )
			valueStr = NoTrailZeros(RoundMath((curStats.crossbowCritChance + 0.1f) * 100))+" %";
		else
			valueStr = NoTrailZeros(RoundMath(curStats.crossbowCritChance * 100))+" %";
	}
	else if ( varKey == 'crossbowDmg' )				valueStr = "";
	// W3EE - Begin
	else if ( varKey == 'crossbowSteelDmg' )				
	{ 
		if( isNigredo ) valueAbility *= nigredoLvl;
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSteelDmg * Damage().pdamc));
		switch (curStats.crossbowSteelDmgType)
		{
			case theGame.params.DAMAGE_NAME_BLUDGEONING: locKey = "attribute_name_bludgeoningdamage"; break;
			case theGame.params.DAMAGE_NAME_FIRE: locKey = "attribute_name_firedamage"; break;
			default : locKey = "attribute_name_piercingdamage"; break;
		}
	} 
	else if ( varKey == 'crossbowSilverDmg' )				
	{
		if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(curStats.crossbowSilverDmg * Damage().pdamc));
	}
	// W3EE - End
	else if ( varKey == 'instant_kill_chance_mult') 
	{
		valueAbility = 0;
		// W3EE - Begin
		/*if (thePlayer.CanUseSkill(S_Sword_s03))
		{
			sp += GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, true);
			valueAbility = CalculateAttributeValue(sp);
			valueAbility *= thePlayer.GetSkillLevel(S_Sword_s03);
			valueAbility *= RoundF(thePlayer.GetStat(BCS_Focus));
		}*/
		// W3EE - End
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if (varKey == 'human_exp_bonus_when_fatal' || varKey == 'nonhuman_exp_bonus_when_fatal') 
	{
		sp = thePlayer.GetAttributeValue(varKey);

		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue(sp) * 100)) + " %";
	}
	else if (varKey == 'safe_dodge_angle' )
	{
		valueStr = Combat().GetSafeDodgeAngle();
	}
	else if (varKey == 'area_nml') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_novigrad') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_skellige') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	
	final_name = GetLocStringByKeyExt(locKey); 

	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Red");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU2(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	if ( varKey == 'silver_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	else if ( varKey == 'steel_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function GetEquippedCrossbowDamage():float
{
	var equippedBolt		  : SItemUniqueId;
	var equippedCrossbow	  : SItemUniqueId;
	var crossbowPower         : SAbilityAttributeValue;
	var crossbowStatValueMult : float;
	var primaryStatLabel      : string;
	var primaryStatValue      : float;
	var silverDamageValue	  : float;
	var min, max 			  : SAbilityAttributeValue;
	
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_RangedWeapon, equippedCrossbow);
	if (!thePlayer.inv.IsIdValid(equippedCrossbow))
	{
		return 0;
	}
	
	crossbowPower = thePlayer.inv.GetItemAttributeValue(equippedCrossbow, 'attack_power');
	if(thePlayer.CanUseSkill(S_Sword_s13))
	{				
		crossbowPower.valueMultiplicative += 0.05f * thePlayer.GetSkillLevel(S_Sword_s13);
	}
	crossbowPower += thePlayer.GetPowerStatValue(CPS_AttackPower);
	
	if (crossbowStatValueMult == 0)
	{
		
		crossbowStatValueMult = 1;
	}
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, equippedBolt);
	if (thePlayer.inv.IsIdValid(equippedBolt))
	{
		thePlayer.inv.GetItemPrimaryStat(equippedBolt, primaryStatLabel, primaryStatValue);
		silverDamageValue = CalculateAttributeValue(GetWitcherPlayer().GetInventory().GetItemAttributeValue(equippedBolt, theGame.params.DAMAGE_NAME_SILVER));
	}
	else
	{
		// W3EE - Begin
		/*
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'PiercingDamage', primaryStatValue);
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'SilverDamage', silverDamageValue);
		*/
		primaryStatValue = 0;
		silverDamageValue = 0;
		// W3EE - End
	}
	
	//Kolaris ++ Mutation Rework
	/*if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
		primaryStatValue += min.valueAdditive;
		silverDamageValue += min.valueAdditive;
	}*/
	//Kolaris -- Mutation Rework
	primaryStatValue = (primaryStatValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	silverDamageValue = (silverDamageValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	
	return (primaryStatValue + silverDamageValue) / 2;
}