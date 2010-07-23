
if ( CLIENT ) then
	SWEP.PrintName			= "Tactical Nuke"
end

SWEP.Base 				= "mw2_killstreak_base"

function SWEP:Run()
	local Nuke = ents.Create("sent_tactical_nuke_system")
	Nuke:SetVar("owner",self.Owner)	
	Nuke:Spawn()
	Nuke:Activate()
end
