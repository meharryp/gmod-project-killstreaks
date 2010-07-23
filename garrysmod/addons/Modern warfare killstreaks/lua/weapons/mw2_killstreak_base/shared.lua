
local ModelExsists			= file.Exists("../models/weapons/v_slam.mdl")
if ( CLIENT ) then
	SWEP.Author				= "Death dealer142"
	SWEP.Purpose			= ""
	SWEP.Instructions		= ""
	SWEP.Category			= "MW2 Killstreaks"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5		
end

if ModelExsists then
	SWEP.ViewModelFlip		= true
	SWEP.ViewModel			= "models/weapons/v_slam.mdl"
	SWEP.WorldModel			= "models/weapons/w_slam.mdl"
end

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.DrawAmmo			= false

SWEP.AutoSwitchTo		= true;

SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay 		= 0

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"

SWEP.CallOnce = true;

SWEP.CalledIn = false;

local drawTime = 0;
local drawBool = true;
local detonateTime = 0;
local detonateBool = false;
local holsterTime = 0;
local holsterBool = false;
local drawSequence;
local detonateSequence;
local holsterSequence;

function SWEP:Equip(NewOwner)
	NewOwner:SelectWeapon(self:GetClass())	
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Cause the weapon that starts the killstreak to go through its animations
---------------------------------------------------------*/
function SWEP:Deploy()	
	local canUsePred = self.Owner:GetNetworkedString("UsedKillStreak")
	if !self.Owner:IsAdmin() && canUsePred != self:GetClass() then
		self.Owner:StripWeapon(self:GetClass());
		return;
	end
	self.Owner:SetNetworkedString("UsedKillStreak", "")
	
	if ModelExsists then
		drawTime = 0;
		drawBool = true;
		detonateTime = 0;
		detonateBool = false;
		holsterTime = 0;
		holsterBool = false;

		drawSequence = self:LookupSequence("detonator_draw")
		detonateSequence = self:LookupSequence("detonator_detonate")
		holsterSequence = self:LookupSequence("detonator_holster")

		self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
		drawTime = self:SequenceDuration() + CurTime();
		self:PlaySound();
	else
		if self.CallOnce then
			timer.Simple(1, self, self.Run);
			self.CalledIn = true;
			self:Holster();
			self.CallOnce = false;			
		end
	end
	return true;
end

function SWEP:Think()
	if ModelExsists then
		if self:GetSequence() == drawSequence && CurTime() > drawTime && drawBool then
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
			detonateTime = self:SequenceDuration( ) + CurTime();
			drawBool = false;
			detonateBool = true;			
			self:Run();
			self.CalledIn = true;
		elseif self:GetSequence() == detonateSequence && CurTime() > detonateTime && detonateBool then
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_HOLSTER)
			holsterTime = self:SequenceDuration( ) + CurTime();
			detonateBool = false;
			holsterBool = true;		
		elseif self:GetSequence() == holsterSequence && CurTime() > holsterTime && holsterBool then			
			self:Holster();			
		end
	end
end

function SWEP:Holster()
	if self.CalledIn && self != nil && self.Owner:HasWeapon(self:GetClass()) then
		self.Owner:StripWeapon(self:GetClass());
	end
end

function SWEP:Run()
end

function SWEP:PlaySound()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end