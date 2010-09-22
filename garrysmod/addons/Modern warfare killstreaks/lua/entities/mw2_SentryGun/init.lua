include( 'shared.lua' )

local disToTurret = 50
local TracerType = CreateConVar("SentryGun_Tracer","HelicopterTracer")
-- disables after 90 seconds
ENT.Placed = false;
ENT.Target = nil;
ENT.BarrelAttachment = "eyes"
ENT.EngageDelay = CurTime();
ENT.AimDelay = CurTime();
ENT.yaw = 0;
ENT.pitch = 0;
ENT.OurHealth = 150;

function ENT:SpawnFunction( ply, tr )
    local ent = ents.Create( self.Classname )
	ent:SetVar("owner", ply)
    ent:Spawn()
    ent:Activate()
 
    return ent
end

function ENT:Think()
	if IsValid(self.Owner) && !self.Placed then
		self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
		self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )
	end
	
	if self.Owner:KeyDown( IN_ATTACK ) && !self.Placed then -- Called for when the sentry should be placed
		self.Placed = true;
		constraint.Weld(GetWorldEntity(), self, 0,0,0, true)
		self.Owner:DrawViewModel(true)
	end	
	
	if self.Owner:KeyDown( IN_USE ) && self.Placed && self:GetPos():Distance(self.Owner:GetPos()) <= disToTurret then
		self.Placed = false;
		constraint.RemoveConstraints(self,"Weld")
		self.Owner:DrawViewModel(false)
	end
	
	if self.Placed then
		if self.Target != nil && !self.Target:IsValid() then
			self.Target = nil;
			self:SetPoseParameter("aim_pitch", 0 )
			self:SetPoseParameter("aim_yaw", 0 )
		end
		
		local ConeEnts = ents.FindInCone(self:GetPos(), self:GetAngles():Forward(), 1500, 90)	
		
		if self.Target == nil then
			
			for i, pEnt in ipairs(ConeEnts) do
				if pEnt:IsNPC() then
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
			self.Target = nil;
			self:SetPoseParameter("aim_pitch", 0 )
			self:SetPoseParameter("aim_yaw", 0 )
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
				self.Owner:ChatPrint(self.yaw)
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
				self.Target = nil;
				self:SetPoseParameter("aim_pitch", 0 )
				self:SetPoseParameter("aim_yaw", 0 )
			end
		end
	end
	self:NextThink(CurTime());  
	return true;
 end

function ENT:Initialize()	

	self.Owner = self.Entity:GetVar("owner")	
	self:SetModel( "models/Combine_turrets/Floor_turret.mdl" );
	
	self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
	self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end	
	self.PhysgunDisabled = true
	self.Owner:DrawViewModel(false)
	
	constraint.NoCollide( self, self.Owner, 0, 0 );
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
end
 
function ENT:Destroy()

end

function ENT:GetTeam()
	return self.Owner:Team()
end

 function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
 
	if(self.OurHealth <= 0) then return; end -- If the health-variable is already zero or below it - do nothing
 
	self.OurHealth = self.OurHealth - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable
 
	if(self.OurHealth <= 0) then -- If our health-variable is zero or below it
		self:Remove(); -- Remove our entity
	end
 end
