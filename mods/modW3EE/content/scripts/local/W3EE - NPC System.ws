/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

enum ENPCSkillTypes
{
	ENST_HitsToRollBlock,
	ENST_ChanceToRaiseBlock,
	ENST_ChanceToLowerBlock,
	ENST_AdditiveBlockChancePerHit,
	ENST_ParryChance,
	
	ENST_HitsToRollCounter,
	ENST_ChanceToCounter,
	ENST_AdditiveCounterChancePerHit,
	
	ENST_DodgeChanceLightAttack,
	ENST_DodgeChanceHeavyAttack,
	ENST_DodgeChanceSigns,
	ENST_DodgeChanceProjectiles
}

struct SOpponentStats
{
	var spdMultID, spdMultID2, spdMultID3 : int;
	var canGetCrippled, isHuge, isArmored : bool;
	var opponentType : EMonsterCategory;
	var healthType : EBaseCharacterStats;
	var healthRegenFactor, regenDelay : float;
	var meleeWeapon : EMeleeWeaponType;
	var rangedWeapon : ERangedWeaponType;
	var healthValue, damageValue, rangedDamageValue, healthMult, damageMult, armorPiercing, rangedArmorPiercing : float;
	var poiseValue, physicalResist, forceResist, frostResist, fireResist, shockResist, elementalResist, slowResist, confusionResist, bleedingResist, poisonResist, stunResist, injuryResist : float;
	var HitsToRollCounter, ChanceToCounter, AdditiveCounterChancePerHit : float;
	var HitsToRollBlock, ChanceToRaiseBlock, ChanceToLowerBlock, AdditiveBlockChancePerHit, ParryChance : float;
	var DodgeChanceLightAttack, DodgeChanceHeavyAttack, DodgeChanceSigns, DodgeChanceProjectiles : float;
	var dangerLevel : int;
}

class W3EEEnemyHandler extends W3EEScalingHandler
{
	public function NPCStaminaSetup( NPC : CNewNPC, opponentStats : SOpponentStats )
	{
		var staminaValue, mod, playerProgression : float;
		/*
		playerProgression = ClampF(Experience().GetTotalSkillPoints(), 0, 100);
		mod = PowF((0.001 * (playerProgression * 6.4)), 2);
		mod += 1.f;
		*/
		
		//Kolaris - Aggression Stamina
		switch( Aggression() )
		{
			case 0: staminaValue = 40;
			break;
			case 1: staminaValue = 60;
			break;
			case 2: staminaValue = 80;
			break;
			case 3: staminaValue = 100;
			break;
			case 4: staminaValue = 120;
			break;
			case 5: staminaValue = 140;
			break;
			case 6: staminaValue = 160;
			break;
			case 7: staminaValue = 100000;
			break;
		}
		
		if( !NPC.IsHuman() && !NPC.HasAbility('mon_wild_hunt_default') )
		{
			if( opponentStats.isHuge )
				staminaValue *= 2.5f;
			else
				staminaValue *= 1.f;
		}
		else
		{
			if( NPC.HasAbility('SkillWitcher') || NPC.HasAbility('mon_wild_hunt_default') )
			{
				staminaValue *= 3.f;
			}
			else
			if( NPC.HasAbility('SkillTwoHanded') || NPC.HasAbility('SkillElite') || NPC.HasAbility('SkillBoss') || NPC.HasAbility('SkillFistsHard') || NPC.HasAbility('SkillArchmage') )
			{
				staminaValue *= 2.f;
			}
			else
			if( NPC.HasAbility('SkillMercenary') || NPC.HasAbility('SkillOfficer') || NPC.HasAbility('SkillSorceress') || NPC.HasAbility('SkillCiri') || NPC.HasAbility('SkillFistsMedium') || NPC.HasAbility('SkillShieldHard'))
			{
				staminaValue *= 1.5f;
			}
			else
			if( NPC.HasAbility('SkillSoldier') || NPC.HasAbility('SkillGuard') || NPC.HasAbility('SkillFistsEasy') || NPC.HasAbility('SkillShield') )
			{
				staminaValue *= 1.25f;
			}
			else
			if( NPC.HasAbility('SkillThug') || NPC.HasAbility('SkillBrigand') || NPC.HasAbility('SkillMage') )
			{
				staminaValue *= 0.75f;
			}
			else
			if( NPC.HasAbility('SkillPeasant') )
			{
				staminaValue *= 0.5f;
			}
		}
		
		//staminaValue *= mod;
		
		if( NPC.HasTag('IsBoss') || NPC.HasTag('PlayerWolfCompanion') )
			staminaValue = 100000;
		else
			staminaValue *= RandRangeF(1.2f, 0.8f);
		
		staminaValue = ClampF(staminaValue, 30.f, CeilF(staminaValue));
		NPC.abilityManager.SetStatPointMax(BCS_Stamina, staminaValue);
		NPC.abilityManager.SetStatPointCurrent(BCS_Stamina, staminaValue);
	}
	
