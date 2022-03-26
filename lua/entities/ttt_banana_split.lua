if SERVER then
	AddCSLuaFile()
end

ENT.Icon = "vgui/ttt/icon_bananabomb.png"
ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"

ENT.Model = Model("models/props/cs_italy/bananna.mdl")

AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )

function ENT:Initialize()	
   self:SetModel(self.Model)
   
   if not self:GetRadius() then self:SetRadius(356) end
   if not self:GetDmg() then self:SetDmg(35) end 
   
   local phys = self:GetPhysicsObject()
   if IsValid(phys) then
	phys:SetMass(1)
   end
   
   timer.Simple(math.random(2,4), function() if IsValid(self) then self:Explode() end end)
   
   return self.BaseClass.Initialize(self)
end

function ENT:Explode()
	if SERVER then
		if !self:IsValid() then return end
		local pos = self.Entity:GetPos()
				  
		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		effect:SetScale(self:GetRadius() * 0.3)
		effect:SetRadius(self:GetRadius())
		effect:SetMagnitude(self.dmg)

		util.Effect("Explosion", effect, true, true)
		util.BlastDamage(self, self.Owner, pos, self:GetRadius(), self:GetDmg())
		
		self:Remove()
	end
end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self:EmitSound("weapons/bananaimpact.wav")
	end
	
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse*2)
end