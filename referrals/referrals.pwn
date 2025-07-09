#include <YSI_Coding\y_hooks>

//##############################################################################
// ENUMS //
enum E_REFERRAL_INFO {
    rpName[MAX_PLAYER_NAME],
    rpLevel,
    rpRegTime,
    rpLogTime
}
//##############################################################################
// VARIABLES //

new referredPlayerInfo[MAX_PLAYERS][E_REFERRAL_INFO],

    bool:PlayerReferred[MAX_PLAYERS],

    promoterName[MAX_PLAYERS][MAX_PLAYER_NAME];

//##############################################################################
// HOOKS //

hook OnPlayerConnect(playerid) {

    PlayerReferred[playerid] = false;
}

//------------------------------------------------------------------------------

forward Referrals_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
public Referrals_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

    if(dialogid == D_REFERRED_PLAYER_CHECK) {

        if(response) {

            new fileString[46];
      		format(fileString, sizeof(fileString), "LBRPG/Accounts/%s.ini", referredPlayerInfo[listitem][rpName]);

        	if(fexist(fileString))
          		INI_ParseFile(fileString, "OnReferredPlayerDataLoad", false, true, listitem);

            SendInfoMessage(playerid, "%s | Level: %i | Sati igre: %i",
            referredPlayerInfo[listitem][rpName], referredPlayerInfo[listitem][rpLevel], referredPlayerInfo[listitem][rpPlayHours]);
        }
        else
        {
            new dialogInfo[4096];
            format(dialogInfo, sizeof dialogInfo, "{FFFFFF}#\t{FFFFFF}Name\t{FFFFFF}Level\t{FFFFFF}Players Referred\n");

            for(new i = 0; i < cache_num_rows(); i ++)  {

                cache_get_value_name_int(i, "id", AllPromotersInfo[i][apSQLId]);
                cache_get_value_name(i, "name", AllPromotersInfo[i][apName]);
                cache_get_value_name_int(i, "level", AllPromotersInfo[i][apLevel]);
                cache_get_value_name_int(i, "players_referred", AllPromotersInfo[i][apPlayersReferred]);

                format(dialogInfo, sizeof dialogInfo, "%s{CCB349}%i{FFFFFF}. \t%s\t%i\t%i\n", dialogInfo, i + 1, AllPromotersInfo[i][apName], AllPromotersInfo[i][apLevel], AllPromotersInfo[i][apPlayersReferred]);
            }
            ShowPlayerDialogEx(playerid, D_PROMOTERS_ALL_LIST, DIALOG_STYLE_TABLIST_HEADERS, D_NASLOV, dialogInfo, D_ODABIR, D_NAZAD);
        }
    }
    return 1;
}

//##############################################################################
// CALLBACKS //

forward OnPlayerReferral(playerid);
public OnPlayerReferral(playerid) {

    new rowCount = 0, string[102];
    cache_get_row_count(rowCount);

    if(rowCount > 0) {

        new promoterSQLId,
        referralCode[MAX_REFERRAL_CODE],
        query[95];

        cache_get_value_name_int(0, "id", promoterSQLId);
        cache_get_value_name(0, "name", promoterName[playerid]);
        cache_get_value_name(0, "referral_code", referralCode);

        if(PlayerReferred[playerid]) {

            mysql_format(_dbConnector, query, sizeof query, "update `referrals` set `promoter_id` = '%i' where `name` = '%e'", promoterSQLId, playerNick[playerid]);
            mysql_tquery(_dbConnector, query);
            
        } else {

            PlayerReferred[playerid] = true;
            mysql_format(_dbConnector, query, sizeof query, "insert into `referrals` (name, promoter_id) values ('%e', '%i')", playerNick[playerid], promoterSQLId);
            mysql_tquery(_dbConnector, query);

            mysql_format(_dbConnector, query, sizeof query, "update `promoters` set `players_referred` = `players_referred`+1 where `id` = '%i'", promoterSQLId);
            mysql_tquery(_dbConnector, query);
        }
        
        PlayerInfo[playerid][pLevel] += 4;
        PlayerInfo[playerid][pBanked] += 50000;
        SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
        
        SendServerMessage(playerid, "Uspesan unos referral koda: '%s' od promotera '%s'.", referralCode, promoterName[playerid]);
        SendServerMessage(playerid, "Zbog uspesnog unosa referral koda dobili ste +4 levela i +50.000$ na bankovni racun.");
        SendServerMessage(playerid, "Zelimo vam puno zabave na serveru - ako trebate pomoc koristite /help komandu.");

        format(string, sizeof string, "AdmWarn: Igrac %s se upravo registrirao na server - pripazite malo na njega.", playerNick[playerid]);
        SendAdminMessage(COLOR_RED, string);

    } else
        ShowPlayerDialogEx(playerid, D_REG_STEP_REFERRAL, DIALOG_STYLE_INPUT, "{CCB349}REGISTRACIJA - REFERRAL","{CCB349}* {FFFFFF}Par napomena o unosu referrala:\
        \n\n{CCB349}  - {FFFFFF}Unesite referral kod promotera preko kog ste culi za server.\
        \n{CCB349}  - {FFFFFF}Nakon uspesnog unosa referral koda dobijate {CCB349}+4 levela {FFFFFF}i {CCB349}50.000$ {FFFFFF}na bankovni racun.\
        \n{CCB349}  - {FFFFFF}Ukoliko nemate referral kod upisite {CCB349}\"Nema\"\
        \n\n* {FFFFFF}Ukoliko ne unesete postojeci referral kod bicete vraceni ovde.", D_ODABIR, D_ODUSTANI);
    return 1;
}

//------------------------------------------------------------------------------

forward OnReferredPlayersList(playerid);
public OnReferredPlayersList(playerid) {

    new dialogInfo[2048];

    for(new i = 0; i < cache_num_rows(); i ++) {
        cache_get_value_name(i, "name", referredPlayerInfo[i][rpName]);

        format(dialogInfo, sizeof dialogInfo, "%s{CCB349}%i. {FFFFFF}%s\n", dialogInfo, i+1, referredPlayerInfo[i][rpName]);
    }

    ShowPlayerDialogEx(playerid, D_REFERRED_PLAYER_CHECK, DIALOG_STYLE_LIST, D_NASLOV, dialogInfo, D_ODABIR, D_ODUSTANI);
    return 1;
}

//------------------------------------------------------------------------------

forward OnReferredPlayerDataLoad(id, name[], value[]);
public OnReferredPlayerDataLoad(id, name[], value[]) {
    INI_Int("RegTime", referredPlayerInfo[id][rpRegTime]);
    INI_Int("LogTime", referredPlayerInfo[id][rpLogTime]);
    INI_Int("Level", referredPlayerInfo[id][rpLevel]);
    return 1;
}