	public function CacheSkillValues( NPC : CNewNPC, out opponentStats : SOpponentStats )
	{
		if( NPC.IsHuman() )
		{
			if( NPC.HasAbility('SkillPeasant') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group1GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group1GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group1GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group1GetVal4();
				opponentStats.ParryChance = 					Group1GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group1GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group1GetVal7();
				opponentStats.DodgeChanceSigns = 				Group1GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group1GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group1GetVal10();
				opponentStats.ChanceToCounter = 				Group1GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group1GetVal12();
			}
			else
			if( NPC.HasAbility('SkillThug') || NPC.HasAbility('SkillBrigand') || NPC.HasAbility('SkillMage') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group2GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group2GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group2GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group2GetVal4();
				opponentStats.ParryChance = 					Group2GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group2GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group2GetVal7();
				opponentStats.DodgeChanceSigns = 				Group2GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group2GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group2GetVal10();
				opponentStats.ChanceToCounter = 				Group2GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group2GetVal12();
			}
			else
			if( NPC.HasAbility('SkillSoldier') || NPC.HasAbility('SkillGuard') || NPC.HasAbility('SkillSorceress') || NPC.HasAbility('SkillFistsEasy') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group3GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group3GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group3GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group3GetVal4();
				opponentStats.ParryChance = 					Group3GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group3GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group3GetVal7();
				opponentStats.DodgeChanceSigns = 				Group3GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group3GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group3GetVal10();
				opponentStats.ChanceToCounter = 				Group3GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group3GetVal12();
			}
			else
			if( NPC.HasAbility('SkillMercenary') || NPC.HasAbility('SkillOfficer') || NPC.HasAbility('SkillArchmage') || NPC.HasAbility('SkillCiri') || NPC.HasAbility('SkillFistsMedium') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group4GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group4GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group4GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group4GetVal4();
				opponentStats.ParryChance = 					Group4GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group4GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group4GetVal7();
				opponentStats.DodgeChanceSigns = 				Group4GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group4GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group4GetVal10();
				opponentStats.ChanceToCounter = 				Group4GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group4GetVal12();
			}
			else
			if( NPC.HasAbility('SkillElite') || NPC.HasAbility('SkillWitcher') || NPC.HasAbility('SkillBoss') || NPC.HasAbility('SkillFistsHard') || NPC.HasTag('IsBoss') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group5GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group5GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group5GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group5GetVal4();
				opponentStats.ParryChance = 					Group5GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group5GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group5GetVal7();
				opponentStats.DodgeChanceSigns = 				Group5GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group5GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group5GetVal10();
				opponentStats.ChanceToCounter = 				Group5GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group5GetVal12();
				
				if( NPC.HasAbility('SkillWitcher') )
				{
					opponentStats.HitsToRollBlock = 				0;
					opponentStats.HitsToRollCounter = 				0;
					opponentStats.ChanceToCounter = 				0.33f;
					opponentStats.AdditiveCounterChancePerHit =		0.25f;
				}
			}
			else
			if( NPC.HasAbility('SkillShield') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group6GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group6GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group6GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group6GetVal4();
				opponentStats.ParryChance = 					Group6GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group6GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group6GetVal7();
				opponentStats.DodgeChanceSigns = 				Group6GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group6GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group6GetVal10();
				opponentStats.ChanceToCounter = 				Group6GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group6GetVal12();
			}
			else
			if( NPC.HasAbility('SkillShieldHard') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group7GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group7GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group7GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group7GetVal4();
				opponentStats.ParryChance = 					Group7GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group7GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group7GetVal7();
				opponentStats.DodgeChanceSigns = 				Group7GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group7GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group7GetVal10();
				opponentStats.ChanceToCounter = 				Group7GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group7GetVal12();
			}
			else
			if( NPC.HasAbility('SkillTwoHanded') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group8GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group8GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group8GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group8GetVal4();
				opponentStats.ParryChance = 					Group8GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group8GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group8GetVal7();
				opponentStats.DodgeChanceSigns = 				Group8GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group8GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group8GetVal10();
				opponentStats.ChanceToCounter = 				Group8GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group8GetVal12();
			}
			else
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				MaxF(0, CalculateAttributeValue(NPC.GetAttributeValue('hits_to_raise_guard')));
				opponentStats.ChanceToRaiseBlock = 				MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('raise_guard_chance')));
				opponentStats.ChanceToLowerBlock = 				MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('lower_guard_chance')));
				opponentStats.AdditiveBlockChancePerHit = 		MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('raise_guard_chance_mult_per_hit')));
				opponentStats.ParryChance = 					MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('parry_chance')));
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('dodge_melee_light_chance')));
				opponentStats.DodgeChanceHeavyAttack =			MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('dodge_melee_heavy_chance')));
				opponentStats.DodgeChanceSigns = 				MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('dodge_magic_chance')));
				opponentStats.DodgeChanceProjectiles = 			MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('dodge_projectile_chance')));
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				MaxF(0, CalculateAttributeValue(NPC.GetAttributeValue('hits_to_roll_counter')));
				opponentStats.ChanceToCounter = 				MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('counter_chance')));
				opponentStats.AdditiveCounterChancePerHit =		MaxF(0, 100 * CalculateAttributeValue(NPC.GetAttributeValue('counter_chance_per_hit')));
			}
		}
		else
		{
			if( NPC.HasAbility('q104_whboss') )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				0;
				opponentStats.ChanceToRaiseBlock = 				0;
				opponentStats.ChanceToLowerBlock = 				0;
				opponentStats.AdditiveBlockChancePerHit = 		0;
				opponentStats.ParryChance = 					0;
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			0;
				opponentStats.DodgeChanceHeavyAttack =			0;
				opponentStats.DodgeChanceSigns = 				0;
				opponentStats.DodgeChanceProjectiles = 			0;
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				0;
				opponentStats.ChanceToCounter = 				0;
				opponentStats.AdditiveCounterChancePerHit =		0;
			}
			else
			if( NPC.IsHuge() )
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group9GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group9GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group9GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group9GetVal4();
				opponentStats.ParryChance = 					Group9GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group9GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group9GetVal7();
				opponentStats.DodgeChanceSigns = 				Group9GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group9GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group9GetVal10();
				opponentStats.ChanceToCounter = 				Group9GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group9GetVal12();
			}
			else
			{
				// ---- Blocking ---- //
				opponentStats.HitsToRollBlock = 				Group10GetVal1();
				opponentStats.ChanceToRaiseBlock = 				Group10GetVal2();
				opponentStats.ChanceToLowerBlock = 				Group10GetVal3();
				opponentStats.AdditiveBlockChancePerHit = 		Group10GetVal4();
				opponentStats.ParryChance = 					Group10GetVal5();
				
				// ---- Dodging ---- //
				opponentStats.DodgeChanceLightAttack = 			Group10GetVal6();
				opponentStats.DodgeChanceHeavyAttack =			Group10GetVal7();
				opponentStats.DodgeChanceSigns = 				Group10GetVal8();
				opponentStats.DodgeChanceProjectiles = 			Group10GetVal9();
				
				// ---- Countering ---- //
				opponentStats.HitsToRollCounter = 				Group10GetVal10();
				opponentStats.ChanceToCounter = 				Group10GetVal11();
				opponentStats.AdditiveCounterChancePerHit =		Group10GetVal12();
			}
		}
	}
	
	public function SunderShieldedBlockChance(npc : CNewNPC, activate : bool) : bool
	{
		var raiseBlockChance  : float;
	
		if (!npc)
			return false;
			
		if (activate)
		{
			if( npc.HasAbility('SkillShield') )
			{
				raiseBlockChance = Group2GetVal2();
				
				if (raiseBlockChance < npc.npcStats.ChanceToRaiseBlock)				
				{
					npc.npcStats.ChanceToRaiseBlock = raiseBlockChance;
					return true;
				}
			}
			else if (npc.HasAbility('SkillShieldHard'))
			{
				raiseBlockChance = Group4GetVal2();
				
				if (raiseBlockChance < npc.npcStats.ChanceToRaiseBlock)				
				{
					npc.npcStats.ChanceToRaiseBlock = raiseBlockChance;
					return true;
				}
			}
			
			return false;
			
		}
		else if( npc.HasAbility('SkillShield') )
		{
			npc.npcStats.ChanceToRaiseBlock = Group6GetVal2();
			return true;
		}
		else if( npc.HasAbility('SkillShieldHard') )
		{
			npc.npcStats.ChanceToRaiseBlock = Group7GetVal2();
			return true;
		}
		
		return false;			
	}
	
	public function SetSkillValue( npcActor : CNewNPC, skill : ENPCSkillTypes ) : int
	{
		var npcStats : SOpponentStats;
		
		npcStats = npcActor.GetNPCStats();
		//Kolaris - Difficulty Settings
		switch(skill)
		{
			case ENST_HitsToRollBlock:
				return (int)npcStats.HitsToRollBlock;
			
			case ENST_ChanceToRaiseBlock:
				return RoundMath(Options().GetDifficultySettingMod() * (npcStats.ChanceToRaiseBlock + (npcActor.GetHitCounter() * npcStats.AdditiveBlockChancePerHit) + (npcActor.GetDefendCounter() * npcStats.AdditiveBlockChancePerHit)));
			
			case ENST_ChanceToLowerBlock:
				return (int)npcStats.ChanceToLowerBlock;
			
			case ENST_ParryChance:
				return RoundMath(npcStats.ParryChance * Options().GetDifficultySettingMod());
			
			case ENST_HitsToRollCounter:
				return (int)npcStats.HitsToRollCounter;
			
			case ENST_ChanceToCounter:
				return RoundMath(Options().GetDifficultySettingMod() * (npcStats.ChanceToCounter + (npcActor.GetHitCounter() * npcStats.AdditiveCounterChancePerHit) + (npcActor.GetDefendCounter() * npcStats.AdditiveCounterChancePerHit)));
			
			case ENST_DodgeChanceLightAttack:
				return RoundMath(npcStats.DodgeChanceLightAttack * Options().GetDifficultySettingMod());
			
			case ENST_DodgeChanceHeavyAttack:
				return RoundMath(npcStats.DodgeChanceHeavyAttack * Options().GetDifficultySettingMod());
			
			case ENST_DodgeChanceSigns:
				return RoundMath(npcStats.DodgeChanceSigns * Options().GetDifficultySettingMod());
			
			case ENST_DodgeChanceProjectiles:
				return RoundMath(npcStats.DodgeChanceProjectiles * Options().GetDifficultySettingMod());
			
			default:
				return 0;
		}
	}
	
	public final function CacheNPCData( npc : CNewNPC, out npcStats : SOpponentStats )
	{
		var tmpName : name;
		var tmpBool : bool;
		
		if( npc.GetNPCType() == ENGT_Commoner )
			return;
			
		theGame.GetMonsterParamsForActor(npc, npcStats.opponentType, tmpName, tmpBool, tmpBool, tmpBool);
		switch( npcStats.opponentType )
		{
			case MC_Specter :
				npcStats.healthMult = SetHealthSpecter();
				npcStats.damageMult = SetDamageSpecter();
			break;
			
			case MC_Vampire :
				npcStats.healthMult = SetHealthVampire();
				npcStats.damageMult = SetDamageVampire();
			break;
			
			case MC_Magicals :
				if( npc.GetSfxTag() != 'sfx_elemental_dao' && npc.GetSfxTag() != 'sfx_elemental_ifryt' && !npc.HasAbility('mon_ice_golem') && !npc.HasAbility('mon_gargoyle') )
				{
					npcStats.healthMult = SetHealthWildHunt();
					npcStats.damageMult = SetDamageWildHunt();
				}
				else
				{
					npcStats.healthMult = SetHealthElemental();
					npcStats.damageMult = SetDamageElemental();
				}
			break;
			
			case MC_Cursed :
				npcStats.healthMult = SetHealthCursed();
				npcStats.damageMult = SetDamageCursed();
			break;
			
			case MC_Insectoid :
				npcStats.healthMult = SetHealthInsectoid();
				npcStats.damageMult = SetDamageInsectoid();
			break;
			
			case MC_Troll :
				if( npc.GetSfxTag() != 'sfx_nekker' )
				{
					npcStats.healthMult = SetHealthTroll();
					npcStats.damageMult = SetDamageTroll();
				}
				else
				{
					npcStats.healthMult = SetHealthNekker();
					npcStats.damageMult = SetDamageNekker();
				}
			break;
			
			case MC_Human :
				npcStats.healthMult = SetHealthHuman();
				npcStats.damageMult = SetDamageHuman();
			break;
			
			case MC_Animal :
				npcStats.healthMult = SetHealthAnimal();
				npcStats.damageMult = SetDamageAnimals();
			break;
			
			case MC_Necrophage :
				npcStats.healthMult = SetHealthNecro();
				npcStats.damageMult = SetDamageNecro();
			break;
			
			case MC_Hybrid :
				if( npc.GetSfxTag() != 'sfx_gryphon' )
				{
					npcStats.healthMult = SetHealthHybrid();
					npcStats.damageMult = SetDamageHybrid();
				}
				else
				{
					npcStats.healthMult = SetHealthGriffin();
					npcStats.damageMult = SetDamageGriffin();
				}
			break;
			
			case MC_Relic :
				npcStats.healthMult = SetHealthRelict();
				npcStats.damageMult = SetDamageRelict();
			break;
			
			case MC_Beast :
				npcStats.healthMult = SetHealthBeast();
				npcStats.damageMult = SetDamageBeast();
			break;
			
			case MC_Draconide :
				npcStats.healthMult = SetHealthDraconid();
				npcStats.damageMult = SetDamageDraconid();
			break;
			
			default :
				npcStats.healthMult = 1;
				npcStats.damageMult = 1;
			break;
		}
	}
}

