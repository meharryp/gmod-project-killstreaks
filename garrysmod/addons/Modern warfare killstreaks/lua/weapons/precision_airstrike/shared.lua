
if ( CLIENT ) then
	SWEP.PrintName			= "Precision Airstrike"
end
SWEP.UseLaptop = true;
SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true
SWEP.Ent = "sent_precision_airstrike"

function SWEP:PlaySound()
	umsg.Start("playHarrierLaptopDeploySound", self.Owner);
	umsg.End()
end