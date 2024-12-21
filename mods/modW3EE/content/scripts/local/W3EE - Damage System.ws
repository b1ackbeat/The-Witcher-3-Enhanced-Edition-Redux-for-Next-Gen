/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

class W3EEDamageHandler
{	
	public var pdam, pdamc, pdams, pdamb, pdot, edot, php, pap, eapl, eaph : float;

	private var Perk10Active : bool; default Perk10Active = false;

	public function RefreshSettings()
	{
		var optionHandler : W3EEOptionHandler = Options();
		
		php = optionHandler.SetHealthPlayer();
		pdam  = optionHandler.PlayerDamage();
		pdamc = optionHandler.PlayerDamageCross();
		pdams = optionHandler.PlayerDamageSign();
		pdamb = optionHandler.PlayerDamageBomb();
		pdot = optionHandler.PlayerDOTDamage();
		edot = optionHandler.EnemyDOTDamage();
		pap = optionHandler.GetPlayerAPMult();
		eapl = optionHandler.GetEnemyLightAPMult();
		eaph = optionHandler.GetEnemyHeavyAPMult();
	}
	
	public function SteelMonsterDamage( actorAttacker : CActor, out damageInfo : array< SRawDamage >, monsterCategory : EMonsterCategory, oilInfos : SOilInfo )
	{
		var witcher : W3PlayerWitcher;
		var i, silverDam, steelDam : int;
		var id : SItemUniqueId;
		
		witcher = (W3PlayerWitcher)actorAttacker;
		if( !witcher )
			return;
			
		silverDam = -1; steelDam = -1;
		for(i=0; i<damageInfo.Size(); i+=1)
		{
			if( damageInfo[i].dmgType == 'SilverDamage' )
				silverDam = i;
			else
			if( DamageHitsVitality(damageInfo[i].dmgType) )
				steelDam = i;
				
			if( silverDam >= 0 && steelDam >= 0 )
				break;
		}
		
		if( silverDam == -1 || steelDam == -1 )
			return;
			
		if( witcher.IsWeaponHeld('crossbow') && (monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed) )
		{
			if ( witcher.inv.GetItemEquippedOnSlot( EES_Bolt, id ) && witcher.inv.ItemHasTag(id, 'Steel_Bolt' ) )
				damageInfo[silverDam].dmgVal = damageInfo[steelDam].dmgVal * 0.1f;
			return;
		}
		
		//Kolaris - Remove Old Enchantments
		if( witcher.inv.ItemHasTag(witcher.GetHeldSword(), 'Aerondight') )
		{
			//Kolaris - Aerondight Damage Fix
			if( witcher.IsWeaponHeld('silversword') )
			{
				if( !MonsterCategoryIsMonster(monsterCategory) )
					damageInfo[steelDam].dmgVal = damageInfo[silverDam].dmgVal * 0.8f;
			}
			else
			{
				if( MonsterCategoryIsMonster(monsterCategory) )
					damageInfo[silverDam].dmgVal *= 1.25f;
			}
			return;
		}
		else
		if( (monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed) && !witcher.IsWeaponHeld('silversword') && witcher.IsWeaponHeld('steelsword') )
		{
			//Kolaris - Steel Against Supernaturals
			if( oilInfos.activeIndex[6] )
				damageInfo[silverDam].dmgVal *= oilInfos.attributeValues[6].valueMultiplicative;
			else
				damageInfo[silverDam].dmgVal = damageInfo[steelDam].dmgVal * 0.1f;
		}	
	}
	
