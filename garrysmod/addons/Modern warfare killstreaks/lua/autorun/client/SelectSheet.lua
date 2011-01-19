require("datastream") 
local width = 300;
local height = 250;
local centerX = ScrW()/2 - width/2
local centerY = ScrH()/2 - height/2
local killstreaks = {{"UAV", 3, "uav"}, {"Care Package", 4, "care_package"}, {"Counter UAV", 4, "mw2_Counter_UAV"}, {"Sentry Gun", 5, "mw2_sentry_gun"}, {"Predator missile", 5, "predator_missile"}, {"Precision Airstrike", 6, "precision_airstrike"},
					 {"Harrier", 7, "harrier"}, {"Emergency Airdrop", 8, "Emergency_Airdrop"}, {"Stealth bomber", 9, "stealth_bomber"}, {"AC-130", 11, "ac-130"}, {"EMP", 15, "mw2_EMP"}, {"Nuke", 25, "Tactical_Nuke"}}
local texturePath = "VGUI/entities/"
local killNumLabels = {}

local function findValue(tab, var) -- tab is a 2d array
	for k,v in ipairs(tab) do
		if table.HasValue(v,var) then
			return v
		end
	end
	return nil;
end

local function getPos(tab, var)
	for k,v in ipairs(tab) do
		if v == var then
			return k;
		end
	end
	return -1;
end

local function setLabels(labelTable, values)
	for k,v in ipairs(labelTable) do
		if values[k] != nil then
			v:SetText(values[k] .. " Kills")
			v:SizeToContents()
		else
			v:SetText("")
			v:SizeToContents()
		end
	end		
end

local numTab = {nil, nil, nil}

local function setImage(picTab, value, insert)	
	local killNum = findValue(killstreaks, value)[2];
	local path = findValue(killstreaks, value)[3];
	
	if insert then
		if numTab[1] == nil then								
			numTab[1] = killNum;
			picTab[1]:SetImage(texturePath .. path)
			picTab[1]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[1] != nil && numTab[1] < killNum && numTab[2] == nil then
			numTab[2] = killNum;
			picTab[2]:SetImage(texturePath .. path)
			picTab[2]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[2] != nil && numTab[2] < killNum && numTab[3] == nil then
			numTab[3] = killNum;
			picTab[3]:SetImage(texturePath .. path)
			picTab[3]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[1] > killNum then
			if numTab[2] != nil then
				numTab[3] = numTab[2];
				picTab[3]:SetImage(picTab[2]:GetImage())
				picTab[3]:SetImageColor( Color(255,255,255,255) )
			end
			numTab[2] = numTab[1];
			numTab[1] = killNum			
			picTab[2]:SetImage(picTab[1]:GetImage())
			picTab[2]:SetImageColor( Color(255,255,255,255) )
			
			picTab[1]:SetImage(texturePath .. path)
			picTab[1]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[2] > killNum then
			numTab[3] = numTab[2];
			numTab[2] = killNum
			picTab[3]:SetImage(picTab[2]:GetImage())
			picTab[3]:SetImageColor( Color(255,255,255,255) )
			
			picTab[2]:SetImage(texturePath .. path)
			picTab[2]:SetImageColor( Color(255,255,255,255) )
		end
	else
		
		if numTab[1] == killNum then
			numTab[1] = numTab[2];
			numTab[2] = numTab[3]
			numTab[3] = nil;
			if numTab[1] != nil then
				picTab[1]:SetImage(picTab[2]:GetImage())
				picTab[1]:SetImageColor( Color(255,255,255,255) )
			else
				picTab[1]:SetImageColor( Color(255,255,255,0) )				
			end
			if numTab[2] != nil then
				picTab[2]:SetImage(picTab[3]:GetImage())
				picTab[2]:SetImageColor( Color(255,255,255,255) )
			else
				picTab[2]:SetImageColor( Color(255,255,255,0) )				
			end
			picTab[3]:SetImageColor( Color(255,255,255,0) )				
			
		elseif numTab[2] == killNum then
			numTab[2] = numTab[3]
			numTab[3] = nil;
			if numTab[2] != nil then
				picTab[2]:SetImage(picTab[3]:GetImage())
				picTab[2]:SetImageColor( Color(255,255,255,255) )
			else
				picTab[2]:SetImageColor( Color(255,255,255,0) )				
			end
			picTab[3]:SetImageColor( Color(255,255,255,0) )				
		else
			numTab[3] = nil;
			picTab[3]:SetImageColor( Color(255,255,255,0) )				
		end
	end
	setLabels(killNumLabels,numTab)
