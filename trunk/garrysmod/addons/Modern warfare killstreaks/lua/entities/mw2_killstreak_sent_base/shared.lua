ENT.Type 			= "anim"
ENT.Author			= "Death dealer142"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.Friendlys = {"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman" }

function ENT:IsFriendly(tar)
	if tar:IsNPC() && table.HasValue(self.Friendlys, tar:GetClass()) then return true end
	if tar:IsPlayer() && ( tar == self.Owner || tar:Team() == self.Owner:Team() ) then return true end
	
	return false;
end

function ENT:GetPossilbeTargets()
	local enttable = ents.FindByClass("npc_*")
	local monstertable = ents.FindByClass("monster_*")
	local playertable = player.GetAll()
	table.Add(enttable, monstertable)
	table.Add(enttable, playerTable)
	return enttable;	
end