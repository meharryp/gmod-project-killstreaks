include( 'shared.lua' )

ENT.ExplosionSound = Sound("killstreak_explosions/105_explosion.wav")

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self.Entity:GetForward() * 3500)
end

function ENT:Initialize()	
	self.Entity:SetModel( "models/military2/bomb/bomb_gbu10.mdl" );
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	timer.Simple(.5, self.EmitSound, self, "ac-130_kill_sounds/105mminair.wav", 475, 100)
end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
		//self.Entity:Remove()
	end
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:Explosion()
	local blastRadius = 1000
	local targets = ents.FindInSphere(self:GetPos(), blastRadius)
	
	util.BlastDamage(self, self.Owner, self:GetPos(), blastRadius, blastRadius)

	self:EmitSound(self.ExplosionSound, 400,100)
	
	timer.Simple(.5, self.CountDeadBodys, self, targets)
	
	ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "agm_explode") -- The names are cluster_explode, 40mm_explode, and agm_explode.
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	
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

	util.ScreenShake( self.Entity:GetPos(), 100, 100, 1, 2000 )
	self.Entity:Remove()
end

function ENT:CountDeadBodys(bodys)
	local deadBodys = -1; //Starts at -1 because of the enitity its self will be removed when it gets here
	
	for k,v in pairs(bodys) do		
		if !v:IsValid() then
			deadBodys = deadBodys + 1;
		end
	end
	//MsgN("Killed targets = " .. deadBodys)
	
	umsg.Start("MW2_AC130_Kill_Sounds", self.Owner)
		umsg.Long(deadBodys)
	umsg.End()
	
end