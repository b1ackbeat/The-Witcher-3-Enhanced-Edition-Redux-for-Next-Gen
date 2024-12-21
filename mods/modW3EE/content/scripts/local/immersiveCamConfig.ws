/* Immersive Cam Control Script v 4.0 */

class icControl
{
	/* ------ IMMERSIVE CAM CONFIGURATION START --------------------------------------------------	
	Edit the default values as desired, but remember that small changes make big differences.
	For some variables, only certain values are valid.  Those values are explained in the variable's comments.
	-------------------------------------------------------------------------------------------- */
	
	//--- FOV ---
	default expFOV 			= 60.0f;
	default hbFOV			= 60.0f;
	
	//--- HEADTRACKING ----
	default headTracking 	= true;		// true = headtracking ON | false = headtracking OFF
	
	// The following two settings are only used if headTracking = true
	default extHTDis 		= 4.0;		// Exterior look at radius  - The higher the number, the farther away people can be for Geralt to look at them.
	default intHTDis 		= 2.5;		// Interior look at radius	- The higher the number, the farther away people can be for Geralt to look at them.

	
	//--- CAMERA CONFIGURATIONS ---
	
	// Exploration Camera
	default expOffset 		= -0.7;		// increase = right   |  decrease = left  		( vanilla 0 ) 
	default expDepth 		= 2.15;		// increase = zoom in |  decrease = zoom out 	( vanilla 0 )
	default expHeight 		= 0.15;		// increase = higher  |  decrease = lower  		( vanilla 0 ) 
	
	// Interior Camera
	default noInteriorCamChange = true; // true = exploration cam does not change upon entering buildings 
	
	//The following interior camera settings are not used if noInteriorCamChange = true
	default intOffset 		= 0.3;		// increase = right   |  decrease = left		 ( vanilla 0.3 )
	default intDepth 		= 2.0;		// increase = zoom in |  decrease = zoom out	
	default intHeight 		= 0.2;		// increase to raise  |  decrease to lower		 ( vanilla 0.3 )
	
	// Sprinting Camera
	default sprintMode		= 0;		// 1 = sprint matches exploration, but slightly zoomed out
										// 2 = vanilla sprint cam (centered and zoomed out)
										// 3 = custom ( uses custom sprint values defined below )
	default sprintOffset	= 0.0;		// increase = right   |  decrease = left  		( vanilla 0 ) 
	default sprintDepth		= 0.0;		// increase = zoom in |  decrease = zoom out 	( vanilla 0 )
	default sprintHeight	= 0.0;		// increase = higher  |  decrease = lower  		( vanilla 0 )
	
	// Horseback Camera
	default hbDistance 		= 2.5;		// Walk and Trot Camera Distance - increase to zoom out | 	decrease to zoom in	 ( vanilla  2.4 )
	default hbCanterDis 	= 2.5;		// Canter Camera Distance - increase to zoom out | 	decrease to zoom in
	default hbGallopDis 	= 2.5;		// Gallop Camera Distance - increase to zoom out | 	decrease to zoom in
	default hbCombatDis 	= 2.8;		// Combat Camera Distance - increase to zoom out | 	decrease to zoom in
	
	default hbOffset 		= 0.0;		// increase = right   |  decrease = left  		( vanilla 0 ) 
	default hbDepth 		= 0.0;		// increase = zoom in |  decrease = zoom out 	( vanilla 0 )
	default hbHeight 		= 0.0;		// increase = higher  |  decrease = lower  		( vanilla 0 )
	
	// Sailing Camera
	default sailOffset = 	0.2;		// increase = right   |  decrease = left  	(Vanilla 0)	
	default sailDepth  = 	1.9;		// increase = closer  |  decrease = farther (Vanilla 0)
	default sailHeight = 	0.3;		// increase = higher  |  decrease = lower  	(Vanilla 0)
	default sailPitch  =	25.0;		// The higher the value, the farther the camera can be tilted skywards.
	