class CWolfTalismanItem extends W3QuestUsableItem
{
	default itemType = UI_None;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	
	event OnUsed( usedBy : CEntity )
	{
		((W3PlayerWitcher)usedBy).ManageFollower();
	}
}

statemachine class CWolfNPC extends CNewNPC
{
	private saved var aiTreeFollow : CAIFollowSideBySideAction;
	private saved var actionID : int;
	
	private saved var npcScale : float;
	private saved var npcSpeed : float;
	private saved var isFollowing : bool;
	public saved var shouldFollow : bool;
	
	default npcScale = 1.f;
	default npcSpeed = 1.25f;
	default isFollowing = false;
	default shouldFollow = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		AddTag('PlayerWolfCompanion');
		SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
		SignalGameplayEvent('AxiiGuardMeAdded');
		SignalGameplayEvent('NoticedObjectReevaluation');
		SetScale();
		SetSpeed();
		
		if( shouldFollow )
			GotoState('Following');
		else
			GotoState('Idle');
	}
	
	event OnDeath( damageData : W3DamageAction )
	{
		super.OnDeath(damageData);
		GetWitcherPlayer().RemoveFollower();
	}
	
	event OnInteraction( actionName : string, activator : CEntity ) {}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity ) {}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity ) {}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity ) {}
	
	event OnCompanionInteraction()
	{
		shouldFollow = !shouldFollow;
		if( shouldFollow )
		{
			GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("wolfcomp_follow"));
			GetWitcherPlayer().SetIsWolfFollowing(true);
			GotoState('Following');
		}
		else
		{
			GetWitcherPlayer().DisplayHudMessage(GetLocStringByKeyExt("wolfcomp_stopfollow"));
			GetWitcherPlayer().SetIsWolfFollowing(false);
			GotoState('Idle');
		}
	}
	
	public function StartFollowing() 
	{
		if( !isFollowing )
		{
			aiTreeFollow = new CAIFollowSideBySideAction in this;
			aiTreeFollow.OnCreated();
			aiTreeFollow.params.targetTag = 'PLAYER';
			aiTreeFollow.params.moveSpeed = 6;
			aiTreeFollow.params.teleportToCatchup = true;
			
			actionID = ForceAIBehavior(aiTreeFollow, BTAP_Emergency);
			if( actionID )
			{
				GetMovingAgentComponent().SetDirectionChangeRate(0.16);
				GetMovingAgentComponent().SetMaxMoveRotationPerSec(60);
				isFollowing = true;
			}
		}
	}
	
	public function StopFollowing() : void
	{
		if( isFollowing )
		{
			CancelAIBehavior(actionID);
			delete aiTreeFollow;
			isFollowing = false;
		}
	}
	
	private function SetScale() : void
	{
		var animComps : array<CComponent>;
		var localScale : Vector;
		var i : int;
		
		if( npcScale == 1 )
			return;
			
		animComps = GetComponentsByClassName('CAnimatedComponent');
		for(i=0; i<animComps.Size(); i+=1)
		{
			if( animComps[i] )
			{
				localScale = animComps[i].GetLocalScale();
				animComps[i].SetScale(localScale * npcScale);
			}
		}
	}	
	
	private var npcSpeedMultID : int;	default npcSpeedMultID = -1;
	private function SetSpeed() : void
	{
		npcSpeedMultID = SetAnimationSpeedMultiplier(npcSpeed, npcSpeedMultID);
	}
}

