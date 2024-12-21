/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3Effect_Poison extends W3DamageOverTimeEffect
{
	// W3EE - Begin
	default effectType = EET_Poison;
	default resistStat = CDS_PoisonRes;
	
	private saved var curStacks : int;
	private var speedMultID : int;
	private var stackTimer : float;
	private var waitTime : float;
	private var witcherCreator : W3PlayerWitcher;
	
	private const var MAX_STACKS : int;
	private const var UPDATE_TIMER : float;
	
	//Kolaris - Poison Tweak
	default MAX_STACKS = 10;
	default UPDATE_TIMER = 1.f;
	
	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		
		witcherCreator = (W3PlayerWitcher)GetCreator();
		
		IncreaseStacks((int)MaxF(1, effectValue.valueMultiplicative));
		CalculateDuration(true);
		ResetStackTimer();
		
		//Kolaris - Toxicity Rework
		if( (W3PlayerWitcher)target )
			target.GainStat(BCS_Toxicity, 1);
		
		if( (CR4Player)target )
			theGame.GetTutorialSystem().uiHandler.GotoState('Poisoning');
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbilityAll('PoisoningStatDebuff');
		target.ResetAnimationSpeedMultiplier(speedMultID);
		//Kolaris - Affliction
		if( !((W3PlayerWitcher)target) && witcherCreator.HasAbility('Runeword 18 _Stats', true) )
		{
			((CNewNPC)target).ReduceNPCStat('poison', -0.05f * curStacks);
			((CNewNPC)target).ReduceNPCStat('bleed', -0.05f * curStacks);
			((CNewNPC)target).ReduceNPCStat('injury', -0.05f * curStacks);
		}
	}
	
	event OnUpdate( dt : float )
	{	
		var buildupReduction : SAbilityAttributeValue;
		var dmg, maxVit, maxEss : float;
		var i : int;
		
		waitTime += dt;
		stackTimer -= dt * curStacks;
		
		if( stackTimer <= 0 )
			RemoveStack();
			
		if( waitTime < UPDATE_TIMER )
			return true;
			
		if( !target.IsAlive() )
			return true;
			
		if( target.IsQuestActor() || target.HasAbility('q105_evil_heart') || (target.HasAbility('mh201_cave_troll') && target.GetAttitude( thePlayer ) == AIA_Friendly) )
			return false;
			
		waitTime = 0.f;
		for(i=0; i<damages.Size(); i+=1)
		{
			if( (W3PlayerWitcher)target )
			{
				dmg = 0.f;
				//Kolaris - Toxicity Rework
				/*buildupReduction = target.GetAttributeValue('poison_buildup_resist');
				((W3PlayerWitcher)target).AddToxicityOffset(1.f * curStacks * (1.f - buildupReduction.valueMultiplicative));*/
				if( target.HasBuff(EET_Decoction10) )
					target.RemoveAbilityAll('PoisoningStatDebuff');
				
				if( curStacks > 4 )
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
			//Kolaris - Affliction
			else
			if( witcherCreator.HasAbility('Runeword 18 _Stats', true) )
				dmg = 10.f * curStacks;
			else
				dmg = 5.f * curStacks;
				
			if( dmg > 0 )
				effectManager.CacheDamage(damages[i].damageTypeName, dmg, GetCreator(), this, 1.f, true, powerStatType, isEnvironment);		
		}
	}
	
	public function ResetStackTimer()
	{
		var timeReduction : SAbilityAttributeValue;
		
		timeReduction = target.GetAttributeValue('poison_stack_timer_reduction');
		stackTimer = 60.f * (1.f - timeReduction.valueMultiplicative);
	}
	
	private function RemoveStack()
	{
		curStacks -= 1;
		target.RemoveAbility('PoisoningStatDebuff');
		if( !((W3PlayerWitcher)target) )
		{
			speedMultID = target.SetAnimationSpeedMultiplier(1.f - MinF(0.2f, 0.02f * curStacks) - ((0.02f * MaxF(0, curStacks - 10)) / (1.f + (0.02f * curStacks))), speedMultID);
			//Kolaris - Affliction
			if( witcherCreator.HasAbility('Runeword 18 _Stats', true) )
			{
				((CNewNPC)target).ReduceNPCStat('poison', -0.05f);
				((CNewNPC)target).ReduceNPCStat('bleed', -0.05f);
				((CNewNPC)target).ReduceNPCStat('injury', -0.05f);
			}
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
		//Kolaris - DoT Stack Overflow, Kolaris - Affliction
		if( curStacks + val > MAX_STACKS && !(witcherCreator.HasAbility('Runeword 17 _Stats', true) || witcherCreator.HasAbility('Runeword 18 _Stats', true)) )
		{
			val += curStacks - MAX_STACKS;
			
			effectManager.CacheDamage(theGame.params.DAMAGE_NAME_POISON, 300 * val * Options().PlayerDOTDamage(), GetCreator(), this, 1.f, true, powerStatType, isEnvironment);
			
			action = new W3DamageAction in theGame;
			action.Initialize(GetCreator(), target, GetWitcherPlayer(), "Poison Overflow", EHRT_Heavy, CPS_Undefined, false, false, false, true);
			action.SetHitAnimationPlayType(EAHA_ForceYes);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			theGame.damageMgr.ProcessAction(action);
			delete action;
			
			val = MAX_STACKS - curStacks;
		}
			
		curStacks += val;
		
		if( !target.HasBuff(EET_Decoction10) )
			target.AddAbilityMultiple('PoisoningStatDebuff', val);
			
		if( !((W3PlayerWitcher)target) )
		{
			speedMultID = target.SetAnimationSpeedMultiplier(1.f - MinF(0.2f, 0.02f * curStacks) - ((0.02f * MaxF(0, curStacks - 10)) / (1.f + (0.02f * curStacks))), speedMultID);
			//Kolaris - Affliction
			if( witcherCreator.HasAbility('Runeword 18 _Stats', true) )
			{
				((CNewNPC)target).ReduceNPCStat('poison', 0.05f * val);
				((CNewNPC)target).ReduceNPCStat('bleed', 0.05f * val);
				((CNewNPC)target).ReduceNPCStat('injury', 0.05f * val);
			}
		}
		
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