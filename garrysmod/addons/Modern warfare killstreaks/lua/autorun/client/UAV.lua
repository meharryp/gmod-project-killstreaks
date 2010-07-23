local sweepTexture = surface.GetTextureID("VGUI/killStreak_misc/uavsweep")

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

local function drawUAV()
lpl = LocalPlayer();
	local CamData = {}
	CamData.angles = Angle(90,0,0)
	CamData.origin = lpl:GetPos() + Vector(0,0,cameraPos)
	CamData.x = x
	CamData.y = y
	CamData.w = width
	CamData.h = height
	CamData.drawviewmodel = false;
	render.RenderView( CamData )
	
	area = Vector(500,500,500)
	aimVector = lpl:GetAimVector()
	
	draw.RoundedBox(4, centerX - 4,  centerY - 4, 8, 8, Color(0,0,255,255))				
	surface.DrawLine(centerX, centerY, centerX + (lineLength * (aimVector.y * -1) ), centerY + (lineLength * (aimVector.x * -1)))
	
	for k, v in pairs(entsInVicenity) do
			pos = lpl:GetPos() - v;
			newX = pos.x/scaleFactor;
			newY = pos.y/scaleFactor;
			targetX = centerY + newY;
			targetY = centerX + newX;
			targetX = math.Clamp(targetX, 20, 270)
			targetY = math.Clamp(targetY, 20, 270)
			draw.RoundedBox(4, targetX ,  targetY , 8, 8, Color(255,0,0,255))				
	end
	
	if sweepPos > 20 then
--		timer.Pause("UavSweep");
		surface.SetTexture(sweepTexture)
		surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
		surface.DrawTexturedRect(sweepPos, 20, 16, uavBoxSize)
	else
		--timer.UnPause("UavSweep");
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
end

function start()
	playUAVDeploySound();
	UavSweep();
	hook.Add( "HUDPaint", "UAV", drawUAV )
	timer.Create("UAV_stopTimer",30,1, killUav)
	timer.Create("UAV_redrawTimer",3,0, UavSweep)
	timer.Create("UavSweeper", 0.005,0,moveSweep)
end

function playUAVDeploySound()
	surface.PlaySound("killstreak_rewards/uav_deploy" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

usermessage.Hook("uavStart", start)