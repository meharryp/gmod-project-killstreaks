
if ( CLIENT ) then	
	SWEP.PrintName			= "Harrier strike"
end
SWEP.UseLaptop = true;
SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true
SWEP.Ent = "sent_harrier_system";

function SWEP:PlaySound()
	umsg.Start("playHarrierLaptopDeploySound", self.Owner);
	umsg.End()
end