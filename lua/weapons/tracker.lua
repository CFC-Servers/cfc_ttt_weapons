-- Tracker
if SERVER then
    AddCSLuaFile( "tracker.lua" )
end

if CLIENT then
    SWEP.PrintName = "Dartgun"
    SWEP.Author = "CountLow"
    SWEP.Slot = 6
    SWEP.ViewModelFOV = 54
    SWEP.ViewModelFlip = false
end

SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "crossbow"
SWEP.UseHands = true
SWEP.Primary.Delay = 1.5
SWEP.Primary.Recoil = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Thumper"
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot" )
SWEP.IronSightsPos = Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng = Vector( 2.2, -0.1, 0 )
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.Kind = WEAPON_EQUIP1
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = ""

SWEP.CanBuy = { ROLE_DETECTIVE }

SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false

if CLIENT then
    SWEP.Icon = "VGUI/ttt/icon_dart"

    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = [[
        Shooting players gives them a persistant aura that
        only you can see. It has 2 darts.
        ]]
    }
end

if SERVER then
    resource.AddFile( "materials/VGUI/ttt/icon_dart.vmt" )
end

local tracked = {}
local prog = 0

function SWEP:PrimaryAttack()
    if ( not self:CanPrimaryAttack() ) then return end

    if SERVER then
        self:SetNextPrimaryFire( CurTime() + 1.5 )
        self:ShootBullet( 0, 1, 0.001 )
        self:TakePrimaryAmmo( 1 )
        self:GetOwner():ViewPunch( Angle( -4, 0, 0 ) )
    end

    if CLIENT then
        local ply = self:GetOwner()
        local tr = ply:GetEyeTrace()
        local tar = tr.Entity
        if ( tar.IsPlayer() == false ) then return end
        tracked[prog] = tar
        prog = prog + 1
        self:EmitSound( self.Primary.Sound )
    end
end

hook.Add( "PreDrawHalos", "Draw", function()
    for a = 0, #tracked do
        if ( IsValid( tracked[a] ) and tracked[a]:Alive() == false ) then
            tracked[a] = false
        end
    end

    halo.Add( tracked, Color( 255, 198, 0, 255 ), 2, 2, 3, true, true )
end )

hook.Add( "TTTBeginRound", "start", function()
    if CLIENT then
        prog = 0
        table.Empty( tracked )
    end
end )

hook.Add( "TTTPrepareRound", "prep", function()
    if CLIENT then
        prog = 0
        table.Empty( tracked )
    end
end )

function reset( weap, own )
    swap = not swap

    if ( own ~= nil ) then
        own:SetFOV( 0, 0.1 )
        weap:SetIronsights( false )
    end
end

function SWEP:Holster()
    reset( self, self:GetOwner() )

    return true
end

function SWEP:Reload()
    reset( self, self:GetOwner() )
end

function SWEP:SetZoom( state )
    if CLIENT then
        return
    elseif IsValid( self:GetOwner() ) and self:GetOwner():IsPlayer() then
        if state then
            self:GetOwner():SetFOV( 20, 0.3 )
        else
            self:GetOwner():SetFOV( 0, 0.2 )
        end
    end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    if self:GetNextSecondaryFire() > CurTime() then return end
    bIronsights = not self:GetIronsights()
    self:SetIronsights( bIronsights )

    if SERVER then
        self:SetZoom( bIronsights )
    end

    self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:PreDrop()
    self:SetZoom( false )
    self:SetIronsights( false )

    return self.BaseClass.PreDrop( self )
end

function SWEP:Reload()
    if self:Clip1() == self.Primary.ClipSize or self:Ammo1() == 0 then return end
    self:SendWeaponAnim( 183 )
    self:DefaultReload( 183 )
    self:SetIronsights( false )
    self:SetZoom( false )
end

function SWEP:Holster()
    self:SetIronsights( false )
    self:SetZoom( false )

    return true
end

if CLIENT then
    local scope = surface.GetTextureID( "sprites/scope" )

    function SWEP:DrawHUD()
        if self:GetIronsights() then
            surface.SetDrawColor( 0, 0, 0, 255 )
            local x = ScrW() / 2.0
            local y = ScrH() / 2.0
            local scope_size = ScrH()
            -- crosshair
            local gap = 80
            local length = scope_size
            surface.DrawLine( x - length, y, x - gap, y )
            surface.DrawLine( x + length, y, x + gap, y )
            surface.DrawLine( x, y - length, x, y - gap )
            surface.DrawLine( x, y + length, x, y + gap )
            gap = 0
            length = 50
            surface.DrawLine( x - length, y, x - gap, y )
            surface.DrawLine( x + length, y, x + gap, y )
            surface.DrawLine( x, y - length, x, y - gap )
            surface.DrawLine( x, y + length, x, y + gap )
            -- cover edges
            local sh = scope_size / 2
            local w = ( x - sh ) + 2
            surface.DrawRect( 0, 0, w, scope_size )
            surface.DrawRect( x + sh - 2, 0, w, scope_size )
            surface.SetDrawColor( 255, 0, 0, 255 )
            surface.DrawLine( x, y, x + 1, y + 1 )
            -- scope
            surface.SetTexture( scope )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawTexturedRectRotated( x, y, scope_size, scope_size, 0 )
        else
            return self.BaseClass.DrawHUD( self )
        end
    end

    function SWEP:AdjustMouseSensitivity()
        return ( self:GetIronsights() and 0.2 ) or nil
    end
end
