if ( SERVER ) then
        AddCSLuaFile( "shared.lua" )	
        resource.AddFile("materials/vgui/ttt/icon_rpg.png")		
	resource.AddWorkshop( "712005457" )
end

if ( CLIENT ) then
   SWEP.PrintName = "Melon Launcher"
   SWEP.Slot = 7
   SWEP.SlotPos	= 0
   
   SWEP.EquipMenuData = {
      type="Weapon",
      model="models/weapons/w_eq_fraggrenade_thrown.mdl",
      name="RPG",
      desc=[[
	  Left-Click:
	  Shoot Melon
	  
	  Right-Click:
	  Say something...]]
   };

   SWEP.Icon = "vgui/ttt/icon_rpg"       
end

SWEP.Base                               = "weapon_tttbase"
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true
SWEP.Kind = WEAPON_EQUIP
SWEP.CustomSecondaryAmmo = false
SWEP.HoldType = "rpg"
SWEP.DrawCrosshair              = false
SWEP.ViewModel                  = "models/weapons/v_rpg.mdl"
SWEP.WorldModel                 = "models/weapons/w_rocket_launcher.mdl"
SWEP.Primary.Reload			= Sound( "common/null.wav" )
SWEP.Primary.Sound			= Sound( "Weapon_RPG.Single" )
SWEP.Primary.SoundNPC		= Sound( "Weapon_RPG.NPC_Single" )
SWEP.Primary.Empty			= Sound( "Weapon_SMG1.Empty" )

function SWEP:Deploy()  
   self:EmitSound("items/battery_pickup.wav")
end

function SWEP:Initialize()

        self:SetWeaponHoldType( self.HoldType )
        
end

SWEP.RunArmAngle  = Angle( 60, 00, 0 )
SWEP.RunArmOffset = Vector( 50, 0, -10 )
SWEP.ViewModelFlip   = false
SWEP.ViewModelFOV  = 55

function SWEP:ShouldDropOnDie()
	return true
end

SWEP.Primary.ClipSize           = 6
SWEP.Primary.DefaultClip        = 1
SWEP.Primary.Automatic          = false
SWEP.Primary.Ammo                       = "1"
SWEP.AllowDrop                  = true

SWEP.Secondary.ClipSize         = 3
SWEP.Secondary.DefaultClip      = 3
SWEP.Secondary.Automatic        = false
SWEP.Secondary.Ammo                     = "none"
SWEP.AllowDrop = true


function SWEP:PrimaryAttack()


        self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
        if not self:CanPrimaryAttack() then return end  
        if ( self.Owner:GetAmmoCount( "RPG_Round" ) < 0 ) then return end
        self.Weapon:EmitSound("Weapon_RPG.Single")
        self.Weapon:SetNextPrimaryFire(CurTime() + 1)
        self.Weapon:SetNextSecondaryFire(CurTime() + 1)
        self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        self.Weapon:TakePrimaryAmmo(1)

        if ( SERVER ) then
        
        
                local grenade = ents.Create( "rpg_rocket" )
                        grenade:SetPos( self.Owner:GetShootPos() )
                        grenade:SetOwner( self.Owner )
                        grenade.FlyAngle = self.Owner:GetAimVector():Angle()
                grenade:Spawn()
                
                local phys = grenade:GetPhysicsObject()
                if (phys:IsValid()) then
                        phys:SetVelocity( self.Owner:GetAimVector() * 2000 )
                end
              
                
        end


end

function SWEP:SecondaryAttack()	
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 3 )
	
	local TauntSound = table.Random( { Sound("vo/Streetwar/sniper/male01/c17_09_help02.wav"), Sound("vo/npc/male01/overhere01.wav") } )


	self.Weapon:EmitSound( TauntSound )
	
	if (!SERVER) then return end
	
	self.Weapon:EmitSound( TauntSound )


end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
end	
