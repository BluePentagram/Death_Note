--DeathNote TTT Weapon init


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
-- SWEP.deathtype = 1
SWEP.DN_DeathType = table.KeyFromValue( DN_DeathTypes, "heartattack" )


resource.AddFile("vgui/deathnote_vgui.vmt")
resource.AddFile("vgui/icon/ttt_deathnote_shop.vmt")

if SERVER then
	function SWEP:GetRepeating()
		local ply = self.Owner
		return IsValid(ply)
	end
end
function DNRESET()
	for k,v in pairs(player.GetAll()) do
		v.DeathNoteUse = false
		v.DN_TTT_Bypass = false
	end
	table.Empty(DN_DeathsInUse)
	if table.HasValue(DN_DeathTypes, "dissolve") then -- These can reapper if you cause a lua reload during a round 
		table.remove( DN_DeathTypes, table.KeyFromValue( DN_DeathTypes, "dissolve" ) )	
		if GetConVar("DeathNote_Debug"):GetBool() then
			print("[Death Note Debug] Module Unloaded: dissolve.") -- Prints loaded module's i only use to make sure module where loaded
		end
	end
	if table.HasValue(DN_DeathTypes, "headexplode") then -- These can reapper if you cause a lua reload during a round 
		table.remove( DN_DeathTypes, table.KeyFromValue( DN_DeathTypes, "headexplode" ) )	
		if GetConVar("DeathNote_Debug"):GetBool() then
			print("[Death Note Debug] Module Unloaded: headexplode.") -- Prints loaded module's i only use to make sure module where loaded
		end
	end
end
hook.Add( "TTTBeginRound", "deathnote_reset", DNRESET )

function SWEP:Reload()
	local ply = self.Owner
	dn_reset_debug(ply)
end

function SWEP:PrimaryAttack()

	local ply = self.Owner
	local eyetrace = ply:GetEyeTrace().Entity
	
	if self.Owner:KeyDown(IN_USE) then
		self.DN_DeathType = self.DN_DeathType + 1
		if self.DN_DeathType > #DN_DeathTypes then
			self.DN_DeathType = 1
		end
		self.Owner:PrintMessage(HUD_PRINTTALK,"Death Note: "..DN_DeathTypes[self.DN_DeathType])
	else	
		if !ply.DeathNoteUse then
			if IsValid(eyetrace) then
				if eyetrace:IsPlayer() then
					local trKill = player.GetByID(eyetrace:EntIndex())
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: You have selected, "..trKill:Nick()..", With "..DN_DeathTypes[self.DN_DeathType])
					DeathNote_Function(ply,trKill,DN_DeathTypes[self.DN_DeathType])
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