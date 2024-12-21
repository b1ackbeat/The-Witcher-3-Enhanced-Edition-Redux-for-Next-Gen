/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




abstract class W3RegenEffect extends CBaseGameplayEffect
{
	protected var regenStat : ECharacterRegenStats;			
	protected saved var stat : EBaseCharacterStats;			
	private var isOnMonster : bool;	
	// W3EE - Begin
	var playerWitcher : W3PlayerWitcher;
	var updateTime : float;
	
	default updateTime = 0.f;
	// W3EE - End
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnUpdate(dt : float)
	{
		var regenPoints : float;
		var canRegen : bool;
		var hpRegenPauseBuff : W3Effect_DoTHPRegenReduce;
		var pauseRegenVal, armorModVal : SAbilityAttributeValue;
		var baseStaminaRegenVal : float;
		// W3EE - Begin
		var targetHealthPerc, adrValue : float;
		// W3EE - End
		
		super.OnUpdate(dt);
		
		// W3EE - Begin
		/*
		if(stat == BCS_Vitality && isOnPlayer && target == playerWitcher && playerWitcher.HasRunewordActive('Runeword 4 _Stats'))
		{
			canRegen = true;
		}
		else
		*/
		// W3EE - End
		{
			canRegen = (target.GetStatPercents(stat) < 1);
		}
		
		if(canRegen)
		{
			// W3EE - Begin
			if(isOnPlayer && (regenStat == CRS_Stamina || regenStat == CRS_Vitality) && !StrContains(EffectTypeToName(effectType), "Auto"))
				regenPoints = 0;
			else
			// W3EE - End
			regenPoints = effectValue.valueAdditive + effectValue.valueMultiplicative * target.GetStatMax(stat);
			
			if (isOnPlayer && regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) && playerWitcher)
			{
				baseStaminaRegenVal = playerWitcher.CalculatedArmorStaminaRegenBonus();				
				regenPoints *= 1 + baseStaminaRegenVal;
			}
			// W3EE - Begin
			else if(regenStat == CRS_Vitality || regenStat == CRS_Essence)
			{
				hpRegenPauseBuff = (W3Effect_DoTHPRegenReduce)target.GetBuff(EET_DoTHPRegenReduce);
				if(hpRegenPauseBuff)
				{
					pauseRegenVal = hpRegenPauseBuff.GetEffectValue();
					regenPoints = MaxF(0, regenPoints * (1 - pauseRegenVal.valueMultiplicative) - pauseRegenVal.valueAdditive);
				}
			}
			
			if( regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) )
			{
				if( target.UsesVitality() )
					targetHealthPerc = target.GetStatPercents(BCS_Vitality);
				else
					targetHealthPerc = target.GetStatPercents(BCS_Essence);
				
				if( isOnPlayer)
				{
					//Kolaris - Adrenaline Restoration
					regenPoints *= 1.f - PowF(1.f - targetHealthPerc, 2) * 0.5f * playerWitcher.GetAdrenalinePercMult();
					regenPoints *= 1.f + playerWitcher.GetAdrenalineEffect().GetValue() / 5.f;
					//Kolaris - Toxicity Rework
					if( playerWitcher.HasBuff(EET_ToxicityFever) )
					{
						if( ((W3Effect_ToxicityFever)playerWitcher.GetBuff(EET_ToxicityFever)).IsFeverActive() )
							regenPoints *= 1.f - 0.5f * playerWitcher.GetFeverEffectReductionMult();
					}
					//Kolaris - Ofieri Set
					if( playerWitcher.IsSetBonusActive(EISB_Ofieri) )
						regenPoints += 0.5f * Combat().GetOfieriSetBonusCount("warding");
					//Kolaris - Perfection
					if( playerWitcher.GetStatPercents(BCS_Vitality) >= 0.999f && (playerWitcher.HasAbility('Glyphword 41 _Stats', true) || playerWitcher.HasAbility('Glyphword 42 _Stats', true)) )
						regenPoints += Combat().GetPlayerVitalityRegen(true) / 20;
					//Kolaris - Constitution
					if( playerWitcher.HasBuff(EET_WellFed) && (playerWitcher.HasAbility('Glyphword 44 _Stats', true) || playerWitcher.HasAbility('Glyphword 45 _Stats', true)) )
						regenPoints += 2.f;
					//Kolaris - Assimilation
					if( (playerWitcher.HasAbility('Glyphword 47 _Stats', true) || playerWitcher.HasAbility('Glyphword 48 _Stats', true)) && (playerWitcher.HasBuff(EET_Decoction8) || playerWitcher.HasBuff(EET_Decoction9) || playerWitcher.HasBuff(EET_Decoction10)) )
						regenPoints += 2.f;
					//Kolaris - Conservation
					if( !playerWitcher.IsPlayerMoving() && (playerWitcher.HasAbility('Glyphword 53 _Stats', true) || playerWitcher.HasAbility('Glyphword 54 _Stats', true)) )
						regenPoints *= 1.5f;
					//Kolaris - Tiger Set
					if( playerWitcher.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
						regenPoints *= 1.25f;
					//Kolaris - Netflix Set
					if( playerWitcher.IsSetBonusActive(EISB_Netflix_1) && playerWitcher.GetStatPercents(BCS_Focus) >= 0.999f )
						regenPoints += Combat().GetPlayerVigorRegen() * 10.f * playerWitcher.GetSetPartsEquipped(EIST_Netflix);
				}
				else
				{
					//Kolaris - Enemy Stamina
					regenPoints *= 1.f - PowF(1.f - targetHealthPerc, 2) * 0.5f;
					//regenPoints *= 0.5f;
				}
				
				//Kolaris - Stamina Options
				if( isOnPlayer && Options().StamRegenGlobal() > 0 )
					regenPoints *= Options().StamRegenGlobal();
			}
			// W3EE - End
			
			if( regenPoints > 0 )
				effectManager.CacheStatUpdate(stat, regenPoints * dt);
		}
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var null : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		// W3EE - Begin
		playerWitcher = GetWitcherPlayer();
		// W3EE - End
		
		if(effectValue == null)
		{
			isActive = false;
		}
		else if(target.GetStatMax(stat) <= 0)
		{
			isActive = false;
		}
		CheckMonsterTarget();
	}
	
	private function CheckMonsterTarget()
	{
		var monsterCategory : EMonsterCategory;
		var temp_n : name;
		var temp_b : bool;
		
		theGame.GetMonsterParamsForActor(target, monsterCategory, temp_n, temp_b, temp_b, temp_b);
		isOnMonster = (monsterCategory != MC_Human);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		CheckMonsterTarget();
	}
	
	public function CacheSettings()
	{
		var i,size : int;
		var att : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
							
		super.CacheSettings();
		
		
		if(regenStat == CRS_Undefined)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			size = att.Size();
			
			for(i=0; i<size; i+=1)
			{
				regenStat = RegenStatNameToEnum(att[i]);
				if(regenStat != CRS_Undefined)
					break;
			}
		}
		stat = GetStatForRegenStat(regenStat);
		attributeName = RegenStatEnumToName(regenStat);
	}
	
	public function GetRegenStat() : ECharacterRegenStats
	{
		return regenStat;
	}
	
	public function UpdateEffectValue()
	{
		SetEffectValue();
	}
}