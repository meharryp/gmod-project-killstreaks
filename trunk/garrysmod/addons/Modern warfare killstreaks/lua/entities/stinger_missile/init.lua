
include( 'shared.lua' )

ENT.Target = NULL;

function ENT:PhysicsUpdate()
	if self.Trail and self.Trail:IsValid() then
		self.Trail:SetPos(self:GetPos() - 16*self:GetForward())
		self.Trail:SetLocalAngles(Vector(0,0,0))
	else
		self:SpawnTrail()
	end	
	
	if IsValid(self.Target) then
		local vec3 = self.Target:GetPos() - self:GetPos();
		local ang = vec3:Angle()
		self:SetAngles(ang)
		self:GetPhysicsObject():SetVelocity(self:GetForward() * 2500)
	end
end

function ENT:Think()
 end

function ENT:Initialize()	
	self.Entity:SetModel( "models/Weapons/W_missile_closed.mdl" );
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Target = self.Entity:GetVar("target",NULL)	
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

function ENT:Explosion()
	
	local expl = ents.Create("env_explosion")
	expl:SetOwner(self)
	expl:SetKeyValue("spawnflags",128)
	expl:SetKeyValue("iMagnitude", "200")
	expl:SetPos(self.Entity:GetPos())
	expl:Spawn()
	expl:Fire("explode","",0)

	local ar2Explo = ents.Create("env_ar2explosion")
		ar2Explo:SetOwner(self)
		ar2Explo:SetPos(self.Entity:GetPos())
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire("Explode", "", 0)
end

function ENT:SpawnTrail()

	self.Trail = ents.Create("env_rockettrail")
	self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
	self.Trail:SetParent(self.Entity)
	self.Trail:SetLocalAngles(Vector(0,0,0))
	self.Trail:Spawn()
	
end