class CWitcherCampfire extends W3Campfire
{
	default dontCheckForNPCs = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	
	event OnDestroyed()
	{
		super.OnDestroyed();
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionActivated(interactionComponentName, activator);
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionDeactivated(interactionComponentName, activator);
	}
	
	public function PlayFireEffect( idx : int )
	{
		if( idx == 1 )
			PlayEffect('fire');
		else
		if( idx == 2 )
			PlayEffect('fire_01');
		else
			PlayEffect('fire_big');
	}
}

exec function playfireeffects( idx : int )
{
		if( idx == 1 )
			CampfireManager().GetPlayerCampfire().PlayEffect('fire');
		else
		if( idx == 2 )
			CampfireManager().GetPlayerCampfire().PlayEffect('fire_01');
		else
			CampfireManager().GetPlayerCampfire().PlayEffect('fire_big');
}

statemachine class CWitcherCampfireManager
{
	protected var alternateFireSource						: CGameplayLightComponent;
	protected var witcherCampfire 							: W3Campfire;
	private var playerWitcher								: W3PlayerWitcher;
	private var fireMode									: int;
	private var noFireMode									: bool;
	
	protected const var CAMPFIRE_SPAWN_DELAY				: float;
	protected const var KINDLE_DELAY						: float;
	protected const var KINDLE_DELAY_EXISTING				: float;
	protected const var EXTINGUISH_DELAY					: float;
	protected const var CAMPFIRE_DESTRUCTION_DELAY			: float;
	
	default KINDLE_DELAY = 1.43f;
	default KINDLE_DELAY_EXISTING = 5.f;
	default CAMPFIRE_SPAWN_DELAY = 3.57f;
	default EXTINGUISH_DELAY = 1.5f;
	default CAMPFIRE_DESTRUCTION_DELAY = 1.9f;
	
	/*
	-2 		- stand up
	-1 		- stand up and put out
	0		- meditate no lighting
	1		- meditate lighting and campfire
	2		- meditate lighting
	*/
	public function ManageFire( noFireCall : bool ) : int
	{
		noFireMode = noFireCall;
		if( GetCurrentStateName() == 'Lit' )
		{
			fireMode = -1;
			GotoState('Extinguished');
		}
		else
		if( GetCurrentStateName() == 'Idle' )
		{
			fireMode = -2;
			GotoState('Extinguished');
		}
		else
		{
			fireMode = GetFireMode();
			if( fireMode == 1 )
				GotoState('Spawned');
			else
			if( fireMode == 2 )
				GotoState('Lit');
			else
				GotoState('Idle');
		}
		
		return fireMode;
	}
	
	public function Init( player : W3PlayerWitcher )
	{
		playerWitcher = player;
	}
	
	public function CanPerformAlchemy( optional alchemist : bool ) : bool
	{
		if( alchemist || Options().GetPerformAlchemyAnywhere() )
			return true;
		else
			return ( (alternateFireSource || witcherCampfire) && (alternateFireSource.IsLightOn() || witcherCampfire.IsOnFire()) && (VecDistanceSquared( GetPlayerPosition(), GetFirePosition() ) <= 4) && GetPlayer().IsMeditating() );
	}
	
	//Kolaris - Campfire Upgrading
	public function CanPerformUpgrade() : bool
	{
		return ( (alternateFireSource || witcherCampfire) && (alternateFireSource.IsLightOn() || witcherCampfire.IsOnFire()) && (VecDistanceSquared( GetPlayerPosition(), GetFirePosition() ) <= 4) && GetPlayer().IsMeditating() );
	}
	
	public function GetPlayerCampfire() : W3Campfire
	{
		return witcherCampfire;
	}
	
	public function IsAnyFireLit() : bool
	{
		return ( alternateFireSource.IsLightOn() || witcherCampfire.IsOnFire() );
	}
	
	public function ForgetFirecamps() 
	{
		BigFactRemove("w3ee_fireplace_x");
		BigFactRemove("w3ee_fireplace_y");
		BigFactRemove("w3ee_fireplace_z");
		BigFactRemove("w3ee_fireplace_w");
		BigFactRemove("w3ee_fireplace_map");
	}
	
	public function RestoreFirecamps() 
	{
		var entityTemplate : CEntityTemplate;
		var x, y, z, w : float;
		var position : Vector;
		var map : int;
		
		if (BigFactExists("w3ee_fireplace_x")) 
		{
			
			map = theGame.GetCommonMapManager().GetCurrentArea();
			
			if (map != FactsQuerySum("w3ee_fireplace_map")) 
			{
				ForgetFirecamps();
				return;
			}
			x = BigFactGet("w3ee_fireplace_x") / 100000.0;
			y = BigFactGet("w3ee_fireplace_y") / 100000.0;
			z = BigFactGet("w3ee_fireplace_z") / 100000.0;
			w = BigFactGet("w3ee_fireplace_w") / 100000.0;
			
			position = (Vector)(x, y ,z, w);
			entityTemplate = (CEntityTemplate)LoadResource("environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
			theGame.CreateEntity(entityTemplate, position);
		}
	}
	
	protected function Getvirtual_parentFireMode() : int
	{
		return fireMode;
	}
	
	protected function GetCampfireZPosition( position : Vector ) : float
	{
		var position_z : float;			
		
		if( theGame.GetWorld().GetWaterLevel(position, true) >= position.Z )
			return 0;
		else
		if( theGame.GetWorld().NavigationLineTest(GetPlayer().GetWorldPosition(), position, 0.2f) )
		{
			theGame.GetWorld().PhysicsCorrectZ(position, position_z);
			return position_z;
		}
		
		return 0;
	}
	
	protected function GetSafeCampfirePosition() : Vector
	{
		return (GetPlayer().GetWorldPosition() + VecFromHeading(GetPlayer().GetHeading() ) * (Vector)(0.83f, 0.83f, 1.f, 1.f) );
	}
	
	protected function DestroyWitcherCampfire()
	{
		if( witcherCampfire )
		{
			witcherCampfire.Destroy();
		}
	}
	
	protected function GetFirePosition() : Vector
	{
		if( alternateFireSource )
			return alternateFireSource.GetWorldPosition();
		else
			return witcherCampfire.GetWorldPosition();
	}
	
	protected function GetPlayerPosition() : Vector
	{
		return playerWitcher.GetWorldPosition();
	}
	
	protected function GetPlayer() : W3PlayerWitcher
	{
		return playerWitcher;
	}
	
	private function GetFireMode() : int
	{
		if( GetIsFireSourceNear() )
		{
			if( alternateFireSource.IsLightOn() )
				return 0;
			else
				return 2;
		}
		else
		if( noFireMode )
			return 0;
		/*
		else
		if( playerWitcher.IsInInterior() )
			return 0;
		*/
		else
		if( !UseTimber() )
			return 0;
		else
		if( !GetCampfireZPosition(GetSafeCampfirePosition()) )
			return 0;
		else
			return 1;
	}
	
	private function GetIsFireSourceNear() : bool
	{
		return ( FindFireSource('CWitcherCampfire') || FindFireSource('W3Campfire') || FindFireSource('W3FireSource') );
	}
	
	private function UseTimber() : bool
	{
		var kindling, hardKindling, requiredKindling, requiredHardKindling, totalKindling, totalRequiredKindling : int;
		var inv : CInventoryComponent;
		
		inv = playerWitcher.GetInventory();
		
		kindling = Equipment().GetItemQuantityByNameForCrafting('Timber');
		hardKindling = Equipment().GetItemQuantityByNameForCrafting('Hardened timber');
		
		requiredKindling = Options().GetRequiredTimber();
		requiredHardKindling = Options().GetRequiredHardTimber();
		
		totalKindling = kindling + hardKindling;
		totalRequiredKindling = requiredKindling + requiredHardKindling;
		
		if( kindling >= requiredKindling )
		{
			Equipment().RemoveItemByNameForCrafting('Timber', requiredKindling);
			return true;
		}
		else
		if( hardKindling >= requiredHardKindling )
		{
			Equipment().RemoveItemByNameForCrafting('Hardened timber', requiredHardKindling);
			return true;
		}
		else
		if( totalRequiredKindling <= totalKindling )
		{
			if( kindling < hardKindling )
			{
				Equipment().RemoveItemByNameForCrafting('Timber', kindling);
				Equipment().RemoveItemByNameForCrafting('Hardened timber', totalRequiredKindling - (totalKindling - kindling));
			}
			else
			{
				Equipment().RemoveItemByNameForCrafting('Hardened timber', hardKindling);
				Equipment().RemoveItemByNameForCrafting('Timber', totalRequiredKindling - (totalKindling - hardKindling));
			}
			return true;
		}
		
		return false;		
	}
	
	private function FindFireSource( fireEntity : name, optional range : float ) : bool
	{
		var entities : array<CGameplayEntity>;
		var lightComponent : CGameplayLightComponent;
		var i : int;
		
		if( !range )
			range = 2.f;
		
		FindGameplayEntitiesInRange(entities, playerWitcher, range, 10,, FLAG_ExcludePlayer,, fireEntity);
		for(i=0; i<entities.Size(); i+=1)
		{
			lightComponent = (CGameplayLightComponent)entities[i].GetComponentByClassName('CGameplayLightComponent');
			if( lightComponent )
			{
				if( witcherCampfire && (CWitcherCampfire)entities[i] == witcherCampfire )
				{
					alternateFireSource = NULL;
					return true;
				}
				else
				{
					alternateFireSource = lightComponent;
					return true;
				}
			}
		}
		return false;
	}
}

state Idle in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		RotateToFire();
	}
	
	private function RotateToFire()
	{
		if( VecDistanceSquared(virtual_parent.GetFirePosition(), virtual_parent.GetPlayerPosition()) < 15 )
			virtual_parent.GetPlayer().SetCustomRotation('LookAtFire', VecHeading(virtual_parent.GetFirePosition() - virtual_parent.GetPlayerPosition()), 360.f, 1.f, false);
	}
}

