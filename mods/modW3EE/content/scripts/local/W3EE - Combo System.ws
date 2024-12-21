struct SAttackAnimation
{
	var animName : name;
	var isStanceSwitched : bool;
	var stance, linkedAnimIndex : int;
}

struct SDividerInfo
{
	var dividerName : name;
	var dividerIndex : int;
}

class W3EEComboSystemExtender
{
	protected var fastAttacks, strongAttacks, fastAttacksFist, strongAttacksFist : array<SAttackAnimation>;
	protected var secondaryAttacks, fastBattleAxeAttacks, strongBattleAxeAttacks : array<SAttackAnimation>;
	protected var shieldFastAttacks : array<SAttackAnimation>;
	protected var dividerArray : array<SDividerInfo>;
	private var isActive : bool;
	
	default isActive = true;
	
	public function GetIsActive() : bool
	{
		return isActive;
	}
	
	public function SetIsActive( b : bool )
	{
		isActive = b;
	}
	
	public function Init()
	{
		var animArray : array<SAttackAnimation>;
		
		// ----- Light Attacks ----- //
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_5_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_rp_40ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_6_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_rp_40ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_rp_40ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_5_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_6_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_5_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_rp_40ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_6_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_rp_40ms', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_3_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_5_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_3_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_5_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_3_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_lp_40ms', false, 0, -1));
		CreateComboArray(animArray, fastAttacks);
		
		CreateLink(0, 13, fastAttacks);
		CreateLink(1, 14, fastAttacks);
		CreateLink(2, 15, fastAttacks);
		CreateLink(3, 16, fastAttacks);
		CreateLink(4, 17, fastAttacks);
		CreateLink(5, 18, fastAttacks);
		CreateLink(6, 19, fastAttacks);
		CreateLink(7, 20, fastAttacks);
		CreateLink(8, 21, fastAttacks);
		CreateLink(9, 22, fastAttacks);
		CreateLink(10, 23, fastAttacks);
		CreateLink(11, 24, fastAttacks);
		CreateLink(12, 25, fastAttacks);
		
		CreateLink(13, 1, fastAttacks);
		CreateLink(14, 2, fastAttacks);
		CreateLink(15, 3, fastAttacks);
		CreateLink(16, 4, fastAttacks);
		CreateLink(17, 5, fastAttacks);
		CreateLink(18, 6, fastAttacks);
		CreateLink(19, 7, fastAttacks);
		CreateLink(20, 8, fastAttacks);
		CreateLink(21, 9, fastAttacks);
		CreateLink(22, 10, fastAttacks);
		CreateLink(23, 11, fastAttacks);
		CreateLink(24, 12, fastAttacks);
		CreateLink(25, 0, fastAttacks);
		
		animArray.Clear();
		
		// ----- Strong Attacks ----- //
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_5_rp', true, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_1_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_4_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_2_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_3_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_5_rp', true, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_3_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_4_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_1_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_5_rp', true, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_4_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_2_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_3_rp_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_4_rp_70ms', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_3_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_2_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_10_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_1_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_3_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_3_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_2_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_10_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_3_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_3_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_1_lp_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_strong_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_strong_3_lp_70ms', false, 0, -1));
		CreateComboArray(animArray, strongAttacks);
		
		CreateLink(0, 15, strongAttacks);
		CreateLink(1, 16, strongAttacks);
		CreateLink(2, 17, strongAttacks);
		CreateLink(3, 18, strongAttacks);
		CreateLink(4, 19, strongAttacks);
		CreateLink(5, 20, strongAttacks);
		CreateLink(6, 21, strongAttacks);
		CreateLink(7, 22, strongAttacks);
		CreateLink(8, 23, strongAttacks);
		CreateLink(9, 24, strongAttacks);
		CreateLink(10, 25, strongAttacks);
		CreateLink(11, 26, strongAttacks);
		CreateLink(12, 27, strongAttacks);
		CreateLink(13, 28, strongAttacks);
		CreateLink(14, 29, strongAttacks);
		
		CreateLink(15, 1, strongAttacks);
		CreateLink(16, 2, strongAttacks);
		CreateLink(17, 3, strongAttacks);
		CreateLink(18, 4, strongAttacks);
		CreateLink(19, 5, strongAttacks);
		CreateLink(20, 6, strongAttacks);
		CreateLink(21, 7, strongAttacks);
		CreateLink(22, 8, strongAttacks);
		CreateLink(23, 9, strongAttacks);
		CreateLink(24, 10, strongAttacks);
		CreateLink(25, 11, strongAttacks);
		CreateLink(26, 12, strongAttacks);
		CreateLink(27, 13, strongAttacks);
		CreateLink(28, 14, strongAttacks);
		CreateLink(29, 0, strongAttacks);
		
		animArray.Clear();
		
		// ----- Fast Fist Attacks ----- //
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_5', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_2', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_5', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_2', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_4', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_1', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_6', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_close_combo_attack_3', false, 0, -1));
		CreateComboArray(animArray, fastAttacksFist);
		
		CreateLink(0, 4, fastAttacksFist);
		CreateLink(1, 5, fastAttacksFist);
		CreateLink(2, 6, fastAttacksFist);
		CreateLink(3, 7, fastAttacksFist);
		
		CreateLink(4, 1, fastAttacksFist);
		CreateLink(5, 2, fastAttacksFist);
		CreateLink(6, 3, fastAttacksFist);
		CreateLink(7, 0, fastAttacksFist);
		
		animArray.Clear();
		
		// ----- Strong Fist Attacks ----- //
		animArray.PushBack((SAttackAnimation)('man_fistfight_attack_heavy_2_rh_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_attack_heavy_1_rh_70ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_attack_heavy_2_rh_70ms', false, 0, -1));
		
		animArray.PushBack((SAttackAnimation)('man_fistfight_attack_heavy_1_lh_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_attack_heavy_4_ll_70ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_fistfight_attack_heavy_2_lh_70ms', false, 1, -1));
		CreateComboArray(animArray, strongAttacksFist);
		
		CreateLink(0, 3, strongAttacksFist);
		CreateLink(1, 4, strongAttacksFist);
		CreateLink(2, 5, strongAttacksFist);
		
		CreateLink(3, 1, strongAttacksFist);
		CreateLink(4, 2, strongAttacksFist);
		CreateLink(5, 0, strongAttacksFist);
		
		animArray.Clear();
		
		// ----- Secondary Weapon Attacks ----- //
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_1_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_2_rp', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_1_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_2_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_3_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_1_lp', false, 0, -1));
		CreateComboArray(animArray, secondaryAttacks);
		
		CreateLink(0, 2, secondaryAttacks);
		CreateLink(1, 3, secondaryAttacks);
		
		CreateLink(2, 1, secondaryAttacks);
		CreateLink(3, 4, secondaryAttacks);
		CreateLink(4, 5, secondaryAttacks);
		CreateLink(5, 0, secondaryAttacks);
		
		animArray.Clear();
		
		// ----- Fast Battle Axe Attacks ----- //
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_3_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_1_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_2_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_3_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_2_rp', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_3_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_4_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_1_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_5_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_fast_1_lp', false, 0, -1));
		CreateComboArray(animArray, fastBattleAxeAttacks);
		
		CreateLink(0, 7, fastBattleAxeAttacks);
		CreateLink(1, 8, fastBattleAxeAttacks);
		CreateLink(2, 9, fastBattleAxeAttacks);
		CreateLink(3, 10, fastBattleAxeAttacks);
		CreateLink(4, 11, fastBattleAxeAttacks);
		CreateLink(5, 12, fastBattleAxeAttacks);
		CreateLink(6, 13, fastBattleAxeAttacks);
		
		CreateLink(7, 1, fastBattleAxeAttacks);
		CreateLink(8, 2, fastBattleAxeAttacks);
		CreateLink(9, 3, fastBattleAxeAttacks);
		CreateLink(10, 4, fastBattleAxeAttacks);
		CreateLink(11, 5, fastBattleAxeAttacks);
		CreateLink(12, 6, fastBattleAxeAttacks);
		CreateLink(13, 0, fastBattleAxeAttacks);
		
		animArray.Clear();
		
		// ----- Strong Battle Axe Attacks ----- //
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_1_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_3_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_1_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_3_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_3_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_3_rp', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_1_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_5_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_1_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_1_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_4_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_3_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_1_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_5_lp', true, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_2_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_axe_strong_3_lp', true, 0, -1));
		CreateComboArray(animArray, strongBattleAxeAttacks);
		
		CreateLink(0, 14, strongBattleAxeAttacks);
		CreateLink(1, 15, strongBattleAxeAttacks);
		CreateLink(2, 16, strongBattleAxeAttacks);
		CreateLink(3, 17, strongBattleAxeAttacks);
		CreateLink(4, 18, strongBattleAxeAttacks);
		CreateLink(5, 19, strongBattleAxeAttacks);
		CreateLink(6, 20, strongBattleAxeAttacks);
		CreateLink(7, 21, strongBattleAxeAttacks);
		CreateLink(8, 22, strongBattleAxeAttacks);
		CreateLink(9, 23, strongBattleAxeAttacks);
		CreateLink(10, 24, strongBattleAxeAttacks);
		CreateLink(11, 25, strongBattleAxeAttacks);
		CreateLink(12, 26, strongBattleAxeAttacks);
		CreateLink(13, 27, strongBattleAxeAttacks);
		
		CreateLink(14, 1, strongBattleAxeAttacks);
		CreateLink(15, 2, strongBattleAxeAttacks);
		CreateLink(16, 3, strongBattleAxeAttacks);
		CreateLink(17, 4, strongBattleAxeAttacks);
		CreateLink(18, 5, strongBattleAxeAttacks);
		CreateLink(19, 6, strongBattleAxeAttacks);
		CreateLink(20, 7, strongBattleAxeAttacks);
		CreateLink(21, 8, strongBattleAxeAttacks);
		CreateLink(22, 9, strongBattleAxeAttacks);
		CreateLink(23, 10, strongBattleAxeAttacks);
		CreateLink(24, 11, strongBattleAxeAttacks);
		CreateLink(25, 12, strongBattleAxeAttacks);
		CreateLink(26, 13, strongBattleAxeAttacks);
		CreateLink(27, 0, strongBattleAxeAttacks);
		
		animArray.Clear();
		
		// ----- Light Shielded Attacks ----- //
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_2_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_6_rp', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_rp_40ms', false, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_3_rp', true, 1, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_5_rp', false, 1, -1));
		
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_1_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_3_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('man_geralt_sword_attack_fast_2_lp_40ms', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_sec_fast_3_lp', false, 0, -1));
		animArray.PushBack((SAttackAnimation)('geralt_attack_fast_2_lp', false, 0, -1));
		CreateComboArray(animArray, shieldFastAttacks);
		
		CreateLink(0, 5, shieldFastAttacks);
		CreateLink(1, 6, shieldFastAttacks);
		CreateLink(2, 7, shieldFastAttacks);
		CreateLink(3, 8, shieldFastAttacks);
		CreateLink(4, 9, shieldFastAttacks);
		
		CreateLink(5, 1, shieldFastAttacks);
		CreateLink(6, 2, shieldFastAttacks);
		CreateLink(7, 3, shieldFastAttacks);
		CreateLink(8, 4, shieldFastAttacks);
		CreateLink(9, 0, shieldFastAttacks);
		
		animArray.Clear();
	}
	
	protected var isStanceSwitched : bool; default isStanceSwitched = false;
	public function SetStanceSwitched( b : bool )
	{
		isStanceSwitched = b;
	}
	
	private var currIdx : int;
	protected function ChooseAttack( out currAttack : SAttackAnimation, arrayIndex : int )
	{
		var stance : float = thePlayer.GetCombatIdleStance();
		var arrayHandle : array<SAttackAnimation>;
		
		switch(arrayIndex)
		{
			case 1:	arrayHandle = fastAttacks;		 		break;
			case 2:	arrayHandle = strongAttacks;	 		break;
			case 3:	arrayHandle = fastAttacksFist;	 		break;
			case 4:	arrayHandle = strongAttacksFist;		break;
			case 5:	arrayHandle = secondaryAttacks;			break;
			case 6:	arrayHandle = fastBattleAxeAttacks;		break;
			case 7:	arrayHandle = strongBattleAxeAttacks;	break;
			case 8:	arrayHandle = shieldFastAttacks;		break;
		}
		
		if( isStanceSwitched )
		{
			if( stance == 1 )
				stance = 0;
			else
				stance = 1;
		}
		
		if( IsValidAttack(currAttack) && HasLink(currAttack) )
		{
			currIdx = currAttack.linkedAnimIndex;
			currAttack = arrayHandle[currAttack.linkedAnimIndex];
			if( currAttack.stance != stance && arrayIndex != 4 )
			{
				currIdx = currAttack.linkedAnimIndex;
				currAttack = arrayHandle[currAttack.linkedAnimIndex];
			}
		}
		else currAttack = arrayHandle[RandRange(arrayHandle.Size(), 0)];
		isStanceSwitched = currAttack.isStanceSwitched;
		
		// theGame.GetGuiManager().ShowNotification("Current Index:" + IntToString(currIdx) + "<br>Link Index:" + IntToString(currAttack.linkedAnimIndex) + "<br>" + NameToString(currAttack.animName));
	}
	
	protected function ResetAttack( out attack : SAttackAnimation )
	{
		attack.animName = '';
		attack.linkedAnimIndex = -1;
	}
	
	private function IsValidAttack( attack : SAttackAnimation ) : bool
	{
		return attack.animName != '';
	}
	
	private function HasLink( attack : SAttackAnimation ) : bool
	{
		return attack.linkedAnimIndex > -1;
	}
	
	private function CreateComboArray( animArray : array<SAttackAnimation>, out arrayHandle : array<SAttackAnimation> )
	{
		var attackAnim : SAttackAnimation;
		var i : int;
		
		for(i=0; i<animArray.Size(); i+=1)
		{
			attackAnim.animName = animArray[i].animName;
			attackAnim.isStanceSwitched = animArray[i].isStanceSwitched;
			attackAnim.stance = animArray[i].stance;
			attackAnim.linkedAnimIndex = -1;
			arrayHandle.PushBack(attackAnim);
		}
	}
	
	private function CreateLink( animIndex1, animIndex2 : int, out arrayHandle : array<SAttackAnimation> )
	{
		arrayHandle[animIndex1].linkedAnimIndex = animIndex2;
	}
}