state Following in CWolfNPC
{
	event OnEnterState( prevStateName : name )
	{
		FollowTickTimer();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.StopFollowing();
	}

	entry function FollowTickTimer()
	{
		var distanceToFollower : float;
		
		while(true)
		{
			distanceToFollower = VecDistance(parent.GetWorldPosition(), thePlayer.GetWorldPosition());
			if( distanceToFollower > 5 )
			{
				parent.StartFollowing();
				if( distanceToFollower > 9 )
					parent.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(1.0f);
				else
					parent.GetMovingAgentComponent().SetGameplayRelativeMoveSpeed(0.f);
			}
			else parent.StopFollowing();
			Sleep(0.5f);
		}
	}
}

state Idle in CWolfNPC extends NewIdle
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState(nextStateName);
	}
}

exec function examine()
{
	var gameplayEntity : array<CGameplayEntity>;
	var tags, attributes, abilities : array<name>;
	var naime : string;
	var i : int;
	var actor : CActor;
	
	FindGameplayEntitiesInRange(gameplayEntity, thePlayer, 4.f, 10,, FLAG_ExcludePlayer,, 'CActor');
	for(i=0; i<gameplayEntity.Size(); i+=1)
	{
		actor = (CActor)gameplayEntity[i];
		naime = actor.GetDisplayName(true);
		tags = actor.GetTags();
		attributes = actor.GetAllAttributes();
		actor.GetCharacterStats().GetAbilities(abilities, true);
		thePlayer.GetTarget();
	}
}

exec function aids()
{
	thePlayer.ApplyPoisoning(3, thePlayer, "Poisoning", true);
}