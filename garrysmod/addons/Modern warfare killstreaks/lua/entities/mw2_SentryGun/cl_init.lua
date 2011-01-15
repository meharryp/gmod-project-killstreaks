include('shared.lua')

local lpl = nil;
local fullWidth = 175
local width = 0
local height = 10
local x = ScrW()/2 - fullWidth/2
local y = ScrH()/2 - height/2
local offset = 4
--local DisFromCrate = CreateConVar ("Supply_CrateDistance", "75")
local setHook = false

local Laser = Material( "cable/redlaser" )

function ENT:Draw()
	
	self.Entity:DrawModel()	
	
	if lpl == nil then		
		return;
	end
	if lpl:GetVar("ShowSentryLaser", false) then
		local barrel = self:GetAttachment(self:LookupAttachment(self.BarrelAttachment))	
		local sPos = barrel.Pos
		local sAng = barrel.Ang
		MsgN(self:GetPoseParameter("aim_pitch"))
		local ang = Angle( self:GetPoseParameter("aim_pitch"), barrel.Ang.y, 0):Forward()
		
		local tracePos = util.QuickTrace( sPos, ang * self.Dis, self )
		local hit = tracePos.HitPos
		
		render.SetMaterial( Laser )
		render.DrawBeam( sPos, hit, 5, 0, 0, Color( 255, 255, 255, 255 ) ) 
	end
	local team = lpl:GetNetworkedString("MW2TeamSound");
	local str;
	if team == "1" then
		str = "militia";
	elseif team == "2" then
		str = "seals";
	elseif team == "3" then
		str = "opfor";
	elseif team == "4" then
		str = "rangers";
	elseif team == "5" then
		str = "tf141";
	end
	
	local tex = surface.GetTextureID("models/deathdealer142/supply_crate/" .. str)
	
	local wlh = getEntityWidthLengthHeight(self)
	local eHeight = wlh.z
	local width = wlh.x
	entPos = self:GetPos() + Vector(0, 0, eHeight + 8)
	
	cam.Start3D2D( entPos, Angle(0, LocalPlayer():GetAngles().y - 90 , 90), 1 )
        surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255) // Makes sure the image draws with all colors
		surface.DrawTexturedRect(-8, -8, 16,16)
    cam.End3D2D()
	
end 

function getEntityWidthLengthHeight(ent) --The function returns a vector with width as the vector's x, length as the vector's y, and height as the vector's z.
    local min,max = ent:WorldSpaceAABB()
    local offset=max-min
    return offset
end
function SetOwner( data )
	lpl = data:ReadEntity();
end
usermessage.Hook("setMW2SentryGunOwner", SetOwner)