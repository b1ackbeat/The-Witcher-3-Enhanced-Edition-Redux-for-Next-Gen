/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

// W3EE - Begin
class W3Effect_SlowdownFrost extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;
	private var npc : CNewNPC;
	private var isFreeze : bool;
	private var currentFreezeDuration : float;
	private const var freezeDuration : float;
	private var slowdownUpdateDelay : float;
	
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_SlowdownFrost;
	default attributeName = 'slowdownFrost';
	default resistStat = CDS_FrostRes;
	default isFreeze = false;
	default freezeDuration = 3.f;
	default slowdownUpdateDelay = 1.f;
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		npc = (CNewNPC)target;
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
		if(isFreeze)
		{
			effectManager.ResumeAllRegenEffects('FrozenEffect');
			target.FreezeCloth( false );
		}
		super.OnEffectRemoved();
	}
		
	event OnEffectAddedPost()
	{
		var action : W3DamageAction;
		if( !npc.IsFlying() && target.CountEffectsOfType(EET_SlowdownFrost) > 1 )
		{
			slowdownCauserId = target.SetAnimationSpeedMultiplier( 0 );
			isFreeze = true;
			currentFreezeDuration = 0.f;
			effectManager.PauseAllRegenEffects('FrozenEffect');
			action = new W3DamageAction in theGame.damageMgr;
			action.Initialize(thePlayer, npc, this, 'chilled', EHRT_None, CPS_Undefined, false, false, false, false);
			action.AddDamage( theGame.params.DAMAGE_NAME_FROST, 800 );
			theGame.damageMgr.ProcessAction( action );
			target.FreezeCloth( true );
			PlayFrostFX(3);
		}
		else
			slowdownCauserId = target.SetAnimationSpeedMultiplier( 0.9 );
		
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
	
	public function OnTimeUpdated(dt : float)
	{
		if(isFreeze)
		{
			super.OnTimeUpdated(dt);
			
			currentFreezeDuration += dt;
			if(currentFreezeDuration > freezeDuration)
			{
				target.RemoveBuff(EET_SlowdownFrost);
			}
		}
		else
		{
			if( IsAddedByPlayer() && (GetWitcherPlayer().HasAbility('Runeword 5 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 6 _Stats', true)) && target != thePlayer )
			{
				if( slowdownUpdateDelay >= 1.f )
				{
					target.ResetAnimationSpeedMultiplier(slowdownCauserId);
					slowdownCauserId = target.SetAnimationSpeedMultiplier( 0.9 - (0.4f * (1.f - target.GetStatPercents(BCS_Stamina))));
					slowdownUpdateDelay = 0;
				}
				else
					slowdownUpdateDelay += dt;
			}
			
			super.OnTimeUpdated(dt);
		}
	}
	
	private function PlayFrostFX( duration : float )
	{
		var ent, fx : CEntity;
		var entityTemplate : CEntityTemplate;
		var rot : EulerAngles;
		var pos, basePos : Vector;
		var i : int;
		var angle, radius : float;
		
		npc.PlayEffect('critical_frozen');
		npc.AddTimer('StopMutation6FX', duration);
		
		fx = npc.CreateFXEntityAtPelvis('mutation2_critical', true);
		fx.PlayEffect('critical_aard');
		fx.PlayEffect('critical_aard');
		fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
		fx.PlayEffect('mutation_1_hit_aard');
		fx.PlayEffect('mutation_1_hit_aard');
		
		theGame.GetSurfacePostFX().AddSurfacePostFXGroup( target.GetWorldPosition(), 0.3f, 0.1, 3.f, 3.f, 0 );
	}
}
// W3EE - End