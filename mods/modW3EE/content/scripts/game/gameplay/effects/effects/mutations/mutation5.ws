/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Mutation5 extends CBaseGameplayEffect
{
	default effectType = EET_Mutation5;
	default isPositive = true;
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
	}
}