class W3EEComboDefinition extends W3EEComboSystemExtender
{
	protected var currentLightAttack : SAttackAnimation;
	protected var currentHeavyAttack : SAttackAnimation;
	protected var currentLightAttackFist : SAttackAnimation;
	protected var currentHeavyAttackFist : SAttackAnimation;
	protected var currentSecondaryAttack : SAttackAnimation;
	protected var currentLightBattleAxeAttack : SAttackAnimation;
	protected var currentHeavyBattleAxeAttack : SAttackAnimation;
	protected var currentLightShieldAttack : SAttackAnimation;
	protected var currentHeavyShieldAttack : SAttackAnimation;
	protected var comboDefinition : CComboDefinition;
	
	public function Init()
	{
		super.Init();
		super.SetIsActive(Options().GetUseCombatAnimations());
		comboDefinition = new CComboDefinition in this;
	}
	
	public function GetComboDefinition() : CComboDefinition
	{
		return comboDefinition;
	}
	
	public function SetStanceSwitched( b : bool )
	{
		super.SetStanceSwitched(b); 
	}
	
	public function ShouldSwitchIdleAnim( wasLightAttack : bool ) : bool
	{
		if( wasLightAttack )
		{
			switch(currentLightAttack.animName)
			{
				case 'geralt_attack_fast_4_rp':
				case 'geralt_attack_fast_5_rp':
				case 'geralt_attack_fast_6_rp':
				case 'geralt_attack_fast_5_lp':
				case 'geralt_attack_fast_6_lp':
				case 'geralt_sec_fast_3_rp':
				case 'geralt_sec_fast_3_lp':
					return true;
				
				default : return false;
			}
		}
		
		return false;
	}
	
