/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
enum EMutationFeedbackType
{
	MFT_PlayHide,
	MFT_PlayOnce,
	MFT_PlayRepeat
	
}
	
class CR4HudModuleWolfHead extends CR4HudModuleBase
{
	
	private	var m_fxSetVitality						: CScriptedFlashFunction;
	private	var m_fxSetStamina						: CScriptedFlashFunction;
	private	var m_fxSetToxicity						: CScriptedFlashFunction;
	private	var m_fxSetExperience					: CScriptedFlashFunction;
	private	var m_fxSetLockedToxicity				: CScriptedFlashFunction;
	private	var m_fxSetDeadlyToxicity				: CScriptedFlashFunction;
	private	var m_fxShowStaminaNeeded				: CScriptedFlashFunction;
	private	var m_fxSwitchWolfActivation			: CScriptedFlashFunction;
	private var m_fxSetSignIconSFF					: CScriptedFlashFunction;
	private var m_fxSetSignTextSFF					: CScriptedFlashFunction;
	private var m_fxSetFocusPointsSFF				: CScriptedFlashFunction;
	private var	m_fxSetFocusProgressSFF				: CScriptedFlashFunction;
	private var m_fxLockFocusPointsSFF				: CScriptedFlashFunction;	
	private var m_fxSetCiriAsMainCharacter			: CScriptedFlashFunction;
	private var m_fxSetCoatOfArms					: CScriptedFlashFunction;
	private var m_fxSetShowNewLevelIndicator		: CScriptedFlashFunction;
	private var m_fxSetAlwaysDisplayed				: CScriptedFlashFunction;
	private var m_fxshowMutationFeedback			: CScriptedFlashFunction;
	private var m_fxSetSignIconDimmed			: CScriptedFlashFunction;
	
	private var swordSprite : CScriptedFlashSprite;
	
	private	var	m_LastVitality				: float;
	private	var	m_LastMaxVitality			: float;
	private	var	m_LastStamina				: float;	
	private	var	m_LastMaxStamina			: float;	
	private	var	m_LastExperience			: float;	
	private	var	m_LastMaxExperience			: float;
	private	var	m_LastToxicity				: float;
	private	var	m_LastLockedToxicity		: float;
	private	var	m_LastMaxToxicity			: float;
	private	var	m_bLastDeadlyToxicity		: bool;
	private	var	m_medallionActivated		: bool;
	private var m_oveloadedIconVisible		: bool;
	private var m_focusPoints				: int;
	private var m_focusProgress				: float;
	private var m_iCurrentPositiveEffectsSize : int;
	private var m_iCurrentNegativeEffectsSize : int;
	private var m_signIconName 				: string;
	private var m_CurrentSelectedSign 		: ESignType;
	private var m_IsPlayerCiri				: bool;
	
	private var m_curToxicity				: float;
	private var m_lockedToxicity			: float;
	private var m_curVitality				: float;
	private var m_maxVitality				: float;
	private var m_bForceToxicityUpdate		: bool;
	//---=== modFriendlyHUD ===---		
	private var m_lastUpdateTimeVitality	: float;
	private var m_lastUpdateTimeStamina		: float;
	private var m_lastUpdateVitality		: float;
	private var m_lastUpdateStamina			: float;
	//---=== modFriendlyHUD ===---
		
		
		
	default m_iCurrentPositiveEffectsSize = 0;
	default m_iCurrentNegativeEffectsSize = 0;
	default m_IsPlayerCiri				  = false;
	default m_bForceToxicityUpdate		  = false;

	event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorWolfHead";
		
		super.OnConfigUI();
		
		flashModule = GetModuleFlash();
		
