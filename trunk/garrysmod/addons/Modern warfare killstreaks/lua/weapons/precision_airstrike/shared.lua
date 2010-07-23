
if ( CLIENT ) then
	SWEP.PrintName			= "Precision Airstrike"
end

SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true

function SWEP:PlaySound()
	umsg.Start("playHarrierLaptopDeploySound", self.Owner);
	umsg.End()
end

function SWEP:Run()	
	local air = ents.Create("sent_precision_airstrike")
	air:SetVar("owner",self.Owner)
	air:SetAngles(Vector(90,0,0))
	air:Spawn()

	air:Activate()			
end