state Lit in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if( prevStateName != 'Spawned' )
			RotateToFire();
		LightFire();
	}
	
	private entry function LightFire()
	{
		if( virtual_parent.Getvirtual_parentFireMode() == 1 )
		{
			Sleep(virtual_parent.KINDLE_DELAY);
			virtual_parent.witcherCampfire.ToggleFire(true);
		}
		else
		{
			Sleep(virtual_parent.KINDLE_DELAY_EXISTING);
			virtual_parent.alternateFireSource.SetLight(true);
		}
	}
	
	private function RotateToFire()
	{
		virtual_parent.GetPlayer().SetCustomRotation('LookAtFire', VecHeading(virtual_parent.GetFirePosition() - virtual_parent.GetPlayerPosition()), 360.f, 1.f, false);
	}
}

state Extinguished in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if( prevStateName != 'Idle' )
			ExtinguishFire();
	}
	
	private entry function ExtinguishFire()
	{
		Sleep(virtual_parent.EXTINGUISH_DELAY);
		if( virtual_parent.Getvirtual_parentFireMode() == -1 )
		{
			virtual_parent.witcherCampfire.ToggleFire(false);
			virtual_parent.alternateFireSource.SetLight(false);
			virtual_parent.alternateFireSource = NULL;
		}
	}
}

state Spawned in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if( prevStateName == 'None' )
			virtual_parent.PushState('Destroyed');
		else
			BuildCampfire();
	}

	private entry function BuildCampfire()
	{
		var entityTemplate : CEntityTemplate;
		var x, y, z, w, map : int;
		var position : Vector;
		
		position = virtual_parent.GetSafeCampfirePosition();
		position.Z = virtual_parent.GetCampfireZPosition(position);
		
		entityTemplate = (CEntityTemplate)LoadResource("environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
		
		Sleep(virtual_parent.CAMPFIRE_SPAWN_DELAY);
		virtual_parent.witcherCampfire = (W3Campfire)theGame.CreateEntity(entityTemplate, position);
		
		x = (int)(position.X * 100000);
		y = (int)(position.Y * 100000);
		z = (int)(position.Z * 100000);
		w = (int)(position.Z * 100000);
		
		BigFactSet("w3ee_fireplace_x", x);
		BigFactSet("w3ee_fireplace_y", y);
		BigFactSet("w3ee_fireplace_z", z);
		BigFactSet("w3ee_fireplace_w", w);
		map = theGame.GetCommonMapManager().GetCurrentArea();
		FactsSet("w3ee_fireplace_map", map);
		
		virtual_parent.PushState('Lit');
	}
}

state Destroyed in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		DestroyCampfire();
		if( prevStateName == 'Extinguished' || prevStateName == 'Spawned' )
			virtual_parent.PushState('Spawned');
	}
	
	private function DestroyCampfire()
	{
		virtual_parent.DestroyWitcherCampfire();
	}
}

