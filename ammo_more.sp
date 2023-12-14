#include <sourcemod>

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*
//*                 Ammo More
//*                 Status: beta.
//*					Автор релиза BatrakovScripts Ник на форуме(Alexander_Mirny)
//*
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ConVar Enable;

Handle AmmoTimer[MAXPLAYERS];
Handle ReloadTimer[MAXPLAYERS];

static bool:active[MAXPLAYERS];

public OnPluginStart()
{
	Enable = CreateConVar("l4d_ammo_more", "1", "Активация плагина (1 - Включен, 0 - Выключен)", FCVAR_NOTIFY);
	if(GetConVarInt(Enable) == 1)
	{
		HookEvent("player_spawn", OnPlayerSpawn);
		HookEvent("player_death", OnPlayerDeath);
		HookEvent("round_end", OnRoundEnd);
		HookEvent("mission_lost", OnRoundEnd);
		HookEvent("map_transition", OnRoundEnd);
	}
}
public OnClientDisconnect(client)
{
	
	if (!client)
		return;
	
	if (IsFakeClient(client))
		return;
	
	active[client] = false;
}
public OnMapStart()
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		active[i] = true;
	}
}
public OnPlayerDeath(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast) 
{
	new client  = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(client != 0 && IsClientInGame(client) && GetClientTeam(client) == 2 && !IsFakeClient(client))
	{
		SetEntProp(client, Prop_Send, "m_upgradeBitVec", 0, 4);
		active[client] = true;
	}
}
public OnRoundEnd(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)  
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientInGame(i) == true && IsClientInGame(i))
		{
			SetEntProp(i, Prop_Send, "m_upgradeBitVec", 0, 4);
			
		}
	}
}
public OnPlayerSpawn(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast) 
{ 
	new client  = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (IsClientConnected(client))
	{
		if (IsClientInGame(client))
		{
			if (!IsFakeClient(client))
			{
				if(client)
				{
					if(active[client] == true)
					{
						AmmoTimer[client] = CreateTimer(0.3, AmmoMore, client, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}
public Action:AmmoMore(Handle Timer, any:client)
{
	if(client)
	{
		if(AmmoTimer[client])
		{	
			KillTimer(AmmoTimer[client]);
			AmmoTimer[client] = null;
		}
		new cl_upgrades = GetEntProp(client, Prop_Send, "m_upgradeBitVec");
		SetEntProp(client, Prop_Send, "m_upgradeBitVec", cl_upgrades + 1048576, 4);
		PrintToChat(client,"\x05[Ammo]\x04Большая обойма, активирована.");
		ReloadTimer[client] = CreateTimer(0.4, Reload, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}
public Action:Reload(Handle Timer, any:client)
{
	if(client)
	{
		if(ReloadTimer[client])
		{	
			KillTimer(ReloadTimer[client]);
			ReloadTimer[client] = null;
		}
		new cl_upgrades = GetEntProp(client, Prop_Send, "m_upgradeBitVec");
		SetEntProp(client, Prop_Send, "m_upgradeBitVec", cl_upgrades + 536870912, 4);
		PrintToChat(client,"\x05[Reload]\x04Ловкость рук, активировано.");
		active[client] = false;
	}
}