AddCSLuaFile( "cl_init.lua" )
//AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

ENT.FlightLength = CurTime();
ENT.flightHeight = nil;
ENT.ang = NULL;
ENT.speed = 1500;
ENT.OurHealth = 100;
local IsUAVActive = false;

function ENT:Think()
	if self.PhysObj:IsAsleep() then
		self.PhysObj:Wake()
	end
	if( !self:IsInWorld()) then
		MsgN("Is out of this world")
		self:Remove()
	end
end

function ENT:PhysicsUpdate()
	
	self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self.flightHeight));
	self.PhysObj:SetVelocity(self:GetForward() * 750)	
	self:SetAngles(self.ang)
	
	local Trace = util.QuickTrace( self:GetPos(), self:GetForward() * 4500,  self )	
	if Trace.HitSky then
		self.ang = self.ang + Angle(0, -0.3, 0)
	end
	
	if self.FlightLength < CurTime() then
		self:Remove()		
	end
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:Initialize()
	self.Owner = self:GetVar("owner")	
	if IsUAVActive then
		self:RunUAV();
		self:Remove();
		return;
	end
	
	self:SetModel( "models/COD4/UAV/UAV.mdl" );
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	self.flightHeight = self:findGround() + 5000

	self:SetPos( Vector( self:FindEdge() - 500, 0, self.flightHeight) )
	self.FlightLength = CurTime() + 30;
	self.ang = Angle(0,-90,0);
	
	self:RunUAV();	
	
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )
	
	IsUAVActive = true;
	self:GetVar("Weapon"):PlaySound();
end

function ENT:RunUAV()
	umsg.Start("MW2_UAV_Start", self.Owner);	
	umsg.End();
	
	local plys = player.GetHumans()
	for k, v in pairs(plys) do		
	    if v:Team() == self.Owner:Team() && v != self.Owner then
			umsg.Start("MW2_UAV_Start", v);
			umsg.End();
	    end
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
 
	if(self.OurHealth <= 0) then return; end -- If the health-variable is already zero or below it - do nothing
 
	self.OurHealth = self.OurHealth - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable
 
	if(self.OurHealth <= 0) then -- If our health-variable is zero or below it
		self:Destroy();
	end
 end

function ENT:Destroy()
	local ParticleExplode = ents.Create("info_particle_system")
		ParticleExplode:SetPos(self:GetPos())
		ParticleExplode:SetKeyValue("effect_name", "cluster_explode")
		ParticleExplode:SetKeyValue("start_active", "1")
		ParticleExplode:Spawn()
		ParticleExplode:Activate()
		ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.		
	self:Remove(); -- Remove our entity		
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
	//local startPos = self.Owner:GetPos()
	local startPos = Vector(0, 0, self:FindSky())
	local endPos = Vector(0, 0,minheight);
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

function ENT:FindEdge()

	local dis = 16384
	local height = self:FindSky()
	local startPos = Vector(0,0, height)
	local endPos = Vector(dis, 0, height);
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
	local WallLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitWorld then
			WallLocation = traceData.HitPos.x;			
			bool = false;
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the ground");
			bool = false;
		end		
	end
	
	return WallLocation;
end

function ENT:OnRemove()
	--do other stuff when removeing cuav
	umsg.Start("MW2_UAV_End", self.Owner);
	umsg.End();
	local plys = player.GetHumans()
	for k, v in pairs(plys) do		
	    if v:Team() == self.Owner:Team() && v != self.Owner then
			umsg.Start("MW2_UAV_End", v);
			umsg.End();
	    end
	end
	IsUAVActive = false;
end