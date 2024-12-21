/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


struct SDurabilityThreshold
{
	var thresholdMax : float;	
	var multiplier : float;		
	var difficulty : EDifficultyMode;
};


import class W3GameParams extends CObject
{
	private var dm : CDefinitionsManagerAccessor;					
	private var main : SCustomNode;									
	
	
	public const var BASE_ABILITY_TAG : name;																					
	public const var PASSIVE_BONUS_ABILITY_TAG : name;																			
		default BASE_ABILITY_TAG = 'base';
		default PASSIVE_BONUS_ABILITY_TAG = 'passive';
	private var forbiddenAttributes : array<name>;				
																
																
	public var GLOBAL_ENEMY_ABILITY : name;						
		default GLOBAL_ENEMY_ABILITY = 'all_NPC_ability';
	
	// W3EE - Begin
	public var ENEMY_GROUP_BONUS_PER_LEVEL : name;					
		default ENEMY_GROUP_BONUS_PER_LEVEL = 'NPCGroupLevelBonus';
	
	public var ENEMY_GROUP_BONUS_PER_LEVEL_FIXED : name;					
		default ENEMY_GROUP_BONUS_PER_LEVEL_FIXED = 'NPCGroupLevelBonusFixed';
	
	public var ENEMY_BONUS_PER_LEVEL_FIXED : name;					
		default ENEMY_BONUS_PER_LEVEL_FIXED = 'NPCLevelBonusFixed';
	
	public var MONSTER_BONUS_PER_LEVEL_FIXED : name;					
		default MONSTER_BONUS_PER_LEVEL_FIXED = 'MonsterLevelBonusFixed';
	
	public var MONSTER_BONUS_PER_LEVEL_GROUP_FIXED : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP_FIXED = 'MonsterLevelBonusGroupFixed';
	
	public var MONSTER_BONUS_PER_LEVEL_ARMORED_FIXED : name;					
		default MONSTER_BONUS_PER_LEVEL_ARMORED_FIXED = 'MonsterLevelBonusArmoredFixed';
	
	public var MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED_FIXED : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED_FIXED = 'MonsterLevelBonusGroupArmoredFixed';
	
	public var ENEMY_HEALTH_PER_LEVEL : int;
		default ENEMY_HEALTH_PER_LEVEL = 267;
	
	public var ENEMY_GROUP_HEALTH_PER_LEVEL : int;
		default ENEMY_GROUP_HEALTH_PER_LEVEL = 96;
	
	public var MONSTER_HEALTH_PER_LEVEL : int;
		default MONSTER_HEALTH_PER_LEVEL = 9100;
	
	public var MONSTER_GROUP_HEALTH_PER_LEVEL : int;
		default MONSTER_GROUP_HEALTH_PER_LEVEL = 131;
	
	public var AMONSTER_HEALTH_PER_LEVEL : int;
		default AMONSTER_HEALTH_PER_LEVEL = 293;
	
	public var AMONSTER_GROUP_HEALTH_PER_LEVEL : int;
		default AMONSTER_GROUP_HEALTH_PER_LEVEL = 124;

	public var ENEMY_DAMAGE_PER_LEVEL : int;
		default ENEMY_DAMAGE_PER_LEVEL = 31;
	
	public var ENEMY_GROUP_DAMAGE_PER_LEVEL : int;
		default ENEMY_GROUP_DAMAGE_PER_LEVEL = 25;
	
	public var MONSTER_DAMAGE_PER_LEVEL : int;
		default MONSTER_DAMAGE_PER_LEVEL = 58;
	
	public var MONSTER_GROUP_DAMAGE_PER_LEVEL : int;
		default MONSTER_GROUP_DAMAGE_PER_LEVEL = 15;
	
	public var AMONSTER_DAMAGE_PER_LEVEL : int;
		default AMONSTER_DAMAGE_PER_LEVEL = 60;
	
	public var AMONSTER_GROUP_DAMAGE_PER_LEVEL : int;
		default AMONSTER_GROUP_DAMAGE_PER_LEVEL = 16;
	// W3EE - End
	
	public var ENEMY_BONUS_PER_LEVEL : name;					
		default ENEMY_BONUS_PER_LEVEL = 'NPCLevelBonus';
		
	public var ENEMY_BONUS_FISTFIGHT_LOW : name;					
		default ENEMY_BONUS_FISTFIGHT_LOW = 'NPCLevelModFistFightLower';
	
	public var ENEMY_BONUS_FISTFIGHT_HIGH : name;					
		default ENEMY_BONUS_FISTFIGHT_HIGH = 'NPCLevelModFistFightHigher';
		
	public var ENEMY_BONUS_LOW : name;					
		default ENEMY_BONUS_LOW = 'NPCLevelBonusLow';
		
	public var ENEMY_BONUS_HIGH : name;					
		default ENEMY_BONUS_HIGH = 'NPCLevelBonusHigh';
		
	public var ENEMY_BONUS_DEADLY : name;					
		default ENEMY_BONUS_DEADLY = 'NPCLevelBonusDeadly';
		
	public var MONSTER_BONUS_PER_LEVEL : name;					
		default MONSTER_BONUS_PER_LEVEL = 'MonsterLevelBonus';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP = 'MonsterLevelBonusGroup';
		
	public var MONSTER_BONUS_PER_LEVEL_ARMORED : name;					
		default MONSTER_BONUS_PER_LEVEL_ARMORED = 'MonsterLevelBonusArmored';
		
	public var MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED : name;					
		default MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED = 'MonsterLevelBonusGroupArmored';
		
	public var MONSTER_BONUS_LOW : name;						
		default MONSTER_BONUS_LOW = 'MonsterLevelBonusLow';
		
	public var MONSTER_BONUS_HIGH : name;						
		default MONSTER_BONUS_HIGH = 'MonsterLevelBonusHigh';
		
	public var MONSTER_BONUS_DEADLY : name;						
		default MONSTER_BONUS_DEADLY = 'MonsterLevelBonusDeadly';
	
	public var BOSS_NGP_BONUS : name;
		default BOSS_NGP_BONUS = 'BossNGPLevelBonus';
		
	public var GLOBAL_PLAYER_ABILITY : name;					
		default GLOBAL_PLAYER_ABILITY = 'all_PC_ability';
	
	public const var NOT_A_SKILL_ABILITY_TAG : name;			
		default NOT_A_SKILL_ABILITY_TAG = 'NotASkill';
	
	
	public const var ALCHEMY_COOKED_ITEM_TYPE_POTION, ALCHEMY_COOKED_ITEM_TYPE_BOMB, ALCHEMY_COOKED_ITEM_TYPE_OIL : string;		
	public const var OIL_ABILITY_TAG : name;																					
	public const var QUANTITY_INCREASED_BY_ALCHEMY_TABLE : int;
		default ALCHEMY_COOKED_ITEM_TYPE_POTION = "Potion";
		default ALCHEMY_COOKED_ITEM_TYPE_BOMB = "Bomb";
		default ALCHEMY_COOKED_ITEM_TYPE_OIL = "Oil";	 
		default	OIL_ABILITY_TAG = 'OilBonus';
		default QUANTITY_INCREASED_BY_ALCHEMY_TABLE = 1;
	
	
	public const var ATTACK_NAME_LIGHT, ATTACK_NAME_HEAVY, ATTACK_NAME_SUPERHEAVY, ATTACK_NAME_SPEED_BASED, ATTACK_NO_DAMAGE : name;		
		default ATTACK_NAME_LIGHT = 'attack_light';
		default ATTACK_NAME_HEAVY = 'attack_heavy';
		default ATTACK_NAME_SUPERHEAVY = 'attack_super_heavy';
		default ATTACK_NAME_SPEED_BASED = 'attack_speed_based';		
		default ATTACK_NO_DAMAGE = 'attack_no_damage';		
	
	
	public const var MAX_DYNAMICALLY_SPAWNED_BOATS : int;		
		default MAX_DYNAMICALLY_SPAWNED_BOATS = 5;
	
	
	public const var MAX_THROW_RANGE : float;					
	public const var UNDERWATER_THROW_RANGE : float;					
	public const var PROXIMITY_PETARD_IDLE_DETONATION_TIME : float;		
	public const var BOMB_THROW_DELAY : float;							
		default MAX_THROW_RANGE = 25.0;
		default UNDERWATER_THROW_RANGE = 5.0;
		default PROXIMITY_PETARD_IDLE_DETONATION_TIME = 10.0;
		default BOMB_THROW_DELAY = 2.f;
		
	
	public const var CONTAINER_DYNAMIC_DESTROY_TIMEOUT : int;	
		default CONTAINER_DYNAMIC_DESTROY_TIMEOUT = 900;
		
	
	public const var CRITICAL_HIT_CHANCE : name;					
	public const var CRITICAL_HIT_DAMAGE_BONUS : name;				
	public const var CRITICAL_HIT_REDUCTION : name;					
	public const var CRITICAL_HIT_FX : name;						
	public const var HEAD_SHOT_CRIT_CHANCE_BONUS : float;			
	public const var BACK_ATTACK_CRIT_CHANCE_BONUS : float;			
	
		default CRITICAL_HIT_CHANCE = 'critical_hit_chance';
		default CRITICAL_HIT_FX = 'critical_hit';
		default CRITICAL_HIT_DAMAGE_BONUS = 'critical_hit_damage_bonus';
		default CRITICAL_HIT_REDUCTION = 'critical_hit_damage_reduction';
		default HEAD_SHOT_CRIT_CHANCE_BONUS = 1.f;
		default BACK_ATTACK_CRIT_CHANCE_BONUS = 0.15;
	
	
	public const var DAMAGE_NAME_DIRECT, DAMAGE_NAME_PHYSICAL, DAMAGE_NAME_SILVER, DAMAGE_NAME_SLASHING, DAMAGE_NAME_PIERCING, DAMAGE_NAME_BLUDGEONING, DAMAGE_NAME_RENDING, DAMAGE_NAME_ELEMENTAL, DAMAGE_NAME_FIRE, DAMAGE_NAME_FORCE, DAMAGE_NAME_FROST, DAMAGE_NAME_POISON, DAMAGE_NAME_SHOCK, DAMAGE_NAME_MORALE, DAMAGE_NAME_STAMINA : name;
		default DAMAGE_NAME_DIRECT 		= 'DirectDamage';
		default DAMAGE_NAME_PHYSICAL 	= 'PhysicalDamage';
		default DAMAGE_NAME_SILVER 		= 'SilverDamage';
		default DAMAGE_NAME_SLASHING	= 'SlashingDamage';
		default DAMAGE_NAME_PIERCING 	= 'PiercingDamage';
		default DAMAGE_NAME_BLUDGEONING = 'BludgeoningDamage';
		default DAMAGE_NAME_RENDING	 	= 'RendingDamage';
		default DAMAGE_NAME_ELEMENTAL	= 'ElementalDamage';
		default DAMAGE_NAME_FIRE 		= 'FireDamage';
		default DAMAGE_NAME_FORCE 		= 'ForceDamage';
		default DAMAGE_NAME_FROST 		= 'FrostDamage';
		default DAMAGE_NAME_POISON 		= 'PoisonDamage';
		default DAMAGE_NAME_SHOCK 		= 'ShockDamage';
		default DAMAGE_NAME_MORALE 		= 'MoraleDamage';
		default DAMAGE_NAME_STAMINA 	= 'StaminaDamage';
		
	// W3EE - Begin
	public const var DAMAGE_NAME_BLEEDING, DAMAGE_NAME_SLOW, DAMAGE_NAME_MENTAL, DAMAGE_NAME_STUN, DAMAGE_NAME_INJURY, DAMAGE_NAME_ARMOR_PIERCE, DAMAGE_NAME_ARMOR_PIERCE_RANGED : name;
		default DAMAGE_NAME_BLEEDING			= 'BleedingDamage';
		default DAMAGE_NAME_SLOW				= 'SlowDamage';
		default DAMAGE_NAME_MENTAL				= 'MentalDamage';
		default DAMAGE_NAME_STUN				= 'StunDamage';
		default DAMAGE_NAME_INJURY				= 'InjuryDamage';
		default DAMAGE_NAME_ARMOR_PIERCE		= 'ArmorPierceDamage';
		default DAMAGE_NAME_ARMOR_PIERCE_RANGED	= 'ArmorPierceDamageRanged';
	// W3EE - End
	
	public const var FOCUS_DRAIN_PER_HIT : float;					
	public const var UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY, UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY : name;		
	public const var MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS 	: float;		
	public const var ARMOR_VALUE_NAME : name;
	public const var LOW_HEALTH_EFFECT_SHOW : float;				
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS : float;					
	public const var UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP : float;				
	public const var ARCHER_DAMAGE_BONUS_NGP : float;				

		default MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS = 70;
		default ARMOR_VALUE_NAME = 'armor';		
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS = 2;
		default UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP = 6;
		default ARCHER_DAMAGE_BONUS_NGP = 2;
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_REGULAR_ENEMY = 'combat_radial_blur';
		default UNINTERRUPTED_HITS_CAMERA_EFFECT_BIG_ENEMY = 'combat_radial_blur_big';
		default FOCUS_DRAIN_PER_HIT = 0.02;
		default LOW_HEALTH_EFFECT_SHOW = 0.3;
	
	public const var IGNI_SPELL_POWER_MILT : float;
		default	IGNI_SPELL_POWER_MILT = 1.0f;
		
	public const var INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN : float;					
		default INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN = 15.f;
	
	
	public var DIFFICULTY_TAG_EASY, DIFFICULTY_TAG_MEDIUM, DIFFICULTY_TAG_HARD, DIFFICULTY_TAG_HARDCORE : name;			
	public var DIFFICULTY_TAG_DIFF_ABILITY : name;																		
	public var DIFFICULTY_HP_MULTIPLIER, DIFFICULTY_DMG_MULTIPLIER : name;												
	public var DIFFICULTY_TAG_IGNORE : name;																			
	
		default DIFFICULTY_TAG_DIFF_ABILITY = 'DifficultyModeAbility';		
		default DIFFICULTY_TAG_EASY			= 'Easy';
		default DIFFICULTY_TAG_MEDIUM		= 'Medium';
		default DIFFICULTY_TAG_HARD			= 'Hard';
		default DIFFICULTY_TAG_HARDCORE 	= 'Hardcore';
		default DIFFICULTY_HP_MULTIPLIER 	= 'health_final_multiplier';
		default DIFFICULTY_DMG_MULTIPLIER 	= 'damage_final_multiplier';
		default DIFFICULTY_TAG_IGNORE		= 'IgnoreDifficultyAbilities';
		
	
	public const var DISMEMBERMENT_ON_DEATH_CHANCE : int;				
		default DISMEMBERMENT_ON_DEATH_CHANCE = 30;
		
	
	public const var FINISHER_ON_DEATH_CHANCE : int;					
		default FINISHER_ON_DEATH_CHANCE = 30;		
	
	
	public const var DURABILITY_ARMOR_LOSE_CHANCE, DURABILITY_WEAPON_LOSE_CHANCE : int;			
	public const var DURABILITY_ARMOR_LOSE_VALUE : float;										
	private const var DURABILITY_WEAPON_LOSE_VALUE, DURABILITY_WEAPON_LOSE_VALUE_HARDCORE : float;
	public const var DURABILITY_ARMOR_CHEST_WEIGHT, DURABILITY_ARMOR_PANTS_WEIGHT, DURABILITY_ARMOR_BOOTS_WEIGHT, DURABILITY_ARMOR_GLOVES_WEIGHT, DURABILITY_ARMOR_MISS_WEIGHT : int; 
	protected var durabilityThresholdsWeapon, durabilityThresholdsArmor : array<SDurabilityThreshold>;					
	public const var TAG_REPAIR_CONSUMABLE_ARMOR, TAG_REPAIR_CONSUMABLE_STEEL, TAG_REPAIR_CONSUMABLE_SILVER : name;		
	public const var ITEM_DAMAGED_DURABILITY : int;												
	public var INTERACTIVE_REPAIR_OBJECT_MAX_DURS : array<int>;									
		
		default TAG_REPAIR_CONSUMABLE_ARMOR = 'RepairArmor';
		default TAG_REPAIR_CONSUMABLE_STEEL = 'RepairSteel';
		default TAG_REPAIR_CONSUMABLE_SILVER = 'RepairSilver';
		
		// W3EE - Begin
		default ITEM_DAMAGED_DURABILITY = 75;
	
		default DURABILITY_ARMOR_LOSE_CHANCE = 100;
		default DURABILITY_WEAPON_LOSE_CHANCE = 100;
		default DURABILITY_ARMOR_LOSE_VALUE = 0.5;
		default DURABILITY_WEAPON_LOSE_VALUE = 0.1;
		default DURABILITY_WEAPON_LOSE_VALUE_HARDCORE = 0.05;
		// W3EE - End
		
		
		default DURABILITY_ARMOR_MISS_WEIGHT = 10;
		default DURABILITY_ARMOR_CHEST_WEIGHT = 50;			
		default DURABILITY_ARMOR_BOOTS_WEIGHT = 15;
		default DURABILITY_ARMOR_PANTS_WEIGHT = 15;
		default DURABILITY_ARMOR_GLOVES_WEIGHT = 10;
	
	
	public const var CFM_SLOWDOWN_RATIO : float;					
		default CFM_SLOWDOWN_RATIO = 0.01;
	
	
	public const var LIGHT_HIT_FX, LIGHT_HIT_BACK_FX, LIGHT_HIT_PARRIED_FX, LIGHT_HIT_BACK_PARRIED_FX, HEAVY_HIT_FX, HEAVY_HIT_BACK_FX, HEAVY_HIT_PARRIED_FX, HEAVY_HIT_BACK_PARRIED_FX : name;
		default LIGHT_HIT_FX = 'light_hit';			
		default LIGHT_HIT_BACK_FX = 'light_hit_back';
		default LIGHT_HIT_PARRIED_FX = 'light_hit_parried';
		default LIGHT_HIT_BACK_PARRIED_FX = 'light_hit_back_parried';
		default HEAVY_HIT_FX = 'heavy_hit';
		default HEAVY_HIT_BACK_FX = 'heavy_hit_back';
		default HEAVY_HIT_PARRIED_FX = 'heavy_hit_parried';
		default HEAVY_HIT_BACK_PARRIED_FX = 'heavy_hit_back_parried';
		
	public const var LOW_HP_SHOW_LEVEL : float;							
		default LOW_HP_SHOW_LEVEL = 0.25;

	
	public const var TAG_ARMOR : name;								
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_YES : name;			
	public const var TAG_ENCUMBRANCE_ITEM_FORCE_NO : name;			
	public const var TAG_ITEM_UPGRADEABLE : name;					
	public const var TAG_DONT_SHOW : name;							
	public const var TAG_DONT_SHOW_ONLY_IN_PLAYERS : name;			
	public const var TAG_ITEM_SINGLETON : name;						
	public const var TAG_INFINITE_AMMO : name;						
	public const var TAG_UNDERWATER_AMMO : name;					
	public const var TAG_GROUND_AMMO : name;	
	public const var TAG_ILLUSION_MEDALLION : name;
	public const var TAG_PLAYER_STEELSWORD : name;					
	public const var TAG_PLAYER_SILVERSWORD : name;					
	public const var TAG_INFINITE_USE : name;						
	private var ARMOR_MASTERWORK_LIGHT_ABILITIES 	: array<name>;			
	private var ARMOR_MAGICAL_LIGHT_ABILITIES 	: array<name>;			
	private var GLOVES_MASTERWORK_LIGHT_ABILITIES	: array<name>;			
	private var GLOVES_MAGICAL_LIGHT_ABILITIES 	: array<name>;			
	private var PANTS_MASTERWORK_LIGHT_ABILITIES	: array<name>;			
	private var PANTS_MAGICAL_LIGHT_ABILITIES 	: array<name>;			
	private var BOOTS_MASTERWORK_LIGHT_ABILITIES	: array<name>;			
	private var BOOTS_MAGICAL_LIGHT_ABILITIES 	: array<name>;			
	private var ARMOR_MASTERWORK_MEDIUM_ABILITIES 	: array<name>;			
	private var ARMOR_MAGICAL_MEDIUM_ABILITIES 	: array<name>;			
	private var GLOVES_MASTERWORK_MEDIUM_ABILITIES	: array<name>;			
	private var GLOVES_MAGICAL_MEDIUM_ABILITIES 	: array<name>;			
	private var PANTS_MASTERWORK_MEDIUM_ABILITIES	: array<name>;			
	private var PANTS_MAGICAL_MEDIUM_ABILITIES 	: array<name>;			
	private var BOOTS_MASTERWORK_MEDIUM_ABILITIES	: array<name>;			
	private var BOOTS_MAGICAL_MEDIUM_ABILITIES 	: array<name>;			
	private var ARMOR_MASTERWORK_HEAVY_ABILITIES 	: array<name>;			
	private var ARMOR_MAGICAL_HEAVY_ABILITIES 	: array<name>;			
	private var GLOVES_MASTERWORK_HEAVY_ABILITIES	: array<name>;			
	private var GLOVES_MAGICAL_HEAVY_ABILITIES 	: array<name>;			
	private var PANTS_MASTERWORK_HEAVY_ABILITIES	: array<name>;			
	private var PANTS_MAGICAL_HEAVY_ABILITIES 	: array<name>;			
	private var BOOTS_MASTERWORK_HEAVY_ABILITIES	: array<name>;			
	private var BOOTS_MAGICAL_HEAVY_ABILITIES 	: array<name>;			
	private var WEAPON_MASTERWORK_ABILITIES	: array<name>;			
	private var WEAPON_MAGICAL_ABILITIES 	: array<name>;			
	// W3EE - Begin
	private var WEAPON_COMMON_ABILITIES 	: array<name>;
	// W3EE - End
	//Kolaris - Armor Set Bonus Setup
	public const var ITEM_SET_TAG_BEAR, ITEM_SET_TAG_GRYPHON, ITEM_SET_TAG_LYNX, ITEM_SET_TAG_WOLF, ITEM_SET_TAG_RED_WOLF, ITEM_SET_TAG_VAMPIRE, ITEM_SET_TAG_VAMPIRE_ALT, ITEM_SET_TAG_TEMERIAN, ITEM_SET_TAG_NILFGAARD, ITEM_SET_TAG_SKELLIGE, ITEM_SET_TAG_OFIERI, ITEM_SET_TAG_NEW_MOON, ITEM_SET_TAG_VIPER, ITEM_SET_TAG_NETFLIX, ITEM_SET_TAG_ELVEN, ITEM_SET_TAG_TIGER : name;		
	public const var BOUNCE_ARROWS_ABILITY : name;					
	public const var TAG_ALCHEMY_REFILL_ALCO : name;				
	public const var REPAIR_OBJECT_BONUS_ARMOR_ABILITY : name;		
	public const var REPAIR_OBJECT_BONUS_WEAPON_ABILITY : name;		
	public const var REPAIR_OBJECT_BONUS : name;					
	public const var CIRI_SWORD_NAME : name;
	public const var TAG_OFIR_SET : name;							
	// W3EE - Begin
	public const var ITEM_SET_TAG_GOTHIC, ITEM_SET_TAG_DIMERITIUM, ITEM_SET_TAG_METEORITE : name;
		default ITEM_SET_TAG_GOTHIC = 'GothicSetTag';
		default ITEM_SET_TAG_DIMERITIUM = 'DimeritiumSetTag';
		default ITEM_SET_TAG_METEORITE = 'MeteoriteSetTag';
	// W3EE - End
		
		default TAG_ARMOR = 'Armor';
		default TAG_ENCUMBRANCE_ITEM_FORCE_YES = 'EncumbranceOn';
		default TAG_ENCUMBRANCE_ITEM_FORCE_NO = 'EncumbranceOff';
		default TAG_ITEM_UPGRADEABLE = 'Upgradeable';
		default TAG_DONT_SHOW = 'NoShow';
		default TAG_DONT_SHOW_ONLY_IN_PLAYERS = 'NoShowInPlayersInventory';
		default TAG_ITEM_SINGLETON = 'SingletonItem';
		default TAG_INFINITE_AMMO = 'InfiniteAmmo';
		default TAG_UNDERWATER_AMMO = 'UnderwaterAmmo';
		default TAG_GROUND_AMMO = 'GroundAmmo';
		default TAG_ILLUSION_MEDALLION = 'IllusionMedallion';
		default TAG_PLAYER_STEELSWORD = 'PlayerSteelWeapon';
		default TAG_PLAYER_SILVERSWORD = 'PlayerSilverWeapon';
		default TAG_INFINITE_USE = 'InfiniteUse';
		default ITEM_SET_TAG_BEAR = 'BearSet';
		default ITEM_SET_TAG_GRYPHON = 'GryphonSet';
		default ITEM_SET_TAG_LYNX = 'LynxSet';
		default ITEM_SET_TAG_WOLF = 'WolfSet';
		default ITEM_SET_TAG_RED_WOLF = 'RedWolfSet';
		default ITEM_SET_TAG_VIPER = 'ViperSet';
		default ITEM_SET_TAG_VAMPIRE = 'VampireSet';
		//Kolaris - Armor Set Bonus Setup
		default ITEM_SET_TAG_VAMPIRE_ALT = 'VampireSetAlt';
		default ITEM_SET_TAG_TEMERIAN = 'TemerianSet';
		default ITEM_SET_TAG_NILFGAARD = 'NilfgaardSet';
		default ITEM_SET_TAG_SKELLIGE = 'SkelligeSet';
		default ITEM_SET_TAG_OFIERI = 'OfieriSet';
		default ITEM_SET_TAG_NEW_MOON = 'NewMoonSet';
		default ITEM_SET_TAG_NETFLIX = 'NetflixSet';
		default ITEM_SET_TAG_ELVEN = 'ElvenSet';
		default ITEM_SET_TAG_TIGER = 'TigerSet';
		default BOUNCE_ARROWS_ABILITY = 'bounce_arrows';
		default TAG_ALCHEMY_REFILL_ALCO = 'StrongAlcohol';
		default REPAIR_OBJECT_BONUS_ARMOR_ABILITY = 'repair_object_armor_bonus';
		default REPAIR_OBJECT_BONUS_WEAPON_ABILITY = 'repair_object_weapon_bonus';
		default REPAIR_OBJECT_BONUS = 'repair_object_stat_bonus';
		default CIRI_SWORD_NAME = 'Zireael Sword';
		default TAG_OFIR_SET = 'Ofir';
	
	
	private var newGamePlusLevel : int;						
	private const var NEW_GAME_PLUS_LEVEL_ADD : int;		
	public const var NEW_GAME_PLUS_MIN_LEVEL : int;				
	public const var NEW_GAME_PLUS_EP1_MIN_LEVEL : int;			
		default NEW_GAME_PLUS_LEVEL_ADD = 0;
		default NEW_GAME_PLUS_MIN_LEVEL = 30;
		default NEW_GAME_PLUS_EP1_MIN_LEVEL = 30;
	
	
	public const var TAG_STEEL_OIL, TAG_SILVER_OIL : name;
		default TAG_STEEL_OIL = 'SteelOil';
		default TAG_SILVER_OIL = 'SilverOil';
	
	
	public const var HEAVY_STRIKE_COST_MULTIPLIER : float;								
	public const var PARRY_HALF_ANGLE : int;											
	public const var PARRY_STAGGER_REDUCE_DAMAGE_LARGE : float;							
	public const var PARRY_STAGGER_REDUCE_DAMAGE_SMALL : float;							
		default PARRY_HALF_ANGLE = 180;
		// W3EE - Begin
		default HEAVY_STRIKE_COST_MULTIPLIER = 1.35;
		// W3EE - End
		default PARRY_STAGGER_REDUCE_DAMAGE_LARGE = 0.6f;
		default PARRY_STAGGER_REDUCE_DAMAGE_SMALL = 0.3f;
		
	
	public const var POTION_QUICKSLOTS_COUNT : int;										
		default POTION_QUICKSLOTS_COUNT = 4;
	
	
	public const var ITEMS_REQUIRED_FOR_MINOR_SET_BONUS : int;
	public const var ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS : int;
	public const var ITEM_SET_TAG_BONUS					: name;
		default ITEMS_REQUIRED_FOR_MINOR_SET_BONUS = 4;
		// W3EE - Begin
		default ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS = 4;
		// W3EE - End
		default ITEM_SET_TAG_BONUS = 'SetBonusPiece';
	
	public const var TAG_STEEL_SOCKETABLE, TAG_SILVER_SOCKETABLE, TAG_ARMOR_SOCKETABLE, TAG_ABILITY_SOCKET : name;
		default TAG_STEEL_SOCKETABLE = 'SteelSocketable';							
		default TAG_SILVER_SOCKETABLE = 'SilverSocketable';							
		default TAG_ARMOR_SOCKETABLE = 'ArmorSocketable';							
		default TAG_ABILITY_SOCKET = 'Socket';										
		
	
	public const var STAMINA_COST_PARRY_ATTRIBUTE, STAMINA_COST_COUNTERATTACK_ATTRIBUTE, STAMINA_COST_EVADE_ATTRIBUTE, STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE, 
					 STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_HEAVY_ACTION_ATTRIBUTE, STAMINA_COST_LIGHT_ACTION_ATTRIBUTE, STAMINA_COST_DODGE_ATTRIBUTE,
					 STAMINA_COST_SPRINT_ATTRIBUTE, STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE, STAMINA_COST_JUMP_ATTRIBUTE, STAMINA_COST_USABLE_ITEM_ATTRIBUTE,
					 STAMINA_COST_DEFAULT, STAMINA_COST_PER_SEC_DEFAULT, STAMINA_COST_ROLL_ATTRIBUTE, STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE : name;
					 
	public const var STAMINA_DELAY_PARRY_ATTRIBUTE, STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE, STAMINA_DELAY_EVADE_ATTRIBUTE, STAMINA_DELAY_SWIMMING_ATTRIBUTE, 
					 STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE, STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE, STAMINA_DELAY_DODGE_ATTRIBUTE,
					 STAMINA_DELAY_SPRINT_ATTRIBUTE, STAMINA_DELAY_JUMP_ATTRIBUTE, STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE, STAMINA_DELAY_DEFAULT, STAMINA_DELAY_ROLL_ATTRIBUTE,
					 STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE, STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE: name;
					 
	public const var STAMINA_SEGMENT_SIZE : int;									
		
		default STAMINA_SEGMENT_SIZE = 10;
		
		default STAMINA_COST_DEFAULT = 'stamina_cost';
		default STAMINA_COST_PER_SEC_DEFAULT = 'stamina_cost_per_sec';
		default STAMINA_COST_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_cost';
		default STAMINA_COST_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_cost';
		default STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_cost';
		default STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_cost';
		default STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_cost';
		default STAMINA_COST_PARRY_ATTRIBUTE = 'parry_stamina_cost';
		default STAMINA_COST_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_cost';
		default STAMINA_COST_DODGE_ATTRIBUTE = 'dodge_stamina_cost';
		default STAMINA_COST_EVADE_ATTRIBUTE = 'evade_stamina_cost';
		default STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE = 'swimming_stamina_cost_per_sec';
		default STAMINA_COST_SPRINT_ATTRIBUTE = 'sprint_stamina_cost';
		default STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE = 'sprint_stamina_cost_per_sec';
		default STAMINA_COST_JUMP_ATTRIBUTE = 'jump_stamina_cost';
		default STAMINA_COST_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_cost';
		default STAMINA_COST_ROLL_ATTRIBUTE = 'roll_stamina_cost';
	
		default STAMINA_DELAY_DEFAULT = 'stamina_delay';
		default STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE = 'light_action_stamina_delay';
		default STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE = 'heavy_action_stamina_delay';			 
		default STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE = 'super_heavy_action_stamina_delay';
		default STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE = 'light_special_stamina_delay';
		default STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE = 'heavy_special_stamina_delay';	
		default STAMINA_DELAY_PARRY_ATTRIBUTE = 'parry_stamina_delay';
		default STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE = 'counter_stamina_delay';
		default STAMINA_DELAY_DODGE_ATTRIBUTE = 'dodge_stamina_delay';
		default STAMINA_DELAY_EVADE_ATTRIBUTE = 'evade_stamina_delay';
		default STAMINA_DELAY_SWIMMING_ATTRIBUTE = 'swimming_stamina_delay';
		default STAMINA_DELAY_SPRINT_ATTRIBUTE = 'sprint_stamina_delay';
		default STAMINA_DELAY_JUMP_ATTRIBUTE = 'jump_stamina_delay';
		default STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE = 'usable_item_stamina_delay';
		default STAMINA_DELAY_ROLL_ATTRIBUTE = 'roll_stamina_delay';

	
	public const var TOXICITY_DAMAGE_THRESHOLD : float;									
		// W3EE - Begin
		default TOXICITY_DAMAGE_THRESHOLD = 25.f;
		// W3EE - End
	
	public const var DEBUG_CHEATS_ENABLED : bool;										
	public const var SKILL_GLOBAL_PASSIVE_TAG : name;									
	public const var TAG_OPEN_FIRE : name;												
	public const var TAG_MONSTER_SKILL : name;											
	public const var TAG_EXPLODING_GAS : name;											
	public const var ON_HIT_HP_REGEN_DELAY : float;										
	public const var TAG_NPC_IN_PARTY : name;											
	public const var TAG_PLAYERS_MOUNTED_VEHICLE : name;								
	public const var TAG_SOFT_LOCK : name;												
	public const var MAX_SPELLPOWER_ASSUMED : float;									
	public const var NPC_RESIST_PER_LEVEL : float;										
	public const var XP_PER_LEVEL : int;												
	public const var XP_MINIBOSS_BONUS : float;											
	public const var XP_BOSS_BONUS : float;												
	public const var ADRENALINE_DRAIN_AFTER_COMBAT_DELAY : float;						
	public const var KEYBOARD_KEY_FONT_COLOR : string;									
	public const var MONSTER_HUNT_ACTOR_TAG : name;										
	public const var GWINT_CARD_ACHIEVEMENT_TAG : name;									
	public const var TAG_AXIIABLE, TAG_AXIIABLE_LOWER_CASE : name;						
	public const var LEVEL_DIFF_DEADLY, LEVEL_DIFF_HIGH : int;							
	public const var LEVEL_DIFF_XP_MOD : float;											
	public const var MAX_XP_MOD : float;												
	public const var DEVIL_HORSE_AURA_MIN_DELAY, DEVIL_HORSE_AURA_MAX_DELAY : int;		
	public const var TOTAL_AMOUNT_OF_BOOKS	: int;										
	public const var MAX_PLAYER_LEVEL	: int;											
	
		default DEBUG_CHEATS_ENABLED = true;
		default SKILL_GLOBAL_PASSIVE_TAG = 'GlobalPassiveBonus';
		default TAG_MONSTER_SKILL = 'MonsterSkill';
		default TAG_OPEN_FIRE = 'CarriesOpenFire';
		default TAG_EXPLODING_GAS = 'explodingGas';
		default ON_HIT_HP_REGEN_DELAY = 2;
		default TAG_NPC_IN_PARTY = 'InPlayerParty';
		default TAG_PLAYERS_MOUNTED_VEHICLE = 'PLAYER_mounted_vehicle';
		default TAG_SOFT_LOCK = 'softLock';
		default MAX_SPELLPOWER_ASSUMED = 2;
		default NPC_RESIST_PER_LEVEL = 0.016;
		default XP_PER_LEVEL = 1;
		default XP_MINIBOSS_BONUS = 1.77;
		default XP_BOSS_BONUS = 2.5;
		default ADRENALINE_DRAIN_AFTER_COMBAT_DELAY = 3;
		default KEYBOARD_KEY_FONT_COLOR = "#CD7D03";
		default MONSTER_HUNT_ACTOR_TAG = 'MonsterHuntTarget';
		default GWINT_CARD_ACHIEVEMENT_TAG = 'GwintCollectorAchievement';
		default TAG_AXIIABLE = 'Axiiable';
		default TAG_AXIIABLE_LOWER_CASE = 'axiiable';
		default LEVEL_DIFF_HIGH = 10;
		default LEVEL_DIFF_DEADLY = 20;
		default LEVEL_DIFF_XP_MOD = 0.16f;
		default MAX_XP_MOD = 1.5f;
		default DEVIL_HORSE_AURA_MIN_DELAY = 2;
		default DEVIL_HORSE_AURA_MAX_DELAY = 6;
		default TOTAL_AMOUNT_OF_BOOKS = 130;
		default MAX_PLAYER_LEVEL = 100;
		
	
	public function Init()
	{
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('global_params');
				
		
		InitForbiddenAttributesList();
		
		SetWeaponDurabilityModifiers();
		
		SetArmorDurabilityModifiers();
			
		
		InitArmorAbilities();
		InitGlovesAbilities();
		InitPantsAbilities();
		InitBootsAbilities();
		InitWeaponAbilities();
		
		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS.Resize(5);
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[0] = 70;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[1] = 50;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[2] = 0;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[3] = 0;		
		INTERACTIVE_REPAIR_OBJECT_MAX_DURS[4] = 0;		
		
		newGamePlusLevel = FactsQuerySum("FinalNewGamePlusLevel");
	}
	
	private final function SetWeaponDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsWeapon.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsWeapon.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsWeapon.PushBack(dur);
	}
	
	private final function SetArmorDurabilityModifiers()
	{
		var dur : SDurabilityThreshold;

		
		dur.difficulty = EDM_Easy;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.975;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Medium;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.95;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hard;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.925;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.85;
		durabilityThresholdsArmor.PushBack(dur);
		
		
		
		dur.difficulty = EDM_Hardcore;
		
		dur.thresholdMax = 1.25;
		dur.multiplier = 1.0;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.75;
		dur.multiplier = 0.9;
		durabilityThresholdsArmor.PushBack(dur);
		
		dur.thresholdMax = 0.5;
		dur.multiplier = 0.8;
		durabilityThresholdsArmor.PushBack(dur);
	}
	
	public final function GetWeaponDurabilityLoseValue() : float
	{
		if(theGame.GetDifficultyMode() == EDM_Hardcore)
			return DURABILITY_WEAPON_LOSE_VALUE_HARDCORE;
		else
			return DURABILITY_WEAPON_LOSE_VALUE;		
	}
	
	// W3EE - Begin
	private function InitArmorAbilities()
	{
		ARMOR_MASTERWORK_LIGHT_ABILITIES.Clear();
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.Clear();
		ARMOR_MASTERWORK_HEAVY_ABILITIES.Clear();
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.Clear();
		ARMOR_MAGICAL_MEDIUM_ABILITIES.Clear();
		ARMOR_MAGICAL_HEAVY_ABILITIES.Clear();
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_ExtraPockets');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_ExtraPockets');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_ExtraPockets');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_ThickPadding');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_ThickPadding');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_ThickPadding');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_Lightweight');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_Lightweight');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_Lightweight');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_Hefted');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_Hefted');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_Hefted');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_Warding');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_Warding');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_Warding');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_Tenacious');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_Tenacious');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_Tenacious');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_Ferocious');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_Ferocious');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_Ferocious');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_Fragrant');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_Fragrant');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_Fragrant');
		
		ARMOR_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Armor_Light_TightlyFitted');
		ARMOR_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Armor_Medium_TightlyFitted');
		ARMOR_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Armor_Heavy_TightlyFitted');
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_Stalwart');
		ARMOR_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_Stalwart');
		ARMOR_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_Stalwart');
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_Eager');
		ARMOR_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_Eager');
		ARMOR_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_Eager');
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_WellFitted');
		ARMOR_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_WellFitted');
		ARMOR_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_WellFitted');
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_WellTempered');
		ARMOR_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_WellTempered');
		ARMOR_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_WellTempered');
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_Trickster');
		ARMOR_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_Trickster');
		ARMOR_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_Trickster');
		
		ARMOR_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Armor_Light_Noble');
		ARMOR_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Armor_Medium_Noble');
		ARMOR_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Armor_Heavy_Noble');
	}
	
	private function InitGlovesAbilities()
	{
		GLOVES_MASTERWORK_LIGHT_ABILITIES.Clear();
		GLOVES_MASTERWORK_MEDIUM_ABILITIES.Clear();
		GLOVES_MASTERWORK_HEAVY_ABILITIES.Clear();
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.Clear();
		GLOVES_MAGICAL_MEDIUM_ABILITIES.Clear();
		GLOVES_MAGICAL_HEAVY_ABILITIES.Clear();
		
		GLOVES_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Gloves_Light_Warding');
		GLOVES_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Gloves_Medium_Warding');
		GLOVES_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Gloves_Heavy_Warding');
		
		GLOVES_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Gloves_Light_Tenacious');
		GLOVES_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Gloves_Medium_Tenacious');
		GLOVES_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Gloves_Heavy_Tenacious');
		
		GLOVES_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Gloves_Light_Ferocious');
		GLOVES_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Gloves_Medium_Ferocious');
		GLOVES_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Gloves_Heavy_Ferocious');
		
		GLOVES_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Gloves_Light_Fragrant');
		GLOVES_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Gloves_Medium_Fragrant');
		GLOVES_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Gloves_Heavy_Fragrant');
		
		GLOVES_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Gloves_Light_TightlyFitted');
		GLOVES_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Gloves_Medium_TightlyFitted');
		GLOVES_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Gloves_Heavy_TightlyFitted');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_Assassin');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_Assassin');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_Assassin');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_Mage');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_Mage');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_Mage');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_Swordmaster');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_Swordmaster');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_Swordmaster');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_WellFitted');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_WellFitted');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_WellFitted');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_WellTempered');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_WellTempered');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_WellTempered');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_Trickster');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_Trickster');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_Trickster');
		
		GLOVES_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Gloves_Light_Noble');
		GLOVES_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Gloves_Medium_Noble');
		GLOVES_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Gloves_Heavy_Noble');
	}
	
	private function InitPantsAbilities()
	{
		PANTS_MASTERWORK_LIGHT_ABILITIES.Clear();
		PANTS_MASTERWORK_MEDIUM_ABILITIES.Clear();
		PANTS_MASTERWORK_HEAVY_ABILITIES.Clear();
		
		PANTS_MAGICAL_LIGHT_ABILITIES.Clear();
		PANTS_MAGICAL_MEDIUM_ABILITIES.Clear();
		PANTS_MAGICAL_HEAVY_ABILITIES.Clear();
		
		PANTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Pants_Light_Warding');
		PANTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Pants_Medium_Warding');
		PANTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Pants_Heavy_Warding');
		
		PANTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Pants_Light_Tenacious');
		PANTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Pants_Medium_Tenacious');
		PANTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Pants_Heavy_Tenacious');
		
		PANTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Pants_Light_Fragrant');
		PANTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Pants_Medium_Fragrant');
		PANTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Pants_Heavy_Fragrant');
		
		PANTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Pants_Light_TightlyFitted');
		PANTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Pants_Medium_TightlyFitted');
		PANTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Pants_Heavy_TightlyFitted');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_ThickPadding');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_ThickPadding');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_ThickPadding');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_Stalwart');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_Stalwart');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_Stalwart');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_Eager');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_Eager');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_Eager');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_WellFitted');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_WellFitted');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_WellFitted');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_WellTempered');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_WellTempered');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_WellTempered');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_Trickster');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_Trickster');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_Trickster');
		
		PANTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Pants_Light_Noble');
		PANTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Pants_Medium_Noble');
		PANTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Pants_Heavy_Noble');
		
	}
	
	private function InitBootsAbilities()
	{
		BOOTS_MASTERWORK_LIGHT_ABILITIES.Clear();
		BOOTS_MASTERWORK_MEDIUM_ABILITIES.Clear();
		BOOTS_MASTERWORK_HEAVY_ABILITIES.Clear();
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.Clear();
		BOOTS_MAGICAL_MEDIUM_ABILITIES.Clear();
		BOOTS_MAGICAL_HEAVY_ABILITIES.Clear();
		
		BOOTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Boots_Light_Hefted');
		BOOTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Boots_Medium_Hefted');
		BOOTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Boots_Heavy_Hefted');
		
		BOOTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Boots_Light_Warding');
		BOOTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Boots_Medium_Warding');
		BOOTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Boots_Heavy_Warding');
		
		BOOTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Boots_Light_Fragrant');
		BOOTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Boots_Medium_Fragrant');
		BOOTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Boots_Heavy_Fragrant');
		
		BOOTS_MASTERWORK_LIGHT_ABILITIES.PushBack('Master_Boots_Light_TightlyFitted');
		BOOTS_MASTERWORK_MEDIUM_ABILITIES.PushBack('Master_Boots_Medium_TightlyFitted');
		BOOTS_MASTERWORK_HEAVY_ABILITIES.PushBack('Master_Boots_Heavy_TightlyFitted');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_Nimble');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_Nimble');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_Nimble');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_Endurance');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_Endurance');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_Endurance');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_Eager');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_Eager');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_Eager');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_WellFitted');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_WellFitted');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_WellFitted');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_WellTempered');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_WellTempered');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_WellTempered');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_Trickster');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_Trickster');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_Trickster');
		
		BOOTS_MAGICAL_LIGHT_ABILITIES.PushBack('Magical_Boots_Light_Noble');
		BOOTS_MAGICAL_MEDIUM_ABILITIES.PushBack('Magical_Boots_Medium_Noble');
		BOOTS_MAGICAL_HEAVY_ABILITIES.PushBack('Magical_Boots_Heavy_Noble');
		
	}
	
	// W3EE - Begin
	private function InitWeaponAbilities()
	{
		WEAPON_COMMON_ABILITIES.Clear();
		WEAPON_MASTERWORK_ABILITIES.Clear();
		WEAPON_MAGICAL_ABILITIES.Clear();
		
		WEAPON_COMMON_ABILITIES.PushBack('Common_PoiseDamage');
		WEAPON_COMMON_ABILITIES.PushBack('Common_ArmorPen');
		WEAPON_COMMON_ABILITIES.PushBack('Common_CounterBonus');
		WEAPON_COMMON_ABILITIES.PushBack('Common_CriticalBonus');
		
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Heft');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_CrushBlocks');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Conserve');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Needle');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Calculated');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Magical_StrongCrits');
		//WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Cavalry');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Butcher');
		WEAPON_MASTERWORK_ABILITIES.PushBack('Master_Light');
		
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Needle');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Precision');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Sting');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Celerity');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_CleanSlice');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Crush');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Spellslinger');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Cleave');
		WEAPON_MAGICAL_ABILITIES.PushBack('Magical_Ram');
	}
	
	public function GetMasterLightArmorAbilityArray() : array<name>
	{
		return ARMOR_MASTERWORK_LIGHT_ABILITIES;
	}
	
	public function GetMasterMediumArmorAbilityArray() : array<name>
	{
		return ARMOR_MASTERWORK_MEDIUM_ABILITIES;
	}
	
	public function GetMasterHeavyArmorAbilityArray() : array<name>
	{
		return ARMOR_MASTERWORK_HEAVY_ABILITIES;
	}
	
	public function GetMasterLightBootsAbilityArray() : array<name>
	{
		return BOOTS_MASTERWORK_LIGHT_ABILITIES;
	}
	
	public function GetMasterMediumBootsAbilityArray() : array<name>
	{
		return BOOTS_MASTERWORK_MEDIUM_ABILITIES;
	}
	
	public function GetMasterHeavyBootsAbilityArray() : array<name>
	{
		return BOOTS_MASTERWORK_HEAVY_ABILITIES;
	}
	
	public function GetMasterLightPantsAbilityArray() : array<name>
	{
		return PANTS_MASTERWORK_LIGHT_ABILITIES;
	}
	
	public function GetMasterMediumPantsAbilityArray() : array<name>
	{
		return PANTS_MASTERWORK_MEDIUM_ABILITIES;
	}
	
	public function GetMasterHeavyPantsAbilityArray() : array<name>
	{
		return PANTS_MASTERWORK_HEAVY_ABILITIES;
	}
	
	public function GetMasterLightGlovesAbilityArray() : array<name>
	{
		return GLOVES_MASTERWORK_LIGHT_ABILITIES;
	}
	
	public function GetMasterMediumGlovesAbilityArray() : array<name>
	{
		return GLOVES_MASTERWORK_MEDIUM_ABILITIES;
	}
	
	public function GetMasterHeavyGlovesAbilityArray() : array<name>
	{
		return GLOVES_MASTERWORK_HEAVY_ABILITIES;
	}
	
	public function GetMagicalLightArmorAbilityArray() : array<name>
	{
		return ARMOR_MAGICAL_LIGHT_ABILITIES;
	}
	
	public function GetMagicalMediumArmorAbilityArray() : array<name>
	{
		return ARMOR_MAGICAL_MEDIUM_ABILITIES;
	}
	
	public function GetMagicalHeavyArmorAbilityArray() : array<name>
	{
		return ARMOR_MAGICAL_HEAVY_ABILITIES;
	}
	
	public function GetMagicalLightBootsAbilityArray() : array<name>
	{
		return BOOTS_MAGICAL_LIGHT_ABILITIES;
	}
	
	public function GetMagicalMediumBootsAbilityArray() : array<name>
	{
		return BOOTS_MAGICAL_MEDIUM_ABILITIES;
	}
	
	public function GetMagicalHeavyBootsAbilityArray() : array<name>
	{
		return BOOTS_MAGICAL_HEAVY_ABILITIES;
	}
	
	public function GetMagicalLightPantsAbilityArray() : array<name>
	{
		return PANTS_MAGICAL_LIGHT_ABILITIES;
	}
	
	public function GetMagicalMediumPantsAbilityArray() : array<name>
	{
		return PANTS_MAGICAL_MEDIUM_ABILITIES;
	}
	
	public function GetMagicalHeavyPantsAbilityArray() : array<name>
	{
		return PANTS_MAGICAL_HEAVY_ABILITIES;
	}
	
	public function GetMagicalLightGlovesAbilityArray() : array<name>
	{
		return GLOVES_MAGICAL_LIGHT_ABILITIES;
	}
	
	public function GetMagicalMediumGlovesAbilityArray() : array<name>
	{
		return GLOVES_MAGICAL_MEDIUM_ABILITIES;
	}
	
	public function GetMagicalHeavyGlovesAbilityArray() : array<name>
	{
		return GLOVES_MAGICAL_HEAVY_ABILITIES;
	}
	
	public function GetCommonWeaponAbilityArray() : array<name>
	{
		return WEAPON_COMMON_ABILITIES;
	}
	
	public function GetMasterworkWeaponAbilityArray() : array<name>
	{
		return WEAPON_MASTERWORK_ABILITIES;
	}
	
	public function GetMagicalWeaponAbilityArray() : array<name>
	{
		return WEAPON_MAGICAL_ABILITIES;
	}
	// W3EE - End

	
	private function InitForbiddenAttributesList()
	{
		var i,size : int;
	
		size = EnumGetMax('EBaseCharacterStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(StatEnumToName(i));
			
		size = EnumGetMax('ECharacterDefenseStats')+1;
		for(i=0; i<size; i+=1)
		{
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, true));
			forbiddenAttributes.PushBack(ResistStatEnumToName(i, false));
		}
			
		size = EnumGetMax('ECharacterPowerStats')+1;
		for(i=0; i<size; i+=1)
			forbiddenAttributes.PushBack(PowerStatEnumToName(i));
	}
	
	public function IsForbiddenAttribute(nam : name) : bool
	{
		if(!IsNameValid(nam))
			return true;
		
		return forbiddenAttributes.Contains(nam);
	}
	
	
	public function GetDurabilityMultiplier(durabilityRatio : float, isWeapon : bool) : float
	{
		// W3EE - Begin
		var currDiff : EDifficultyMode;
		
		currDiff = theGame.GetDifficultyMode();
		
		switch( currDiff )
		{
			case EDM_Easy:
				return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.8f, 1.0f);
			case EDM_Medium:
				return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.7f, 1.0f);
			case EDM_Hard:
				return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.6f, 1.0f);
			case EDM_Hardcore:
				return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.5f, 1.0f);
			default:
				return 1.0f;
		}
		// W3EE - End
	}
	
	private function GetDurMult(durabilityRatio : float, durs : array<SDurabilityThreshold>) : float
	{
		var i : int;
		var currDiff : EDifficultyMode;
	
		currDiff = theGame.GetDifficultyMode();
		
		for(i=durs.Size()-1; i>=0; i-=1)
		{
			if(durs[i].difficulty == currDiff)			
				if(durabilityRatio <= durs[i].thresholdMax)
					return durs[i].multiplier;
		}
		
		return durs[0].multiplier;
	}
	
	
	// W3EE - Begin
	public function GetRandomMasterworkLightArmorAbility() : name
	{
		return ARMOR_MASTERWORK_LIGHT_ABILITIES[RandRange(ARMOR_MASTERWORK_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkMediumArmorAbility() : name
	{
		return ARMOR_MASTERWORK_MEDIUM_ABILITIES[RandRange(ARMOR_MASTERWORK_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkHeavyArmorAbility() : name
	{
		return ARMOR_MASTERWORK_HEAVY_ABILITIES[RandRange(ARMOR_MASTERWORK_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalLightArmorAbility() : name
	{
		return ARMOR_MAGICAL_LIGHT_ABILITIES[RandRange(ARMOR_MAGICAL_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalMediumArmorAbility() : name
	{
		return ARMOR_MAGICAL_MEDIUM_ABILITIES[RandRange(ARMOR_MAGICAL_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalHeavyArmorAbility() : name
	{
		return ARMOR_MAGICAL_HEAVY_ABILITIES[RandRange(ARMOR_MAGICAL_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkLightGlovesAbility() : name
	{
		return GLOVES_MASTERWORK_LIGHT_ABILITIES[RandRange(GLOVES_MASTERWORK_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkMediumGlovesAbility() : name
	{
		return GLOVES_MASTERWORK_MEDIUM_ABILITIES[RandRange(GLOVES_MASTERWORK_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkHeavyGlovesAbility() : name
	{
		return GLOVES_MASTERWORK_HEAVY_ABILITIES[RandRange(GLOVES_MASTERWORK_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalLightGlovesAbility() : name
	{
		return GLOVES_MAGICAL_LIGHT_ABILITIES[RandRange(GLOVES_MAGICAL_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalMediumGlovesAbility() : name
	{
		return GLOVES_MAGICAL_MEDIUM_ABILITIES[RandRange(GLOVES_MAGICAL_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalHeavyGlovesAbility() : name
	{
		return GLOVES_MAGICAL_HEAVY_ABILITIES[RandRange(GLOVES_MAGICAL_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkLightPantsAbility() : name
	{
		return PANTS_MASTERWORK_LIGHT_ABILITIES[RandRange(PANTS_MASTERWORK_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkMediumPantsAbility() : name
	{
		return PANTS_MASTERWORK_MEDIUM_ABILITIES[RandRange(PANTS_MASTERWORK_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkHeavyPantsAbility() : name
	{
		return PANTS_MASTERWORK_HEAVY_ABILITIES[RandRange(PANTS_MASTERWORK_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalLightPantsAbility() : name
	{
		return PANTS_MAGICAL_LIGHT_ABILITIES[RandRange(PANTS_MAGICAL_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalMediumPantsAbility() : name
	{
		return PANTS_MAGICAL_MEDIUM_ABILITIES[RandRange(PANTS_MAGICAL_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalHeavyPantsAbility() : name
	{
		return PANTS_MAGICAL_HEAVY_ABILITIES[RandRange(PANTS_MAGICAL_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkLightBootsAbility() : name
	{
		return BOOTS_MASTERWORK_LIGHT_ABILITIES[RandRange(BOOTS_MASTERWORK_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkMediumBootsAbility() : name
	{
		return BOOTS_MASTERWORK_MEDIUM_ABILITIES[RandRange(BOOTS_MASTERWORK_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkHeavyBootsAbility() : name
	{
		return BOOTS_MASTERWORK_HEAVY_ABILITIES[RandRange(BOOTS_MASTERWORK_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalLightBootsAbility() : name
	{
		return BOOTS_MAGICAL_LIGHT_ABILITIES[RandRange(BOOTS_MAGICAL_LIGHT_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalMediumBootsAbility() : name
	{
		return BOOTS_MAGICAL_MEDIUM_ABILITIES[RandRange(BOOTS_MAGICAL_MEDIUM_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalHeavyBootsAbility() : name
	{
		return BOOTS_MAGICAL_HEAVY_ABILITIES[RandRange(BOOTS_MAGICAL_HEAVY_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMasterworkWeaponAbility() : name
	{
		return WEAPON_MASTERWORK_ABILITIES[RandRange(WEAPON_MASTERWORK_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomMagicalWeaponAbility() : name
	{
		return WEAPON_MAGICAL_ABILITIES[RandRange(WEAPON_MAGICAL_ABILITIES.Size() - 1)];
	}
	
	public function GetRandomCommonWeaponAbility() : name
	{
		return WEAPON_COMMON_ABILITIES[RandRange(WEAPON_COMMON_ABILITIES.Size() - 1)];
	}
	// W3EE - End
	
	public function GetStaminaActionAttributes(action : EStaminaActionType, getCostPerSec : bool, out costAttributeName : name, out delayAttributeName : name)
	{		
		switch(action)
		{
			case ESAT_LightAttack :
				costAttributeName = STAMINA_COST_LIGHT_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_ACTION_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_SuperHeavyAttack :
				costAttributeName = STAMINA_COST_SUPER_HEAVY_ACTION_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_SUPER_HEAVY_ACTION_ATTRIBUTE;
				return;
			case ESAT_LightSpecial :
				costAttributeName = STAMINA_COST_LIGHT_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_LIGHT_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_HeavyAttack :
				costAttributeName = STAMINA_COST_HEAVY_SPECIAL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_HEAVY_SPECIAL_ATTRIBUTE;
				return;
			case ESAT_Parry :
				costAttributeName = STAMINA_COST_PARRY_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_PARRY_ATTRIBUTE;
				return;
			case ESAT_Counterattack :
				costAttributeName = STAMINA_COST_COUNTERATTACK_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_COUNTERATTACK_ATTRIBUTE;
				return;
			case ESAT_Dodge :
				costAttributeName = STAMINA_COST_DODGE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_DODGE_ATTRIBUTE;
				return;
			case ESAT_Roll :
				costAttributeName = STAMINA_COST_ROLL_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_ROLL_ATTRIBUTE;
				return;
			case ESAT_Evade :
				costAttributeName = STAMINA_COST_EVADE_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_EVADE_ATTRIBUTE;
				return;
			case ESAT_Swimming :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SWIMMING_PER_SEC_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SWIMMING_ATTRIBUTE;
				return;
			case ESAT_Sprint :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_SPRINT_PER_SEC_ATTRIBUTE;
				}
				else
				{
					costAttributeName = STAMINA_COST_SPRINT_ATTRIBUTE;
				}
				delayAttributeName = STAMINA_DELAY_SPRINT_ATTRIBUTE;
				return;
			case ESAT_Jump :
				costAttributeName = STAMINA_COST_JUMP_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_JUMP_ATTRIBUTE;
				return;
			case ESAT_UsableItem :
				costAttributeName = STAMINA_COST_USABLE_ITEM_ATTRIBUTE;
				delayAttributeName = STAMINA_DELAY_USABLE_ITEM_ATTRIBUTE;
				return;
			case ESAT_Ability :
				if(getCostPerSec)
				{
					costAttributeName = STAMINA_COST_PER_SEC_DEFAULT;
				}
				else
				{
					costAttributeName = STAMINA_COST_DEFAULT;
				}
				delayAttributeName = STAMINA_DELAY_DEFAULT;
				return;
			default :
				LogAssert(false, "W3GameParams.GetStaminaActionAttributes : unknown stamina action type <<" + action + ">> !!");
				return;
		}		
	}	
	    
  	public function GetItemLevel(itemCategory : name, itemAttributes : array<SAbilityAttributeValue>, optional itemName : name, optional out baseItemLevel : int) : int
	{
		var stat : SAbilityAttributeValue;
		var stat_f : float;
		var stat1,stat2,stat3,stat4,stat5,stat6,stat7 : SAbilityAttributeValue;
		var stat_min, stat_add : float;
		var level : int;
	
		if ( itemCategory == 'armor' )
		{
				stat_min = 25;
				stat_add = 5;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'boots' )
		{
				stat_min = 5;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'gloves' )
		{
				stat_min = 1;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'pants' )
		{
				stat_min = 5;
				stat_add = 2;
			stat = itemAttributes[0];
			level = FloorF( 1 + ( stat.valueBase - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'silversword' )
		{
				stat_min = 90;
				stat_add = 10;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'steelsword' )
		{
				stat_min = 25;
				stat_add = 8;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat7 = itemAttributes[6];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1) + (stat7.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
		} else
		if ( itemCategory == 'bolt' )
		{
			if ( itemName == 'Tracking Bolt' ) { level = 2; } else
			if ( itemName == 'Bait Bolt' ) { level = 2; }  else
			if ( itemName == 'Blunt Bolt' ) { level = 2; }  else
			if ( itemName == 'Broadhead Bolt' ) { level = 10; }  else
			if ( itemName == 'Target Point Bolt' ) { level = 5; }  else
			if ( itemName == 'Split Bolt' ) { level = 15; }  else
			if ( itemName == 'Explosive Bolt' ) { level = 20; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 5; }  else
			if ( itemName == 'Broadhead Bolt Legendary' ) { level = 20; }  else
			if ( itemName == 'Target Point Bolt Legendary' ) { level = 15; }  else
			if ( itemName == 'Blunt Bolt Legendary' ) { level = 12; }  else
			if ( itemName == 'Split Bolt Legendary' ) { level = 24; }  else
			if ( itemName == 'Explosive Bolt Legendary' ) { level = 26; } 
		} else
		if ( itemCategory == 'crossbow' )
		{
			// W3EE - Begin
			/*
			stat = itemAttributes[0];
			level = 1;
			if ( stat.valueMultiplicative > 1.01 ) level = 2;
			if ( stat.valueMultiplicative > 1.1 ) level = 4;
			if ( stat.valueMultiplicative > 1.2 ) level = 8;
			if ( stat.valueMultiplicative > 1.3 ) level = 11;
			if ( stat.valueMultiplicative > 1.4 ) level = 15;
			if ( stat.valueMultiplicative > 1.5 ) level = 19;
			if ( stat.valueMultiplicative > 1.6 ) level = 22;
			if ( stat.valueMultiplicative > 1.7 ) level = 25;
			if ( stat.valueMultiplicative > 1.8 ) level = 27;
			if ( stat.valueMultiplicative > 1.9 ) level = 32;
			*/
			
			stat_min = 25;
			stat_add = 8;
			stat1 = itemAttributes[0];
			stat2 = itemAttributes[1];
			stat3 = itemAttributes[2];
			stat4 = itemAttributes[3];
			stat5 = itemAttributes[4];
			stat6 = itemAttributes[5];
			stat7 = itemAttributes[6];
			stat_f = (stat1.valueBase - 1) + (stat2.valueBase - 1) + (stat3.valueBase - 1) + (stat4.valueBase - 1) + (stat5.valueBase - 1) + (stat6.valueBase - 1) + (stat7.valueBase - 1);
			level = CeilF( 1 + ( 1 + stat_f - stat_min ) / stat_add );
			// W3EE - Begin
		} 
		level = level - 1;
		if ( level < 1 ) level = 1;	
		baseItemLevel = level;
		if ( level > GetWitcherPlayer().GetMaxLevel() ) level = GetWitcherPlayer().GetMaxLevel();
		
		return level;
	}
	
	public final function SetNewGamePlusLevel(playerLevel : int)
	{
		if ( playerLevel > NEW_GAME_PLUS_MIN_LEVEL )
		{
			newGamePlusLevel = playerLevel;
		}
		else
		{
			newGamePlusLevel = NEW_GAME_PLUS_MIN_LEVEL;
		}
			
		FactsAdd("FinalNewGamePlusLevel", newGamePlusLevel);
	}
	
	public final function GetNewGamePlusLevel() : int
	{
		return newGamePlusLevel;
	}
	public final function NewGamePlusLevelDifference() : int
	{
		return ( theGame.params.GetNewGamePlusLevel() - theGame.params.NEW_GAME_PLUS_MIN_LEVEL );
	}
	public final function GetPlayerMaxLevel() : int
	{
		return MAX_PLAYER_LEVEL;
	}
}
