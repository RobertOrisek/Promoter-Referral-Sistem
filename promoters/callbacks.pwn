//------------------------------------------------------------------------------

forward OnAllPromotersList(playerid);
public OnAllPromotersList(playerid)
{
    new dialogInfo[2048];

    format(dialogInfo, sizeof dialogInfo, "{FFFFFF}#\t{FFFFFF}Name\t{FFFFFF}Level\t{FFFFFF}Players Referred\n");
    for(new i = 0; i < cache_num_rows(); i ++)
    {
        cache_get_value_name_int(i, "id", AllPromotersInfo[i][apSQLId]);
        cache_get_value_name(i, "name", AllPromotersInfo[i][apName]);
        cache_get_value_name_int(i, "level", AllPromotersInfo[i][apLevel]);
        cache_get_value_name_int(i, "players_referred", AllPromotersInfo[i][apPlayersReferred]);

        format(dialogInfo, sizeof dialogInfo, "%s{CCB349}%i{FFFFFF}. \t%s\t%i\t%i\n", dialogInfo, i + 1, AllPromotersInfo[i][apName], AllPromotersInfo[i][apLevel], AllPromotersInfo[i][apPlayersReferred]);
    }
    ShowPlayerDialogEx(playerid, D_PROMOTERS_ALL_LIST, DIALOG_STYLE_TABLIST_HEADERS, D_NASLOV, dialogInfo, D_ODABIR, D_NAZAD);
    return 1;
}

//------------------------------------------------------------------------------

forward getUniqueReferralCode(playerid, targetid);
public getUniqueReferralCode(playerid, targetid)
{
	if(cache_num_rows() > MAX_PROMOTERS-1) return SendErrorMessage(playerid, "Dostignut je makismalan broj promotera!");
	new loopCount = 0,
		bool:notUniqueReferralCode = true,
		referralCodes[MAX_PROMOTERS][MAX_REFERRAL_CODE];

	if(cache_num_rows() > 0)
		for(new i = 0; i < cache_num_rows(); i ++)
			cache_get_value_name(i, "referral_code", referralCodes[i]);

	new referralSourceString[] = "ABCDEFGHJKLMNOPQRSTUVWXYZ0123456789";
	
	do {
		for(new i = 0; i < MAX_REFERRAL_CODE; i++)
			PromoterInfo[targetid][prReferralCode][i] = referralSourceString[random(strlen(referralSourceString))];

		if(cache_num_rows() > 0)
		{
			for(new i = 0; i < cache_num_rows(); i ++)
			{
				if(!strcmp(PromoterInfo[targetid][prReferralCode], referralCodes[i], false))
				{
					notUniqueReferralCode = false;
					break;
				}
			}
		}
		loopCount ++;
		
	} while(!notUniqueReferralCode && loopCount < cache_num_rows() + 2);

	if(loopCount == cache_num_rows() + 2)
	{
		SendErrorMessage(playerid, "Dostignut je maksimum kombinacija za generisanje referral koda!");
		SendErrorMessage(targetid, "Dostignut je maksimum kombinacija za generisanje referral koda!");
	} else
		sql_create_promoter(playerid, targetid);

	return true; 
}

//------------------------------------------------------------------------------

forward OnPromoterCreate(playerid, targetid);
public OnPromoterCreate(playerid, targetid)
{
    PromoterInfo[targetid][prSQLId] = cache_insert_id();

    PlayerInfo[targetid][pBanked] += 30000;
    SendInfoMessage(targetid, "Cestitamo, dobili ste status promotera i 30000$ za pridruzivanje.");
    SendInfoMessage(targetid, "Referral code mozete videti preko komande /myreferralcode.");
    
    SendInfoMessage(playerid, "Odabrani igrac je uspjesno postavljen za promotera.");
}

//------------------------------------------------------------------------------

forward OnPlayerPromoterLoad(playerid);
public OnPlayerPromoterLoad(playerid)
{
	if(cache_num_rows() > 0)
	{
		cache_get_value_name_int(0, "id", PromoterInfo[playerid][prSQLId]);
		cache_get_value_name(0, "name", PromoterInfo[playerid][prName]);
		cache_get_value_name_int(0, "level", PromoterInfo[playerid][prLevel]);
		cache_get_value_name(0, "referral_code", PromoterInfo[playerid][prReferralCode]);
		cache_get_value_name(0, "players_referred", PromoterInfo[playerid][prPlayersReferred]);
	}
	return true;
}