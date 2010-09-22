//if !MW2KillStreakAddon then return end
function MW2UserOptions(Panel)
	Panel:ClearControls()
	
	button = {}
	button.Label = "Choose killstreaks"
	button.Command = "OpenKillstreakWindow";
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
	
	CheckBox = {}
	CheckBox.Label = "Allow Teams"
	CheckBox.Command = "mw2_Allow_Teams";
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
