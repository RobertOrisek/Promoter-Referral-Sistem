//##############################################################################
// INCLUDES //

#include <YSI_Coding\y_hooks>

//##############################################################################
// MACROS //

#define MAX_REFERRAL_CODE 11

#define MAX_PROMOTERS 1000

#define DEFAULT_REFERRAL_CODE "0000000000"

//##############################################################################
// ENUMS //

enum E_PROMOTER_INFO
{
    prSQLId,
    prName[MAX_PLAYER_NAME],
	prLevel,
    prReferralCode[MAX_REFERRAL_CODE],
    prPlayersReferred
}

//------------------------------------------------------------------------------

enum E_ALL_PROMOTERS_INFO
{
	apSQLId,
    apName[MAX_PLAYER_NAME],
	apLevel,
	apReferralCode[MAX_REFERRAL_CODE],
    apPlayersReferred
}

//##############################################################################
// VARIABLES //

new PromoterInfo[MAX_PLAYERS][E_PROMOTER_INFO],

	AllPromotersInfo[MAX_PROMOTERS][E_ALL_PROMOTERS_INFO],
	
	editingPromoter[MAX_PLAYERS];

//##############################################################################
// HOOKS //

hook OnPlayerConnect(playerid) {
	PromoterInfo[playerid][prSQLId] = -1;
	strmid(PromoterInfo[playerid][prName], "Niko", 0, strlen("Niko"));
	strmid(PromoterInfo[playerid][prReferralCode], DEFAULT_REFERRAL_CODE, 0, strlen(DEFAULT_REFERRAL_CODE));
	PromoterInfo[playerid][prPlayersReferred] = 0;
	PromoterInfo[playerid][prLevel] = 0;

	editingPromoter[playerid] = -1;
}

//------------------------------------------------------------------------------

forward Promoters_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
public Promoters_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	switch(dialogid) {

		case D_PROMOTERS_ALL_LIST: {

			if(response) {

				new query[128];
				mysql_format(_dbConnector, query, sizeof query, "select name from referrals where promoter_id = '%i'", AllPromotersInfo[listitem][apSQLId]);
				mysql_tquery(_dbConnector, query, "OnReferredPlayersList", "ii", playerid, listitem);
			}
		}
	}
}

//##############################################################################