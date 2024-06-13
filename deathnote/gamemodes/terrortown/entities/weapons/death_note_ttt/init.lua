


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
-- SWEP.deathtype = 1
-- SWEP.DN_DeathType = table.KeyFromValue( DN_DeathTypes, "heartattack" )
SWEP.DN_DeathType = DN_DeathTypes["heartattack"]


resource.AddFile("vgui/deathnote_vgui.vmt")
resource.AddFile("vgui/icon/ttt_deathnote_shop.vmt")

if SERVER then
	function SWEP:GetRepeating()
		local ply = self.Owner
		return IsValid(ply)
	end
end

function DN_RESET_ON_NEW_ROUND() -- Let's unload modules here to prevent a weapon swap to a disabled swap
	dn_reset_tables() -- Go to the reset function in sv_deathnote.lua
	DN_TTT_Swap_Availabilty("Explode") -- so multiple death modules can be done with less lines of code
	DN_TTT_Swap_Availabilty("Dissolve")

	if DN_DeathTypes["headexplode"] then
		DN_DeathTypes["headexplode"] = nil	
		if GetConVar("DeathNote_Debug"):GetBool() then
			print("[Death Note Debug] Module Unloaded: Head Explode.") 
		end
	end
end
hook.Add( "TTTBeginRound", "deathnote_reset", DN_RESET_ON_NEW_ROUND )

function SWEP:Reload()
	local ply = self.Owner
	dn_reset_debug(ply)
end

function SWEP:PrimaryAttack()

	local ply = self.Owner
	local eyetrace = ply:GetEyeTrace().Entity
	
	if self.Owner:KeyDown(IN_USE) then
		self.DN_DeathType = next( DN_DeathTypes,self.DN_DeathType )
		if self.DN_DeathType == nil then -- if the table is at the end it will give a nil and we will need to redo to restart the table
			self.DN_DeathType = next( DN_DeathTypes,self.DN_DeathType )
		end
		ply:PrintMessage(HUD_PRINTTALK,"Death Note: Selection "..self.DN_DeathType)
	else	
		if !DN_DeathNoteUse[ply] then
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

function DN_TTT_Swap_Availabilty(deathtype)
	if GetConVar("DeathNote_TTT_DT_"..deathtype.."_Enable"):GetBool() then
		local ldeathtype = string.lower(deathtype)
		if not DN_DeathTypes[ldeathtype] then
			DN_DeathTypes[ldeathtype] = ldeathtype
			if GetConVar("DeathNote_Debug"):GetBool() then
				print("[Death Note Debug] Module Loaded: "..deathtype..".") -- Prints loaded module's i only use to make sure module where loaded
			end
		end
	else
		local ldeathtype = string.lower(deathtype)
		if DN_DeathTypes[ldeathtype] then
			DN_DeathTypes[ldeathtype] = nil
			if GetConVar("DeathNote_Debug"):GetBool() then
				print("[Death Note Debug] Module Unloaded: "..deathtype..".") -- Prints loaded module's i only use to make sure module where loaded
			end
		end
	end
end