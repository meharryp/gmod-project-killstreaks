require("datastream")
if not ( CLIENT ) then return end
//if !MW2KillStreakAddon then return end
local aquiredKillStreaks = {};
local centerX = ScrW()/2;
local centerY = ScrH()/2
local picturePossitonX = centerX - 256;
//local picturePossitonY = centerY - 500
local picturePossitonY = 0
local width, height;
local curKillIconX = ScrW() - 100;
local curKillIconY = ScrH() - 150;
local playOnce = true;
local lastKillStreak = "";
local streak = "";
local AddedKillStreakHook = false;
function drawAddedKillStreaks()		
	streak = LocalPlayer():GetNetworkedString("AddKillStreak");
	if streak == "none" || streak == nil || streak == "nil" || lastKillStreak == streak then return end;
	AddedKillStreakHook = true;
	
	surface.SetTexture(surface.GetTextureID("VGUI/killstreaks/" .. streak))
	
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(picturePossitonX, picturePossitonY, 512, 256)
	
	if playOnce then
		playAcquiredSound(streak)
		playOnce = false;
	end
end

function addHook_AddedKillStreaks()
	if AddedKillStreakHook then
		RunConsoleCommand("Stopsounds")
		removeHook_AddedKillStreaks()
		timer.Destroy("AddedKillstreaks_Timer");
	end
	table.insert(aquiredKillStreaks, LocalPlayer():GetNetworkedString("AddKillStreak"));
	playOnce = true;
	hook.Add("HUDPaint", "AddedKillStreaks", drawAddedKillStreaks);
	timer.Create("AddedKillstreaks_Timer",2,1, removeHook_AddedKillStreaks)
end

function removeHook_AddedKillStreaks()
	AddedKillStreakHook = false;
	lastKillStreak = streak;	
	//datastream.StreamToServer( "MW2KillstreakCounter_ResetStreak" )
	hook.Remove("HUDPaint", "AddedKillStreaks");	
end

function drawAvaliabeKillStreak()	
	availableStreak = LocalPlayer():GetNetworkedString("AddKillStreak");
	
	str = availableStreak;
	if str == nil || str == "nil" || str == "none" || str == "" then return end
	availableStreak = "VGUI/killstreaks/animated/" .. str;
	surface.SetTexture(surface.GetTextureID( availableStreak))
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(curKillIconX, curKillIconY, 44, 44)
end

function removeUsedKillStreak()
	table.remove(aquiredKillStreaks);	
end

function playAcquiredSound(soundName)
	if soundName == "stealth_bomber" then
		soundName = "precision_airstrike";
	end
	surface.PlaySound("killstreak_rewards/" .. soundName .. "_acquired" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

function playerDies( victim, weapon, killer )
	lastKillStreak = "";
end

usermessage.Hook("RemoveUsedKillStreak", removeUsedKillStreak)
usermessage.Hook("AddKillStreak", addHook_AddedKillStreaks)
hook.Add("HUDPaint", "DrawAvaliabeKillStreaks", drawAvaliabeKillStreak)
usermessage.Hook( "ResetKillStreakIcon", playerDies )