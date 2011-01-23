local tex = surface.GetTextureID("VGUI/killStreak_misc/callin")
local arrow = surface.GetTextureID("VGUI/killStreak_misc/arrow")
local texSize = 64;
local arrowSize = 32;
local edge = arrowSize + arrowSize/2
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

function findBounds(axis, height)

	local length = 16384
	local startPos = Vector(0,0,height);
	local endPos;
	if axis == "x" then 
		endPos = Vector(length, 0,height);
	elseif axis == "y" then 
		endPos = Vector(0, length,height);
	end
	
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
	local wallLocation1 = -1;
	local wallLocation2 = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			if wallLocation1 == -1 then
				if axis == "x" then
					wallLocation1 = traceData.HitPos.x;
				elseif axis == "y" then
					wallLocation1 = traceData.HitPos.y;
				end
				
				if axis == "x" then 
					endPos = Vector(length * -1, 0,height);
				elseif axis == "y" then 
					endPos = Vector(0, length * -1,height);
				end
				
				trace = {}
				trace.start = startPos;
				trace.endpos = endPos;
				trace.filter = filterList;
			else
				if axis == "x" then
					wallLocation2 = traceData.HitPos.x;
				elseif axis == "y" then
					wallLocation2 = traceData.HitPos.y;
				end
				
				bool = false;
			end
		elseif hitWorld then
			if wallLocation1 == -1 then
				if axis == "x" then
					trace.start = traceData.HitPos + Vector(50,0,0);
				elseif axis == "y" then
					trace.start = traceData.HitPos + Vector(0,50,0);
				end
			else
				if axis == "x" then
					trace.start = traceData.HitPos - Vector(50,0,0);
				elseif axis == "y" then
					trace.start = traceData.HitPos - Vector(0,50,0);
				end
			end
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the wall");
			bool = false;
		end		
		maxNumber = maxNumber + 1;
	end
	
	return wallLocation1, wallLocation2;
end
local sky = FindSky()
local x1,x2 = findBounds("x", sky) -- x1 is positive, x2 is negative
local y1,y2 = findBounds("y", sky) -- y1 > 0; y2 < 0

local xyOffset = .05
local x,y = ScrW() * xyOffset, ScrH() * xyOffset
local w,h = math.Round( ScrW() - (x * 2 ) ), math.Round( ScrH() - ( y * 2 ) )

local function isInWorld( pos )
	local posX, posY = pos.x, pos.y
	if ( posX > x2 && posX < x1 ) && ( posY > y2 && posY < y1 ) then
		return true;
	end
	return false;
end

function math.AdvRound( val, d )
	d = d or 0;
 
	return math.Round( val * (10 ^ d) ) / (10 ^ d);
end

local function drawDirArrow(angle, xPos, yPos)	
	surface.SetTexture(arrow)
	surface.SetDrawColor(255,255,255,255)
	if angle == 0 then
		surface.DrawTexturedRectRotated(xPos, yPos - edge, arrowSize, arrowSize, 0)	-- 					X = 640, 	Y = 464	
	elseif angle == 45 then
		surface.DrawTexturedRectRotated(xPos - edge/1.5, yPos - edge/1.5, arrowSize, arrowSize, 45)	--	X = 608,	Y = 480	
	elseif angle == 90 then
		surface.DrawTexturedRectRotated(xPos - edge, yPos, arrowSize, arrowSize, 90)	-- 				X = 592,	Y = 512
	elseif angle == 135 then
		surface.DrawTexturedRectRotated(xPos - edge/1.5, yPos + edge/1.5, arrowSize, arrowSize, 135)--	X = 608,	Y = 544
	elseif angle == 180 then
		surface.DrawTexturedRectRotated(xPos, yPos + edge, arrowSize, arrowSize, 180)	--				X = 640,	Y = 560
	elseif angle == 225 then
		surface.DrawTexturedRectRotated(xPos + edge/1.5, yPos + edge/1.5, arrowSize, arrowSize, 225)--	X = 672,	Y = 544
	elseif angle == 270 then
		surface.DrawTexturedRectRotated(xPos + edge, yPos, arrowSize, arrowSize, 270)	--				X = 688,	Y = 512
	elseif angle == 315 then
		surface.DrawTexturedRectRotated(xPos + edge/1.5, yPos - edge/1.5, arrowSize, arrowSize, 315)--	X = 672,	Y = 480	
	end
