require("datastream")
if not ( CLIENT ) then return end
//if !MW2KillStreakAddon then return end
local centerX = ScrW()/2;
local centerY = ScrH()/2
local picturePossitonX = centerX - 256;
local picturePossitonY = 0
local curKillIconX = ScrW() - 100;
local curKillIconY = ScrH() - 150;
local streak = "";
local oldId = 0;
local showNewKillstreak = false;
local curStreak = nil;
local id = 0;

local function playAcquiredSound(soundName)//
	if soundName == "stealth_bomber" then
		soundName = "precision_airstrike";
	end
	surface.PlaySound("killstreak_rewards/" .. soundName .. "_acquired" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

local function drawAddedKillStreak()
	
	if curStreak == nil || id <= oldId then
		local str = LocalPlayer():GetNetworkedString("MW2NewKillstreak");		
		local Sep = string.Explode("+", str)
		curStreak = Sep[1];
		
		if Sep[2] != nil then id = tonumber(Sep[2]); end	
		
	elseif curStreak != nil && id > oldId then		
		streak = curStreak;
		
		playAcquiredSound(streak)
		showNewKillstreak = true;
		timer.Create("AddedKillstreaks_Timer",2,1, function()
			showNewKillstreak = false;
		end)
		oldId = id;
	end
	if !showNewKillstreak then return; end
	
	if streak == "none" || streak == nil then return end;	
	
	surface.SetTexture(surface.GetTextureID("VGUI/killstreaks/" .. streak))	
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(picturePossitonX, picturePossitonY, 512, 256)
end
hook.Add("HUDPaint", "DrawAddedMW2KillStreaks", drawAddedKillStreak)

local function drawAvaliabeKillStreak()	
	local availableStreak = LocalPlayer():GetNetworkedString("CurrentMW2KillStreak");
	
	str = availableStreak;
	if str == nil || str == "none" || str == "" then return end
	availableStreak = "VGUI/killstreaks/animated/" .. str;
	surface.SetTexture(surface.GetTextureID( availableStreak))
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(curKillIconX, curKillIconY, 44, 44)
end
hook.Add("HUDPaint", "DrawAvaliabeMW2KillStreaks", drawAvaliabeKillStreak)