include( 'shared.lua' )

local disToTurret = 50
local TracerType = CreateConVar("SentryGun_Tracer","HelicopterTracer")
local enemys = {"npc_combine_s", "npc_poisonzombie", "NPC npc_zombie*", "npc_zombine", "npc_fastzombie*", "npc_antlion*", "npc_hunter" };

-- disables after 90 seconds
ENT.Placed = false;
ENT.Target = nil;
ENT.BarrelAttachment = "muzzle"
ENT.EngageDelay = CurTime();
ENT.AimDelay = CurTime();
ENT.LifeTimer = CurTime();
ENT.FadeTimer = CurTime();
ENT.yaw = 0;
ENT.pitch = 0;
ENT.OurHealth = 150;
ENT.AutomaticFrameAdvance = true;
ENT.Dead = false;

ENT.TurnDelay = CurTime();
ENT.MaxYaw = 60;
ENT.MinYaw = -60;
ENT.CurYaw = 0;
ENT.Direction = 1;
ENT.InitialTurnDelay = CurTime();

function ENT:Think()
	self:NextThink(CurTime());  
	if self.Dead then
		if self.FadeTimer <= CurTime() then
			self:Remove();
		end
		return true;
	end
	if IsValid(self.Owner) && !self.Placed then
		self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
		self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )
	end
	
	if self.Owner:KeyDown( IN_ATTACK ) && !self.Placed then -- Called for when the sentry should be placed
		self.Placed = true;
		self:ResetSequence( self:LookupSequence( "Deploy" ) )
		constraint.Weld(GetWorldEntity(), self, 0,0,0, true)
		self.Owner:DrawViewModel(true)
		self.InitialTurnDelay = CurTime() + 3;
	end	
	
	if self.Owner:KeyDown( IN_USE ) && self.Placed && self:GetPos():Distance(self.Owner:GetPos()) <= disToTurret then
		self.Placed = false;
		constraint.RemoveConstraints(self,"Weld")
		self.Owner:DrawViewModel(false)
		self:PreDeploy()
	end
	
	if self.Placed then
		self:Search();
		if self.Target != nil && !self.Target:IsValid() then
			self:NoTarget()
		end
		--[[
		local tempEnemys = {};
		for k, v in ipairs(enemys) do
			tempEnemys = ents.FindByClass(v);
			for j, l in ipairs(tempEnemys) do
				l:AddEntityRelationship(self, D_HT, 999 )
			end
		end
		]]
		local ConeEnts = ents.FindInCone(self:GetPos(), self:GetAngles():Forward(), 1500, 90)	
		
		if self.Target == nil then
			
			for i, pEnt in ipairs(ConeEnts) do
				if pEnt:IsNPC() && pEnt:GetClass() != "npc_bullseye" then
					local ang = ( pEnt:GetPos() - self:GetPos() ):Angle()
					local yaw = ang.y - self:GetAngles().y;
					if yaw > 60 then
						yaw = ang.y - 360
					end
					
					local pitch = ang.p					
					if pitch > 15 then
						pitch = ang.p - 360
					end
				 
					if (pitch < 15 && pitch > -15) && ( yaw < 60 && yaw > -60 ) then
					  self.Target = pEnt;
					  break;
					end
				end
			end
		end
		
		if IsValid(self.Target) && !table.HasValue(ConeEnts,self.Target) then -- This is to check to see if the target does exist, but is out side of our line of site
			self:NoTarget()
		end
		
		if IsValid(self.Target) then
			--Engage Target Here
			if self.AimDelay <= CurTime() then
				local ang = ( self.Target:GetPos() - self:GetPos() ):Angle()
				self.yaw = ang.y - self:GetAngles().y;
				if self.yaw > 60 then
					self.yaw = ang.y - 360
				end
				
				self.pitch = ang.p //- self:GetAngles().p;
				
				if self.pitch > 15 then
					self.pitch = ang.p - 360
				end
				//self.Owner:ChatPrint(self.yaw)
				self.AimDelay = CurTime() + 0.15									
			end
			
			if (self.pitch < 15 && self.pitch > -15) && ( self.yaw < 60 && self.yaw > -60 ) then
				self:SetPoseParameter("aim_pitch", self.pitch )
				self:SetPoseParameter("aim_yaw", self.yaw )
				
				if self.EngageDelay <= CurTime() then
					self:EngageTarget(self.pitch, self.yaw);
					self.EngageDelay = CurTime() + .15
				end							
			else			
				self:NoTarget()
			end
		end
	end
	if self.LifeTimer <= CurTime() then
		self:Destroy();
	end
	
	return true;