end

local DermaFrame;

local function MW2TeamsTab(frame)
	local ButtonPanel = vgui.Create( "DPanel" )
	ButtonPanel:SetPos( 0, 0)
	ButtonPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 31 )
	ButtonPanel:SetPaintBackground(false)
	
	local buttonSize = 64
	local buttonSpaceing = (ButtonPanel:GetTall() - (buttonSize * 5) ) /  5
	local buttonX, buttonY = frame:GetWide()/2 - buttonSize/2, 10;
	local numButtons = 0;
	local MW2Voices = {"militia", "seals", "opfor", "rangers", "tf141"}
	local t = LocalPlayer():Team() - 1;
	--MsgN("Team = " .. tostring(t))
	for k,v in ipairs(MW2Voices) do
	
		local myButton = vgui.Create("DImageButton", ButtonPanel)
		myButton:SetMaterial( "models/deathdealer142/supply_crate/" .. MW2Voices[k] )
		myButton:SetPos( buttonX, (buttonSize * numButtons) + (buttonSpaceing * numButtons) + buttonY );
		myButton:SetSize(buttonSize, buttonSize)
		myButton.DoClick = function()
			t = k - 1;
			datastream.StreamToServer( "SetMw2Voices", {k} )		
		end
		numButtons = numButtons + 1
	end
	ButtonPanel.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawRect( 0, 0, ButtonPanel:GetWide(), ButtonPanel:GetTall() ) -- Draw the rect	
		
		local y = (buttonSize * t) + (buttonSpaceing * t) + buttonY
		surface.SetDrawColor( 150, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawOutlinedRect( buttonX, y, 64, 64 ) -- Draw the rect
	end
	return ButtonPanel;
end

local function MW2UserVars(frame)
	local OptionPanel = vgui.Create( "DPanel")
	OptionPanel:SetPos( 0, 0)
	OptionPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 31 )
	OptionPanel:SetPaintBackground(false)
	
	local nuke = LocalPlayer():GetNetworkedBool("MW2NukeEffectOwner") or false;
	
	local nukeOwner = vgui.Create("DCheckBoxLabel", OptionPanel)
	nukeOwner:SetText("Nuke effects owner")
	if nuke then
		nukeOwner:SetValue(true)
	end
	nukeOwner:SetPos( 10, 10)
	
	nukeOwner:SizeToContents()
	nukeOwner.OnChange = function()
		nuke = nukeOwner:GetChecked()
	end	
	
	local nX, nY = nukeOwner:GetPos();
	local sentryTracer = vgui.Create("DCheckBoxLabel", OptionPanel)
	sentryTracer:SetText("Show laser on Sentry")
	if LocalPlayer():GetVar("ShowSentryLaser", false) then
		sentryTracer:SetValue(true)
	end
	sentryTracer:SetPos( nX, nY + 20);
	sentryTracer:SizeToContents()
	sentryTracer.OnChange = function()		
		LocalPlayer():SetVar("ShowSentryLaser", sentryTracer:GetChecked() )
	end	
	
	local setButton = vgui.Create("DButton", OptionPanel)
	setButton:SetText("Set")	
	setButton:SetSize(50,30)
	setButton:SetPos( OptionPanel:GetWide()/2 - setButton:GetWide()/2, OptionPanel:GetTall() - setButton:GetTall() - 5 )
	setButton.DoClick = function()
		datastream.StreamToServer( "setMW2PlayerVars", {nuke} )
		DermaFrame:Close();
	end

	OptionPanel.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawRect( 0, 0, OptionPanel:GetWide(), OptionPanel:GetTall() ) -- Draw the rect
	end
	
	return OptionPanel;
end

