/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Oil extends CBaseGameplayEffect
{
	protected saved var currCount : float;			
	protected saved var maxCount : float;			
	protected saved var sword : SItemUniqueId;	
	protected saved var oilAbility : name;		
	protected saved var oilItemName : name;		
	protected saved var queueTimer : int;
	protected saved var meditationApplied : bool;
	protected var isEffectPaused : bool;
	protected var secondsToExpire : int;
	protected var tickTimer : float;
	
	default effectType = EET_Oil;
	default isPositive = true;
	default dontAddAbilityOnTarget = true;
	default queueTimer = 0;
	default meditationApplied = false;
	default isEffectPaused = false;
	default secondsToExpire = 1200;
	default tickTimer = 0;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var oilParams : W3OilBuffParams;
		
		
		oilParams = (W3OilBuffParams)customParams;
		if(oilParams)
		{
			iconPath = oilParams.iconPath;
			effectNameLocalisationKey = oilParams.localizedName;
			effectDescriptionLocalisationKey = oilParams.localizedDescription;
			currCount = oilParams.currCount;
			maxCount = oilParams.maxCount;
			sword = oilParams.sword;
			oilAbility = oilParams.oilAbilityName;
			oilItemName = oilParams.oilItemName;
			meditationApplied = GetWitcherPlayer().IsMeditating();
		}
		
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( deltaTime : float )
	{
		if( !isEffectPaused )
		{
			tickTimer += deltaTime;
			if( tickTimer >= 2.f )
			{
				currCount -= maxCount / secondsToExpire * 2.f;
				tickTimer = 0;
				//Kolaris - Oil Passive Drain Fix
				if( currCount <= 0 )
					target.RemoveEffect(this);
			}
		}
	}
	
	event OnEffectRemoved()
	{
		
		if( ShouldProcessTutorial( 'TutorialAlchemyRefill' ) && FactsQuerySum( "q001_nightmare_ended" ) > 0 && target == GetWitcherPlayer() )
		{
			FactsAdd( 'tut_alch_refill', 1 );
		}
		
		
		target.GetInventory().RemoveItemCraftedAbility( sword, oilAbility );
		
		Show( false );
		
		super.OnEffectRemoved();
	}
	
	event OnEffectAddedPost()
	{
		var swordEquipped : bool;
		var swordEntity : CWitcherSword;
		
		
		target.GetInventory().AddItemCraftedAbility( sword, oilAbility );
		
		swordEquipped = GetWitcherPlayer().IsItemEquipped( sword );
		if(swordEquipped)
		{
			
			target.AddAbility( oilAbility );
			
			
			swordEntity = (CWitcherSword) target.GetInventory().GetItemEntityUnsafe( sword );
			swordEntity.ApplyOil( oilAbility );
		}
		
		UpdateOilsQueue();
	}
	
	public function GetAbilityName() : name
	{
		return oilAbility;
	}
	
	public function WasMeditationApplied() : bool
	{
		return meditationApplied;
	}
	
	protected function Show( visible : bool )
	{
		var swordEntity : CWitcherSword;
		
		if( visible )
		{
			if( !GetWitcherPlayer().IsItemHeld( sword ) )
			{
				return;
			}
		}
		
		showOnHUD = visible;
		
		
		swordEntity = (CWitcherSword) target.GetInventory().GetItemEntityUnsafe( sword );		
		if( visible )
		{
			swordEntity.ApplyOil( oilAbility );
		}
		else
		{
			swordEntity.RemoveOil( oilAbility );
		}	
	}
	
	protected function OnResumed()
	{
		if( currCount > 0 )
		{
			Show( true );
			isEffectPaused = false;
		}
	}
	
	protected function OnPaused()
	{
		Show( false );
		isEffectPaused = true;
	}
	
	public final function Reapply( newMax : int )
	{
		maxCount = newMax;
		currCount = newMax;
		meditationApplied = GetWitcherPlayer().IsMeditating();
		
		queueTimer = 0;
		UpdateOilsQueue();
		
		
		if( !IsPaused( '' ) )
		{
			Show( true );
		}
	}
	
	private final function UpdateOilsQueue()
	{
		var otherOils : array< W3Effect_Oil >;
		var i : int;
		
		otherOils = target.GetInventory().GetOilsAppliedOnItem( sword );
		otherOils.Remove( this );
		
		for( i=0; i<otherOils.Size(); i+=1 )
		{
			otherOils[i].IncreaseQueueTimer();
		}
	}
	
	public final function IncreaseQueueTimer()
	{
		queueTimer += 1;
	}
	
	public final function GetQueueTimer() : int
	{
		return queueTimer;
	}
	
	protected function CumulateWith( effect : CBaseGameplayEffect )
	{
		var oldCount : float;
		
		oldCount = currCount;
		
		super.CumulateWith( effect );
		
		if( oldCount <= 0 && currCount > 0 && !IsPaused( '' ) && !showOnHUD )
		{
			Show( true );
		}
	}
	
	public final function ReduceAmmo( isHeavyAttack : bool )
	{
		var drainAmount : float;
		
		drainAmount = RandRangeF(1.3f, 0.4f);
		if( isHeavyAttack )
			drainAmount *= 1.5f;
		
		//Kolaris - Prolongation
		if( GetWitcherPlayer().HasAbility('Runeword 37 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 38 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 39 _Stats', true) )
			drainAmount *= 0.5f;
		
		//Kolaris - Tiger Set
		if( GetWitcherPlayer().IsSetBonusActive(EISB_Tiger_2) && GetWitcherPlayer().HasBuff(EET_AlbedoDominance) )
			drainAmount *= 0.5f;
		
		if( currCount - drainAmount <= 0 )
		{
			Show( false );
		}
		
		currCount = MaxF( 0, currCount - drainAmount );
		
		if( currCount <= 0 )
			target.RemoveEffect(this);
	}
	
	public final function GetAmmoMaxCount() : int
	{
		return CeilF(maxCount);
	}

	public final function GetAmmoCurrentCount() : int
	{
		return CeilF(currCount);
	}

	public final function GetAmmoPercentage() : float
	{
		return currCount / maxCount;
	}
	
	public final function GetSwordItemId() : SItemUniqueId
	{
		return sword;
	}
	
	public final function GetOilItemName() : name
	{
		return oilItemName;
	}
	
	public final function GetOilAbilityName() : name
	{
		return oilAbility;
	}
	
	// W3EE - Begin
		/*
	public final function GetMonsterCategory() : EMonsterCategory
	{
		var i : int;
		var mcType : EMonsterCategory;
		var attributes : array< name >;
		
		theGame.GetDefinitionsManager().GetAbilityAttributes( oilAbility, attributes );
		
		for( i=0; i<attributes.Size(); i+=1 )
		{
			mcType = MonsterCriticalDamageBonusToCategory(attributes[i]);
			if( mcType == MC_NotSet )
				mcType = MonsterResistReductionToCategory(attributes[i]);
				
			if( mcType != MC_NotSet )
			{
				return mcType;
			}
		}
		return MC_NotSet;
	}
		*/	
	// W3EE - End
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var otherLevel, selfLevel : int;
		var oilTypeSelf, oilTypeOther : string;
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var otherBuff : W3Effect_Oil;
	
		otherBuff = ( W3Effect_Oil ) e;		
		oilTypeSelf = StrLeft( oilItemName, StrLen( oilItemName ) - 2 );
		oilTypeOther = StrLeft( otherBuff.oilItemName, StrLen( otherBuff.oilItemName ) - 2 );
		
		if(oilTypeSelf != oilTypeOther)
		{
			return EI_Pass;
		}
		
		
		dm = theGame.GetDefinitionsManager();
		dm.GetItemAttributeValueNoRandom( oilItemName, true, 'level', min, max );
		selfLevel = RoundMath( CalculateAttributeValue( min ) );
		
		dm.GetItemAttributeValueNoRandom( otherBuff.oilItemName, true, 'level', min, max );
		otherLevel = RoundMath( CalculateAttributeValue( min ) );
		
		if( otherLevel >= selfLevel)
		{
			return EI_Override;
		}

		return EI_Deny;
	}
}

class W3OilBuffParams extends W3BuffCustomParams
{
	var iconPath : string;
	var localizedName : string;
	var localizedDescription : string;
	var currCount : int;
	var maxCount : int;
	var sword : SItemUniqueId;
	var oilAbilityName : name;
	var oilItemName : name;
}