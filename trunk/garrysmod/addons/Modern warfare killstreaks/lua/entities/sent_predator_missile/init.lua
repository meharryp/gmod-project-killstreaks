AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

ENT.moveFactor = 1;
ENT.speedFactor = 1;
ENT.speedBoost = true;
ENT.keepPlaying = false;
ENT.playerAng = NULL;
ENT.playerWeapons = {};
ENT.Sky = 0;
ENT.ang = nil;
ENT.turnDelay = CurTime();
local missileThrustSound = Sound("killstreak_rewards/predator_missile_thruster.wav")
local missileBoostSound = Sound("killstreak_rewards/predator_missile_boost.wav")
local missileExplosionSound = Sound("killstreak_rewards/predator_missile_explosion.wav")
local thrustSoundDuration = SoundDuration(missileThrustSound);

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity((self.Entity:GetForward()* (self.Sky /6.5) ) * self.speedFactor)
	
	self.ang = self:GetAngles()
	
	if self.Entity.Owner:KeyDown( IN_FORWARD ) then --IN_FORWARD
		if self.ang.p > 60 then
			self.ang =  Angle( self.ang.p - self.moveFactor, self.ang.y, self.ang.r )		
		end
	elseif self.Owner:KeyDown( IN_BACK ) then
		if self.ang.p < 89 then
			self.ang =  Angle( self.ang.p + self.moveFactor, self.ang.y, self.ang.r )			
		end
	end	
	if self.Entity.Owner:KeyDown( IN_MOVERIGHT ) then
		self.ang =  Angle( self.ang.p, self.ang.y - self.moveFactor, self.ang.r )
	elseif 	self.Owner:KeyDown( IN_MOVELEFT ) then
		self.ang =  Angle( self.ang.p, self.ang.y + self.moveFactor, self.ang.r )
	end	
	self:SetAngles(self.ang)
	
	if self.Owner:KeyDown( IN_ATTACK ) && self.speedBoost then
		self.speedFactor = 3;
		self.speedBoost = false;
		self.Entity:EmitSound(missileBoostSound)
	end
		
		if self.Trail and self.Trail:IsValid() then
			self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
			self.Trail:SetLocalAngles(Angle(0,0,0))
		else
			self:SpawnTrail()
		end	
	if thrustSoundDuration <= CurTime() && self.keepPlaying then
		self:StartThrustSound()	
	end
end

function ENT:Think()
	if( self.PhysObj:IsAsleep() ) then
		self.PhysObj:Wake()
	end
 end

function ENT:Initialize()	
	self.Sky = self:FindSky()
	if self.Sky == -1 then return end
	self.Sky = self.Sky - 100;

	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Wep = self:GetVar("Weapon")
	local lplPos = self.Owner:GetPos()
	local skyVector = Vector(lplPos.x,lplPos.y, self.Sky);
	self.speedFactor = 1;
	self.speedBoost = true;
	self.Entity:SetModel( "models/military2/bomb/bomb_cbu.mdl" ); --// "models/military2/missile/missile_sm2.mdl" );
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.Entity:SetPos(skyVector)
	self.Entity:SetAngles(Angle(75, self.Owner:EyeAngles().y, 0))
	
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end	
	
	GAMEMODE:SetPlayerSpeed(self.Owner, 0, 0)
	self.playerAng = self.Owner:GetAngles();
		
	self.Owner:SetViewEntity(self);
	umsg.Start("Predator_missile_SetUpHUD", self.Owner);
	umsg.End()
	umsg.Start("playPredatorMissileInboundSound", self.Owner);
	umsg.End()
	self.keepPlaying = true;
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:PredatorExplosion()		
		self.Owner:SetViewEntity(self.Owner)
		self.Owner:ExitVehicle()
		self.Owner:SetAngles(self.playerAng)
		GAMEMODE:SetPlayerSpeed(self.Owner, 250, 500)
		umsg.Start("Predator_missile_RemoveHUD", self.Owner);
		umsg.End();
		self.Wep:CallIn();
	end
end

function ENT:PredatorExplosion()

	util.BlastDamage(self, self.Owner, self:GetPos(), 700, 700)
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "agm_explode")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	

	local shake = ents.Create("env_shake")
		shake:SetOwner(self)
		shake:SetPos(self.Entity:GetPos())
		shake:SetKeyValue("amplitude", "2000")	// Power of the shake
		shake:SetKeyValue("radius", "1250")		// Radius of the shake
		shake:SetKeyValue("duration", "2.5")	// Time of shake
		shake:SetKeyValue("frequency", "255")	// How har should the screenshake be
		shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	self:StopThrustSound();
	self.Entity:EmitSound(missileExplosionSound, 140,100)
	self.Entity:Remove()

	local en = ents.FindInSphere(self:GetPos(), 500)
	local phys
	for k, v in pairs(en) do
		phys = v:GetPhysicsObject()
		if (phys:IsValid()) then
			v:Fire("enablemotion", "", 0)
			constraint.RemoveAll(v)
			phys:ApplyForceCenter( ( v:GetPos() - self:GetPos() ):GetNormal() * phys:GetMass() * 1500 )
		end
		if v:GetClass() == "npc_strider" then 
			v:Fire("Break","",0);
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:SpawnTrail()

	self.Trail = ents.Create("env_rockettrail")
	self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
	self.Trail:SetParent(self.Entity)
	self.Trail:SetLocalAngles(Angle(0,0,0))
	self.Trail:Spawn()
	
end

function getTeam()
	return self.Owner:Team()
end

function ENT:StartThrustSound()	
	self.Entity:EmitSound(missileThrustSound)
end

function ENT:StopThrustSound()		
	self.keepPlaying = false;
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
