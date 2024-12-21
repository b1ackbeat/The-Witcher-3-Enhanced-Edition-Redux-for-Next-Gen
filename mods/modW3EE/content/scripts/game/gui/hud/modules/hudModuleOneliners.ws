/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct OnelinerDefinition
{
	var m_Target : CEntity; //modFriendlyHUD
	var m_Text	 : string;
	var m_ID	 : int;
};

class CR4HudModuleOneliners extends CR4HudModuleBase
{	
	private	var m_hud 						: CR4ScriptedHud;
	private	var m_fxCreateOnelinerSFF		: CScriptedFlashFunction;
	private	var m_fxRemoveOnelinerSFF		: CScriptedFlashFunction;
	private var m_flashModule 				: CScriptedFlashSprite;
	private var m_oneliners 				: array< OnelinerDefinition >;
	private var modMarkers					: CModMarkers; //modFriendlyHUD
	
	private const var VISIBILITY_DISTANCE_SQUARED : float;	default VISIBILITY_DISTANCE_SQUARED = 2025; 

	event  OnConfigUI()
	{
		m_anchorName = "ScaleOnly";
		
		m_flashModule 			= GetModuleFlash();
		
		
		m_fxCreateOnelinerSFF	= m_flashModule.GetMemberFlashFunction( "CreateOneliner" );
		m_fxRemoveOnelinerSFF	= m_flashModule.GetMemberFlashFunction( "RemoveOneliner" );
		
		super.OnConfigUI();
		
		m_hud 					= (CR4ScriptedHud)theGame.GetHud();
		
		if (m_hud)
		{
			m_hud.UpdateHudConfig('OnelinersModule', true);
		}
		
		//modFriendlyHUD begin
		modMarkers = new CModMarkers in this;
		modMarkers.Init();
		//modFriendlyHUD end
	}
	
	
	event OnTick( timeDelta : float )
	{
		var target				: CEntity; //modFriendlyHUD
		var screenPos			: Vector;
		var i 					: int;
		var mcOneliner			: CScriptedFlashSprite;
		
		modMarkers.Update( timeDelta ); //modFriendlyHUD

		for( i = 0; i < m_oneliners.Size(); i += 1 )
		{
			mcOneliner = m_flashModule.GetChildFlashSprite( "mcOneliner" + m_oneliners[ i ].m_ID );
			if ( mcOneliner )
			{
				target = m_oneliners[ i ].m_Target;
				if ( target && IsTargetCloseEnough( target ) )
				{
					if ( GetBaseScreenPosition( screenPos, target, NULL, 0, true ) )
					{
						screenPos.Y -= 90;
						mcOneliner.SetPosition( screenPos.X, screenPos.Y );
						mcOneliner.SetVisible( true );
						mcOneliner.SetAlpha( 100 ); //modFriendlyHUD
					}
					else
					{
						mcOneliner.SetVisible( false );
					}
				}
				else
				{
					mcOneliner.SetVisible( false );
				}
			}
		}
	}

	event OnCreateOneliner( target : CEntity, value : string, ID : int )
	{
		var oneliner : OnelinerDefinition;
		
		//modFriendlyHUD begin
		//theGame.witcherLog.AddMessage( "SHOW " + ID + ": " + value + " [" + target.GetName() + "]" );
		if( modMarkers.IsValidID(ID) )
			return true;
		//modFriendlyHUD end
		
		LogChannel( 'Oneliner', "SHOW " + ID + ": " + value + " [" + target.GetName() + "]" );

		if( ( theGame.isDialogDisplayDisabled || !m_hud.IsOnelinersModuleEnabled() ) ) //modFriendlyHUD
		{
			value = "";
		}
		oneliner.m_Target = target; //modFriendlyHUD
		oneliner.m_Text = value;
		oneliner.m_ID = ID;
		
		m_oneliners.PushBack(oneliner);
		
		m_fxCreateOnelinerSFF.InvokeSelfTwoArgs(FlashArgInt(ID),FlashArgString(value));
	}		
	
	event OnRemoveOneliner( ID : int )
	{
		var i : int;

		LogChannel( 'Oneliner', "HIDE " + ID );

		for( i = 0; i < m_oneliners.Size(); i += 1 )
		{
			if( m_oneliners[i].m_ID == ID )
			{
				m_oneliners.Erase(i);
				m_fxRemoveOnelinerSFF.InvokeSelfOneArg(FlashArgInt(ID));
				return true;
			}
		}
	}
	
	//modFriendlyHUD begin
	public function FXGetOneliner( ID : int ) : CScriptedFlashSprite
	{
		return m_flashModule.GetChildFlashSprite( "mcOneliner" + ID );
	}

	public function FXGetOnelinerText( ID : int ) : CScriptedFlashTextField
	{
		return m_flashModule.GetChildFlashTextField( "mcOneliner" + ID );
	}

	public function FXCreateOneliner( value : string, ID : int )
	{
		m_fxCreateOnelinerSFF.InvokeSelfTwoArgs(FlashArgInt(ID),FlashArgString(value));
	}

	public function FXRemoveOneliner( ID : int )
	{
		m_fxRemoveOnelinerSFF.InvokeSelfOneArg(FlashArgInt(ID));
	}

	public function SignalCache3DMarkers( questPins : bool )
	{
		return modMarkers.SignalCache3DMarkers( questPins );
	}
	//modFriendlyHUD end

	private function IsTargetCloseEnough( target : CEntity ) : bool //modFriendlyHUD
	{
		return VecDistanceSquared( target.GetWorldPosition(), thePlayer.GetWorldPosition() ) < VISIBILITY_DISTANCE_SQUARED;
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{
		return false;
	}
}

exec function sayoneliner( value : string, id : int )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleOneliners;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
	module.OnCreateOneliner( GetWitcherPlayer(), value, id );
}

exec function sayoneliner2( tag : name, value : string, id : int )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleOneliners;
	var entity : CEntity;

	entity = theGame.GetEntityByTag( tag );
	if ( entity )
	{
		hud = (CR4ScriptedHud)theGame.GetHud();
		module = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
		module.OnCreateOneliner( entity, value, id );
	}
}

exec function removeoneliner( id : int )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleOneliners;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleOneliners)hud.GetHudModule("OnelinersModule");
	module.OnRemoveOneliner( id );
}
