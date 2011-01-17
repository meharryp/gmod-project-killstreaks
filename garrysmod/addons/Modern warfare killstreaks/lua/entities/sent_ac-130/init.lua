AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

ENT.camera = NULL;
ENT.sky = 0;
ENT.ang = NULL;
ENT.cameraAng = Angle(0,0,0)
ENT.weapon = 0;
ENT.DelayTime105mm = CurTime();
ENT.DelayTime40mm = CurTime();
ENT.DelayTime25mm = CurTime();
ENT.CoolDownTime25mm = CurTime();
ENT.SwitchDelay = CurTime();
ENT.Max40mmShotDelay = CurTime();
ENT.TurnDelay = CurTime();
ENT.Max40mm = 0;
ENT.missile = NULL;
ENT.AC130Life = CurTime();
ENT.AC130Time = 40;
ENT.OneSecond = CurTime();
ENT.Flares = 2;
ENT.OwnerPos = NULL;
ENT.BulletsShot = 0;
ENT.StayAlive = true;
ENT.rotateAroundPlayer = true;
ENT.playerPos = NULL;
ENT.disFromPl = 3000;
ENT.PlayerAng = NULL;
//local DisFromPlayer = CreateConVar ("AC130DisFromPl", "3000")
//local DelayForTurn = CreateConVar ("AC130TurnDelay", ".2")
//local AngleInc = CreateConVar ("AC130AngInc", "1")
local sound105mm = Sound("killstreak_rewards/ac-130_105mm_fire.wav");
local sound40mm = Sound("killstreak_rewards/ac-130_40mm_fire.wav");
local sound25mm = Sound("killstreak_rewards/ac-130_25mm_fire.wav");


function ENT:PhysicsUpdate()
	if self.StayAlive then
		self:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.sky));
		self.PhysObj:SetVelocity(self.Entity:GetForward() * 300)	
		self:SetAngles(self.ang)
		self.camera:SetPos( self:GetPos() + (self:GetRight() * -97) + (self:GetUp() * 97) + (self:GetForward() * -242) )
		self.camera:SetAngles(self.Owner:GetAimVector():Angle() + Angle(40, 0, 0) - self.cameraAng )		
		//MsgN("Angle = " .. tostring(self.Owner:GetAimVector():Angle()));
		self.Entity.Seat:SetPos(self.OwnerPos)  
		self.Entity.Seat:SetAngles(self.ang)
		self.HUDXPos = self:GetPos().x
		self.HUDYPos = self:GetPos().y
		self.HUDAGL = self:GetPos().z
		self.Owner:SetNetworkedInt("Ac_130_HUDXPos",self.HUDXPos)
		self.Owner:SetNetworkedInt("Ac_130_HUDYPos",self.HUDYPos)
		self.Owner:SetNetworkedInt("Ac_130_HUDAGL",self.HUDAGL)
		self:UpdateReloadingStates()
		if self.rotateAroundPlayer then
			local dis = Vector(self:GetPos().x, self:GetPos().y, 0):Distance( Vector( self.playerPos.x, self.playerPos.y, 0) );
			if self.disFromPl < dis && self.TurnDelay < CurTime() then
				//local an = AngleInc:GetFloat();
				//local de = DelayForTurn:GetFloat();				
				self.ang = self.ang + Angle(0, .1, 0)
				self.TurnDelay = CurTime() + .02;
			end
		end
		local Trace = util.QuickTrace( self:GetPos(), self:GetForward() * 3000,  self )
	
		if Trace.HitSky then
			self.ang = self.ang + Angle(0, .3, 0)
		end
		if self.Owner:KeyDown( IN_ATTACK ) then
			if self.weapon == 0 && self.DelayTime105mm <= CurTime() then
				self:FireMissile(self.camera:GetForward(), "105mm")
				self.DelayTime105mm = CurTime() + 5;
				self.Is105mmReloading = true
				timer.Create("TimerStop105mmRel",5,1,function() self:StopReloadingForHUD("105mm") end)
			elseif self.weapon == 1 && self.DelayTime40mm <= CurTime() && self.Max40mmShotDelay <= CurTime() then
				self:FireMissile(self.camera:GetForward(), "40mm")
				self.Max40mm = self.Max40mm + 1;
				if self.Max40mm >= 4  then
					self.Max40mm = 0;
					self.Is40mmReloading = true
					self.Max40mmShotDelay = CurTime() + 5
					timer.Create("TimerStop40mmRel",5,1,function() self:StopReloadingForHUD("40mm") end)
				end
				self.DelayTime40mm = CurTime() + .28;
			elseif self.weapon == 2 && self.DelayTime25mm <= CurTime() && self.CoolDownTime25mm <= CurTime() then
				self:Shoot25mm()
				self.DelayTime25mm = CurTime() + .1
				if self.BulletsShot >= 30 then
					self.BulletsShot = 0;
					self.Is25mmReloading = true
					self.CoolDownTime25mm = CurTime() + 5;
					timer.Create("TimerStop25mmRel",5,1,function() self:StopReloadingForHUD("25mm") end)
				end
			end
		elseif self.Owner:KeyDown( IN_ATTACK2 ) && self.SwitchDelay < CurTime() then
			
			self.BulletsShot = 0;
			self.Max40mm = 0;
			self.SwitchDelay = CurTime() + .25
			self.weapon = self.weapon + 1;
			if self.weapon > 2 then
				self.weapon = 0;
			end
			self.Owner:SetNetworkedInt("Ac_130_weapon",self.weapon)
		end
		
		if self.weapon == 0 then
			self.Owner:SetFOV(75,0);
		elseif self.weapon == 1  then
			self.Owner:SetFOV(25,0);
		elseif self.weapon == 2 then
			self.Owner:SetFOV(8,0);
		end
		
		if self.AC130Life <= CurTime() then
			self:RemoveAC130()
		end
		
		if self.OneSecond <= CurTime() then
			self.OneSecond = CurTime() + 1
			self.AC130Time = self.AC130Time - 1;
			self.Owner:SetNetworkedInt("Ac_130_Time",self.AC130Time)		
		end
		
		local orgin_ents = ents.FindInSphere( self:GetPos(), 1000 )
		
		if self.Flares > 0 then
			for k,v in pairs(orgin_ents) do
				if v:GetClass() == "rpg_missile" || v:GetClass() == "stinger_missile" then
					v:Remove();
					for i = 0 , 20 do 
						self:SpawnFlares()
					end				
					self.Flares = self.Flares - 1;
				end
			end		
		end
		
		if !self.Owner:InVehicle() then
			self.Owner:EnterVehicle(self.Entity.Seat);
		end
		
	else
		self:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.sky));
		self.PhysObj:SetVelocity(self.Entity:GetForward() * 1000)	
		self:SetAngles(self.ang)
	end
	
	if( !self:IsInWorld()) then
		//MsgN("Is not of this world")
		self:Remove()		
	end
