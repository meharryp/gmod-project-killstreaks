include( 'shared.lua' )

ENT.SearchSize = 5000;
ENT.Model = "models/COD4/Cobra/cobra.mdl"
ENT.SpawnHeight = 2000;
ENT.MaxHeight = 1500;
ENT.Damage = 0;
ENT.BarrelAttachment = "Gun_barrel"
ENT.LifeDuration = 120;
ENT.SectorHoldDuration = 4;
ENT.MaxSpeed = 1800;
ENT.MinSpeed = 1000;

ENT.Barrels = {};
//util.Effect( "propspawn", ed, true, true )

function ENT:Helicopter_Init()	
	self.PhysObj:EnableGravity(false)
	
	self.Barrels = {}
	for i, v in pairs(self.Sectors) do
		self:SpawnBarrel( v )
	end
end

function ENT:SpawnBarrel(pos)
	
	local x = pos.MidPoint.x
	local y = pos.MidPoint.y
	
	local barrel = ents.Create("prop_physics");
	barrel:SetModel("models/props_borealis/bluebarrel001.mdl")
	barrel:SetPos( Vector( x, y, self.CurHeight ) )	
	barrel:Spawn();
	barrel:GetPhysicsObject():EnableGravity(false)
	barrel:SetNotSolid(true)
	table.insert(self.Barrels, barrel )
	pos.MidPoint.Prop = barrel;
end

function ENT:OnRemove()
	for i, v in pairs(self.Barrels) do
		v:Remove();
	end	
end