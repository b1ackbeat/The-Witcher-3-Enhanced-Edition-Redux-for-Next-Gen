/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
enum EFloatingValueType
{
	EFVT_None,
	EFVT_Critical,
	EFVT_Block,
	EFVT_InstantDeath,
	EFVT_DoT,
	EFVT_Heal,
	EFVT_Buff
}

class CR4HudModuleEnemyFocus extends CR4HudModuleBase
{	
	
	
	
	
	private	var m_fxSetEnemyName				: CScriptedFlashFunction;
	private	var m_fxSetEnemyLevel				: CScriptedFlashFunction;
	private	var m_fxSetAttitude					: CScriptedFlashFunction;
	private	var m_fxSetEnemyHealth				: CScriptedFlashFunction;
	private	var m_fxSetEnemyStamina				: CScriptedFlashFunction;
	private	var m_fxSetEssenceBarVisibility		: CScriptedFlashFunction;
	private	var m_fxSetStaminaVisibility		: CScriptedFlashFunction;
	private var m_fxSetNPCQuestIcon				: CScriptedFlashFunction;
	private	var m_fxSetDodgeFeedback			: CScriptedFlashFunction;
	private	var m_fxSetBossOrDead				: CScriptedFlashFunction;
	private	var m_fxSetShowHardLock				: CScriptedFlashFunction;
	private var m_fxSetDamageText				: CScriptedFlashFunction;
	private var m_fxHideDamageText				: CScriptedFlashFunction;
	private var m_fxSetGeneralVisibility		: CScriptedFlashFunction;
	private var m_fxSetMutationEightVisibility	: CScriptedFlashFunction;

	private	var m_mcNPCFocus				: CScriptedFlashSprite;
	
	private var m_lastTarget				: CGameplayEntity;
	private var m_lastTargetAttitude		: EAIAttitude;
	private var m_lastHealthPercentage		: int;
	private var m_wasAxiied					: bool;
	private var m_lastStaminaPercentage		: int;
	private var m_nameInterval				: float;
	private var m_lastEnemyDifferenceLevel	: string;
	private var m_lastEnemyLevelString		: string;
	private var m_lastDodgeFeedbackTarget	: CActor;
	private var m_lastEnemyName				: string;
	private var m_lastUseMutation8Icon		: bool;
	
	
	private var pulseArray : array<string>;
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "ScaleOnly";
		
		flashModule 			= GetModuleFlash();
		
		m_fxSetEnemyName				= flashModule.GetMemberFlashFunction( "setEnemyName" );
		m_fxSetEnemyLevel				= flashModule.GetMemberFlashFunction( "setEnemyLevel" );
		m_fxSetAttitude					= flashModule.GetMemberFlashFunction( "setAttitude" );
		m_fxSetEnemyHealth				= flashModule.GetMemberFlashFunction( "setEnemyHealth" );
		m_fxSetEnemyStamina				= flashModule.GetMemberFlashFunction( "setEnemyStamina" );
		m_fxSetEssenceBarVisibility		= flashModule.GetMemberFlashFunction( "setEssenceBarVisibility" );
		m_fxSetStaminaVisibility		= flashModule.GetMemberFlashFunction( "setStaminaVisibility" );		
		m_fxSetNPCQuestIcon				= flashModule.GetMemberFlashFunction( "setNPCQuestIcon" );
		m_fxSetDodgeFeedback			= flashModule.GetMemberFlashFunction( "setDodgeFeedback" );
		m_fxSetDamageText				= flashModule.GetMemberFlashFunction( "setDamageText" );
		m_fxHideDamageText				= flashModule.GetMemberFlashFunction( "hideDamageText" );
		m_fxSetBossOrDead				= flashModule.GetMemberFlashFunction( "SetBossOrDead" );		
		m_fxSetShowHardLock				= flashModule.GetMemberFlashFunction( "setShowHardLock" );
		m_fxSetGeneralVisibility		= flashModule.GetMemberFlashFunction( "SetGeneralVisibility" );
		m_fxSetMutationEightVisibility 	= flashModule.GetMemberFlashFunction( "displayMutationEight" );
		m_mcNPCFocus 					= flashModule.GetChildFlashSprite( "mcNPCFocus" );
		