	public function NPCSteelMonsterDamage( actorAttacker : CActor, out damageInfo : array< SRawDamage >, monsterCategory : EMonsterCategory )
    {
        var i, silverDam : int;
        var steelDam : float;
		//Kolaris - Steel Against Supernaturals
        if( ((CR4Player)actorAttacker) /*|| monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed*/ )
            return;
        
        silverDam = -1; steelDam = -1;
        for(i=0; i<damageInfo.Size(); i+=1)
        {
            if( damageInfo[i].dmgType == 'SilverDamage' )
                silverDam = i;
            else
            if( DamageHitsVitality(damageInfo[i].dmgType) && damageInfo[i].dmgType != 'DirectDamage' )
                steelDam += damageInfo[i].dmgVal;
        }
        
        if( steelDam == -1 )
			return;
			
        if( silverDam == -1 )
        {
			damageInfo.PushBack(SRawDamage('SilverDamage', 1.f, 1.f));
			silverDam = damageInfo.Size() - 1;
		}
		
        if( damageInfo[silverDam].dmgVal < steelDam )
		{
			if( monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed )
			{
				//Kolaris - NPC Witcher Damage
				if( ((CNewNPC)actorAttacker).HasAbility('SkillWitcher') )
					damageInfo[silverDam].dmgVal = steelDam * 0.75f;
				else if( actorAttacker.IsHuman() )
					damageInfo[silverDam].dmgVal = steelDam * 0.1f;
				else
					damageInfo[silverDam].dmgVal = steelDam * 0.25f;
			}
			else
				damageInfo[silverDam].dmgVal = steelDam;
		}
    }

	public function GeraltFistDamage( attackAction : W3Action_Attack, out damageInfo : array<SRawDamage>, monsterCategory : EMonsterCategory )
	{
		var i, steelDam, silverDam : int;
		var witcher : W3PlayerWitcher;
		//Kolaris - Brawler
		var gauntlet : SItemUniqueId;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		//Kolaris - Brawler
		if( !witcher || !attackAction.IsActionMelee() || !witcher.IsWeaponHeld('fist') || ( (monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed) && !witcher.CanUseSkill(S_Perk_21) ) )
			return;
		
		for(i=0; i<damageInfo.Size(); i+=1)
		{
			if( damageInfo[i].dmgType == 'BludgeoningDamage' )
				steelDam = i;
			if( damageInfo[i].dmgType == 'SilverDamage' )
				silverDam = i;
		}
		
		//Kolaris - Brawler
		if( witcher.CanUseSkill(S_Perk_21) || (monsterCategory == MC_Human || monsterCategory == MC_NotSet || monsterCategory == MC_Beast || monsterCategory == MC_Animal || monsterCategory == MC_Unused) )
		{
			damageInfo[steelDam].dmgVal = 570.f;
			damageInfo[silverDam].dmgVal = 570.f;
		}
		else
		{
			damageInfo[steelDam].dmgVal = 150.f;
			damageInfo[silverDam].dmgVal = 150.f;
		}

		if( witcher.CanUseSkill(S_Perk_21) && witcher.GetItemEquippedOnSlot(EES_Gloves, gauntlet) )
		{
			damageInfo[steelDam].dmgVal += 3.5f * witcher.inv.GetItemLevel(gauntlet);
			damageInfo[silverDam].dmgVal += 3.5f * witcher.inv.GetItemLevel(gauntlet);
		}
	}
	
	public function HookBaseDamage( actorAttacker : CActor, damageAction : W3DamageAction, out damageInfo : array< SRawDamage > )
    {
        var npcAttacker : CNewNPC;
        var sum, mult : float;
        var i : int;
        
		//Kolaris - Enemy Attacks
        if( (CPlayer)actorAttacker || !actorAttacker || !damageAction || damageAction.WasDamageReturnedToAttacker() || damageAction.IsDoTDamage() || (((W3Action_Attack)damageAction).GetAttackName() == 'attack_no_damage') )
            return;
        
        npcAttacker = (CNewNPC)actorAttacker;
        for(i=0; i<damageInfo.Size(); i+=1)
            if( damageInfo[i].dmgType != 'SilverDamage' )
                sum += damageInfo[i].dmgVal;
        
        if( (damageAction.IsActionRanged() || damageAction.IsActionEnvironment()) && npcAttacker.GetScaledRangedDamage() )
            mult = npcAttacker.GetScaledRangedDamage() / sum;
        else
            mult = npcAttacker.GetScaledDamage() / sum;
        
        for(i=0; i<damageInfo.Size(); i+=1)
		/* original damage system
		{
			if( damageInfo[i].dmgType != 'SilverDamage' )
				damageInfo[i].dmgVal = npcAttacker.GetScaledDamage();
			else
				damageInfo[i].dmgVal *= mult;
        }
		*/
		{
            if( damageInfo[i].dmgType == 'SilverDamage' )
            {
                damageInfo[i].dmgSplit = 1.f;
                continue;
            }
            
            damageInfo[i].dmgSplit = damageInfo[i].dmgVal / sum;
            damageInfo[i].dmgVal *= mult;
        }
    }
	