local function getClientVersion()
	local fi = "lua/autorun/server/killstreakCounter.lua";
	local dir = nil;	
	local addons = file.FindDir("addons/*", true);
	
	for k,v in ipairs(addons) do
		if file.Exists("addons/" .. v .. "/" .. fi, true) then 
			dir = "addons/" .. v .. "/.svn/entries";
			break;
		end
	end
	
	if dir != nil && file.Exists(dir,true) then
		return tonumber(string.Explode("\n", file.Read( dir, true) )[4] )
	else
		return nil;
	end
end

local serverVer = -1;
local userVer = getClientVersion();

local function UpdateFrame(frame)
	if userVer == nil then return end
	local mes1 = "You have version " .. userVer .. "\nThe current version is "
	local VersionPanel = vgui.Create( "DPanel", frame)
		VersionPanel:SetPos( 5, 30)
		VersionPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 40 )
		VersionPanel.Paint = function() -- Paint function
			surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
			surface.DrawRect( 0, 0, VersionPanel:GetWide(), VersionPanel:GetTall() ) -- Draw the rect
		end
	local DisplayPanel = vgui.Create( "DPanel", VersionPanel)
		DisplayPanel:SetPos( 5, 5)
		DisplayPanel:SetSize( DisplayPanel:GetParent():GetWide() - 10, 60 )
		DisplayPanel._BGColor = Color(75,75,75,255)
		DisplayPanel.Paint = function() -- The paint function		
			draw.RoundedBox( 4, 0, 0, DisplayPanel:GetWide(), DisplayPanel:GetTall(), DisplayPanel._BGColor )
		end
	local myLabel= vgui.Create("DLabel", DisplayPanel)
		myLabel:SetText(mes1)
		myLabel:SetPos(10,10)
		myLabel:SizeToContents()
		DisplayPanel:SetSize(DisplayPanel:GetParent():GetWide() - 10, myLabel:GetTall() + 20)
	local setButton = vgui.Create("DButton", VersionPanel)
		setButton:SetText("Check SVN Version")	
		setButton:SetSize(100,30)
		--setButton:SetPos( setButton:GetParent():GetWide()/2 - setButton:GetWide()/2, setButton:GetParent():GetTall() - setButton:GetTall() - 5 )
		local x,y = DisplayPanel:GetPos()
		setButton:SetPos( x + DisplayPanel:GetWide()/2 - setButton:GetWide()/2, y + DisplayPanel:GetTall() + 10 )
		
		setButton.DoClick = function()			
			http.Get("http://gmod-project-killstreaks.googlecode.com/svn/trunk/","",function(contents,size)
					serverVer = tonumber(string.match( contents, "Revision ([0-9]+)" ))
					paintPane()
			end)			
		end			
		function paintPane()
			local ver = tonumber(userVer)
			local mes2 = serverVer .. "\n"
			if ver < serverVer then --When the user has an outdated version
				DisplayPanel._BGColor = Color(185,75,75, 255)
				myLabel:SetColor( Color(0,0,0,255) )
				mes2 = mes2 .. "You don't have the most upto date version of the MW2 Killstreaks\nPlease go and update the SVN"
				DisplayPanel:SetSize(DisplayPanel:GetParent():GetWide() - 10, myLabel:GetTall() + 10)
			elseif ver == serverVer then --When the user is up to date
				DisplayPanel._BGColor = Color(75,185,75, 255)
				myLabel:SetColor( Color(0,0,0,255) )
				mes2 = mes2 .. "You have the most current version of the MW2 Killstreaks"
			else --When the user has a higher version then the server, which shouldn't happen
			end
			myLabel:SetText(mes1 .. mes2)
			myLabel:SizeToContents()
			DisplayPanel:SetSize(DisplayPanel:GetParent():GetWide() - 10, myLabel:GetTall() + 20)
			x,y = DisplayPanel:GetPos()
			setButton:SetPos( x + DisplayPanel:GetWide()/2 - setButton:GetWide()/2, y + DisplayPanel:GetTall() + 10 )
		end
		if serverVer > 0 then
			paintPane(serverVer)
		end
	return VersionPanel;
end

