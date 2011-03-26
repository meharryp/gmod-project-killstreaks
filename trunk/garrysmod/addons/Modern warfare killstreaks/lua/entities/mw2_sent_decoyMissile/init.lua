
include('shared.lua')

ENT.Target = nil;
ENT.Vel = nil;
ENT.Exploded = false;

function ENT:Initialize()

	local m = self:GetVar( "Model", nil );
	self.Owner = self:GetVar( "Owner", nil );
	self.Target = self:GetVar( "Target", nil );
	self.Vel = self:GetVar( "Velocity", nil );
	if m == nil then
		self:Remove()
		return;
	end
	self:SetModel( m )
	self:SetOwner(self.Owner)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

    self.phys = self:GetPhysicsObject()
	if self.phys:IsValid() then 
		self.phys:Wake() 
	else
		self:SetModel( "models/Weapons/W_missile_closed.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )	
		self:SetSolid( SOLID_VPHYSICS )
		self.phys = self:GetPhysicsObject()
		
		if self.phys:IsValid() then self.phys:Wake() end
	end
	
	util.SpriteTrail( self, 0, Color(255,255,255,150), false, 10, 0, 0.4, 1/(3)*0.5, "trails/smoke.vmt" )
	self.turnDelay = CurTime();
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide( data, phys ) 
	if !self.Exploded then
		self:Explode()
		self.Exploded = true;
	end
end

-------------------------------------------THINK
function ENT:Think()
	self:NextThink( CurTime() + 0.001 )
	
	self.phys:SetVelocity( self:GetForward() * self.Vel )
	
	if IsValid(self.Target) then				
		local ourAng = self:GetAngles();
		local ang = ( self.Target:GetPos() - self:GetPos() ):Angle()
		if ourAng.y < 0 then ourAng.y = 360 + ourAng.y end
		if ourAng.p < 0 then ourAng.p = 360 + ourAng.p end		
		if self.turnDelay < CurTime() then
			local turnF = 10;
			
			self.yaw = math.ApproachAngle( math.Round(ourAng.y), math.Round(ang.y), turnF )
			
			self.pitch = math.ApproachAngle( math.Round(ourAng.p), math.Round(ang.p), turnF )

			self:SetAngles( Angle( self.pitch, self.yaw, ourAng.r ) )
			self.turnDelay = CurTime() + 0.005
		end		
	end
	return true;
end

function ENT:Explode()
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "stealth_explode")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	--util.BlastDamage(self, self.Owner, self:GetPos(), 350, 350)
	
	util.ScreenShake( self:GetPos(), 100, 100, 2, 5000 )
	self:Remove()
end