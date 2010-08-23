
if ( CLIENT ) then
	SWEP.PrintName			= "Predator Missile"
end
SWEP.UseLaptop = true;
SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true
SWEP.Ent = "sent_predator_missile"

function SWEP:PlaySound()
	umsg.Start("playPredatorMissileDeploySound", self.Owner);
	umsg.End()
end
