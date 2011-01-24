include( 'shared.lua' )

ENT.SearchSize = 1000;
ENT.Model = "models/dav0r/camera.mdl"
ENT.Barrel = "models/props_borealis/bluebarrel001.mdl"
ENT.Barrels = {};

function ENT:SpawnFunction( ply, tr )
    local ent = ents.Create( self.Classname )
    ent:Spawn()
    ent:Activate()
 
    return ent
end

function ENT:Helicopter_Init()	
	self.PhysObj:EnableGravity(false)
	self:SetPos( Vector( 0,0,0 ) )
	for i, v in pairs(self.Sectors) do
		self:SpawnBarrel( v )
	end
end

function ENT:SpawnBarrel(pos)
	
	local x = pos.MidPoint.x
	local y = pos.MidPoint.y
	
	local barrel = ents.Create("prop_physics");
	barrel:SetModel(self.Barrel)
	barrel:SetPos( Vector( x, y, 3353 ) )
	barrel:Spawn();
	barrel:GetPhysicsObject():EnableGravity(false)
	table.insert(self.Barrels, barrel )
end

function ENT:OnRemove()
	for i, v in pairs(self.Barrels) do
		v:Remove();
	end
end