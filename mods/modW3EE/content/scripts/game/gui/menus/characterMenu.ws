/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3BuySkillConfirmation extends ConfirmationPopupData
{
	public var characterMenuRef : CR4CharacterMenu;
	public var targetSkill      : ESkill;
	
	
	protected function OnUserAccept() : void
	{
		characterMenuRef.handleBuySkillConfirmation(targetSkill);
	}
	
	protected function OnUserDecline() : void
	{
		super.OnUserDecline();
		theSound.SoundEvent("gui_global_panel_close");
	}
}

enum CharacterMenuTabIndexes
{
	CharacterMenuTab_Sword = 0,
	CharacterMenuTab_Signs = 1,
	CharacterMenuTab_Alchemy = 2,
	CharacterMenuTab_Perks = 3,
	CharacterMenuTab_Mutagens = 4
};


enum EMutationResourceType
{
	MRT_SkillPoints,
	MRT_GreenMutation,
	MRT_RedMutation,
	MRT_BlueMutation
};

enum EBonusSkillSlot
{
	BSS_SkillSlot1 = 13,
	BSS_SkillSlot2 = 14,
	BSS_SkillSlot3 = 15,
	BSS_SkillSlot4 = 16
};	

class CR4CharacterMenu extends CR4MenuBase
{
	protected var initDataBuySkill		  : W3BuySkillConfirmation;
	
	private var _playerInv    	   		: W3GuiPlayerInventoryComponent;
	protected var _inv                  : CInventoryComponent;
	private var _charStatsPopupData 	: CharacterStatsPopupData;
	private var _sentStats 				: array<SentStatsData>;
	protected var currentlySelectedTab	: int;
	
	private var m_previousSkillBonuses  : array<string>;
	
	private	var m_fxPaperdollChanged	 : CScriptedFlashFunction;
	private var m_fxClearSkillSlot 	 	 : CScriptedFlashFunction;
	private var m_fxNotifySkillUpgraded	 : CScriptedFlashFunction;
	private var m_fxActivateRunwordBuf	 : CScriptedFlashFunction;
	private var m_fxSetMutationBonusMode : CScriptedFlashFunction;
	private var m_fxConfirmMutResearch	 : CScriptedFlashFunction;
	private var m_fxResetInput	 		 : CScriptedFlashFunction;
	
	private var m_mutationBonusMode		 : bool;
	default m_mutationBonusMode = false;
	
	private var MAX_BONUS_SOCKETS : int;
	default MAX_BONUS_SOCKETS = 4;
	
	private var MAX_MASTER_MUTATION_STAGE : int;
	default MAX_MASTER_MUTATION_STAGE = 4;
	private var MutFirstOpen : bool;//Mutagen Sorter
		default MutFirstOpen = false;
	
	
	event  OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var filterTagsList 			: array<name>;
		
		super.OnConfigUI();
		
		m_initialSelectionsToIgnore = 3;
		
		// W3EE - Begin
		((W3PlayerAbilityManager)thePlayer.abilityManager).OnLevelGained(1);
		// W3EE - End
		
		m_fxPaperdollChanged = m_flashModule.GetMemberFlashFunction( "onPaperdollChanged" );
		m_fxClearSkillSlot = m_flashModule.GetMemberFlashFunction( "clearSkillSlot" );
		m_fxNotifySkillUpgraded = m_flashModule.GetMemberFlashFunction( "notifySkillUpgraded" );
		m_fxActivateRunwordBuf = m_flashModule.GetMemberFlashFunction( "activateRunwordBuf" );
		m_fxSetMutationBonusMode = m_flashModule.GetMemberFlashFunction( "setMutationBonusMode" );
		m_fxConfirmMutResearch = m_flashModule.GetMemberFlashFunction( "confirmMutationResearch" );
		m_fxResetInput = m_flashModule.GetMemberFlashFunction( "resetInput" );
		
		SendCombatState();
		
		_inv = thePlayer.GetInventory();
		_playerInv = new W3GuiPlayerInventoryComponent in this;
		_playerInv.Initialize( _inv );
		_playerInv.ignorePosition = true;
		filterTagsList.PushBack('MutagenIngredient');
		_playerInv.SetFilterType(IFT_Ingredients);
		_playerInv.filterTagList = filterTagsList;
		
		if( GetWitcherPlayer().IsMutationSystemEnabled() )
		{
			setMutationBonusMode( true );
		}
		else
		{
			m_fxSetMutationBonusMode.InvokeSelfOneArg( FlashArgBool( false ) );
		}
		
		
		UpdateMasterMutation();
		UpdateData(true);
		
		m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
		
		// W3EE - Begin
		CreateCharMenuContext();
		
