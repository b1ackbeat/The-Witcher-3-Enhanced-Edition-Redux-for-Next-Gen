/********************************************
Make Sure to give modReduxW3EE priority over modW3EE in Script Merger
********************************************/

exec function anim( n : name )
{
	GetWitcherPlayer().ActionPlaySlotAnimationAsync('PLAYER_SLOT', n, 0, 0);
}

exec function animnpc( n : name )
{
	GetWitcherPlayer().GetTarget().ActionPlaySlotAnimationAsync('GAMEPLAY_SLOT', n, 0, 0);
}

exec function stagr()
{
	GetWitcherPlayer().GetTarget().AddEffectDefault(EET_LongStagger, GetWitcherPlayer(), "test");
}

exec function ayylmao()
{
	thePlayer.GetTarget().ApplyBleeding(1, thePlayer, "Bleeding", true);
}

exec function ayylmao2()
{
	GetWitcherPlayer().GotoState('Exploration');
}

exec function dumpallquests()
{
	var manager : CWitcherJournalManager;
	var questPhase : CJournalQuestPhase;
	var allQuests : array<CJournalBase>;
	var objective : CJournalQuestObjective;
	var objectiveTag : string;
	var aQuest : CJournalQuest;
	var i, j, k : int;

	theGame.GetJournalManager().GetActivatedOfType( 'CJournalQuest', allQuests );
	for( i = 0; i < allQuests.Size(); i += 1 )
	{
		aQuest = ((CJournalQuest)allQuests[i]);
		LogChannel(' ', " ");
		LogChannel('QUEST BULLSHIT', "Quest: " + aQuest.GetUniqueScriptTag());
		for( j = 0; j < aQuest.GetNumChildren(); j += 1 )
		{
			questPhase = (CJournalQuestPhase)aQuest.GetChild(j);
			if( questPhase )
			{				
				for( k = 0; k < questPhase.GetNumChildren(); k += 1 )
				{
					objective = (CJournalQuestObjective)questPhase.GetChild(k);
					objectiveTag = NameToString(objective.GetUniqueScriptTag());
					LogChannel('QUEST BULLSHIT', "     Objective: " + objectiveTag);
				}
			}
		}
	}
}

exec function ForceBolts()
{
	GetWitcherPlayer().GetInventory().AddAndEquipItem('Bodkin Bolt', EES_Bolt, 25);
}