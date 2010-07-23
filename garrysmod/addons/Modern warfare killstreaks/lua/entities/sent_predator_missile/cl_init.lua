
include('shared.lua')

local tarpos;
local pos;
local dist;
local color;
local friendlys = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }
function drawHUD()

	render_Crosshair();
	allEnts = ents.GetAll();

	for k, v in pairs(allEnts) do
		if v:IsPlayer() or v:IsNPC() then
			tarpos = v:GetPos() + Vector(0,0,v:OBBMaxs().z * .5)
			pos = tarpos:ToScreen()			
			dist = 25;
			color = teamColor(v);
			if color == 0 then
				surface.SetDrawColor(0,0,255,255)
			elseif color == 1 then
				surface.SetDrawColor(0,255,0,255)
			elseif color == 2 then
				surface.SetDrawColor(255,0,0,255)
			end		
			
			surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist)
		end
	end
	return true;
end

function teamColor(ent)
	local lpl = LocalPlayer();
	if ent:IsPlayer() and ent != lpl then 
		if ent:Team() == lpl:Team() then 
			return 1;
		else
			return 2;
		end
	elseif ent:IsNPC() then
		if table.HasValue(friendlys, ent:GetClass()) then
			return 1;
		else
			return 2;
		end
	elseif ent == lpl then
		return 0;
	end	
	return -1
end

local width = 120;
local height = 60;
local lineLength = 100;
local cornorLength = 35;
local centerX = ScrW()/2;
local centerY = ScrH()/2
local distanceFromCenter = 350;
function render_Crosshair()
	surface.SetDrawColor(149,149,149,255)
    surface.DrawOutlinedRect( centerX - width/2, centerY - height/2, width, height ) -- Draws the middle square
	
	surface.DrawLine(centerX - width/2, centerY, (centerX - width/2) - lineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + width/2, centerY, (centerX + width/2) + lineLength, centerY); -- Draws the horizontal line on the right
	surface.DrawLine(centerX, centerY - height/2, centerX , (centerY - height/2) - lineLength); -- Draws the vertical line on the top
	surface.DrawLine(centerX, centerY + height/2, centerX , (centerY + height/2) + lineLength); -- Draws the vertical line on the bottom
	
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornorLength, centerY - distanceFromCenter) -- upper left cornor
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter), (centerY - distanceFromCenter) + cornorLength) --
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornorLength, centerY + distanceFromCenter) -- bottom left cornor
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter), (centerY + distanceFromCenter) - cornorLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornorLength, centerY - distanceFromCenter) -- upper right cornor
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter), (centerY - distanceFromCenter) + cornorLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornorLength, centerY + distanceFromCenter) -- bottom right cornor
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter), (centerY + distanceFromCenter) - cornorLength) --
	----------------------------------------------------
end

function screenContrast()
 
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

function setUpHUD()
	hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOO", screenContrast )
	hook.Add("HUDPaint", "TargetEffect", drawHUD)	
end
function removeHUD()
	hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOO")
	hook.Remove("HUDPaint", "TargetEffect")	
end

usermessage.Hook("Predator_missile_SetUpHUD", setUpHUD)
usermessage.Hook("Predator_missile_RemoveHUD", removeHUD)
