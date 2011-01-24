AddCSLuaFile( "cl_init.lua" )
IncludeClientFile("cl_init.lua")
include( 'shared.lua' )

ENT.MapBounds = { };
ENT.Model = "";
ENT.Sky = 0;
ENT.playerSpeeds = {}
ENT.restrictMovement = false;
ENT.DropLoc = nil;
ENT.DropAng = nil;
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
	local startPos = Vector( 0,0, self.Sky) 
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

function ENT:FindBounds(xAxis)
	local height = self.Sky;
	local length = 16384
	local startPos = Vector(0,0,height);
	local endPos;
	if xAxis then 
		endPos = Vector(length, 0,height);
	elseif !xAxis then 
		endPos = Vector(0, length,height);
	end
	
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
	local wallLocation1 = -1;
	local wallLocation2 = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			if wallLocation1 == -1 then
				if xAxis then
					wallLocation1 = traceData.HitPos.x;
				elseif !xAxis then
					wallLocation1 = traceData.HitPos.y;
				end
				
				if xAxis then 
					endPos = Vector(length * -1, 0,height);
				elseif !xAxis then 
					endPos = Vector(0, length * -1,height);
				end
				
				trace = {}
				trace.start = startPos;
				trace.endpos = endPos;
				trace.filter = filterList;
			else
				if xAxis then
					wallLocation2 = traceData.HitPos.x;
				elseif !xAxis then
					wallLocation2 = traceData.HitPos.y;
				end
				
				bool = false;
			end
		elseif hitWorld then
			if wallLocation1 == -1 then
				if xAxis then
					trace.start = traceData.HitPos + Vector(50,0,0);
				elseif !xAxis then
					trace.start = traceData.HitPos + Vector(0,50,0);
				end
			else
				if xAxis then
					trace.start = traceData.HitPos - Vector(50,0,0);
				elseif !xAxis then
					trace.start = traceData.HitPos - Vector(0,50,0);
				end
			end
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the wall");
			bool = false;
		end		
		maxNumber = maxNumber + 1;
	end
	
	return wallLocation1, wallLocation2;
end

function ENT:Initialize()	
	self.Owner = self:GetVar("owner", nil)	
	self.Wep = self:GetVar("Weapon", nil)
	self.Sky = self:FindSky()
	self:SetModel( self.Model );
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end	
	
	if self.restrictMovement then
		self.playerSpeeds = { self.Owner:GetWalkSpeed(), self.Owner:GetRunSpeed() }
		GAMEMODE:SetPlayerSpeed(self.Owner, -1, -1)
	end
	
	self:MW2_Init();
end

function ENT:MW2_Init()	
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:Destroy()
end

function ENT:SetDropLocation(vec, ang)
	self.DropLoc = vec;
	self.DropAng = Angle( 0, ang ,0 );
end

function ENT:OpenOverlayMap(select)
	umsg.Start("MW2_DropLoc_Overlay_UM", self.Owner);		
		umsg.Entity(self);
		umsg.Bool(select);
	umsg.End();
end

local function SetLocation( pl, handler, id, encoded, decoded ) -- this data stream allows the client to reset the killstreak, so if you recive two of the same killstreak right after the other it will playthe notification for both
	if decoded[3] != nil then
		decoded[1]:SetDropLocation( decoded[2], decoded[3] )
	else
		decoded[1]:SetDropLocation( decoded[2], nil )
	end	
end
datastream.Hook( "MW2_DropLocation_Overlay_Stream", SetLocation )