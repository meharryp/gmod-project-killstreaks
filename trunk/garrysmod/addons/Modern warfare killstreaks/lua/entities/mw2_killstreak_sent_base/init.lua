AddCSLuaFile( "cl_init.lua" )
IncludeClientFile("cl_init.lua")
include( 'shared.lua' )
--[[
function ENT:PhysicsUpdate()
end

function ENT:Think()
end

function ENT:Initialize()
end
]]
function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:FindSky()

	local maxheight = 16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,maxheight);
	local filterList = {}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local skyLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			//MsgN("Hit the sky")
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
			//MsgN("hit the world, not the sky")
		else 
			//Msg("Hit ")
			//MsgN(traceData.Entity:GetClass());
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 300 then
			MsgN("Reached max number here, no luck in finding a skyBox");
			bool = false;
		end
	end
	
	return skyLocation;
end

function ENT:findGround()

	local minheight = -16384
	local startPos = self.Owner:GetPos()
	local endPos = Vector(startPos.x, startPos.y,minheight);
	local filterList = {self.Owner, self}

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

function ENT:SetDropLocation(vec)
	self.TestDropLoc = vec;
	MsgN("Loc = " .. tostring(self.TestDropLoc))
end

function ENT:OpenOverlayMap()
	umsg.Start("MW2_DropLoc_Overlay_UM", self.Owner);
		umsg.Entity(self);
	umsg.End();
end

local function SetLocation( pl, handler, id, encoded, decoded ) -- this data stream allows the client to reset the killstreak, so if you recive two of the same killstreak right after the other it will playthe notification for both
	decoded[1]:SetDropLocation( decoded[2] )
end
datastream.Hook( "MW2_DropLocation_Overlay_Stream", SetLocation )