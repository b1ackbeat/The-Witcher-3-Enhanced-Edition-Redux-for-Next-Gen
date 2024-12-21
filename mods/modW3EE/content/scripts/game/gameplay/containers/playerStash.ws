/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Stash extends CInteractiveEntity
{
	editable var forceDiscoverable : bool;	default forceDiscoverable = false;

	event OnInteraction( actionName : string, activator : CEntity )
	{
		//Kolaris - Fixed Stashes
		if(activator != thePlayer)
			return false;
			
		theGame.GameplayFactsAdd("inFixedStash", 1);
		thePlayer.GetInputHandler().PushStashScreen();
	}
	
	public function  IsForcedToBeDiscoverable() : bool
	{
		return false;
	}
}