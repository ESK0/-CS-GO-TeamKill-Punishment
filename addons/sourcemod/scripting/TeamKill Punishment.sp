#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>

#define PLUGIN_URL "https://github.com/ESK0"
#define PLUGIN_VERSION "0.1a"
#define PLUGIN_AUTHOR "ESK0"
#define g_sTag "[TK-Punishment]"

new Handle: PunishmentDataPack;
new g_iAccount;

public Plugin:myinfo = 
{
	name = "Teamkill punishment",
	author = PLUGIN_AUTHOR,
	description = "Teamkill punishment",
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

public OnPluginStart()
{
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	new Handle:cvar = FindConVar("mp_autokick");
	SetConVarString(cvar, "mp_autokick 0");
	HookEvent("player_death", OnPlayerDead);
	
	LoadTranslations("common.phrases.txt");
	LoadTranslations("TeamKillPunishment.phrases");
}
public Action: OnPlayerDead(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(IsValidPlayer(victim) && IsValidPlayer(attacker) && victim != attacker && GetClientTeam(victim) == GetClientTeam(attacker))
	{
		new Handle:PunishmentMenu = CreateMenu(PunishmentList);
		
		decl String: MenuTitle[32];
		Format(MenuTitle, sizeof(MenuTitle), "%T", "Punishment menu title", victim);
		SetMenuTitle(PunishmentMenu, MenuTitle);
		
		decl String: Forgive[32];
		Format(Forgive, sizeof(Forgive), "%T", "Forgive", victim);
		AddMenuItem(PunishmentMenu, "Forgive", Forgive);
		
		decl String: Slay[32];
		Format(Slay, sizeof(Slay), "%T", "Slay", victim);
		AddMenuItem(PunishmentMenu, "Slay", Slay);
		
		decl String: Freeze[32];
		Format(Freeze, sizeof(Freeze), "%T", "Freeze", victim);
		AddMenuItem(PunishmentMenu, "Freeze", Freeze);
		
		decl String: BreakLeg[32];
		Format(BreakLeg, sizeof(BreakLeg), "%T", "BreakLeg", victim);
		AddMenuItem(PunishmentMenu, "BreakLeg", BreakLeg);
		
		decl String: Health[32];
		Format(Health, sizeof(Health), "%T", "Health", victim);
		AddMenuItem(PunishmentMenu, "10HP", Health);
		
		decl String: Rob[32];
		Format(Rob, sizeof(Rob), "%T", "Rob", victim);
		AddMenuItem(PunishmentMenu, "Rob", Rob);
		
		decl String: Reincarnation[32];
		Format(Reincarnation, sizeof(Reincarnation), "%T", "Reincarnation", victim);
		AddMenuItem(PunishmentMenu, "Reincarnation", Reincarnation);
		
		DisplayMenu(PunishmentMenu, victim, MENU_TIME_FOREVER);
		SetMenuExitBackButton(PunishmentMenu, true);
		
		PunishmentDataPack = CreateDataPack();
		WritePackCell(PunishmentDataPack, victim);
		WritePackCell(PunishmentDataPack, attacker);
	}
}
public PunishmentList(Handle:PunishmentList, MenuAction:action, client, Position)
{
	if(action == MenuAction_Select)
	{
		ResetPack(PunishmentDataPack);
		new victim = ReadPackCell(PunishmentDataPack);
		new attacker = ReadPackCell(PunishmentDataPack);
		
		decl String:Item[32];
		GetMenuItem(PunishmentList, Position, Item, sizeof(Item));
		if(StrEqual(Item, "Forgive"))
		{
			PrintToChat(victim, "%s You forgived %N's teamkill.", g_sTag, attacker);
		}
		else if(StrEqual(Item, "Slay"))
		{
			SlayPlayer(attacker);
			PrintToChat(attacker, "%s You were killed for teamkill.", g_sTag)
			PrintToChat(victim, "%s %N was murdered.", g_sTag, attacker);
		}
		else if(StrEqual(Item, "Freeze"))
		{
			SetEntityMoveType(attacker, MOVETYPE_NONE);
			SetEntityRenderColor(attacker, 165, 242, 243);
			PrintToChat(attacker, "%s You are frozen for teamkill.", g_sTag);
			PrintToChat(victim, "%s %N was frozen.", g_sTag, attacker);
		}
		else if(StrEqual(Item, "BreakLeg"))
		{
			SetEntPropFloat(attacker, Prop_Data, "m_flLaggedMovementValue", 0.75);
			PrintToChat(attacker, "%s %N broke your leg.", g_sTag, victim);
			PrintToChat(victim, "%s %N has now a broken leg.", g_sTag, attacker);
		}
		else if(StrEqual(Item, "10HP"))
		{
			SetEntProp(attacker, Prop_Data, "m_iHealth", 10);
			PrintToChat(attacker, "%s %N poisoned you to 10HP", g_sTag, victim);
			PrintToChat(victim, "%s %N has now 10HP", g_sTag, attacker);
		}
		else if(StrEqual(Item, "Rob"))
		{
			new AttackerWallet = GetEntData(attacker, g_iAccount);
			new VictimWallet = GetEntData(victim, g_iAccount);
			
			if(VictimWallet + AttackerWallet > 16000)
			{
				SetEntData(victim, g_iAccount, 16000);
			}
			else
			{
				SetEntData(victim, g_iAccount, AttackerWallet + VictimWallet);
			}
			PrintToChat(attacker, "%s You have been robbed by %N", g_sTag, victim);
			PrintToChat(victim, "%s You robbed %N, You earned $%d", g_sTag, attacker, AttackerWallet);
			SetEntData(attacker, g_iAccount, 0);
		}
		else if(StrEqual(Item, "Reincarnation"))
		{
			SlayPlayer(attacker);
			CS_RespawnPlayer(victim);
			PrintToChat(attacker, "%s %N took your life", g_sTag, victim);
			PrintToChat(victim, "%s You were revived", g_sTag);
		}
	}
}


SlayPlayer(client)
{
	ForcePlayerSuicide(client);
}
stock bool:IsValidPlayer(client, bool:alive = false){
    if(client >= 1 &&
	client <= MaxClients &&
	IsClientConnected(client) &&
	IsClientInGame(client) &&
	(alive == false || IsPlayerAlive(client))){
        return true;
    }
    return false;
}