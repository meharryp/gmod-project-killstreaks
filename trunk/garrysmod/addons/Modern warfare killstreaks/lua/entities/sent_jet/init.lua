AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local flyBySound = Sound("killstreak_misc/jet_fly_by.wav");

ENT.dropPos = NULL;
local radius = 500;
local jetModel = Model("models/military2/air/air_f35_l.mdl")
ENT.ground = 0;
ENT.dropDelay = CurTime();
ENT.droppedBombset1 = false;
ENT.droppedBombset2 = false;
ENT.bomb = NULL;
ENT.bomb2 = NULL;
ENT.bomb3 = NULL;
ENT.bomb4 = NULL;
ENT.DropDaBomb = false;
ENT.StartAngle = NULL;
ENT.WasInWorld = false;

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self.Entity:GetForward()*7000)
	self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.ground));
	self.Entity:SetAngles(self.StartAngle)

	if( !self.Entity:IsInWorld() && self.WasInWorld) then
		self.Entity:Remove();
		hook.Remove( "PhysgunPickup", "DisallowJetPickUp");
	end
	
	if !self.WasInWorld && self.Entity:IsInWorld() then
		self.WasInWorld = true;
	end
	
	if( self:FindDropZone(self.dropPos) && self.dropDelay < CurTime()) && (!self.droppedBombset1 || !self.droppedBombset2) then
		self.dropDelay = CurTime() + 0.1;
		self:DropBomb()		
	end	
end

function ENT:Initialize()	
	local bombSent = "sent_air_strike_cluster"
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.StartPos = self:GetVar("WallLocation", NULL);
	self.FlyAng = self:GetVar("FlyAngle", NULL);
--	self.dropPos = self.Owner:GetNetworkedVector("Hover_zone_vector");	
	self.dropPos = self:GetVar("JetDropZone", NULL)
	self.ground = findGround() + 2000;
	//self.ground = self.dropPos.z + 2000;
	
	if self.StartPos != NULL && self.FlyAng != NULL then
		self.spawnZone = Vector(self.StartPos.x, self.StartPos.y, self.ground);
		self.StartAngle = self.FlyAng;
	else
		x = findWall("x", self.ground)
		self.spawnZone = Vector(x,self.dropPos.y,self.ground);
		self.StartAngle = Angle(0, 180, 0);
		self.Owner:SetNetworkedVector("Harrier_Spawn_Pos", self.spawnZone);
	end	
		
	self.Entity:SetModel( jetModel )
	self.Entity:SetColor(255,255,255,255)
	self.Entity:SetPos(self.spawnZone )
	self.Entity:SetAngles( self.StartAngle )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity(false);
		self.PhysObj:Wake()
	end

	self.bomb = ents.Create( bombSent );
	self.bomb:SetPos(self:GetPos() + (self:GetRight() * 99) + (self:GetUp() * -21) + (self:GetForward() * -149) ) 	
	self.bomb:SetAngles(self.Entity:GetAngles());
	self.bomb:SetVar("owner",self.Owner)
	self.bomb:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	self.bomb:Spawn();
	self.bomb:SetNotSolid(true);

	self.bomb2 = ents.Create( bombSent );
	self.bomb2:SetPos(self:GetPos() + (self:GetRight() * 144) + (self:GetUp() * -20) + (self:GetForward() * -176) )
	self.bomb2:SetAngles(self.Entity:GetAngles());
	self.bomb2:SetVar("owner",self.Owner)
	self.bomb2:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	self.bomb2:Spawn()
	self.bomb2:SetNotSolid(true);

	self.bomb3 = ents.Create( bombSent );
	self.bomb3:SetPos(self:GetPos() + (self:GetRight() * -99) + (self:GetUp() * -21) + (self:GetForward() * -149) ) 	
	self.bomb3:SetAngles(self.Entity:GetAngles());
	self.bomb3:SetVar("owner",self.Owner)
	self.bomb3:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	self.bomb3:Spawn()
	self.bomb3:SetNotSolid(true);

	self.bomb4 = ents.Create( bombSent );
	self.bomb4:SetPos(self:GetPos() + (self:GetRight() * -144) + (self:GetUp() * -20) + (self:GetForward() * -176) )
	self.bomb4:SetAngles(self.Entity:GetAngles());
	self.bomb4:SetVar("owner",self.Owner)
	self.bomb4:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	self.bomb4:Spawn()	
	self.bomb4:SetNotSolid(true);


	constraint.NoCollide( self.Entity, self.bomb, 0, 0 );
	constraint.NoCollide( self.Entity, self.bomb2, 0, 0 );
	constraint.NoCollide( self.Entity, self.bomb4, 0, 0 );
	constraint.NoCollide( self.Entity, self.bomb3, 0, 0 );

	bool = false;

	constraint.Weld(self.Entity, self.bomb, 0,0,0, bool)
	constraint.Weld(self.Entity, self.bomb2, 0,0,0, bool)
	constraint.Weld(self.Entity, self.bomb3, 0,0,0, bool)
	constraint.Weld(self.Entity, self.bomb4, 0,0,0, bool)
	
	constraint.NoCollide( self.Entity, GetWorldEntity(), 0, 0 );	
	self.PhysgunDisabled = true
	self.bomb.PhysgunDisabled = true
	self.bomb2.PhysgunDisabled = true
	self.bomb3.PhysgunDisabled = true
	self.bomb4.PhysgunDisabled = true
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

function ENT:DropBomb()
	if !self.droppedBombset1 then	
		constraint.RemoveConstraints(self.bomb, "Weld")
		constraint.RemoveConstraints(self.bomb2, "Weld")
		self.bomb:SetNotSolid(false);
		self.bomb2:SetNotSolid(false);
		
		self.bomb:GetPhysicsObject():SetVelocity(Vector(0,0,0));
		self.bomb2:GetPhysicsObject():SetVelocity(Vector(0,0,0));
		
		self.bomb:SetVar("HasBeenDropped",true);
		self.bomb2:SetVar("HasBeenDropped",true);
		
		self.droppedBombset1 = true;
		self:EmitSound(flyBySound, 500, 100)
	elseif !self.droppedBombset2 then
		constraint.RemoveConstraints(self.bomb3, "Weld")
		constraint.RemoveConstraints(self.bomb4, "Weld")
		self.bomb3:SetNotSolid(false);
		self.bomb4:SetNotSolid(false);
		
		self.bomb3:GetPhysicsObject():SetVelocity(Vector(0,0,0));
		self.bomb4:GetPhysicsObject():SetVelocity(Vector(0,0,0));
		
		self.bomb3:SetVar("HasBeenDropped",true);
		self.bomb4:SetVar("HasBeenDropped",true);
		
		self.droppedBombset2 = true;
	end
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
