AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

local moveFactor = 40;
ENT.sky = 0;
ENT.DropDelay = CurTime();
ENT.turnDealy = CurTime()
ENT.playerAng = NULL;
ENT.removeSelf = false;
ENT.playOnce = true;
ENT.MarkerAng = 0;
ENT.findHoverZone = true
ENT.WallLoc = NULL;
ENT.Bomber = NULL
ENT.InitialDelay = CurTime();
ENT.playerWeapons = {};

function ENT:Think()
	if( self.PhysObj:IsAsleep() ) then
		self.PhysObj:Wake()
	end

	if self.removeSelf then
		self.Bomber:Remove()
		self:Remove()
	end	
	
	if self.Bomber != NULL && self.Bomber:IsValid() && !self.Bomber:IsInWorld() then
		self.Bomber:Remove()
		self:Remove()
	end
end

function ENT:PhysicsUpdate()
	self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.sky))
	if self.findHoverZone then
		if 	self.Entity.Owner:KeyDown( IN_FORWARD ) then
			self.Entity:SetPos(self.Entity:GetPos() + Vector(moveFactor,0,0));
		end
				
		if 	self.Owner:KeyDown( IN_BACK ) then
			self.Entity:SetPos(self.Entity:GetPos() - Vector(moveFactor,0,0));
		end	
		
		if 	self.Entity.Owner:KeyDown( IN_MOVERIGHT ) then
			self.Entity:SetPos(self.Entity:GetPos() - Vector(0,moveFactor,0));
		end
				
		if 	self.Owner:KeyDown( IN_MOVELEFT ) then
			self.Entity:SetPos(self.Entity:GetPos() + Vector(0,moveFactor,0));
		end	
		
		if self.Owner:KeyDown( IN_ATTACK ) then			
			self.findHoverZone = false;
			self.Owner:ExitVehicle()
			
			self:SetAngles(Angle(0,self.MarkerAng - 180 ,0))
			self.WallLoc = self:FindWall();
			self.FlyAng = Angle(0,self.MarkerAng,0)
			
			self.Owner:SetViewEntity(self.Owner);
			//self.Owner:SetSuppressPickupNotices( true )
			GAMEMODE:SetPlayerSpeed(self.Owner, 250, 500)
			--[[
			for k,v in pairs(self.playerWeapons) do
				if v != "stealth_bomber" then
					self.Owner:Give(v);	
				end		
			end
			self.Owner:SetSuppressPickupNotices( false )
			]]
			self.Wep:CallIn();
			self.Owner:SetAngles(self.playerAng)
			umsg.Start("Stealth_bomber_RemoveHUD", self.Owner);
			umsg.End();
			self:SpawnBomber();
		end
		
		if self.Owner:KeyDown( IN_ATTACK2 ) && self.turnDealy < CurTime() then
			self.turnDealy = CurTime() + .1
			self.MarkerAng = self.MarkerAng + 45;
			if self.MarkerAng >= 360 then
				self.MarkerAng = 0;
			end
			self.Owner:SetNetworkedInt("StealthMarkerAngle",self.MarkerAng);			
		end
	else
		self.Bomber.PhysObj:SetVelocity(self.Bomber:GetForward()*5000)
		if self.DropDelay < CurTime() && self.InitialDelay < CurTime() then
			self.DropDelay = CurTime() + .08;
			self:SpawnBomb();
		end
	end
	
	if !self.findHoverZone && self.playOnce then
		umsg.Start("playPrecisionAirstrikeInboundSound", self.Owner);
		umsg.End()
		self.playOnce = false;
	end
		
end

function ENT:Initialize()	
	self.sky = self:findSky()
	if self.sky == -1 then return end
	self.sky = self.sky - 100;
	
	self.Entity:SetModel( "models/dav0r/camera.mdl" )
	self.Entity:SetColor(255,255,255,0)
	self.Entity:SetAngles(Angle(90,0,0))
	self:SetPos(Vector(0,0, self.sky));
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetNotSolid(true);
	

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Wep = self:GetVar("Weapon")
	self.MarkerAng = 0;
	self.Owner:SetNetworkedInt("StealthMarkerAngle",self.MarkerAng);
	self.playerAng = self.Owner:GetAngles();
	GAMEMODE:SetPlayerSpeed(self.Owner, 0, 0)
	--[[
	for k,v in pairs(self.Owner:GetWeapons()) do
		self.playerWeapons[k] = v:GetClass()
	end	
	self.Owner:StripWeapons();
	]]
	self.Owner:SetViewEntity(self.Entity);	
	
	umsg.Start("Stealth_bomber_SetUpHUD", self.Owner);
	umsg.End();
end

function ENT:SpawnBomber()
	self.ground = findGround() + 2000;
	self.Bomber = ents.Create("prop_physics")
	self.Bomber:SetModel("models/military2/air/air_f117_l.mdl")
	self.Bomber:SetColor(255,255,255,255)
	self.Bomber:SetPos( Vector( self.WallLoc.x, self.WallLoc.y, self.ground) )
	self.Bomber:SetAngles( self.FlyAng )
	
	self.Bomber:PhysicsInit( SOLID_VPHYSICS )
	self.Bomber:SetMoveType( MOVETYPE_VPHYSICS )		
	self.Bomber:SetSolid( SOLID_VPHYSICS )

	self.Bomber.PhysObj = self.Bomber:GetPhysicsObject()
	if (self.Bomber.PhysObj:IsValid()) then
		self.Bomber.PhysObj:Wake()
	end
	//self.DropDelay = CurTime() + .3;
	self.InitialDelay = CurTime() + .6;
end

function ENT:SpawnBomb()
	local bomb = ents.Create( "sent_air_strike_bomb" );
	bomb:SetPos(self.Bomber:GetPos() + (self.Bomber:GetRight() * -50) )
	bomb:SetAngles(self.Bomber:GetAngles());
	bomb:SetVar("owner",self.Owner)
	bomb:Spawn();
	constraint.NoCollide( self.Bomber, bomb, 0, 0 );
	
	bomb:SetVar("HasBeenDropped",true);
	
	local bomb2 = ents.Create( "sent_air_strike_bomb" );
	bomb2:SetPos(self.Bomber:GetPos() + (self.Bomber:GetRight() * 50) )
	bomb2:SetAngles(self.Bomber:GetAngles());
	bomb2:SetVar("owner",self.Owner)
	bomb2:Spawn();
	constraint.NoCollide( self.Bomber, bomb2, 0, 0 );
	bomb2:SetVar("HasBeenDropped",true);
	
	constraint.NoCollide( self.Bomber, GetWorldEntity(), 0, 0 );	
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:findSky()

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
			
		if maxNumber >= 50 then
			MsgN("Reached max number here, no luck in finding a skyBox");
			bool = false;
		end
	end
	
	return skyLocation;
end

function ENT:findGround()

	local minheight = -16384
	local startPos = Vector(0,0,self.sky);
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

function ENT:FindWall()
	trace = util.QuickTrace( self:GetPos(), self:GetForward() * 100000, self)
	return trace.HitPos;
end

function ENT:OnRemove( )
end
