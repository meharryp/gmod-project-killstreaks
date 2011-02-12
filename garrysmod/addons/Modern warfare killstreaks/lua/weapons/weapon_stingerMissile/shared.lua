if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "shotgun"	
end

if ( CLIENT ) then

	SWEP.PrintName			= "Stinger"
	SWEP.Author				= "Death dealer142"

	SWEP.Slot				= 4
	SWEP.SlotPos			= 7
	//SWEP.IconLetter			= "x"

end
------------General Swep Info---------------
SWEP.Author   = "Death dealer142"
SWEP.Contact        = ""
SWEP.Purpose        = "Destroy stuff"
SWEP.Instructions   = "Hold secondary fire until lock, then fire"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
-----------------------------------------------

------------Models---------------------------
SWEP.ViewModel      = "models/weapons/v_rpg.mdl"
SWEP.WorldModel   = "models/weapons/w_rocket_launcher.mdl"
-----------------------------------------------

-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.Delay			= 0.9 	--In seconds
SWEP.Primary.Recoil			= 0		--Gun Kick
SWEP.Primary.Damage			= 15	--Damage per Bullet
SWEP.Primary.NumShots		= 1		--Number of shots per one fire
SWEP.Primary.Cone			= 0 	--Bullet Spread
SWEP.Primary.ClipSize		= 1	--Use "-1 if there are no clips"
SWEP.Primary.DefaultClip	= 2	--Number of shots in next clip
SWEP.Primary.Automatic   	= false	--Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= "rpg_round"	--Ammo Type
-------------End Primary Fire Attributes------------------------------------

-------------Secondary Fire Attributes-------------------------------------
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"
-------------End Secondary Fire Attributes--------------------------------

SWEP.Target = SWEP.Target or NULL;
SWEP.Missile = SWEP.Missile or NULL;
SWEP.TempTarget = NULL;
SWEP.LockTime = CurTime();
SWEP.LockCount = 0;
SWEP.DidExplosion = false
SWEP.CanFireMissile = true;
SWEP.LastTarget = NULL;

function SWEP:Initialize()
	self.Owner:SetNetworkedBool("TargetLock", false)
end

function SWEP:Think()
	if !( SERVER ) then	return end
	
	if self.Owner:KeyDown(IN_ATTACK2) && self.Missile == NULL && self.Target == NULL then	
		local trace = self.Owner:GetEyeTrace()		
		if self.Target == NULL && trace.Hit && trace.Entity:IsValid() && !trace.Entity:IsPlayer() then
			if self.LockTime < CurTime() then
				self.LockTime = CurTime() + 1
				self.LockCount = self.LockCount + 1			
				self.Owner:ChatPrint("Lock " .. self.LockCount)
				if self.LockCount >= 2 then
					self.Target = trace.Entity;
					self.Owner:SetNetworkedBool("TargetLock", true)
					self.Owner:ChatPrint("Ready to fire")
				end
			end
		else
			self.LockCount = 0;
		end
	elseif self.Owner:KeyDown(IN_ATTACK) && IsValid(self.Target) then
		self:FireMissile()
		self:TakePrimaryAmmo(1)		
	end
	
	if( self.Owner:KeyReleased( IN_ATTACK2  ) ) then
		self.LockCount = 0;
	end
end

function SWEP:DrawHUD()	
	if !self.Owner:GetNetworkedBool("TargetLock") then 
		trace = self.Owner:GetEyeTrace()
		if trace.Hit && !trace.Entity:IsNPC() && !trace.Entity:IsPlayer() && trace.Entity:IsValid() then
			self.TempTarget = trace.Entity;
			self.TempTarget:SetColor(255, 0, 0, 255);
		elseif (self.TempTarget != NULL && self.TempTarget:IsValid() && !trace.Entity:IsValid()) && trace.Entity != self.TempTarget then
			self.TempTarget:SetColor(255, 255, 255, 255);
			self.TempTarget = NULL;
		end
	
	end
	if self.Owner:GetNetworkedBool("TargetLock") then 
		if self.Target:IsValid() then
			self.TempTarget:SetColor(255, 255, 255, 255);
			self.TempTarget = NULL;
			self.Target:SetColor(0, 255, 0, 255);
		end
	end
	
	if self.LastTarget != NULL && self.LastTarget:IsValid() then
		self.LastTarget:SetColor(255, 255, 255, 255);
	end	
end

function SWEP:FireMissile()
	self.Missile = ents.Create("stinger_missile");
	self.Missile:SetPos(self.Owner:GetShootPos() + self.Owner:GetUp() * 15)
	self.Missile:SetOwner(self.Owner)
	self.Missile:SetVar("target",self.Target);
	
	self.Missile:Spawn();
	self.Missile:Activate();
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	self.LastTarget = self.Target;
	self.Target = NULL;
	self.Owner:SetNetworkedBool("TargetLock", false)
end

function SWEP:Holster()
	self.TargetLock = false;
	self.TempTarget = NULL;
	self.LockCount = 0;
	return true;
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
end