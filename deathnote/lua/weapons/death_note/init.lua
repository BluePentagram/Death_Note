--DeathNote Weapon init


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include( 'autorun/server/sv_deathnote.lua' )

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
-- SWEP.DN_DeathType = 1
SWEP.DN_DeathType = table.KeyFromValue( DN_DeathTypes, "heartattack" )



if SERVER then
	function SWEP:GetRepeating()
		local ply = self.Owner
		return IsValid(ply)
	end
end

function SWEP:Reload()
	local ply = self.Owner
	dn_reset_debug(ply)
end

function SWEP:PrimaryAttack()

	local ply = self.Owner
	local eyetrace = ply:GetEyeTrace().Entity
	
	if ply:KeyDown(IN_USE) then
		self.DN_DeathType = self.DN_DeathType + 1
		if self.DN_DeathType > #DN_DeathTypes then
			self.DN_DeathType = 1
		end
		ply:PrintMessage(HUD_PRINTTALK,"Death Note: Selection "..DN_DeathTypes[self.DN_DeathType])
	else	
		if !ply.DeathNoteUse then
			if IsValid(eyetrace) then
				if (eyetrace:IsPlayer() or eyetrace:IsNPC() or eyetrace:IsNextBot()) then
					local entity_target = eyetrace:GetName()
					if !eyetrace:IsPlayer() then 
						entity_target = eyetrace:GetClass() 
					end
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: You have selected, "..entity_target..", With "..DN_DeathTypes[self.DN_DeathType]) -- Nick no work with NPC's
					local trKill = player.GetByID(eyetrace:EntIndex()) 
					DeathNote_Function(ply,eyetrace,DN_DeathTypes[self.DN_DeathType])
				end
			end
		else
			ply:PrintMessage(HUD_PRINTTALK,"Death Note: Is on cooldown.")
		end
	end
end

function SWEP:SecondaryAttack()
	if ( SERVER ) then
		net.Start( "deathnote_gui" )
			net.WriteTable(DN_DeathTypes)
		net.Send( self.Owner ) 
	end
end