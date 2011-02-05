
include( 'shared.lua' )

--Variables to be set by sub classes
ENT.SearchSize = 0;
ENT.SpawnHeight = 0;
ENT.MaxHeight = 0;
ENT.Damage = 0;
ENT.AIGunner = true;
ENT.BarrelAttachment = "";
ENT.LifeDuration = 0;
ENT.SectorHoldDuration = 0;
ENT.MaxSpeed = 0;
ENT.MinSpeed = 0;
ENT.ShootTime = 0;
ENT.MaxBullets = 0;
ENT.BarrelCoolDownDelay = 0;
--Variables set by the entity for it to function.
ENT.Ground = 0;
ENT.Sectors = {};
ENT.TempSectors = {};
ENT.Target = nil;
ENT.CurSector = nil;
ENT.SectorDelay = CurTime();
ENT.Life = CurTime();
ENT.IsInSector = false;
ENT.CurHeight = 0;
ENT.turnDelay = CurTime();
ENT.Pitch = 0;
ENT.Roll = 0;
ENT.PrevSector = nil;
ENT.FireDelay = CurTime();
ENT.Leave = false;
ENT.speedScaler = 0;
ENT.TargetAcquired = false;
ENT.BulletsShot = 0;
ENT.CoolDownTime = CurTime();
ENT.CoolDown = false;

local function removeSector(tab, value)
	for k,v in pairs(tab) do
		if v == value then
			table.remove(tab, k)
		end
	end
end

local function searchBox(startVec, endVec, size) -- startVec = Starting Vector, endVec = Ending Vector, size = The toatl width and length of the box.
	local s, e = Vector(startVec.x, startVec.y, 0 ), Vector( endVec.x, endVec.y, 0);
	
	local ang = ( e - s ):Angle():Right();	
	local st = s + (ang * size/2 )

	ang = ( s - e ):Angle():Right();
	local en = e + (ang * size/2 )

	return Vector( st.x, st.y, startVec.z), Vector( en.x, en.y, endVec.z );
	
end

function ENT:MW2_Init()	
	self.Ground = self:findGround();
	
	self.MapBounds.xPos, self.MapBounds.xNeg = self:FindBounds(true);
	self.MapBounds.yPos, self.MapBounds.yNeg = self:FindBounds(false);
	self.Sectors = {};
	self:SetupSectors();
	self.TempSectors = self.Sectors;
	MsgN( table.Count( self.Sectors ) )
	self.CurHeight = self.Ground + self.SpawnHeight;
	self:SetPos( Vector( self.MapBounds.xPos, 0, self.CurHeight ) )
	self:SetAngles( Angle( 0, 181, 0 ) )
	self.Life = CurTime() + self.LifeDuration
	self.speedScaler = 0;
	
	self:Helicopter_Init()
end

function ENT:Helicopter_Init()	
end

function ENT:Think()
	self:NextThink( CurTime() + 0.01 )
	
	self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.CurHeight ) );
	
	if IsValid(self) && !self:IsInWorld() then
		self:Remove();
	end	
	
	if self.Leave then
		local curSpeed = Lerp(self.speedScaler, 0, self.MaxSpeed)
		self.PhysObj:SetVelocity( self:GetForward() * curSpeed)
		self.speedScaler = self.speedScaler + .01
		self:SetPitch(true)
		self:SetRoll(false)		
		return true;
	end
	
	if self.Life < CurTime() then
		self:RemoveHeli();
		return true;
	end
	
	--self:SetAngles( Angle( self.Pitch, self:GetAngles().y, self.Roll ) )
	
	if self.CurSector == nil then
		if table.Count(self.TempSectors) <= 0 then self.TempSectors = self.Sectors; end
		local sec = self:FindSector();
		if sec != self.PrevSector then
			self.CurSector = sec;
			--removeSector( self.TempSectors, self.CurSector);
			self.IsInSector = false;
			self.CurSector.MidPoint.Prop:SetColor(0,255,0,255) ---------------------
			--MsgN("Pos = " .. tostring( self.CurSector.MidPoint.Prop:GetPos() ) )
		end
	end
	
	if !self.IsInSector && !self.TargetAcquired then
		self:MoveToArea();
	elseif self.IsInSector && self.CurSector != nil then
		self:SetPitch(false)
		if self.SectorDelay < CurTime() then
			self.CurSector.MidPoint.Prop:SetColor(255,255,255,255) ---------------
			self.PrevSector = self.CurSector;
			self.CurSector = nil;
		end
	end	
	
	if self.AIGunner then
		if !self:VerifyTarget() then
			self:FindTarget();
		end
		if self:VerifyTarget() then
			if self.BulletsShot <= self.MaxBullets then
				self:EngageTarget();
			elseif !self.CoolDown then
				self.CoolDownTime = CurTime() + self.BarrelCoolDownDelay
				self.CoolDown = true;
			elseif self.CoolDownTime > CurTime() then
				self.CoolDown = false;
				self.BulletsShot = 0;
			end
		end
	end
	
	return true;
