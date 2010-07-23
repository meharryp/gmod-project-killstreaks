
include('shared.lua')

local tex = surface.GetTextureID("VGUI/killStreak_misc/callin")
local arrow = surface.GetTextureID("VGUI/killStreak_misc/arrow")
local imageSize = 64

local centerX = ScrW()/2;
local centerY = ScrH()/2
local picturePossitonX = centerX - imageSize/2;
local picturePossitonY = centerY - imageSize/2;

local arrowPosX = centerX 
local arrowPosY = centerY

local arrowHeight = 32

local edge = arrowHeight + arrowHeight/2

local function DrawStealthMarker()
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(picturePossitonX, picturePossitonY, imageSize, imageSize)	
	surface.SetTexture(arrow)
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	DrawArrow(LocalPlayer():GetNetworkedInt("StealthMarkerAngle"));
	return true;
end

function DrawArrow(angle)
	if angle == 0 then
		surface.DrawTexturedRectRotated(arrowPosX, arrowPosY - edge, 32, 32, 0)	-- 					X = 640, 	Y = 464	
	elseif angle == 45 then
		surface.DrawTexturedRectRotated(arrowPosX - edge/1.5, arrowPosY - edge/1.5, 32, 32, 45)	--	X = 608,	Y = 480	
	elseif angle == 90 then
		surface.DrawTexturedRectRotated(arrowPosX - edge, arrowPosY, 32, 32, 90)	-- 				X = 592,	Y = 512
	elseif angle == 135 then
		surface.DrawTexturedRectRotated(arrowPosX - edge/1.5, arrowPosY + edge/1.5, 32, 32, 135)--	X = 608,	Y = 544
	elseif angle == 180 then
		surface.DrawTexturedRectRotated(arrowPosX, arrowPosY + edge, 32, 32, 180)	--				X = 640,	Y = 560
	elseif angle == 225 then
		surface.DrawTexturedRectRotated(arrowPosX + edge/1.5, arrowPosY + edge/1.5, 32, 32, 225)--	X = 672,	Y = 544
	elseif angle == 270 then
		surface.DrawTexturedRectRotated(arrowPosX + edge, arrowPosY, 32, 32, 270)	--				X = 688,	Y = 512
	elseif angle == 315 then
		surface.DrawTexturedRectRotated(arrowPosX + edge/1.5, arrowPosY - edge/1.5, 32, 32, 315)--	X = 672,	Y = 480	
	end
end

local function drawHud()
	hook.Add("HUDPaint","DrawStealthMarker",DrawStealthMarker)
end
local function removeHud()
	hook.Remove("HUDPaint","DrawStealthMarker")
end

usermessage.Hook("Stealth_bomber_SetUpHUD", drawHud)
usermessage.Hook("Stealth_bomber_RemoveHUD", removeHud)