local function MW2KillstreakChooseFrame()
	local select3 = 0;
	local selectedNums = 0;
	local canUseNuke = GetConVarNumber("mw2_Allow_Nuke") or 0
	local buttonHeight, buttonSpaceing = 30, 5;
	local buttonWidth, buttonX = 100, 10;	
	
	DermaFrame = vgui.Create( "DFrame" )
		DermaFrame:SetPos( centerX,centerY )
		DermaFrame:SetSize( width, height )
		DermaFrame:SetTitle( "MW2 Killstreaks" )
		DermaFrame:SetVisible( true )
		DermaFrame:SetDraggable( true )
		DermaFrame:ShowCloseButton( true )
		DermaFrame:MakePopup()
	local PropertySheet = vgui.Create( "DPropertySheet" )
		PropertySheet:SetParent( DermaFrame )
		PropertySheet:SetPos( 5, 30 )
		PropertySheet:SetSize( 340, 315 )
	
	local DermaPanel = vgui.Create( "DPanel", DermaFrame )
		DermaPanel:SetPos( 0, 22)
		DermaPanel:SetSize( width, height )
		DermaPanel:SetPaintBackground(false)

	local selectedLabel = vgui.Create("DLabel", DermaPanel)
	
	local dups = {4,5,7,9,11}
	local tables = {};
	local picLabels = {};
	local numButtons = 1;
	local selectedStreaks = {};
	local defaultColor, selectedColor, restrictedColor = Color( 39, 37, 54, 255 ), Color( 0, 255, 0, 50 ), Color(255,0,0,100);
	for k,v in ipairs(killstreaks) do
	
		if v[1] != "Nuke" || ( canUseNuke == 1 && v[1] == "Nuke" ) then -- Have to wrap the whole process in an if statement to check against weither the nuke is usable or not, :'( no continue statement
			local valButton = vgui.Create( "DButton", DermaPanel ); -- Create the button
			valButton:SetSize( buttonWidth, buttonHeight ); -- Set the size of the button
			valButton:SetPos( buttonX, (buttonHeight * numButtons) + (buttonSpaceing * (numButtons - 1)) - 22 ); -- Set the position of the button
			numButtons = numButtons + 1;
			valButton:SetText( v[2] .. ") " .. v[1] );
			valButton.name = v[1]
			valButton.Paint = function() -- The paint function		
				draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
			end
			local value = v[2]
			if table.HasValue(dups, value) then
				local tab = findValue(tables, value)
				if tab == nil then
					table.insert(tables, {value, valButton })
				else
					table.insert(tab, valButton)
				end
			end
			
			local pressed = false;
			valButton.DoClick = function(valButton)
				local tab = nil;
				local color = defaultColor;
				if !pressed && selectedNums < 3 && !valButton.locked then
					selectedNums = selectedNums + 1;
					color = selectedColor;
					pressed = true
					selectedLabel:SetText(selectedNums .."/3 Selected")
					table.insert(selectedStreaks, valButton.name)					
					setImage(picLabels, valButton.name, true)
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), restrictedColor )
									v2.locked = true;
								end	
							end
						end
					end
				elseif pressed && !valButton.locked then
					selectedNums = selectedNums - 1;
					pressed = false;
					selectedLabel:SetText(selectedNums .."/3 Selected")
					setImage(picLabels, valButton.name, false)
					table.remove(selectedStreaks, getPos(selectedStreaks,valButton.name))
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
									v2.locked = false;
								end	
							end
						end
					end		
				end		
				if !valButton.locked then
					valButton.Paint = function() -- The paint function
						draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), color )
					end		
				end
			end
		end
	end

	DermaPanel:SetSize( DermaFrame:GetWide(), (buttonHeight * numButtons) + (numButtons * buttonSpaceing) + 10 )
	PropertySheet:SetSize( DermaFrame:GetWide(), (buttonHeight * numButtons) + (numButtons * buttonSpaceing) + 10 )	
	DermaFrame:SetSize( PropertySheet:GetWide(), PropertySheet:GetTall() )
	
	local CBx, CBy = buttonWidth + buttonX + 15, DermaFrame:GetTall()/2
	local numPics = 0;
	local picD = 64;
	local picY = DermaFrame:GetTall()/2 - picD;
	local imagePanel = vgui.Create( "DPanel", DermaPanel )
	
	for i=1,3 do 
		local picImage = vgui.Create("DImage", DermaPanel)
		picImage:SetPos(CBx - 5 + ( 10 + numPics * picD ) + (25 * numPics), picY)
		picImage:SetSize(picD,picD)
		numPics = numPics + 1
		table.insert(picLabels, picImage)
	end	
	
	local x,y = picLabels[3]:GetPos();
	
	DermaPanel:SetSize( x + picD + 15, DermaFrame:GetTall())
	PropertySheet:SetSize( x + picD + 15, DermaFrame:GetTall())
	local x3,y3 = PropertySheet:GetPos()
	DermaFrame:SetSize( PropertySheet:GetWide() + x3 + 5, PropertySheet:GetTall() + y3 + 5 )
	
	local ySpace = 30
	imagePanel:SetPos( CBx - 5, picY - 10 )
	imagePanel:SetSize( x + picD + 15,  picD + ySpace )
	imagePanel.Paint = function() -- Paint function	
		surface.SetDrawColor( 50, 50, 50, 255 ) 
		local x1,y1 = imagePanel:GetPos() 
		local x2,y2 = picLabels[2]:GetPos()
		local x3,y3 = picLabels[3]:GetPos()
		surface.DrawRect( 0, 0, picD + 20, picD + ySpace ) 
		surface.DrawRect( x2 - x1 - 10, 0, picD + 20, picD + ySpace ) 
		surface.DrawRect( x3 - x1 - 10, 0, picD + 20, picD + ySpace ) 
	end
	local x,y = imagePanel:GetPos();
	surface.CreateFont ("BankGothic Md BT", 20, 400, true, false, "MW2Font")	
	
	selectedLabel:SetPos(CBx + 35, y + imagePanel:GetTall() + 10);
	selectedLabel:SetFont("MW2Font")
	selectedLabel:SetText("0/3 Selected")
	selectedLabel:SizeToContents()
	surface.CreateFont ("BankGothic Md BT", 15, 200, true, false, "MW2Font2")
	for i=1,3 do
		local x1,y1 = picLabels[i]:GetPos()
		killNumLabels[i] = vgui.Create("DLabel", DermaPanel)
		killNumLabels[i]:SetPos( x1, y1 + picD);
		killNumLabels[i]:SetFont("MW2Font2")
		killNumLabels[i]:SetText("")
		killNumLabels[i]:SizeToContents()
	end
	
	local x,y = selectedLabel:GetPos();
	
	local selectButton = vgui.Create("DButton", DermaPanel)
	selectButton:SetText("Use selected killstreaks")
	selectButton:SetPos(CBx + 35, y + selectedLabel:GetTall() + 5 )
	selectButton:SetSize(150,30)	
	selectButton.DoClick = function()
		--PrintTable( selectedStreaks )
		selectedNums = 0;
		killNumLabels = {}
		numTab = {nil, nil, nil}
		datastream.StreamToServer( "ChoosenKillstreaks", selectedStreaks )
		DermaFrame:Close();
	end	
	
	DermaPanel.Paint = function() -- The paint function
		surface.SetDrawColor( 110, 110, 110, 255 ) -- What color ( R, B, G, A )
		surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
	end
	
	PropertySheet:AddSheet( "Killstreak Menu", DermaPanel, "gui/silkicons/user", false, false, "Select your Killstreaks here" )	
	PropertySheet:AddSheet( "Team Menu", MW2TeamsTab(DermaPanel), "gui/silkicons/group", false, false, "Select your Team here" )
	PropertySheet:AddSheet( "User Vars", MW2UserVars(DermaPanel), "gui/silkicons/wrench", false, false, "Set Your options" )
	local pan = UpdateFrame(DermaPanel);
	if pan != nil then
		PropertySheet:AddSheet( "Killstreak version", pan, "gui/silkicons/world", false, false, "Check for Updates" )
	end
end

concommand.Add("OpenKillstreakWindow", MW2KillstreakChooseFrame)