		/*
		theInput.RegisterListener(this, 'OnSpriteUp', 'MoveSpriteU');
		theInput.RegisterListener(this, 'OnSpriteDown', 'MoveSpriteD');
		theInput.RegisterListener(this, 'OnSpriteLeft', 'MoveSpriteL');
		theInput.RegisterListener(this, 'OnSpriteRight', 'MoveSpriteR');
		*/
		// W3EE - End
	}

	// W3EE - Begin
	/*
	event OnSpriteUp( action : SInputAction )
	{
		var sprite : CScriptedFlashSprite;
		var x,y : float;
		
		
		sprite = m_flashModule.GetChildFlashSprite("moduleSkillTabList").GetChildFlashSprite("txtSpentPoints");
		x=sprite.GetX();
		y=sprite.GetY();
		y=sprite.GetY();
		//sprite.SetY(sprite.GetY() - 0.5);
		
	}
	event OnSpriteDown( action : SInputAction )
	{
		var sprite : CScriptedFlashSprite;
		
		sprite = m_flashModule.GetChildFlashSprite("moduleSkillTabList").GetChildFlashSprite("txtSpentPoints");
		sprite.SetY(sprite.GetY() + 0.5);
	}
	event OnSpriteLeft( action : SInputAction )
	{
		var sprite : CScriptedFlashSprite;
		
		sprite = m_flashModule.GetChildFlashSprite("moduleSkillTabList").GetChildFlashSprite("txtSpentPoints");
		sprite.SetX(sprite.GetX() - 1);
	}
	event OnSpriteRight( action : SInputAction )
	{
		var sprite : CScriptedFlashSprite;
		
		sprite = m_flashModule.GetChildFlashSprite("moduleSkillTabList").GetChildFlashSprite("txtSpentPoints");
		sprite.SetX(sprite.GetX() + 1);
	}
	*/
	
	private var targetedSkill, selectedSkill : ESkill;
	private var resRedMutagenList : array<SItemUniqueId>;
	private var resBlueMutagenList : array<SItemUniqueId>;
	private var resGreenMutagenList : array<SItemUniqueId>;
	private var characterMenuContext : W3CharacterMenuContext;
	private  var experienceHandler : W3EEExperienceHandler;
	private var previewSkillLevel : int;
	default previewSkillLevel = 0;
	
	private function CreateCharMenuContext()
	{
		if( characterMenuContext )
			delete characterMenuContext;
		
		characterMenuContext = new W3CharacterMenuContext in this;
		characterMenuContext.SetCharacterMenuRef(this);
		ActivateContext(characterMenuContext);
		characterMenuContext.UpdateContext();
		experienceHandler = Experience();
		firstOpen = true;
	}
	
	private function GetPreviewSkillLevel() : int
	{
		return previewSkillLevel;
	}
	
	private function SetPreviewSkillLevel( i : int )
	{
		previewSkillLevel = i;
	}
	
	private function UpdateSkillPreview( skill : ESkill, showNotification : bool )
	{
		PopulateTabData(GetTabForSkill(skill), skill);
		UpdateAppliedSkillIfEquipped(skill);
		UpdateGroupsData();
		if( showNotification )
			m_fxNotifySkillUpgraded.InvokeSelfOneArg(FlashArgInt(skill));
	}
	
	event OnIncreaseSkillLVL()
	{
		var skillLevel : int; 
		
		skillLevel = GetPreviewSkillLevel();
		if( GetWitcherPlayer().GetSkillMaxLevel(targetedSkill) - GetWitcherPlayer().GetSkillLevel(targetedSkill) <= skillLevel )
			return false;
		
		if( skillLevel < GetWitcherPlayer().GetSkillMaxLevel(targetedSkill) )
		{
			SetPreviewSkillLevel(skillLevel + 1);
			UpdateSkillPreview(targetedSkill, true);
			OnGetSlotSkillTooltipData(targetedSkill, 0);
		}
	}

	event OnDecreaseSkillLVL()
	{
		var skillLevel : int;
		
		if( GetWitcherPlayer().GetSkillMaxLevel(targetedSkill) == GetWitcherPlayer().GetSkillLevel(targetedSkill) )
			return false;
		
		skillLevel = GetPreviewSkillLevel();
		if( skillLevel > 1 || (skillLevel > 0 && GetWitcherPlayer().GetSkillLevel(targetedSkill) > 0) )
		{
			SetPreviewSkillLevel(skillLevel - 1);
			UpdateSkillPreview(targetedSkill, true);
			OnGetSlotSkillTooltipData(targetedSkill, 0);
		}
	}
	
	event OnHighlightSkill( skill : ESkill, module : int )
	{
		DisplaySkillProgress(skill);
	}
	
	private function UpdatePointDisplay( tabIndex : int )
	{
		var displayText : string;
		
		displayText = "<p align=\"left\"><font size=\"20\">";
		switch(tabIndex)
		{
			case 0:
				displayText += "<font color=\"#aa9578\">";
				displayText += GetLocStringByKeyExt("skill_name_sword_1") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Sword_StyleFast) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_sword_2") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Sword_StyleStrong) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_sword_3") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Sword_Utility) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_sword_4") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Sword_Crossbow) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_sword_5") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Sword_BattleTrance) + "</font>" + "<br>";
			break;
			
			case 1:
				displayText += "<font color=\"#aa9578\">";
				displayText += GetLocStringByKeyExt("skill_name_magic_1") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Signs_Aard) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_magic_2") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Signs_Igni) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_magic_3") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Signs_Yrden) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_magic_4") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Signs_Quen) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_magic_5") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Signs_Axi) + "</font>" + "<br>";
			break;
			
			case 2:
				displayText += "<font color=\"#aa9578\">";
				displayText += GetLocStringByKeyExt("skill_name_alchemy_1") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Alchemy_Potions) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_alchemy_2") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Alchemy_Oils) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_alchemy_3") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Alchemy_Bombs) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_alchemy_4") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Alchemy_Mutagens) + "</font>" + "<br>";
				displayText += GetLocStringByKeyExt("skill_name_alchemy_5") + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Alchemy_Grasses) + "</font>" + "<br>";
			break;
			
			case 3:
				displayText += "<font color=\"#aa9578\">";
				displayText += GetLocStringByKeyExt("panel_character_perks_name")  + " " + GetLocStringByKeyExt("W3EE_Skillpoints") + ":" + "<font color=\"#ffffff\"> " + experienceHandler.GetCurrentPathPoints(ESSP_Perks) + "</font>" + "<br>";
			break;
			
			case 4:
				DisplaySkillProgress(S_Sword_1);
			break;
		}
		
		displayText += "</font></p>";
		m_flashModule.GetChildFlashTextField("txfAvailablePoints").SetTextHtml(displayText);
	}
	
	private var firstOpen : bool;
	private var previousString : string;
	private function DisplaySkillProgress( skill : ESkill ) : string
	{
		var displayText : string;
		var skillPath : ESkillSubPath;
		var skillType : ESkillPath;
		var progressValue : int;
		
		skillPath = GetWitcherPlayer().GetSkillSubPathType(skill);
		skillType = GetWitcherPlayer().GetSkillPathType(skill);
		progressValue = experienceHandler.GetPathProgress(skillPath);
		
		displayText = "<font size=\"20\"><font color=\"#ffffff\">";
		switch(skillPath)
		{
			case ESSP_Sword_StyleFast:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_sword_1")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Sword_StyleStrong:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_sword_2")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Sword_Utility:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_sword_3")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Sword_Crossbow:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_sword_4")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Sword_BattleTrance:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_sword_5")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Signs_Aard:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_magic_1")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Signs_Igni:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_magic_2")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Signs_Yrden:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_magic_3")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Signs_Quen:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_magic_4")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Signs_Axi:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_magic_5")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Alchemy_Potions:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_alchemy_1")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Alchemy_Oils:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_alchemy_2")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Alchemy_Bombs:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_alchemy_3")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Alchemy_Mutagens:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_alchemy_4")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Alchemy_Grasses:
				displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_alchemy_5")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
			
			case ESSP_Perks:
			case ESSP_Perks_col1:
			case ESSP_Perks_col2:
			case ESSP_Perks_col3:
			case ESSP_Perks_col4:
			case ESSP_Perks_col5:
				displayText += StrUpperUTF(GetLocStringByKeyExt("panel_character_perks_name")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			break;
		}
		displayText += "</font>" + progressValue + "%";
		
		if( firstOpen )
		{
			displayText = "<font size=\"20\"><font color=\"#ffffff\">";
			displayText += StrUpperUTF(GetLocStringByKeyExt("skill_name_sword_1")) + " " + StrUpperUTF(GetLocStringByKeyExt("W3EE_SkillProg")) + ": ";
			displayText += "</font>" + experienceHandler.GetPathProgress(ESSP_Sword_StyleFast) + "%";
			previousString = displayText;
			UpdatePointDisplay(0);
			MutFirstOpen = true;//Mutagen Sorter
			firstOpen = false;
		}
		if( (ESkillPath)(currentlySelectedTab + 1) == skillType )
			previousString = displayText;
		else
			displayText = previousString;
		
		if( currentlySelectedTab == 4 )
			displayText = "";
		
		m_flashModule.GetChildFlashSprite("moduleSkillTabList").GetChildFlashTextField("txtSpentPoints").SetTextHtml(displayText);
		return displayText;
	}
	// W3EE - End

	private function BlockClosing( locked : bool )
	{	
		var guiManager : CR4GuiManager;
		var rootMenu : CR4CommonMenu;
			
		rootMenu = (CR4CommonMenu)theGame.GetGuiManager().GetRootMenu();
		
		if (rootMenu)
		{
			rootMenu.SetLockedInMenu(locked);
		}
	}

	event  OnClosingMenu()
	{
		var hud : CR4ScriptedHud;
		super.OnClosingMenu();
		
		// W3EE - Begin
		/*
		if( GetCurrentSkillPoints() < 1 )
		{
		*/
			hud = (CR4ScriptedHud)theGame.GetHud(); 
			if( hud ) 
			{
				hud.OnShowLevelUpIndicator( false );
			}
		//}
		// W3EE - End
		
		if (_charStatsPopupData)
		{
			_charStatsPopupData.ClosePopupOverlay();
			delete _charStatsPopupData;
		}
		BlockClosing( false );
		
		// W3EE - Begin
		if( characterMenuContext )
		{
			characterMenuContext.Deactivate();
			delete characterMenuContext;
		}
		SetPreviewSkillLevel(0);
		// W3EE - End
	}

	event  OnCloseMenu()
	{	
		if(CampfireManager().CanPerformAlchemy())//Mutagen Sorter
			MutSort().Terminate();
		if ( _playerInv )
		{
			delete _playerInv;
		}
		
		if ( initDataBuySkill )
		{
			delete initDataBuySkill;
		}
		
		CloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}
	
	event  OnTabDataRequested(tabIndex : int )
	{
		PopulateTabData(tabIndex);
	}
	
	event  OnTabChanged(tabIndex:int)
	{
		var uiState : W3TutorialManagerUIHandlerStateCharDevMutagens;
		
		//Mutagen Sorter
		if(tabIndex == CharacterMenuTab_Mutagens  && MutFirstOpen && CampfireManager().CanPerformAlchemy())
		{
				MutFirstOpen = false;
				MutSort().Init();
		}
		
		currentlySelectedTab = tabIndex;
		
		if(tabIndex == CharacterMenuTab_Mutagens && ShouldProcessTutorial('TutorialMutagenDescription'))
		{
			uiState = (W3TutorialManagerUIHandlerStateCharDevMutagens)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(uiState)
				uiState.SelectedMutagensTab();
		}
		
		// W3EE - Begin
		UpdatePointDisplay(tabIndex);
		// W3EE - End
	}
	
	event  OnOpenMutationPanel():void
	{
		Equipment().TransferMutationIngredients(true); //Kolaris - Mutation Rework
		OnPlaySoundEvent( "gui_tutorial_big_appear" );
		theGame.GetTutorialSystem().uiHandler.OnClosingMenu( 'CharacterMenu' );
		theGame.GetTutorialSystem().uiHandler.OnOpeningMenu( 'MutationMenu' );
		UpdateAllMutationsData();
		BlockClosing( true );
	}
	
	event  OnCloseMutationPanel():void
	{
		Equipment().TransferMutationIngredients(false); //Kolaris - Mutation Rework
		OnPlaySoundEvent( "gui_character_remove_mutagen" );
		theGame.GetTutorialSystem().uiHandler.OnClosingMenu( 'MutationMenu' );
		theGame.GetTutorialSystem().uiHandler.OnOpeningMenu( 'CharacterMenu' );
		
		
		UpdateData( true ); 
		BlockClosing( false );
	}
	
	event  OnMutationSelected( mutationId : EPlayerMutationType ):void
	{
		var canResearch : W3TutorialManagerUIHandlerStateMutationsCanResearch;
		
		canResearch = ( W3TutorialManagerUIHandlerStateMutationsCanResearch ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if( canResearch )
		{
			m_fxResetInput.InvokeSelf();
			canResearch.OnMutationSelected( mutationId );
		}
	}
	
	event  OnResearchOpened( mutationId : EPlayerMutationType ):void
	{
		var canResearch : W3TutorialManagerUIHandlerStateMutationsCanResearch;
		
		canResearch = ( W3TutorialManagerUIHandlerStateMutationsCanResearch ) theGame.GetTutorialSystem().uiHandler.GetCurrentState();
		if( canResearch )
		{
			canResearch.OnResearch();
		}
		OnPlaySoundEvent( "gui_global_panel_open" );
	}
	
	event  OnResearchClosed():void
	{
		OnPlaySoundEvent( "gui_global_panel_close" );
	}
	
	private function ResearchMutagen( mutationId : int, count : int, itemName : name )
	{
		GetWitcherPlayer().MutationResearchWithItem( mutationId, thePlayer.inv.GetFirstUnusedMutagenByName( itemName ), count );
	}
	
	private function UpdateMasterMutation():void
	{
		var currentlyEquipped : EPlayerMutationType;
		
		if( GetWitcherPlayer().IsMutationSystemEnabled() )
		{
			currentlyEquipped = GetWitcherPlayer().GetEquippedMutationType();
			
			if( currentlyEquipped != EPMT_None )
			{
				UpdateTargetMutationData( currentlyEquipped );
			}
		}
	}
	
	event  OnCantResearchMutation()
	{
		
	}
	
	event  OnResearchMutation( mutationId : int, points : int, red : int, green : int, blue : int ) 
	{
		var isChanged:bool = false;
		var i : int;
		var	idToRemove: SItemUniqueId;
		if( thePlayer.IsInCombat() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_combat" ) );
			OnPlaySoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( points > 0 )
		{
			GetWitcherPlayer().MutationResearchWithSkillPoints( mutationId, points );
			UpdateSkillPoints();
			isChanged = true;
		}
		
		if( red > 0 )
		{
			ResearchMutagen( mutationId, red, 'Greater mutagen red'  ); 
			isChanged = true;
		}
		
		if( green > 0 )
		{
			ResearchMutagen( mutationId, green, 'Greater mutagen green' ); 
			isChanged = true;
		}
		
		if( blue > 0 )
		{
			ResearchMutagen( mutationId, blue, 'Greater mutagen blue' ); 
			isChanged = true;
		}
		
		if( isChanged )
		{
			OnUpdateAfterResearch( mutationId );
		}
	}
	
	event OnUpdateAfterResearch( mutationId : int ) 
	{
		var researchedMutation	   : int;
		var requaredForNextLevel   : int;
		var masterStage			   : int;
		var abilityManager         : W3PlayerAbilityManager;
		
		if(GetWitcherPlayer().IsMutationResearched( mutationId ) )
		{
			UpdateAllMutationsData();
			
			
			masterStage = GetWitcherPlayer().GetMasterMutationStage();
			if (masterStage > 0)
			{
				abilityManager = ( ( W3PlayerAbilityManager ) GetWitcherPlayer().abilityManager );
				
				requaredForNextLevel = abilityManager.GetMutationsRequiredForMasterStage(masterStage);
				researchedMutation = abilityManager.GetResearchedMutationsCount();
				
				if (requaredForNextLevel == researchedMutation )
				{
					
					OnPlaySoundEvent( "gui_enchanting_runeword_add" );		
				}
			}
			
			OnPlaySoundEvent( "gui_character_place_mutagen" );
		}
		else
		{
			UpdateTargetMutationData( mutationId );
		}
	}
	
	event  OnEquipMutation( mutationId : int )
	{
		var currentlyEquipped : EPlayerMutationType;
		
		currentlyEquipped = GetWitcherPlayer().GetEquippedMutationType();
		
		if( currentlyEquipped != mutationId )
		{
			if( thePlayer.IsInCombat() )
			{
				showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_combat" ) );
				OnPlaySoundEvent( "gui_global_denied" );
			}
			else
			{
				GetWitcherPlayer().SetEquippedMutation( mutationId );
				setMutationBonusMode( true );
				UpdateAllMutationsData();
				
				OnPlaySoundEvent( "gui_character_synergy_effect" );
			}
		}
	}
	
	event  OnUnequipMutation()
	{
		var currentlyEquipped : EPlayerMutationType;
		
		currentlyEquipped = GetWitcherPlayer().GetEquippedMutationType();
		
		if( currentlyEquipped != EPMT_None )
		{
			if( thePlayer.IsInCombat() )
			{
				showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_combat" ) );
				OnPlaySoundEvent( "gui_global_denied" );
			}
			else
			{
				setMutationBonusMode( false );
				GetWitcherPlayer().SetEquippedMutation( EPMT_None );
				UpdateAllMutationsData();
				
				OnPlaySoundEvent( "gui_character_synergy_effect_lose" );
			}
		}
	}
	
	private function setMutationBonusMode( value : bool ):void
	{
		if( m_mutationBonusMode != value )
		{
			m_mutationBonusMode = value;
			m_fxSetMutationBonusMode.InvokeSelfOneArg( FlashArgBool( value ) );
			
			if( m_mutationBonusMode )
			{
				
			}
			else
			{
				thePlayer.UnequipSkill( BSS_SkillSlot1 );
				thePlayer.UnequipSkill( BSS_SkillSlot2 );
				thePlayer.UnequipSkill( BSS_SkillSlot3 );
				thePlayer.UnequipSkill( BSS_SkillSlot4 );
				
				UpdatePlayerStatisticsData();
				UpdateGroupsData();
			}
		}
	}
	
	private function UpdateTargetMutationData( mutationId : EPlayerMutationType ):void
	{
		var mutationData      : CScriptedFlashObject;
		
		mutationData = CreateMutationFlashDataObj( mutationId );
		m_flashValueStorage.SetFlashObject( "character.mutation", mutationData );
	}
	
	private function UpdateAllMutationsData():void
	{
		var mutationsList      : CScriptedFlashArray;
		var mutationData       : CScriptedFlashObject;
		var count              : int;
		var curMutationId      : int;
		
		mutationsList = m_flashValueStorage.CreateTempFlashArray();
		
		if( GetWitcherPlayer().IsMutationSystemEnabled() )
		{
			count = EnumGetMax( 'EPlayerMutationType' );
			
			for( curMutationId = EPMT_Mutation1; curMutationId <= count; curMutationId += 1 )
			{
				mutationData = CreateMutationFlashDataObj( curMutationId );
				mutationsList.PushBackFlashObject( mutationData );
			}
		}
		
		m_flashValueStorage.SetFlashArray( "character.mutations.list", mutationsList );
	}
	
	private function filterMutagens( list : array<SItemUniqueId> ):array<SItemUniqueId>
	{
		var isEquipped: bool;
		var tempArray: array<SItemUniqueId>;
		var itemsCount, i : int;
		
		itemsCount = list.Size();
		
		for( i = 0; i < itemsCount; i += 1 )
		{
			if( !GetWitcherPlayer().IsItemEquipped( list[i] ) )
			{
				tempArray.PushBack( list[i] );
			}
		}
		
		return tempArray;
	}
	
	private function CreateMutationFlashDataObj( curMutationId : EPlayerMutationType ) : CScriptedFlashObject
	{
		var mutationData : CScriptedFlashObject;
		
		var mutationResourceList    : CScriptedFlashArray;
		var mutationResourceData    : CScriptedFlashObject;
		var mutationRequirementList : CScriptedFlashArray;
		var mutationRequirementData : CScriptedFlashObject;
		var mutationColorList 		: CScriptedFlashArray;
		var mutationColorData       : CScriptedFlashObject;
		
		var strParams		 	 : array< string >;
		var strIntParams		 : array< int >;
		var colorName			 : string;
		var colorsList    		 : array< ESkillColor >;
		var curRequiredMutations : array< EPlayerMutationType >;
		var curReqMutationType   : EPlayerMutationType;
		var curReqMutation       : SMutation;
		var curMutation    		 : SMutation;
		var curProgress     	 : SMutationProgress;
		var curPlayer      		 : W3PlayerWitcher;
		
		var colorsCount			 : int;
		var unlockedSockets      : int;
		var masterStage			 : int;
		var masterStageLabel 	 : string;
		var masterStageNumbLabel : string;
		var masterStageDesc      : string;
		var nextLevelDescription : string;
		
		var avaliableSkillPoints   : int;
		var overalProgress         : int;
		var i, requirementsCount   : int;
		var progressStrInfo        : string;
		var isResearchEnabled	   : bool;
		var abilityManager         : W3PlayerAbilityManager;
		var requaredResourcesCount : int;
		var usedResourcesCount     : int;
		var researchedMutation	   : int;
		var requaredForNextLevel   : int;
		
		var avaliableRed		   : int;
		var avaliableGreen		   : int;
		var avaliableBlue		   : int;
		var canResearch			   : bool;
		
		var equippedMutationId : EPlayerMutationType;
		
		// W3EE - Begin
		var mutReq : SMutationRequirements;
		var addDescr : string;
		var baseMutagen : name; //Kolaris - Mutation Rework
		var mutationCostMult : float; //Kolaris - Mutation Rework
		// W3EE - End
		
		curPlayer = GetWitcherPlayer();
		abilityManager = ( ( W3PlayerAbilityManager ) curPlayer.abilityManager );
		
		equippedMutationId = curPlayer.GetEquippedMutationType();
		
		curMutation = curPlayer.GetMutation( curMutationId );
		curProgress = curMutation.progress;
		overalProgress = curPlayer.GetMutationResearchProgress( curMutationId );
		mutationData = m_flashValueStorage.CreateTempFlashObject();
		progressStrInfo = overalProgress + " % " + GetLocStringByKeyExt( "mutation_tooltip_research_progress" );
		
		// W3EE - Begin
		baseMutagen = Equipment().GetBaseMutagenForMutation(curMutationId);
		mutationCostMult = Equipment().GetMutationCostMult(curMutationId, baseMutagen);
		//mutReq = Experience().GetMutationPathPointTypes(curMutationId);
		if( overalProgress < 100 && curMutationId != EPMT_Mutation11 && curMutationId != EPMT_Mutation12 )
			addDescr = Equipment().GetRequiredMutagensString(baseMutagen);
			//addDescr = Experience().GetRequiredPathsString(mutReq);
		// W3EE - End
		
		mutationData.SetMemberFlashString( "name", GetLocStringByKeyExt( curMutation.localizationNameKey ) );
		// W3EE - Begin
		mutationData.SetMemberFlashString( "description", curPlayer.GetMutationLocalizedDescription( curMutationId ) + addDescr );
		// W3EE - End
		mutationData.SetMemberFlashString( "iconPath", curMutation.iconPath );
		
		usedResourcesCount = curMutation.progress.blueUsed + curMutation.progress.greenUsed + curMutation.progress.redUsed + curMutation.progress.skillpointsUsed;
		requaredResourcesCount = curMutation.progress.blueRequired + curMutation.progress.redRequired + curMutation.progress.greenRequired + curMutation.progress.skillpointsRequired;
		//Kolaris ++ Mutation Rework
		requaredResourcesCount = RoundMath(requaredResourcesCount * mutationCostMult);
		//Kolaris -- Mutation Rework
		
		mutationData.SetMemberFlashInt( "requaredResourcesCount", requaredResourcesCount );
		mutationData.SetMemberFlashInt( "usedResourcesCount", usedResourcesCount );
		mutationData.SetMemberFlashString( "progressInfo",  progressStrInfo );
		
		mutationData.SetMemberFlashInt( "mutationId", curMutationId );
		mutationData.SetMemberFlashInt( "overallProgress", overalProgress ); 
		mutationData.SetMemberFlashBool( "researchCompleted", overalProgress >= 100 );
		
		if (equippedMutationId == curMutationId)
		{
			mutationData.SetMemberFlashBool( "isEquipped", true );
		}
		
		if( curMutationId == EPMT_MutationMaster )
		{
			masterStage = curPlayer.GetMasterMutationStage();
			
			if( masterStage < 1 )
			{
				strParams.Clear();
				strParams.PushBack(15); strParams.PushBack(10);
				masterStageDesc = GetLocStringByKeyExtWithParams( "mutation_master_mutation_description",,,strParams ) + "<br/>";
			}
			else
			{
				masterStageDesc = "";
			}
			
			requaredForNextLevel = abilityManager.GetMutationsRequiredForMasterStage(masterStage + 1);
			researchedMutation = abilityManager.GetResearchedMutationsCount();
			
			if (masterStage == 0)
			{
				strIntParams.Clear();
				strIntParams.PushBack( requaredForNextLevel );
				mutationData.SetMemberFlashString( "lockedDescription",  GetLocStringByKeyExtWithParams( "mutation_master_mutation_requires_unlock", strIntParams ) );
			}
			else
			{
				strParams.Clear();
				strParams.PushBack(15 * masterStage); strParams.PushBack(10 * masterStage);
				masterStageDesc = masterStageDesc + GetLocStringByKeyExtWithParams( "mutation_master_mutation_tooltip_unlocks",,,strParams );
					
				if (masterStage < MAX_MASTER_MUTATION_STAGE)
				{
					
					strIntParams.Clear();
					strIntParams.PushBack( requaredForNextLevel );
					nextLevelDescription = GetLocStringByKeyExtWithParams( "mutation_master_mutation_requires", strIntParams );
					masterStageDesc = masterStageDesc + "<br/>"+  nextLevelDescription;
				}
			}
			
			switch( masterStage )
			{
				case 1:
					masterStageLabel = GetLocStringByKeyExt( "mutation_master_mutation_stage_1" );
					masterStageNumbLabel = "I";
					break;
				case 2:
					masterStageLabel = GetLocStringByKeyExt( "mutation_master_mutation_stage_2" );
					masterStageNumbLabel = "II";
					break;
				case 3:
					masterStageLabel = GetLocStringByKeyExt( "mutation_master_mutation_stage_3" );
					masterStageNumbLabel = "III";
					break;
				case 4:
					masterStageLabel = GetLocStringByKeyExt( "mutation_master_mutation_stage_4" );
					masterStageNumbLabel = "IV";
					break;
				default:
					masterStageLabel = "";
					masterStageNumbLabel = "";
			}
			
			mutationData.SetMemberFlashInt( "stage",  masterStage );
			mutationData.SetMemberFlashBool( "isMasterMutation", true );
			mutationData.SetMemberFlashString( "stageLabel",  masterStageLabel );
			mutationData.SetMemberFlashString( "stageNumbLabel",  masterStageNumbLabel );
			mutationData.SetMemberFlashString( "name", GetLocStringByKeyExt("skill_name_mutation_master") );
			mutationData.SetMemberFlashString( "description", masterStageDesc);
		}
		else
		{
			
			
			isResearchEnabled = true;
			curRequiredMutations = curMutation.requiredMutations;
			requirementsCount = curRequiredMutations.Size();
			mutationRequirementList = m_flashValueStorage.CreateTempFlashArray();
			
			for( i = 0; i < requirementsCount; i += 1 )
			{
				curReqMutationType = curRequiredMutations[i];
				
				if( !curPlayer.IsMutationResearched( curReqMutationType ) )
				{
					isResearchEnabled = false;
				}
				
				curReqMutation = curPlayer.GetMutation( curReqMutationType );
				mutationRequirementData = m_flashValueStorage.CreateTempFlashObject();
				mutationRequirementData.SetMemberFlashString( "name", GetLocStringByKeyExt( curReqMutation.localizationNameKey ) );
				mutationRequirementData.SetMemberFlashInt( "type", curReqMutationType );
				mutationRequirementList.PushBackFlashObject( mutationRequirementData );
			}
			
			mutationData.SetMemberFlashArray( "requiredMutations", mutationRequirementList );
			mutationData.SetMemberFlashBool( "enabled", isResearchEnabled );
			
			
			//Kolaris ++ Mutation Rework
			/*mutationColorList = m_flashValueStorage.CreateTempFlashArray();
			colorsList = curMutation.colors;
			colorsCount = colorsList.Size();
			
			for( i=0; i < colorsCount; i+=1 )
			{
				mutationColorData = m_flashValueStorage.CreateTempFlashObject();
				mutationColorData.SetMemberFlashString( "color",  colorsList[i] );
				
				switch ( colorsList[i] )
				{
					case SC_Red:
						colorName = GetLocStringByKeyExt("panel_character_skill_sword");
						break;
					case SC_Blue:
						colorName = GetLocStringByKeyExt("panel_character_skill_signs");
						break;						
					case SC_Green:
						colorName = GetLocStringByKeyExt("panel_character_skill_alchemy");
						break;
				}
				
				mutationColorData.SetMemberFlashString( "colorLocName", colorName );
				mutationColorList.PushBackFlashObject( mutationColorData );
			}
			
			mutationData.SetMemberFlashArray( "colorsList", mutationColorList );*/
			//Kolaris -- Mutation Rework
			
			
			mutationResourceList = m_flashValueStorage.CreateTempFlashArray();
			
			// W3EE - Begin
			avaliableSkillPoints = Experience().GetTotalMutationSkillpoints(mutReq);
			// W3EE - End
			mutationResourceData = m_flashValueStorage.CreateTempFlashObject();
			mutationResourceData.SetMemberFlashString( "title", GetLocStringByKeyExt("mutation_research_knowledge") );
			mutationResourceData.SetMemberFlashInt( "type", MRT_SkillPoints );
			mutationResourceData.SetMemberFlashInt( "used", curProgress.skillpointsUsed );
			mutationResourceData.SetMemberFlashInt( "required", curProgress.skillpointsRequired );
			mutationResourceData.SetMemberFlashInt( "avaliableResources", avaliableSkillPoints );
			mutationResourceData.SetMemberFlashUInt( "resourceColor", 0 );
			mutationResourceData.SetMemberFlashString( "resourceName", GetLocStringByKeyExt( "mutation_ability_point" ) );
			mutationResourceData.SetMemberFlashString( "resourceIconPath", "img://icons/skills/ico_skill_point.png" );
			mutationResourceData.SetMemberFlashString( "description", "1 /" + GetLocStringByKeyExt( "mutation_research_point" ) );
			mutationResourceData.SetMemberFlashString( "avaliableResourcesText", GetLocStringByKeyExt( "mutation_research_available" ) );			
			mutationResourceData.SetMemberFlashString( "researchCostText", "1x / " + GetLocStringByKeyExt( "mutation_research_point" ) );
			mutationResourceData.SetMemberFlashUInt( "itemName", 0 );
			mutationResourceList.PushBackFlashObject( mutationResourceData );
			
			
			mutationResourceData = m_flashValueStorage.CreateTempFlashObject();
			mutationResourceData.SetMemberFlashString( "title", GetLocStringByKeyExt("mutation_strain_research_green") );
			mutationResourceData.SetMemberFlashInt( "type", MRT_GreenMutation );
			mutationResourceData.SetMemberFlashInt( "used", curProgress.greenUsed );
			mutationResourceData.SetMemberFlashInt( "required", RoundMath(curProgress.greenRequired * mutationCostMult) ); //Kolaris - Mutation Rework
			
			avaliableGreen = thePlayer.inv.GetUnusedMutagensCount('Greater mutagen green');
			AddItemResearchData( mutationResourceData, 'Greater mutagen green', SC_Green );
			mutationResourceData.SetMemberFlashInt( "avaliableResources", avaliableGreen );
			
			mutationResourceList.PushBackFlashObject( mutationResourceData );
			
			
			mutationResourceData = m_flashValueStorage.CreateTempFlashObject();
			mutationResourceData.SetMemberFlashString( "title", GetLocStringByKeyExt("mutation_strain_research_red") );
			mutationResourceData.SetMemberFlashInt( "type", MRT_RedMutation );
			mutationResourceData.SetMemberFlashInt( "used", curProgress.redUsed );
			mutationResourceData.SetMemberFlashInt( "required", RoundMath(curProgress.redRequired * mutationCostMult) ); //Kolaris - Mutation Rework
			
			avaliableRed = thePlayer.inv.GetUnusedMutagensCount('Greater mutagen red');
			AddItemResearchData( mutationResourceData, 'Greater mutagen red', SC_Red );
			mutationResourceData.SetMemberFlashInt( "avaliableResources", avaliableRed );
			
			mutationResourceList.PushBackFlashObject( mutationResourceData );
			
			
			mutationResourceData = m_flashValueStorage.CreateTempFlashObject();
			mutationResourceData.SetMemberFlashString( "title", GetLocStringByKeyExt("mutation_strain_research_blue") );
			mutationResourceData.SetMemberFlashInt( "type", MRT_BlueMutation );
			mutationResourceData.SetMemberFlashInt( "used", curProgress.blueUsed );
			mutationResourceData.SetMemberFlashInt( "required", RoundMath(curProgress.blueRequired * mutationCostMult) ); //Kolaris - Mutation Rework
			
			avaliableBlue = thePlayer.inv.GetUnusedMutagensCount('Greater mutagen blue');
			AddItemResearchData( mutationResourceData, 'Greater mutagen blue', SC_Blue );
			mutationResourceData.SetMemberFlashInt( "avaliableResources", avaliableBlue );
			mutationResourceList.PushBackFlashObject( mutationResourceData );
			
			mutationData.SetMemberFlashArray( "progressDataList", mutationResourceList );
			//Kolaris ++ Mutation Rework
			canResearch = avaliableRed >= RoundMath(curMutation.progress.redRequired *  mutationCostMult);
			canResearch = canResearch && avaliableGreen >= RoundMath(curMutation.progress.greenRequired * mutationCostMult);
			canResearch = canResearch && avaliableBlue >= RoundMath(curMutation.progress.blueRequired * mutationCostMult);
			canResearch = canResearch && avaliableSkillPoints >= curMutation.progress.skillpointsRequired;
			
			mutationData.SetMemberFlashInt( "redRequired", RoundMath(curMutation.progress.redRequired * mutationCostMult) );
			mutationData.SetMemberFlashInt( "greenRequired", RoundMath(curMutation.progress.greenRequired * mutationCostMult) );
			mutationData.SetMemberFlashInt( "blueRequired", RoundMath(curMutation.progress.blueRequired * mutationCostMult) );
			mutationData.SetMemberFlashInt( "skillpointsRequired", curMutation.progress.skillpointsRequired );
			//Kolaris -- Mutation Rework
		}
		
		mutationData.SetMemberFlashBool( "canResearch", canResearch );
		
		return mutationData;
	}
	
	private function AddItemResearchData( out flashDataObj : CScriptedFlashObject, itemName : name, optional resourceColor : ESkillColor )
	{
		var playerInv    : CInventoryComponent;
		var itemLocName  : string;
		var itemIconPath : string;
		
		playerInv = thePlayer.inv;		
		itemLocName = GetLocStringByKeyExt( playerInv.GetItemLocalizedNameByName( itemName ) );
		itemIconPath = playerInv.GetItemIconPathByName( itemName );		
		
		flashDataObj.SetMemberFlashUInt( "resourceColor", resourceColor );
		flashDataObj.SetMemberFlashString( "avaliableResourcesText", GetLocStringByKeyExt( "mutation_research_available" ) );
		flashDataObj.SetMemberFlashString( "researchCostText", "1x / " + GetLocStringByKeyExt( "mutation_research_point" ) );
		flashDataObj.SetMemberFlashString( "resourceName", itemLocName );
		flashDataObj.SetMemberFlashString( "resourceIconPath", "img://" + itemIconPath );
		flashDataObj.SetMemberFlashString( "description", "1 " + itemLocName + " / " + GetLocStringByKeyExt( "mutation_research_point" ) );
		flashDataObj.SetMemberFlashUInt( "itemName", NameToFlashUInt( itemName ) );
	}
	
	private function PopulateTabData(tabIndex:int, optional skillId:int) : void
	{
		// W3EE - Begin
		switch (tabIndex)
		{
			case CharacterMenuTab_Sword:
				PopulateDataForTabWithSkills(CharacterMenuTab_Sword, ESP_Sword, skillId);
			break;
			
			case CharacterMenuTab_Signs:
				PopulateDataForTabWithSkills(CharacterMenuTab_Signs, ESP_Signs, skillId);
			break;
			
			case CharacterMenuTab_Alchemy:
				PopulateDataForTabWithSkills(CharacterMenuTab_Alchemy, ESP_Alchemy, skillId);
			break;
			
			case CharacterMenuTab_Perks:
				PopulateDataForTabWithSkills(CharacterMenuTab_Perks, ESP_Perks);
			break;
			
			case CharacterMenuTab_Mutagens:
				PopulateDataForMutagenTab();
			break;
		}
		// W3EE - End
	}
	
	private function PopulateDataForTabWithSkills(tabIndex:int, skillType:ESkillPath, optional skillId:int):void
	{
		var gfxSkill      : CScriptedFlashObject;
		var gfxSkillsList : CScriptedFlashArray;
		var skillsList    : array <SSkill>;
		var curSkill      : SSkill;
		var i 	          : int;
		var len		      : int;
		
		gfxSkillsList = m_flashValueStorage.CreateTempFlashArray();
		skillsList = thePlayer.GetPlayerSkills();
		len = skillsList.Size();
		
		for (i=1; i<len; i+=1)
		{
			curSkill = skillsList[i];
			
			if (curSkill.skillPath == skillType && 
				curSkill.skillSubPath != ESSP_NotSet && curSkill.skillSubPath != ESSP_Core)
			{
				gfxSkill = m_flashValueStorage.CreateTempFlashObject();
				GetSkillGFxObject(curSkill, true, gfxSkill);
				
				if( skillType == ESP_Perks )
				{
					gfxSkill.SetMemberFlashInt( "perkPosition", curSkill.positionID );
				}
				
				if (skillId == curSkill.skillType)
				{
					gfxSkill.SetMemberFlashBool("playUpgradeAnimation", true);
				}
				
				gfxSkillsList.PushBackFlashObject(gfxSkill);
			}
		}
		
		PopulateDataForTab(tabIndex, gfxSkillsList);
	}
	
	public function PopulateDataForMutagenTab(optional force: bool):void//Mutagen Sorter
	{
		var mutagenItemData : CScriptedFlashArray;
		var l_flashObject  : CScriptedFlashObject;
		

		mutagenItemData = m_flashValueStorage.CreateTempFlashArray();
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		if (_playerInv)
		{
			if(force)
				_playerInv.GetInventoryFlashArray(mutagenItemData, l_flashObject, MutSort().sortedMutagens);	
			else
				_playerInv.GetInventoryFlashArray(mutagenItemData, l_flashObject);
		}
		
		PopulateDataForTab(CharacterMenuTab_Mutagens, mutagenItemData);
	}
	
	private function PopulateDataForTab(tabIndex:int, entriesArray:CScriptedFlashArray):void
	{
		var l_flashObject : CScriptedFlashObject;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashInt("tabIndex", tabIndex);
		l_flashObject.SetMemberFlashArray("tabData", entriesArray);
		
		if( entriesArray.GetLength() > 0 )
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
		}
		
		m_flashValueStorage.SetFlashObject( "character.menu.tabs.data" + tabIndex, l_flashObject );
	}
	
	private function GetTabForSkill(skillID : ESkill) : CharacterMenuTabIndexes
	{
		var skill : SSkill;
		
		skill = thePlayer.GetPlayerSkill(skillID);
		
		switch ( skill.skillPath )
		{
		case ESP_Sword:
		case ESP_NotSet:
			return CharacterMenuTab_Sword;
		case ESP_Signs:
			return CharacterMenuTab_Signs;
		case ESP_Alchemy:
			return CharacterMenuTab_Alchemy;
		case ESP_Perks:
			return CharacterMenuTab_Perks;
		}
		
		return CharacterMenuTab_Sword;
	}
	
	event  OnStartApplyMode():void
	{
		OnPlaySoundEvent("gui_global_panel_open");
	}
	
	event  OnCancelApplyMode():void
	{
		OnPlaySoundEvent("gui_global_panel_close");
	}
	
	event  OnInventoryItemSelected(itemId:SItemUniqueId) : void
	{
		if (_inv.IsIdValid(itemId))
		{
			_playerInv.ClearItemIsNewFlag(itemId);
		}
	}
	
	event  OnBuySkill(skill : ESkill, slotID : int)
	{
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetLevelAnywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
		}
		// W3EE - End
		else
		{
			// W3EE - Begin
			if( !Options().GetLevelAnywhere() )
			{
				GetWitcherPlayer().AdvanceTimeSeconds( 4800 );
			}
			// W3EE - End
			tryUnequipSkill(skill);
			thePlayer.AddSkill(skill);
			thePlayer.EquipSkill(skill, slotID);
			
			OnPlaySoundEvent("gui_character_buy_skill");
			
			// W3EE - Begin
			/*
			UpdateMasterMutation();
			UpdateSkillPoints();
			PopulateTabData( GetTabForSkill( skill ), skill );
			*/
			
			handleBuySkillConfirmation(skill);
			OnGetSlotSkillTooltipData(skill, 0);
			((W3Effect_Poise)thePlayer.GetBuff(EET_Poise)).UpdateMaxPoise();
			// W3EE - End
		}
	}
	
	event  OnSwapSkill(skill1 : ESkill, slotID1 : int, skill2 : ESkill, slotID2 : int)
	{
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetTalentsEverywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
		}
		// W3EE - End
		else
		{
			thePlayer.EquipSkill(skill1, slotID1);
			thePlayer.EquipSkill(skill2, slotID2);
			
			UpdateAppliedSkills();
			UpdateSkillPoints();			
			UpdatePlayerStatisticsData();						
			UpdateGroupsData();
			UpdateMutagens();
			UpdateMasterMutation();
			
			OnPlaySoundEvent("gui_character_add_skill");
		}
	}
	
	event  OnEquipSkill(skill : ESkill, slotID : int)
	{
		var oldSkill:ESkill;
		var foundSkill:bool;
		var oldSkillSlot:int;
		var targetSlot:SSkillSlot;
		
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetTalentsEverywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
		}
		// W3EE - End
		else
		{
			// W3EE - Begin
			if( !Options().GetTalentsEverywhere() )
			{
				GetWitcherPlayer().AdvanceTimeSeconds( 900 );
			}
			// W3EE - End
			foundSkill = thePlayer.GetSkillOnSlot(slotID, oldSkill);
			
			OnPlaySoundEvent("gui_character_add_skill");
			
			if (!foundSkill || oldSkill != skill)
			{
				tryUnequipSkill(skill);
				
				thePlayer.EquipSkill(skill, slotID);
				
				PopulateTabData(GetTabForSkill(skill));
				
				if (oldSkillSlot != -1)
				{
					m_fxClearSkillSlot.InvokeSelfOneArg(FlashArgInt(oldSkillSlot));
				}
				
				UpdateAppliedSkill(slotID);				
				UpdateMutagens();
				UpdatePlayerStatisticsData();				
				UpdateGroupsData();
				UpdateMasterMutation();
				
				if (oldSkill != S_SUndefined)
				{
					PopulateTabData(GetTabForSkill(oldSkill));
				}
				
				m_fxPaperdollChanged.InvokeSelf();
			}
		}
	}
	
	event  OnUnequipSkill(slotID : int)
	{	
		var skill : ESkill;
		
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
			//UpdateAppliedSkill(slotID);
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetTalentsEverywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
			//UpdateAppliedSkill(slotID);
		}
		// W3EE - End
		else
		{
			thePlayer.GetSkillOnSlot(slotID, skill);
			
			OnPlaySoundEvent("gui_character_remove_skill");
		
			LogChannel('CHR', "OnUnequipSkill " + slotID);
			thePlayer.UnequipSkill(slotID);
			PopulateTabData(GetTabForSkill(skill));
			
			UpdateAppliedSkill(slotID);
			
			UpdateMutagens();
			UpdatePlayerStatisticsData();			
			UpdateGroupsData();
			UpdateMasterMutation();
			
			m_fxPaperdollChanged.InvokeSelf();
		}
	}
	
	event  OnUpdateMutationData()
	{
		UpdateAppliedSkills();
		PopulateTabData(CharacterMenuTab_Mutagens);
		UpdateMutagens();
		UpdateGroupsData();
		UpdatePlayerStatisticsData();
	}
	
	event  OnUpgradeSkill(skillID : ESkill)
	{
		var skill : SSkill;
		var m_guiManager 	  : CR4GuiManager;
		
		skill = thePlayer.GetPlayerSkill(skillID);
		
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetLevelAnywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
		}
		// W3EE - End
		else
		{
			// W3EE - Begin
			if( !Options().GetLevelAnywhere() )
			{
				GetWitcherPlayer().AdvanceTimeSeconds( 1800 );
			}
			
			/*initDataBuySkill = new W3BuySkillConfirmation in this;
			initDataBuySkill.HideTutorial = true;
			
			if (GetWitcherPlayer().GetSkillLevel(skill.skillType) == 0)
			{
				initDataBuySkill.SetMessageTitle(GetLocStringByKeyExt("panel_character_popup_title_buy_skill"));
				initDataBuySkill.SetMessageText(GetLocStringByKeyExt("panel_character_popup_title_buy_skill_text"));
			}
			else
			{
				initDataBuySkill.SetMessageTitle(GetLocStringByKeyExt("panel_character_popup_title_upgrade_skill"));
				initDataBuySkill.SetMessageText(GetLocStringByKeyExt("panel_character_popup_title_upgrade_skill_text"));
			}
			
			initDataBuySkill.characterMenuRef = this;
			initDataBuySkill.targetSkill = skillID;
			initDataBuySkill.BlurBackground = true;
			
			RequestSubMenu('PopupMenu', initDataBuySkill);*/
			
			handleBuySkillConfirmation(skillID);
			OnGetSlotSkillTooltipData(skillID, 0);
			((W3Effect_Poise)thePlayer.GetBuff(EET_Poise)).UpdateMaxPoise();
			// W3EE - End
		}
	}
	
	event  OnMoveMutagenToEmptySlot(itemID:SItemUniqueId, slotFrom:EEquipmentSlots, slotTo:EEquipmentSlots)
	{
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		else
		{
			OnPlaySoundEvent("gui_character_place_mutagen");
			
			GetWitcherPlayer().MoveMutagenToSlot(itemID, slotFrom, slotTo);
			
			UpdateMutagens();
			UpdateGroupsData();
			PopulateTabData(CharacterMenuTab_Mutagens);
			UpdatePlayerStatisticsData();
			UpdateMasterMutation();
			
			m_fxPaperdollChanged.InvokeSelf();
		}
	}
	
	event  OnEquipMutagen(itemID:SItemUniqueId, slotId:EEquipmentSlots)
	{
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetTalentsEverywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
		}
		// W3EE - End
		else
		{
			// W3EE - Begin
			if( !Options().GetTalentsEverywhere() )
			{
				GetWitcherPlayer().AdvanceTimeSeconds( 900 );
			}
			// W3EE - End
			GetWitcherPlayer().EquipItemInGivenSlot(itemID, slotId, false);
			
			OnPlaySoundEvent("gui_character_place_mutagen");
			
			UpdateMutagens();
			UpdateGroupsData();
			PopulateTabData(CharacterMenuTab_Mutagens);
			UpdatePlayerStatisticsData();
			UpdateMasterMutation();
			((W3Effect_Poise)thePlayer.GetBuff(EET_Poise)).UpdateMaxPoise(); //Kolaris - Poise Mutagen Fix
			
			m_fxPaperdollChanged.InvokeSelf();
		}
	}
	
	event  OnUnequipMutagen(slotID : int)
	{
		var mutagen : SItemUniqueId;
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		// W3EE - Begin
		//Kolaris - Campfire Upgrade
		else if( !CampfireManager().CanPerformUpgrade() && !Options().GetTalentsEverywhere() )
		{
			showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
			OnPlaySoundEvent( "gui_global_denied" );
		}
		// W3EE - End
		else
		{
			LogChannel('CHR', "onUnequipMutagen " + slotID);
			GetWitcherPlayer().UnequipItemFromSlot(slotID);
			
			OnPlaySoundEvent("gui_character_remove_mutagen");
			
			RemoveMutagenBonus();
			UpdateMutagens();			
			UpdatePlayerStatisticsData();
			PopulateTabData(CharacterMenuTab_Mutagens);			
			UpdateGroupsData();
			UpdateMasterMutation();
			((W3Effect_Poise)thePlayer.GetBuff(EET_Poise)).UpdateMaxPoise(); //Kolaris - Poise Mutagen Fix
			
			m_fxPaperdollChanged.InvokeSelf();
		}
	}
	
	protected function tryUnequipSkill(skill : ESkill):void
	{
		var currentSkillSlotIdx:int;
		var res:bool;
		
		if (thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
			OnPlaySoundEvent("gui_global_denied");
		}
		else
		{
			currentSkillSlotIdx = thePlayer.GetSkillSlotIndexFromSkill(skill);
			
			LogChannel('CHR', "tryUnequipSkill, currentSkillSlotIdx " + currentSkillSlotIdx);
			if (currentSkillSlotIdx > -1)
			{
				res = thePlayer.UnequipSkill(currentSkillSlotIdx + 1);
			}
			
			m_fxClearSkillSlot.InvokeSelfOneArg(FlashArgInt(currentSkillSlotIdx + 1));
			
			RemoveMutagenBonus();
			UpdateMutagens();
			
		}
	}
	
	public function handleBuySkillConfirmation(skill : ESkill)
	{
		var m_guiManager 	  : CR4GuiManager;	
		
		thePlayer.AddSkill(skill);
		OnPlaySoundEvent("gui_character_buy_skill");
		UpdateSkillPoints();
		
		PopulateTabData( GetTabForSkill( skill ), skill );
		
		UpdateAppliedSkillIfEquipped(skill);
		UpdatePlayerStatisticsData();
		// W3EE - Begin
		//UpdateMutagens();
		// W3EE - End
		UpdateGroupsData();
		m_guiManager = theGame.GetGuiManager();
		m_guiManager.RegisterNewSkillEntry( skill );
		m_fxNotifySkillUpgraded.InvokeSelfOneArg(FlashArgInt(skill));
	}
	
	public function UpdateData(tabs:bool):void
	{
		if (tabs)
		{
			PopulateTabData(CharacterMenuTab_Sword);
			PopulateTabData(CharacterMenuTab_Signs);
			PopulateTabData(CharacterMenuTab_Alchemy);
			PopulateTabData(CharacterMenuTab_Perks);
			PopulateTabData(CharacterMenuTab_Mutagens);
		}
		
		UpdateAppliedSkills();
		UpdateMutagens();
		UpdateSkillPoints();
		UpdatePlayerStatisticsData();
		UpdateGroupsData();
	}
	
	protected function UpdateGroupsData():void
	{
		var gfxGroupsList : CScriptedFlashArray;
		var i, j : int;
		
		gfxGroupsList = m_flashValueStorage.CreateTempFlashArray();
		
		RemoveMutagenBonus();
		
		gfxGroupsList.PushBackFlashObject(CreateBonusGFxData(1));
		gfxGroupsList.PushBackFlashObject(CreateBonusGFxData(2));
		gfxGroupsList.PushBackFlashObject(CreateBonusGFxData(3));
		gfxGroupsList.PushBackFlashObject(CreateBonusGFxData(4));
		
		m_flashValueStorage.SetFlashArray("character.groups.bonus", gfxGroupsList);
	}
	
	private function RemoveMutagenBonus()
	{
		var i : int;
	
			for (i = 0; i < 20; i += 1)
			{
				thePlayer.RemoveAbility( 'greater_mutagen_color_green_x' );
				thePlayer.RemoveAbility( 'greater_mutagen_color_red_x' );
				thePlayer.RemoveAbility( 'greater_mutagen_color_blue_x' );
				thePlayer.RemoveAbility( 'lesser_mutagen_color_green_x' );
				thePlayer.RemoveAbility( 'lesser_mutagen_color_red_x' );
				thePlayer.RemoveAbility( 'lesser_mutagen_color_blue_x' );
				thePlayer.RemoveAbility( 'mutagen_color_green_x' );
				thePlayer.RemoveAbility( 'mutagen_color_red_x' );
				thePlayer.RemoveAbility( 'mutagen_color_blue_x' );
			}	
	}
	
	private function GetGroupBonusDescription( groupId:int, out color : ESkillColor ):string
	{
		var defManager			 	: CDefinitionsManagerAccessor;
		var curAttributeValue, min, max	 : SAbilityAttributeValue;
		var curAttributeCalc	 	: float;
		var curDescription		 	: string;
		var curAbilityName 		 	: name;
		var attributes 			 	: array<name>;	
		var curColorCount,i			: int;
		var hasAbility		     	: bool;
		var mutagen 				: SItemUniqueId;
		var hasMutagen				: bool;
		var mutagenStats			: array<SAttributeTooltip>;
		var attributeValue			: float;
		var synergyBonus			: float;
		var pam : W3PlayerAbilityManager;
		
		hasMutagen = GetWitcherPlayer().GetItemEquippedOnSlot(thePlayer.GetMutagenSlotIDFromGroupID(groupId), mutagen);
		
		pam = (W3PlayerAbilityManager)thePlayer.abilityManager;
		curAbilityName = thePlayer.GetSkillGroupBonus(groupId);
		curColorCount =  1 + thePlayer.GetGroupBonusCount( thePlayer.GetInventory().GetSkillMutagenColor( mutagen ), groupId );
		
		hasAbility = thePlayer.HasAbility(curAbilityName);
		
		color = SC_None;
		
		if ((curAbilityName == 'None' || !hasAbility) && !hasMutagen)
		{
			return "";
		}
		
		if (hasMutagen)
		{
			_inv.GetItemStats(mutagen, mutagenStats);
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'mutagen_color_red_synergy_bonus' ) 
			{
				thePlayer.AddAbilityMultiple('mutagen_color_red_x' , curColorCount - 1);
				color = SC_Red;
			}
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'mutagen_color_green_synergy_bonus' ) 		
			{
				thePlayer.AddAbilityMultiple('mutagen_color_green_x' , curColorCount - 1);
				color = SC_Green;
			}
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'mutagen_color_blue_synergy_bonus' ) 
			{
				thePlayer.AddAbilityMultiple('mutagen_color_blue_x' , curColorCount - 1);
				color = SC_Blue;
			}
			
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'mutagen_color_lesser_red_synergy_bonus' ) 
			{
				thePlayer.AddAbilityMultiple('lesser_mutagen_color_red_x' , curColorCount - 1);
				color = SC_Red;
			}
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'mutagen_color_lesser_green_synergy_bonus' ) 		
			{
				thePlayer.AddAbilityMultiple('lesser_mutagen_color_green_x' , curColorCount - 1);
				color = SC_Green;
			}
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'mutagen_color_lesser_blue_synergy_bonus' ) 
			{
				thePlayer.AddAbilityMultiple('lesser_mutagen_color_blue_x' , curColorCount - 1);
				color = SC_Blue;
			}
			
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'greater_mutagen_color_red_synergy_bonus' ) 
			{
				thePlayer.AddAbilityMultiple('greater_mutagen_color_red_x' , curColorCount - 1);
				color = SC_Red;
			}
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'greater_mutagen_color_green_synergy_bonus' ) 		
			{
				thePlayer.AddAbilityMultiple('greater_mutagen_color_green_x' , curColorCount - 1);
				color = SC_Green;
			}
			if ( pam.GetMutagenBonusAbilityName(mutagen) == 'greater_mutagen_color_blue_synergy_bonus' ) 
			{
				thePlayer.AddAbilityMultiple('greater_mutagen_color_blue_x' , curColorCount - 1);
				color = SC_Blue;
			}

			for (i = 0; i < mutagenStats.Size(); i += 1)
			{
				curDescription = mutagenStats[i].attributeName + " ";
				if (i > 0)
				{
					curDescription += ", ";
				}
				
				if (hasAbility)
				{
					attributeValue = mutagenStats[i].value * curColorCount;
				}
				else
				{
					attributeValue = mutagenStats[i].value * curColorCount;
				}
				//Kolaris - Acclimation
				/*if ( GetWitcherPlayer().CanUseSkill ( S_Alchemy_s19 ) )
				{
					synergyBonus = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s19, 'synergy_bonus', false, false));
					synergyBonus *=  GetWitcherPlayer().GetSkillLevel(S_Alchemy_s19);
					attributeValue += attributeValue * synergyBonus;
				}*/
				//Kolaris - Assimilation
				if( GetWitcherPlayer().HasAbility('Glyphword 48 _Stats', true) )
				{
					synergyBonus = 0.f;
					synergyBonus += 0.1f * ((W3Effect_Toxicity)GetWitcherPlayer().GetBuff(EET_Toxicity)).GetToxicityEntryCount();
					attributeValue += attributeValue * synergyBonus;
				}
				if( mutagenStats[i].percentageValue )
				{
					curDescription += "+" + NoTrailZeros(RoundTo(attributeValue * 100, 1)) +"%"; // W3EE
				}
				else
				{
					curDescription += "+" + NoTrailZeros(RoundTo(attributeValue, 1));// W3EE
				}
			}
		}
		else
		{
			
		}
		
		return curDescription;
	}
	
	
	protected function CreateBonusGFxData(index:int):CScriptedFlashObject
	{
		var gfxGroupBonus : CScriptedFlashObject;
		var description   : string;
		var color         : ESkillColor;
		
		description = GetGroupBonusDescription(index, color);
		
		if (index > m_previousSkillBonuses.Size())
		{
			m_previousSkillBonuses.PushBack(description);
		}
		else if (m_previousSkillBonuses[index] != description)
		{
			m_previousSkillBonuses[index] = description;
			if (description == "")
			{
				OnPlaySoundEvent("gui_character_synergy_effect_lose");
			}
			else
			{
				OnPlaySoundEvent("gui_character_synergy_effect");
			}
		}
		
		gfxGroupBonus = m_flashValueStorage.CreateTempFlashObject();
		gfxGroupBonus.SetMemberFlashString('description', description);
		gfxGroupBonus.SetMemberFlashInt('color', color);
		
		return gfxGroupBonus;
	}
	
	protected function UpdateAppliedSkills():void
	{		
		var gfxSlots           : CScriptedFlashObject;
		var gfxSlotsList       : CScriptedFlashArray;
		var curSlot            : SSkillSlot;
		var equipedSkill       : SSkill;
		var skillSlots         : array<SSkillSlot>;
		var slotsCount 	       : int;
		var i 	               : int;
		var equippedMutationId : EPlayerMutationType;
		var equippedMutation   : SMutation;
		var colorsList		   : array< ESkillColor >;
		var colorBorderId      : string;
		
		gfxSlotsList = m_flashValueStorage.CreateTempFlashArray();
		skillSlots = thePlayer.GetSkillSlots();
		slotsCount = skillSlots.Size();
		equippedMutationId = GetWitcherPlayer().GetEquippedMutationType();
		
		if( equippedMutationId != EPMT_None )
		{
			equippedMutation = GetWitcherPlayer().GetMutation( equippedMutationId );
		}
		
		LogChannel( 'CHR', "UpdateAppliedSkills add " + slotsCount + " items" );
		
		for( i=0; i < slotsCount; i+=1 )
		{
			curSlot = skillSlots[i];
			equipedSkill = thePlayer.GetPlayerSkill( curSlot.socketedSkill );
			
			gfxSlots = m_flashValueStorage.CreateTempFlashObject();
			GetSkillGFxObject( equipedSkill, false, gfxSlots );
			
			gfxSlots.SetMemberFlashInt( 'tabId', GetTabForSkill( curSlot.socketedSkill ) );
			gfxSlots.SetMemberFlashInt( 'slotId', curSlot.id );
			
			gfxSlots.SetMemberFlashInt( 'unlockedOnLevel', curSlot.unlockedOnLevel );
			
			gfxSlots.SetMemberFlashInt( 'groupID', curSlot.groupID );
			
			gfxSlots.SetMemberFlashBool( 'unlocked', curSlot.unlocked );
			
			colorBorderId = "";
			if( curSlot.id >= BSS_SkillSlot1 )
			{
				gfxSlots.SetMemberFlashBool( 'isMutationSkill', true );
				gfxSlots.SetMemberFlashInt( 'unlockedOnLevel', ( curSlot.id - BSS_SkillSlot1 + 1 ) );
				
				if (equippedMutationId != EPMT_None)
				{
					colorsList = equippedMutation.colors;
					
					if( colorsList.Contains(SC_Red) )
					{
						colorBorderId += "Red";
					}
					
					if( colorsList.Contains(SC_Green) )
					{
						colorBorderId += "Green";
					}
					
					if( colorsList.Contains(SC_Blue) )
					{
						colorBorderId += "Blue";
					}
				}
				
				gfxSlots.SetMemberFlashString( 'colorBorder', colorBorderId );
			}
			else
			{
				gfxSlots.SetMemberFlashInt( 'unlockedOnLevel', curSlot.unlockedOnLevel );
			}
			
			gfxSlotsList.PushBackFlashObject( gfxSlots );
		}
		
		m_flashValueStorage.SetFlashArray( "character.skills.slots", gfxSlotsList );
	}
	
	protected function SkillColorEnumToName( color : ESkillColor ) : void
	{
		
	}
	
	protected function GetSlotForSkill(skill : ESkill):int
	{
		var curSlot      : SSkillSlot;
		var skillSlots   : array<SSkillSlot>;
		var slotsCount 	 : int;
		var i 	         : int;
		var slotID:int;
		
		slotID = -1;
		
		skillSlots = thePlayer.GetSkillSlots();
		slotsCount = skillSlots.Size();
		
		for (i=0; i<slotsCount; i+=1)
		{
			curSlot = skillSlots[i];
			
			if (curSlot.socketedSkill == skill)
			{
				slotID = curSlot.id;
				break;
			}
		}
		
		return slotID;
	}
	
	protected function UpdateAppliedSkillIfEquipped(skill : ESkill):void
	{
		var slotId: int;
		
		slotId = GetSlotForSkill(skill);
		
		if (slotId != -1)
		{
			UpdateAppliedSkill(slotId);
		}
	}
	
	protected function UpdateAppliedSkill(slotID:int):void
	{
		var curSlot      : SSkillSlot;
		var skillSlots   : array<SSkillSlot>;
		var slotsCount 	 : int;
		var i 	         : int;
		var foundSlot	 : bool;
		
		foundSlot = false;
		
		skillSlots = thePlayer.GetSkillSlots();
		slotsCount = skillSlots.Size();
		
		for (i=0; i<slotsCount; i+=1)
		{
			curSlot = skillSlots[i];
			
			if (curSlot.id == slotID)
			{
				foundSlot = true;
				break;
			}
		}
		
		if (foundSlot)
		{
			SendEquippedSkillInfo(curSlot);
		}
	}
	
	protected function SendEquippedSkillInfo(curSlot : SSkillSlot):void
	{
		var gfxSlot       : CScriptedFlashObject;
		var equipedSkill  : SSkill;
		var colorsList    : array< ESkillColor >;
		var colorBorderId : string;
		var equippedMutationId : EPlayerMutationType;
		var equippedMutation   : SMutation;
		
		equippedMutationId = GetWitcherPlayer().GetEquippedMutationType();
		
		if( equippedMutationId != EPMT_None )
		{
			equippedMutation = GetWitcherPlayer().GetMutation( equippedMutationId );
		}
		
		equipedSkill = thePlayer.GetPlayerSkill(curSlot.socketedSkill);
		
		gfxSlot = m_flashValueStorage.CreateTempFlashObject();
		GetSkillGFxObject(equipedSkill, false, gfxSlot);
		
		gfxSlot.SetMemberFlashInt('tabId', GetTabForSkill(curSlot.socketedSkill));
		gfxSlot.SetMemberFlashInt('slotId', curSlot.id);
		gfxSlot.SetMemberFlashInt('unlockedOnLevel', curSlot.unlockedOnLevel);
		gfxSlot.SetMemberFlashInt('groupID', curSlot.groupID);
		gfxSlot.SetMemberFlashBool('unlocked', curSlot.unlocked);
		
		colorBorderId = "";
		if( equippedMutationId != EPMT_None && curSlot.id >= BSS_SkillSlot1 )
		{
			colorsList = equippedMutation.colors;
			
			if( colorsList.Contains(SC_Red) )
			{
				colorBorderId += "Red";
			}
			
			if( colorsList.Contains(SC_Green) )
			{
				colorBorderId += "Green";
			}
			
			if( colorsList.Contains(SC_Blue) )
			{
				colorBorderId += "Blue";
			}
			
			gfxSlot.SetMemberFlashString( 'colorBorder', colorBorderId );
		}
		
		m_flashValueStorage.SetFlashObject( "character.skills.slot.update", gfxSlot);
	}
	
	protected function UpdateMutagens():void
	{
		var idx               : int;
		var mutCount          : int;
		var slotUnlocked      : bool;
		var gfxMutSlot        : CScriptedFlashObject;
		var gfxMutSlotsList   : CScriptedFlashArray;
		var skillMutagenSlots : array<SMutagenSlot>;
		var currentMutSlot	  : SMutagenSlot;
		var invComponent      : CInventoryComponent;
		var playerInv 		  : W3GuiPlayerInventoryComponent;
		
		invComponent = thePlayer.GetInventory();
		playerInv = new W3GuiPlayerInventoryComponent in this;
		playerInv.Initialize( invComponent );
		
		gfxMutSlotsList = m_flashValueStorage.CreateTempFlashArray();
		skillMutagenSlots = thePlayer.GetPlayerSkillMutagens();
		mutCount = skillMutagenSlots.Size();
		
		for (idx = 0; idx < mutCount; idx+=1)
		{
			currentMutSlot = skillMutagenSlots[idx];
			gfxMutSlot = m_flashValueStorage.CreateTempFlashObject();
			
			// W3EE - Begin
			if ( Options().AllMutagensUnlocked() )
				slotUnlocked = true;
			else
				//Kolaris - Mutagen Slots
				slotUnlocked = GetWitcherPlayer().GetSkillLevel(S_Alchemy_s19) >= currentMutSlot.unlockedAtLevel;
			// W3EE - End
			
			gfxMutSlot.SetMemberFlashInt('slotId', currentMutSlot.equipmentSlot);
			gfxMutSlot.SetMemberFlashInt('groupId', currentMutSlot.skillGroupID);
			gfxMutSlot.SetMemberFlashString('slotType', currentMutSlot.equipmentSlot);
			gfxMutSlot.SetMemberFlashBool('unlocked', slotUnlocked);
			gfxMutSlot.SetMemberFlashInt('unlockedAtLevel', currentMutSlot.unlockedAtLevel);
			
			if (invComponent.IsIdValid(currentMutSlot.item))
			{
				playerInv.SetInventoryFlashObjectForItem(currentMutSlot.item, gfxMutSlot);
				gfxMutSlot.SetMemberFlashString('color', invComponent.GetSkillMutagenColor(currentMutSlot.item));
			}
			else
			{
				gfxMutSlot.SetMemberFlashString('color', SC_None);
			}
			gfxMutSlotsList.PushBackFlashObject(gfxMutSlot);
		}
		m_flashValueStorage.SetFlashArray( "character.skills.mutagens", gfxMutSlotsList);
	}
	
	protected function GetSkillGFxObject(curSkill : SSkill, isGridView:bool, out dataObject : CScriptedFlashObject) : void
	{
		var skillColor:ESkillColor;
		var subPathName:string;
		
		var originSkillLevel : int;
		var boostedSkillLevel : int;
		
		skillColor = thePlayer.GetSkillColor(curSkill.skillType);
		
		dataObject.SetMemberFlashInt('id', curSkill.skillType); 
		dataObject.SetMemberFlashInt('skillTypeId', curSkill.skillType);
		
		originSkillLevel = GetWitcherPlayer().GetBoughtSkillLevel(curSkill.skillType);
		
		if ( isGridView )
		{
			dataObject.SetMemberFlashInt('level', originSkillLevel);
		}
		else
		{
			boostedSkillLevel = GetWitcherPlayer().GetSkillLevel(curSkill.skillType);
			dataObject.SetMemberFlashInt('level', boostedSkillLevel);
			
			if (originSkillLevel < boostedSkillLevel)
			{
				dataObject.SetMemberFlashBool('highlight', true);
			}
		}
		
		dataObject.SetMemberFlashInt('maxLevel', curSkill.maxLevel);
		dataObject.SetMemberFlashInt('requiredPointsSpent', curSkill.requiredPointsSpent);
		
		dataObject.SetMemberFlashString('dropDownLabel', GetLocStringByKeyExt( SkillPathTypeToName( curSkill.skillPath ) ) );
		dataObject.SetMemberFlashString('skillType', curSkill.skillType);
		dataObject.SetMemberFlashString('skillPath', curSkill.skillPath); 
		dataObject.SetMemberFlashString('skillSubPath',  SkillSubPathTypeToName( curSkill.skillSubPath ) );
		dataObject.SetMemberFlashString('abilityName', curSkill.abilityName); 
		dataObject.SetMemberFlashString('cost', curSkill.cost);
		dataObject.SetMemberFlashString('iconPath', curSkill.iconPath);
		dataObject.SetMemberFlashString('isCoreSkill', curSkill.isCoreSkill);
		dataObject.SetMemberFlashString('skillPathPoints', SkillsPathsPointsSpent(curSkill));
		
		dataObject.SetMemberFlashString('positionID', curSkill.positionID);
		dataObject.SetMemberFlashString('color', skillColor);
		
		dataObject.SetMemberFlashBool('hasRequiredPointsSpent', CheckIfLocked(curSkill));
		
		dataObject.SetMemberFlashBool('updateAvailable', CheckIfAvailable(curSkill));
		dataObject.SetMemberFlashBool('notEnoughPoints', ( GetCurrentSkillPoints(SkillNameToEnum(curSkill.abilityName)) <= 0 ));
		
		if (curSkill.skillType == S_SUndefined)
		{
			dataObject.SetMemberFlashBool('isEquipped', false);
		}
		else
		{
			dataObject.SetMemberFlashBool('isEquipped', thePlayer.IsSkillEquipped(curSkill.skillType));
		}
		dataObject.SetMemberFlashBool('isCoreSkill', curSkill.isCoreSkill);
	}
	
	protected function CheckIfLocked( skill : SSkill ) : bool 
	{
		var skillType : ESkill;
		skillType = SkillNameToEnum(skill.abilityName);
		return GetWitcherPlayer().HasSpentEnoughPoints(skillType);
	}
	
	protected function SkillsPathsPointsSpent( skill : SSkill ) : int 
	{
		var skillType : ESkill;
		skillType = SkillNameToEnum(skill.abilityName);
		return GetWitcherPlayer().PathPointsForSkillsPath(skillType);
	}
	
	protected function UpdateSkillPoints() : void
	{
		// W3EE - Begin
		UpdatePointDisplay(currentlySelectedTab);
		m_flashValueStorage.SetFlashInt( "character.skills.points", 1);
		// W3EE - End
	}
	
	private function CheckIfAvailable( skill : SSkill ) : bool
	{
		var skillType : ESkill;
		skillType = SkillNameToEnum(skill.abilityName);
		return GetWitcherPlayer().CanLearnSkill(skillType);
	}

	private function GetCurrentSkillPoints( skill : ESkill ) : int
	{
		var levelManager : W3LevelManager;
		
		// W3EE - Begin	
		//levelManager = GetWitcherPlayer().levelManager;
		if( Options().NoSkillPointReq() )
			return 1000;
		else
			return Experience().GetCurrentPathPoints(GetWitcherPlayer().GetSkillSubPathType(skill));
		// W3EE - End
	}
	
	private function GetSkillTooltipDescriptionForSkillLevel(targetSkill : SSkill, skillLevel : int) : string
	{
		var baseString	: string;
		var locKey		: string;
		
		//Kolaris - Skill Tooltips
		/*if (skillLevel == 2)
		{
			
			locKey = targetSkill.localisationDescriptionLevel2Key;
		}
		else if (skillLevel >= 3)
		{
			
			locKey = targetSkill.localisationDescriptionLevel3Key;
		}
		else
		{
			
			locKey = targetSkill.localisationDescriptionKey;
		}*/
		locKey = targetSkill.localisationDescriptionKey;
		if ( skillLevel == 0)
			skillLevel = 1;
		
		if (targetSkill.skillType <= S_Sword_s21)
			baseString = GetSwordSkillsTooltipDescription(targetSkill, skillLevel, locKey);
		else if (targetSkill.skillType <= S_Magic_s20)
			baseString = GetSignSkillsTooltipDescription(targetSkill, skillLevel, locKey);
		else if (targetSkill.skillType <= S_Alchemy_s20)
			baseString = GetAlchemySkillsTooltipDescription(targetSkill, skillLevel, locKey);
		else if (targetSkill.skillType <= S_Perk_MAX)
			baseString = GetPerkTooltipDescription(targetSkill, skillLevel, locKey);
		
		return baseString;
	}
	
	private function GetSwordSkillsTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
	{
		var baseString	: string;
		var argsInt 	: array<int>;
		var argsFloat	: array<float>;
		var argsString	: array< string >;
		var arg			: float;
		var arg_focus	: float;
		var ability		: SAbilityAttributeValue;
		var min, max	: SAbilityAttributeValue;
		var dm 			: CDefinitionsManagerAccessor;
		var store		: float;
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue('sword_adrenalinegain', 'focus_gain', min, max);
		ability =  GetAttributeRandomizedValue(min, max);
		arg_focus = ability.valueAdditive;
		
		switch (targetSkill.skillType)
		{
			// Aard
			case S_Magic_1:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
				arg = 500;
				if (GetWitcherPlayer().GetSkillLevel(S_Magic_s20) >= 2)
					arg += 125;
				if (GetWitcherPlayer().GetSkillLevel(S_Magic_s20) >= 4)
					arg += 125;
				arg += 50 * GetWitcherPlayer().GetSkillLevel(S_Magic_s12);
				arg *= ability.valueMultiplicative;
				argsInt.PushBack(RoundMath(arg));
				//Kolaris - Shockwave
				argsInt.PushBack(RoundMath((10 * ability.valueMultiplicative)));
				argsInt.PushBack(RoundMath((5 + GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * 3) * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams("W3EE_AardSkill", argsInt);
			break;
			
			// Igni
			case S_Magic_2:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
				//Kolaris - Pyromaniac
				arg = (GetWitcherPlayer().GetSkillLevel(S_Magic_s09) * 40 + 200) * ability.valueMultiplicative;
				argsInt.PushBack(RoundMath(arg));
				arg = (GetWitcherPlayer().GetSkillLevel(S_Magic_s07) * 0.05f + 0.2f) * ability.valueMultiplicative + 0.3f;
				argsInt.PushBack(RoundMath(arg * 100));
				baseString = GetLocStringByKeyExtWithParams("W3EE_IgniSkill", argsInt);
			break;
			
			// Yrden
			case S_Magic_3:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				//Kolaris - Griffin Set Bonus
				if( GetWitcherPlayer().IsSetBonusActive(EISB_Gryphon_1) )
					argsInt.PushBack(25);
				else
					argsInt.PushBack(15);
				arg = 20 + 20 * GetWitcherPlayer().GetSkillLevel(S_Magic_s11) ;
				argsInt.PushBack(RoundMath(arg * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath(2 * ability.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod()));
				argsInt.PushBack(RoundMath((3 + GetWitcherPlayer().GetSkillLevel(S_Magic_s16)) * ability.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod()));
				arg = 40;
				if (GetWitcherPlayer().GetSkillLevel(S_Magic_s10) >= 1)
					arg += GetWitcherPlayer().GetSkillLevel(S_Magic_s10) * 4;
				arg *= ability.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod();
				argsInt.PushBack(RoundMath(arg));
				baseString = GetLocStringByKeyExtWithParams("W3EE_YrdenSkill", argsInt);
			break;
			
			// Quen
			case S_Magic_4:
				argsInt.PushBack(50 - 5 * GetWitcherPlayer().GetSkillLevel(S_Magic_s14));
				arg = 1000;
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
				arg *= ability.valueMultiplicative;
				argsInt.PushBack(RoundMath(arg));
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true));
				arg *= ability.valueMultiplicative * 1.5f * GetWitcherPlayer().GetPlayerSignDurationMod();
				argsInt.PushBack(RoundMath(arg));
				baseString = GetLocStringByKeyExtWithParams("W3EE_QuenSkill", argsInt);
			break;
			
			// Axii
			case S_Magic_5:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
				arg = 75.f + 5.f * GetWitcherPlayer().GetSkillLevel(S_Magic_s19);
				argsInt.PushBack(RoundMath(arg * ability.valueMultiplicative));
				arg = 10.f + 2.f * GetWitcherPlayer().GetSkillLevel(S_Magic_s19);
				argsInt.PushBack(RoundMath(arg * ability.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod()));
				baseString = GetLocStringByKeyExtWithParams("W3EE_AxiiSkill", argsInt);
			break;
			
			
			
			// Fast Attack
			case S_Sword_1:
				baseString = GetLocStringByKeyExtWithParams("W3EE_FastAttackSkill", argsInt);
			break;
			
			// Strong Attack
			case S_Sword_2:
				argsInt.PushBack(25);
				baseString = GetLocStringByKeyExtWithParams("W3EE_StrongAttackSkill", argsInt);
			break;
			
			// Defense
			case S_Sword_3:
				baseString = GetLocStringByKeyExtWithParams("W3EE_DefenseSkill", argsInt);
			break;
			
			// Ranged
			case S_Sword_4:
				baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
			break;
			
			// Battle Trance
			case S_Sword_5:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_5, PowerStatEnumToName(CPS_AttackPower), false, true);
				argsInt.PushBack( RoundMath( ability.valueMultiplicative * 100) );
				baseString = GetLocStringByKeyExtWithParams("W3EE_VigorSkill", argsInt);
			break;
			
			
			
			// Muscle Memory
			case S_Sword_s21:
				argsInt.PushBack(FloorF(skillLevel * 2.f));
				argsInt.PushBack(FloorF(skillLevel * 2.f));
				baseString = GetLocStringByKeyExtWithParams("W3EE_MuscleMemorySkill", argsInt);
			break;
			
			// Precise Blows
			case S_Sword_s17:
				argsInt.PushBack(4 * skillLevel);
				argsInt.PushBack(2 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_PreciseBlowsSkill", argsInt);
			break;
			
			// Whirl
			//Kolaris - Whirl
			case S_Sword_s01:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, false);				
				argsInt.PushBack( RoundMath(ability.valueMultiplicative * 100 * skillLevel) );
				argsInt.PushBack(5 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Crippling Strikes
			//Kolaris - Crippling Strikes
			case S_Sword_s05:
				argsInt.PushBack(10 * skillLevel);
				argsFloat.PushBack(0.01 * 100);
				argsFloat.PushBack(0.1 * 100);
				argsInt.PushBack(2 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			
			
			// Strength Training
			case S_Sword_s04:
				argsInt.PushBack(FloorF(skillLevel * 2.f));
				argsInt.PushBack(FloorF(skillLevel * 4.f));
				baseString = GetLocStringByKeyExtWithParams("W3EE_StrTrainingSkill", argsInt);
			break;
			
			// Crushing Blows
			case S_Sword_s08:
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, false)) * skillLevel;
				argsInt.PushBack(RoundMath(3.f * skillLevel));
				argsInt.PushBack(RoundMath(arg * 100));
				baseString = GetLocStringByKeyExtWithParams("W3EE_CrushingBlowSkill", argsInt);
			break;
			
			// Rend
			case S_Sword_s02:
				argsInt.PushBack(3 * skillLevel);
				argsInt.PushBack(3 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_RendSkill", argsInt);
			break;
			
			// Sundering Blows
			case S_Sword_s06:
				argsInt.PushBack(10 * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			
			
			// Heightened Senses
			//Kolaris - Heightened Senses
			case S_Sword_s10:
				argsFloat.PushBack(10.f * skillLevel);
				argsFloat.PushBack(200.f - 10.f * skillLevel);
				argsFloat.PushBack(10.f * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey,, argsFloat);
			break;
			
			// Fleet Footed
			//Kolaris - Footwork
			case S_Sword_s09:
				argsInt.PushBack(4 * skillLevel);
				argsInt.PushBack(4 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Counterattack
			case S_Sword_s11:
				// Base Effects
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s11, 'attack_power', false, false);
				argsFloat.PushBack(RoundMath(ability.valueMultiplicative * skillLevel * 100));
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s11, 'critical_hit_chance', false, false);
				argsFloat.PushBack(RoundMath(ability.valueAdditive * skillLevel* 100));
				
				// Kick
				argsFloat.PushBack(15 * skillLevel);
				argsFloat.PushBack(2);
				
				// Slash
				argsFloat.PushBack(50);
				argsFloat.PushBack(skillLevel);
				
				baseString = GetLocStringByKeyExtWithParams("W3EE_CounterattackLvl2", argsInt, argsFloat);
			break;
			
			// Deadly Precision
			case S_Sword_s03:
				argsInt.PushBack(4 * skillLevel);
				argsInt.PushBack(4 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			
			
			// Lightning Reflexes
			//Kolaris - Steady Shot
			case S_Sword_s13:
				argsInt.PushBack(5 * skillLevel);
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s13, 'slowdown_mod', false, false)) * skillLevel;
				argsInt.PushBack(RoundMath(40 + arg * 100));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Cold Blood
			case S_Sword_s15:
				argsFloat.PushBack(20 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_ColdBloodLvl1", argsInt, argsFloat);
			break;
			
			// Anatomical Knowledge
			case S_Sword_s07:
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_CHANCE, false, false)) * skillLevel;
				argsInt.PushBack(5 * skillLevel);
				argsInt.PushBack(RoundMath(arg*100));
				baseString = GetLocStringByKeyExtWithParams("W3EE_AnKnowlSkill", argsInt);
			break;
			
			// Crippling shot
			case S_Sword_s12:
				argsInt.PushBack(RoundMath(4 * skillLevel));
				argsInt.PushBack(FloorF(10 * skillLevel));
				baseString = GetLocStringByKeyExtWithParams("W3EE_CripplingShot2", argsInt);
			break;
			
			
			
			// Resolve
			//Kolaris - Resolve
			case S_Sword_s16:
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, false)) * skillLevel;
				argsInt.PushBack(RoundMath(arg*50));
				argsInt.PushBack(RoundMath(arg*50));
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Undying
			//Kolaris - Undying
			case S_Sword_s18:
				argsFloat.PushBack(50);
				argsFloat.PushBack(0.3f * skillLevel);
				argsFloat.PushBack(1.f * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey,,argsFloat);
			break;
			
			// Razor Focus
			//Kolaris - Razor Focus
			case S_Sword_s20:
				argsInt.PushBack(10 * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				argsFloat.PushBack(0.5f * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			// Flood of Anger
			case S_Sword_s19:
				argsInt.PushBack(5 * skillLevel);
				argsFloat.PushBack(0.1f * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_FloodAngerSkill", argsInt, argsFloat);
			break;
			
			default:
				if (skillLevel == 2) 		baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel2Key);
				else if (skillLevel >= 3) 	baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel3Key);
				else 						baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
		}
		
		return baseString;
	}
	
	private function GetSignSkillsTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
	{
		var baseString	: string;
		var argsInt 	: array<int>;
		var argsFloat	: array<float>;
		var arg, penaltyReduction : float;
		var arg_stamina : float;
		var ability, penalty : SAbilityAttributeValue;
		var min, max	: SAbilityAttributeValue;
		var dm 			: CDefinitionsManagerAccessor;
		
		
		dm = theGame.GetDefinitionsManager();
		
		switch (targetSkill.skillType)
		{
			// Dispersion
			case S_Magic_s20:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
				arg = skillLevel / 2.f;
				argsFloat.PushBack(CeilF(arg));
				arg = 125.f * FloorF(skillLevel / 2) * ability.valueMultiplicative;
				argsInt.PushBack(RoundMath(arg));
				if (skillLevel > 1)
					baseString = GetLocStringByKeyExtWithParams("W3EE_Dispersion2", argsInt, argsFloat);
				else
					baseString = GetLocStringByKeyExtWithParams("W3EE_Dispersion1", , argsFloat);
			break;
			
			// Whirlwind
			//Kolaris - Whirlwind
			case S_Magic_s01:
				argsInt.PushBack(100 - (25 + 5 * skillLevel));
				argsInt.PushBack(100 - (50 + 5 * skillLevel));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Frostbite
			case S_Magic_s12:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
				argsInt.PushBack(RoundMath(50 * skillLevel * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath(50 * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath((1 + skillLevel) * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Shockwave
			case S_Magic_s06:
				argsInt.PushBack(RoundMath(20 * skillLevel));
				argsInt.PushBack(RoundMath(5 + 3 * skillLevel));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;	
			
			
			
			// Melt Armor
			case S_Magic_s08:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
				argsInt.PushBack(RoundMath(2 * skillLevel * ability.valueMultiplicative));
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, false)) * skillLevel;
				argsInt.PushBack(RoundMath(arg*100));
				baseString = GetLocStringByKeyExtWithParams("W3EE_MeltArmorSkill", argsInt);
			break;
			
			// Firestream
			//Kolaris - Firestream
			case S_Magic_s02:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
				arg = 800 + 80 * GetWitcherPlayer().GetSkillLevel(S_Magic_s09);
				argsFloat.PushBack(RoundMath(arg * ability.valueMultiplicative));
				argsFloat.PushBack(25.f);
				argsInt.PushBack(50 + 10 * (skillLevel));
				argsInt.PushBack(10 * (skillLevel));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			// Combustion
			case S_Magic_s07:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
				argsInt.PushBack(10 * skillLevel);
				argsInt.PushBack(CeilF(1.f + skillLevel / 2.f));
				argsInt.PushBack(RoundMath((5 * skillLevel) * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams("W3EE_CombustionSkill", argsInt);
			break;
			
			// Pyromaniac
			case S_Magic_s09:
				//Kolaris - Pyromaniac
				argsInt.PushBack(RoundMath(80 * skillLevel));
				argsInt.PushBack(RoundMath(40 * skillLevel));
				argsInt.PushBack(RoundMath(20 * skillLevel));
				baseString = GetLocStringByKeyExtWithParams("W3EE_PyromaniacSkill", argsInt);
			break;
			
			
			
			
			// Sustained Glyphs
			case S_Magic_s10:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				arg = skillLevel * 4;
				argsInt.PushBack(RoundMath(arg * ability.valueMultiplicative));
				argsInt.PushBack(10 * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_SustainedGlyphs",argsInt);
			break;
			
			// Warding Glyphs
			//Kolaris - Warding Glyphs
			case S_Magic_s03:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				argsInt.PushBack(RoundMath((250 + 50 * skillLevel) * ability.valueMultiplicative));
				argsFloat.PushBack(6.5f - skillLevel / 2.f);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			// Binding Glyphs
			case S_Magic_s16:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				argsInt.PushBack(RoundMath(2 * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath((3 + skillLevel) * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath(3 * skillLevel * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams("W3EE_EnchantedGlyphsSkill", argsInt);
			break;
			
			// Waning Glyphs
			case S_Magic_s11:
				arg = 20 * (skillLevel + 1);
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				if( GetWitcherPlayer().HasAbility('Glyphword 18 _Stats', true) )
					argsInt.PushBack(RoundMath(6 * skillLevel));
				else
					argsInt.PushBack(RoundMath(3 * skillLevel));
				argsInt.PushBack(RoundMath(arg * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams("W3EE_WaningGlyphs",argsInt);
			break;
			
			
			
			// Kolaris - Exploding Shield
			case S_Magic_s13:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
				argsInt.PushBack(70 - 10 * skillLevel);
				argsInt.PushBack(RoundMath(500 * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath(15 + 3 * skillLevel * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			//Kolaris - Active Shield
			case S_Magic_s04:
				argsInt.PushBack(10 * skillLevel);
				argsInt.PushBack(20 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);	
			break;
			
			// Kolaris - Warding Shield
			case S_Magic_s15:
				argsInt.PushBack(25 + 5 * skillLevel);
				argsInt.PushBack(20 + 4 * skillLevel);
				argsInt.PushBack(50 + 5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);	
			break;
			
			// Kolaris - Renewing Shield
			case S_Magic_s14:
				argsInt.PushBack(RoundMath(10 * skillLevel));
				argsInt.PushBack(RoundMath(5 * skillLevel));
				argsInt.PushBack(RoundMath(5 * skillLevel));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			
			
			// Kolaris - Lethargy
			case S_Magic_s17:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
				argsInt.PushBack(RoundMath(skillLevel * 10 * ability.valueMultiplicative));
				argsInt.PushBack(RoundMath(skillLevel * 2 * ability.valueMultiplicative));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Puppet
			//Kolaris - Puppet
			case S_Magic_s05:
				ability = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
				argsInt.PushBack(RoundMath(60 * ability.valueMultiplicative * (1 + (0.2 * GetWitcherPlayer().GetSkillLevel(S_Magic_s19)))));
				argsInt.PushBack(RoundMath(50 + (5 * skillLevel) + (5 * GetWitcherPlayer().GetSkillLevel(S_Magic_s19)) * ability.valueMultiplicative));
				argsInt.PushBack(10);
				argsInt.PushBack(skillLevel + 5);
				argsInt.PushBack(75 - skillLevel * 10);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Link
			case S_Magic_s18:
				argsInt.PushBack(1 + skillLevel);
				argsInt.PushBack(11 - skillLevel);
				argsInt.PushBack(15 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_AxiiLink", argsInt);
			break;
			
			// Domination
			//Kolaris - Domination
			case S_Magic_s19:
				argsInt.PushBack(skillLevel * 5);
				argsInt.PushBack(skillLevel * 20);
				baseString = GetLocStringByKeyExtWithParams("W3EE_AxiiLvl1", argsInt);
			break;
		}
		
		return baseString;
	}
	
	private function GetAlchemySkillsTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
	{
		var baseString		: string;
		var argsInt 		: array<int>;
		var argsFloat		: array<float>;
		var argsString		: array<string>;
		var arg				: float;
		var arg_duration	: float;
		var toxThreshold	: float;
		var ability			: SAbilityAttributeValue;
		var min, max		: SAbilityAttributeValue;
		var dm 				: CDefinitionsManagerAccessor;
		
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue('alchemy_potionduration', 'potion_duration', min, max);
		ability =  GetAttributeRandomizedValue(min, max);
		arg_duration = CalculateAttributeValue(ability);
				
		switch (targetSkill.skillType)
		{
			// Heightened Tolerance
			//Kolaris - Dissolution
			case S_Alchemy_s01:
				argsInt.PushBack(5 * skillLevel);
				argsInt.PushBack(20 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Potion Specialization
			//Kolaris - Purification
			case S_Alchemy_s02:
				argsInt.PushBack(25 - 5 * skillLevel);
				argsInt.PushBack(20 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Remedial Brew
			//Kolaris - Coagulation
			case S_Alchemy_s03:
				argsInt.PushBack(4 * skillLevel);
				argsInt.PushBack(20 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Side Effects
			//Kolaris - Saturation
			case S_Alchemy_s04:
				argsInt.PushBack(20*skillLevel);
				argsInt.PushBack(10*skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			
			
			// Potency
			//Kolaris - Potency
			case S_Alchemy_s12:
				argsInt.PushBack(5 * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Precise Administration
			//Kolaris - Fixative
			case S_Alchemy_s05:
				argsInt.PushBack(20 * skillLevel);
				argsInt.PushBack(20 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Fixative
			//Kolaris - Transfusion
			case S_Alchemy_s06:
				argsInt.PushBack(1 * skillLevel);
				argsInt.PushBack(1 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt); 
			break;
			
			// Emulsion
			case S_Alchemy_s07:
				arg = 50 + (5 * skillLevel);				
				argsInt.PushBack(RoundMath(arg));
				baseString = GetLocStringByKeyExtWithParams("W3EE_Emulsion", argsInt);
			break;
			
			
			
			// Steady Aim
			//Kolaris - Steady Aim
			case S_Alchemy_s09:
				argsInt.PushBack(20 * skillLevel);
				arg = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s09, 'slowdown_mod', false, false)) * skillLevel;
				argsInt.PushBack(RoundMath(40 + arg * 100));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Pyrotechnics
			//Kolaris - Delayed Charge
			case S_Alchemy_s10:
				argsInt.PushBack(1 * skillLevel);
				argsInt.PushBack(10);
				argsFloat.PushBack(0.1f * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			// Riving Blasts
			case S_Alchemy_s08:
				argsInt.PushBack(6 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams("W3EE_RivingBlasts", argsInt);
			break;
			
			// Cluster Bombs
			//Kolaris - Cluster Bombs
			case S_Alchemy_s11:
				argsInt.PushBack(20);
				argsInt.PushBack(2 * skillLevel);
				argsFloat.PushBack(0.1f * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			
			
			// Acquired Tolerance
			//Kolaris - Affinity
			case S_Alchemy_s18:
				argsInt.PushBack(skillLevel * 5);
				argsInt.PushBack(skillLevel * 4);
				argsInt.PushBack(skillLevel * 2);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Tissue Resilience
			//Kolaris - Hunter Instinct
			case S_Alchemy_s13:
				argsInt.PushBack(skillLevel);
				argsInt.PushBack(skillLevel * 4);
				argsInt.PushBack(skillLevel * 2);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Synergy
			//Kolaris - Acclimation
			case S_Alchemy_s19:
				argsInt.PushBack(1 + CeilF(skillLevel / 2.f));
				argsInt.PushBack(10 * FloorF(skillLevel / 2.f));
				if (skillLevel > 1)
					baseString = GetLocStringByKeyExtWithParams("Redux_Acclimation2", argsInt);
				else
					baseString = GetLocStringByKeyExtWithParams("Redux_Acclimation1", argsInt);
			break;
			
			// Adaptation
			//Kolaris - Strain Isolation
			case S_Alchemy_s14:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Alchemy_s14, 'duration', false, false) * skillLevel;				
				argsInt.PushBack(RoundMath(ability.valueMultiplicative*100));
				arg = 5 * skillLevel;
				argsInt.PushBack(RoundMath(arg));
				arg = 10 * skillLevel;
				argsInt.PushBack(RoundMath(arg));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			
			
			// Frenzy
			case S_Alchemy_s16:
				argsInt.PushBack(skillLevel * 3);
				argsInt.PushBack(skillLevel * 10);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Endure Pain
			//Kolaris - Endure Pain
			case S_Alchemy_s20:
				argsInt.PushBack(3 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Adrenal Influence
			//Kolaris - Heightened Tolerance
			case S_Alchemy_s15:
				argsInt.PushBack(8 * skillLevel);
				argsInt.PushBack(10 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Killing Spree
			//Kolaris - Metabolic Control
			case S_Alchemy_s17:
				argsInt.PushBack(10 * skillLevel);
				argsInt.PushBack(5 * skillLevel);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			default:
				if (skillLevel == 2) 		baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel2Key);
				else if (skillLevel >= 3) 	baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel3Key);
				else 						baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
		}
		
		return baseString;
	}
	
	private function GetPerkTooltipDescription(targetSkill : SSkill, skillLevel : int, locKey : string) : string
	{
		var baseString	: string;
		var argsInt 	: array<int>;
		var argsFloat	: array<float>;
		var argsString	: array<string>;
		var arg			: float;
		var ability, temp		: SAbilityAttributeValue;
		
		switch (targetSkill.skillType)
		{
			// Sun and Stars
			case S_Perk_01:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_01, 'vitalityRegen_tooltip', false, true);
				argsInt.PushBack(RoundMath(CalculateAttributeValue(ability)));
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_01, 'staminaRegen_tooltip', false, true);
				argsInt.PushBack(RoundMath(ability.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina)));
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Steady Shot
			//Kolaris - Horseman
			case S_Perk_02:
				argsInt.PushBack(25);
				argsInt.PushBack(50);
				argsInt.PushBack(20);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Balanced Diet
			//Kolaris - Alchemical Studies
			case S_Perk_04:
				argsInt.PushBack(25);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			//Kolaris - Cat School Techniques
			// Cat School Techniques
			case S_Perk_05:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_05, 'safe_dodge_angle_bonus', false, true);
				argsInt.PushBack(RoundMath(CalculateAttributeValue(ability)));
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_05, 'focus_gain', false, true);
				argsFloat.PushBack(ability.valueMultiplicative*100);
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_05, 'injury_resist', false, true);
				argsFloat.PushBack(ability.valueMultiplicative*100);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			//Kolaris - Gryphon School Techniques
			// Gryphon School Techniques
			case S_Perk_06:
				argsInt.PushBack(5);
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_06, 'delayReduction', false, true);
				argsFloat.PushBack(ability.valueMultiplicative*100);
				argsFloat.PushBack(ability.valueMultiplicative*100);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			//Kolaris - Bear School Techniques
			// Bear School Techniques
			case S_Perk_07:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_07, 'staminaRegen', false, true);
				argsFloat.PushBack(ability.valueAdditive);
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_07, 'poiseRegen', false, true);
				argsFloat.PushBack(ability.valueAdditive);
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_07, 'parryKnockdownChance', false, true);
				argsFloat.PushBack(ability.valueAdditive);
				baseString = GetLocStringByKeyExtWithParams(locKey,, argsFloat);
			break;
			
			// Inner Strength
			//Kolaris - Inner Strength
			case S_Perk_09:
				if( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
					argsInt.PushBack(RoundMath((3.f - GetWitcherPlayer().GetSkillLevel(S_Sword_s16) * 0.3) * Options().VigIntLost()));
				else
					argsInt.PushBack(RoundMath(3.f * Options().VigIntLost()));
				baseString = GetLocStringByKeyExtWithParams("W3EE_RageManageSkill", argsInt);
			break;
			
			// Adrenaline Burst
			case S_Perk_10:
				argsInt.PushBack(50);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Focus
			//Kolaris - Coup de Grace
			case S_Perk_11:
				argsInt.PushBack(3);
				argsInt.PushBack(200);
				argsFloat.PushBack(2.f);
				argsFloat.PushBack(1.5f);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt, argsFloat);
			break;
			
			// Enzymatic Induction
			//Kolaris - Alchemical Refinement
			case S_Perk_12:
				argsInt.PushBack(1);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Improved Conditioning
			//Kolaris - Fleet Footed
			case S_Perk_13:
				argsInt.PushBack(15);
				argsInt.PushBack(2);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Gourmet
			//Kolaris - Gourmet
			case S_Perk_15:
				argsInt.PushBack(50);
				argsInt.PushBack(1000);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			//Kolaris - Positioning
			case S_Perk_16:
				argsInt.PushBack(10);
				argsInt.PushBack(20);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Advanced Pyrotechnics
			//Kolaris - Advanced Maintenance
			case S_Perk_18:
				argsInt.PushBack(50);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Battle Frenzy
			//Kolaris - Huntsman
			case S_Perk_19:
				argsInt.PushBack(10);
				argsInt.PushBack(50);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Haggling
			case S_Perk_20:
				baseString = GetLocStringByKeyExt(locKey);
			break;
			
			// Attack is the Best Defense
			case S_Perk_21:
				argsInt.PushBack(10);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			// Strong Back
			case S_Perk_22:
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_22, 'encumbrance', false, true);
				argsInt.PushBack(RoundMath(ability.valueBase));
				argsInt.PushBack(20);
				baseString = GetLocStringByKeyExtWithParams(locKey, argsInt);
			break;
			
			default:
				if (skillLevel == 2) 		baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel2Key);
				else if (skillLevel >= 3) 	baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionLevel3Key);
				else 						baseString = GetLocStringByKeyExt(targetSkill.localisationDescriptionKey);
		}
		
		return baseString;
	}
	
	private function GetSkillTooltipDescription(targetSkill : SSkill, isGridView : bool, out currentLevelDesc : string, out nextLevelDesc : string ) : void
	{
		// W3EE - Begin
		var skillLevel, boostedSkillLevel : int;
		
		currentLevelDesc = "";
		nextLevelDesc = "";
		
		if ( isGridView )
			skillLevel = Clamp(GetWitcherPlayer().GetBoughtSkillLevel(targetSkill.skillType) + GetPreviewSkillLevel(), 0, targetSkill.maxLevel);
		else
			skillLevel = Clamp(GetWitcherPlayer().GetSkillLevel(targetSkill.skillType) + GetPreviewSkillLevel(), 0, targetSkill.maxLevel);
		
		if (skillLevel > 0)
		{
			if (!targetSkill.isCoreSkill)
			{
				currentLevelDesc += "<font color=\"#ecdda8\">" + GetLocStringByKeyExt("panel_character_tooltip_skill_desc_current_level") + ":</font>&#10;";
			}
			currentLevelDesc += GetSkillTooltipDescriptionForSkillLevel(targetSkill, skillLevel);
		}
		
		if( targetSkill.maxLevel > 1 || skillLevel == 0 || skillLevel == 1 )
		{
			boostedSkillLevel = skillLevel + 1;
			boostedSkillLevel = Min(targetSkill.maxLevel, boostedSkillLevel);
			boostedSkillLevel = Max(boostedSkillLevel, 1);
			if (skillLevel < targetSkill.maxLevel || GetPreviewSkillLevel() > 0)
			{
				nextLevelDesc += "<font color=\"#A09588\">" + GetLocStringByKeyExt("panel_character_tooltip_skill_desc_next_level") + ":</font>&#10;";
				nextLevelDesc += GetSkillTooltipDescriptionForSkillLevel(targetSkill, boostedSkillLevel);
			}
		}
		// W3EE - End
	}
	
	event  OnNotEnoughtPoints()
	{
		theSound.SoundEvent( "gui_global_denied" );
		showNotification(GetLocStringByKeyExt("message_common_not_enough_skill_points"));
	}
	
	event  OnGetGridSkillTooltipData(targetSkill : ESkill, compareItemType : int)
	{
		GetSkillTooltipData(targetSkill, compareItemType, true);
	}
	
	event  OnGetSlotSkillTooltipData(targetSkill : ESkill, compareItemType : int)
	{
		GetSkillTooltipData(targetSkill, compareItemType, false);
	}
	
	private function GetSkillTooltipData(targetSkill : ESkill, compareItemType : int, isGridView : bool)
	{
		var abilityMgr 			  : W3PlayerAbilityManager;
		var resultGFxData 	      : CScriptedFlashObject;
		var targetSkillData       : SSkill;
		var targetSubPathLocName  : string;
		var skillCurrentLevelDesc : string;
		var skillNextLevelDesc    : string;
		var skillLevelString	  : string;
		var skillNumPoitnsNeeded  : int;
		var pathPointsSpent		  : int;
		
		var originSkillLevel : int;
		var boostedSkillLevel : int;
		
		// W3EE - Begin
		DisplaySkillProgress(targetSkill);
		
		if( targetSkill != targetedSkill && GetWitcherPlayer().GetSkillMaxLevel(targetSkill) < GetWitcherPlayer().GetSkillLevel(targetSkill) )
			previewSkillLevel = GetWitcherPlayer().GetSkillLevel(targetSkill);
		else
		if( targetSkill != targetedSkill && GetWitcherPlayer().GetSkillMaxLevel(targetSkill) >= GetWitcherPlayer().GetSkillLevel(targetSkill) )
			previewSkillLevel = 0;
		
		targetedSkill = targetSkill;
		// W3EE - End
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		targetSkillData = thePlayer.GetPlayerSkill(targetSkill);
		
		if (targetSkillData.isCoreSkill)
		{
			targetSubPathLocName = "";
		}
		else
		{
			targetSubPathLocName = GetLocStringByKeyExt(SkillSubPathToLocalisationKey(targetSkillData.skillSubPath));
		}
		
		resultGFxData.SetMemberFlashString('skillSubCategory', targetSubPathLocName);
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt(targetSkillData.localisationNameKey));
		
		GetSkillTooltipDescription(targetSkillData, isGridView, skillCurrentLevelDesc, skillNextLevelDesc);
		
		resultGFxData.SetMemberFlashString('nextLevelDescription', skillNextLevelDesc);
		resultGFxData.SetMemberFlashString('isCoreSkill', targetSkillData.isCoreSkill);
		
		if (targetSkillData.isCoreSkill)
		{
			skillLevelString = "<font color=\"#ecdda8\">" +GetLocStringByKeyExt("tooltip_skill_core_category") + "</font>&#10;";
			skillCurrentLevelDesc = "<font color=\"#ecdda8\">" +GetLocStringByKeyExt("tooltip_skill_core_desc") + "</font>&#10;" + skillCurrentLevelDesc;
		}
		else
		{
		
			// W3EE - Begin
			originSkillLevel = Clamp(GetWitcherPlayer().GetBoughtSkillLevel(targetSkillData.skillType) + GetPreviewSkillLevel(),0 , targetSkillData.maxLevel);
			// W3EE - End
			
			if ( isGridView )
			{
				// W3EE - Begin
				if( GetPreviewSkillLevel() > 0 )
					skillLevelString = "<font color = '#ffcc00'>" + GetLocStringByKey("W3EE_Preview");
				// W3EE - End
				
				skillLevelString += " " + originSkillLevel + "/" + targetSkillData.maxLevel;
			}
			else
			{
				boostedSkillLevel = Clamp(GetWitcherPlayer().GetSkillLevel(targetSkillData.skillType) + GetPreviewSkillLevel(), 0, targetSkillData.maxLevel);
				
				if (boostedSkillLevel > originSkillLevel)
				{
					// W3EE - Begin
					if( GetPreviewSkillLevel() > 0 )
						skillLevelString = "<font color = '#ffcc00'>" + GetLocStringByKey("W3EE_Preview");
					// W3EE - End
					
					skillLevelString += " <font color = '#f68104'>" + boostedSkillLevel + "</font>/" + targetSkillData.maxLevel;
				}
				else
				{
					// W3EE - Begin
					if( GetPreviewSkillLevel() > 0 )
						skillLevelString += "<font color = '#ffcc00'>" + GetLocStringByKey("W3EE_Preview");
					// W3EE - End
					
					skillLevelString += " " + boostedSkillLevel + "/" + targetSkillData.maxLevel;
				}
			}
		}
		
		resultGFxData.SetMemberFlashString('currentLevelDescription', skillCurrentLevelDesc);
		resultGFxData.SetMemberFlashString('skillLevelString', skillLevelString);
		
		if ( isGridView )
		{
			resultGFxData.SetMemberFlashInt('level', GetWitcherPlayer().GetBoughtSkillLevel(targetSkillData.skillType));
		}
		else
		{
			resultGFxData.SetMemberFlashInt('level', GetWitcherPlayer().GetSkillLevel(targetSkillData.skillType));
		}
		resultGFxData.SetMemberFlashInt('maxLevel', targetSkillData.maxLevel);
		
		if (targetSkillData.isCoreSkill || CheckIfLocked(targetSkillData))
		{
			skillNumPoitnsNeeded = -1;
		}
		else
		{
			abilityMgr = (W3PlayerAbilityManager)thePlayer.abilityManager;
			
			if( abilityMgr )
			{
				pathPointsSpent = targetSkillData.requiredPointsSpent - abilityMgr.GetPathPointsSpent( targetSkillData.skillPath );
			}
			else
			{
				pathPointsSpent = targetSkillData.requiredPointsSpent;
			}
			
			skillNumPoitnsNeeded = pathPointsSpent;
		}
		
		resultGFxData.SetMemberFlashNumber('requiredPointsSpent', skillNumPoitnsNeeded);
		resultGFxData.SetMemberFlashString('IconPath', targetSkillData.iconPath);
		resultGFxData.SetMemberFlashBool('hasEnoughPoints', CheckIfLocked(targetSkillData));
		// W3EE - Begin
		resultGFxData.SetMemberFlashInt( 'curSkillPoints', GetCurrentSkillPoints(targetSkill) );
		// W3EE - End
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	event  OnGetEmptySlotTooltipData(unlockedAtLevel : int):void
	{
		var resultGFxData 	: CScriptedFlashObject;
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt("panel_character_tooltip_skill_empty_title"));
		resultGFxData.SetMemberFlashString('currentLevelDescription', GetLocStringByKeyExt("panel_character_tooltip_skill_empty_desc"));
		resultGFxData.SetMemberFlashString('nextLevelDescription', "");
		resultGFxData.SetMemberFlashString('skillLevelString', "");
		resultGFxData.SetMemberFlashString('isCoreSkill', false);
		resultGFxData.SetMemberFlashInt('level', -1);
		resultGFxData.SetMemberFlashInt('maxLevel', -1);
		resultGFxData.SetMemberFlashNumber('requiredPointsSpent', -1);		
		resultGFxData.SetMemberFlashString('IconPath', "icons\\Skills\\skill_slot_empty.png");
		resultGFxData.SetMemberFlashBool('hasEnoughPoints', true);
		resultGFxData.SetMemberFlashInt('curSkillPoints', -1);
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	event  OnGetLockedTooltipData(unlockedAtLevel : int):void
	{
		var resultGFxData 	: CScriptedFlashObject;
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt("panel_character_tooltip_skill_locked_title"));
		//W3EE - Begin
		//resultGFxData.SetMemberFlashString('currentLevelDescription', GetLocStringByKeyExt("panel_character_tooltip_skill_locked_desc") + ": " + unlockedAtLevel);
		resultGFxData.SetMemberFlashString('currentLevelDescription', GetLocStringByKeyExt("panel_character_tooltip_skill_locked_desc"));
		//W3EE - End
		resultGFxData.SetMemberFlashString('nextLevelDescription', "");
		resultGFxData.SetMemberFlashString('skillLevelString', "");
		resultGFxData.SetMemberFlashInt('level', -1);
		resultGFxData.SetMemberFlashInt('maxLevel', -1);
		resultGFxData.SetMemberFlashNumber('requiredPointsSpent', -1);		
		resultGFxData.SetMemberFlashString('IconPath', "icons\\Skills\\skill_slot_locked.png");
		resultGFxData.SetMemberFlashBool('hasEnoughPoints', true);
		resultGFxData.SetMemberFlashInt('curSkillPoints', -1);
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	event  OnGetLockedMutationSkillSlotTooltipData(unlockedAtLevel : int):void
	{
		var resultGFxData 	 : CScriptedFlashObject;
		var abilityManager   : W3PlayerAbilityManager;
		var lockDescription  : string;
		var requaredMutCount : int;
		var intParamArray    : array<int>;
		
		abilityManager = ( ( W3PlayerAbilityManager ) GetWitcherPlayer().abilityManager );
		requaredMutCount = abilityManager.GetMutationsRequiredForMasterStage(unlockedAtLevel);
		intParamArray.PushBack(requaredMutCount);
		lockDescription = GetLocStringByKeyExtWithParams("mutation_master_mutation_requires_unlock", intParamArray);
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt("panel_character_tooltip_skill_locked_title"));
		resultGFxData.SetMemberFlashString('currentLevelDescription', lockDescription);
		resultGFxData.SetMemberFlashString('nextLevelDescription', "");
		resultGFxData.SetMemberFlashString('skillLevelString', "");
		resultGFxData.SetMemberFlashInt('level', -1);
		resultGFxData.SetMemberFlashInt('maxLevel', -1);
		resultGFxData.SetMemberFlashNumber('requiredPointsSpent', -1);		
		resultGFxData.SetMemberFlashString('IconPath', "icons\\Skills\\skill_slot_locked.png");
		resultGFxData.SetMemberFlashBool('hasEnoughPoints', true);
		resultGFxData.SetMemberFlashInt('curSkillPoints', -1);
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	event  OnGetMutagenEmptyTooltipData(unlockedAtLevel : int)
	{
		var resultGFxData 	: CScriptedFlashObject;
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt("panel_character_tooltip_mutagen_empty_title"));
		resultGFxData.SetMemberFlashString('currentLevelDescription', GetLocStringByKeyExt("panel_character_tooltip_mutagen_empty_desc"));
		resultGFxData.SetMemberFlashString('nextLevelDescription', "");
		resultGFxData.SetMemberFlashString('skillLevelString', "");
		resultGFxData.SetMemberFlashInt('level', -1);
		resultGFxData.SetMemberFlashInt('maxLevel', -1);
		resultGFxData.SetMemberFlashNumber('requiredPointsSpent', -1);		
		resultGFxData.SetMemberFlashString('IconPath', "icons\\Skills\\mutagen_slot_empty.png");
		resultGFxData.SetMemberFlashBool('hasEnoughPoints', true);
		resultGFxData.SetMemberFlashInt('curSkillPoints', -1);
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	event  OnGetMutagenLockedTooltipData(unlockedAtLevel : int)
	{
		var resultGFxData 	: CScriptedFlashObject;
		
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt("panel_character_tooltip_mutagen_locked_title"));
		resultGFxData.SetMemberFlashString('currentLevelDescription', GetLocStringByKeyExt("panel_character_tooltip_mutagen_locked_desc") + ": " + unlockedAtLevel);
		resultGFxData.SetMemberFlashString('nextLevelDescription', "");
		resultGFxData.SetMemberFlashString('skillLevelString', "");
		resultGFxData.SetMemberFlashInt('level', -1);
		resultGFxData.SetMemberFlashInt('maxLevel', -1);
		resultGFxData.SetMemberFlashNumber('requiredPointsSpent', -1);		
		resultGFxData.SetMemberFlashString('IconPath', "icons\\Skills\\mutagen_slot_locked.png");
		resultGFxData.SetMemberFlashBool('hasEnoughPoints', true);
		resultGFxData.SetMemberFlashInt('curSkillPoints', -1);
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
		
	event  OnGetItemData(item : SItemUniqueId, compareItemType : int)
	{
		var tooltipInv 			: CInventoryComponent;
		var compareItem 		: SItemUniqueId;
		var itemUIData			: SInventoryItemUIData;
		var itemWeight			: SAbilityAttributeValue;
		var compareItemStats	: array<SAttributeTooltip>;
		var itemStats 			: array<SAttributeTooltip>;
		var itemName 			: string;
		var category			: string;
		var typeStr				: string;
		var weight 				: float;
		
		var primaryStatLabel    : string;
		var primaryStatValue    : float;
		var categoryDescription : string;
		var durabilityValue		: string;
		var oilName				: name;
		var idx  				: int;
		var socketsCount		: int;
		var usedSocketsCount	: int;
		var emptySocketsCount	: int;
		var socketItems			: array<name>;
		
		var resultData 			: CScriptedFlashObject;
		var statsList			: CScriptedFlashArray;
		var propsList			: CScriptedFlashArray;
		
		var tmpStr				: string;
		
		GetWitcherPlayer().GetItemEquippedOnSlot(compareItemType, compareItem);
		tooltipInv = _inv;
		itemName = tooltipInv.GetItemName(item);		
		resultData = m_flashValueStorage.CreateTempFlashObject();
		statsList = m_flashValueStorage.CreateTempFlashArray();
		propsList = m_flashValueStorage.CreateTempFlashArray();
		
		if( tooltipInv.IsIdValid(item) )
		{
			_inv.GetItemPrimaryStat(item, primaryStatLabel, primaryStatValue);
			itemName = tooltipInv.GetItemLocNameByID(item);
			// itemName = GetLocStringByKeyExt(itemName);
			resultData.SetMemberFlashString("ItemName", itemName);
			
			
			if( tooltipInv.GetItemName(item) != _inv.GetItemName(compareItem) ) 
			{
				_inv.GetItemStats(compareItem, compareItemStats);
			}
			tooltipInv.GetItemStats(item, itemStats);
			CompareItemsStats(itemStats, compareItemStats, statsList);
			resultData.SetMemberFlashArray("StatsList", statsList);
			
			if( tooltipInv.ItemHasTag(item, 'Quest') || tooltipInv.IsItemIngredient(item) || tooltipInv.IsItemAlchemyItem(item) ) 
			{
				weight = 0;
			}
			else
			{
				weight = tooltipInv.GetItemEncumbrance( item );
			}
			
			category = GetItemCategoryLocalisedString( tooltipInv.GetItemCategory(item) );
			typeStr = GetLocStringByKeyExt("item_category_" + tooltipInv.GetItemCategory(item) );
			resultData.SetMemberFlashString("ItemType", typeStr);
			
			categoryDescription = getCategoryDescription(tooltipInv.GetItemCategory(item));
			resultData.SetMemberFlashString("CommonDescription", categoryDescription); 
			resultData.SetMemberFlashString("UniqueDescription", GetLocStringByKeyExt(tooltipInv.GetItemLocalizedDescriptionByUniqueID(item)));		
			resultData.SetMemberFlashString("PrimaryStatLabel", primaryStatLabel);
			resultData.SetMemberFlashNumber("PrimaryStatValue", primaryStatValue);
			resultData.SetMemberFlashString("ItemRarity", GetItemRarityDescription(item, tooltipInv) );
			resultData.SetMemberFlashString("IconPath", tooltipInv.GetItemIconPathByUniqueID(item) );
			resultData.SetMemberFlashString("ItemCategory", category);
			
			tmpStr = NoTrailZeros( weight );
			addGFxItemStat(propsList, "weight", tmpStr, "attribute_name_weight");
			
			addGFxItemStat(propsList, "price", 0, "panel_inventory_item_price");
			
		
			
			
			
			oilName = _inv.GetOldestOilAppliedOnItem( item, false ).GetOilItemName();
			if (oilName != '')
			{
				addGFxItemStat(propsList, "oil", GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(oilName)));
			}
			
			socketsCount = _inv.GetItemEnhancementSlotsCount( item );
			usedSocketsCount = _inv.GetItemEnhancementCount( item );
			emptySocketsCount = socketsCount - usedSocketsCount;		
			_inv.GetItemEnhancementItems(item, socketItems);
			for (idx = 0; idx < socketItems.Size(); idx+=1)
			{
				addGFxItemStat(propsList, "socket", GetLocStringByKeyExt(socketItems[idx]));
			}
			for (idx = 0; idx < emptySocketsCount; idx+=1)
			{
				addGFxItemStat(propsList, "empty_socket", GetLocStringByKeyExt("panel_inventory_tooltip_empty_socket"));
			}
			
			resultData.SetMemberFlashArray("PropertiesList", propsList);		
			m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
		}
	}
	
	function CompareItemsStats(itemStats : array<SAttributeTooltip>, compareItemStats : array<SAttributeTooltip>, out compResult : CScriptedFlashArray)
	{
		var l_flashObject	: CScriptedFlashObject;
		var attributeVal 	: SAbilityAttributeValue;
		var strDifference 	: string;
		var strDifValue	    : string;
		var percentDiff 	: float;
		var nDifference 	: float;
		var i, j, price 	: int;
		var statsCount		: int;
		
		strDifference = "none";
		statsCount = itemStats.Size();
		for( i = 0; i < statsCount; i += 1 ) 
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			l_flashObject.SetMemberFlashString("name",itemStats[i].attributeName);
			l_flashObject.SetMemberFlashString("color",itemStats[i].attributeColor);
			
			
			for( j = 0; j < compareItemStats.Size(); j += 1 )
			{
				if( itemStats[j].attributeName == compareItemStats[i].attributeName )
				{
					nDifference = itemStats[j].value - compareItemStats[i].value;
					percentDiff = AbsF(nDifference/itemStats[j].value);
					
					
					if(nDifference > 0)
					{
						strDifValue = "(+" + NoTrailZeros(nDifference) + ")";
						if(percentDiff < 0.25) 
							strDifference = "better";
						else if(percentDiff > 0.75) 
							strDifference = "wayBetter";
						else						
							strDifference = "reallyBetter";
					}
					
					else if(nDifference < 0)
					{
						strDifValue = "(" + RoundMath(nDifference) + ")";
						if(percentDiff < 0.25) 
							strDifference = "worse";
						else if(percentDiff > 0.75) 
							strDifference = "wayWorse";
						else						
							strDifference = "reallyWorse";					
					}
					break;					
				}
			}
			l_flashObject.SetMemberFlashString("icon", strDifference);
			l_flashObject.SetMemberFlashBool("primaryStat", itemStats[j].primaryStat);
			
			// W3EE - Begin
			if( itemStats[i].percentageValue )
			{
				l_flashObject.SetMemberFlashString("value","+ " + NoTrailZeros(RoundTo(itemStats[i].value * 100, 1)) +" %");
			}
			else
			{
				l_flashObject.SetMemberFlashString("value","+ " + NoTrailZeros(RoundTo(itemStats[i].value, 1)));
			}
			// W3EE - End
			compResult.PushBackFlashObject(l_flashObject);
		}	
	}
	
	private function getCategoryDescription(itemCategory : name):string
	{	
		switch (itemCategory)
		{
			case 'steelsword':
			case 'silversword':
			case 'crossbow':
			case 'secondary':
			case 'armor':
			case 'pants':
			case 'gloves':
			case 'boots':
			case 'armor':
			case 'bolt':
				return GetLocStringByKeyExt("item_category_" + itemCategory + "_desc");
				break;
			default:
				return "";
				break;
		}
		return "";
	}
	
	function GetItemRarityDescription( item : SItemUniqueId, tooltipInv : CInventoryComponent ) : string
	{
		var itemQuality : int;
		
		itemQuality = tooltipInv.GetItemQuality(item);
		return GetItemRarityDescriptionFromInt(itemQuality);
	}
	
	private function addGFxItemStat(out targetArray:CScriptedFlashArray, type:string, value:string, optional label:string):void
	{
		var resultData : CScriptedFlashObject;
		var labelLoc   : string;
		
		resultData = m_flashValueStorage.CreateTempFlashObject();
		resultData.SetMemberFlashString("type", type);
		resultData.SetMemberFlashString("value", value);
		if (label != "")
		{
			labelLoc = GetLocStringByKeyExt(label);
			resultData.SetMemberFlashString("label", labelLoc);
		}
		targetArray.PushBackFlashObject(resultData);
	}
	
	function UpdatePlayerStatisticsData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;		
		var valueStr 				: string;
		var statsNr 				: int;
		var statName 				: name;
		var i 						: int;
		var lastSentStatString		: string;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		
		AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dps", "attack_silver", l_flashArray, m_flashValueStorage); 
		AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dps", "attack_steel", l_flashArray, m_flashValueStorage); 
		AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", l_flashArray, m_flashValueStorage); 
		AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", l_flashArray, m_flashValueStorage);
		AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", l_flashArray, m_flashValueStorage);
		
		m_flashValueStorage.SetFlashArray( "playerstats.stats", l_flashArray );
	}
	
	private function updateSentStatValue(statName:name, statValue:string):void
	{
		var sentStat : SentStatsData;
		var i : int;
		
		for (i = 0; i < _sentStats.Size(); i += 1)
		{
			if (_sentStats[i].statName == statName)
			{
				_sentStats[i].statValue = statValue;
				return;
			}
		}
		
		sentStat.statName = statName;
		sentStat.statValue = statValue;
		_sentStats.PushBack(sentStat);
	}
	
	private function getLastSentStatValue(statName:name) : string
	{
		var i : int;
		
		for (i = 0; i < _sentStats.Size(); i += 1)
		{
			if (_sentStats[i].statName == statName)
			{
				return _sentStats[i].statValue;
			}
		}
	
		return "";
	}
	
	event  OnSelectPlayerStat(statId : name)
	{
		ShowStatTooltip(statId);
	}
	
	event  OnStatisticsLostFocus()
	{
		m_flashValueStorage.SetFlashBool("statistic.tooltip.hide", true); 
	}
	
	public function ShowStatTooltip(statName : name)
	{
		var resultData : CScriptedFlashObject;
		var statsList  : CScriptedFlashArray;
		
		resultData = m_flashValueStorage.CreateTempFlashObject();
		statsList = m_flashValueStorage.CreateTempFlashArray();
		switch (statName)
		{
			case 'vitality':
				GetHealthTooltipData(statsList);
				break;
			case 'toxicity':
				GetToxicityTooltipData(statsList);
				break;
			case 'stamina':
				GetStaminaTooltipData(statsList);
				break;
			case 'focus':
				GetAdrenalineTooltipData(statsList);
				break;
			case 'stat_offense':
				GetOffenseTooltipData(statsList);
				break;
			case 'stat_defense':
				GetDefenseTooltipData(statsList);
				break;
			case 'stat_signs':
				GetSignsTooltipData(statsList);
				break;
		}
		resultData.SetMemberFlashString("title", GetLocStringByKeyExt(statName));
		resultData.SetMemberFlashString("description", GetLocStringByKeyExt(statName+"_desc"));
		resultData.SetMemberFlashArray("statsList", statsList);
		m_flashValueStorage.SetFlashObject("statistic.tooltip.data", resultData);
	}
	
	private function GetHealthTooltipData(out GFxData: CScriptedFlashArray):void
	{
		var maxHealth:float;
		var curHealth:float;
		var inCombatRegen:float;
		var outOfCombatRegen:float;
		
		maxHealth = thePlayer.GetStatMax(BCS_Vitality);
		curHealth = thePlayer.GetStatPercents(BCS_Vitality);
		inCombatRegen = CalculateAttributeValue(thePlayer.GetAttributeValue('vitalityCombatRegen'));
		outOfCombatRegen = CalculateAttributeValue(thePlayer.GetAttributeValue('vitalityRegen')); 
		PushStatItem(GFxData, "panel_common_statistics_tooltip_current_health", (string)RoundMath(maxHealth * curHealth));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_maximum_health", (string)RoundMath(maxHealth));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_incombat_regen", (string)NoTrailZeros(RoundTo(inCombatRegen, 1)));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_outofcombat_regen", (string)NoTrailZeros(RoundTo(outOfCombatRegen, 1)));
	}
	
	private function GetToxicityTooltipData(out GFxData: CScriptedFlashArray):void
	{
		var maxToxicity:float;
		var curToxicity:float;
		var lockedToxicity:float;
		var toxicityThreshold:float;
		
		maxToxicity = thePlayer.GetStatMax(BCS_Toxicity);
		curToxicity = thePlayer.GetStat(BCS_Toxicity, true);
		lockedToxicity = thePlayer.GetStat(BCS_Toxicity) - curToxicity;
		toxicityThreshold = GetWitcherPlayer().GetToxicityDamageThreshold();
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_current_toxicity", (string)RoundMath(curToxicity));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_current_maximum", (string)RoundMath(maxToxicity));
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_locked", (string)RoundMath(lockedToxicity));		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_threshold", (string)RoundMath(toxicityThreshold));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_degeneration", (string)RoundMath(0));
	}
	
	private function GetStaminaTooltipData(out GFxData: CScriptedFlashArray):void
	{
		var maxStamina:float;		
		var regenStamia:float;
		var value : SAbilityAttributeValue;
		
		value = thePlayer.GetAttributeValue('staminaRegen');
		regenStamia = value.valueMultiplicative / 0.34;
		maxStamina = thePlayer.GetStatMax(BCS_Stamina);
		PushStatItem(GFxData, "panel_common_statistics_tooltip_maximum_stamina ", (string)RoundMath(maxStamina));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_regeneration_rate", (string)NoTrailZeros( RoundTo(regenStamia, 2) ) );
		
	}
	
	private function GetAdrenalineTooltipData(out GFxData: CScriptedFlashArray):void
	{
		var maxAdrenaline:float;
		var curAdrenaline:float;

		maxAdrenaline = thePlayer.GetStatMax(BCS_Focus);
		curAdrenaline = thePlayer.GetStat(BCS_Focus);
		PushStatItem(GFxData, "panel_common_statistics_tooltip_adrenaline_current", (string)FloorF(curAdrenaline));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_adrenaline_max", (string)RoundMath(maxAdrenaline));
		
	}
	
	private function GetOffenseTooltipData(out GFxData: CScriptedFlashArray):void
	{
		var curStats:SPlayerOffenseStats;
		curStats = GetWitcherPlayer().GetOffenseStatsList();
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_steel_fast_dps", StatToStr(curStats.steelFastDPS));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_steel_fast_crit_chance", StatToStr(curStats.steelFastCritChance) + "%");
		PushStatItem(GFxData, "panel_common_statistics_tooltip_steel_fast_crit_dmg", StatToStr(curStats.steelFastCritDmg) + "%");
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_steel_strong_dps", StatToStr(curStats.steelStrongDPS));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_steel_strong_crit_chance", StatToStr(curStats.steelStrongCritChance) + "%");
		PushStatItem(GFxData, "panel_common_statistics_tooltip_steel_strong_crit_dmg", StatToStr(curStats.steelStrongCritDmg) + "%");
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_silver_fast_dps", StatToStr(curStats.silverFastDPS));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_silver_fast_crit_chance", StatToStr(curStats.silverFastCritChance) + "%");
		PushStatItem(GFxData, "panel_common_statistics_tooltip_silver_fast_crit_dmg", StatToStr(curStats.silverFastCritDmg) + "%");
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_silver_strong_dps", StatToStr(curStats.silverStrongDPS));
		PushStatItem(GFxData, "panel_common_statistics_tooltip_silver_strong_crit_chance", StatToStr(curStats.silverStrongCritChance) + "%");
		PushStatItem(GFxData, "panel_common_statistics_tooltip_silver_strong_crit_dmg", StatToStr(curStats.silverStrongCritDmg) + "%");
		
		PushStatItem(GFxData, "panel_common_statistics_tooltip_crossbow_dps", StatToStr(curStats.crossbowCritChance) + "%");
		PushStatItem(GFxData, "panel_common_statistics_tooltip_crossbow_crit_chance", StatToStr(curStats.crossbowSteelDmg));
	}
	
	private function GetDefenseTooltipData(out GFxData: CScriptedFlashArray):void
	{
		PushStatItem(GFxData, "panel_common_statistics_tooltip_armor", "");
		PushStatItem(GFxData, "slashing_resistance", GetStatValue('slashing_resistance_perc') + "%");
		PushStatItem(GFxData, "piercing_resistance", GetStatValue('piercing_resistance_perc') + "%");
		PushStatItem(GFxData, "bludgeoning_resistance", GetStatValue('bludgeoning_resistance_perc') + "%");
		//PushStatItem(GFxData, "rending_resistance", GetStatValue('rending_resistance_pec') + "%");//W3EE
		PushStatItem(GFxData, "elemental_resistance", GetStatValue('elemental_resistance_perc') + "%");
		PushStatItem(GFxData, "poison_resistance", GetStatValue('poison_resistance_perc') + "%");
		PushStatItem(GFxData, "fire_resistance", GetStatValue('fire_resistance_perc') + "%");
		PushStatItem(GFxData, "bleeding_resistance", GetStatValue('bleeding_resistance_perc') + "%");
		PushStatItem(GFxData, "knockdown_resistance", GetStatValue('knockdown_resistance_perc') + "%");
	}
	
	private function GetSignsTooltipData(out GFxData: CScriptedFlashArray):void
	{
		var sp : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var str : string;
		
		witcher = GetWitcherPlayer();
		
		sp = witcher.GetTotalSignSpellPower(S_Magic_1);
		str = (string)RoundMath(sp.valueMultiplicative*100) + "%";
		PushStatItem(GFxData, 'aard_intensity', str );
		
		sp = witcher.GetTotalSignSpellPower(S_Magic_2);
		str = (string)RoundMath(sp.valueMultiplicative*100) + "%";
		PushStatItem(GFxData, 'igni_intensity', str );
		
		sp = witcher.GetTotalSignSpellPower(S_Magic_3);
		str = (string)RoundMath(sp.valueMultiplicative*100) + "%";
		PushStatItem(GFxData, 'yrden_intensity', str );
		
		sp = witcher.GetTotalSignSpellPower(S_Magic_4);
		str = (string)RoundMath(sp.valueMultiplicative*100) + "%";
		PushStatItem(GFxData, 'quen_intensity', str );
		
		sp = witcher.GetTotalSignSpellPower(S_Magic_5);
		str = (string)RoundMath(sp.valueMultiplicative*100) + "%";
		PushStatItem(GFxData, 'axii_intensity', str );
	}
	
	private function GetSignStat(targetSkill:ESkill):string
	{
		var powerStatValue	: SAbilityAttributeValue;
		var damageTypeName 	: name;
		var points 			: float;
		
		GetWitcherPlayer().GetSignStats(targetSkill, damageTypeName, points, powerStatValue);
		return NoTrailZeros(RoundMath(powerStatValue.valueMultiplicative * 100)) + " %";
	}
	
	private function StatToStr(value:float):string
	{
		return (string)NoTrailZeros(RoundTo(value, 1));
	}
	
	private function PushStatItem(out statsList: CScriptedFlashArray, label:string, value:string):void
	{
		var statItemData : CScriptedFlashObject;
		statItemData = m_flashValueStorage.CreateTempFlashObject();
		statItemData.SetMemberFlashString("name", GetLocStringByKeyExt(label));
		statItemData.SetMemberFlashString("value", value);
		statsList.PushBackFlashObject(statItemData);
	}
	
	event  OnShowFullStats()
	{
		if (_charStatsPopupData)
		{
			delete _charStatsPopupData;
		}
		
		_charStatsPopupData = new CharacterStatsPopupData in this;
		_charStatsPopupData.HideTutorial = true;
		
		RequestSubMenu('PopupMenu', _charStatsPopupData);
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
}
