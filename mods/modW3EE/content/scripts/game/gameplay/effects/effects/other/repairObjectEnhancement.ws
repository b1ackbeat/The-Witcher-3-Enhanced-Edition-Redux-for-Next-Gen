/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3EnhanceBuffParams extends W3BuffCustomParams
{
	var item : SItemUniqueId;
}

abstract class W3RepairObjectEnhancement extends CBaseGameplayEffect
{
	protected saved var curCount : float;
	protected saved var maxCount : float;
	protected saved var item : SItemUniqueId;
	protected var isEffectPaused : bool;
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	default isEffectPaused = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var dm : CDefinitionsManagerAccessor;		
		var enhanceParams : W3EnhanceBuffParams;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, 'ammo', min, max);
		curCount = min.valueAdditive;
		maxCount = min.valueAdditive;
		
		enhanceParams = (W3EnhanceBuffParams)customParams;
		if(enhanceParams)
		{
			item = enhanceParams.item;
			target.GetInventory().AddItemTag(item, 'ItemEnhanced');
		}
		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectAddedPost()
	{
		var armorBuff : bool;
		
		armorBuff = (W3Effect_EnhancedArmor)this;
		if( (armorBuff && !((W3PlayerWitcher)target).IsItemEquipped(item)) || (!armorBuff && !target.GetInventory().IsItemHeld(item)) )
			Show(false);
		else
		if( !target.GetInventory().ItemHasTag(item, 'ItemEnhanced') )
			target.GetInventory().AddItemTag(item, 'ItemEnhanced');
	}
	
	event OnEffectRemoved()
	{
		Show(false);
		super.OnEffectRemoved();
	}
	
	protected function Show( visible : bool )
	{
		if( visible )
		{
			if( !GetWitcherPlayer().IsItemEquipped(item) )
				return;
				
			if( !target.GetInventory().ItemHasTag(item, 'ItemEnhanced') )
				target.GetInventory().AddItemTag(item, 'ItemEnhanced');
		}
		else target.GetInventory().RemoveItemTag(item, 'ItemEnhanced');
		
		showOnHUD = visible;
	}
	
	protected function CumulateWith( effect : CBaseGameplayEffect )
	{
		var oldCount : float;
		
		oldCount = curCount;
		curCount = maxCount;
		super.CumulateWith(effect);
		if( oldCount <= 0 && curCount > 0 && !IsPaused('') && !showOnHUD )
			Show(true);
	}
	
	protected function OnResumed()
	{
		var shouldContinue : bool;
		
		if( (W3Effect_EnhancedArmor)this && ((W3PlayerWitcher)target).IsItemEquipped(item) )
			shouldContinue = true;
		if( (W3Effect_EnhancedWeapon)this && target.GetInventory().IsItemHeld(item) )
			shouldContinue = true;
			
		if( curCount > 0 && shouldContinue )
		{
			Show(true);
			isEffectPaused = false;
		}
		else Pause('', true);
	}
	
	protected function OnPaused()
	{
		Show(false);
		isEffectPaused = true;
	}
	
	public function ReduceAmmo( isHeavyAttack : bool, optional oilPercent : float )
	{
		var drainAmount, bonusDurability : float;
		
		drainAmount = RandRangeF(1.3f, 0.4f);
		if( isHeavyAttack )
			drainAmount *= 2.f;
		//Kolaris - Advanced Maintenance
		if( ((W3PlayerWitcher)target).CanUseSkill(S_Perk_18) )
			drainAmount *= 0.5f;
		//Kolaris - Prolongation
		if( ((W3PlayerWitcher)target).HasAbility('Runeword 37 _Stats', true) || ((W3PlayerWitcher)target).HasAbility('Runeword 38 _Stats', true) || ((W3PlayerWitcher)target).HasAbility('Runeword 39 _Stats', true) )
			drainAmount *= 0.5f;
		
		bonusDurability = CalculateAttributeValue( target.GetInventory().GetItemAttributeValue( item, 'indestructible' ) );
		drainAmount *= 1.f / (1.f + bonusDurability);
		
		//Kolaris - Fixative
		if( oilPercent > 0.f )
			drainAmount *= 1.f - (0.2f * ((W3PlayerWitcher)target).GetSkillLevel(S_Alchemy_s05) * oilPercent);
		
		if( curCount - drainAmount <= 0 )
			Show(false);
			
		curCount = MaxF(0, curCount - drainAmount);
		if( curCount <= 0 )
			target.RemoveEffect(this);
	}
	
	public function Reapply( newMax : int )
	{
		maxCount = newMax;
		curCount = newMax;
		if( !IsPaused('') )
			Show(true);
	}
	
	public function GetItemID() : SItemUniqueId
	{
		return item;
	}
	
	public function GetAmmoMaxCount() : float
	{
		return 100.f;
	}

	public function GetAmmoCurrentCount() : float
	{
		return (curCount / maxCount);
	}

}