/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



struct SAardEffects
{
	editable var baseCommonThrowEffect 				: name;
	editable var baseCommonThrowEffectUpgrade1		: name;
	editable var baseCommonThrowEffectUpgrade2		: name;
	editable var baseCommonThrowEffectUpgrade3		: name;

	editable var throwEffectSoil					: name;
	editable var throwEffectSoilUpgrade1			: name;
	editable var throwEffectSoilUpgrade2			: name;
	editable var throwEffectSoilUpgrade3			: name;
	
	editable var throwEffectSPNoUpgrade				: name;
	editable var throwEffectSPUpgrade1				: name;
	editable var throwEffectSPUpgrade2				: name;
	editable var throwEffectSPUpgrade3				: name;
	
	editable var throwEffectDmgNoUpgrade			: name;
	editable var throwEffectDmgUpgrade1				: name;
	editable var throwEffectDmgUpgrade2				: name;
	editable var throwEffectDmgUpgrade3				: name;
	
	editable var throwEffectWater 					: name;
	editable var throwEffectWaterUpgrade1			: name;
	editable var throwEffectWaterUpgrade2			: name;
	editable var throwEffectWaterUpgrade3			: name;
	
	editable var cameraShakeStrength				: float;
}

struct SAardAspect
{
	editable var projTemplate		: CEntityTemplate;
	editable var cone				: float;
	editable var distance			: float;
	editable var distanceUpgrade1	: float;
	editable var distanceUpgrade2	: float;
	editable var distanceUpgrade3	: float;
}

