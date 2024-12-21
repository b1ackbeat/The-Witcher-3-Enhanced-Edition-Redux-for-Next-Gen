/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskPerformParry extends CBTTaskPlayAnimationEventDecorator
{
	public var activationTimeLimitBonusHeavy 	: float;
	public var activationTimeLimitBonusLight 	: float;
	// W3EE - Begin
	//public var checkParryChance 				: bool;
	// W3EE - End
	public var interruptTaskToExecuteCounter 	: bool;
	public var allowParryOverlap 				: bool;
	
	private var activationTimeLimit 			: float;
	private var action 							: CName;
	private var runMain 						: bool;
	private var parryChance 					: float;
	private var counterChance 					: float;
	private var counterMultiplier 				: float;
	// W3EE - Begin
	private var counterStaminaCost 				: float;
	private var parryStaminaCost 				: float;
	// W3EE - End
	private var hitsToCounter 					: int;
	private var swingType 						: int;
	private var swingDir 						: int;
	
	default activationTimeLimit = 0.0;
	default action = '';
	default runMain = false;
	default allowParryOverlap = true;
	
	
	function IsAvailable() : bool
	{
		// W3EE - Begin
		GetStats();
		// W3EE - End
		
		InitializeCombatDataStorage();
		if ( ((CHumanAICombatStorage)combatDataStorage).IsProtectedByQuen() )
		{
			GetNPC().SetParryEnabled(true);
			return false;
		}
		// W3EE - Begin
		else if ( activationTimeLimit > 0.0 /*&& ( isActive || !combatDataStorage.GetIsAttacking() )*/ )
		// W3EE - End
		{
			if ( GetLocalTime() < activationTimeLimit )
			{
				// W3EE - Begin
				return GetNPC().GetStat( BCS_Stamina ) >= parryStaminaCost;
				// W3EE - End
			}
			activationTimeLimit = 0.0;
			return false;
		}
		else if ( GetNPC().HasShieldedAbility() && activationTimeLimit > 0.0 )
		{
			GetNPC().SetParryEnabled(true);
			return false;
		}
		else
			GetNPC().SetParryEnabled(false);
			
		return false;
		
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		
		if ( swingDir != -1 )
		{
			npc.SetBehaviorVariable( 'HitSwingDirection', swingDir );
		}
		if ( swingType != -1 )
		{
			npc.SetBehaviorVariable( 'HitSwingType', swingType );
		}
		
		InitializeCombatDataStorage();
		npc.SetParryEnabled(true);
		LogChannel( 'HitReaction', "TaskActivated. ParryEnabled" );
		
		if ( action == 'ParryPerform' )
		{
			if ( TryToParry() )
			{
				runMain = true;
				RunMain();
			}
			action = '';
		}
		
		if ( CheckCounter() && interruptTaskToExecuteCounter )
		{
			npc.DisableHitAnimFor(0.1);
			activationTimeLimit = 0.0;
			return BTNS_Completed;
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var resStart,resEnd : bool = false;
		while ( runMain )
		{
			resStart = GetNPC().WaitForBehaviorNodeDeactivation('ParryPerformEnd',2.f);
			resEnd = GetNPC().WaitForBehaviorNodeActivation('ParryPerformStart',0.0001f);
			if ( !resEnd )
			{
				activationTimeLimit = 0;
				runMain = false;
			}
			if ( resStart && resEnd )
			{
				SleepOneFrame();
			}
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetParryEnabled( false );
		runMain = false;
		activationTimeLimit = 0;
		action = '';
		swingType = -1;
		swingDir = -1;
		
		((CHumanAICombatStorage)combatDataStorage).ResetParryCount();
		
		super.OnDeactivate();
		
		LogChannel( 'HitReaction', "PerformParry Task Deactivated" );
	}
	
	private function CheckCounter() : bool
	{
		var npc : CNewNPC = GetNPC();
		var defendCounter : int;
		
		defendCounter = npc.GetDefendCounter();
		if ( defendCounter >= hitsToCounter )
		{
			// W3EE - Begin
			if( Roll( counterChance ) && GetNPC().GetStat( BCS_Stamina ) >= counterStaminaCost )
			// W3EE - End
			{
				npc.SignalGameplayEvent('CounterFromDefence');
				return true;
			}
		}
		
		return false;
	}
	
	private function GetStats()
	{
		var actor : CActor = GetActor();
		
		//W3EE - Begin
		/*
		parryChance = MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('parry_chance')));
		counterChance = MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance')));
		counterMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(actor.GetAttributeValue('counter_chance_per_hit')));
		hitsToCounter = (int)MaxF(0, CalculateAttributeValue(actor.GetAttributeValue('hits_to_roll_counter')));
		counterChance += Max( 0, actor.GetDefendCounter() ) * counterMultiplier;
		
		if ( hitsToCounter < 0 )
		{
			hitsToCounter = 65536;
		}
		*/
		
		parryChance	= Enemies().SetSkillValue(GetNPC(), ENST_ParryChance);
		hitsToCounter = Enemies().SetSkillValue(GetNPC(), ENST_HitsToRollCounter);
		counterChance = Enemies().SetSkillValue(GetNPC(), ENST_ChanceToCounter);
		parryStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'parry_stamina_cost' ));
		counterStaminaCost = CalculateAttributeValue(actor.GetAttributeValue( 'counter_stamina_cost' ));
		//W3EE - End
	}
	
	private function CanParry() : bool
	{
		// W3EE - Begin
		GetStats();
		/*if ( checkParryChance )
		{*/
			if ( Roll(parryChance) && GetNPC().GetStat( BCS_Stamina ) >= parryStaminaCost )
				return true;
			else
				return false;
		//}
		
		//return true;
		// W3EE - End
	}
	
	private function TryToParry(optional counter : bool) : bool
	{
		var npc : CNewNPC = GetNPC();
		// W3EE - Begin
		var mult : float;
		
		GetStats();
		// W3EE - End
		
		if ( isActive && npc.CanParryAttack() && allowParryOverlap )
		{
			LogChannel( 'HitReaction', "Parried" );
			
			npc.SignalGameplayEvent('SendBattleCry');
			
			// W3EE - Begin
			mult = theGame.params.HEAVY_STRIKE_COST_MULTIPLIER;
			// W3EE - End
			
			if ( npc.RaiseEvent('ParryPerform') )
			{
				// W3EE - Begin
				if( counter )
				{
					//npc.DrainStamina( ESAT_Counterattack, 0, 0, '', 0 );
					npc.SignalGameplayEvent('Counter');
				}
				else
					npc.DrainStamina(ESAT_FixedValue, parryStaminaCost * mult, 0.5);
				// W3EE - End
				
				((CHumanAICombatStorage)combatDataStorage).IncParryCount();
				npc.IncDefendCounter();
				activationTimeLimit = GetLocalTime() + 0.5;
			}
			else
			{
				Complete(false);
			}
			
			return true;
			
		}
		else if ( isActive )
		{
			Complete(false);
			activationTimeLimit = 0.0;
		}
		
		
		return false;
	}
	
	function AdditiveParry( optional force : bool) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( force || (!isActive && npc.CanParryAttack() && combatDataStorage.GetIsAttacking()) )
		{
			npc.RaiseEvent('PerformAdditiveParry');
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var res : bool;
		var isHeavy : bool;
		
		InitializeCombatDataStorage();
		
		if ( eventName == 'swingType' )
		{
			swingType = this.GetEventParamInt(-1);
		}
		if ( eventName == 'swingDir' )
		{
			swingDir = this.GetEventParamInt(-1);
		}
		
		
		if ( eventName == 'ParryStart' )
		{
			GetStats();
			
			if ( interruptTaskToExecuteCounter && CheckCounter() && !GetNPC().IsCountering() )
			{
				GetNPC().DisableHitAnimFor(0.1);
				activationTimeLimit = 0.0;
				Complete(true);
				return false;
			}
			
			if ( CanParry() )
			{
				isHeavy = GetEventParamInt(-1);
				
				if ( isHeavy )
					activationTimeLimit = GetLocalTime() + activationTimeLimitBonusHeavy;
				else
					activationTimeLimit = GetLocalTime() + activationTimeLimitBonusLight;
				
				if ( GetNPC().HasShieldedAbility() )
				{
					GetNPC().SetParryEnabled(true);
				}
			}
			return true;
		}
		
		else if ( eventName == 'ParryPerform' )
		{
			// W3EE - Begin
			GetStats();
			// W3EE - End
			
			if( AdditiveParry() )
				return true;
			
			if( !isActive )
				return false;
			
			isHeavy = GetEventParamInt(-1);
			if( ShouldCounter(isHeavy) )
				res = TryToParry(true);
			else
				res = TryToParry();
			
			if( res )
			{
				runMain = true;
				RunMain();
			}		
			return true;
		}
		
		else if ( eventName == 'CounterParryPerform' )
		{
			// W3EE - Begin
			GetStats();
			// W3EE - End
			
			if ( TryToParry(true) )
			{
				runMain = true;
				RunMain();
			}
			return true;
		}
		
		else if( eventName == 'ParryStagger' )
		{
			// W3EE - Begin
			GetStats();
			// W3EE - End
			
			if( !isActive )
				return false;
				
			if( GetNPC().HasShieldedAbility() )
			{
				GetNPC().AddEffectDefault( EET_Stagger, GetCombatTarget(), "ParryStagger" );
				runMain = false;
				activationTimeLimit = 0.0;
			}
			else if ( TryToParry() )
			{
				GetNPC().LowerGuard();
				runMain = false;
			}
			return true;
		}
		
		else if ( eventName == 'ParryEnd' )
		{
			activationTimeLimit = 0.0;
			return true;
		}
		else if ( eventName == 'PerformAdditiveParry' )
		{
			AdditiveParry(true);
			return true;
		}
		else if ( eventName == 'WantsToPerformDodgeAgainstHeavyAttack' && GetActor().HasAbility('ablPrioritizeAvoidingHeavyAttacks') )
		{
			activationTimeLimit = 0.0;
			if ( isActive )
				Complete(true);
			return true;
		}
		
		return super.OnGameplayEvent ( eventName );
	}
	
	function ShouldCounter(isHeavy : bool) : bool
	{
		var playerTarget : W3PlayerWitcher;
		// W3EE - Begin
		//var temp, temp2		:int;
		// W3EE - End
		
		if ( GetActor().HasAbility('DisableCounterAttack') )
			return false;
		
		playerTarget = (W3PlayerWitcher)GetCombatTarget();
		
		// W3EE - Begin
		if ( playerTarget && playerTarget.IsInCombatAction_SpecialAttackHeavy() )
		// W3EE - End
			return false;
		
		if ( isHeavy && !GetActor().HasAbility('ablCounterHeavyAttacks') )
			return false;
			
		// W3EE - Begin
		//temp = ((CHumanAICombatStorage)combatDataStorage).GetParryCount();
		//temp2 = hitsToCounter;
		return ((CHumanAICombatStorage)combatDataStorage).GetParryCount() >= hitsToCounter && Roll(counterChance) && GetNPC().GetStat( BCS_Stamina ) >= counterStaminaCost;
		// W3EE - End
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBTTaskPerformParryDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskPerformParry';

	editable var activationTimeLimitBonusHeavy 		: CBehTreeValFloat;
	editable var activationTimeLimitBonusLight 		: CBehTreeValFloat;
	editable var checkParryChance 					: bool;
	editable var interruptTaskToExecuteCounter 		: bool;
	editable var allowParryOverlap 					: bool;

	default finishTaskOnAllowBlend = false;
	default allowParryOverlap = true;
	
	hint checkParryChance = "added 18.01.2016, previously npc's used only raise guard chance";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ParryStart' );
		listenToGameplayEvents.PushBack( 'ParryPerform' );
		listenToGameplayEvents.PushBack( 'CounterParryPerform' );
		listenToGameplayEvents.PushBack( 'ParryStagger' );
		listenToGameplayEvents.PushBack( 'ParryEnd' );
		listenToGameplayEvents.PushBack( 'PerformAdditiveParry' );
		listenToGameplayEvents.PushBack( 'WantsToPerformDodgeAgainstHeavyAttack' );
		listenToGameplayEvents.PushBack( 'IgniShieldUp' );
		listenToGameplayEvents.PushBack( 'IgniShieldDown' );
		listenToGameplayEvents.PushBack( 'swingType' );
		listenToGameplayEvents.PushBack( 'swingDir' );
	}
}

class CBTTaskCombatStylePerformParry extends CBTTaskPerformParry
{
	public var parentCombatStyle : EBehaviorGraph;
	
	function GetActiveCombatStyle() : EBehaviorGraph
	{
		InitializeCombatDataStorage();
		if ( combatDataStorage )
			return ((CHumanAICombatStorage)combatDataStorage).GetActiveCombatStyle();
		else
			return EBG_Combat_Undefined;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid(eventName) && parentCombatStyle != GetActiveCombatStyle() )
		{
			return false;
		}
		return super.OnListenedGameplayEvent(eventName);
	}
}

class CBTTaskCombatStylePerformParryDef extends CBTTaskPerformParryDef
{
	default instanceClass = 'CBTTaskCombatStylePerformParry';

	editable inlined var parentCombatStyle : CBTEnumBehaviorGraph;
}