state W3EEMeditation in W3PlayerWitcher extends MeditationBase
{
	private var campfireManager				: CWitcherCampfireManager;
	private var fastForwardSystem			: CGameFastForwardSystem;
	private var alchemyManager				: W3EEAlchemyExtender;
	private var shouldSpinCamera			: bool;	
	private var reduceCameraSpin			: bool;	
	private var spinReductionThreshold 		: float;
	private var saveLock					: int;	
	private var stateTimeSpent				: float;
	private var hoursPerMinute 				: float;
	private var animationDelay 				: float;
	private var meditatingTime 				: float;
	private var brewingTime 				: float;
	private var meditationTimeSpent 		: float;
	private var isMeditating, isBrewing		: bool;
	private var shouldMeditate, shouldBrew	: bool;
	private var isForcedMeditation			: bool;
	private var meditationTimeScale			: float;
	private var interactionPriority			: EInteractionPriority;
	
	private const var MEDITATION_ANIMATION_DELAY		: float;
	private const var FIRE_MEDITATION_ANIMATION_DELAY	: float;
	private const var MEDITATION_TIME_SCALE_MENU		: float;
	// private const var MEDITATION_TIME_SCALE				: float;
	private const var BREWING_TIME_SCALE				: float;
	private const var RESET_MEDITATION_TIME				: float;
	private const var RESTED_BUFF_TIME					: float;
	// private const var METABOLIC_BUFF_TIME				: float;
	
	default MEDITATION_ANIMATION_DELAY = 3.2f;
	default FIRE_MEDITATION_ANIMATION_DELAY = 7.2f;
	default MEDITATION_TIME_SCALE_MENU = 130.0f;
	// default MEDITATION_TIME_SCALE = 50.0f;
	default BREWING_TIME_SCALE = 30.0f;
	default RESET_MEDITATION_TIME = 6.0f;
	default RESTED_BUFF_TIME = 21600.0f;
	// default METABOLIC_BUFF_TIME = 3600.0f;
	
	timer function MeditationTutorial( dt : float, id : int )
	{
		theGame.GetTutorialSystem().uiHandler.GotoState('Meditation');
	}
	
	event OnEnterState( prevStateName : name )
	{
		alchemyManager = Alchemy();
		hoursPerMinute = theGame.GetHoursPerMinute();
		campfireManager = CampfireManager();
		
		super.OnEnterState(prevStateName);
		StartMeditationState();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		StopMeditationState();
		super.OnLeaveState(nextStateName);
	}	
	
	event OnPlayerTickTimer( dt : float )
	{
		super.OnPlayerTickTimer(dt);
		
		stateTimeSpent += dt;
		if( stateTimeSpent < animationDelay )
			return 0;
			
		//Kolaris - Injury Effects
		if( virtual_parent.GetStatPercents(BCS_Vitality) >= 0.999f )
			virtual_parent.GetInjuryManager().ClearInjuries();
			
		if( shouldBrew && !isBrewing )
			BeginBrewing();
		else
		if( !shouldBrew && isBrewing )
			EndBrewing();
			
		meditationTimeSpent = dt * 15;
		if( isMeditating )
		{
			if( !isForcedMeditation )
			{
				virtual_parent.UpdateEffectsAccelerated(dt * meditationTimeScale);
				meditationTimeSpent = dt * meditationTimeScale * 180;
			}
			else
			{
				virtual_parent.UpdateEffectsAccelerated(dt * MEDITATION_TIME_SCALE_MENU);
				meditationTimeSpent = dt * MEDITATION_TIME_SCALE_MENU * 180;
				
				if( meditatingTime <= 0 && isForcedMeditation )
					shouldMeditate = false;
				meditatingTime -= dt * MEDITATION_TIME_SCALE_MENU * 180;
			}
		}
		else
		if( isBrewing )
		{
			virtual_parent.UpdateEffectsAccelerated(dt * BREWING_TIME_SCALE);
			if( brewingTime <= 0 )
				shouldBrew = false;
			
			if( shouldBrew )
			{
				brewingTime -= dt * BREWING_TIME_SCALE * 60;
				return 0;
			}
		}
		
		if( shouldMeditate && !isMeditating )
			BeginMeditation();
		else
		if( !shouldMeditate && isMeditating )
			EndMeditation();
		
		ManageRestedBuff(meditationTimeSpent);
	}
	
	private entry function StartMeditationState()
	{
		var camera : CCustomCamera;
		
		fastForwardSystem = theGame.GetFastForwardSystem();
		shouldSpinCamera = false;
		reduceCameraSpin = false;
		meditationTimeScale = Options().GetMeditateTimeScale();
		interactionPriority = virtual_parent.GetInteractionPriority();
		
		//---=== modFriendlyHUD ===---
		if( GetFHUDConfig().enableMeditationModules )
		{
			ToggleMeditModules( true, "RealTimeMeditation" );
		}
		//---=== modFriendlyHUD ===---
		
		theGame.CreateNoSaveLock('W3EEMeditation', saveLock);
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		camera.SetAllowAutoRotation(true);
		if( Options().GetIsCameraLocked() )
			virtual_parent.EnableManualCameraControl(false, 'W3EEMeditation');
		else
			camera.SetAllowAutoRotation(false);
		virtual_parent.SetInteractionPriority(IP_Max_Unpushable);
		virtual_parent.HideUsableItem();
		
		ManagePlayerDisarm();
		//Kolaris - Oil Ability Fix
		ClearOilAbilities();
		BlockGameplayActions(true);
		ManagePlayerBehavior(campfireManager.ManageFire(virtual_parent.GetNoFireCall()));
		if( alchemyManager.GetBrewingInterrupted() && CanPerformAlchemy() )
		{
			alchemyManager.SetBrewingInterrupted(false);
			SetShouldBrew();
		}
		virtual_parent.AddTimer('MeditationTutorial', animationDelay, false);
	}
	
	private entry function StopMeditationState()
	{
		var camera : CCustomCamera;
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		camera.SetAllowAutoRotation(virtual_parent.GetAutoCameraCenter());
		virtual_parent.EnableManualCameraControl(true, 'W3EEMeditation');
		if( theGame.IsBlackscreenOrFading() )
			theGame.FadeInAsync(1.f);
			
		virtual_parent.SetNoFireCall(false);
		virtual_parent.SetInteractionPriority(interactionPriority);
		theGame.SetHoursPerMinute(hoursPerMinute);
		virtual_parent.LockEntryFunction(true);
		
		//---=== modFriendlyHUD ===---
		if( GetFHUDConfig().enableMeditationModules )
		{
			ToggleMeditModules( false, "RealTimeMeditation" );
		}
		//---=== modFriendlyHUD ===---
		
		if( stateTimeSpent < animationDelay )
			Sleep(animationDelay - stateTimeSpent);
		
		ManagePlayerBehavior(campfireManager.ManageFire(false));
		Sleep(MEDITATION_ANIMATION_DELAY * 0.6f);
		fastForwardSystem.AllowFastForwardSelfCompletion();
		if( brewingTime > 0 )
		{
			alchemyManager.SetBrewingInterrupted(true);
			alchemyManager.SetBrewingDuration(brewingTime);
		}
		
		stateTimeSpent = 0;
		meditationTimeSpent = 0;
		spinReductionThreshold = 0;
		shouldSpinCamera = false;
		reduceCameraSpin = false;
		
		BlockGameplayActions(false);
		BlockGameplayActionsAll(false);
		theGame.ReleaseNoSaveLock(saveLock);
		theGame.CloseMenu('MeditationClockMenu');
		virtual_parent.inMeditationMenu = false;
		virtual_parent.LockEntryFunction(false);
	}

	public function IsActivelyMeditating() : bool
	{
		return (isMeditating || isBrewing || shouldBrew || shouldMeditate || theGame.IsBlackscreenOrFading());
	}
	
	public function CanPerformAlchemy() : bool
	{
		return campfireManager.CanPerformAlchemy();
	}
	
	public function SetShouldBrew()
	{
		if( isMeditating || isBrewing || shouldBrew || shouldMeditate )
			return;
		
		shouldBrew = true;
	}
	
	public function SetShouldMeditate( meditate : bool )
	{
		if( (isMeditating || isBrewing || shouldBrew || shouldMeditate) && meditate )
			return;
		
		shouldMeditate = meditate;
	}
	
	public function SetShouldMeditateMenu( meditate : bool )
	{
		if( (isMeditating || isBrewing || shouldBrew || shouldMeditate) && meditate )
			return;
		
		isForcedMeditation = meditate;
		shouldMeditate = meditate;
	}
	
	private entry function BeginBrewing()
	{
		theGame.LockEntryFunction(true);
		fastForwardSystem.AllowFastForwardSelfCompletion();
		isBrewing = true;
		shouldSpinCamera = true;
		spinReductionThreshold = 0;
		brewingTime = alchemyManager.GetBrewingDuration();
		restedTimer += brewingTime; //Kolaris - Brewing Rested Buff
		
		BlockGameplayActionsAll(true);
		fastForwardSystem.BeginFastForward();
		theGame.SetHoursPerMinute(BREWING_TIME_SCALE);
		if( Options().GetShouldAlchemyFade() )
		{
			theGame.FadeOutAsync(1.f);
			Sleep(1.f);
		}
	}
	
	private entry function EndBrewing()
	{
		isBrewing = false;
		reduceCameraSpin = true;
		alchemyManager.ResetBrewingDuration();
		alchemyManager.FinishBrewing();
		
		BlockGameplayActionsAll(false);
		
		theGame.SetHoursPerMinute(hoursPerMinute);
		fastForwardSystem.AllowFastForwardSelfCompletion();
		if( Options().GetShouldAlchemyFade() )
		{
			theGame.FadeInAsync(1.5f);
			Sleep(1.5f);
		}
		theGame.LockEntryFunction(false);
	}

	private function BeginMeditation()
	{
		isMeditating = true;
		spinReductionThreshold = 0;
		theGame.SetTimeScale(3.f, theGame.GetTimescaleSource(ETS_Meditation), theGame.GetTimescalePriority(ETS_Meditation));
		if( isForcedMeditation )
		{
			shouldSpinCamera = true;
			BeginMenuMeditation();
		}
		else
		{
			shouldSpinCamera = false;
			reduceCameraSpin = false;
			
			fastForwardSystem.BeginFastForward();
			theGame.SetHoursPerMinute(meditationTimeScale);
		}
	}
	
	private function EndMeditation()
	{
		if( isForcedMeditation )
		{
			reduceCameraSpin = true;
			theSound.SoundEvent("gui_global_denied");
			BlockGameplayActionsAll(false);
		}
		
		isMeditating = false;
		isForcedMeditation = false;
		
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Meditation));
		theGame.SetHoursPerMinute(hoursPerMinute);
		fastForwardSystem.AllowFastForwardSelfCompletion();
	}
	
	private function BeginMenuMeditation()
	{
		var startTime, targetTime : GameTime;
		var targetHour : int;
		
		startTime = theGame.GetGameTime();
		targetHour = virtual_parent.GetWaitTargetHour();
		if( targetHour > GameTimeHours(startTime) )
			targetTime = GameTimeCreate(GameTimeDays(startTime), targetHour, 5, 0);
		else
			targetTime = GameTimeCreate(GameTimeDays(startTime) + 1, targetHour, 5, 0);
		
		BlockGameplayActionsAll(true);
		
		fastForwardSystem.BeginFastForward();
		theGame.SetHoursPerMinute(MEDITATION_TIME_SCALE_MENU);
		
		meditatingTime += (GameTimeToSeconds(targetTime) - GameTimeToSeconds(startTime));
	}
	
	private function ManagePlayerBehavior( mode : int ) : bool
	{
		switch(mode)
		{
			case -2:
				virtual_parent.SetBehaviorVariable('HasCampfire', 0.f);
				if( virtual_parent.GetPlayerAction() == PEA_Meditation )
					virtual_parent.PlayerStopAction(PEA_Meditation);
			return false;
			
			case -1:
				virtual_parent.SetBehaviorVariable('HasCampfire', 1.f);
				if( virtual_parent.GetPlayerAction() == PEA_Meditation )
					virtual_parent.PlayerStopAction(PEA_Meditation);
			return true;
			
			case  0:
				virtual_parent.SetBehaviorVariable('MeditateWithIgnite', 0.f);
				if( !virtual_parent.PlayerStartAction(PEA_Meditation) )
				{
					virtual_parent.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
					virtual_parent.PopState(true);
				}
				if( VecDistanceSquared( virtual_parent.GetWorldPosition(), virtual_parent.GetHorseWithInventory().GetWorldPosition() ) > 25 && !virtual_parent.IsInInterior() && campfireManager.IsAnyFireLit() && Options().GetWhistleAtFires() )
					theGame.OnSpawnPlayerHorse();
				animationDelay = MEDITATION_ANIMATION_DELAY;
			return false;
			
			
			case  1:
			case  2:
				virtual_parent.SetBehaviorVariable('MeditateWithIgnite', 1.f);
				if( !virtual_parent.PlayerStartAction(PEA_Meditation) )
				{
					virtual_parent.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
					virtual_parent.PopState(true);
				}
				if( VecDistanceSquared( virtual_parent.GetWorldPosition(), virtual_parent.GetHorseWithInventory().GetWorldPosition() ) > 25 && !virtual_parent.IsInInterior() && Options().GetWhistleAtFires() )
					theGame.OnSpawnPlayerHorse();
				animationDelay = FIRE_MEDITATION_ANIMATION_DELAY;
			return false;
		}
	}
	
	private function ManagePlayerDisarm()
	{
		if( virtual_parent.GetCurrentMeleeWeaponType() != PW_None )
			virtual_parent.OnEquipMeleeWeapon(PW_None, true, false);
			
		if( virtual_parent.IsHoldingItemInLHand() )
			virtual_parent.HideUsableItem(true);
			
		if( virtual_parent.rangedWeapon )
			virtual_parent.OnRangedForceHolster(true, true, false);
	}
	
	//Kolaris - Oil Ability Fix
	private function ClearOilAbilities()
	{
		virtual_parent.RemoveAbilityAll('CorrosiveOil_1');
		virtual_parent.RemoveAbilityAll('CorrosiveOil_2');
		virtual_parent.RemoveAbilityAll('CorrosiveOil_3');
		virtual_parent.RemoveAbilityAll('EtherealOil_1');
		virtual_parent.RemoveAbilityAll('EtherealOil_2');
		virtual_parent.RemoveAbilityAll('EtherealOil_3');
		virtual_parent.RemoveAbilityAll('BrownOil_1');
		virtual_parent.RemoveAbilityAll('BrownOil_2');
		virtual_parent.RemoveAbilityAll('BrownOil_3');
		virtual_parent.RemoveAbilityAll('PoisonousOil_1');
		virtual_parent.RemoveAbilityAll('PoisonousOil_2');
		virtual_parent.RemoveAbilityAll('PoisonousOil_3');
		virtual_parent.RemoveAbilityAll('FalkaOil_1');
		virtual_parent.RemoveAbilityAll('FalkaOil_2');
		virtual_parent.RemoveAbilityAll('FalkaOil_3');
		virtual_parent.RemoveAbilityAll('RimingOil_1');
		virtual_parent.RemoveAbilityAll('RimingOil_2');
		virtual_parent.RemoveAbilityAll('RimingOil_3');
		virtual_parent.RemoveAbilityAll('FlammableOil_1');
		virtual_parent.RemoveAbilityAll('FlammableOil_2');
		virtual_parent.RemoveAbilityAll('FlammableOil_3');
		virtual_parent.RemoveAbilityAll('ParalysisOil_1');
		virtual_parent.RemoveAbilityAll('ParalysisOil_2');
		virtual_parent.RemoveAbilityAll('ParalysisOil_3');
		virtual_parent.RemoveAbilityAll('SilverOil_1');
		virtual_parent.RemoveAbilityAll('SilverOil_2');
		virtual_parent.RemoveAbilityAll('SilverOil_3');
	}
	
	private function BlockGameplayActionsAll( lock : bool )
	{
		if( lock )
			virtual_parent.BlockAllActions('W3EEBrewing', true);
		else
			virtual_parent.BlockAllActions('W3EEBrewing', false);
	}
	
	private function BlockGameplayActions( lock : bool )
	{
		var exceptions : array< EInputActionBlock >;
		if ( lock )
		{
			exceptions.PushBack( EIAB_MeditationWaiting );
			exceptions.PushBack( EIAB_OpenFastMenu );
			exceptions.PushBack( EIAB_OpenInventory );
			exceptions.PushBack( EIAB_OpenAlchemy );
			exceptions.PushBack( EIAB_OpenCharacterPanel );
			exceptions.PushBack( EIAB_OpenJournal );
			exceptions.PushBack( EIAB_OpenMap );
			exceptions.PushBack( EIAB_OpenGlossary );
			exceptions.PushBack( EIAB_RadialMenu );
			exceptions.PushBack( EIAB_OpenMeditation );
			exceptions.PushBack( EIAB_QuickSlots );
			exceptions.PushBack( EIAB_CallHorse );
			virtual_parent.BlockAllActions('W3EEMeditation', true, exceptions);
		}	
		else virtual_parent.BlockAllActions('W3EEMeditation', false);
	}
	
	private function IsMeditationAllowed() : bool
	{
		return ( !theGame.IsBlackscreenOrFading() && virtual_parent.CanMeditateWait(true) && virtual_parent.CanPerformPlayerAction(true) );
	}
	
	private var restedTimer : float;
	private entry function ManageRestedBuff( dt : float )
	{
		restedTimer += dt;
		if( restedTimer >= RESTED_BUFF_TIME )
		{
			restedTimer = 0;
			if( CanPerformAlchemy() )
				virtual_parent.AddEffectDefault(EET_WellRested, virtual_parent, "Bed Buff");
		}
	}
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = thePlayer.GetWorldRotation();
		
		if( !shouldSpinCamera )		
		{
			RotateCamera(moveData, rotation, 180.0f, 0.4f/*0.25f*/, -15.0f);
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.0f, 11.2f, -11.5f, 0.f ), 2.5f, dt );
		}
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = moveData.pivotRotationValue;		
		var rotationSpeed : float = 0.6f;
		
		if( shouldSpinCamera )
		{
			if( reduceCameraSpin )
			{
				spinReductionThreshold += dt * 0.2625f;
				if( spinReductionThreshold > rotationSpeed )
				{
					spinReductionThreshold = 0;
					shouldSpinCamera = false;
					reduceCameraSpin = false;
				}
			}
			RotateCamera(moveData, rotation, 90.f, (rotationSpeed - spinReductionThreshold), (spinReductionThreshold * -35.0f) );
		}
	}
	
	private function RotateCamera( out moveData : SCameraMovementData, rotation : EulerAngles, angle, rotationSpeed, pitch : float ) : void
	{
		theGame.GetGameCamera().ChangePivotRotationController('Exploration');
		theGame.GetGameCamera().ChangePivotDistanceController('Default');
		theGame.GetGameCamera().ChangePivotPositionController('Default');
		
		moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
		moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
		moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
		
		moveData.pivotRotationController.SetDesiredHeading(rotation.Yaw + angle, rotationSpeed);
		moveData.pivotRotationController.SetDesiredPitch(pitch, 0.4);
		moveData.pivotPositionController.offsetZ = 0.5;
		moveData.pivotDistanceController.SetDesiredDistance(3.8);
	}
}