end

function ENT:FindSector()

	local maxCount = 0;
	local count = 0;
	local maxSector = nil;
	for k,v in pairs(self.TempSectors) do
		count = v.Enemies();
		if maxCount < count then
			maxCount = count
			maxSector = v;
		end
	end	
	if maxSector != nil then
		return maxSector;
	else
		return table.Random(self.TempSectors);
	end
	
end

function ENT:MoveToArea()
	local targetPos = Vector( self.CurSector.MidPoint.x, self.CurSector.MidPoint.y, self:GetPos().z )
	local dis = self:GetPos():Distance( targetPos );
	--self.Owner:SetNetworkedString("AttackHeliDis", dis ) ----------------
	local speedFactor = 1;
	local disAway = 2;
	if dis < self.SearchSize/4 && dis >= disAway then
		speedFactor = dis / (self.SearchSize / 4) 
		speedFactor = math.Clamp(speedFactor, 0, 1)
		self:SetPitch(false)
	elseif dis < disAway then
		speedFactor = 0;
		self.IsInSector = true;
		self.SectorDelay = CurTime() + self.SectorHoldDuration;
	else
		local curSpeed = Lerp(self.speedScaler, 0, self.MaxSpeed)
		self.PhysObj:SetVelocity( self:GetForward() * curSpeed)
		self.speedScaler = self.speedScaler + .01
	end
	
	if self.PrevSector then
		local curSecPos = Vector( self.PrevSector.MidPoint.x, self.PrevSector.MidPoint.y, self:GetPos().z )
		dis = self:GetPos():Distance( curSecPos );
		if dis < self.SearchSize/4 then
			speedFactor = dis / (self.SearchSize / 4) 
			speedFactor = math.Clamp(speedFactor, .1, 1)
		else
			self.PrevSector = nil;
		end
	end
	
	local speed = self:CalculateSpeed(targetPos);
	local dir = (targetPos - self:GetPos()):Normalize()
	local ourAng = self:GetAngles();
	local ang = ( (targetPos - self:GetPos()):Angle().y ) //- ourAng.y

	if ourAng.y < 0 then
		ourAng.y = 360 + ourAng.y
	end
	
	--self.Owner:SetNetworkedString("AttackHeliYaw", ang ) ----------------
	--self.Owner:SetNetworkedString("AttackHeliAng", ourAng.y ) ----------------
	--self.Owner:SetNetworkedString("AttackHeliSpeed", speed) ----------------
	if self.turnDelay < CurTime() then
		local turnF = 1;
		ang = math.Round(ang);
		if ang >= 360 then ang = 0; end
		if ang > math.Round(ourAng.y) then			
			self:SetPitch(false)
			self:SetRoll(true)
			self:SetAngles( Angle( self.Pitch, ourAng.y + turnF, self.Roll ) )
		elseif ang < math.Round(ourAng.y) then			
			self:SetPitch(false)
			self:SetRoll(true)
			self:SetAngles( Angle( self.Pitch, ourAng.y - turnF, self.Roll ) )
		else
			self:SetPitch(true)
			self:SetRoll(false)
		end
		self.turnDelay = CurTime() + 0.01;
	end
	
	self.PhysObj:SetVelocity( dir * (speed * speedFactor) )
