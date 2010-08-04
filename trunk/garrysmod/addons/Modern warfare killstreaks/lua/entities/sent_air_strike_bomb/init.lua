include( 'shared.lua' )

function ENT:PhysicsUpdate()
--[[
	if self:GetVar("Dropped", false) then
		//self.PhysObj:SetVelocity(self:GetForward()*10)
	end
	]]
end

function ENT:Think()
 end


function ENT:Initialize()	
	self.Entity:SetModel( "models/military2/bomb/bomb_jdam.mdl" ); 
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


function ENT:HitEffect()
	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 1250 ) ) do

	if v:IsValid() && v:IsPlayer() then
		
		v:ConCommand( "pp_motionblur 1; pp_dof 1; sensitivity 1; play killstreak_rewards/shellshock.wav" )
 		v:SetWalkSpeed(50)
		v:SetRunSpeed(50)
		timer.Simple( 5, v.ConCommand, v, "pp_motionblur 0; pp_dof 0; sensitivity 10" )
		timer.Simple( 5,  v.SetWalkSpeed, v, "250" )
		timer.Simple( 5,  v.SetRunSpeed, v, "500" )
			
		end
	end
end

function ENT:Explosion()

	ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "stealth_explode")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	util.BlastDamage(self, self.Owner, self:GetPos(), 350, 350)
	
	--[[
	local expl = ents.Create("env_explosion")
	expl:SetOwner(self)
	expl:SetKeyValue("spawnflags",128)
	expl:SetKeyValue("iMagnitude", "350")
	expl:SetPos(self.Entity:GetPos())
	expl:Spawn()
	self:HitEffect()
	expl:Fire("explode","",0)
	]]
	util.ScreenShake( self.Entity:GetPos(), 100, 100, 2, 5000 )
end
