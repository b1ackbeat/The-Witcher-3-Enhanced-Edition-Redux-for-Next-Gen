class W3BlacksmithContext extends W3UIContext
{
	protected var blacksmithMenuRef : CR4BlacksmithMenu;

	public function SetBlacksmithMenuRef( ref : CR4BlacksmithMenu ) 
	{
		blacksmithMenuRef = ref;
	}
	
	public function UpdateContext()
	{
		updateInputFeedback();
	}
	
	protected function updateInputFeedback()
	{
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		
		AddInputBinding("w3ee_sort_stash", "gamepad_R2", IK_T, true);
		
		m_managerRef.updateInputFeedback();
	}

	public function HandleUserFeedback( keyName : string ) : void 
	{
		if( keyName == "gamepad_R2" )
		{
			blacksmithMenuRef.SwitchShowStashItems();
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
}

class W3CharacterMenuContext extends W3UIContext
{
	protected var characterMenuRef : CR4CharacterMenu;

	public function SetCharacterMenuRef( ref : CR4CharacterMenu ) 
	{
		characterMenuRef = ref;
	}
	
	public function UpdateContext()
	{
		updateInputFeedback();
	}
	
	protected function updateInputFeedback()
	{
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		
		AddInputBinding("w3ee_cycle_skill_down", "gamepad_L2", IK_Comma, true);
		AddInputBinding("w3ee_cycle_skill_up", "gamepad_R2", IK_Period, true);
		
		m_managerRef.updateInputFeedback();
	}

	public function HandleUserFeedback( keyName : string ) : void 
	{
		if( keyName == "gamepad_L2" )
		{
			characterMenuRef.OnDecreaseSkillLVL();
		}
		else
		if( keyName == "gamepad_R2" )
		{
			characterMenuRef.OnIncreaseSkillLVL();
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
}

class W3AlchemyMenuContext extends W3UIContext
{
	protected var alchemyMenuRef : CR4AlchemyMenu;

	public function SetAlchemyMenuRef( ref : CR4AlchemyMenu ) 
	{
		alchemyMenuRef = ref;
	}
	
	public function UpdateContext()
	{
		updateInputFeedback();
	}
	
	protected function updateInputFeedback()
	{
		var language, audioLanguage : string;
		
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		
		theGame.GetGameLanguageName(audioLanguage, language);
		
		AddInputBinding("w3ee_ingrlock_backw", "gamepad_L2", IK_Comma, true);
		AddInputBinding("w3ee_ingrlock_forw", "gamepad_R2", IK_Period, true);
		
		if( alchemyMenuRef.CanCycleCurrentIngredient() )
		{
			if( !theInput.LastUsedGamepad() )
				AddInputBinding("w3ee_cycle_ingredients", "gamepad_R1", IK_MiddleMouse, true);
			
			if( theInput.LastUsedGamepad() || language == "EN" )
			{
				AddInputBinding("w3ee_ingredient_down", "dpad_down", IK_Down, true);
				AddInputBinding("w3ee_ingredient_up", "dpad_up", IK_Up, true);
			}
		}
		
		m_managerRef.updateInputFeedback();
	}

	public function HandleUserFeedback( keyName : string ) : void 
	{
		if( keyName == "gamepad_R2" )
		{
			alchemyMenuRef.OnIngredientLockForward();
		}
		else
		if( keyName == "gamepad_L2" )
		{
			alchemyMenuRef.OnIngredientLockBackward();
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
}

class W3CraftingMenuContext extends W3UIContext
{
	protected var craftingMenuRef : CR4CraftingMenu;

	public function SetCraftingMenuRef( ref : CR4CraftingMenu ) 
	{
		craftingMenuRef = ref;
	}
	
	public function UpdateContext()
	{
		updateInputFeedback();
	}
	
	protected function updateInputFeedback()
	{
		var language, audioLanguage : string;
		
		m_inputBindings.Clear();
		m_contextBindings.Clear();
		
		theGame.GetGameLanguageName(audioLanguage, language);
		
		if( craftingMenuRef.IsDynamicItemSelected() )
		{
			AddInputBinding("w3ee_abilityarr_backw", "gamepad_L2", IK_Comma, true);
			AddInputBinding("w3ee_abilityarr_forw", "gamepad_R2", IK_Period, true);
		}
		
		if( craftingMenuRef.CanCycleCurrentIngredient() )
		{
			if( !theInput.LastUsedGamepad() )
				AddInputBinding("w3ee_cycle_ingredients", "gamepad_R1", IK_MiddleMouse, true);
			
			if( theInput.LastUsedGamepad() || language == "EN" )
			{
				AddInputBinding("w3ee_ingredient_down", "dpad_down", IK_Down, true);
				AddInputBinding("w3ee_ingredient_up", "dpad_up", IK_Up, true);
			}
		}
		
		if( !craftingMenuRef.GetIsModuleSelected() && craftingMenuRef.IsCompareItem() )
			AddInputBinding("w3ee_toggle_comp", "dpad_down", IK_V, true);
		
		m_managerRef.updateInputFeedback();
	}

	public function HandleUserFeedback( keyName : string ) : void 
	{
		if( keyName == "gamepad_R2" )
		{
			craftingMenuRef.OnAbilityForward();
		}
		else
		if( keyName == "gamepad_L2" )
		{
			craftingMenuRef.OnAbilityBackward();
		}
		else
		if( keyName == "dpad_down" && !craftingMenuRef.GetIsModuleSelected() )
		{
			craftingMenuRef.OnToggleItemComparison();
		}
		else
		{
			super.HandleUserFeedback(keyName);
		}
	}
}