AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local Burn_Sound = Sound("Fire.Plasma")
util.PrecacheModel("models/props_junk/watermelon01.mdl")

function ENT:Initialize()

        self.Entity:SetModel("models/props_junk/watermelon01.mdl")       
        self.Entity:PhysicsInitSphere( 4, "metal_bouncy" )        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
                phys:Wake()
        end
        
        self.Entity:SetAngles(self.Entity:GetOwner():GetAimVector():Angle())       
        self.Entity:SetCollisionBounds( Vector()*-4, Vector()*4 )

        self.Sound = CreateSound( self.Entity, Burn_Sound )
        self.Sound:SetSoundLevel( 95 )
        self.Sound:Play()
end

function ENT:OnRemove()

        if ( self.Sound ) then
                self.Sound:Stop()
        end
        
end

function ENT:Think() 

        if self.Dead then
                self:Explode()
        end
        
        return true
        
end

function ENT:Explode()

        if ( self.Exploded ) then return end
        
        self.Exploded = true
        
        local explosion = ents.Create( "env_explosion" )
		explosion:SetKeyValue( "spawnflags", 144 )
		explosion:SetKeyValue( "iMagnitude", 155 )
		explosion:SetKeyValue( "iRadiusOverride", 150 )
		explosion:SetPos(self:GetPos())
		explosion:Spawn( )
		explosion:Fire("explode","",0)
		self.Entity:Remove()

        self.Entity:Remove()

end

function ENT:PhysicsSimulate( phys, deltatime )

        if self.Dead then return SIM_NOTHING end
                
        local fSin = math.sin( CurTime() * 20 ) * 1.1
        local fCos = math.cos( CurTime() * 20 ) * 1.1
        
        local vAngular = Vector(0,0,0)
        local vLinear = (self.FlyAngle:Right() * fSin) + (self.FlyAngle:Up() * fCos)
        vLinear = vLinear * deltatime * 1.001

        return vAngular, vLinear, SIM_GLOBAL_FORCE
        
end

function ENT:PhysicsCollide( data, physobj )
        
        self.Dead = true
        
        self.Entity:NextThink(CurTime())
        
end