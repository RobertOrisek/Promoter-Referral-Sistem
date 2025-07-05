//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GLOBAL COMMANDS //

CMD:promoteri(playerid)
{
	new dialogInfo[2048];

	foreach(new i : Player)
 	    if(PromoterInfo[i][prLevel] >= 1)
			format(dialogInfo, sizeof dialogInfo, "%s{CCB349}LB Promoter - {FFFFFF}[Id: {CCB349}%d{FFFFFF}] - {CCB349}%s {FFFFFF}| Level: {CCB349}%i\n", dialogInfo, i, GetName(i), PromoterInfo[i][prLevel]);

	if(strlen(dialogInfo) == 0) return SendErrorMessage(playerid, "Trenutno nema online Promotera.");

	ShowPlayerDialogEx(playerid, MESSAGE_DIALOG, DIALOG_STYLE_MSGBOX, D_NASLOV, dialogInfo, "OK", "");
	return 1;
}

//------------------------------------------------------------------------------

alias:promoteri("promoters")

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ADMIN COMMANDS //

CMD:makepromoter(playerid, params[])
{
    if(!IsPlayerConnectedAndLoggedIn(playerid))
		return 1;
	if(PlayerInfo[playerid][pAdmin] < 5 && PromoterInfo[playerid][prLevel] < 3)
		return SendErrorMessage(playerid, "Niste autorizovani - nemate admin/promoter level.");

	new targetid;
	new level;
	if(sscanf(params, "ui", targetid, level) || level < 0 || level > 3)
		return SendUsageMessage(playerid, "makepromoter [id/deo imena] [0-3]");

	if(!IsPlayerConnectedAndLoggedIn(targetid))
		return SendErrorMessage(playerid, "Odabrani igrac nije online ili nije ulogovan u svoj korisnicki nalog.");

	if(level == 0)
	{
		sql_delete_promoter(playerid);

		PromoterInfo[targetid][prSQLId] = -1;
		strmid(PromoterInfo[targetid][prName], "Niko", 0, strlen("Niko"));
		strmid(PromoterInfo[targetid][prReferralCode], "00000000000", 0, strlen("00000000000"));
		PromoterInfo[targetid][prPlayersReferred] = 0;
		PromoterInfo[targetid][prLevel] = 0;

		SendInfoMessage(playerid, "Odabranom igracu je uspesno skinut promoter status.");
		PlayerPlaySound(playerid, SOUND_SUCCESS_INFO, 0.0, 0.0, 0.0);
	}
	else
	{
		if(PromoterInfo[targetid][prLevel] == level)
			return SendErrorMessage(playerid, "Odabrani igrac je trenutno isti level koji zelite da postavite!");

		if(PromoterInfo[targetid][prLevel] > 0)
		{
			new query[55];
			mysql_format(_dbConnector, query, sizeof query, "update promoters set level = '%i' where id = '%i'", level, PromoterInfo[targetid][prSQLId]);
			mysql_tquery(_dbConnector, query);

			if(level > PromoterInfo[targetid][prLevel])
				SendInfoMessage(targetid, "Cestitamo, dobili ste status promotera level %i.", level);
			else
				SendInfoMessage(targetid, "Nazalost, dobili ste status promotera level %i.", level);
		}
		else
		{
			strmid(PromoterInfo[targetid][prName], playerNick[targetid], 0, strlen(playerNick[targetid]));
			mysql_tquery(_dbConnector, "select referral_code from promoters where id > -1", "getUniqueReferralCode", "ii", playerid, targetid);
		}
		PromoterInfo[targetid][prLevel] = level;
	}
	return 1;
}

//------------------------------------------------------------------------------

CMD:allpromoters(playerid)
{
	if(PlayerInfo[playerid][pAdmin] < 7 && PromoterInfo[playerid][prLevel] < 3)
		return SendErrorMessage(playerid, "Niste autorizovani - nemate administrator/promoter level.");

	new query[128];
	mysql_format(_dbConnector, query, sizeof query, "select id, name, level, players_referred from promoters");
	mysql_tquery(_dbConnector, query, "OnAllPromotersList", "i", playerid);
	return 1;
}

//------------------------------------------------------------------------------

