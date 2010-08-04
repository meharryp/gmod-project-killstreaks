include('shared.lua')
require("datastream")

local lpl;
local fullWidth = 175
local width = 0
local height = 10
local x = ScrW()/2 - fullWidth/2
local y = ScrH()/2 - height/2
local offset = 4
local DisFromCrate = CreateConVar ("Supply_CrateDistance", "75")
local setHook = false

function drawProgressBar()
	if width > fullWidth then
		width = fullWidth;
	end
	surface.CreateFont ("BankGothic Md BT", 20, 400, true, false, "MW2Font")
	draw.SimpleText("Capturing...", "MW2Font", ScrW()/2, ScrH()/2 - (height + offset), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor( 50, 50, 50, 150)
	surface.DrawRect(x - offset/2, y - offset/2, fullWidth + offset, height + offset)	
	surface.SetDrawColor( 255, 255, 255, 255)
	surface.DrawRect(x, y, width, height)	
	if !lpl:GetNetworkedBool("SupplyCrate_DrawBarBool") then		
		timer.Stop("SupplyCrate_ProgressBarTimer")
		hook.Remove("HUDPaint", "SupplyCrate_ProgressBar");
		return;
	end	
	if width >= fullWidth then
		datastream.StreamToServer( "SupplyCrate_GiveReward" )
		timer.Stop("SupplyCrate_ProgressBarTimer")
		hook.Remove("HUDPaint", "SupplyCrate_ProgressBar");
		hook.Remove("HUDPaint", "SupplyCrate_PopUpText")
		return;
	end
end

function increment()
	width = width + lpl:GetNetworkedFloat("SupplyCrate_Inc");
end

function startProgressBar()
	lpl = LocalPlayer();
	width = 0
	hook.Add("HUDPaint", "SupplyCrate_ProgressBar", drawProgressBar)	
	timer.Create("SupplyCrate_ProgressBarTimer", 0.01 , fullWidth, increment)
end

function setUp()
	timer.Simple(0.05, startProgressBar);
end

usermessage.Hook("SupplyCrate_DrawBar", setUp)

function ENT:Draw()
	
	self.Entity:DrawModel()
	
	local reward = self:GetNetworkedString("SupplyCrate_Reward")
	local tex = surface.GetTextureID("VGUI/killstreaks/animated/" .. reward)
	
	local wlh = getEntityWidthLengthHeight(self)
	local eHeight = wlh.z
	local width = wlh.x
	entPos = self:GetPos() + Vector(0, 0, eHeight + 8)
	
	cam.Start3D2D( entPos, Angle(0, LocalPlayer():GetAngles().y - 90, 90), 1 )
        surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255) // Makes sure the image draws with all colors
		surface.DrawTexturedRect(-8, -8, 16,16)
    cam.End3D2D()
	
	local tab = ents.FindInSphere(self:GetPos(), DisFromCrate:GetInt())	

	if table.HasValue(tab,LocalPlayer()) && !setHook then
		local function drawPopUpText()
			surface.CreateFont ("BankGothic Md BT", 20, 400, true, false, "MW2Font")			
			local str = "a " .. reward;
			if string.find(reward, "_") then
				local sep = string.Explode("_", reward)
				str = "a " .. sep[1] .. sep[2];
			elseif reward == "ammo" then str = reward end			
						
			draw.SimpleText("Press and hold \"Use\" for " .. str, "MW2Font", ScrW()/2, ScrH()/2 + (height + offset), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		hook.Add("HUDPaint", "SupplyCrate_PopUpText", drawPopUpText)
		setHook = true;
	elseif !table.HasValue(tab,LocalPlayer()) then
		hook.Remove("HUDPaint", "SupplyCrate_PopUpText")
		setHook = false;
	end
	
end 

function getEntityWidthLengthHeight(ent) --The function returns a vector with width as the vector's x, length as the vector's y, and height as the vector's z.
    local min,max = ent:WorldSpaceAABB()
    local offset=max-min
    return offset
end