	// Witcher Sense Cameras 
	default witcherSenseZoom = true; // Setting this to false will disable Witcher Sense camera zoom 
	
	//The following Witcher Sense camera settings are only used if noWitcherSenseZoom = false
	// Exterior Witcher Sense Camera 
	default eWSOffset 		= 0.25;		// increase = right   |  decrease = left		( vanilla  0.5 )	
	default eWSDepth 		= 1.8;		// increase = zoom in |  decrease = zoom out	( vanilla  2.0 )
	default eWSHeight 		= 0.35;		// increase = higher  |  decrease = lower		( vanilla  0.3 )
	
	// Interior Witcher Sense Camera 
	default iWSOffset		= 0.30;		// increase = right   |  decrease = left		( vanilla  0.5 )				
	default iWSDepth 		= 2.15;		// increase = zoom in |  decrease = zoom out	( vanilla  2.3 )
	default iWSHeight 		= 0.25;		// increase = higher  |  decrease = lower		( vanilla  0.5 )

	// Clue Investigation Camera
	default clueOffset		= 0.6;		// increase = right   |  decrease = left		( vanilla  0.7 )
	default clueDepth		= 4.0;		// increase = zoom in |  decrease = zoom out	( vanilla  0.0 )
	default clueHeight		= -1.5;		// increase = higher  |  decrease = lower		( vanilla  0.0 )
	
	// Combat Camera 
	default comLock			= true;	// true = camera doesn't zoom in and out during combat - false = vanilla combat camera movements
	default comOffset		= 0.3;		// increase = right   |  decrease = left  		( vanilla 0 )	
	default comDepth 		= 1.3;		// increase = zoom in |  decrease = zoom out	( vanilla 0 )
	default comHeight 		= 0.0;		// increase = higher  |  decrease = lower  		( vanilla 0 )
	default hlOffset		= 0.6;		// increase = right   |  decrease = left  		( hard-lock / vanilla 0 )	
	default hlDepth 		= 4.0;		// increase = zoom in |  decrease = zoom out	( hard-lock / vanilla 0 )
	default hlHeight 		= 0.0;		// increase = higher  |  decrease = lower  		( hard-lock / vanilla 0 )
	
	// Aim/Throw Camera  
	/* If atRotate is set to true, Geralt will auto rotate to the camera facing.  
	This looks odd when the cam is zoomed out far enough to see his legs. */
	   
	default atRotate 		= true;	// ( vanilla  true )
	default atOffset		= 0.43;		// increase = right   |  decrease = left  		( vanilla 0.43 )	
	default atDepth 		= 0.52;		// increase = zoom in |  decrease = zoom out	( vanilla 0.52 )
	default atHeight 		= 0.22;		// increase = higher  |  decrease = lower  		( vanilla 0.22 )
	
	// Igni Firestream Camera 
	default fsOffset		= 0.95;		// increase = right   |  decrease = left  		( vanilla 0.65 )	
	default fsDepth 		= -0.5;		// increase = zoom in |  decrease = zoom out	( vanilla 1.8 )
	default fsHeight 		= 0;		// increase = higher  |  decrease = lower  		( vanilla 0.4 )
	
	/* ---- IMMERSIVE CAM CONFIGURATION END (DO NOT CHANGE ANYTHING BELOW THIS LINE) -----    */
	
	////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////
	
	private var attackAction 				: W3Action_Attack;
	private var weaponId					: SItemUniqueId;
	private var actorAttacker 				: CActor;
	private var playerAttacker				: CR4Player;
	private var actorVictim 				: CActor;	

	public  var aardSlowMoFactor 			: float;
	public  var igniSlowMoFactor 			: float;
	private var dodgeRollSlowMoFactor 		: float;
	private var evadeStepSlowMoFactor 		: float;
	private var counterAttackSlowMoFactor 	: float;
	private var criticalHitSlowMoFactor		: float;
	private var dismemberSlowMoFactor		: float;
	
