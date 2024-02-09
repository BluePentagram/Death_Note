


ulx_premissions	= {"superadmin","admin","operator","owner"}
TTT_DN_Chance	= {2,4}


--------------------------------------
-- Don't Change Under This Line!!!! --
--------------------------------------
-- Clinet commands
-- if !ConVarExists( "DeathNote_GUI_ShowNPCs") then
	CreateClientConVar( "DeathNote_GUI_ShowNPCs", 1, true, false )
-- end
-- General
if !ConVarExists( "DeathNote_ulx_installed") then
	CreateConVar( "DeathNote_ulx_installed", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_Debug") then
	CreateConVar( "DeathNote_Debug", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_Admin_Messages") then
	CreateConVar( "DeathNote_Admin_Messages", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_Update_Messege") then
	CreateConVar( "DeathNote_Update_Messege", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
-- Default
if !ConVarExists( "DeathNote_DeathTime") then
	CreateConVar( "DeathNote_DeathTime", 5, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_ExplodeTimer") then
	CreateConVar( "DeathNote_ExplodeTimer", 10, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_RemoveUnkillableEntity") then
	CreateConVar( "DeathNote_RemoveUnkillableEntity", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
-- Shared
if !ConVarExists( "DeathNote_ExplodeCountDown") then
	CreateConVar( "DeathNote_ExplodeCountDown", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_ExplodeCountDownFrom") then
	CreateConVar( "DeathNote_ExplodeCountDownFrom", 5, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end 
if !ConVarExists( "DeathNote_Heart_Attack_Fallback") then
	CreateConVar( "DeathNote_Heart_Attack_Fallback", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
-- TTT
if !ConVarExists( "DeathNote_TTT_DeathTime") then
	CreateConVar( "DeathNote_TTT_DeathTime", 15, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_AlwaysDies") then
	CreateConVar( "DeathNote_TTT_AlwaysDies", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_Explode_Time") then
	CreateConVar( "DeathNote_TTT_Explode_Time", 15, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_LoseDNOnFail") then
	CreateConVar( "DeathNote_TTT_LoseDNOnFail", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_DNLockOut") then
	CreateConVar( "DeathNote_TTT_DNLockOut", 30, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_BypassChance") then
	CreateConVar( "DeathNote_TTT_BypassChance", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_ShowKiller") then
	CreateConVar( "DeathNote_TTT_ShowKiller", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_MessageAboutDeath") then
	CreateConVar( "DeathNote_TTT_MessageAboutDeath", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
-- TTT Deathtype Disable/Enable
if !ConVarExists( "DeathNote_TTT_DT_Explode_Enable") then
	CreateConVar( "DeathNote_TTT_DT_Explode_Enable", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
-- if !ConVarExists( "DeathNote_TTT_DT_Dissolve_Enable") then -- Dissolve Does not work with TTT.
	-- CreateConVar( "DeathNote_TTT_DT_Dissolve_Enable", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
-- end
-- Commands that work for certain death types could be in the death type itself but since only the server loads them
-- the commands will not be built on the client side making it harder for admins to find the commands and change them

local version = "0.3.0"
hook.Add("Think", "DeathNote_CheckVersion", function()
	http.Fetch("https://raw.githubusercontent.com/BluePentagram/Death_Note/master/version.txt", function( body, len, headers, code)
		if GetConVar("DeathNote_Update_Messege"):GetBool() then
			local githubversion = body
				if githubversion != version then 
					if SERVER then
						print("Deathnote: Death Note addon version is different, Server Version: "..version..", Github Version: "..githubversion)
					elseif CLIENT then
						chat.AddText( Color( 25, 25, 25 ), "Deathnote: ", color_white, "Server Death Note version is different, Server Vesion: "..version..", Github Vesion: "..githubversion )
					end
				end
			end
		end)
	hook.Remove("Think", "DeathNote_CheckVersion")
end)

DeathnoteCustomDeathCode = [[
function dn_module_heartattack(ply,target) -- The function that gets called make sure you change it to the same as the last line.
	-- DeathNoteDeathInUse("heartattack",true) -- This function is not needed in a "heartattack" as this death has no timer in use so another of the same death can't override who it's going to
	if target:IsPlayer() then -- Check to see if they are a player. 
		if target:InVehicle() then -- Check to see if said player is in a vehicle.
			target:ExitVehicle() -- Kick them out if they are to kill cleanly.
		end -- The end of the vehicle check.
		local tttmessage = "Death Note: "..target:Nick().." has died via the Death Note." -- Let’s Say what the TTT one says in the message.
		dn_messages(ply,target,tttmessage) -- Let’s Do the telling the player they died, and sending the TTT Messages for the Terror Town one
		if target:Health() >= target:GetMaxHealth() then -- Let's see if their health is bigger than the game mode max hp. (if they have eaten bouncy balls or another way of getting more hp.)
			target:SetHealth(target:GetMaxHealth()) -- Let's reset there hp back to max hp if it is.
		end -- The end of the health check.
	end -- The ending for the player check. there will be another player check after the damage in case they survived somehow (ie: they had a lot of hp)
	local dmgInfo = DamageInfo() -- Now let's Creating some damage info to kill NPC Or try and kill Next Bot’s, this should not do anything if the target was a player as we returned the function ending it completely.
	dmgInfo:SetDamage( 1e8 ) -- So, we set the damage to 1e8. (100000000 damage).
	dmgInfo:SetAttacker( ply or target ) -- Set's the attacker, to show who killed the NPC/Next Bot. (if killable.)
	dmgInfo:SetDamageForce( Vector(0,0,0) ) -- To try and stop the ragdoll from flying in a random direction. (still fly’s off sometimes)
	target:TakeDamageInfo(dmgInfo) -- and deal it to our poor victim.
	DeathNote_RemoveEntity(ply,target) -- Let's call the function that remove's entities, since the code is the same across the death's it being called for easier editing.
	-- DeathNoteDeathInUse("heartattack",false) -- This function is not needed in a "heart attack" same as the 1st line of this function, but this just reallows the death to happen always be as late as possible before code stops.
	if not IsValid( target ) then return end -- if the target no longer valid let's stop here (though NPCS tend to exist for little longer after death)
	if target:IsNPC() or target:IsNextBot() or not target:Alive() then return end -- if the target still valid but is an NPC or NextBot or dead let's stop here
	target:Kill() -- Now let's kill the player off if they survived this make it so it's better logged in TTT in the event viewer.
end
hook.Add( "dn_module_heartattack", "DN Heart Attack Death", dn_module_heartattack ) -- The thing the code hooks into leave the "dn_module_" as that what the code uses and can't really be changed.
]]

concommand.Add( "DeathNote_Copy_Module", function( ply, cmd, args )
	print( "-----------------------------------------------------------------------------------" )
	print( DeathnoteCustomDeathCode )
	print( "-----------------------------------------------------------------------------------" )
	if CLIENT then SetClipboardText( DeathnoteCustomDeathCode ) end
	print( "Create a Lua file in 'lua/modules/deathnote' in LOWERCASE and paste what has been copied to your clipboard in there." )
	print( "don't forget to change the 'heartattack' in the 'dn_module_heartattack'." )
	print( "the code within is the Heart Attack, to show you an example on how create a custom death." )
end )