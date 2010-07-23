ENT.Type = "anim"
ENT.PrintName = "HE Grenade"
ENT.Author = "Me"
ENT.Contact = nil
ENT.Purpose = nil
ENT.Instructions = nil

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end

	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse)
end