	private var criticalHitSlowMoChance		: Int32;
	
	private var rolling 					: string;
	private var evading 					: string;
	private var counterattack 				: string;
	private var criticalhit 				: string;
	private var dismember					: string;
	
	public var inputAdj						: float;
	
	public var headTracking, critSloMoCam, witcherSenseZoom 								: bool;
	public var noInteriorCamChange, comLock													: bool;
	public var useCampfire, medFreeCam														: bool;
	public var extHTDis, intHTDis															: float;
	public var expFOV, hbFOV, sprintFOV														: float;
	public var expOffset, expDepth, expHeight 												: float;
	public var comOffset, comDepth, comHeight 												: float;
	public var hlOffset, hlDepth, hlHeight 													: float;
	public var intOffset, intDepth, intHeight 												: float;
	public var hbDistance, hbCanterDis, hbGallopDis, hbCombatDis, hbAutoRot 				: float;
	public var hbOffset, hbDepth, hbHeight 													: float;
	public var eWSOffset, eWSDepth, eWSHeight, iWSOffset, iWSDepth, iWSHeight 				: float;
	public var clueOffset, clueDepth, clueHeight											: float;
	public var atRotate, fsRotate															: bool;	
	public var sailOffset, sailDepth, sailHeight, sailPitch									: float;
	public var atOffset, atDepth, atHeight, fsOffset, fsDepth, fsHeight 					: float;
	public var medOffset, medDepth, medHeight, medRotSpeed, medPitch, medEndFacing, medHPS	: float;
	public var sprintMode, sprintOffset, sprintDepth, sprintHeight							: float;
	
	private var igconfig					: CInGameConfigWrapper;
	
	/* Immersive Cam functions */
	
	private function InitializeMenuSettings()
	{
		igconfig = theGame.GetInGameConfigWrapper();
		
	}

