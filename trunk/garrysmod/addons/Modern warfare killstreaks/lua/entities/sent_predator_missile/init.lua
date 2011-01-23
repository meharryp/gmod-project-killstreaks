AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

ENT.Model = "models/military2/bomb/bomb_cbu.mdl";
ENT.moveFactor = .5;
ENT.speedFactor = 1;
ENT.speedBoost = true;
ENT.keepPlaying = false;
ENT.playerAng = NULL;
ENT.playerWeapons = {};
ENT.Sky = 0;
ENT.ang = nil;
ENT.turnDelay = CurTime();
ENT.playerSpeeds = {};
ENT.MissileSpeed = 0;
ENT.restrictMovement = true;
local missileThrustSound = Sound("killstreak_rewards/predator_missile_thruster.wav")
local missileBoostSound = Sound("killstreak_rewards/predator_missile_boost.wav")
local missileExplosionSound = Sound("killstreak_rewards/predator_missile_explosion.wav")
local thrustSoundDuration = SoundDuration(missileThrustSound);

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity((self.Entity:GetForward()* self.MissileSpeed ) * self.speedFactor)
	
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

function ENT:Initialize2()	
	self.Sky = self.Sky - 100;

	local lplPos = self.Owner:GetPos()
	local skyVector = Vector(lplPos.x,lplPos.y, self.Sky);
	--self.speedFactor = 1;
	--self.speedBoost = true;

	self.Entity:SetPos(skyVector)
	self.Entity:SetAngles(Angle(75, self.Owner:EyeAngles().y, 0))
	
	--self.playerSpeeds = { self.Owner:GetWalkSpeed(), self.Owner:GetRunSpeed() }
	--GAMEMODE:SetPlayerSpeed(self.Owner, -1, -1)
	self.playerAng = self.Owner:GetAngles();
		
	self.Owner:SetViewEntity(self);
	umsg.Start("Predator_missile_SetUpHUD", self.Owner);
	umsg.End()
	self.keepPlaying = true;
	self.MissileSpeed = math.Clamp(Vector(0,0, self.Sky):Distance( Vector( 0,0, self:findGround()) ), 0, 2000)
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:PredatorExplosion()		
		self.Owner:SetViewEntity(self.Owner)
		self.Owner:ExitVehicle()
		self.Owner:SetAngles(self.playerAng)
		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])
		umsg.Start("Predator_missile_RemoveHUD", self.Owner);
		umsg.End();
		if IsValid(self.Wep) then
			self.Wep:CallIn();
		end
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

function ENT:StartThrustSound()	
	self.Entity:EmitSound(missileThrustSound)
end

function ENT:StopThrustSound()		
	self.keepPlaying = false;
end