		super.OnConfigUI();
		
		m_fxSetEnemyName.InvokeSelfOneArg( FlashArgString( "" ) );
		m_fxSetEnemyStamina.InvokeSelfOneArg(FlashArgInt(0));
		
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('EnemyFocusModule', true);
		}
		
		pulseArray.Clear();
		pulseArray.PushBack("<font color=\"#ff1744\">");
		pulseArray.PushBack("<font color=\"#fad7a0\">");
	}
	
	
	
	private function GetAttitudeOfTargetActor( target : CGameplayEntity ) : EAIAttitude
	{
		var targetActor : CActor;
		
		targetActor = ( CActor )target;
		if ( targetActor )
		{
			return targetActor.GetAttitude( thePlayer );
		}
		return AIA_Neutral;
	}
	
	// W3EE - Begin
	public function SetDodgeFeedback( target : CActor ) :void 
	{
		/*
		m_fxSetDodgeFeedback.InvokeSelfOneArg( FlashArgBool( !( !target ) ) );
		m_lastDodgeFeedbackTarget = target;
		*/
	}
	// W3EE - End
	
	public function DisplayMutationEight( value : bool ) :void
	{
		m_fxSetMutationEightVisibility.InvokeSelfOneArg( FlashArgBool ( value ) );
	}
	
	
	public function SetGeneralVisibility( showEnemyFocus : bool, showName : bool )
	{
		m_fxSetGeneralVisibility.InvokeSelfTwoArgs( FlashArgBool( showEnemyFocus ), FlashArgBool( showName ) );
	}
	
	
	// W3EE - Begin
	public function ShowDamageType(valueType : EFloatingValueType, value : float, optional stringParam : string, optional labelString : string, optional damageType : name, optional statusType : EEffectType)
	{
		var label:string;
		var color:float;
		var hud:CR4ScriptedHud;
		var target : CActor;
		var bleedingEffect : W3Effect_Bleeding;
		var poisonEffect : W3Effect_Poison;
		
		if(valueType != EFVT_InstantDeath && valueType != EFVT_Buff && value == 0.f)
			return;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( !hud.AreEnabledEnemyHitEffects() )
		{
			return;
		}
		
		switch (valueType)
		{
			case EFVT_Critical:
				//---=== modFriendlyHUD ===---
				if ( GetFHUDConfig().doNotShowDamage )
					return;
				//---=== modFriendlyHUD ===---
				label = GetLocStringByKeyExt("");
				color = 0xFDFFC2;
				break;
			case EFVT_InstantDeath:
				label = GetLocStringByKeyExt("effect_instant_death");
				color = 0xFFC2C2;
				break;
			case EFVT_Block:
				label = GetLocStringByKeyExt("");
				color = 0xFC5B5B;
				break;
			case EFVT_DoT:
				//---=== modFriendlyHUD ===---
				if ( GetFHUDConfig().doNotShowDamage )
					return;
				//---=== modFriendlyHUD ===---
				label = GetLocStringByKeyExt("");
				switch(damageType)
				{
					case theGame.params.DAMAGE_NAME_FIRE:
						color = 0xFF8D00;
					break;
					
					case theGame.params.DAMAGE_NAME_POISON:
						color = 0xDFFF80;
					break;
					
					case theGame.params.DAMAGE_NAME_DIRECT:
						color = 0xFF0000;
					break;
					
					case theGame.params.DAMAGE_NAME_ELEMENTAL:
						color = 0xDB74DB;
					break;
					
					case theGame.params.DAMAGE_NAME_SHOCK:
						color = 0xFFFFCC;
					break;
					
					default:
						color = 0xFFF0F0;
					break;
				}
				break;
			case EFVT_Heal:
				label = GetLocStringByKeyExt("");
				color = 0x00FF00;
				break;
			case EFVT_Buff:
				label = GetLocStringByKeyExt(stringParam);
				switch(statusType)
				{
					case EET_Bleeding:
						label = GetLocStringByKeyExt("W3EE_Bleeding");
						target = (CActor)thePlayer.GetDisplayTarget();
						bleedingEffect = (W3Effect_Bleeding)target.GetBuff(EET_Bleeding);
						label += ": " + IntToString(bleedingEffect.GetStacks());
						color = 0xFF0000;
					break;
					
					case EET_Burning:
						label = GetLocStringByKeyExt("W3EE_Burning");
						color = 0xFF8D00;
					break;
					
					case EET_Immobilized:
						label = GetLocStringByKeyExt("W3EE_Immobilized");
						color = 0xBD406C;
					break;
					//Kolaris - Paralyze
					case EET_Paralyzed:
						label = GetLocStringByKeyExt("W3EE_Immobilized");
						color = 0xBD406C;
					break;
					
					case EET_Poison:
						label = GetLocStringByKeyExt("W3EE_Poisoning");
						target = (CActor)thePlayer.GetDisplayTarget();
						poisonEffect = (W3Effect_Poison)target.GetBuff(EET_Poison);
						label += ": " + IntToString(poisonEffect.GetStacks());
						color = 0xDFFF80;
					break;
					
					case EET_Electroshock:
						label = GetLocStringByKeyExt("W3EE_Electroshock");
						color = 0xFFFFCC;
					break;
					
					case EET_SilverBurn:
						label = GetLocStringByKeyExt("W3EE_SilverBurn");
						color = 0xC0C0C0;
					break;
					
					case EET_PoisonCritical:
						label = GetLocStringByKeyExt("W3EE_Poisoning");
						color = 0xDFFF80;
					break;
					
					case EET_Slowdown:
						label = GetLocStringByKeyExt("W3EE_Slowdown");
						color = 0xDB74DB;
					break;
					
					case EET_SlowdownFrost:
						label = GetLocStringByKeyExt("W3EE_Chilled");
						color = 0xB0E0E6;
					break;
					
					case EET_Confusion:
						label = GetLocStringByKeyExt("W3EE_Stunned");
						color = 0xFFF0F0;
					break;
					
					case EET_Blindness:
						label = GetLocStringByKeyExt("W3EE_Blinded");
						color = 0xFFF0F0;
					break;
					
					case EET_Knockdown:
						label = GetLocStringByKeyExt("W3EE_Knockdown");
						color = 0xFFF0F0;
					break;
					
					case EET_HeavyKnockdown:
						label = GetLocStringByKeyExt("W3EE_Knockdown");
						color = 0xFFF0F0;
					break;
					
					default:
						//Kolaris - Critter HUD Fix
						label = GetLocStringByKeyExt("");
						color = 0xFFF0F0;
					break;
				}
				break;
			default:
				//---=== modFriendlyHUD ===---
				if ( GetFHUDConfig().doNotShowDamage )
					return;
				//---=== modFriendlyHUD ===---
				label = GetLocStringByKeyExt("");
				switch(damageType)
				{
					case theGame.params.DAMAGE_NAME_DIRECT:
						color = 0xA64CA6;
					break;
					
					case theGame.params.DAMAGE_NAME_PHYSICAL:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_SILVER:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_SLASHING:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_PIERCING:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_BLUDGEONING:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_RENDING:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_ELEMENTAL:
						color = 0xDB74DB;
					break;
					
					case theGame.params.DAMAGE_NAME_FIRE:
						color = 0xFF8D00;
					break;
					
					case theGame.params.DAMAGE_NAME_FORCE:
						color = 0xFFF0F0;
					break;
					
					case theGame.params.DAMAGE_NAME_FROST:
						color = 0xB0E0E6;
					break;
					
					case theGame.params.DAMAGE_NAME_POISON:
						color = 0xDFFF80;
					break;
					
					case theGame.params.DAMAGE_NAME_SHOCK:
						color = 0xFFFFCC;
					break;
					
					case theGame.params.DAMAGE_NAME_MORALE:
						color = 0x800080;
					break;
					
					case theGame.params.DAMAGE_NAME_STAMINA:
						color = 0xFFF68F;
					break;
					
					default:
						color = 0xFFF0F0;
					break;
					
				}
				break;
		}
		
		if( labelString != "" )
			SetDamageText(labelString, CeilF(value), color);
		else
			SetDamageText(label, CeilF(value), color);
	}
	// W3EE - End
	
	
		
	private function SetDamageText(label:string, value:int, color:float) : void
	{		
		m_fxSetDamageText.InvokeSelfThreeArgs( FlashArgString(label), FlashArgNumber(value), FlashArgNumber(color) );
	}
	public function HideDamageText()
	{
		m_fxHideDamageText.InvokeSelf();
	}
	
	
	
	private var pulseCounter : int; default pulseCounter = 0;
	private var pulseTimer : float; default pulseTimer = 0.2f;
	private var lastPoisePerc : int; default lastPoisePerc = -1;
	event OnTick( timeDelta : float )
	{
		var l_target 					: CNewNPC;
		var l_targetNonActor			: CGameplayEntity;
		var l_isHuman					: bool;
		var l_isDifferentTarget			: bool;
		var l_wasAxiied 				: bool;
		var l_currentHealthPercentage	: int;
		var l_currentStaminaPercentage	: int;
		var l_currentTargetAttitude		: EAIAttitude;
		var l_currentEnemyDifferenceLevel : string;
		var l_currentEnemyLevelString   : string;
		var l_targetScreenPos			: Vector;
		var l_dodgeFeedbackTarget		: CActor;
		var l_isBoss					: bool;
		var screenMargin : float = 0.085;
		var marginLeftTop : Vector;
		var marginRightBottom : Vector;
		var hud : CR4ScriptedHud;
		var extraOffset					: int;
		var herbTag						: name;
		var herbEntity					: W3Herb;
		var definitionManager 			: CDefinitionsManagerAccessor;
		var useMutation8Icon			: bool;
		var currentPoisePerc : int;
		var poiseColor : string;
		var poiseEffect : W3Effect_NPCPoise;
		
		l_targetNonActor = thePlayer.GetDisplayTarget();
		l_target = (CNewNPC)l_targetNonActor;
		l_dodgeFeedbackTarget = thePlayer.GetDodgeFeedbackTarget();
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		
		
		
		
		
		
		
		
		
		
		
		
		if ( l_target )
		{
			if ( !l_target.IsUsingTooltip())
			{
				l_target = NULL;
			}
		}
		if ( l_target )
		{
			
			
			if ( l_target.HasTag( 'HideHealthBarModule' ) )
			{
				if ( l_target.HasTag( 'NotBoss' ) ) 
				{
					l_target = NULL;
				}
				else
					l_isBoss = (!GetFHUDConfig().showBossHP); //modFriendlyHUD
			}
			else
			{
				
				if ( (CHeartMiniboss)l_target )
				{
					l_target = NULL;
				}
			}
		}
 
		if ( l_target )
		{
			
			l_isHuman = l_target.IsHuman();
			l_isDifferentTarget = ( l_target != m_lastTarget );
			l_wasAxiied = ( l_target.GetAttitudeGroup() == 'npc_charmed' );
			
			
			
			
			if(l_isDifferentTarget && l_target && !l_target.IsInCombat() && IsRequiredAttitudeBetween(thePlayer, l_target, true))
			{
				l_target.RecalcLevel();
			}
			
			
			if ( l_isDifferentTarget )
			{
				m_fxSetBossOrDead.InvokeSelfOneArg( FlashArgBool( l_isBoss || !l_target.IsAlive() ) );
				
				
				HideDamageText();
				
				
				m_fxSetStaminaVisibility.InvokeSelfOneArg( FlashArgBool( l_isHuman ) ); 
				// W3EE - Begin
				m_fxSetEssenceBarVisibility.InvokeSelfOneArg( FlashArgBool( l_target.GetHealthBarType()) );
				// W3EE - End
				UpdateQuestIcon( l_target );
				SetDodgeFeedback( NULL );
				
				ShowElement( true ); 
				
				m_lastTarget = l_target;
			}
			
			

			l_currentTargetAttitude = l_target.GetAttitude( thePlayer );
			if ( l_currentTargetAttitude != AIA_Hostile )
			{
				
				if ( l_target.IsVIP() )
				{
					l_currentTargetAttitude = 4;
				}
			}
				
			if ( l_isDifferentTarget || m_lastTargetAttitude != l_currentTargetAttitude || m_wasAxiied != l_wasAxiied )
			{
				m_lastTargetAttitude = l_currentTargetAttitude;
				m_wasAxiied = l_wasAxiied;
				if( m_wasAxiied )
				{
					m_fxSetAttitude.InvokeSelfOneArg( FlashArgInt( 3 ) ); 
				}
				else
				{
					m_fxSetAttitude.InvokeSelfOneArg( FlashArgInt( l_currentTargetAttitude ) );
				}
			}

			
			if ( m_lastDodgeFeedbackTarget != l_dodgeFeedbackTarget )
			{
				if ( l_currentTargetAttitude == AIA_Hostile )
				{
					SetDodgeFeedback( l_dodgeFeedbackTarget );
				}
				else
				{
					SetDodgeFeedback( NULL );
				}
				m_lastDodgeFeedbackTarget = l_dodgeFeedbackTarget;
			}
			
			
			
			
			
			
			m_nameInterval -= timeDelta;
			if ( l_isDifferentTarget || m_nameInterval < 0  )
			{
				m_nameInterval = 0.25; 
				
				//---=== modFriendlyHUD ===---
				if( GetFHUDConfig().ShowNPCName(l_target) )
				{
					UpdateName( l_target.GetDisplayName() );
				}
				else
				{
					UpdateName( "" );
				}
				//---=== modFriendlyHUD ===---
			}
			
			l_currentHealthPercentage = CeilF( 100 * l_target.GetHealthPercents() );	
			if ( m_lastHealthPercentage != l_currentHealthPercentage )
			{
				m_lastHealthPercentage = l_currentHealthPercentage;	
				m_fxSetEnemyHealth.InvokeSelfOneArg( FlashArgInt( l_currentHealthPercentage ) );
				
			}			
			
			// W3EE - Begin
			poiseEffect = (W3Effect_NPCPoise)l_target.GetBuff(EET_NPCPoise);
			l_currentStaminaPercentage = CeilF( 100 * poiseEffect.GetPoisePercentage() );
			if ( m_lastStaminaPercentage != l_currentStaminaPercentage )
			{
				m_lastStaminaPercentage = l_currentStaminaPercentage;
				m_fxSetEnemyStamina.InvokeSelfOneArg( FlashArgInt( l_currentStaminaPercentage ) );
			}			
			
			/*currentPoisePerc = CeilF( 100 * l_target.GetStaminaPercents() );
			if( l_target.GetAttitude(thePlayer) == AIA_Hostile && (l_isDifferentTarget || currentPoisePerc != lastPoisePerc) )
			{
				lastPoisePerc = currentPoisePerc;
				//if( poiseEffect.IsPoiseBroken() )
				//{
				//	poiseColor = pulseArray[pulseCounter];
				//	
				//	pulseTimer -= timeDelta;
				//	if( pulseTimer <= 0 )
				//	{
				//		pulseTimer = 0.15f;
				//		pulseCounter += 1;
				//		if( pulseCounter >= 2 )
				//			pulseCounter = 0;
				//	}
				//}
				//else
				if( currentPoisePerc > 80 )
					poiseColor = "<font color=\"#eaeded\">";
				else
				if( currentPoisePerc > 65 )
					poiseColor = "<font color=\"#fad7a0\">";
				else
				if( currentPoisePerc > 50 )
					poiseColor = "<font color=\"#f8c471\">";
				else
				if( currentPoisePerc > 35 )
					poiseColor = "<font color=\"#f5b041\">";
				else
				if( currentPoisePerc > 15 )
					poiseColor = "<font color=\"#f39c12\">";
				else
					poiseColor = "<font color=\"#d35400\">";
					
				m_fxSetEnemyLevel.InvokeSelfTwoArgs( FlashArgString( "normalLevel" ), FlashArgString( poiseColor + "·</font>" ) );
			}*/
			
			/*l_currentEnemyDifferenceLevel = l_target.GetExperienceDifferenceLevelName( l_currentEnemyLevelString );
			if ( l_isDifferentTarget || 
				 m_lastEnemyDifferenceLevel != l_currentEnemyDifferenceLevel ||
				 m_lastEnemyLevelString     != l_currentEnemyLevelString )
			{
				m_lastEnemyDifferenceLevel = l_currentEnemyDifferenceLevel;
				m_lastEnemyLevelString     = l_currentEnemyLevelString;
				m_fxSetEnemyLevel.InvokeSelfTwoArgs( FlashArgString( l_currentEnemyDifferenceLevel ), FlashArgString( l_currentEnemyLevelString ) );
			}*/
			// W3EE - End
			
			useMutation8Icon = /*GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) && !l_target.IsImmuneToMutation8Finisher() ||*/ poiseEffect.IsPoiseBroken(); //Kolaris - Mutation Rework
			if ( m_lastUseMutation8Icon != useMutation8Icon )
			{
				m_lastUseMutation8Icon = useMutation8Icon;
				DisplayMutationEight( useMutation8Icon );
			}
			
			if ( GetBaseScreenPosition( l_targetScreenPos, l_target ) )
			{
				l_targetScreenPos.Y -= 45;
				
				marginLeftTop     = hud.GetScaleformPoint( screenMargin,     screenMargin );
				marginRightBottom = hud.GetScaleformPoint( 1 - screenMargin, 1 - screenMargin );

				if ( l_targetScreenPos.X < marginLeftTop.X )
				{
					l_targetScreenPos.X = marginLeftTop.X;
				}
				else if ( l_targetScreenPos.X > marginRightBottom.X )
				{
					l_targetScreenPos.X = marginRightBottom.X;
				}
				
				if ( l_targetScreenPos.Y < marginLeftTop.Y )
				{
					l_targetScreenPos.Y = marginLeftTop.Y;
				}
				else if ( l_targetScreenPos.Y > marginRightBottom.Y )
				{
					l_targetScreenPos.Y = marginRightBottom.Y;
				}

				m_mcNPCFocus.SetVisible( true );
				m_mcNPCFocus.SetPosition( l_targetScreenPos.X, l_targetScreenPos.Y );
			}			
			else
			{
				m_mcNPCFocus.SetVisible( false );
			}
		}
		else if ( l_targetNonActor )
		{
			
			l_isDifferentTarget = ( l_targetNonActor != m_lastTarget );

			
			if ( l_isDifferentTarget )
			{
				
				m_fxSetStaminaVisibility.InvokeSelfOneArg( FlashArgBool( false ) );
				m_fxSetEssenceBarVisibility.InvokeSelfOneArg( FlashArgBool( false ) );
				UpdateQuestIcon( (CNewNPC)l_targetNonActor );
				SetDodgeFeedback( NULL );
				
				ShowElement( true ); 
				
				m_fxSetAttitude.InvokeSelfOneArg( FlashArgInt( 0 ) );
				m_fxSetEnemyLevel.InvokeSelfTwoArgs( FlashArgString( "none" ), FlashArgString( "" ) );

				
				m_lastTarget				= l_targetNonActor;
				m_lastTargetAttitude		= GetAttitudeOfTargetActor( m_lastTarget );
				m_lastHealthPercentage		= -1;
				m_lastStaminaPercentage		= -1;
				m_lastEnemyDifferenceLevel	= "none";
				m_lastEnemyLevelString		= "";
			}		
		
			
			
			
			
			
			
			herbEntity = (W3Herb)l_targetNonActor;
			if ( herbEntity )
			{
				extraOffset = 140; 
				m_nameInterval -= timeDelta;
				if ( l_isDifferentTarget || m_nameInterval < 0  )
				{
					m_nameInterval = 0.25; 

					herbEntity.GetStaticMapPinTag( herbTag );
					//---=== modFriendlyHUD ===---
					if ( (bool)herbTag && !GetFHUDConfig().hideHerbNames )
					//---=== modFriendlyHUD ===---
					{
						definitionManager = theGame.GetDefinitionsManager();
						if ( definitionManager )
						{
							UpdateName( GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyName( herbTag ) ) );
						}
					}
					else
					{
						UpdateName( "" );
					}
				}
			}
			else
			{
				if ( l_isDifferentTarget )
				{
					UpdateName( "" );
				}
			}

			
			useMutation8Icon = false;
			if ( m_lastUseMutation8Icon != useMutation8Icon )
			{
				DisplayMutationEight( useMutation8Icon );
				m_lastUseMutation8Icon = useMutation8Icon;
			}

			
			if ( GetBaseScreenPosition( l_targetScreenPos, l_targetNonActor ) )
			{
				l_targetScreenPos.Y -= 10;
				l_targetScreenPos.Y -= extraOffset;

				marginLeftTop     = hud.GetScaleformPoint( screenMargin,     screenMargin );
				marginRightBottom = hud.GetScaleformPoint( 1 - screenMargin, 1 - screenMargin );

				if ( l_targetScreenPos.X < marginLeftTop.X )
				{
					l_targetScreenPos.X = marginLeftTop.X;
				}
				else if ( l_targetScreenPos.X > marginRightBottom.X )
				{
					l_targetScreenPos.X = marginRightBottom.X;
				}
			
				if ( l_targetScreenPos.Y < marginLeftTop.Y )
				{
					l_targetScreenPos.Y = marginLeftTop.Y;
				}
				else if ( l_targetScreenPos.Y > marginRightBottom.Y )
				{
					l_targetScreenPos.Y = marginRightBottom.Y;
				}

				m_mcNPCFocus.SetVisible( true );
				m_mcNPCFocus.SetPosition( l_targetScreenPos.X, l_targetScreenPos.Y );	
			}
			else
			{
				m_mcNPCFocus.SetVisible( false );
			}
		}
		else if ( m_lastTarget )
		{
			m_lastTarget = NULL;
			m_mcNPCFocus.SetVisible( false );
			SetDodgeFeedback( NULL );
			ShowElement( false ); 
		}
		else
		{
			
			if ( m_mcNPCFocus.GetVisible() )
			{
				m_mcNPCFocus.SetVisible( false );
				ShowElement( false );
			}
		}
	}	
	
	public function UpdateName( enemyName : string )
	{
		if ( m_lastEnemyName != enemyName )
		{
			m_lastEnemyName = enemyName;
			m_fxSetEnemyName.InvokeSelfOneArg( FlashArgString( m_lastEnemyName ) );
		}
	}
	
	public function SetShowHardLock( set : bool )
	{
		m_fxSetShowHardLock.InvokeSelfOneArg( FlashArgBool( set ) );
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool 
	{
		return false;
	}
	
	//---=== modFriendlyHUD ===---
	private function UpdateQuestIcon( target : CNewNPC )
	{
		var questIcon : string;
		
		if( GetFHUDConfig().hideNPCQuestMarkers )
		{
			questIcon = "none";
		}
		else
		{
			questIcon = GetQuestIconFromMarker( target );
			if( questIcon == "none" )
			{
				questIcon = GetQuestIconFromJournal( target );
			}
		}
		m_fxSetNPCQuestIcon.InvokeSelfOneArg( FlashArgString( questIcon ) );
	}
	
	private function GetQuestIconFromMarker( target : CNewNPC ) : string
	{
		var mapPinInstances : array< SCommonMapPinInstance >;
		var commonMapManager : CCommonMapManager;
		var currentPin : SCommonMapPinInstance;
		var targetTags : array< name >;
		var i : int;
		var questIcon : string;
		var mapPinType : name;
		
		questIcon = "none";

		if ( target )
		{
			targetTags = target.GetTags();
			
			if (targetTags.Size() > 0)
			{
				commonMapManager = theGame.GetCommonMapManager();

				mapPinType = commonMapManager.GetMapPinTypeByTag( targetTags[0] );
				switch ( mapPinType )
				{
					case 'QuestReturn':
						questIcon = "QuestReturn";
						break;
					case 'QuestGiverStory':
						questIcon = "QuestGiverStory";
						break;
					case 'QuestGiverChapter':
						questIcon = "QuestGiverChapter";
						break;
					case 'QuestGiverSide':
					case 'QuestAvailable':
					case 'QuestAvailableHoS':
					case 'QuestAvailableBaW':
						questIcon = "QuestGiverSide";
						break;
					case 'MonsterQuest':
						questIcon = "MonsterQuest";
						break;
					case 'TreasureQuest':
						questIcon = "TreasureQuest";
						break;
				}
			}
		}
		return questIcon;
	}
	
	private function GetQuestIconFromJournal( target : CNewNPC ) : string
	{
		var journalManager		: CWitcherJournalManager;
		var currentQuest		: CJournalQuest;
		var currentPhase		: CJournalQuestPhase;
		var currentObjective	: CJournalQuestObjective;
		var questsList			: array< CJournalBase >;
		var questsCount, qIdx	: int;
		var phaseCount, pIdx	: int;
		var objCount, oIdx		: int;
		var pinsCount, pinIdx	: int;
		var currentMappin		: CJournalQuestMapPin;
		var questIcon			: string;
		var targetTags			: array< name >;
		var tagsCount, tIdx		: int;

		questIcon = "none";
		if ( target )
		{
			targetTags = target.GetTags();
			tagsCount = targetTags.Size();
			if ( tagsCount > 0 )
			{
				journalManager = theGame.GetJournalManager();
				journalManager.GetActivatedOfType( 'CJournalQuest', questsList );
				questsCount = questsList.Size();
				for( qIdx = 0; qIdx < questsCount; qIdx += 1 )
				{
					currentQuest = (CJournalQuest)questsList[qIdx];
					if( currentQuest && journalManager.GetEntryStatus( currentQuest ) == JS_Active )
					{
						phaseCount = currentQuest.GetNumChildren();
						for( pIdx = 0; pIdx < phaseCount; pIdx += 1 )
						{
							currentPhase = (CJournalQuestPhase)currentQuest.GetChild(pIdx);
							if( currentPhase )
							{
								objCount = currentPhase.GetNumChildren();
								for( oIdx = 0;  oIdx < objCount; oIdx += 1 )
								{
									currentObjective = (CJournalQuestObjective)currentPhase.GetChild(oIdx);
									if ( currentObjective && journalManager.GetEntryStatus( currentObjective ) == JS_Active )
									{
										pinsCount = currentObjective.GetNumChildren();
										for( pinIdx = 0; pinIdx < pinsCount; pinIdx += 1 )
										{			
											currentMappin = (CJournalQuestMapPin)currentObjective.GetChild(pinIdx);
											if( currentMappin )
											{
												for( tIdx = 0; tIdx < tagsCount; tIdx += 1 )
												{
													if( currentMappin.GetMapPinID() == targetTags[tIdx] )
													{
														switch (currentQuest.GetType())
														{
															case Story:
																questIcon = "QuestGiverStory"; // yellow !
																return questIcon;
															case Chapter:
																questIcon = "QuestGiverChapter"; // white !
																return questIcon;
															case Side:
																questIcon = "QuestGiverSide"; // white !
																return questIcon;
															case MonsterHunt:
																questIcon = "MonsterQuest";
																return questIcon;
															case TreasureHunt:
																questIcon = "TreasureQuest";
																return questIcon;
															default:
																//return "QuestReturn"; //?
																break;
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				} 
			}
		}
		return questIcon;
	}
	//---=== modFriendlyHUD ===---
}

exec function dodgeFeedback()
{
	var npc : CNewNPC;
	
	npc = (CNewNPC)thePlayer.GetDisplayTarget();
	if ( npc )
	{
		thePlayer.SetDodgeFeedbackTarget( npc );
	}
}

exec function hardlock( set : bool )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleEnemyFocus;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleEnemyFocus)hud.GetHudModule("EnemyFocusModule");
	module.SetShowHardLock( set );
}