	public function PlayerModule( out damageData : W3DamageAction )
	{
		//Kolaris - Quest NPC Damage Sliders
		if( thePlayer.IsInFistFightMiniGame() /*|| ((CActor)damageData.victim).IsImmortal()*/ )
			return;
		
		if( (CPlayer)damageData.victim )
		{
			damageData.processedDmg.vitalityDamage /= php;
			damageData.processedDmg.essenceDamage /= php;
			return;
		}
		else
 		if( (CPlayer)damageData.attacker )
		{
			if( damageData.IsActionWitcherSign() && (W3SignProjectile)damageData.causer )
			{
				damageData.processedDmg.vitalityDamage *= pdams;
				damageData.processedDmg.essenceDamage *= pdams;
				return;
			}
			else
			if( damageData.IsActionRanged() && (W3BoltProjectile)damageData.causer )
			{
				damageData.processedDmg.vitalityDamage *= pdamc;
				damageData.processedDmg.essenceDamage *= pdamc;
				return;
			}
			else
			if( damageData.IsActionRanged() && (W3Petard)damageData.causer )
			{
				damageData.processedDmg.vitalityDamage *= pdamb;
				damageData.processedDmg.essenceDamage *= pdamb;
				return;
			}
			else
			{
				damageData.processedDmg.vitalityDamage *= pdam;
				damageData.processedDmg.essenceDamage *= pdam;
				return;
			}
		}
		
	}
	
	public function NPCModule( out damageData : W3DamageAction, actorAttacker : CActor, actorVictim : CActor )
	{
		var npcAttacker, npcVictim : CNewNPC;
		var cachedDamage, cachedHealth : float;
		
		//Kolaris - Quest NPC Damage Sliders
		/*if( actorVictim.IsImmortal() )
			return;*/
		
		npcAttacker = (CNewNPC)actorAttacker;
		npcVictim = (CNewNPC)actorVictim;
		
		if( npcAttacker && npcAttacker != thePlayer )
		{
			cachedDamage = npcAttacker.GetCachedDamage();
			if( cachedDamage <= 0 )
				cachedDamage = 1;
			damageData.processedDmg.vitalityDamage *= cachedDamage;
			damageData.processedDmg.essenceDamage *= cachedDamage;
		}
		
		if( npcVictim && npcVictim != thePlayer )
		{
			cachedHealth = npcVictim.GetCachedHealth();
			if( cachedHealth <= 0 )
				cachedHealth = 1;
			damageData.processedDmg.vitalityDamage /= cachedHealth;
			damageData.processedDmg.essenceDamage /= cachedHealth;
		}
	}
	
	public function DOTModule( out damageData : W3DamageAction )
	{
		if( thePlayer.IsInFistFightMiniGame() )
			return;
		
		if( (CPlayer)damageData.attacker )
		{
			damageData.processedDmg.vitalityDamage *= pdot;
			damageData.processedDmg.essenceDamage *= pdot;
			return;
		}
		else
		{
			damageData.processedDmg.vitalityDamage *= edot;
			damageData.processedDmg.essenceDamage *= edot;
			return;
		}
	}
	
	public function SetPerk10State( i : bool )
	{
		Perk10Active = i;
	}

	public function GetPerk10State() : bool
	{
		return Perk10Active;
	}

