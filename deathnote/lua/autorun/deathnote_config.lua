


ulx_premissions	= {"superadmin","admin","operator","owner"}
TTT_DN_Chance	= {2,4}


--------------------------------------
-- Don't Change Under This Line!!!! --
--------------------------------------

-- General
if !ConVarExists( "DeathNote_ulx_installed") then
	CreateConVar( "DeathNote_ulx_installed", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_Debug") then
	CreateConVar( "DeathNote_Debug", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
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
if !ConVarExists( "DeathNote_ExplodeCountDown") then
	CreateConVar( "DeathNote_ExplodeCountDown", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
 
-- TTT
if !ConVarExists( "DeathNote_TTT_DeathTime") then
	CreateConVar( "DeathNote_TTT_DeathTime", 15, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_AlwaysDies") then
	CreateConVar( "DeathNote_TTT_AlwaysDies", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
end
if !ConVarExists( "DeathNote_TTT_Explode_Enable") then
	CreateConVar( "DeathNote_TTT_Explode_Enable", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY} )
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

local version = "0.2.0"
-- checking version in the first tick to ensure http library is loaded (https://github.com/Facepunch/garrysmod-issues/issues/1010)
hook.Add("Think", "DeathNote_CheckVersion", function()
	http.Fetch("https://raw.githubusercontent.com/BluePentagram/Death_Note/master/version.txt", function( body, len, headers, code)
		if GetConVar("DeathNote_Update_Messege"):GetBool() then
		local githubversion = body
			if githubversion != version then 
				if SERVER then
					print("Deathnote: Your DeathNote version is different, Server Vesion: "..version..", Github Vesion: "..githubversion)
				elseif CLIENT then
					chat.AddText( Color( 25, 25, 25 ), "Deathnote: ", color_white, "Server DeathNote version is different, Server Vesion: "..version..", Github Vesion: "..githubversion )
				end
			end
		end
	end)
	hook.Remove("Think", "DeathNote_CheckVersion")
end)

DeathnoteCustomDeathCode = [[
function dn_module_customdeath(ply,TarPly,TTT)
	if !TTT then
		-- Sandbox Code Version
	else -- TTT Version
		-- TTT Code Version
	end
end
hook.Add( "dn_module_customdeath", "DN Custom Death Death", dn_module_customdeath )
]]

concommand.Add( "DeathNote_Copy_Module", function( ply, cmd, args )
	print( "-----------------------------------------------------------------------------------" )
	print( DeathnoteCustomDeathCode )
	print( "-----------------------------------------------------------------------------------" )
	if CLIENT then SetClipboardText( DeathnoteCustomDeathCode ) end
	print( "Create a Lua file in 'lua modules deathnote' in LOWERCASE and paste what has been copyed to your clipboard in there" )
	print( "don't forget to change the 'customdeath' in the 'dn_module_customdeath'." )
end )
