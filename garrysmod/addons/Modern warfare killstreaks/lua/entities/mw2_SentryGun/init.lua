include( 'shared.lua' )

local disToTurret = 50
local TracerType = CreateConVar("SentryGun_Tracer","HelicopterTracer")
local enemys = {"npc_combine_s", "npc_poisonzombie", "NPC npc_zombie*", "npc_zombine", "npc_fastzombie*", "npc_antlion*", "npc_hunter" };
local Sentrys = {};

-- disables after 90 seconds
ENT.Placed = false;
ENT.Target = nil;

ENT.SmokeAttachment = "smoke_particle"
ENT.EngageDelay = CurTime();
ENT.AimDelay = CurTime();
ENT.LifeTimer = CurTime();
ENT.FadeTimer = CurTime();
ENT.yaw = 0;
ENT.pitch = 0;
ENT.OurHealth = 200;
ENT.AutomaticFrameAdvance = true;
ENT.Dead = false;


ENT.TurnDelay = CurTime();
ENT.MaxYaw = 60;
ENT.MinYaw = -60;
ENT.CurYaw = 0;
ENT.Direction = 1;
ENT.InitialTurnDelay = CurTime();

ENT.SnapToDelay = CurTime();
ENT.TurnAmount = 1;
ENT.TurnFactor = 1;
ENT.ShouldSearch = false;

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
		self:SetDisposition(true);-- Makes the npcs hate the sentry
		self:SetColor(255,255,255,255);
	end	
	
	if self.Owner:KeyDown( IN_USE ) && self.Placed && self:GetPos():Distance(self.Owner:GetPos()) <= disToTurret then
		self.Placed = false;
		constraint.RemoveConstraints(self,"Weld")
		self.Owner:DrawViewModel(false)
		self:PreDeploy()
		self:SetDisposition(false); -- makes the npc feel neutral about the sentry
		self:SetColor(229,236,191,200);
	end
	
	if self.Placed then
		self:Search();
		--[[
		if !IsValid(self.Target) then
			self:NoTarget()
		end
]]
		local ConeEnts = ents.FindInCone(self:LocalToWorld(self:OBBCenter()) + (self:GetForward() * -50), self:GetAngles():Forward(), self.Dis, 90)	
		--local ConeEnts = ents.FindInCone(self:GetAttachment(self:LookupAttachment(self.BarrelAttachment)).Pos - (self:GetForward() * -50), self:GetAngles():Forward(), self.Dis, 90)	
		
		if self.Target == nil then
			
			for i, pEnt in ipairs(ConeEnts) do
				if pEnt:IsNPC() && pEnt:GetClass() != "npc_bullseye" then
					local ang = ( pEnt:GetPos() - self:GetPos() ):Angle()
					local yaw = math.NormalizeAngle( ang.y - self:GetAngles().y );

					local pitch = math.NormalizeAngle(ang.p)
				 
					if (pitch <= 45 && pitch >= -45) && ( yaw <= 60 && yaw >= -60 ) && self:HasLOS(pEnt) then
					  self.Target = pEnt;
					  --self.Owner:SetNetworkedBool("SentryGunTargetLocated", true)
					  self.yaw = self.CurYaw
					  break;
					end
				end
			end
		end
		
		if IsValid(self.Target) && !table.HasValue(ConeEnts,self.Target) then -- This is to check to see if the target does exist, but is out side of our line of site
			self:NoTarget()		
		end
		
		if IsValid(self.Target) && self:HasLOS(self.Target) then
			--Engage Target Here
			self.ShouldSearch = true;
			local ang = ( self.Target:GetPos() - self:GetPos() ):Angle()
			local vec1 = self.Target:GetPos() - self:GetPos();
			local ang1 = math.NormalizeAngle( vec1:Angle().y - self:GetAngles().y )			
			ang1 = math.Clamp( ang1 , -60, 60 )
			
			local diff = ang1 - self.yaw;			
			--[[
			self.Owner:SetNetworkedString("SentryGunYawDebug", tostring(ang1));
			self.Owner:SetNetworkedVector("SentryGunSPosDebug", self:GetPos());
			self.Owner:SetNetworkedAngle("SentryGunSAngDebug", self:GetAngles());
			self.Owner:SetNetworkedVector("SentryGunTPosDebug", self.Target:GetPos());
			]]
			if diff > -1 && diff < 1 then
				self.TurnFactor = .05;
			else
				self.TurnFactor = 1;
			end
			
			if ang1 > self.yaw && ang1 < 60 then
				self.yaw = self.yaw + (self.TurnAmount * self.TurnFactor);
			elseif ang1 < self.yaw && ang1 > -60 then
				self.yaw = self.yaw - (self.TurnAmount * self.TurnFactor);
			end
							
			self:SetPoseParameter("aim_yaw", self.yaw )			
			
			self.pitch = math.NormalizeAngle( vec1:Angle().p - self:GetAngles().p )
			self.pitch = math.Clamp( self.pitch , -45, 45 )					
			
			if (self.pitch < 45 && self.pitch > -45) && ( self.yaw < 60 && self.yaw > -60 ) then
				self:SetPoseParameter("aim_pitch", self.pitch )
				
				if self.EngageDelay <= CurTime() then
					self:EngageTarget(self.pitch, self.yaw);
					self.EngageDelay = CurTime() + .07 -- Fire delay
				end
			else			
				self:NoTarget()
			end
		elseif self.ShouldSearch then
			self.ShouldSearch = false;
			self:NoTarget()
		end
	end
	if self.LifeTimer <= CurTime() then
		self:Destroy();
	end
	return true;
