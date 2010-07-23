
include('shared.lua')

ENT.TimeToDetonate = CurTime() + 10;
ENT.DetonatePos = NULL;
ENT.CountDown = 10.0;
ENT.TimerDelay = CurTime();
ENT.NukeSpawned = false;
function ENT:Initialize()
	SetGlobalString("MW2_Nuke_CountDown_Timer", "")
	self.TimeToDetonate = CurTime() + 10;
	self.Owner = self.Entity:GetVar("owner",Entity(1))		
	SetGlobalString("MW2_Nuke_Player", self.Owner:GetName())
	self:SetModel("models/dav0r/camera.mdl") -- Just need a model, doesnt matter what it is
	self:SetColor(255,255,255,0);
	self:SetPos( Vector(0,0, self:findGround()) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:GetPhysicsObject():EnableGravity(false)
	self:SetNotSolid(true)	
	for k,v in pairs(player.GetAll()) do
		umsg.Start("MW2_Nukes_SetUpHUD", v);
		umsg.End()	
	end
end

function ENT:Think()
	if CurTime() < self.TimeToDetonate && self.TimerDelay < CurTime() then
		self.TimerDelay = CurTime() + 0.1;
		self.CountDown = self.CountDown - 0.1;
		
		local timerString = self.CountDown .. "";
		SetGlobalString("MW2_Nuke_CountDown_Timer", timerString)
	elseif CurTime() > self.TimeToDetonate && !self.NukeSpawned then
		self:SpawnNuke();
		timer.Simple(5, self.Remove, self)
	end
	self.Entity:NextThink( CurTime() + .01 )
    return true
end

function ENT:SpawnNuke()
	self.NukeSpawned = true;
	umsg.Start("MW2_Nuke_RemoveHUD", self.Owner);
	umsg.End()	
		local nuke = ents.Create("sent_tactical_nuke")
		nuke:SetPos( self:GetPos())
		nuke:SetVar("owner", self.Owner)
		nuke:Spawn()
		nuke:Activate()
	self:killEveryOneWithNuke()
end

function ENT:killEveryOneWithNuke()
	local players =  ents.GetAll()
	local frags = 0;
	for k, v in pairs(players) do
		if (v:IsPlayer() && v != self.Owner	) then
			SlowDownPlayers(v)
			frags = frags + 1;
		elseif ( v:IsPlayer() && v == self.Owner && v:GetNetworkedBool("MW2NukeEffectOwner") ) then
			SlowDownPlayers(v)
			frags = frags + 1;
		elseif v:IsNPC() then
			
			if v:GetClass() != "npc_strider" && v:GetClass() != "bullseye_strider_focus" && v:GetClass() != "npc_turret_floor" && v:GetClass() != "npc_rollermine" then				
				timer.Create("NukeRagDollFadeTimer" .. k, .03, 255, FadeRagdolls, self:TurnIntoRagdoll(v), self)
			else
				v:Fire("Break","",0);
			end
			frags = frags + 1;
		end		
	end
	self.Owner:AddFrags(frags)
end

function FadeRagdolls(ragdoll, nuke)
	if ragdoll == NULL then return end
	local r,g,b,a = ragdoll:GetColor()
	ragdoll:SetColor(r,g,b, a - 1)
	if a -1 == 0 then 
		ragdoll:Remove()
	end	
end

function SlowDownPlayers(pl)
	GAMEMODE:SetPlayerSpeed(pl, 50, 50)
	pl:SetJumpPower(100)
	//Controls the bloom. Redundant, but will work for now.
	timer.Simple(0.3, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.1; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1; sensitivity 1")
	timer.Simple(0.5, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.2; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.7, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.3; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.9, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.4; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.11, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.5; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.13, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.6; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.15, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.7; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.17, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 0.8; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(0.19, pl.ConCommand, pl, "pp_bloom_darken 0;pp_bloom_multiply 1.0; pp_bloom_sizex 9; pp_bloom_sizey 9; pp_bloom_passes 3; pp_bloom_color 10; pp_bloom_color_r 255; pp_bloom_color_b 0; pp_bloom_color_g 153; pp_bloom 1")
	timer.Simple(5, pl.Kill, pl)
	timer.Simple(10, pl.ConCommand, pl, "pp_bloom 0; sensitivity 10")
	
end

function ENT:TurnIntoRagdoll(npc)
	local tempRag = ents.Create("prop_ragdoll")
	tempRag:SetModel(npc:GetModel())
	tempRag:SetPos(npc:GetPos())
	npc:Remove();
	tempRag:Spawn();
	return tempRag;
end

function ENT:findGround()

	local minheight = -16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,minheight);
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
	local groundLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitWorld then
			groundLocation = traceData.HitPos.z;			
			bool = false;
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the ground");
			bool = false;
		end		
	end
	
	return groundLocation;
end