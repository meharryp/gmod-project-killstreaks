include('shared.lua')

local sweepTexture = surface.GetTextureID("VGUI/killStreak_misc/uavsweep")

local isActive = false;
local totalActive = 0;

local uavBoxSize = 250;
local x = 20;
local y = 20;
local width = uavBoxSize;
local height = uavBoxSize;
local edge = 270;
local sweepPos = 0;
local cameraPos = 1000
local centerX = x + width/2;
local centerY = y + height/2;
local scaleFactor = ((cameraPos *2)/1.5)/uavBoxSize
local lineLength = 10
local entsInVicenity = {}
local friendlys = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }
local enemyColor = Color(255,0,0,255);
local friendlyColor = Color(0,255,0,255);

local UavSweepBase = 3;
local UavBarBase = 0.005;
local UavSweepNew = 0;
local UavBarNew = 0;

local function drawUAV()
	local lpl = LocalPlayer();
	local CamData = {}
		CamData.angles = Angle(90,0,0)
		CamData.origin = lpl:GetPos() + Vector(0,0,cameraPos)
		CamData.x = x
		CamData.y = y
		CamData.w = width
		CamData.h = height
		CamData.drawviewmodel = false;
	render.RenderView( CamData )
	
	local aimVector = lpl:GetAimVector()
	
	draw.RoundedBox(4, centerX - 4,  centerY - 4, 8, 8, Color(0,0,255,255))				
	surface.DrawLine(centerX, centerY, centerX + (lineLength * (aimVector.y * -1) ), centerY + (lineLength * (aimVector.x * -1)))
	
	for k, v in pairs(entsInVicenity) do
			local pos = lpl:GetPos() - v;
			local newX = pos.x/scaleFactor;
			local newY = pos.y/scaleFactor;
			local targetX = centerY + newY;
			local targetY = centerX + newX;
			local targetX = math.Clamp(targetX, 20, 270)
			local targetY = math.Clamp(targetY, 20, 270)
			draw.RoundedBox(4, targetX ,  targetY , 8, 8, Color(255,0,0,255))				
	end
	
	if sweepPos > 20 then
		surface.SetTexture(sweepTexture)
		surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
		surface.DrawTexturedRect(sweepPos, 20, 16, uavBoxSize)
	end
	
end

function findTeamColor(ent)
	local lpl = LocalPlayer();
	if ent:IsPlayer() then 
		if ent:Team() == lpl:Team() then 
			return friendlyColor;
		else
			return enemyColor;
		end
	elseif ent:IsNPC() then
		if table.HasValue(friendlys, ent:GetClass()) then
			return friendlyColor;
		else
			return enemyColor;
		end
	end	
end

function UavSweep()
	sweepPos = edge - 8;
	local lpl = LocalPlayer();
	entsInVicenity = {}
	tempEnts = ents.GetAll( );
	for k, v in pairs(tempEnts) do
		if v:IsNPC() or (v:IsPlayer() and not lpl) then
			entsInVicenity[k] = v:GetPos();
		end
	end
end

function moveSweep()
	sweepPos = sweepPos - 4
end

function killUav()
	timer.Stop("UAV_redrawTimer");
	timer.Stop("UavSweeper");
	timer.Stop("UAV_stopTimer");
	hook.Remove("HUDPaint", "UAV");
	totalActive = 0;
	isActive = false;
end

function start()
	playUAVDeploySound();
	totalActive = totalActive + 1;
	
	if isActive then
		if totalActive <= 3 then
			UavSweepNew = UavSweepBase - ( totalActive / 1.25 );
			UavBarNew = UavBarBase * (totalActive + 2 );
			timer.Adjust("UAV_redrawTimer", UavSweepNew, 0, UavSweep)
			timer.Adjust("UavSweeper", UavBarNew, 0, moveSweep)
		end
		return;
	end	
	
	UavSweep();
	hook.Add( "HUDPaint", "UAV", drawUAV )
	//timer.Create("UAV_stopTimer",30,1, killUav)
	timer.Create("UAV_redrawTimer", UavSweepBase, 0, UavSweep)
	timer.Create("UavSweeper", UavBarBase, 0, moveSweep)	
	if !isActive then
		isActive = true;
	end		
end

function playUAVDeploySound()
	surface.PlaySound("killstreak_rewards/uav_deploy" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

usermessage.Hook("MW2_UAV_Start", start)
usermessage.Hook("MW2_UAV_End", killUav)