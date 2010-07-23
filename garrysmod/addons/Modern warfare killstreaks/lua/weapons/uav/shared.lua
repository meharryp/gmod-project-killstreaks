
if ( CLIENT ) then
	SWEP.PrintName			= "UAV"
end

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base 				= "mw2_killstreak_base"
SWEP.AdminSpawnable		= true

function SWEP:Run()
	if ( CLIENT ) then
		playUAVDeploySound();
	end 
	umsg.Start("uavStart", ply);
	umsg.End();
end
