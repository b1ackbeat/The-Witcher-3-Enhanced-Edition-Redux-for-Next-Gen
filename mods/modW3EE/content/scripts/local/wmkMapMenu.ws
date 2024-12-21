class WmkMapMenu
{
	// ================================ CONFIGURATION ================================

	// The icon used for a quest pin depends on player's level and quest's recommended level. The rules
	// used to decide the difficulty of a quest are the same ones used by the game for displaying the suggested
	// level in Quests menu.
	//
	// The STANDARD and FULL versions include two sets with custom icons, so it will be easy to know which
	// pins are added by this mod and which pins are added by the game. See map-icons.html for all valid
	// options (the file is included in mod's archive).

	// The icon used for the quests with a recommended level much lower than player's level.
	private const var QUEST_PIN_TYPE_LOW : name; default QUEST_PIN_TYPE_LOW = 'WmkQuestIconGreen';
	// The icon used for the quests with a recommended level close to player's level.
	private const var QUEST_PIN_TYPE : name; default QUEST_PIN_TYPE = 'WmkQuestIconGreen';
	// The icon used for the quests with a recommended level much higher than player's level.
	private const var QUEST_PIN_TYPE_HIGH : name; default QUEST_PIN_TYPE_HIGH = 'WmkQuestIconGreen';
	// The icon used for impossible quests (15+ levels).
	private const var QUEST_PIN_TYPE_DEADLY : name; default QUEST_PIN_TYPE_DEADLY = 'WmkQuestIconGreen';

	// Quest icon rotation (degrees). For example you can set this to 180 for an upside down exclamation
	// mark icon. Or set it to -5 or 5 to slightly rotate the icon to left or right. Useful to make a difference
	// between the pins added by game and the pins added by this mod if you use a standard quest icon.
	private const var QUEST_PIN_ROTATION : int; default QUEST_PIN_ROTATION = 0;

	// Only for STANDARD & FULL versions: the label to be used in the filtering list.
	private const var FILTER_LABEL : string; default FILTER_LABEL = "W3EE_MapFilterLabel";

	// Enabling this may improve the performance on slow computers because quest pin coordinates won't be retrieved
	// everytime the map is opened (except for currently tracked quest). Leave it disabled, unless you notice
	// that the map loads slower. If caching is enabled sometimes you may see "ghost" icons if a quest that is not
	// tracked is updated. Nothing serious and a reload fixes these problems.
	private const var CACHE_QUEST_PIN_POSITIONS : bool; default CACHE_QUEST_PIN_POSITIONS = false;

	// True to enable logging, false otherwise. Leave it disabled, unless you know what you're doing.
	protected const var LOG_ENABLED : bool; default LOG_ENABLED = false;

	// ============================== END CONFIGURATION ==============================

	// Globals.

	public var m_thePlayer : CPlayer;

	protected var m_commonMapManager : CCommonMapManager;
	private var m_journalManager : CWitcherJournalManager;

	private var m_isNewGamePlus : bool;
	private var m_cachedQuestMapPins : array<WmkQuestMapPin>;
	private var m_quickUpdateEntityPins : bool; default m_quickUpdateEntityPins = false;

	// These should be locals.

	protected var m_mapMenu : CR4MapMenu;
	protected var m_shownArea : EAreaName;
	private var m_questMapPinInstances : array<SCommonMapPinInstance>;
	private var m_questMapPins : array<WmkQuestMapPin>;

	private var m_currentTrackedQuest : CJournalQuest;
	private var m_currentHighlightedObjective : CJournalQuestObjective;

	// Initialization. Called only once, when the user loads the map for the first time after loading or starting a new game.
	public function Initialize()
	{
		Log("WmkMapMenu initialized...");

		this.m_thePlayer = thePlayer;

		this.m_commonMapManager = theGame.GetCommonMapManager();
		this.m_journalManager = theGame.GetJournalManager();

		m_isNewGamePlus = FactsQuerySum("NewGamePlus") > 0;
	}

	// This one must be called from CR4MapMenu::UpdateEntityPins, after map pin instances are processed (mapMenu.ws file).
	public function UpdateEntityPins(mapMenu : CR4MapMenu, shownArea : EAreaName, mapPinInstances : array<SCommonMapPinInstance>, out flashArray : CScriptedFlashArray)
	{
		var initialLength : int;

		// This should cause a compilation error if the mapMenu.ws file does not contain the required changes.
		mapMenu.ALL_QUEST_OBJECTIVES_ON_MAP___ANOTHER_MOD_CHANGES_MAPMENU_WS_FILE___USE_SCRIPT_MERGER_TO_DETECT_AND_FIX_THE_CONFLICT = 1;

		m_currentTrackedQuest = m_journalManager.GetTrackedQuest();
		m_currentHighlightedObjective = m_journalManager.GetHighlightedObjective();

		m_mapMenu = mapMenu;
		m_shownArea = shownArea;

		if (LOG_ENABLED) {
			initialLength = flashArray.GetLength();
			Log("UpdateEntityPins START: updating map pins for " + shownArea + " area. Quick = " + m_quickUpdateEntityPins + ". There were "
					+ "already processed " + mapPinInstances.Size() + " pin(s) (only " + initialLength + " being valid)");
		}

		PopulateQuestMapPinInstances(mapPinInstances);

		if (!m_quickUpdateEntityPins) {
			ProcessAllQuests();
		}

		if (m_currentTrackedQuest.guid != m_journalManager.GetTrackedQuest().guid) {
			m_journalManager.SetTrackedQuest(m_currentTrackedQuest);
		}
		if (m_currentHighlightedObjective.guid != m_journalManager.GetHighlightedObjective().guid) {
			m_journalManager.SetHighlightedObjective(m_currentHighlightedObjective);
		}

		UpdateFlashData(flashArray);

		if (!m_quickUpdateEntityPins && CACHE_QUEST_PIN_POSITIONS) {
			m_cachedQuestMapPins = m_questMapPins;
		}

		if (LOG_ENABLED) {
			Log("UpdateEntityPins END: done, added " + (flashArray.GetLength() - initialLength) + " new quest map pin(s)");
		}
	}

	// Called when the user double clicks on a pin.
	public function OnMapPinUsed(mapMenu : CR4MapMenu, id: name, wmkTag : name, wmkData : int, areaId : int) : bool
	{
		var idx : int;
		var questObjective : CJournalQuestObjective;

		if (LOG_ENABLED) {
			Log("OnMapPinUsed: id = " + id + " wmkTag = " + wmkTag + " wmkData = " + wmkData + " areaId = " + areaId);
		}

		if (wmkTag == 'wmk_quest') {
			idx = wmkData;

			if ((idx >= 0) && (idx < m_questMapPins.Size())) {
				questObjective = m_questMapPins[idx].questObjective;
			}
		} else {
			for (idx = 0; idx < m_questMapPinInstances.Size(); idx += 1) {
				if (m_questMapPinInstances[idx].tag == id) {
					questObjective = (CJournalQuestObjective)m_journalManager.GetEntryByGuid(m_questMapPinInstances[idx].guid);
					break;
				}
			}
		}

		if (questObjective) {
			m_journalManager.SetTrackedQuest(questObjective.GetParentQuest());
			m_journalManager.SetHighlightedObjective(questObjective);
			m_mapMenu.UpdateCurrentQuestData(false);

			QuickUpdateMapData();
		}

		return false;
	}

	// Updates the map (entity pins, player pin, custom pin and filter data) using existing quest data.
	protected function QuickUpdateMapData()
	{
		var mcHubMapPinPanel : CScriptedFlashObject;
		var fxSaveCurrentCategoryIndex : CScriptedFlashFunction;

		mcHubMapPinPanel = m_mapMenu.GetMenuFlash().GetMemberFlashObject("mcHubMapPinPanel");
		if (mcHubMapPinPanel) {
			fxSaveCurrentCategoryIndex = mcHubMapPinPanel.GetMemberFlashFunction("WmkSaveCurrentCategoryIndex");
			if (fxSaveCurrentCategoryIndex) {
				fxSaveCurrentCategoryIndex.InvokeSelf();
			}
		}

		m_quickUpdateEntityPins = true;
		m_mapMenu.UpdateData(true);
		m_quickUpdateEntityPins = false;
	}

	// Retrieves the quest map pins from the pins already processed by CR4MapMenu class. These should be the ones for currently tracked quest.
	private function PopulateQuestMapPinInstances(mapPinInstances : array<SCommonMapPinInstance>)
	{
		var i : int;
		var pin : SCommonMapPinInstance;
		var questObjective : CJournalQuestObjective;

		if (LOG_ENABLED) {
			Log("Retrieving the quest map pins from already processed pins...");
		}

		m_questMapPinInstances.Clear();

		for (i = 0; i < mapPinInstances.Size(); i += 1) {
			pin = mapPinInstances[i];
			if ((pin.isDiscovered || pin.isKnown) && m_commonMapManager.IsQuestPinType(pin.type)) {
				m_questMapPinInstances.PushBack(pin);

				if (LOG_ENABLED) {
					questObjective = (CJournalQuestObjective) m_journalManager.GetEntryByGuid(pin.guid);
					if (questObjective) {
						Log("Found quest map pin instance: tag = " + pin.tag + " objective title = " + GetLocStringById(questObjective.GetTitleStringId()));
					} else {
						Log("WARNING, found quest map pin instance without a quest objective: tag = " + pin.tag);
					}
				}
			}
		}

		if (LOG_ENABLED) {
			Log("Found " + m_questMapPinInstances.Size() + " quest map pin(s)");
		}
	}

	// Iterates all active quests / phases. When returns the m_mapPins contains the data for all the map pins related to all active quests.
	private function ProcessAllQuests()
	{
		var i, j, k : int;
		var questsList : array<CJournalBase>;
		var questItem : CJournalQuest;
		var questPhase : CJournalQuestPhase;
		var questObjective : CJournalQuestObjective;

		if (LOG_ENABLED) {
			Log("Processing all player's active quests and their active objectives...");
		}

		m_questMapPins.Clear();

		m_journalManager.GetActivatedOfType('CJournalQuest', questsList);

		for (i = 0; i < questsList.Size(); i += 1) {
			questItem = (CJournalQuest) questsList[i];
			if (questItem) {
				if (m_journalManager.GetEntryStatus(questItem) == JS_Active) { // only active quests
					for (j = 0; j < questItem.GetNumChildren(); j += 1) {
						questPhase = (CJournalQuestPhase) questItem.GetChild(j);
						if (questPhase) {
							if (m_journalManager.GetEntryStatus(questPhase) == JS_Active) { // only active quest phases
								for (k = 0; k < questPhase.GetNumChildren(); k += 1) {
									questObjective = (CJournalQuestObjective) questPhase.GetChild(k);
									if (questObjective) {
										if (m_journalManager.GetEntryStatus(questObjective) == JS_Active) { // only active quest objectives
											ProcessQuestObjective(questObjective);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	// Called for each active objective.
	private function ProcessQuestObjective(questObjective : CJournalQuestObjective)
	{
		var i : int;
		var questMapPin : CJournalQuestMapPin;

		for (i = 0; i < questObjective.GetNumChildren(); i += 1) {
			questMapPin = (CJournalQuestMapPin) questObjective.GetChild(i);
			if (questMapPin) {
				ProcessQuestMapPin(questObjective, questMapPin);
			}
		}
	}

	// Called for each map pin that belongs to an active quest objective.
	private function ProcessQuestMapPin(questObjective : CJournalQuestObjective, questMapPin : CJournalQuestMapPin)
	{
		var qpin : WmkQuestMapPin;

		if (LOG_ENABLED) {
			Log("Processing quest map pin: id = " + questMapPin.GetMapPinID() + " radius = " + questMapPin.GetRadius() + " area = " + (EAreaName)questObjective.GetWorld()
				+ " objective title = " + GetLocStringById(questObjective.GetTitleStringId()));
		}

		qpin.tag = questMapPin.GetMapPinID();
		qpin.questArea = questObjective.GetWorld(); // this may be AN_Undefined (world = 0)
		qpin.questObjective = questObjective;
		qpin.titleStringId = questObjective.GetParentQuest().GetTitleStringId();
		qpin.descriptionStringId = questObjective.GetTitleStringId();
		qpin.questLevel = 0; //GetQuestLevel(questObjective.GetParentQuest());

		SetAreaAndPositionForQuestMapPin(qpin);

		m_questMapPins.PushBack(qpin);
	}

	// Returns the level for a quest. This is copy & paste from CR4JournalQuestMenu class (with few changes).
	// This is stupid: for each pin (maybe up to 50, depends on how many active quests the player has) we iterate an
	// array with probably few hundred items (or how many quests the game has).
	private function GetQuestLevel(questItem : CJournalQuest) : int
	{
		var i, j : int;
		var questLevels : C2dArray;
		var questName : string;
		var questLevel : int;

		for (i = 0; i < theGame.questLevelsContainer.Size(); i += 1) {
			questLevels = theGame.questLevelsContainer[i];
			for (j = 0; j < questLevels.GetNumRows(); j += 1) {
				questName = questLevels.GetValueAtAsName(0, j);
				if (questName == questItem.baseName) {
					questLevel = NameToInt(questLevels.GetValueAtAsName(1, j));
					if (m_isNewGamePlus && (questLevel > 1)) {
						questLevel += theGame.params.GetNewGamePlusLevel();
					}
					break; // this is missing from source
				}
			}
		}

		return questLevel;
	}

	// Sets the coordinates for a map pin. Optionally sets the area too.
	//
	// Note that very few quest objectives do not have an area assigned. Somehow the game still shows a pin for them
	// when tracked, but I think this happens only if the player is in quest's area (not enough examples to be 100% sure). For
	// example for the quest "Gwent: Old Pals", objective "Win a unique card from Vernon Roche", the pin appears only if
	// the player is in Novigrad or Valen. It doesn't appear if the player is in White Orchard. For the tracked quests that
	// have an area asigned the game shows a pin to closest fast travel sign if the player is in different area and can
	// travel to quest's area (for example if Skellige was unlocked).
	private function SetAreaAndPositionForQuestMapPin(out qpin : WmkQuestMapPin)
	{
		var i : int;
		var unknownArea : bool = (qpin.questArea == AN_Undefined);
		var pinForShownArea : bool = !unknownArea && AreaEquals(qpin.questArea, m_shownArea);
		var pinInstances : array<SCommonMapPinInstance>;
		var pos : Vector;
		var logPrefix : string;

		if (LOG_ENABLED) {
			if (unknownArea) {
				logPrefix = "the area and position ";
			} else {
				logPrefix = "the position ";
			}
		}

		// Tracked quest map pins.
		// If the quest is for a different known area then pin's position is the closest sign post, so is useless.

		if (pinForShownArea || unknownArea) {
			for (i = 0; i < m_questMapPinInstances.Size(); i += 1) {
				if (m_questMapPinInstances[i].tag == qpin.tag) {
					pos = m_questMapPinInstances[i].position;

					if (LOG_ENABLED) {
						Log("FOUND: " + logPrefix + "for quest map pin " + qpin.tag + " in the array with quest map pin instances: x = "
								+ pos.X + " y = " + pos.Y + " z = " + pos.Z);
					}

					qpin.position = pos;
					qpin.areaPosType = WmkAreaPos_Valid;

					if (unknownArea) {
						qpin.questArea = m_shownArea;
					}

					return; // hurrah
				}
			}
		}

		// Nothing to do if the pin is for currently tracked quest. This means that is for a different known area
		// or is not in m_questMapPinInstances.

		if (qpin.questObjective.GetParentQuest().guid == m_currentTrackedQuest.guid) {
			qpin.areaPosType = WmkAreaPos_Unknown;
			if (LOG_ENABLED) {
				Log("SKIPPING: pin " + qpin.tag + " for tracked quest");
			}
			return;
		}

		// Previous data, if caching is enabled.
		//
		// Bad example: a quest objective have 2 pins, A and B. Initially the game displays only the A
		// pin. The player opens the map and the area and position for both pins are cached (A as being valid, B as
		// being invalid). The player advances on the quest, A becomes invalid and B becomes valid. The B pin is
		// updated because is found in m_questMapPinInstances array, but if caching is used the A will still be
		// added on map. This is not an issue for the tracked quest because caching is not used, but
		// still it may happen.

		if (CACHE_QUEST_PIN_POSITIONS) {
			for (i = 0; i < m_cachedQuestMapPins.Size(); i += 1) {
				if (m_cachedQuestMapPins[i].tag == qpin.tag) {
					if (m_cachedQuestMapPins[i].areaPosType != WmkAreaPos_Unknown) {
						pos = m_cachedQuestMapPins[i].position;

						if (LOG_ENABLED) {
							Log("CACHE: " + logPrefix + "for quest map pin " + qpin.tag + ": area = " + m_cachedQuestMapPins[i].questArea
									+ " areaPosType = " + m_cachedQuestMapPins[i].areaPosType + " x = " + pos.X
									+ " y = " + pos.Y + " z = " + pos.Z);
						}

						qpin.position = pos;
						qpin.areaPosType = m_cachedQuestMapPins[i].areaPosType;

						if (unknownArea) {
							qpin.questArea = m_cachedQuestMapPins[i].questArea;
						}

						return;
					}

					break;
				}
			}
		}

		// The dirty trick. Not used for the pins that are from a different known area. This is ugly, but is the
		// only solution I've found to get the coordinates for a pin.

		if (pinForShownArea || unknownArea) {
			m_journalManager.SetTrackedQuest(qpin.questObjective.GetParentQuest());
			m_journalManager.SetHighlightedObjective(qpin.questObjective);

			pinInstances = m_commonMapManager.GetMapPinInstances(m_commonMapManager.GetWorldPathFromAreaType(m_shownArea));

			for (i = 0; i < pinInstances.Size(); i += 1) {
				if (pinInstances[i].isDiscovered || pinInstances[i].isKnown) {
					if ((pinInstances[i].tag == qpin.tag) && m_commonMapManager.IsQuestPinType(pinInstances[i].type)
							&& (pinInstances[i].guid == qpin.questObjective.guid)) {
						pos = pinInstances[i].position;

						if (LOG_ENABLED) {
							Log("DIRTY: " + logPrefix + "for quest map pin " + qpin.tag + " using the dirty trick: x = " + pos.X + " y = " + pos.Y + " z = " + pos.Z);
						}

						qpin.position = pos;
						qpin.areaPosType = WmkAreaPos_Valid;

						if (unknownArea) {
							qpin.questArea = m_shownArea;
						}

						return;
					}
				}
			}
		}

		// Failed, but this is not necessarily an error. If we get here probably the pin must not be added to the map.

		if (pinForShownArea || unknownArea) {
			qpin.areaPosType = WmkAreaPos_Invalid;

			if (LOG_ENABLED) {
				Log("FAILED: to obtain " + logPrefix + "for map pin " + qpin.tag);
			}
		} else {
			qpin.areaPosType = WmkAreaPos_Unknown; // pin for other area not found in cache

			if (LOG_ENABLED) {
				Log("SKIPPED: pin " + qpin.tag + " is from a different area and is not cached");
			}
		}
	}

	// Adds the data for new map pins to the flash array.
	private function UpdateFlashData(out flashArray : CScriptedFlashArray)
	{
		var i, j : int;
		var flashObject : CScriptedFlashObject;
		var qpin : WmkQuestMapPin;
		var questDifficulty : WmkQuestDifficulty;
		var questPinType : name;
		var skip : bool;

		if (LOG_ENABLED) {
			Log("Adding data to flash array...");
		}

		for (i = 0; i < m_questMapPins.Size(); i += 1) {
			qpin = m_questMapPins[i];
			if ((qpin.areaPosType == WmkAreaPos_Valid)
					&& (qpin.questObjective.GetParentQuest().guid != m_currentTrackedQuest.guid)
					&& AreaEquals(qpin.questArea, m_shownArea)) {

				skip = false;
				for (j = 0; !skip && (j < m_questMapPinInstances.Size()); j += 1) {
					if (m_questMapPinInstances[j].tag == qpin.tag) {
						skip = true;
					}
				}

				if (skip) {
					if (LOG_ENABLED) {
						Log("Skipping the pin " + qpin.tag + "...");
					}
					continue;
				}

				questDifficulty = GetQuestDifficulty(qpin.questLevel);

				switch (questDifficulty) {
					case WmkQD_Low: questPinType = QUEST_PIN_TYPE_LOW; break;
					case WmkQD_High: questPinType = QUEST_PIN_TYPE_HIGH; break;
					case WmkQD_Deadly: questPinType = QUEST_PIN_TYPE_DEADLY; break;
					default:
						questPinType = QUEST_PIN_TYPE;
				}

				// In the same order as they are declared in StaticMapPinData class (from panel_worldmap.redswf).
				flashObject = m_mapMenu.GetMenuFlashValueStorage().CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");
				flashObject.SetMemberFlashUInt("id", NameToFlashUInt(qpin.tag));
				flashObject.SetMemberFlashString("type", questPinType);
				flashObject.SetMemberFlashString("filteredType", 'ChapterQuest');
				flashObject.SetMemberFlashString("label", GetLocStringById(qpin.titleStringId));
				flashObject.SetMemberFlashString("description", GetMapPinDescription(qpin.questLevel, questDifficulty, qpin.descriptionStringId));
				flashObject.SetMemberFlashNumber("posX", qpin.position.X);
				flashObject.SetMemberFlashNumber("posY", qpin.position.Y);
				flashObject.SetMemberFlashNumber("radius", 0);
				flashObject.SetMemberFlashBool("tracked", false);
				flashObject.SetMemberFlashBool("highlighted", false);
				flashObject.SetMemberFlashUInt("areaId", m_shownArea);
				flashObject.SetMemberFlashInt("journalAreaId", m_commonMapManager.GetJournalAreaByPosition(m_shownArea, qpin.position));
				flashObject.SetMemberFlashNumber("rotation", QUEST_PIN_ROTATION);
				flashObject.SetMemberFlashBool("isFastTravel", false);
				flashObject.SetMemberFlashBool("isQuest", false);
				flashObject.SetMemberFlashBool("isPlayer", false);
				flashObject.SetMemberFlashBool("isUserPin", false);
				flashObject.SetMemberFlashNumber("distance", 0);
				flashObject.SetMemberFlashBool("hidden", false);

				// Custom data.
				flashObject.SetMemberFlashUInt("wmkTag", NameToFlashUInt('wmk_quest'));
				flashObject.SetMemberFlashUInt("wmkData", i);
				flashObject.SetMemberFlashString("wmkFilteredLabel", GetLocStringByKeyExt(FILTER_LABEL));

				flashArray.PushBackFlashObject(flashObject);
			}
		}
	}

	// Returns the difficulty of a quest.
	private function GetQuestDifficulty(questLevel : int) : WmkQuestDifficulty
	{
		return WmkQD_Normal;
	}

	// Returns the description for a quest map pin.
	private function GetMapPinDescription(questLevel : int, questDifficulty : WmkQuestDifficulty, stringId : int) : string
	{
		return GetLocStringById(stringId);
	}

	// Novigrad and Valen are different areas, but same map.
	private function AreaEquals(first : EAreaName, second : EAreaName) : bool
	{
		if (first == second) {
			return true;
		}

		if ((first == AN_NMLandNovigrad) && (second == AN_Velen)) {
			return true;
		}

		if ((first == AN_Velen) && (second == AN_NMLandNovigrad)) {
			return true;
		}

		return false;
	}

	// Logging...
	protected function Log(message : string)
	{
		if (LOG_ENABLED) {
			LogChannel('WMKMAP', message);
		}
	}
}
