/*stock*/ sql_delete_promoter(targetid)
{
    new query[51];
    mysql_format(_dbConnector, query, sizeof query, "delete from `promoters` where `id` = '%i' limit 1", PromoterInfo[targetid][prSQLId]);
    mysql_tquery(_dbConnector, query);
}

/*stock*/ sql_create_promoter(playerid, targetid)
{
    new query[110];
    mysql_format(_dbConnector, query, sizeof query, "insert into `promoters` (name, level, referral_code) \
                                                    values ('%e', '%i', '%e')", 
    PromoterInfo[targetid][prName], PromoterInfo[targetid][prLevel], PromoterInfo[targetid][prReferralCode]);
    mysql_tquery(_dbConnector, query, "OnPromoterCreate", "ii", playerid, targetid);
}