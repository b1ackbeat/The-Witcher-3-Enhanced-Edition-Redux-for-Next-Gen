/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Mutation7BaseEffect extends CBaseGameplayEffect
{
	protected var actors : array<CActor>;
	protected var actorsCount : int;
	protected var apBonus : float;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var i : int;
		
		super.OnEffectAdded();
		
		actors = GetActorsInRange( target, 30, 50, '', true );
		
		for(i = actors.Size() - 1; i >= 0; i -= 1)
		{
			if( GetAttitudeBetween( target, actors[i] ) != AIA_Hostile )
			{
				actors.Erase(i);
			}
		}
		
		actorsCount = actors.Size();
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	event OnUpdate(deltaTime : float)
	{
		super.OnUpdate( deltaTime );
	}
	
	public function GetStacks() : int
	{
		return (int)( ( actorsCount - 1 ) * 100 * apBonus );
	}
}