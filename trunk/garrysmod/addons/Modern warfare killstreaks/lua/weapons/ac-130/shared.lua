
if ( CLIENT ) then
	SWEP.PrintName			= "AC-130"
end

SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true

function SWEP:Run()
	local ac = ents.Create("sent_ac-130")
	ac:SetVar("owner",self.Owner)	
	ac:Spawn()
	ac:Activate()
end