end

function ENT:CalculateSpeed(targetPos)
	local ang = ( (targetPos - self:GetPos()):Angle().y ) - self:GetAngles().y	
	ang = math.NormalizeAngle(ang)
	local factor = math.abs(ang)/180 -- 180 is the oppiste direction of where we are heading.
	local speedDif = self.MaxSpeed - self.MinSpeed
	local newSpeed = self.MaxSpeed - ( speedDif * math.Round(factor) )
	return newSpeed;
end

function ENT:SetPitch(inc)
	if inc then
		if self.Pitch <= 15 then
			self.Pitch = self.Pitch + 1;
		end
	else
		if self.Pitch > 0 then
			self.Pitch = self.Pitch - 1;
		end
	end
	self:SetAngles( Angle( self.Pitch, self:GetAngles().y, self:GetAngles().r ) )
end

function ENT:SetRoll(inc)
	if inc then
		if self.Roll <= 20 then
			self.Roll = self.Roll + 1;
		end
	else
		if self.Roll > 0 then
			self.Roll = self.Roll - 1;
		end
	end
	self:SetAngles( Angle( self:GetAngles().p, self:GetAngles().y, self.Roll ) )
end

function ENT:SetupSectors()
	local x1, x2, y1, y2 = self.MapBounds.xPos, self.MapBounds.xNeg, self.MapBounds.yPos, self.MapBounds.yNeg;
	local tX, tY = 0, 0;
	local bool = true;
	while bool do
		tX, tY = 0, 0;
		x1 = self.MapBounds.xPos;
		while x1 >= x2 do
			
			if x1 - self.SearchSize >= x2 then
				tX = x1 - self.SearchSize;
			else
				tX = x2;
			end
			
			if y1 - self.SearchSize >= y2 then
				tY = y1 - self.SearchSize;
			else
				tY = y2;
				bool = false;
			end
			
			self:InitSector( x1, y1, tX, tY)
			
			x1 = x1 - self.SearchSize;
		end
		y1 = y1 - self.SearchSize;
	end
	
end

function ENT:InitSector( x, y, x2, y2 )
	local sec = {}
	sec.x = x;
	sec.y = y;
	sec.x2 = x2;
	sec.y2 = y2;
	local midX = x - ( (x - x2) / 2)
	local midY = y - ( (y - y2) / 2)
	sec.MidPoint = {};
	sec.MidPoint.x = midX;
	sec.MidPoint.y = midY;	
	
	local function EnemyCount(entTab)
		local count = 0;
		for k,v in pairs(entTab) do
			if self:FilterTarget(v, true) then count = count + 1; end
		end
		return count;
	end
	
	sec.Enemies = function()
		local maxVec = Vector( x, y, self.Ground + self.SpawnHeight + self.MaxHeight )
		--MsgN(maxVec.z)
		local minVec = Vector( x2, y2, -16384)		
		return EnemyCount( ents.FindInBox( minVec, maxVec ) );
	end
	
	if self:PointInWorld( midX, midY ) then
		table.insert( self.Sectors, sec);
	end	
end

function ENT:PointInWorld( x, y )
	local minheight = -16384

	local trace = {}
	trace.start = Vector( x, y, self.Sky) ;
	trace.endpos = Vector(x, y, minheight);
	trace.filter = {self.Owner, self};

	local hitHeight = util.TraceLine(trace).HitPos.z;
	
	if hitHeight < self.Ground + self.SpawnHeight + self.MaxHeight then
		return true;
	end
	return false;
end