end

function ENT:Think()
	if( self.PhysObj:IsAsleep() ) then
		self.PhysObj:Wake()
	end
 end

function ENT:Initialize()	
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	self.Wep = self:GetVar("Weapon")
	self.playerPos = self.Owner:GetPos();
	self.PlayerAng = self.Owner:GetAngles();
	
	self.sky = self:findGround()
	
	if self.sky == -1 then 
		self:Remove();
		return;
	end
	self.sky = self.sky + 6000;	
	if self.Owner:IsAdmin() && !SinglePlayer()  then
		self.AC130Life = CurTime() + 60		-- Admins get about 1.5 times the normal rate in the ac 130 then regular players.
		self.AC130Time = 60
	else	
		self.AC130Life = CurTime() + 40
		self.AC130Time = 40
	end	
	
	local lplPos = self.Owner:GetPos()
	local forw = self.Owner:GetForward();
	local distance = 2000
	local spawnPos = lplPos + ((-1 * forw) * distance)
	spawnPos = Vector( spawnPos.x, spawnPos.y, self.sky )
	if !util.IsInWorld(spawnPos) then	
		spawnPos = lplPos + Vector(0,0,self.sky)
	end

	if !util.IsInWorld(spawnPos) then
		MsgN("Pos = " .. tostring(spawnPos));
		self:Remove();
		MsgN("The AC-130 was not of this world, and so had to be sent off to kill other bad guys who are of it's world")
		umsg.Start("AC_130_Error", self.Owner);
		umsg.End();
		if IsValid(self.Wep) then
			self.Wep:CallIn();
		end
		return;
	end
	
	self.Entity:SetModel( "models/military2/air/air_130_l.mdl" );
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.Entity:SetPos(spawnPos)
	
	local vec3 = lplPos - spawnPos
	local ang = vec3:Angle()
	
	self.Entity:SetAngles(Angle(0,self.Owner:GetAngles().y - 90,0))
	
	self.ang = self:GetAngles();
	
	self.camera = ents.Create("prop_physics")
	self.camera:SetModel("models/dav0r/camera.mdl")
	self.camera:SetPos( self:GetPos() + (self:GetRight() * -97) + (self:GetUp() * 97) + (self:GetForward() * -242) )
	self.camera:SetAngles( Angle(0,90,0))
	self.camera:SetColor(255,255,255,0)
	self.camera:Spawn();
	self.camera:GetPhysicsObject():EnableGravity(false)
	self.camera:SetNotSolid(true)
	
	constraint.NoCollide( self, self.camera, 0, 0 );
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
		
	self.OwnerPos = self.Owner:GetPos()
	self.Entity.Seat = ents.Create("prop_vehicle_prisoner_pod")  
	self.Entity.Seat:SetKeyValue("vehiclescript","scripts/vehicles/JetSeat.txt")  
	self.Entity.Seat:SetModel( "models/nova/airboat_seat.mdl" ) 
	self.Entity.Seat:SetPos(self.OwnerPos )  
	self.Entity.Seat:SetAngles(self.ang)
	self.Entity.Seat:SetColor(255,255,255,0)
	self.Entity.Seat:Spawn()
		
	self.Owner:EnterVehicle(self.Entity.Seat);
	self.Owner:SetViewEntity(self.camera);
	
	self.Owner:SetNetworkedInt("Ac_130_weapon",0)
	
	self.OneSecond = CurTime();
	self.Owner:SetNetworkedInt("Ac_130_Time",self.AC130Time)
	
	umsg.Start("AC_130_SetUpHUD", self.Owner);
	umsg.End()	
	--[[
	umsg.Start("playAC130DeploySound", self.Owner);
	umsg.End()
	]]
