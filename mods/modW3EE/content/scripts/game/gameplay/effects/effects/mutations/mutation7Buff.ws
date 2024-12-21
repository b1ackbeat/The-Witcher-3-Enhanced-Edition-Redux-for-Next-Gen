/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Mutation7Buff extends W3Mutation7BaseEffect
{
	default effectType = EET_Mutation7Buff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded( customParams );
		
		target.AddAbilityMultiple( 'Mutation7Buff', actorsCount - 1 );
		target.SoundEvent( 'ep2_mutations_07_berserk_buff' );
	}
	
	event OnUpdate(deltaTime : float)
	{
		super.OnUpdate( deltaTime );
	}
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation7Buff', 'attack_power', min, max );
		apBonus = min.valueMultiplicative;
	}
	
	event OnEffectRemoved()
	{
		target.RemoveAbilityAll( 'Mutation7Buff' );
		
		super.OnEffectRemoved();		
	}
}