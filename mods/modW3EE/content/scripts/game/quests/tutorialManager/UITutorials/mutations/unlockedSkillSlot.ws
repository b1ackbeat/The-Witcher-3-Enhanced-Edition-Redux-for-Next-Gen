/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
state MutationsUnlockedSkillSlot in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var LEVEL_UP : name;
	private var isClosing : bool;
	private var selectedMutation : EPlayerMutationType;
	
		default LEVEL_UP = 'TutorialMutationsMasterLevelUp';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		isClosing = false;
	}
		
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseStateHint( LEVEL_UP );
		
		theGame.GetTutorialSystem().MarkMessageAsSeen( LEVEL_UP );
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnMenuClosing( menuName : name )
	{
		QuitState();
	}
	
	event OnTutorialClosed( hintName : name, closedByParentMenu : bool )
	{
		var highlights : array< STutorialHighlight >;
		
		if( closedByParentMenu || isClosing )
		{
			return true;
		}
	}
	
	public final function OnMutationSkillSlotUnlocked()
	{
		ShowHint( LEVEL_UP, POS_MUTATIONS_X, POS_MUTATIONS_Y, ETHDT_Input, GetHighlightsMutationsMaster() );
	}
}