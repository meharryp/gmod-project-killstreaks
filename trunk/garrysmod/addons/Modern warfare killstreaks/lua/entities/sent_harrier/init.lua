AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" );
include( 'shared.lua' )
local bulletSound = Sound("killstreak_rewards/harrier_shoot.wav");
local hoveringSound = Sound("killstreak_rewards/harrier_hover.wav");
local hoverSoundDuration = SoundDuration(hoveringSound);

local backLeftWing = Model("models/military2/air/gibs/backleftwing.mdl");
local backRightWing = Model("models/military2/air/gibs/backrightwing.mdl");
local cockPit = Model("models/military2/air/gibs/cockpit.mdl");
local leftWing = Model("models/military2/air/gibs/leftwing.mdl");
local middle = Model("models/military2/air/gibs/middle.mdl");
local rightWing = Model("models/military2/air/gibs/rightwing.mdl");

ENT.radius = 2000;
ENT.radi = 20
ENT.shootPos = Vector(153, 3, -13)
ENT.sky = 0;
ENT.distance = 0;
ENT.hoverPos = NULL;
ENT.hoverMode = false;
ENT.flyTo = true
ENT.startTimer = true;
ENT.curTarget = nil;
ENT.shootDelay = CurTime();
ENT.setPos = true;
ENT.curPos = NULL;
ENT.curAng = NULL;
ENT.turnDelay = CurTime()
ENT.keepPlaying = false;
ENT.alreadyBlownUp = false;
ENT.retireDelay = CurTime();
ENT.retireOnce = false;
ENT.friendlys = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }
ENT.targets = NULL;
ENT.SoundTime = CurTime();

ENT.movementDelay = CurTime() + 8;
ENT.startAngle = 180;
ENT.turnFactor = 1;
ENT.turnAmount = 45;
ENT.turned = 0;
ENT.newAngle = 0;
ENT.direction = math.random(0,1)
ENT.moveTime = CurTime();
ENT.StartMove = false;
ENT.AllowMove = true; -- change this to make it move

function ENT:PhysicsUpdate() -- Think
	self.distance = math.Dist(self.Entity:GetPos().x, self.Entity:GetPos().y, self.hoverPos.x, self.hoverPos.y)
	self:SetAngles(self.curAng);
	if !self:FindHoverZone() && self.flyTo then 		
		self.PhysObj:SetVelocity(self.Entity:GetForward()* self.distance)	
		self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.sky));
		
	elseif self:FindHoverZone() && self.flyTo then 
		self.hoverMode = true;
		self.flyTo = false;
		
	elseif self.hoverMode then
		self.PhysObj:SetVelocity(Vector(0,0,0))	
		if self.setPos then
			self.curPos = self.Entity:GetPos()
			self.setPos = false;
		end		
		
		if self.startTimer then --// Sets a timer so that the harrier will leave after 45 seconds
			self.retireDelay = CurTime() + 45;
			self.retireOnce = true;
			self.startTimer = false;			
		end
		
		if self.curTarget != nil && self.curTarget:IsValid() && self.shootDelay <= CurTime() then	--// This is what tells the harrier to attack the target
			self.StartMove = false;
			self.shootDelay = CurTime() + 0.2;
			self:EngageEnemy();
			
		elseif ( self.curTarget == nil || !self.curTarget:IsValid() ) && self.shootDelay <= CurTime() then	--// if there is no target then find one
			self.curTarget = nil;			
			if !self.StartMove then 
				self.StartMove = true;	
				self.movementDelay = CurTime() + 8;
			end
			self.shootDelay = CurTime() + 0.01
			self:FindEnemys();
		end
		
		if self.StartMove && self.AllowMove then
			self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self.sky))
			self:SetAngles(Angle(0, self.startAngle + self.newAngle,0))
			if self.movementDelay < CurTime() && math.abs(self.turned) < self.turnAmount * self.turnFactor then
				if direction == 0 then
					self.turned = self.turned + 1;
					self.newAngle = self.newAngle + 1;			
				else 
					self.turned = self.turned - 1;
					self.newAngle = self.newAngle - 1;
				end
			elseif self.movementDelay < CurTime() && math.abs(self.turned) >= self.turnAmount * self.turnFactor then
				self.turned = 0;
				self.movementDelay = CurTime() + 8;
				self.moveTime = CurTime() + .5;
				self.direction = math.random(0,1)
				self.turnFactor =  math.random(1,6)
			elseif self.moveTime > CurTime() then
				self.PhysObj:SetVelocity(self:GetForward() * 600)
			end
		else
			self.Entity:SetPos(self.curPos);	
		end
		
	elseif !self.flyTo && !self.hoverMode then
		self.PhysObj:SetVelocity(self.Entity:GetForward()*(self.distance + 50))	
	end	
	
	if( !self.Entity:IsInWorld()) then
		self:Remove();
	end
	
	if self.SoundTime <= CurTime() && self.keepPlaying then
		self:StartHoverSound()	
		self.SoundTime = hoverSoundDuration + CurTime()
	end
	
	if self.retireOnce && self.retireDelay <= CurTime() && self.curTarget == nil then
		self.retireOnce = false;
		self:HarrierLeave()
	end
	
