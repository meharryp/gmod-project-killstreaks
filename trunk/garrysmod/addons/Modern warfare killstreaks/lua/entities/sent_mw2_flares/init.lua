
include('shared.lua')

ENT.ParentOnce = 0
ENT.RemoveDel = CurTime()
ENT.FlareSprite = NULL
ENT.smoke = NULL

function ENT:Initialize()

	self:SetModel("models/dav0r/hoverball.mdl")
	self:SetOwner(self.Owner)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(0,0,0,0)

    local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	
	phys:SetMass( 10 )
	
	self.RemoveDel = CurTime() + 5
	
	util.SpriteTrail( self, 0, Color(255,255,255,150), false, 10, 0, 0.4, 1/(3)*0.5, "trails/smoke.vmt" )

end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide( data, phys ) 
	--ent = data.HitEntity
	self.Entity:Remove()
end

-------------------------------------------THINK
function ENT:Think()
		
	if self.ParentOnce == 0 then
		self.ParentOnce = 1
	
		local size = math.random( 1, 10 )
			  size = size / 10
	
		self.FlareSprite = ents.Create("env_sprite");
		self.FlareSprite:SetPos( self.Entity:GetPos() );
		self.FlareSprite:SetKeyValue( "renderfx", "14" )
		self.FlareSprite:SetKeyValue( "model", "sprites/glow1.vmt")
		self.FlareSprite:SetKeyValue( "scale",size)
		self.FlareSprite:SetKeyValue( "spawnflags","1")
		self.FlareSprite:SetKeyValue( "angles","0 0 0")
		self.FlareSprite:SetKeyValue( "rendermode","9")
		self.FlareSprite:SetKeyValue( "renderamt","255")
		self.FlareSprite:SetKeyValue( "rendercolor", "255 0 0" )				
		self.FlareSprite:Spawn()			
		self.FlareSprite:SetParent(self.Entity)
		
		self.smoke = ents.Create("env_smokestack")
		self.smoke:SetPos(self.Entity:GetPos())
		self.smoke:SetKeyValue("WindAngle", "0 0 0")
		self.smoke:SetKeyValue("WindSpeed", "0")
		self.smoke:SetKeyValue("rendercolor", "100 100 100")
		self.smoke:SetKeyValue("renderamt", "255")
		self.smoke:SetKeyValue("SmokeMaterial", "particle/particle_smokegrenade.vmt")
		self.smoke:SetKeyValue("BaseSpread", "9")
		self.smoke:SetKeyValue("SpreadSpeed", "13")
		self.smoke:SetKeyValue("Speed", "50")
		self.smoke:SetKeyValue("StartSize", "52")
		self.smoke:SetKeyValue("EndSize", "52")
		self.smoke:SetKeyValue("roll", "50")
		self.smoke:SetKeyValue("Rate", "32")
		self.smoke:SetKeyValue("JetLength", "150")
		self.smoke:SetKeyValue("twist", "2")	
		self.smoke:Spawn()
		self.smoke:Activate()
		self.smoke:SetParent(self.Entity)
		self.smoke:Fire("TurnOn", "", 0)		
	end
	
	if self.RemoveDel < CurTime() then
		self.Entity:Remove()
	end	
	
end

function ENT:OnRemove()
	if IsValid(self.FlareSprite) then self.FlareSprite:Remove() end
	if IsValid(self.smoke) then self.smoke:Remove() end
end