	public function Perk10DamageBoost( out damageData : W3DamageAction )
	{
		if( (CPlayer)damageData.attacker && damageData.IsActionMelee() && Perk10Active )
		{
			damageData.processedDmg.vitalityDamage *= 1.1f;
			damageData.processedDmg.essenceDamage *= 1.1f;
			
			GetWitcherPlayer().AddTimer('ResetPerk10', 0.75f, false,,,,true);
		}
		
		//Kolaris - Adrenaline Burst
		/*
		if( (CPlayer)damageData.attacker && thePlayer.CanUseSkill(S_Perk_10) && !Perk10Active )
		{
			SetPerk10State(true);
			GetWitcherPlayer().AddTimer('ResetPerk10', 0.75f, false,,,,true);
		}*/
	}

	public function ColdBloodDamage( out damageData : W3DamageAction, actorVictim : CActor )
	{
		var skillLevel, i : int;
		var damageMult : float;
		var npcVictim : CNewNPC;
		
		npcVictim = (CNewNPC)actorVictim;
		
		if( ((W3ThrowingKnife)damageData.causer || (W3BoltProjectile)damageData.causer) && thePlayer.CanUseSkill(S_Sword_s15) && npcVictim && npcVictim != thePlayer)
		{
			if 	( 	actorVictim.HasBuff(EET_Immobilized) || 
					actorVictim.HasBuff(EET_Burning) || 
					actorVictim.HasBuff(EET_Knockdown) || 
					actorVictim.HasBuff(EET_HeavyKnockdown) || 
					actorVictim.HasBuff(EET_Blindness) || 
					actorVictim.HasBuff(EET_Confusion) || 
					actorVictim.HasBuff(EET_Paralyzed) || 
					actorVictim.HasBuff(EET_Hypnotized) || 
					actorVictim.HasBuff(EET_Stagger) || 
					actorVictim.HasBuff(EET_LongStagger) ||
					actorVictim.HasBuff(EET_Tangled) ||
					actorVictim.HasBuff(EET_Ragdoll) ||
					actorVictim.HasBuff(EET_Frozen) ||
					actorVictim.HasBuff(EET_Trap) ||
					actorVictim.HasBuff(EET_KnockdownTypeApplicator) ||
					actorVictim.HasBuff(EET_CounterStrikeHit) 
				)
			{
				skillLevel = thePlayer.GetSkillLevel(S_Sword_s15);
				
				damageData.processedDmg.vitalityDamage *= skillLevel * 0.2f + 1;
				damageData.processedDmg.essenceDamage *= skillLevel * 0.2f + 1;
			}
		}
	}
	