		m_fxSetSignIconDimmed				= flashModule.GetMemberFlashFunction( "setSignIconDimmed" );
		m_fxSetVitality						= flashModule.GetMemberFlashFunction( "setVitality" );
		m_fxSetStamina						= flashModule.GetMemberFlashFunction( "setStamina" );
		m_fxSetToxicity						= flashModule.GetMemberFlashFunction( "setToxicity" );
		m_fxSetExperience					= flashModule.GetMemberFlashFunction( "setExperience" );
		m_fxSetLockedToxicity				= flashModule.GetMemberFlashFunction( "setLockedToxicity" );
		m_fxSetDeadlyToxicity				= flashModule.GetMemberFlashFunction( "setDeadlyToxicity" );
		m_fxShowStaminaNeeded				= flashModule.GetMemberFlashFunction( "showStaminaNeeded" );
		m_fxSwitchWolfActivation			= flashModule.GetMemberFlashFunction( "switchWolfActivation" );
		m_fxSetSignIconSFF 					= flashModule.GetMemberFlashFunction( "setSignIcon" );
		m_fxSetSignTextSFF 					= flashModule.GetMemberFlashFunction( "setSignText" );
		m_fxSetFocusPointsSFF				= flashModule.GetMemberFlashFunction( "setFocusPoints" );
		m_fxSetFocusProgressSFF				= flashModule.GetMemberFlashFunction( "UpdateFocusPointsBar" );
		m_fxLockFocusPointsSFF				= flashModule.GetMemberFlashFunction( "lockFocusPoints" );
		m_fxSetCiriAsMainCharacter			= flashModule.GetMemberFlashFunction( "setCiriAsMainCharacter" );
		m_fxSetCoatOfArms					= flashModule.GetMemberFlashFunction( "setCoatOfArms" );
		m_fxSetShowNewLevelIndicator		= flashModule.GetMemberFlashFunction( "setShowNewLevelIndicator" );
		m_fxSetAlwaysDisplayed				= flashModule.GetMemberFlashFunction( "setAlwaysDisplayed" );
		m_fxshowMutationFeedback			= flashModule.GetMemberFlashFunction( "showMutationFeedback" );
		
		m_CurrentSelectedSign = thePlayer.GetEquippedSign();
		m_fxSetSignIconSFF.InvokeSelfOneArg(FlashArgString(GetSignIcon()));
		
