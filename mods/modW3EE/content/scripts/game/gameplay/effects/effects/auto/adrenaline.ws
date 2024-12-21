/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_AdrenalineDrain extends CBaseGameplayEffect
{
	// W3EE - Begin
	default effectType = EET_AdrenalineDrain;
	default attributeName = 'focus_drain';
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;

	private var customTimerRunning, isRegen : bool;
	private var playerWitcher : W3PlayerWitcher;
	private var Adr : W3EEOptionHandler;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		playerWitcher = (W3PlayerWitcher)target;
		Adr = Options();
		
		if(!playerWitcher)
		{
			LogEffects("W3Effect_AdrenalineDrain.OnEffectAdded: trying to add on non-witcher, aborting!");
			isActive = false;
			return false;
		}
		super.OnEffectAdded(customParams);
		isRegen = true;
	}
	
	public function OnLoad( t : CActor, eff : W3EffectManager )
	{
		super.OnLoad(t, eff);
		if( isOnPlayer )
		{
			playerWitcher = (W3PlayerWitcher)target;
			Adr = Options();
			isRegen = true;
		}
	}
	
	event OnUpdate(dt : float)
	{
		var vigorRegenBonus, mariborBonus : SAbilityAttributeValue;
		var focusGain, reductionValue : float;
		
		if( !isRegen )
			return false;
			
		if( playerWitcher.IsCurrentSignChanneled() )
			return false;
			
		if( playerWitcher.IsQuenActive(true) )
			return false;
			
		vigorRegenBonus = playerWitcher.GetAttributeValue('vigor_regen');
		//Kolaris - Metabolic Control
		if( playerWitcher.HasAbility('Glyphword 46 _Stats', true) || playerWitcher.HasAbility('Glyphword 47 _Stats', true) || playerWitcher.HasAbility('Glyphword 48 _Stats', true) )
			reductionValue = 0.25f - 0.05f * playerWitcher.GetSkillLevel(S_Alchemy_s17);
		else
			reductionValue = 0.5f - 0.05f * playerWitcher.GetSkillLevel(S_Alchemy_s17);
		
		//Kolaris - Maribor Forest
		mariborBonus = playerWitcher.GetAttributeValue('toxicity_vigor_penalty');
		reductionValue *= 1.f + mariborBonus.valueMultiplicative;
		
		focusGain = 0.1f * vigorRegenBonus.valueMultiplicative * dt;
		if( playerWitcher.IsQuenActive(false) )
		{
			if( playerWitcher.CanUseSkill(S_Magic_s14) )
				((W3QuenEntity)playerWitcher.GetSignEntity(ST_Quen)).RegenerateQuen(dt);
			
			//Kolaris - Bastion
			if( playerWitcher.HasAbility('Glyphword 24 _Stats', true) )
				focusGain *= 0.75f + 0.05f * playerWitcher.GetSkillLevel(S_Magic_s14);
			else
				focusGain *= 0.5f + 0.05f * playerWitcher.GetSkillLevel(S_Magic_s14);
		}
		//Kolaris - Perfection
		if( playerWitcher.GetStatPercents(BCS_Vitality) >= 0.999f && (playerWitcher.HasAbility('Glyphword 41 _Stats', true) || playerWitcher.HasAbility('Glyphword 42 _Stats', true)) )
			focusGain *= 1.f + Combat().GetPlayerVitalityRegen(true) / 200;
		//Kolaris - Constitution
		if( playerWitcher.HasBuff(EET_WellRested) && (playerWitcher.HasAbility('Glyphword 44 _Stats', true) || playerWitcher.HasAbility('Glyphword 45 _Stats', true)) )
			focusGain *= 1.2f;
		//Kolaris - Assimilation
		if( (playerWitcher.HasAbility('Glyphword 47 _Stats', true) || playerWitcher.HasAbility('Glyphword 48 _Stats', true)) && (playerWitcher.HasBuff(EET_Decoction5) || playerWitcher.HasBuff(EET_Decoction6) || playerWitcher.HasBuff(EET_Decoction7)) )
			focusGain *= 1.2f;
		//Kolaris - Griffin Set Bonus
		/*if( playerWitcher.IsSetBonusActive(EISB_Gryphon_1) && playerWitcher.CountEffectsOfType(EET_GryphonSetBonusYrden) > 0 )
			focusGain *= 1.2f;*/
		//Kolaris - Tiger Set
		if( playerWitcher.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
			focusGain *= 1.25f;
		//Kolaris - Mutation Rework
		if( FactsQuerySum("TaFtSComplete") > 0 && (playerWitcher.GetEquippedMutationType() == EPMT_Mutation1 || playerWitcher.GetEquippedMutationType() == EPMT_Mutation2 || playerWitcher.GetEquippedMutationType() == EPMT_Mutation6) )
			focusGain *= 1.25f;
		if( ((W3Effect_ToxicityFever)playerWitcher.GetBuff(EET_ToxicityFever)).IsFeverActive() )
			focusGain *= 1.f - 0.5f * playerWitcher.GetFeverEffectReductionMult();
		focusGain *= playerWitcher.GetHPReductionMult();
		//Kolaris - Adrenaline Restoration
		focusGain *= 1.f + playerWitcher.GetAdrenalineEffect().GetValue() / 5.f;
		focusGain *= Adr.AdrGenSpeedMult;
		focusGain *= 1.f - (reductionValue * PowF(target.GetStatPercents(BCS_Toxicity), 2));
		//Kolaris - Mutation 2
		if( !playerWitcher.IsMutationActive(EPMT_Mutation2) || target.GetCurrentStateName() == 'W3EEMeditation' )
			target.GainStat(BCS_Focus, focusGain);
	}
	
	public function StopRegen()
	{
		isRegen = false;
	}
	
	public function ResumeRegen()
	{
		if( !customTimerRunning )
			isRegen = true;
	}
	
	public function SetCustomTimerActive( b : bool )
	{
		customTimerRunning = b;
	}
	// W3EE - End
}