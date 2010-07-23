
if ( CLIENT ) then
	SWEP.PrintName			= "Predator Missile"
end

SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true

function SWEP:PlaySound()
	umsg.Start("playPredatorMissileDeploySound", self.Owner);
	umsg.End()
end

function SWEP:Run()		
	local pred = ents.Create("sent_predator_missile")
	pred:SetVar("owner",self.Owner)	
	pred:Spawn()
	pred:Activate()
end