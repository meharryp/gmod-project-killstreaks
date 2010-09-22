include('shared.lua')

local Alpha = 255;
local alphaDelay = .01
local alphaTimer = CurTime();
local usersTeam = -1;

function FireMW2EMPEffect()
	if Alpha > 0 then
		drawFlash();
	end
	
	if usersTeam != LocalPlayer():Team() then
		-- Remove teams hud
	end
	
end

function drawFlash()
	surface.SetDrawColor(255, 255, 255, Alpha)
	surface.DrawRect(0, 0, surface.ScreenWidth(), surface.ScreenHeight())
	if alphaTimer <= CurTime() then
		Alpha = Alpha - 1;
		alphaTimer = CurTime() + alphaDelay;
	end
end

function MW2_EMP_Effect( data )
	usersTeam = data:ReadShort();
	hook.Add("HUDPaint", "MW2_EMP_Effect", FireMW2EMPEffect)	
end

function MW2_Clear_EMP()
	hook.Remove("HUDPaint", "MW2_EMP_Effect")	
end

usermessage.Hook("MW2_EMP_FireEMP", MW2_EMP_Effect)
usermessage.Hook("MW2_EMP_RemoveEMP", MW2_Clear_EMP)