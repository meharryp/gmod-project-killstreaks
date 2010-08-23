AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

local moveFactor = 40;
ENT.sky = 0;
ENT.findHoverZone = true;
ENT.hoverZone = NULL;
local jet = nil;
ENT.jet1Alive = false;
ENT.jet2Alive = false;
ENT.jet3Alive = false;
ENT.spawnJet2 = false;
ENT.spawnJet3 = false;
ENT.SpawnDelay = CurTime();
ENT.playerAng = NULL;
ENT.removeSelf = false;
ENT.playOnce = true;
ENT.playerWeapons = {};

function ENT:Think()
	if( self.PhysObj:IsAsleep() ) then
		self.PhysObj:Wake()
	end

	if self.removeSelf then
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
			Vector( self:GetPos().x, self:GetPos().y, self:findGround() )
			
			//self.Owner:ExitVehicle()
			//self.Owner:SetSuppressPickupNotices( true );
			self.Owner:SetViewEntity(self.Owner);
			GAMEMODE:SetPlayerSpeed(self.Owner, 250, 500)
			--[[
			for k,v in pairs(self.playerWeapons) do
				if v != "harrier" then
					self.Owner:Give(v);	
				end	
			end
			]]
			//self.Owner:SetSuppressPickupNotices( false )
			self.Wep:CallIn();
			self.Owner:SetAngles(self.playerAng)
			umsg.Start("Harrier_Strike_RemoveHUD", self.Owner);
			umsg.End();

			self.jet1Alive = true;
			self.Jet1:SetVar("JetDropZone", self.Entity:GetPos())
			self.Jet1:Spawn()
			self.Jet1:Activate()
			self.SpawnDelay = CurTime() + 2;
			
		end					
	end
	if !self.findHoverZone && self.playOnce then
		umsg.Start("playHarrierInboundSound", self.Owner);
		umsg.End()
		self.playOnce = false;
	end
		if self.SpawnDelay <= CurTime() && self.jet1Alive then
			self.jet1Alive = false;
			self.jet2Alive = true;
			self.Jet2:SetVar("JetDropZone", self.Entity:GetPos())
			self.Jet2:Spawn();
			self.Jet2:Activate();
			self.SpawnDelay = CurTime() + 2;
		elseif self.SpawnDelay <= CurTime() && self.jet2Alive then
			self.jet2Alive = false;			
			self.Harrier:SetVar("HarrierHoverZone", self.Entity:GetPos())
			self.Harrier:Spawn();
			self.Harrier:Activate();
			self.removeSelf = true;
		end	
		
end

function ENT:Initialize()
	removeEnt = false;
	//hook.Add("EntityRemoved", "entRemoved", JetsRemoved)
	
	self.sky = findSky()
	if self.sky == -1 then return end
	self.sky = self.sky - 100;
	
	self.Entity:SetModel( "models/dav0r/camera.mdl" )
	self.Entity:SetColor(255,255,255,0)
	self.Entity:SetAngles(Vector(90,0,0))
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetNotSolid(true);

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Wep = self:GetVar("Weapon")	
	self.playerAng = self.Owner:GetAngles();
	
	self.Jet1 = ents.Create("sent_jet")
	self.Jet1:SetVar("owner",self.Owner) 
	
	self.Jet2 = ents.Create("sent_jet")
	self.Jet2:SetVar("owner",self.Owner) 
	
	self.Harrier = ents.Create("sent_harrier")
	self.Harrier:SetVar("owner",self.Owner) 

	GAMEMODE:SetPlayerSpeed(self.Owner, 0, 0)
	--[[
	for k,v in pairs(self.Owner:GetWeapons()) do
		self.playerWeapons[k] = v:GetClass()
	end	
	self.Owner:StripWeapons();
	]]
	self.Owner:SetViewEntity(self.Entity);
	self.Owner:SetNetworkedString("harrier_Killsteak", "none")
	umsg.Start("Harrier_Strike_SetUpHUD", self.Owner);
	umsg.End();
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function findSky()

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

function ENT:OnRemove( )
end
