AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local flyBySound = Sound("killstreak_misc/jet_fly_by.wav");

ENT.dropPos = NULL;
local radius = 500;
ENT.Model = Model("models/military2/air/air_f35_l.mdl")
ENT.ground = 0;
ENT.dropDelay = CurTime();
ENT.droppedBombset1 = false;
ENT.droppedBombset2 = false;
ENT.bomb = NULL;
ENT.bomb2 = NULL;
ENT.bomb3 = NULL;
ENT.bomb4 = NULL;
ENT.DropDaBomb = false;
ENT.StartAngle = NULL;
ENT.WasInWorld = false;

function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self:GetForward()*7000)
	self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self.ground));

	self:SetAngles(self.StartAngle)

	if( !self:IsInWorld() && self.WasInWorld) then
		self:Remove();
	end
	
	if !self.WasInWorld && self:IsInWorld() then
		self.WasInWorld = true;
	end
	
	if( self:FindDropZone(self.dropPos) && self.dropDelay < CurTime()) && (!self.droppedBombset1 || !self.droppedBombset2) then
		self.dropDelay = CurTime() + 0.1;
		self:DropBomb()		
	end	
end

function ENT:MW2_Init()	
	self.StartPos = self:GetVar("WallLocation", NULL);
	self.FlyAng = self:GetVar("FlyAngle", NULL);

	self.dropPos = self:GetVar("JetDropZone", NULL)
	self.ground = self:findGround() + 2000;
	
	if self.StartPos != NULL && self.FlyAng != NULL then
		self.spawnZone = Vector(self.StartPos.x, self.StartPos.y, self.ground);
		self.StartAngle = self.FlyAng;
	else
		local x,x2 = self:FindBounds(true)
		self.spawnZone = Vector(x,self.dropPos.y,self.ground);
		self.StartAngle = Angle(0, 180, 0);
		self.Owner:SetNetworkedVector("Harrier_Spawn_Pos", self.spawnZone);
	end			
	self.Entity:SetPos(self.spawnZone )
	self.Entity:SetAngles( self.StartAngle )
	
	
	self:FindMinHeight()
	self.spawnZone.z = self:FindMinHeight();
	self.Entity:SetPos(self.spawnZone )	
	self:SpawnBombs()

	constraint.NoCollide( self.Entity, GetWorldEntity(), 0, 0 );	
	self.PhysgunDisabled = true

end
ENT.BombPos = { Vector(-149, 99, -21), Vector(-149, -99, -21), Vector(-176, 144, -21), Vector(-176, -144, -21) };
ENT.Bombs = {};
function ENT:SpawnBombs()
	local bombSent = "sent_air_strike_cluster"
	for k,v in pairs( self.BombPos ) do
		local bomb = ents.Create( bombSent );
		bomb:SetPos( self:LocalToWorld(v) )
		bomb:SetAngles(self:GetAngles());
		bomb:SetVar("owner",self.Owner)
		bomb:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
		bomb:Spawn();
		bomb:SetNotSolid(true);		
		constraint.NoCollide( self, bomb, 0, 0 );
		constraint.Weld(self, bomb, 0,0,0, false)	
		bomb.PhysgunDisabled = true
		
		table.insert(self.Bombs, bomb)
	end
end

function ENT:FindMinHeight()
	local startPos = self:GetPos()
	local endPos = startPos + ( self:GetForward() * 1000000)
	local filterList = {self}
	
	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local bool = true;
	local maxNumber = 0;
	local skyLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		if traceData.HitSky then
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif traceData.HitWorld then
			local loc = traceData.HitPos 

			local skytrace = {}
			skytrace.start = Vector( loc.x, loc.y, self.Sky )
			skytrace.endpos = loc
			local tr = util.TraceLine(skytrace)

			local hit = tr.HitPos + Vector(0,0, 500);
			
			trace.start = hit.z;
			trace.endpos = hit.z;
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 300 then
			MsgN("Reached max number here, no luck in finding a skyBox");
			bool = false;
		end
		maxNumber = maxNumber + 1;
	end
	
	if self:GetPos().z > skyLocation then 
		return self:GetPos().z;
	end
	
	return skyLocation;	
end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:FindDropZone(vec)
	local jetPos = self.Entity:GetPos();
	local distance = jetPos - self.dropPos;
	if math.abs(distance.x) <= radius && math.abs(distance.y) <= radius then
		return true;
	end
	return false;
end

function ENT:DropBomb()
	if !self.droppedBombset1 then	
		for i=1,2 do 
			local bomb = self.Bombs[i]
			constraint.RemoveConstraints(bomb, "Weld")
			bomb:SetNotSolid(false);
		
			bomb:GetPhysicsObject():SetVelocity(Vector(0,0,0));
		
			bomb:SetVar("HasBeenDropped",true);
			
		end
		table.remove( self.Bombs, 2 )
		table.remove( self.Bombs, 1 )
		self.droppedBombset1 = true;
		self:EmitSound(flyBySound, 500, 100)
	elseif !self.droppedBombset2 then
		for i=1,2 do 
			local bomb = self.Bombs[i]
			constraint.RemoveConstraints(bomb, "Weld")
			bomb:SetNotSolid(false);
		
			bomb:GetPhysicsObject():SetVelocity(Vector(0,0,0));
		
			bomb:SetVar("HasBeenDropped",true);
			
		end
		table.remove( self.Bombs, 2 )
		table.remove( self.Bombs, 1 )
		self.droppedBombset2 = true;
	end
end