end

function ENT:NoTarget()
	self.Target = nil;
	//self:SetPoseParameter("aim_pitch", 0 )
	self.CurYaw = self:GetPoseParameter("aim_yaw")
	self.InitialTurnDelay = CurTime() + 1;
end
 
function ENT:Initialize()	

	self.Owner = self.Entity:GetVar("owner")	
	self:SetModel( "models/mw2_sentry.mdl" );
	
	self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
	self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.bullseye = ents.Create("npc_bullseye");
	self.bullseye:SetPos(self:GetPos() + self:OBBCenter());
	self.bullseye:SetKeyValue("health", tostring(self.OurHealth))
	self.bullseye:CallOnRemove("RemoveSentry", self.KillBullseye, self);
	self.bullseye:SetParent(self);
	self.bullseye:Spawn();
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end	
	self.PhysgunDisabled = true
	self.Owner:DrawViewModel(false)
	
	constraint.NoCollide( self, self.Owner, 0, 0 );
	self:PreDeploy()
	
	self.FireAnim, self.FireTime = self:LookupSequence( "Fire" );
	self.LifeTimer = CurTime() + 90;

	umsg.Start("setMW2SentryGunOwner", self.Owner);
		umsg.Entity(self.Owner);
	umsg.End()
end

function ENT:KillBullseye(ent)
	ent:Destroy()
end

function ENT:EngageTarget(pitch, yaw)

	bullet = {}		
	bullet.Src		= self:GetAttachment(self:LookupAttachment(self.BarrelAttachment)).Pos;
	bullet.Attacker = self.Owner;
	bullet.Dir		= ( self:GetAngles() + Angle(pitch, yaw, 0) ):Forward();
			
	bullet.Spread		= Vector(0.01,0.01,0)
	bullet.Num		= 1
	bullet.Damage		= 45
	bullet.Force		= 5
	bullet.Tracer		= 1	
	bullet.TracerName	= TracerType:GetString()//"HelicopterTracer"
	
	self.Entity:FireBullets(bullet);
	self:EmitSound("weapons/smg1/smg1_fire1.wav", 500, 200)
	self:StartFireing()
end
 
function ENT:StartFireing()
	self:ResetSequence( self.FireAnim )
end

function ENT:Search()
	if self.Target != nil then
		self.CurYaw = 0;
		return; 
	end
	if self.InitialTurnDelay > CurTime() then return; end
	if self.TurnDelay <= CurTime() then
		self:SetPoseParameter("aim_yaw", self.CurYaw )
		self.CurYaw = self.CurYaw + ( 1 * self.Direction );
		self.TurnDelay = CurTime() + .001;
	end
	
	if self.CurYaw >= self.MaxYaw then
		self.Direction = -1;
	elseif self.CurYaw <= self.MinYaw then
		self.Direction = 1;
	end
end

function ENT:Destroy()
	if self.Dead then return end
	self.Dead = true;
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetAttachment(self:LookupAttachment( "smoke_particle" )).Pos  )
	ParticleExplode:SetKeyValue("effect_name", "smoke_burning_engine_01")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 7) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	self:ResetSequence( self:LookupSequence( "Die" ) )
	self.FadeTimer = CurTime() + 10
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
 
	if(self.OurHealth <= 0) then return; end -- If the health-variable is already zero or below it - do nothing
 
	self.OurHealth = self.OurHealth - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable
 
	if(self.OurHealth <= 0) then -- If our health-variable is zero or below it
		//self:Destroy(); -- Remove our entity
	end
 end

function ENT:PreDeploy()
	self:ResetSequence( self:LookupSequence( "Predeploy" ) )
end