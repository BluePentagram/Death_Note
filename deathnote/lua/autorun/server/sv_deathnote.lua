

resource.AddFile( "resource/fonts/deathnotefont.ttf" ) -- Not needed for TTT used for the death_mark_ent which pulls from sandbox entity base
local folder = "modules/deathnote/"
DN_DeathTypes = {}
DN_DeathsInUse = {} 

if SERVER then
	util.AddNetworkString( "deathnote_gui" )
	util.AddNetworkString( "deathnote_pen" )
	
	for _, File in SortedPairs(file.Find(folder .. "/*.lua", "LUA"), true) do
		local RemoveLua = string.Split( string.lower(File), "." )
		table.insert( DN_DeathTypes, RemoveLua[1] )
		if GetConVar("DeathNote_Debug"):GetBool() then
			print("[Death Note Debug] Module Loaded: "..RemoveLua[1]..".") -- Prints loaded module's i only use to make sure module where loaded
		end
		
		AddCSLuaFile(folder .. "/" .. File)
		include(folder .. "/" .. File)
	end
		
	net.Receive( "deathnote_pen", function( len, ply )
		local plyName = tonumber(net.ReadString())
		local TheDeathType = net.ReadString()
		if TheDeathType == "3nt.F1x" then
			ply.CanUseDeathNoteEnt = false
			if GetConVar("DeathNote_Debug"):GetBool() then
				print("[Death Note Debug] Server received from "..ply:Nick()..", A dummy message to reset the entity variable on themself")
			end
			return
		end
		local target = ents.GetByIndex(plyName)
		if GetConVar("DeathNote_Debug"):GetBool() then
			local DN_PlayerNPC_Fix = target:GetClass()
			if target:IsPlayer() then DN_PlayerNPC_Fix = target:Nick() end
			print("[Death Note Debug] Server received from "..ply:Nick()..", Target "..DN_PlayerNPC_Fix..", With the death of "..TheDeathType)
		end
		DeathNote_Function(ply,target,TheDeathType)
	end )
		
	function DeathNote_Function(ply,target,TheDeathType)
		if GetConVar("DeathNote_Debug"):GetBool() then
			print("[Death Note Debug] "..ply:Nick().." Has DN? "..tostring(ply:HasWeapon("death_note"))..", TTT DN? "..tostring(ply:HasWeapon("death_note_ttt"))..", Ent? "..tostring(ply.CanUseDeathNoteEnt))
		end
		if not ply:HasWeapon("death_note") and not ply:HasWeapon("death_note_ttt") and not ply.CanUseDeathNoteEnt then -- Let's Do our Death Note Validation check to stop people from opening up a gui and sending the message
			ply:PrintMessage(HUD_PRINTTALK,"Death Note: I am sorry, I'm not allowed to do that for you, please grab my weapon and try again.")
			DeathNote_AdminMessegeExploit(ply,target)
			return -- Lets Stop the code function here
		end
		DeathNote_HA_Fallback = GetConVar("DeathNote_Heart_Attack_Fallback"):GetBool()
		ply.CanUseDeathNoteEnt = false
		if gmod.GetGamemode().FolderName != "terrortown" then -- If it's not Terror Town Do the sandbox dunction
			DeathNote_Timer = GetConVar("DeathNote_DeathTime"):GetInt()
			if !ply.DeathNoteUse then
				if IsValid( target ) then
					ply.DeathNoteUse = true
					timer.Simple( DeathNote_Timer, function()
						ply.DeathNoteUse = false
						if target:IsPlayer() then
							if not target:Alive() then
								ply:PrintMessage(HUD_PRINTTALK,"Death Note: That Person Is Already Dead")
								DeathNote_FailAdminMessege(ply,target)
								return
							end
						end
						if not IsValid( target ) then
							ply:PrintMessage(HUD_PRINTTALK,"Death Note: That NPC Is Already Dead")
							DeathNote_FailAdminMessege(ply,target)
							return
						end
							if not table.HasValue(DN_DeathsInUse, TheDeathType) then
								DeathNote_AdminMessege(ply,target,TheDeathType) -- Run the admin message before the hook to get the class on the npo
								hook.Run( "dn_module_"..TheDeathType, ply,target ) 
								return
							else
								if DeathNote_HA_Fallback then
									ply:PrintMessage(HUD_PRINTTALK,"Death Note: That death is currently in use, swapping to heart attack.")
									TheDeathType = "heartattack" -- So we can use an admin message
									DeathNote_AdminMessege(ply,target,TheDeathType)
									hook.Run( "dn_module_"..TheDeathType, ply,target )
									return
								else
									ply:PrintMessage(HUD_PRINTTALK,"Death Note: That death is currently in use, please try again later.")
									return
								end
							end
					end)
				else
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: That Person Is Already Dead")
				end
			else
				ply:PrintMessage(HUD_PRINTTALK,"Death Note: Is on cooldown.")
			end
		else -- else if it's terror town lets do that instead
			DN_TTT_DeathTime = GetConVar("DeathNote_TTT_DeathTime"):GetInt()
			DN_TTT_AlwaysDie = GetConVar("DeathNote_TTT_AlwaysDies"):GetBool()
			DN_TTT_LoseDN = GetConVar("DeathNote_TTT_LoseDNOnFail"):GetBool()
			DN_TTT_LockOut = GetConVar("DeathNote_TTT_DNLockOut"):GetInt()
			if not target:IsPlayer() then
				ply:PrintMessage(HUD_PRINTTALK,"Death Note: That is not a Player please try again.")
				return
			end
			if !ply.DeathNoteUse then
				if target:Alive() then
					ply:StripWeapon("death_note_ttt")
					ply.DeathNoteUse = true
					timer.Simple( DN_TTT_DeathTime, function()
						if DN_TTT_AlwaysDie or ply.DN_TTT_Bypass then -- Always Die
							ply.DeathNoteUse = false
							if target:Alive() then
								if ply.DN_TTT_Bypass then
									ply:PrintMessage(HUD_PRINTTALK,"Death Note: Chance system bypassed, due to failed previous attempt.")
								end
								ply.DN_TTT_Bypass = false
								DN_TTT_Hook_Run(ply,target,TheDeathType)
							else
								ply:PrintMessage(HUD_PRINTTALK,"Death Note: That Person already dead, Choose a new target.")
								DN_TTT_Regive_DN(ply,DN_TTT_LockOut)
							end
						else
							rolled = math.random(1,6)
							if table.HasValue(TTT_DN_Chance, rolled) then
								ply:PrintMessage(HUD_PRINTTALK, "DeathNote: You rolled a " .. rolled)
								if target:Alive() then
									DN_TTT_Hook_Run(ply,target,TheDeathType)
								else
									ply:PrintMessage(HUD_PRINTTALK,"Death Note: That Person Is Already Dead, You did not lose the Death Note")
									DN_TTT_Regive_DN(ply,DN_TTT_LockOut)
								end
							else
								if not DN_TTT_LoseDN then
									 DN_TTT_Regive_DN(ply,DN_TTT_LockOut)
								end
								ply:PrintMessage(HUD_PRINTTALK, "Death Note: You rolled a " .. rolled .. " And needed either a " .. table.concat(TTT_DN_Chance, " "))
							end	
							ply.DeathNoteUse = false
						end
					end)
				else
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: That Person Is Already Dead")
				end
			else
				ply:PrintMessage(HUD_PRINTTALK,"Death Note: The Death Note is in cooldown.")
			end
		end
	end
	
	function DN_TTT_Hook_Run(ply,target,TheDeathType)
		if not table.HasValue(DN_DeathsInUse, TheDeathType) then
			hook.Run( "dn_module_"..TheDeathType, ply,target ) 
			return
		else
			if DeathNote_HA_Fallback then
				ply:PrintMessage(HUD_PRINTTALK,"Death Note: That death is in use going to heart attack.")
				TheDeathType = "heartattack" -- So we can use an admin message
				hook.Run( "dn_module_"..TheDeathType, ply,target )
				return
			else
				if GetConVar("DeathNote_TTT_LoseDNOnFail"):GetBool() then
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: That death is in use, please try again, You have a free kill to claim.")
					ply.DN_TTT_Bypass = true
				else
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: That death is in use, please try your luck again.")
				end
				return
			end
		end
	end
	
	function DN_TTT_Regive_DN(ply,DN_TTT_LockOut)
	if not ply:Alive() then return end -- If there dead they can't really get the dn back can't they.
	ply:PrintMessage(HUD_PRINTTALK,"Death Note: You have lost the Death Note, it will return in "..DN_TTT_LockOut.." seconds.")
	timer.Simple( DN_TTT_LockOut, function()
		if ply:Alive() then
			ply:Give( "death_note_ttt" )
			ply:PrintMessage(HUD_PRINTTALK,"Death Note: The Death Note has returned to your red bloody hands.")
		end
	end )
	end
	
	function dn_messages(ply,target,TTTDeath)
		if gmod.GetGamemode().FolderName != "terrortown" then -- SANDBOX
			if !IsValid(target) then return end
			if target:IsPlayer() then
				target:PrintMessage(HUD_PRINTTALK,"Death Note: Died via the Death Note killed by '"..ply:Nick().."'")
			end
			return
		else -- TTT
			DN_TTT_TellKillerVar = "Death Note: Died via the Death Note killed by '"..ply:Nick().."'"
			if not GetConVar("DeathNote_TTT_ShowKiller"):GetBool() then
				DN_TTT_TellKillerVar = "Death Note: Died via the Death Note"
			end
			target:PrintMessage(HUD_PRINTTALK,DN_TTT_TellKillerVar)
			if GetConVar("DeathNote_TTT_MessageAboutDeath"):GetBool() then
				for k,v in pairs(player.GetAll()) do
					if v != target then
						v:PrintMessage(HUD_PRINTTALK,TTTDeath)
					end
				end
			end
		end
	end
	
	function dn_reset_debug(ply) -- This get's called with weapon reload's bot SandBox and TTT
		if GetConVar("DeathNote_Debug"):GetBool() and !ply.PreventDNDebugSpam then
			ply.PreventDNDebugSpam = true
			timer.Simple( 3, function() 
				ply.PreventDNDebugSpam = false
			end)
			if DeathNote_AdminCheck(ply) then
				ply:PrintMessage(HUD_PRINTTALK,"Death Note Admin: You Reset Everyone's the Death Note")
				for k,v in pairs(player.GetAll()) do
					v.DeathNoteUse = false
					v.DN_TTT_Bypass = false
					v.DeathNoteUse = false
				end
				table.Empty(DN_DeathsInUse)
			end
		end
	end
		
	function DeathNoteDeathInUse(DeathTypeToLockOut,Lock) -- let's add it into the in use
		if Lock then
			table.insert( DN_DeathsInUse, DeathTypeToLockOut )
		else
			if not table.HasValue(DN_DeathsInUse, DeathTypeToLockOut) then return end
			table.remove( DN_DeathsInUse, table.KeyFromValue( DN_DeathsInUse, DeathTypeToLockOut ) )	
		end
		if GetConVar("DeathNote_Debug"):GetBool() then
			print("-----[Death Note Debug]-----")
			print("Death's In Use Update")
			PrintTable(DN_DeathsInUse)
			print("----------------------------")
		end
	end
		
	function DeathNote_RemoveEntity(ply,target) -- The function that is called
		RemoveEntity = GetConVar("DeathNote_RemoveUnkillableEntity"):GetBool() -- Lets grab the console command
		if GetConVar("DeathNote_Debug"):GetBool() then
				print("[Death Note Debug] Should be removing entities: "..tostring(RemoveEntity))
		end
		if target:IsPlayer() then return end
		if RemoveEntity and IsValid(target) then -- lets check the console command and if they are valid
			if target:Health() >= 1 then -- since npc's around for a little bit after there death if there health is above zero that means they survived and need a fake ragdoll
				ply:PrintMessage(HUD_PRINTTALK,"Death Note: "..target:GetClass().." was unkillable by the Death Note and has been removed.") 
				DeathNote_AdminRemoveEntity(ply,target)
				local DNTargetModel = target:GetModel()
				DeathNote_Create_Ragdoll(DNTargetModel,target) -- Not doing physcics proply for ragdoll and making shovel move
				target:Remove() -- lets remove the entity
			end
		end
	end
	
	function DeathNote_Create_Ragdoll(DNTargetModel,target) -- Createing a fake clinet ragdoll if remove entity is aviable (can be in the remove entity part but got a new function for my simple sake
	if gmod.GetGamemode().FolderName == "terrortown" then return end -- Make sure it's not accidenlty run in Terrortown as the entity does not work
		local Pos = target:GetPos()
		local Ang = target:GetAngles()
		local DN_Ragdoll = ents.Create( "ent_death_mark" )
		if ( !IsValid( DN_Ragdoll ) ) then return end 
		DN_Ragdoll:SetPos( Pos )
		DN_Ragdoll:SetAngles( Ang )
		DN_Ragdoll:SetOwner(target)
		DN_Ragdoll:SetModel(DNTargetModel)
		DN_Ragdoll:Spawn()
	end
	
	hook.Add( "PlayerDeath", "DeathNoteStopEntityUsage", function( ply ) -- This Hook Fixes up if you die while the Entity version was opened prevent a stored killed
		if ply.CanUseDeathNoteEnt then
			ply.CanUseDeathNoteEnt = false
		end
	end )
end


--------------- ADMIN MESSEGES ---------------
function DeathNote_AdminCheck(ply)
	if GetConVar("DeathNote_ulx_installed"):GetBool() then
		if table.HasValue(ulx_premissions, ply:GetNWString("usergroup")) then
			return true
		end
	else
		if ply:IsAdmin() then
			return true
		end
	end
	return false
end

function DeathNote_AdminMessege(ply,target,TheDeathType)
	if GetConVar("DeathNote_Admin_Messages"):GetBool() then
		for k,v in pairs( player.GetAll() ) do
			if DeathNote_AdminCheck(v) then
				if target:IsPlayer() then
					v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: "..ply:Nick().." has used the Death Note on "..target:Nick()..". ("..TheDeathType..")")
				else
					v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: "..ply:Nick().." has used the Death Note on "..target:GetClass()..". ("..TheDeathType..")")
				end
			end
		end
	else return false end
end

function DeathNote_FailAdminMessege(ply,target)
	if GetConVar("DeathNote_Admin_Messages"):GetBool() then
		for k,v in pairs( player.GetAll() ) do
			if DeathNote_AdminCheck(v) then
				if target:IsPlayer() then
						v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: "..ply:Nick().." tried the Death Note on "..target:Nick().." but failed")
					else
						v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: "..ply:Nick().." has used the Death Note on an NPC but failed")
				end
			end
		end
	else return false end
end

function DeathNote_AdminMessegeExploit(ply,target)
	if GetConVar("DeathNote_Admin_Messages"):GetBool() then
		for k,v in pairs( player.GetAll() ) do
			if DeathNote_AdminCheck(v) then
				if target:IsPlayer() then
					v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: "..ply:Nick()..", Had nearly exploited the Death Note on "..target:Nick()..". (died while useing the DN or Trying to use the function without a Death Note)")
				else
					v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: "..ply:Nick()..", Had nearly exploited the Death Note on an NPC. (died while useing the DN or Trying to use the function without a Death Note)")
				end
			end
		end
	else return false end
end

function DeathNote_AdminRemoveEntity(ply,target)
	if GetConVar("DeathNote_Admin_Messages"):GetBool() then
		for k,v in pairs( player.GetAll() ) do
			if DeathNote_AdminCheck(v) then
				v:PrintMessage(HUD_PRINTTALK,"Death Note Admin: '"..target:GetClass().."' was unkillable and has been removed. Done By '"..ply:Nick().."'")
			end
		end
	else return false end
end