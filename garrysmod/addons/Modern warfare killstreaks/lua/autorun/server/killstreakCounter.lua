if not SERVER then return end
require("datastream")
MW2KillStreakAddon = 1
MW2_KillStreaks_EMP_Team = -1
local enableKillStreaks = CreateConVar ("mw2_enable_killstreaks", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local maxNpcKills = CreateConVar ("mw2_NPC_requirement", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE});
local MW2AllowUseOfNuke = CreateConVar ("mw2_Allow_Nuke", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE});
local MW2AllowTeams = CreateConVar ("mw2_Allow_Teams", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE});
local frendlysNpcs = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }
local easyKillNpcs = {"npc_breen", "npc_cscanner", "npc_pigeon","npc_seagull","npc_crow", "npc_clawscanner", "npc_stalker", "npc_barnacle"}

function playerJoin(ply) --when a player joins the server initailizes the nessacary variables 
	ply.npcKills = 0;
	ply.plKills = 0;
	ply.killStreaks = {}
	ply.curKillstreaks = {}
	ply.newKillstreaks = {}
	ply:SetNetworkedString("AddKillStreak","none")
	ply:ConCommand("OpenKillstreakWindow")
	ply.FirstSpawn = true;
	local teamNum = math.random(1,5)
	ply:SetTeam(teamNum);
	ply:SetNetworkedString("MW2TeamSound", tostring( teamNum ))	
	ply:SetNetworkedBool("MW2AC130ThermalView", true) 
end

function npcDeath( victim, killer, weapon )   -- since an npc can be easyer to kill then a player, it takes more kills of NPCs to add to one kill against a player	
	if enableKillStreaks:GetInt() != 1 then return end
	if killer:IsPlayer() && checkNPC(victim) then 
		if weapon:GetVar("FromCarePackage",false) then
			return;
		end
		if victim:GetClass() == "npc_antlionguard" || victim:GetClass() == "npc_strider" then
			killer.plKills = killer.plKills + 1;
			checkKills(killer);
		else
			killer.npcKills = killer.npcKills + 1;
		end
		if killer.npcKills == maxNpcKills:GetFloat() then 
			killer.npcKills = 0;
			killer.plKills = killer.plKills + 1;
			checkKills(killer);
		end
	end
end

function checkNPC(victim)	--Disallow people from killing freindly NPCs and easy to kill NPCs like breen
	if table.HasValue(frendlysNpcs, victim:GetClass()) || table.HasValue(easyKillNpcs, victim:GetClass()) then
		return false;	
	else
		return true;
	end
end

function playerDies( victim, weapon, killer ) 
	
	if victim:IsPlayer() then -- If a player dies then reset their kills to zero.
		victim.npcKills = 0;
		victim.plKills = 0;		
		victim.curKillstreaks = victim.newKillstreaks	
		for k,v in pairs(victim.killStreaks) do -- If the player has any killstreaks and they were killed will make it so that their killstreaks will not get them kills next life
			v[2] = true;
		end			
		umsg.Start("ResetKillStreakIcon", victim);
		umsg.End();
	end
	if enableKillStreaks:GetInt() != 1 then return end -- if the admin chooses not to allow this mod to work then it will end here
	
	if weapon:GetVar("FromCarePackage",false) then
		return;
	end
	
	if killer:IsPlayer() && killer != victim then		-- Increments the killers kills by 1
		killer.plKills = killer.plKills + 1;
		checkKills(killer);
	end 
end

function checkKills(ply)
	local kills = ply.plKills;
	if kills == 3 && canUseStreak(ply, "UAV") then 
		addKillStreak(ply,"uav");
	elseif kills == 4 && canUseStreak(ply, "Care Package") then 
		addKillStreak(ply,"care_package");
	elseif kills == 4 && canUseStreak(ply, "Counter UAV") then 
		addKillStreak(ply,"mw2_Counter_UAV");
	elseif kills == 5 && canUseStreak(ply, "Predator missile") then 
		addKillStreak(ply,"predator_missile");
	elseif kills == 5 && canUseStreak(ply, "Sentry Gun") then 
		addKillStreak(ply,"mw2_sentry_gun_package");
	elseif kills == 6 && canUseStreak(ply, "Precision Airstrike")	then 
		addKillStreak(ply,"precision_airstrike");		
	elseif kills == 7 && canUseStreak(ply, "Harrier") then 
		addKillStreak(ply,"harrier");
	elseif kills == 8  && canUseStreak(ply, "Emergency Airdrop") then 
		addKillStreak(ply,"emergency_airdrop");
	elseif kills == 9  && canUseStreak(ply, "Stealth bomber") then 
		addKillStreak(ply,"stealth_bomber");
	elseif kills == 11 && canUseStreak(ply, "AC-130") then 
		addKillStreak(ply,"ac-130");
	elseif kills == 15 && canUseStreak(ply, "EMP") then 
		addKillStreak(ply,"mw2_EMP");
	elseif MW2AllowUseOfNuke:GetInt() == 1 && kills == 25 && canUseStreak(ply, "Nuke") then 
		addKillStreak(ply,"tactical_Nuke");		
	end
