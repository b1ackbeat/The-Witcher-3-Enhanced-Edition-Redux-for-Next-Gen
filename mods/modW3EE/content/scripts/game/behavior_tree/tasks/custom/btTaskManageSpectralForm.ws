/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
 









class BTTaskManageSpectralForm extends IBehTreeTask
{	
	
	
	
	private var m_LastEnteredYrden 	: W3YrdenEntity;
	
	private var m_IsInYrden			: bool;
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( CanSwitchToShadow() )
		{
			ActivateShadowForm();
		}
		
		return BTNS_Active;
	}	
	
	//Kolaris - Wraith Drain
	latent function Main() : EBTNodeStatus
	{
		var l_npc : CNewNPC = GetNPC();
		var l_target : CActor = l_npc.GetTarget();
		var l_npcPos, l_targetPos : Vector;
		var l_dist : float;
		var l_params : SCustomEffectParams;
		var l_targetNode : CNode;
		var m_DrainEffectEntity : CEntity;
		var drainTemplate : CEntityTemplate;
		
		while( true )
		{
			if( m_IsInYrden && !m_LastEnteredYrden )
			{
				m_IsInYrden = false;
				l_npc.SetBehaviorVariable( 'isInYrden', 0 );
			}
			
			if( l_npc.HasAbility ( 'ShadowFormActive' ) )
			{
				l_npc.SetCanPlayHitAnim( false );
			}
			else
			if( l_npc.GetGameplayVisibility() && !GetNPC().IsAbilityBlocked('ShadowForm') && !GetNPC().HasBuff(EET_SilverBurn) && GetNPC().HasBuff(EET_HealthRegen) && !((W3SummonedEntityComponent)l_npc.GetComponentByClassName('W3SummonedEntityComponent')) )
			{
				l_npcPos = l_npc.GetWorldPosition();
				l_targetPos = l_target.GetWorldPosition();
				l_dist = VecDistance( l_npcPos, l_targetPos );
				if( l_dist < 4 && (W3PlayerWitcher)l_target && l_target.GetImmortalityMode() != AIM_Invulnerable && !l_target.HasBuff( EET_VitalityDrain ) && !l_target.HasBuff( EET_BasicQuen ) )
				{
					l_targetNode = l_npc.GetComponent("torso3effect");
					if( !l_targetNode )
						l_targetNode = l_npc;
					
					l_params.effectType = EET_VitalityDrain;
					l_params.creator = l_npc;
					l_params.sourceName = l_npc.GetName();
					l_params.duration = 1;
					l_target.AddEffectCustom( l_params );
					
					l_npc.Heal( l_target.GetCurrentHealth() * 0.025f );
					l_npc.ShowFloatingValue(EFVT_Heal, l_target.GetCurrentHealth() * 0.025f, false );
					
					l_target.PlayEffect( 'drain_energy', l_targetNode);
					theGame.StopVibrateController();
				}
			}
			
			if( !CanSwitchToShadow() )
				DeactivateShadowForm();
			else
			if( CanSwitchToShadow() )
				ActivateShadowForm();
				
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	
	private final function CanSwitchToShadow() : bool
	{
		if( !m_IsInYrden && GetNPC().HasAbility('ShadowForm') && !GetNPC().IsAbilityBlocked('ShadowForm') && !((W3Effect_NPCPoise)GetNPC().GetBuff(EET_NPCPoise)).IsPoiseBroken() )
		{
			return true;
		}
		return false;
	}
	
	
	private final function ActivateShadowForm()
	{
		var l_npc : CNewNPC = GetNPC();
		
		l_npc.PlayEffectSingle( 'shadows_form' );
		l_npc.SetCanPlayHitAnim( false );
		
		if( !l_npc.HasAbility ( 'ShadowFormActive' ) )
		{	
			l_npc.EnableCharacterCollisions( false );		
			l_npc.AddAbility('ShadowFormActive');
			l_npc.SoundSwitch( 'ghost_visibility', 'invisible' );
		}
	}
	
	
	private final function DeactivateShadowForm()
	{
		var l_npc : CNewNPC = GetNPC();
		
		if( l_npc.IsEffectActive( 'shadows_form' ) )
		{				
			l_npc.StopEffect( 'shadows_form' );				
		}
		
		if( l_npc.HasAbility ( 'ShadowFormActive' ) )
		{
			l_npc.EnableCharacterCollisions( true );
			l_npc.SetCanPlayHitAnim( true );
			l_npc.RemoveAbility('ShadowFormActive');
			l_npc.SoundSwitch( 'ghost_visibility', 'visible' );
		}
	}
	
	
	final function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var l_yrdenEntity 	: W3YrdenEntity;
		
		l_yrdenEntity = (W3YrdenEntity) GetEventParamObject();
		
		if( !GetNPC().IsAlive() ) 
			return false;
		
		switch( eventName )
		{
			case 'EntersYrden':
			m_IsInYrden = true;
			GetNPC().SetBehaviorVariable( 'isInYrden', 1 );
			
			m_LastEnteredYrden = l_yrdenEntity;			
			
			
			DeactivateShadowForm();
			
			break;
			case 'LeavesYrden':
			if( l_yrdenEntity == m_LastEnteredYrden )
			{
				m_IsInYrden = false;
				GetNPC().SetBehaviorVariable( 'isInYrden', 0 );
				
				
				if( CanSwitchToShadow() )
				{
					ActivateShadowForm();
				}
			}
			break;
		}
		
		return true;
	}

}



class BTTaskManageSpectralFormDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageSpectralForm';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'EntersYrden' );
		listenToGameplayEvents.PushBack( 'LeavesYrden' );
	}
}