	public function SetImmCamVars()
	{
		inputAdj = 	StringToFloat( igconfig.GetVarValue( 'ImmMotion', 'InputAdj' ) );
		headTracking = igconfig.GetVarValue('HT', 'Headtracking');
		critSloMoCam = igconfig.GetVarValue('SlowMotionCam', 'CritSloMoCam');
		witcherSenseZoom = igconfig.GetVarValue('ImmersiveCamPositionsWS', 'WitcherSenseZoom');
		noInteriorCamChange = igconfig.GetVarValue('ImmersiveCamPositionsExploration', 'noInteriorCamChange');
		extHTDis = StringToFloat( igconfig.GetVarValue( 'HT', 'extHTDis' ) );
		intHTDis = StringToFloat( igconfig.GetVarValue( 'HT', 'intHTDis' ) );
		expFOV = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expFOV' ) );
		hbFOV = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbFOV' ) );
		sprintFOV = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'sprintFOV' ) );
		expOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expOffset' ) );
		expDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expDepth' ) );
		expHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expHeight' ) );
		intDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'intDepth' ) );
		intOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'intOffset' ) );
		intHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'intHeight' ) );
		sprintMode = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsSprint', 'sprintMode') ) + 1;
		sprintOffset = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsSprint', 'sprintOffset') );
		sprintDepth = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsSprint', 'sprintDepth') );
		sprintHeight = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsSprint', 'sprintHeight') );
		hbDistance = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbDistance' ) );
		hbCanterDis = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbCanterDis' ) );
		hbGallopDis = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbGallopDis' ) );
		hbCombatDis = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbCombatDis' ) );
		hbOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbOffset' ) );
		hbDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbDepth' ) );
		hbHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsHorse', 'hbHeight' ) );
		sailPitch = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsSailing', 'sailPitch' ) );
		sailOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsSailing', 'sailOffset' ) );
		sailDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsSailing', 'sailDepth' ) );
		sailHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsSailing', 'sailHeight' ) );
		eWSOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsWS', 'eWSOffset' ) );
		eWSDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsWS', 'eWSDepth' ) );
		eWSHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsWS', 'eWSHeight' ) );
		iWSOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsWS', 'iWSOffset' ) );
		iWSDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsWS', 'iWSDepth' ) );
		iWSHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsWS', 'iWSHeight' ) );
		clueOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsClue', 'clueOffset' ) );
		clueDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsClue', 'clueDepth' ) );
		clueHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsClue', 'clueHeight' ) );
		comLock = igconfig.GetVarValue('ImmersiveCamPositionsCombat', 'comLock');
		comOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsCombat', 'comOffset' ) );
		comDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsCombat', 'comDepth' ) );
		comHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsCombat', 'comHeight' ) );
		hlOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsCombat', 'hlOffset' ) );
		hlDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsCombat', 'hlDepth' ) );
		hlHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsCombat', 'hlHeight' ) );
		atRotate = igconfig.GetVarValue('ImmersiveCamPositionsAT', 'atRotate');
		atOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsAT', 'atOffset' ) );
		atDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsAT', 'atDepth' ) );
		atHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsAT', 'atHeight' ) );
		fsOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsFS', 'fsOffset' ) );
		fsDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsFS', 'fsDepth' ) );
		fsHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsFS', 'fsHeight' ) );
		criticalHitSlowMoChance = StringToInt( igconfig.GetVarValue( 'SlowMotionCam', 'criticalHitSlowMoChance' ) );
		aardSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'aardSlowMoFactor' ) );
		igniSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'igniSlowMoFactor' ) );
		dodgeRollSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'dodgeRollSlowMoFactor' ) );
		evadeStepSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'evadeStepSlowMoFactor' ) );
		counterAttackSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'counterAttackSlowMoFactor' ) );
		criticalHitSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'criticalHitSlowMoFactor' ) );
		dismemberSlowMoFactor = StringToFloat( igconfig.GetVarValue( 'SlowMotionCam', 'dismemberSlowMoFactor' ) );
	}
	
	public function RegisterImmCamVars( init : bool )  
	{
		if( !igconfig )
			igconfig = theGame.GetInGameConfigWrapper();
			
		if ( init )
			SetImmCamVars();
		else
			thePlayer.AddTimer('SetImmCamVars', 0.5, false);
	}
	
	private function RegisterImmCamInputs()
	{	
		theInput.RegisterListener( this, 'OnCamOffsetDecrease', 'CamOffsetDecrease' );
		theInput.RegisterListener( this, 'OnCamOffsetIncrease', 'CamOffsetIncrease' );
		theInput.RegisterListener( this, 'OnCamDepthDecrease', 'CamDepthDecrease' );
		theInput.RegisterListener( this, 'OnCamDepthIncrease', 'CamDepthIncrease' );
		theInput.RegisterListener( this, 'OnCamHeightDecrease', 'CamHeightDecrease' );
		theInput.RegisterListener( this, 'OnCamHeightIncrease', 'CamHeightIncrease' );
		theInput.RegisterListener( this, 'OnCamReset', 'CamReset' );
		theInput.RegisterListener( this, 'OnCamSet', 'CamSet' );
	}
	
	public function icInit()
	{
		RegisterImmCamInputs();
		RegisterImmCamVars( true );
	}
	
	event OnCamReset ( action : SInputAction )
	{
		if( thePlayer.GetCurrentStateName() == 'HorseRiding' )
			thePlayer.ResetHBCam();
		else if( thePlayer.IsInCombat() )
			thePlayer.ResetComCam();
		else
			thePlayer.ResetExpCam();
	}
	
	event OnCamSet ( action : SInputAction )
	{
		if( thePlayer.GetCurrentStateName() == 'HorseRiding' )
			thePlayer.SetHBCam();
		else if( thePlayer.IsInCombat() )
			thePlayer.SetComCam();
		else
			thePlayer.SetExpCam();
	}
}