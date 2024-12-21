/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




import class CCommunitySystem extends IGameSystem
{
	import var communitySpawnInitializer : ISpawnTreeInitializerAI;
	
	// -= WMK:modAQOOM =-
	// Added this "global" here because is unlikely that this file is changed by any other mods.
	public var wmkMapMenu : WmkMapMenu;
	// -= WMK:modAQOOM =-

	function Init()
	{
		communitySpawnInitializer = new ISpawnTreeInitializerCommunityAI in this;
		communitySpawnInitializer.Init();
	}
};



import function DumpCommunityAgentsCPP();
exec function DumpCommunityAgents()
{
	DumpCommunityAgentsCPP();
}