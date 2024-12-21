/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CR4HudModuleBuffs extends CR4HudModuleBase
{
	private var _currentEffects : array <CBaseGameplayEffect>;
	private var _previousEffects : array <CBaseGameplayEffect>;
	private var _forceUpdate : bool;
	
	private var m_fxSetPercentSFF : CScriptedFlashFunction;
	private var m_fxShowBuffUpdateFx : CScriptedFlashFunction;
	private var m_fxsetViewMode : CScriptedFlashFunction;
	
	private var m_flashValueStorage : CScriptedFlashValueStorage;	
	private var iCurrentEffectsSize : int;	default iCurrentEffectsSize = 0;
	private var bDisplayBuffs : bool; default bDisplayBuffs = true;
	
	private var m_runword5Applied : bool; default m_runword5Applied = false;
	
	
	

	//---=== modFriendlyHUD ===---
	private var showKeys : bool; default showKeys = false;
	//---=== modFriendlyHUD ===---
	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorBuffs";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();
		
		flashModule = GetModuleFlash();	
		m_fxSetPercentSFF				= flashModule.GetMemberFlashFunction( "setPercent" );
		m_fxShowBuffUpdateFx			= flashModule.GetMemberFlashFunction( "showBuffUpdateFx" );
		m_fxsetViewMode 				= flashModule.GetMemberFlashFunction( "setViewMode" );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('BuffsModule', true);
		}
	}

	function ForceUpdate()
	{
		_forceUpdate = true;
	}
	
	event OnTick( timeDelta : float )
	{
		var effectsSize : int;
		var effectArray : array< CBaseGameplayEffect >;
		var i : int;
		var offset : int;
		var duration : float;
		var extraValue : int;
		var initialDuration : float;
		var hasRunword5 : bool;
		var oilEffect : W3Effect_Oil;
		var aerondightEffect	: W3Effect_Aerondight;
		var effectType : EEffectType;
		
		// W3EE - Begin
		var WolvenEffect : W3Effect_WolfSetParry;
		var BleedingEffect : W3Effect_Bleeding;
		var PoisonEffect : W3Effect_Poison;
		var WinterBladeEffect : W3Effect_WinterBlade;
		var PhantomWeaponEffect : W3Effect_PhantomWeapon;
		var CombatAdrEffect : W3Effect_CombatAdrenaline;
		var DimeritiumSetEffect : W3Effect_DimeritiumCharge;
		var EnhanceEffect : W3RepairObjectEnhancement;
		// W3EE - End
		//Kolaris - Gaunter Mode
		var DeathCounterEffect : W3Effect_DeathCounter;
		//Kolaris - Enchantment Overhaul
		var PerfectionEffect : W3Effect_GlyphwordPerfection;
		var ObliterationEffect : W3Effect_RunewordObliteration;
		var ElectrocutionEffect : W3Effect_RunewordElectrocution;
		
		//---=== modFriendlyHUD ===---
		UpdateFadeOut( timeDelta );
		
		if ( !CanTick( timeDelta ) || showKeys )
		//---=== modFriendlyHUD ===---
			return true;

		_previousEffects = _currentEffects;
		_currentEffects.Clear();
		
		if( bDisplayBuffs && GetEnabled() )
		{		
			offset = 0;
			
			effectArray = thePlayer.GetCurrentEffects();
			effectsSize = effectArray.Size();
			hasRunword5 = false;
			
			for ( i = 0; i < effectsSize; i += 1 )
			{
				if(effectArray[i].ShowOnHUD() && effectArray[i].GetEffectNameLocalisationKey() != "MISSING_LOCALISATION_KEY_NAME" )
				{	
					
					initialDuration = effectArray[i].GetInitialDurationAfterResists();
					
					// W3EE - Begin
					/*if ( (W3RepairObjectEnhancement)effectArray[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
					{
						hasRunword5 = true;
						
						if (!m_runword5Applied)
						{
							m_runword5Applied = true;
							UpdateBuffs();
							break;
						}
					}*/
					// W3EE - End

					effectType = effectArray[i].GetEffectType();

					if( initialDuration < 1.0)
					{
						initialDuration = 1;
						duration = 1;
					}
					else
					{
						duration = effectArray[i].GetDurationLeft();
						if ( thePlayer.CanUseSkill( S_Perk_14 ) &&
							( effectType == EET_ShrineAxii || 
							  effectType == EET_ShrineIgni || 
							  effectType == EET_ShrineQuen || 
							  effectType == EET_ShrineYrden || 
							  effectType == EET_ShrineAard
							)
						   )
						{
							
							duration = effectArray[i].GetInitialDuration() + 1;
						}
						// W3EE - Begin
						/*
						else if ( effectType == EET_EnhancedWeapon ||
								  effectType == EET_EnhancedArmor )
						{
							if ( GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
							{
								
								duration = effectArray[i].GetInitialDuration() + 1;
							}
						}
						*/
						// W3EE - End
						else
						{
							if(duration < 0.f)
								duration = 0.f;		
						}
					}
					
					if ( effectType == EET_Oil )
					{
						oilEffect = (W3Effect_Oil)effectArray[ i ];
						if ( oilEffect )
						{
							// W3EE - Begin
							duration = CeilF(oilEffect.GetAmmoPercentage() * 100.f);
							initialDuration = 100;
							// W3EE - End
						}
					}					
					else if( effectType == EET_Aerondight )
					{
						aerondightEffect = (W3Effect_Aerondight)effectArray[i];
						if( aerondightEffect )
						{
							initialDuration = aerondightEffect.GetMaxCount();
							duration		= aerondightEffect.GetCurrentCount();
						}
					}
					// W3EE - Begin
					else if( effectType == EET_EnhancedWeapon || effectType == EET_EnhancedArmor )
					{
						EnhanceEffect = (W3RepairObjectEnhancement)effectArray[i];
						if( EnhanceEffect )
						{
							initialDuration = 100;
							duration = CeilF(EnhanceEffect.GetAmmoCurrentCount() * 100.f);
						}
					}
					else if( effectType == EET_WolfSetParry )
					{
						WolvenEffect = (W3Effect_WolfSetParry)effectArray[i];
						if( WolvenEffect )
						{
							initialDuration = WolvenEffect.GetMaxStacks();
							duration = WolvenEffect.GetStacks();
						}
					}
					else if( effectType == EET_Bleeding )
					{
						BleedingEffect = (W3Effect_Bleeding)effectArray[i];
						if( BleedingEffect )
						{
							initialDuration = BleedingEffect.GetMaxStacks();
							duration = BleedingEffect.GetStacks();
						}
					}
					else if( effectType == EET_Poison )
					{
						PoisonEffect = (W3Effect_Poison)effectArray[i];
						if( PoisonEffect )
						{
							initialDuration = PoisonEffect.GetMaxStacks();
							duration = PoisonEffect.GetStacks();
						}
					}
					else if( effectType == EET_WinterBlade )
					{
						WinterBladeEffect = (W3Effect_WinterBlade)effectArray[i];
						if( WinterBladeEffect )
						{
							initialDuration = WinterBladeEffect.GetMaxDisplayCount();
							duration = WinterBladeEffect.GetDisplayCount();
						}
					}
					else if( effectType == EET_PhantomWeapon )
					{
						PhantomWeaponEffect = (W3Effect_PhantomWeapon)effectArray[i];
						if( PhantomWeaponEffect )
						{
							initialDuration = PhantomWeaponEffect.GetMaxDisplayCount();
							duration = PhantomWeaponEffect.GetDisplayCount();
						}
					}
					else if( effectType == EET_CombatAdr )
					{
						CombatAdrEffect = (W3Effect_CombatAdrenaline)effectArray[i];
						if( CombatAdrEffect )
						{
							initialDuration = CombatAdrEffect.GetMaxDisplayCount();
							duration = CombatAdrEffect.GetDisplayCount();
						}
					}
					else if( effectType == EET_DimeritiumCharge )
					{
						DimeritiumSetEffect = (W3Effect_DimeritiumCharge)effectArray[i];
						if( DimeritiumSetEffect )
						{
							initialDuration = DimeritiumSetEffect.GetMaxDisplayCount();
							duration = DimeritiumSetEffect.GetDisplayCount();
						}
					}
					// W3EE - End
					//Kolaris - Gaunter Mode
					else if( effectType == EET_DeathCounter )
					{
						DeathCounterEffect = (W3Effect_DeathCounter)effectArray[i];
						if( DeathCounterEffect )
						{
							initialDuration = DeathCounterEffect.GetMaxDisplayCount();
							duration = DeathCounterEffect.GetDisplayCount();
						}
					}
					//Kolaris - Enchantment Overhaul
					else if( effectType == EET_GlyphwordPerfection )
					{
						PerfectionEffect = (W3Effect_GlyphwordPerfection)effectArray[i];
						if( PerfectionEffect )
						{
							initialDuration = PerfectionEffect.GetMaxDisplayCount();
							duration = PerfectionEffect.GetDisplayCount();
						}
					}
					else if( effectType == EET_RunewordObliteration )
					{
						ObliterationEffect = (W3Effect_RunewordObliteration)effectArray[i];
						if( ObliterationEffect )
						{
							initialDuration = ObliterationEffect.GetMaxDisplayCount();
							duration = ObliterationEffect.GetDisplayCount();
						}
					}
					else if( effectType == EET_RunewordElectrocution )
					{
						ElectrocutionEffect = (W3Effect_RunewordElectrocution)effectArray[i];
						if( ElectrocutionEffect )
						{
							initialDuration = ElectrocutionEffect.GetMaxDisplayCount();
							duration = ElectrocutionEffect.GetDisplayCount();
						}
					}
					else if( effectType == EET_BasicQuen )
					{
						duration = ( ( W3Effect_BasicQuen ) effectArray[i] ).GetStacks();
						initialDuration = ( ( W3Effect_BasicQuen ) effectArray[i] ).GetMaxStacks();
						
					}
					else if( effectType == EET_Mutation3 )
					{						
						duration = ( ( W3Effect_Mutation3 ) effectArray[i] ).GetStacks();
						initialDuration = duration;
					}
					else if( effectType == EET_Mutation4 )
					{						
						duration = ( ( W3Effect_Mutation4 ) effectArray[i] ).GetStacks();
						initialDuration = duration;
					}
					else if( effectType == EET_Mutation7Buff || effectType == EET_Mutation7Debuff )
					{	
						
						extraValue = ( ( W3Mutation7BaseEffect ) effectArray[i] ).GetStacks();
					}
					else if( effectType == EET_Mutation10 )
					{						
						duration = ( ( W3Effect_Mutation10 ) effectArray[i] ).GetStacks();
						initialDuration = duration;
					}
					
					
					if(_currentEffects.Size() < i+1-offset)
					{
						_currentEffects.PushBack(effectArray[i]);
						m_fxSetPercentSFF.InvokeSelfFourArgs( FlashArgNumber(i-offset),FlashArgNumber( duration ), FlashArgNumber( initialDuration ), FlashArgInt( extraValue ) );
					}
					else if( effectArray[i].GetEffectType() == _currentEffects[i-offset].GetEffectType() )
					{
						m_fxSetPercentSFF.InvokeSelfFourArgs( FlashArgNumber(i-offset),FlashArgNumber( duration ), FlashArgNumber( initialDuration ), FlashArgInt( extraValue ) );
					}
					else
					{
						LogChannel('HUDBuffs',i+" something wrong");
					}
				}
				else
				{
					offset += 1;
					
				}
			}
			
			if (!hasRunword5 && m_runword5Applied)
			{
				m_runword5Applied = false;
				UpdateBuffs();
			}
		}

		
		if ( _currentEffects.Size() == 0 && _previousEffects.Size() == 0 )
			return true;

		
		if ( buffListHasChanged(_currentEffects, _previousEffects) || _forceUpdate )
		{
			_forceUpdate = false;
			UpdateBuffs();
		}

	}

	//---=== modFriendlyHUD ===---
	public function ForceUpdatePosition()
	{
		SnapToAnchorPosition();
	}
	
	public function ForceUpdateBuffs()
	{
		UpdateBuffs();
	}
	
	public function SetBuffsPercent( idx : int, duration : float, initialDuration : float )
	{
		m_fxSetPercentSFF.InvokeSelfFourArgs( FlashArgNumber( idx ), FlashArgNumber( duration ), FlashArgNumber( initialDuration ), FlashArgInt( 0 ) );
	}
	
	public function GetTempFlashArray() : CScriptedFlashArray
	{
		return m_flashValueStorage.CreateTempFlashArray();
	}
	
	public function GetTempFlashObject() : CScriptedFlashObject
	{
		return m_flashValueStorage.CreateTempFlashObject();
	}
	
	public function SetBuffsFlashArray( flArray : CScriptedFlashArray )
	{
		m_flashValueStorage.SetFlashArray( "hud.buffs", flArray );
	}
	
	public function ToggleShowKeys( toggle : bool )
	{
		showKeys = toggle;
	}
	//---=== modFriendlyHUD ===---
	
	private function buffListHasChanged( currentEffects : array<CBaseGameplayEffect>, previousEffects : array<CBaseGameplayEffect> ) : bool
	{
		var i : int;
		var currentSize : int = currentEffects.Size();
		var previousSize : int = previousEffects.Size();

		
		if( currentSize != previousSize )
			return true;
		else 
		{
			
			for( i = 0; i < currentSize; i+=1 )
			{
				if ( currentEffects[i] != previousEffects[i] )
					return true;
			}

			
			return false;
		}
	}
	
	public function SetMinimalViewMode( value : bool )
	{
		m_fxsetViewMode.InvokeSelfOneArg(FlashArgBool( value ));
	}

	function UpdateBuffs()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var i 						: int;
		var oilEffect				: W3Effect_Oil;
		var aerondightEffect		: W3Effect_Aerondight;
		var buffDisplayLimit		: int = 18;
		var mut3Buff 				: W3Effect_Mutation3;
		var mut4Buff 				: W3Effect_Mutation4;
		var mut5Buff 				: W3Effect_Mutation5;
		var effectType				: EEffectType;
		var mut7Buff 				: W3Mutation7BaseEffect;
		var mut10Buff 				: W3Effect_Mutation10;
		var buffState				: int;
		var format					: int;
		var quenBuff 				: W3Effect_BasicQuen;

		// W3EE - Begin
		var WolvenEffect : W3Effect_WolfSetParry;
		var BleedingEffect : W3Effect_Bleeding;
		var PoisonEffect : W3Effect_Poison;
		var WinterBladeEffect : W3Effect_WinterBlade;
		var PhantomWeaponEffect : W3Effect_PhantomWeapon;
		var CombatAdrEffect : W3Effect_CombatAdrenaline;
		var DimeritiumSetEffect : W3Effect_DimeritiumCharge;
		var EnhanceEffect : W3RepairObjectEnhancement;
		// W3EE - End
		//Kolaris - Gaunter Mode
		var DeathCounterEffect : W3Effect_DeathCounter;
		//Kolaris - Enchantment Overhaul
		var PerfectionEffect : W3Effect_GlyphwordPerfection;
		var ObliterationEffect : W3Effect_RunewordObliteration;
		var ElectrocutionEffect : W3Effect_RunewordElectrocution;

		l_flashArray = GetModuleFlashValueStorage()().CreateTempFlashArray();
		for(i = 0; i < Min(buffDisplayLimit,_currentEffects.Size()); i += 1) 
		{
			if(_currentEffects[i].ShowOnHUD() && _currentEffects[i].GetEffectNameLocalisationKey() != "MISSING_LOCALISATION_KEY_NAME" )
			{
				if(_currentEffects[i].IsNegative())
				{
					buffState = 0;
				}
				else if ( _currentEffects[i].IsPositive() )
				{
					buffState = 1;
				}
				else if ( _currentEffects[i].IsNeutral() )
				{
					buffState = 2;
				}

				effectType = _currentEffects[i].GetEffectType();

				// W3EE - Begin
				/*
				if ( effectType == EET_Oil && thePlayer.IsSkillEquipped( S_Alchemy_s06 ) )
				{
					
					format = 0;
				}
				//Kolaris - Gaunter Mode, Kolaris - Enchantment Overhaul
				else*/ if ( /*effectType == EET_Oil ||*/ effectType == EET_Aerondight || effectType == EET_BasicQuen || effectType == EET_WinterBlade || effectType == EET_PhantomWeapon || effectType == EET_DimeritiumCharge || effectType == EET_Bleeding || effectType == EET_WolfSetParry || effectType == EET_Poison || effectType == EET_DeathCounter || effectType == EET_GlyphwordPerfection || effectType == EET_RunewordObliteration || effectType == EET_RunewordElectrocution )
				// W3EE - End
				{
					
					format = 1;
				}
				else if ( effectType == EET_Mutation3 || effectType == EET_Mutation4 || effectType == EET_Mutation10 || effectType == EET_Oil || effectType == EET_CombatAdr || effectType == EET_EnhancedArmor || effectType == EET_EnhancedWeapon )
				{
					
					format = 2;
				}
				// W3EE - Begin
				else if ( effectType == EET_Mutation7Buff || effectType == EET_Mutation7Debuff /*|| effectType == EET_BasicQuen*/ )
				// W3EE - End
				{
					
					format = 4;
				}
				else
				{
					
					format = 3;
				}
				
				l_flashObject = m_flashValueStorage.CreateTempFlashObject();
				l_flashObject.SetMemberFlashBool("isVisible",_currentEffects[i].ShowOnHUD());
				l_flashObject.SetMemberFlashString("iconName",_currentEffects[i].GetIcon());
				l_flashObject.SetMemberFlashString("title",GetLocStringByKeyExt(_currentEffects[i].GetEffectNameLocalisationKey()));
				l_flashObject.SetMemberFlashBool("IsPotion",_currentEffects[i].IsPotionEffect());
				l_flashObject.SetMemberFlashInt("isPositive", buffState);
				l_flashObject.SetMemberFlashInt("format", format);
				
				if ( effectType == EET_Oil )
				{	
					oilEffect = (W3Effect_Oil)_currentEffects[i];
					if ( oilEffect )
					{
						// W3EE - Begin
						l_flashObject.SetMemberFlashNumber("duration",        CeilF(oilEffect.GetAmmoPercentage() * 100.f));
						l_flashObject.SetMemberFlashNumber("initialDuration", 100);
						// W3EE - End
					}
				}
				else if( effectType == EET_Aerondight )
				{
					aerondightEffect = (W3Effect_Aerondight)_currentEffects[i];
					if( aerondightEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration",        aerondightEffect.GetCurrentCount() * 1.f );
						l_flashObject.SetMemberFlashNumber("initialDuration", aerondightEffect.GetMaxCount()	 * 1.f );
					}
				}
				// W3EE - Begin
				else if( effectType == EET_EnhancedWeapon || effectType == EET_EnhancedArmor )
				{
					EnhanceEffect = (W3RepairObjectEnhancement)_currentEffects[i];
					if( EnhanceEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", CeilF(EnhanceEffect.GetAmmoCurrentCount() * 100.f));
						l_flashObject.SetMemberFlashNumber("initialDuration", 100);
					}
				}
				else if( effectType == EET_WolfSetParry )
				{
					WolvenEffect = (W3Effect_WolfSetParry)_currentEffects[i];
					if( WolvenEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", WolvenEffect.GetStacks() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", WolvenEffect.GetMaxStacks() * 1.0);
					}
				}
				else if( effectType == EET_Bleeding )
				{
					BleedingEffect = (W3Effect_Bleeding)_currentEffects[i];
					if( BleedingEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", BleedingEffect.GetStacks() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", BleedingEffect.GetMaxStacks() * 1.0);
					}
				}
				else if( effectType == EET_Poison )
				{
					PoisonEffect = (W3Effect_Poison)_currentEffects[i];
					if( PoisonEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", PoisonEffect.GetStacks() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", PoisonEffect.GetMaxStacks() * 1.0);
					}
				}
				else if( effectType == EET_WinterBlade )
				{
					WinterBladeEffect = (W3Effect_WinterBlade)_currentEffects[i];
					if( WinterBladeEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", WinterBladeEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", WinterBladeEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_PhantomWeapon )
				{
					PhantomWeaponEffect = (W3Effect_PhantomWeapon)_currentEffects[i];
					if( PhantomWeaponEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", PhantomWeaponEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", PhantomWeaponEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_CombatAdr )
				{
					CombatAdrEffect = (W3Effect_CombatAdrenaline)_currentEffects[i];
					if( CombatAdrEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", CombatAdrEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", CombatAdrEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_DimeritiumCharge )
				{
					DimeritiumSetEffect = (W3Effect_DimeritiumCharge)_currentEffects[i];
					if( DimeritiumSetEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", DimeritiumSetEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", DimeritiumSetEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_BasicQuen )
				{
					l_flashObject.SetMemberFlashNumber("duration", ( ( W3Effect_BasicQuen ) _currentEffects[i] ).GetStacks() * 1.0);
					l_flashObject.SetMemberFlashNumber("initialDuration", ( ( W3Effect_BasicQuen ) _currentEffects[i] ).GetMaxStacks() * 1.0);
				}
				// W3EE - End
				//Kolaris - Gaunter Mode
				else if( effectType == EET_DeathCounter )
				{
					DeathCounterEffect = (W3Effect_DeathCounter)_currentEffects[i];
					if( DeathCounterEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", DeathCounterEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", DeathCounterEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				//Kolaris - Enchantment Overhaul
				else if( effectType == EET_GlyphwordPerfection )
				{
					PerfectionEffect = (W3Effect_GlyphwordPerfection)_currentEffects[i];
					if( PerfectionEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", PerfectionEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", PerfectionEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_RunewordObliteration )
				{
					ObliterationEffect = (W3Effect_RunewordObliteration)_currentEffects[i];
					if( ObliterationEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", ObliterationEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", ObliterationEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_RunewordElectrocution )
				{
					ElectrocutionEffect = (W3Effect_RunewordElectrocution)_currentEffects[i];
					if( ElectrocutionEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration", ElectrocutionEffect.GetDisplayCount() * 1.0);
						l_flashObject.SetMemberFlashNumber("initialDuration", ElectrocutionEffect.GetMaxDisplayCount() * 1.0);
					}
				}
				else if( effectType == EET_Mutation3 )
				{						
					mut3Buff = ( W3Effect_Mutation3 ) _currentEffects[i];						
					l_flashObject.SetMemberFlashNumber("duration", 			mut3Buff.GetStacks() );
					l_flashObject.SetMemberFlashNumber("initialDuration", 	mut3Buff.GetStacks() );
				}
				else if( effectType == EET_Mutation4 )
				{						
					mut4Buff = ( W3Effect_Mutation4 ) _currentEffects[i];						
					l_flashObject.SetMemberFlashNumber("duration", 			mut4Buff.GetStacks() );
					l_flashObject.SetMemberFlashNumber("initialDuration", 	mut4Buff.GetStacks() );
				}
				// W3EE - Begin
				else if( effectType == EET_Mutation10 )
				{						
					mut10Buff = ( W3Effect_Mutation10 ) _currentEffects[i];						
					l_flashObject.SetMemberFlashNumber("duration", 			mut10Buff.GetStacks() );
					l_flashObject.SetMemberFlashNumber("initialDuration", 	mut10Buff.GetMaxStacks() );
				}
				/*
				else if ( (W3RepairObjectEnhancement)_currentEffects[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
				{
					l_flashObject.SetMemberFlashNumber("duration", -1 );
					l_flashObject.SetMemberFlashNumber("initialDuration", -1 );
				}
				*/
				// W3EE - End
				else
				{
					l_flashObject.SetMemberFlashNumber("duration",_currentEffects[i].GetDurationLeft() );
					l_flashObject.SetMemberFlashNumber("initialDuration", _currentEffects[i].GetInitialDurationAfterResists());
				}
				
				l_flashArray.PushBackFlashObject(l_flashObject);	
			}
		}
		
		m_flashValueStorage.SetFlashArray( "hud.buffs", l_flashArray );
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{
		return true;
	}
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		var tempX				: float;
		var tempY				: float;
		
		l_flashModule 	= GetModuleFlash();
		
		
		
		
		tempX = anchorX + (660.0 * (1.0 - theGame.GetUIHorizontalFrameScale()));
		tempY = anchorY + (645.0 * (1.0 - theGame.GetUIVerticalFrameScale())); 
		
		l_flashModule.SetX( tempX );
		l_flashModule.SetY( tempY );	
	}
	
	event  OnBuffsDisplay( value : bool )
	{
		bDisplayBuffs = value;
	}
	
	public function ShowBuffUpdate() :void
	{
		m_fxShowBuffUpdateFx.InvokeSelf();
	}
	
	public function SetDisplayBuffs( b : bool )
	{
		bDisplayBuffs = b;
	}
}

exec function testBf()
{
	var hud : CR4ScriptedHud;
	hud = (CR4ScriptedHud)theGame.GetHud();
	if (hud)
	{
		hud.ShowBuffUpdate();
	}
}
