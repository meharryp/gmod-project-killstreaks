if not SERVER then return end
require("datastream")
MW2KillStreakAddon = 1
local enableKillStreaks = CreateConVar ("mw2_enable_killstreaks", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local maxNpcKills = CreateConVar ("mw2_NPC_requirement", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE});
local MW2AllowUseOfNuke = CreateConVar ("mw2_Allow_Nuke", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE});
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
	ply:SetNetworkedString("MW2TeamSound", tostring(math.random(1,5)))
	ply:SetNetworkedBool("MW2AC130ThermalView", true) 
end

function npcDeath( victim, killer, weapon )   -- since an npc can be easyer to kill then a player, it takes more kills of NPCs to add to one kill against a player	
	if enableKillStreaks:GetInt() != 1 then return end
	if killer:IsPlayer() && checkNPC(victim) then 
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
		umsg.Start("ResetKillStreakIcon", victim);
		umsg.End();
	end
	if enableKillStreaks:GetInt() != 1 then return end -- if the admin chooses not to allow this mod to work then it will end here
	
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
	elseif kills == 5 && canUseStreak(ply, "Predator missile") then 
		addKillStreak(ply,"predator_missile");
		
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
--	elseif kills == 15 then 
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
	if str == "ammo" then
		giveAmmo(ply);
		return;
	end
	ply:SetNetworkedString("AddKillStreak", str)
	table.insert(ply.killStreaks, str)
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
	remaingKillStreaks = table.Count(player.killStreaks)	
	
	if remaingKillStreaks > 0 then	
		streak = table.remove(player.killStreaks)
		player:SetNetworkedString("UsedKillStreak",streak)
		player:Give(streak);
		--[[
		umsg.Start("RemoveUsedKillStreak", player);
		umsg.End();
	]]
	end
	killStr = player.killStreaks[remaingKillStreaks-1]
	player:SetNetworkedString("AddKillStreak", tostring(killStr))

end

function damageInfo(ent, inflictor, attacker, amount, dmginfo) -- Allows the correct kill icon to be drawn for the explosive.
	if( dmginfo:IsExplosionDamage() && ((attacker:GetClass() == "sent_predator_missile" && ent:GetClass() != "sent_predator_missile") || (attacker:GetClass() == "sent_bomblet" && ent:GetClass() != "sent_bomblet") || (attacker:GetClass() == "sent_air_strike_bomb" && ent:GetClass() != "sent_air_strike_bomb") || (attacker:GetClass() == "sent_105mm" && ent:GetClass() != "sent_105mm") || (attacker:GetClass() == "sent_40mm" && ent:GetClass() != "sent_40mm") )) then 
		dmginfo:SetInflictor(inflictor:GetOwner())
		dmginfo:SetAttacker(attacker.Owner)
	elseif ( inflictor:GetClass() == "sent_predator_missile" ) then 
		dmginfo:SetAttacker(inflictor.Owner)
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
hook.Add("EntityTakeDamage", "KillStreakBombings", damageInfo)