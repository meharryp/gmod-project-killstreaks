
include('shared.lua')

local tex = surface.GetTextureID("VGUI/killStreak_misc/callin")
local imageSize = 64

local centerX = ScrW()/2;
local centerY = ScrH()/2
local picturePossitonX = centerX - imageSize/2;
local picturePossitonY = centerY - imageSize/2;

function drawMarker()
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(picturePossitonX, picturePossitonY, imageSize, imageSize)	
	return true;
end
function drawHud()
	hook.Add("HUDPaint","DrawHarrierMarker",drawMarker)
end
function removeHud()
	hook.Remove("HUDPaint","DrawHarrierMarker")
end

usermessage.Hook("Harrier_Strike_SetUpHUD", drawHud)
usermessage.Hook("Harrier_Strike_RemoveHUD", removeHud)