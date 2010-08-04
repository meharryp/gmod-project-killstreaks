AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Activate()
end

function ENT:Freeze()
	self.Entity:SetMoveType(MOVETYPE_NONE)
end

function ENT:Explode()
--[[
	local Ent = ents.Create("env_explosion")
	Ent:SetPos(self.Entity:GetPos())
	Ent:SetOwner(self)
	Ent:Spawn()
	Ent:Activate()
	Ent:SetKeyValue("iMagnitude", 100)
	Ent:SetKeyValue("iRadiusOverride", 500)
	Ent:Fire("explode", "", 0)
]]
	util.BlastDamage(self, self.Owner, self:GetPos(), 500, 100)
	ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "cluster_explode")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	
	self.Entity:EmitSound("weapons/explode3.wav", 400, 100)
	self.Entity:Fire("kill", "", "0")
end

function ENT:PhysicsCollide( data, physobj )
    if data.Speed > 1 and data.DeltaTime > 0.1 && data.HitEntity:GetClass() != self:GetClass() then -- if it hits an object at over 1 speed
		self:Explode()
	    self.Entity:Remove()
	end
end
function ENT:OnRemove()
end

function ENT:Think()
end

function ENT:Initialize()
	self.Entity:SetModel("models/items/ar2_grenade.mdl")
	self.Entity:SetColor(50, 50, 50, 255)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Owner = self:GetVar("owner",Entity(1))	
	
	local Phys = self.Entity:GetPhysicsObject()
	if Phys:IsValid() then
		Phys:Wake()
	end
end