		// W3EE - Begin
		LockFocusPoints(3);
		// W3EE - End
		SetTickInterval( 0.5 );
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('WolfMedalion', true);
		}
		DisplayNewLevelIndicator();
		
		UpdateCoatOfArms();
	}
	
	public function DisplayMutationFeedback( value : EMutationFeedbackType )
	{
		m_fxshowMutationFeedback.InvokeSelfOneArg(FlashArgInt( value ));
	}
	
	function DisplayNewLevelIndicator()
	{
		/*var levelManager : W3LevelManager;
		levelManager = GetWitcherPlayer().levelManager;
		if( levelManager.GetPointsFree(ESkillPoint) > 0)
		{
			if( !thePlayer.IsCiri() )
			{
				m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(true));
			}
			else
			{
				m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(false));
			}
		}
		else
		{*/
			m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(false));
		//}
	}

	event OnTick( timeDelta : float )
	{
		//modFriendlyHUD begin
		if( isFadingOut || IsVisibleTemporarily() )
		{
			SetAlwaysDisplayed( true );
			UpdateFadeOut( timeDelta );
		}
		//modFriendlyHUD end
		
		UpdateVitality();
		UpdateStamina();
		UpdateToxicity();
		UpdateSignData();
		// W3EE - Begin
		UpdateFocusPoints();
		UpdateExperience();
		// W3EE - End
		
		if ( !CanTick( timeDelta ) )
		{
			return true;
		}
		
		UpdateMedallion();
		//UpdateFocusPoints();
		UpdateStateByPlayer();
		
		// W3EE - Begin
		if ( isFadingOut || IsVisibleTemporarily() || thePlayer.IsCombatMusicEnabled() /*|| (m_curToxicity > 0.f || m_lockedToxicity > 0.f)*/ || (thePlayer.GetStatPercents(BCS_Vitality) < 0.999f) || thePlayer.GetStat(BCS_Focus) < thePlayer.GetStatMax(BCS_Focus) || thePlayer.GetStat(BCS_Stamina) < thePlayer.GetStatMax(BCS_Stamina) || thePlayer.GetPoiseEffect().GetCurrentPoise() < thePlayer.GetPoiseEffect().GetMaxPoise() )
		// W3EE - End
			SetAlwaysDisplayed( true );
		else
			SetAlwaysDisplayed( false );	
	}

	public function UpdateVitality() : void
	{
		var l_currentVitality 		: float;
		var l_currentMaxVitality 	: float;
		//---=== modFriendlyHUD ===---
		var l_timeDelta				: float;
		var l_vitalityDelta			: float;
		var l_staminaDelta			: float;
		//---=== modFriendlyHUD ===---
		
		thePlayer.GetStats( BCS_Vitality, l_currentVitality, l_currentMaxVitality );

		m_curVitality = l_currentVitality;
		m_maxVitality = l_currentMaxVitality;

		//---=== modFriendlyHUD ===---
		l_timeDelta = theGame.GetEngineTimeAsSeconds() - m_lastUpdateTimeVitality;
		if( GetFHUDConfig().enableWolfModuleOnVitalityChanged && l_timeDelta >= 0.5 && m_LastVitality != 0 )
		{
			l_vitalityDelta = GetFHUDConfig().vitalityRiseThreshold * l_timeDelta;
			if ( ( CeilF( l_currentVitality ) < m_lastUpdateVitality || l_currentVitality > m_lastUpdateVitality + l_vitalityDelta ) && m_lastUpdateVitality != 0 )
			{
				thePlayer.RemoveTimer( 'DamageOffTimer' );
				ToggleHUDModule( "WolfHeadModule", true, "OnDamage" );
				thePlayer.AddTimer( 'DamageOffTimer' , 3.0, false );
			}
			m_lastUpdateTimeVitality = theGame.GetEngineTimeAsSeconds();
			m_lastUpdateVitality = l_currentVitality;
		}
		//---=== modFriendlyHUD ===---
		
		if( l_currentVitality != m_LastVitality ||  l_currentMaxVitality != m_LastMaxVitality )
		{
			
			m_fxSetVitality.InvokeSelfOneArg( FlashArgNumber(  l_currentVitality / l_currentMaxVitality ) );
			m_LastVitality = l_currentVitality;
			m_LastMaxVitality = l_currentMaxVitality;
		}
	}
	
	private var playStaminaSoundCue : bool;
	private var isStaminaSoundPlaying : bool;
	public function UpdateStamina() : void
	{
		var l_curStamina 				: float;
		var l_curMaxStamina 			: float;
		var l_tooLowStaminaIndication 	: float = thePlayer.GetShowToLowStaminaIndication();
		//---=== modFriendlyHUD ===---
		var l_timeDelta				: float;
		var l_staminaDelta			: float;
		//---=== modFriendlyHUD ===---
		
		thePlayer.GetStats( BCS_Stamina, l_curStamina, l_curMaxStamina );
		if( m_LastStamina != l_curStamina || m_LastMaxStamina != l_curMaxStamina )
		{
			m_fxSetStamina.InvokeSelfOneArg( FlashArgNumber ( l_curStamina / l_curMaxStamina ) );
			
			m_LastStamina 	 = l_curStamina;
			m_LastMaxStamina = l_curMaxStamina;
			
			//---=== modFriendlyHUD ===---
			l_timeDelta = theGame.GetEngineTimeAsSeconds() - m_lastUpdateTimeStamina;
			if( GetFHUDConfig().enableWolfModuleOnStaminaChanged && l_timeDelta >= 0.5 && m_LastStamina != 0 )
			{
				l_staminaDelta = GetFHUDConfig().staminaRiseThreshold * l_timeDelta;
				if ( ( CeilF( l_curStamina ) < m_lastUpdateStamina || l_curStamina > m_lastUpdateStamina + l_staminaDelta ) && m_lastUpdateStamina != 0 )
				{
					thePlayer.RemoveTimer( 'DamageOffTimer' );
					ToggleHUDModule( "WolfHeadModule", true, "OnDamage" );
					thePlayer.AddTimer( 'DamageOffTimer' , 3.0, false );
				}
				m_lastUpdateTimeStamina = theGame.GetEngineTimeAsSeconds();
				m_lastUpdateStamina = l_curStamina;
			}
			//---=== modFriendlyHUD ===---
			
			if ( l_curStamina <= l_curMaxStamina * 0.60f ) 
				playStaminaSoundCue = true;
				
			if ( !isStaminaSoundPlaying && l_curStamina <= l_curMaxStamina * 0.5f && !thePlayer.IsCiri() )
			{
				isStaminaSoundPlaying = true;
				if( !theSound.SoundIsBankLoaded("heartloop.bnk") )
					theSound.SoundLoadBank("heartloop.bnk", false);
					
				theSound.SoundEvent("play_heartloop");
			}
			else
			if( isStaminaSoundPlaying )
			{
				theSound.SoundParameter("heartloop_rate", (1.f - l_curStamina / l_curMaxStamina / 0.5f) * 100.f);
				if( l_curStamina > l_curMaxStamina * 0.5f )
				{
					isStaminaSoundPlaying = false;
					if( !theSound.SoundIsBankLoaded("heartloop.bnk") )
						theSound.SoundLoadBank("heartloop.bnk", false);
						
					theSound.SoundEvent("stop_heartloop");
				}
			}
			
			if ( l_curStamina <= 0 && l_tooLowStaminaIndication <= 0 )
			{
				thePlayer.SoundEvent("gui_no_stamina");
				theGame.VibrateControllerVeryLight(); 
			}
			else if ( l_curStamina >= l_curMaxStamina && playStaminaSoundCue )
			{
				thePlayer.SoundEvent("gui_stamina_recharged");
				theGame.VibrateControllerVeryLight(); 
				playStaminaSoundCue = false;
			}
		}
		
		if( l_tooLowStaminaIndication > 0 )
		{
			m_fxShowStaminaNeeded.InvokeSelfOneArg( FlashArgNumber ( l_tooLowStaminaIndication / l_curMaxStamina ) );
			thePlayer.SetShowToLowStaminaIndication( 0 );
			thePlayer.SoundEvent("gui_no_stamina");
			theGame.VibrateControllerVeryLight(); 
		}
	}

	public function UpdateToxicity() : void
	{
		var curToxicity 	: float;	
		var curMaxToxicity 	: float;
		var curLockedToxicity: float;
		var damageThreshold	: float;
		var curDeadlyToxicity : bool;
		
		thePlayer.GetStats( BCS_Toxicity, curToxicity, curMaxToxicity );
		
		curLockedToxicity = thePlayer.GetStat(BCS_Toxicity) - curToxicity;
		
		
		m_curToxicity = curToxicity;
		m_lockedToxicity = curLockedToxicity;
		
		if ( m_bForceToxicityUpdate || m_LastToxicity != curToxicity || m_LastMaxToxicity != curMaxToxicity || m_LastLockedToxicity != curLockedToxicity )
		{
			
			if( m_bForceToxicityUpdate || m_LastLockedToxicity != curLockedToxicity || m_LastMaxToxicity != curMaxToxicity)
			{
				m_fxSetLockedToxicity.InvokeSelfOneArg( FlashArgNumber( ( curLockedToxicity )/ curMaxToxicity ) );
				m_LastLockedToxicity = curLockedToxicity;
			}
			m_fxSetToxicity.InvokeSelfOneArg( FlashArgNumber( ( curToxicity + m_LastLockedToxicity )/ curMaxToxicity ) );
			//Kolaris - Toxicity Rework
			curDeadlyToxicity = ( curToxicity > m_LastToxicity );
			m_LastToxicity 	= curToxicity;
			m_LastMaxToxicity = curMaxToxicity;
			
			damageThreshold = GetWitcherPlayer().GetToxicityDamageThreshold();
			// W3EE - Begin
			// curDeadlyToxicity = ( curToxicity >= damageThreshold );
			// W3EE - End
			if( m_bForceToxicityUpdate || m_bLastDeadlyToxicity != curDeadlyToxicity ) 
			{
				m_fxSetDeadlyToxicity.InvokeSelfOneArg( FlashArgBool( curDeadlyToxicity ) );
				m_bLastDeadlyToxicity = curDeadlyToxicity;
			}
			
			m_bForceToxicityUpdate = false;
			
		}
	}

	public function UpdateExperience() : void
	{
		var curExperience 	: float;
		var curMaxExperience 	: float;
		var witcher : W3PlayerWitcher;
		var adrenaline : W3Effect_Poise;
		
		witcher = GetWitcherPlayer();
		adrenaline = (W3Effect_Poise)witcher.GetBuff(EET_Poise);
		
		curExperience = adrenaline.GetCurrentPoise();
		curMaxExperience = adrenaline.GetMaxPoise();
		
		if ( m_LastExperience != curExperience || m_LastMaxExperience != curMaxExperience )
		{			
			m_fxSetExperience.InvokeSelfOneArg( FlashArgNumber(curExperience / curMaxExperience));
			
			m_LastExperience 	 = curExperience;
			m_LastMaxExperience = curMaxExperience;
		}
	}
	
	private function GetCurrentExperience() : float
	{
		/*var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;*/
		
		return 0; //levelManager.GetPointsTotal(EExperiencePoint);
	}
	
	private function GetLevelExperience() : float
	{
		/*var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;*/
		return 1; //levelManager.GetTotalExpForCurrLevel();
	}

	private function GetTargetExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		return levelManager.GetTotalExpForNextLevel();
	}
	
	public function UpdateMedallion() : void
	{
		var l_curMedallionActivated : bool = GetWitcherPlayer().GetMedallion().IsActive();
		
		if( m_medallionActivated != l_curMedallionActivated )
		{
			m_medallionActivated = l_curMedallionActivated;
			m_fxSwitchWolfActivation.InvokeSelfOneArg( FlashArgBool( m_medallionActivated ) );
		}
	}
	
	private var lastUpdateValue : float;
	private function UpdateFocusPoints()
	{
		// W3EE - Begin
		var curFocusPoints : int = FloorF( GetWitcherPlayer().GetStatPercents( BCS_Focus ) * 3 );
		var focusProgress : float = GetWitcherPlayer().GetStatPercents( BCS_Focus ) * 3;
		var signCost : float = 1.f; //Kolaris - Mutation Rework
		
		//Kolaris ++ Mutation Rework
		if( GetWitcherPlayer().IsMutationActive(EPMT_Mutation1) )
			signCost *= 0.5f;
		if( GetWitcherPlayer().IsMutationActive(EPMT_Mutation9) )
			signCost *= 3.f;
		//Kolaris -- Mutation Rework
		
		if ( m_focusPoints != curFocusPoints )
		{
			m_focusPoints = curFocusPoints;
			
			m_fxSetFocusPointsSFF.InvokeSelfOneArg( FlashArgInt( m_focusPoints) );
		}
		if ( m_focusProgress != focusProgress )
		{
			m_focusProgress = focusProgress;
			m_fxSetFocusProgressSFF.InvokeSelfOneArg( FlashArgNumber( focusProgress ) );
		}
		
		if( focusProgress < signCost )
			m_fxSetSignIconDimmed.InvokeSelfOneArg(FlashArgBool(true));
		else
		{
			m_fxSetSignIconDimmed.InvokeSelfOneArg(FlashArgBool(false)); //Kolaris - Mutation Rework
			if( curFocusPoints >= lastUpdateValue + 1.f )
			{
				m_fxSetSignIconDimmed.InvokeSelfOneArg(FlashArgBool(true));
				m_fxSetSignIconDimmed.InvokeSelfOneArg(FlashArgBool(false));
				lastUpdateValue = focusProgress; //Kolaris - Mutation Rework
			}
		}
		
		if( curFocusPoints < lastUpdateValue )
			lastUpdateValue = curFocusPoints;
		// W3EE - End
	}

	public function ResetFocusPoints()
	{
		var curFocusPoints : int = FloorF( GetWitcherPlayer().GetStat( BCS_Focus ) );
		m_fxSetFocusPointsSFF.InvokeSelfOneArg( FlashArgInt(curFocusPoints) );
	}
	
	public function LockFocusPoints( value : int )
	{
		
		if ( value <= 3 )
			m_fxLockFocusPointsSFF.InvokeSelfOneArg( FlashArgInt( value) );
	}
	
	public function UpdateSignData()
	{
		if( thePlayer.GetEquippedSign() != m_CurrentSelectedSign )
		{
			m_CurrentSelectedSign = thePlayer.GetEquippedSign();
			m_fxSetSignIconSFF.InvokeSelfOneArg(FlashArgString(GetSignIcon()));
			m_fxSetSignTextSFF.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt(SignEnumToString(m_CurrentSelectedSign))));
		}
	}
	
	public function UpdateStateByPlayer()
	{
		if( thePlayer.IsCiri() != m_IsPlayerCiri )
		{
			m_IsPlayerCiri = thePlayer.IsCiri();
			m_bForceToxicityUpdate = true;
			m_fxSetCiriAsMainCharacter.InvokeSelfOneArg(FlashArgBool(m_IsPlayerCiri));
			DisplayNewLevelIndicator();
		}
	}
	
	public function SetCoatOfArms( val : bool )
	{
		thePlayer.SetUsingCoatOfArms( val );
		
		UpdateCoatOfArms();
	}
	
	private function UpdateCoatOfArms()
	{
		m_fxSetCoatOfArms.InvokeSelfOneArg( FlashArgBool( thePlayer.IsUsingCoatOfArms() ) );
	}
	
	private function GetSignIcon() : string
	{
		if((W3ReplacerCiri)thePlayer)
		{
			return "hud/radialmenu/mcCiriPower.png";
		}
		return GetSignIconByType(m_CurrentSelectedSign); 
	}
	
	private function GetSignIconByType( signType : ESignType ) : string
	{
		switch( signType )
		{
			case ST_Aard:		return "hud/radialmenu/mcAard.png";
			case ST_Yrden:		return "hud/radialmenu/mcYrden.png";
			case ST_Igni:		return "hud/radialmenu/mcIgni.png";
			case ST_Quen:		return "hud/radialmenu/mcQuen.png";
			case ST_Axii:		return "hud/radialmenu/mcAxii.png";
			default : return "";
		}
	}
	
	public function ShowLevelUpIndicator( value : bool )
	{
		m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(value));
	}

	public function SetAlwaysDisplayed( value : bool )
	{
		m_fxSetAlwaysDisplayed.InvokeSelfOneArg(FlashArgBool(value));
	}
	
	public function GetWolfActivator() : CScriptedFlashFunction
	{
		return m_fxSwitchWolfActivation;
	}
}

exec function AlwaysDisplayHUD( value : bool )
{
	var hudWolfHeadModule : CR4HudModuleWolfHead;		
	var hud : CR4ScriptedHud;
	hud = (CR4ScriptedHud)theGame.GetHud();
	
	hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
	if ( hudWolfHeadModule )
	{
		hudWolfHeadModule.SetAlwaysDisplayed(value);
	}
}

exec function coa( val : bool )
{
	var hud : CR4ScriptedHud;
	var hudWolfHeadModule : CR4HudModuleWolfHead;		

	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
		if ( hudWolfHeadModule )
		{
			hudWolfHeadModule.SetCoatOfArms( val );
		}
	}
}