end

function ENT:Initialize()	
	self.hoverMode = false;
	self.flyTo = true
	self.startTimer = true;
	self.retireOnce = false;
	self.curTarget = nil;
	self.setPos = true;
	
	self.Owner = self.Entity:GetVar("owner",Entity(1))	

--	self.hoverPos = self.Owner:GetNetworkedVector("Hover_zone_vector");	
	self.hoverPos = self:GetVar("HarrierHoverZone", NULL)
	self.spawnPos = self.Owner:GetNetworkedVector("Harrier_Spawn_Pos");
	self.sky = self.spawnPos.z
	self.hoverPos = Vector(self.hoverPos.x, self.hoverPos.y, self.sky)
	
	self.Entity:SetModel( "models/harrier.mdl" )
	self.Entity:SetColor(255,255,255,255)
	self.Entity:SetPos( self.spawnPos)
	self.curAng = Angle(0, self.startAngle, 0);
	self.Entity:SetAngles(self.curAng)
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity(false);
		self.PhysObj:Wake()
	end
	self.PhysgunDisabled = true
	constraint.NoCollide( self.Entity, GetWorldEntity(), 0, 0 );	
	self.keepPlaying = true
	self.alreadyBlownUp = false;
end

function ENT:FindHoverZone()
	local jetPos = self.Entity:GetPos();
	self.distanceToTarget = jetPos - self.hoverPos;
	if math.abs(self.distanceToTarget.x) <= self.radi && math.abs(self.distanceToTarget.y) <= self.radi then
		return true;
	end
	return false;
end

function ENT:FindEnemys()
	self.groundV2 = -16384;
	
	minVec = self.Entity:GetPos() - Vector(self.radius, self.radius, 0);
	minVec = Vector(minVec.x, minVec.y, self.groundV2);
	maxVec = self.Entity:GetPos() + Vector(self.radius, self.radius, 0);

--[[
	minVec = (self.Entity:GetPos() + (self.Entity:GetRight() * radius)) * -1;
	minVec = Vector(minVec.x, minVec.y, 0);
	maxVec = self.Entity:GetPos() + (self.Entity:GetForward() * radius)
	maxVec = Vector(maxVec.x, maxVec.y, -16384);
	]]
	self.targets = ents.FindInBox(minVec, maxVec)
	enemys = {}
	for k, v in pairs(self.targets) do				
		if self:FilterEnemy(v) then
			table.insert(enemys, v);
		end
	end
	if table.Count(enemys) >= 1 then
		self.curTarget = table.Random(enemys);
	else
		self.curTarget = nil;
	end
end

function ENT:FilterEnemy(v)
	if v:IsValid() then
		if ( ( v:IsNPC() && checkForStriders(v) ) || (v:IsPlayer() && v != self.Owner && GetConVarNumber("sbox_plpldamage") != 0 && self.Owner:Team() != v:Team()) ) then
			if !table.HasValue(self.friendlys, v:GetClass()) then
				if self:traceHitEnemy(v) then 			
					return true;
				end
			end
		end
	end
	return false;
end

function checkForStriders(v)
	if v:GetClass() == "npc_strider" then return false end
	local tab = string.Explode("_", v:GetClass())
	if table.HasValue( tab, "strider" ) then
		return false
	end
	return true;
end

