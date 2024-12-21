/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3BlindnessEffect extends W3CriticalEffect
{
	var envID 							: int;
	var fxEntity 						: CEntity;
	
	default criticalStateType 	= ECST_Blindness;
	default effectType 			= EET_Blindness;
	default resistStat 			= CDS_WillRes;
	default attachedHandling 	= ECH_Abort;
	default onHorseHandling 	= ECH_Abort;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		//blockedActions.PushBack(EIAB_Fists);
		//blockedActions.PushBack(EIAB_Jump);
		//blockedActions.PushBack(EIAB_RunAndSprint);
		//blockedActions.PushBack(EIAB_ThrowBomb);
		//blockedActions.PushBack(EIAB_Crossbow);
		//blockedActions.PushBack(EIAB_UsableItem);
		//blockedActions.PushBack(EIAB_Parry);
		//blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		//blockedActions.PushBack(EIAB_Counter);
		//blockedActions.PushBack(EIAB_QuickSlots);
		
		
		
		
		
		
		
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var template : CEntityTemplate;
		var environment : CEnvironmentDefinition;	
		
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer)
		{
			if(!theSound.SoundIsBankLoaded("feverflash.bnk"))
				theSound.SoundLoadBank("feverflash.bnk", false);
			theSound.SoundEvent("play_feverflash");
		
			thePlayer.HardLockToTarget( false );
			
			DisableCatViewFx( 0.5f );
			
			template = (CEntityTemplate)LoadResource("bies_fx");
			fxEntity = theGame.CreateEntity(template,thePlayer.GetWorldPosition());
			if ( fxEntity )
			{
				fxEntity.CreateAttachment(thePlayer);
				
				
				fxEntity.DestroyAfter(duration);
			}
			
			environment = (CEnvironmentDefinition)LoadResource("env_bies_hypnotize");
    		envID = ActivateEnvironmentDefinition( environment, 1000, 1, 1.f );
    		theGame.SetEnvironmentID(envID);
		}
	}
	
	event OnEffectRemoved()
	{
		if( isOnPlayer )
		{
			theSound.SoundEvent("stop_feverflash");
			DeactivateEnvironment( envID, 1 );
		}
		super.OnEffectRemoved();
	}
}