statemachine class W3EEAnimationManager extends CEntity
{
	public var usedSlot : EEquipmentSlots;
	public var usedItem, usedSword : SItemUniqueId;

	private var playerWitcher : W3PlayerWitcher;	
	public function Init( player : W3PlayerWitcher )
	{
		playerWitcher = player;
		GotoState('Idle');
	}
	
	public function IsAnimated() : bool
	{
		return GetCurrentStateName() == 'Animation';
	}
	
	public timer function StartAnimatedState( dt : float, id : int )
	{
		GotoState('Animation');
	}
	
	public function GetAnimatedState() : W3EEAnimationManagerStateAnimation
	{
		if( IsAnimated() )
		{
			return (W3EEAnimationManagerStateAnimation)GetState('Animation');
		}
		
		return NULL;
	}
	
	public function PerformAnimation( slot : EEquipmentSlots, itemID : SItemUniqueId, optional swordItem : SItemUniqueId ) : bool
	{
		if( playerWitcher.IsInAir() || playerWitcher.IsSwimming() )
		{
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_here"));
			theSound.SoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( GetCurrentStateName() == 'Animation' || playerWitcher.IsCurrentlyDodging() || playerWitcher.HasBuff(EET_Stagger) || playerWitcher.HasBuff(EET_LongStagger) || playerWitcher.HasBuff(EET_Knockdown) || playerWitcher.HasBuff(EET_HeavyKnockdown) )
		{
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
			theSound.SoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( playerWitcher.GetCurrentStateName() == 'HorseRiding' )
		{
			if( !(playerWitcher.inv.ItemHasTag(itemID, 'Potion') || playerWitcher.inv.ItemHasTag(itemID,'Edibles')) )
			{
				playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
				theSound.SoundEvent( "gui_global_denied" );
				return false;
			}
		}
		
		usedSlot = slot;
		usedItem = itemID;
		usedSword = swordItem;
		playerWitcher.AddTimer('StartAnimatedState', 0.05f, false);
		theGame.GetGuiManager().GetCommonMenu().CloseMenu();
		((CR4HudModuleRadialMenu)theGame.GetHud().GetHudModule("RadialMenuModule")).HideRadialMenu();
		return true;
	}
	
	public var savedContainer : W3Container;
    public function PerformLootingAnimation( container : W3Container ) : bool
    {
        var playerWitcher : W3PlayerWitcher = GetWitcherPlayer();
        if( playerWitcher.IsInAir() )
        {
            playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_here"));
            theSound.SoundEvent( "gui_global_denied" );
            return false;
        }
        
        if( GetCurrentStateName() == 'Animation' || playerWitcher.GetCurrentStateName() == 'HorseRiding' || playerWitcher.IsCurrentlyDodging() || playerWitcher.HasBuff(EET_Stagger) || playerWitcher.HasBuff(EET_LongStagger) || playerWitcher.HasBuff(EET_Knockdown) || playerWitcher.HasBuff(EET_HeavyKnockdown) )
        {
            playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
            theSound.SoundEvent( "gui_global_denied" );
            return false;
        }
		//Kolaris - LootTweak
        if( playerWitcher.IsSwimming() )
        {
            if( (W3Herb)container )
            {
                Equipment().LootHerb(container);
                return true;
            }
            return false;
        }
		if( (W3Herb)container )
		{
			if( !Options().GetUseHerbAnimation() )
			{
				Equipment().LootHerb(container);
				return false;
			}
		}
		else
		if( !Options().GetUseLootAnimation() )
		{
			return false;
		}
        
        savedContainer = container;
        playerWitcher.AddTimer('StartAnimatedState', 0.05f, false);
        return true;
    }
	
	public function ResetAnimData()
	{
		usedSlot = EES_InvalidSlot;
		usedItem = GetInvalidUniqueId();
		usedSword = usedItem;
		savedContainer = NULL;
	}
}

state Idle in W3EEAnimationManager
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

state Animation in W3EEAnimationManager
{
	private var playerWitcher			: W3PlayerWitcher;
	private var playerWeapon			: EPlayerWeapon;
	private var oiledWeapon				: EPlayerWeapon;
	private var usedItemSlot			: EEquipmentSlots;
	private var usedItem				: SItemUniqueId;
	private var swordItem				: SItemUniqueId;
	private var animName				: name;
	private var saveLock				: int;
	private var usingFood				: bool;
	private var usingOil				: bool;
	private var usingBandage			: bool;
	private var wasPlayerHit			: bool;
	private var wasHolstering			: bool;
	private var loopAnim				: bool;
	private var speedMultID				: int;
	private var lootAnimType			: int;
	
	private const var DRINK_ANIM_ACTIVATE_TIME : float;
	private const var DRINK_ANIM_FINISH_TIME : float;
	
	default DRINK_ANIM_ACTIVATE_TIME = 1.55f;
	default DRINK_ANIM_FINISH_TIME = 0.90f;

	private const var OIL_ANIM_ACTIVATE_TIME : float;
	private const var OIL_ANIM_HALF_TIME : float;
	private const var OIL_ANIM_FINISH_TIME : float;
	
	default OIL_ANIM_ACTIVATE_TIME = 1.85f;
	default OIL_ANIM_HALF_TIME = 0.9f;
	default OIL_ANIM_FINISH_TIME = 1.2f;
	
	private const var EAT_ANIM_ACTIVATE_TIME : float;
	private const var EAT_ANIM_FINISH_TIME : float;
	
	default EAT_ANIM_ACTIVATE_TIME = 1.55f;
	default EAT_ANIM_FINISH_TIME = 0.75f;
	
	private const var HERB_ANIM_START_TIME : float;
	private const var HERB_ANIM_PART1_TIME : float;
	private const var HERB_ANIM_PART2_TIME : float;
	
	default HERB_ANIM_START_TIME = 2.5f;
	default HERB_ANIM_PART1_TIME = 3.44f;
	default HERB_ANIM_PART2_TIME = 3.9f;
	
	private const var LOOT_ANIM_START_TIME_1 : float;
	private const var LOOT_ANIM_START_TIME_2 : float;
	private const var LOOT_ANIM_LOOP_TIME_1 : float;
	private const var LOOT_ANIM_LOOP_TIME_2 : float;
	private const var LOOT_ANIM_FINISH_TIME_1 : float;
	private const var LOOT_ANIM_FINISH_TIME_2 : float;
	
	default LOOT_ANIM_START_TIME_1 = 2.3f; // 2.4f;
	default LOOT_ANIM_START_TIME_2 = 0.8f;
	default LOOT_ANIM_LOOP_TIME_1 = 3.23f;
	default LOOT_ANIM_LOOP_TIME_2 = 4.06f;
	default LOOT_ANIM_FINISH_TIME_1 = 2.f;
	default LOOT_ANIM_FINISH_TIME_2 = 0.8f;
	
	private var error : int;
	event OnEnterState( prevStateName : name )
	{
		playerWitcher = GetWitcherPlayer();
		super.OnEnterState(prevStateName);
		
		SetConsumptionItem(virtual_parent.usedSlot, virtual_parent.usedItem, virtual_parent.usedSword);
		GetAnimationType();
		error = GetExceptions();
		if( !error || virtual_parent.savedContainer )
		{
			theGame.CreateNoSaveLock('W3EEAnimation', saveLock);
			if( usingBandage || usingOil || virtual_parent.savedContainer )
				playerWitcher.BlockAllActions('W3EEAnimation', true);
			else
				BlockActiveAnimationActions('W3EEAnimation');
			PerformAnimations();
			return true;
		}
		ShowErrorMessage(error);
		virtual_parent.GotoState('Idle');
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if( virtual_parent.savedContainer && !playerWitcher.GetWeaponHolster().IsOnTheMiddleOfHolstering() )
			playerWitcher.OnEquipMeleeWeapon(playerWeapon, false);
		
		virtual_parent.ResetAnimData();
		playerWeapon = PW_None;
		oiledWeapon = PW_None;
		wasPlayerHit = false;
		usingFood = false;
		usingOil = false;
		usingBandage = false;
		playerWitcher.BlockAllActions('W3EEAnimation', false);
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		theGame.ReleaseNoSaveLock(saveLock);
		
		super.OnLeaveState(nextStateName);
	}
	
	public function StopAnimationLoop()
	{
		loopAnim = false;
		if( lootAnimType == 0 || lootAnimType == 1 )
		{
			virtual_parent.LockEntryFunction(false);
			EndLootingAnimation();
		}
	}
	
	public function OnTakeDamage( action : W3DamageAction )
	{
		if( action.DealsAnyDamage() && !action.IsDoTDamage() )
		{
			wasPlayerHit = true;
			if( !usingOil && !virtual_parent.savedContainer )
				playerWitcher.RaiseForceEvent('ItemEndL');
			else
			{
				StopAnimationLoop();
				playerWitcher.PlayerStopAction(playerWitcher.GetPlayerAction());
				playerWitcher.LockEntryFunction(false);
				virtual_parent.GotoState('Idle');
			}
		}
	}
	
	private entry function PerformAnimations()
	{
		virtual_parent.LockEntryFunction(true);
		if( playerWitcher.IsWeaponHeld('silversword') )
			playerWeapon = PW_Silver;
		else
		if( playerWitcher.IsWeaponHeld('steelsword') )
			playerWeapon = PW_Steel;
			
		playerWitcher.OnRangedForceHolster(true, true);
		if( playerWitcher.RaiseEvent('ForcedUsableItemUnequip') )
			Sleep(0.3f);
		if( usingOil || virtual_parent.savedContainer || usingBandage )
			playerWitcher.OnEquipMeleeWeapon(oiledWeapon, true);	
			
		wasHolstering = false;
		while( usingOil && playerWitcher.GetWeaponHolster().IsOnTheMiddleOfHolstering() )
		{
			wasHolstering = true;
			Sleep(0.2f);
		}
		
		if( (W3Herb)virtual_parent.savedContainer )
			PerformHerbAnim();
		else
		if( (W3ActorRemains)virtual_parent.savedContainer )
			PerformBodyLootingAnim();
		else
		if( virtual_parent.savedContainer )
			PerformLootingAnim();
		else
		if( usingOil )
			PerformOilingAnim(animName);
		else
		if( usingFood )
			PerformEatingAnim(animName);
		else
		if( usingBandage )
			PerformBandageAnim();
		else
			PerformDrinkingAnim(animName);
	}
	
	private latent function PerformDrinkingAnim( animName : name )
	{
		var items : array<SItemUniqueId>;
		
		items = playerWitcher.inv.GetItemsByName(animName);
		if( !items.Size() )
			items = playerWitcher.inv.AddAnItem(animName, 1, true, true);
		playerWitcher.inv.MountItem(items[0], true);
		
		playerWitcher.SetBehaviorVariable('SelectedItemL', (int)UI_Horn, true);
		playerWitcher.RaiseEvent('ItemUseL');
		Sleep(DRINK_ANIM_ACTIVATE_TIME);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			Sleep(DRINK_ANIM_FINISH_TIME);
		}
		playerWitcher.inv.UnmountItem(items[0]);
		//playerWitcher.inv.RemoveItem(items[0], 1);
		Sleep(0.5f);
		virtual_parent.LockEntryFunction(false);
		virtual_parent.GotoState('Idle');
	}
	
	private latent function PerformEatingAnim( animName : name )
	{
		var items : array<SItemUniqueId>;
		
		items = playerWitcher.inv.GetItemsByName(animName);
		if( !items.Size() )
			items = playerWitcher.inv.AddAnItem(animName, 1, true, true);
		playerWitcher.inv.MountItem(items[0], true);
		
		playerWitcher.SetBehaviorVariable('SelectedItemL', (int)UI_Horn, true);
		playerWitcher.RaiseEvent('ItemUseL');
		Sleep(EAT_ANIM_ACTIVATE_TIME);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			Sleep(EAT_ANIM_FINISH_TIME);
		}
		playerWitcher.inv.UnmountItem(items[0]);
		//playerWitcher.inv.RemoveItem(items[0], 1);
		Sleep(0.5f);
		virtual_parent.LockEntryFunction(false);
		virtual_parent.GotoState('Idle');
	}
	
	private latent function PerformOilingAnim( animName : name )
	{
		if( wasHolstering )
			Sleep(0.8f);
		speedMultID = playerWitcher.SetAnimationSpeedMultiplier(0.4f, speedMultID);
		thePlayer.GetRootAnimatedComponent().PlaySlotAnimationAsync( animName, 'PLAYER_SLOT', SAnimatedComponentSlotAnimationSettings(0.25f, 0.2f));
		Sleep(OIL_ANIM_HALF_TIME);
		
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		Sleep(OIL_ANIM_ACTIVATE_TIME);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			
			Sleep(OIL_ANIM_FINISH_TIME);
		}
		virtual_parent.LockEntryFunction(false);
		virtual_parent.GotoState('Idle');
	}
	
	var herbAnim : EPlayerExplorationAction;
	private latent function PerformHerbAnim()
	{
		var animSpeed : float;
		var lootData : W3LootPopupData;
		var playerPos, containerPos, boxSize : Vector;
		
		herbAnim = PEA_None;
		lootAnimType = 0;
		playerWitcher.SetCustomRotation('LootingAnim', VecHeading(virtual_parent.savedContainer.GetWorldPosition() - playerWitcher.GetWorldPosition()), 360.f, 1.f, false);
		
		if( !wasPlayerHit )
		{
			loopAnim = true;
			animSpeed = 1.f;
			speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
			boxSize = GetBoxSize(((CMeshComponent)virtual_parent.savedContainer.GetComponentByClassName('CMeshComponent')).GetBoundingBox());
			playerPos = playerWitcher.GetWorldPosition();
			containerPos = virtual_parent.savedContainer.GetWorldPosition();
			
			if( containerPos.Z + boxSize.Z < playerPos.Z + 0.6f )
			{
				thePlayer.PlayerStartAction(PEA_InspectLow);
				herbAnim = PEA_InspectLow;
				Sleep(LOOT_ANIM_START_TIME_2 / animSpeed);
				lootData = new W3LootPopupData in virtual_parent.savedContainer;
				lootData.targetContainer = virtual_parent.savedContainer;
				theGame.RequestPopup('LootPopup', lootData);
			}
			else
			if( containerPos.Z + boxSize.Z > playerPos.Z + 0.6f && containerPos.Z + boxSize.Z < playerPos.Z + 1.6f )
			{
				animSpeed = 1.5f;
				speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
				playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_picking_up_herbs_start', 0.15f, 0.f);
				Sleep(HERB_ANIM_START_TIME / animSpeed);
				lootData = new W3LootPopupData in virtual_parent.savedContainer;
				lootData.targetContainer = virtual_parent.savedContainer;
				theGame.RequestPopup('LootPopup', lootData);
				while( loopAnim && !wasPlayerHit )
				{
					playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_picking_up_herbs_loop_01', 0.f, 0.f);
					Sleep(7.5f / animSpeed);
				}
			}
			else
			if( containerPos.Z + boxSize.Z > playerPos.Z + 1.6f )
			{
				thePlayer.PlayerStartAction(PEA_InspectHigh);
				herbAnim = PEA_InspectHigh;
				Sleep(LOOT_ANIM_START_TIME_2 / animSpeed);
				lootData = new W3LootPopupData in virtual_parent.savedContainer;
				lootData.targetContainer = virtual_parent.savedContainer;
				theGame.RequestPopup('LootPopup', lootData);
			}
		}
	}
	
	private latent function PerformBodyLootingAnim()
	{
		var animSpeed : float = 1.55f;
		var lootData : W3LootPopupData;
		
		lootAnimType = 1;
		playerWitcher.SetCustomRotation('LootingAnim', VecHeading(virtual_parent.savedContainer.GetWorldPosition() - playerWitcher.GetWorldPosition()), 360.f, 1.f, false);
		speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
		playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'work_kneeling_start', 1.55f, 0.f);
		Sleep(LOOT_ANIM_START_TIME_1 / animSpeed);
		
		if( !wasPlayerHit )
		{
			loopAnim = true;
			animSpeed = 0.5f;
			lootData = new W3LootPopupData in virtual_parent.savedContainer;
			lootData.targetContainer = virtual_parent.savedContainer;
			theGame.RequestPopup('LootPopup', lootData);
			speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
			while( loopAnim && !wasPlayerHit )
			{
				playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'work_kneeling_loop', 0.f, 0.f);
				Sleep(LOOT_ANIM_LOOP_TIME_1 / animSpeed);
			}
		}
	}
	
	private latent function PerformBandageAnim()
	{
		var animSpeed : float = 1.55f;
		var lootData : W3LootPopupData;
		var bleedingEffect : W3Effect_Bleeding;
		var counter : int; 
		
		counter = 0;
		
		lootAnimType = 1;
		speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
		playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'work_kneeling_start', 1.55f, 0.f);
		Sleep(LOOT_ANIM_START_TIME_1 / animSpeed);
		bleedingEffect = (W3Effect_Bleeding)thePlayer.GetBuff(EET_Bleeding);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			loopAnim = true;
			animSpeed = 0.5f;
			speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
			
			playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'work_kneeling_loop', 0.f, 0.f);
			Sleep(2.f);
			bleedingEffect.RemoveStack(3);
			//Kolaris - Bandage Injuries
			playerWitcher.GetInjuryManager().HealRandomInjury();
			StopAnimationLoop();
		}
	}
	
	private latent function PerformLootingAnim()
	{
		var animSpeed : float = 1.f;
		var lootData : W3LootPopupData;
		var playerPos, containerPos, boxSize : Vector;
		var anim : EPlayerExplorationAction;
		
		lootAnimType = 2;
		playerWitcher.SetCustomRotation('LootingAnim', VecHeading(virtual_parent.savedContainer.GetWorldPosition() - playerWitcher.GetWorldPosition()), 360.f, 1.f, false);
		if( !wasPlayerHit )
		{
			speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
			boxSize = GetBoxSize(((CMeshComponent)virtual_parent.savedContainer.GetComponentByClassName('CMeshComponent')).GetBoundingBox());
			playerPos = playerWitcher.GetWorldPosition();
			containerPos = virtual_parent.savedContainer.GetWorldPosition();
			
			if( containerPos.Z + boxSize.Z < playerPos.Z + 0.7f )
			{
				thePlayer.PlayerStartAction(PEA_InspectLow);
				anim = PEA_InspectLow;
			}
			else
			if( containerPos.Z + boxSize.Z > playerPos.Z + 0.7f && containerPos.Z + boxSize.Z < playerPos.Z + 1.6f )
			{
				thePlayer.PlayerStartAction(PEA_InspectMid);
				anim = PEA_InspectMid;
			}
			else
			if( containerPos.Z + boxSize.Z > playerPos.Z + 1.6f )
			{
				thePlayer.PlayerStartAction(PEA_InspectHigh);
				anim = PEA_InspectHigh;
			}
			
			Sleep(LOOT_ANIM_START_TIME_2 / animSpeed);
			if( !wasPlayerHit )
			{
				lootData = new W3LootPopupData in virtual_parent.savedContainer;
				lootData.targetContainer = virtual_parent.savedContainer;
				theGame.RequestPopup('LootPopup', lootData);
				
				animSpeed = 0.6f;
				speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
				loopAnim = true;
				while( loopAnim && !wasPlayerHit )
					Sleep(0.1f);
			}
		}
		
		if( !wasPlayerHit )
		{
			animSpeed = 0.8f;
			speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
			thePlayer.PlayerStopAction(anim);
			Sleep(LOOT_ANIM_FINISH_TIME_2 / animSpeed);
		}
		
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		virtual_parent.LockEntryFunction(false);
		virtual_parent.GotoState('Idle');
	}
	
	private entry function EndLootingAnimation()
	{
		var animSpeed : float;
		var item : array<SItemUniqueId>;
		
		virtual_parent.LockEntryFunction(true);
		if( lootAnimType == 0 )
		{
			if( herbAnim == PEA_None )
			{
				animSpeed = 2.f;
				if( !wasPlayerHit )
				{
					speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
					playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_picking_up_herbs_loop_03', 0.f, 50.f);
					Sleep(1.f);
				}
				item = playerWitcher.inv.GetItemsByName('herb_a');
				playerWitcher.inv.UnmountItem(item[0], true);
			}
			else
			{
				animSpeed = 0.8f;
				speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
				thePlayer.PlayerStopAction(herbAnim);
				Sleep(LOOT_ANIM_FINISH_TIME_2 / animSpeed);
			}
			playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
			virtual_parent.LockEntryFunction(false);
			virtual_parent.GotoState('Idle');
		}
		else
		if( lootAnimType == 1 )
		{
			animSpeed = 1.2f;
			if( !wasPlayerHit )
			{
				speedMultID = playerWitcher.SetAnimationSpeedMultiplier(animSpeed, speedMultID);
				playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'work_kneeling_end', 0.f, 2.55f);
				Sleep(LOOT_ANIM_FINISH_TIME_1 / animSpeed);
			}
			
			playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
			virtual_parent.LockEntryFunction(false);
			virtual_parent.GotoState('Idle');
		}
	}
	
	private function BlockActiveAnimationActions( sourceName : name )
	{
		var inputHandler : CPlayerInput = playerWitcher.GetInputHandler();
		var exceptions : array<EInputActionBlock>;
		
		if( inputHandler )
		{
			exceptions.PushBack(EIAB_ExplorationFocus);
			exceptions.PushBack(EIAB_DrawWeapon);
			exceptions.PushBack(EIAB_RadialMenu);
			exceptions.PushBack(EIAB_Movement);
			exceptions.PushBack(EIAB_HighlightObjective);
			exceptions.PushBack(EIAB_ExplorationFocus);
			exceptions.PushBack(EIAB_OpenFastMenu);
			exceptions.PushBack(EIAB_HardLock);
			exceptions.PushBack(EIAB_MeditationWaiting);
			exceptions.PushBack(EIAB_InteractionContainers);
			
			inputHandler.BlockAllActions(sourceName, true, exceptions);
		}
	}
	
	private function GetAnimationType()
	{
		lootAnimType = -1;
		if( playerWitcher.inv.GetItemCategory(swordItem) == 'steelsword' )
		{
			usingOil = true;
			oiledWeapon = PW_Steel;
			animName = 'man_work_sword_sharpening_02';
		}
		else
		if( playerWitcher.inv.GetItemCategory(swordItem) == 'silversword' )
		{
			usingOil = true;
			oiledWeapon = PW_Silver;
			animName = 'man_work_sword_sharpening_02';
		}
		else
		if( playerWitcher.inv.ItemHasTag(usedItem, 'Bandage') )
		{
			usingBandage = true;
			animName = 'deadbodyloot';
		}
		else
		if( !playerWitcher.inv.ItemHasTag(usedItem, 'Drinks') && playerWitcher.inv.ItemHasTag(usedItem,'Edibles') )
		{
			usingFood = true;
			animName = 'goods_apple';
		}
		else
		if( playerWitcher.inv.ItemHasTag(usedItem, 'Drinks') )
		{
			animName = 'PN_Bottle';
		}
		else
		{
			animName = 'PN_Potion';
		}
	}

	private function UseCachedItem()
	{
		if( playerWitcher.inv.ItemHasTag(usedItem, 'Potion') && playerWitcher.inv.ItemHasTag(usedItem, 'SingletonItem') )
			playerWitcher.DrinkPreparedPotion(usedItemSlot, usedItem);
		else
		if( usingBandage || usingFood || playerWitcher.inv.ItemHasTag(usedItem, 'Drinks') )
			playerWitcher.ConsumeItem(usedItem);
		else
		if( usingOil )
			playerWitcher.ApplyOilHack(usedItem, swordItem);
	}
	
	private function GetExceptions() : int
	{
		if( usedItem == GetInvalidUniqueId() )
			return 3;
		else
		if( !usingFood && !usingOil )
		{
			if( !playerWitcher.ToxicityLowEnoughToDrinkPotion(EES_InvalidSlot, usedItem) )
				return 1;		
		}
		else
		if( usingFood && playerWitcher.IsInCombat() )
			return 2;
		
		return 0;		
	}
	
	private function ShowErrorMessage(error : int)
	{
		var exceptionMessage : string;
		
		if( error == 1 )
		{
			exceptionMessage = GetLocStringByKeyExt("menu_cannot_perform_action_now") + " " + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity") +
			": " + (int)(playerWitcher.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(playerWitcher.abilityManager.GetStatMax(BCS_Toxicity));
			playerWitcher.DisplayHudMessage(exceptionMessage);
		}
		else
		if( error == 2 )
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
	}
	
	private function SetConsumptionItem( itemSlot : EEquipmentSlots, itemID : SItemUniqueId, swordID : SItemUniqueId )
	{
		usedItemSlot = itemSlot;
		swordItem = swordID;
		usedItem = itemID;
	}
}

exec function tryshit()
{
					thePlayer.PlayerStartAction( PEA_InspectLow );
}exec function tryshit2()
{
					thePlayer.PlayerStartAction( PEA_InspectMid );
}exec function tryshit3()
{
					thePlayer.PlayerStartAction( PEA_InspectHigh );
}