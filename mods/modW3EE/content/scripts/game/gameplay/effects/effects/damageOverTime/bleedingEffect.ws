/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_Bleeding extends W3DamageOverTimeEffect
{	
	// W3EE - Begin
	default effectType = EET_Bleeding;
	default resistStat = CDS_BleedingRes;
	
	private saved var curStacks : int;
	private var stackTimer : float;
	private var waitTime : float;
	private var witcherCreator : W3PlayerWitcher;
	
	private const var MAX_STACKS : int;
	private const var UPDATE_TIMER : float;
	
	default MAX_STACKS = 10;
	default UPDATE_TIMER = 1.f;
	
	
	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		
		witcherCreator = (W3PlayerWitcher)GetCreator();
		IncreaseStacks((int)MaxF(1, effectValue.valueMultiplicative));
		CalculateDuration(true);
		ResetStackTimer();
		if( (CR4Player)target )
			theGame.GetTutorialSystem().uiHandler.GotoState('Bleeding');
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbilityAll('BleedingStatDebuff');
		if( target.IsEffectActive(targetEffectName) )
			StopTargetFX();
		//Kolaris - Wolf Set
		if( !((W3PlayerWitcher)target) && witcherCreator.IsSetBonusActive(EISB_Wolf_2) )
		{
			((CNewNPC)target).ReduceNPCStat('force', -0.05f * curStacks);
			((CNewNPC)target).ReduceNPCStat('frost', -0.05f * curStacks);
		}
	}
	
	event OnUpdate( dt : float )
	{	
		var dmg, maxVit, maxEss : float;
		var i : int;
		
		waitTime += dt;
		//Kolaris - Mutilation
		if( witcherCreator.HasAbility('Runeword 55 _Stats', true) || witcherCreator.HasAbility('Runeword 56 _Stats', true) || witcherCreator.HasAbility('Runeword 57 _Stats', true) )
			stackTimer -= dt * curStacks / (1.f + 0.5f * ((CActor)target).GetInjuryManager().GetInjuryCount());
		else
			stackTimer -= dt * curStacks;
		
		if( stackTimer <= 0 )
			RemoveStack();
		
		if( waitTime < UPDATE_TIMER )
			return true;
			
		if( !target.IsAlive() )
			return true;
			
		if( target.IsQuestActor() || target.HasAbility('q105_evil_heart') || (target.HasAbility('mh201_cave_troll') && target.GetAttitude( thePlayer ) == AIA_Friendly) || (target.HasAbility('WildHunt_Eredin') && target.GetStatPercents(BCS_Essence) < 0.05f) )
			return false;
			
		waitTime = 0.f;
		for(i=0; i<damages.Size(); i+=1)
		{
			//Kolaris - Bleed Rebalance
			dmg = 5.f * curStacks;
			dmg *= 2.f - target.GetStatPercents(BCS_Stamina);
				
			if( (W3PlayerWitcher)target && ((W3PlayerWitcher)target).IsMeditating() )
				dmg *= 0.5f;
			
			//Kolaris - Difficulty Settings
			if( (W3PlayerWitcher)target )
				dmg *= Options().GetDifficultySettingMod();
			
			if( dmg > 0 )
				effectManager.CacheDamage(damages[i].damageTypeName, dmg, GetCreator(), this, 1.f, true, powerStatType, isEnvironment);		
		}
	}
	
	public function ResetStackTimer()
	{
		var timeReduction : SAbilityAttributeValue;
		
		timeReduction = target.GetAttributeValue('bleed_stack_timer_reduction');
		stackTimer = 60.f * (1.f - timeReduction.valueMultiplicative);
	}
	
	public function RemoveStack( optional val : int )
	{
		val = Max(val, 1);
		if( curStacks - val < 0 )
			val = curStacks;
			
		curStacks -= val;
		target.RemoveAbilityMultiple('BleedingStatDebuff', val);
		
		//Kolaris - Wolf Set
		if( !((W3PlayerWitcher)target) && witcherCreator.IsSetBonusActive(EISB_Wolf_2) )
		{
			((CNewNPC)target).ReduceNPCStat('force', -0.05f * val);
			((CNewNPC)target).ReduceNPCStat('frost', -0.05f * val);
		}
		
		if( curStacks <= 0 )
			target.RemoveEffect(this);
		
		ResetStackTimer();
	}
	
	protected function CalculateDuration( optional setInitialDuration : bool )
	{
		if( setInitialDuration )
			initialDuration = -1;
		duration = -1;
	}
	
	public function OnDamageDealt( dealtDamage : bool )
	{
		if( target.IsQuestActor() )
			return;
			
		if( dealtDamage && curStacks > 4 )
		{
			shouldPlayTargetEffect = true;
			if( !target.IsEffectActive(targetEffectName) )
				PlayTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = false;
			if( target.IsEffectActive(targetEffectName) )
				StopTargetFX();
		}
	}
	
	public function IncreaseStacks( optional val : int )
	{
		var action : W3DamageAction;
		
		if( target.IsQuestActor() )
			return;
			
		ResetStackTimer();
		
		val = Max(1, val);
		//Kolaris - DoT Stack Overflow, Kolaris - Exsanguination
		if( curStacks + val > MAX_STACKS && !(witcherCreator.HasAbility('Runeword 20 _Stats', true) || witcherCreator.HasAbility('Runeword 21 _Stats', true)) )
		{
			val += curStacks - MAX_STACKS;
			
			if( (W3PlayerWitcher)target )
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_BLEEDING, 300 * val * Options().EnemyDOTDamage(), GetCreator(), this, 1.f, true, powerStatType, isEnvironment);	
			else
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_BLEEDING, 300 * val * Options().PlayerDOTDamage(), GetCreator(), this, 1.f, true, powerStatType, isEnvironment);
			
			action = new W3DamageAction in theGame;
			action.Initialize(GetCreator(), target, GetWitcherPlayer(), "Poison Overflow", EHRT_Heavy, CPS_Undefined, false, false, false, true);
			action.SetHitAnimationPlayType(EAHA_ForceYes);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			theGame.damageMgr.ProcessAction(action);
			delete action;
			
			if(target.CanBleed())
			{
				target.PlayEffectSingle( 'blood_spill' );
				target.CreateBloodSpill();
			}
			
			val = MAX_STACKS - curStacks;
		}
			
		curStacks += val;
		
		//Kolaris - Wolf Set
		if( !((W3PlayerWitcher)target) && witcherCreator.IsSetBonusActive(EISB_Wolf_2) )
		{
			((CNewNPC)target).ReduceNPCStat('force', 0.05f * val);
			((CNewNPC)target).ReduceNPCStat('frost', 0.05f * val);
		}
		
		target.AddAbilityMultiple('BleedingStatDebuff', val);
		
		//Kolaris - Conjunction
		if( Combat().DoesAxiiLinkContainActor(target) && (GetWitcherPlayer().HasAbility('Glyphword 25 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 26 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 27 _Stats', true)) )
			Combat().ProcessConjunctionEffects(this, target);
	}
	
	public function GetStacks() : int
	{
		return curStacks;
	}
	
	public function GetMaxStacks() : int
	{
		return MAX_STACKS;
	}
	// W3EE - End
}

class W3Effect_Bleeding1 extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding1;
	default resistStat = CDS_BleedingRes;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);

		if( target == thePlayer)
		 Log("");
	}

	public function OnDamageDealt(dealtDamage : bool)
	{

		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;

			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;

			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}

class W3Effect_Bleeding2 extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding2;
	default resistStat = CDS_BleedingRes;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);

		if( target == thePlayer)
		 Log("");
	}

	public function OnDamageDealt(dealtDamage : bool)
	{

		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;

			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;

			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}

class W3Effect_Bleeding3 extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding3;
	default resistStat = CDS_BleedingRes;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);

		if( target == thePlayer)
		 Log("");
	}

	public function OnDamageDealt(dealtDamage : bool)
	{

		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;

			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;

			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}
