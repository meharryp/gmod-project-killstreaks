include( 'shared.lua' )

ENT.SpawnEffectsOnce = false;
ENT.Smoke = nil;
function ENT:Initialize()	
	self.Owner = self:GetVar("owner")	
	
	self:SetModel( "models/Items/grenadeAmmo.mdl" );
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end		
	self.Smoke = ents.Create("info_particle_system");
	
end

function ENT:PhysicsCollide( data, physobj )
	if !self.SpawnEffectsOnce then		
		self.SpawnEffectsOnce = true;
		self.Smoke:SetKeyValue("effect_name", "Smoke") -- The names are cluster_explode, 40mm_explode, and agm_explode.
		self.Smoke:SetKeyValue("start_active", "1")
		self.Smoke:SetPos(self:GetPos())
		self.Smoke:Spawn()
		self.Smoke:Activate()
		self.Smoke:Fire("kill", "", 12) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
		timer.Simple(2, self.StartDrop, self);
		timer.Simple(12, self.Remove, self);
	end
	if self.Smoke != NULL && self.Smoke != nil then
		self.Smoke:SetPos(self:GetPos())
	end
end

function ENT:StartDrop()
	self.DropType = self:GetVar("DropType","sent_CarePackage")
	local ent;
	if self.DropType == "Sentry_Gun" then
		ent = ents.Create("sent_CarePackage")
		ent:SetVar("IsSentry", true)
	else
		ent = ents.Create(self.DropType)
	end
			
		ent:SetVar("owner",self.Owner)
		ent:SetVar("PackageDropZone", self:GetPos())
		ent:Spawn()
		ent:Activate()
end