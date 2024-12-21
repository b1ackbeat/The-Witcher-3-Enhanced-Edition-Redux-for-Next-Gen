/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



import class CPeristentEntity extends CEntity
{
	import public var idTag : IdTag; // -= WMK:modAQOOM =-

	event OnBehaviorSnaphot() { return false; }
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
}