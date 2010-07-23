
if ( CLIENT ) then	
	SWEP.PrintName			= "Harrier strike"
end

SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true

function SWEP:PlaySound()
	umsg.Start("playHarrierLaptopDeploySound", self.Owner);
	umsg.End()
end

function SWEP:Run()		
	local harrier = ents.Create("sent_harrier_system")
	harrier:SetVar("owner",self.Owner)
	harrier:SetAngles(Vector(90,0,0))
	harrier:Spawn()

	harrier:Activate()
end
