
include( 'shared.lua' )

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self.Entity:GetForward() * 5500)
end

function ENT:Think()
 end

function ENT:Initialize()	
	self.Entity:SetModel( "models/military2/missile/missile_s300.mdl" ); --//  models/military2/bomb/bomb_mk82.mdl --// models/military2/bomb/bomb_jdam.mdl
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
		self.Entity:Remove()
	end

end


function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end



function ENT:Explosion()

	local expl = ents.Create("env_explosion")
	expl:SetOwner(self)
	expl:SetKeyValue("spawnflags",128)
	expl:SetKeyValue("spawnflags", "64")
	expl:SetKeyValue("spawnflags", "256")
	expl:SetKeyValue("iMagnitude", 200)
	expl:SetKeyValue("iRadiusOverride", 1000)
	expl:SetPos(self.Entity:GetPos())
	expl:Spawn()
	expl:Fire("explode","",0)
	
	ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "40mm_explode") -- The names are cluster_explode, 40mm_explode, and agm_explode.
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	
	
--[[
	local ar2Explo = ents.Create("env_ar2explosion")
		ar2Explo:SetOwner(self)
		ar2Explo:SetPos(self.Entity:GetPos())
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire("Explode", "", 0)
]]
	util.ScreenShake( self.Entity:GetPos(), 15, 15, 0.5, 2000 )
end