CMD:promoterreward(playerid, params[])
{
    if(IsPlayerConnectedAndLoggedIn(playerid))
   	{
   	    if(PlayerInfo[playerid][pAdmin] < 7 && PromoterInfo[playerid][prLevel] < 2)
   	    	return SendErrorMessage(playerid, "Niste autorizovani - nemate admin/promoter level.");

		new targetid, reklame, ocena;
		if(sscanf(params, "uii", targetid, reklame, ocena) || ocena < 0 || ocena > 100)
			return SendUsageMessage(playerid, "promoterreward [id/deo imena] [broj reklama] [ocena 0-100]");

		if(!IsPlayerConnectedAndLoggedIn(targetid))
			return SendErrorMessage(playerid, "Odabrani igrac nije online ili nije ulogovan u svoj korisnicki nalog.");
		
		if(PlayerInfo[targetid][pPromoter] < 1)
			return SendErrorMessage(playerid, "Igrac nije promoter.");

		new zarada = reklame * ocena;
		GivePlayerCash(targetid, zarada, "zarada za promovisanje");

		if(ocena >= 50) {

			PlayerInfo[targetid][pRespect] += 5;

			if(PlayerInfo[playerid][pRespect] >= PlayerInfo[playerid][pLevel] * 3) {

				PlayerInfo[playerid][pLevel] += 1;
				PlayerInfo[playerid][pRespect] = PlayerInfo[playerid][pRespect] - PlayerInfo[playerid][pLevel] * 3;
				SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
				IncrementAchievement(playerid, ACHIEVEMENT_LEVELS);
			}
		}
		if(ocena >= 90)
		{
			PlayerInfo[targetid][pBoatLic] += 100;
			PlayerInfo[targetid][pFlyLic] += 100;
			PlayerInfo[targetid][pWepLic] += 100;
		}
		SendInfoMessage(playerid, "Odabranom igracu ste uspesno dali nagradu za reklamiranje.");
		SendInfoMessage(targetid, "Cestitamo, dobili ste nagradu za promovisanje servera.");	
	}
	return 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PROMOTER COMMANDS //

CMD:pc(playerid, params[]) {
	if(IsPlayerConnectedAndLoggedIn(playerid)) {
		if(PlayerInfo[playerid][pAdmin] < 5 && PromoterInfo[playerid][prLevel] == 0)
			return SendErrorMessage(playerid, "Niste autorizovani - nemate admin/promoter level.");
		new poruka[80], rankText[20];

		if(sscanf(params,"s[80]",poruka)) return SendUsageMessage(playerid, "pc [poruka]");

		if(PromoterInfo[playerid][prLevel] == 1) ranktext = "Promoter";
		if(PromoterInfo[playerid][prLevel] == 2) ranktext = "Marketing Support";
		if(PlayerInfo[playerid][pAdmin] > 0 && PlayerInfo[playerid][pAdmin] < 5) ranktext = "Admin";
		if(PlayerInfo[playerid][pAdmin] == 5) ranktext = "Ultra Admin";
		if(PlayerInfo[playerid][pAdmin] == 6) ranktext = "Co Head";
		if(PlayerInfo[playerid][pAdmin] == 7) ranktext = "Head Admin";
		if(PromoterInfo[playerid][prLevel] == 3) ranktext = "Nadzornik Promotera";

		SendPromoterMessage(COLOR_YELLOW, "* %s %s : %s *", ranktext, GetName(playerid), poruka);
	}
	return true;
}

//------------------------------------------------------------------------------

CMD:prfix(playerid, params[]) {

	if(IsPlayerConnectedAndLoggedIn(playerid)) {

		if(limit_prfix[playerid] > gettime())
			return SendErrorMessage(playerid, "Nedavno ste koristili komandu /prfix - pricekajte malo.");

		if(PromoterInfo[playerid][prLevel] == 0)
			return SendErrorMessage(playerid, "Niste autorizovani - nemate admin/promoter level.");
			
		if(!IsPlayerInAnyVehicle(playerid))
			return SendErrorMessage(playerid, "Niste unutar vozila.");

		if(PlayerInfo[playerid][pWanted] != 0)
			return SendErrorMessage(playerid, "Ne mozete koristiti komandu jer imate WL.");

		RepairVehicle(GetPlayerVehicleID(playerid));
		
		SendAdminMessage(COLOR_RED, "AdmWarn: Igrac %s je koristio komandu /prfix.", GetName(playerid));
		SendInfoMessage(playerid, "Uspesno ste popravili vozilo");

		limit_prfix[playerid] = gettime() + 180;
	}
	return true;
}

//------------------------------------------------------------------------------

CMD:prhelp(playerid, params[]) {

	if(IsPlayerConnectedAndLoggedIn(playerid)) {

		if(PromoterInfo[playerid][prLevel] == 0)
			return SendErrorMessage(playerid, "Niste autorizovani - nemate admin/promoter level.");

		SendClientMessage(playerid,-1,"{ff0000}====================================");
		if(PromoterInfo[playerid][prLevel] == 1 || PromoterInfo[playerid][prLevel] == 2)
			SendClientMessage(playerid, COLOR_INFO, "Promoter: /pc /prfix /prveh /myreferralcode");
		else if(PromoterInfo[playerid][prLevel] == 3)
			SendClientMessage(playerid, COLOR_INFO, "Nadzornik Promotera: /makepromoter");
		SendClientMessage(playerid,-1,"{ff0000}====================================");
	}
	return true;
}

//------------------------------------------------------------------------------

CMD:myreferralcode(playerid)
{
	if(PromoterInfo[playerid][prLevel] == 0) return SendErrorMessage(playerid, "Niste autorizovani - nemate admin/promoter level.");
	SendInfoMessage(playerid, "Vas referral code je: %s", PromoterInfo[playerid][prReferralCode]);
	return true;
}