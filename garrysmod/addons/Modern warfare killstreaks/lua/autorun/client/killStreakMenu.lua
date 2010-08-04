//if !MW2KillStreakAddon then return end
require("datastream") 
function MW2UserOptions(Panel)
	Panel:ClearControls()
	
	button = {}
	button.Label = "Choose killstreaks"
	button.Command = "OpenKillstreakWindow";
	Panel:AddControl("Button", button)
	
	button = {}
	button.Label = "Choose Voices"
	button.Command = "OpenMW2VoiceWindow";
	Panel:AddControl("Button", button)
	
	button = {}
	button.Label = "Set options"
	button.Command = "OpenMW2PlayerVars";
	Panel:AddControl("Button", button)
end

function MW2AdminOptions(Panel)
	Panel:ClearControls()
	
	CheckBox = {}
	CheckBox.Label = "Enable killstreaks"
	CheckBox.Command = "mw2_enable_killstreaks";
	Panel:AddControl("CheckBox", CheckBox)
	
	CheckBox = {}
	CheckBox.Label = "Allow Tactical Nuke"
	CheckBox.Command = "mw2_Allow_Nuke";
	Panel:AddControl("CheckBox", CheckBox)
	
	slider = {}
	slider.Label 	= "Number of NPCs to = 1 player kill"
	slider.Command 	= "mw2_NPC_requirement"
	slider.Type 		= "Integer";
	slider.Min 		= "1"
	slider.Max 		= "20"
	Panel:AddControl("Slider", slider)
end

function LoadMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Admin", "MW2KillStreaksAdmin", "MW2 KillStreaks", "", "", MW2AdminOptions)
	spawnmenu.AddToolMenuOption("Utilities", "User", "MW2KillStreaksUser", "MW2 KillStreaks", "", "", MW2UserOptions)
end
hook.Add( "PopulateToolMenu", "MW2KillstreakMenus", LoadMenu )

local width = 300;
local height = 250;
local centerX = ScrW()/2 - width/2
local centerY = ScrH()/2 - height/2
local killstreaks = {"UAV = 3", "Care Package = 4", "Predator missile = 5", "Precision Airstrike = 6", "Harrier = 7", "Emergency Airdrop = 8", "Stealth bomber = 9", "AC-130 = 11", "Nuke = 25"}


function MW2KillstreakChooseFrame()
	local select3 = 0;
	local canUseNuke = GetConVarNumber("mw2_Allow_Nuke") or 0
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( centerX,centerY )
	DermaPanel:SetSize( width, height )
	DermaPanel:SetTitle( "MW2 Killstreaks" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	
	lastLength = 0;	
	local StreakComboBox = vgui.Create( "DComboBox", DermaPanel )
	StreakComboBox:SetPos( 10, 35 )
	StreakComboBox:SetSize( 100, 185 )
	StreakComboBox:SetMultiple( false )
	for k,v in ipairs(killstreaks) do
		if string.len(v) > lastLength then 		lastLength = string.len(v)	end
		
		StreakComboBox:SetSize(lastLength * 5 + 5, 185)
		if  v != "Nuke = 25" || ( canUseNuke == 1 && v == "Nuke = 25" ) then
			StreakComboBox:AddItem(v);
		end
	end
	
	CBx, CBy = StreakComboBox:GetPos();
	
	local myButton = vgui.Create("DButton", DermaPanel)
	myButton:SetText("Use selected killstreaks")
	
	myButton:SetPos( StreakComboBox:GetWide() + CBx + 10, 100 )
	
	myButton:SetSize(150,30)
	myButton.DoClick = function()
		killstreakTable = {}
		tab = StreakComboBox:GetSelectedItems()
		for k,v in pairs(tab) do 			
			str = string.Explode(" =", v:GetValue())
			killstreakTable[k] = str[1];
		end
		datastream.StreamToServer( "ChoosenKillstreaks", killstreakTable )
		DermaPanel:Close();
    end

	function StreakComboBox:SelectItem( item, onlyme ) 

		if ( !onlyme && item:GetSelected() ) then return end 
	 
		self.m_pSelected = item 
		if item:GetSelected() then
			item:SetSelected( false )
			for k, v in pairs (self.SelectedItems) do
				if v == item then			
					table.remove(self.SelectedItems, k)
					select3 = select3 - 1;
				end
			end
	 
		else
			if select3 < 3 then
				item:SetSelected( true )
				select3 = select3 + 1;
				table.insert( self.SelectedItems, item ) 
			end
		end
	end
end

local MW2Voices = {"Militia", "Navy seals", "Opfor", "US Marines", "TF 141"}
function MW2VoiceChooseFrame()

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( centerX,centerY )
	DermaPanel:SetSize( width, height )
	DermaPanel:SetTitle( "MW2 voices" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	
	for k,v in ipairs(MW2Voices) do
	
		local myButton = vgui.Create("DButton", DermaPanel)
		myButton:SetText(v)
		
		myButton:SetPos( 10, 35 + ( ((k-1) * 35)) + 10 )
		
		myButton:SetSize(100,30)
		myButton.DoClick = function()
			//LocalPlayer():SetNetworkedString("MW2TeamSound", tostring(k))
			SetVoiceMW2(k)
		end
	end
end

function SetVoiceMW2 (num)
	datastream.StreamToServer( "SetMw2Voices", {num} )
end

function MW2PlayerVarsFrame()
	local thermal = LocalPlayer():GetNetworkedBool("MW2AC130ThermalView") or false;
	local nuke = LocalPlayer():GetNetworkedBool("MW2NukeEffectOwner") or false;
	
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( centerX,centerY )
	DermaPanel:SetSize( width, height )
	DermaPanel:SetTitle( "Player variables" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()	
	
	local useThermal = vgui.Create("DCheckBoxLabel", DermaPanel)
	useThermal:SetText("Use thermal vision")
	if thermal then
		useThermal:SetValue(true)
	end
	useThermal:SetPos( 10, 35)
	
	useThermal:SizeToContents()
	useThermal.OnChange = function()
		thermal = useThermal:GetChecked()
	end
	
	local nukeOwner = vgui.Create("DCheckBoxLabel", DermaPanel)
	nukeOwner:SetText("Nuke effects owner")
	if nuke then
		nukeOwner:SetValue(true)
	end
	nukeOwner:SetPos( 10, 50)
	
	nukeOwner:SizeToContents()
	nukeOwner.OnChange = function()
		nuke = nukeOwner:GetChecked()
	end
	
	
	local myButton = vgui.Create("DButton", DermaPanel)
	myButton:SetText("Set")
	myButton:SetPos( 50, 65 )
	myButton:SetSize(50,30)
	myButton.DoClick = function()
		SetPlayerVarsMW2(thermal, nuke)
		DermaPanel:Close();
	end

end

function SetPlayerVarsMW2 (thermal, nuke)
	datastream.StreamToServer( "setMW2PlayerVars", {thermal,nuke} )
end

concommand.Add("OpenKillstreakWindow", MW2KillstreakChooseFrame)
concommand.Add("OpenMW2VoiceWindow", MW2VoiceChooseFrame)
concommand.Add("OpenMW2PlayerVars", MW2PlayerVarsFrame)