function ENT:EngageEnemy()
	if self.curTarget:IsValid() && self:traceHitEnemy(self.curTarget) then
		local entityCenter = Vector(0, 0, self.curTarget:OBBMaxs().z) 
		local pos = self.curTarget:GetPos() - (self.curTarget:OBBCenter( ) - entityCenter)
		local dist = (self.Entity:GetPos() + self.shootPos) - pos;
		local target = dist:GetNormal();
		target = target * -1; 
		
		bullet = {}
		
		bullet.Src		= self.Entity:GetPos() + self.shootPos;
		bullet.Attacker = self.Owner;
		bullet.Dir		= target;
				
		bullet.Spread		= Vector(0.01,0.01,0)
		bullet.Num		= 1
		bullet.Damage		= 35
		bullet.Force		= 5
		bullet.Tracer		= 1	
		bullet.TracerName	= "HelicopterTracer"
		
		self.Entity:FireBullets(bullet);
		self:EmitSound(bulletSound,140,100)
	end
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:traceHitEnemy(enemy)

	local startPos = self:GetPos();
	local endPos = enemy:GetPos();

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = self;

	local clearSight = false;
	local traceData = util.TraceLine(trace);
	local hitWorld = traceData.HitWorld;
	
	if hitWorld then			
		clearSight = false;
	else
		clearSight = true;
	end
	return clearSight;
end

function ENT:HarrierLeave()
	self.hoverMode = false;
	self.keepPlaying = false;
	self:StopSound(hoveringSound);
end

function ENT:StartHoverSound()
	self.Entity:EmitSound(hoveringSound,85,100)
end

function ENT:OnTakeDamage(dmg)
	if( dmg:IsExplosionDamage() ) then
		self:Destroy();
	end
end

function ENT:Destroy()
	self:HarrierLeave();
	self:BlowUpJet();
end 

function ENT:BlowUpJet()
	if self.alreadyBlownUp then return end;
	self.alreadyBlownUp = true;
	--Boom!
		local expl = ents.Create("env_explosion")
		expl:SetKeyValue("spawnflags",128)
		expl:SetPos(self.Entity:GetPos())
		expl:Spawn()
		expl:Fire("explode","",0)
	
		local FireExp = ents.Create("env_physexplosion")
		FireExp:SetPos(self.Entity:GetPos())
		FireExp:SetParent(self.Entity)
		FireExp:SetKeyValue("magnitude", 500)
		FireExp:SetKeyValue("radius", 500)
		FireExp:SetKeyValue("spawnflags", "1")
		FireExp:Spawn()
		FireExp:Fire("Explode", "", 0)
		FireExp:Fire("kill", "", 5)
		util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 500, 500)
	
		local effectdata = EffectData()
		effectdata:SetStart( self.Entity:GetPos() )
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetScale( 1 )
		
		--Explosions!
		
		local ParticleExplode = ents.Create("info_particle_system")
		ParticleExplode:SetPos(self:GetPos())
		ParticleExplode:SetKeyValue("effect_name", "harrier_explode") -- The names are cluster_explode, 40mm_explode, and agm_explode.
		ParticleExplode:SetKeyValue("start_active", "1")
		ParticleExplode:Spawn()
		ParticleExplode:Activate()
		ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.	
		
		
		util.Effect( "Explosion", effectdata )	
		util.Effect( "HelicopterMegaBomb", effectdata )	
		util.Effect( "cball_explode", effectdata )
		
		self.Entity:SetColor(0,0,0,255)	
	
		--Spawning gibs
		local gib = NULL;
		gib = ents.Create( "prop_physics" )
		gib:SetModel(backLeftWing)
		gib:SetColor(150,150,150,255)		
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel(backRightWing)	
		gib:SetColor(150,150,150,255)					
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )	
		gib:Fire("kill", "", 15)		

		gib = ents.Create( "prop_physics" )
		gib:SetModel(cockPit)
		gib:SetColor(150,150,150,255)				
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )			
		gib:Fire("kill", "", 15)		
	
		gib = ents.Create( "prop_physics" )
		gib:SetModel(leftWing)	
		gib:SetColor(150,150,150,255)				
		gib:SetPos(self.Entity:GetPos())		
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()		
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )		
		gib:Fire("kill", "", 15)
		
		gib = ents.Create( "prop_physics" )
		gib:SetModel(middle)
		gib:SetColor(150,150,150,255)					
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()		
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )	
		gib:Fire("kill", "", 15)

		gib = ents.Create( "prop_physics" )
		gib:SetModel(rightWing)	
		gib:SetColor(150,150,150,255)						
		gib:SetPos(self.Entity:GetPos())	
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()	
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)		
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetStart( Vector(0,0,90) )
		util.Effect( "jetdestruction_explosion", effectdata )			
		
		self.Entity:Remove()
end