
if ( CLIENT ) then
	SWEP.PrintName			= "Stealth bomber test"
end
SWEP.UseLaptop = true;
SWEP.Base 				= "mw2_killstreak_wep_base"
SWEP.AdminSpawnable		= false
SWEP.Ent = "sent_stealth_bomber_test"
SWEP.DelaySound = true;

function SWEP:PlaySound()
	umsg.Start("playWeaponInboundSound", self.Owner);
		umsg.String("precision_airstrike")
	umsg.End()
end