end

function canUseStreak(ply, streak)
	if table.HasValue(ply.curKillstreaks, streak) then
		return true;
	end
	return false;
end

function addKillStreak(ply, str)
	addKillStreak(ply, str, false)
end

function addKillStreak(ply, str, isCare)
	if str == "ammo" then
		giveAmmo(ply);
		return;
	end
	ply:SetNetworkedString("AddKillStreak", str)
	table.insert(ply.killStreaks, {str, isCare})
	umsg.Start("AddKillStreak", ply);
	umsg.End();
end

function giveAmmo(pl)
	local ammoAmount = 100;
	local healthAmount = 25;
	local armorAmount = 50;
	for k,v in pairs(pl:GetWeapons()) do
		pl:GiveAmmo(ammoAmount, v:GetPrimaryAmmoType());
	end	
	pl:SetHealth( pl:Health() + healthAmount )
	pl:SetArmor( pl:Armor() + armorAmount )
end

function useKillStreak(player, command, arguments ) -- command for the user to use the kill streaks they have aquired.

	if MW2_KillStreaks_EMP_Team != -1 && player:Team() != MW2_KillStreaks_EMP_Team then
		--Print out that the killstreaks are temp. unavlible
		player:ChatPrint("Killstreaks are temp. unavlible");
		return;
	end

	local remaingKillStreaks = table.Count(player.killStreaks)	
	
	if remaingKillStreaks > 0 then	
	
		local val = player.killStreaks[remaingKillStreaks][1];
		
		if val == "ac-130" || val == "predator_missile" then 
			if !FindSky(player) then
				umsg.Start("ShowKillstreakSpawnError", player);
				umsg.End()
				return;
			end
		end
	
		local tab = table.remove(player.killStreaks)
		local streak = tab[1];
		local isCare = tab[2];
		player:SetNetworkedString("UsedKillStreak",streak)
		player:SetNetworkedBool("IsKillStreakFromCarePackage",isCare)
		player:Give(streak);
	end
	local killStr = player.killStreaks[remaingKillStreaks-1]
	if killStr != nil then
		player:SetNetworkedString("AddKillStreak", tostring(killStr[1]))
	else
		player:SetNetworkedString("AddKillStreak", "none")
	end

end

function setKillstreaks( pl, handler, id, encoded, decoded )
	if pl.FirstSpawn then
		pl.curKillstreaks = decoded;
		pl.newKillstreaks = decoded;
		pl.FirstSpawn = false;
	else
		pl.newKillstreaks = decoded;
	end
end
datastream.Hook( "ChoosenKillstreaks", setKillstreaks )

function setMW2Voices( pl, handler, id, encoded, decoded )
	pl:SetNetworkedString("MW2TeamSound", decoded[1])
	if MW2AllowTeams:GetInt() == 1 then
		pl:SetTeam(decoded[1]);
	end
end
datastream.Hook( "SetMw2Voices", setMW2Voices )

function setMW2PlayerVars( pl, handler, id, encoded, decoded )
	pl:SetNetworkedBool("MW2AC130ThermalView", decoded[1])
	pl:SetNetworkedBool("MW2NukeEffectOwner", decoded[2])
end
datastream.Hook( "setMW2PlayerVars", setMW2PlayerVars )

function ResetMW2Killstreak( pl, handler, id, encoded, decoded ) -- this data stream allows the client to reset the killstreak, so if you recive two of the same killstreak right after the other it will playthe notification for both
	pl:SetNetworkedString("AddKillStreak","none")
end
datastream.Hook( "MW2KillstreakCounter_ResetStreak", ResetMW2Killstreak )

concommand.Add( "Use_KillStreak", useKillStreak )

hook.Add("PlayerInitialSpawn" ,"SetUpKillStreakCounter", playerJoin)
hook.Add( "PlayerDeath", "ResetKillStreak", playerDies )
hook.Add("OnNPCKilled", "AddKillsToKillStrreak", npcDeath)

function FindSky(player)
	local pos = player:GetPos();
	local maxheight = 16384
	local startPos = pos;
	local endPos = Vector(pos.x, pos.y, maxheight);
	local filterList = {player}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local num = 0;
	local foundSky = false;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			foundSky = true;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if num >= 300 then			
			bool = false;
		end
		num = num + 1
	end
	
	return foundSky;
end