end

function ENT:NoTarget()
	self.Target = nil;
	--self.Owner:SetNetworkedBool("SentryGunTargetLocated", false)
	self:SetPoseParameter("aim_pitch", 0 )
	self.CurYaw = self:GetPoseParameter("aim_yaw")
	self.InitialTurnDelay = CurTime() + 1;
end
 
function ENT:HasLOS(tar)
	
	local ang = (tar:GetPos() - self:GetPos() ):Normalize()
	local barrel = self:GetAttachment(self:LookupAttachment(self.BarrelAttachment))	
	
	--local traceRes = util.QuickTrace( self:LocalToWorld(self:OBBCenter()), ang * self.Dis, {self, self.bullseye })
	local traceRes = util.QuickTrace( barrel.Pos, ang * self.Dis, {self, self.bullseye })
		--self.Owner:SetNetworkedVector("SentryGunLOSHit", traceRes.HitPos);
	local ent = traceRes.Entity;
		--self.Owner:SetNetworkedEntity("SentryGunTracedEnt", ent);
	if ent:IsNPC() || ent:IsPlayer() then
		return true;
	end
	return false;
end
 
function ENT:Initialize()	

	self.Owner = self.Entity:GetVar("owner")	
	self:SetModel( "models/mw2_sentry/sentry_gun.mdl" );
	
	self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
	self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.bullseye = ents.Create("npc_bullseye");
	self.bullseye:SetPos(self:GetPos() + self:OBBCenter());
	
	self.bullseye:SetKeyValue("health", tostring(self.OurHealth))
	self.bullseye:SetKeyValue("spawnflags", "262144")
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
	table.insert(Sentrys,self.bullseye);
	self:SetColor(229,236,191,200);
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
	if IsValid(self.Target) then
		self.CurYaw = 0;
		--self.Owner:SetNetworkedBool("SentryGunSearching", false);
		return; 
	end	
	if self.InitialTurnDelay > CurTime() then return; end
	--self.Owner:SetNetworkedBool("SentryGunSearching", true);
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
	for k, v in pairs(Sentrys) do
		if v == self.bullseye then
			table.remove(Sentrys, k);
			break;
		end
	end
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

function ENT:SetDisposition(level)
	local tempEnemys = {};
		for k, v in ipairs(enemys) do
			tempEnemys = ents.FindByClass(v);
			for j, l in ipairs(tempEnemys) do
				if level then
					l:AddEntityRelationship(self.bullseye, D_HT, 99 )
				else
					l:AddEntityRelationship(self.bullseye, D_NU, 99 )
				end
			end
		end
end
function SetDisOnSentrys(pl, npc) -- When an enemy npc spawns, will set their disposition to hate all sentrys.
	for k, v in ipairs(Sentrys) do
		npc:AddEntityRelationship(v, D_HT, 99 )
	end
end

hook.Add("PlayerSpawnedNPC", "SetDisOnSentrys", SetDisOnSentrys);
