include( 'shared.lua' )

ENT.Model = "models/dav0r/camera.mdl";
ENT.DropDelay = CurTime();
ENT.playOnce = true;
ENT.findHoverZone = true
ENT.WallLoc = NULL;
ENT.Bomber = nil
ENT.InitialDelay = CurTime();
ENT.restrictMovement = true;

function ENT:Think()
	self:NextThink( CurTime() + 0.1 )
	if IsValid(self.Bomber) && !self.Bomber:IsInWorld() then
		self.Bomber:Remove()
		self:Remove()
		return true;
	end

	if self.DropLoc == nil || self.DropAng == nil then return end

	if self.findHoverZone then
		self.findHoverZone = false;
		
		self.WallLoc = self:FindWall();
		self.FlyAng = self.DropAng
		
		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])
		if IsValid(self.Wep) then
			self.Wep:CallIn();
		end
		self:SpawnBomber();		
	else
		self.Bomber.PhysObj:SetVelocity(self.Bomber:GetForward()*5000)
		if self.DropDelay < CurTime() && self.InitialDelay < CurTime() then
			self.DropDelay = CurTime() + .08;
			self:SpawnBomb();
		end
	end
	
	if !self.findHoverZone && self.playOnce then
		self.Wep:PlaySound();
		self.playOnce = false;
	end
	return true;
end

function ENT:MW2_Init()
	self.Entity:SetModel( "models/dav0r/camera.mdl" )
	self.Entity:SetColor(255,255,255,0)
	self:SetPos(Vector(0,0, 0));
	
	self.PhysObj:EnableGravity(false)
	self.Entity:SetNotSolid(true);
	
	self:OpenOverlayMap(true);
end

function ENT:SpawnBomber()
	self.ground = self:findGround() + 4000;
	self.Bomber = ents.Create("prop_physics")
	self.Bomber:SetModel("models/military2/air/air_f117_l.mdl")
	self.Bomber:SetColor(255,255,255,255)
	self.Bomber:SetPos( Vector( self.WallLoc.x, self.WallLoc.y, self.ground) )
	self.Bomber:SetAngles( self.FlyAng )
	
	self.Bomber:PhysicsInit( SOLID_VPHYSICS )
	self.Bomber:SetMoveType( MOVETYPE_VPHYSICS )		
	self.Bomber:SetSolid( SOLID_VPHYSICS )

	self.Bomber.PhysObj = self.Bomber:GetPhysicsObject()
	if (self.Bomber.PhysObj:IsValid()) then
		self.Bomber.PhysObj:Wake()
	end
	self.InitialDelay = CurTime() + .6;
	
	constraint.NoCollide( self.Bomber, GetWorldEntity(), 0, 0 );	
	self.Bomber.PhysgunDisabled = true
end

function ENT:SpawnBomb()
	local bomb = ents.Create( "sent_air_strike_bomb" );
	bomb:SetPos(self.Bomber:GetPos() + (self.Bomber:GetRight() * -50) )
	bomb:SetAngles(self.Bomber:GetAngles());
	bomb:SetVar("owner",self.Owner)
	bomb:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	bomb:Spawn();
	constraint.NoCollide( self.Bomber, bomb, 0, 0 );	
	bomb:SetVar("HasBeenDropped",true);
	
	local bomb2 = ents.Create( "sent_air_strike_bomb" );
	bomb2:SetPos(self.Bomber:GetPos() + (self.Bomber:GetRight() * 50) )
	bomb2:SetAngles(self.Bomber:GetAngles());
	bomb2:SetVar("owner",self.Owner)
	bomb2:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	bomb2:Spawn();
	constraint.NoCollide( self.Bomber, bomb2, 0, 0 );
	bomb2:SetVar("HasBeenDropped",true);		
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:FindWall()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -100000, self).HitPos
end