	//Kolaris - Manticore Set
	public function ManticoreSetStatusDamage( out damageData : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var setParts : int;
		var damageMult : float;
		var npcVictim : CNewNPC;
		
		npcVictim = (CNewNPC)actorVictim;
		
		if( playerAttacker && npcVictim && playerAttacker.IsSetBonusActive(EISB_RedWolf_1) )
		{
			damageMult = 0;
			setParts = ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped(EIST_RedWolf);
			
			if( actorVictim.HasBuff(EET_Bleeding) )
				damageMult += 0.004f * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks();
			if( actorVictim.HasBuff(EET_Poison) )
				damageMult += 0.004f * ((W3Effect_Poison)actorVictim.GetBuff(EET_Poison)).GetStacks();
			if( actorVictim.HasBuff(EET_Immobilized) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Burning) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Knockdown) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_HeavyKnockdown) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Blindness) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Confusion) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Paralyzed) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Hypnotized) )
				damageMult += 0.04f;
			/*if( actorVictim.HasBuff(EET_Stagger) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_LongStagger) )
				damageMult += 0.04f;*/
			if( actorVictim.HasBuff(EET_Tangled) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Ragdoll) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Frozen) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_Trap) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_KnockdownTypeApplicator) )
				damageMult += 0.04f;
			if( actorVictim.HasBuff(EET_CounterStrikeHit) )
				damageMult += 0.04f;
				
			if( damageMult > 0 )
			{
				damageData.processedDmg.vitalityDamage *= 1 + damageMult * setParts;
				damageData.processedDmg.essenceDamage *= 1 + damageMult * setParts;
			}
		}
	}
	//Kolaris - Exhaustion
	public function ExhaustionExpandDamage( out damages : array<SRawDamage>, action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var i : int;
		var frostIdx : int;
		var frostDmg : SRawDamage;
		var damageValue : float;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		if( playerAttacker && action.IsActionMelee() && witcher.HasAbility('Runeword 6 _Stats', true) )
		{
			frostIdx = -1;
			for(i=0; i<damages.Size(); i+=1)
			{
				if( damages[i].dmgType == theGame.params.DAMAGE_NAME_FROST )
				{
					frostIdx = i;
					break;
				}
			}
			
			damageValue = 0.f;
			damageValue += MinF((actorVictim.GetStatMax(BCS_Stamina) - actorVictim.GetStat(BCS_Stamina)), (500.f * (1.f - actorVictim.GetStatPercents(BCS_Stamina))));
			if(actorVictim.GetStatPercents(BCS_Stamina) < 0.25f)
				actorVictim.CreateFXEntityAndPlayEffect('mutation2_critical', 'critical_aard');
			else if(actorVictim.GetStatPercents(BCS_Stamina) < 0.75f)
				actorVictim.CreateFXEntityAndPlayEffect('mutation1_hit', 'mutation_1_hit_aard');
			
			if( frostIdx != -1 )
			{
				damages[frostIdx].dmgVal += damageValue;
			}
			else
			{
				frostDmg.dmgType = theGame.params.DAMAGE_NAME_FROST;
				frostDmg.dmgVal = damageValue;
				damages.PushBack(frostDmg);
			}
		}
	}
	
	//Kolaris - Cremation
	public function CremationDamageAmp( out damageData : W3DamageAction, actorVictim : CActor )
	{
		damageData.processedDmg.vitalityDamage *= 1 + actorVictim.GetCremationCounter();
		damageData.processedDmg.essenceDamage *= 1 + actorVictim.GetCremationCounter();
	}
	
	//Kolaris - Electrocution
	public function ElectrocutionExpandDamage( out damages : array<SRawDamage>, action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var i : int;
		var shockIdx : int;
		var shockDmg : SRawDamage;
		var damageValue : float;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		if( playerAttacker && action.IsActionMelee() && (witcher.HasAbility('Runeword 29 _Stats', true) || witcher.HasAbility('Runeword 30 _Stats', true)) )
		{
			shockIdx = -1;
			for(i=0; i<damages.Size(); i+=1)
			{
				if( damages[i].dmgType == theGame.params.DAMAGE_NAME_SHOCK )
				{
					shockIdx = i;
					break;
				}
			}
			
			damageValue = 0.f;
			damageValue += 150 * ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL);
			if(damageValue >= 75)
				actorVictim.CreateFXEntityAndPlayEffect('mutation1_hit', 'mutation_1_hit_quen');
			
			if( shockIdx != -1 )
			{
				damages[shockIdx].dmgVal += damageValue;
			}
			else
			{
				shockDmg.dmgType = theGame.params.DAMAGE_NAME_SHOCK;
				shockDmg.dmgVal = damageValue;
				damages.PushBack(shockDmg);
			}
		}
	}
	
	//Kolaris - Invocation
	public function ProcessInvocationDamage( out damages : array<SRawDamage>, action : W3DamageAction, playerAttacker : CR4Player )
	{
		var witcher : W3PlayerWitcher;
		var invocationType : ESignType;
		var invocationDamage : SRawDamage;
		var damageValue : float;
		var sp : SAbilityAttributeValue;
		var i, dmgTypeIdx : int;
		var damageTypeName : name;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		invocationType = witcher.GetRunewordInfusionType();
		if( playerAttacker && action.IsActionMelee() && invocationType != ST_None && (witcher.HasAbility('Runeword 40 _Stats', true) || witcher.HasAbility('Runeword 41 _Stats', true) || witcher.HasAbility('Runeword 42 _Stats', true)) )
		{
			switch(invocationType)
			{
				case ST_Aard:
					sp = witcher.GetTotalSignSpellPower( S_Magic_1 );
					damageValue = sp.valueMultiplicative * 100;
					damageTypeName = theGame.params.DAMAGE_NAME_FROST;
				break;
				case ST_Igni:
					sp = witcher.GetTotalSignSpellPower( S_Magic_2 );
					damageValue = sp.valueMultiplicative * 100;
					damageTypeName = theGame.params.DAMAGE_NAME_FIRE;
				break;
				case ST_Yrden:
					sp = witcher.GetTotalSignSpellPower( S_Magic_3 );
					damageValue = sp.valueMultiplicative * 50;
					damageTypeName = theGame.params.DAMAGE_NAME_ELEMENTAL;
				break;
				case ST_Quen:
					sp = witcher.GetTotalSignSpellPower( S_Magic_4 );
					damageValue = sp.valueMultiplicative * 50;
					damageTypeName = theGame.params.DAMAGE_NAME_SHOCK;
				break;
				case ST_Axii:
					sp = witcher.GetTotalSignSpellPower( S_Magic_5 );
					damageValue = sp.valueMultiplicative * 100;
					damageTypeName = theGame.params.DAMAGE_NAME_POISON;
				break;
			}
			
			dmgTypeIdx = -1;
			for(i=0; i<damages.Size(); i+=1)
			{
				if( damages[i].dmgType == damageTypeName )
				{
					dmgTypeIdx = i;
					break;
				}
			}
			
			if( dmgTypeIdx != -1 )
			{
				damages[dmgTypeIdx].dmgVal += damageValue;
			}
			else
			{
				invocationDamage.dmgType = damageTypeName;
				invocationDamage.dmgVal = damageValue;
				damages.PushBack(invocationDamage);
			}
		}
	}
	
	//Kolaris - Resolution
	public function ResolutionDamageMod( out action : W3DamageAction, playerAttacker : CR4Player )
	{
		var enemies : array< CActor >;
		var witcher : W3PlayerWitcher;
		var enemyHealth : float;
		var i : int;
		
		witcher = (W3PlayerWitcher)playerAttacker;
		enemies = witcher.GetEnemies();
		
		if( playerAttacker && action.IsActionMelee() && (witcher.HasAbility('Runeword 43 _Stats', true) || witcher.HasAbility('Runeword 44 _Stats', true) || witcher.HasAbility('Runeword 45 _Stats', true)) )
		{
			for( i = 0; i < enemies.Size(); i += 1)
			{
				if( enemies[i].IsAlive() )
					enemyHealth += enemies[i].GetStatMax(BCS_Vitality) + enemies[i].GetStatMax(BCS_Essence);
			}
			
			action.processedDmg.vitalityDamage *= 1.f + enemyHealth / 100000;
			action.processedDmg.essenceDamage *= 1.f + enemyHealth / 100000;
		}
	}
	
	//Kolaris - Destruction
	public function DestructionDamageMod( out action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var npcVictim : CNewNPC;
		var witcher : W3PlayerWitcher;
		
		npcVictim = (CNewNPC)actorVictim;
		witcher = (W3PlayerWitcher)playerAttacker;
		
		if( playerAttacker && npcVictim && action.IsActionMelee() && (witcher.HasAbility('Runeword 46 _Stats', true) || witcher.HasAbility('Runeword 47 _Stats', true) || witcher.HasAbility('Runeword 48 _Stats', true)) )
		{
			if( npcVictim.HasBuff(EET_Stagger) || npcVictim.HasBuff(EET_LongStagger) )
			{
				action.processedDmg.vitalityDamage *= 1.25f;
				action.processedDmg.essenceDamage *= 1.25f;
			}
			else if( npcVictim.IsInHitAnim() )
			{
				action.processedDmg.vitalityDamage *= 1.1f;
				action.processedDmg.essenceDamage *= 1.1f;
			}
			
			if( witcher.GetStatPercents(BCS_Vitality) > 0.25f && witcher.HasAbility('Runeword 48 _Stats', true) )
			{
				action.processedDmg.vitalityDamage *= 1.5f;
				action.processedDmg.essenceDamage *= 1.5f;
				witcher.DrainVitality(witcher.GetStatMax(BCS_Vitality) * 0.05f);
			}
			witcher.AddTimer('ManageDestructionVisuals', 0.5f,,,,,true);
		}
	}
	
	public function WeatherDamageMultiplier( out damageInfo : array<SRawDamage>, actorVictim : CActor )
	{
		var curGameTime : GameTime;
		var dayPart : EDayPart;
		var moonState : EMoonState;
		var weather : EWeatherEffect;
		var i : int;
		
		moonState = GetCurMoonState();
		curGameTime = GameTimeCreate();
		dayPart = GetDayPart(curGameTime);
		weather = GetCurWeather();
		
		switch( dayPart )
		{
			case ( EDP_Midnight) :
				//if( /moonState != EMS_NotFull )
				{
					if ( moonState == EMS_Red )
					{
						for( i=0; i<damageInfo.Size(); i+=1 )
						{
							if( damageInfo[i].dmgType == 'ElementalDamage' )	damageInfo[i].dmgVal *= 1.40f;
							if( damageInfo[i].dmgType == 'SilverDamage' )		damageInfo[i].dmgVal *= 0.80f;
						}
					}
					else
					if( moonState == EMS_Full )
					{
						for( i=0; i<damageInfo.Size(); i+=1 )
						{
							if( damageInfo[i].dmgType == 'ElementalDamage' )	damageInfo[i].dmgVal *= 1.15f;
							if( damageInfo[i].dmgType == 'SilverDamage' )		damageInfo[i].dmgVal *= 1.05f;
						}
					}
					else
						for( i=0; i<damageInfo.Size(); i+=1 )
							if( damageInfo[i].dmgType == 'ElementalDamage' )	damageInfo[i].dmgVal *= 1.10f;
				}
			break;
			case ( EDP_Noon ) :
				if ( weather == EWE_Clear )
					for( i=0; i<damageInfo.Size(); i+=1 )
						if( damageInfo[i].dmgType == 'FrostDamage' )	damageInfo[i].dmgVal *= 0.95f;
				for( i=0; i<damageInfo.Size(); i+=1 )
					if( damageInfo[i].dmgType == 'ElementalDamage' )	damageInfo[i].dmgVal *= 0.90f;
			break;
			default : break;
		}
		
		switch ( weather )
		{
			case ( EWE_Rain ) :
				for( i=0; i<damageInfo.Size(); i+=1 )
				{
					if( damageInfo[i].dmgType == 'ShockDamage' )	damageInfo[i].dmgVal *= 1.10f;
					if( damageInfo[i].dmgType == 'FireDamage' )		damageInfo[i].dmgVal *= 0.90f;
					if( damageInfo[i].dmgType == 'FrostDamage' )	damageInfo[i].dmgVal *= 1.05f;
				}			
			break;
			case ( EWE_Storm ) :
				for( i=0; i<damageInfo.Size(); i+=1 )
				{
					if( damageInfo[i].dmgType == 'ShockDamage' )	damageInfo[i].dmgVal *= 1.15f;
					if( damageInfo[i].dmgType == 'FireDamage' )		damageInfo[i].dmgVal *= 0.80f;
					if( damageInfo[i].dmgType == 'FrostDamage' )	damageInfo[i].dmgVal *= 1.10f;
				}
			break;
			case ( EWE_Snow ) :
				for( i=0; i<damageInfo.Size(); i+=1 )
				{
					if( damageInfo[i].dmgType == 'FireDamage' )		damageInfo[i].dmgVal *= 0.85f;
					if( damageInfo[i].dmgType == 'FrostDamage' )	damageInfo[i].dmgVal *= 1.15f;
				}
			break;
		}
		
		for( i=0; i<damageInfo.Size(); i+=1 )
			damageInfo[i].dmgVal *= actorVictim.GetDamageTakenMultiplier();
	}
}