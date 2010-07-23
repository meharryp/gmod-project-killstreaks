include('shared.lua')
local Countdown = Sound("killstreak_rewards/tactical_nuke_countdown.wav")
local function drawNukeCountDownHUD()
	
	local nukeTime = GetGlobalString("MW2_Nuke_CountDown_Timer")
	
	local nukeString = "";
	if string.len(nukeTime) > 3 then	
		nukeString = "0:0" .. string.sub(nukeTime, 1, 3);
	else
		nukeString = "0:0" .. nukeTime;
	end
	
	surface.SetTexture(surface.GetTextureID("VGUI/killstreaks/animated/tactical_nuke"))
	
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(200 - 32, 20 , 64, 64)
	surface.CreateFont ("BankGothic Md BT", 20, 400, true, false, "MW2Font")
	surface.SetFont("MW2Font")
	surface.SetTextColor( 255, 255, 255, 255 )
    surface.SetTextPos( 200 - 20 , 15 + 32  )
    surface.DrawText( nukeString )	
end


function NukeSetUpHUD()
	hook.Add("HUDPaint", "NukeCountDownEffect", drawNukeCountDownHUD)
	surface.PlaySound(Countdown)
	timer.Simple(1, playNukeInboundSound);
end

function playNukeInboundSound()
	local teamType = "";
	
	if GetGlobalString("MW2_Nuke_Player") == LocalPlayer():GetName() then
		teamType = "friendly";
	else 
		teamType = "enemy";
	end
	surface.PlaySound("killstreak_rewards/Tactical_Nuke_" .. teamType .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	
end

function NukeRemoveHUD()
	hook.Remove("HUDPaint", "NukeCountDownEffect")	
end

usermessage.Hook("MW2_Nukes_SetUpHUD", NukeSetUpHUD)
usermessage.Hook("MW2_Nuke_RemoveHUD", NukeRemoveHUD)