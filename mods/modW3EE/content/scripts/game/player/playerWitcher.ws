/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

statemachine class W3PlayerWitcher extends CR4Player
{		
	private saved var craftingSchematics				: array<name>; 					
	private saved var expandedCraftingCategories		: array<name>;
	private saved var craftingFilters : SCraftingFilters;
	
	
	private saved var alchemyRecipes 					: array<name>; 					
	private saved var expandedAlchemyCategories			: array<name>;
	private saved var alchemyFilters : SCraftingFilters;
	
	// -= WMK:modAQOOM =-
	public saved var wmkMapMenuData : WmkMapMenuData;
	public var wmkMapMenu : WmkMapMenuEx;
	// -= WMK:modAQOOM =-
	
	private saved var expandedBestiaryCategories		: array<name>;
	
	
	private saved var booksRead 						: array<name>; 					
	
	
	private 			var fastAttackCounter, heavyAttackCounter	: int;		
	private				var isInFrenzy : bool;
	private				var hasRecentlyCountered : bool;
	private saved 		var cannotUseUndyingSkill : bool;						
	
	
	protected saved			var amountOfSetPiecesEquipped			: array<int>;
	
	
	public				var canSwitchFocusModeTarget	: bool;
	protected			var switchFocusModeTargetAllowed : bool;
		default canSwitchFocusModeTarget = true;
		default switchFocusModeTargetAllowed = true;
	
	
	private editable	var signs						: array< SWitcherSign >;
	private	saved		var equippedSign				: ESignType;
	private				var currentlyCastSign			: ESignType; default currentlyCastSign = ST_None;
	private				var signOwner					: W3SignOwnerPlayer;
	private				var usedQuenInCombat			: bool;
	public				var yrdenEntities				: array<W3YrdenEntity>;
	public saved		var m_quenReappliedCount		: int;
	public saved		var m_quickInventorySaveData	: WmkQuickInventorySaveData; // -= WMK:modQuickSlots =-
	
	default				equippedSign	= ST_Aard;
	default				m_quenReappliedCount = 1;
	
	
	
	private 			var bDispalyHeavyAttackIndicator 		: bool; 
	private 			var bDisplayHeavyAttackFirstLevelTimer 	: bool; 
	public	 			var specialAttackHeavyAllowed 			: bool;	
	private 			var mutations : bool;
	
	default mutations = false;
	default bIsCombatActionAllowed = true;	
	default bDispalyHeavyAttackIndicator = false; 
	default bDisplayHeavyAttackFirstLevelTimer = true; 
	
	
	
		default explorationInputContext = 'Exploration';
		default combatInputContext = 'Combat';
		default combatFistsInputContext = 'Combat';
		
	
	private saved var companionNPCTag		: name;
	private saved var companionNPCTag2		: name;
	
	private saved var companionNPCIconPath	: string;
	private saved var companionNPCIconPath2	: string;	
		
	
	private 	  saved	var itemSlots					: array<SItemUniqueId>;
	private 			var remainingBombThrowDelaySlot1	: float;
	private 			var remainingBombThrowDelaySlot2	: float;
	private 			var previouslyUsedBolt : SItemUniqueId;				
	private		  saved var questMarkedSelectedQuickslotItems : array< SSelectedQuickslotItem >;
	
	default isThrowingItem = false;
	default remainingBombThrowDelaySlot1 = 0.f;
	default remainingBombThrowDelaySlot2 = 0.f;
	
	
	
	
	
	private saved var tempLearnedSignSkills : array<SSimpleSkill>;		
	public	saved var autoLevel				: bool;						
	
	
	
	
	protected saved var skillBonusPotionEffect			: CBaseGameplayEffect;			
	
	
	public saved 		var levelManager 				: W3LevelManager;
	
	//---=== modFriendlyHUD ===---
	public				var prepDisallowOilsInCombat	: bool;		default prepDisallowOilsInCombat = false;
	public				var prepOilsHaveAmmo			: bool;		default prepOilsHaveAmmo = false;
	//---=== modFriendlyHUD ===---

	
	saved var reputationManager	: W3Reputation;
	
	
	private editable	var medallionEntity			: CEntityTemplate;
	private				var medallionController		: W3MedallionController;
	
	
	
	
	public 				var bShowRadialMenu	: bool;	

	private 			var _HoldBeforeOpenRadialMenuTime : float;
	
	default _HoldBeforeOpenRadialMenuTime = 0.5f;
	
	public var MappinToHighlight : array<SHighlightMappin>;
	
	
	protected saved	var horseManagerHandle			: EntityHandle;		
	

	private var isInitialized : bool;
	private var timeForPerk21 : float;
	
		default isInitialized = false;
		
	
	private var invUpdateTransaction : bool;
		default invUpdateTransaction = false;
	
	
	
	
	
	
	
	//Kolaris - Gaunter Mode
	private saved var DeathCounter : int;
	default DeathCounter = 0;
	//Kolaris - Mutation Rework
	private saved var mutationSpentRed : int;
	private saved var mutationSpentBlue : int;
	private saved var mutationSpentGreen : int;
	public function SetMutationSpentMutagens(itemString : string, quantity : int)
	{
		if(StrContains(itemString, "red"))
			mutationSpentRed += quantity;
		if(StrContains(itemString, "blue"))
			mutationSpentBlue += quantity;
		if(StrContains(itemString, "green"))
			mutationSpentGreen += quantity;
	}
	
	// W3EE - Begin
	private saved var hasFollowerWolf : bool;
	private saved var isWolfFollowing : bool;
	private var followerWolf : CWolfNPC;
	public function GetFollower() : CWolfNPC
	{
		return followerWolf;
	}
	
	public function RemoveFollower()
	{
		hasFollowerWolf = false;
		isWolfFollowing = false;
	}
	
	public function SetIsWolfFollowing( b : bool )
	{
		isWolfFollowing = b;
	}
	
	public function DestroyFollower()
	{
		if( followerWolf )
		{
			followerWolf.Destroy();
			delete followerWolf;
			hasFollowerWolf = false;
			isWolfFollowing = false;
		}
	}
	
	public function ManageFollower( optional silentSpawn : bool )
	{
		var Z : float;
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		var wolfTemplate : CEntityTemplate;
		
		if( !followerWolf || !followerWolf.IsAlive() || (!WasVisibleInScaledFrame(followerWolf, 1.5f, 1.5f) && VecDistanceSquared(GetWorldPosition(), followerWolf.GetWorldPosition()) > 900) || VecDistanceSquared(GetWorldPosition(), followerWolf.GetWorldPosition()) > 1600 )
		{
			if( followerWolf )
			{
				followerWolf.Destroy();
				delete followerWolf;
				hasFollowerWolf = false;
				isWolfFollowing = false;
			}
			
			spawnRot = GetWorldRotation();
			spawnPos = GetWorldPosition(); Z = spawnPos.Z;
			spawnPos += theCamera.GetCameraDirection() * -6;
			
			if( theGame.GetWorld().NavigationLineTest(GetWorldPosition(), spawnPos, 0.2f) )
				theGame.GetWorld().PhysicsCorrectZ(spawnPos, Z);
				
			spawnPos.Z = Z;
			switch( StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('wolfCompanion' ,'wolfType')) )
			{
				case 0:	wolfTemplate = (CEntityTemplate)LoadResource("dlc\wolfie\data\ents\wolfie_grey.w2ent", true); break;
				case 1:	wolfTemplate = (CEntityTemplate)LoadResource("dlc\wolfie\data\ents\wolfie_timber.w2ent", true); break;
				case 2:	wolfTemplate = (CEntityTemplate)LoadResource("dlc\wolfie\data\ents\wolfie_white.w2ent", true); break;
			}
			followerWolf = (CWolfNPC)theGame.CreateEntity(wolfTemplate, spawnPos, spawnRot);
			
			if( followerWolf )
			{
				hasFollowerWolf = true;
				isWolfFollowing = true;
			}
		}
		else followerWolf.OnCompanionInteraction();
	}
	
	timer function CompanionOnSpawn( dt : float, id : int )
	{
		if( hasFollowerWolf && isWolfFollowing )
			ManageFollower(true);
	}
	
	private var horseFollowTask : CBTTaskHorseSummon;
	public function SetFollowTask( task : CBTTaskHorseSummon )
	{
		horseFollowTask = task;
	}
	
	public function ClearFollowTask()
	{
		horseFollowTask = NULL;
	}
	
	timer function SummonDistanceCheck( dt: float, id : int )
	{
		if( VecDistanceSquared( GetWorldPosition(), GetHorseWithInventory().GetWorldPosition() ) < 25.0 )
		{
			horseFollowTask.OnDeactivate();
			RemoveTimer('SummonDistanceCheck');
		}
	}
	
	timer function ResetPerk10( dt : float, id : int )
	{	
		Damage().SetPerk10State(false);
	}
	
	timer function ReactivatePerk21( dt : float, id : int )
	{
		Combat().SetPerk21State(true);
		Combat().SetPerk21TimerState(false);
	}
	
	//Kolaris - Dol Blathanna Set
	timer function DisableElvenSet( dt : float, id : int )
	{
		Combat().SetElvenSetState(false);
	}
	
	timer function RefreshVigor( dt : float, id : int )
	{
		Options().ReadOptionValues();
		Combat().SetMaximumAdrenaline();
		
		CountPiecesOnSpawn();
		
		RemoveBuff(EET_AdrenalineDrain, true);
		RemoveBuff(EET_DimeritiumCharge, true);
		AddEffectDefault(EET_AdrenalineDrain, this, "VigorRegen");
		if( !FactsDoesExist("StoredVigor") )
			FactsAdd("StoredVigor", (int)(GetStatMax(BCS_Focus) * 1000), -1);
			
		/*if( !FactsDoesExist("WasCharacterReset") )
		{
			Options().ResetCharacter();
			FactsAdd("WasCharacterReset");
		}*/
		
		DrainFocus(GetStat(BCS_Focus, true));
		GainStat(BCS_Focus, FactsQueryLatestValue("StoredVigor") / 1000);
		
		if( !HasBuff(EET_Poise) )
			AddEffectDefault(EET_Poise, this, "Poise");
			
		GetPoiseEffect().UpdateMaxPoise();
	}
	
	timer function W3EEBestiaryInitialize( dt : float, id : int )
	{
		var manager : CWitcherJournalManager;
		
		if( !FactsDoesExist("BestiaryUpdatedFinal") )
		{
			FactsAdd("BestiaryUpdatedFinal");
			manager = theGame.GetJournalManager();
			
			activateJournalBestiaryEntryWithAlias("BestiaryGolding", manager);
			activateJournalBestiaryEntryWithAlias("BestiarySilvan", manager);
			activateJournalBestiaryEntryWithAlias("BestiarySuccubus", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryHigherVampire", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryBear", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryHim", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryPesta", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryAlghoul", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryMiscreant", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWerebear", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryDzinn", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryBasilisk", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryCockatrice", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryCrabSpider", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryArmoredArachas", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryPoisonousArachas", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryEkkima", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryElemental", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryEndriaga", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryEndriagaWorker", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryEndriagaTruten", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryForktail", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGhoul", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGolem", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryKatakan", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryMoonwright", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryNoonwright", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryLycanthrope", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWerewolf", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWyvern", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryCzart", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryBies", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryDog", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryDrowner", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryFireElemental", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryFogling", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGraveHag", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGriffin", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryErynia", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryHarpy", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryIceGiant", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryLeshy", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryNekker", manager);
			activateJournalBestiaryEntryWithAlias("BestiarySiren", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryIceTroll", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryCaveTroll", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWaterHag", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWhMinion", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWolf", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWraith", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryCyclop", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryIceGolem", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGargoyle", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGreaterRotFiend", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryDracolizardMatriarch", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryDracolizard", manager);
			activateJournalBestiaryEntryWithAlias("BestiarySpriggan", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGarkain", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryPanther", manager);
			activateJournalBestiaryEntryWithAlias("BestiarySharley", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryBarghest", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryBruxa", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryFleder", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryProtofleder", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryAlp", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryPaleWidow", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryScolopendromorph", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryKikimoraWarrior", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryKikimoraWorker", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryArchespore", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryWicht", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryBeanshie", manager);
			activateJournalBestiaryEntryWithAlias("BestiarySpiderEP2", manager); 
			activateJournalBestiaryEntryWithAlias("BestiaryBoarEP2", manager);
			activateJournalBestiaryEntryWithAlias("BestiaryGraveir", manager);
		}
	}
	
	timer function InitSkills( dt : float, id : int )
	{
		Combat().SetPerkArmorBonuses();
		Experience().InitializeSkills(this);
		Alchemy().Initialize(this);
		ManageActiveSetBonuses(EIST_MediumArmor);
		InitAnimManager();
		Combat().ForceEndGlyphsSkill();
		BlockAllActions('tutorial_chardev', false);
		BlockAllActions('tutorial_alchemy', false);
		BlockAllActions('tutorial_crafting', false);
		BlockAllActions('tutorial_inventory', false);
		
		UpdateWoundedState();
		if( !FactsDoesExist("was_repair_buff_fixed") )
		{
			FactsAdd("was_repair_buff_fixed");
			RemoveAllRepairBuffs();
		}
		
		// theGame.GetGuiManager().ShowUserDialogAdv(0, "pauseonload", "Game Paused", false, UDB_Ok);
	}
	
	//Kolaris - Gaunter Mode
	timer function InitGaunterMode( dt : float, id : int )
	{
		GaunterMode().UpdateDeathEffects();
		GaunterMode().UpdateDemonMark();
	}
	
	//Kolaris - Dynamic Witcher Schematics
	timer function InitDWS( dt : float, id : int )
	{
		if( !FactsQuerySum("DWS_initialized") )
		{
			if( Equipment().IsDWSInstalled() )
				Equipment().ManageOldSchematics();
		}
	}
	
	private var nightSight : bool;
	event OnToggleNightsight( action : SInputAction )
	{
		if( IsPressed(action) && !nightSight && !HasBuff(EET_Blindness) && !HasBuff(EET_Hypnotized) ) 
		{
			nightSight = true;
			EnableCatViewFx( 1.0f );
			SetTintColorsCatViewFx(Vector(0.1f,0.12f,0.13f,0.6f),Vector(0.075f,0.1f,0.11f,0.6f),0.2f);
			SetBrightnessCatViewFx(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('NightSightMenu', 'NightSightBrightness')));
			SetViewRangeCatViewFx(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('NightSightMenu', 'NightSightRange')));
			SetPositionCatViewFx( Vector(0,0,0,0) , true );
			SetHightlightCatViewFx( Vector(0.5f,0.2f,0.2f,1.f),0.05f,1.5f);
			SetFogDensityCatViewFx( 0.5 );
		}	
		else 
		if( IsPressed(action) && nightSight ) 
		{
			nightSight = false;
			DisableCatViewFx( 1.0f );
		}
	}
	
	public function ManageModShieldHoods( item : SItemUniqueId, isOnEquip : bool )
	{
		if( inv.ItemHasTag( item, 'Hood' ) && !isOnEquip )
			DisplayHair( false );
	}
	
	public function DisplayHair( display : bool )
	{
		var l_comp : CComponent;
		var hair : CEntityTemplate;
		
		l_comp = thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		hair = (CEntityTemplate)LoadResource("dlc\kontusz\data\items\hoods\hood_hair\hair_hood.w2ent", true);    
		
		if( display )
			((CAppearanceComponent)l_comp).IncludeAppearanceTemplate(hair);
		else
			((CAppearanceComponent)l_comp).ExcludeAppearanceTemplate(hair);
	}
	// W3EE - End
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var i 				: int;
		var items 			: array<SItemUniqueId>;
		var items2 			: array<SItemUniqueId>;
		var horseTemplate 	: CEntityTemplate;
		var horseManager 	: W3HorseManager;
		// W3EE - Begin
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;
		var effectType : name;
		var infType : ESignType;
		// W3EE - End
		
		AddAnimEventCallback( 'ActionBlend', 			'OnAnimEvent_ActionBlend' );
		AddAnimEventCallback('cast_begin',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_throw',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_end',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_friendly_begin',		'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_friendly_throw',		'OnAnimEvent_Sign');
		AddAnimEventCallback('axii_ready',				'OnAnimEvent_Sign');
		AddAnimEventCallback('axii_alternate_ready',	'OnAnimEvent_Sign');
		AddAnimEventCallback('yrden_draw_ready',		'OnAnimEvent_Sign');
		
		AddAnimEventCallback( 'ProjectileThrow',	'OnAnimEvent_Throwable'	);
		AddAnimEventCallback( 'OnWeaponReload',		'OnAnimEvent_Throwable'	);
		AddAnimEventCallback( 'ProjectileAttach',	'OnAnimEvent_Throwable' );
		AddAnimEventCallback( 'Mutation11AnimEnd',	'OnAnimEvent_Mutation11AnimEnd' );
		AddAnimEventCallback( 'Mutation11ShockWave', 'OnAnimEvent_Mutation11ShockWave' );
		
		// W3EE - Begin
		AddAnimEventCallback( 'GeraltFastAttackAnimStart',	'OnAnimEvent_GeraltFastAttackAnimStart' );
		AddAnimEventCallback( 'GeraltStrongAttackAnimStart', 'OnAnimEvent_GeraltStrongAttackAnimStart' );
		AddAnimEventCallback( 'GeraltFastAttackFarAnimStart', 'OnAnimEvent_GeraltFastAttackFarAnimStart' );
		AddAnimEventCallback( 'GeraltStrongAttackFarAnimStart', 'OnAnimEvent_GeraltStrongAttackFarAnimStart' );
		AddAnimEventCallback( 'SecondaryAttackAnimStart', 'OnAnimEvent_SecondaryAttackAnimStart' );
		AddAnimEventCallback( 'FastAxeAttackAnimStart', 'OnAnimEvent_FastAxeAttackAnimStart' );
		AddAnimEventCallback( 'StrongAxeAttackAnimStart', 'OnAnimEvent_StrongAxeAttackAnimStart' );
		AddAnimEventCallback( 'ShieldBlockAnimStart', 'OnAnimEvent_ShieldBlockAnimStart' );
		AddAnimEventCallback( 'ShieldBlockAnimEnd', 'OnAnimEvent_ShieldBlockAnimEnd' );
		AddAnimEventCallback( 'SpecialKickAnimStart', 'OnAnimEvent_SpecialKickAnimStart' );
		AddAnimEventCallback( 'SpecialKickAnimEnd', 'OnAnimEvent_SpecialKickAnimEnd' );
		AddAnimEventCallback( 'GeraltSpecialStrongAnimEnd', 'OnAnimEvent_GeraltSpecialStrongAnimEnd' );
		AddAnimEventCallback( 'DodgeInvulnerableStart', 'OnAnimEvent_DodgeInvulnerableStart' );
		AddAnimEventCallback( 'DodgeGrazeStart', 'OnAnimEvent_DodgeGrazeStart' );
		AddAnimEventCallback( 'TriggerFinisherFromAnimEvent', 'OnAnimEvent_TriggerFinisherFromAnimEvent' );
		// W3EE - End
		
		amountOfSetPiecesEquipped.Resize( EnumGetMax( 'EItemSetType' ) + 1 );
		
		runewordInfusionType = ST_None;
				
		
		inv = GetInventory();			

		
		signOwner = new W3SignOwnerPlayer in this;
		signOwner.Init( this );
		
		itemSlots.Resize( EnumGetMax('EEquipmentSlots')+1 );

		if(!spawnData.restored)
		{
			levelManager = new W3LevelManager in this;			
			levelManager.Initialize();
			
			
			inv.GetAllItems(items);
			for(i=0; i<items.Size(); i+=1)
			{
				if(inv.IsItemMounted(items[i]) && ( !inv.IsItemBody(items[i]) || inv.GetItemCategory(items[i]) == 'hair' ) )
					EquipItem(items[i]);
			}
			
			
			
			
			
			AddAlchemyRecipe('Recipe for Swallow 1',true,true);
			AddAlchemyRecipe('Recipe for Cat 1',true,true);
			AddAlchemyRecipe('Recipe for White Honey 1',true,true);
			
			AddAlchemyRecipe('Recipe for Samum 1',true,true);
			AddAlchemyRecipe('Recipe for Grapeshot 1',true,true);
			
			AddAlchemyRecipe('Recipe for Specter Oil 1',true,true);
			AddAlchemyRecipe('Recipe for Necrophage Oil 1',true,true);
			AddAlchemyRecipe('Recipe for Alcohest 1',true,true);
		}
		else
		{
			AddTimer('DelayedOnItemMount', 0.1, true);
			
			
			CheckHairItem();
		}
		
		
		AddStartingSchematics();

		super.OnSpawned( spawnData );
		
		
		AddAlchemyRecipe('Recipe for Mutagen red',true,true);
		AddAlchemyRecipe('Recipe for Mutagen green',true,true);
		AddAlchemyRecipe('Recipe for Mutagen blue',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen red',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen green',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen blue',true,true);
		
		if( inputHandler )
		{
			inputHandler.BlockAllActions( 'being_ciri', false );
		}
		SetBehaviorVariable( 'test_ciri_replacer', 0.0f);
		
		if(!spawnData.restored)
		{
			
			abilityManager.GainStat(BCS_Toxicity, 0);		
		}		
		
		levelManager.PostInit(this, spawnData.restored, true);
		
		SetBIsCombatActionAllowed( true );		
		SetBIsInputAllowed( true, 'OnSpawned' );				
		
		
		if ( !reputationManager )
		{
			reputationManager = new W3Reputation in this;
			reputationManager.Initialize();
		}
		
		theSound.SoundParameter( "focus_aim", 1.0f, 1.0f );
		theSound.SoundParameter( "focus_distance", 0.0f, 1.0f );
		
		
		
		
			
		
		currentlyCastSign = ST_None;
		
		
		if(!spawnData.restored)
		{
			horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
			horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
			horseManager.CreateAttachment(this);
			horseManager.OnCreated();
			EntityHandleSet( horseManagerHandle, horseManager );
		}
		else
		{
			AddTimer('DelayedHorseUpdate', 0.01, true);
		}
		
		
		RemoveAbility('Ciri_CombatRegen');
		RemoveAbility('Ciri_Rage');
		RemoveAbility('CiriBlink');
		RemoveAbility('CiriCharge');
		RemoveAbility('Ciri_Q205');
		RemoveAbility('Ciri_Q305');
		RemoveAbility('Ciri_Q403');
		RemoveAbility('Ciri_Q111');
		RemoveAbility('Ciri_Q501');
		RemoveAbility('SkillCiri');
		
		if(spawnData.restored)
		{
			RestoreQuen(savedQuenHealth, savedQuenDuration);			
		}
		else
		{
			savedQuenHealth = 0.f;
			savedQuenDuration = 0.f;
		}
		
		if(spawnData.restored)
		{
			ApplyPatchFixes();
		}
		else
		{
			
			FactsAdd( "new_game_started_in_1_20" );
		}
		
		if ( spawnData.restored )
		{
			FixEquippedMutagens();
		}
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			NewGamePlusAdjustDLC1TemerianSet(inv);
			NewGamePlusAdjustDLC5NilfgardianSet(inv);
			NewGamePlusAdjustDLC10WolfSet(inv);
			NewGamePlusAdjustDLC14SkelligeSet(inv);
			if(horseManager)
			{
				NewGamePlusAdjustDLC1TemerianSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC5NilfgardianSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC10WolfSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC14SkelligeSet(horseManager.GetInventoryComponent());
			}
		}
		
		
		// W3EE - Begin
		ResumeStaminaRegen('WhirlSkill');
		ResumeStaminaRegen('RendSkill');
		
		armorPieces.Resize(4);
		armorPiecesOriginal.Resize(4);
		
		abilityManager.GainStat(BCS_Toxicity, 0);
		
		AddTimer('CompanionOnSpawn', 0.5f, false);
		
		AddTimer('RefreshVigor', 0.5f, false);
		
		AddTimer('InitSkills', 0.5f, false);
		
		AddTimer('W3EEBestiaryInitialize', 2.5f, false);
		
		AddTimer('ResetAdrenalineCombat', 5.f, false);
		
		RemoveAbilityAll('magic_staminaregen');
		
		RemoveAbilityAll('sword_adrenalinegain');
		
		ResumeStaminaRegen('RendSkill');
		
		if( FactsQuerySum("MissingRecipesAdded") < 1 )
		{
			AddAlchemyRecipe('Recipe for Tawny Owl 1', true, true);
			AddCraftingSchematic('Meteorite plate schematic', true, true);
			FactsAdd("MissingRecipesAdded");
		}
		
		//AddTimer('RelevelItem', 4, false);
		
		Equipment().ScaleItems(inv);
		
		for(i=1; i<=50; i+=1)
		{
			RemoveAbilityAll( GetLevelupAbility(i) );
			AddAbility( GetLevelupAbility(i) );
		}
		
		theInput.UnregisterListener(this, 'Nightsight');
		theInput.RegisterListener(this, 'OnToggleNightsight', 'Nightsight');
		// W3EE - End
		
		//Kolaris - Gaunter Mode
		AddTimer('InitGaunterMode', 0.6f, false);
		//Kolaris - Dynamic Witcher Schematics
		AddTimer('InitDWS', 1.5f, false);
		
		if(HasAbility('Runeword 4 _Stats', true))
			StartVitalityRegen();
		
		
		if(HasAbility('sword_s19'))
		{
			RemoveTemporarySkills();
		}
		
		HACK_UnequipWolfLiver();
		
		
		if( HasBuff( EET_GryphonSetBonusYrden ) )
		{
			RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
		}
		
		// -= WMK:modQuickSlots =-
		if (WmkGetQuickInventoryInstance()) {
			WmkGetQuickInventoryInstance().OnPlayerWitcherSpawned();
		}
		// -= WMK:modQuickSlots =-
		
		if( spawnData.restored )
		{
			
			UpdateEncumbrance();
			
			
			RemoveBuff( EET_Mutation11Immortal );
			RemoveBuff( EET_Mutation11Buff );
		}
		
		
		theGame.GameplayFactsAdd( "PlayerIsGeralt" );
		
		isInitialized = true;
		
		//Kolaris - NextGen Update (Disabled)
		/*if(IsMutationActive( EPMT_Mutation6 ))
			if(( (W3PlayerAbilityManager)abilityManager).GetMutationSoundBank(( EPMT_Mutation6 )) != "" ) 
				theSound.SoundLoadBank(((W3PlayerAbilityManager)abilityManager).GetMutationSoundBank(( EPMT_Mutation6 )), true );*/
		
		//modNoDuplicates - Begin
		if(!newGamePlusInitialized && FactsQuerySum("NewGamePlus")<=0)
		{
			ModNoDuplicatesAddInventoryComponentFacts(inv);
			ModNoDuplicatesAddInventoryComponentFacts(GetHorseManager().GetInventoryComponent());
		}
		//modNoDuplicates - End
	}
	
	private function HACK_UnequipWolfLiver()
	{
		var itemName1, itemName2, itemName3, itemName4 : name;
		var item1, item2, item3, item4 : SItemUniqueId;
		
		GetItemEquippedOnSlot( EES_Potion1, item1 );
		GetItemEquippedOnSlot( EES_Potion2, item2 );
		GetItemEquippedOnSlot( EES_Potion3, item3 );
		GetItemEquippedOnSlot( EES_Potion4, item4 );

		if ( inv.IsIdValid( item1 ) )
			itemName1 = inv.GetItemName( item1 );
		if ( inv.IsIdValid( item2 ) )
			itemName2 = inv.GetItemName( item2 );
		if ( inv.IsIdValid( item3 ) )
			itemName3 = inv.GetItemName( item3 );
		if ( inv.IsIdValid( item4 ) )
			itemName4 = inv.GetItemName( item4 );

		if ( itemName1 == 'Wolf liver' || itemName3 == 'Wolf liver' )
		{
			if ( inv.IsIdValid( item1 ) )
				UnequipItem( item1 );
			if ( inv.IsIdValid( item3 ) )
				UnequipItem( item3 );
		}
		else if ( itemName2 == 'Wolf liver' || itemName4 == 'Wolf liver' )
		{
			if ( inv.IsIdValid( item2 ) )
				UnequipItem( item2 );
			if ( inv.IsIdValid( item4 ) )
				UnequipItem( item4 );
		}
	}
	
	
	
	

	timer function DelayedHorseUpdate( dt : float, id : int )
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
		{
			if ( man.ApplyHorseUpdateOnSpawn() )
			{
				
				UpdateEncumbrance();
				
				RemoveTimer( 'DelayedHorseUpdate' );
			}
		}
	}	
	
	event OnAbilityAdded( abilityName : name)
	{
		super.OnAbilityAdded(abilityName);
		
		if( HasAbility('Runeword 4 _Stats', true) )
		{
			StartVitalityRegen();
		}
		
		// W3EE - Begin
		/*if ( abilityName == 'Runeword 8 _Stats' && GetStat(BCS_Focus, true) >= GetStatMax(BCS_Focus) && !HasBuff(EET_Runeword8) )
		{
			AddEffectDefault(EET_Runeword8, this, "equipped item");
		}*/
		// W3EE - End
	}
	
	private final function AddStartingSchematics()
	{
		//Kolaris - Repair Kit Schematics
		AddCraftingSchematic('WeaponRepairKit_1 schematic',true,true);
		AddCraftingSchematic('WeaponRepairKit_2 schematic',true,true);
		AddCraftingSchematic('WeaponRepairKit_3 schematic',true,true);
		AddCraftingSchematic('ArmorRepairKit_1 schematic',true,true);
		AddCraftingSchematic('ArmorRepairKit_2 schematic',true,true);
		AddCraftingSchematic('ArmorRepairKit_3 schematic',true,true);
		//Kolaris - Improved Kaer Morhen Set
		AddCraftingSchematic('Starting Armor Upgrade schematic 1',	true,true);
		AddCraftingSchematic('Starting Pants Upgrade schematic 1',	true,true);
		AddCraftingSchematic('Starting Boots Upgrade schematic 1',	true,true);
		AddCraftingSchematic('Starting Gloves Upgrade schematic 1',	true,true);
		AddCraftingSchematic('Starting Steel Sword Upgrade schematic 1',true,true);
		AddCraftingSchematic('Starting Silver Sword Upgrade schematic 1',true,true);
		AddCraftingSchematic('Thread schematic',					true, true);
		AddCraftingSchematic('String schematic',					true, true);
		AddCraftingSchematic('Linen schematic',						true, true);
		AddCraftingSchematic('Cloth schematic',                     true, true);
		AddCraftingSchematic('Silk schematic',						true, true);
		AddCraftingSchematic('Resin schematic',						true, true);
		AddCraftingSchematic('Blasting powder schematic',			true, true);
		AddCraftingSchematic('Haft schematic',						true, true);
		AddCraftingSchematic('Hardened timber schematic',			true, true);
		AddCraftingSchematic('Leather squares schematic',			true, true);
		AddCraftingSchematic('Leather schematic',					true, true);
		AddCraftingSchematic('Hardened leather schematic',			true, true);
		AddCraftingSchematic('Draconide leather schematic',			true, true);
		AddCraftingSchematic('Iron ingot schematic',				true, true);
		AddCraftingSchematic('Steel ingot schematic',				true, true);
		AddCraftingSchematic('Steel ingot schematic 1',				true, true);
		AddCraftingSchematic('Steel plate schematic',				true, true);
		AddCraftingSchematic('Dark iron ingot schematic',			true, true);
		AddCraftingSchematic('Dark iron plate schematic',			true, true);
		AddCraftingSchematic('Dark steel ingot schematic',			true, true);
		AddCraftingSchematic('Dark steel ingot schematic 1',		true, true);
		AddCraftingSchematic('Dark steel plate schematic',			true, true);
		AddCraftingSchematic('Silver ore schematic',				true, true);
		AddCraftingSchematic('Silver ingot schematic',				true, true);
		AddCraftingSchematic('Silver ingot schematic 1',			true, true);
		AddCraftingSchematic('Silver plate schematic',				true, true);
		//Kolaris - Meteorite Schematics
		AddCraftingSchematic('Meteorite ore schematic',				true, true);
		AddCraftingSchematic('Meteorite silver ore schematic',		true, true);
		AddCraftingSchematic('Meteorite ingot schematic',			true, true);
		AddCraftingSchematic('Meteorite silver ingot schematic',	true, true);
		AddCraftingSchematic('Meteorite silver plate schematic',	true, true);
		AddCraftingSchematic('Glowing ingot schematic',				true, true);
		AddCraftingSchematic('Dwimeryte ore schematic',				true, true);
		AddCraftingSchematic('Dwimeryte ingot schematic',			true, true);
		AddCraftingSchematic('Dwimeryte ingot schematic 1',			true, true);
		AddCraftingSchematic('Dwimeryte plate schematic',			true, true);
		AddCraftingSchematic('Infused dust schematic',				true, true);
		AddCraftingSchematic('Infused shard schematic',				true, true);
		AddCraftingSchematic('Infused crystal schematic',			true, true);

		if ( theGame.GetDLCManager().IsEP2Available() )
		{
			AddCraftingSchematic('Draconide infused leather schematic',	true, true);
			AddCraftingSchematic('Nickel ore schematic',				true, true);
			AddCraftingSchematic('Cupronickel ore schematic',			true, true);
			AddCraftingSchematic('Copper ore schematic',				true, true);
			AddCraftingSchematic('Copper ingot schematic',				true, true);
			AddCraftingSchematic('Copper plate schematic',				true, true);
			AddCraftingSchematic('Green gold ore schematic',			true, true);
			AddCraftingSchematic('Green gold ore schematic 1',			true, true);
			AddCraftingSchematic('Green gold ingot schematic',			true, true);
			AddCraftingSchematic('Green gold plate schematic',			true, true);
			AddCraftingSchematic('Orichalcum ore schematic',			true, true);
			AddCraftingSchematic('Orichalcum ore schematic 1',			true, true);
			AddCraftingSchematic('Orichalcum ingot schematic',			true, true);
			AddCraftingSchematic('Orichalcum plate schematic',			true, true);
			AddCraftingSchematic('Dwimeryte enriched ore schematic',	true, true);
			AddCraftingSchematic('Dwimeryte enriched ingot schematic',	true, true);
			AddCraftingSchematic('Dwimeryte enriched plate schematic',	true, true);
		}
	}
	
	private final function ApplyPatchFixes()
	{
		var cnt, transmutationCount, mutagenCount, i, slot : int;
		var transmutationAbility, itemName : name;
		var pam : W3PlayerAbilityManager;
		var slotId : int;
		var offset : float;
		var buffs : array<CBaseGameplayEffect>;
		var skill : SSimpleSkill;
		var spentSkillPoints, swordSkillPointsSpent, alchemySkillPointsSpent, perkSkillPointsSpent, pointsToAdd : int;
		
		if(FactsQuerySum("ClearingPotionPassiveBonusFix") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			
			// W3EE - Begin
			/*cnt = GetAbilityCount('sword_adrenalinegain') - pam.GetPathPointsSpent(ESP_Sword);
			if(cnt > 0)
				RemoveAbilityMultiple('sword_adrenalinegain', cnt);
				
			cnt = GetAbilityCount('magic_staminaregen') - pam.GetPathPointsSpent(ESP_Signs);
			if(cnt > 0)
				RemoveAbilityMultiple('magic_staminaregen', cnt);*/
			// W3EE - End
			
			cnt = GetAbilityCount('alchemy_potionduration') - pam.GetPathPointsSpent(ESP_Alchemy);
			if(cnt > 0)
				RemoveAbilityMultiple('alchemy_potionduration', cnt);
		
			FactsAdd("ClearingPotionPassiveBonusFix");
		}
				
		
		if(FactsQuerySum("DimeritiumSynergyFix") < 1)
		{
			slotId = GetSkillSlotID(S_Alchemy_s19);
			if(slotId != -1)
				UnequipSkill(S_Alchemy_s19);
				
			RemoveAbilityAll('greater_mutagen_color_green_synergy_bonus');
			RemoveAbilityAll('mutagen_color_green_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_green_synergy_bonus');
			
			RemoveAbilityAll('greater_mutagen_color_blue_synergy_bonus');
			RemoveAbilityAll('mutagen_color_blue_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_blue_synergy_bonus');
			
			RemoveAbilityAll('greater_mutagen_color_red_synergy_bonus');
			RemoveAbilityAll('mutagen_color_red_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_red_synergy_bonus');
			
			if(slotId != -1)
				EquipSkill(S_Alchemy_s19, slotId);
		
			FactsAdd("DimeritiumSynergyFix");
		}
		
		
		if(FactsQuerySum("DontShowRecipePinTut") < 1)
		{
			FactsAdd( "DontShowRecipePinTut" );
			TutorialScript('alchemyRecipePin', '');
			TutorialScript('craftingRecipePin', '');
		}
		
		
		/*if(FactsQuerySum("LevelReqPotGiven") < 1)
		{
			FactsAdd("LevelReqPotGiven");
			inv.AddAnItem('Wolf Hour', 1, false, false, true);
		}*/
		
		
		if(!HasBuff(EET_AutoStaminaRegen))
		{
			AddEffectDefault(EET_AutoStaminaRegen, this, 'autobuff', false);
		}
		
		
		
		buffs = GetBuffs();
		offset = 0;
		//mutagenCount = 0;
		
		if(offset != (GetStat(BCS_Toxicity) - GetStat(BCS_Toxicity, true)))
			SetToxicityOffset(offset);
			
		
		/*mutagenCount *= GetSkillLevel(S_Alchemy_s13);
		transmutationAbility = GetSkillAbilityName(S_Alchemy_s13);
		transmutationCount = GetAbilityCount(transmutationAbility);
		if(mutagenCount < transmutationCount)
		{
			RemoveAbilityMultiple(transmutationAbility, transmutationCount - mutagenCount);
		}
		else if(mutagenCount > transmutationCount)
		{
			AddAbilityMultiple(transmutationAbility, mutagenCount - transmutationCount);
		}*/
		
		
		if(theGame.GetDLCManager().IsEP1Available())
		{
			theGame.GetJournalManager().ActivateEntryByScriptTag('TutorialJournalEnchanting', JS_Active);
		}

		
		if(HasAbility('sword_s19') && FactsQuerySum("Patch_Sword_s19") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;

			
			skill.level = 0;
			for(i = S_Magic_s01; i <= S_Magic_s20; i+=1)
			{
				skill.skillType = i;				
				pam.RemoveTemporarySkill(skill);
			}
			
			
			spentSkillPoints = levelManager.GetPointsUsed(ESkillPoint);
			swordSkillPointsSpent = pam.GetPathPointsSpent(ESP_Sword);
			alchemySkillPointsSpent = pam.GetPathPointsSpent(ESP_Alchemy);
			perkSkillPointsSpent = pam.GetPathPointsSpent(ESP_Perks);
			
			pointsToAdd = spentSkillPoints - swordSkillPointsSpent - alchemySkillPointsSpent - perkSkillPointsSpent;
			if(pointsToAdd > 0)
				levelManager.UnspendPoints(ESkillPoint, pointsToAdd);
			
			
			RemoveAbilityAll('sword_s19');
			
			
			FactsAdd("Patch_Sword_s19");
		}
		
		
		if( HasAbility( 'sword_s19' ) )
		{
			RemoveAbilityAll( 'sword_s19' );
		}
		
		
		if(FactsQuerySum("Patch_Armor_Type_Glyphwords") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			
			pam.SetPerkArmorBonus( S_Perk_05, this );
			pam.SetPerkArmorBonus( S_Perk_06, this );
			pam.SetPerkArmorBonus( S_Perk_07, this );
			
			FactsAdd("Patch_Armor_Type_Glyphwords");
		}
		else if( FactsQuerySum("154999") < 1 )
		{
			
			pam = (W3PlayerAbilityManager)abilityManager;
			
			pam.SetPerkArmorBonus( S_Perk_05, this );
			pam.SetPerkArmorBonus( S_Perk_06, this );
			pam.SetPerkArmorBonus( S_Perk_07, this );
			
			FactsAdd("154999");
		}
		
		if( FactsQuerySum( "154997" ) < 1 )
		{
			if( IsSkillEquipped( S_Alchemy_s18 ) )
			{
				slot = GetSkillSlotID( S_Alchemy_s18 );
				UnequipSkill( slot );
				EquipSkill( S_Alchemy_s18, slot );
			}
			FactsAdd( "154997" );
		}
		if( FactsQuerySum( "Patch_Mutagen_Ing_Stacking" ) < 1 )
		{
			Patch_MutagenStacking();		
			FactsAdd( "Patch_Mutagen_Ing_Stacking" );
		}
	}
	
	private final function Patch_MutagenStacking()
	{
		var i, j, quantity : int;
		var muts : array< SItemUniqueId >;
		var item : SItemUniqueId;
		var mutName : name;
		var wasInArray : bool;
		var mutsToAdd : array< SItemParts >;
		var mutToAdd : SItemParts;
		
		muts = inv.GetItemsByTag( 'MutagenIngredient' );
		if( GetItemEquippedOnSlot( EES_SkillMutagen1, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen2, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen3, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen4, item ) )
		{
			muts.Remove( item );
			inv.SetItemStackable( item, false );
		}
		
		for( i=0; i<muts.Size(); i+=1 )
		{
			mutName = inv.GetItemName( muts[i] );
			quantity = inv.GetItemQuantity( muts[i] );
			
			wasInArray = false;
			for( j=0; j<mutsToAdd.Size(); j+=1 )
			{
				if( mutsToAdd[j].itemName == mutName )
				{
					mutsToAdd[j].quantity += quantity;
					wasInArray = true;
					break;
				}
			}
			
			if( !wasInArray )
			{
				mutToAdd.itemName = mutName;
				mutToAdd.quantity = quantity;
				mutsToAdd.PushBack( mutToAdd );
			}
			
			inv.RemoveItem( muts[i], quantity );
		}
		
		for( i=0; i<mutsToAdd.Size(); i+=1 )
		{
			inv.AddAnItem( mutsToAdd[i].itemName, mutsToAdd[i].quantity, true, true );
		}
	}
	
	private function FixEquippedMutagens()
	{
		var item : SItemUniqueId;
		if( GetItemEquippedOnSlot( EES_SkillMutagen1, item ) )
		{
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen2, item ) )
		{
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen3, item ) )
		{
			inv.SetItemStackable( item, false );
		}
		if( GetItemEquippedOnSlot( EES_SkillMutagen4, item ) )
		{
			inv.SetItemStackable( item, false );
		}
	}
	
	public final function RestoreQuen( quenHealth : float, quenDuration : float, optional alternate : bool ) : bool
	{
		var restoredQuen 	: W3QuenEntity;
		
		if(quenHealth > 0.f && quenDuration >= 3.f)
		{
			restoredQuen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			restoredQuen.Init( signOwner, signs[ST_Quen].entity, true );
			
			if( alternate )
			{
				restoredQuen.SetAlternateCast( S_Magic_s04 );
			}
			
			restoredQuen.OnStarted();
			restoredQuen.OnThrowing();
			
			if( !alternate )
			{
				restoredQuen.OnEnded();
			}
			
			restoredQuen.SetDataFromRestore(quenHealth, quenDuration);
			
			return true;
		}
		
		return false;
	}
	
	public function IsInitialized() : bool
	{
		return isInitialized;
	}
	
	private function NewGamePlusInitialize()
	{
		var questItems : array<name>;
		var horseManager : W3HorseManager;
		var horseInventory : CInventoryComponent;
		var i, missingLevels, expDiff : int;
		
		super.NewGamePlusInitialize();
		
		
		horseManager = (W3HorseManager)EntityHandleGet(horseManagerHandle);
		if(horseManager)
			horseInventory = horseManager.GetInventoryComponent();
		
		
		theGame.params.SetNewGamePlusLevel(GetLevel());
		
		
		if (theGame.GetDLCManager().IsDLCAvailable('ep1'))
			missingLevels = theGame.params.NEW_GAME_PLUS_EP1_MIN_LEVEL - GetLevel();
		else
			missingLevels = theGame.params.NEW_GAME_PLUS_MIN_LEVEL - GetLevel();
			
		for(i=0; i<missingLevels; i+=1)
		{
			
			expDiff = levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint);
			expDiff = CeilF( ((float)expDiff) / 2 );
			AddPoints(EExperiencePoint, expDiff, false);
		}
		
		
		
		
		
		inv.RemoveItemByTag('Quest', -1);
		horseInventory.RemoveItemByTag('Quest', -1);

		
		
		questItems = theGame.GetDefinitionsManager().GetItemsWithTag('Quest');
		for(i=0; i<questItems.Size(); i+=1)
		{
			inv.RemoveItemByName(questItems[i], -1);
			horseInventory.RemoveItemByName(questItems[i], -1);
		}
		
		
		inv.RemoveItemByName('mq1002_artifact_3', -1);
		horseInventory.RemoveItemByName('mq1002_artifact_3', -1);
		
		
		inv.RemoveItemByTag('NotTransferableToNGP', -1);
		horseInventory.RemoveItemByTag('NotTransferableToNGP', -1);
		
		
		inv.RemoveItemByTag('NoticeBoardNote', -1);
		horseInventory.RemoveItemByTag('NoticeBoardNote', -1);
		
		
		RemoveAllNonAutoBuffs();
		
		
		RemoveAlchemyRecipe('Recipe for Trial Potion Kit');
		RemoveAlchemyRecipe('Recipe for Pops Antidote');
		RemoveAlchemyRecipe('Recipe for Czart Lure');
		RemoveAlchemyRecipe('q603_diarrhea_potion_recipe');
		
		
		inv.RemoveItemByTag('Trophy', -1);
		horseInventory.RemoveItemByTag('Trophy', -1);
		
		
		inv.RemoveItemByCategory('usable', -1);
		horseInventory.RemoveItemByCategory('usable', -1);
		
		
		RemoveAbility('StaminaTutorialProlog');
    	RemoveAbility('TutorialStaminaRegenHack');
    	RemoveAbility('area_novigrad');
    	RemoveAbility('NoRegenEffect');
    	RemoveAbility('HeavySwimmingStaminaDrain');
    	RemoveAbility('AirBoost');
    	RemoveAbility('area_nml');
    	RemoveAbility('area_skellige');
    	
    	
    	inv.RemoveItemByTag('GwintCard', -1);
    	horseInventory.RemoveItemByTag('GwintCard', -1);
    	    	
    	
    	
    	inv.RemoveItemByTag('ReadableItem', -1);
    	horseInventory.RemoveItemByTag('ReadableItem', -1);
    	
    	
    	abilityManager.RestoreStats();
    	
    	
    	((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(10000);
    	
    	// W3EE - Begin
    	//GetInventory().SingletonItemsRefillAmmo();
		GetInventory().SingletonItemsRefillAmmoNoAlco(true);    	
    	// W3EE - End
    	
    	craftingSchematics.Clear();
    	AddStartingSchematics();
    	
    	
    	for( i=0; i<amountOfSetPiecesEquipped.Size(); i+=1 )
    	{
			amountOfSetPiecesEquipped[i] = 0;
		}

    	
    	inv.AddAnItem('Clearing Potion', 1, true, false, false);
    	
    	
    	inv.RemoveItemByName('q203_broken_eyeofloki', -1);
    	horseInventory.RemoveItemByName('q203_broken_eyeofloki', -1);
    	
    	
    	NewGamePlusReplaceViperSet(inv);
    	NewGamePlusReplaceViperSet(horseInventory);
    	NewGamePlusReplaceLynxSet(inv);
    	NewGamePlusReplaceLynxSet(horseInventory);
    	NewGamePlusReplaceGryphonSet(inv);
    	NewGamePlusReplaceGryphonSet(horseInventory);
    	NewGamePlusReplaceBearSet(inv);
    	NewGamePlusReplaceBearSet(horseInventory);
    	NewGamePlusReplaceEP1(inv);
    	NewGamePlusReplaceEP1(horseInventory);
    	NewGamePlusReplaceEP2WitcherSets(inv);
    	NewGamePlusReplaceEP2WitcherSets(horseInventory);
    	NewGamePlusReplaceEP2Items(inv);
    	NewGamePlusReplaceEP2Items(horseInventory);
    	NewGamePlusMarkItemsToNotAdjust(inv);
    	NewGamePlusMarkItemsToNotAdjust(horseInventory);
    	
    	inputHandler.ClearLocksForNGP();
    	
    	
    	buffImmunities.Clear();
    	buffRemovedImmunities.Clear();
    	
    	newGamePlusInitialized = true;
		
		//modNoDuplicates - Begin
		ModNoDuplicatesAddInventoryItemsModifiers(inv);
		ModNoDuplicatesAddInventoryItemsModifiers(horseInventory);
		//modNoDuplicates - End
    	
    	m_quenReappliedCount = 1;
		
    	tiedWalk = false;
    	proudWalk = false;
    	injuredWalk = false;
    	SetBehaviorVariable( 'alternateWalk', 0.0f );
    	SetBehaviorVariable( 'proudWalk', 0.0f );
    	if( GetHorseManager().GetHorseMode() == EHM_Unicorn )
			GetHorseManager().SetHorseMode( EHM_Normal );
	}
		
	private final function NewGamePlusMarkItemsToNotAdjust(out inv : CInventoryComponent)
	{
		var ids		: array<SItemUniqueId>;
		var i 		: int;
		var n		: name;
		
		inv.GetAllItems(ids);
		for( i=0; i<ids.Size(); i+=1 ) 
		{
			inv.SetItemModifierInt(ids[i], 'NGPItemAdjusted', 1);
		}
	}
	
	private final function NewGamePlusReplaceItem( item : name, new_item : name, out inv : CInventoryComponent)
	{
		var i, j 					: int;
		var ids, new_ids, enh_ids 	: array<SItemUniqueId>;
		var dye_ids					: array<SItemUniqueId>;
		var enh					 	: array<name>;
		var wasEquipped 			: bool;
		var wasEnchanted 			: bool;
		var wasDyed					: bool;
		var enchantName, colorName	: name;
		
		if ( inv.HasItem( item ) )
		{
			ids = inv.GetItemsIds(item);
			for (i = 0; i < ids.Size(); i += 1)
			{
				inv.GetItemEnhancementItems( ids[i], enh );
				wasEnchanted = inv.IsItemEnchanted( ids[i] );
				if ( wasEnchanted ) 
					enchantName = inv.GetEnchantment( ids[i] );
				wasEquipped = IsItemEquipped( ids[i] );
				wasDyed = inv.IsItemColored( ids[i] );
				if ( wasDyed )
				{
					colorName = inv.GetItemColor( ids[i] );
				}
				
				inv.RemoveItem( ids[i], 1 );
				new_ids = inv.AddAnItem( new_item, 1, true, true, false );
				if ( wasEquipped )
				{
					EquipItem( new_ids[0] );
				}
				if ( wasEnchanted )
				{
					inv.EnchantItem( new_ids[0], enchantName, getEnchamtmentStatName(enchantName) );
				}
				for (j = 0; j < enh.Size(); j += 1)
				{
					enh_ids = inv.AddAnItem( enh[j], 1, true, true, false );
					inv.EnhanceItemScript( new_ids[0], enh_ids[0] );
				}
				if ( wasDyed )
				{
					dye_ids = inv.AddAnItem( colorName, 1, true, true, false );
					inv.ColorItem( new_ids[0], dye_ids[0] );
					inv.RemoveItem( dye_ids[0], 1 );
				}
				
				inv.SetItemModifierInt( new_ids[0], 'NGPItemAdjusted', 1 );
			}
		}
	}
	
	private final function NewGamePlusAdjustDLCItem(item : name, mod : name, inv : CInventoryComponent)
	{
		var ids		: array<SItemUniqueId>;
		var i 		: int;
		
		if( inv.HasItem(item) )
		{
			ids = inv.GetItemsIds(item);
			for (i = 0; i < ids.Size(); i += 1)
			{
				if ( inv.GetItemModifierInt(ids[i], 'DoNotAdjustNGPDLC') <= 0 )
				{
					inv.AddItemBaseAbility(ids[i], mod);
					inv.SetItemModifierInt(ids[i], 'DoNotAdjustNGPDLC', 1);	
				}
			}
		}
		
	}
	
	private final function NewGamePlusAdjustDLC1TemerianSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC5NilfgardianSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC10WolfSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP Wolf Armor',   'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 1', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 2', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 3', 'NGP DLC Compatibility Chest Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword',   'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 1', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 2', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 3', 'NGP Wolf Steel Sword Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword',   'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 1', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 2', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 3', 'NGP Wolf Silver Sword Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC14SkelligeSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC18NetflixSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP Netflix Armor',   'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Armor 1', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Armor 2', 'NGP DLC Compatibility Chest Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Netflix Boots 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Boots 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Boots', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Netflix Gloves 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Gloves 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Netflix Pants 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Pants 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix Pants', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Netflix steel sword',   'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix steel sword 1', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix steel sword 2', 'NGP Wolf Steel Sword Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Netflix silver sword',   'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix silver sword 1', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Netflix silver sword 2', 'NGP Wolf Silver Sword Mod', inv);
	}
	
	
	
	private final function NewGamePlusAdjustDolBlathannaSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP Dol Blathanna Armor',   'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Dol Blathanna Boots', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Dol Blathanna Gloves', 'NGP DLC Compatibility Armor Mod', inv);		
		NewGamePlusAdjustDLCItem('NGP Dol Blathanna Pants', 'NGP DLC Compatibility Armor Mod', inv);		
		NewGamePlusAdjustDLCItem('NGP Dol Blathanna longsword',   'NGP Wolf Steel Sword Mod', inv);		
		NewGamePlusAdjustDLCItem('NGP White Widow of Dol Blathanna',   'NGP Wolf Silver Sword Mod', inv);
	}
	
	
	
	private final function NewGamePlusAdjustWhiteTigerSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP White Tiger Armor',   'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP White Tiger Boots', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP White Tiger Gloves', 'NGP DLC Compatibility Armor Mod', inv);		
		NewGamePlusAdjustDLCItem('NGP White Tiger Pants', 'NGP DLC Compatibility Armor Mod', inv);		
		NewGamePlusAdjustDLCItem('NGP Steel Vixen',   'NGP Wolf Steel Sword Mod', inv);		
		NewGamePlusAdjustDLCItem('NGP Silver Vixen',   'NGP Wolf Silver Sword Mod', inv);
	}
	
	private final function NewGamePlusReplaceViperSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Viper School steel sword', 'NGP Viper School steel sword', inv);
		
		NewGamePlusReplaceItem('Viper School silver sword', 'NGP Viper School silver sword', inv);
	}
	
	private final function NewGamePlusReplaceLynxSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Lynx Armor', 'NGP Lynx Armor', inv);
		NewGamePlusReplaceItem('Lynx Armor 1', 'NGP Lynx Armor 1', inv);
		NewGamePlusReplaceItem('Lynx Armor 2', 'NGP Lynx Armor 2', inv);
		NewGamePlusReplaceItem('Lynx Armor 3', 'NGP Lynx Armor 3', inv);
		
		NewGamePlusReplaceItem('Lynx Gloves 1', 'NGP Lynx Gloves 1', inv);
		NewGamePlusReplaceItem('Lynx Gloves 2', 'NGP Lynx Gloves 2', inv);
		NewGamePlusReplaceItem('Lynx Gloves 3', 'NGP Lynx Gloves 3', inv);
		NewGamePlusReplaceItem('Lynx Gloves 4', 'NGP Lynx Gloves 4', inv);
		
		NewGamePlusReplaceItem('Lynx Pants 1', 'NGP Lynx Pants 1', inv);
		NewGamePlusReplaceItem('Lynx Pants 2', 'NGP Lynx Pants 2', inv);
		NewGamePlusReplaceItem('Lynx Pants 3', 'NGP Lynx Pants 3', inv);
		NewGamePlusReplaceItem('Lynx Pants 4', 'NGP Lynx Pants 4', inv);
		
		NewGamePlusReplaceItem('Lynx Boots 1', 'NGP Lynx Boots 1', inv);
		NewGamePlusReplaceItem('Lynx Boots 2', 'NGP Lynx Boots 2', inv);
		NewGamePlusReplaceItem('Lynx Boots 3', 'NGP Lynx Boots 3', inv);
		NewGamePlusReplaceItem('Lynx Boots 4', 'NGP Lynx Boots 4', inv);
		
		NewGamePlusReplaceItem('Lynx School steel sword', 'NGP Lynx School steel sword', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 1', 'NGP Lynx School steel sword 1', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 2', 'NGP Lynx School steel sword 2', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 3', 'NGP Lynx School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Lynx School silver sword', 'NGP Lynx School silver sword', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 1', 'NGP Lynx School silver sword 1', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 2', 'NGP Lynx School silver sword 2', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 3', 'NGP Lynx School silver sword 3', inv);
	}
	
	private final function NewGamePlusReplaceGryphonSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Gryphon Armor', 'NGP Gryphon Armor', inv);
		NewGamePlusReplaceItem('Gryphon Armor 1', 'NGP Gryphon Armor 1', inv);
		NewGamePlusReplaceItem('Gryphon Armor 2', 'NGP Gryphon Armor 2', inv);
		NewGamePlusReplaceItem('Gryphon Armor 3', 'NGP Gryphon Armor 3', inv);
		
		NewGamePlusReplaceItem('Gryphon Gloves 1', 'NGP Gryphon Gloves 1', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 2', 'NGP Gryphon Gloves 2', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 3', 'NGP Gryphon Gloves 3', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 4', 'NGP Gryphon Gloves 4', inv);
		
		NewGamePlusReplaceItem('Gryphon Pants 1', 'NGP Gryphon Pants 1', inv);
		NewGamePlusReplaceItem('Gryphon Pants 2', 'NGP Gryphon Pants 2', inv);
		NewGamePlusReplaceItem('Gryphon Pants 3', 'NGP Gryphon Pants 3', inv);
		NewGamePlusReplaceItem('Gryphon Pants 4', 'NGP Gryphon Pants 4', inv);
		
		NewGamePlusReplaceItem('Gryphon Boots 1', 'NGP Gryphon Boots 1', inv);
		NewGamePlusReplaceItem('Gryphon Boots 2', 'NGP Gryphon Boots 2', inv);
		NewGamePlusReplaceItem('Gryphon Boots 3', 'NGP Gryphon Boots 3', inv);
		NewGamePlusReplaceItem('Gryphon Boots 4', 'NGP Gryphon Boots 4', inv);
		
		NewGamePlusReplaceItem('Gryphon School steel sword', 'NGP Gryphon School steel sword', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 1', 'NGP Gryphon School steel sword 1', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 2', 'NGP Gryphon School steel sword 2', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 3', 'NGP Gryphon School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Gryphon School silver sword', 'NGP Gryphon School silver sword', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 1', 'NGP Gryphon School silver sword 1', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 2', 'NGP Gryphon School silver sword 2', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 3', 'NGP Gryphon School silver sword 3', inv);
	}
	
	private final function NewGamePlusReplaceBearSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Bear Armor', 'NGP Bear Armor', inv);
		NewGamePlusReplaceItem('Bear Armor 1', 'NGP Bear Armor 1', inv);
		NewGamePlusReplaceItem('Bear Armor 2', 'NGP Bear Armor 2', inv);
		NewGamePlusReplaceItem('Bear Armor 3', 'NGP Bear Armor 3', inv);
		
		NewGamePlusReplaceItem('Bear Gloves 1', 'NGP Bear Gloves 1', inv);
		NewGamePlusReplaceItem('Bear Gloves 2', 'NGP Bear Gloves 2', inv);
		NewGamePlusReplaceItem('Bear Gloves 3', 'NGP Bear Gloves 3', inv);
		NewGamePlusReplaceItem('Bear Gloves 4', 'NGP Bear Gloves 4', inv);
		
		NewGamePlusReplaceItem('Bear Pants 1', 'NGP Bear Pants 1', inv);
		NewGamePlusReplaceItem('Bear Pants 2', 'NGP Bear Pants 2', inv);
		NewGamePlusReplaceItem('Bear Pants 3', 'NGP Bear Pants 3', inv);
		NewGamePlusReplaceItem('Bear Pants 4', 'NGP Bear Pants 4', inv);
		
		NewGamePlusReplaceItem('Bear Boots 1', 'NGP Bear Boots 1', inv);
		NewGamePlusReplaceItem('Bear Boots 2', 'NGP Bear Boots 2', inv);
		NewGamePlusReplaceItem('Bear Boots 3', 'NGP Bear Boots 3', inv);
		NewGamePlusReplaceItem('Bear Boots 4', 'NGP Bear Boots 4', inv);
		
		NewGamePlusReplaceItem('Bear School steel sword', 'NGP Bear School steel sword', inv);
		NewGamePlusReplaceItem('Bear School steel sword 1', 'NGP Bear School steel sword 1', inv);
		NewGamePlusReplaceItem('Bear School steel sword 2', 'NGP Bear School steel sword 2', inv);
		NewGamePlusReplaceItem('Bear School steel sword 3', 'NGP Bear School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Bear School silver sword', 'NGP Bear School silver sword', inv);
		NewGamePlusReplaceItem('Bear School silver sword 1', 'NGP Bear School silver sword 1', inv);
		NewGamePlusReplaceItem('Bear School silver sword 2', 'NGP Bear School silver sword 2', inv);
		NewGamePlusReplaceItem('Bear School silver sword 3', 'NGP Bear School silver sword 3', inv);
	}
		
	private final function NewGamePlusReplaceEP1(out inv : CInventoryComponent)
	{	
		NewGamePlusReplaceItem('Ofir Armor', 'NGP Ofir Armor', inv);
		NewGamePlusReplaceItem('Ofir Sabre 2', 'NGP Ofir Sabre 2', inv);
		
		NewGamePlusReplaceItem('Crafted Burning Rose Armor', 'NGP Crafted Burning Rose Armor', inv);
		NewGamePlusReplaceItem('Crafted Burning Rose Gloves', 'NGP Crafted Burning Rose Gloves', inv);
		NewGamePlusReplaceItem('Crafted Burning Rose Sword', 'NGP Crafted Burning Rose Sword', inv);
		
		NewGamePlusReplaceItem('Crafted Ofir Armor', 'NGP Crafted Ofir Armor', inv);
		NewGamePlusReplaceItem('Crafted Ofir Boots', 'NGP Crafted Ofir Boots', inv);
		NewGamePlusReplaceItem('Crafted Ofir Gloves', 'NGP Crafted Ofir Gloves', inv);
		NewGamePlusReplaceItem('Crafted Ofir Pants', 'NGP Crafted Ofir Pants', inv);
		NewGamePlusReplaceItem('Crafted Ofir Steel Sword', 'NGP Crafted Ofir Steel Sword', inv);
		
		NewGamePlusReplaceItem('EP1 Crafted Witcher Silver Sword', 'NGP EP1 Crafted Witcher Silver Sword', inv);
		NewGamePlusReplaceItem('Olgierd Sabre', 'NGP Olgierd Sabre', inv);
		
		NewGamePlusReplaceItem('EP1 Witcher Armor', 'NGP EP1 Witcher Armor', inv);
		NewGamePlusReplaceItem('EP1 Witcher Boots', 'NGP EP1 Witcher Boots', inv);
		NewGamePlusReplaceItem('EP1 Witcher Gloves', 'NGP EP1 Witcher Gloves', inv);
		NewGamePlusReplaceItem('EP1 Witcher Pants', 'NGP EP1 Witcher Pants', inv);
		NewGamePlusReplaceItem('EP1 Viper School steel sword', 'NGP EP1 Viper School steel sword', inv);
		NewGamePlusReplaceItem('EP1 Viper School silver sword', 'NGP EP1 Viper School silver sword', inv);
	}
	
	private final function NewGamePlusReplaceEP2WitcherSets(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Lynx Armor 4', 'NGP Lynx Armor 4', inv);
		NewGamePlusReplaceItem('Gryphon Armor 4', 'NGP Gryphon Armor 4', inv);
		NewGamePlusReplaceItem('Bear Armor 4', 'NGP Bear Armor 4', inv);
		NewGamePlusReplaceItem('Wolf Armor 4', 'NGP Wolf Armor 4', inv);
		NewGamePlusReplaceItem('Red Wolf Armor 1', 'NGP Red Wolf Armor 1', inv);
		
		NewGamePlusReplaceItem('Lynx Gloves 5', 'NGP Lynx Gloves 5', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 5', 'NGP Gryphon Gloves 5', inv);
		NewGamePlusReplaceItem('Bear Gloves 5', 'NGP Bear Gloves 5', inv);
		NewGamePlusReplaceItem('Wolf Gloves 5', 'NGP Wolf Gloves 5', inv);
		NewGamePlusReplaceItem('Red Wolf Gloves 1', 'NGP Red Wolf Gloves 1', inv);
		
		NewGamePlusReplaceItem('Lynx Pants 5', 'NGP Lynx Pants 5', inv);
		NewGamePlusReplaceItem('Gryphon Pants 5', 'NGP Gryphon Pants 5', inv);
		NewGamePlusReplaceItem('Bear Pants 5', 'NGP Bear Pants 5', inv);
		NewGamePlusReplaceItem('Wolf Pants 5', 'NGP Wolf Pants 5', inv);
		NewGamePlusReplaceItem('Red Wolf Pants 1', 'NGP Red Wolf Pants 1', inv);
		
		NewGamePlusReplaceItem('Lynx Boots 5', 'NGP Lynx Boots 5', inv);
		NewGamePlusReplaceItem('Gryphon Boots 5', 'NGP Gryphon Boots 5', inv);
		NewGamePlusReplaceItem('Bear Boots 5', 'NGP Bear Boots 5', inv);
		NewGamePlusReplaceItem('Wolf Boots 5', 'NGP Wolf Boots 5', inv);
		NewGamePlusReplaceItem('Red Wolf Boots 1', 'NGP Red Wolf Boots 1', inv);
		
		
		NewGamePlusReplaceItem('Lynx School steel sword 4', 'NGP Lynx School steel sword 4', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 4', 'NGP Gryphon School steel sword 4', inv);
		NewGamePlusReplaceItem('Bear School steel sword 4', 'NGP Bear School steel sword 4', inv);
		NewGamePlusReplaceItem('Wolf School steel sword 4', 'NGP Wolf School steel sword 4', inv);
		NewGamePlusReplaceItem('Red Wolf School steel sword 1', 'NGP Red Wolf School steel sword 1', inv);
		
		NewGamePlusReplaceItem('Lynx School silver sword 4', 'NGP Lynx School silver sword 4', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 4', 'NGP Gryphon School silver sword 4', inv);
		NewGamePlusReplaceItem('Bear School silver sword 4', 'NGP Bear School silver sword 4', inv);
		NewGamePlusReplaceItem('Wolf School silver sword 4', 'NGP Wolf School silver sword 4', inv);
		NewGamePlusReplaceItem('Red Wolf School silver sword 1', 'NGP Red Wolf School silver sword 1', inv);
	}
	
	private final function NewGamePlusReplaceEP2Items(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Guard Lvl1 Armor 3', 'NGP Guard Lvl1 Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Armor 3', 'NGP Guard Lvl1 A Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Armor 3', 'NGP Guard Lvl2 Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Armor 3', 'NGP Guard Lvl2 A Armor 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Armor 3', 'NGP Knight Geralt Armor 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Armor 3', 'NGP Knight Geralt A Armor 3', inv);
		NewGamePlusReplaceItem('q702_vampire_armor', 'NGP q702_vampire_armor', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Gloves 3', 'NGP Guard Lvl1 Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Gloves 3', 'NGP Guard Lvl1 A Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Gloves 3', 'NGP Guard Lvl2 Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Gloves 3', 'NGP Guard Lvl2 A Gloves 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Gloves 3', 'NGP Knight Geralt Gloves 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Gloves 3', 'NGP Knight Geralt A Gloves 3', inv);
		NewGamePlusReplaceItem('q702_vampire_gloves', 'NGP q702_vampire_gloves', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Pants 3', 'NGP Guard Lvl1 Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Pants 3', 'NGP Guard Lvl1 A Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Pants 3', 'NGP Guard Lvl2 Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Pants 3', 'NGP Guard Lvl2 A Pants 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Pants 3', 'NGP Knight Geralt Pants 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Pants 3', 'NGP Knight Geralt A Pants 3', inv);
		NewGamePlusReplaceItem('q702_vampire_pants', 'NGP q702_vampire_pants', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Boots 3', 'NGP Guard Lvl1 Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Boots 3', 'NGP Guard Lvl1 A Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Boots 3', 'NGP Guard Lvl2 Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Boots 3', 'NGP Guard Lvl2 A Boots 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Boots 3', 'NGP Knight Geralt Boots 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Boots 3', 'NGP Knight Geralt A Boots 3', inv);
		NewGamePlusReplaceItem('q702_vampire_boots', 'NGP q702_vampire_boots', inv);
		
		NewGamePlusReplaceItem('Serpent Steel Sword 1', 'NGP Serpent Steel Sword 1', inv);
		NewGamePlusReplaceItem('Serpent Steel Sword 2', 'NGP Serpent Steel Sword 2', inv);
		NewGamePlusReplaceItem('Serpent Steel Sword 3', 'NGP Serpent Steel Sword 3', inv);
		NewGamePlusReplaceItem('Guard lvl1 steel sword 3', 'NGP Guard lvl1 steel sword 3', inv);
		NewGamePlusReplaceItem('Guard lvl2 steel sword 3', 'NGP Guard lvl2 steel sword 3', inv);
		NewGamePlusReplaceItem('Knights steel sword 3', 'NGP Knights steel sword 3', inv);
		NewGamePlusReplaceItem('Hanza steel sword 3', 'NGP Hanza steel sword 3', inv);
		NewGamePlusReplaceItem('Toussaint steel sword 3', 'NGP Toussaint steel sword 3', inv);
		NewGamePlusReplaceItem('q702 vampire steel sword', 'NGP q702 vampire steel sword', inv);
		
		NewGamePlusReplaceItem('Serpent Silver Sword 1', 'NGP Serpent Silver Sword 1', inv);
		NewGamePlusReplaceItem('Serpent Silver Sword 2', 'NGP Serpent Silver Sword 2', inv);
		NewGamePlusReplaceItem('Serpent Silver Sword 3', 'NGP Serpent Silver Sword 3', inv);
	}
	
	public function GetEquippedSword(steel : bool) : SItemUniqueId
	{
		var item : SItemUniqueId;
		
		if(steel)
			GetItemEquippedOnSlot(EES_SteelSword, item);
		else
			GetItemEquippedOnSlot(EES_SilverSword, item);
			
		return item;
	}
	
	timer function BroadcastRain( deltaTime : float, id : int )
	{
		var rainStrength : float = 0;
		rainStrength = GetRainStrength();
		if( rainStrength > 0.5 )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'RainAction', 2.0f , 50.0f, -1.f, -1, true); 
			LogReactionSystem( "'RainAction' was sent by Player - single broadcast - distance: 50.0" ); 
		}
	}
	
	function InitializeParryType()
	{
		var i, j : int;
		
		parryTypeTable.Resize( EnumGetMax('EAttackSwingType')+1 );
		for( i = 0; i < EnumGetMax('EAttackSwingType')+1; i += 1 )
		{
			parryTypeTable[i].Resize( EnumGetMax('EAttackSwingDirection')+1 );
		}
		parryTypeTable[AST_Horizontal][ASD_UpDown] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_DownUp] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_LeftRight] = PT_Left;
		parryTypeTable[AST_Horizontal][ASD_RightLeft] = PT_Right;
		parryTypeTable[AST_Vertical][ASD_UpDown] = PT_Up;
		parryTypeTable[AST_Vertical][ASD_DownUp] = PT_Down;
		parryTypeTable[AST_Vertical][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_Vertical][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_LeftRight] = PT_UpLeft;
		parryTypeTable[AST_DiagonalUp][ASD_RightLeft] = PT_RightUp;
		parryTypeTable[AST_DiagonalDown][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_LeftRight] = PT_LeftDown;
		parryTypeTable[AST_DiagonalDown][ASD_RightLeft] = PT_DownRight;
		parryTypeTable[AST_Jab][ASD_UpDown] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_DownUp] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_LeftRight] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_RightLeft] = PT_Jab;	
	}
	
	
	
	
	
	
	event OnDeath( damageAction : W3DamageAction )
	{
		var items 		: array< SItemUniqueId >;
		var i, size 	: int;	
		var slot		: EEquipmentSlots;
		var holdSlot	: name;
	
		super.OnDeath( damageAction );
	
		items = GetHeldItems();
				
		if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait')
		{
			OnRangedForceHolster( true, true, true );		
			rangedWeapon.ClearDeployedEntity(true);
		}
		
		size = items.Size();
		
		if ( size > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				if ( this.inv.IsIdValid( items[i] ) && !( this.inv.IsItemCrossbow( items[i] ) ) )
				{
					holdSlot = this.inv.GetItemHoldSlot( items[i] );				
				
					if (  holdSlot == 'l_weapon' && this.IsHoldingItemInLHand() )
					{
						this.OnUseSelectedItem( true );
					}			
			
					DropItemFromSlot( holdSlot, false );
					
					if ( holdSlot == 'r_weapon' )
					{
						slot = this.GetItemSlot( items[i] );
						if ( UnequipItemFromSlot( slot ) )
							Log( "Unequip" );
					}
				}
			}
		}
	}
	
	
	
	
	
	
	
	function HandleMovement( deltaTime : float )
	{
		super.HandleMovement( deltaTime );
		
		rawCameraHeading = theCamera.GetCameraHeading();
	}
		
	
	
	
	
	
	
	function ToggleSpecialAttackHeavyAllowed( toggle : bool)
	{
		specialAttackHeavyAllowed = toggle;
	}
	
	function GetReputationManager() : W3Reputation
	{
		return reputationManager;
	}
			
	function OnRadialMenuItemChoose( selectedItem : string ) 
	{
		var iSlotId : int;
		var item : SItemUniqueId;
		
		if ( selectedItem != "Crossbow" )
		{
			if ( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
				OnRangedForceHolster( true, false );
		}
		
		
		switch(selectedItem)
		{
			
			case "Meditation":
				theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu' );
				break;			
			// -= WMK:modQuickSlots =-
			/*
			case "Slot1":
				GetItemEquippedOnSlot( EES_Petard1, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Petard1 );
				}
				else
				{
					SelectQuickslotItem( EES_Petard2 );
				}
				break;
				
			case "Slot2":
				GetItemEquippedOnSlot( EES_Petard2, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Petard2 );
				}
				else
				{
					SelectQuickslotItem( EES_Petard1 );
				}
				break;
			*/
			case "Slot1":
				SelectQuickslotItem(EES_Petard1);
				break;
			case "Slot2":
				SelectQuickslotItem(EES_Petard2);
				break;
			case "Slot5":
				SelectQuickslotItem(EES_Petard3);
				break;
			case "Slot6":
				SelectQuickslotItem(EES_Petard4);
				break;
			// -= WMK:modQuickSlots =-
				
			case "Crossbow":
				SelectQuickslotItem(EES_RangedWeapon);
				break;
				
			case "Slot3":
				GetItemEquippedOnSlot( EES_Quickslot1, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Quickslot1 );
				}
				else
				{
					SelectQuickslotItem( EES_Quickslot2 );
				}
				break;
				
			case "Slot4": 
				GetItemEquippedOnSlot( EES_Quickslot2, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Quickslot2 );
				}
				else
				{
					SelectQuickslotItem( EES_Quickslot1 );
				}
				break;
				
			default:
				SetEquippedSign(SignStringToEnum( selectedItem ));
				FactsRemove("SignToggled");
				break;
		}
	}
	
	function ToggleNextItem()
	{
		var quickSlotItems : array< EEquipmentSlots >;
		var currentSelectedItem : SItemUniqueId;
		var item : SItemUniqueId;
		var i : int;
		
		for( i = EES_Quickslot2; i > EES_Petard1 - 1; i -= 1 )
		{
			GetItemEquippedOnSlot( i, item );
			if( inv.IsIdValid( item ) )
			{
				quickSlotItems.PushBack( i );
			}
		}
		if( !quickSlotItems.Size() )
		{
			return;
		}
		
		currentSelectedItem = GetSelectedItemId();
		
		if( inv.IsIdValid( currentSelectedItem ) )
		{
			for( i = 0; i < quickSlotItems.Size(); i += 1 )
			{
				GetItemEquippedOnSlot( quickSlotItems[i], item );
				if( currentSelectedItem == item )
				{
					if( i == quickSlotItems.Size() - 1 )
					{
						SelectQuickslotItem( quickSlotItems[ 0 ] );
					}
					else
					{
						SelectQuickslotItem( quickSlotItems[ i + 1 ] );
					}
					return;
				}
			}
		}
		else 
		{
			SelectQuickslotItem( quickSlotItems[ 0 ] );
		}
	}
		
	
	function SetEquippedSign( signType : ESignType )
	{
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		var fxName : name;
		
		// W3EE - Begin
		if(!IsSignBlocked(signType) || IsSwimming())
		// W3EE - End
		{
			equippedSign = signType;
			FactsSet("CurrentlySelectedSign", equippedSign);
		}
		
		//Kolaris - Invocation
		if( (HasAbility('Runeword 40 _Stats', true) || HasAbility('Runeword 41 _Stats', true) || HasAbility('Runeword 42 _Stats', true)) /*&& !infusionCooldown*/)
		{
			// DrainFocus(1.0f);
			// W3EE - End
			runewordInfusionType = signType;
			items = inv.GetHeldWeapons();
			weaponEnt = inv.GetItemEntityUnsafe(items[0]);
			
			
			weaponEnt.StopEffect('runeword_aard');
			weaponEnt.StopEffect('runeword_axii');
			weaponEnt.StopEffect('runeword_igni');
			weaponEnt.StopEffect('runeword_quen');
			weaponEnt.StopEffect('runeword_yrden');
			
			
			if(signType == ST_Aard)
				fxName = 'runeword_aard';
			else if(signType == ST_Axii)
				fxName = 'runeword_axii';
			else if(signType == ST_Igni)
				fxName = 'runeword_igni';
			else if(signType == ST_Quen)
				fxName = 'runeword_quen';
			else if(signType == ST_Yrden)
				fxName = 'runeword_yrden';
			
			weaponEnt.PlayEffect(fxName);
			
			//infusionCooldown = true;
			//AddTimer('InfusionCooldown', 1.5f, false);
		}
	}
	
	function GetEquippedSign() : ESignType
	{
		return equippedSign;
	}
	
	function GetCurrentlyCastSign() : ESignType
	{
		return currentlyCastSign;
	}
	
	function SetCurrentlyCastSign( type : ESignType, entity : W3SignEntity )
	{
		currentlyCastSign = type;
		
		if( type != ST_None )
		{
			signs[currentlyCastSign].entity = entity;
		}
	}
	
	function GetCurrentSignEntity() : W3SignEntity
	{
		if(currentlyCastSign == ST_None)
			return NULL;
			
		return signs[currentlyCastSign].entity;
	}
	
	public function GetSignEntity(type : ESignType) : W3SignEntity
	{
		if(type == ST_None)
			return NULL;
			
		return signs[type].entity;
	}
	
	public function GetSignTemplate(type : ESignType) : CEntityTemplate
	{
		if(type == ST_None)
			return NULL;
			
		return signs[type].template;
	}
	
	public function IsCurrentSignChanneled() : bool
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
			return signs[currentlyCastSign].entity.OnCheckChanneling();
		
		return false;
	}
	
	function IsCastingSign() : bool
	{
		return currentlyCastSign != ST_None;
	}
	
	
	protected function IsInCombatActionCameraRotationEnabled() : bool
	{
		if( IsInCombatAction() && ( GetCombatAction() == EBAT_EMPTY || GetCombatAction() == EBAT_Parry ) )
		{
			return true;
		}
		
		return !bIsInCombatAction;
	}
	
	function SetHoldBeforeOpenRadialMenuTime ( time : float )
	{
		_HoldBeforeOpenRadialMenuTime = time;
	}
	
	
	
	
	
	
	
	public function RepairItem (  rapairKitId : SItemUniqueId, usedOnItem : SItemUniqueId )
	{
		var itemMaxDurablity 		: float;
		var itemCurrDurablity 		: float;
		var baseRepairValue		  	: float;
		var reapirValue				: float;
		var itemAttribute			: SAbilityAttributeValue;
		//Kolaris - Advanced Maintenance
		var effect : SCustomEffectParams;
		var effectParams : W3EnhanceBuffParams;
		
		itemMaxDurablity = inv.GetItemMaxDurability(usedOnItem);
		itemCurrDurablity = inv.GetItemDurability(usedOnItem);
		itemAttribute = inv.GetItemAttributeValue ( rapairKitId, 'repairValue' );
		
		if( !(CanUseSkill(S_Perk_18)) && itemCurrDurablity >= itemMaxDurablity )
		{
			return;
		}
		
		if ( inv.IsItemAnyArmor ( usedOnItem )|| inv.IsItemWeapon( usedOnItem ) )
		{			
			
			baseRepairValue = (itemMaxDurablity - itemCurrDurablity) * itemAttribute.valueMultiplicative;					
			reapirValue = MinF( itemCurrDurablity + baseRepairValue, itemMaxDurablity );
			
			inv.SetItemDurabilityScript ( usedOnItem, MinF ( reapirValue, itemMaxDurablity ));
			//Kolaris - Advanced Maintenance
			if(CanUseSkill(S_Perk_18))
			{
				if( inv.IsItemWeapon( usedOnItem ) )
				{
					effect.effectType = EET_EnhancedWeapon;
					effect.creator = this;
					effectParams = new W3EnhanceBuffParams in this;
					effectParams.item = usedOnItem;
					effect.sourceName = inv.GetItemName(usedOnItem);
					effect.buffSpecificParams = effectParams;
					AddEffectCustom(effect);
					delete effectParams;
				}
				else if( IsAnyItemEquippedOnSlot(EES_Armor) )
				{
					if( !inv.IsItemChestArmor(usedOnItem) )
						inv.GetItemEquippedOnSlot(EES_Armor, usedOnItem);
					
					effect.effectType = EET_EnhancedArmor;
					effect.creator = this;
					effectParams = new W3EnhanceBuffParams in this;
					effectParams.item = usedOnItem;
					effect.sourceName = inv.GetItemName(usedOnItem);
					effect.buffSpecificParams = effectParams;
					AddEffectCustom(effect);
					delete effectParams;
				}				
			}
		}
		
		if( !CanUseSkill(S_Perk_18) || RandF() > 0.5f )
			inv.RemoveItem ( rapairKitId, 1 );
		
	}
	public function HasRepairAbleGearEquiped ( ) : bool
	{
		var curEquipedItem : SItemUniqueId;
		
		return ( GetItemEquippedOnSlot(EES_Armor, curEquipedItem) || GetItemEquippedOnSlot(EES_Boots, curEquipedItem) || GetItemEquippedOnSlot(EES_Pants, curEquipedItem) || GetItemEquippedOnSlot(EES_Gloves, curEquipedItem)) == true;
	}
	public function HasRepairAbleWaponEquiped () : bool
	{
		var curEquipedItem : SItemUniqueId;
		
		return ( GetItemEquippedOnSlot(EES_SilverSword, curEquipedItem) || GetItemEquippedOnSlot(EES_SteelSword, curEquipedItem) ) == true;
	}
	public function IsItemRepairAble ( item : SItemUniqueId ) : bool
	{
		//Kolaris - Advanced Maintenance
		return inv.GetItemDurabilityRatio(item) <= 0.99999f || CanUseSkill(S_Perk_18);
	}
	
	
	
	
	
	
		
	// W3EE - Begin
	public function ApplyOilHack( oilId : SItemUniqueId, usedOnItem : SItemUniqueId )
	{
		super.ApplyOil(oilId, usedOnItem);
	}
	// W3EE - End
	
	public function ApplyOil( oilId : SItemUniqueId, usedOnItem : SItemUniqueId ) : bool
	{
		var tutStateOil : W3TutorialManagerUIHandlerStateOils;
		
		// W3EE - Begin		
		/*if( !super.ApplyOil( oilId, usedOnItem ))
			return false;*/
		
		if( IsMeditating() || !Options().GetUseOilAnimation() )
			return super.ApplyOil(oilId, usedOnItem);
		else
			GetAnimManager().PerformAnimation(EES_InvalidSlot, oilId, usedOnItem);
		// W3EE - End
		
		return true;
	}
	
	private final function RemoveExtraOilsFromItem( item : SItemUniqueId, hasWolfSet : bool, hasEmulation : bool )
	{
		var oils : array< CBaseGameplayEffect >;
		var i, cnt, maxOils : int;
		var buff : W3Effect_Oil;

		maxOils = 1;
		if(hasWolfSet) maxOils += 1;
		if(hasEmulation) maxOils += 1;

		oils = GetBuffs( EET_Oil );
		for( i=0; i<oils.Size(); i+=1 )
		{			
			buff = (W3Effect_Oil) oils[ i ];
			if( buff && buff.GetSwordItemId() == item )
			{
				cnt += 1;
			}
		}
		while( cnt > maxOils )
		{
			inv.RemoveOldestOilFromItem( item );
			cnt -= 1;
		}
	}
	
	
	
	
	
	
	timer function Mutation5Disable( dt : float, id : int )
	{
		RemoveBuff(EET_Mutation5);
	}
	
	function ReduceDamage(out damageData : W3DamageAction)
	{
		var actorAttacker : CActor;
		var quen : W3QuenEntity;
		var attackRange : CAIAttackRange;
		var angleDist, distToAttacker, currAdrenaline, adrenReducedDmg, focus : float;
		var attackName : name;
		var safeDodgeAngle : int;
		var grazeDamageReduction : SAbilityAttributeValue; //Kolaris - Dodge Tweaks
		//Kolaris - Deflection
		var deflectionEffect : SCustomEffectParams;
		
		super.ReduceDamage(damageData);
		//Kolaris - Relict Decoction
		//((W3Decoction7_Effect)GetBuff(EET_Decoction7)).ActivateQuen(damageData, this);
		quen = (W3QuenEntity)signs[ST_Quen].entity;
		if( !damageData.DealsAnyDamage() )
			return;
		
		actorAttacker = (CActor)damageData.attacker;
		if(actorAttacker && ( IsCurrentlyDodging() || IsInCombatAction() && ((int)GetBehaviorVariable( 'combatActionType' ) == CAT_Dodge || (int)GetBehaviorVariable( 'combatActionType' ) == CAT_Roll) ) )
		{
			angleDist = AbsF(AngleDistance(evadeHeading, actorAttacker.GetHeading()));
			distToAttacker = VecDistance(this.GetWorldPosition(),damageData.attacker.GetWorldPosition());
			attackName = actorAttacker.GetLastAttackRangeName();
			attackRange = theGame.GetAttackRangeForEntity( actorAttacker, attackName );
			//Kolaris - Footwork, Kolaris - Cat Potion
			if( RandRange(100, 1) < GetSkillLevel(S_Sword_s09) * 10 || (HasBuff(EET_Cat) && GetPotionBuffLevel(EET_Cat) == 3) )
				damageData.SetHitAnimationPlayType(EAHA_ForceNo);
				
			//Kolaris - Dodge Tweaks
			safeDodgeAngle = Combat().GetSafeDodgeAngle();
			grazeDamageReduction = GetAttributeValue('graze_damage_reduction');
			//Kolaris - Footwork
			grazeDamageReduction.valueMultiplicative += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s09, 'damage_reduction', false, true)) * GetSkillLevel(S_Sword_s09);
			//Kolaris - Cat Set
			if( HasBuff(EET_LynxSetAttack) )
				grazeDamageReduction.valueMultiplicative += 0.1f * GetSetPartsEquipped(EIST_Lynx);
			//Kolaris - Spectre Decoction
			if( HasBuff(EET_Decoction6) )
				grazeDamageReduction.valueMultiplicative += 1.f;
			
			if( /*damageData.CanBeDodged()*/ Combat().GetEnemyAoESpecialAttackType(actorAttacker) != 2 && ((angleDist <= safeDodgeAngle && attackName != 'stomp' && attackName != 'anchor_special_far' && attackName != 'anchor_far') || ((attackName == 'stomp' || attackName == 'anchor_special_far' || attackName == 'anchor_far') && distToAttacker > attackRange.rangeMax * (1 - safeDodgeAngle / 360))) )
			{
				//Kolaris - New Moon Set
				if( isInvulnerableDodge || (IsSetBonusActive(EISB_New_Moon) && GetDayPart(GameTimeCreate()) == EDP_Midnight) && !HasBuff(EET_Overexertion) )
				{
					damageData.SetWasDodged();
					damageData.ClearEffects();
					damageData.SetAllProcessedDamageAs(0);
					damageData.SetHitAnimationPlayType(EAHA_ForceNo);
					damageData.SetSuppressHitSounds(true);
					damageData.SetCanPlayHitParticle(false);
				}
				else
				if( IsMutationActive(EPMT_Mutation10) )
				{
					damageData.SetWasDodged();
					damageData.ClearEffects();
					damageData.SetAllProcessedDamageAs(0);
					damageData.SetHitAnimationPlayType(EAHA_ForceNo);
					damageData.SetSuppressHitSounds(true);
					damageData.SetCanPlayHitParticle(false);
					Combat().StaminaLoss(ESAT_Roll, 1.f - (safeDodgeAngle / 360));
					GetPoiseEffect().ReducePoise(10.f + 10.f * MaxF(0, 1 - grazeDamageReduction.valueMultiplicative), 2.f, 'Dodge');
				}
				else
				if( (isGrazeDodge && !HasBuff(EET_Overexertion)) || (isInvulnerableDodge && HasBuff(EET_Overexertion)) )
				{
					damageData.SetWasPartiallyDodged();
					damageData.RemoveBuffsByType(EET_Bleeding);
					//Kolaris - Dodge Tweaks
					damageData.processedDmg.vitalityDamage *= 0.50;
					damageData.processedDmg.essenceDamage *= 0.50;
					damageData.processedDmg.vitalityDamage *= MaxF(0, 1 - grazeDamageReduction.valueMultiplicative);
				}
			}
			//Kolaris - Mutation 10
			else if( IsMutationActive(EPMT_Mutation10) )
			{
				damageData.SetWasDodged();
				damageData.ClearEffects();
				damageData.SetAllProcessedDamageAs(0);
				damageData.SetHitAnimationPlayType(EAHA_ForceNo);
				damageData.SetSuppressHitSounds(true);
				damageData.SetCanPlayHitParticle(false);
				Combat().StaminaLoss(ESAT_Roll, 1.5f - (safeDodgeAngle / 360));
				GetPoiseEffect().ReducePoise(10.f + 10.f * MaxF(0, 1 - grazeDamageReduction.valueMultiplicative), 2.f, 'Dodge');
			}
			//Kolaris - Dodge Tweaks
			else
			{
				damageData.SetWasPartiallyDodged();
				damageData.processedDmg.vitalityDamage *= MaxF(0, 1 - grazeDamageReduction.valueMultiplicative);
			}
		}
		
		if(quen && damageData.GetBuffSourceName() != "FallingDamage")
		{
			quen.OnTargetHit( damageData );
		}	
		
		//Kolaris - Conjunction
		if( HasAbility('Glyphword 27 _Stats', true) )
			damageData.processedDmg.vitalityDamage = Combat().ProcessConjunctionDamage(damageData);
		
		//Kolaris ++ Deflection
		if( !damageData.IsDoTDamage() && damageData.processedDmg.vitalityDamage > 0.f && (HasAbility('Glyphword 35 _Stats', true) || HasAbility('Glyphword 36 _Stats', true)) && !HasBuff(EET_GlyphwordDeflectionCooldown) )
		{
			deflectionEffect.effectType = EET_GlyphwordDeflectionCooldown;
			//theGame.GetGuiManager().ShowNotification(damageData.GetOriginalDamageDealt() * 0.01f * damageData.GetDamageDealt() / damageData.GetOriginalDamageDealtWithArmor());
			if( HasAbility('Glyphword 36 _Stats', true) )
				deflectionEffect.duration = damageData.GetOriginalDamageDealt() * 0.005f * damageData.GetDamageDealt() / damageData.GetOriginalDamageDealtWithArmor();
			else
				deflectionEffect.duration = damageData.GetOriginalDamageDealt() * 0.01f * damageData.GetDamageDealt() / damageData.GetOriginalDamageDealtWithArmor();
			AddEffectCustom(deflectionEffect);
			
			PlayEffect('glyphword_reflection');
			damageData.SetWasDodged();
			damageData.ClearEffects();
			damageData.SetProcessBuffsIfNoDamage(false);
			damageData.SetAllProcessedDamageAs(0);
			damageData.SetHitAnimationPlayType(EAHA_ForceNo);
			damageData.SetSuppressHitSounds(true);
			damageData.SetCanPlayHitParticle(false);
			return;
		}
		//Kolaris -- Deflection
		
		//Kolaris ++ Griffin Set Bonus
		/*if( HasBuff( EET_GryphonSetBonusYrden ) )
		{
			min = GetAttributeValue( 'gryphon_set_bns_dmg_reduction' );
			damageData.processedDmg.vitalityDamage *= 1 - min.valueAdditive;
		}*/
		//Kolaris -- Griffin Set Bonus
		
		//Kolaris ++ Mutation Rework
		/*if( IsMutationActive(EPMT_Mutation5) && !damageData.IsDoTDamage() )
		{
			if( HasBuff(EET_Mutation5) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation5', 'mut5_dmg_red_perc', min, max);
				damageData.processedDmg.vitalityDamage *= 1 - min.valueAdditive;
				
				theGame.MutationHUDFeedback(MFT_PlayOnce);
				PlayEffect('mutation_5_stage_03');
			}
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation5Effect', 'duration', min, max);
			AddEffectDefault(EET_Mutation5, this, "", false);
			AddTimer('Mutation5Disable', min.valueAdditive, false);
		}*/
		//Kolaris -- Mutation Rework
		
		if(!damageData.GetIgnoreImmortalityMode())
		{
			if(!((W3PlayerWitcher)this))
				Log("");
			
			
			if( IsInvulnerable() )
			{
				if ( theGame.CanLog() )
				{
					LogDMHits("CActor.ReduceDamage: victim Invulnerable - no damage will be dealt", damageData );
				}
				damageData.SetAllProcessedDamageAs(0);
				return;
			}
			
			
			if(actorAttacker && damageData.DealsAnyDamage() )
				actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', damageData );
			
			
			if( IsImmortal() )
			{
				if ( theGame.CanLog() )
				{
					LogDMHits("CActor.ReduceDamage: victim is Immortal, clamping damage", damageData );
				}
				damageData.processedDmg.vitalityDamage = ClampF(damageData.processedDmg.vitalityDamage, 0, GetStat(BCS_Vitality)-1 );
				damageData.processedDmg.essenceDamage  = ClampF(damageData.processedDmg.essenceDamage, 0, GetStat(BCS_Essence)-1 );
				return;
			}
		}
		else
		{
			
			if(actorAttacker && damageData.DealsAnyDamage() )
				actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', damageData );
		}
	}
	
	timer function UndyingSkillCooldown(dt : float, id : int)
	{
		cannotUseUndyingSkill = false;
	}
	
	event OnTakeDamage( action : W3DamageAction)
	{
		var currVitality, rgnVitality, hpTriggerTreshold : float;
		var healingFactor : float;
		var abilityName : name;
		var abilityCount, maxStack, itemDurability : float;
		var addAbility : bool;
		var min, max : SAbilityAttributeValue;
		var mutagenQuen : W3SignEntity;
		var equipped : array<SItemUniqueId>;
		var i : int;
		var killSourceName : string;
		var aerondight	: W3Effect_Aerondight;
		
		
		//Kolaris - Immolation
		if(action.processedDmg.vitalityDamage >= GetStatMax(BCS_Vitality) * 0.2f && (HasAbility('Glyphword 8 _Stats', true) || HasAbility('Glyphword 9 _Stats', true)))
		{
			theGame.GameplayFactsSet( "ImmolationCast", 1);
			CastDesiredSign( ST_Igni, true, false, false, GetWorldPosition(), GetWorldRotation() );
			theGame.GameplayFactsSet( "ImmolationCast", 0);
		}
		
		// W3EE - Begin
		if( action.GetHitReactionType() != EHRT_None && action.GetHitAnimationPlayType() != EAHA_ForceNo && !action.IsDoTDamage() )
		{
			ResetCustomAnimationSpeedMult();
			Combat().RemovePlayerSpeedMult();
		}
		
		//Kolaris - Mutation 7
		if( IsMutationActive(EPMT_Mutation7) && !action.IsDoTDamage() )
			Combat().ManageMutation7(action.attacker, action.victim, action.processedDmg.vitalityDamage);
		
		//Kolaris - Mutation 4
		if( IsMutationActive(EPMT_Mutation4) && !action.IsDoTDamage() )
			Combat().Mutation4DrainStamina(action.processedDmg.vitalityDamage);
		
		GetAnimatedState().OnTakeDamage(action);
		((W3Effect_WolfSetParry)GetBuff(EET_WolfSetParry, "BearSetBonus2")).OnTakeDamage(action);
		// W3EE - End
		
		currVitality = GetStat(BCS_Vitality);
		
		if(action.processedDmg.vitalityDamage >= currVitality)
		{
			killSourceName = action.GetBuffSourceName();
			
			//Kolaris - Gaunter Mode, Kolaris - Mutation Rework
			if( killSourceName != "Quest" && killSourceName != "Kill Trigger" && killSourceName != "Trap" && killSourceName != "FallingDamage" && !IsInFistFight() )
			{			
				
				/*if(!cannotUseUndyingSkill && CanUseSkill(S_Sword_s18) )
				{
					// W3EE - Begin
					healingFactor = GetStatMax(BCS_Vitality) / 30.f;
					healingFactor *= GetStat(BCS_Focus) * GetSkillLevel(S_Sword_s18);
					healingFactor += GetSkillLevel(S_Sword_s18) * GetStatMax(BCS_Vitality) / 20.f;
					GainStat(BCS_Vitality, MinF(healingFactor, GetStatMax(BCS_Vitality)) + action.processedDmg.vitalityDamage);
					DrainFocus(GetStat(BCS_Focus),,true);
					RemoveBuff(EET_BattleTrance);
					cannotUseUndyingSkill = true;
					AddTimer('UndyingSkillCooldown', 300 - (GetSkillLevel(S_Sword_s18) - 1) * 30, false, , , true);
					// W3EE - End
				}
				else
				if( IsMutationActive( EPMT_Mutation11 ) && !( HasBuff( EET_Mutation11Debuff ) && GetBuff( EET_Mutation11Debuff, "Mutation 11 Debuff" ) ) && !IsInAir() )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation11', 'health_prc', min, max );

					action.SetAllProcessedDamageAs( 0 );
					
					OnMutation11Triggered();					
				}
				//Kolaris - Cursed Decoction
				else*/ if( HasBuff(EET_Decoction4) && GetDayPart(GameTimeCreate()) == EDP_Midnight && (GetCurMoonState() == EMS_Full || GetCurMoonState() == EMS_Red))
				{
					GainStat(BCS_Vitality, GetStatMax(BCS_Vitality) * 0.5f + action.processedDmg.vitalityDamage - GetStat(BCS_Vitality));
					RemoveBuff(EET_Decoction4);
					PlayEffect('runeword_20_adrenaline');
				}
				//Kolaris - Constitution
				else if( GetStat(BCS_Focus) >= 1 && HasAbility('Glyphword 45 _Stats', true))
				{
					GainStat(BCS_Vitality, action.processedDmg.vitalityDamage - GetStat(BCS_Vitality) + 500);
					DrainFocus(1);
					PlayEffect('mutation_10_energy');
				}
				//Kolaris - Protection
				else if( HasAbility('Glyphword 33 _Stats', true) && Equipment().GlyphwordProtectionCheck(action.processedDmg.vitalityDamage))
				{
					action.SetAllProcessedDamageAs( 0 );
				}
				//Kolaris - Gaunter Mode
				else if( GaunterMode().ConfigEnabled() && GaunterMode().CanActivate() )
				{
					action.SetAllProcessedDamageAs( 0 );
					OnMutation11Triggered(true);
					if( GaunterMode().ConfigDeathMod() > 0 && GetBuff( EET_Mutation11Debuff, "GM Debuff" ) )
						UpdateDeathCounter(GaunterMode().ConfigDeathMod() + 1);
					else
						UpdateDeathCounter();
					GaunterMode().ProcessSkillDrain();
					GaunterMode().ProcessEquipmentDamage();
				}
				else
				{
					
					equipped = GetEquippedItems();
					
					for(i=0; i<equipped.Size(); i+=1)
					{
						if ( !inv.IsIdValid( equipped[i] ) )
						{
							continue;
						}
						itemDurability = inv.GetItemDurability(equipped[i]);
						if(inv.ItemHasAbility(equipped[i], 'MA_Reinforced') && itemDurability > 0)
						{
							
							inv.SetItemDurabilityScript(equipped[i], MaxF(0, itemDurability - action.processedDmg.vitalityDamage) );
							
							
							action.processedDmg.vitalityDamage = 0;
							ForceSetStat(BCS_Vitality, 1);
							
							break;
						}
					}
				}
			}
		}
		
		if(HasBuff(EET_Trap) && !action.IsDoTDamage() && action.attacker.HasAbility( 'mon_dettlaff_monster_base' ))
		{
			action.AddEffectInfo(EET_Knockdown);
			RemoveBuff(EET_Trap, true);
		}		
		
		super.OnTakeDamage(action);
		
		//Kolaris - Regeneration
		if( HasBuff(EET_AutoVitalityRegen) && !action.IsDoTDamage() && action.processedDmg.vitalityDamage > 0 && HasAbility('Glyphword 39 _Stats', true) )
		{
			((W3Effect_AutoVitalityRegen)GetBuff(EET_AutoVitalityRegen)).SetGlyphword39Value(action.processedDmg.vitalityDamage);
			((W3Effect_AutoVitalityRegen)GetBuff(EET_AutoVitalityRegen)).ResetGlyphword39Duration();
		}
		
		//Kolaris - Perfection
		if( !action.IsDoTDamage() && action.processedDmg.vitalityDamage > 0 && HasBuff(EET_GlyphwordPerfection) )
			((W3Effect_GlyphwordPerfection)GetBuff(EET_GlyphwordPerfection)).OnTakeDamage(action);
		
		if( !action.WasDodged() && action.DealtDamage() && inv.ItemHasTag( inv.GetCurrentlyHeldSword(), 'Aerondight' ) && !action.IsDoTDamage() && !( (W3Effect_Toxicity) action.causer ) )
		{
			aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
			if( aerondight && aerondight.GetCurrentCount() != 0 )
			{
				aerondight.ReduceAerondightStacks();
			}
		}
		
		//Kolaris ++ Mutation Rework
		/*if( !action.WasDodged() && action.DealtDamage() && !action.IsDoTDamage() )
		{
			RemoveBuff( EET_Mutation3 );
		}*/ //Kolaris -- Mutation Rework
		
		// W3EE - Begin
		if( action.attacker.HasTag('Vesemir') )
			ForceSetStat(BCS_Vitality, GetStatMax(BCS_Vitality));
		// W3EE - End
	}
	
	//Kolaris - Gaunter Mode
	public function UpdateDeathCounter(optional amount : int)
	{
		if( amount )
			DeathCounter = Max(0, DeathCounter + amount);
		else
			DeathCounter += 1;
		GaunterMode().UpdateDeathEffects();
		GaunterMode().UpdateDemonMark();
	}
	
	public function ResetDeathCounter()
	{
		DeathCounter = 0;
		GaunterMode().UpdateDeathEffects();
		GaunterMode().UpdateDemonMark();
	}
	
	public function GetDeathCounter() : int
	{
		if( GaunterMode().ConfigEnabled() )
			return DeathCounter;
		else
			return 0;
	}
	
	// W3EE - Begin
	private var equippedHood : SItemUniqueId;
	private var hoodSlot : EEquipmentSlots;
	private function UnequipHoodFistfight()
	{
		if( inv.GetItemEquippedOnSlot(EES_Quickslot1, equippedHood) && inv.ItemHasTag(equippedHood, 'Hood') )
		{
			UnequipItem(equippedHood);
			hoodSlot = EES_Quickslot1;
		}
		if( inv.GetItemEquippedOnSlot(EES_Quickslot2, equippedHood) && inv.ItemHasTag(equippedHood, 'Hood') )
		{
			UnequipItem(equippedHood);
			hoodSlot = EES_Quickslot1;
		}
	}
	
	private function EquipHoodFistfight()
	{
		EquipItem(equippedHood, hoodSlot, false);
	}
	
	event OnStartFistfightMinigame()
	{
		var i : int;
		var buffs : array< CBaseGameplayEffect >;
		
		/*
		effectManager.RemoveAllPotionEffects();
		
		abilityManager.DrainToxicity(GetStatMax( BCS_Toxicity ));
		
		buffs = GetBuffs( EET_WellFed );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			RemoveEffect( buffs[i] );
		}
		
		
		buffs.Clear();
		buffs = GetBuffs( EET_WellHydrated );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			RemoveEffect( buffs[i] );
		}
		*/
		
		UnequipHoodFistfight();
		
		super.OnStartFistfightMinigame();
	}
	
	event OnEndFistfightMinigame()
	{
		EquipHoodFistfight();
		super.OnEndFistfightMinigame();
	}
	// W3EE - End
	
	
	public function GetCriticalHitChance( isLightAttack : bool, isHeavyAttack : bool, target : CActor, victimMonsterCategory : EMonsterCategory, isBolt : bool ) : float
	{
		var ret : float;
		// var thunder : W3Potion_Thunderbolt;
		var min, max : SAbilityAttributeValue;
		
		ret = super.GetCriticalHitChance( isLightAttack, isHeavyAttack, target, victimMonsterCategory, isBolt );
		
		
		
		
		
		
		
		// W3EE - Begin
		/*
		thunder = ( W3Potion_Thunderbolt )GetBuff( EET_Thunderbolt );
		if( thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm )
		{
			ret += 0.25f;
		}
		*/
		// W3EE - End
		
		//Kolaris ++ Mutation Rework
		/*if( isBolt && IsMutationActive( EPMT_Mutation9 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'critical_hit_chance', min, max);
			ret += min.valueMultiplicative;
		}*/
		//Kolaris -- Mutation Rework
		
		if( isBolt && CanUseSkill( S_Sword_s07 ) )
		{
			ret += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s07);
		}
			
		return ret;
	}
	
	
	public function GetCriticalHitDamageBonus(weaponId : SItemUniqueId, victimMonsterCategory : EMonsterCategory, isStrikeAtBack : bool) : SAbilityAttributeValue
	{
		// W3EE - Begin
		var min, max, bonus, null, oilBonus : SAbilityAttributeValue;
		var monsterBonusType : name;
		var aerondightBuff : W3Effect_Aerondight;
		
		bonus = super.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, isStrikeAtBack);
		
		/*
		if( inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) && GetStat( BCS_Focus ) >= Options().MaxFocus() && CanUseSkill( S_Alchemy_s07 ) )
		{
			monsterBonusType = MonsterCategoryToAttackPowerBonus( victimMonsterCategory );
			oilBonus = inv.GetItemAttributeValue( weaponId, monsterBonusType );
			if(oilBonus != null)	
			{
				bonus += GetSkillAttributeValue(S_Alchemy_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * GetSkillLevel(S_Alchemy_s07);
			}
		}
		*/
		
		aerondightBuff = (W3Effect_Aerondight)GetBuff(EET_Aerondight);
		if( aerondightBuff )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('AerondightEffect', 'crit_dam_bonus_stack', min, max);
			bonus += min * aerondightBuff.GetCurrentCount();
		}
		// W3EE - End
		
		return bonus;		
	}
	
	public function ProcessLockTarget( optional newLockTarget : CActor, optional checkLeftStickHeading : bool ) : bool
	{
		var newLockTargetFound	: bool;
	
		newLockTargetFound = super.ProcessLockTarget(newLockTarget, checkLeftStickHeading);
		
		if(GetCurrentlyCastSign() == ST_Axii)
		{
			((W3AxiiEntity)GetCurrentSignEntity()).OnDisplayTargetChange(newLockTarget);
		}
		
		return newLockTargetFound;
	}
	
	
	
	
	
	event OnProcessActionPost(action : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		var rendLoad : float;
		var value : SAbilityAttributeValue;
		var actorVictim : CActor;
		var weaponId : SItemUniqueId;
		var usesSteel, usesSilver, usesVitality, usesEssence : bool;
		var abs : array<name>;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		//Kolaris - Cat Set
		var lynxSetBuff : W3Effect_SwordDancing;
		
		super.OnProcessActionPost(action);
		
		attackAction = (W3Action_Attack)action;
		actorVictim = (CActor)action.victim;
		
		if(attackAction)
		{
			if(attackAction.IsActionMelee())
			{
				
				if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
				{
					// W3EE - Begin
					/*rendLoad = GetSpecialAttackTimeRatio();
					
					
					rendLoad = MinF(rendLoad * GetStatMax(BCS_Focus), GetStat(BCS_Focus));
					
					
					rendLoad = FloorF(rendLoad);					
					DrainFocus(rendLoad);*/
					// W3EE - End
					
					OnSpecialAttackHeavyActionProcess();
				}
				else if(actorVictim && IsRequiredAttitudeBetween(this, actorVictim, true))
				{
					
					
					value = GetAttributeValue('focus_gain');
					
					if( FactsQuerySum("debug_fact_focus_boy") > 0 )
					{
						Debug_FocusBoyFocusGain();
					}
					
					
					/*if ( CanUseSkill(S_Sword_s20) )
					{
						value += GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s20);
					}*/
					
					//Kolaris ++ Mutation Rework
					/*if( IsMutationActive( EPMT_Mutation3 ) && IsRequiredAttitudeBetween( this, action.victim, true ) && !action.victim.HasTag( 'Mutation3InvalidTarget' ) && !attackAction.IsParried() && !attackAction.WasDodged() && !attackAction.IsCountered() && !inv.IsItemFists( attackAction.GetWeaponId() ) && !attackAction.WasDamageReturnedToAttacker() && attackAction.DealtDamage() )
					{
						AddEffectDefault( EET_Mutation3, this, "", false );
					}*/
					//Kolaris -- Mutation Rework
					// W3EE - Begin
					// GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(value)) );
					// W3EE - End
				}
				
				
				weaponId = attackAction.GetWeaponId();
				if(actorVictim && (ShouldProcessTutorial('TutorialWrongSwordSteel') || ShouldProcessTutorial('TutorialWrongSwordSilver')) && GetAttitudeBetween(actorVictim, this) == AIA_Hostile)
				{
					usesSteel = inv.IsItemSteelSwordUsableByPlayer(weaponId);
					usesSilver = inv.IsItemSilverSwordUsableByPlayer(weaponId);
					usesVitality = actorVictim.UsesVitality();
					usesEssence = actorVictim.UsesEssence();
					
					if(usesSilver && usesVitality)
					{
						FactsAdd('tut_wrong_sword_silver',1);
					}
					else if(usesSteel && usesEssence)
					{
						FactsAdd('tut_wrong_sword_steel',1);
					}
					else if(FactsQuerySum('tut_wrong_sword_steel') && usesSilver && usesEssence)
					{
						FactsAdd('tut_proper_sword_silver',1);
						FactsRemove('tut_wrong_sword_steel');
					}
					else if(FactsQuerySum('tut_wrong_sword_silver') && usesSteel && usesVitality)
					{
						FactsAdd('tut_proper_sword_steel',1);
						FactsRemove('tut_wrong_sword_silver');
					}
				}
				
				// W3EE - Begin
				/*
				if(!action.WasDodged() && HasAbility('Runeword 1 _Stats', true))
				{
					if(runewordInfusionType == ST_Axii)
					{
						actorVictim.SoundEvent('sign_axii_release');
					}
					else if(runewordInfusionType == ST_Igni)
					{
						actorVictim.SoundEvent('sign_igni_charge_begin');
					}
					else if(runewordInfusionType == ST_Quen)
					{
						value = GetAttributeValue('runeword1_quen_heal');
						Heal( action.GetDamageDealt() * value.valueMultiplicative );
						PlayEffectSingle('drain_energy_caretaker_shovel');
					}
					else if(runewordInfusionType == ST_Yrden)
					{
						actorVictim.SoundEvent('sign_yrden_shock_activate');
					}
					runewordInfusionType = ST_None;
					
					
					items = inv.GetHeldWeapons();
					weaponEnt = inv.GetItemEntityUnsafe(items[0]);
					weaponEnt.StopEffect('runeword_aard');
					weaponEnt.StopEffect('runeword_axii');
					weaponEnt.StopEffect('runeword_igni');
					weaponEnt.StopEffect('runeword_quen');
					weaponEnt.StopEffect('runeword_yrden');
				}
				*/
				// W3EE - End
				
				if(ShouldProcessTutorial('TutorialLightAttacks') || ShouldProcessTutorial('TutorialHeavyAttacks'))
				{
					if(IsLightAttack(attackAction.GetAttackName()))
					{
						theGame.GetTutorialSystem().IncreaseGeraltsLightAttacksCount(action.victim.GetTags());
					}
					else if(IsHeavyAttack(attackAction.GetAttackName()))
					{
						theGame.GetTutorialSystem().IncreaseGeraltsHeavyAttacksCount(action.victim.GetTags());
					}
				}
			}
			// W3EE - Begin
			/*
			else if(action.IsActionRanged())
			{
				if(CanUseSkill(S_Sword_s15))
				{				
					value = GetSkillAttributeValue(S_Sword_s15, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s15) ;
					GainStat(BCS_Focus, CalculateAttributeValue(value) );
				}
				
				if(CanUseSkill(S_Sword_s12) && action.IsCriticalHit() && actorVictim && !actorVictim.HasAbility('mon_dettlaff_monster_base'))
				{
					
					actorVictim.GetCharacterStats().GetAbilities(abs, false);
					dm = theGame.GetDefinitionsManager();
					for(i=abs.Size()-1; i>=0; i-=1)
					{
						if(!dm.AbilityHasTag(abs[i], theGame.params.TAG_MONSTER_SKILL) || actorVictim.IsAbilityBlocked(abs[i]))
						{
							abs.EraseFast(i);
						}
					}
					
					
					if(abs.Size() > 0)
					{
						value = GetSkillAttributeValue(S_Sword_s12, 'duration', true, true) * GetSkillLevel(S_Sword_s12);
						actorVictim.BlockAbility(abs[ RandRange(abs.Size()) ], true, CalculateAttributeValue(value));
					}
				}
			}
			*/
			// W3EE - End
		}
		//Kolaris ++ Mutation 10
		/*if( IsMutationActive( EPMT_Mutation10 ) && actorVictim && ( action.IsActionMelee() || action.IsActionWitcherSign() ) && !IsCurrentSignChanneled() )
		{
			PlayEffectSingle( 'mutation_10_energy' );
		}*/
		//Kolaris -- Mutation 10
		// W3EE - Begin
		/*if(CanUseSkill(S_Perk_18) && ((W3Petard)action.causer) && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			value = GetSkillAttributeValue(S_Perk_18, 'focus_gain', false, true);
			GainStat(BCS_Focus, CalculateAttributeValue(value));
		}*/
		
		//Kolaris - Cat Set
		if( attackAction && attackAction.IsActionMelee() && !IsUsingHorse() && attackAction.DealtDamage() /*&& IsSetBonusActive( EISB_Lynx_1 )*/ && !attackAction.IsCountered() && ( inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) && inv.ItemHasTag(inv.GetCurrentlyHeldSword(), 'SwordDancingEffect') )
		{
			lynxSetBuff = (W3Effect_SwordDancing)GetBuff(EET_SwordDancing);
			if( IsHeavyAttack(attackAction.GetAttackName()) )
			{
				if( lynxSetBuff && lynxSetBuff.GetSourceName() == "LightAttack" )
				{
					RemoveEffect(lynxSetBuff);
				}
				AddEffectDefault(EET_SwordDancing, NULL, "HeavyAttack");
			}
			else
			{
				if( lynxSetBuff && lynxSetBuff.GetSourceName() == "HeavyAttack" )
				{
					RemoveEffect(lynxSetBuff);
				}
				AddEffectDefault(EET_SwordDancing, NULL, "LightAttack");
			}
			SoundEvent("ep2_setskill_lynx_activate");
		}
		// W3EE - End
	}
	
	public final function FailFundamentalsFirstAchievementCondition()
	{
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
		
	public final function SetUsedQuenInCombat()
	{
		usedQuenInCombat = true;
	}
	
	public final function UsedQuenInCombat() : bool
	{
		return usedQuenInCombat;
	}
	
	// W3EE - Begin
	private var adrenalineEffect : W3Effect_CombatAdrenaline;
	public function GetAdrenalineEffect() : W3Effect_CombatAdrenaline
	{
		return adrenalineEffect;
	}
	
	public function GetAdrenalinePercMult() : float
	{
		//Kolaris - Wolf Set
		return MaxF(0.f, (1.f - adrenalineEffect.GetValue()));
	}
	
	private var isWounded : bool;	default isWounded = false;
	public function UpdateWoundedState( optional forceNo : bool )
	{
		isWounded = false;
		if( GetStatPercents(BCS_Vitality) <= 0.3f )
			isWounded = true;
			
		if( GetInjuryManager().GetInjuryCount() >= 2 )
			isWounded = true;
			
		//Kolaris - Hunter Instinct
		if( ((W3Effect_ToxicityFever)GetBuff(EET_ToxicityFever)).IsFeverActive() /*&& !(CanUseSkill(S_Alchemy_s13) && HasDecoctionEffect())*/ )
			isWounded = true;
			
		if( IsInCombat() )
			isWounded = false;
			
		if( forceNo )
			isWounded = false;
			
		if( GetBehaviorVariable('alternateWalk') != 2 )
		{
			if( isWounded )
			{
				BlockAction(EIAB_RunAndSprint, 'woundedState', true);
				SetBehaviorVariable('alternateWalk', 1);
				theGame.GetTutorialSystem().uiHandler.GotoState('InjuredState');
			}
			else
			{
				UnblockAction(EIAB_RunAndSprint, 'woundedState');
				SetBehaviorVariable('alternateWalk', 0);
			}
		}
	}
	
	public function IsWounded() : bool
	{
		return isWounded;
	}
	
	public var enemiesKilled : int;
	public var startingHealthPerc : float;
	event OnCombatStart()
	{
		var quenEntity, glyphQuen : W3QuenEntity;
		var focus, stamina : float;
		var glowTargets, moTargets, actors : array< CActor >;
		var delays : array< float >;
		var rand, i : int;
		var isHostile, isAlive, isUnconscious : bool;
		
		super.OnCombatStart();
		
		if ( IsInCombatActionFriendly() )
		{
			SetBIsCombatActionAllowed(true);
			SetBIsInputAllowed(true, 'OnCombatActionStart' );
		}
		
		UpdateWoundedState();
		enemiesKilled = 0;
		startingHealthPerc = GetStatPercents(BCS_Vitality);
		if( !Options().CombatInv() )
			BlockAction(EIAB_OpenInventory, 'CombatInventoryBlock');
		
		//Kolaris - Bear Set
		/*if( IsSetBonusActive(EISB_Bear_2) && !HasBuff(EET_WolfSetParry) )
			AddEffectDefault(EET_WolfSetParry, this, "BearSetBonus2", false);*/
			
		if( IsSetBonusActive(EISB_Dimeritium1) && !HasBuff(EET_DimeritiumCharge) )
			AddEffectDefault(EET_DimeritiumCharge, this, "DimeritiumSetBonus", false);
			
		if( !HasBuff(EET_CombatAdr) )
			AddEffectDefault(EET_CombatAdr, this, "CombatAdrenaline", false);
		adrenalineEffect = (W3Effect_CombatAdrenaline)GetBuff(EET_CombatAdr);
		//Kolaris - Adrenaline Burst
		if( CanUseSkill(S_Perk_10) )
			GetAdrenalineEffect().AddAdrenaline(50.f);
		//Kolaris - Perfection
		if( HasAbility('Glyphword 42 _Stats', true) && !HasBuff(EET_GlyphwordPerfection) )
			AddEffectDefault(EET_GlyphwordPerfection, this, "Glyphword42", false);
		
		mutation12IsOnCooldown = false;
		
		
		quenEntity = (W3QuenEntity)signs[ST_Quen].entity;		
		
		
		if(quenEntity)
		{
			usedQuenInCombat = quenEntity.IsAnyQuenActive();
		}
		else
		{
			usedQuenInCombat = false;
		}
		
		if(usedQuenInCombat || HasPotionBuff() || IsEquippedSwordUpgradedWithOil(true) || IsEquippedSwordUpgradedWithOil(false))
		{
			SetFailedFundamentalsFirstAchievementCondition(true);
		}
		else
		{
			if(IsAnyItemEquippedOnSlot(EES_PotionMutagen1) || IsAnyItemEquippedOnSlot(EES_PotionMutagen2) || IsAnyItemEquippedOnSlot(EES_PotionMutagen3) || IsAnyItemEquippedOnSlot(EES_PotionMutagen4))
				SetFailedFundamentalsFirstAchievementCondition(true);
			else
				SetFailedFundamentalsFirstAchievementCondition(false);
		}
		
		//Kolaris - Remove Old Enchantments
		/*if ( HasAbility('Glyphword 17 _Stats', true) && RandF() < CalculateAttributeValue(GetAttributeValue('quen_apply_chance')) )
		{
			glyphQuen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			glyphQuen.Init( signOwner, signs[ST_Quen].entity, true, false, true );
			glyphQuen.OnStarted();
			glyphQuen.OnThrowing();
			glyphQuen.OnEnded();
		}*/
		
		MeditationForceAbort(true);
		
		//Kolaris - Wolf Set
		/*if( IsSetBonusActive(EISB_Wolf_1) )
		{
			RemoveTimer( 'Mutation7CombatStartHackFixGo' );
			AddTimer( 'Mutation7CombatStartHackFix', 1.f, true, , , , true );
		}*/
		//Kolaris ++ Mutation Rework
		/*if( IsMutationActive( EPMT_Mutation4 ) )
		{
			AddEffectDefault( EET_Mutation4, this, "combat start", false );
		}
		else if( IsMutationActive( EPMT_Mutation8 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayRepeat );
		}
		else if( IsMutationActive( EPMT_Mutation10 ) )
		{
			if( !HasBuff( EET_Mutation10 ) && GetStat( BCS_Toxicity ) > 0.f )
			{
				AddEffectDefault( EET_Mutation10, this, "Mutation 10" );
			}
			
			PlayEffect( 'mutation_10' );
			PlayEffect( 'critical_toxicity' );
			AddTimer( 'Mutation10StopEffect', 5.f );
		}*/
		//Kolaris -- Mutation Rework
	}
	// W3EE - End
	
	timer function Mutation7CombatStartHackFix( dt : float, id : int )
	{
		var actors : array< CActor >;
		
		actors = GetEnemies();
		
		if( actors.Size() > 0 )
		{
			
			AddTimer( 'Mutation7CombatStartHackFixGo', 0.5f );
			RemoveTimer( 'Mutation7CombatStartHackFix' );
		}
	}
	
	timer function Mutation7CombatStartHackFixGo( dt : float, id : int )
	{
		var actors : array< CActor >;
		
		if( IsSetBonusActive(EISB_Wolf_1) )
		{
			actors = GetEnemies();
			
			if( actors.Size() > 1 )
			{		
				AddEffectDefault( EET_Mutation7Buff, this, "Mutation 7, combat start" );			
			}
		}
	}
	
	public final function IsInFistFight() : bool
	{
		var enemies : array< CActor >;
		var i, j : int;
		var invent : CInventoryComponent;
		var weapons : array< SItemUniqueId >;
		
		if( IsInFistFightMiniGame() )
		{
			return true;
		}
		
		enemies = GetEnemies();
		for( i=0; i<enemies.Size(); i+=1 )
		{
			weapons.Clear();
			invent = enemies[i].GetInventory();
			weapons = invent.GetHeldWeapons();
			
			for( j=0; j<weapons.Size(); j+=1 )
			{
				if( invent.IsItemFists( weapons[j] ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	timer function Mutation10StopEffect( dt : float, id : int )
	{
		StopEffect( 'critical_toxicity' );
	}
	
	// W3EE - Begin
	timer function ResetAdrenalineCombat( dt : float, id : int )
	{
		if( !IsInCombat() )
		{
			RemoveBuff(EET_CombatAdr, true, "CombatAdrenaline");
			((W3Effect_DimeritiumCharge)GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).SetDimeritiumCharge(0);
			RemoveBuff(EET_DimeritiumCharge);
			RemoveBuff(EET_WolfSetParry);
		}
	}
	// W3EE - End
	
	event OnCombatFinished()
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var disableAutoSheathe : bool;
		
		super.OnCombatFinished();
		
		Experience().AwardCombatAdrenalineXP(this, enemiesKilled, startingHealthPerc == GetStatPercents(BCS_Vitality));
		UnblockAction(EIAB_OpenInventory, 'CombatInventoryBlock');
		AddTimer('ResetAdrenalineCombat', 8.f, false,,,,true);
		adrenalineEffect = NULL;
		enemiesKilled = 0;
		
		if( HasBuff(EET_Decoction9) )
			((W3Decoction9_Effect)GetBuff(EET_Decoction9)).ClearBoost();
		// W3EE - End
		
		
		RemoveBuff( EET_Mutation3 );
		
		
		RemoveBuff( EET_Mutation4 );
		
		
		RemoveBuff( EET_Mutation5 );
		
		
		RemoveBuff( EET_Mutation7Buff );
		RemoveBuff( EET_Mutation7Debuff );
		//Kolaris ++ Mutation Rework
		/*if( IsMutationActive( EPMT_Mutation8 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}*/
		//Kolaris -- Mutation Rework
		//Kolaris - Cat Set
		RemoveBuff( EET_SwordDancing );
		
		// W3EE - Begin
		
		UpdateWoundedState();
		// RemoveBuff( EET_Mutation10 );
		
		/*if(GetStat(BCS_Focus) > 0)
		{
			AddTimer('DelayedAdrenalineDrain', theGame.params.ADRENALINE_DRAIN_AFTER_COMBAT_DELAY, , , , true);
		}*/
		// W3EE - End
		
		thePlayer.abilityManager.ResetOverhealBonus();
		
		usedQuenInCombat = false;		
		
		theGame.GetGamerProfile().ResetStat(ES_FinesseKills);
		
		LogChannel( 'OnCombatFinished', "OnCombatFinished: DelayedSheathSword timer added" ); 
		
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Gameplay', 'DisableAutomaticSwordSheathe' );			
		if( !disableAutoSheathe )
		{
			if ( ShouldAutoSheathSwordInstantly() )
				AddTimer( 'DelayedSheathSword', 0.5f );
			else
				AddTimer( 'DelayedSheathSword', 2.f );
		}
		
		OnBlockAllCombatTickets( false ); 
		
		
		runewordInfusionType = ST_None;
		
		
		
		
		
	}
	
	public function PlayHitEffect( damageAction : W3DamageAction )
	{
		var hitReactionType		: EHitReactionType;
		var isAtBack			: bool;
		
		
		if( damageAction.GetMutation4Triggered() )
		{
			hitReactionType = damageAction.GetHitReactionType();
			isAtBack = IsAttackerAtBack( damageAction.attacker );
			
			if( hitReactionType != EHRT_Heavy )
			{
				if( isAtBack )
				{
					damageAction.SetHitEffect( 'light_hit_back_toxic', true );					
				}
				else
				{
					damageAction.SetHitEffect( 'light_hit_toxic' );
				}
			}
			else
			{
				if( isAtBack )
				{
					damageAction.SetHitEffect( 'heavy_hit_back_toxic' ,true );
				}
				else
				{
					damageAction.SetHitEffect( 'heavy_hit_toxic' );
				}
			}
		}
		
		super.PlayHitEffect( damageAction );
	}
	
	
	// W3EE - Begin
	public function StartRegenTimer( regenDelay : float )
	{
		((W3Effect_AdrenalineDrain)GetBuff(EET_AdrenalineDrain)).StopRegen();
		//Kolaris ++ Mutation Rework
		/*if( IsMutationActive(EPMT_Mutation1) )
			ResumeVigorRegen(0, 0);
		else*/ //Kolaris -- Mutation Rework
			AddTimer('ResumeVigorRegen', regenDelay, false,,,,true);
	}
	
	timer function ResumeVigorRegen( dt : float, id : int )
	{
		if( !HasBuff(EET_AdrenalineDrain) )
			AddEffectDefault(EET_AdrenalineDrain, this, "VigorRegen");
		((W3Effect_AdrenalineDrain)GetBuff(EET_AdrenalineDrain)).ResumeRegen();
	}
	
	public function StartCustomVigorTimer( time : float )
	{
		((W3Effect_AdrenalineDrain)GetBuff(EET_AdrenalineDrain)).StopRegen();
		((W3Effect_AdrenalineDrain)GetBuff(EET_AdrenalineDrain)).SetCustomTimerActive(true);
		AddTimer('CustomVigorTimerEnd', time, false,,,,true);
	}
	
	timer function CustomVigorTimerEnd( dt : float, id : int )
	{
		((W3Effect_AdrenalineDrain)GetBuff(EET_AdrenalineDrain)).SetCustomTimerActive(false);
		((W3Effect_AdrenalineDrain)GetBuff(EET_AdrenalineDrain)).ResumeRegen();
	}
	
	timer function StunPlayer( dt : float, id : int )
	{
		AddEffectDefault(EET_Knockdown, NULL, "Stun", false);
	}
	// W3EE - End	
	
	protected function Attack( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity)
	{
		// W3EE - Begin
		var isNotCounterAttack, isBuffConsumed : bool;
		
		super.Attack(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity);
		
		isNotCounterAttack = IsLightAttack(animData.attackName) || IsHeavyAttack(animData.attackName);
		
		if( HasBuff(EET_Decoction9) )
		{
			
			if ( IsLightAttack(animData.attackName) )
			{
				if( ((W3Decoction9_Effect)GetBuff(EET_Decoction9)).HasBoost("light") )
					((W3Decoction9_Effect)GetBuff(EET_Decoction9)).ClearBoost();
				
				FactsAdd("decoction_9_attack_light", 1);
			}
			else if( IsHeavyAttack(animData.attackName) )
			{
				if( ((W3Decoction9_Effect)GetBuff(EET_Decoction9)).HasBoost("heavy") )
					((W3Decoction9_Effect)GetBuff(EET_Decoction9)).ClearBoost();
				
				FactsAdd("decoction_9_attack_heavy", 1);
			}	
		}
		// W3EE - End
	}
	
	public final timer function SpecialAttackLightSustainCost(dt : float, id : int)
	{
		var focusPerSec, cost, delay : float;
		var reduction, attackEfficiency, armorEfficiency : SAbilityAttributeValue;
		var skillLevel : int;
		
		if(abilityManager && abilityManager.IsInitialized() && IsAlive())
		{
			PauseStaminaRegen('WhirlSkill');
			
			if(GetStat(BCS_Stamina) > 0)
			{
				//Kolaris - Whirl
				cost = GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
				delay = GetStaminaActionDelay(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
				skillLevel = GetSkillLevel(S_Sword_s01);
				attackEfficiency = GetAttributeValue('attack_stamina_cost_bonus');
				armorEfficiency = GetAttributeValue('armor_stamina_efficiency');
				cost *= (1.f - armorEfficiency.valueMultiplicative * (1.f - 0.2f * GetSkillLevel(S_Perk_22))) * (1.f - attackEfficiency.valueMultiplicative);
				
				if(skillLevel >= 1)
				{
					reduction = GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, true) * skillLevel;
					cost = MaxF(0, cost * (1 - reduction.valueMultiplicative) - reduction.valueAdditive);
				}
				
				//W3EE - Begin
				DrainStamina(ESAT_FixedValue, cost, delay, GetSkillAbilityName(S_Sword_s01));
				//W3EE - End
			}
			// W3EE - Begin
			/*else				
			{				
				GetSkillAttributeValue(S_Sword_s01, 'focus_cost_per_sec', false, true);
				focusPerSec = GetWhirlFocusCostPerSec();
				DrainFocus(focusPerSec * dt);
			}*/
			// W3EE - End
		}
		
		// W3EE - Begin
		if(GetStat(BCS_Stamina) <= 0 /*&& GetStat(BCS_Focus) <= 0*/)
		// W3EE - End
		{
			OnPerformSpecialAttack(true, false);
		}
	}
	
	public final function GetWhirlFocusCostPerSec() : float
	{
		var ability : SAbilityAttributeValue;
		var val : float;
		var skillLevel : int;
		
		ability = GetSkillAttributeValue(S_Sword_s01, 'focus_cost_per_sec_initial', false, false);
		skillLevel = GetSkillLevel(S_Sword_s01);
		
		if(skillLevel >= 1)
			ability -= GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, false) * skillLevel;
			
		val = CalculateAttributeValue(ability);
		
		return val;
	}
	
	public final timer function SpecialAttackHeavySustainCost(dt : float, id : int)
	{
		var focusHighlight, ratio : float;
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;		
		
		//W3EE - Begin
		PauseStaminaRegen('RendSkill');
		
		DrainStamina(ESAT_Ability, 0, 0, GetSkillAbilityName(S_Sword_s02), dt, 1.f);
		// W3EE - End
		
		if(GetStat(BCS_Stamina) <= 0)
			OnPerformSpecialAttack(false, false);
			
		
		ratio = EngineTimeToFloat(theGame.GetEngineTime() - specialHeavyStartEngineTime) / specialHeavyChargeDuration;
		
		
		if(ratio > 0.95)
			ratio = 1;
			
		SetSpecialAttackTimeRatio(ratio);
	}
	
	public function OnSpecialAttackHeavyActionProcess()
	{
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;
		
		super.OnSpecialAttackHeavyActionProcess();
		
		// W3EE - Begin
		/*hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.ResetFocusPoints();
			}		
		}*/
		// W3EE - End
	}
	
	timer function IsSpecialLightAttackInputHeld ( time : float, id : int )
	{
		var hasResource : bool;
		
		if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
		{
			if ( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
			{
				// W3EE - Begin
				if(GetStat(BCS_Stamina) > 0)
				{
					hasResource = true;
				}
				/*else
				{
					hasResource = (GetStat(BCS_Focus) >= GetWhirlFocusCostPerSec() * time);					
				}*/
				
				if(hasResource)
				{
					SetupCombatAction( EBAT_SpecialAttack_Light, BS_Pressed );
					RemoveTimer('IsSpecialLightAttackInputHeld');
				}
				else if(!playedSpecialAttackMissingResourceSound)
				{
					
					SetShowToLowStaminaIndication(1.f);
					playedSpecialAttackMissingResourceSound = true;
				}
				// W3EE - End
			}			
		}
		else
		{
			RemoveTimer('IsSpecialLightAttackInputHeld');
		}
	}	
	
	timer function IsSpecialHeavyAttackInputHeld ( time : float, id : int )
	{		
		var cost : float;
		
		// W3EE - Begin
		if( (theInput.LastUsedGamepad() && !theInput.IsActionPressed('AttackHeavy')) || (!theInput.LastUsedGamepad() && (!theInput.IsActionPressed('AttackWithAlternateHeavy')&& !theInput.IsActionPressed('AttackWithAlternateLight') )) )
		{
			CancelHoldAttacks();
			RemoveTimer('IsSpecialHeavyAttackInputHeld');
			return;
		}
		
		if ( (GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver') && !inputHandler.IsRendCanceled() )
		{
			if( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack) )
			{
				cost = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s02, 'stamina_cost_per_sec', false, false));
				
				if(GetStat(BCS_Stamina) >= cost)
				{
					SetupCombatAction( EBAT_SpecialAttack_Heavy, BS_Pressed );
					RemoveTimer('IsSpecialHeavyAttackInputHeld');
				}
				else if(!playedSpecialAttackMissingResourceSound)
				{
					SetShowToLowStaminaIndication(1.f);
					playedSpecialAttackMissingResourceSound = true;
				}
			}
		}
		else
		{
			CancelHoldAttacks();
			RemoveTimer('IsSpecialHeavyAttackInputHeld');
		}
		// W3EE - End
	}
	
	public function EvadePressed( bufferAction : EBufferActionType )
	{
		var cat : float;
		
		if( (bufferAction == EBAT_Dodge && IsActionAllowed(EIAB_Dodge)) || (bufferAction == EBAT_Roll && IsActionAllowed(EIAB_Roll)) )
		{
			
			if(bufferAction != EBAT_Roll && ShouldProcessTutorial('TutorialDodge'))
			{
				FactsAdd("tut_in_dodge", 1, 2);
				
				if(FactsQuerySum("tut_fight_use_slomo") > 0)
				{
					theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
					FactsRemove("tut_fight_slomo_ON");
				}
			}				
			else if(bufferAction == EBAT_Roll && ShouldProcessTutorial('TutorialRoll'))
			{
				FactsAdd("tut_in_roll", 1, 2);
				
				if(FactsQuerySum("tut_fight_use_slomo") > 0)
				{
					theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
					FactsRemove("tut_fight_slomo_ON");
				}
			}
				
			if ( GetBIsInputAllowed() )
			{			
				if ( GetBIsCombatActionAllowed() )
				{
					CriticalEffectAnimationInterrupted("Dodge 2");
					PushCombatActionOnBuffer( bufferAction, BS_Released );
					ProcessCombatActionBuffer();
				}					
				else if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					//Kolaris - Attack Commitment
					if ( (CanPlayHitAnim() || !Options().AttackCommitment() || thePlayer.IsCiri()) && IsThreatened() )
					{
						CriticalEffectAnimationInterrupted("Dodge 1");
						PushCombatActionOnBuffer( bufferAction, BS_Released );
						ProcessCombatActionBuffer();							
					}
					else
						PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
				
				else if ( !( IsCurrentSignChanneled() ) )
				{
					
					PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
			}
			else
			{
				if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					//Kolaris - Attack Commitment
					if ( (CanPlayHitAnim() || !Options().AttackCommitment() || thePlayer.IsCiri()) && IsThreatened() )
					{
						CriticalEffectAnimationInterrupted("Dodge 3");
						PushCombatActionOnBuffer( bufferAction, BS_Released );
						ProcessCombatActionBuffer();							
					}
					else
						PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
				LogChannel( 'InputNotAllowed', "InputNotAllowed" );
			}
		}
		else
		{
			DisplayActionDisallowedHudMessage(EIAB_Dodge);
		}
	}
		
	
	public function ProcessCombatActionBuffer() : bool
	{
		var action	 			: EBufferActionType			= this.BufferCombatAction;
		var stage	 			: EButtonStage 				= this.BufferButtonStage;		
		var throwStage			: EThrowStage;		
		var actionResult 		: bool = true;
		
		
		if( isInFinisher )
		{
			return false;
		}
		
		if ( action != EBAT_SpecialAttack_Heavy )
			specialAttackCamera = false;			
		
		
		if(super.ProcessCombatActionBuffer())
			return true;		
			
		switch ( action )
		{			
			case EBAT_CastSign :
			{
				switch ( stage )
				{
					case BS_Pressed : 
					{




	
	
								actionResult = this.CastSign();
								LogChannel('SignDebug', "CastSign()");
	

					} break;
					
					default : 
					{
						actionResult = false;
					} break;
				}
			} break;
			
			case EBAT_SpecialAttack_Light :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformSpecialAttack( true, true );
					} break;
					
					case BS_Released :
					{						
						actionResult = this.OnPerformSpecialAttack( true, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;

			case EBAT_SpecialAttack_Heavy :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformSpecialAttack( false, true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( false, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			
			default:
				return false;	
		}
		
		
		this.CleanCombatActionBuffer();
		
		if (actionResult)
		{
			SetCombatAction( action ) ;
		}
		
		return true;
	}
		
		
	event OnPerformSpecialAttack( isLightAttack : bool, enableAttack : bool ){}	
	
	public final function GetEnemies() : array< CActor >
	{
		var actors, actors2 : array<CActor>;
		var i : int;
		
		
		actors = GetWitcherPlayer().GetHostileEnemies();
		ArrayOfActorsAppendUnique( actors, GetWitcherPlayer().GetMoveTargets() );
		
		
		thePlayer.GetVisibleEnemies( actors2 );
		ArrayOfActorsAppendUnique( actors, actors2 );
		
		for( i=actors.Size()-1; i>=0; i-=1 )
		{
			if( !IsRequiredAttitudeBetween( actors[i], this, true ) )
			{
				actors.EraseFast( i );
			}
		}
		
		return actors;
	}
	
	//Kolaris - 2H Sword Stance
	public function GetTotalActiveThreat() : int
	{
		var actors : array<CActor>;
		var i, totalThreat : int;
		
		actors = GetEnemies();
		totalThreat = 0;
		for( i=actors.Size()-1; i>=0; i-=1 )
		{
			totalThreat += ((CNewNPC)actors[i]).GetThreatLevel();
		}
		return totalThreat;
	}
	
	// W3EE - Begin
	private var tickTimer : float;	default tickTimer = 0;
	event OnPlayerTickTimer( deltaTime : float )
	{
		super.OnPlayerTickTimer( deltaTime );
		
		if ( !IsInCombat() )
		{
			fastAttackCounter = 0;
			heavyAttackCounter = 0;			
		}
		
		tickTimer += deltaTime;
		if(tickTimer > 5)
		{
			FactsSet("StoredVigor", (int)(GetStat(BCS_Focus) * 1000), -1);
		}
		WmkGetMapMenuInstance().OnTick(deltaTime); // -= WMK:modAQOOM =-
	}
	// W3EE - End
	
	
	
	
	protected function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var ret : bool;
		var skill : ESkill;
	
		ret = super.PrepareAttackAction(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity, attackAction);
		
		if(!ret)
			return false;
		
		
		if(attackAction.IsActionMelee())
		{			
			skill = SkillNameToEnum( attackAction.GetAttackTypeName() );
			if( skill != S_SUndefined && CanUseSkill(skill))
			{
				if(IsLightAttack(animData.attackName))
					fastAttackCounter += 1;
				else
					fastAttackCounter = 0;
				
				if(IsHeavyAttack(animData.attackName))
					heavyAttackCounter += 1;
				else
					heavyAttackCounter = 0;				
			}		
		}
		
		AddTimer('FastAttackCounterDecay',5.0);
		AddTimer('HeavyAttackCounterDecay',5.0);
		
		return true;
	}
	
	protected function TestParryAndCounter(data : CPreAttackEventData, weaponId : SItemUniqueId, out parried : bool, out countered : bool) : array<CActor>
	{
		
		if(SkillNameToEnum(attackActionName) == S_Sword_s02)
			data.Can_Parry_Attack = false;
			
		return super.TestParryAndCounter(data, weaponId, parried, countered);
	}
		
	private timer function FastAttackCounterDecay(delta : float, id : int)
	{
		fastAttackCounter = 0;
	}
	
	private timer function HeavyAttackCounterDecay(delta : float, id : int)
	{
		heavyAttackCounter = 0;
	}
		
	
	public function GetCraftingSchematicsNames() : array<name>		{return craftingSchematics;}
	
	public function RemoveAllCraftingSchematics()
	{
		craftingSchematics.Clear();
	}
	
	
	function AddCraftingSchematic( nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool ) : bool
	{
		var i : int;
		
		if(!skipTutorialUpdate && ShouldProcessTutorial('TutorialCraftingGotRecipe'))
		{
			FactsAdd("tut_received_schematic");
		}
		
		for(i=0; i<craftingSchematics.Size(); i+=1)
		{
			if(craftingSchematics[i] == nam)
				return false;
			
			
			if(StrCmp(craftingSchematics[i],nam) > 0)
			{
				craftingSchematics.Insert(i,nam);
				AddCraftingHudNotification( nam, isSilent );
				theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_CraftingSchematics );
				return true;
			}			
		}	

		
		craftingSchematics.PushBack(nam);
		AddCraftingHudNotification( nam, isSilent );
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_CraftingSchematics );
		return true;	
	}
	
	function AddCraftingHudNotification( nam : name, isSilent : bool )
	{
		var hud : CR4ScriptedHud;
		if( !isSilent )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				hud.OnCraftingSchematicUpdate( nam );
			}
		}
	}	
	
	function AddAlchemyHudNotification( nam : name, isSilent : bool )
	{
		var hud : CR4ScriptedHud;
		if( !isSilent )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				hud.OnAlchemySchematicUpdate( nam );
			}
		}
	}

	public function GetExpandedCraftingCategories() : array< name >
	{
		return expandedCraftingCategories;
	}
	
	public function AddExpandedCraftingCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			ArrayOfNamesPushBackUnique( expandedCraftingCategories, category );
		}
	}

	public function RemoveExpandedCraftingCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			expandedCraftingCategories.Remove( category );
		}
	}
	
	public function SetCraftingFilters(showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		craftingFilters.showCraftable = showHasIngre;
		craftingFilters.showMissingIngre = showMissingIngre;
		craftingFilters.showAlreadyCrafted = showAlreadyCrafted;
	}
	
	public function GetCraftingFilters() : SCraftingFilters
	{
		
		if ( craftingFilters.showCraftable == false && craftingFilters.showMissingIngre == false && craftingFilters.showAlreadyCrafted == false )
		{
			craftingFilters.showCraftable = true;
			craftingFilters.showMissingIngre = true;
			craftingFilters.showAlreadyCrafted = false;
		}
		
		return craftingFilters;
	}
	
	
	
	
	//Kolaris - Gaunter Mode
	event OnMutation11Triggered( optional fromGM : bool )
	{
		var min, max : SAbilityAttributeValue;
		var healValue : float;
		var quenEntity : W3QuenEntity;
		
		if( IsSwimming() || IsDiving() || IsSailing() || IsUsingHorse() || IsUsingBoat() || IsUsingVehicle() || IsUsingExploration() )
		{
			
			ForceSetStat( BCS_Vitality, GetStatMax( BCS_Vitality ) );
			
			
			theGame.MutationHUDFeedback( MFT_PlayOnce );
			
			
			GCameraShake( 1.0f, , , , true, 'camera_shake_loop_lvl1_1' );
			AddTimer( 'StopMutation11CamShake', 2.f );
			
			
			theGame.VibrateControllerVeryHard( 2.f );
			
			
			Mutation11ShockWave( true );
			
			//Kolaris - Gaunter Mode
			if( !fromGM )
				AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
			else if( GaunterMode().ConfigDeathMod() > 0 )
				AddEffectDefault( EET_Mutation11Debuff, NULL, "GM Debuff", false );
		}
		else
		{
			//Kolaris - Gaunter Mode
			if( fromGM )
				AddEffectDefault( EET_Mutation11Buff, this, "GaunterMode", false );
			else
				AddEffectDefault( EET_Mutation11Buff, this, "Mutation 11", false );
		}
	}
	
	timer function StopMutation11CamShake( dt : float, id : int )
	{
		theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
	}
	
	public final function GetDrunkDecoctions( optional sourceName : string ) : array<CBaseGameplayEffect>
	{
		return effectManager.GetDrunkDecoctions(sourceName);
	}
	
	private var mutation12IsOnCooldown : bool;
	public final function AddMutation12Decoction()
	{
		var params : SCustomEffectParams;
		var buffs : array< EEffectType >;
		var existingDecoctionBuffs : array<CBaseGameplayEffect>;
		var i : int;
		var effectType : EEffectType;
		var decoctions : array< SItemUniqueId >;
		var tmpName : name;
		var min, max : SAbilityAttributeValue;
		
		return; //Kolaris - Mutation 12
		
		if( mutation12IsOnCooldown )
		{
			return;
		}
		
		existingDecoctionBuffs = GetDrunkDecoctions("Mutation12");
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'maxcap', min, max);
		if( existingDecoctionBuffs.Size() >= min.valueAdditive )
		{
			return;
		}
		
		mutation12IsOnCooldown = true;		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'cooldown', min, max);
		AddTimer('Mutation12Cooldown', CalculateAttributeValue(min));
		for(i=EET_Decoction1; i<=EET_Decoction10; i+=1)
		{
			if( !HasBuff(i) )
				buffs.PushBack(i);
		}
		
		if( buffs.Size() == 0 )
		{
			return;
		}
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation12', 'duration', min, max);
		params.effectType = buffs[RandRange(buffs.Size())];
		params.creator = this;
		params.sourceName = "Mutation12";
		params.duration = min.valueAdditive;
		AddEffectCustom(params);
		if( !IsEffectActive('invisible') )
			PlayEffect( 'use_potion' );
			
		theGame.MutationHUDFeedback( MFT_PlayOnce );
	}
	
	timer function Mutation12Cooldown( dt : float, id : int )
	{
		mutation12IsOnCooldown = false;
	}
	
	
	public final function HasResourcesToStartAnyMutationResearch() : bool
	{
		var greenPoints, redPoints, bluePoints, count : int;
		var itemIDs : array< SItemUniqueId >;
		
		if( levelManager.GetPointsFree( ESkillPoint ) > 0 )
		{
			return true;
		}
		
		
		count = inv.GetItemQuantityByName( 'Greater mutagen green' );
		if( count > 0 )
		{
			itemIDs = inv.GetItemsByName( 'Greater mutagen green' );
			greenPoints = inv.GetMutationResearchPoints( SC_Green, itemIDs[0] );
			if( greenPoints > 0 )
			{
				return true;
			}
		}	
		count = inv.GetItemQuantityByName( 'Greater mutagen red' );
		if( count > 0 )
		{
			itemIDs.Clear();
			itemIDs = inv.GetItemsByName( 'Greater mutagen red' );
			redPoints = inv.GetMutationResearchPoints( SC_Red, itemIDs[0] );
			if( redPoints > 0 )
			{
				return true;
			}
		}		
		count = inv.GetItemQuantityByName( 'Greater mutagen blue' );
		if( count > 0 )
		{
			itemIDs.Clear();
			itemIDs = inv.GetItemsByName( 'Greater mutagen blue' );
			bluePoints = inv.GetMutationResearchPoints( SC_Blue, itemIDs[0] );
			if( bluePoints > 0 )
			{
				return true;
			}
		}		
		
		return false;
	}
	
	
	public final function Mutation11StartAnimation()
	{
		
		thePlayer.ActionPlaySlotAnimationAsync( 'PLAYER_SLOT', 'geralt_mutation_11', 0.2, 0.2 );
		
		
		BlockAllActions( 'Mutation11', true );
		
		
		loopingCameraShakeAnimName = 'camera_shake_loop_lvl1_1';
		GCameraShake( 1.0f, , , , true, loopingCameraShakeAnimName );
		
		
		theGame.VibrateControllerVeryHard( 15.f );
		
		
		storedInteractionPriority = GetInteractionPriority();
		SetInteractionPriority( IP_Max_Unpushable );
	}
	
	event OnAnimEvent_Mutation11ShockWave( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		Mutation11ShockWave( false );
	}
	
	private final function Mutation11ShockWave( skipQuenSign : bool )
	{
		var action : W3DamageAction;
		var ents : array< CGameplayEntity >;
		var i, j : int;
		var damages : array< SRawDamage >;
	
		
		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), 5.f, 1000, '', FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral, this);
		
		if( ents.Size() > 0 )
		{
			damages = theGame.GetDefinitionsManager().GetDamagesFromAbility( 'Mutation11' );
		}
		
		
		for(i=0; i<ents.Size(); i+=1)
		{
			action = new W3DamageAction in theGame;
			action.Initialize( this, ents[i], NULL, "Mutation11", EHRT_Heavy, CPS_SpellPower, false, false, true, false );
			
			for( j=0; j<damages.Size(); j+=1 )
			{
				action.AddDamage( damages[j].dmgType, damages[j].dmgVal );
			}
			
			action.SetCannotReturnDamage( true );
			action.SetProcessBuffsIfNoDamage( true );
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
			action.SetHitAnimationPlayType( EAHA_ForceYes );
			action.SetCanPlayHitParticle( false );
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		
		
		
		
		mutation11QuenEntity = ( W3QuenEntity )GetSignEntity( ST_Quen );
		if( !mutation11QuenEntity )
		{
			mutation11QuenEntity = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
			mutation11QuenEntity.CreateAttachment( this, 'quen_sphere' );
			AddTimer( 'DestroyMutation11QuenEntity', 2.f );
		}
		mutation11QuenEntity.PlayHitEffect( 'quen_impulse_explode', mutation11QuenEntity.GetWorldRotation() );
		
		if( !skipQuenSign )
		{
			
			PlayEffect( 'mutation_11_second_life' );
			
			
			RestoreQuen( 1000000.f, 10.f, true );
		}
	}
	
	private var mutation11QuenEntity : W3QuenEntity;
	private var storedInteractionPriority : EInteractionPriority;
	
	timer function DestroyMutation11QuenEntity( dt : float, id : int )
	{
		if( mutation11QuenEntity )
		{
			mutation11QuenEntity.Destroy();
		}
	}
	
	event OnAnimEvent_Mutation11AnimEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_DurationEnd )
		{
			
			BlockAllActions( 'Mutation11', false );			
			
			
			theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
			
			
			theGame.StopVibrateController();
			
			
			SetInteractionPriority( storedInteractionPriority );
			
			
			RemoveBuff( EET_Mutation11Buff, true );
		}
		else if ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle )
		{
			
			SetBehaviorVariable( 'AIControlled', 0.f );
		}
	}
		
	public final function MutationSystemEnable( enable : bool )
	{
		( ( W3PlayerAbilityManager ) abilityManager ).MutationSystemEnable( enable );
	}
	
	public final function IsMutationSystemEnabled() : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationSystemEnabled();
	}
	
	public final function GetMutation( mutationType : EPlayerMutationType ) : SMutation
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutation( mutationType );
	}
	
	public final function IsMutationActive( mutationType : EPlayerMutationType) : bool
	{
		//Kolaris ++ Mutation Rework
		if( GetEquippedMutationType() == mutationType || (GetEquippedMutationType() == EPMT_Mutation12 && IsMutationResearched(mutationType)) )
			return true;
		return false;
		
		/*
		var swordQuality : int;
		var sword : SItemUniqueId;
		
		if( GetEquippedMutationType() != mutationType )
		{
			return false;
		}
		
		switch( mutationType )
		{
			case EPMT_Mutation4 :
			case EPMT_Mutation8 :
			case EPMT_Mutation11 :
			case EPMT_Mutation12 :
				if( IsInFistFight() )
				{
					return false;
				}
		}
		
		return true;*/
		//Kolaris -- Mutation Rework
	}
		
	public final function SetEquippedMutation( mutationType : EPlayerMutationType ) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).SetEquippedMutation( mutationType );
	}
	
	public final function GetEquippedMutationType() : EPlayerMutationType
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetEquippedMutationType();
	}
	
	public final function CanEquipMutation(mutationType : EPlayerMutationType) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).CanEquipMutation( mutationType );
	}
	
	public final function CanResearchMutation( mutationType : EPlayerMutationType ) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).CanResearchMutation( mutationType );
	}
	
	public final function IsMutationResearched(mutationType : EPlayerMutationType) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationResearched( mutationType );
	}
	
	public final function GetMutationResearchProgress(mutationType : EPlayerMutationType) : int
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutationResearchProgress( mutationType );
	}
	
	public final function GetMasterMutationStage() : int
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMasterMutationStage();
	}
	
	public final function MutationResearchWithSkillPoints(mutation : EPlayerMutationType, skillPoints : int) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).MutationResearchWithSkillPoints( mutation, skillPoints );
	}
	
	public final function MutationResearchWithItem(mutation : EPlayerMutationType, item : SItemUniqueId, optional count: int) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).MutationResearchWithItem( mutation, item, count );
	}
	
	public final function GetMutationLocalizedName( mutationType : EPlayerMutationType ) : string
	{
		var pam : W3PlayerAbilityManager;
		var locKey : name;
	
		pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
		locKey = pam.GetMutationNameLocalizationKey( mutationType );
		
		return GetLocStringByKeyExt( locKey );
	}
	
	public final function GetMutationLocalizedDescription( mutationType : EPlayerMutationType ) : string
	{
		var pam : W3PlayerAbilityManager;
		var locKey : name;
		var arrStr : array< string >;
		var dm : CDefinitionsManagerAccessor;
		var min, max, sp : SAbilityAttributeValue;
		var tmp, tmp2, tox, critBonusDamage, val : float;
		var stats, stats2 : SPlayerOffenseStats;
		var buffPerc, exampleEnemyCount, debuffPerc : int;
	
		pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
		locKey = pam.GetMutationDescriptionLocalizationKey( mutationType );
		dm = theGame.GetDefinitionsManager();
		
		//Kolaris - Mutation Rework
		switch( mutationType )
		{
			case EPMT_Mutation1 :
				/*dm.GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);							
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * min.valueAdditive ) ) );*/
				
				arrStr.PushBack( "50" );
				arrStr.PushBack( "50" );
				arrStr.PushBack( "50" );
			break;
			
			case EPMT_Mutation2 :
				/*sp = GetTotalSpellPower();
				
				
				dm.GetAbilityAttributeValue( 'Mutation2', 'crit_chance_factor', min, max );
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * ( min.valueAdditive + sp.valueMultiplicative * min.valueMultiplicative ) ) ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation2', 'crit_damage_factor', min, max );
				critBonusDamage = sp.valueMultiplicative * min.valueMultiplicative;
				
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * critBonusDamage ) ) );*/
				
				arrStr.PushBack( "2" );
				arrStr.PushBack( "4" );
				arrStr.PushBack( "1" );
				arrStr.PushBack( "5" );
				arrStr.PushBack( "10" );
				break;
				
			case EPMT_Mutation3 :
				
				/*dm.GetAbilityAttributeValue( 'Mutation3', 'attack_power', min, max );
				tmp = min.valueMultiplicative;
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * tmp ) ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation3', 'maxcap', min, max );
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * tmp * min.valueAdditive ) ) );*/
				
				arrStr.PushBack( "50" );
				break;
				
			case EPMT_Mutation4 :
			
				/*dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
				tmp2 = 100 * min.valueAdditive;
				dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
				tmp2 *= min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( tmp2 ) );
				
				
				tox = GetStat( BCS_Toxicity );
				if( tox > 0 )
				{
					tmp = RoundMath( tmp2 * tox );
				}
				else
				{
					tmp = tmp2;
				}
				arrStr.PushBack( NoTrailZeros( tmp ) );
				
				
				tox = GetStatMax( BCS_Toxicity );
				tmp = RoundMath( tmp2 * tox );
				arrStr.PushBack( NoTrailZeros( tmp ) );*/
				
				arrStr.PushBack ( FloatToStringPrec(Options().StamRed() / 10.f, 1) );
				arrStr.PushBack ( FloatToStringPrec(Options().StamDamRed() * 2.f, 0) );
				break;
				
			case EPMT_Mutation5 :
				
				/*dm.GetAbilityAttributeValue( 'Mutation5', 'mut5_dmg_red_perc', min, max );
				tmp = min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp ) );
				
				
				arrStr.PushBack( NoTrailZeros( 100 * tmp * 3 ) );*/
				
				arrStr.PushBack( "0.25" );
				arrStr.PushBack( "0.25" );
				break;
			
			case EPMT_Mutation6 :	
				
				/*theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );	
				
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
				sp = GetTotalSignSpellPower( S_Magic_1 );
				val = sp.valueAdditive + sp.valueMultiplicative * ( sp.valueBase + min.valueAdditive );
				arrStr.PushBack( NoTrailZeros( RoundMath( val ) ) );*/
				
				arrStr.PushBack( "50" );
				arrStr.PushBack( "50" );
				arrStr.PushBack( "50" );
				break;
				
			case EPMT_Mutation7 :
			
				/*dm.GetAbilityAttributeValue( 'Mutation7Buff', 'attack_power', min, max );
				buffPerc = (int) ( 100 * min.valueMultiplicative );
				arrStr.PushBack( NoTrailZeros( buffPerc ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation7BuffEffect', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
				
				exampleEnemyCount = 11;
				arrStr.PushBack( exampleEnemyCount );
				
				
				arrStr.PushBack( buffPerc * ( exampleEnemyCount -1 ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation7Debuff', 'attack_power', min, max );
				debuffPerc = (int) ( - 100 * min.valueMultiplicative );
				arrStr.PushBack( NoTrailZeros( debuffPerc ) );
				
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation7Debuff', 'minCapStacks', min, max );
				arrStr.PushBack( NoTrailZeros( debuffPerc * min.valueAdditive ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation7DebuffEffect', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );*/
			
			break;
			
			case EPMT_Mutation8 :
				
				/*dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation8', 'hp_perc_trigger', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );*/
				
			break;
				
			case EPMT_Mutation9 :
				
				
				
				
				/*stats = GetOffenseStatsList( 1 );
				arrStr.PushBack( NoTrailZeros( RoundMath( stats.crossbowSteelDmg ) ) );
				
				
				stats2 = GetOffenseStatsList( 2 );
				arrStr.PushBack( NoTrailZeros( RoundMath( stats2.crossbowSteelDmg ) ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation9', 'critical_hit_chance', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				
				dm.GetAbilityAttributeValue( 'Mutation9', 'health_reduction', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );*/
				
				arrStr.PushBack( "20" );
				arrStr.PushBack( "50" );
				arrStr.PushBack( "50" );
				arrStr.PushBack( "200" );
				break;
				
			case EPMT_Mutation10 :
				
				/*dm.GetAbilityAttributeValue( 'Mutation10Effect', 'mutation10_stat_boost', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative * GetStatMax( BCS_Toxicity ) ) );*/
				
				break;
				
			case EPMT_Mutation11 :
				
				/*arrStr.PushBack( 100 );
				
				
				dm.GetAbilityAttributeValue( 'Mutation11DebuffEffect', 'duration', min, max);
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );*/
				break;
				
			case EPMT_Mutation12 :
				
				/*dm.GetAbilityAttributeValue( 'Mutation12', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );				
				
				
				dm.GetAbilityAttributeValue( 'Mutation12', 'maxcap', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );*/
				break;
				
			case EPMT_MutationMaster :
				
				arrStr.PushBack("15");
				arrStr.PushBack("10");
				
				break;
		}
		
		return GetLocStringByKeyExtWithParams( locKey, , , arrStr );
	}
		
	public final function ApplyMutation10StatBoost( out statValue : SAbilityAttributeValue )
	{
		var attValue 			: SAbilityAttributeValue;
		var currToxicity		: float;
		
		if( IsMutationActive( EPMT_Mutation10 ) )
		{
			// W3EE - Begin
			currToxicity = GetStat(BCS_Toxicity) / GetStatMax(BCS_Toxicity);
			if( currToxicity > 0.f )
			{
				attValue = GetAttributeValue( 'mutation10_stat_boost' );
				attValue.valueMultiplicative *= PowF(currToxicity, 2);
				statValue.valueMultiplicative += attValue.valueMultiplicative;
			}
			// W3EE - End
		}
	}

	
	
	
	
	

	public final function IsBookRead( bookName : name ):bool
	{
		return booksRead.Contains( bookName );
	}	
	
	public final function AddReadBook( bookName : name ):void
	{
		if( !booksRead.Contains( bookName ) )
		{
			booksRead.PushBack( bookName );
		}
	}
	
	public final function RemoveReadBook( bookName : name ):void
	{
		var idx : int = booksRead.FindFirst( bookName );
		
		if( idx > -1 )
		{
			booksRead.Erase( idx );
		}
	}
	
	
	
	
	
	
	
	public function GetAlchemyRecipes() : array<name>
	{
		return alchemyRecipes;
	}
		
	public function CanLearnAlchemyRecipe(recipeName : name) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var recipeNode : SCustomNode;
		var i, tmpInt : int;
		var tmpName : name;
	
		dm = theGame.GetDefinitionsManager();
		if ( dm.GetSubNodeByAttributeValueAsCName( recipeNode, 'alchemy_recipes', 'name_name', recipeName ) )
		{
			return true;
			
		}
		
		return false;
	}
	
	private final function RemoveAlchemyRecipe(recipeName : name)
	{
		alchemyRecipes.Remove(recipeName);
	}
	
	private final function RemoveAllAlchemyRecipes()
	{
		alchemyRecipes.Clear();
	}

	
	function AddAlchemyRecipe(nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool) : bool
	{
		var i, potions, bombs : int;
		var found : bool;
		var m_alchemyManager : W3AlchemyManager;
		var recipe : SAlchemyRecipe;
		var knownBombTypes : array<string>;
		var strRecipeName, recipeNameWithoutLevel : string;
		
		if(!IsAlchemyRecipe(nam))
			return false;
		
		found = false;
		for(i=0; i<alchemyRecipes.Size(); i+=1)
		{
			if(alchemyRecipes[i] == nam)
				return false;
			
			
			if(StrCmp(alchemyRecipes[i],nam) > 0)
			{
				alchemyRecipes.Insert(i,nam);
				found = true;
				AddAlchemyHudNotification(nam,isSilent);
				break;
			}			
		}	

		if(!found)
		{
			alchemyRecipes.PushBack(nam);
			AddAlchemyHudNotification(nam,isSilent);
		}
		
		m_alchemyManager = new W3AlchemyManager in this;
		m_alchemyManager.Init(alchemyRecipes);
		m_alchemyManager.GetRecipe(nam, recipe);
			
		
		// W3EE - Begin
		/*
		if(CanUseSkill(S_Alchemy_s18))
		{
			if ((recipe.cookedItemType != EACIT_Bolt) && (recipe.cookedItemType != EACIT_Undefined) && (recipe.cookedItemType != EACIT_Dye) && (recipe.level <= GetSkillLevel(S_Alchemy_s18)))
				AddAbility(SkillEnumToName(S_Alchemy_s18), true);
			
		}
		*/
		// W3EE - End
		
		if(recipe.cookedItemType == EACIT_Bomb)
		{
			bombs = 0;
			for(i=0; i<alchemyRecipes.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
				
				
				if(recipe.cookedItemType == EACIT_Bomb)
				{
					strRecipeName = NameToString(alchemyRecipes[i]);
					recipeNameWithoutLevel = StrLeft(strRecipeName, StrLen(strRecipeName)-2);
					if(!knownBombTypes.Contains(recipeNameWithoutLevel))
					{
						bombs += 1;
						knownBombTypes.PushBack(recipeNameWithoutLevel);
					}
				}
			}
			
			theGame.GetGamerProfile().SetStat(ES_KnownBombRecipes, bombs);
		}		
		
		else if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
		{
			potions = 0;
			for(i=0; i<alchemyRecipes.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
				
				
				if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
				{
					potions += 1;
				}				
			}		
			theGame.GetGamerProfile().SetStat(ES_KnownPotionRecipes, potions);
		}
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_AlchemyRecipe );
				
		return true;
	}
	public function GetExpandedAlchemyCategories() : array< name >
	{
		return expandedAlchemyCategories;
	}
	
	public function AddExpandedAlchemyCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			ArrayOfNamesPushBackUnique( expandedAlchemyCategories, category );
		}
	}

	public function RemoveExpandedAlchemyCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			expandedAlchemyCategories.Remove( category );
		}
	}
	
	public function SetAlchemyFilters(showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		alchemyFilters.showCraftable = showHasIngre;
		alchemyFilters.showMissingIngre = showMissingIngre;
		alchemyFilters.showAlreadyCrafted = showAlreadyCrafted;
	}
	
	public function GetAlchemyFilters() : SCraftingFilters
	{
		
		if ( alchemyFilters.showCraftable == false && alchemyFilters.showMissingIngre == false && alchemyFilters.showAlreadyCrafted == false )
		{
			alchemyFilters.showCraftable = true;
			alchemyFilters.showMissingIngre = true;
			alchemyFilters.showAlreadyCrafted = false;
		}

		return alchemyFilters;
	}
	
	
	
	
	
	

	public function GetExpandedBestiaryCategories() : array< name >
	{
		return expandedBestiaryCategories;
	}
	
	public function AddExpandedBestiaryCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			ArrayOfNamesPushBackUnique( expandedBestiaryCategories, category );
		}
	}

	public function RemoveExpandedBestiaryCategory( category : name )
	{
		if ( IsNameValid( category ) )
		{
			expandedBestiaryCategories.Remove( category );
		}
	}
	
	
	
	
	
	
	
	public function GetDisplayHeavyAttackIndicator() : bool
	{
		return bDispalyHeavyAttackIndicator;
	}

	public function SetDisplayHeavyAttackIndicator( val : bool ) 
	{
		bDispalyHeavyAttackIndicator = val;
	}

	public function GetDisplayHeavyAttackFirstLevelTimer() : bool
	{
		return bDisplayHeavyAttackFirstLevelTimer;
	}

	public function SetDisplayHeavyAttackFirstLevelTimer( val : bool ) 
	{
		bDisplayHeavyAttackFirstLevelTimer = val;
	}
	
	
	
	
	
	

	public function SelectQuickslotItem( slot : EEquipmentSlots )
	{
		var item : SItemUniqueId;
	
		GetItemEquippedOnSlot(slot, item);
		selectedItemId = item;			
	}	
	
	
	
	
	
	
	
	public function GetMedallion() : W3MedallionController
	{
		if ( !medallionController )
		{
			medallionController = new W3MedallionController in this;
		}
		return medallionController;
	}
	
	
	public final function HighlightObjects(range : float, optional highlightTime : float )
	{
		var ents : array<CGameplayEntity>;
		var i : int;

		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), range, 100, 'HighlightedByMedalionFX', FLAG_ExcludePlayer);

		if(highlightTime == 0)
			highlightTime = 30;
		
		for(i=0; i<ents.Size(); i+=1)
		{
			if(!ents[i].IsHighlighted())
			{
				ents[i].SetHighlighted( true );
				ents[i].PlayEffectSingle( 'medalion_detection_fx' );
				ents[i].AddTimer( 'MedallionEffectOff', highlightTime );
			}
		}
	}
	
	
	public final function HighlightEnemies(range : float, optional highlightTime : float )
	{
		var ents : array<CGameplayEntity>;
		var i : int;
		var catComponent : CGameplayEffectsComponent;

		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), range, 100, , FLAG_ExcludePlayer + FLAG_OnlyAliveActors);

		if(highlightTime == 0)
			highlightTime = 5;
		
		for(i=0; i<ents.Size(); i+=1)
		{
			if(IsRequiredAttitudeBetween(this, ents[i], true))
			{
				catComponent = GetGameplayEffectsComponent(ents[i]);
				if(catComponent)
				{
					catComponent.SetGameplayEffectFlag(EGEF_CatViewHiglight, true);
					ents[i].AddTimer( 'EnemyHighlightOff', highlightTime, , , , , true );
				}
			}
		}
	}	
	
	function SpawnMedallionEntity()
	{
		var rot					: EulerAngles;
		var spawnedMedallion	: CEntity;
				
		spawnedMedallion = theGame.GetEntityByTag( 'new_Witcher_medallion_FX' ); 
		
		if ( !spawnedMedallion )
			theGame.CreateEntity( medallionEntity, GetWorldPosition(), rot, true, false );
	}
	
	
	
	
	
	
	
	
	
	public final function InterruptCombatFocusMode()
	{
		if( this.GetCurrentStateName() == 'CombatFocusMode_SelectSpot' )
		{	
			SetCanPlayHitAnim( true );
			PopState();
		}
	}
	
	public final function IsInDarkPlace() : bool
	{
		var envs : array< string >;
		
		if( FactsQuerySum( "tut_in_dark_place" ) )
		{
			return true;
		}
		
		GetActiveAreaEnvironmentDefinitions( envs );
		
		if( envs.Contains( 'env_novigrad_cave' ) || envs.Contains( 'cave_catacombs' ) )
		{
			return true;
		}
		
		return false;
	}
	
	
	
	
	
	private saved var selectedPotionSlotUpper, selectedPotionSlotLower : EEquipmentSlots;
	private var potionDoubleTapTimerRunning, potionDoubleTapSlotIsUpper : bool;
		default selectedPotionSlotUpper = EES_Potion1;
		default selectedPotionSlotLower = EES_Potion2;
		default potionDoubleTapTimerRunning = false;
	
	public final function SetPotionDoubleTapRunning(b : bool, optional isUpperSlot : bool)
	{
		if(b)
		{
			AddTimer('PotionDoubleTap', 0.3);
		}
		else
		{
			RemoveTimer('PotionDoubleTap');
		}
		
		potionDoubleTapTimerRunning = b;
		potionDoubleTapSlotIsUpper = isUpperSlot;
	}
	
	public final function IsPotionDoubleTapRunning() : bool
	{
		return potionDoubleTapTimerRunning;
	}
	
	timer function PotionDoubleTap(dt : float, id : int)
	{
		potionDoubleTapTimerRunning = false;
		OnPotionDrinkInput(potionDoubleTapSlotIsUpper);
	}
	
	public final function OnPotionDrinkInput(fromUpperSlot : bool)
	{
		var slot : EEquipmentSlots;
		
		if(fromUpperSlot)
			slot = GetSelectedPotionSlotUpper();
		else
			slot = GetSelectedPotionSlotLower();
			
		DrinkPotionFromSlot(slot);
	}
	
	public final function OnPotionDrinkKeyboardsInput(slot : EEquipmentSlots)
	{
		DrinkPotionFromSlot(slot);
	}
	
	private function DrinkPotionFromSlot(slot : EEquipmentSlots):void
	{
		var item : SItemUniqueId;		
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleItemInfo;
		
		GetItemEquippedOnSlot(slot, item);
		// W3EE - Begin
		if(inv.ItemHasTag(item, 'Edibles'))
		{
			//Kolaris - Shaving Razor
			if( inv.GetItemName(item) == 'Razor' )
			{
				if( !CampfireManager().CanPerformUpgrade() )
				{
					theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
					theSound.SoundEvent("gui_global_denied");
				}
				else
					ConsumeItem( item );
			}
			else if( inv.ItemHasTag(item, 'Drinks') )
			{
				if( !Options().GetUseDrinkAnimation() )
					ConsumeItem( item );
				else
					GetAnimManager().PerformAnimation(slot, item);
			}
			else
			{
				if( !Options().GetUseEatAnimation() )
					ConsumeItem( item );
				else
					GetAnimManager().PerformAnimation(slot, item);
			}
		}
		else
		{			
			if (ToxicityLowEnoughToDrinkPotion(slot))
			{
				if( !Options().GetUseDrinkAnimation() )
					DrinkPreparedPotion(slot);
				else
					GetAnimManager().PerformAnimation(slot, item);
			}
			else
			{
				SendToxicityTooHighMessage();
			}
		}
		
		/*
		if(inv.ItemHasTag(item, 'Edibles'))
		{
			ConsumeItem( item );
		}
		else
		{			
			if (ToxicityLowEnoughToDrinkPotion(slot))
			{
				DrinkPreparedPotion(slot);
			}
			else
			{
				SendToxicityTooHighMessage();
			}
		}
		*/
		// W3EE - End
		
		hud = (CR4ScriptedHud)theGame.GetHud(); 
		if ( hud ) 
		{ 
			module = (CR4HudModuleItemInfo)hud.GetHudModule("ItemInfoModule");
			if( module )
			{
				module.ForceShowElement();
			}
		}
	}
	
	private function SendToxicityTooHighMessage()
	{
		var messageText : string;
		var language : string;
		var audioLanguage : string;
		
		if (GetHudMessagesSize() < 2)
		{
			messageText = GetLocStringByKeyExt("menu_cannot_perform_action_now") + " " + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");
			
			theGame.GetGameLanguageName(audioLanguage,language);
			if (language == "AR")
			{
				messageText += (int)(abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(abilityManager.GetStatMax(BCS_Toxicity)) + " :";
			}
			else
			{
				messageText += ": " + (int)(abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(abilityManager.GetStatMax(BCS_Toxicity));
			}
			
			DisplayHudMessage(messageText);
		}
		theSound.SoundEvent("gui_global_denied");
	}
	
	public final function GetSelectedPotionSlotUpper() : EEquipmentSlots
	{
		return selectedPotionSlotUpper;
	}
	
	public final function GetSelectedPotionSlotLower() : EEquipmentSlots
	{
		return selectedPotionSlotLower;
	}
	
	
	public final function FlipSelectedPotion(isUpperSlot : bool) : bool
	{
		if(isUpperSlot)
		{
			if(selectedPotionSlotUpper == EES_Potion1)
			{
				
				if(IsAnyItemEquippedOnSlot(EES_Potion3))
				{
					selectedPotionSlotUpper = EES_Potion3;
					return true;
				}
				else if(CheckRadialMenu())
				{
					PotionSelectionPopup( EISPM_RadialMenuSlot3 );
					return true;
				}
				
			}
			else if(selectedPotionSlotUpper == EES_Potion3)
			{
				
				if(IsAnyItemEquippedOnSlot(EES_Potion1))
				{
					selectedPotionSlotUpper = EES_Potion1;
					return true;
				}
				else if(CheckRadialMenu())
				{
					PotionSelectionPopup( EISPM_RadialMenuSlot1 );
					return true;
				}
				
			}
		}
		else
		{
			if(selectedPotionSlotLower == EES_Potion2)
			{
				
				if(IsAnyItemEquippedOnSlot(EES_Potion4))
				{
					selectedPotionSlotLower = EES_Potion4;
					return true;
				}
				else if(CheckRadialMenu())
				{
					PotionSelectionPopup( EISPM_RadialMenuSlot4 );
				}
				
			}
			else if(selectedPotionSlotLower == EES_Potion4)
			{
				
				if(IsAnyItemEquippedOnSlot(EES_Potion2))
				{
					selectedPotionSlotLower = EES_Potion2;
					return true;
				}
				else if(CheckRadialMenu())
				{
					PotionSelectionPopup( EISPM_RadialMenuSlot2 );
				}
				
			}
		}
		
		return false;
	}
	
	public final function AddBombThrowDelay( bombId : SItemUniqueId )
	{
		var slot : EEquipmentSlots;
		
		slot = GetItemSlot( bombId );
		
		if( slot == EES_Unused )
		{
			return;
		}
			
		if( slot == EES_Petard1 || slot == EES_Quickslot1 )
		{
			remainingBombThrowDelaySlot1 = theGame.params.BOMB_THROW_DELAY;
			AddTimer( 'BombDelay', 0.0f, true );
		}
		else if( slot == EES_Petard2 || slot == EES_Quickslot2 )
		{
			remainingBombThrowDelaySlot2 = theGame.params.BOMB_THROW_DELAY;
			AddTimer( 'BombDelay', 0.0f, true );
		}
		else
		{
			return;
		}
	}
	
	public final function GetBombDelay( slot : EEquipmentSlots ) : float
	{
		if( slot == EES_Petard1 || slot == EES_Quickslot1 )
		{
			return remainingBombThrowDelaySlot1;
		}
		else if( slot == EES_Petard2 || slot == EES_Quickslot2 )
		{
			return remainingBombThrowDelaySlot2;
		}
		
		return 0;
	}
	
	timer function BombDelay( dt : float, id : int )
	{
		remainingBombThrowDelaySlot1 = MaxF( 0.f , remainingBombThrowDelaySlot1 - dt );
		remainingBombThrowDelaySlot2 = MaxF( 0.f , remainingBombThrowDelaySlot2 - dt );
		
		if( remainingBombThrowDelaySlot1 <= 0.0f && remainingBombThrowDelaySlot2  <= 0.0f )
		{
			RemoveTimer('BombDelay');
		}
	}
	
	public function ResetCharacterDev()
	{
		
		UnequipItemFromSlot(EES_SkillMutagen1);
		UnequipItemFromSlot(EES_SkillMutagen2);
		UnequipItemFromSlot(EES_SkillMutagen3);
		UnequipItemFromSlot(EES_SkillMutagen4);
		
		levelManager.ResetCharacterDev();
		((W3PlayerAbilityManager)abilityManager).ResetCharacterDev();		
	}
	
	public final function ResetMutationsDev()
	{
		levelManager.ResetMutationsDev();
		((W3PlayerAbilityManager)abilityManager).ResetMutationsDev();
	}
	
	public final function GetHeldSword() : SItemUniqueId
	{
		var i : int;
		var weapons : array< SItemUniqueId >;
		
		weapons = inv.GetHeldWeapons();
		for( i=0; i<weapons.Size(); i+=1 )
		{
			if( inv.IsItemSilverSwordUsableByPlayer( weapons[i] ) || inv.IsItemSteelSwordUsableByPlayer( weapons[i] ) )
			{
				return weapons[i];
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public function ConsumeItem( itemId : SItemUniqueId ) : bool
	{
		var itemName : name;
		var removedItem, willRemoveItem : bool;
		var edibles : array<SItemUniqueId>;
		var toSlot : EEquipmentSlots;
		var i : int;
		var equippedNewEdible : bool;
		
		var newEdibleId : int;
		var isLevel1, isLevel2 : bool;
		var abilities : array<name>;
		
		var acs : array< CComponent >; //Kolaris - Shaving Razor
		
		
		itemName = inv.GetItemName( itemId );
		
		//Kolaris - Bandage Fix, Kolaris - Bandage Injuries
		if( inv.ItemHasTag(itemId, 'Bandage') && !(Options().GetUseDrinkAnimation()) )
		{
			((W3Effect_Bleeding)GetBuff(EET_Bleeding)).RemoveStack(3);
			GetInjuryManager().HealRandomInjury();
		}
			
		//Kolaris - Shaving Razor
		if( itemName == 'Razor' )
		{
			acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
			( ( CHeadManagerComponent ) acs[0] ).Shave();
			theSound.SoundEvent("gui_inventory_weapon_attach");
			//theSound.SoundEvent("gui_inventory_steelsword_back");
		}
		// W3EE - Begin
		else if (itemName == 'q111_imlerith_acorn' ) 
		{
			// AddPoints(ESkillPoint, 2, true);
			Experience().ModTotalPathPoints(ESSP_Sword_Utility, 2);
			removedItem = inv.RemoveItem( itemId, 1 );
			// theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_title_buy_skill") + "<br>" + GetLocStringByKeyExt("panel_character_availablepoints") + " +2");
			theSound.SoundEvent("gui_character_buy_skill"); 
		} 
		else if ( itemName == 'Clearing Potion' ) 
		{
			ResetMutationsDev();
			ResetCharacterDev();
			Debug_ClearCharacterDevelopment(true);
			removedItem = inv.RemoveItem( itemId, 1 );
			if( !HasBuff(EET_Poise) )
				AddEffectDefault(EET_Poise, this, "Poise");
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_character_cleared") );
			theSound.SoundEvent("gui_character_synergy_effect"); 
		}
		else if ( itemName == 'Restoring Potion' ) 
		{
			/*ResetMutationsDev();*/
			removedItem = inv.RemoveItem( itemId, 1 );
			/*theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_character_cleared") );*/
			theSound.SoundEvent("gui_character_synergy_effect"); 
		}
		// W3EE - End
		else if(itemName == 'Wolf Hour')
		{
			removedItem = inv.RemoveItem( itemId, 1 );
			theSound.SoundEvent("gui_character_synergy_effect"); 
			//AddEffectDefault(EET_WolfHour, thePlayer, 'wolf hour');
		}
		else if ( itemName == 'q704_ft_golden_egg' )
		{
			Experience().ModTotalPathPoints(ESSP_Perks, 2);
			removedItem = inv.RemoveItem( itemId, 1 );
			//theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_title_buy_skill") + "<br>" + GetLocStringByKeyExt("panel_character_availablepoints") + " +1");
			theSound.SoundEvent("gui_character_buy_skill"); 
		} 
		else if ( itemName == 'mq7023_cake' )
		{
			this.AddAbility('mq7023_cake_vitality_bonus');
			removedItem = inv.RemoveItem( itemId, 1 );
			theSound.SoundEvent("gui_character_synergy_effect");
		}
		else
		{
			willRemoveItem = inv.GetItemQuantity(itemId) == 1 && !inv.ItemHasTag(itemId, 'InfiniteUse');
			
			if(willRemoveItem)
				toSlot = GetItemSlot(itemId);
				
			removedItem = super.ConsumeItem(itemId);
			
			if(willRemoveItem && removedItem)
			{
				edibles = inv.GetItemsByTag('Edibles');
				equippedNewEdible = false;
				
				newEdibleId = 0;
				
				
				for(i=0; i<edibles.Size(); i+=1)
				{
					if(!IsItemEquipped(edibles[i]) && !inv.ItemHasTag(edibles[i], 'Alcohol') && inv.GetItemName(edibles[i]) != 'Clearing Potion' && inv.GetItemName(edibles[i]) != 'Wolf Hour')
					{
						abilities.Clear();
						inv.GetItemAbilities(edibles[i], abilities);
						if (abilities.Contains('FoodEdibleQuality_3') || abilities.Contains('BeverageQuality_3'))
						{
							equippedNewEdible = true;
							newEdibleId = i;
							break;
						}
						else if (!isLevel2)
						{
							if (abilities.Contains('FoodEdibleQuality_2') || abilities.Contains('BeverageQuality_2'))
							{
								isLevel2 = true;
								isLevel1 = false;
								equippedNewEdible = true;
								newEdibleId = i;
							}
							else if (!isLevel1)
							{
								if (abilities.Contains('FoodEdibleQuality_1') || abilities.Contains('BeverageQuality_1'))
								{
									equippedNewEdible = true;
									newEdibleId = i;
									isLevel1 = true;
								}
								else 
								{
									equippedNewEdible = true;
									newEdibleId = i;
								}
							}
						}
					}
				}
				
				
				if(!equippedNewEdible)
				{
					for(i=0; i<edibles.Size(); i+=1)
					{
						if(!IsItemEquipped(edibles[i]) && inv.GetItemName(edibles[i]) != 'Clearing Potion' && inv.GetItemName(edibles[i]) != 'Wolf Hour')
						{
							EquipItemInGivenSlot(edibles[i], toSlot, true, false);
							break;
						}
					}
				}
				else
					EquipItemInGivenSlot(edibles[newEdibleId], toSlot, true, false);
			}
		}
		
		return removedItem;
	}
	
	
	public final function GetAlcoholForAlchemicalItemsRefill() : SItemUniqueId
	{
		var alcos : array<SItemUniqueId>;
		var id : SItemUniqueId;
		var i, price, minPrice : int;
		
		alcos = inv.GetItemsByTag(theGame.params.TAG_ALCHEMY_REFILL_ALCO);
		
		if(alcos.Size() > 0)
		{
			if(inv.ItemHasTag(alcos[0], theGame.params.TAG_INFINITE_USE))
				return alcos[0];
				
			minPrice = inv.GetItemPrice(alcos[0]);
			price = minPrice;
			id = alcos[0];
			
			for(i=1; i<alcos.Size(); i+=1)
			{
				if(inv.ItemHasTag(alcos[i], theGame.params.TAG_INFINITE_USE))
					return alcos[i];
				
				price = inv.GetItemPrice(alcos[i]);
				
				if(price < minPrice)
				{
					minPrice = price;
					id = alcos[i];
				}
			}
			
			return id;
		}
		
		return GetInvalidUniqueId();
	}
	
	public final function ClearPreviouslyUsedBolt()
	{
		previouslyUsedBolt = GetInvalidUniqueId();
	}
	
	public function ShouldUseInfiniteWaterBolts() : bool
	{
		// W3EE - Begin
		return false; //GetCurrentStateName() == 'Swimming' || IsSwimming() || IsDiving();
		// W3EE - End
	}
	
	public function GetCurrentInfiniteBoltName( optional forceBodkin : bool, optional forceHarpoon : bool ) : name
	{
		if(!forceBodkin && (forceHarpoon || ShouldUseInfiniteWaterBolts()) )
		{
			return 'Harpoon Bolt';
		}
		return 'Bodkin Bolt';
	}
	
	
	public final function AddAndEquipInfiniteBolt(optional forceBodkin : bool, optional forceHarpoon : bool)
	{
		// W3EE - Begin
		/*
		var bolt, bodkins, harpoons : array<SItemUniqueId>;
		var boltItemName : name;
		var i : int;
		
		
		bodkins = inv.GetItemsByName('Bodkin Bolt');
		harpoons = inv.GetItemsByName('Harpoon Bolt');
		
		for(i=bodkins.Size()-1; i>=0; i-=1)
			inv.RemoveItem(bodkins[i], inv.GetItemQuantity(bodkins[i]) );
			
		for(i=harpoons.Size()-1; i>=0; i-=1)
			inv.RemoveItem(harpoons[i], inv.GetItemQuantity(harpoons[i]) );
			
		
		
		boltItemName = GetCurrentInfiniteBoltName( forceBodkin, forceHarpoon );
		
		
		if(boltItemName == 'Bodkin Bolt' && inv.IsIdValid(previouslyUsedBolt))
		{
			bolt.PushBack(previouslyUsedBolt);
		}
		else
		{
			
			bolt = inv.AddAnItem(boltItemName, 1, true, true);
			
			
			if(boltItemName == 'Harpoon Bolt')
			{
				GetItemEquippedOnSlot(EES_Bolt, previouslyUsedBolt);
			}
		}
		
		EquipItem(bolt[0], EES_Bolt);
		*/
		// W3EE - End
	}
	
	
	event OnItemGiven(data : SItemChangedData)
	{
		var m_guiManager 	: CR4GuiManager;
		
		super.OnItemGiven(data);
		
		
		if(!inv)
			inv = GetInventory();
			
		ModNoDuplicatesAddDuplicateItemFact(inv,data);//modNoDuplicates
		
		
		if(inv.IsItemEncumbranceItem(data.ids[0]))
			UpdateEncumbrance();
		
		m_guiManager = theGame.GetGuiManager();
		if(m_guiManager)
			m_guiManager.RegisterNewItem(data.ids[0]);
			
		// -= WMK:modQuickSlots =-
		if (WmkGetQuickInventoryInstance()) {
			WmkGetQuickInventoryInstance().RegisterNewItem(data.ids[0]);
		}
		// -= WMK:modQuickSlots =-
	}
		
	public final function CheckForFullyArmedAchievement()
	{
		if( HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_BEAR) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_GRYPHON) || 
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_LYNX) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_WOLF) ||
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_VIPER) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_NETFLIX)			
		)
		{
			theGame.GetGamerProfile().AddAchievement(EA_FullyArmed);
		}
	}
	
	
	public final function HasAllItemsFromSet(setItemTag : name) : bool
	{
		var item : SItemUniqueId;
		
		if(!GetItemEquippedOnSlot(EES_SteelSword, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
		
		if(!GetItemEquippedOnSlot(EES_SilverSword, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Boots, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Pants, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Gloves, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Armor, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		
		if(setItemTag == theGame.params.ITEM_SET_TAG_BEAR || setItemTag == theGame.params.ITEM_SET_TAG_LYNX)
		{
			if(!GetItemEquippedOnSlot(EES_RangedWeapon, item) || !inv.ItemHasTag(item, setItemTag))
				return false;
		}

		return true;
	}
	
	public final function CheckForFullyArmedByTag(setItemTag : name)
	{
		var doneParts, totalParts : int;
		var item : SItemUniqueId;
		
		if(setItemTag == '')
			return;
			
		
		doneParts = 0;
		totalParts = 6;
		if(GetItemEquippedOnSlot(EES_SteelSword, item) && inv.ItemHasTag(item, setItemTag))
			doneParts += 1;
		
		if(GetItemEquippedOnSlot(EES_SilverSword, item) && inv.ItemHasTag(item, setItemTag))
			doneParts += 1;
			
		if(GetItemEquippedOnSlot(EES_Boots, item) && inv.ItemHasTag(item, setItemTag))
			doneParts += 1;
			
		if(GetItemEquippedOnSlot(EES_Pants, item) && inv.ItemHasTag(item, setItemTag))
			doneParts += 1;
			
		if(GetItemEquippedOnSlot(EES_Gloves, item) && inv.ItemHasTag(item, setItemTag))
			doneParts += 1;
			
		if(GetItemEquippedOnSlot(EES_Armor, item) && inv.ItemHasTag(item, setItemTag))
			doneParts += 1;
			
		
		if(setItemTag == theGame.params.ITEM_SET_TAG_BEAR || setItemTag == theGame.params.ITEM_SET_TAG_LYNX)
		{
			totalParts += 1;
			if(GetItemEquippedOnSlot(EES_RangedWeapon, item) && inv.ItemHasTag(item, setItemTag))
				doneParts += 1;
		}
		
		
		if(doneParts >= totalParts) 
		{
			theGame.GetGamerProfile().AddAchievement(EA_FullyArmed);
		}
		else
		{
			theGame.GetGamerProfile().NoticeAchievementProgress(EA_FullyArmed, doneParts, totalParts);
		}
	}
	
	
	public function GetTotalArmor() : SAbilityAttributeValue
	{
		// W3EE - Begin
		var armor, tempArmor : SAbilityAttributeValue;
		var armorItem : SItemUniqueId;
		var tempArmorGlyph : SAbilityAttributeValue;
		var temp : bool;
		
		armor = super.GetTotalArmor();
		
		//Kolaris - Armor System
		if(GetItemEquippedOnSlot(EES_Armor, armorItem))
		{
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			armor += inv.GetItemArmorTotal(armorItem);
		}
		
		if(GetItemEquippedOnSlot(EES_Pants, armorItem))
		{
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			armor += inv.GetItemArmorTotal(armorItem);
		}
			
		if(GetItemEquippedOnSlot(EES_Boots, armorItem))
		{
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			armor += inv.GetItemArmorTotal(armorItem);
		}
			
		if(GetItemEquippedOnSlot(EES_Gloves, armorItem))
		{
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			armor += inv.GetItemArmorTotal(armorItem);
		}
		
		//Kolaris - Ofieri Set
		if( IsSetBonusActive(EISB_Ofieri) )
		{
			tempArmorGlyph.valueBase = 50 * Combat().GetOfieriSetBonusCount("reinforcement");
			armor += tempArmorGlyph;
		}
		//Kolaris - Protection
		if( HasBuff(EET_EnhancedArmor) && HasAbility('Glyphword 31 _Stats', true) || HasAbility('Glyphword 32 _Stats', true) || HasAbility('Glyphword 33 _Stats', true) )
		{
			tempArmorGlyph.valueBase = 300;
			armor += tempArmorGlyph;
		}
		//Kolaris - Constitution
		if( HasAbility('Glyphword 43 _Stats', true) || HasAbility('Glyphword 44 _Stats', true) || HasAbility('Glyphword 45 _Stats', true) )
		{
			tempArmorGlyph.valueBase = RoundMath(200 * GetEncumbrance() / GetMaxRunEncumbrance(temp));
			armor += tempArmorGlyph;
		}
		
		return armor;
		// W3EE - End
	}
	
	
	
	public function ReduceArmorDurability() : EEquipmentSlots
	{
		var r, sum : int;
		var slot : EEquipmentSlots;
		var id : SItemUniqueId;
		var prevDurMult, currDurMult, ratio : float;
	
		
		sum = theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_BOOTS_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_MISS_WEIGHT;
		
		r = RandRange(sum);
		
		if(r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT)
			slot = EES_Armor;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT)
			slot = EES_Pants;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT + theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT)
			slot = EES_Gloves;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT + theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT + theGame.params.DURABILITY_ARMOR_BOOTS_WEIGHT)
			slot = EES_Boots;
		else
			return EES_InvalidSlot;					
		
		GetItemEquippedOnSlot(slot, id);				
		ratio = inv.GetItemDurabilityRatio(id);		
		if(inv.ReduceItemDurability(id))			
		{
			prevDurMult = theGame.params.GetDurabilityMultiplier(ratio, false);
			
			ratio = inv.GetItemDurabilityRatio(id);
			currDurMult = theGame.params.GetDurabilityMultiplier(ratio, false);
			
			if(currDurMult != prevDurMult)
			{
				
				
				
				
			}
				
			return slot;
		}
		
		return EES_InvalidSlot;
	}
	
	
	public function DismantleItem(dismantledItem : SItemUniqueId, toolItem : SItemUniqueId) : bool
	{
		var parts : array<SItemParts>;
		var i : int;
		
		if(!inv.IsItemDismantleKit(toolItem))
			return false;
		
		parts = inv.GetItemRecyclingParts(dismantledItem);
		
		if(parts.Size() <= 0)
			return false;
			
		for(i=0; i<parts.Size(); i+=1)
			inv.AddAnItem(parts[i].itemName, parts[i].quantity, true, false);
			
		inv.RemoveItem(toolItem);
		inv.RemoveItem(dismantledItem);
		return true;
	}
	
	
	public function GetItemEquippedOnSlot(slot : EEquipmentSlots, out item : SItemUniqueId) : bool
	{
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots'))
			return false;
		
		item = itemSlots[slot];
		
		return inv.IsIdValid(item);
	}
	
	
	public function GetItemSlotByItemName(itemName : name) : EEquipmentSlots
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		var slot : EEquipmentSlots;
		
		ids = inv.GetItemsByName(itemName);
		for(i=0; i<ids.Size(); i+=1)
		{
			slot = GetItemSlot(ids[i]);
			if(slot != EES_InvalidSlot)
				return slot;
		}
		
		return EES_InvalidSlot;
	}
	
	
	public function GetItemSlot(item : SItemUniqueId) : EEquipmentSlots
	{
		var i : int;
		
		if(!inv.IsIdValid(item))
			return EES_InvalidSlot;
			
		for(i=0; i<itemSlots.Size(); i+=1)
			if(itemSlots[i] == item)
				return i;
		
		return EES_InvalidSlot;
	}
	
	public function GetEquippedItems() : array<SItemUniqueId>
	{
		return itemSlots;
	}
	
	public function IsItemEquipped(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		return itemSlots.Contains(item);
	}

	public function IsItemHeld(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		return inv.IsItemHeld(item);
	}

	
	public function IsAnyItemEquippedOnSlot(slot : EEquipmentSlots) : bool
	{
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots'))
			return false;
			
		return inv.IsIdValid(itemSlots[slot]);
	}
	
	
	public function GetFreeQuickslot() : EEquipmentSlots
	{
		if(!inv.IsIdValid(itemSlots[EES_Quickslot1]))		return EES_Quickslot1;
		if(!inv.IsIdValid(itemSlots[EES_Quickslot2]))		return EES_Quickslot2;
		
		
		return EES_InvalidSlot;
	}
	
	
	event OnEquipItemRequested(item : SItemUniqueId, ignoreMount : bool)
	{
		var slot : EEquipmentSlots;
		
		if(inv.IsIdValid(item))
		{
			slot = inv.GetSlotForItemId(item);
				
			if (slot != EES_InvalidSlot)
			{
				
				
				EquipItemInGivenSlot(item, slot, ignoreMount);
			}
		}
	} 
	
	event OnUnequipItemRequested(item : SItemUniqueId)
	{
		UnequipItem(item);
	}
	
	
	public function EquipItem(item : SItemUniqueId, optional slot : EEquipmentSlots, optional toHand : bool) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		if(slot == EES_InvalidSlot)
		{
			slot = inv.GetSlotForItemId(item);
			
			if(slot == EES_InvalidSlot)
				return false;
		}
		
		ForceSoundAppearanceUpdate();
		
		return EquipItemInGivenSlot(item, slot, false, toHand);
	}
	
	protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		
		
		return !IsSlotPotionMutagen(slot) && category != 'usable' && category != 'potion' && category != 'petard' && !inv.ItemHasTag(item, 'PlayerUnwearable');
	}
		
	protected function ShouldMountItemWithName( itemName: name ): bool
	{
		var slot : EEquipmentSlots;
		var items : array<SItemUniqueId>;
		var category : name;
		var i : int;
		
		items = inv.GetItemsByName( itemName );
		
		category = inv.GetItemCategory( items[0] );
		
		slot = GetItemSlot( items[0] );
		
		return ShouldMount( slot, items[0], category );
	}	
	
	public function GetMountableItems( out items : array< SItemUniqueId > )
	{
		var i : int;
		var mountable : bool;
		var mountableItems : array< SItemUniqueId >;
		var slot : EEquipmentSlots;
		var category : name;
		var item: SItemUniqueId;
		
		for ( i = 0; i < items.Size(); i += 1 )
		{
			item = items[i];
		
			category = inv.GetItemCategory( item );
		
			slot = GetItemSlot( item );
		
			mountable = ShouldMount( slot, item, category );
		
			if ( mountable )
			{
				mountableItems.PushBack( items[ i ] );
			}
		}
		items = mountableItems;
	}
	
	public final function AddAndEquipItem( item : name ) : bool
	{
		var ids : array< SItemUniqueId >;
		
		ids = inv.AddAnItem( item );
		if( inv.IsIdValid( ids[ 0 ] ) )
		{
			return EquipItem( ids[ 0 ] );
		}
		
		return false;
	}
	
	public final function AddQuestMarkedSelectedQuickslotItem( sel : SSelectedQuickslotItem )
	{
		questMarkedSelectedQuickslotItems.PushBack( sel );
	}
	
	public final function GetQuestMarkedSelectedQuickslotItem( sourceName : name ) : SItemUniqueId
	{
		var i : int;
		
		for( i=0; i<questMarkedSelectedQuickslotItems.Size(); i+=1 )
		{
			if( questMarkedSelectedQuickslotItems[i].sourceName == sourceName )
			{
				return questMarkedSelectedQuickslotItems[i].itemID;
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public final function SwapEquippedItems(slot1 : EEquipmentSlots, slot2 : EEquipmentSlots)
	{
		var temp : SItemUniqueId;
		var pam : W3PlayerAbilityManager;
		
		temp = itemSlots[slot1];
		itemSlots[slot1] = itemSlots[slot2];
		itemSlots[slot2] = temp;
		
		if(IsSlotSkillMutagen(slot1))
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			if(pam)
				pam.OnSwappedMutagensPost(itemSlots[slot1], itemSlots[slot2]);
		}
	}
	
	public final function GetSlotForEquippedItem( itemID : SItemUniqueId ) : EEquipmentSlots
	{
		var i : int;
		
		for( i=0; i<itemSlots.Size(); i+=1 )
		{
			if( itemSlots[i] == itemID )
			{
				return i;
			}
		}
		
		return EES_InvalidSlot;
	}
	
	public function GetPoiseEffect() : W3Effect_Poise
	{
		return (W3Effect_Poise)GetBuff(EET_Poise);
	}
	
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{			
		var i, groupID, quantity : int;
		var fistsID : array<SItemUniqueId>;
		var pam : W3PlayerAbilityManager;
		var isSkillMutagen : bool;		
		var armorEntity : CItemEntity;
		var armorMeshComponent : CComponent;
		var armorSoundIdentification : name;
		var category : name;
		var tagOfASet : name;
		var prevSkillColor : ESkillColor;
		var containedAbilities : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var armorType : EArmorType;
		var otherMask, previousItemInSlot : SItemUniqueId;
		var tutStatePot : W3TutorialManagerUIHandlerStateInventory;
		var tutStateFood : W3TutorialManagerUIHandlerStateFood;
		var boltItem, armorItem : SItemUniqueId;
		var aerondight : W3Effect_Aerondight;
		
		if(!inv.IsIdValid(item))
		{
			LogAssert(false, "W3PlayerWitcher.EquipItemInGivenSlot: invalid item");
			return false;
		}
		if(slot == EES_InvalidSlot || slot == EES_HorseBlinders || slot == EES_HorseSaddle || slot == EES_HorseBag || slot == EES_HorseTrophy)
		{
			LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> - provided slot <<" + slot + ">> is invalid");
			return false;
		}
		if(itemSlots[slot] == item)
		{
			return true;
		}	
		
		if(!HasRequiredLevelToEquipItem(item))
		{
			
			return false;
		}
		
		if(inv.ItemHasTag(item, 'PhantomWeapon') && !GetPhantomWeaponMgr())
		{
			InitPhantomWeaponMgr();
		}
		
		// W3EE - Begin
		UpdateArmorCount(slot, item, 1);
		if( /*slot == EES_SilverSword &&*/ inv.ItemHasTag( item, 'Aerondight' ) )
		{
			AddEffectDefault( EET_Aerondight, this, "Aerondight" );
			
			
			aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
			aerondight.Pause( 'ManageAerondightBuff' );
			//Kolaris - Aerondight Set Bonus Count
			//UpdateAllSetBonuses(true);
		}
		
		GetPoiseEffect().UpdateMaxPoise();
		// W3EE - End
		
		previousItemInSlot = itemSlots[slot];
		if( IsItemEquipped(item)) 
		{
			SwapEquippedItems(slot, GetItemSlot(item));
			return true;
		}
		
		
		isSkillMutagen = IsSlotSkillMutagen(slot);
		if(isSkillMutagen)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			if(!pam.IsSkillMutagenSlotUnlocked(slot))
			{
				return false;
			}
		}
		
		
		if(inv.IsIdValid(previousItemInSlot))
		{			
			if(!UnequipItemFromSlot(slot, true))
			{
				LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> !!");
				return false;
			}
		}		
		
		
		if(inv.IsItemMask(item))
		{
			if(slot == EES_Quickslot1)
				GetItemEquippedOnSlot(EES_Quickslot2, otherMask);
			else
				GetItemEquippedOnSlot(EES_Quickslot1, otherMask);
				
			if(inv.IsItemMask(otherMask))
				UnequipItem(otherMask);
		}
		
		if(isSkillMutagen)
		{
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
		}
		
		itemSlots[slot] = item;
		
		category = inv.GetItemCategory( item );
	
		
		if( !ignoreMounting && ShouldMount(slot, item, category) )
		{
			
			inv.MountItem( item, toHand, IsSlotSkillMutagen( slot ) );
		}		
		
		theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_EQUIPPED, inv.GetItemName(item), slot );
				
		if(slot == EES_RangedWeapon)
		{			
			rangedWeapon = ( Crossbow )( inv.GetItemEntityUnsafe(item) );
			if(!rangedWeapon)
				AddTimer('DelayedOnItemMount', 0.1, true);
			
			if ( IsSwimming() || IsDiving() )
			{
				GetItemEquippedOnSlot(EES_Bolt, boltItem);
				
				if(inv.IsIdValid(boltItem))
				{
					if ( !inv.ItemHasTag(boltItem, 'UnderwaterAmmo' ))
					{
						AddAndEquipInfiniteBolt(false, true);
					}
				}
				else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
				{
					AddAndEquipInfiniteBolt(false, true);
				}
			}
			
			else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
				AddAndEquipInfiniteBolt();
		}
		else if(slot == EES_Bolt)
		{
			if(rangedWeapon)
			{	if ( !IsSwimming() || !IsDiving() )
				{
					rangedWeapon.OnReplaceAmmo();
					rangedWeapon.OnWeaponReload();
				}
				else
				{
					DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
				}
			}
		}		
		
		else if(isSkillMutagen)
		{
			theGame.GetGuiManager().IgnoreNewItemNotifications( true );
			
			
			quantity = inv.GetItemQuantity( item );
			if( quantity > 1 )
			{
				inv.SplitItem( item, quantity - 1 );
			}
			
			pam.OnSkillMutagenEquipped(item, slot, prevSkillColor);
			LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> equipped to slot <<" + slot + ">>");
			LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
			LogSkillColors("");
			
			theGame.GetGuiManager().IgnoreNewItemNotifications( false );
		}
		else if(slot == EES_Gloves && HasWeaponDrawn(false))
		{
			// W3EE - Begin
			/*
			PlayRuneword4FX(PW_Steel);
			PlayRuneword4FX(PW_Silver);
			*/
			// W3EE - End
		}
		
		else if( ( slot == EES_Petard1 || slot == EES_Petard2 ) && inv.IsItemBomb( GetSelectedItemId() ) )
		{
			SelectQuickslotItem( slot );
		}

		
		if(inv.ItemHasAbility(item, 'MA_HtH'))
		{
			inv.GetItemContainedAbilities(item, containedAbilities);
			fistsID = inv.GetItemsByName('fists');
			dm = theGame.GetDefinitionsManager();
			for(i=0; i<containedAbilities.Size(); i+=1)
			{
				if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
				{					
					inv.AddItemCraftedAbility(fistsID[0], containedAbilities[i], true);
				}
			}
		}		
		
		
		if(inv.IsItemAnyArmor(item))
		{
			// W3EE - Begin
			armorType = inv.GetArmorTypeOriginal(item);
			// W3EE - End
			pam = (W3PlayerAbilityManager)abilityManager;
			
			if(armorType == EAT_Light)
			{
				if(CanUseSkill(S_Perk_05))
					pam.SetPerkArmorBonus(S_Perk_05);
			}
			else if(armorType == EAT_Medium)
			{
				if(CanUseSkill(S_Perk_06))
					pam.SetPerkArmorBonus(S_Perk_06);
			}
			else if(armorType == EAT_Heavy)
			{
				if(CanUseSkill(S_Perk_07))
					pam.SetPerkArmorBonus(S_Perk_07);
			}
		}
		
		
		UpdateItemSetBonuses( item, true );
		
		//Kolaris - Enchantment Overhaul
		if( slot == EES_Armor )
			Equipment().ManageEnchantmentAbilities(item, inv.GetEnchantment(item), true);
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
	
		
		if(ShouldProcessTutorial('TutorialPotionCanEquip3'))
		{
			if(IsSlotPotionSlot(slot))
			{
				tutStatePot = (W3TutorialManagerUIHandlerStateInventory)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStatePot)
				{
					tutStatePot.OnPotionEquipped(inv.GetItemName(item));
				}
			}
		}
		
		// W3EE - Begin
		ManageModShieldHoods(item, true);
		if( inv.IsItemAnyArmor(item) )
			ResumeRepairBuffs(item);
		// W3EE - End
		
		if(ShouldProcessTutorial('TutorialFoodSelectTab'))
		{
			if( IsSlotPotionSlot(slot) && inv.IsItemFood(item))
			{
				tutStateFood = (W3TutorialManagerUIHandlerStateFood)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStateFood)
				{
					tutStateFood.OnFoodEquipped();
				}
			}
		}
		
		tagOfASet = inv.DetectTagOfASet(item);
		CheckForFullyArmedByTag(tagOfASet);
		
		return true;
	}

	private function CheckHairItem()
	{
		var ids : array<SItemUniqueId>;
		var i   : int;
		var itemName : name;
		var hairApplied : bool;
		
		ids = inv.GetItemsByCategory('hair');
		
		for(i=0; i<ids.Size(); i+= 1)
		{
			itemName = inv.GetItemName( ids[i] );
			
			if( itemName != 'Preview Hair' )
			{
				if( hairApplied == false )
				{
					inv.MountItem( ids[i], false );
					hairApplied = true;
				}
				else
				{
					inv.RemoveItem( ids[i], 1 );
				}
				
			}
		}
		
		if( hairApplied == false )
		{
			ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
			inv.MountItem( ids[0], false );
		}
		
	}

	
	timer function DelayedOnItemMount( dt : float, id : int )
	{
		var crossbowID : SItemUniqueId;
		var invent : CInventoryComponent;
		
		invent = GetInventory();
		if(!invent)
			return;	
		
		
		GetItemEquippedOnSlot(EES_RangedWeapon, crossbowID);
				
		if(invent.IsIdValid(crossbowID))
		{
			
			rangedWeapon = ( Crossbow )(invent.GetItemEntityUnsafe(crossbowID) );
			
			if(rangedWeapon)
			{
				
				RemoveTimer('DelayedOnItemMount');
			}
		}
		else
		{
			
			RemoveTimer('DelayedOnItemMount');
		}
	}

	public function GetHeldItems() : array<SItemUniqueId>
	{
		var items : array<SItemUniqueId>;
		var item : SItemUniqueId;
	
		if( inv.GetItemEquippedOnSlot(EES_SilverSword, item) && inv.IsItemHeld(item))
			items.PushBack(item);
			
		if( inv.GetItemEquippedOnSlot(EES_SteelSword, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_RangedWeapon, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Quickslot1, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Quickslot2, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Petard1, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Petard2, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		// -= WMK:modQuickSlots =-
		if (inv.GetItemEquippedOnSlot(EES_Petard3, item) && inv.IsItemHeld(item))
			items.PushBack(item);
		if (inv.GetItemEquippedOnSlot(EES_Petard4, item) && inv.IsItemHeld(item))
			items.PushBack(item);
		// -= WMK:modQuickSlots =-

		return items;			
	}
	
	public function MoveMutagenToSlot( item : SItemUniqueId, slotFrom : EEquipmentSlots, slotTo : EEquipmentSlots )
	{
		var pam : W3PlayerAbilityManager;
		var prevSkillColor : ESkillColor;
		var groupID : int;
		
		if( IsSlotSkillMutagen( slotTo ) )
		{	
			itemSlots[slotFrom] = GetInvalidUniqueId();
			
			
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slotFrom);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
			pam = (W3PlayerAbilityManager)abilityManager;
			pam.OnSkillMutagenUnequipped(item, slotFrom, prevSkillColor, true);
			
			
			
			EquipItemInGivenSlot( item, slotTo, false );
		}
	}
	
	
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item, bolts, id, armorItem : SItemUniqueId;
		var items : array<SItemUniqueId>;
		var retBool : bool;
		var fistsID, bolt : array<SItemUniqueId>;
		var i, groupID : int;
		var pam : W3PlayerAbilityManager;
		var prevSkillColor : ESkillColor;
		var containedAbilities : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var armorType : EArmorType;
		var isSwimming : bool;
		var hud 				: CR4ScriptedHud;
		var damagedItemModule 	: CR4HudModuleDamagedItems;
		
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots') || !inv.IsIdValid(itemSlots[slot]))
			return false;
			
		// W3EE - Begin
		item = itemSlots[slot];
		if( Equipment().DisallowUnequip(slot, item, inv) )
			return false;
			
		PauseRepairBuffs(item);
		Equipment().HandleRelicAbilities(this, item, false);
		// W3EE - End
		
		if(IsSlotSkillMutagen(slot))
		{
			
			pam = (W3PlayerAbilityManager)abilityManager;
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
		}
		
		
		if(slot == EES_SilverSword  || slot == EES_SteelSword)
		{
			PauseOilBuffs( slot == EES_SteelSword );
		}
		
		// item = itemSlots[slot];
		itemSlots[slot] = GetInvalidUniqueId();
		
		
		if(inv.ItemHasTag( item, 'PhantomWeapon' ) && GetPhantomWeaponMgr())
		{
			DestroyPhantomWeaponMgr();
		}
		
		// W3EE - Begin
		UpdateArmorCount(slot, item, -1);
		
		if( /*slot == EES_SilverSword &&*/ inv.ItemHasTag( item, 'Aerondight' ) )
		{
			RemoveBuff( EET_Aerondight );
			//Kolaris - Aerondight Set Bonus Count
			//UpdateAllSetBonuses(false);
		}
		
		GetPoiseEffect().UpdateMaxPoise();
		// W3EE - End
		
		if(slot == EES_RangedWeapon)
		{
			
			this.OnRangedForceHolster( true, true );
			rangedWeapon.ClearDeployedEntity(true);
			rangedWeapon = NULL;
		
			
			if(GetItemEquippedOnSlot(EES_Bolt, bolts))
			{
				if(inv.ItemHasTag(bolts, theGame.params.TAG_INFINITE_AMMO))
				{
					inv.RemoveItem(bolts, inv.GetItemQuantity(bolts) );
				}
			}
		}
		else if(IsSlotSkillMutagen(slot))
		{			
			pam.OnSkillMutagenUnequipped(item, slot, prevSkillColor, true);
			LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> unequipped from slot <<" + slot + ">>");
			LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
			LogSkillColors("");
		}
		
		
		if(currentlyEquipedItem == item)
		{
			currentlyEquipedItem = GetInvalidUniqueId();
			RaiseEvent('ForcedUsableItemUnequip');
		}
		if(currentlyEquipedItemL == item)
		{
			if ( currentlyUsedItemL )
			{
				currentlyUsedItemL.OnHidden( this );
			}
			HideUsableItem ( true );
		}
				
		
		if( !IsSlotPotionMutagen(slot) )
		{
			GetInventory().UnmountItem(item, true);
		}
		
		retBool = true;
				
		
		if(IsAnyItemEquippedOnSlot(EES_RangedWeapon) && slot == EES_Bolt)
		{			
			if(inv.ItemHasTag(item, theGame.params.TAG_INFINITE_AMMO))
			{
				
				inv.RemoveItem(item, inv.GetItemQuantityByName( inv.GetItemName(item) ) );
			}
			else if (!reequipped)
			{
				
				AddAndEquipInfiniteBolt();
			}
		}
		
		
		if(slot == EES_SilverSword  || slot == EES_SteelSword)
		{
			OnEquipMeleeWeapon(PW_None, true);			
		}
		
		if(  GetSelectedItemId() == item )
		{
			ClearSelectedItemId();
		}
		
		if(inv.IsItemBody(item))
		{
			retBool = true;
		}		
		
		/*if(retBool && !reequipped)
		{
			theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_UNEQUIPPED, inv.GetItemName(item), slot );
			
			
			if(slot == EES_SteelSword && !IsAnyItemEquippedOnSlot(EES_SilverSword))
			{
				RemoveBuff(EET_EnhancedWeapon);
			}
			else if(slot == EES_SilverSword && !IsAnyItemEquippedOnSlot(EES_SteelSword))
			{
				RemoveBuff(EET_EnhancedWeapon);
			}
			else if(inv.IsItemAnyArmor(item))
			{
				if( !IsAnyItemEquippedOnSlot(EES_Armor) && !IsAnyItemEquippedOnSlot(EES_Gloves) && !IsAnyItemEquippedOnSlot(EES_Boots) && !IsAnyItemEquippedOnSlot(EES_Pants))
					RemoveBuff(EET_EnhancedArmor);
			}
		}*/
		
		
		if(inv.ItemHasAbility(item, 'MA_HtH'))
		{
			inv.GetItemContainedAbilities(item, containedAbilities);
			fistsID = inv.GetItemsByName('fists');
			dm = theGame.GetDefinitionsManager();
			for(i=0; i<containedAbilities.Size(); i+=1)
			{
				if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
				{
					inv.RemoveItemCraftedAbility(fistsID[0], containedAbilities[i]);
				}
			}
		}
		
		//Kolaris - Enchantment Overhaul
		if(inv.IsItemAnyArmor(item))
		{
			// W3EE - Begin
			armorType = inv.GetArmorTypeOriginal(item);
			// W3EE - End
			pam = (W3PlayerAbilityManager)abilityManager;
			
			if(CanUseSkill(S_Perk_05) && armorType == EAT_Light)
			{
				pam.SetPerkArmorBonus(S_Perk_05);
			}
			if(CanUseSkill(S_Perk_06) && armorType == EAT_Medium)
			{
				pam.SetPerkArmorBonus(S_Perk_06);
			}
			if(CanUseSkill(S_Perk_07) && armorType == EAT_Heavy)
			{
				pam.SetPerkArmorBonus(S_Perk_07);
			}
		}
		
		UpdateItemSetBonuses( item, false );
		
		//Kolaris - Enchantment Overhaul
		if( slot == EES_Armor )
			Equipment().ManageEnchantmentAbilities(item, inv.GetEnchantment(item), false);
		
		//Kolaris - Manticore Set
		if( inv.ItemHasTag( item, theGame.params.ITEM_SET_TAG_BONUS ) /*&& !IsSetBonusActive( EISB_RedWolf_2 )*/ )
		{
			SkillReduceBombAmmoBonus();
		}
		
		// W3EE - Begin
		ManageModShieldHoods(item, false);
		// W3EE - End
		
		if( slot == EES_Gloves )
		{
			thePlayer.DestroyEffect('runeword_4');
		}
		
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			damagedItemModule = hud.GetDamagedItemModule();
			if ( damagedItemModule )
			{
				damagedItemModule.OnItemUnequippedFromSlot( slot );
			}
		}
		
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		return retBool;
	}
		
	public function UnequipItem(item : SItemUniqueId) : bool
	{
		// W3EE - Begin
		if(!inv.IsIdValid(item) || Equipment().DisallowUnequip(itemSlots.FindFirst(item), item, inv))
			return false;
		// W3EE - End
		
		return UnequipItemFromSlot( itemSlots.FindFirst(item) );
	}
	
	public function DropItem( item : SItemUniqueId, quantity : int ) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
		if(IsItemEquipped(item))
			return UnequipItem(item);
		
		return true;
	}	
	
	
	public function IsItemEquippedByName(itemName : name) : bool
	{
		var i : int;
	
		for(i=0; i<itemSlots.Size(); i+=1)
			if(inv.GetItemName(itemSlots[i]) == itemName)
				return true;

		return false;
	}

	
	public function IsItemEquippedByCategoryName(categoryName : name) : bool
	{
		var i : int;
	
		for(i=0; i<itemSlots.Size(); i+=1)
			if(inv.GetItemCategory(itemSlots[i]) == categoryName)
				return true;
				
		return false;
	}
	
	public function GetMaxRunEncumbrance(out usesHorseBonus : bool) : float
	{
		var attValue : SAbilityAttributeValue;
		var value : float;
		
		// W3EE - Begin
		//value = CalculateAttributeValue(GetHorseManager().GetHorseAttributeValue('encumbrance', false));
		value = 0;
		usesHorseBonus = (value > 0);
		attValue = GetAttributeValue('carryweight_bonus');
		value += Options().BaseCWGeralt() + CalculateAttributeValue( GetAttributeValue('encumbrance') ) - 60 + attValue.valueAdditive;
		// W3EE - End
		//Kolaris - Constitution, Kolaris - Elation
		if( HasAbility('Glyphword 43 _Stats', true) || HasAbility('Glyphword 44 _Stats', true) || HasAbility('Glyphword 45 _Stats', true) || HasAbility('Glyphword 49 _Stats', true) || HasAbility('Glyphword 50 _Stats', true) || HasAbility('Glyphword 51 _Stats', true) )
			value += 20;
		
		return value;
	}
		
	public function GetEncumbrance() : float
	{
		var i: int;
		var encumbrance : float;
		var items : array<SItemUniqueId>;
		var inve : CInventoryComponent;
	
		inve = GetInventory();			
		inve.GetAllItems(items);

		for(i=0; i<items.Size(); i+=1)
		{
			encumbrance += inve.GetItemEncumbrance( items[i] );
			
			
			
		}		
		return encumbrance;
	}
	
	
	
	public function StartInvUpdateTransaction():void
	{
		invUpdateTransaction = true;
	}
	
	public function FinishInvUpdateTransaction():void
	{
		invUpdateTransaction = false;
		
		
		
		UpdateEncumbrance();
	}
	
	
	public function UpdateEncumbrance()
	{
		var temp : bool;
		
		if (invUpdateTransaction)
		{
			
			return;
		}
		
		
		
		if ( GetEncumbrance() >= (GetMaxRunEncumbrance(temp) + 1) )
		{
			if( !HasBuff(EET_OverEncumbered) && FactsQuerySum( "DEBUG_EncumbranceBoy" ) == 0 )
			{
				AddEffectDefault(EET_OverEncumbered, NULL, "OverEncumbered");
			}
		}
		else if(HasBuff(EET_OverEncumbered))
		{
			RemoveAllBuffsOfType(EET_OverEncumbered);
		}
	}
	
	public final function GetSkillGroupIDFromIndex(idx : int) : int
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupIDFromIndex(idx);
			
		return -1;
	}
	
	public final function GetSkillGroupColor(groupID : int) : ESkillColor
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupColor(groupID);
			
		return SC_None;
	}
	
	public final function GetSkillGroupsCount() : int
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupsCount();
			
		return 0;
	}
	
	
	
	
	
	
	
	
	function CycleSelectSign( bIsCyclingLeft : bool ) : ESignType
	{
		var signOrder : array<ESignType>;
		var i : int;
		
		signOrder.PushBack( ST_Yrden );
		signOrder.PushBack( ST_Quen );
		signOrder.PushBack( ST_Igni );
		signOrder.PushBack( ST_Axii );
		signOrder.PushBack( ST_Aard );
			
		for( i = 0; i < signOrder.Size(); i += 1 )
			if( signOrder[i] == equippedSign )
				break;
		
		if(bIsCyclingLeft)
			return signOrder[ (4 + i) % 5 ];	
		else
			return signOrder[ (6 + i) % 5 ];
	}
	
	function ToggleNextSign()
	{
		SetEquippedSign(CycleSelectSign( false ));
		FactsAdd("SignToggled", 1, 1);
	}
	
	function TogglePreviousSign()
	{
		SetEquippedSign(CycleSelectSign( true ));
		FactsAdd("SignToggled", 1, 1);
	}
	
	function ProcessSignEvent( eventName : name ) : bool
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
		{
			return signs[currentlyCastSign].entity.OnProcessSignEvent( eventName );
		}
		
		return false;
	}
	
	var findActorTargetTimeStamp : float;
	var pcModeChanneledSignTimeStamp	: float;
	event OnProcessCastingOrientation( isContinueCasting : bool )
	{
		var customOrientationTarget : EOrientationTarget;
		var checkHeading 			: float;
		var rotHeading 				: float;
		var playerToHeadingDist 	: float;
		var slideTargetActor		: CActor;
		var newLockTarget			: CActor;
		
		var enableNoTargetOrientation	: bool;
		
		var currTime : float;
		
		enableNoTargetOrientation = true;
		if ( GetDisplayTarget() && this.IsDisplayTargetTargetable() )
		{
			enableNoTargetOrientation = false;
			//Kolaris - NG Quick Cast
			if ( theInput.GetActionValue( 'CastSignHold' ) > 0 || this.IsCurrentSignChanneled() )
			{
				if ( IsPCModeEnabled() )
				{
					if ( EngineTimeToFloat( theGame.GetEngineTime() ) >  pcModeChanneledSignTimeStamp + 1.f )
						enableNoTargetOrientation = true;
				}
				else
				{
					if ( GetCurrentlyCastSign() == ST_Igni || GetCurrentlyCastSign() == ST_Axii )
					{
						slideTargetActor = (CActor)GetDisplayTarget();
						if ( slideTargetActor 
							&& ( !slideTargetActor.GetGameplayVisibility() || !CanBeTargetedIfSwimming( slideTargetActor ) || !slideTargetActor.IsAlive() ) )
						{
							SetSlideTarget( NULL );
							if ( ProcessLockTarget() )
								slideTargetActor = (CActor)slideTarget;
						}				
						
						if ( !slideTargetActor )
						{
							LockToTarget( false );
							enableNoTargetOrientation = true;
						}
						else if ( IsThreat( slideTargetActor ) || GetCurrentlyCastSign() == ST_Axii )
							LockToTarget( true );
						else
						{
							LockToTarget( false );
							enableNoTargetOrientation = true;
						}
					}
				}
			}

			if ( !enableNoTargetOrientation )
			{			
				customOrientationTarget = OT_Actor;
			}
		}
		
		if ( enableNoTargetOrientation )
		{
			//Kolaris - NG Quick Cast
			if ( GetPlayerCombatStance() == PCS_AlertNear && theInput.GetActionValue( 'CastSignHold' ) > 0 )
			{
				if ( GetDisplayTarget() && !slideTargetActor )
				{
					currTime = EngineTimeToFloat( theGame.GetEngineTime() );
					if ( currTime > findActorTargetTimeStamp + 1.5f )
					{
						findActorTargetTimeStamp = currTime;
						
						newLockTarget = GetScreenSpaceLockTarget( GetDisplayTarget(), 180.f, 1.f, 0.f, true );
						
						if ( newLockTarget && IsThreat( newLockTarget ) && IsCombatMusicEnabled() )
						{
							SetTarget( newLockTarget, true );
							SetMoveTargetChangeAllowed( true );
							SetMoveTarget( newLockTarget );
							SetMoveTargetChangeAllowed( false );
							SetSlideTarget( newLockTarget );							
						}	
					}
				}
				else
					ProcessLockTarget();
			}
			
			if ( wasBRAxisPushed )
				customOrientationTarget = OT_CameraOffset;
			else
			{
				if ( !lastAxisInputIsMovement || theInput.LastUsedPCInput() )
					customOrientationTarget = OT_CameraOffset;
				//Kolaris - NG Quick Cast
				else if ( theInput.GetActionValue( 'CastSignHold' ) > 0 )
				{
					if ( GetOrientationTarget() == OT_CameraOffset )
						customOrientationTarget = OT_CameraOffset;
					else if ( GetPlayerCombatStance() == PCS_AlertNear || GetPlayerCombatStance() == PCS_Guarded ) 
						customOrientationTarget = OT_CameraOffset;
					else
						customOrientationTarget = OT_Player;
				}
				else
					customOrientationTarget = OT_CustomHeading;
			}			
		}		
		
		if ( GetCurrentlyCastSign() == ST_Quen )
		{
			if ( IsCurrentSignChanneled() )
			{
				if ( bLAxisReleased )
					customOrientationTarget = OT_Player;
				else
					customOrientationTarget = OT_Camera;
			}
			else 
				customOrientationTarget = OT_Player;
		}	
		
		if ( GetCurrentlyCastSign() == ST_Axii && IsCurrentSignChanneled() )
		{	
			if ( slideTarget && (CActor)slideTarget )
			{
				checkHeading = VecHeading( slideTarget.GetWorldPosition() - this.GetWorldPosition() );
				rotHeading = checkHeading;
				playerToHeadingDist = AngleDistance( GetHeading(), checkHeading );
				
				if ( playerToHeadingDist > 45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading, 0.0, 0.5, false );
				else if ( playerToHeadingDist < -45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading, 0.0, 0.5, false );					
			}
			else
			{
				checkHeading = VecHeading( theCamera.GetCameraDirection() );
				rotHeading = GetHeading();
				playerToHeadingDist = AngleDistance( GetHeading(), checkHeading );
				
				if ( playerToHeadingDist > 45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading - 22.5, 0.0, 0.5, false );
				else if ( playerToHeadingDist < -45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading + 22.5, 0.0, 0.5, false );				
			}
		}
		
 		if( Options().LockOn() == 0 && !Options().LockOnMode() || Options().LockOn() != 0 && !Options().LockOnModeSF() && theGame.GetInGameConfigWrapper().GetVarValue('EnhancedTargeting', 'ETSignsTowardsCamera') )
			customOrientationTarget = OT_CameraOffset;
		else
 		if( GetCurrentlyCastSign() != ST_Quen && theGame.GetInGameConfigWrapper().GetVarValue('EnhancedTargeting', 'ETSignsTowardsCamera') )
			customOrientationTarget = OT_CustomHeading;
			
		if ( IsActorLockedToTarget() )
			customOrientationTarget = OT_Actor;
			
		AddCustomOrientationTarget( customOrientationTarget, 'Signs' );
		if ( customOrientationTarget == OT_CustomHeading )
			SetOrientationTargetCustomHeading( GetCombatActionHeading(), 'Signs' );			
	}
	
	event OnRaiseSignEvent()
	{
		var newTarget : CActor;
	
		if ( ( !IsCombatMusicEnabled() && !CanAttackWhenNotInCombat( EBAT_CastSign, false, newTarget ) ) || ( IsOnBoat() && !IsCombatMusicEnabled() ) )
		{		
			if ( CastSignFriendly() )
				return true;
		}
		else
		{
			RaiseEvent('CombatActionFriendlyEnd');
			SetBehaviorVariable( 'SignNum', (int)equippedSign );
			SetBehaviorVariable( 'combatActionType', (int)CAT_CastSign );

			if ( IsPCModeEnabled() )
				pcModeChanneledSignTimeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
		
			if( RaiseForceEvent('CombatAction') )
			{
				OnCombatActionStart();
				findActorTargetTimeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
				theTelemetry.LogWithValueStr(TE_FIGHT_PLAYER_USE_SIGN, SignEnumToString( equippedSign ));
				return true;
			}
		}
		
		return false;
	}
	
	function CastSignFriendly() : bool
	{
		var actor : CActor;
	
		SetBehaviorVariable( 'combatActionTypeForOverlay', (int)CAT_CastSign );			
		if ( RaiseCombatActionFriendlyEvent() )
		{
						
			return true;
		}	
		
		return false;
	}
	
	function CastSign() : bool
	{
		var equippedSignStr : string;
		var newSignEnt : W3SignEntity;
		var spawnPos : Vector;
		var slotMatrix : Matrix;
		var target : CActor;
		
		// W3EE - Begin
		if ( IsInAir() || IsSwimming() || IsMeditating() )
		{
			return false;
		}
		// W3EE - End
		
		AddTemporarySkills();
		
		
		
		if(equippedSign == ST_Aard)
		{
			CalcEntitySlotMatrix('l_weapon', slotMatrix);
			spawnPos = MatrixGetTranslation(slotMatrix);
		}
		else
		{
			spawnPos = GetWorldPosition();
		}
		
		if( equippedSign == ST_Aard || equippedSign == ST_Igni )
		{
			target = GetTarget();
			if(target)
				target.SignalGameplayEvent( 'DodgeSign' );
		}
		
		newSignEnt = (W3SignEntity)theGame.CreateEntity( signs[equippedSign].template, spawnPos, GetWorldRotation() );
		return newSignEnt.Init( signOwner, signs[equippedSign].entity );
	}
	
	// W3EE - Begin
	public function CastSignUnderwater()
	{
		if( equippedSign == ST_Aard )
		{
			SetBehaviorVariable('SelectedItemL', (int)UI_OilLamp, true);
			RaiseEvent('ItemUseL');
			AddTimer('CastSignUnderwaterTimer', 1.1f, false);
			AddTimer('EndUsableAnim', 1.6f, false);
		}
	}
	
	timer function EndUsableAnim( dt : float, id : int )
	{
		RaiseEvent('ItemEndL');
	}
	
	timer function CastSignUnderwaterTimer( dt : float, id : int )
	{
		CastDesiredSignUnderwater(equippedSign, false);
	}
	
	public function CastDesiredSignUnderwater( signType : ESignType, alternateCast : bool )
	{
		var slotMatrix : Matrix;
		var spawnPos : Vector;
		var signEntity : W3SignEntity;
		
		if( signType == ST_Aard )
		{
			CalcEntitySlotMatrix('l_weapon', slotMatrix);
			spawnPos = MatrixGetTranslation(slotMatrix);
		}
		else
		if( signType == ST_Quen )
		{
			spawnPos = GetWorldPosition();
		}
		else return;
		
		AddTemporarySkills();
		
		signEntity = (W3SignEntity)theGame.CreateEntity(signs[signType].template, spawnPos, GetWorldRotation());
		signEntity.Init(signOwner, signs[signType].entity, true, false, false);
		if( alternateCast )
			signEntity.SetAlternateCast(SignEnumToSkillEnum(signType));
		signEntity.OnStarted();
		signEntity.OnThrowing();
		signEntity.OnEnded();
	}
	
	public function CastDesiredSign( signType : ESignType, freeCast : bool, alternateCast : bool, baseCast : bool, spawnPos : Vector, rotation : EulerAngles )
	{
		var signEntity : W3SignEntity;
		
		signEntity = (W3SignEntity)theGame.CreateEntity(signs[signType].template, spawnPos, rotation);
		signEntity.Init(signOwner, signs[signType].entity, true, false, freeCast);
		if( baseCast )
			signEntity.SetBaseCast();
		if( alternateCast )
			signEntity.SetAlternateCast(SignEnumToSkillEnum(signType));
		signEntity.OnStarted();
		signEntity.OnThrowing();
		signEntity.OnEnded();
	}
	// W3EE - End
	
	private function HAX_SignToThrowItemRestore()
	{
		var action : SInputAction;
		
		action.value = theInput.GetActionValue('ThrowItemHold');
		action.lastFrameValue = 0;
		
		if(IsPressed(action) && CanSetupCombatAction_Throw())
		{
			if(inv.IsItemBomb(selectedItemId))
			{
				BombThrowStart();
			}
			else
			{
				UsableItemStart();
			}
			
			SetThrowHold( true );
		}
	}
	
	event OnCFMCameraZoomFail(){}
		
	

	public final function GetPotionBuffs() : array<CBaseGameplayEffect>
	{
		return effectManager.GetPotionBuffs();
	}
	
	public final function RecalcPotionsDurations()
	{
		var i : int;
		var buffs : array<CBaseGameplayEffect>;
		
		buffs = GetPotionBuffs();
		for(i=0; i<buffs.Size(); i+=1)
		{
			buffs[i].RecalcPotionDuration();
		}
	}

	// W3EE - Begin
	private var frenzySpeedBuff : int;	default frenzySpeedBuff = -1;
	public function StartFrenzy()
	{
		var min, max : SAbilityAttributeValue;
		var slowdown, duration, chance : float;
		var thunderbolt : W3Potion_Thunderbolt;
		
		thunderbolt = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
		if( !isInFrenzy && thunderbolt && thunderbolt.GetBuffLevel() == 3  )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('ThunderboltEffect_Level3', 'critical_frenzy_chance', min, max);
			chance = min.valueAdditive;
			
			if( RandRange(100, 0) <= chance )
			{
				isInFrenzy = true;
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('ThunderboltEffect_Level3', 'critical_frenzy_duration', min, max);
				duration = min.valueAdditive;
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('ThunderboltEffect_Level3', 'critical_frenzy_slowdown', min, max);
				slowdown = min.valueAdditive;
				frenzySpeedBuff = SetAnimationSpeedMultiplier(1 / slowdown, frenzySpeedBuff, true);
				theGame.SetTimeScale(slowdown, theGame.GetTimescaleSource(ETS_SkillFrenzy), theGame.GetTimescalePriority(ETS_SkillFrenzy), true);
				AddTimer('SkillFrenzyFinish', duration * slowdown, , , , true);
			}
		}
	}
	
	timer function SkillFrenzyFinish(dt : float, optional id : int)
	{
		ResetAnimationSpeedMultiplier(frenzySpeedBuff);
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_SkillFrenzy));
		isInFrenzy = false;
	}
	// W3EE - End
	
	public function GetToxicityDamageThreshold() : float
	{
		var ret : float;
		
		ret = theGame.params.TOXICITY_DAMAGE_THRESHOLD;
		
		// W3EE - Begin
		if( GetCurrentStateName() == 'W3EEMeditation' )
			ret += GetStatMax(BCS_Toxicity) * 0.2f;
		
		/*
		if(CanUseSkill(S_Alchemy_s01))
			ret += CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s01, 'threshold', false, true)) * GetSkillLevel(S_Alchemy_s01);
		*/
		// W3EE - End
		
		return ret;
	}
	
	
	
	public final function AddToxicityOffset( val : float )
	{
		((W3PlayerAbilityManager)abilityManager).AddToxicityOffset(val);		
	}
	
	public final function SetToxicityOffset( val : float )
	{
		((W3PlayerAbilityManager)abilityManager).SetToxicityOffset(val);
	}
	
	public final function RemoveToxicityOffset( val : float )
	{
		((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(val);		
	}
	
	public final function GetToxicityOffset() : float
	{
		return ((W3PlayerAbilityManager)abilityManager).GetToxicityOffset();		
	}
	
	
	public final function CalculatePotionDuration(item : SItemUniqueId, isDecoction : bool, optional itemName : name) : float
	{
		var duration, skillPassiveMod, mutagenSkillMod : float;
		var val, min, max : SAbilityAttributeValue;
		
		
		if(inv.IsIdValid(item))
		{
			duration = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'duration'));			
		}
		else
		{
			theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		
		// W3EE - Begin		
		if( isDecoction )
		{
			if( Options().GetGlobalDecoctionDuration()() )
				duration = Options().GetGlobalDecoctionDuration();
			else
			if( Options().GetMinimumDecoctionDuration() )
				duration += Options().GetMinimumDecoctionDuration();
			
			if( Options().GetDecoctionDurationMult() )
				duration *= Options().GetDecoctionDurationMult();
			
			if( IsMeditating() )
				duration *= 1.1f;
		}
		else
		{
			if( Options().GetGlobalPotionDuration() )
				duration = Options().GetGlobalPotionDuration();
			else
			if( Options().GetMinimumPotionDuration() )
				duration += Options().GetMinimumPotionDuration();
			
			if( Options().GetPotionDurationMult() && !isDecoction )
				duration *= Options().GetPotionDurationMult();
			
			if( IsMeditating() )
				duration *= 1.2f;
				
			//Kolaris - Saturation
			duration *= 1.f + 0.2f * GetSkillLevel(S_Alchemy_s04);
			
			//Kolaris - Assimilation
			duration *= 1.f + CalculateAttributeValue(GetAttributeValue('potion_duration_bonus'));
		}
		
		skillPassiveMod = CalculateAttributeValue(GetAttributeValue('potion_duration'));		
		if( isDecoction )
		{
			if (CanUseSkill(S_Alchemy_s14) )
			{
				val = GetSkillAttributeValue(S_Alchemy_s14, 'duration', false, true);
				mutagenSkillMod = val.valueMultiplicative * GetSkillLevel(S_Alchemy_s14);
				duration *= (1 + mutagenSkillMod);
			}
		}
		else
			duration = duration * (1 + skillPassiveMod);
		// W3EE - End

		//Kolaris - Netflix Set
		/*if( IsSetBonusActive( EISB_Netflix_1 ) )
		{
			duration += (duration * (amountOfSetPiecesEquipped[ EIST_Netflix ] * 7 )) / 100 ;
		}*/

		return duration;
	}
	
	// W3EE - Begin
	public function ToxicityLowEnoughToDrinkPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId ) : bool
	{
		var item 				: SItemUniqueId;
		// var maxTox 				: float;
		// var potionToxicity 		: float;
		var toxicityOffset 		: float;
		var effectType 			: EEffectType;
		var customAbilityName 	: name;
		
		if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];
		
		inv.GetPotionItemBuffData(item, effectType, customAbilityName);
		
		return HasFreeToxicityToDrinkPotion(item, effectType, toxicityOffset);
	}
	
	public function GetFinalPotionToxicity( finalPotionToxicity : float ) : float
	{
		var i : int;
		var buffs : array<CBaseGameplayEffect>;
		
		buffs = GetPotionBuffs();
		
		if( finalPotionToxicity > 0.f )
		{
			for(i=0; i<buffs.Size(); i+=1)
			{
				//Kolaris - Decoction Toxicity
				if( /*(W3Potion_GoldenOriole)buffs[i] ||*/ buffs[i].IsDecoctionEffect() )
					continue;
					
				//Kolaris - Purification & Alchemical Refinement
				if(  GetSkillLevel(S_Alchemy_s02) > 0 )
					finalPotionToxicity *= 1.25f - (GetSkillLevel(S_Alchemy_s02) * 0.05f);
				else
					finalPotionToxicity *= 1.25f;
			}
			//Kolaris - Saturation
			finalPotionToxicity *= 1.f + 0.1f * GetSkillLevel(S_Alchemy_s04);
			//Kolaris - Toxicity Multiplier Option
			finalPotionToxicity *= Options().GetToxicityMultiplier();
		}
		
		return finalPotionToxicity;
		
	}
	
	public final function HasFreeToxicityToDrinkPotion( item : SItemUniqueId, effectType : EEffectType, out finalPotionToxicity : float ) : bool
	{
		var i : int;
		var maxTox, toxicityOffset, adrenaline : float;
		var costReduction, toxicity : SAbilityAttributeValue;
		
		if( effectType == EET_WhiteHoney )
		{
			return true;
		}
		
		maxTox = abilityManager.GetStatMax(BCS_Toxicity);
		toxicity = inv.GetItemAttributeValue(item, 'toxicity');
		if( /*effectType == EET_GoldenOriole ||*/ inv.ItemHasTag(item, 'Decoction') )
			finalPotionToxicity = toxicity.valueAdditive;
		else
			finalPotionToxicity = GetFinalPotionToxicity(toxicity.valueAdditive);
			
		toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
		//Kolaris - Decoction Toxicity
		if( inv.ItemHasTag(item, 'Decoction') )
			finalPotionToxicity -= 5 * GetSkillLevel(S_Alchemy_s14);
		/*else
			finalPotionToxicity *= 1.f + 0.1f * GetSkillLevel(S_Alchemy_s04);*/
		
		//Kolaris - Toxicity Rework
		/*if(abilityManager.GetStat(BCS_Toxicity, false) + finalPotionToxicity + toxicityOffset > maxTox )
		{
			return false;
		}*/
		
		return true;
	}
	// W3EE - End
	
	public function DrinkPreparedPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId )
	{	
		var potParams : W3PotionParams;
		var potionParams : SCustomEffectParams;
		var factPotionParams : W3Potion_Fact_Params;
		var adrenaline, hpGainValue, duration, finalPotionToxicity : float;
		var ret : EEffectInteract;
		var effectType : EEffectType;
		var item : SItemUniqueId;
		//Kolaris - Netflix Set
		var customAbilityName, netflixAbilityName, factId : name;
		var atts : array<name>;
		var i : int;
		// W3EE - Begin
		var toxicity : W3Effect_Toxicity;
		// W3EE - End
		
		
		if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];
			
		if(!inv.IsIdValid(item))
			return;
			
		if( inv.SingletonItemGetAmmo(item) <= 0 )
			return;
		
		inv.GetPotionItemBuffData(item, effectType, customAbilityName);
		
		//Kolaris - Netflix Set
		if(IsSetBonusActive(EISB_Netflix_2) && (effectManager.GetPotionBuffsCount() == 0 || (HasDecoctionEffect() && effectManager.GetPotionBuffsCount() == 1)) )
		{
			if( inv.ItemHasTag(item, 'Decoction') )
				netflixAbilityName = Equipment().GetNetflixDecoctionAbility(inv.GetItemName(item));
			else
				netflixAbilityName = Equipment().GetNetflixPotionAbility(customAbilityName);
			
			if( netflixAbilityName != '')
			{
				inv.AddItemBaseAbility(item, netflixAbilityName);
				customAbilityName = netflixAbilityName;
			}
		}
		
		if( inv.ItemHasTag(item, 'Decoction') && HasDecoctionEffect() )
		{
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("W3EE_DecoctionActive"), 2000.f, true);
			return;
		}
		
		if( !HasFreeToxicityToDrinkPotion( item, effectType, finalPotionToxicity ) )
		{
			return;
		}
		
		if(effectType == EET_Fact)
		{
			inv.GetItemAttributes(item, atts);
			
			for(i=0; i<atts.Size(); i+=1)
			{
				if(StrBeginsWith(NameToString(atts[i]), "fact_"))
				{
					factId = atts[i];
					break;
				}
			}
			
			factPotionParams = new W3Potion_Fact_Params in theGame;
			factPotionParams.factName = factId;
			factPotionParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = factPotionParams;
		}
		else
		{
			potParams = new W3PotionParams in theGame;
			potParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = potParams;
		}
	
		
		duration = CalculatePotionDuration(item, inv.ItemHasTag( item, 'Decoction' ));		

		potionParams.effectType = effectType;
		potionParams.creator = this;
		potionParams.sourceName = "drank_potion";
		potionParams.duration = duration;
		potionParams.customAbilityName = customAbilityName;
		ret = AddEffectCustom(potionParams);

		
		if(factPotionParams)
			delete factPotionParams;
			
		Experience().AwardAlchemyUsageXP(inv.IsItemMutagenPotion(item), inv.IsItemPotion(item), inv.IsItemOil(item), inv.IsItemBomb(item));
		
		// W3EE - Begin
		Alchemy().AddSecondarySubstanceEffects(item);
		//Kolaris - Mutation 11
		if( !IsMutationActive(EPMT_Mutation11) )
		{
			inv.SingletonItemRemoveAmmo(item);
			inv.AddAnItem('Empty vial', 1);
		}
		// W3EE - End
		
		if(ret == EI_Pass || ret == EI_Override || ret == EI_Cumulate)
		{
			// W3EE - Begin
			if( finalPotionToxicity > 0.f )
			{
				abilityManager.GainStat(BCS_Toxicity, finalPotionToxicity / duration);
			}
			else
			if( effectType == EET_WhiteHoney )
			{
				abilityManager.DrainToxicity(finalPotionToxicity * -1.f);
			}
			
			toxicity = (W3Effect_Toxicity)GetBuff(EET_Toxicity);
			if( toxicity )
				toxicity.AddToxicityEntry(effectType, finalPotionToxicity, duration);
				
			/*if(CanUseSkill(S_Perk_13))
			{
				abilityManager.DrainFocus(adrenaline);
			}*/
			// W3EE - End
			
			if (!IsEffectActive('invisible'))
			{
				PlayEffect('use_potion');
			}
			
			if ( inv.ItemHasTag( item, 'Decoction' ) )
			{
				
				theGame.GetGamerProfile().CheckTrialOfGrasses();
				
				
				SetFailedFundamentalsFirstAchievementCondition(true);
			}
			
			// W3EE - Begin
			//Kolaris - Coagulation
			if(CanUseSkill(S_Alchemy_s03) && !(effectType == EET_WhiteHoney))
			{
				hpGainValue = ClampF(GetStatMax(BCS_Vitality) * 0.04f * GetSkillLevel(S_Alchemy_s03), 0, GetStatMax(BCS_Vitality));
				GainStat(BCS_Vitality, hpGainValue);
			}			
			
			/*
			if(CanUseSkill(S_Alchemy_s04) && !skillBonusPotionEffect && (RandF() < CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s04, 'apply_chance', false, true)) * GetSkillLevel(S_Alchemy_s04)))
			{
				AddRandomPotionEffectFromAlch4Skill( effectType );				
			}
			*/
			// W3EE - End
			
			theGame.GetGamerProfile().SetStat(ES_ActivePotions, effectManager.GetPotionBuffsCount());
		}
		
		theTelemetry.LogWithLabel(TE_ELIXIR_USED, inv.GetItemName(item));
		
		GetPoiseEffect().UpdateMaxPoise();
		
		if(ShouldProcessTutorial('TutorialPotionAmmo'))
		{
			FactsAdd("tut_used_potion");
		}
		
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
	
	
	private final function AddRandomPotionEffectFromAlch4Skill( currentlyDrankPotion : EEffectType )
	{
		var randomPotions : array<EEffectType>;
		var currentPotion : CBaseGameplayEffect;
		var effectsOld, effectsNew : array<CBaseGameplayEffect>;
		var i, ind : int;
		var duration : float;
		var params : SCustomEffectParams;
		var ret : EEffectInteract;
		
		
		randomPotions.PushBack( EET_BlackBlood );
		randomPotions.PushBack( EET_Blizzard );
		randomPotions.PushBack( EET_FullMoon );
		randomPotions.PushBack( EET_GoldenOriole );
		randomPotions.PushBack( EET_MariborForest );
		randomPotions.PushBack( EET_PetriPhiltre );
		randomPotions.PushBack( EET_Swallow );
		randomPotions.PushBack( EET_TawnyOwl );
		randomPotions.PushBack( EET_Thunderbolt );
		
		
		randomPotions.Remove( currentlyDrankPotion );
		
		
		ind = RandRange( randomPotions.Size() );

		
		if( HasBuff( randomPotions[ ind ] ) )
		{
			currentPotion = GetBuff( randomPotions[ ind ] );
			currentPotion.SetTimeLeft( currentPotion.GetInitialDurationAfterResists() );
		}
		
		else
		{			
			duration = BonusPotionGetDurationFromXML( randomPotions[ ind ] );
			
			if(duration > 0)
			{
				effectsOld = GetCurrentEffects();
									
				params.effectType = randomPotions[ ind ];
				params.creator = this;
				params.sourceName = SkillEnumToName( S_Alchemy_s04 );
				params.duration = duration;
				ret = AddEffectCustom( params );
				
				
				if( ret != EI_Undefined && ret != EI_Deny )
				{
					effectsNew = GetCurrentEffects();
					
					ind = -1;
					for( i=effectsNew.Size()-1; i>=0; i-=1)
					{
						if( !effectsOld.Contains( effectsNew[i] ) )
						{
							ind = i;
							break;
						}
					}
					
					if(ind > -1)
					{
						skillBonusPotionEffect = effectsNew[ind];
					}
				}
			}		
		}
	}
	
	
	private function BonusPotionGetDurationFromXML(type : EEffectType) : float
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName, typeName, itemName : name;
		var abs : array<name>;
		var min, max : SAbilityAttributeValue;
		var tmpInt : int;
		var temp 								: array<float>;
		var i, temp2, temp3 : int;
						
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');
		typeName = EffectTypeToName(type);
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
			{
				
				if(tmpName == typeName)
				{
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
					{
						
						if(tmpInt == 1)
						{
							if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', itemName))
							{
								
								if(IsNameValid(itemName))
								{
									break;
								}
							}
						}
					}
				}
			}
		}
		
		if(!IsNameValid(itemName))
			return 0;
		
		
		dm.GetItemAbilitiesWithWeights(itemName, true, abs, temp, temp2, temp3);
		dm.GetAbilitiesAttributeValue(abs, 'duration', min, max);						
		return CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	
	public function ClearSkillBonusPotionEffect()
	{
		skillBonusPotionEffect = NULL;
	}
	
	public function GetSkillBonusPotionEffect() : CBaseGameplayEffect
	{
		return skillBonusPotionEffect;
	}
	
	
	
	
	
	
	
	public final function HasRunewordActive(abilityName : name) : bool
	{
		var item : SItemUniqueId;
		var hasRuneword : bool;
		
		if(GetItemEquippedOnSlot(EES_SteelSword, item))
		{
			hasRuneword = inv.ItemHasAbility(item, abilityName);				
		}
		
		if(!hasRuneword)
		{
			if(GetItemEquippedOnSlot(EES_SilverSword, item))
			{
				hasRuneword = inv.ItemHasAbility(item, abilityName);
			}
		}
		
		return hasRuneword;
	}
	
	public final function GetShrineBuffs() : array<CBaseGameplayEffect>
	{
		var null : array<CBaseGameplayEffect>;
		
		if(effectManager && effectManager.IsReady())
			return effectManager.GetShrineBuffs();
			
		return null;
	}
	
	// W3EE - Begin
	event OnHolsteredItem( category :  name, slotName : name )
	{
		if( slotName == 'r_weapon' )
		{
			if( category == 'steelsword' )
				PauseRepairBuffs(GetEquippedSword(true));
			//Kolaris - Bugfix
			else if ( category == 'silversword' )
				PauseRepairBuffs(GetEquippedSword(false));
		}
		
		super.OnHolsteredItem(category, slotName);
	}
	
	private function GetEnhancementsOnItem( item : SItemUniqueId ) : array<W3RepairObjectEnhancement>
	{
		var buffs : array<CBaseGameplayEffect>;
		var buff : W3RepairObjectEnhancement;
		var ret : array<W3RepairObjectEnhancement>;
		var i : int;
		
		if( inv.IsItemAnyArmor(item) )
		{
			buffs = GetBuffs(EET_EnhancedArmor, inv.GetItemName(item));
			for(i=0; i<buffs.Size(); i+=1)
			{
				buff = (W3RepairObjectEnhancement)buffs[i];
				if( buff.GetItemID() == item )
					ret.PushBack(buff);
			}
		}
		else
		if( inv.IsItemWeapon(item) )
		{
			buffs = GetBuffs(EET_EnhancedWeapon, inv.GetItemName(item));
			for(i=0; i<buffs.Size(); i+=1)
			{
				buff = (W3RepairObjectEnhancement)buffs[i];
				if( buff.GetItemID() == item )
					ret.PushBack(buff);
			}
		}
		
		return ret;
	}
	
	public final function ManageRepairBuffs( action : W3Action_Attack, weaponId : SItemUniqueId, isHeavyAttack : bool )
	{
		var buffs : array<W3RepairObjectEnhancement>;
		var weapons : array<SItemUniqueId>;
		//Kolaris - Fixative
		var oils : array<W3Effect_Oil>;
		var oilPercent : float;
		var armorId : SItemUniqueId;
		var i, j : int;
		
		if( action.IsDoTDamage() || !action.DealsAnyDamage() )
			return;
			
		if( action.victim == this )
		{
			if( action.IsActionMelee() || action.IsActionRanged() )
			{
				if( action.IsParried() || action.IsCountered() )
				{
					weapons = inv.GetHeldWeapons();
					for(i=0; i<weapons.Size(); i+=1)
					{
						if( inv.IsIdValid(weapons[i]) && (inv.IsItemSteelSwordUsableByPlayer(weapons[i]) || inv.IsItemSilverSwordUsableByPlayer(weapons[i])) )
						{
							//Kolaris - Fixative
							oilPercent = 0.f;
							oils = inv.GetOilsAppliedOnItem( weaponId );
							for(j=0; j<oils.Size(); j+=1)
							{
								if(oils[j].GetAmmoPercentage() > oilPercent)
									oilPercent = oils[j].GetAmmoPercentage();
							}
							buffs = GetEnhancementsOnItem(weapons[i]);
							for(j=0; j<buffs.Size(); j+=1)
								buffs[j].ReduceAmmo(isHeavyAttack, oilPercent);
								
							break;
						}
					}
				}
				else
				{
					if( GetItemEquippedOnSlot(EES_Armor, armorId) )
					{
						buffs = GetEnhancementsOnItem(armorId);
						for(i=0; i<buffs.Size(); i+=1)
							buffs[i].ReduceAmmo(isHeavyAttack);
					}
				}
			}
		}
		else
		{
			if( action.IsActionMelee() )
			{
				//Kolaris - Fixative
				oilPercent = 0.f;
				oils = inv.GetOilsAppliedOnItem( weaponId );
				for(i=0; i<oils.Size(); i+=1)
				{
					if(oils[i].GetAmmoPercentage() > oilPercent)
						oilPercent = oils[i].GetAmmoPercentage();
				}
				buffs = GetEnhancementsOnItem(weaponId);
				for(i=0; i<buffs.Size(); i+=1)
					buffs[i].ReduceAmmo(isHeavyAttack, oilPercent);
			}
		}
	}
	
	public final function ResumeRepairBuffs( item : SItemUniqueId )
	{
		var buffs : array<W3RepairObjectEnhancement>;
		var i : int;
		
		buffs = GetEnhancementsOnItem(item);
		for(i=0; i<buffs.Size(); i+=1)
			buffs[i].Resume('');
	}
	
	public final function PauseRepairBuffs( item : SItemUniqueId )
	{
		var buffs : array<W3RepairObjectEnhancement>;
		var i : int;
		
		buffs = GetEnhancementsOnItem(item);
		for(i=0; i<buffs.Size(); i+=1)
			buffs[i].Pause('', true);
	}
	
	public final function RemoveRepairBuffs( item : SItemUniqueId )
	{
		var buffs : array<W3RepairObjectEnhancement>;
		var i : int;
		
		buffs = GetEnhancementsOnItem(item);
		for(i=0; i<buffs.Size(); i+=1)
			RemoveEffect(buffs[i]);
	}
	
	public final function RemoveAllRepairBuffs()
	{
		var buffs : array<CBaseGameplayEffect>;
		var i : int;
		
		buffs = GetBuffs(EET_EnhancedWeapon);
		for(i=0; i<buffs.Size(); i+=1)
			RemoveEffect(buffs[i]);
			
		buffs = GetBuffs(EET_EnhancedArmor);
		for(i=0; i<buffs.Size(); i+=1)
			RemoveEffect(buffs[i]);
	}
	
	public final function AddRepairObjectBuff( armor : bool, weapon : bool ) : bool
	{
		var effect : SCustomEffectParams;
		var effectParams : W3EnhanceBuffParams;
		var steel, silver : SItemUniqueId;
		var added : bool = false;
		
		if( weapon )
		{
			effect.effectType = EET_EnhancedWeapon;
			effect.creator = this;
			if( GetItemEquippedOnSlot(EES_SilverSword, silver) )
			{
				effectParams = new W3EnhanceBuffParams in this;
				effectParams.item = silver;
				effect.sourceName = inv.GetItemName(silver);
				effect.buffSpecificParams = effectParams;
				AddEffectCustom(effect);
				delete effectParams;
				added = true;
				if( !inv.IsItemHeld(silver) )
					PauseRepairBuffs(silver);
			}
			
			if( GetItemEquippedOnSlot(EES_SteelSword, steel) )
			{
				effectParams = new W3EnhanceBuffParams in this;
				effectParams.item = steel;
				effect.sourceName = inv.GetItemName(steel);
				effect.buffSpecificParams = effectParams;
				AddEffectCustom(effect);
				delete effectParams;
				added = true;
				if( !inv.IsItemHeld(steel) )
					PauseRepairBuffs(steel);
			}
		}
		else
		if( armor )
		{
			effect.effectType = EET_EnhancedArmor;
			effect.creator = this;
			if( GetItemEquippedOnSlot(EES_Armor, steel) )
			{
				effectParams = new W3EnhanceBuffParams in this;
				effectParams.item = steel;
				effect.sourceName = inv.GetItemName(steel);
				effect.buffSpecificParams = effectParams;
				AddEffectCustom(effect);
				delete effectParams;
				added = true;
			}
		}
		
		return added;
	}
	// W3EE - End
	
	public function StartCSAnim(buff : CBaseGameplayEffect) : bool
	{
		
		if(IsAnyQuenActive() && (W3CriticalDOTEffect)buff)
			return false;
			
		return super.StartCSAnim(buff);
	}
	
	public function GetPotionBuffLevel(effectType : EEffectType) : int
	{
		if(effectManager && effectManager.IsReady())
			return effectManager.GetPotionBuffLevel(effectType);
			
		return 0;
	}	

	
	
	
	
	
	
	event OnLevelGained(currentLevel : int, show : bool)
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(abilityManager && abilityManager.IsInitialized())
		{
			((W3PlayerAbilityManager)abilityManager).OnLevelGained(currentLevel);
		}
		
		// W3EE - Begin
		/*
		if ( theGame.GetDifficultyMode() != EDM_Hardcore ) 
		{
			Heal(GetStatMax(BCS_Vitality));
		} 
		*/
		// W3EE - End
		
		if(currentLevel >= 35)
		{
			theGame.GetGamerProfile().AddAchievement(EA_Immortal);
		}
		else
		{
			theGame.GetGamerProfile().NoticeAchievementProgress(EA_Immortal, currentLevel);
		}
	
		if ( hud && currentLevel < levelManager.GetMaxLevel() && FactsQuerySum( "DebugNoLevelUpUpdates" ) == 0 )
		{
			hud.OnLevelUpUpdate(currentLevel, show);
		}
		
		theGame.RequestAutoSave( "level gained", false );
	}
	
	public function GetSignStats(skill : ESkill, out damageType : name, out damageVal : float, out spellPower : SAbilityAttributeValue)
	{
		var i, size : int;
		var dm : CDefinitionsManagerAccessor;
		var attrs : array<name>;
	
		spellPower = GetPowerStatValue(CPS_SpellPower);
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(GetSkillAbilityName(skill), attrs);
		size = attrs.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( IsDamageTypeNameValid(attrs[i]) )
			{
				damageVal = CalculateAttributeValue(GetSkillAttributeValue(skill, attrs[i], false, true));
				damageType = attrs[i];
				break;
			}
		}
	}
		
	
	public function SetIgnorePainMaxVitality(val : float)
	{
		if(abilityManager && abilityManager.IsInitialized())
			abilityManager.SetStatPointMax(BCS_Vitality, val);
	}
	
	event OnAnimEvent_ActionBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart && !disableActionBlend )
		{
			if ( this.IsCastingSign() )
				ProcessSignEvent( 'cast_end' );
			
			
			FindMoveTarget();
			SetCanPlayHitAnim( true );
			this.SetBIsCombatActionAllowed( true );
			
			if ( this.GetFinisherVictim() && this.GetFinisherVictim().HasAbility( 'ForceFinisher' ) && !isInFinisher )
			{
				this.GetFinisherVictim().SignalGameplayEvent( 'Finisher' );
			}
			else if (this.BufferCombatAction != EBAT_EMPTY )
			{
				
				
					
					if ( !IsCombatMusicEnabled() )
					{
						SetCombatActionHeading( ProcessCombatActionHeading( this.BufferCombatAction ) ); 
						FindTarget();
						UpdateDisplayTarget( true );
					}
			
					if ( AllowAttack( GetTarget(), this.BufferCombatAction ) )
						this.ProcessCombatActionBuffer();
			}
			else
			{
				
				ResumeStaminaRegen( 'InsideCombatAction' );
				
				
				
			}
		}
		else if ( disableActionBlend )
		{
			disableActionBlend = false;
		}
	}
	
	
	event OnAnimEvent_Sign( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_Tick )
		{
			ProcessSignEvent( animEventName );
		}
	}
	
	event OnAnimEvent_Throwable( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var thrownEntity		: CThrowable;	
		
		thrownEntity = (CThrowable)EntityHandleGet( thrownEntityHandle );
			
		if ( inv.IsItemCrossbow( inv.GetItemFromSlot('l_weapon') ) &&  rangedWeapon.OnProcessThrowEvent( animEventName ) )
		{		
			return true;
		}
		else if( thrownEntity && IsThrowingItem() && thrownEntity.OnProcessThrowEvent( animEventName ) )
		{
			return true;
		}
	}
	
	event OnTaskSyncAnim( npc : CNewNPC, animNameLeft : name )
	{
		var tmpBool : bool;
		var tmpName : name;
		var damage, points, resistance : float;
		var min, max : SAbilityAttributeValue;
		var mc : EMonsterCategory;
		
		super.OnTaskSyncAnim( npc, animNameLeft );
		//Kolaris ++ Mutation Rework
		/*if( animNameLeft == 'BruxaBite' && IsMutationActive( EPMT_Mutation4 ) )
		{
			theGame.GetMonsterParamsForActor( npc, mc, tmpName, tmpBool, tmpBool, tmpBool );
			
			if( mc == MC_Vampire )
			{
				GetResistValue( CDS_BleedingRes, points, resistance );
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'DirectDamage', min, max );
				damage = MaxF( 0.f, max.valueMultiplicative * GetMaxHealth() - points );
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'duration', min, max );
				damage *= min.valueAdditive * ( 1 - MinF( 1.f, resistance ) );
				
				if( damage > 0.f )
				{
					npc.AddAbility( 'Mutation4BloodDebuff' );
					ProcessActionMutation4ReturnedDamage( damage, npc, EAHA_ForceNo );					
					npc.AddTimer( 'RemoveMutation4BloodDebuff', 15.f, , , , , true );
				}
			}
		}*/
		//Kolaris -- Mutation Rework
	}
	
	
	public function ProcessActionMutation4ReturnedDamage( damageDealt : float, attacker : CActor, hitAnimationType : EActionHitAnim, optional action : W3DamageAction ) : bool
	{
		var customParams				: SCustomEffectParams;
		var currToxicity				: float;
		var min, max, customDamageValue	: SAbilityAttributeValue;
		var dm							: CDefinitionsManagerAccessor;
		var animAction					: W3DamageAction;

		if( damageDealt <= 0 )
		{
			return false;
		}
		
		if( action )
		{
			action.SetMutation4Triggered();
		}
			
		// W3EE - Begin
		dm = theGame.GetDefinitionsManager();
		currToxicity = GetStatPercents( BCS_Toxicity );
		
		dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
		//customDamageValue.valueAdditive = damageDealt * min.valueAdditive;
		
		/*if( currToxicity > 0 )
		{*/
			customDamageValue.valueAdditive = MaxF(5.f, currToxicity * GetStat(BCS_Vitality) * 0.5f);
		//}
		// W3EE - End
		
		dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
		customDamageValue.valueAdditive /= min.valueAdditive; 
		
		customParams.effectType = EET_Acid;
		customParams.effectValue = customDamageValue;
		customParams.duration = min.valueAdditive;
		customParams.creator = this;
		customParams.sourceName = 'Mutation4';
		
		attacker.AddEffectCustom( customParams );
		attacker.ApplyPoisoning(2, this, "Mutation4", true);
		
		animAction = new W3DamageAction in theGame;
		animAction.Initialize( this, attacker, NULL, 'Mutation4', EHRT_Reflect, CPS_Undefined, true, false, false, false );
		animAction.SetCannotReturnDamage( true );
		animAction.SetCanPlayHitParticle( false );
		animAction.SetHitAnimationPlayType( hitAnimationType );
		theGame.damageMgr.ProcessAction( animAction );
		delete animAction;
		
		theGame.MutationHUDFeedback( MFT_PlayOnce );
		
		return true;
	}
	
	event OnPlayerActionEnd()
	{
		var l_i				: int;
		var l_bed			: W3WitcherBed;
		
		l_i = (int)GetBehaviorVariable( 'playerExplorationAction' );
		
		if( l_i == PEA_GoToSleep )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			BlockAllActions( 'WitcherBed', false );
			l_bed.ApplyAppearance( "collision" );
			l_bed.GotoState( 'WakeUp' );
			theGame.ReleaseNoSaveLock( l_bed.m_bedSaveLock );
			
			
			substateManager.m_MovementCorrectorO.disallowRotWhenGoingToSleep = false;
		}
		
		super.OnPlayerActionEnd();
	}
	
	event OnPlayerActionStartFinished()
	{
		var l_initData			: W3SingleMenuInitData;		
		var l_i					: int;
		
		l_i = (int)GetBehaviorVariable( 'playerExplorationAction' );
		
		if( l_i == PEA_GoToSleep )
		{
			l_initData = new W3SingleMenuInitData in this;
			l_initData.SetBlockOtherPanels( true );
			l_initData.ignoreSaveSystem = true;
			l_initData.ignoreMeditationCheck = true;
			l_initData.setDefaultState( '' );
			l_initData.isBonusMeditationAvailable = true;
			l_initData.fixedMenuName = 'MeditationClockMenu';
			
			theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu', l_initData );
		}
		
		super.OnPlayerActionStartFinished();
	}
	
	public function IsInCombatAction_SpecialAttack() : bool
	{
		if ( IsInCombatAction() && ( GetCombatAction() == EBAT_SpecialAttack_Light || GetCombatAction() == EBAT_SpecialAttack_Heavy ) )
			return true;
		else
			return false;
	}
	
	public function IsInCombatAction_SpecialAttackLight() : bool
	{
		if ( IsInCombatAction() && GetCombatAction() == EBAT_SpecialAttack_Light )
			return true;
		else
			return false;
	}
	
	public function IsInCombatAction_SpecialAttackHeavy() : bool
	{
		if ( IsInCombatAction() && GetCombatAction() == EBAT_SpecialAttack_Heavy )
			return true;
		else
			return false;
	}
	
	protected function WhenCombatActionIsFinished()
	{
		super.WhenCombatActionIsFinished();
		RemoveTimer( 'ProcessAttackTimer' );
		RemoveTimer( 'AttackTimerEnd' );
		CastSignAbort();
		specialAttackCamera = false;
		this.OnPerformSpecialAttack( true, false );
	}
	
	// W3EE - Begin
	private var isCurrentlyRolling : bool;
	public function SetIsCurrentlyDodging( enable : bool, optional isRolling : bool )
	{
		isCurrentlyRolling = isRolling;
		super.SetIsCurrentlyDodging(enable, isRolling);
	}

	event OnCombatActionStart()
	{
		var combatActionType : float = GetBehaviorVariable('combatActionType', -1);
		
		if( (combatActionType >= 0 && combatActionType <= 3) || combatActionType == 9 )
		{
			Combat().GetActionType();
			Combat().CombatSpeedModule();
		}
		
		super.OnCombatActionStart();
	}
	
	event OnCombatActionEnd()
	{
		ResetDodgeState();
		isCurrentlyRolling = false;
		Combat().RemovePlayerSpeedMult();
		ResetCustomAnimationSpeedMult();
		//RemoveCustomOrientationTarget('Signs');
		
		CleanCombatActionBuffer();		
		super.OnCombatActionEnd();
		
		RemoveTemporarySkills();
	}
	// W3EE - End
	
	event OnCombatActionFriendlyEnd()
	{
		if ( IsCastingSign() )
		{
			SetBehaviorVariable( 'IsCastingSign', 0 );
			SetCurrentlyCastSign( ST_None, NULL );
			LogChannel( 'ST_None', "ST_None" );					
		}

		super.OnCombatActionFriendlyEnd();
	}
	
	public function GetPowerStatValue( stat : ECharacterPowerStats, optional ablName : name, optional ignoreDeath : bool ) : SAbilityAttributeValue
	{
		var result :  SAbilityAttributeValue;
		
		
		result = super.GetPowerStatValue( stat, ablName, ignoreDeath );
		//ApplyMutation10StatBoost( result ); //Kolaris - Mutation 10
		
		return result;
	}
	
	
	
	timer function OpenRadialMenu( time: float, id : int )
	{
		
		if( GetBIsCombatActionAllowed() && !IsUITakeInput() )
		{
			bShowRadialMenu = true;
		}
		
		this.RemoveTimer('OpenRadialMenu');
	}
	
	public function OnAddRadialMenuOpenTimer(  )
	{
		
		
		
		    
		    
			this.AddTimer('OpenRadialMenu', _HoldBeforeOpenRadialMenuTime * theGame.GetTimeScale() );
		
	}

	public function SetShowRadialMenuOpenFlag( bSet : bool  )
	{
		
		bShowRadialMenu = bSet;
	}
	
	public function OnRemoveRadialMenuOpenTimer()
	{
		
		this.RemoveTimer('OpenRadialMenu');
	}
	
	public function ResetRadialMenuOpenTimer()
	{
		
		this.RemoveTimer('OpenRadialMenu');
		if( GetBIsCombatActionAllowed() )
		{
		    
		    
			AddTimer('OpenRadialMenu', _HoldBeforeOpenRadialMenuTime * theGame.GetTimeScale() );
		}
	}

	
	
	timer function ResendCompanionDisplayName(dt : float, id : int)
	{
		var hud : CR4ScriptedHud;
		var companionModule : CR4HudModuleCompanion;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			companionModule = (CR4HudModuleCompanion)hud.GetHudModule("CompanionModule");
			if( companionModule )
			{
				companionModule.ResendDisplayName();
			}
		}
	}

	timer function ResendCompanionDisplayNameSecond(dt : float, id : int)
	{
		var hud : CR4ScriptedHud;
		var companionModule : CR4HudModuleCompanion;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			companionModule = (CR4HudModuleCompanion)hud.GetHudModule("CompanionModule");
			if( companionModule )
			{
				companionModule.ResendDisplayNameSecond();
			}
		}
	}
	
	public function RemoveCompanionDisplayNameTimer()
	{
		this.RemoveTimer('ResendCompanionDisplayName');
	}
		
	public function RemoveCompanionDisplayNameTimerSecond()
	{
		this.RemoveTimer('ResendCompanionDisplayNameSecond');
	}
	
		
	public function GetCompanionNPCTag() : name
	{
		return companionNPCTag;
	}

	public function SetCompanionNPCTag( value : name )
	{
		companionNPCTag = value;
	}	

	public function GetCompanionNPCTag2() : name
	{
		return companionNPCTag2;
	}

	public function SetCompanionNPCTag2( value : name )
	{
		companionNPCTag2 = value;
	}

	public function GetCompanionNPCIconPath() : string
	{
		return companionNPCIconPath;
	}

	public function SetCompanionNPCIconPath( value : string )
	{
		companionNPCIconPath = value;
	}

	public function GetCompanionNPCIconPath2() : string
	{
		return companionNPCIconPath2;
	}

	public function SetCompanionNPCIconPath2( value : string )
	{
		companionNPCIconPath2 = value;
	}
	
	

	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
	{
		var chance : float;
		var procQuen : W3SignEntity;
		
		if(!damageAction.IsDoTDamage() && damageAction.DealsAnyDamage())
		{
			if(inv.IsItemBomb(selectedItemId))
			{
				BombThrowAbort();
			}
			else
			{
				
				ThrowingAbort();
			}			
		}		
		
		// W3EE - Begin
		if(damageAction.IsActionRanged())
		{
			chance = CalculateAttributeValue(GetAttributeValue('quen_chance_on_projectile'));
			if(chance > 0)
			{
				chance = ClampF(chance, 0, 1);
				
				if(RandF() < chance)
				{
					procQuen = (W3QuenEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
					procQuen.Init(signOwner, signs[ST_Quen].entity, true );
					procQuen.OnStarted();
					procQuen.OnThrowing();
					procQuen.OnEnded();
				}
			}
		}
		
		
		if( !damageAction.IsDoTDamage() )
			MeditationForceAbort(true);
		// W3EE - End
		
		
		if(IsDoingSpecialAttack(false))
			damageAction.SetHitAnimationPlayType(EAHA_ForceNo);
		
		return super.ReactToBeingHit(damageAction, buffNotApplied);
	}
	
	protected function ShouldPauseHealthRegenOnHit() : bool
	{
		// W3EE - Begin
		//Kolaris - Swallow
		if( HasBuff( EET_WhiteRaffardDecoction ) /*|| HasBuff( EET_Runeword8 )*/ || HasBuff( EET_Mutation11Buff ) )
		// W3EE - End
		{
			return false;
		}
			
		return true;
	}
		
	public function SetMappinToHighlight( mappinName : name, mappinState : bool )
	{
		var mappinDef : SHighlightMappin;
		mappinDef.MappinName = mappinName;
		mappinDef.MappinState = mappinState;
		MappinToHighlight.PushBack(mappinDef);
	}	

	public function ClearMappinToHighlight()
	{
		MappinToHighlight.Clear();
	}
	
	public function CastSignAbort()
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
		{
			signs[currentlyCastSign].entity.OnSignAborted();
		}
		
		
	}
	
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		var med : W3PlayerWitcherStateMeditationWaiting;
				
		
		med = (W3PlayerWitcherStateMeditationWaiting)GetCurrentState();
		if(med)
		{
			med.StopRequested(true);
		}
		
		super.OnBlockingSceneStarted( scene );
	}
	
	
	
	
	
	public function GetHorseManager() : W3HorseManager
	{
		return (W3HorseManager)EntityHandleGet( horseManagerHandle );
	}
	
	
	public function HorseEquipItem(horsesItemId : SItemUniqueId) : bool
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.EquipItem(horsesItemId) != GetInvalidUniqueId();
			
		return false;
	}
	
	
	public function HorseUnequipItem(slot : EEquipmentSlots) : bool
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.UnequipItem(slot) != GetInvalidUniqueId();
			
		return false;
	}
	
	
	public final function HorseRemoveItemByName(itemName : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByName(itemName, quantity);
	}
	
	
	public final function HorseRemoveItemByCategory(itemCategory : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByCategory(itemCategory, quantity);
	}
	
	
	public final function HorseRemoveItemByTag(itemTag : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByTag(itemTag, quantity);
	}
	
	public function GetAssociatedInventory() : CInventoryComponent
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.GetInventoryComponent();
			
		return NULL;
	}
	
	
	
	
	
	public final function TutorialMutagensUnequipPlayerSkills() : array<STutorialSavedSkill>
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		return pam.TutorialMutagensUnequipPlayerSkills();
	}
	
	public final function TutorialMutagensEquipOneGoodSkill()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		pam.TutorialMutagensEquipOneGoodSkill();
	}
	
	public final function TutorialMutagensEquipOneGoodOneBadSkill()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
			pam.TutorialMutagensEquipOneGoodOneBadSkill();
	}
	
	public final function TutorialMutagensEquipThreeGoodSkills()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
			pam.TutorialMutagensEquipThreeGoodSkills();
	}
	
	public final function TutorialMutagensCleanupTempSkills(savedEquippedSkills : array<STutorialSavedSkill>)
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		return pam.TutorialMutagensCleanupTempSkills(savedEquippedSkills);
	}
	
	
	
	
	
	public final function CalculatedArmorStaminaRegenBonus() : float
	{
		// W3EE - Begin
		/*
		var armorEq, glovesEq, pantsEq, bootsEq : bool;
		var tempItem : SItemUniqueId;
		var staminaRegenVal : float;
		var armorRegenVal : SAbilityAttributeValue;
		
		if( HasAbility( 'Glyphword 2 _Stats', true ) )
		{
			armorEq = inv.GetItemEquippedOnSlot( EES_Armor, tempItem );
			glovesEq = inv.GetItemEquippedOnSlot( EES_Gloves, tempItem );
			pantsEq = inv.GetItemEquippedOnSlot( EES_Pants, tempItem );
			bootsEq = inv.GetItemEquippedOnSlot( EES_Boots, tempItem );
			
			if ( armorEq )
				staminaRegenVal += 0.1;
			if ( glovesEq )
				staminaRegenVal += 0.02;
			if ( pantsEq )
				staminaRegenVal += 0.1;
			if ( bootsEq )
				staminaRegenVal += 0.03;
			
		}
		else if( HasAbility( 'Glyphword 3 _Stats', true ) )
		{
			staminaRegenVal = 0;
		}
		else if( HasAbility( 'Glyphword 4 _Stats', true ) )
		{
			armorEq = inv.GetItemEquippedOnSlot( EES_Armor, tempItem );
			glovesEq = inv.GetItemEquippedOnSlot( EES_Gloves, tempItem );
			pantsEq = inv.GetItemEquippedOnSlot( EES_Pants, tempItem );
			bootsEq = inv.GetItemEquippedOnSlot( EES_Boots, tempItem );
			
			if ( armorEq )
				staminaRegenVal -= 0.1;
			if ( glovesEq )
				staminaRegenVal -= 0.02;
			if ( pantsEq )
				staminaRegenVal -= 0.1;
			if ( bootsEq )
				staminaRegenVal -= 0.03;
		}
		*/
		
		//W3EE old armor system
		/*
		if( HasAbility('Glyphword 9 _Stats', true) )
		{
			staminaRegenVal = 0;
			if( inv.GetItemEquippedOnSlot( EES_Armor, tempItem ) && inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.05;
			if( inv.GetItemEquippedOnSlot( EES_Gloves, tempItem ) && inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.01;
			if( inv.GetItemEquippedOnSlot( EES_Pants, tempItem ) && inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.05;
			if( inv.GetItemEquippedOnSlot( EES_Boots, tempItem ) && inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.015;
		}
		else
		{
			staminaRegenVal = 0;
			if( inv.GetItemEquippedOnSlot( EES_Armor, tempItem ) && inv.GetArmorType(tempItem) == EAT_Medium ) staminaRegenVal -= 0.05;
			else
			if( inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.1;
			
			if( inv.GetItemEquippedOnSlot( EES_Gloves, tempItem ) && inv.GetArmorType(tempItem) == EAT_Medium ) staminaRegenVal -= 0.01;
			else
			if( inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.02;
			
			if( inv.GetItemEquippedOnSlot( EES_Pants, tempItem ) && inv.GetArmorType(tempItem) == EAT_Medium ) staminaRegenVal -= 0.05;
			else
			if( inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.1;
			
			if( inv.GetItemEquippedOnSlot( EES_Boots, tempItem ) && inv.GetArmorType(tempItem) == EAT_Medium ) staminaRegenVal -= 0.015;
			else
			if( inv.GetArmorType(tempItem) == EAT_Heavy ) staminaRegenVal -= 0.03;
		}
		*/
		var attributeRegenPenalty : SAbilityAttributeValue;
		var staminaRegenVal : float;
				
		attributeRegenPenalty = GetAttributeValue('armor_regen_penalty');
		staminaRegenVal = attributeRegenPenalty.valueMultiplicative;
		
		//Kolaris - Remove Old Enchantments
		/*if( HasAbility('Glyphword 9 _Stats', true) )
			staminaRegenVal += 0.05;*/
			
		//Kolaris - Strong Back
		if( CanUseSkill(S_Perk_22) )
			staminaRegenVal *= 0.8f;
		
		//Kolaris - Elation
		staminaRegenVal *= 1.f - CalculateAttributeValue(GetAttributeValue('armor_penalty_bonus'));
		
		return staminaRegenVal;
		
		// W3EE - End
		
	}
	
	// W3EE - Begin
	public function GetOffenseStatsList( optional hackMode : int ) : SPlayerOffenseStats
	{
		var playerOffenseStats:SPlayerOffenseStats;
		var steelDmg, silverDmg, elementalSteel, elementalSilver : float;
		var steelCritChance, steelCritDmg : float;
		var silverCritChance, silverCritDmg : float;
		var attackPower	: SAbilityAttributeValue;
		var fastCritChance, fastCritDmg : float;
		var strongCritChance, strongCritDmg : float;
		var fastAP, strongAP, min, max : SAbilityAttributeValue;
		var item, crossbow : SItemUniqueId;
		var value : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		// var thunder : W3Potion_Thunderbolt;
		//Kolaris - Aerondight Tooltip
		var aerondightBuff : W3Effect_Aerondight;
		
		if(!abilityManager || !abilityManager.IsInitialized())
			return playerOffenseStats;
		
		/*if (CanUseSkill(S_Sword_s21))
			fastAP += GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s21); */
		if (CanUseSkill(S_Perk_05))
		{
			fastAP += GetAttributeValue('attack_power_fast_style');
			fastCritDmg += CalculateAttributeValue(GetAttributeValue('critical_hit_chance_fast_style'));
			// W3EE - Begin
			// strongCritDmg += CalculateAttributeValue(GetAttributeValue('critical_hit_chance_fast_style'));
			// W3EE - End
		}
		/*if (CanUseSkill(S_Sword_s04))
			strongAP += GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s04);*/
		if (CanUseSkill(S_Perk_07))
			strongAP +=	GetAttributeValue('attack_power_heavy_style');
			
		if (CanUseSkill(S_Sword_s17)) 
		{
			// W3EE - Begin
			fastCritChance += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s17);
			//fastCritDmg += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s17);
			// W3EE - End
		}
		
		if (CanUseSkill(S_Sword_s08)) 
		{
			// W3EE - Begin
			//strongCritChance += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s08);
			// W3EE - End
			strongCritDmg += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s08);
		}
		
		fastCritChance += 0.005f * GetSkillLevel(S_Sword_s20) * GetStat(BCS_Focus); //Kolaris - Razor Focus
		strongCritChance += 0.005f * GetSkillLevel(S_Sword_s20) * GetStat(BCS_Focus); //Kolaris - Razor Focus
		
		steelCritChance += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		silverCritChance += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		steelCritDmg += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		silverCritDmg += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		attackPower += GetPowerStatValue(CPS_AttackPower);
		
		if (GetItemEquippedOnSlot(EES_SteelSword, item))
		{
			steelDmg = super.GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
			steelDmg += super.GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_PIERCING, GetInvalidUniqueId());
			steelDmg += super.GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_BLUDGEONING, GetInvalidUniqueId());
			elementalSteel = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FIRE));
			elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FROST)); 
			elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_ELEMENTAL)); 
			if ( GetInventory().IsItemHeld(item) )
			{
				steelCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				silverCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				steelCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
				silverCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			}
			steelCritChance += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
			steelCritDmg += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			
			// W3EE - Begin
			/*
			thunder = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
			if(thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm)
			{
				steelCritChance += 1.0f;
			}
			*/
			// W3EE - End
		}
		else
		{
			steelDmg += 0;
			steelCritChance += 0;
			steelCritDmg +=0;
		}
		
		if (GetItemEquippedOnSlot(EES_SilverSword, item))
		{
			silverDmg = super.GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
			elementalSilver = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FIRE));
			elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FROST));
			elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_ELEMENTAL));
			if ( GetInventory().IsItemHeld(item) )
			{
				steelCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				silverCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				steelCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
				silverCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			}
			silverCritChance += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
			silverCritDmg += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			
			//Kolaris - Aerondight Tooltip
			aerondightBuff = (W3Effect_Aerondight)GetBuff(EET_Aerondight);
			if( aerondightBuff )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('AerondightEffect', 'crit_dam_bonus_stack', min, max);
				silverCritDmg += min.valueAdditive * aerondightBuff.GetCurrentCount();
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('AerondightEffect', 'crit_chance_bonus', min, max);
				if( aerondightBuff.IsFullyCharged() )
					silverCritChance += min.valueAdditive;
			}
			
			// W3EE - Begin
			/*
			thunder = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
			if(thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm)
			{
				silverCritChance += 1.0f;
			}
			*/
			// W3EE - End
		}
		else
		{
			silverDmg += 0;
			silverCritChance += 0;
			silverCritDmg +=0;
		}
		
		if ( HasAbility('Runeword 4 _Stats', true) )
		{
			steelDmg += steelDmg * (abilityManager.GetOverhealBonus() / GetStatMax(BCS_Vitality));
			silverDmg += silverDmg * (abilityManager.GetOverhealBonus() / GetStatMax(BCS_Vitality));
		}
		
		fastAP += attackPower;
		strongAP += attackPower;
		
		// W3EE - Begin
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(theGame.params.ATTACK_NAME_HEAVY, 'attack_power', min, max);
		strongAP += GetAttributeRandomizedValue(min, max);
		playerOffenseStats.fastAP = fastAP.valueMultiplicative;
		playerOffenseStats.strongAP = strongAP.valueMultiplicative;		
		// W3EE - End
		
		playerOffenseStats.steelFastCritChance = (steelCritChance + fastCritChance) * 100;
		playerOffenseStats.steelFastCritDmg = steelCritDmg + fastCritDmg;
		if ( steelDmg != 0 )
		{
			// W3EE - Begin
			playerOffenseStats.steelFastDmg = (steelDmg + fastAP.valueBase + elementalSteel) * fastAP.valueMultiplicative + fastAP.valueAdditive;
			playerOffenseStats.steelFastCritDmg = (steelDmg + fastAP.valueBase + elementalSteel) * (fastAP.valueMultiplicative + playerOffenseStats.steelFastCritDmg) + fastAP.valueAdditive;
			// W3EE - End
		}
		else
		{
			playerOffenseStats.steelFastDmg = 0;
			playerOffenseStats.steelFastCritDmg = 0;
		}
		playerOffenseStats.steelFastDPS = (playerOffenseStats.steelFastDmg * (100 - playerOffenseStats.steelFastCritChance) + playerOffenseStats.steelFastCritDmg * playerOffenseStats.steelFastCritChance) / 100;
		// W3EE - Begin
		//playerOffenseStats.steelFastDPS = playerOffenseStats.steelFastDPS / 0.6;
		// W3EE - End
		
		playerOffenseStats.steelStrongCritChance = (steelCritChance + strongCritChance) * 100;
		playerOffenseStats.steelStrongCritDmg = steelCritDmg + strongCritDmg;
		if ( steelDmg != 0 )
		{
			// W3EE - Begin
			playerOffenseStats.steelStrongDmg = (steelDmg + strongAP.valueBase + elementalSteel) * strongAP.valueMultiplicative + strongAP.valueAdditive; //modSigns
			//playerOffenseStats.steelStrongDmg *= 1.833f;
			playerOffenseStats.steelStrongCritDmg = (steelDmg + strongAP.valueBase + elementalSteel) * (strongAP.valueMultiplicative + playerOffenseStats.steelStrongCritDmg) + strongAP.valueAdditive; //modSigns
			//playerOffenseStats.steelStrongCritDmg *= 1.833f;
			// W3EE - End
		}
		else
		{
			playerOffenseStats.steelStrongDmg = 0;
			playerOffenseStats.steelStrongCritDmg = 0;
		}
		playerOffenseStats.steelStrongDPS = (playerOffenseStats.steelStrongDmg * (100 - playerOffenseStats.steelStrongCritChance) + playerOffenseStats.steelStrongCritDmg * playerOffenseStats.steelStrongCritChance) / 100;
		// W3EE - Begin
		// playerOffenseStats.steelStrongDPS = playerOffenseStats.steelStrongDPS / 1.1;
		// W3EE - End
		
		playerOffenseStats.silverFastCritChance = (silverCritChance + fastCritChance) * 100;
		playerOffenseStats.silverFastCritDmg = silverCritDmg + fastCritDmg;
		if ( silverDmg != 0 )
		{
			// W3EE - Begin
			playerOffenseStats.silverFastDmg = (silverDmg + fastAP.valueBase + elementalSilver) * fastAP.valueMultiplicative + fastAP.valueAdditive;
			playerOffenseStats.silverFastCritDmg = (silverDmg + fastAP.valueBase + elementalSilver) * (fastAP.valueMultiplicative + playerOffenseStats.silverFastCritDmg) + fastAP.valueAdditive;
			// W3EE - End
		}
		else
		{
			playerOffenseStats.silverFastDmg = 0;
			playerOffenseStats.silverFastCritDmg = 0;	
		}
		playerOffenseStats.silverFastDPS = (playerOffenseStats.silverFastDmg * (100 - playerOffenseStats.silverFastCritChance) + playerOffenseStats.silverFastCritDmg * playerOffenseStats.silverFastCritChance) / 100;
		// W3EE - Begin
		// playerOffenseStats.silverFastDPS = playerOffenseStats.silverFastDPS / 0.6;
		// W3EE - End
		
		playerOffenseStats.silverStrongCritChance = (silverCritChance + strongCritChance) * 100;
		playerOffenseStats.silverStrongCritDmg = silverCritDmg + strongCritDmg;		
		if ( silverDmg != 0 )
		{
			// W3EE - Begin
			playerOffenseStats.silverStrongDmg = (silverDmg + strongAP.valueBase + elementalSilver) * strongAP.valueMultiplicative + strongAP.valueAdditive;
			//playerOffenseStats.silverStrongDmg *= 1.833f;
			playerOffenseStats.silverStrongCritDmg = (silverDmg + strongAP.valueBase + elementalSilver) * (strongAP.valueMultiplicative + playerOffenseStats.silverStrongCritDmg) + strongAP.valueAdditive;
			//playerOffenseStats.silverStrongCritDmg *= 1.833f;
			// W3EE - End
		}
		else
		{
			playerOffenseStats.silverStrongDmg = 0;
			playerOffenseStats.silverStrongCritDmg = 0;
		}
		playerOffenseStats.silverStrongDPS = (playerOffenseStats.silverStrongDmg * (100 - playerOffenseStats.silverStrongCritChance) + playerOffenseStats.silverStrongCritDmg * playerOffenseStats.silverStrongCritChance) / 100;
		// W3EE - Begin
		// playerOffenseStats.silverStrongDPS = playerOffenseStats.silverStrongDPS / 1.1;
		// W3EE - End
		
		playerOffenseStats.crossbowCritChance = GetCriticalHitChance( false, false, NULL, MC_NotSet, true );
		playerOffenseStats.crossbowCritChance += 0.005f * GetSkillLevel(S_Sword_s20) * GetStat(BCS_Focus); //Kolaris - Razor Focus
		
		playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
		if (GetItemEquippedOnSlot(EES_Bolt, item))
		{
			
			
			steelDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FIRE));
			if(steelDmg > 0)
			{
				playerOffenseStats.crossbowSteelDmg = steelDmg;
				
				playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_FIRE;
				playerOffenseStats.crossbowSilverDmg = steelDmg;
			}
			else
			{
				playerOffenseStats.crossbowSilverDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_SILVER));
				
				steelDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_PIERCING));
				if(steelDmg > 0)
				{
					playerOffenseStats.crossbowSteelDmg = steelDmg;
					playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
				}
				else
				{
					playerOffenseStats.crossbowSteelDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_BLUDGEONING));
					playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_BLUDGEONING;
				}
			}
		}
		
		if (GetItemEquippedOnSlot(EES_RangedWeapon, item))
		{
			attackPower += GetInventory().GetItemAttributeValue(item, PowerStatEnumToName(CPS_AttackPower));
			if(CanUseSkill(S_Sword_s13))
			{				
				attackPower.valueMultiplicative += 0.05f * GetSkillLevel(S_Sword_s13);
			}
			//Kolaris ++ Mutation Rework
			/*if( hackMode != 1 && ( IsMutationActive( EPMT_Mutation9 ) || hackMode == 2 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
				playerOffenseStats.crossbowSteelDmg += min.valueAdditive;
				playerOffenseStats.crossbowSilverDmg += min.valueAdditive;
			}*/
			//Kolaris -- Mutation Rework
			playerOffenseStats.crossbowSteelDmg = (playerOffenseStats.crossbowSteelDmg + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive;
			playerOffenseStats.crossbowSilverDmg = (playerOffenseStats.crossbowSilverDmg + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive;
		}
		else
		{
			playerOffenseStats.crossbowSteelDmg = 0;
			playerOffenseStats.crossbowSilverDmg = 0;
			playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
		}
		
		return playerOffenseStats;
	}
	// W3EE - End
	
	public function GetTotalWeaponDamage(weaponId : SItemUniqueId, damageTypeName : name, crossbowId : SItemUniqueId, optional bolt : W3BoltProjectile) : float
	{
		var damage, durRatio, durMod, itemMod : float;
		//Kolaris - Bugfix
		var repairObjectBonus, min, max, weaponDamage, innateDamage : SAbilityAttributeValue;
		
		// W3EE - Begin
		durMod = 1;
		// W3EE - End
		
		//Kolaris - Bugfix
		//damage = super.GetTotalWeaponDamage(weaponId, damageTypeName, crossbowId, bolt);
		innateDamage = GetAttributeValue(damageTypeName);
		if( bolt )
		{
			weaponDamage.valueAdditive = bolt.GetBoltDamage(damageTypeName);
			weaponDamage.valueAdditive += innateDamage.valueAdditive;
			weaponDamage.valueMultiplicative += innateDamage.valueMultiplicative;
		}
		else
		{
			weaponDamage = innateDamage;
		}
		damage = CalculateAttributeValue(weaponDamage);
		//Kolaris ++ Mutation Rework
		/*if( IsMutationActive( EPMT_Mutation9 ) && inv.IsItemBolt( weaponId ) && IsDamageTypeAnyPhysicalType( damageTypeName ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'damage', min, max);
			damage += min.valueAdditive;
		}*/
		//Kolaris -- Mutation Rework
		
		if(IsPhysicalResistStat(GetResistForDamage(damageTypeName, false)))
		{
			repairObjectBonus = inv.GetItemAttributeValue(weaponId, theGame.params.REPAIR_OBJECT_BONUS);
			durRatio = -1;
			
			if(inv.IsIdValid(crossbowId) && inv.HasItemDurability(crossbowId))
			{
				durRatio = inv.GetItemDurabilityRatio(crossbowId);
			}
			else if(inv.IsIdValid(weaponId) && inv.HasItemDurability(weaponId))
			{
				durRatio = inv.GetItemDurabilityRatio(weaponId);
			}
			
			
			if(durRatio >= 0)
				durMod = theGame.params.GetDurabilityMultiplier(durRatio, true);
			else
				durMod = 1;
		}
		
		if( damageTypeName == 'SilverDamage' && inv.ItemHasTag( weaponId, 'Aerondight' ) )
		{
			itemMod = inv.GetItemModifierFloat( weaponId, 'PermDamageBoost' );
			if( itemMod > 0.f )
			{
				damage += itemMod;
			}
		}
		//Kolaris - Fortification
		else if( HasAbility('Runeword 54 _Stats', true) )
		{
			if( damageTypeName == 'SilverDamage' || (damageTypeName == 'SlashingDamage' || inv.IsItemSteelSwordUsableByPlayer(weaponId)) )
			{
				itemMod = inv.GetItemModifierFloat( weaponId, 'PermDamageBoost' );
				if( itemMod > 0.f )
				{
					damage += itemMod;
				}
			}
		}
		
		return damage * (durMod + repairObjectBonus.valueMultiplicative);
	}
	
	
	
	
	
	public final function GetSkillPathType(skill : ESkill) : ESkillPath
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillPathType(skill);
			
		return ESP_NotSet;
	}
	
	public function GetSkillLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
				return ((W3PlayerAbilityManager)abilityManager).GetSkillLevel(s);
		return -1;
	}
	
	public function GetSkillMaxLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillMaxLevel(s);
			
		return -1;
	}
	
	public function GetBoughtSkillLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetBoughtSkillLevel(s);
			
		return -1;
	}
	
	
	public function GetAxiiLevel() : int
	{
		var level : int;
		
		//Kolaris - Lethargy
		level = 4;
		
		//if(CanUseSkill(S_Magic_s17)) level = 4;
			
		return Clamp(level, 1, 4);
	}
	
	public function IsInFrenzy() : bool
	{
		return isInFrenzy;
	}
	
	public function HasRecentlyCountered() : bool
	{
		return hasRecentlyCountered;
	}
	
	public function SetRecentlyCountered(counter : bool)
	{
		hasRecentlyCountered = counter;
	}
	
	timer function CheckBlockedSkills(dt : float, id : int)
	{
		var nextCallTime : float;
		
		nextCallTime = ((W3PlayerAbilityManager)abilityManager).CheckBlockedSkills(dt);
		if(nextCallTime != -1)
			AddTimer('CheckBlockedSkills', nextCallTime, , , , true);
	}
		
	
	public function RemoveTemporarySkills()
	{
		var i : int;
		var pam : W3PlayerAbilityManager;
	
		if(tempLearnedSignSkills.Size() > 0)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			for(i=0; i<tempLearnedSignSkills.Size(); i+=1)
			{
				pam.RemoveTemporarySkill(tempLearnedSignSkills[i]);
			}
			
			tempLearnedSignSkills.Clear();						
		}
		RemoveAbilityAll(SkillEnumToName(S_Sword_s19));
	}
	
	public function RemoveTemporarySkill(skill : SSimpleSkill) : bool
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.RemoveTemporarySkill(skill);
			
		return false;
	}
	
	// W3EE - Begin
	private function AddTemporarySkills()
	{
		/*if(CanUseSkill(S_Sword_s19) && GetStat(BCS_Focus) >= 3)
		{
			// tempLearnedSignSkills = ((W3PlayerAbilityManager)abilityManager).AddTempNonAlchemySkills();						
			AddAbilityMultiple(SkillEnumToName(S_Sword_s19), GetSkillLevel(S_Sword_s19));			
		}*/
	}
	// W3EE - End
	
	
	public function HasAlternateQuen() : bool
	{
		var quenEntity : W3QuenEntity;
		
		quenEntity = (W3QuenEntity)GetCurrentSignEntity();
		if(quenEntity)
		{
			return quenEntity.IsAlternateCast();
		}
		
		return false;
	}
	
	
	
	
	
	public function AddPoints(type : ESpendablePointType, amount : int, show : bool)
	{
		levelManager.AddPoints(type, amount, show);
	}
	
	public function GetLevel() : int											{return levelManager.GetLevel();}
	public function GetMaxLevel() : int											{return levelManager.GetMaxLevel();}
	public function GetTotalExpForNextLevel() : int								{return levelManager.GetTotalExpForNextLevel();}	
	public function GetPointsTotal(type : ESpendablePointType) : int 			{return levelManager.GetPointsTotal(type);}
	public function IsAutoLeveling() : bool										{return autoLevel;}
	public function SetAutoLeveling( b : bool )									{autoLevel = b;}
	
	public function GetMissingExpForNextLevel() : int
	{
		return Max(0, GetTotalExpForNextLevel() - GetPointsTotal(EExperiencePoint));
	}
	
	
	
	
	private saved var runewordInfusionType : ESignType;
	default runewordInfusionType = ST_None;
	
	public final function GetRunewordInfusionType() : ESignType
	{
		//Kolaris - Invocation
		return GetEquippedSign();
	}
	
	// W3EE - Begin
	public var infusionCooldown : bool;
	timer function InfusionCooldown( dt : float, id : int )
	{
		infusionCooldown = false;
	}
	
	public final function SetRunewordInfusionType( i : ESignType )
	{
		runewordInfusionType = i;
	}
	// W3EE - End
	
	//Kolaris - Exploding Shield
	public function QuenImpulse( isAlternate : bool, signEntity : W3QuenEntity, source : string, optional direction : float )
	{
		var level, i, j : int;
		var atts, damages : array<name>;
		// W3EE - Begin
		var ents : array<CActor>;
		var action : W3DamageAction;
		var dm : CDefinitionsManagerAccessor;
		var skillAbilityName : name;
		var dmg, impulsePower, forceResist : float;
		var min, max, sp : SAbilityAttributeValue;
		var pos : Vector;
		var fx : CEntity;
		var poise : W3Effect_NPCPoise;
		
		dm = theGame.GetDefinitionsManager();
		skillAbilityName = GetSkillAbilityName(S_Magic_s13);
		
		dm.GetAbilityAttributes(skillAbilityName, atts);
		for(i=0; i<atts.Size(); i+=1)
		{
			if(IsDamageTypeNameValid(atts[i]))
			{
				damages.PushBack(atts[i]);
			}
		}
		
		sp = signEntity.GetTotalSignIntensity();
		pos = signEntity.GetWorldPosition();
		level = signEntity.GetActualOwner().GetSkillLevel(S_Magic_s13, signEntity);
		if( direction )
			ents = GetNPCsAndPlayersInCone(7, direction, 60, 1000);
		else
			ents = GetActorsInRange(this, 5, 1000, , true);
		for(i=0; i<ents.Size(); i+=1)
		{
			if( (W3PlayerWitcher)ents[i] || ents[i].GetAttitude(this) == AIA_Friendly || ents[i].GetAttitude(this) == AIA_Neutral )
				continue;
				
			action = new W3DamageAction in theGame;
			action.Initialize(this, ents[i], signEntity, source, EHRT_Heavy, CPS_SpellPower, false, false, true, false);
			action.SetSignSkill(S_Magic_s13);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			
			action.SetHitEffect('hit_electric_quen');
			action.SetHitEffect('hit_electric_quen', true);
			action.SetHitEffect('hit_electric_quen', false, true);
			action.SetHitEffect('hit_electric_quen', true, true);
				
			fx = ((CActor)ents[i]).CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			
			if( ((CActor)ents[i]).IsHelpless() )
				action.SetHitAnimationPlayType(EAHA_ForceNo);
			
			for(j=0; j<damages.Size(); j+=1)
			{
				dm.GetAbilityAttributeValue(skillAbilityName, damages[j], min, max);
				
				dmg = 500.f;
				if( HasAbility('Glyphword 19 _Stats', true) || HasAbility('Glyphword 20 _Stats', true) || HasAbility('Glyphword 21 _Stats', true) )
					dmg += 1000.f;
				if( direction )
					dmg += 1000.f;
				
				dmg *= sp.valueMultiplicative;
				
				action.AddDamage(damages[j], dmg);
			}
			
			poise = (W3Effect_NPCPoise)((CNewNPC)ents[i]).GetBuff(EET_NPCPoise);
			forceResist = ((CNewNPC)ents[i]).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FORCE);
			
			impulsePower = 0.5f * sp.valueMultiplicative * (1.5f - poise.GetPoisePercentage()) *  (1.f - forceResist);
			if( ((CNewNPC)ents[i]).HasTag('WeakToQuen') )
				impulsePower *= 1.5f;
			if( direction )
				impulsePower *= 2.f;
			
			if( RandF() <= impulsePower )
			{
				if( ents[i].HasAbility('mon_werewolf_base') )
					action.AddEffectInfo(EET_LongStagger);
				else
					action.AddEffectInfo(EET_Knockdown);
			}
			else
			if( RandF() <= impulsePower )
				action.AddEffectInfo(EET_LongStagger);
			else
			if( RandF() <= impulsePower )
				action.AddEffectInfo(EET_Stagger);
			else
				action.SetHitAnimationPlayType(EAHA_ForceYes);
			
			// action.AddEffectInfo(EET_KnockdownTypeApplicator);
			
			if( direction )
				((CNewNPC)ents[i]).AddEffectDefault(EET_Electroshock, this, "Glyphword 21");
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		GCameraShake(0.05f * level * sp.valueMultiplicative);
		// W3EE - End
		
		if(isAlternate)
		{
			signEntity.PlayHitEffect('quen_impulse_explode', signEntity.GetWorldRotation());
			signEntity.EraseFirstTimeStamp();
			
			//Kolaris - Retribution Fx - Disabled, Lots of Clutter
			//if( HasAbility('Glyphword 20 _Stats', true) || HasAbility('Glyphword 21 _Stats', true) )
				//signEntity.PlayHitEffect('quen_electric_explode_bear_abl2', signEntity.GetWorldRotation());
			//else
				signEntity.PlayHitEffect('quen_electric_explode', signEntity.GetWorldRotation());
		}
		else
		{
			signEntity.PlayEffect('lasting_shield_impulse');
		}
	}

	public function OnSignCastPerformed(signType : ESignType, isAlternate : bool)
	{
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		var fxName : name;
		var pos : Vector;
		var harmonyAbility : SCustomEffectParams;
		
		super.OnSignCastPerformed(signType, isAlternate);
		
		//plasticmetal - Sign Camera Fix
		thePlayer.ClearCustomOrientationInfoStack();
		
		// W3EE - Begin
		Combat().SetInfusionVariables(this, signType);
		
		//Kolaris - Invocation
		/*if( (HasAbility('Runeword 40 _Stats', true) || HasAbility('Runeword 41 _Stats', true) || HasAbility('Runeword 42 _Stats', true)) && !infusionCooldown && GetStat(BCS_Focus) >= 1.0f)
		{
			// DrainFocus(1.0f);
			// W3EE - End
			runewordInfusionType = signType;
			items = inv.GetHeldWeapons();
			weaponEnt = inv.GetItemEntityUnsafe(items[0]);
			
			
			weaponEnt.StopEffect('runeword_aard');
			weaponEnt.StopEffect('runeword_axii');
			weaponEnt.StopEffect('runeword_igni');
			weaponEnt.StopEffect('runeword_quen');
			weaponEnt.StopEffect('runeword_yrden');
			
			
			if(signType == ST_Aard)
				fxName = 'runeword_aard';
			else if(signType == ST_Axii)
				fxName = 'runeword_axii';
			else if(signType == ST_Igni)
				fxName = 'runeword_igni';
			else if(signType == ST_Quen)
				fxName = 'runeword_quen';
			else if(signType == ST_Yrden)
				fxName = 'runeword_yrden';
			
			weaponEnt.PlayEffect(fxName);
			
			infusionCooldown = true;
			AddTimer('InfusionCooldown', 1.5f, false);
		}*/
		
		if( CanUseSkill(S_Magic_s12) && signType == ST_Aard )
		{
			if( !isAlternate )
				pos = GetWorldPosition() + GetWorldForward() * 2;
			else
				pos = GetWorldPosition();
				
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup( pos, 0.15f, 7.f, 2.f, 5.f, 0 );
		}
		//Kolaris ++ Mutation Rework
		/*if( IsMutationActive( EPMT_Mutation6 ) )
		{
			if( signType == ST_Aard && HasBuff( EET_HarmonyAard ) )
			{
				harmonyAbility.effectType = EET_HarmonyAxii;
				harmonyAbility.creator = this;
				harmonyAbility.sourceName = "Mutation 6";
				harmonyAbility.isSignEffect = false;
				harmonyAbility.duration = -1;
				this.AddEffectCustom(harmonyAbility);
				RemoveBuff(EET_HarmonyAard);
			}
			else
			if( signType == ST_Axii && HasBuff( EET_HarmonyAxii ) )
			{
				harmonyAbility.effectType = EET_HarmonyQuen;
				harmonyAbility.creator = this;
				harmonyAbility.sourceName = "Mutation 6";
				harmonyAbility.isSignEffect = false;
				harmonyAbility.duration = -1;
				this.AddEffectCustom(harmonyAbility);
				RemoveBuff(EET_HarmonyAxii);
			}
			else
			if( signType == ST_Quen && HasBuff( EET_HarmonyQuen ) )
			{
				harmonyAbility.effectType = EET_HarmonyIgni;
				harmonyAbility.creator = this;
				harmonyAbility.sourceName = "Mutation 6";
				harmonyAbility.isSignEffect = false;
				harmonyAbility.duration = -1;
				this.AddEffectCustom(harmonyAbility);
				RemoveBuff(EET_HarmonyQuen);
			}
			else
			if( signType == ST_Igni && HasBuff( EET_HarmonyIgni ) )
			{
				harmonyAbility.effectType = EET_HarmonyYrden;
				harmonyAbility.creator = this;
				harmonyAbility.sourceName = "Mutation 6";
				harmonyAbility.isSignEffect = false;
				harmonyAbility.duration = -1;
				this.AddEffectCustom(harmonyAbility);
				RemoveBuff(EET_HarmonyIgni);
			}
			else
			if( signType == ST_Yrden && HasBuff( EET_HarmonyYrden ) )
			{
				harmonyAbility.effectType = EET_HarmonyAard;
				harmonyAbility.creator = this;
				harmonyAbility.sourceName = "Mutation 6";
				harmonyAbility.isSignEffect = false;
				harmonyAbility.duration = -1;
				this.AddEffectCustom(harmonyAbility);
				RemoveBuff(EET_HarmonyYrden);
			}
			else
			if( !(HasBuff( EET_HarmonyAard ) || HasBuff( EET_HarmonyAxii ) || HasBuff( EET_HarmonyQuen ) || HasBuff( EET_HarmonyIgni ) || HasBuff( EET_HarmonyYrden )) )
			{
				harmonyAbility.effectType = EET_HarmonyYrden;
				harmonyAbility.creator = this;
				harmonyAbility.sourceName = "Mutation 6";
				harmonyAbility.isSignEffect = false;
				harmonyAbility.duration = -1;
				this.AddEffectCustom(harmonyAbility);
			}
		}*/ //Kolaris -- Mutation Rework
	}
	
	public saved var savedQuenHealth, savedQuenDuration : float;
	
	timer function HACK_QuenSaveStatus(dt : float, id : int)
	{
		var quenEntity : W3QuenEntity;
		
		quenEntity = (W3QuenEntity)signs[ST_Quen].entity;
		savedQuenHealth = quenEntity.GetShieldHealth();
		savedQuenDuration = quenEntity.GetShieldRemainingDuration();
	}
	
	timer function DelayedRestoreQuen(dt : float, id : int)
	{
		RestoreQuen(savedQuenHealth, savedQuenDuration);
	}
	
	private var refreshFace : bool;	default refreshFace = false;
	public final function OnBasicQuenFinishing()
	{
		RemoveTimer('HACK_QuenSaveStatus');
		savedQuenHealth = 0.f;
		savedQuenDuration = 0.f;
		refreshFace = true;
	}
	
	public function ShouldRefreshFace() : bool
	{
		return refreshFace;
	}
	
	public function ResetRefreshFace()
	{
		refreshFace = false;
	}
	
	public final function IsAnyQuenActive() : bool
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)GetSignEntity(ST_Quen);
		if(quen)
			return quen.IsAnyQuenActive();
			
		return false;
	}
	
	public final function IsQuenActive(alternateMode : bool) : bool
	{
		if(IsAnyQuenActive() && GetSignEntity(ST_Quen).IsAlternateCast() == alternateMode)
			return true;
			
		return false;
	}
	
	public function FinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)GetSignEntity(ST_Quen);
		if(quen)
			quen.ForceFinishQuen( skipVisuals, forceNoBearSetBonus );
	}
	
	// W3EE - Begin
	public function GetTotalSpellPower(optional displayOnly : bool) : SAbilityAttributeValue
	{
		var sp : SAbilityAttributeValue;
		var maxFocus, currFocus, penaltyPerc, vigorPenalty : float;
		
		sp = GetAttributeValue(PowerStatEnumToName(CPS_SpellPower));
		
		if( CanUseSkill(S_Sword_s19) && GetAdrenalineEffect().GetValue() > 0 )
		{
			sp.valueMultiplicative += (GetAdrenalineEffect().GetValue() * GetSkillLevel(S_Sword_s19) * 0.1f);
		}
		
		//Kolaris - Relict Decoction
		if( HasBuff(EET_Decoction7) )
			sp.valueMultiplicative += 0.2f * GetStatPercents(BCS_Vitality);
		
		//Kolaris - Mutation 1
		if( IsMutationActive(EPMT_Mutation1) )
			sp.valueMultiplicative += 0.5f;
		
		//Kolaris - Sign Intensity Scaling
		if( !displayOnly )
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		
		maxFocus = GetStatMax(BCS_Focus);
		currFocus = GetStat(BCS_Focus);
		
		//Kolaris - Resolve
		if( CanUseSkill(S_Sword_s16) )
			penaltyPerc = Options().VigIntLost() / (100.f + 20.f * GetSkillLevel(S_Sword_s16));
		else
			penaltyPerc = Options().VigIntLost() / 100.f;
		
		//Kolaris - Inner Strength
		if( currFocus < 1 && CanUseSkill(S_Perk_09) )
			vigorPenalty = 3.f * penaltyPerc;
		else
			vigorPenalty = (maxFocus / Options().MaxFocus()) * (maxFocus - currFocus) * penaltyPerc;
		
		//Kolaris - Hybrid Decoction
		if( HasBuff(EET_Decoction8) )
			vigorPenalty = MinF(vigorPenalty, (1.f - GetStatPercents(BCS_Stamina)) * penaltyPerc);
		
		sp.valueMultiplicative -= sp.valueMultiplicative * vigorPenalty; 
		sp.valueMultiplicative = MaxF(0, sp.valueMultiplicative);
		
		//ApplyMutation10StatBoost(sp); //Kolaris - Mutation 10
		
		return sp;
	}
	
	public function GetSingleSignSpellPower( signSkill : ESkill ) : SAbilityAttributeValue
	{
		var sp : SAbilityAttributeValue;
		var penaltyReduction : float;
		var penaltyReductionLevel : int; 
		var quenEntity : W3QuenEntity;
		var maxFocus, currFocus, penaltyPerc, vigorPenalty : float;
		
		if(signSkill == S_Magic_1 || signSkill == S_Magic_s01)
		{
			sp = GetAttributeValue('spell_power_aard');
			//Kolaris - Acceleration
			if( HasAbility('Glyphword 5 _Stats', true) || HasAbility('Glyphword 6 _Stats', true) )
			{
				sp.valueMultiplicative += MaxF( 0.f, Combat().EvadeSpeedModule(true) - 1.f );
				sp.valueMultiplicative += 0.1f * GetSprintingTime();
			}
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("aard");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Aard) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
			
			//Kolaris - Whirlwind
			/*if( signSkill == S_Magic_s01 )
			{
				penaltyReductionLevel = GetSkillLevel(S_Magic_s01) - 1;
				if(penaltyReductionLevel > 0)
				{
					penaltyReduction = penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', false, false));
					sp.valueMultiplicative += penaltyReduction;
				}
			}*/
		}
		else if(signSkill == S_Magic_2 || signSkill == S_Magic_s02)
		{
			sp = GetAttributeValue('spell_power_igni');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("igni");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Igni) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		else if(signSkill == S_Magic_3 || signSkill == S_Magic_s03)
		{
			sp = GetAttributeValue('spell_power_yrden');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("yrden");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Yrden) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		else if(signSkill == S_Magic_4 || signSkill == S_Magic_s04)
		{
			sp = GetAttributeValue('spell_power_quen');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("quen");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Quen) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
			quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);
		}
		else if(signSkill == S_Magic_5 || signSkill == S_Magic_s05)
		{
			sp = GetAttributeValue('spell_power_axii');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("axii");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Axi) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		
		maxFocus = GetStatMax(BCS_Focus);
		currFocus = GetStat(BCS_Focus);
		if( CanUseSkill(S_Sword_s16) )
			penaltyPerc = Options().VigIntLost() / (100.f + 20.f * GetSkillLevel(S_Sword_s16));
		else
			penaltyPerc = Options().VigIntLost() / 100.f;
		
		//Kolaris - Inner Strength
		if( currFocus < 1 && CanUseSkill(S_Perk_09) )
			vigorPenalty = 3.f * penaltyPerc;
		else
			vigorPenalty = (3.f - GetStatPercents(BCS_Focus) * 3.f) * penaltyPerc;
		
		//Kolaris - Hybrid Decoction
		if( HasBuff(EET_Decoction8) )
			vigorPenalty = MinF(vigorPenalty, (1.f - GetStatPercents(BCS_Stamina)) * penaltyPerc);
		
		sp.valueMultiplicative -= sp.valueMultiplicative * vigorPenalty; 
		sp.valueMultiplicative = MaxF(0, sp.valueMultiplicative);
		
		//ApplyMutation10StatBoost(sp); //Kolaris - Mutation 10
		
		return sp;
	}
	
	public function GetTotalSignSpellPower(signSkill : ESkill) : SAbilityAttributeValue
	{
		var sp: SAbilityAttributeValue;
		var penaltyReduction : float;
		var penaltyReductionLevel : int; 
		var quenEntity : W3QuenEntity;
		var maxFocus, currFocus, penaltyPerc, vigorPenalty : float;
		
		sp = GetAttributeValue(PowerStatEnumToName(CPS_SpellPower));
		if( CanUseSkill(S_Sword_s19) && GetAdrenalineEffect().GetValue() > 0 )
		{
			sp.valueMultiplicative += (GetAdrenalineEffect().GetValue() * GetSkillLevel(S_Sword_s19) * 0.1f);
		}
		
		//Kolaris - Relict Decoction
		if( HasBuff(EET_Decoction7) )
			sp.valueMultiplicative += 0.2f * GetStatPercents(BCS_Vitality);
		
		//Kolaris - Mutation 1
		if( IsMutationActive(EPMT_Mutation1) )
			sp.valueMultiplicative += 0.5f;
		
		if(signSkill == S_Magic_1 || signSkill == S_Magic_s01)
		{
			if( signSkill == S_Magic_s01 )
			{
				penaltyReductionLevel = GetSkillLevel(S_Magic_s01) - 1;
				if(penaltyReductionLevel > 0)
				{
					penaltyReduction = penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', false, false));
					sp.valueMultiplicative += penaltyReduction;
				}
			}
			sp += GetAttributeValue('spell_power_aard');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("aard");
			//Kolaris - Acceleration
			if( HasAbility('Glyphword 5 _Stats', true) || HasAbility('Glyphword 6 _Stats', true) )
			{
				sp.valueMultiplicative += MaxF( 0.f, Combat().EvadeSpeedModule(true) - 1.f );
				sp.valueMultiplicative += 0.1f * GetSprintingTime();
			}
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Aard) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		else if(signSkill == S_Magic_2 || signSkill == S_Magic_s02)
		{
			sp += GetAttributeValue('spell_power_igni');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("igni");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Igni) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		else if(signSkill == S_Magic_3 || signSkill == S_Magic_s03)
		{
			sp += GetAttributeValue('spell_power_yrden');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("yrden");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Yrden) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		else if(signSkill == S_Magic_4 || signSkill == S_Magic_s04)
		{
			sp += GetAttributeValue('spell_power_quen');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("quen");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Quen) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
			quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);
		}
		else if(signSkill == S_Magic_5 || signSkill == S_Magic_s05)
		{
			sp += GetAttributeValue('spell_power_axii');
			//Kolaris - Ofieri Set
			if( IsSetBonusActive(EISB_Ofieri) )
				sp.valueMultiplicative += 0.05f * Combat().GetOfieriSetBonusCount("axii");
			//Kolaris - Sign Intensity Scaling
			//sp.valueMultiplicative += Experience().GetSpentPathPoints(ESSP_Signs_Axi) * 0.01f;
			sp.valueMultiplicative = 1.f + (sp.valueMultiplicative - 1.f) * (MinF(1.f, 1.f / sp.valueMultiplicative));
		}
		
		maxFocus = GetStatMax(BCS_Focus);
		currFocus = GetStat(BCS_Focus);
		if( CanUseSkill(S_Sword_s16) )
			penaltyPerc = Options().VigIntLost() / (100.f + 20.f * GetSkillLevel(S_Sword_s16));
		else
			penaltyPerc = Options().VigIntLost() / 100.f;
		
		//Kolaris - Inner Strength
		if( currFocus < 1 && CanUseSkill(S_Perk_09) )
			vigorPenalty = 3.f * penaltyPerc;
		else
			vigorPenalty = (maxFocus / Options().MaxFocus()) * (maxFocus - currFocus) * penaltyPerc;
		
		//Kolaris - Hybrid Decoction
		if( HasBuff(EET_Decoction8) )
			vigorPenalty = MinF(vigorPenalty, (1.f - GetStatPercents(BCS_Stamina)) * penaltyPerc);
		
		sp.valueMultiplicative -= sp.valueMultiplicative * vigorPenalty; 
		sp.valueMultiplicative = MaxF(0, sp.valueMultiplicative);
		
		//ApplyMutation10StatBoost(sp); //Kolaris - Mutation 10
		
		return sp;
	}
	// W3EE - End
	
	
	
	
	
	public final function GetGwentCardIndex( cardName : name ) : int
	{
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		if(dm.ItemHasTag( cardName , 'GwintCardLeader' )) 
		{
			return theGame.GetGwintManager().GwentLeadersNametoInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNrkd' ))
		{
			return theGame.GetGwintManager().GwentNrkdNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNlfg' ))
		{
			return theGame.GetGwintManager().GwentNlfgNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSctl' ))
		{
			return theGame.GetGwintManager().GwentSctlNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardMstr' ))
		{
			return theGame.GetGwintManager().GwentMstrNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSke' ))
		{
			return theGame.GetGwintManager().GwentSkeNameToInt( cardName );
		}	
		else if(dm.ItemHasTag( cardName , 'GwintCardNeutral' ))
		{
			return theGame.GetGwintManager().GwentNeutralNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSpcl' ))
		{
			return theGame.GetGwintManager().GwentSpecialNameToInt( cardName );
		}
		
		return -1;
	}
	
	public final function AddGwentCard(cardName : name, amount : int) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var cardIndex, i : int;
		var tut : STutorialMessage;
		var gwintManager : CR4GwintManager;
		
		
		
		if(FactsQuerySum("q001_nightmare_ended") > 0 && ShouldProcessTutorial('TutorialGwentDeckBuilder2'))
		{
			tut.type = ETMT_Hint;
			tut.tutorialScriptTag = 'TutorialGwentDeckBuilder2';
			tut.journalEntryName = 'TutorialGwentDeckBuilder2';
			tut.hintPositionType = ETHPT_DefaultGlobal;
			tut.markAsSeenOnShow = true;
			tut.hintDurationType = ETHDT_Long;

			theGame.GetTutorialSystem().DisplayTutorial(tut);
		}
		
		dm = theGame.GetDefinitionsManager();
		
		cardIndex = GetGwentCardIndex(cardName);
		
		if (cardIndex != -1)
		{
			FactsAdd("Gwint_Card_Looted");
			
			for(i = 0; i < amount; i += 1)
			{
				theGame.GetGwintManager().AddCardToCollection( cardIndex );
			}
		}
		
		if( dm.ItemHasTag( cardName, 'GwentTournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsAdd( "GwentTournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsAdd( "GwentTournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsAdd( "GwentTournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsAdd( "GwentTournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsAdd( "GwentTournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsAdd( "GwentTournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsAdd( "GwentTournament", 7 );
			}
			
			CheckGwentTournamentDeck();
		}
		
		if( dm.ItemHasTag( cardName, 'EP2Tournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsAdd( "EP2Tournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsAdd( "EP2Tournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsAdd( "EP2Tournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsAdd( "EP2Tournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsAdd( "EP2Tournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsAdd( "EP2Tournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsAdd( "EP2Tournament", 7 );
			}
			
			CheckEP2TournamentDeck();
		}
		
		gwintManager = theGame.GetGwintManager();
		if( !gwintManager.IsDeckUnlocked( GwintFaction_Skellige ) &&
			gwintManager.HasCardsOfFactionInCollection( GwintFaction_Skellige, false ) )
		{
			gwintManager.UnlockDeck( GwintFaction_Skellige );
		}
		
		return true;
	}
	
	
	public final function RemoveGwentCard(cardName : name, amount : int) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var cardIndex, i : int;
		
		dm = theGame.GetDefinitionsManager();
		
		if(dm.ItemHasTag( cardName , 'GwintCardLeader' )) 
		{
			cardIndex = theGame.GetGwintManager().GwentLeadersNametoInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNrkd' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNrkdNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNlfg' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNlfgNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSctl' ))
		{
			cardIndex = theGame.GetGwintManager().GwentSctlNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardMstr' ))
		{
			cardIndex = theGame.GetGwintManager().GwentMstrNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNeutral' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNeutralNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSpcl' ))
		{
			cardIndex = theGame.GetGwintManager().GwentSpecialNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		
		if( dm.ItemHasTag( cardName, 'GwentTournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsSubstract( "GwentTournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsSubstract( "GwentTournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsSubstract( "GwentTournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsSubstract( "GwentTournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsSubstract( "GwentTournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsSubstract( "GwentTournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsSubstract( "GwentTournament", 7 );
			}
			
			CheckGwentTournamentDeck();
		}
			
			
		if( dm.ItemHasTag( cardName, 'EP2Tournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsSubstract( "EP2Tournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsSubstract( "EP2Tournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsSubstract( "EP2Tournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsSubstract( "EP2Tournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsSubstract( "EP2Tournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsSubstract( "EP2Tournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsSubstract( "EP2Tournament", 7 );
			}
			
			CheckEP2TournamentDeck();
		}
		
		return true;
	}
	
	function CheckGwentTournamentDeck()
	{
		var gwentPower			: int;
		var neededGwentPower	: int;
		var checkBreakpoint		: int;
		
		neededGwentPower = 70;
		
		checkBreakpoint = neededGwentPower/5;
		gwentPower = FactsQuerySum( "GwentTournament" );
		
		if ( gwentPower >= neededGwentPower )
		{
			FactsAdd( "HasGwentTournamentDeck", 1 );
		}
		else
		{
			if( FactsDoesExist( "HasGwentTournamentDeck" ) )
			{
				FactsRemove( "HasGwentTournamentDeck" );
			}
			
			if ( gwentPower >= checkBreakpoint )
			{
				FactsAdd( "GwentTournamentObjective1", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective1" ) )
			{
				FactsRemove( "GwentTournamentObjective1" );
			}
			
			if ( gwentPower >= checkBreakpoint*2 )
			{
				FactsAdd( "GwentTournamentObjective2", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective2" ) )
			{
				FactsRemove( "GwentTournamentObjective2" );
			}
			
			if ( gwentPower >= checkBreakpoint*3 )
			{
				FactsAdd( "GwentTournamentObjective3", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective3" ) )
			{
				FactsRemove( "GwentTournamentObjective3" );
			}
			
			if ( gwentPower >= checkBreakpoint*4 )
			{
				FactsAdd( "GwentTournamentObjective4", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective4" ) )
			{
				FactsRemove( "GwentTournamentObjective4" );
			}
		}
	}
	
	function CheckEP2TournamentDeck()
	{
		var gwentPower			: int;
		var neededGwentPower	: int;
		var checkBreakpoint		: int;
		
		neededGwentPower = 24;
		
		checkBreakpoint = neededGwentPower/5;
		gwentPower = FactsQuerySum( "EP2Tournament" );
		
		if ( gwentPower >= neededGwentPower )
		{
			if( FactsQuerySum( "HasEP2TournamentDeck") == 0 )
			{
				FactsAdd( "HasEP2TournamentDeck", 1 );
			}
			
		}
		else
		{
			if( FactsDoesExist( "HasEP2TournamentDeck" ) )
			{
				FactsRemove( "HasEP2TournamentDeck" );
			}
			
			if ( gwentPower >= checkBreakpoint )
			{
				FactsAdd( "EP2TournamentObjective1", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective1" ) )
			{
				FactsRemove( "EP2TournamentObjective1" );
			}
			
			if ( gwentPower >= checkBreakpoint*2 )
			{
				FactsAdd( "EP2TournamentObjective2", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective2" ) )
			{
				FactsRemove( "EP2TournamentObjective2" );
			}
			
			if ( gwentPower >= checkBreakpoint*3 )
			{
				FactsAdd( "EP2TournamentObjective3", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective3" ) )
			{
				FactsRemove( "EP2TournamentObjective3" );
			}
			
			if ( gwentPower >= checkBreakpoint*4 )
			{
				FactsAdd( "EP2TournamentObjective4", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective4" ) )
			{
				FactsRemove( "EP2TournamentObjective4" );
			}
		}
	}
	
	
	
	
	
	
	public function SimulateBuffTimePassing(simulatedTime : float)
	{
		super.SimulateBuffTimePassing(simulatedTime);
		
		FinishQuen(true);
	}
	
	public function CanMeditate() : bool
	{
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		
		if(currentStateName == 'Exploration' && !CanPerformPlayerAction())
			return false;
		
		
		if(GetCurrentStateName() != 'Exploration' && GetCurrentStateName() != 'Meditation' && GetCurrentStateName() != 'MeditationWaiting')
			return false;
			
		
		if(GetUsedVehicle())
			return false;
			
		
		return CanMeditateHere();
	}
	
	
	public final function CanMeditateWait(optional skipMeditationStateCheck : bool) : bool
	{
		var currState : name;
		
		currState = GetCurrentStateName();
		
		
		
		if(!skipMeditationStateCheck && currState != 'Meditation')
			return false;
			
		// W3EE - Begin
		
		if(theGame.IsGameTimePaused())
		{
			return false;
		}
			
		if(!IsActionAllowed( EIAB_MeditationWaiting ))
		{
			return false;
		}
		
		if( IsThreatened() )
		{
			return false;
		}
		
		if( IsOnBoat() || IsInAir() || IsSwimming() )
		{
			return false;
		}
		
		return true;
		
		// W3EE - End
	}

	
	public final function CanMeditateHere() : bool
	{
		var pos	: Vector;
		
		pos = GetWorldPosition();
		
		// W3EE - Begin
		if(pos.Z <= theGame.GetWorld().GetWaterLevel(pos, true) && IsInShallowWater())
		{
			return false;
		}
		
		if(IsThreatened())
		{
			return false;
		}
			
		if( !clockMenu )
		{
			if( ((CMovingPhysicalAgentComponent)GetMovingAgentComponent()).GetSubmergeDepth() < 0 )
			{
				return false;
			}
			
			return CanMeditateWait(true);
		}
		// W3EE - End
		
		return true;
	}
	
	// W3EE - Begin
	private var animManager : W3EEAnimationManager;
	private function InitAnimManager()
	{
		if( !animManager )
		{
			animManager = new W3EEAnimationManager in this;
			animManager.Init(this);
		}
	}
	
	public function GetAnimManager() : W3EEAnimationManager
	{
		return animManager;
	}
	
	public function IsAnimated() : bool
	{
		return animManager.IsAnimated();
	}
	
	public timer function StartAnimatedState( dt : float, id : int )
	{
		animManager.GotoState('Animation');
	}
	
	public function GetAnimatedState() : W3EEAnimationManagerStateAnimation
	{
		return animManager.GetAnimatedState();
	}
	
	public function AdvanceTimeSeconds( seconds : int )
	{
		theGame.SetGameTime(theGame.GetGameTime() + GameTimeCreateFromGameSeconds(seconds), false);
		UpdateEffectsAccelerated(ConvertGameSecondsToRealTimeSeconds(seconds));
	}
	
	public function IsMeditating() : bool
	{
		return GetCurrentStateName() == 'W3EEMeditation';
	}
	
	public function GetMeditationState() : W3PlayerWitcherStateW3EEMeditation
	{
		if( IsMeditating() )
		{
			return (W3PlayerWitcherStateW3EEMeditation)GetState('W3EEMeditation');
		}
		
		return NULL;
	}
	
	public function MeditationStartFastforwardMenu()
	{
		GetMeditationState().SetShouldMeditateMenu(true);
	}
	
	public function MeditationStartFastforward()
	{
		GetMeditationState().SetShouldMeditate(true);
	}
	
	public function MeditationEndFastforward()
	{
		GetMeditationState().SetShouldMeditate(false);
	}
	
	private var brewingInterrupted : bool;
	timer function MeditationStartBrewing( dt : float, id : int )
	{
		GetMeditationState().SetShouldBrew();
	}
	
	public function HasNonAlliedActorsNearby() : bool
	{
		var entities : array< CGameplayEntity >;
		var i : int;
		
		FindGameplayEntitiesInRange( entities, thePlayer, 15, 10,, FLAG_ExcludePlayer + FLAG_OnlyAliveActors,, 'CActor' );
		for( i = 0; i < entities.Size(); i += 1 )
		{
			if( ((CActor)entities[i]).GetAttitude( thePlayer ) != AIA_Friendly || ((CActor)entities[i]).GetAttitude( thePlayer ) != AIA_Neutral )
			{
				return true;
			}
		}
		return false;
	}
	
	public function UpdateEffectsAccelerated( dt : float )
	{
		effectManager.PerformUpdate(dt);
	}
	
	private var noFireCall : bool;
	public function GetNoFireCall() : bool
	{
		return noFireCall;
	}
	
	public function SetNoFireCall( b: bool )
	{
		noFireCall = b;
	}
	
	protected var inMeditationMenu : bool;
	public function SetInMeditationMenu( b : bool )
	{
		inMeditationMenu = b;
	}
	
	timer function StartW3EEMeditationTimer( dt : float, id : int )
	{
		if( IsMeditating() )
		{
			if( !inMeditationMenu )
			{
				theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'MeditationClockMenu' );
			}
			else
			{
				theGame.CloseMenu('MeditationClockMenu');
			}
		}
		else
		{
			noFireCall = true;
			StartW3EEMeditation();
		}
	}

	timer function W3EEMeditationTimer( dt : float, id : int )
	{
		if( GetCurrentStateName() != 'W3EEMeditation' )
		{
			StartW3EEMeditation();
		}
		else
		{
			EndW3EEMeditation();
		}
	}
	
	public function StartW3EEMeditation()
	{
		if( GetCurrentStateName() != 'W3EEMeditation' && CanMeditateHere() )
		{
			PushState( 'W3EEMeditation' );
		}
		else DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_here"));
	}
	
	public function EndW3EEMeditation()
	{
		if( GetCurrentStateName() == 'W3EEMeditation' && !inMeditationMenu && !GetMeditationState().IsActivelyMeditating() )
		{
			PopState();
		}
	}
	// W3EE - End
	
	public function Meditate() : bool
	{
		var medState 			: W3PlayerWitcherStateMeditation;
		var stateName 			: name;
	
		stateName = GetCurrentStateName();
	
		
		if (!CanMeditate()  || stateName == 'MeditationWaiting' )
			return false;
	
		GotoState('Meditation');
		medState = (W3PlayerWitcherStateMeditation)GetState('Meditation');		
		medState.SetMeditationPointHeading(GetHeading());
		
		return true;
	}
	
	
	public final function MeditationRestoring(simulatedTime : float)
	{	
		// W3EE - Begin
		/*if ( theGame.GetDifficultyMode() != EDM_Hard && theGame.GetDifficultyMode() != EDM_Hardcore ) 
		{
			Heal(GetStatMax(BCS_Vitality));
		}
		
		
		abilityManager.DrainToxicity( abilityManager.GetStat( BCS_Toxicity ) );
		
		abilityManager.DrainFocus( abilityManager.GetStat( BCS_Focus ) );
		
		inv.SingletonItemsRefillAmmo();
		
		
		SimulateBuffTimePassing(simulatedTime);*/
		// W3EE - End
		
		ApplyWitcherHouseBuffs();
	}
	
	var clockMenu : CR4MeditationClockMenu;
	
	public function MeditationClockStart(m : CR4MeditationClockMenu)
	{
		clockMenu = m;
		AddTimer('UpdateClockTime',0.1,true);
	}
	
	public function MeditationClockStop()
	{
		clockMenu = NULL;
		RemoveTimer('UpdateClockTime');
	}
	
	public timer function UpdateClockTime(dt : float, id : int)
	{
		if(clockMenu)
			clockMenu.UpdateCurrentHours();
		else
			RemoveTimer('UpdateClockTime');
	}
	
	private var waitTimeHour : int;
	public function SetWaitTargetHour(t : int)
	{
		waitTimeHour = t;
	}
	public function GetWaitTargetHour() : int
	{
		return waitTimeHour;
	}
	
	public function MeditationForceAbort(forceCloseUI : bool)
	{
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		var medd : W3PlayerWitcherStateMeditation;
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		if(currentStateName == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)GetCurrentState();
			if(waitt)
			{
				waitt.StopRequested(forceCloseUI);
			}
		}
		else if(currentStateName == 'Meditation')
		{
			medd = (W3PlayerWitcherStateMeditation)GetCurrentState();
			if(medd)
			{
				medd.StopRequested(forceCloseUI);
			}
		}
		
		
		if( forceCloseUI && theGame.GetGuiManager().IsAnyMenu() && !theGame.GetPhotomodeEnabled() )
		{
			theGame.GetGuiManager().GetRootMenu().CloseMenu();
			DisplayActionDisallowedHudMessage(EIAB_MeditationWaiting, false, false, true, false);
		}
		
		// W3EE - Begin
		EndW3EEMeditation();
		// W3EE - End
	}
	
	public function Runeword10Triggerred()
	{
		var min, max : SAbilityAttributeValue; 
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 10 _Stats', 'stamina', min, max );
		GainStat(BCS_Stamina, min.valueMultiplicative * GetStatMax(BCS_Stamina));
		PlayEffect('runeword_10_stamina');
	}
	
	public function Runeword12Triggerred()
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 12 _Stats', 'focus', min, max );
		GainStat(BCS_Focus, RandRangeF(max.valueAdditive, min.valueAdditive));
		PlayEffect('runeword_20_adrenaline');	
	}
	
	var runeword10TriggerredOnFinisher, runeword12TriggerredOnFinisher : bool;
	
	event OnFinisherStart()
	{
		super.OnFinisherStart();
		
		runeword10TriggerredOnFinisher = false;
		runeword12TriggerredOnFinisher = false;
	}
	
	public function ApplyWitcherHouseBuffs()
	{
		var l_bed			: W3WitcherBed;
		
		if( FactsQuerySum( "PlayerInsideInnerWitcherHouse" ) > 0 )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			
			if( l_bed.GetWasUsed() )
			{
				// W3EE - Begin
				abilityManager.DrainToxicity( abilityManager.GetStat( BCS_Toxicity ) );
				SimulateBuffTimePassing(0);
				// W3EE - End
				
				if( l_bed.GetBedLevel() != 0 )
				{
					AddEffectDefault( EET_WellRested, this, "Bed Buff" );
				}

				if( FactsQuerySum( "StablesExists" ) )
				{
					AddEffectDefault( EET_HorseStableBuff, this, "Stables" );
				}
				
				// W3EE - Begin
				if( FactsQuerySum( "AlchemyTableExists" ) )
				{
					ManageAlchemyTableBonus();
				}
				
				/*if( l_bed.GetWereItemsRefilled() )
				{
					theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_applied" ),, true );
					l_bed.SetWereItemsRefilled( false );
				}*/
				// W3EE - End
				
				AddEffectDefault( EET_BookshelfBuff, this, "Bookshelf" );
				
				Heal( GetStatMax( BCS_Vitality ) );
			}
		}
	}
	
	// W3EE - Begin
	public function ManageAlchemyTableBonus()
	{
		AddEffectDefault( EET_AlchemyTable, this, "Alchemy Table" );
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_applied" ),, true );
	}	
	// W3EE - End
	
	public function CheatResurrect()
	{
		super.CheatResurrect();
		theGame.ReleaseNoSaveLock(theGame.deathSaveLockId);
		theInput.RestoreContext( 'Exploration', true );	
	}
	
	
	public function Debug_EquipTestingSkills(equip : bool, force : bool)
	{
		var skills : array<ESkill>;
		var i, slot : int;
		
		
		((W3PlayerAbilityManager)abilityManager).OnLevelGained(36);
		
		skills.PushBack(S_Magic_s01);
		skills.PushBack(S_Magic_s02);
		skills.PushBack(S_Magic_s03);
		skills.PushBack(S_Magic_s04);
		skills.PushBack(S_Magic_s05);
		skills.PushBack(S_Sword_s01);
		skills.PushBack(S_Sword_s02);
		
		
		if(equip)
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				if(!force && IsSkillEquipped(skills[i]))
					continue;
					
				
				if(GetSkillLevel(skills[i]) == 0)
					AddSkill(skills[i]);
				
				
				if(force)
					slot = i+1;		
				else
					slot = GetFreeSkillSlot();
				
				
				EquipSkill(skills[i], slot);
			}
		}
		else
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				UnequipSkill(GetSkillSlotID(skills[i]));
			}
		}
	}
	
	public function Debug_ClearCharacterDevelopment(optional keepInv : bool)
	{
		var template : CEntityTemplate;
		var entity : CEntity;
		var invTesting : CInventoryComponent;
		var i : int;
		var items : array<SItemUniqueId>;
		var abs : array<name>;
		
		RemoveAllRepairBuffs();
		items = inv.GetItemsByCategory('steelsword');
		for(i=0; i<items.Size(); i+=1)
			inv.RemoveAllOilsFromItem(items[i]);
		items = inv.GetItemsByCategory('silversword');
		for(i=0; i<items.Size(); i+=1)
			inv.RemoveAllOilsFromItem(items[i]);
		
		//Kolaris - Mutation Rework
		if( IsMutationSystemEnabled() && FactsQuerySum("TaFtSComplete") < 1 )
			mutations = true;
			
		delete abilityManager;
		delete levelManager;
		delete effectManager;
		
		
		GetCharacterStats().GetAbilities(abs, false);
		for(i=0; i<abs.Size(); i+=1)
			RemoveAbility(abs[i]);
			
		
		abs.Clear();
		GetCharacterStatsParam(abs);		
		for(i=0; i<abs.Size(); i+=1)
			AddAbility(abs[i]);
					
		
		levelManager = new W3LevelManager in this;			
		levelManager.Initialize();
		levelManager.PostInit(this, false, true);		
						
		
		//AddAbility('GeraltSkills_Testing');
		SetAbilityManager();		
		abilityManager.Init(this, GetCharacterStats(), false, theGame.GetDifficultyMode());
		
		SetEffectManager();
		
		abilityManager.PostInit();						
		
		
		for(i=1; i<=50; i+=1)
		{
			RemoveAbilityAll( GetLevelupAbility(i) );
			AddAbility( GetLevelupAbility(i) );
		}
		
		//Kolaris - Mutation Rework
		if(mutations)
			FactsAdd("TaFtSComplete", 1);
		MutationSystemEnable( true );
		
		if( mutationSpentRed > 0 )
		{
			inv.AddAnItem('Greater mutagen red', mutationSpentRed);
			mutationSpentRed = 0;
		}
		if( mutationSpentBlue > 0 )
		{
			inv.AddAnItem('Greater mutagen blue', mutationSpentBlue);
			mutationSpentBlue = 0;
		}
		if( mutationSpentGreen > 0 )
		{
			inv.AddAnItem('Greater mutagen green', mutationSpentGreen);
			mutationSpentGreen = 0;
		}
		
		if(keepInv)
		{
			//inv.RemoveAllItems();
			return;
		}
		
		
		template = (CEntityTemplate)LoadResource("geralt_inventory_release");
		entity = theGame.CreateEntity(template, Vector(0,0,0));
		invTesting = (CInventoryComponent)entity.GetComponentByClassName('CInventoryComponent');
		invTesting.GiveAllItemsTo(inv, true);
		entity.Destroy();
		
		
		inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if(!inv.ItemHasTag(items[i], 'NoDrop'))			
				EquipItem(items[i]);
		}
		
		if( !HasBuff(EET_Poise) )
			AddEffectDefault(EET_Poise, this, "Poise");
		//Debug_GiveTestingItems(0);
	}
	
	function Debug_BearSetBonusQuenSkills()
	{
		var skills	: array<ESkill>;
		var i, slot	: int;
		
		skills.PushBack(S_Magic_s04);
		skills.PushBack(S_Magic_s14);
		
		for(i=0; i<skills.Size(); i+=1)
		{				
			
			if(GetSkillLevel(skills[i]) == 0)
			{
				AddSkill(skills[i]);
			}
			
			slot = GetFreeSkillSlot();
			
			
			EquipSkill(skills[i], slot);
		}
	}
	
	final function Debug_HAX_UnlockSkillSlot(slotIndex : int) : bool
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).Debug_HAX_UnlockSkillSlot(slotIndex);
			
		return false;
	}
	
	
	public function GetLevelupAbility( id : int) : name
	{
		switch(id)
		{
			case 1: return 'Lvl1';
			case 2: return 'Lvl2';
			case 3: return 'Lvl3';
			case 4: return 'Lvl4';
			case 5: return 'Lvl5';
			case 6: return 'Lvl6';
			case 7: return 'Lvl7';
			case 8: return 'Lvl8';
			case 9: return 'Lvl9';
			case 10: return 'Lvl10';
			case 11: return 'Lvl11';
			case 12: return 'Lvl12';
			case 13: return 'Lvl13';
			case 14: return 'Lvl14';
			case 15: return 'Lvl15';
			case 16: return 'Lvl16';
			case 17: return 'Lvl17';
			case 18: return 'Lvl18';
			case 19: return 'Lvl19';
			case 20: return 'Lvl20';
			case 21: return 'Lvl21';
			case 22: return 'Lvl22';
			case 23: return 'Lvl23';
			case 24: return 'Lvl24';
			case 25: return 'Lvl25';
			case 26: return 'Lvl26';
			case 27: return 'Lvl27';
			case 28: return 'Lvl28';
			case 29: return 'Lvl29';
			case 30: return 'Lvl30';
			case 31: return 'Lvl31';
			case 32: return 'Lvl32';
			case 33: return 'Lvl33';
			case 34: return 'Lvl34';
			case 35: return 'Lvl35';
			case 36: return 'Lvl36';
			case 37: return 'Lvl37';
			case 38: return 'Lvl38';
			case 39: return 'Lvl39';
			case 40: return 'Lvl40';
			case 41: return 'Lvl41';
			case 42: return 'Lvl42';
			case 43: return 'Lvl43';
			case 44: return 'Lvl44';
			case 45: return 'Lvl45';
			case 46: return 'Lvl46';
			case 47: return 'Lvl47';
			case 48: return 'Lvl48';
			case 49: return 'Lvl49';
			case 50: return 'Lvl50';
		
			default: return '';
		}
		
		return '';
	}	
	
	public function CanSprint( speed : float ) : bool
	{
		if( !super.CanSprint( speed ) )
		{
			return false;
		}		
		if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			if ( this.GetPlayerCombatStance() ==  PCS_AlertNear )
			{
				if ( IsSprintActionPressed() )
					OnRangedForceHolster( true, false );
			}
			else
				return false;
		}
		if( GetCurrentStateName() != 'Swimming' && GetStat(BCS_Stamina) <= 0 )
		{
			SetSprintActionPressed(false,true);
			return false;
		}
		
		return true;
	}
	
	public function ManageSleeping()
	{
		thePlayer.RemoveBuffImmunity_AllCritical( 'Bed' );
		thePlayer.RemoveBuffImmunity_AllNegative( 'Bed' );

		thePlayer.PlayerStopAction( PEA_GoToSleep );
	}
	
	
	
	public function RestoreHorseManager() : bool
	{
		var horseTemplate 	: CEntityTemplate;
		var horseManager 	: W3HorseManager;	
		
		if ( GetHorseManager() )
		{
			return false;
		}
		
		horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
		horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
		horseManager.CreateAttachment(this);
		horseManager.OnCreated();
		EntityHandleSet( horseManagerHandle, horseManager );	
		
		return true;
	}
	
	
	
	
	
	
	final function PerformParryCheck( parryInfo : SParryInfo ) : bool
	{
		if( super.PerformParryCheck( parryInfo ) )
		{
			// W3EE - Begin
			// GainAdrenalineFromPerk21( 'parry' );
			// W3EE - End
			return true;
		}
		return false;
	}	
	
	protected final function PerformCounterCheck( parryInfo: SParryInfo ) : bool
	{
		var fistFightCheck, isInFistFight		: bool;
		
		if( super.PerformCounterCheck( parryInfo ) )
		{
			// W3EE - Begin
			// GainAdrenalineFromPerk21( 'counter' );
			// W3EE - End
			
			isInFistFight = FistFightCheck( parryInfo.target, parryInfo.attacker, fistFightCheck );
			
			if( isInFistFight && fistFightCheck )
			{
				FactsAdd( "statistics_fist_fight_counter" );
				AddTimer( 'FistFightCounterTimer', 0.5f, , , , true );
			}
			
			return true;
		}
		return false;
	}
	
	public function GainAdrenalineFromPerk21( n : name )
	{
		var perkStats, perkTime : SAbilityAttributeValue;
		var targets	: array<CActor>;
		
		targets = GetHostileEnemies();
		
		if( !CanUseSkill( S_Perk_21 ) || targets.Size() == 0 )
		{
			return;
		}
		
		perkTime = GetSkillAttributeValue( S_Perk_21, 'perk21Time', false, false );
		
		if( theGame.GetEngineTimeAsSeconds() >= timeForPerk21 + perkTime.valueAdditive )
		{
			perkStats = GetSkillAttributeValue( S_Perk_21, n , false, false );
			GainStat( BCS_Focus, perkStats.valueAdditive );
			timeForPerk21 = theGame.GetEngineTimeAsSeconds();
			
			AddEffectDefault( EET_Perk21InternalCooldown, this, "Perk21", false );
		}	
	}
	
	timer function FistFightCounterTimer( dt : float, id : int )
	{
		FactsRemove( "statistics_fist_fight_counter" );
	}
	
	public final function IsSignBlocked(signType : ESignType) : bool
	{
		switch( signType )
		{
			case ST_Aard :
				return IsRadialSlotBlocked ( 'Aard');
				break;
			case ST_Axii :
				return IsRadialSlotBlocked ( 'Axii');
				break;
			case ST_Igni :
				return IsRadialSlotBlocked ( 'Igni');
				break;
			case ST_Quen :
				return IsRadialSlotBlocked ( 'Quen');
				break;
			case ST_Yrden :
				return IsRadialSlotBlocked ( 'Yrden');
				break;
			default:
				break;
		}
		return false;
		
	}
	
	public final function AddAnItemWithAutogenLevelAndQuality(itemName : name, desiredLevel : int, minQuality : int, optional equipItem : bool)
	{
		var itemLevel, quality : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;
		
		itemLevel = 0;
		quality = 0;
		attemptCounter = 0;
		while(itemLevel != desiredLevel || quality < minQuality)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			itemLevel = inv.GetItemLevel(ids[0]);
			quality = RoundMath(CalculateAttributeValue(inv.GetItemAttributeValue(ids[0], 'quality')));
			
			
			if(attemptCounter >= 1000)
				break;
			
			if(itemLevel != desiredLevel || quality < minQuality)
				inv.RemoveItem(ids[0]);
		}
		
		if(equipItem)
			EquipItem(ids[0]);
	}
	
	public final function AddAnItemWithAutogenLevel(itemName : name, desiredLevel : int)
	{
		var itemLevel : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;

		itemLevel = 0;
		while(itemLevel != desiredLevel)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			itemLevel = inv.GetItemLevel(ids[0]);
			
			
			if(attemptCounter >= 1000)
				break;
				
			if(itemLevel != desiredLevel)
				inv.RemoveItem(ids[0]);
		}
	}
	
	public final function AddAnItemWithMinQuality(itemName : name, minQuality : int, optional equip : bool)
	{
		var quality : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;

		quality = 0;
		while(quality < minQuality)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			quality = RoundMath(CalculateAttributeValue(inv.GetItemAttributeValue(ids[0], 'quality')));
			
			
			if(attemptCounter >= 1000)
				break;
				
			if(quality < minQuality)
				inv.RemoveItem(ids[0]);
		}
		
		if(equip)
			EquipItem(ids[0]);
	}
	
	
	
	
	
	//Kolaris - Armor Set Bonus Setup, Kolaris - Set Bonus Count Option
	public function IsSetBonusActive( bonus : EItemSetBonus ) : bool
	{
		switch(bonus)
		{
			case EISB_Lynx_1:			return amountOfSetPiecesEquipped[ EIST_Lynx ] + amountOfSetPiecesEquipped[ EIST_MinorLynx ] >= Options().SetBonusCountFirst();
			case EISB_Lynx_2:			return amountOfSetPiecesEquipped[ EIST_Lynx ] >= Options().SetBonusCountSecond();
			case EISB_Gryphon_2:		return amountOfSetPiecesEquipped[ EIST_Gryphon ] + amountOfSetPiecesEquipped[ EIST_MinorGryphon ] >= Options().SetBonusCountFirst();
			case EISB_Gryphon_1:		return amountOfSetPiecesEquipped[ EIST_Gryphon ] >= Options().SetBonusCountSecond();
			case EISB_Bear_1:			return amountOfSetPiecesEquipped[ EIST_Bear ] + amountOfSetPiecesEquipped[ EIST_MinorBear ] >= Options().SetBonusCountFirst();
			case EISB_Bear_2:			return amountOfSetPiecesEquipped[ EIST_Bear ] >= Options().SetBonusCountSecond();
			case EISB_Wolf_1:			return amountOfSetPiecesEquipped[ EIST_Wolf ] + amountOfSetPiecesEquipped[ EIST_MinorWolf ] >= Options().SetBonusCountFirst();
			case EISB_Wolf_2:			return amountOfSetPiecesEquipped[ EIST_Wolf ] >= Options().SetBonusCountSecond();
			case EISB_RedWolf_1:		return amountOfSetPiecesEquipped[ EIST_RedWolf ] + amountOfSetPiecesEquipped[ EIST_MinorRedWolf ] >= Options().SetBonusCountFirst();
			case EISB_RedWolf_2:		return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= Options().SetBonusCountSecond();
			case EISB_Vampire:			return amountOfSetPiecesEquipped[ EIST_Vampire ] >= Options().SetBonusCountFirst();
			case EISB_Vampire_2:		return amountOfSetPiecesEquipped[ EIST_Vampire ] >= Options().SetBonusCountSecond();
			case EISB_Vampire_Alt_1:	return amountOfSetPiecesEquipped[ EIST_Vampire_Alt ] >= Options().SetBonusCountFirst();
			case EISB_Vampire_Alt_2:	return amountOfSetPiecesEquipped[ EIST_Vampire_Alt ] >= Options().SetBonusCountSecond();
			case EISB_Temerian:			return amountOfSetPiecesEquipped[ EIST_Temerian ] >= Options().SetBonusCountFirst();
			case EISB_Nilfgaard:		return amountOfSetPiecesEquipped[ EIST_Nilfgaard ] >= Options().SetBonusCountFirst();
			case EISB_Skellige:			return amountOfSetPiecesEquipped[ EIST_Skellige ] >= Options().SetBonusCountFirst();
			case EISB_Ofieri:			return amountOfSetPiecesEquipped[ EIST_Ofieri ] >= Options().SetBonusCountFirst();
			case EISB_New_Moon:			return amountOfSetPiecesEquipped[ EIST_New_Moon ] >= Options().SetBonusCountFirst();
			case EISB_Netflix_1:		return amountOfSetPiecesEquipped[ EIST_Netflix ] + amountOfSetPiecesEquipped[ EIST_MinorNetflix ] >= Options().SetBonusCountFirst();
			case EISB_Netflix_2:		return amountOfSetPiecesEquipped[ EIST_Netflix ] >= Options().SetBonusCountSecond();
			case EISB_Elven_1:			return amountOfSetPiecesEquipped[ EIST_Elven ] >= Options().SetBonusCountFirst();
			case EISB_Elven_2:			return amountOfSetPiecesEquipped[ EIST_Elven ] >= Options().SetBonusCountSecond();
			case EISB_Tiger_1:			return amountOfSetPiecesEquipped[ EIST_Tiger ] >= Options().SetBonusCountFirst();
			case EISB_Tiger_2:			return amountOfSetPiecesEquipped[ EIST_Tiger ] >= Options().SetBonusCountSecond();
			case EISB_Viper2:			return amountOfSetPiecesEquipped[ EIST_Viper ] + amountOfSetPiecesEquipped[ EIST_MinorViper ] >= Options().SetBonusCountFirst();
			case EISB_Viper1:			return amountOfSetPiecesEquipped[ EIST_Viper ] >= Options().SetBonusCountSecond();
			case EISB_Gothic1:			return amountOfSetPiecesEquipped[ EIST_Gothic ] + IsHelmetEquipped(EIST_Gothic) >= Options().SetBonusCountFirst();
			case EISB_Gothic2:			return amountOfSetPiecesEquipped[ EIST_Gothic ] + IsHelmetEquipped(EIST_Gothic) >= Options().SetBonusCountFirst();
			case EISB_Dimeritium1:		return amountOfSetPiecesEquipped[ EIST_Dimeritium ] + IsHelmetEquipped(EIST_Dimeritium) >= Options().SetBonusCountFirst();
			case EISB_Dimeritium2:		return amountOfSetPiecesEquipped[ EIST_Dimeritium ] + IsHelmetEquipped(EIST_Dimeritium) >= Options().SetBonusCountFirst();
			case EISB_Meteorite:		return amountOfSetPiecesEquipped[ EIST_Meteorite ] + IsHelmetEquipped(EIST_Meteorite) >= Options().SetBonusCountFirst();
			default:					return false;
		}
	}
	
	// W3EE - Begin
	public function GetSetPartsEquipped( setType : EItemSetType ) : int
	{
		//Kolaris - Matched Set Bonus Removal
		/*if( setType == EIST_LightArmor )
			return armorPiecesOriginal[0].all + armorPiecesOriginal[1].all;
		else
		if( setType == EIST_MediumArmor )
			return armorPiecesOriginal[2].all;
		else
		if( setType == EIST_HeavyArmor )
			return armorPiecesOriginal[3].all;
		else*/
		if( IsMinorSetType(setType) )
			return amountOfSetPiecesEquipped[ setType ] + amountOfSetPiecesEquipped[ GetSetTypeMajor(setType) ] + IsHelmetEquipped(setType);
		else
			return amountOfSetPiecesEquipped[ setType ] + amountOfSetPiecesEquipped[ GetSetTypeMinor(setType) ] + IsHelmetEquipped(setType);
	}
	
	public function IsMinorSetType( setType : EItemSetType ) : bool
	{
		switch(setType)
		{
			case EIST_MinorLynx:
			case EIST_MinorGryphon:
			case EIST_MinorBear:
			case EIST_MinorWolf:
			case EIST_MinorRedWolf:
			case EIST_MinorViper:
			case EIST_MinorNetflix:
				return true;
			default:
				return false;
		}
	}
	
	public function GetSetTypeMinor( setType : EItemSetType ) : EItemSetType
	{
		switch(setType)
		{
			case EIST_Lynx:			return EIST_MinorLynx;
			case EIST_Gryphon:		return EIST_MinorGryphon;
			case EIST_Bear:			return EIST_MinorBear;
			case EIST_Wolf:			return EIST_MinorWolf;
			case EIST_RedWolf:		return EIST_MinorRedWolf;
			case EIST_Viper:		return EIST_MinorViper;
			case EIST_Netflix:		return EIST_MinorNetflix;
			default:				return EIST_Undefined;
		}
	}
	
	public function GetSetTypeMajor( setType : EItemSetType ) : EItemSetType
	{
		switch(setType)
		{
			case EIST_MinorLynx:			return EIST_Lynx;
			case EIST_MinorGryphon:			return EIST_Gryphon;
			case EIST_MinorBear:			return EIST_Bear;
			case EIST_MinorWolf:			return EIST_Wolf;
			case EIST_MinorRedWolf:			return EIST_RedWolf;
			case EIST_MinorViper:			return EIST_Viper;
			case EIST_MinorNetflix:			return EIST_Netflix;
			default:						return EIST_Undefined;
		}
	}
	
	private saved var currentHelmet : EItemSetType;
	public function SetCurrentHelmet( type : EItemSetType )
	{
		currentHelmet = type;
	}
	
	public function IsHelmetEquipped( type : EItemSetType ) : int
	{
		if( currentHelmet == type && FactsDoesExist("isWearingHelmet") )
			return 1;
			
		return 0;
	}
	
	//Kolaris - Set Item Count Fix
	public function ClearAllSetBonuses()
	{
		var setType : EItemSetType;
		var i : int;
		
		for(i=1; i<=EnumGetMax('EItemSetType'); i+=1)
		{
			setType = (EItemSetType)i;
			amountOfSetPiecesEquipped[ setType ] = 0;
		}
	}
	
	public function UpdateAllSetBonuses( increment : bool )
	{
		var setType : EItemSetType;
		var tutorialStateSets : W3TutorialManagerUIHandlerStateSetItemsUnlocked;
		var id : SItemUniqueId;
		var i : int;
		
		for(i=1; i<=EnumGetMax('EItemSetType')-8; i+=1)
		{
			setType = (EItemSetType)i;
			
			if( increment )
			{
				amountOfSetPiecesEquipped[ setType ] += 1;
				
				if( amountOfSetPiecesEquipped[ setType ] >= Options().SetBonusCountFirst() && ShouldProcessTutorial( 'TutorialSetBonusesUnlocked' ) && theGame.GetTutorialSystem().uiHandler && theGame.GetTutorialSystem().uiHandler.GetCurrentStateName() == 'SetItemsUnlocked' )
				{
					tutorialStateSets = ( W3TutorialManagerUIHandlerStateSetItemsUnlocked )theGame.GetTutorialSystem().uiHandler.GetCurrentState();
					tutorialStateSets.OnSetBonusCompleted();
				}
			}
			else if( amountOfSetPiecesEquipped[ setType ] > 0 )
			{
				amountOfSetPiecesEquipped[ setType ] -= 1;
			}
			
			if( setType != EIST_Vampire && amountOfSetPiecesEquipped[ setType ] == Options().SetBonusCountSecond() )
			{
				theGame.GetGamerProfile().AddAchievement( EA_ReadyToRoll );
			}
			
			if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
			{
				RemoveExtraOilsFromItem( id, ( increment && IsSetBonusActive( EISB_Viper1 ) ), CanUseSkill(S_Alchemy_s07) );
			}
			if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
			{
				RemoveExtraOilsFromItem( id, ( increment && IsSetBonusActive( EISB_Viper1 ) ), CanUseSkill(S_Alchemy_s07)  );
			}
			
			ManageActiveSetBonuses( setType );
			
			ManageSetBonusesSoundbanks( setType );
		}
	}
	
	public function UpdateItemSetBonuses( item : SItemUniqueId, increment : bool )
	{
		var setType : EItemSetType;
		var tutorialStateSets : W3TutorialManagerUIHandlerStateSetItemsUnlocked;
		var id : SItemUniqueId;
					
		if( !inv.IsIdValid( item ) || !inv.IsItemSetItem(item) )  
		{
			
			if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
			{
				RemoveExtraOilsFromItem( id, IsSetBonusActive( EISB_Viper1 ) , CanUseSkill(S_Alchemy_s07) );
			}
			if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
			{
				RemoveExtraOilsFromItem( id, IsSetBonusActive( EISB_Viper1 ) , CanUseSkill(S_Alchemy_s07) );
			}
		
			return;
		}
		
		setType = CheckSetType( item );
		
		//Kolaris - Set Item Count Fix
		if( setType != EIST_Undefined && setType != EIST_LightArmor && setType != EIST_MediumArmor && setType != EIST_HeavyArmor )
		{
			if( increment )
			{
				amountOfSetPiecesEquipped[ setType ] += 1;
				
				if( amountOfSetPiecesEquipped[ setType ] >= Options().SetBonusCountFirst() && ShouldProcessTutorial( 'TutorialSetBonusesUnlocked' ) && theGame.GetTutorialSystem().uiHandler && theGame.GetTutorialSystem().uiHandler.GetCurrentStateName() == 'SetItemsUnlocked' )
				{
					tutorialStateSets = ( W3TutorialManagerUIHandlerStateSetItemsUnlocked )theGame.GetTutorialSystem().uiHandler.GetCurrentState();
					tutorialStateSets.OnSetBonusCompleted();
				}
			}
			else if( amountOfSetPiecesEquipped[ setType ] > 0 )
			{
				amountOfSetPiecesEquipped[ setType ] -= 1;
				if( !IsAnyItemEquippedOnSlot(EES_SteelSword) && !IsAnyItemEquippedOnSlot(EES_SilverSword) && !IsAnyItemEquippedOnSlot(EES_Armor) && !IsAnyItemEquippedOnSlot(EES_Pants) && !IsAnyItemEquippedOnSlot(EES_Boots) && !IsAnyItemEquippedOnSlot(EES_Gloves) )
				{
					amountOfSetPiecesEquipped[ setType ] = 0;
				}
			}
		}
		else if( amountOfSetPiecesEquipped[ setType ] > 0 && !IsAnyItemEquippedOnSlot(EES_SteelSword) && !IsAnyItemEquippedOnSlot(EES_SilverSword) && !IsAnyItemEquippedOnSlot(EES_Armor) && !IsAnyItemEquippedOnSlot(EES_Pants) && !IsAnyItemEquippedOnSlot(EES_Boots) && !IsAnyItemEquippedOnSlot(EES_Gloves) )
		{
			amountOfSetPiecesEquipped[ setType ] = 0;
		}
		
		if( setType != EIST_Vampire )
		{
			if(amountOfSetPiecesEquipped[ setType ] == Options().SetBonusCountSecond())
			{
				theGame.GetGamerProfile().AddAchievement( EA_ReadyToRoll );
			}
			else 
			{
				theGame.GetGamerProfile().NoticeAchievementProgress( EA_ReadyToRoll, amountOfSetPiecesEquipped[ setType ]);
			}
		}
		

		if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
		{
			RemoveExtraOilsFromItem( id, IsSetBonusActive( EISB_Viper1 ) , CanUseSkill(S_Alchemy_s07) );
		}
		if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
		{
			RemoveExtraOilsFromItem( id, IsSetBonusActive( EISB_Viper1 ) , CanUseSkill(S_Alchemy_s07) );
		}
		
		ManageActiveSetBonuses( setType );
		
		
		ManageSetBonusesSoundbanks( setType );
	}
	// W3EE - End
	
	public function ManageActiveSetBonuses( setType : EItemSetType )
	{
		var l_i				: int;
		
		
		if( setType == EIST_Lynx )
		{
			
			if( HasBuff( EET_LynxSetBonus ) && !IsSetBonusActive( EISB_Lynx_1 ) )
			{
				RemoveBuff( EET_LynxSetBonus );
			}
		}
		// W3EE - Begin
		else
		if( setType == EIST_Dimeritium )
		{
			if( !IsSetBonusActive(EISB_Dimeritium1) )
			{
				((W3Effect_DimeritiumCharge)GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).SetDimeritiumCharge(0);
				RemoveBuff(EET_DimeritiumCharge);
			}
		}
		/*else
		if( setType == EIST_Bear )
		{
			if( !IsSetBonusActive(EISB_Bear_2) )
				RemoveBuff(EET_WolfSetParry);
		}*/
		// W3EE - End
		else if( setType == EIST_Gryphon )
		{
			
			if( !IsSetBonusActive( EISB_Gryphon_1 ) )
			{
				RemoveBuff( EET_GryphonSetBonus );
			}
			
			/*if( IsSetBonusActive( EISB_Gryphon_2 ) && !HasBuff( EET_GryphonSetBonusYrden ) )
			{
				for( l_i = 0 ; l_i < yrdenEntities.Size() ; l_i += 1 )
				{
					if( yrdenEntities[ l_i ].GetIsPlayerInside() && !yrdenEntities[ l_i ].IsAlternateCast() )
					{
						AddEffectDefault( EET_GryphonSetBonusYrden, this, "GryphonSetBonusYrden" );
						break;
					}
				}
			}
			else
			{
				RemoveBuff( EET_GryphonSetBonusYrden );
			}*/
		}
		else
		if( setType == EIST_MediumArmor )
		{
			//Kolaris - Matched Set Bonus Removal
			/*if( IsSetBonusActive(EISB_MediumArmor) )
				AddAbility('MediumSetBonusAbility', false);
			else*/
				RemoveAbility('MediumSetBonusAbility');
		}
	}
	
	//Kolaris - Armor Set Bonus Setup
	public function CheckSetTypeByName( itemName : name ) : EItemSetType
	{
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_LYNX ) )
		{
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_Lynx;
			else
				return EIST_MinorLynx;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GRYPHON ) )
		{
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_Gryphon;
			else
				return EIST_MinorGryphon;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_BEAR ) )
		{
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_Bear;
			else
				return EIST_MinorBear;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_WOLF ) )
		{
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_Wolf;
			else
				return EIST_MinorWolf;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_RED_WOLF ) )
		{
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_RedWolf;
			else
				return EIST_MinorRedWolf;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VAMPIRE ) )
		{
			return EIST_Vampire;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VAMPIRE_ALT ) )
		{
			return EIST_Vampire_Alt;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_TEMERIAN ) )
		{
			return EIST_Temerian;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_NILFGAARD ) )
		{
			return EIST_Nilfgaard;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_SKELLIGE ) )
		{
			return EIST_Skellige;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_OFIERI ) )
		{
			return EIST_Ofieri;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_NEW_MOON ) )
		{
			return EIST_New_Moon;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_NETFLIX ) )
		{
			return EIST_Netflix;
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_Netflix;
			else
				return EIST_MinorNetflix;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_ELVEN ) )
		{
			return EIST_Elven;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_TIGER ) )
		{
			return EIST_Tiger;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VIPER ) )
		{
			if( dm.ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BONUS) )
				return EIST_Viper;
			else
				return EIST_MinorViper;
		}
		// W3EE - Begin
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GOTHIC ) )
		{
			return EIST_Gothic;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_DIMERITIUM ) )
		{
			return EIST_Dimeritium;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_METEORITE ) )
		{
			return EIST_Meteorite;
		}
		//Kolaris - Matched Set Bonus Removal
		/*else
		if( inv.GetArmorTypeOriginal(inv.GetItemId(itemName)) == EAT_Light )
		{
			return EIST_LightArmor;
		}
		else
		if( inv.GetArmorTypeOriginal(inv.GetItemId(itemName)) == EAT_Medium )
		{
			return EIST_MediumArmor;
		}
		else
		if( inv.GetArmorTypeOriginal(inv.GetItemId(itemName)) == EAT_Heavy )
		{
			return EIST_HeavyArmor;
		}*/
		// W3EE - End
		else
		{
			return EIST_Undefined;
		}
	}
	
	//Kolaris - Armor Set Bonus Setup
	public function CheckSetType( item : SItemUniqueId ) : EItemSetType
	{
		var stopLoop 	: bool;
		var tags 		: array<name>;
		var i 			: int;
		var setType 	: EItemSetType;
		
		stopLoop = false;
		
		inv.GetItemTags( item, tags );
		
		
		for( i=0; i<tags.Size(); i+=1 )
		{
			switch( tags[i] )
			{
				case theGame.params.ITEM_SET_TAG_LYNX:
				case theGame.params.ITEM_SET_TAG_GRYPHON:
				case theGame.params.ITEM_SET_TAG_BEAR:
				case theGame.params.ITEM_SET_TAG_WOLF:
				case theGame.params.ITEM_SET_TAG_RED_WOLF:
				case theGame.params.ITEM_SET_TAG_VAMPIRE:
				case theGame.params.ITEM_SET_TAG_VAMPIRE_ALT:
				case theGame.params.ITEM_SET_TAG_TEMERIAN:
				case theGame.params.ITEM_SET_TAG_NILFGAARD:
				case theGame.params.ITEM_SET_TAG_SKELLIGE:
				case theGame.params.ITEM_SET_TAG_OFIERI:
				case theGame.params.ITEM_SET_TAG_NEW_MOON:
				case theGame.params.ITEM_SET_TAG_NETFLIX:
				case theGame.params.ITEM_SET_TAG_ELVEN:
				case theGame.params.ITEM_SET_TAG_TIGER:
				case theGame.params.ITEM_SET_TAG_VIPER:
				case theGame.params.ITEM_SET_TAG_GOTHIC:
				case theGame.params.ITEM_SET_TAG_DIMERITIUM:
				case theGame.params.ITEM_SET_TAG_METEORITE:
					setType = SetItemNameToType( tags[i] );
					stopLoop = true;
					break;
			}		
			if ( stopLoop )
			{
				break;
			}
		}
		
		// W3EE - Begin
		if( !inv.IsItemGrandmasterItem(item) )
		{
			switch(setType)
			{
				case EIST_Lynx:
					return EIST_MinorLynx;
				case EIST_Gryphon:
					return EIST_MinorGryphon;
				case EIST_Bear:
					return EIST_MinorBear;
				case EIST_Wolf:
					return EIST_MinorWolf;
				case EIST_RedWolf:
					return EIST_MinorRedWolf;
				case EIST_Viper:
					return EIST_MinorViper;
				case EIST_Netflix:
					return EIST_MinorNetflix;
				default: break;
			}
		}
		//Kolaris - Matched Set Bonus Removal
		/*if( !stopLoop )
		{
			if( inv.GetArmorTypeOriginal(item) == EAT_Light )
				return EIST_LightArmor;
			else
			if( inv.GetArmorTypeOriginal(item) == EAT_Medium )
				return EIST_MediumArmor;
			else
			if( inv.GetArmorTypeOriginal(item) == EAT_Heavy )
				return EIST_HeavyArmor;
		}*/
		// W3EE - End
		
		return setType;
	}
	
	public function GetSetBonusStatusByName( itemName : name, out desc1, desc2 : string, out isActive1, isActive2 : bool ) : EItemSetType
	{
		var setType : EItemSetType;
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			setType = CheckSetTypeByName( itemName );
			SetBonusStatusByType( setType, desc1, desc2, isActive1, isActive2 );
			
			return setType;		
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	public function GetSetBonusStatus( item : SItemUniqueId, out desc1, desc2 : string, out isActive1, isActive2 : bool ) : EItemSetType
	{
		var setType : EItemSetType;
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			setType = CheckSetType( item );
			SetBonusStatusByType( setType, desc1, desc2, isActive1, isActive2 );
			
			return setType;
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	private function SetBonusStatusByType(setType : EItemSetType, out desc1, desc2 : string, out isActive1, isActive2 : bool):void
	{
		var setBonus : EItemSetBonus;
		
		// W3EE - Begin
		isActive1 = IsSetBonusActive(ItemSetTypeToItemSetBonus(setType, 1));
		isActive2 = IsSetBonusActive(ItemSetTypeToItemSetBonus(setType, 2));
		
		setBonus = ItemSetTypeToItemSetBonus(setType, 1);
		desc1 = GetSetBonusTooltipDescription(setBonus);
		
		setBonus = ItemSetTypeToItemSetBonus(setType, 2);
		desc2 = GetSetBonusTooltipDescription(setBonus);
		// W3EE - End
	}
	
	//Kolaris - Armor Set Bonus Setup
	public function ItemSetTypeToItemSetBonus( setType : EItemSetType, nr : int ) : EItemSetBonus
	{
		var setBonus : EItemSetBonus;
	
		if( nr == 1 )
		{
			switch( setType )
			{
				case EIST_Lynx:
				case EIST_MinorLynx: 		setBonus = EISB_Lynx_1;		break;
				case EIST_Gryphon:
				case EIST_MinorGryphon: 	setBonus = EISB_Gryphon_2;	break;
				case EIST_Bear:
				case EIST_MinorBear: 		setBonus = EISB_Bear_1;		break;
				case EIST_Wolf:
				case EIST_MinorWolf: 		setBonus = EISB_Wolf_1;		break;
				case EIST_RedWolf:
				case EIST_MinorRedWolf: 	setBonus = EISB_RedWolf_1;	break;
				case EIST_Vampire:			setBonus = EISB_Vampire;	break;
				case EIST_Vampire_Alt:		setBonus = EISB_Vampire_Alt_1;	break;
				case EIST_Temerian:			setBonus = EISB_Temerian;	break;
				case EIST_Nilfgaard:		setBonus = EISB_Nilfgaard;	break;
				case EIST_Skellige:			setBonus = EISB_Skellige;	break;
				case EIST_Ofieri:			setBonus = EISB_Ofieri;		break;
				case EIST_New_Moon:			setBonus = EISB_New_Moon;	break;
				case EIST_Netflix:
				case EIST_MinorNetflix:		setBonus = EISB_Netflix_1;	break;
				case EIST_Elven:			setBonus = EISB_Elven_1;	break;
				case EIST_Tiger:			setBonus = EISB_Tiger_1;	break;
				case EIST_Viper:
				case EIST_MinorViper:		setBonus = EISB_Viper2;		break;
				case EIST_Gothic:			setBonus = EISB_Gothic1;		break;
				case EIST_Dimeritium:		setBonus = EISB_Dimeritium1;	break;
				case EIST_Meteorite:		setBonus = EISB_Undefined;		break;
				case EIST_LightArmor:		setBonus = EISB_LightArmor;		break;
				case EIST_MediumArmor:		setBonus = EISB_MediumArmor;	break;
				case EIST_HeavyArmor:		setBonus = EISB_HeavyArmor;		break;
				default: 					setBonus = EISB_Undefined;		break;
			}
		}
		else
		{
			switch( setType )
			{
				case EIST_Lynx: 			setBonus = EISB_Lynx_2;		break;
				case EIST_Gryphon: 			setBonus = EISB_Gryphon_1;	break;
				case EIST_Bear: 			setBonus = EISB_Bear_2;		break;
				case EIST_Wolf: 			setBonus = EISB_Wolf_2;		break;
				case EIST_RedWolf: 			setBonus = EISB_RedWolf_2;	break;
				case EIST_Viper: 			setBonus = EISB_Viper1;	break;
				case EIST_Vampire:			setBonus = EISB_Vampire_2;	break;
				case EIST_Vampire_Alt:		setBonus = EISB_Vampire_Alt_2;	break;
				case EIST_Netflix:			setBonus = EISB_Netflix_2;	break;
				case EIST_Elven:			setBonus = EISB_Elven_2;	break;
				case EIST_Tiger:			setBonus = EISB_Tiger_2;	break;
				case EIST_Gothic:			setBonus = EISB_Gothic2;		break;
				case EIST_Dimeritium:		setBonus = EISB_Dimeritium2;	break;
				case EIST_Meteorite:		setBonus = EISB_Meteorite;		break;
				default: 					setBonus = EISB_Undefined;		break;
			}
		} 
	
		return setBonus;
	}
	
	//Kolaris - Armor Set Bonus Setup
	public function GetSetBonusTooltipDescription( bonus : EItemSetBonus ) : string
	{
		var finalString : string;
		var arrString	: array<string>;
		var dm			: CDefinitionsManagerAccessor;
		var min, max 	: SAbilityAttributeValue;
		var tempString	: string;
		
		switch( bonus )
		{
			case EISB_Lynx_1:			tempString = "skill_desc_lynx_set_ability1"; break;
			case EISB_Lynx_2:			tempString = "skill_desc_lynx_set_ability2"; break;
			case EISB_Gryphon_1:		tempString = "skill_desc_gryphon_set_ability1"; break;
			case EISB_Gryphon_2:		tempString = "skill_desc_gryphon_set_ability2"; break;
			case EISB_Bear_1:			tempString = "skill_desc_bear_set_ability1"; break;
			case EISB_Bear_2:			tempString = "skill_desc_bear_set_ability2"; break;
			case EISB_Wolf_1:			tempString = "skill_desc_wolf_set_ability1"; break;
			case EISB_Wolf_2:			tempString = "skill_desc_wolf_set_ability2"; break;
			case EISB_RedWolf_1:		tempString = "skill_desc_red_wolf_set_ability1"; break;
			case EISB_RedWolf_2:		tempString = "skill_desc_red_wolf_set_ability2"; break;
			case EISB_Vampire:			tempString = "skill_desc_vampire_set_ability1"; break;
			case EISB_Vampire_2:		tempString = "skill_desc_vampire_set_ability2"; break;
			case EISB_Vampire_Alt_1:	tempString = "skill_desc_vampire_set_ability3"; break;
			case EISB_Vampire_Alt_2:	tempString = "skill_desc_vampire_set_ability4"; break;
			case EISB_Temerian:			tempString = "skill_desc_temerian_set_ability1"; break;
			case EISB_Nilfgaard:		tempString = "skill_desc_nilfgaard_set_ability1"; break;
			case EISB_Skellige:			tempString = "skill_desc_skellige_set_ability1"; break;
			case EISB_Ofieri:			tempString = "skill_desc_ofieri_set_ability1"; break;
			case EISB_New_Moon:			tempString = "skill_desc_new_moon_set_ability1"; break;
			case EISB_Netflix_1:		tempString = "skill_desc_netflix_set_ability1"; break;
			case EISB_Netflix_2:		tempString = "skill_desc_netflix_set_ability2"; break;
			case EISB_Elven_1:			tempString = "skill_desc_elven_set_ability1"; break;
			case EISB_Elven_2:			tempString = "skill_desc_elven_set_ability2"; break;
			case EISB_Tiger_1:			tempString = "skill_desc_tiger_set_ability1"; break;
			case EISB_Tiger_2:			tempString = "skill_desc_tiger_set_ability2"; break;
			case EISB_Viper1:			tempString = "skill_desc_viper_set_ability2"; break;
			case EISB_Viper2:			tempString = "skill_desc_viper_set_ability1"; break;
			case EISB_Gothic1:			tempString = "GothicDescription"; break;
			case EISB_Gothic2:			tempString = "GothicDescription2"; break;
			case EISB_Dimeritium1:		tempString = "DimeritiumDescription"; break;
			case EISB_Dimeritium2:		tempString = "DimeritiumDescription2"; break;
			case EISB_Meteorite:		tempString = "MeteoriteDescription"; break;
			case EISB_LightArmor:		tempString = "GenericLightArmorBonus"; break;
			case EISB_MediumArmor:		tempString = "GenericMediumArmorBonus"; break;
			case EISB_HeavyArmor:		tempString = "GenericHeavyArmorBonus"; break;
			default:					tempString = ""; break;
		}
		
		dm = theGame.GetDefinitionsManager();
		
		switch( bonus )
		{
		case EISB_Lynx_1:
			/*dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'duration', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_dmg_boost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) );*/
			
			arrString.PushBack( IntToString(10) );
			arrString.PushBack( IntToString(5) );
			arrString.PushBack( IntToString(10) );
			arrString.PushBack( IntToString(5) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Lynx_2:
			/*dm.GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_dmg_boost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) );
			dm.GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_adrenaline_cost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) );*/
			
			arrString.PushBack( IntToString(5) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Gryphon_2:
			/*dm.GetAbilityAttributeValue( 'GryphonSetBonusEffect', 'duration', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );*/
			
			arrString.PushBack( FloatToString( 0.5f ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString ); 
			break;		
		case EISB_Gryphon_1:
			/*dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'staminaRegen', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'spell_power', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'gryphon_set_bns_dmg_reduction', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			arrString.PushBack( FloatToString( ( min.valueAdditive - 1 )* 100) );
			arrString.PushBack( FloatToString( 0.2f * 100) );*/
			
			arrString.PushBack( IntToString(10) );
			arrString.PushBack( IntToString(20) );
			arrString.PushBack( IntToString(20) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Bear_1:
			/*dm.GetAbilityAttributeValue( 'setBonusAbilityBear_1', 'quen_reapply_chance', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100 ) );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100 * amountOfSetPiecesEquipped[ EIST_Bear ] ) );*/
			
			arrString.PushBack( IntToString(10) );
			arrString.PushBack( FloatToString(5.f * Options().StamCostGlobal()) );
			arrString.PushBack( IntToString(5) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Bear_2:
			arrString.PushBack( FloatToString(0.2f) );
			arrString.PushBack( FloatToString(0.3f) );
			arrString.PushBack( FloatToString(0.2f) );
			arrString.PushBack( FloatToString(0.3f) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Wolf_1:
			arrString.PushBack( FloatToString(0.25f) );
			arrString.PushBack( IntToString(100) );
			arrString.PushBack( IntToString(1) );
			arrString.PushBack( FloatToString(0.1f) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Wolf_2:
			arrString.PushBack( IntToString(150) );
			arrString.PushBack( IntToString(5) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_RedWolf_1:
			arrString.PushBack( IntToString(6) );
			arrString.PushBack( IntToString(4) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_RedWolf_2:
			/*dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_2', 'amount', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );*/
			
			arrString.PushBack( FloatToString( 0.2f ) );
			arrString.PushBack( FloatToString( 0.3f ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Viper1:
			arrString.PushBack( FloatToString(50) );
			arrString.PushBack( FloatToString(25) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Viper2:
			arrString.PushBack( FloatToString(0.25f) );
			arrString.PushBack( FloatToString(1) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Vampire_2:
			arrString.PushBack( IntToString(200) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Vampire_Alt_2:
			arrString.PushBack( IntToString(500) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Temerian:
			arrString.PushBack( IntToString(50) );
			arrString.PushBack( IntToString(4) );
			arrString.PushBack( IntToString(20) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Nilfgaard:
			arrString.PushBack( IntToString(50) );
			arrString.PushBack( IntToString(RoundMath(Options().StamCostHeavy() * Options().StamCostGlobal() / 2.f) ));
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Skellige:
			arrString.PushBack( IntToString(50) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Ofieri:
			arrString.PushBack( IntToString(5) );
			arrString.PushBack( IntToString(3) );
			arrString.PushBack( FloatToString(0.5) );
			arrString.PushBack( IntToString(10) );
			arrString.PushBack( IntToString(50) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_New_Moon:
			arrString.PushBack( IntToString(10) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Elven_1:
			arrString.PushBack( FloatToString(10) );
			arrString.PushBack( FloatToString(50) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Elven_2:
			arrString.PushBack( FloatToString(3) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Tiger_1:
			arrString.PushBack( FloatToString(25) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Tiger_2:
			arrString.PushBack( FloatToString(50) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Netflix_1:
			arrString.PushBack( FloatToString(0.25f) );
			arrString.PushBack( IntToString(1000) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Netflix_2:
			arrString.PushBack( IntToString(RoundMath(5.f * MaxF(GetAdrenalineEffect().GetAdrenalineGainMult(), 1.f))) );
			arrString.PushBack( IntToString(50) );
			arrString.PushBack( IntToString(100) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		default:
			finalString = GetLocStringByKeyExtWithParams( tempString );
		}
		
		return finalString;
	}
	
	public function ManageSetBonusesSoundbanks( setType : EItemSetType )
	{
		if( amountOfSetPiecesEquipped[ setType ] >= Options().SetBonusCountFirst() )
		{
			switch( setType )
			{
				case EIST_Lynx:
				case EIST_MinorLynx:
					LoadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
					break;
				case EIST_Gryphon:
				case EIST_MinorGryphon:
					LoadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
					break;
				case EIST_Bear:
				case EIST_MinorBear:
					LoadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
					break;
			}
		}
		else
		{
			switch( setType )
			{
				case EIST_Lynx:
				case EIST_MinorLynx:
					UnloadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
					break;
				case EIST_Gryphon:
				case EIST_MinorGryphon:
					UnloadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
					break;
				case EIST_Bear:
				case EIST_MinorBear:
					UnloadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
					break;
			}
		}
	}
	
	//Kolaris - Vampire Set
	public function VampiricSetAbilityRegeneration(bleedStacks : int)
	{
		var healthToReg		: float;
		
		healthToReg = 200 * bleedStacks;
		
		if( healthToReg > 0.f )
		{
			PlayEffect('drain_energy_caretaker_shovel');
			GainStat( BCS_Vitality, healthToReg );
		}
	}
	
	//Kolaris - Vampire Set
	public function VampiricSetAbilityCharm(actorAttacker : CActor)
	{
		var resist : float;
		var axiiStrength : SAbilityAttributeValue;
		var npcAttacker : CNewNPC;
		var params : SCustomEffectParams;
		
		npcAttacker = (CNewNPC)actorAttacker;
		axiiStrength = GetTotalSignSpellPower(S_Magic_5);
		resist = npcAttacker.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL);
		if( RandF() < 0.05f * (axiiStrength.valueMultiplicative + 0.05f * GetSkillLevel(S_Magic_s19)) * (1.f - resist) )
		{
			params.creator = this;
			params.sourceName = "VampiricCharm";
			params.isSignEffect = true;
			params.duration = 60.f * (1.f + 0.2f * GetSkillLevel(S_Magic_s19));
			params.effectType = EET_AxiiGuardMe;
			npcAttacker.AddEffectCustom(params);
		}
		else
		if( RandF() < 0.1f * (axiiStrength.valueMultiplicative + 0.05f * GetSkillLevel(S_Magic_s19)) * (1.f - resist) )
		{
			params.creator = this;
			params.sourceName = "VampiricCharm";
			params.isSignEffect = true;
			params.duration = 10.f * (1.f + 0.2f * GetSkillLevel(S_Magic_s19));
			params.effectType = EET_Confusion;
			npcAttacker.AddEffectCustom(params);
		}
	}
	
	private function LoadSetBonusSoundBank( bankName : string )
	{
		if( !theSound.SoundIsBankLoaded( bankName ) )
		{
			theSound.SoundLoadBank( bankName, true );
		}
	}
	
	private function UnloadSetBonusSoundBank( bankName : string )
	{
		if( theSound.SoundIsBankLoaded( bankName ) )
		{
			theSound.SoundUnloadBank( bankName );
		}
	}
	
	timer function BearSetBonusQuenReapply( dt : float, id : int )
	{
		var newQuen		: W3QuenEntity;
		
		newQuen = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
		newQuen.Init( signOwner, GetSignEntity( ST_Quen ), true );
		newQuen.freeFromBearSetBonus = true;
		newQuen.OnStarted();
		newQuen.OnThrowing();
		newQuen.OnEnded();
		
		m_quenReappliedCount += 1;
		
		RemoveTimer( 'BearSetBonusQuenReapply');
	}
	
	public final function StandaloneEp1_1()
	{
		var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
		var pam : W3PlayerAbilityManager;
		var ids : array<SItemUniqueId>;
		var STARTING_LEVEL : int;
		
		FactsAdd("StandAloneEP1", 1);
		
		
		inv.RemoveAllItems();
		
		
		inv.AddAnItem('Illusion Medallion', 1, true, true, false);
		inv.AddAnItem('q103_safe_conduct', 1, true, true, false);
		
		
		theGame.GetGamerProfile().ClearAllAchievementsForEP1();
		
		
		STARTING_LEVEL = 32;
		inc = STARTING_LEVEL - GetLevel();
		for(i=0; i<inc; i+=1)
		{
			levelManager.AddPoints(EExperiencePoint, levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint), false);
		}
		
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
			Experience().ModTotalPathPoints((ESkillSubPath)i, 15, true);
		
		
		levelManager.ResetCharacterDev();
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
		{
			pam.ResetCharacterDev();
		}
		levelManager.SetFreeSkillPoints(levelManager.GetLevel() - 1 + 11);	
		
		
		inv.AddAnItem('Greater mutagen green', 6);
		inv.AddAnItem('Greater mutagen blue', 6);
		inv.AddAnItem('Greater mutagen red', 6);
		
		
		startingMoney = 10000;
		if(GetMoney() > startingMoney)
		{
			RemoveMoney(GetMoney() - startingMoney);
		}
		else
		{
			AddMoney( 10000 - GetMoney() );
		}
		
		
		
		
		
		ids.Clear();
		ids = inv.AddAnItem('Oathbreaker Armor');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Oathbreaker Boots');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Oathbreaker Gloves');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Oathbreaker Pants');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Hood Grey');
		EquipItem(ids[0]);
		
		
		ids.Clear();
		ids = inv.AddAnItem('Wild Hunt sword 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Silver sword 7');
		EquipItem(ids[0]);
		
		
		inv.AddAnItem('Torch', 1, true, true, false);
		
		
		quantityLow = 1;
		randLow = 3;
		quantityMedium = 4;
		randMedium = 4;
		quantityHigh = 8;
		randHigh = 6;
		
		inv.AddAnItem('Alghoul bone marrow',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Amethyst dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas eyes',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Basilisk venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Coal',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Cotton',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Dark iron ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dark iron ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Deer hide',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Diamond dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowned dead tongue',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowner brain',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Dwimeryte ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dwimeryte ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Emerald dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Endriag chitin plates',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Endriag embryo',quantityLow+RandRange(randLow));
		inv.AddAnItem('Ghoul blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hag teeth',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened leather',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened timber',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Harpy feathers',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Leather straps',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Linen',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Meteorite ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Meteorite ore',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Necrophage skin',quantityLow+RandRange(randLow));
		inv.AddAnItem('Nekker blood',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Nekker heart',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Oil',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Phosphorescent crystal',quantityLow+RandRange(randLow));
		inv.AddAnItem('Pig hide',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Pure silver',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rabbit pelt',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rotfiend blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Sapphire dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Silk',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Silver ingot',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Silver ore',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Specter dust',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Steel ingot',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Steel plate',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('String',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Thread',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Timber',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Twine',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Venom extract',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Water essence',quantityMedium+RandRange(randMedium));
		
		inv.AddAnItem('Alcohest', 5);
		inv.AddAnItem('Dwarven spirit', 5);
	
		
		ids.Clear();
		ids = inv.AddAnItem('Crossbow 5');
		EquipItem(ids[0]);
		ids.Clear();
		inv.AddAnItem('Broadhead Bolt', 40);
		EquipItem(ids[0]);
		
		
		RemoveAllAlchemyRecipes();
		RemoveAllCraftingSchematics();
		
		
		
		
		AddAlchemyRecipe('Recipe for Cat 1');
		
		
		
		AddAlchemyRecipe('Recipe for Maribor Forest 1');
		AddAlchemyRecipe('Recipe for Petris Philtre 1');
		AddAlchemyRecipe('Recipe for Swallow 1');
		AddAlchemyRecipe('Recipe for Tawny Owl 1');
		
		AddAlchemyRecipe('Recipe for White Gull 1');
		AddAlchemyRecipe('Recipe for White Honey 1');
		AddAlchemyRecipe('Recipe for White Raffards Decoction 1');
		
		
		
		AddAlchemyRecipe('Recipe for Beast Oil 1');
		AddAlchemyRecipe('Recipe for Cursed Oil 1');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 1');
		AddAlchemyRecipe('Recipe for Hybrid Oil 1');
		AddAlchemyRecipe('Recipe for Insectoid Oil 1');
		AddAlchemyRecipe('Recipe for Magicals Oil 1');
		AddAlchemyRecipe('Recipe for Necrophage Oil 1');
		AddAlchemyRecipe('Recipe for Specter Oil 1');
		AddAlchemyRecipe('Recipe for Vampire Oil 1');
		AddAlchemyRecipe('Recipe for Draconide Oil 1');
		AddAlchemyRecipe('Recipe for Ogre Oil 1');
		AddAlchemyRecipe('Recipe for Relic Oil 1');
		AddAlchemyRecipe('Recipe for Beast Oil 2');
		AddAlchemyRecipe('Recipe for Cursed Oil 2');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 2');
		AddAlchemyRecipe('Recipe for Hybrid Oil 2');
		AddAlchemyRecipe('Recipe for Insectoid Oil 2');
		AddAlchemyRecipe('Recipe for Magicals Oil 2');
		AddAlchemyRecipe('Recipe for Necrophage Oil 2');
		AddAlchemyRecipe('Recipe for Specter Oil 2');
		AddAlchemyRecipe('Recipe for Vampire Oil 2');
		AddAlchemyRecipe('Recipe for Draconide Oil 2');
		AddAlchemyRecipe('Recipe for Ogre Oil 2');
		AddAlchemyRecipe('Recipe for Relic Oil 2');
		
		
		AddAlchemyRecipe('Recipe for Dancing Star 1');
		
		AddAlchemyRecipe('Recipe for Dwimeritum Bomb 1');
		
		AddAlchemyRecipe('Recipe for Grapeshot 1');
		AddAlchemyRecipe('Recipe for Samum 1');
		
		AddAlchemyRecipe('Recipe for White Frost 1');
		
		
		
		AddAlchemyRecipe('Recipe for Dwarven spirit 1');
		AddAlchemyRecipe('Recipe for Alcohest 1');
		AddAlchemyRecipe('Recipe for White Gull 1');
		
		
		AddStartingSchematics();
		
		
		ids.Clear();
		ids = inv.AddAnItem('Swallow 2 Rubedo');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Thunderbolt 2 Nigredo');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Tawny Owl 2');
		EquipItem(ids[0]);
		ids.Clear();
		
		ids = inv.AddAnItem('Grapeshot 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Samum 2');
		EquipItem(ids[0]);
		
		inv.AddAnItem('Dwimeritum Bomb 1');
		inv.AddAnItem('Silver Dust Bomb 1');
		inv.AddAnItem('White Frost 2');
		inv.AddAnItem('Dancing Star 2');
		inv.AddAnItem('Brown Oil 3');
		inv.AddAnItem('Ethereal Oil 3');
		inv.AddAnItem('Poisonous Oil 2');
		inv.AddAnItem('Flammable Oil 2');
		inv.AddAnItem('Cat 2 Albedo');
		inv.AddAnItem('Maribor Forest 1');
		inv.AddAnItem('Petris Philtre 1');
		inv.AddAnItem('White Gull 1', 3);
		inv.AddAnItem('White Honey 1');
		
		
		inv.AddAnItem('weapon_repair_kit_1', 2);
		inv.AddAnItem('weapon_repair_kit_2', 1);
		inv.AddAnItem('armor_repair_kit_1', 2);
		inv.AddAnItem('armor_repair_kit_2', 1);
		
		
		StandaloneEp1_2();
	}
	
	public final function StandaloneEp1_2()
	{
		var horseId : SItemUniqueId;
		var ids : array<SItemUniqueId>;
		var ents : array< CJournalBase >;
		var i : int;
		var manager : CWitcherJournalManager;
		
		
		ids.Clear();
		ids = inv.AddAnItem( 'Dumpling', 12 );
		EquipItem(ids[0]);
		
		
		inv.AddAnItem('Clearing Potion', 2, true, false, false);
		
		
		GetHorseManager().RemoveAllItems();
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Bag 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Blinder 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Saddle 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		manager = theGame.GetJournalManager();

		
		manager.GetActivatedOfType( 'CJournalCreature', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalCharacter', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalQuest', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			
			if( StrStartsWith(ents[i].baseName, "q60"))
				continue;
				
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		
		manager.ActivateEntryByScriptTag('TutorialAard', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAdrenaline', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAxii', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAxiiDialog', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCamera', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCamera_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriBlink', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriCharge', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriStamina', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCounter', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialDialogClose', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFallingRoll', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocus', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseRoad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed0', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed0_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed1', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed2', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSummon', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSummon_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialIgni', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalAlternateSings', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBoatDamage', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBoatMount', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBuffs', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCharDevLeveling', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCharDevSkills', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCrafting', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCrossbow', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDialogGwint', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDialogShop', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDive', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDodge', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDodge_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDurability', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalExplorations', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalExplorations_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalFastTravel', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalFocusRedObjects', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalGasClouds', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHeavyAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHorse', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHorseStamina', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalJump', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMeditation', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMeditation_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMonsterThreatLevels', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMovement', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMovement_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMutagenIngredient', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMutagenPotion', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalOils', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPetards', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPotions', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPotions_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalQuestArea', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRadial', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRifts', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRun', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalShopDescription', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSignCast', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSignCast_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSpecialAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalStaminaExploration', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJumpHang', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadder', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadderMove', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadderMove_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialObjectiveSwitching', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialOxygen', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialParry', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialPOIUncovered', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialQuen', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialRoll', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialRoll_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSpeedPairing', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSprint', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialStaminaSigns', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialStealing', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSwimmingSpeed', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialTimedChoiceDialog', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialYrden', JS_Active);
		
		
		FactsAdd('kill_base_tutorials');
		
		
		theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
		
		
		FactsAdd('standalone_ep1');
		FactsRemove("StandAloneEP1");
		
		theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
	}
	
	final function Debug_FocusBoyFocusGain()
	{
		var focusGain : float;
		
		focusGain = FactsQuerySum( "debug_fact_focus_boy" ) ;
		GainStat( BCS_Focus, focusGain );
	}
	
	public final function StandaloneEp2_1()
	{
		var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
		var pam : W3PlayerAbilityManager;
		var ids : array<SItemUniqueId>;
		var STARTING_LEVEL : int;
		
		FactsAdd( "StandAloneEP2", 1 );
		
		
		inv.RemoveAllItems();
		
		
		inv.AddAnItem( 'Illusion Medallion', 1, true, true, false );
		inv.AddAnItem( 'q103_safe_conduct', 1, true, true, false );
		
		
		theGame.GetGamerProfile().ClearAllAchievementsForEP2();
		
		
		levelManager.Hack_EP2StandaloneLevelShrink( 35 );
		
		
		levelManager.ResetCharacterDev();
		pam = ( W3PlayerAbilityManager )abilityManager;
		if( pam )
		{
			pam.ResetCharacterDev();
		}
		levelManager.SetFreeSkillPoints( levelManager.GetLevel() - 1 + 11 );	
		
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
			Experience().ModTotalPathPoints((ESkillSubPath)i, 20, true);
		
		inv.AddAnItem( 'Mutagen red', 4 );
		inv.AddAnItem( 'Mutagen green', 4 );
		inv.AddAnItem( 'Mutagen blue', 4 );
		inv.AddAnItem( 'Lesser mutagen red', 2 );
		inv.AddAnItem( 'Lesser mutagen green', 2 );
		inv.AddAnItem( 'Lesser mutagen blue', 2 );
		inv.AddAnItem( 'Greater mutagen red', 6 );
		inv.AddAnItem( 'Greater mutagen green', 6 );
		inv.AddAnItem( 'Greater mutagen blue', 6 );
		
		
		startingMoney = 10000;
		if( GetMoney() > startingMoney )
		{
			RemoveMoney( GetMoney() - startingMoney );
		}
		else
		{
			AddMoney( 10000 - GetMoney() );
		}
		
		
		ids.Clear();
		ids = inv.AddAnItem('Kinslayer Armor');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Kinslayer Boots');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Kinslayer Gloves');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Kinslayer Pants');
		EquipItem(ids[0]);
		
		
		ids.Clear();
		ids = inv.AddAnItem('Sezon Burz Steel Sword');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Sezon Burz Silver Sword');
		EquipItem(ids[0]);
		
		
		inv.AddAnItem('Torch', 1, true, true, false);
		
		
		quantityLow = 1;
		randLow = 3;
		quantityMedium = 4;
		randMedium = 4;
		quantityHigh = 8;
		randHigh = 6;
		
		inv.AddAnItem('Alghoul bone marrow',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Amethyst dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas eyes',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Basilisk venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Coal',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Cotton',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Dark iron ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dark iron ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Deer hide',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Diamond dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowned dead tongue',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowner brain',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Dwimeryte ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dwimeryte ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Emerald dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Endriag chitin plates',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Endriag embryo',quantityLow+RandRange(randLow));
		inv.AddAnItem('Ghoul blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hag teeth',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened leather',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened timber',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Harpy feathers',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Leather straps',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Linen',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Meteorite ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Meteorite ore',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Necrophage skin',quantityLow+RandRange(randLow));
		inv.AddAnItem('Nekker blood',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Nekker heart',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Oil',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Phosphorescent crystal',quantityLow+RandRange(randLow));
		inv.AddAnItem('Pig hide',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Pure silver',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rabbit pelt',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rotfiend blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Sapphire dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Silk',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Silver ingot',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Silver ore',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Specter dust',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Steel ingot',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Steel plate',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('String',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Thread',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Timber',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Twine',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Venom extract',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Water essence',quantityMedium+RandRange(randMedium));
		
		inv.AddAnItem('Alcohest', 5);
		inv.AddAnItem('Dwarven spirit', 5);
	
		
		ids.Clear();
		ids = inv.AddAnItem('Crossbow 5');
		EquipItem(ids[0]);
		ids.Clear();
		inv.AddAnItem('Broadhead Bolt', 40);
		EquipItem(ids[0]);
		
		
		RemoveAllAlchemyRecipes();
		RemoveAllCraftingSchematics();
		
		
		
		
		AddAlchemyRecipe('Recipe for Cat 1');
		
		
		
		AddAlchemyRecipe('Recipe for Maribor Forest 1');
		AddAlchemyRecipe('Recipe for Petris Philtre 1');
		AddAlchemyRecipe('Recipe for Swallow 1');
		AddAlchemyRecipe('Recipe for Tawny Owl 1');
		
		AddAlchemyRecipe('Recipe for White Gull 1');
		AddAlchemyRecipe('Recipe for White Honey 1');
		AddAlchemyRecipe('Recipe for White Raffards Decoction 1');
		
		
		
		AddAlchemyRecipe('Recipe for Beast Oil 1');
		AddAlchemyRecipe('Recipe for Cursed Oil 1');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 1');
		AddAlchemyRecipe('Recipe for Hybrid Oil 1');
		AddAlchemyRecipe('Recipe for Insectoid Oil 1');
		AddAlchemyRecipe('Recipe for Magicals Oil 1');
		AddAlchemyRecipe('Recipe for Necrophage Oil 1');
		AddAlchemyRecipe('Recipe for Specter Oil 1');
		AddAlchemyRecipe('Recipe for Vampire Oil 1');
		AddAlchemyRecipe('Recipe for Draconide Oil 1');
		AddAlchemyRecipe('Recipe for Ogre Oil 1');
		AddAlchemyRecipe('Recipe for Relic Oil 1');
		AddAlchemyRecipe('Recipe for Beast Oil 2');
		AddAlchemyRecipe('Recipe for Cursed Oil 2');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 2');
		AddAlchemyRecipe('Recipe for Hybrid Oil 2');
		AddAlchemyRecipe('Recipe for Insectoid Oil 2');
		AddAlchemyRecipe('Recipe for Magicals Oil 2');
		AddAlchemyRecipe('Recipe for Necrophage Oil 2');
		AddAlchemyRecipe('Recipe for Specter Oil 2');
		AddAlchemyRecipe('Recipe for Vampire Oil 2');
		AddAlchemyRecipe('Recipe for Draconide Oil 2');
		AddAlchemyRecipe('Recipe for Ogre Oil 2');
		AddAlchemyRecipe('Recipe for Relic Oil 2');
		
		
		AddAlchemyRecipe('Recipe for Dancing Star 1');
		
		AddAlchemyRecipe('Recipe for Dwimeritum Bomb 1');
		
		AddAlchemyRecipe('Recipe for Grapeshot 1');
		AddAlchemyRecipe('Recipe for Samum 1');
		
		AddAlchemyRecipe('Recipe for White Frost 1');
		
		
		
		AddAlchemyRecipe('Recipe for Dwarven spirit 1');
		AddAlchemyRecipe('Recipe for Alcohest 1');
		AddAlchemyRecipe('Recipe for White Gull 1');
		
		
		AddStartingSchematics();
		
		
		ids.Clear();
		ids = inv.AddAnItem('Swallow 2 Rubedo');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Thunderbolt 2 Nigredo');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Tawny Owl 2');
		EquipItem(ids[0]);
		ids.Clear();
		
		ids = inv.AddAnItem('Grapeshot 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Samum 2');
		EquipItem(ids[0]);
		
		inv.AddAnItem('Dwimeritum Bomb 1');
		inv.AddAnItem('Silver Dust Bomb 1');
		inv.AddAnItem('White Frost 2');
		inv.AddAnItem('Dancing Star 2');
		inv.AddAnItem('Brown Oil 3');
		inv.AddAnItem('Ethereal Oil 3');
		inv.AddAnItem('Poisonous Oil 2');
		inv.AddAnItem('Flammable Oil 2');
		inv.AddAnItem('Cat 2 Albedo');
		inv.AddAnItem('Maribor Forest 1');
		inv.AddAnItem('Petris Philtre 1');
		inv.AddAnItem('White Gull 1', 3);
		inv.AddAnItem('White Honey 1');
		
		
		inv.AddAnItem('weapon_repair_kit_1', 2);
		inv.AddAnItem('weapon_repair_kit_2', 1);
		inv.AddAnItem('armor_repair_kit_1', 2);
		inv.AddAnItem('armor_repair_kit_2', 1);
		
		
		StandaloneEp2_2();
	}
	
	public final function StandaloneEp2_2()
	{
		var horseId : SItemUniqueId;
		var ids : array<SItemUniqueId>;
		var ents : array< CJournalBase >;
		var i : int;
		var manager : CWitcherJournalManager;
		
		
		inv.AddAnItem( 'Cows milk', 20 );
		ids.Clear();
		ids = inv.AddAnItem( 'Dumpling', 44 );
		EquipItem( ids[0] );
		
		
		inv.AddAnItem( 'Clearing Potion', 2, true, false, false );
		
		
		GetHorseManager().RemoveAllItems();
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Bag 2' );
		horseId = GetHorseManager( ).MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Blinder 2' );
		horseId = GetHorseManager().MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Saddle 2' );
		horseId = GetHorseManager().MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		manager = theGame.GetJournalManager();

		
		manager.GetActivatedOfType( 'CJournalCreature', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalCharacter', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalQuest', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			
			if( StrStartsWith( ents[i].baseName, "q60" ) )
				continue;
				
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		
		manager.ActivateEntryByScriptTag( 'TutorialAard', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAdrenaline', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAxii', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAxiiDialog', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCamera', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCamera_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriBlink', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriCharge', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriStamina', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCounter', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialDialogClose', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFallingRoll', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocus', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseRoad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed1', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed2', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSummon', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSummon_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialIgni', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalAlternateSings', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBoatDamage', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBoatMount', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBuffs', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevLeveling', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevSkills', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCrafting', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCrossbow', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDialogGwint', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDialogShop', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDive', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDodge', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDodge_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDurability', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalFastTravel', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalFocusRedObjects', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalGasClouds', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHeavyAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHorse', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHorseStamina', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalJump', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMonsterThreatLevels', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMovement', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMovement_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenIngredient', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenPotion', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalOils', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPetards', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPotions', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPotions_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalQuestArea', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRadial', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRifts', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRun', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalShopDescription', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSpecialAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalStaminaExploration', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJumpHang', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadder', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadderMove', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadderMove_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialObjectiveSwitching', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialOxygen', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialParry', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialPOIUncovered', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialQuen', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialRoll', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialRoll_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSpeedPairing', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSprint', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialStaminaSigns', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialStealing', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSwimmingSpeed', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialTimedChoiceDialog', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialYrden', JS_Active );
		
		SelectQuickslotItem( EES_RangedWeapon );
		
		
		FactsAdd( 'kill_base_tutorials' );
		
		
		theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
		
		
		FactsAdd( 'standalone_ep2' );
		FactsRemove( "StandAloneEP2" );
		
		theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
	}
	
	
	private var radialPopupShown : bool;
	
	private function ToggleRadialMenuInput(enable : bool)
	{
		var hud    : CR4ScriptedHud;
		var module : CR4HudModuleRadialMenu;
		
		hud = ( CR4ScriptedHud )theGame.GetHud();
		
		if ( hud )
		{
			module = (CR4HudModuleRadialMenu)hud.GetHudModule( "RadialMenuModule" );
			if ( module )
			{
				module.DisableRadialMenuInput(!enable);
			}
		}
	}
	public function EnableRadialInput()
	{
		radialPopupShown = false;
		AddTimer( 'EnableRadialMenuInput', 0.03f, false );
	}
	
	timer function EnableRadialMenuInput( delta : float , id : int)
	{
		ToggleRadialMenuInput(true);
	}
	
	timer function DrinkRadialPotionUpper( delta : float , id : int)
	{
		OnPotionDrinkInput(true);
		GetInputHandler().SetRadialPotionUpperTimer(false);
	}
	
	timer function DrinkRadialPotionLower( delta : float , id : int)
	{
		OnPotionDrinkInput(false);
		GetInputHandler().SetRadialPotionLowerTimer(false);
	}
	
	public function GetRadialPopupShown() : bool
	{
		return radialPopupShown;
	}

	public function PotionSelectionPopup( selectionMode : EItemSelectionPopupMode )
	{
		var cat : array<name>;
		var m_popupData : W3ItemSelectionPopupData;
	
		m_popupData = new W3ItemSelectionPopupData in theGame.GetGuiManager();
		m_popupData.targetInventory = thePlayer.GetInventory();
		m_popupData.overrideQuestItemRestrictions = true;

		m_popupData.selectionMode = selectionMode;
		
		cat.PushBack('potion');
		cat.PushBack('edibles');
		m_popupData.categoryFilterList = cat;
		
		theGame.RequestPopup('ItemSelectionPopup', m_popupData);
		
		ToggleRadialMenuInput(false);
		radialPopupShown = true;
	}
	
	public function OilSelectionPopup( steel : bool )
	{
		var cat, tags : array<name>;
		var m_popupData : W3ItemSelectionPopupData;
	
		m_popupData = new W3ItemSelectionPopupData in theGame.GetGuiManager();
		m_popupData.targetInventory = thePlayer.GetInventory();
		m_popupData.overrideQuestItemRestrictions = true;
		
		if(steel)
		{
			tags.PushBack('SteelOil');
			m_popupData.selectionMode = EISPM_RadialMenuSteelOil;
		}
		else
		{
			tags.PushBack('SilverOil');
			m_popupData.selectionMode = EISPM_RadialMenuSilverOil;
		}
		m_popupData.filterTagsList = tags;		
		
		cat.PushBack('oil');
		m_popupData.categoryFilterList = cat;
		
		theGame.RequestPopup('ItemSelectionPopup', m_popupData);
		
		ToggleRadialMenuInput(false);
		radialPopupShown = true;
	}
	
	private function CheckRadialMenu() : bool
	{
		var hud    : CR4ScriptedHud;
		var module : CR4HudModuleRadialMenu;
		
		hud = ( CR4ScriptedHud )theGame.GetHud();
		
		if ( hud )
		{
			module = (CR4HudModuleRadialMenu)hud.GetHudModule( "RadialMenuModule" );
			if ( module )
			{				
				return module.IsRadialMenuOpened();
			}
		}
		
		return false;
	}
	
	// W3EE - Begin
	private var armorPiecesOriginal, armorPieces : array<SArmorCount>;
	private function UpdateArmorCount( slot : EEquipmentSlots, item : SItemUniqueId, increment : int )
	{
		if( !inv.IsItemAnyArmor(item) )
			return;
		
		switch(inv.GetArmorType(item))
		{
			case EAT_Light:		armorPieces[1].all += increment;	if( slot != EES_Boots && slot != EES_Pants ) armorPieces[1].upper += increment;	break;
			case EAT_Medium:	armorPieces[2].all += increment;	if( slot != EES_Boots && slot != EES_Pants ) armorPieces[2].upper += increment;	break;
			case EAT_Heavy:		armorPieces[3].all += increment;	if( slot != EES_Boots && slot != EES_Pants ) armorPieces[3].upper += increment;	break;
			default : break;
		}
		
		switch(inv.GetArmorTypeOriginal(item))
		{
			case EAT_Light:		armorPiecesOriginal[1].all += increment;	if( slot != EES_Boots && slot != EES_Pants ) armorPiecesOriginal[1].upper += increment;	break;
			case EAT_Medium:	armorPiecesOriginal[2].all += increment;	if( slot != EES_Boots && slot != EES_Pants ) armorPiecesOriginal[2].upper += increment;	break;
			case EAT_Heavy:		armorPiecesOriginal[3].all += increment;	if( slot != EES_Boots && slot != EES_Pants ) armorPiecesOriginal[3].upper += increment;	break;
			default : break;
		}
		
		armorPieces[0].all = 4 - armorPieces[1].all - armorPieces[2].all - armorPieces[3].all;
		armorPieces[0].upper = 2 - armorPieces[1].upper - armorPieces[2].upper - armorPieces[3].upper;
		armorPiecesOriginal[0].all = 4 - armorPiecesOriginal[1].all - armorPiecesOriginal[2].all - armorPiecesOriginal[3].all;
		armorPiecesOriginal[0].upper = 2 - armorPiecesOriginal[1].upper - armorPiecesOriginal[2].upper - armorPiecesOriginal[3].upper;
	}
	
	private function CountPiecesOnSpawn()
	{
		var item : SItemUniqueId;
		
		armorPieces[0].all = 0; armorPieces[0].upper = 0;
		armorPieces[1].all = 0; armorPieces[1].upper = 0;
		armorPieces[2].all = 0; armorPieces[2].upper = 0;
		armorPieces[3].all = 0; armorPieces[3].upper = 0;
		armorPiecesOriginal[0].all = 0; armorPiecesOriginal[0].upper = 0;
		armorPiecesOriginal[1].all = 0; armorPiecesOriginal[1].upper = 0;
		armorPiecesOriginal[2].all = 0; armorPiecesOriginal[2].upper = 0;
		armorPiecesOriginal[3].all = 0; armorPiecesOriginal[3].upper = 0;
		
		if( inv.GetItemEquippedOnSlot(EES_Armor, item) )
		{
			switch(inv.GetArmorType(item))
			{
				case EAT_Light:		armorPieces[1].all += 1; armorPieces[1].upper += 1;	break;
				case EAT_Medium:	armorPieces[2].all += 1; armorPieces[2].upper += 1;	break;
				case EAT_Heavy:		armorPieces[3].all += 1; armorPieces[3].upper += 1;	break;
				default : break;
			}
			
			switch(inv.GetArmorTypeOriginal(item))
			{
				case EAT_Light:		armorPiecesOriginal[1].all += 1; armorPiecesOriginal[1].upper += 1;	break;
				case EAT_Medium:	armorPiecesOriginal[2].all += 1; armorPiecesOriginal[2].upper += 1;	break;
				case EAT_Heavy:		armorPiecesOriginal[3].all += 1; armorPiecesOriginal[3].upper += 1;	break;
				default : break;
			}
		}
		
		if( inv.GetItemEquippedOnSlot(EES_Boots, item) )
		{
			switch(inv.GetArmorType(item))
			{
				case EAT_Light:		armorPieces[1].all += 1; break;
				case EAT_Medium:	armorPieces[2].all += 1; break;
				case EAT_Heavy:		armorPieces[3].all += 1; break;
				default : break;
			}
			
			switch(inv.GetArmorTypeOriginal(item))
			{
				case EAT_Light:		armorPiecesOriginal[1].all += 1; break;
				case EAT_Medium:	armorPiecesOriginal[2].all += 1; break;
				case EAT_Heavy:		armorPiecesOriginal[3].all += 1; break;
				default : break;
			}
		}
		
		if( inv.GetItemEquippedOnSlot(EES_Pants, item) )
		{
			switch(inv.GetArmorType(item))
			{
				case EAT_Light:		armorPieces[1].all += 1; break;
				case EAT_Medium:	armorPieces[2].all += 1; break;
				case EAT_Heavy:		armorPieces[3].all += 1; break;
				default : break;
			}
			
			switch(inv.GetArmorTypeOriginal(item))
			{
				case EAT_Light:		armorPiecesOriginal[1].all += 1; break;
				case EAT_Medium:	armorPiecesOriginal[2].all += 1; break;
				case EAT_Heavy:		armorPiecesOriginal[3].all += 1; break;
				default : break;
			}
		}
		
		if( inv.GetItemEquippedOnSlot(EES_Gloves, item) )
		{
			switch(inv.GetArmorType(item))
			{
				case EAT_Light:		armorPieces[1].all += 1; armorPieces[1].upper += 1;	break;
				case EAT_Medium:	armorPieces[2].all += 1; armorPieces[2].upper += 1;	break;
				case EAT_Heavy:		armorPieces[3].all += 1; armorPieces[3].upper += 1;	break;
				default : break;
			}
			
			switch(inv.GetArmorTypeOriginal(item))
			{
				case EAT_Light:		armorPiecesOriginal[1].all += 1; armorPiecesOriginal[1].upper += 1;	break;
				case EAT_Medium:	armorPiecesOriginal[2].all += 1; armorPiecesOriginal[2].upper += 1;	break;
				case EAT_Heavy:		armorPiecesOriginal[3].all += 1; armorPiecesOriginal[3].upper += 1;	break;
				default : break;
			}
		}
		
		armorPieces[0].all = 4 - armorPieces[1].all - armorPieces[2].all - armorPieces[3].all;
		armorPieces[0].upper = 2 - armorPieces[1].upper - armorPieces[2].upper - armorPieces[3].upper;
		armorPiecesOriginal[0].all = 4 - armorPiecesOriginal[1].all - armorPiecesOriginal[2].all - armorPiecesOriginal[3].all;
		armorPiecesOriginal[0].upper = 2 - armorPiecesOriginal[1].upper - armorPiecesOriginal[2].upper - armorPiecesOriginal[3].upper;
	}
	
	public function GetArmorCount() : array<SArmorCount>
	{
		return armorPieces;
	}
	
	public function GetArmorCountOrig() : array<SArmorCount>
	{
		return armorPiecesOriginal;
	}
	
	event OnAnimEvent_GeraltFastAttackAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animName : name;
		var speed : float;
		
		animName = GetAnimNameFromEventAnimInfo(animInfo);
		switch(animName)
		{
			case 'geralt_attack_fast_2_rp':	speed = 1.35f;	break;
			case 'geralt_attack_fast_4_rp':	speed = 1.65f;	break;
			case 'geralt_attack_fast_5_rp':	speed = 1.35f;	break;
			case 'geralt_attack_fast_6_rp':	speed = 1.3f;	break;
			
			case 'geralt_attack_fast_long_1_rp':	speed = 1.3f;	break;
			case 'geralt_attack_fast_long_1_lp':	speed = 1.3f;	break;
			
			case 'geralt_attack_fast_2_lp':	speed = 1.65f;	break;
			case 'geralt_attack_fast_3_lp':	speed = 1.45f;	break;
			case 'geralt_attack_fast_4_lp':	speed = 1.45f;	break;
			case 'geralt_attack_fast_5_lp':	speed = 1.25f;	break;
			case 'geralt_attack_fast_6_lp':	speed = 1.75f;	break;
			default: speed = 1.f;	break;
		}
		
		SetAnimSpeed(speed);
	}
	
	event OnAnimEvent_GeraltStrongAttackAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animName : name;
		var speed : float;
		
		animName = GetAnimNameFromEventAnimInfo(animInfo);
		switch(animName)
		{
			case 'geralt_attack_strong_4_rp':	speed = 0.85f;	break;
			case 'geralt_attack_strong_5_rp':	speed = 0.85f;	break;
			
			case 'geralt_attack_strong_3_lp':	speed = 0.85f;	break;
			case 'geralt_attack_strong_2_lp':	speed = 1.05f;	break;
			default: speed = 1.f;	break;
		}
		
		SetAnimSpeed(speed);
	}
	
	event OnAnimEvent_GeraltFastAttackFarAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAnimSpeed(0.9f);
	}
	
	event OnAnimEvent_GeraltStrongAttackFarAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAnimSpeed(0.85f);
	}
	
	event OnAnimEvent_SecondaryAttackAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animName : name;
		var speed : float;
		
		animName = GetAnimNameFromEventAnimInfo(animInfo);
		switch(animName)
		{
			case 'geralt_sec_fast_1_rp':	speed = 1.2f;	break;
			case 'geralt_sec_fast_2_rp':	speed = 1.1f;	break;
			case 'geralt_sec_fast_3_rp':	speed = 1.25f;	break;
			
			case 'geralt_sec_fast_1_lp':	speed = 1.1f;	break;
			case 'geralt_sec_fast_2_lp':	speed = 1.3f;	break;
			case 'geralt_sec_fast_3_lp':	speed = 1.2f;	break;
			default: speed = 1.f;	break;
		}
		
		SetAnimSpeed(speed);
	}
	
	event OnAnimEvent_FastAxeAttackAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animName : name;
		var speed : float;
		
		animName = GetAnimNameFromEventAnimInfo(animInfo);
		switch(animName)
		{
			case 'geralt_axe_fast_1_rp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_2_rp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_3_rp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_4_rp':	speed = 1.25f;	break;
			
			case 'geralt_axe_fast_1_lp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_2_lp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_3_lp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_4_lp':	speed = 1.25f;	break;
			case 'geralt_axe_fast_5_lp':	speed = 1.25f;	break;
			default: speed = 1.f;	break;
		}
		
		SetAnimSpeed(speed);
	}
	
	event OnAnimEvent_StrongAxeAttackAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animName : name;
		var speed : float;
		
		animName = GetAnimNameFromEventAnimInfo(animInfo);
		switch(animName)
		{
			case 'geralt_axe_strong_1_rp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_2_rp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_3_rp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_4_rp':	speed = 1.1f;	break;
			
			case 'geralt_axe_strong_1_lp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_2_lp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_3_lp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_4_lp':	speed = 1.1f;	break;
			case 'geralt_axe_strong_5_lp':	speed = 1.1f;	break;
			default: speed = 1.f;	break;
		}
		
		SetAnimSpeed(speed);
	}
	
	event OnAnimEvent_ShieldBlockAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var animName : name;
		var speed : float;
		
		animName = GetAnimNameFromEventAnimInfo(animInfo);
		if( animName == 'geralt_shield_block_3' )
			speed = 1.5f;
		else
			speed = 1.2f;
		
		SetAnimSpeed(speed);
	}
	
	event OnAnimEvent_ShieldBlockAnimEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		ResetCustomAnimationSpeedMult();
		Combat().RemovePlayerSpeedMult();
	}
	
	event OnAnimEvent_SpecialKickAnimStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SetAnimSpeed(0.9f);
	}
	
	event OnAnimEvent_SpecialKickAnimEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		ResetCustomAnimationSpeedMult();
		Combat().RemovePlayerSpeedMult();
	}
	
	event OnAnimEvent_GeraltSpecialStrongAnimEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		ResetCustomAnimationSpeedMult();
		Combat().RemovePlayerSpeedMult();
	}
	
	private var isInvulnerableDodge, isGrazeDodge : bool;
	event OnAnimEvent_DodgeInvulnerableStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		isInvulnerableDodge = true;
		isGrazeDodge = false;
	}
	
	event OnAnimEvent_DodgeGrazeStart( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		isInvulnerableDodge = false;
		isGrazeDodge = true;
	}
	
	event OnAnimEvent_TriggerFinisherFromAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( cachedAct && cachedAct.IsAlive() )
		{
			FinishTarget(0, 0);
		}
	}
	
	private function ResetDodgeState()
	{
		isInvulnerableDodge = false;
		isGrazeDodge = false;
	}
	
	private var animationID : int;	default animationID = -1;
	public function ResetCustomAnimationSpeedMult()
	{
		ResetAnimationSpeedMultiplier(animationID);
	}
	
	private timer function PlayLightAttackSound( dt : float, id : int )
	{
		SoundEvent("cmb_weapon_swoosh_light_slow", 'r_hand');
	}
	
	private timer function PlayHeavyAttackSound( dt : float, id : int )
	{
		SoundEvent("cmb_weapon_swoosh_heavy_slow", 'r_hand');
	}
	
	public function SetAnimSpeed( speed : float )
	{
		animationID = SetAnimationSpeedMultiplier(speed, animationID, true);
	}
	
	private var cachedAct : CActor;
	private var isBashing : bool;
	private var counteredAct : CActor;
	
	public function SetCountAct( a : CActor )
	{
		counteredAct = a;
	}
	
	public function GetCountAct() : CActor
	{
		return counteredAct;
	}
	
	public timer function DestroyProj( dt : float, id : int )
	{
		Combat().IsUsingShield().DestroyProjectiles();
	}
	
	timer function SetNormalStagger( dt : float, id : int )
	{
		if( VecDistance(GetWorldPosition(), counteredAct.GetWorldPosition()) < 2.3f )
			counteredAct.AddEffectDefault(EET_Stagger, this, "ReflexParryPerformed", false);
	}
	
	timer function SetLongStagger( dt : float, id : int )
	{
		if( VecDistance(GetWorldPosition(), counteredAct.GetWorldPosition()) < 2.3f )
			counteredAct.AddEffectDefault(EET_LongStagger, this, "ReflexParryPerformed", false);
	}
	
	timer function SetKnockdownStagger( dt : float, id : int )
	{
		if( VecDistance(GetWorldPosition(), counteredAct.GetWorldPosition()) < 2.3f )
			counteredAct.AddEffectDefault(EET_Knockdown, this, "ReflexParryPerformed", false);
	}
	
	public function GetIsBashing() : bool
	{
		return isBashing;
	}
	
	public function SetIsBashing( b : bool )
	{
		isBashing = b;
	}
	
	timer function RemoveBashing( dt : float, id : int )
	{
		SetIsBashing(false);
	}
	
	public function SetCachedAct( act : CActor )
	{
		cachedAct = act;
	}
	
	public function GetCachedAct() : CActor
	{
		return cachedAct;
	}
	
	public timer function FinishTarget( dt : float, id : int )
	{
		if( cachedAct && cachedAct.IsAlive() )
		{
			SetTarget(cachedAct, true);
			cachedAct.AddAbility('ForceFinisher', false);
			cachedAct.Kill('ForceFinisher', false, this, true);
			SetFinisherVictim(cachedAct);
			CleanCombatActionBuffer();
			OnBlockAllCombatTickets(true);
			
			// cachedAct.SignalGameplayEvent('ForceFinisher');
			FindMoveTarget();
			AddTimer('FinishVictim', 0.2, false);
		}
	}
	
	timer function FinishVictim( dt : float, id : int )
	{
		cachedAct.SignalGameplayEvent('Finisher');
		cachedAct = NULL;
	}
	
	public timer function RemoveWeaponCharge( dt : float, id : int )
	{
		Combat().RemoveInfusionEffects();
	}
	
	private var isAlternateCastInput : bool;
	private var timeStamp : float;
	
	public function GetTimeStampSign()
	{
		isAlternateCastInput = true;
		timeStamp = theGame.GetEngineTimeAsSeconds();
	}
	
	public function ResetCastInput()
	{
		isAlternateCastInput = false;
	}
	
	public function GetIsAlternateCast() : bool
	{
		return (theGame.GetEngineTimeAsSeconds() - timeStamp > 0.1f && isAlternateCastInput) || theInput.GetActionValue('CastSignHold') > 0.f;
	}
	
	public function GetSignOwner() : W3SignOwnerPlayer
	{
		return signOwner;
	}
	
	public function GetBoltArmorPiercingValue() : SAbilityAttributeValue
	{
		var bolt : SItemUniqueId;
		
		GetItemEquippedOnSlot(EES_Bolt, bolt);
		return inv.GetItemAttributeValue(bolt, 'armor_reduction');
	}
	
	public function GetOilCritChanceBonus( victimMonsterCategory : EMonsterCategory ) : SAbilityAttributeValue
	{
		var i : int;
		var weaponId : SItemUniqueId;
		var oils : array<W3Effect_Oil>;
		var critChance : SAbilityAttributeValue;
		var attributeName, appliedOilName : name;
		
		weaponId = inv.GetCurrentlyHeldSword();
		oils = inv.GetOilsAppliedOnItem(weaponId);
		if( oils.Size() > 0 )
		{
			attributeName = MonsterCategoryToCriticalChanceBonus(victimMonsterCategory);
			for(i=0; i<oils.Size(); i+=1)
			{
				appliedOilName = oils[i].GetOilItemName();
				if( oils[i].GetAmmoCurrentCount() > 0 && theGame.GetDefinitionsManager().ItemHasAttribute(appliedOilName, true, attributeName) )
				{
					critChance = inv.GetItemAttributeValue(weaponId, attributeName) * (1.f - PowF(1.f - oils[i].GetAmmoPercentage(), 2) * (1.f - 0.2f * GetSkillLevel(S_Alchemy_s05)));
				}
			}
		}
		
		return critChance;
	}
	
	public function GetOilCritDamageBonus( victimMonsterCategory : EMonsterCategory ) : SAbilityAttributeValue
	{
		var i : int;
		var weaponId : SItemUniqueId;
		var oils : array<W3Effect_Oil>;
		var critDamage : SAbilityAttributeValue;
		var attributeName, appliedOilName : name;
		
		weaponId = inv.GetCurrentlyHeldSword();
		oils = inv.GetOilsAppliedOnItem(weaponId);
		if( oils.Size() > 0 )
		{
			attributeName = MonsterCategoryToCriticalDamageBonus(victimMonsterCategory);
			for(i=0; i<oils.Size(); i+=1)
			{
				appliedOilName = oils[i].GetOilItemName();
				if( oils[i].GetAmmoCurrentCount() > 0 && theGame.GetDefinitionsManager().ItemHasAttribute(appliedOilName, true, attributeName) )
				{
					critDamage = inv.GetItemAttributeValue(weaponId, attributeName) * (1.f - PowF(1.f - oils[i].GetAmmoPercentage(), 2) * (1.f - 0.2f * GetSkillLevel(S_Alchemy_s05)));
				}
			}
		}
		
		return critDamage;
	}
	
	public function GetOilResistIgnore( victimMonsterCategory : EMonsterCategory ) : float
	{
		var i : int;
		var weaponId : SItemUniqueId;
		var oils : array<W3Effect_Oil>;
		var attributeName, appliedOilName : name;
		var resistIgnore : SAbilityAttributeValue;
		
		weaponId = inv.GetCurrentlyHeldSword();
		oils = inv.GetOilsAppliedOnItem(weaponId);
		if( oils.Size() > 0 )
		{
			attributeName = MonsterCategoryToResistReduction(victimMonsterCategory);
			for(i=0; i<oils.Size(); i+=1)
			{
				appliedOilName = oils[i].GetOilItemName();
				if( oils[i].GetAmmoCurrentCount() > 0 && theGame.GetDefinitionsManager().ItemHasAttribute(appliedOilName, true, attributeName) )
				{
					resistIgnore = inv.GetItemAttributeValue(weaponId, attributeName) * (1.f - PowF(1.f - oils[i].GetAmmoPercentage(), 2) * (1.f - 0.2f * GetSkillLevel(S_Alchemy_s05)));
				}
			}
		}
		
		return resistIgnore.valueMultiplicative;
	}
	
	public function GetPlayerArmorPiercingValue( isMelee : bool, isRanged : bool, throwable : CThrowable, attackName : name ) : float
	{
		var armorPiercing : SAbilityAttributeValue;
		var finalArmorPiercing : float;
		var attrs : array<name>;
		
		if( isMelee )
		{
			armorPiercing = GetAttributeValue('armor_reduction');
			finalArmorPiercing = armorPiercing.valueMultiplicative - 1.f;
			
			if( IsHeavyAttack(attackName) )
			{
				armorPiercing = GetAttributeValue('armor_reduction_heavy_style');
				
				finalArmorPiercing += 0.25f;
				if( IsInCombatAction_SpecialAttackHeavy() )
					finalArmorPiercing += (0.1f + 0.03f * GetSkillLevel(S_Sword_s02)) * GetSpecialAttackTimeRatio(); //Kolaris - Rend Rebalance
				
				finalArmorPiercing += GetSkillLevel(S_Sword_s08) * 0.03f + armorPiercing.valueMultiplicative;
			}
			else
			if( IsLightAttack(attackName) )
			{
				armorPiercing = GetAttributeValue('armor_reduction_fast_style');
				finalArmorPiercing += armorPiercing.valueMultiplicative;
			}
			
			//Kolaris - Counter Armor Pierce
			if( IsCounterAttack(attackName) )
				finalArmorPiercing += 1.f;
			//Kolaris - Temerian Set
			if( IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				finalArmorPiercing += 0.2f;
			//Kolaris - Fortification
			if( HasBuff(EET_EnhancedWeapon) && (HasAbility('Runeword 52 _Stats', true) || HasAbility('Runeword 53 _Stats', true) || HasAbility('Runeword 53 _Stats', true)) )
				finalArmorPiercing += 0.2f;
			//Kolaris - Relict Decoction
			if( HasBuff(EET_Decoction7) )
				finalArmorPiercing += 0.2f * (1.f - GetStatPercents(BCS_Vitality));
		}
		else
		{
			if( (W3Petard)throwable )
				finalArmorPiercing = ((W3Petard)throwable).GetBombArmorPierce(false);
			else
			if( (W3ThrowingKnife)throwable )
				finalArmorPiercing = ((W3ThrowingKnife)throwable).GetKnifeArmorPierce(false) + (GetSkillLevel(S_Sword_s07) * 0.04f + armorPiercing.valueMultiplicative);
			else
			{
				armorPiercing = GetBoltArmorPiercingValue();
				finalArmorPiercing = GetSkillLevel(S_Sword_s07) * 0.04f + armorPiercing.valueMultiplicative;
			}
		}
		
		return MinF(finalArmorPiercing * Damage().pap, 1.f);
	}
	
	public function HasQuen() : bool
	{
		return IsQuenActive(false) || IsQuenActive(true);
	}
	
	timer function DestroyQuen( dt : float, id : int )
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)signs[ST_Quen].entity;
		quen.Destroy();
	}
	
	timer function RemoveWolvenParry( dt : float, id : int )
	{
		Combat().GetWolvenEffect().ResetCounter();
	}
	
	private var isSelectionActive : bool;	default isSelectionActive = false;
	public function IsSelectionActive() : bool
	{
		return isSelectionActive;
	}
	
	public function SetSelectionActive( b : bool )
	{
		isSelectionActive = b;
	}
	
	public function GetNumMutagenSlotsUnlocked() : int
	{
		var pam : W3PlayerAbilityManager;
		var count : int;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if( pam && pam.IsInitialized() )
		{
			if( pam.IsSkillMutagenSlotUnlocked(EES_SkillMutagen1) )	count += 1;
			if( pam.IsSkillMutagenSlotUnlocked(EES_SkillMutagen2) )	count += 1;
			if( pam.IsSkillMutagenSlotUnlocked(EES_SkillMutagen3) )	count += 1;
			if( pam.IsSkillMutagenSlotUnlocked(EES_SkillMutagen4) )	count += 1;
			
			return count;
		}
		
		return 0;
	}
	
	private var isFreeBomb : bool;	default isFreeBomb = true;
	public function IsFreeBomb() : bool
	{
		return isFreeBomb;
	}
	
	public function SetIsFreeBomb( b : bool )
	{
		isFreeBomb = b;
	}
	
	timer function ManticoreBombCooldown( dt : float, id : int )
	{
		SetIsFreeBomb(true);
	}
	
	public function GetFeverEffectReductionMult() : float
	{
		//Kolaris - Heightened Tolerance
		if( CanUseSkill(S_Alchemy_s17) /*&& HasDecoctionEffect()*/ )
			return 1.f - 0.08f * GetSkillLevel(S_Alchemy_s15);
			
		return 1.f;
	}
	// W3EE - End
	//Kolaris - Player Vitality Penalty
	public function GetHPReductionMult() : float
	{
		if( HasAbility('Glyphword 45 _Stats', true) )
			return 1.f - 0.25f * PowF(1.f - GetStatPercents(BCS_Vitality), 2) * GetAdrenalinePercMult();
		else
			return 1.f - 0.5f * PowF(1.f - GetStatPercents(BCS_Vitality), 2) * GetAdrenalinePercMult();
	}
	
	//Kolaris - Player Moving Check
	public function IsPlayerMoving() : bool
	{
		var movingAgentComponent : CMovingAgentComponent;
		
		movingAgentComponent = GetMovingAgentComponent();
		if( VecLength( movingAgentComponent.GetVelocity() ) > 0 )
			return true;
		else
			return false;
	}
	
	//Kolaris - Assassination
	public timer function ManageAssassinationVisuals( dt : float, id : int )
	{
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		var sword : CWitcherSword;
		
		items = inv.GetHeldWeapons();
		weaponEnt = inv.GetItemEntityUnsafe(items[0]);
		sword = (CWitcherSword)inv.GetItemEntityUnsafe(items[0]);
		
		if( HasAbility('Runeword 36 _Stats', true) && HasAbility('Runeword 36 Ability') )
		{
			weaponEnt.PlayEffect('bereavement_glow');
			sword.PlayEffect('rune_lvl3');
			sword.PlayEffect('rune_triglav');
		}
		else
		{
			weaponEnt.StopEffect('bereavement_glow');
			sword.PlayEffect('rune_lvl3');
			sword.PlayEffect('rune_triglav');
		}
	}
	
	//Kolaris - Prolongation
	public function GetPlayerSignDurationMod() : float
	{
		if( HasAbility('Runeword 38 _Stats', true) || HasAbility('Runeword 39 _Stats', true) )
			return 1.5f;
		else
			return 1.f;
	}
	
	//Kolaris - Resolution
	public function IsRuneword44Active() : bool
	{
		var enemies : array< CActor >;
		var i : int;
		
		if( HasAbility('Runeword 44 _Stats', true) || HasAbility('Runeword 45 _Stats', true) )
		{
			enemies = GetEnemies();
			for( i=0; i<enemies.Size(); i+=1 )
			{
				if( enemies[i].HasTag('IsBoss') || ((CNewNPC)enemies[i]).HasAbility('Boss') || enemies[i].HasTag('ContractTarget') || (W3MonsterHuntNPC)enemies[i] )
					return true;
			}
		}
		
		return false;
	}
	
	//Kolaris - Destruction
	public timer function ManageDestructionVisuals( dt : float, id : int )
	{
		if( HasAbility('Runeword 48 _Stats', true) && GetStatPercents(BCS_Vitality) > 0.25f )
		{
			if( !IsEffectActive('runeword_4') )
				PlayEffect('runeword_4');
		}
		else if( IsEffectActive('runeword_4') )
			StopEffect('runeword_4');
	}
	
	//Kolaris - Regeneration
	public timer function StopRuneword8Effect( dt : float, id : int )
	{
		StopEffect( 'runeword_8' );
	}
	
	//Kolaris - Next Gen Sets
	public var itemToDamage : SItemUniqueId;
	public function SetItemToDamage(item : SItemUniqueId)
	{
		itemToDamage = item;
	}
	
	public timer function DelayedReduceItemDurability( dt : float, id : int )
	{
		GetInventory().SetItemDurabilityScript(itemToDamage, GetInventory().GetItemMaxDurability(itemToDamage) * RandRangeF(0.2f, 0.01f));
	}
}

exec function fuqfep1()
{
	theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
}


function GetWitcherPlayer() : W3PlayerWitcher
{
	return (W3PlayerWitcher)thePlayer;
}