function ENT:FindTarget()
	local pos = self:GetPos();	
	local des = pos + ( self:GetForward() * self.SearchSize * 1.5 )
	
	pos.z = self.Ground + self.SpawnHeight + self.MaxHeight
	des.z = -16384;
	local maxVec, minVec = searchBox( pos , des)
	--local maxVec = Vector( pos.x , pos.y, self.Ground + self.SpawnHeight + self.MaxHeight ) local minVec = Vector( pos.x - self.SearchSize/2, pos.y - self.SearchSize/2, -16384)
	
	local es = ents.FindInBox( minVec, maxVec )
	self.Target = self:PrioritizeTargets(es)
	
	if self.Target == nil && self.IsInSector && self.CurSector != nil then
		maxVec = Vector( self.CurSector.x, self.CurSector.y, self.Ground + self.SpawnHeight + self.MaxHeight )
		minVec = Vector( self.CurSector.x2, self.CurSector.y2, -16384)
		es = ents.FindInBox( minVec, maxVec )
		
		for k,v in pairs(es) do
			if self:FilterTarget(v, true) then
				self.Target = v;
				break;
			end
		end			
	end
	if IsValid(self.Target) then
		self.TargetAcquired = true;
	end
end

function ENT:PrioritizeTargets(targets)
	
	local prio1 = {};
	local prio2 = {};
	for k,v in pairs(targets) do
		if self:FilterTarget(v, true) && v:GetEnemy() == self then
			table.insert(prio1, v)
		elseif self:FilterTarget(v, true) then
			table.insert(prio2, v)
		end
	end
	
	if table.Count(prio1) + table.Count(prio2) <= 0 then
		return nil;	
	elseif table.Count(prio1) > 0 then
		return table.Random(prio1)
	else
		return table.Random(prio2)
	end
	
end

function ENT:VerifyTarget()
	if IsValid(self.Target) && self:HasLOS(self.Target) then
		return true;
	end
	self.Target = nil;
	self.TargetAcquired = false;
	return false;
end

function ENT:EngageTarget()
	local ourAng = self:GetAngles();
	local ang = ( self.Target:GetPos() - self:GetPos() ):Angle().y

	if ourAng.y < 0 then
		ourAng.y = 360 + ourAng.y
	end
	
	if self.turnDelay < CurTime() then
		local turnF = 1;
		ang = math.Round(ang);
		if ang >= 360 then ang = 0; end
		if ang > math.Round(ourAng.y) then					
			self:SetAngles( Angle( self.Pitch, ourAng.y + turnF, self.Roll ) )
			self:SetRoll(false)
		elseif ang < math.Round(ourAng.y) then			
			self:SetAngles( Angle( self.Pitch, ourAng.y - turnF, self.Roll ) )
			self:SetRoll(false)
		elseif self.FireDelay < CurTime() then
				self:ShootTarget();
				self.FireDelay = CurTime() + self.ShootTime;
		end	
		self.turnDelay = CurTime() + 0.01
	end
end

function ENT:ShootTarget()
		
	bullet = {}		
	bullet.Src		= self:GetAttachment(self:LookupAttachment(self.BarrelAttachment)).Pos;
	
	local dir = ( self.Target:LocalToWorld(self.Target:OBBCenter()) - bullet.Src ):Normalize();
	
	bullet.Attacker = self.Owner;
	bullet.Dir		= dir
			
	bullet.Spread		= Vector(0.001,0.001,0)
	bullet.Num			= 1
	bullet.Damage		= self.Damage
	bullet.Force		= 5
	bullet.Tracer		= 1	
	bullet.TracerName	= "HelicopterTracer"
	
	self.Entity:FireBullets(bullet);
	self.BulletsShot = self.BulletsShot + 1;
	self:EmitSound("weapons/smg1/smg1_fire1.wav", 500, 200)
end

function ENT:RemoveHeli()	
	self.Leave = true;
	self.speedScaler = 0;
	self:SetNotSolid(true)
end
