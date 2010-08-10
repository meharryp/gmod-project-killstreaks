
if ( CLIENT ) then
	SWEP.Author				= "Death dealer142"
	SWEP.PrintName			= "Care Package"
	SWEP.Purpose			= ""
	SWEP.Instructions		= ""
	SWEP.Category			= "MW2 Killstreaks"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5		
end


//SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.Spawnable			= true
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

SWEP.PulledBack = false;
SWEP.Used = false;


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
	return true;
end

function SWEP:Think()

	if self.PulledBack then					
		if self.Owner:KeyReleased(IN_ATTACK) then
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			self.PulledBack = false
			local ent = ents.Create("sent_SupplyDrop_Grenade")
			ent:SetVar("owner",self.Owner)
			ent:SetVar("DropType","sent_CarePackage")
			ent:SetPos(self.Owner:GetShootPos())
			ent:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
			ent:SetOwner(self.Weapon:GetOwner())
			ent:Spawn()
			ent:Activate()
			ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * 750)
			self.Used = true;
			self:Holster()
		end
	end
end

function SWEP:Holster()
	if self != nil && self.Used && self.Owner:HasWeapon(self:GetClass()) then
		self.Owner:StripWeapon(self:GetClass());
	end
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
	self.PulledBack = true;
end

function SWEP:SecondaryAttack()
end