end

local function showOverlay(ent, select)
	local viewPos = Vector(0,0,sky) 
	local ang = 0;
	local CamData = {}
	local Overlay = vgui.Create('DFrame')
		Overlay:SetSize(w, h)
		Overlay:SetPos(x, y)
		Overlay:SetDraggable(false)
		Overlay:ShowCloseButton(false)
		Overlay:SetTitle('')
		Overlay:SetBackgroundBlur( true )
		Overlay:MakePopup()
				
	local button = vgui.Create("DButton", Overlay) -- Need to use a button to register right clicks.
		button:SetSize(Overlay:GetWide(), Overlay:GetTall())
		button:SetPos(0,0);
		button:SetText("");
		button.DoClick = function()			
			if select then
				datastream.StreamToServer("MW2_DropLocation_Overlay_Stream", { ent, viewPos, ang } )
			else
				datastream.StreamToServer("MW2_DropLocation_Overlay_Stream", { ent, viewPos, nil } )
			end
			Overlay:Close()
		end	
		button.DoRightClick = function()
			if select then
				ang = ang + 45;
				if ang >= 360 then ang = 0 end
			end
		end	
		button.curX, button.curY = 0,0
		button.fov = 75;
		button.fovScale = 1;
	local moveFactor = .005	
	local texPossitonX = button:GetWide()/2 - texSize/2
	local texPossitonY = button:GetTall()/2 - texSize/2

	button.Paint = function()
		local CamX, CamY = Overlay:GetPos()
		
		CamData.angles = Angle(90,0,0)
		CamData.origin = viewPos
		CamData.x = CamX
		CamData.y = CamY
		CamData.w = w
		CamData.h = h
		CamData.drawviewmodel = false;
		CamData.fov = button.fov
		render.RenderView( CamData )			
		
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
		surface.DrawTexturedRect(texPossitonX, texPossitonY, texSize, texSize)	
		if select then			
			drawDirArrow(ang, button:GetWide()/2, button:GetTall()/2)
		end
	end
	
	button.Think = function()
		if !button.Move then return end
		button.curX, button.curY = button:CursorPos();
		button.curX = button.curX - button:GetWide()/2;
		button.curY = button.curY - button:GetTall()/2;
		button.curX = math.AdvRound( ( button.curX / (button:GetWide() * moveFactor) ) * button.fovScale, 2 );
		button.curY = math.AdvRound( ( button.curY / (button:GetTall() * moveFactor) ) * button.fovScale, 2 );
		if button.curX != 0 && isInWorld( viewPos - Vector(0, button.curX, 0) ) then viewPos = viewPos - Vector(0, button.curX, 0) end
		if button.curY != 0 && isInWorld( viewPos - Vector(button.curY, 0, 0) ) then viewPos = viewPos - Vector(button.curY, 0, 0) end
	end
	function button:OnMouseWheeled(mc)
		if mc > 0 then			
			if button.fov < 10 then 
				button.fov = button.fov - 1;
			else
				button.fov = button.fov - 4
			end
			if button.fov < 1 then button.fov = 1; end			
		elseif mc < 0 then
			if button.fov < 10 then 
				button.fov = button.fov + 1;
			else
				button.fov = button.fov + 4;
			end
			if button.fov > 75 then button.fov = 75; end
		end
		button.fovScale = button.fov/75
	end

	button.OnCursorEntered = function()
		button.Move = true;
	end
	button.OnCursorExited = function()
		button.Move = false;
	end
	
	input.SetCursorPos(ScrW()/2,ScrH()/2)
end

local function OpenOverlay( um )
	showOverlay( um:ReadEntity(), um:ReadBool() )
end

usermessage.Hook("MW2_DropLoc_Overlay_UM", OpenOverlay)
