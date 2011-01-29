--AddCSLuaFile( "cl_init.lua" )
--IncludeClientFile("cl_init.lua")
include( 'shared.lua' )

ENT.MapBounds = { };
ENT.Model = "";
ENT.Sky = 0;
ENT.playerSpeeds = {}
ENT.restrictMovement = false;
ENT.DropLoc = nil;
ENT.DropAng = nil;
ENT.Friendlys = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }

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
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
		else 
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
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local groundLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
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
	
	if self.Owner == nil then 
		self:Remove();
		MsgN("You do not have permission to use this");
		return;
	end
	
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

function ENT:FilterTarget(target) --This could all be done in one line, but to make it look nice and understandable I wrote it like this
	if IsValid(target) && self:HasLOS(target) then
		if target:IsNPC() then
			if !table.HasValue( self.Friendlys, target:GetClass() ) then
				return true;
			end
		elseif target:IsPlayer() then
			if target != self.Owner && target:Team() != self.Owner:Team() && GetConVarNumber("sbox_plpldamage") != 0 then
				return true;
			end
		end
	end
	return false;
end

function ENT:HasLOS(target)
	local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = target:GetPos()
		tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	if IsValid(trace.Entity) && trace.Entity == target then
		return true;	
	end
	return false;
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