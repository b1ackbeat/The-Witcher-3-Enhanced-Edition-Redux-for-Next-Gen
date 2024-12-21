/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

class W3EECrimeSystemHandler extends W3EEOptionHandler
{
	public function SignalMurder()
	{
		var NPC : CNewNPC;
		var entity : array <CActor>;
		var i : int;
		
		entity = thePlayer.GetNPCsAndPlayersInRange(8);
		for(i=0; i<entity.Size(); i+=1)
		{
			NPC = (CNewNPC)entity[i];
			if( NPC && NPC.GetNPCType() == ENGT_Guard )
			{
				NPC.SetTemporaryAttitudeGroup('hostile_to_player', AGP_Default);
				NPC.SetAttitude(thePlayer, AIA_Hostile);
				NPC.SetTatgetableByPlayer(true);
				NPC.ForceVulnerable();
			}
		}
	}
	
	public final function ForceKillable( NPC : CNewNPC )
	{
		if( NPC.GetNPCType() == ENGT_Guard /*|| NPC.GetNPCType() == ENGT_Commoner*/ )
		{
			NPC.ForceVulnerable();
			NPC.SetAttitude(thePlayer, AIA_Neutral);
			if( NPC.GetNPCType() == ENGT_Commoner )
				NPC.SetTemporaryAttitudeGroup('hostile_to_player', AGP_Default);
		}
	}
	
	public final function SetHostility( NPC : CNewNPC, hostile : bool )
	{
		if( hostile )
		{
			NPC.SetTemporaryAttitudeGroup('hostile_to_player', AGP_Default);
			NPC.SetAttitude(thePlayer, AIA_Hostile);
			NPC.SetTatgetableByPlayer(true);
			NPC.ForceVulnerable();
			if( NPC.GetNPCType() == ENGT_Commoner )
				SetRagdollWeight(NPC, 1.f);
		}
		else
		{
			NPC.ResetTemporaryAttitudeGroup(AGP_Default);
			NPC.ResetAttitude(thePlayer);
		}
	}
	
	function PlayDeathSound( NPC : CNewNPC )
	{
		var npcType : ENPCType;
		
		npcType = GetNPCType(NPC);
		switch ( npcType )
		{
			case ENT_AdultFemale:
				NPC.SoundEvent("grunt_vo_test_scream_AdultFemale", 'head');
				break;
				
			case ENT_ChildMale:
				NPC.SoundEvent("grunt_vo_test_scream_ChildMale", 'head');
				break;
				
			case ENT_ChildFemale:
				NPC.SoundEvent("grunt_vo_test_scream_ChildFemale", 'head');
				break;
				
			default:
				break;
		}
	}
	
	public function SetRagdollWeight( NPC : CNewNPC, weight : float )
	{
		NPC.SetBehaviorVariable('Ragdoll_Weight', weight);
		NPC.RaiseEvent('Ragdoll');
	}
	
	function GetNPCType( NPC : CNewNPC ) : ENPCType
	{
		var voiceTagStr : string;
		
		voiceTagStr = NameToString( NPC.GetVoicetag() );
		if ( StrFindFirst(voiceTagStr, "BOY") >= 0 )
			return ENT_ChildMale;
		else if ( StrFindFirst(voiceTagStr, "GIRL") >= 0 )
			return ENT_ChildFemale;
		else if ( StrFindFirst(voiceTagStr, "WOMAN") >= 0 || StrFindFirst(voiceTagStr, "FEMALE") >= 0 || StrFindFirst(voiceTagStr, "NOBLEWOMAN") >= 0 || StrFindFirst(voiceTagStr, "PROSTITUTE") >= 0 )
			return ENT_AdultFemale;
		else
			return ENT_AdultMale;
	}
	
	public final function InitDeathEvent( NPC : CNewNPC, damageData : W3DamageAction )
	{
		if( ( NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Guard ) && (CPlayer)damageData.attacker )
		{
			PlayDeathSound(NPC);
			SignalMurder();
		}
		else
		if( NPC.GetNPCType() == ENGT_Commoner && !((CPlayer)damageData.attacker) )
		{
			PlayDeathSound(NPC);
		}
	}
}