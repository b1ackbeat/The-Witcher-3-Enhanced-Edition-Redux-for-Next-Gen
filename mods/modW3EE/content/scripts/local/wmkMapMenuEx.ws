class WmkMapMenuEx extends WmkMapMenu
{
	// ================================ CONFIGURATION ================================

	// The prefix to be used for merchant pin titles.
	private const var CACHED_MERCHANT_PIN_LABEL_PREFIX : string;
	default CACHED_MERCHANT_PIN_LABEL_PREFIX = "W3EE_Cached";

	// The suffix to be used for merchant pin descriptions.
	private const var CACHED_MERCHANT_PIN_DESCR_SUFFIX : string;
	default CACHED_MERCHANT_PIN_DESCR_SUFFIX = "W3EE_ClickToRemove";

	// The message displayed when a merchant pin is manually deleted (the user double clicks on its pin).
	private const var MSG_CACHED_PIN_DELETED : string;
	default MSG_CACHED_PIN_DELETED = "W3EE_PinRemoved";

	// The inteval in seconds used for updating the list with known merchant pins.
	private const var CACHE_MERCHANT_PINS_TICK_INTERVAL : float; default CACHE_MERCHANT_PINS_TICK_INTERVAL = 2.0;

	// Merchant icon rotation (degrees).
	private const var MERCHANT_PIN_ROTATION : int; default MERCHANT_PIN_ROTATION = 0;

	// Specifies if the mod should cache the pins for wandering merchants.
	private const var CACHE_WANDERING_MERCHANT_PINS : bool; default CACHE_WANDERING_MERCHANT_PINS = false;

	// The maximum number of merchant pins to cache. I assume the game has way less merchants, but is better to have a maximum limit.
	private const var MAX_CACHED_PINS : int; default MAX_CACHED_PINS = 300;

	// Used to avoid caching similar pins for same location. Also to avoid adding a pin if there's already one in that location.
	private const var TOO_CLOSE_DISTANCE : float; default TOO_CLOSE_DISTANCE = 5.0;

	// ================================ CONFIGURATION ================================

	// Globals

	private var m_data : WmkMapMenuData;
	private var m_tickCounter : float; default m_tickCounter = 0;

	private var m_idTagsList : array<IdTag>;
	private var m_uniqueTagsList : array<name>;

	// Initialization. Called only once, when the Witcher player is spawned.
	public /* override */ function Initialize()
	{
		var i, j : int;
		var playerWitcher : W3PlayerWitcher = GetWitcherPlayer();
		var distance : float;
		var tmpTagsList : array<name>;
		var uniqueTag : name;

		super.Initialize();

		if (!playerWitcher.wmkMapMenuData) {
			playerWitcher.wmkMapMenuData = new WmkMapMenuData in playerWitcher;
		}

		m_data = playerWitcher.wmkMapMenuData;
		Log("WmkMapMenuEx::Initialize: " + m_data.merchantPins.Size() + " saved merchant pins");

		if (LOG_ENABLED) {
			for (i = 0; i < m_data.merchantPins.Size(); i += 1) {
				Log("MP[" + i + "]: " + PinToString(m_data.merchantPins[i]));
			}
			for (i = 0; i < m_data.deletedMerchantPins.Size(); i += 1) {
				Log("DEL MP[" + i + "]: " + PinToString(m_data.deletedMerchantPins[i]));
			}
			for (i = 0; i < m_data.removedSameUniqueTagMerchantPins.Size(); i += 1) {
				Log("REM MP[" + i + "]: " + PinToString(m_data.removedSameUniqueTagMerchantPins[i]));
			}
			for (i = 0; i < m_data.replacedSameTypePosMerchantPins.Size(); i += 1) {
				Log("RPL MP[" + i + "]: " + PinToString(m_data.replacedSameTypePosMerchantPins[i]));
			}
		}

		// I don't know why but sometime the saved entities get corrupted, entityIdTag member being null. I think
		// this only happens when reloading the scripts using Script Studio...
		for (i = m_data.merchantPins.Size() - 1; i >= 0; i -= 1) {
			if (!IsIdTagValid(m_data.merchantPins[i].entityIdTag)) {
				m_data.merchantPins.Erase(i);
			}
		}

		// Up to 1.11.3 the mod could cache multiple similar pins in same location. This removes the
		// duplicates from saved data.
		if (FactsQuerySum("WmkRemovedDuplicatedMerchantPins") < 1) {
			for (i = m_data.merchantPins.Size() - 1; i > 0; i -= 1) {
				for (j = i - 1; j >= 0; j -= 1) {
					if (m_data.merchantPins[i].pin.type == m_data.merchantPins[j].pin.type) {
						distance = VecDistance(m_data.merchantPins[i].pin.position, m_data.merchantPins[j].pin.position);
						if (distance <= TOO_CLOSE_DISTANCE) {
							m_data.merchantPins.Erase(i); // same pin type, same location
							break;
						}
					}
				}
			}
			FactsAdd("WmkRemovedDuplicatedMerchantPins");
		}

		// The unique tags were added after version 1.11.5. This sets the uniqueTag property, but also
		// removes any duplicates.
		if (FactsQuerySum("WmkUpdatedMerchantUniqueTags") < 1) {
			for (i = m_data.merchantPins.Size() - 1; i >= 0; i -= 1) {
				uniqueTag = GetMerchantUniqueTag(m_data.merchantPins[i].entityTags);
				if (uniqueTag != 'WmkNone') {
					if (tmpTagsList.Contains(uniqueTag)) {
						m_data.merchantPins.Erase(i); // duplicate
						continue;
					}
					tmpTagsList.PushBack(uniqueTag);
				}
				m_data.merchantPins[i].uniqueTag = uniqueTag;
			}
			FactsAdd("WmkUpdatedMerchantUniqueTags");
		}

		// Used for fast searching.
		for (i = 0; i < m_data.merchantPins.Size(); i += 1) {
			m_idTagsList.PushBack(m_data.merchantPins[i].entityIdTag);
			m_uniqueTagsList.PushBack(m_data.merchantPins[i].uniqueTag);
		}
	}

	// This one must be called from CR4MapMenu::UpdateEntityPins, after map pin instances are processed (mapMenu.ws file).
	public /* override */ function UpdateEntityPins(mapMenu : CR4MapMenu, shownArea : EAreaName, mapPinInstances : array<SCommonMapPinInstance>, out flashArray : CScriptedFlashArray)
	{
		var i, j : int;
		var size : int = mapPinInstances.Size();
		var mpin : WmkMerchantMapPin;
		var pin : SCommonMapPinInstance;
		var npcEntity : CNewNPC;
		var found : bool;
		var distance : float;

		super.UpdateEntityPins(mapMenu, shownArea, mapPinInstances, flashArray);

		if (shownArea == AN_Velen) {
			shownArea = AN_NMLandNovigrad;
		}

		// Is not easy to know if a pin for a saved/cached merchant already exists in the instances array
		// because only the the ones that are close to the player have an entity. Comparing only the IdTags results
		// in adding cached pins for merchants that always have a pin on map but are not spawned. To avoid this
		// problem the code doesn't add a pin if a similar one already exists in the same location.
		//
		// Bad example: the mod caches the pin for a merchant that always has a pin on map. The merchant (let's say Keira)
		// is then teleported far away and despawned. The game will add the pin for the new location, but the pin
		// won't contain any useful information that can be used to identify the merchant. Has no tag, no extraTag,
		// no entity etc... Because of this, the mod doesn't know that the merchant already has a pin on map
		// and will add the one for latest saved location. This sucks, but cannot be fixed.

		for (i = 0; i < m_data.merchantPins.Size(); i += 1) {
			mpin = m_data.merchantPins[i];
			if (mpin.area == shownArea) { // add only the cached merchant pins for shown area
				found = false;

				for (j = 0; (j < size) && !found; j += 1) {
					pin = mapPinInstances[j];
					if ((pin.isKnown || pin.isDiscovered) && (pin.type == mpin.pin.type)) {
						// the entity may be NULL (it happens sometimes!) or may not be a CNewNPC object
						if (pin.entities.Size() == 1) {
							npcEntity = (CNewNPC) pin.entities[0];

							if (npcEntity) {
								if (mpin.entityIdTag == npcEntity.idTag) {
									found = true;
								}
							}
						}

						if (!found) {
							distance = VecDistance(mpin.pin.position, pin.position);
							if (distance <= TOO_CLOSE_DISTANCE) {
								found = true;
							}
						}
					}
				}

				if (!found) {
					flashArray.PushBackFlashObject(CreateMerchantPinFlashObject(mpin, i));
				}
			}
		}
	}

	// Called when the user double clicks on a pin.
	public /* override */ function OnMapPinUsed(mapMenu : CR4MapMenu, id: name, wmkTag : name, wmkData : int, areaId : int) : bool
	{
		var result : bool = super.OnMapPinUsed(mapMenu, id, wmkTag, wmkData, areaId);
		var idx : int;

		if (wmkTag == 'wmk_merchant') {
			idx = wmkData;
			if ((idx >= 0) && (idx < m_data.merchantPins.Size())) {
				if (LOG_ENABLED) {
					Log("DELETED MERCHANT PIN[" + idx + "]: " + PinToString(m_data.merchantPins[idx]));
					m_data.deletedMerchantPins.PushBack(m_data.merchantPins[idx]);
				}

				EraseMerchantPin(idx);

				mapMenu.showNotification(GetLocStringByKeyExt(MSG_CACHED_PIN_DELETED));
				QuickUpdateMapData();
			}
		}

		return result;
	}

	// Called from W3PlayerWitcher::OnPlayerTickTimer (playerWitcher.ws).
	public function OnTick(deltaTime : float)
	{
		m_tickCounter -= deltaTime;

		if (m_tickCounter < 0) {
			m_tickCounter += CACHE_MERCHANT_PINS_TICK_INTERVAL;
			UpdateMerchantPins();
		}
	}

	// Called once every few seconds. Updates the list with saved / cached merchant pins.
	//
	// Initially the merchants were unique identified by entity's idTag. I assumed that it is unique during a playthrough,
	// but later I've found out that many merchants are respawned with different idTags during or after some quests. Or some have
	// different idTags depending on their location or current game time. For example the armorer from White Orchard has an idTag right
	// after Twisted Firestarter quest is finished, but when the player moves away is immediately despawned and respawned with a different
	// idTag. The blacksmith from White Orchard also changes the idTag 4 times until the player goes to Vizima. Another example is Keira,
	// which has one idTag when the player meets her for the first time, a different one when the Wandering in the Dark quest is started,
	// a different one when is separated from Geralt etc... Another example is the trader from Crow's Perch (the one from village) that
	// is spawned with an idTag when is outside and with a different idTag during the night, when is inside his house.
	//
	// Then added some additional code to prevent caching multiple pins for a merchant that is respawned with different idTags, but in
	// the same location. This didn't work too well.
	//
	// Then I've observed that for most merchants the first tag seems to be unique, like prologue_smith, Elza, nml_crossroads_barkeep,
	// fergus_graem, keira_metz, baron_keep_village_trader_01 etc... The exception are the generic merchants, for which the first
	// tag is generic_merchant_nomansland_merchant, generic_merchant_nomansland_herbalist etc...
	//
	// This is why now there are 3 methods to find if the pin for a merchant is new or is already cached.
	//
	// Note that pin IDs or NPC GUIDs are not a solution. They change when a game is loaded, when the game is restarted etc...
	private function UpdateMerchantPins()
	{
		var currentArea : EAreaName = m_commonMapManager.GetCurrentArea();
		var worldPath : string = m_commonMapManager.GetWorldPathFromAreaType(currentArea);
		var mapPinInstances : array<SCommonMapPinInstance> = m_commonMapManager.GetMapPinInstances(worldPath);

		var i, foundType, idx, pos : int;
		var pin : SCommonMapPinInstance;
		var size : int = m_data.merchantPins.Size();
		var hasValidIdTag : bool;
		var npcEntity : CNewNPC;
		var mpin : WmkMerchantMapPin;

		if (currentArea == AN_Velen) {
			currentArea = AN_NMLandNovigrad;
		}

		for (i = 0; i < mapPinInstances.Size(); i += 1) {
			pin = mapPinInstances[i];
			// Warning: sometimes the entities array has one NULL element!
			if ((pin.isKnown || pin.isDiscovered) && (pin.entities.Size() == 1) && IsMerchantType(pin.type)) {
				npcEntity = (CNewNPC) pin.entities[0];
				if (npcEntity) {
					hasValidIdTag = IsIdTagValid(npcEntity.idTag);

					if (hasValidIdTag || LOG_ENABLED) {
						mpin.entityIdTag = npcEntity.idTag;
						mpin.uniqueTag = GetMerchantUniqueTag(npcEntity.GetTags());
						mpin.area = currentArea;
						mpin.pin = pin;
						mpin.entityTags = npcEntity.GetTags();
						mpin.pin.entities.Clear();
					}

					if (hasValidIdTag) {
						foundType = 0; // not found

						idx = m_idTagsList.FindFirst(mpin.entityIdTag);
						if (idx == -1) {
							if (mpin.uniqueTag != 'WmkNone') {
								idx = m_uniqueTagsList.FindFirst(mpin.uniqueTag);
							}
							if (idx == -1) {
								idx = FindFirstMerchantByTypeAndLocation(pin.type, pin.position);
								if (idx != -1) {
									foundType = 3;
								}
							} else {
								foundType = 2;
							}
						} else {
							foundType = 1;
						}

						if (idx != -1) {
							if (LOG_ENABLED) {
								switch (foundType) {
									case 1:
									case 2: Log("UPDATED MERCHANT PIN [" + foundType + ", " + idx + "]: " + PinToString(mpin)); break;
									case 3:
										m_data.replacedSameTypePosMerchantPins.PushBack(m_data.merchantPins[idx]);
										Log("REPLACED MERCHANT PIN[" + idx + "]: " + PinToString(m_data.merchantPins[idx]));
										Log("WITH: " + PinToString(mpin));
								}
							}

							pos = -1;

							if ((foundType != 2) && (mpin.uniqueTag != 'WmkNone')) {
								m_uniqueTagsList[idx] = '';
								pos = m_uniqueTagsList.FindFirst(mpin.uniqueTag);
							}

							UpdateMerchantPin(idx, mpin);

							if (pos != -1) {
								m_data.removedSameUniqueTagMerchantPins.PushBack(m_data.merchantPins[pos]);
								Log("REMOVED MERCANT PIN [" + pos + "]: " + PinToString(m_data.merchantPins[pos]));
								EraseMerchantPin(pos);
							}
						} else {
							if (m_data.merchantPins.Size() >= MAX_CACHED_PINS) {
								if (LOG_ENABLED) {
									Log("WARNING: maximum number of cached pins reached: size = " + m_data.merchantPins.Size() + " max = " + MAX_CACHED_PINS);
									Log("SKIPPING MERCHANT PIN: " + PinToString(mpin));
								}
							} else if (CACHE_WANDERING_MERCHANT_PINS || !IsWanderingMerchant(npcEntity)) {
								AddMerchantPin(mpin);
								if (LOG_ENABLED) {
									Log("NEW MERCHANT PIN: " + PinToString(mpin));
								}
							} else if (LOG_ENABLED) {
								Log("SKIPPING WANDERING MERCHANT PIN: " + PinToString(mpin));
							}
						}
					} else if (LOG_ENABLED) {
						Log("WARNING: " + PinToString(mpin));
					}
				}
			}
		}
	}

	function FindFirstMerchantByTypeAndLocation(type : name, position : Vector) : int
	{
		var i : int;
		var distance : float;

		for (i = 0; i < m_data.merchantPins.Size(); i += 1) {
			if (m_data.merchantPins[i].pin.type == type) {
				distance = VecDistance(m_data.merchantPins[i].pin.position, position);
				if (distance <= TOO_CLOSE_DISTANCE) {
					return i;
				}
			}
		}

		return -1;
	}

	// Returns true to cache the pins with specified type, false otherwise.
	private function IsMerchantType(type : name) : bool {
		switch (type) {
			case 'Shopkeeper':
			case 'Blacksmith':
			case 'Armorer':
			case 'Hairdresser':
			case 'Alchemic':
			case 'Herbalist':
			case 'Innkeeper':
			case 'Enchanter':
			case 'Prostitute':
			case 'DyeMerchant':
			case 'WineMerchant':
			case 'Cammerlengo':
				return true;
		}

		return false;
	}

	private function AddMerchantPin(mpin : WmkMerchantMapPin)
	{
		m_data.merchantPins.PushBack(mpin);
		m_idTagsList.PushBack(mpin.entityIdTag);
		m_uniqueTagsList.PushBack(mpin.uniqueTag);
	}

	private function UpdateMerchantPin(idx : int, mpin : WmkMerchantMapPin)
	{
		m_data.merchantPins[idx] = mpin;
		m_idTagsList[idx] = mpin.entityIdTag;
		m_uniqueTagsList[idx] = mpin.uniqueTag;
	}

	private function EraseMerchantPin(idx : int)
	{
		m_data.merchantPins.Erase(idx);
		m_idTagsList.Erase(idx);
		m_uniqueTagsList.Erase(idx);
	}

	// Returns TRUE if the specified tag is generic and cannot be used to identify a merchant.
	private function IsGenericMerchantTag(tag : name) : bool
	{
		switch (tag)
		{
			case 'Merchant':
			case 'ShopkeeperEntity':
			case 'Blacksmith':
			case 'Armorer':
			case 'Apprentice':
			case 'Specialist':
			case 'Master':
			case 'Archmaster':
			case 'type_enchanter':
				return true;
		}

		return StrBeginsWith(NameToString(tag), "generic_merchant_");
	}

	// Returns the first tag if can be used to unique identify a merchant.
	// For most merchants only the first tag seems to be unique, but there's at least one exception: the innkeeper from Crossroads,
	// which has nml_crossroads_barkeep, q101_barkeep, ShopkeeperEntity and Merchant tags (so I assume the
	// second one is unique too).
	private function GetMerchantUniqueTag(tags : array<name>) : name
	{
		if (tags.Size() > 0) {
			if (IsNameValid(tags[0]) && !IsGenericMerchantTag(tags[0])) {
				return tags[0];
			}
		}
		return 'WmkNone';
	}

	// Wandering merchants should have the first tag set to generic_merchant_nomansland_merchant_wandering (Valen)
	// or generic_merchant_skellige_merchant_wandering (Skellige).
	private function IsWanderingMerchant(npc : CNewNPC) : bool
	{
		var tags : array<name> = npc.GetTags();

		if (tags.Size() > 0) {
			return StrBeginsWith(tags[0], "generic_merchant_") && StrEndsWith(tags[0], "_wandering");
		}

		return false;
	}

	// Creates the flash object for a saved / cached merchant pin.
	private function CreateMerchantPinFlashObject(mpin : WmkMerchantMapPin, idx : int) : CScriptedFlashObject
	{
		var flashObject : CScriptedFlashObject;
		var pin : SCommonMapPinInstance = mpin.pin;

		if (LOG_ENABLED) {
			Log("ADD MERCHANT PIN: " + PinToString(mpin));
		}

		flashObject = m_mapMenu.GetMenuFlashValueStorage().CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");
		flashObject.SetMemberFlashUInt("id", NameToFlashUInt(pin.tag));
		flashObject.SetMemberFlashString("type", pin.visibleType);
		flashObject.SetMemberFlashString("filteredType", NameToString(pin.visibleType));
		flashObject.SetMemberFlashNumber("posX", pin.position.X);
		flashObject.SetMemberFlashNumber("posY", pin.position.Y);
		flashObject.SetMemberFlashUInt("areaId", m_shownArea);
		flashObject.SetMemberFlashInt("journalAreaId", m_commonMapManager.GetJournalAreaByPosition(m_shownArea, pin.position));
		flashObject.SetMemberFlashNumber("rotation", MERCHANT_PIN_ROTATION);

		flashObject.SetMemberFlashUInt("wmkTag", NameToFlashUInt('wmk_merchant'));
		flashObject.SetMemberFlashUInt("wmkData", idx);

		AddPinTypeData(flashObject, pin);

		return flashObject;
	}

	// See CR4MapMenu::AddPinTypeData function (mapMenu.ws file).
	private function AddPinTypeData(out flashObject : CScriptedFlashObject, pin: SCommonMapPinInstance)
	{
		var labelKey, descriptionKey : string;
		var label, description : string;

		switch (pin.type) {
			case 'Shopkeeper':
			case 'Blacksmith':
			case 'Armorer':
			case 'Hairdresser':
			case 'Alchemic':
			case 'DyeMerchant':
			case 'WineMerchant':
			case 'Cammerlengo':
				labelKey = "map_location_" + StrLower(pin.type);
				descriptionKey = "map_description_" + StrLower(pin.type);
				break;
			case 'Herbalist':
				labelKey = "herbalist";
				descriptionKey = "map_description_alchemic";
				break;
			case 'Innkeeper':
				label = GetLocStringById(175619);
				descriptionKey = "map_description_shopkeeper";
				break;
			case 'Enchanter':
				labelKey = "panel_map_enchanter_pin_name";
				descriptionKey = "panel_map_enchanter_pin_description";
				break;
			case 'Prostitute':
				labelKey = "novigrad_courtisan";
				descriptionKey = "map_description_prostitute";
				break;
			default:
				return;
		}

		if (StrLen(label) == 0) {
			label = GetLocStringByKeyExt(labelKey);
		}

		flashObject.SetMemberFlashString("label", "<font color=\"#969696\">" + GetLocStringByKeyExt(CACHED_MERCHANT_PIN_LABEL_PREFIX) + "</font>" + label);
		flashObject.SetMemberFlashString("description", GetLocStringByKeyExt(descriptionKey) + "<br><font color=\"#969696\" size=\"18\">" + GetLocStringByKeyExt(CACHED_MERCHANT_PIN_DESCR_SUFFIX) + "</font>");
		flashObject.SetMemberFlashString("wmkFilteredLabel", label);
	}

	// For logging.
	private function PinToString(mpin : WmkMerchantMapPin) : string
	{
		var i : int;
		var entityTags : string;
		var pin : SCommonMapPinInstance = mpin.pin;
		var prefix : string;

		for (i = 0; i < mpin.entityTags.Size(); i += 1) {
			if (i > 0) {
				entityTags += ", ";
			}
			if (mpin.entityTags[i] == mpin.uniqueTag) {
				entityTags += "[" + mpin.entityTags[i] + "]";
			} else {
				entityTags += mpin.entityTags[i];
			}
		}

		if (!IsIdTagValid(mpin.entityIdTag)) {
			prefix = "INVALID IDTAG ";
		}

		return prefix + "entityTags = " + entityTags + " area = " + mpin.area + " id = " + pin.id
				+ " tag = " + pin.tag + " extraTag = " + pin.extraTag + " type = " + pin.type + " visibleType = " + pin.visibleType
				+ " isDynamic = " + pin.isDynamic + " isKnown = " + pin.isKnown + " isDiscovered = " + pin.isDiscovered
				+ " isDisabled = " + pin.isDisabled + " isHighlightable = " + pin.isHighlightable + " isHighlighted = " + pin.isHighlighted
				+ " canBePointedByArrow = " + pin.canBePointedByArrow + " canBeAddedToMinimap = " + pin.canBeAddedToMinimap
				+ " isAddedToMinimap = " + pin.isAddedToMinimap + " invalidated = " + pin.invalidated
				+ " radius = " + pin.radius + " visibleRadius = " + pin.visibleRadius
				+ " x = " + pin.position.X + " y = " + pin.position.Y + " z = " + pin.position.Z
				+ " entities = " + pin.entities.Size();

	}

	// Is this the only way to know if an IdTag value is valid?
	private function IsIdTagValid(idTag : IdTag) : bool
	{
		var nullIdTag : IdTag;
		return idTag != nullIdTag;
	}
}
