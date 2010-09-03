AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.FireOnce = true;

function ENT:Freeze()
	self.Entity:SetMoveType(MOVETYPE_NONE)
end

function ENT:Explode()

	local Ent = ents.Create("prop_combine_ball")
	Ent:SetPos(self.Entity:GetPos())
	Ent:Spawn()
	Ent:Activate()
	Ent:EmitSound("ambient/explosions/explode_3.wav")
	Ent:Fire("explode", "", 0)

	for i = 1, 8 do
		local bomblet = ents.Create("sent_bomblet")
		
		bomblet:SetPos(self.Entity:GetPos())
		bomblet:SetVar("owner",self.Owner);
		bomblet:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
		bomblet:Spawn()
				
		local Phys = bomblet:GetPhysicsObject()
		
		if Phys:IsValid() then
			Phys:Wake()
			Phys:ApplyForceCenter(Vector(math.random(5-40, 40), math.random(5-40, 40), math.random(5-40, 40)) * Phys:GetMass())
		end
	end
	
	self.Entity:Remove();
end

function ENT:Think()
	if self:GetVar("HasBeenDropped",false) && self.FireOnce then
		timer.Simple(1.5, self.Explode, self)
		self.FireOnce = false;
	end
end

function ENT:Initialize()
	self.Entity:SetModel( "models/military2/bomb/bomb_jdam.mdl" ); 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Owner = self.Entity:GetVar("owner",Entity(1))	
	
	self.FireOnce = true;
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
end