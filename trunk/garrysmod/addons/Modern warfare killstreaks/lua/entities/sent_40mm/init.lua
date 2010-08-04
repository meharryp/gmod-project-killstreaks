include( 'shared.lua' )

ENT.ExplosionSound = Sound("killstreak_explosions/105_explosion.wav")

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self.Entity:GetForward() * 5500)
end

function ENT:Initialize()	
	self.Entity:SetModel( "models/military2/missile/missile_s300.mdl" );
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	self.Entity:EmitSound("ac-130_kill_sounds/40mminair.wav", 475, 100)
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
		self:Remove()
	end
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:Explosion()
	
	util.BlastDamage(self, self.Owner, self:GetPos(), 250, 250)
	
	self:EmitSound(self.ExplosionSound, 70,100)
	
	ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "40mm_explode") -- The names are cluster_explode, 40mm_explode, and agm_explode.
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	util.ScreenShake( self.Entity:GetPos(), 15, 15, 0.5, 2000 )
end
