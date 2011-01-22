local tex = surface.GetTextureID("VGUI/killStreak_misc/callin")
local imageSize = 64;
local function FindSky()

	local maxheight = 16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,maxheight);
	local filterList = {}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local skyLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			//MsgN("Hit the sky")
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
			//MsgN("hit the world, not the sky")
		else 
			//Msg("Hit ")
			//MsgN(traceData.Entity:GetClass());
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 300 then
			MsgN("Reached max number here, no luck in finding a skyBox");
			bool = false;
		end
	end
	
	return skyLocation;
end

local sky = FindSky()

local xyOffset = .05
local x,y = ScrW() * xyOffset, ScrH() * xyOffset
local w,h = math.Round( ScrW() - (x * 2 ) ), math.Round( ScrH() - ( y * 2 ) )

local function showOverlay(ent)
	local viewPos = Vector(0,0,sky) 
	local CamData = {}
	local Overlay = vgui.Create('DFrame')
		Overlay:SetSize(w, h)
		Overlay:SetPos(x, y)
		Overlay:SetDraggable(false)
		Overlay:ShowCloseButton(false)
		Overlay:SetTitle('')
		Overlay:MakePopup()
		Overlay.curX, Overlay.curY = 0,0
	Overlay.OnMousePressed  = function()
		datastream.StreamToServer("MW2_DropLocation_Overlay_Stream", { ent, viewPos } )
		Overlay:Close()
	end	
	local moveFactor = .005	
	local texPossitonX = Overlay:GetWide()/2 - imageSize/2
	local texPossitonY = Overlay:GetTall()/2 - imageSize/2

	Overlay.Paint = function()
		local CamX, CamY = Overlay:GetPos()
		
		CamData.angles = Angle(90,0,0)
		CamData.origin = viewPos
		CamData.x = CamX
		CamData.y = CamY
		CamData.w = w
		CamData.h = h
		CamData.drawviewmodel = false;
		render.RenderView( CamData )			
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
		surface.DrawTexturedRect(texPossitonX, texPossitonY, imageSize, imageSize)	
	end

	Overlay.Think = function()
		if !Overlay.Move then return end
		Overlay.curX, Overlay.curY = Overlay:CursorPos();
		Overlay.curX = Overlay.curX - Overlay:GetWide()/2;
		Overlay.curY = Overlay.curY - Overlay:GetTall()/2;
		Overlay.curX = math.Round( Overlay.curX / (Overlay:GetWide() * moveFactor) ); 
		Overlay.curY = math.Round( Overlay.curY / (Overlay:GetTall() * moveFactor) );		
		if Overlay.curX != 0 then viewPos = viewPos - Vector(0, Overlay.curX, 0) end
		if Overlay.curY != 0 then viewPos = viewPos - Vector(Overlay.curY, 0, 0) end
	end

	Overlay.OnCursorEntered = function()
		Overlay.Move = true;
	end
	Overlay.OnCursorExited = function()
		Overlay.Move = false;
	end
		
	input.SetCursorPos(ScrW()/2,ScrH()/2)
end


local function OpenOverlay( um )
	showOverlay( um:ReadEntity() )
end

usermessage.Hook("MW2_DropLoc_Overlay_UM", OpenOverlay)