end

function ENT:FireMissile(target, weaponType)
	missileSound = NULL;
	if weaponType == "105mm" then
		self.missile = ents.Create("sent_105mm")  
		missileSound = sound105mm;
	elseif weaponType == "40mm" then
		self.missile = ents.Create("sent_40mm")
		missileSound = sound40mm;
	elseif weaponType == "25mm" then
		self.missile = ents.Create("sent_25mm")  	
	end
	self.missile:SetPos(self:GetPos())  
	self.missile:SetAngles(target:Angle())
	self.missile:SetVar("owner",self.Owner)	
	self.missile:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	self.missile:Spawn()
	self:EmitSound(missileSound)
	constraint.NoCollide( self, self.missile, 0, 0 );
end

function ENT:Shoot25mm()

	local HERounds = function(attacker, tr, dmginfo)

		local imp = EffectData()
		imp:SetOrigin(tr.HitPos)
		imp:SetNormal(tr.HitNormal)
		imp:SetScale(8)
		imp:SetRadius(8)
		imp:SetMagnitude(8)
		util.Effect("AR2Explosion",imp)

		util.BlastDamage(dmginfo:GetInflictor(),attacker,tr.HitPos,25,12)

		return true
	end
	bullet = {}
		
	bullet.Src		= self.camera:GetPos();
	bullet.Attacker = self.Owner;
	bullet.Dir		= self.camera:GetForward();
			
	bullet.Spread		= Vector(0.0001,0.0001,0)
	bullet.Num			= 1
	bullet.Damage		= 35
	bullet.Force		= 5
	bullet.Tracer		= 1	
	bullet.TracerName	= "HelicopterTracer"
	bullet.Callback		= HERounds
	
	self.Entity:FireBullets(bullet);
	self:EmitSound(sound25mm);
	self.BulletsShot = self.BulletsShot + 1;
end

function ENT:SpawnFlares()
	local flares = ents.Create( "sent_flares" )	
	flares:SetPos(self:GetPos() )		
	flares:Spawn()
	flares:Activate()
	constraint.NoCollide( self, flares, 0, 0 )			
end

function ENT:OnTakeDamage(dmg)
	if( dmg:IsExplosionDamage() && self.Flares <= 0 ) then
		self:Destroy()
	end
end

function ENT:StopReloadingForHUD(weaponType)
	if weaponType == "105mm" then	
		self.Is105mmReloading = false
	elseif weaponType == "40mm" then	
		self.Is40mmReloading = false
	elseif weaponType == "25mm" then	
		self.Is25mmReloading = false
	end
end

function ENT:Destroy()
	--spawn effect for explosion here.
	self:RemoveAC130();
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:RemoveAC130()
	if timer.IsTimer ("TimerStop105mmRel") then
		timer.Destroy("TimerStop105mmRel")
	end
	if timer.IsTimer ("TimerStop40mmRel") then
		timer.Destroy("TimerStop40mmRel")
	end
	if timer.IsTimer ("TimerStop25mmRel") then
		timer.Destroy("TimerStop25mmRel")
	end
	self.Is105mmReloading = false
	self.Is40mmReloading = false
	self.Is25mmReloading = false
	self:UpdateReloadingStates()
	umsg.Start("AC_130_RemoveHUD", self.Owner);
	umsg.End()
	self.Owner:SetViewEntity(self.Owner)
	self.Owner:ExitVehicle()
	self.Owner:SetFOV(75,0);	
	self.camera:Remove();
	self.Entity.Seat:Remove()
	self.StayAlive = false;
	constraint.NoCollide( self, GetWorldEntity(), 0, 0 );	
	self.Owner:GetActiveWeapon().MouseSensitivity = 1;
	if IsValid(self.Wep) then
		self.Wep:CallIn();
	end
	self.Owner:SetAngles(self.PlayerAng);
end

function ENT:UpdateReloadingStates()
	self.Owner:SetNetworkedBool("Ac_130_105mmReloading",self.Is105mmReloading)
	self.Owner:SetNetworkedBool("Ac_130_40mmReloading",self.Is40mmReloading)
	self.Owner:SetNetworkedBool("Ac_130_25mmReloading",self.Is25mmReloading)
end

function ENT:findGround()

	local minheight = -16384
	local startPos = self.Owner:GetPos()
	local endPos = Vector(startPos.x, startPos.y,minheight);
	local filterList = {self.Owner, self}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local groundLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitWorld then
			groundLocation = traceData.HitPos.z;			
			bool = false;
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the ground");
			bool = false;
		end		
	end
	
	return groundLocation;
end
