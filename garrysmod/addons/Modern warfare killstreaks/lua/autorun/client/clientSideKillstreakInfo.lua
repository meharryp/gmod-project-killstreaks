//if !MW2KillStreakAddon then return end
predMissileDeploy = Sound("killstreak_rewards/predator_missile_deploy.wav");
harrierLaptopDeploy = Sound("killstreak_rewards/harrier_laptop.wav");

function playPredatorMissileDeploy()
	surface.PlaySound(predMissileDeploy)
end

function playPredatorMissileInbound()
	surface.PlaySound("killstreak_rewards/predator_missile_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

function playHarrierLaptopDeploy()
	surface.PlaySound(harrierLaptopDeploy);
end

function playHarrierInbound()
	surface.PlaySound("killstreak_rewards/harrier_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

function playPrecisionAirstrikeInbound()
	surface.PlaySound("killstreak_rewards/precision_airstrike_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

function playAC130Deploy()
	surface.PlaySound("killstreak_rewards/ac-130_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav")
end

function killstreakSpawnError()
	local DLabel1
	local ACE

	ACE = vgui.Create('DFrame')
	ACE:SetSize(357, 66)
	ACE:Center()
	ACE:SetTitle('Killstreak Error')
	ACE:SetBackgroundBlur(true)
	ACE:MakePopup()

	DLabel1 = vgui.Create('DLabel')
	DLabel1:SetParent(ACE)
	DLabel1:SetPos(18, 35)
	DLabel1:SetText("You can't use the aquired killstreak here, Reason: Not enough room")
	DLabel1:SizeToContents()
end

usermessage.Hook("playPredatorMissileDeploySound", playPredatorMissileDeploy)
usermessage.Hook("playPredatorMissileInboundSound", playPredatorMissileInbound)
usermessage.Hook("playHarrierLaptopDeploySound", playHarrierLaptopDeploy)
usermessage.Hook("playHarrierInboundSound", playHarrierInbound)
usermessage.Hook("playPrecisionAirstrikeInboundSound", playPrecisionAirstrikeInbound)
usermessage.Hook("playAC130DeploySound", playAC130Deploy)
usermessage.Hook("ShowKillstreakSpawnError", killstreakSpawnError)

killicon.Add("sent_predator_missile","vgui/killicons/predator_missile",Color ( 255, 255, 255, 255 ) )
killicon.Add("sent_air_strike_bomb","vgui/killicons/precision_air_strike",Color ( 255, 255, 255, 255 ) ) 
killicon.Add("sent_harrier","vgui/killicons/harrier",Color ( 255, 255, 255, 255 ) ) -- this was added
killicon.Add("sent_ac-130","vgui/killicons/ac-130",Color ( 255, 255, 255, 255 ) ) 
killicon.AddAlias( "sent_105mm", "sent_ac-130" )
killicon.AddAlias( "sent_40mm", "sent_ac-130" )
killicon.AddAlias( "sent_bomblet", "sent_air_strike_bomb" )