	private function CreateRealisticAttackAspectLight()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		ChooseAttack(currentLightAttack, 1);
		
		aspect = comboDefinition.CreateComboAspect('AttackLightReal');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentLightAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_rp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Right, ADIST_Small );			
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms_mod', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms_mod', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms_mod', AD_Right, ADIST_Large );
			
			str.AddAttack( currentLightAttack.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentLightAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_lp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms', AD_Right, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms_mod', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms_mod', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms_mod', AD_Right, ADIST_Large );
			
			str.AddAttack( currentLightAttack.animName, ADIST_Small );
		}
	}
	
	private function CreateRealisticAttackAspectHeavy()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		ChooseAttack(currentHeavyAttack, 2);
		
		aspect = comboDefinition.CreateComboAspect('AttackHeavyReal');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentHeavyAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_10_rp_70ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_rp_70ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_left_1_rp_80ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_back_1_rp_80ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_rp_80ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_right_1_rp_80ms', AD_Right, ADIST_Medium );			
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_left_1_rp_80ms_mod', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_back_1_rp_80ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_rp_80ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_right_1_rp_80ms_mod', AD_Right, ADIST_Large );			
			
			str.AddAttack( currentHeavyAttack.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentHeavyAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_8_lp_70ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_left_1_lp_70ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_right_1_lp_70ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_back_1_lp_80ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_left_1_lp_80ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_right_1_lp_80ms', AD_Right, ADIST_Medium );			
			
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_forward_1_lp_80ms_mod', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_back_1_lp_80ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_left_1_lp_80ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_strong_far_right_1_lp_80ms_mod', AD_Right, ADIST_Large );			
			
			str.AddAttack( currentHeavyAttack.animName, ADIST_Small );
		}
	}
	
	private function CreateRealisticAttackAspectFistLight()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		ChooseAttack(currentLightAttackFist, 3);
		
		aspect = comboDefinition.CreateComboAspect('AttackFistFast');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentLightAttackFist.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_2_rh_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_back_1_rh_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_left_1_rh_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_right_1_rh_50ms', AD_Right, ADIST_Medium );			
			
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_back_1_rh_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_left_1_rh_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_right_1_rh_50ms', AD_Right, ADIST_Large );			
			
			str.AddAttack( currentLightAttackFist.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentLightAttackFist.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_2_rh_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_left_1_rh_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_fast_right_1_rh_40ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_back_1_rh_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_left_1_rh_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_right_1_rh_50ms', AD_Right, ADIST_Medium );			
			
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_2_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_forward_1_rh_50ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_back_1_rh_50ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_left_1_rh_50ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_fast_far_right_1_rh_50ms', AD_Right, ADIST_Large );			
			
			str.AddAttack( currentLightAttackFist.animName, ADIST_Small );
		}
	}
	
	private function CreateRealisticAttackAspectFistHeavy()
	{
		var aspect : CComboAspect;
		var str : CComboString;
		
		ChooseAttack(currentHeavyAttackFist, 4);
		
		aspect = comboDefinition.CreateComboAspect('AttackFistHeavy');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentHeavyAttackFist.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_back_1_rh_80ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_left_1_rh_80ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_right_1_rh_80ms', AD_Right, ADIST_Medium );		
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_back_1_rh_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_left_1_rh_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_right_1_rh_80ms', AD_Right, ADIST_Large );		
			
			str.AddAttack( currentHeavyAttackFist.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentHeavyAttackFist.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_back_1_rh_70ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_left_1_rh_70ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_fistfight_attack_heavy_right_1_lh_70ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_back_1_rh_80ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_left_1_rh_80ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_right_1_rh_80ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_1_rh_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_2_ll_80ms', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_back_1_rh_80ms', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_left_1_rh_80ms', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_fistfight_attack_heavy_far_right_1_rh_80ms', AD_Right, ADIST_Large );
			
			str.AddAttack( currentHeavyAttackFist.animName, ADIST_Small );
		}
	}
	
	private function CreateAttackAspectSecondaryLight()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		ChooseAttack(currentSecondaryAttack, 5);
		
		aspect = comboDefinition.CreateComboAspect('AttackLightSecondary');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentSecondaryAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_1_rp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_rp_40ms', AD_Right, ADIST_Small );
			
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms', AD_Right, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_rp_50ms_mod', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_3_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_forward_1_rp_50ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_rp_50ms_mod', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_rp_50ms_mod', AD_Right, ADIST_Large );
			
			str.AddAttack( currentSecondaryAttack.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentSecondaryAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_2_lp_40ms', AD_Left, ADIST_Small );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_right_1_lp_40ms', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_lp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_lp_50ms', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms', AD_Right, ADIST_Medium );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms_mod', AD_Front, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_1_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_back_2_rp_50ms_mod', AD_Back, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_2_lp_50ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_left_1_lp_50ms_mod', AD_Left, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_2_lp_50ms_mod', AD_Right, ADIST_Large );
			str.AddDirAttack( 'man_geralt_sword_attack_fast_far_right_1_lp_50ms_mod', AD_Right, ADIST_Large );
			
			str.AddAttack( currentSecondaryAttack.animName, ADIST_Small );
		}
	}
	
	private function CreateAttackAspectFastBattleAxe()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		ChooseAttack(currentLightBattleAxeAttack, 6);
		
		aspect = comboDefinition.CreateComboAspect('AttackBattleAxeFast');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentLightBattleAxeAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'geralt_axe_fast_3_rp', AD_Back, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_fast_2_rp', AD_Left, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_fast_1_rp', AD_Right, ADIST_Small );
			
			str.AddAttack( currentLightBattleAxeAttack.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentLightBattleAxeAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'geralt_axe_fast_3_rp', AD_Back, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_fast_4_lp', AD_Left, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_fast_2_lp', AD_Right, ADIST_Small );
			
			str.AddAttack( currentLightBattleAxeAttack.animName, ADIST_Small );
		}
	}
	
	private function CreateAttackAspectHeavyBattleAxe()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		ChooseAttack(currentHeavyBattleAxeAttack, 7);
		
		aspect = comboDefinition.CreateComboAspect('AttackBattleAxeHeavy');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentHeavyBattleAxeAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'geralt_axe_strong_4_rp', AD_Back, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_strong_1_rp', AD_Left, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_strong_2_rp', AD_Right, ADIST_Small );
			
			str.AddAttack( currentHeavyBattleAxeAttack.animName, ADIST_Small );
		}
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentHeavyBattleAxeAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'geralt_axe_strong_4_rp', AD_Back, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_strong_2_lp', AD_Left, ADIST_Small );
			str.AddDirAttack( 'geralt_axe_strong_4_lp', AD_Right, ADIST_Small );
			
			str.AddAttack( currentHeavyBattleAxeAttack.animName, ADIST_Small );
		}
	}
	
	public function CreateAttackAspectLightShield()
	{
		var aspect 		: CComboAspect;
		var str 		: CComboString;
		
		ChooseAttack(currentLightShieldAttack, 8);
		
		aspect = comboDefinition.CreateComboAspect('AttackLightReal');
		{
			str = aspect.CreateComboString(false);
			
			str.AddDirAttack( currentLightShieldAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'geralt_shield_attack_fast_1_rp', AD_Back, ADIST_Small );
			str.AddDirAttack( 'geralt_shield_attack_fast_5_lp', AD_Left, ADIST_Small );
			str.AddDirAttack( 'geralt_shield_attack_fast_5_rp', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Front, ADIST_Large );
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Back, ADIST_Large );
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Left, ADIST_Large );
			str.AddDirAttack( 'geralt_attack_fast_long_1_rp', AD_Right, ADIST_Large );
			
			str.AddAttack( currentLightShieldAttack.animName, ADIST_Small );
		}
		
		{
			str = aspect.CreateComboString(true);
			
			str.AddDirAttack( currentLightShieldAttack.animName, AD_Front, ADIST_Small );
			
			str.AddDirAttack( 'man_geralt_sword_attack_fast_back_1_lp_40ms', AD_Back, ADIST_Small );
			str.AddDirAttack( 'geralt_attack_fast_4_lp', AD_Left, ADIST_Small );
			str.AddDirAttack( 'geralt_attack_fast_2_lp', AD_Right, ADIST_Small );
			
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Front, ADIST_Medium );
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Back, ADIST_Medium );
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Left, ADIST_Medium );
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Right, ADIST_Medium );
			
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Front, ADIST_Large );
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Back, ADIST_Large );
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Left, ADIST_Large );
			str.AddDirAttack( 'geralt_attack_fast_long_1_lp', AD_Right, ADIST_Large );
			
			str.AddAttack( currentLightShieldAttack.animName, ADIST_Small );
		} 	
	}
	
	public function Update( attackType : name, fistAnim : bool )
	{
		if( attackType == theGame.params.ATTACK_NAME_LIGHT )
		{
			if( !fistAnim )
			{
				if( Combat().IsUsingBattleAxe() || Combat().IsUsingBattleMace() )
				{
					comboDefinition.DeleteComboAspect('AttackBattleAxeFast');
					CreateAttackAspectFastBattleAxe();
				}
				else
				if( Combat().IsUsingSecondaryWeapon() )
				{
					comboDefinition.DeleteComboAspect('AttackLightSecondary');
					CreateAttackAspectSecondaryLight();
				}
				else
				{
					comboDefinition.DeleteComboAspect('AttackLightReal');
					CreateRealisticAttackAspectLight();
				}
			}
			else
			{
				comboDefinition.DeleteComboAspect('AttackFistFast');
				CreateRealisticAttackAspectFistLight();
			}
		}
		else
		{
			if( !fistAnim )
			{
				if( Combat().IsUsingBattleAxe() || Combat().IsUsingBattleMace() )
				{
					comboDefinition.DeleteComboAspect('AttackBattleAxeHeavy');
					CreateAttackAspectHeavyBattleAxe();
				}
				else
				{
					comboDefinition.DeleteComboAspect('AttackHeavyReal');
					CreateRealisticAttackAspectHeavy();
				}
			}
			else
			{
				comboDefinition.DeleteComboAspect('AttackFistHeavy');
				CreateRealisticAttackAspectFistHeavy();
			}
		}
	}
}