/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_ToxicityVenom extends CBaseGameplayEffect
{
	default effectType = EET_ToxicityVenom;
	default isNegative = true;
	default dontAddAbilityOnTarget = false;
	
	private var poisonTimer : float;
	event OnUpdate( dt : float )
	{
		var toxToAdd : float;
		
		super.OnUpdate( dt );
		
		poisonTimer += dt;
		if( poisonTimer >= 1.f )
		{
			poisonTimer = 0.f;
			target.ApplyPoisoning(1, creator, "Poisoning");
		}
	}
}