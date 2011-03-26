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
ENT.Flares = 0;
ENT.FlareSpawnPos = nil;

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
	
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )
	
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

function ENT:FilterTarget(target, LOS) 
	local haslos;
	if !LOS then haslos = true;
	else
		haslos = self:HasLOS(target);
	end
	
	if IsValid(target) && haslos then
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
		tracedata.endpos = target:LocalToWorld(target:OBBCenter())
		tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	if IsValid(trace.Entity) && ( trace.Entity == target || !table.HasValue(self.Friendlys, target:GetClass()) ) then
		return true;
	end
	return false;
end

local function SpawnFlares(self, fpos)
	local flare = nil;
	for i = 0 , 20 do 
		local flares = ents.Create( "sent_mw2_flares" )	
		flares:SetPos( fpos )
		flares:Spawn()
		local Phys = flares:GetPhysicsObject()
		
		if Phys:IsValid() then
			Phys:Wake()
			Phys:ApplyForceCenter(Vector(math.random(5-40, 40), math.random(5-40, 40), math.random(5-40, 40)) * Phys:GetMass())
		end
		flares:Activate()
		constraint.NoCollide( self, flares, 0, 0 )
		if flare == nil then flare = flares end -- returns the first flare spawned so we can track it.
	end	
	
	return flare;
end

function ENT:DeployFlares( obj, fpos )
	if self.Flares <= 0 then return end
	if obj.FlareSpawned then return end
	local vel = obj:GetVelocity();
	if vel:Dot(vel:GetNormal()) <= 0 then return end
	
	local trace = util.QuickTrace( obj:GetPos(), vel:GetNormal() * 10000, {obj})
	if IsValid(trace.Entity ) && trace.Entity == self then
		self:SpawnDecoy( obj, SpawnFlares(self, fpos) )
	end
	obj.FlareSpawned = true;
	self.Flares = self.Flares - 1;
end

function ENT:SpawnDecoy(missile, target)

	local decoy = ents.Create("mw2_sent_decoyMissile")
	decoy:SetVar( "Model", missile:GetModel() );
	decoy:SetVar( "Owner", missile:GetOwner() or missile.Owner );
	decoy:SetVar( "Target", target );
	local phys = missile:GetPhysicsObject()
	local vel = nil;
	if IsValid(phys) then
		vel = phys:GetVelocity( )
	else
		vel = missile:GetVelocity()
	end
	decoy:SetVar( "Velocity", vel:Dot( vel:GetNormal() ) );
	
	local pos = missile:GetPos();
	missile:Remove();
	decoy:SetPos(pos);	
	decoy:Spawn();
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