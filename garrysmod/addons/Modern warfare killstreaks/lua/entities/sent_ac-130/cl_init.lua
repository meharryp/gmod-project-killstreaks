
include('shared.lua')

local tarpos;
local pos;
local dist;
local color;
local friendlys = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }
local UseThermal;
local isInVehicle = false;
local PlayVoice = false;
local playerInVehicle = NULL;
local AC130IdleInsideSound = Sound("ac-130_kill_sounds/AC130_idle_inside.mp3")
AC130Idele = nil; //= CreateSound(LocalPlayer(), AC130IdleInsideSound )

local function drawAC130HUD()
	textWhiteColor = Color(255,255,255,255)
	unusedGunColor = Color(255,255,255,127)
	blinkingColor = Color(255,255,255,math.sin(RealTime() * 16) * 127.5 + 127.5)
	ac130weapon = LocalPlayer():GetNetworkedInt("Ac_130_weapon")
	Is105mmReloading = LocalPlayer():GetNetworkedBool("Ac_130_105mmReloading")
	Is40mmReloading = LocalPlayer():GetNetworkedBool("Ac_130_40mmReloading")
	Is25mmReloading = LocalPlayer():GetNetworkedBool("Ac_130_25mmReloading")
	local ac130weapon = LocalPlayer():GetNetworkedInt("Ac_130_weapon")
	if ac130weapon == 0 then
		Crosshair_105mm()
	elseif ac130weapon == 1 then
		Crosshair_40mm()
	elseif ac130weapon == 2 then
		Crosshair_25mm()
	end
	
	local sen = 0;
	if ac130weapon == 0 then	
		sen = LocalPlayer():GetFOV() / 90;
	elseif ac130weapon == 1 then
		sen = LocalPlayer():GetFOV() / 105;
	else
		sen = LocalPlayer():GetFOV() / 53;
	end
	LocalPlayer():GetActiveWeapon().MouseSensitivity = sen

	
	allEnts = ents.GetAll();

	for k, v in pairs(allEnts) do
		if v:IsPlayer() && v != LocalPlayer() && PlayVoice then
			tarpos = v:GetPos() + Vector(0,0,v:OBBMaxs().z * .5)
			pos = tarpos:ToScreen()			
			dist = 40;
			color = teamColor(v);
			if v:Team() != LocalPlayer():Team() then
				surface.SetDrawColor(255,0,0,255)
				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist)
			else
				surface.SetDrawColor(0,255,0,255)
				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist)
			end
		elseif v:IsNPC() then
			tarpos = v:GetPos() + Vector(0,0,v:OBBMaxs().z * .5)
			pos = tarpos:ToScreen()			
			dist = 40;
			if table.HasValue(friendlys, v:GetClass()) then
			else
				surface.SetDrawColor(255,0,0,255)
				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist)
			end
		elseif v:IsPlayer() && v==LocalPlayer() then
			lplpos = LocalPlayer():GetPos()
			lpltarpos = lplpos:ToScreen()
			surface.SetDrawColor(0,255,0,255)
			surface.DrawLine(lpltarpos.x-25,lpltarpos.y,lpltarpos.x+25,lpltarpos.y)
			surface.DrawLine(lpltarpos.x,lpltarpos.y-25,lpltarpos.x,lpltarpos.y+25)
		end
	end
	
	acTime = string.ToMinutesSeconds(LocalPlayer():GetNetworkedInt("Ac_130_Time"))
	
	if ScrH() >= 1000 then
		textFont = "HUDNumber5"
	elseif ScrH() <=1000 then
		textFont = "HUDNumber4"
	elseif ScrH() <=900 then
		textFont = "HUDNumber3"
	elseif ScrH() <=700 then
		textFont = "HUDNumber2"
	elseif ScrH() <=600 then
		textFont = "HUDNumber"
	end

	draw.SimpleText("0   A-G  MAN NARO",textFont,25,25,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("RAY",textFont,25,65,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("FF 30",textFont,25,105,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("LIR",textFont,25,145,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("BORE",textFont,25,225,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("L1514",textFont,ScrW()/2,ScrH()-50,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText("RDY",textFont,ScrW()/2+20,ScrH()-50,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText(acTime,textFont,ScrW()/4*3,ScrH()-50,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText(acHUDXPos,textFont,ScrW()-25,5,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText(acHUDYPos,textFont,ScrW()-150,5,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText(acHUDAGL.." AGL",textFont,ScrW()-25,45,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	if UseThermal then
		if ThermalBlackMode then
			draw.SimpleText("BHOT",textFont,ScrW()-100,85,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		else
			draw.SimpleText("WHOT",textFont,ScrW()-100,85,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		end
	end
	if ScrH() >= 750 then
		draw.SimpleText("N",textFont,ScrW()-25,ScrH()/2-250,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2-200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("S",textFont,ScrW()-25,ScrH()/2-100,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("F",textFont,ScrW()-25,ScrH()/2-50,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Q",textFont,ScrW()-25,ScrH()/2+50,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Z",textFont,ScrW()-25,ScrH()/2+100,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("G",textFont,ScrW()-25,ScrH()/2+250,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+300,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	else
		draw.SimpleText("N",textFont,ScrW()-25,ScrH()/2-200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2-160,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("S",textFont,ScrW()-25,ScrH()/2-80,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("F",textFont,ScrW()-25,ScrH()/2-40,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Q",textFont,ScrW()-25,ScrH()/2+40,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Z",textFont,ScrW()-25,ScrH()/2+80,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+160,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("G",textFont,ScrW()-25,ScrH()/2+200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+240,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	end
	if ac130weapon == 0 then
		draw.SimpleText("105mm",textFont,25,ScrH()-50,blinkingColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("40mm",textFont,25,ScrH()-90,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("25mm",textFont,25,ScrH()-130,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	elseif ac130weapon == 1 then
		draw.SimpleText("105mm",textFont,25,ScrH()-50,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("40mm",textFont,25,ScrH()-90,blinkingColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("25mm",textFont,25,ScrH()-130,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	elseif ac130weapon == 2 then	
		draw.SimpleText("105mm",textFont,25,ScrH()-50,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("40mm",textFont,25,ScrH()-90,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("25mm",textFont,25,ScrH()-130,blinkingColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)	
	end
	
	//return true;
end

function CheckForVehicle(ply)
	
	if ( ( !ply:InVehicle() && ply == playerInVehicle ) || !playerInVehicle:IsValid() ) && isInVehicle then
		playerInVehicle = NULL;
		isInVehicle = false;
	end
	
	if ply:InVehicle() && !isInVehicle then
		playerInVehicle = ply;
		isInVehicle = true;
		surface.PlaySound("ac-130_kill_sounds/clear_to_engage.wav")
	end
end

function Crosshair_105mm()
	local width = 120;
	local height = 60;
	local lineLength = 100;
	local cornerLength = 35;
	local centerX = ScrW()/2;
	local centerY = ScrH()/2;
	distanceFromCenter = 250
	
	if Is105mmReloading then
		surface.SetDrawColor(255,255,255,math.sin(RealTime() * 8) * 127.5 + 127.5) 			//--surface.SetDrawColor(blinkingColor)
	else
		surface.SetDrawColor(textWhiteColor)
	end
	
    surface.DrawOutlinedRect( centerX - width/2, centerY - height/2, width, height ) -- Draws the middle square
	
	surface.DrawLine(centerX - width/2, centerY, (centerX - width/2) - lineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + width/2, centerY, (centerX + width/2) + lineLength, centerY); -- Draws the horizontal line on the right
	surface.DrawLine(centerX, centerY - height/2, centerX , (centerY - height/2) - lineLength); -- Draws the vertical line on the top
	surface.DrawLine(centerX, centerY + height/2, centerX , (centerY + height/2) + lineLength); -- Draws the vertical line on the bottom
	
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY - distanceFromCenter) -- upper left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY + distanceFromCenter) -- bottom left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY - distanceFromCenter) -- upper right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY + distanceFromCenter) -- bottom right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
end

function Crosshair_40mm()
	local width = 60;
	local height = 60;
	local hlineLength = 280;
	local vlineLength = 225;
	local centerX = ScrW()/2;
	local centerY = ScrH()/2

	if Is40mmReloading then
		surface.SetDrawColor(255,255,255,math.sin(RealTime() * 8) * 127.5 + 127.5) 			//--surface.SetDrawColor(blinkingColor)
	else
		surface.SetDrawColor(textWhiteColor)
	end

	surface.DrawLine(centerX - width/2, centerY, (centerX - width/2) - hlineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + width/2, centerY, (centerX + width/2) + hlineLength, centerY); -- Draws the horizontal line on the right
	
	surface.DrawLine(centerX - width/2 - 40, centerY - 10, centerX - width/2 - 40, centerY + 10); 
	surface.DrawLine(centerX - width/2 - 40*3, centerY - 10, centerX - width/2 - 40*3, centerY + 10); 
	surface.DrawLine(centerX - width/2 - 40*5, centerY - 10, centerX - width/2 - 40*5, centerY + 10); 
	surface.DrawLine(centerX - width/2 - 40*7, centerY - 20, centerX - width/2 - 40*7, centerY + 20); 
	
	surface.DrawLine(centerX + width/2 + 40, centerY - 10, centerX + width/2 + 40, centerY + 10); 
	surface.DrawLine(centerX + width/2 + 40*3, centerY - 10, centerX + width/2 + 40*3, centerY + 10); 
	surface.DrawLine(centerX + width/2 + 40*5, centerY - 10, centerX + width/2 + 40*5, centerY + 10); 
	surface.DrawLine(centerX + width/2 + 40*7, centerY - 20, centerX + width/2 + 40*7, centerY + 20); 
	
	surface.DrawLine(centerX, centerY - height/2, centerX , (centerY - height/2) - vlineLength); -- Draws the vertical line on the top
	
	surface.DrawLine(centerX - 10, centerY - height/2 - 45, centerX + 10 , (centerY - height/2) - 45);
	surface.DrawLine(centerX - 10, centerY - height/2 - 45*3, centerX + 10, (centerY - height/2) - 45*3);
	surface.DrawLine(centerX - 20, centerY - height/2 - 45*5, centerX + 20 , (centerY - height/2) - 45*5);
		
	surface.DrawLine(centerX, centerY + height/2, centerX , (centerY + height/2) + vlineLength); -- Draws the vertical line on the bottom
	
	surface.DrawLine(centerX - 10, centerY + height/2 + 45, centerX + 10 , (centerY + height/2) + 45);
	surface.DrawLine(centerX - 10, centerY + height/2 + 45*3, centerX + 10, (centerY + height/2) + 45*3);
	surface.DrawLine(centerX - 20, centerY + height/2 + 45*5, centerX + 20 , (centerY + height/2) + 45*5);
end

function Crosshair_25mm()
	local width = 120;
	local height = 60;
	local lineLength = 100;
	local cornerLength = 35;
	local centerX = ScrW()/2;
	local centerY = ScrH()/2
	local distanceFromCenter = 150;
	local lineDistance = 6
	if Is25mmReloading then
		surface.SetDrawColor(255,255,255,math.sin(RealTime() * 8) * 127.5 + 127.5) 			//--surface.SetDrawColor(blinkingColor)
	else
		surface.SetDrawColor(textWhiteColor)
	end

	surface.DrawLine(centerX - lineDistance, centerY, (centerX - lineDistance) - lineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + lineDistance, centerY, (centerX + lineDistance) + lineLength, centerY); -- Draws the horizontal line on the right
	
	surface.DrawLine(centerX, centerY + lineDistance, centerX , (centerY + lineDistance) + lineLength); -- Draws the vertical line on the bottom
	
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY - distanceFromCenter) -- upper left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY + distanceFromCenter) -- bottom left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY - distanceFromCenter) -- upper right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY + distanceFromCenter) -- bottom right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + 6, centerY + 6, centerX + 16, centerY + 6)
	surface.DrawLine(centerX + 6, centerY + 6, centerX + 6, centerY + 16)
	----
	surface.DrawLine(centerX + 16, centerY + 16, centerX + 26, centerY + 16)
	surface.DrawLine(centerX + 16, centerY + 16, centerX + 16, centerY + 26)
	----
	surface.DrawLine(centerX + 26, centerY + 26, centerX + 36, centerY + 26)
	surface.DrawLine(centerX + 26, centerY + 26, centerX + 26, centerY + 36)
	----
	surface.DrawLine(centerX + 36, centerY + 36, centerX + 46, centerY + 36)
	surface.DrawLine(centerX + 36, centerY + 36, centerX + 36, centerY + 46)
	----
	surface.DrawLine(centerX + 46, centerY + 46, centerX + 56, centerY + 46)
	surface.DrawLine(centerX + 46, centerY + 46, centerX + 46, centerY + 56)
	----
	surface.DrawLine(centerX + 56, centerY + 56, centerX + 66, centerY + 56)
	surface.DrawLine(centerX + 56, centerY + 56, centerX + 56, centerY + 66)
	----
end

function screenContrastWHOT()
 
	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = 1
	tab[ "$pp_colour_colour" ] = 0
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0 
 
	DrawColorModify( tab )
end

function screenContrastBHOT()
 
	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = 2
	tab[ "$pp_colour_colour" ] = 0
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0 
 
	DrawColorModify( tab )
end

function UpdatePosAgl()
	local sky = findGround() + 6000
	local spawnPos = LocalPlayer():GetPos() + (LocalPlayer():GetForward() * 2000)
	acHUDXPos = tostring(math.floor(spawnPos.x)+16384)
	acHUDYPos = tostring(math.floor(spawnPos.y)+16384)
	acHUDAGL = tostring(math.floor(sky)+16384)
	timer.Create("refreshTimer",2,0, UpdatePosAglNumbers)
end

function UpdatePosAglNumbers()
	acHUDXPos = tostring(math.floor(LocalPlayer():GetNetworkedInt("Ac_130_HUDXPos"))+16384)
	acHUDYPos = tostring(math.floor(LocalPlayer():GetNetworkedInt("Ac_130_HUDYPos"))+16384)
	acHUDAGL = tostring(math.floor(LocalPlayer():GetNetworkedInt("Ac_130_HUDAGL"))+16384)
end

local DefMats = {}	-- The heat vision is curtisy of Teta_Bonita's x-ray vison script
local DefClrs = {}
local material = "thermal/thermal"
function ThermalVision()
	if LocalPlayer():KeyPressed(IN_RELOAD) then
		if ThermalBlackMode == true then
			ThermalBlackMode = false
		else
			ThermalBlackMode = true
		end
	end
	local playerTable = player.GetAll();
	local npcTable = ents.FindByClass("npc_*");
	local targets = {};
	table.Add(targets, playerTable)
	table.Add(targets, npcTable)
	for k,v in pairs( targets ) do
		
		-- Inefficient, but not TOO laggy I hope
		local r,g,b,a = v:GetColor()
		local entmat = v:GetMaterial()

		if v:IsNPC() or v:IsPlayer() then -- It's alive!
			if ThermalBlackMode == false then
				if not (r == 255 and g == 255 and b == 255 and a == 255) then -- Has our color been changed?
					DefClrs[ v ] = Color( r, g, b, a )  -- Store it so we can change it back later
					v:SetColor( 255, 255, 255, 255 ) -- Set it back to what it should be now
				end
			else
				if v:IsNPC() then
					if not (r == 0 and g == 0 and b == 0 and a == 0) then -- Has our color been changed?
						DefClrs[ v ] = Color( r, g, b, a )  -- Store it so we can change it back later
						v:SetColor( 0, 0, 0, 255 ) -- Set it back to what it should be now
					end
				elseif v:IsPlayer() and v:Alive() then
					if not (r == 0 and g == 0 and b == 0 and a == 0) then -- Has our color been changed?
						DefClrs[ v ] = Color( r, g, b, a )  -- Store it so we can change it back later
						v:SetColor( 0, 0, 0, 255 ) -- Set it back to what it should be now
					end
				elseif v:IsPlayer() and v:Alive() == false then
					v:SetColor( 255,255,255,255 )
				end
			end
			
			if entmat ~= material then -- Has our material been changed?
				DefMats[ v ] = entmat -- Store it so we can change it back later
				v:SetMaterial( material ) -- The xray matierals are designed to show through walls
			end
			
		end
	end
	if ThermalBlackMode == true then
		hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT", screenContrastBHOT )
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT")
	else
		hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT", screenContrastWHOT )
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT")	
	end	
end

function removeThermalVision()
	hook.Remove( "RenderScene", "ThermalVision" )

	for ent,mat in pairs( DefMats ) do
		if ent:IsValid() then
			ent:SetMaterial( mat )
		end
	end

	for ent,clr in pairs( DefClrs ) do
		if ent:IsValid() then
			ent:SetColor( clr.r, clr.g, clr.b, clr.a )
		end
	end
	
	-- Clean up our tables- we don't need them anymore.
	DefMats = {}
	DefClrs = {}
end

function hideDefaultHUD(name)
	for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do
		if name == v then return false end
	end
end

function setUpHUD()
	ThermalBlackMode = false;
	hook.Add("HUDShouldDraw", "hideDefaultHUD", hideDefaultHUD)	;
	UseThermal = LocalPlayer():GetNetworkedBool("MW2AC130ThermalView");
	UpdatePosAgl()
	if UseThermal then
		hook.Add( "RenderScene", "ThermalVision", ThermalVision )
	end
	hook.Add("HUDPaint", "TargetEffect", drawAC130HUD)	
	timer.Simple(3, function()
		PlayVoice = true;
	end )
	AC130Idele = CreateSound(LocalPlayer(), AC130IdleInsideSound )
	AC130Idele:Play()
end

function removeHUD()
	AC130Idele:Stop()
	hook.Remove("HUDShouldDraw", "hideDefaultHUD");
	if ThermalBlackMode == true then
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT")
	else
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT")
	end
	hook.Remove("HUDPaint", "TargetEffect")	
	if UseThermal then
		removeThermalVision();
	end
	LocalPlayer():GetActiveWeapon().MouseSensitivity = 1
	
end

function PlayAC130KillSound(um)
	kills = um:ReadLong()
	//MsgN(kills)
	local soundName = NULL;
	
	if kills >=3 && kills <=5 then
		if math.random(0,1) == 0 then
			soundName = "nice";
		else
			soundName = "you_got_him";
		end
	elseif kills >= 6 && kills <=9 then
		if math.random(0,1) == 0 then
			soundName = "kaboom";
		else
			soundName = "thats_a_hit";
		end
		
	elseif kills >=10 then
		soundName = "little_pieces";
	end
	if soundName != NULL then
		surface.PlaySound("ac-130_kill_sounds/" .. soundName .. ".wav")
	end
end

function findGround()

	local minheight = -16384
	local startPos = LocalPlayer():GetPos()
	local endPos = Vector(0, 0,minheight);
	local filterList = {LocalPlayer()}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local groundLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitWorld then
			groundLocation = traceData.HitPos.z;			
			bool = false;
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the ground");
			bool = false;
		end		
	end
	
	return groundLocation;
end

function ErrorMessage()
	-- Lua generated by DermaDesigner

	local DLabel1
	local ACE

	ACE = vgui.Create('DFrame')
	ACE:SetSize(357, 66)
	ACE:Center()
	ACE:SetTitle('AC-130 Error')
	ACE:SetBackgroundBlur(true)
	ACE:MakePopup()

	DLabel1 = vgui.Create('DLabel')
	DLabel1:SetParent(ACE)
	DLabel1:SetPos(18, 35)
	DLabel1:SetText("You can't use the AC-130 in this map, Reason: Not enough room")
	DLabel1:SizeToContents()
end

usermessage.Hook("MW2_AC130_Kill_Sounds", PlayAC130KillSound)
usermessage.Hook("AC_130_SetUpHUD", setUpHUD)
usermessage.Hook("AC_130_RemoveHUD", removeHUD)
usermessage.Hook("AC_130_Error", ErrorMessage)
