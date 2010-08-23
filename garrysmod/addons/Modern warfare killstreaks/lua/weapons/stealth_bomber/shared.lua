
if ( CLIENT ) then
	SWEP.PrintName			= "Stealth bomber"
end
SWEP.UseLaptop = true;
SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true
SWEP.Ent = "sent_stealth_bomber"

function SWEP:PlaySound()
	umsg.Start("playHarrierLaptopDeploySound", self.Owner);
	umsg.End()	
end