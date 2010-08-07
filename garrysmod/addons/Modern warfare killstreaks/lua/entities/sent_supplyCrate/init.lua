require("datastream")

AddCSLuaFile( "cl_init.lua" )
include( 'shared.lua' )
IncludeClientFile("cl_init.lua")

local MW2Killstreaks = { "ammo", "uav", "predator_missile", "precision_airstrike", "harrier", "stealth_bomber", "ac-130" };

ENT.Players = {}
ENT.GiveReward = false;
ENT.Reward = nil;
ENT.Winner = nil;
ENT.Model = Model("models/deathdealer142/supply_crate/supply_crate.mdl");

function ENT:Initialize()	
	self.Owner = self:GetVar("owner")	
	
	self:SetModel( self.Model );
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )	
	
	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )
	
	self.Reward = self:PickReward()
	self:SetNetworkedString("SupplyCrate_Reward", self.Reward) -- Have to use a network variable because the reward needs to be accessed from client side.
	self:SetSkin( self.Owner:GetNetworkedString("MW2TeamSound") - 1 )
end

function ENT:PickReward()
	local num = math.random(1, 100)
	local str = "";
	local crateType = self:GetVar("CrateType", "sent_CarePackage")
	if crateType == "sent_CarePackage" then
		if num <= 15 then --15 - Ammo
			str = MW2Killstreaks[1]
		elseif num > 15 && num <= 30 then --15 - UAV
			str = MW2Killstreaks[2]
		elseif num > 30 && num <= 43 then --13 - Counter-UAV
			str = MW2Killstreaks[1]
		elseif num > 43 && num <= 53 then --10 - Sentry Gun
			str = MW2Killstreaks[1]
		elseif num > 53 && num <= 63 then --10 - Predator Missile
			str = MW2Killstreaks[3]
		elseif num > 63 && num <= 73 then --10 - Precision Airstrike
			str = MW2Killstreaks[4]
		elseif num > 73 && num <= 79 then --6 - Harrier Strike
			str = MW2Killstreaks[5]
		elseif num > 79 && num <= 85 then --6 - Attack Helicopter
			str = MW2Killstreaks[1]
		elseif num > 85 && num <= 89 then --4 - Pave Low
			str = MW2Killstreaks[1]
		elseif num > 89 && num <= 93 then --4 - Stealth Bomber
			str = MW2Killstreaks[6]
		elseif num > 93 && num <= 96 then --3 - Chopper Gunner
			str = MW2Killstreaks[1]
		elseif num > 96 && num <= 99 then --3 - AC-130
			str = MW2Killstreaks[7]
		elseif num > 99 then --1 - EMP 
			str = MW2Killstreaks[1]
		end
	else
		if num <= 12 then --12 - Ammo
			str = MW2Killstreaks[1]
		elseif num > 12 && num <= 24 then --12 - UAV
			str = MW2Killstreaks[2]
		elseif num > 24 && num <= 40 then --16 - Counter-UAV
			str = MW2Killstreaks[1]
		elseif num > 40 && num <= 56 then --16 - Sentry Gun
			str = MW2Killstreaks[1]
		elseif num > 56 && num <= 70 then --14 - Predator Missile
			str = MW2Killstreaks[3]
		elseif num > 70 && num <= 80 then --10 - Precision Airstrike
			str = MW2Killstreaks[4]
		elseif num > 80 && num <= 85 then --5 - Harrier Strike
			str = MW2Killstreaks[5]
		elseif num > 85 && num <= 90 then --5 - Attack Helicopter
			str = MW2Killstreaks[1]
		elseif num > 90 && num <= 93 then --3 - Pave Low
			str = MW2Killstreaks[1]
		elseif num > 93 && num <= 96 then --3 - Stealth Bomber
			str = MW2Killstreaks[6]
		elseif num > 96 && num <= 98 then --2 - Chopper Gunner
			str = MW2Killstreaks[1]
		elseif num > 98 && num <= 100 then --2 - AC-130
			str = MW2Killstreaks[7]
		end
	end
	return str;	
end

function ENT:Think()
	if self.GiveReward then
		addKillStreak(self.Winner, self.Reward)
		for k,v in pairs(self.Players) do 
			v:SetNetworkedBool("SupplyCrate_DrawBarBool", false)
			v.UseBool = false;
			table.remove(self.Players,k);
		end
		self:Remove()
		return;
	end
	for k,v in pairs(self.Players) do 
		if( v:KeyReleased( IN_USE ) && v.UseBool ) then		
			v:SetNetworkedBool("SupplyCrate_DrawBarBool", false)
			v.UseBool = false;
			table.remove(self.Players,k);
		end
	end
	self:NextThink( CurTime() + .001 )
    return true //-- Note: You need to return true to override the default next think time
end

function ENT:Use(pl, caller)	
	if !pl.UseBool || pl.UseBool == nil then
		table.insert(self.Players,pl);
		pl:SetNetworkedBool("SupplyCrate_DrawBarBool", true)	
		pl.SupplyCrate = self;
		pl.UseBool = true
		if pl == self.Owner then
			pl:SetNetworkedFloat("SupplyCrate_Inc", 4)
		elseif pl:Team() == self.Owner:Team() then
			pl:SetNetworkedFloat("SupplyCrate_Inc", 2)
		else
			pl:SetNetworkedFloat("SupplyCrate_Inc", 1)
		end		
		umsg.Start("SupplyCrate_DrawBar", pl);
		umsg.End()	
	end
end

function giveReward( pl, handler, id, encoded, decoded )
	pl.SupplyCrate.GiveReward = true -- The Supply Crate	
	pl.SupplyCrate.Winner = pl;
end

datastream.Hook( "SupplyCrate_GiveReward", giveReward )
