AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
ENT.dropPos = NULL;
local radius = 100;
ENT.ground = 0;
ENT.RemoveDelay = CurTime();
ENT.crate = NULL;
ENT.DropDaCrate = false;
ENT.StartAngle = NULL;
ENT.WasInWorld = false;
ENT.Model = Model("models/military2/air/air_130_l.mdl" )
function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self.Entity:GetForward()*3500)		
	
	self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.ground));
	self.Entity:SetAngles(self.StartAngle)

	if( !self.Entity:IsInWorld() && self.WasInWorld && self.RemoveDelay < CurTime()) then
		self.Entity:Remove();
		hook.Remove( "PhysgunPickup", "DisallowJetPickUp");
		return;
	end
	
	if !self.WasInWorld && self.Entity:IsInWorld() then
		self.RemoveDelay = CurTime() + 2;
		self.WasInWorld = true;
	end
	
	if self:FindDropZone(self.dropPos) && !self.DropDaCrate  then
		self.DropDaCrate = true;
		timer.Create("EmAd_crateTimer", .1, 4, self.DropCrate, self);
	end	
	
end

function ENT:Initialize()	
	hook.Add( "PhysgunPickup", "DisallowJetPickUp", physgunJetPickup );	
	self.Owner = self:GetVar("owner")		
	self.dropPos = self:GetVar("PackageDropZone", NULL) -- Needs to be set from the weapon
	self.ground = findGround() + 2000;
	
	x = findWall("x", self.ground)
	self.spawnZone = Vector(x,self.dropPos.y,self.ground);
	self.StartAngle = Angle(0, 180, 0);	
		
	self:SetModel( self.Model )
	self:SetColor(255,255,255,255)
	self:SetPos(self.spawnZone )
	self:SetAngles( self.StartAngle )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity(false);
		self.PhysObj:Wake()
	end
	constraint.NoCollide( self.Entity, GetWorldEntity(), 0, 0 );	
end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:FindDropZone(vec)
	local jetPos = self.Entity:GetPos();
	local distance = jetPos - self.dropPos;
	if math.abs(distance.x) <= radius && math.abs(distance.y) <= radius then
		return true;
	end
	return false;
end

function ENT:DropCrate()
	self.DropDaCrate = true;
	
	local crate = ents.Create( "sent_supplyCrate" );
	crate:SetPos( self:GetPos() + (self:GetRight() * -3.5) + (self:GetUp() * 16.6) + (self:GetForward() * -393) )			
	crate:SetVar("CrateType", self:GetClass())	
	crate:SetVar("owner",self.Owner)
	crate:Spawn();	
	constraint.NoCollide( self, crate, 0, 0 );
end

function findGround()

	local minheight = -16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,minheight);
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

function findWall(axis, height)

	local length = 16384
	local startPos = Vector(0,0,height);
	local endPos;
	if axis == "x" then 
		endPos = Vector(length, 0,height);
	elseif axis == "y" then 
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
	local wallLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			if axis == "x" then
				wallLocation = traceData.HitPos.x;
			elseif axis == "y" then
				wallLocation = traceData.HitPos.y;
			end
			bool = false;
		elseif hitWorld then
			if axis == "x" then
				trace.start = traceData.HitPos + Vector(50,0,0);
			elseif axis == "y" then
				trace.start = traceData.HitPos + Vector(0,50,0);
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
	
	return wallLocation;
end

function ENT:OnRemove()
end

function physgunJetPickup( ply, ent )
	if ent:GetClass() == "sent_jet" || ent:GetClass() == "sent_air_strike_cluster"  then
		return false // Don't allow them to pick up the jet or the bombs.
	else
		return true 
	end
end
