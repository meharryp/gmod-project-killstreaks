
include('shared.lua')

ENT.Duration = 90;
ENT.Timer = CurTime();
ENT.Killstreaks = {"mw2_counterUAV", "mw2_SentryGun", "mw2_UAV", "sent_ac-130", "sent_harrier"}

function ENT:Initialize()
	self.Owner = self:GetVar("owner")		
	self:SetModel("models/dav0r/camera.mdl") -- Just need a model, doesnt matter what it is
	self:SetColor(255,255,255,0);
	self:SetPos( Vector(0,0, self:FindSky()) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:GetPhysicsObject():EnableGravity(false)
	self:SetNotSolid(true)	
	
	for k,v in pairs(player.GetAll()) do
		umsg.Start("MW2_EMP_FireEMP", v);
			umsg.Short(self.Owner:Team())
		umsg.End()	
		
		if v:Team() == self.Owner:Team() then
			v:SetNoTarget(true)
		end
		
	end
	MW2_KillStreaks_EMP_Team = self.Owner:Team()
	self:Create_EMP_Effect()
	self:Kill_Killstreaks()
	self.Timer = CurTime() + self.Duration;
end

function ENT:Think()

	if self.Timer <= CurTime() then
		self:Remove_EMP();
	end

    self.Entity:NextThink( CurTime()+ 0.01 )
    return true;
end

function ENT:Create_EMP_Effect()
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue("effect_name", "EMP")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 40)
end

function ENT:Kill_Killstreaks()
	for k,v in pairs(self.Killstreaks) do
		local ents = ents.FindByClass(v);
		for k,v in pairs(ents) do
			MsgN(v:GetClass())
			if v:GetTeam() != self.Owner:Team() then
				v:Destroy();
			end
		end		
	end
end

function ENT:Remove_EMP()
	
	for k,v in pairs(player.GetAll()) do
		umsg.Start("MW2_EMP_RemoveEMP", v);
		umsg.End()			
		if v:Team() == self.Owner:Team() then
			v:SetNoTarget(false)
		end		
	end
	MW2_KillStreaks_EMP_Team = -1;
	self:Remove();
end

function ENT:FindSky()

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
	local num = 0;
	local skyLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if num >= 300 then
			MsgN("Reached max number here, no luck in finding a skyBox");
			bool = false;
		end
		num = num + 1
	end
	
	return skyLocation;
end