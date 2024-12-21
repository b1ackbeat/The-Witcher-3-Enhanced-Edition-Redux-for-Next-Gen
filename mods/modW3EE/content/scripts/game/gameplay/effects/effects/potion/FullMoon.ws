/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_FullMoon extends W3ChangeMaxStatEffect
{
	default effectType = EET_FullMoon;
	default stat = BCS_Vitality;
	
	// W3EE - Begin
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		//var vitality : float;
		
		super.OnEffectAdded(customParams);
		//Kolaris - Full Moon, Kolaris - Golden Oriole
		/*if(GetBuffLevel() == 3)
		{
			vitality = thePlayer.GetStatMax(BCS_Vitality) * thePlayer.GetStatPercents(BCS_Toxicity);
			thePlayer.GainStat(BCS_Vitality, vitality);
		}*/
	}
	// W3EE - End
}