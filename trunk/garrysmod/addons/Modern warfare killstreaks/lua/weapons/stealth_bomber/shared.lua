
if ( CLIENT ) then
	SWEP.PrintName			= "Stealth bomber"
end

SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true

function SWEP:PlaySound()
	umsg.Start("playHarrierLaptopDeploySound", self.Owner);
	umsg.End()	
end

function SWEP:Run()	
	local stealth = ents.Create("sent_stealth_bomber")
	stealth:SetVar("owner",self.Owner)
	stealth:Spawn()
	stealth:Activate()		
end