statemachine class W3AardEntity extends W3SignEntity
{
	editable var aspects		: array< SAardAspect >;
	editable var effects		: array< SAardEffects >;
	editable var waterTestOffsetZ : float;
	editable var waterTestDistancePerc : float;
	
	var projectileCollision 		: array< name >;
	
	default skillEnum = S_Magic_1;
	default waterTestOffsetZ = -2;
	default waterTestDistancePerc = 0.5;
	
		hint waterTestOffsetZ = "Z offset added to Aard Entity when testing for water level";
		hint waterTestDistancePerc = "Percentage of sign distance to use along heading for water test";		
		
	public function GetSignType() : ESignType
	{
		return ST_Aard;
	}
		
	event OnStarted()
	{
		// W3EE - Begin
		var reflexBlastEffect : SCustomEffectParams;
		
		//Kolaris - Acceleration
		if( !isFreeCast && (owner.GetActor().HasAbility('Glyphword 4 _Stats', true) || owner.GetActor().HasAbility('Glyphword 5 _Stats', true) || owner.GetActor().HasAbility('Glyphword 6 _Stats', true)) && owner.GetActor().IsInCombat() )
		{
			if( !owner.GetPlayer().HasBuff(EET_ReflexBlast) )
			{
				reflexBlastEffect.effectType = EET_ReflexBlast;
				reflexBlastEffect.creator = this;
				reflexBlastEffect.sourceName = "AardReflexBlast";
				reflexBlastEffect.customPowerStatValue = GetTotalSignIntensity();
				reflexBlastEffect.isSignEffect = true;
				reflexBlastEffect.duration = -1;
				owner.GetPlayer().AddEffectCustom(reflexBlastEffect);
			}
			else ((W3Effect_ReflexBlast)owner.GetPlayer().GetBuff(EET_ReflexBlast)).StackEffectDuration();
		}
		
		if( IsAlternateCast() )
		{
			if( (CPlayer)owner.GetActor() )
			{
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			}
		}
		// W3EE - End
		else
		{
			super.OnStarted();
		}
		
		projectileCollision.Clear();
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Door' );
		projectileCollision.PushBack( 'Static' );		
		projectileCollision.PushBack( 'Character' );
		projectileCollision.PushBack( 'ParticleCollider' ); 
		
		if ( owner.ChangeAspect( this, S_Magic_s01 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AardCircleCast' );
		}
		else
		{
			GotoState( 'AardConeCast' );
		}
	}

	
	event OnAardHit( sign : W3AardProjectile ) {}

	
	
	
	var processThrow_alternateCast : bool;
	
	protected function ProcessThrow( alternateCast : bool )
	{
		if ( owner.IsPlayer() )
		{
			
			ProcessThrow_MainTick( alternateCast );
		}
		else
		{
			processThrow_alternateCast = alternateCast;
			AddTimer( 'ProcessThrowTimer', 0.00000001f, , , TICK_Main );
		}
	}
	
	timer function ProcessThrowTimer( dt : float, id : int )
	{
		ProcessThrow_MainTick( processThrow_alternateCast );
	}
	
	
	
	public final function GetDistance() : float
	{
		if ( owner.CanUseSkill( S_Magic_s20, this ) )
		{
			switch( CeilF(owner.GetSkillLevel(S_Magic_s20, this) / 2.f) )
			{
				case 1 : return aspects[ fireMode ].distanceUpgrade1;
				case 2 : return aspects[ fireMode ].distanceUpgrade2;
				case 3 : return aspects[ fireMode ].distanceUpgrade3;
			}
		}
		
		return aspects[ fireMode ].distance;
	}
	
	protected function ProcessThrow_MainTick( alternateCast : bool )
	{
		var projectile	: W3AardProjectile;
		var spawnPos, collisionPos, collisionNormal, waterCollTestPos : Vector;
		var spawnRot : EulerAngles;
		var heading : Vector;
		var distance, waterZ, staminaDrain : float;
		var ownerActor : CActor;
		var dispersionLevel : int;
		var attackRange : CAIAttackRange;
		var movingAgent : CMovingPhysicalAgentComponent;
		var hitsWater : bool;
		var collisionGroupNames : array<name>;
		
		ownerActor = owner.GetActor();
		
		if ( owner.IsPlayer() )
		{
			GCameraShake(effects[fireMode].cameraShakeStrength, true, this.GetWorldPosition(), 30.0f);
		}
		
		
		distance = GetDistance();		
		
		if ( owner.HasCustomAttackRange() )
		{
			attackRange = theGame.GetAttackRangeForEntity( this, owner.GetCustomAttackRange() );
		}
		else if( owner.CanUseSkill( S_Magic_s20, this ) )
		{
			dispersionLevel = CeilF(owner.GetSkillLevel(S_Magic_s20, this) / 2.f);
			
			if(dispersionLevel == 1)
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade1' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade1' );
			}
			else if(dispersionLevel == 2)
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade2' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade2' );
			}
			else if(dispersionLevel == 3)
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade3' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade3' );
			}
		}
		else
		{
			if ( !alternateCast )
				attackRange = theGame.GetAttackRangeForEntity( this, 'cone' );
			else
				attackRange = theGame.GetAttackRangeForEntity( this, 'blast' );
		}
		
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		heading = this.GetHeadingVector();
		
		
		
		
		if ( alternateCast )
		{
			spawnPos.Z -= 0.5;
			
			projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos - heading * 0.7, spawnRot );				
			projectile.ExtInit( owner, skillEnum, this );	
			projectile.SetAttackRange( attackRange );
			projectile.SphereOverlapTest( distance, projectileCollision );			
		}
		else
		{			
			spawnPos -= 0.7 * heading;
			
			projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos, spawnRot );				
			projectile.ExtInit( owner, skillEnum, this );							
			projectile.SetAttackRange( attackRange );
			
			projectile.ShootCakeProjectileAtPosition( aspects[fireMode].cone, 3.5f, 0.0f, 30.0f, spawnPos + heading * distance, distance, projectileCollision );			
		}
		
		// W3EE - Begin
		//Kolaris - Shockwave
		/*if( !isFreeCast )
			staminaDrain = 0.05f + 0.05f * owner.GetSkillLevel(S_Magic_s06);*/
		staminaDrain = 0.1f;
		projectile.SetStaminaDrainPerc(staminaDrain);
		// W3EE - End
		
		if(alternateCast)
		{
			movingAgent = (CMovingPhysicalAgentComponent)ownerActor.GetMovingAgentComponent();
			hitsWater = movingAgent.GetSubmergeDepth() < 0;
		}
		else
		{
			waterCollTestPos = GetWorldPosition() + heading * distance * waterTestDistancePerc;			
			waterCollTestPos.Z += waterTestOffsetZ;
			collisionGroupNames.PushBack('Terrain');
			
			
			waterZ = theGame.GetWorld().GetWaterLevel(waterCollTestPos, true);
			
			
			if(theGame.GetWorld().StaticTrace(GetWorldPosition(), waterCollTestPos, collisionPos, collisionNormal, collisionGroupNames))
			{
				
				if(waterZ > collisionPos.Z && waterZ > waterCollTestPos.Z)
					hitsWater = true;
				else
					hitsWater = false;
			}
			else
			{
				
				hitsWater = (waterCollTestPos.Z <= waterZ);
			}
		}
		
		// W3EE - Begin
		if( owner.GetPlayer().IsSwimming() )
		{
			PlayAardFX(hitsWater);
			PlayAardFX(hitsWater);
			PlayAardFX(hitsWater);
			PlayAardFX(hitsWater);
			PlayAardFX(hitsWater);
			PlayAardFX(hitsWater);
		}
		else
		if ( Options().IsAardIntense() )
		{
			PlayAardFX(hitsWater);
			PlayAardFX(hitsWater);
		}
		else PlayAardFX(hitsWater);
		// W3EE - End
		
		ownerActor.OnSignCastPerformed(ST_Aard, alternateCast);
		AddTimer('DelayedDestroyTimer', 0.1, true, , , true);
	}
	
	
	public final function PlayAardFX(hitsWater : bool)
	{
		var dispersionLevel : int;
		var hasFrostAard : bool;
		
		hasFrostAard = owner.CanUseSkill( S_Magic_s12, this );
		
		if ( owner.CanUseSkill( S_Magic_s20, this ) )
		{
			dispersionLevel = CeilF(owner.GetSkillLevel(S_Magic_s20, this) / 2.f);
			
			if(dispersionLevel == 1)
			{			
				
				PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade1 );
			
				
				if(!hasFrostAard)
				{
					if(hitsWater)
						// W3EE - Begin
						if ( Options().IsAardIntense() )
						{
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade1 );
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade1 );
						}
						else
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade1 );
						// W3EE - End
					else
						// W3EE - Begin
						if ( Options().IsAardIntense() )
						{
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade1 );
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade1 );
						}
						else
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade1 );
						// W3EE - End
				}
			}
			else if(dispersionLevel == 2)
			{			
				
				// W3EE - Begin
				if ( Options().IsAardIntense() )
				{
					PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade2 );
					PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade2 );
				}
				else
					PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade2 );
				// W3EE - End
			
				
				if(!hasFrostAard)
				{
					if(hitsWater)
						// W3EE - Begin
						if ( Options().IsAardIntense() )
						{
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade2 );
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade2 );
						}
						else
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade2 );
						// W3EE - End
					else
						// W3EE - Begin
						if ( Options().IsAardIntense() )
						{
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade2 );
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade2 );
						}
						else
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade2 );
						// W3EE - End
				}
			}
			else if(dispersionLevel == 3)
			{			
				
				// W3EE - Begin
				if ( Options().IsAardIntense() )
				{
					PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade3 );
					PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade3 );
				}
				else
					PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade3 );
				// W3EE - End
			
				
				if(!hasFrostAard)
				{
					if(hitsWater)
						// W3EE - Begin
						if ( Options().IsAardIntense() )
						{
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade3 );
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade3 );
						}
						else
							PlayEffect( effects[fireMode].throwEffectWaterUpgrade3 );
						// W3EE - End
					else
						// W3EE - Begin
						if ( Options().IsAardIntense() )
						{
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade3 );
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade3 );
						}
						else
							PlayEffect( effects[fireMode].throwEffectSoilUpgrade3 );
						// W3EE - End
				}
			}
		}
		else
		{
			
			// W3EE - Begin
			if ( Options().IsAardIntense() )
			{
				PlayEffect( effects[fireMode].baseCommonThrowEffect );
				PlayEffect( effects[fireMode].baseCommonThrowEffect );
			}
			else
				PlayEffect( effects[fireMode].baseCommonThrowEffect );
			// W3EE - End
		
			
			if(!hasFrostAard)
			{
				if(hitsWater)
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectWater );
						PlayEffect( effects[fireMode].throwEffectWater );
					}
					else
						PlayEffect( effects[fireMode].throwEffectWater );
					// W3EE - End
				else
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectSoil );
						PlayEffect( effects[fireMode].throwEffectSoil );
					}
					else
						PlayEffect( effects[fireMode].throwEffectSoil );
					// W3EE - End
			}
		}
		
		
		if(owner.GetSkillLevel(S_Magic_s20, this) >= 2)
		{
			
			switch(dispersionLevel)
			{
				case 0:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectSPNoUpgrade );
						PlayEffect( effects[fireMode].throwEffectSPNoUpgrade );
					}
					else
						PlayEffect( effects[fireMode].throwEffectSPNoUpgrade );
					// W3EE - End
					break;
				case 1:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectSPUpgrade1 );
						PlayEffect( effects[fireMode].throwEffectSPUpgrade1 );
					}
					else
						PlayEffect( effects[fireMode].throwEffectSPUpgrade1 );
					// W3EE - End
					break;
				case 2:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectSPUpgrade2 );
						PlayEffect( effects[fireMode].throwEffectSPUpgrade2 );
					}
					else
						PlayEffect( effects[fireMode].throwEffectSPUpgrade2 );
					// W3EE - End
					break;
				case 3:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectSPUpgrade3 );
						PlayEffect( effects[fireMode].throwEffectSPUpgrade3 );
					}
					else
						PlayEffect( effects[fireMode].throwEffectSPUpgrade3 );
					// W3EE - End
					break;
			}
		}
		
		// W3EE - Begin
		if( owner.GetPlayer().IsSwimming() )
		{
			PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
			PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
			PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
		}
		else
		// W3EE - End
		if(owner.CanUseSkill(S_Magic_s06, this))
		{
			
			switch(dispersionLevel)
			{
				case 0:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectDmgNoUpgrade );
						PlayEffect( effects[fireMode].throwEffectDmgNoUpgrade );
					}
					else
						PlayEffect( effects[fireMode].throwEffectDmgNoUpgrade );
					// W3EE - End
					break;
				case 1:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade1 );
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade1 );
					}
					else
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade1 );
					// W3EE - End
					break;
				case 2:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade2 );
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade2 );
					}
					else
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade2 );
					// W3EE - End
					break;
				case 3:
					// W3EE - Begin
					if ( Options().IsAardIntense() )
					{
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
					}
					else
						PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
					// W3EE - End
					break;
			}
		}
		
		if( hasFrostAard )
		{
			//thePlayer.PlayEffect( 'mutation_6_power' );
			
			if( fireMode == 0 )
			{
				PlayEffect( 'cone_ground_mutation_6' );
			}
			else
			{
				PlayEffect( 'blast_ground_mutation_6' );
				theGame.GetSurfacePostFX().AddSurfacePostFXGroup(GetWorldPosition(), 0.3f, 3.f, 2.f, GetDistance(), 0 );
			}
		}
	}
	
	timer function DelayedDestroyTimer(dt : float, id : int)
	{
		var active : bool;
		
		if(owner.CanUseSkill(S_Magic_s20, this))
		{
			switch(CeilF(owner.GetSkillLevel(S_Magic_s20, this) / 2.f))
			{
				case 1 :
					active = IsEffectActive( effects[fireMode].baseCommonThrowEffectUpgrade1 );
					break;
				case 2 :
					active = IsEffectActive( effects[fireMode].baseCommonThrowEffectUpgrade2 );
					break;
				case 3 :
					active = IsEffectActive( effects[fireMode].baseCommonThrowEffectUpgrade3 );
					break;
				default :
					LogAssert(false, "W3AardEntity.DelayedDestroyTimer: S_Magic_s20 skill level out of bounds!");
			}
		}
		else
		{
			active = IsEffectActive( effects[fireMode].baseCommonThrowEffect );
		}
		
		if(!active)
			Destroy();
	}
}

state AardConeCast in W3AardEntity extends NormalCast
{		
	event OnThrowing()
	{
		var player				: CR4Player;
	
		if( super.OnThrowing() )
		{
			parent.ProcessThrow( false );
			
			player = caster.GetPlayer();
			
			if( player )
			{
				parent.ManagePlayerStamina();
				//Kolaris - Griffin Set
				//parent.ManageGryphonSetBonusBuff();
			}
			else
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
			// W3EE - Begin
			if( player )
				Experience().AwardSignXP(parent.GetSignType());
			// W3EE - End
		}
	}
}

state AardCircleCast in W3AardEntity extends NormalCast
{
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.ProcessThrow( true );
			parent.ManagePlayerStamina();
 			Experience().AwardSignXP(parent.GetSignType());
		}
	}
}
