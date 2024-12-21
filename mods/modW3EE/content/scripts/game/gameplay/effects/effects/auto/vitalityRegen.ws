/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_AutoVitalityRegen extends W3AutoRegenEffect
{
	private var regenModeIsCombat : bool;		
	private var cachedPlayer : CR4Player;
	private var witcherPlayer : W3PlayerWitcher;
	private var glyphword39Duration : float;
	private var glyphword39Value : float;

		default regenStat = CRS_Vitality;	
		default effectType = EET_AutoVitalityRegen;
		default regenModeIsCombat = false;
		default glyphword39Duration = 0;
		default glyphword39Value = 0;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			witcherPlayer = (W3PlayerWitcher)target;
		}
	}
	
	//Kolaris - Regeneration
	public function SetGlyphword39Value(amount : float)
	{
		glyphword39Value = amount / 20;
		//theGame.GetGuiManager().ShowNotification("Took " + amount + " Damage");
	}
	
	public function ResetGlyphword39Duration()
	{
		glyphword39Duration = 10.f;
		witcherPlayer.PlayEffect('runeword_8');
		witcherPlayer.AddTimer('StopRuneword8Effect', 9.f, true);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			witcherPlayer = (W3PlayerWitcher)target;
		}
	}
	
	event OnUpdate(deltaTime : float)
	{
		
		if(isOnPlayer)
		{
			
			regenModeIsCombat = cachedPlayer.IsInCombat();
			if(regenModeIsCombat)
				attributeName = 'vitalityCombatRegen';
			else
				attributeName = 'vitalityRegen';
				
			SetEffectValue();
			
			//Kolaris - Regeneration
			if( glyphword39Duration > 0 )
				glyphword39Duration -= deltaTime;
		}
		
		super.OnUpdate(deltaTime);
		
		// W3EE - Begin
		if( target.GetStatPercents( BCS_Vitality ) >= 1.0f /*&& !target.HasAbility('Runeword 4 _Stats', true)*/)
		// W3EE - End
		{
			target.StopVitalityRegen();
		}
	}

	protected function SetEffectValue()
	{
		effectValue = target.GetAttributeValue(attributeName);
		if( isOnPlayer )
		{
			//Kolaris - Undying
			if( target.GetStatPercents(BCS_Vitality) <= 0.5f && witcherPlayer.CanUseSkill(S_Sword_s18) )
				effectValue.valueAdditive += (0.3f * witcherPlayer.GetSkillLevel(S_Sword_s18)) * (1.f - target.GetStatPercents(BCS_Vitality) * 2) * (witcherPlayer.GetAdrenalineEffect().GetFullValue());
			
			//Kolaris - Manticore Set
			if( witcherPlayer.IsSetBonusActive(EISB_RedWolf_2) )
				effectValue.valueAdditive += 0.3f * witcherPlayer.GetStat(BCS_Toxicity);
			
			//Kolaris - Coagulation
			if( witcherPlayer.CountEffectsOfType(EET_RubedoDominance) > 0 )
				effectValue.valueAdditive += 15.f + 3.f * witcherPlayer.GetSkillLevel(S_Alchemy_s03);
			
			//Kolaris - Mutation Rework
			if( FactsQuerySum("TaFtSComplete") > 0 && (witcherPlayer.GetEquippedMutationType() == EPMT_Mutation3 || witcherPlayer.GetEquippedMutationType() == EPMT_Mutation7 || witcherPlayer.GetEquippedMutationType() == EPMT_Mutation8 || witcherPlayer.GetEquippedMutationType() == EPMT_Mutation9) )
				effectValue.valueAdditive += 20.f;
			
			//Kolaris - Ofieri Set
			if( witcherPlayer.IsSetBonusActive(EISB_Ofieri) )
				effectValue.valueAdditive += 3.f * Combat().GetOfieriSetBonusCount("mending");
			
			//Kolaris - Assimilation
			if( (witcherPlayer.HasAbility('Glyphword 47 _Stats', true) || witcherPlayer.HasAbility('Glyphword 48 _Stats', true)) && (witcherPlayer.HasBuff(EET_Decoction1) || witcherPlayer.HasBuff(EET_Decoction2) || witcherPlayer.HasBuff(EET_Decoction3) || witcherPlayer.HasBuff(EET_Decoction4)) )
				effectValue.valueAdditive += 20.f;
			
			//Kolaris - Bastion
			if( witcherPlayer.IsQuenActive(true) && (witcherPlayer.HasAbility('Glyphword 23 _Stats', true) || witcherPlayer.HasAbility('Glyphword 24 _Stats', true)) )
				effectValue += effectValue * 2.f;
			
			//Kolaris - Regeneration
			if( witcherPlayer.HasAbility('Glyphword 37 _Stats', true) || witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true) )
			{
				if( witcherPlayer.GetStat(BCS_Stamina) >= witcherPlayer.GetStatMax(BCS_Stamina) )
				{
					effectValue.valueAdditive += Combat().GetPlayerStaminaRegen() / Options().StamRegenGlobal() * 2.f;
					if( !witcherPlayer.IsPlayerMoving() && (witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true)) )
						effectValue.valueAdditive += Combat().GetPlayerStaminaRegen() / Options().StamRegenGlobal() * 2.f;
				}
				if( witcherPlayer.GetStat(BCS_Focus) >= witcherPlayer.GetStatMax(BCS_Focus) )
				{
					effectValue.valueAdditive += Combat().GetPlayerVigorRegen() * 200.f;
					if( !witcherPlayer.IsPlayerMoving() && (witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true)) )
						effectValue.valueAdditive += Combat().GetPlayerVigorRegen() * 200.f;
				}
			}
			
			if( witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true) )
				effectValue.valueAdditive *= 1.f + (1.f - target.GetStatPercents(BCS_Vitality)) / 2;
			
			//Kolaris - Meditation Regeneration, Kolaris - Mutation 7
			if( target.GetCurrentStateName() == 'W3EEMeditation' )
				effectValue += effectValue;
			else if( witcherPlayer.IsMutationActive(EPMT_Mutation7) && !thePlayer.IsCiri() )
				effectValue.valueAdditive = 0.f;
			
			//Kolaris - Regeneration
			if( glyphword39Duration > 0 )
				effectValue.valueAdditive += glyphword39Value;
			
			//Kolaris - Ciri Regeneration
			if( thePlayer.IsCiri() )
				effectValue.valueAdditive += 100.f * (1.f - target.GetStatPercents(BCS_Vitality));
		}
	}
}