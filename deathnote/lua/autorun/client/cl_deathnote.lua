

function deathnote_sandbox_names(DeathNotePlayerList) -- Sandbox version of adding names into the list as well as NPC, 
	for k,v in pairs(player.GetAll()) do -- Let's first grab all the players
		DeathNotePlayerList:AddLine(v:Name(),v:EntIndex()) -- Add lines for player's
	end -- and end it to start the one for npc's doing it this why makes sure the players are on the top of the list
	if GetConVar("DeathNote_GUI_ShowNPCs"):GetBool() then
		if GetConVar("DeathNote_GUI_FastNPCsNames"):GetBool() then -- Getting there class as a name only removing and adding a fance npc titles and useing class instead most modded npcs are citizens though
			for k,v in pairs(ents.GetAll()) do -- let's grab every entity
				if ( v:IsNPC() or v:IsNextBot() ) then -- See if entity is a a NPC or NextBot
					local npc_type = deathnote_npc_type_fix(v)
					local npc_name = deathnote_npc_classname(v)
					npc_name = npc_type..npc_name -- Add the fancy type and stiped name again
					DeathNotePlayerList:AddLine(npc_name,v:EntIndex()) -- Then add lines for NPC's/NextBots
				end
			end
		else -- Now let's if the player wants to get there nice fancy name
			deathnote_npc_nicenamecache() -- Let's create the tables for the bad habbit table checking.
			for k,v in pairs(ents.GetAll()) do -- let's grab every entity
				if ( v:IsNPC() or v:IsNextBot() ) then -- See if entity is a a NPC or NextBot
					local npc_name = "???" -- Lets set the tempory name to nothing
					local npc_type = deathnote_npc_type_fix(v)
					if table.HasValue( DN_NPCListCacheModel, v:GetModel() ) then -- Now let's check the cached model table for the npcs model
						npc_name = DN_NPCListCacheModelName[table.KeyFromValue( DN_NPCListCacheModel, v:GetModel() )] -- now lets grab the name from the key of the cached model
					elseif table.HasValue( DN_NPCListCacheClass, v:GetClass() ) then -- if they have no name let's check the the entity class with the class cached table
						npc_name = DN_NPCListCacheClassName[table.KeyFromValue( DN_NPCListCacheClass, v:GetClass() )] -- now lets grab the name from the key of the cached class
					else
						table.Empty(DN_NPCListCacheModel)
						table.Empty(DN_NPCListCacheClass)
						if GetConVar("DeathNote_Debug"):GetBool() then -- Debug Messages
							print("[Death Note Debug] Cache error forceing reset on next GUI open.")
						end
						npc_name = deathnote_npc_classname(v)
					end
					npc_name = npc_type..npc_name -- let's add the npc type to the fancy name
					DeathNotePlayerList:AddLine(npc_name,v:EntIndex()) -- Then add lines for NPC's/NextBots
				end
			end
		end
	end
end

function deathnote_npc_type_fix(npc)
	if npc:IsNPC() then -- If they are a base NPC
		return "[NPC] "	-- lets return the string for NPC
	elseif npc:IsNextBot() then -- If they are a NextBot
		return "[NextBot] " -- lets return the string for NextBot
	elseif npc:IsPlayer() then -- If it's a Player? this should never trigger.
		return "[Player?] " -- -- return Player class? but how did this happen?
	end
	return "[???] " -- If it's neither let's return question marks
end

function deathnote_npc_classname(npc) -- Use for Fast Class and fallback for fancy name one done
	local npc_name = npc:GetClass()
	if string.StartsWith(npc:GetClass(), "npc_") then -- If they have npc_
		npc_name = string.TrimLeft(npc:GetClass(), "npc_") -- let's remove it
		npc_name = string.SetChar(npc_name, 1, string.upper( string.sub( npc_name, 1, 1 ))) -- let's capitalize the first character.
	end
	return npc_name
end

DN_NPCListCacheModel = {} -- let's create the cache models
DN_NPCListCacheModelName = {} -- let's create the cache name for the models
DN_NPCListCacheClass = {} -- let's create the cache class
DN_NPCListCacheClassName = {} -- let's create the cache name for the class

function deathnote_npc_nicenamecache()
	-- let's check if any of the tables are empty if one is, remake it.
	if table.IsEmpty( DN_NPCListCacheModel ) or table.IsEmpty( DN_NPCListCacheModelName ) or table.IsEmpty( DN_NPCListCacheClass ) or table.IsEmpty( DN_NPCListCacheClassName ) then 
		table.Empty(DN_NPCListCacheModel) -- empty the tables incase there aleady data in there
		table.Empty(DN_NPCListCacheModelName) -- empty the tables incase there aleady data in there
		table.Empty(DN_NPCListCacheClass) -- empty the tables incase there aleady data in there
		table.Empty(DN_NPCListCacheClassName) -- empty the tables incase there aleady data in there
		local DN_NPCList = list.Get( "NPC" ) -- let's gtab the npc list
		for k, v in pairs( DN_NPCList ) do -- let's go though the list 
			if v.Model != nil then -- if it has a model 
				table.insert( DN_NPCListCacheModel, string.lower(v.Model) ) --let's the model to cached models and lower case at the same time incase someone uppercased the string model
				table.insert( DN_NPCListCacheModelName, v.Name ) -- and the name to the cached models name, they end up having the same key so there "linked"
			else
				table.insert( DN_NPCListCacheClass, v.Class ) -- again but class
				if v.Class != "npc_citizen" then -- if it's not a Citizen
					table.insert( DN_NPCListCacheClassName, v.Name ) -- use the name of the class
				else
					table.insert( DN_NPCListCacheClassName, "Citizen" ) -- if it's a citizen lets call them that instead of Medic
				end
			end
		end
		if GetConVar("DeathNote_Debug"):GetBool() then -- Debug Messages
			print("[Death Note Debug] NPC's tables created and cached.")
		end
	else
		if GetConVar("DeathNote_Debug"):GetBool() then-- Debug Messages for already cached
			print("[Death Note Debug] NPC's tables already cached.")
		end
	end
end

function deathnote_ttt_names(DeathNotePlayerList) -- TTT Version of only adding names no NPC's and hideing traitor roles (not coded the great for TTT2 use link from below)
	if GetRoundState() == ROUND_ACTIVE then -- Only work if round is in the active state
		for k,v in pairs(player.GetAll()) do -- Grab all the players
			if v != LocalPlayer() then
				FixNoRole = v:GetRoleString()  -- Get all there roles
				if string.lower(v:GetRoleString()) == "no role" then FixNoRole = "Innocent" end -- A Simple TTT2 Not need for the original ttt, for better one use: https://steamcommunity.com/sharedfiles/filedetails/?id=3118796974
				Name = string.Left(FixNoRole,1).." - "..v:Nick() -- Grab the first letter of the person's role
				local hidetraitor = v:GetRole() != ROLE_TRAITOR -- Check if they are not a traitor for the if statement below
				local alive = v:Alive() or v:Team() != TEAM_SPEC -- grab if they are alive or not in spectator team (usefull for the ghost deathmatch addons for ttt)
				if hidetraitor and alive then -- if they are not a tratior and alive or not in team soec
					DeathNotePlayerList:AddLine(Name,v:EntIndex()) -- Add the lines to the Death Note.
				end
			end
		end
	end
end

function deathnote_gui(DN_DeathTypes) 

	TargetPlayer = "?"
	TargetDeathType = "?" -- Let's give a bad death type so that you can select heart attack and if they don't set one lets just make it heart attack when it gets sent if it was not changed

	CBlack = Color( 25, 25, 25 )
	CGrey = Color( 150, 150, 150 )
	CWhite = Color( 255, 255, 255 )
	
	
	local DeathNote = vgui.Create( "DFrame" )
	DeathNote:SetSize( 400, 619 )
	DeathNote:Center()
	DeathNote:SetTitle( "" )
	DeathNote:SetVisible( true )
	DeathNote:SetBackgroundBlur( true )
	DeathNote:SetDraggable( false )
	-- DeathNote:ShowCloseButton( true )
	DeathNote:ShowCloseButton( false )
	DeathNote:MakePopup()
	
	DeathNote.Paint = function()
		tex = surface.GetTextureID( "vgui/deathnote_vgui"  )
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(0, 0, 400, 600)
	end
	
	local DNCloseButten = vgui.Create( "DButton" ) -- Close button was moved up to allow the butten to work on client draw error just in case
	DNCloseButten:SetParent( DeathNote ) -- Set parent to our "DermaPanel"
	DNCloseButten:SetText( "" )
	DNCloseButten:SetPos( 253, 484 )
	DNCloseButten:SetSize( 114, 60 )
	DNCloseButten.Paint = function() end
	DNCloseButten.DoClick = function()
		DeathNote:Close()
		net.Start( "deathnote_pen" ) -- Send a dummy message to the server ro remove the abilty to use the entity deathnote as it varrible can persist though death untill the next use.
			net.WriteString("?")
			net.WriteString("3nt.F1x") -- just some stange charters for the deathtype to check for the dummy message leave as is (as this should be numbers)
		net.SendToServer()
	end
	
	local DeathNotePlayerList = vgui.Create("DListView")
	DeathNotePlayerList:SetParent(DeathNote)
	DeathNotePlayerList:SetPos(38, 150)
	DeathNotePlayerList:SetSize(114, 316)
	DeathNotePlayerList:SetMultiSelect(false)
	DeathNotePlayerList:AddColumn("Name")
	DeathNotePlayerList:SelectFirstItem()
	if gmod.GetGamemode().FolderName == "terrortown" then -- a check to see to get the TTT or Sandbox list of names
		deathnote_ttt_names(DeathNotePlayerList) -- Grab the TTT one	
	else
		deathnote_sandbox_names(DeathNotePlayerList) -- Grab the Sandbox one
	end
	DeathNotePlayerList.OnRowSelected = function( panel, rowIndex, row )
		if row:GetValue(2) != TargetPlayer then -- to stop mulptile printing of selected players
			if not GetConVar("DeathNote_GUI_FastNPCsNames"):GetBool() then -- Fancy names tend to be long so let's print the nbame to the chat as well.
				local Target = ents.GetByIndex(row:GetValue(2))
				local TargetType = "???"
				if Target:IsPlayer() then
					TargetType = "Player"
				elseif Target:IsNPC() or Target:IsNextBot() then
					TargetType = "NPC"
				end
				chat.AddText( Color( 25, 25, 25 ), "Death Note: ", CGrey, row:GetValue(1), CWhite," "..TargetType.." Selected" )
			end
			TargetPlayer = row:GetValue(2)
			TargetPlayerName = row:GetValue(1)
		end
	end
	/*DeathNotePlayerList.OnClickLine = function(parent, line, isselected) -- OLD WAY
		-- if line:GetValue(2) != TargetPlayer then -- to stop mulptile printing of selected players
			-- chat.AddText( Color( 25, 25, 25 ), "Death Note: ", CGrey, line:GetValue(1), CWhite," Player Selected" )
			-- TargetPlayer = line:GetValue(2)
			-- TargetPlayerName = line:GetValue(1)
		-- end
	-- end*/
	DeathNotePlayerList.Paint = function() end
	
	local DeathType = vgui.Create("DListView")
	DeathType:SetParent(DeathNote)
	DeathType:SetPos(253, 150)
	DeathType:SetSize(116, 318)
	DeathType:SetMultiSelect(false)
	DeathType:AddColumn("Death Type") -- Add column
	for i = 1 , #DN_DeathTypes do 
			DeathType:AddLine(DN_DeathTypes[i])
	end 
	DeathType:SortByColumn( 1 )
	-- DeathType:SelectItem("heartattack")
	DeathType.Paint = function() end
	DeathType.OnRowSelected = function( panel, rowIndex, row )
		if row:GetValue(1) != TargetDeathType then-- to stop mulptile printing of selected death types
			-- chat.AddText( Color( 25, 25, 25 ), "Death Note: ", CGrey, row:GetValue(1), CWhite," Death Selected" )
			TargetDeathType = row:GetValue(1)
		end
	end
	/*DeathType.OnClickLine = function(parent, line, isselected) -- OLD WAY
		if line:GetValue(1) != TargetDeathType then-- to stop mulptile printing of selected death types
			chat.AddText( Color( 25, 25, 25 ), "Death Note: ", CGrey, line:GetValue(1), CWhite," Death Selected" )
			TargetDeathType = line:GetValue(1)
		end
	end*/
	
	local DNWrite = vgui.Create( "DButton" )
	DNWrite:SetParent( DeathNote ) -- Set parent to our "DermaPanel"
	DNWrite:SetText( "" )
	DNWrite:SetPos( 38, 484 )
	DNWrite:SetSize( 114, 60 )
	DNWrite.Paint = function() end
	DNWrite.DoClick = function()
		if TargetPlayer != "?" then
			if TargetDeathType == "?" then TargetDeathType = "heartattack" end -- let's fix the death type if they don't selected one
			DeathNote:Close()
			net.Start( "deathnote_pen" )
				net.WriteString(TargetPlayer)
				net.WriteString(TargetDeathType)
			net.SendToServer()
				chat.AddText( CBlack, "Death Note: ", CWhite, "You have selected, ", CGrey, TargetPlayerName, CWhite,", With ", CGrey, TargetDeathType )
		else
			chat.AddText( CBlack, "Death Note: ", CWhite, "Please choose a Target" )
		end
	end
	
	local DNCheck = vgui.Create( "DButton" ) --Easter Egg in GUI
	DNCheck:SetParent( DeathNote ) -- Set parent to our "DermaPanel"
	DNCheck:SetText( "" )
	DNCheck:SetPos( 260, 22 )
	DNCheck:SetSize( 40, 20 )
	DNCheck.Paint = function() end
	DNCheck.DoClick = function()
		for k,v in pairs(player.GetAll()) do --All this does is put some text in the chat if the 2 creators are on the server
			if v:SteamID64() == "76561198025795415" then chat.AddText( CBlack, "Death Note: ", Color( 0, 100, 255 ), "Blue-Pentagram", CWhite, " is on this server." ) end
			if v:SteamID64() == "76561198055281421" then chat.AddText( CBlack, "Death Note: ", CWhite, v:Nick().." AKA 'TheRowan' is on this server." ) end
		end -- This is a free to use code you may edit the code how ever you want but keep the steam ids and message the same please.
	end

end

net.Receive( "deathnote_gui", function( len, pl )
	DN_DeathTypes = net.ReadTable()
	if gmod.GetGamemode().FolderName == "terrortown" then
		if not GetConVar("DeathNote_TTT_DT_Explode_Enable"):GetBool() then 
			DeathNote_Remove_TTT_Disabled_Death_Types("explode")
		end
	end
	deathnote_gui(DN_DeathTypes)
end )

function DeathNote_Remove_TTT_Disabled_Death_Types(DN_Neater_Menu) -- This was made due to fact i have a disable for dissolve for TTT, that was before it was tested in TTT
	if not table.HasValue(DN_DeathTypes, DN_Neater_Menu) then return end
	table.remove( DN_DeathTypes, table.KeyFromValue( DN_DeathTypes, DN_Neater_Menu ) )	
end
	
-- Below Not Requied for TTT at all
hook.Add( "PopulateToolMenu", "deathnote_q_utilities_settings", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Death Note", "Death_Note_Q_General", "Settings", "", "", function( panel )
		panel:Clear()
		panel:Help("---[Client]---")
		panel:CheckBox( "Show NPC's in list", "DeathNote_GUI_ShowNPCs", 0, 1 )
		panel:CheckBox( "Fast NPC's Names in list", "DeathNote_GUI_FastNPCsNames", 0, 1 )
		panel:Help("---[Server]---")
		panel:Help("Note: Dedicated Server's will need to RCON for changes to work correctly.")
		panel:Help("[General]")
		panel:CheckBox( "Debugging (admin resetting/console messages)", "DeathNote_Debug", 0, 1 )
		panel:CheckBox( "Admin Messages", "DeathNote_Admin_Messages", 0, 1 )
		panel:CheckBox( "Use ULX Admin Options", "DeathNote_ulx_installed", 0, 1 )
		panel:CheckBox( "Version Checking", "DeathNote_Update_Messege", 0, 1 )
		panel:Help("------------------------------------------------")
		panel:Help("[Sandbox]")
		panel:CheckBox( "Remove Unkillable Entitys", "DeathNote_RemoveUnkillableEntity", 0, 1 )
		panel:NumSlider( "Timer For Death", "DeathNote_DeathTime", 0, 60,false )
		panel:NumSlider( "Explosion Timer", "DeathNote_ExplodeTimer", 1, 60,false )
		panel:Help("------------------------------------------------")
		panel:Help("[Shared]")
		panel:CheckBox( "Heart Attack Fallback", "DeathNote_Heart_Attack_Fallback", 0, 1 )
		panel:CheckBox( "Explosion Countdown", "DeathNote_ExplodeCountDown", 0, 1 )
		panel:NumSlider( "Explosion Countdown", "DeathNote_ExplodeCountDownFrom", 1, 60,false )
		panel:Help("[Trouble in Terriost Town]")
		panel:CheckBox( "[TTT] Always Die", "DeathNote_TTT_AlwaysDies", 0, 1 )
		panel:NumSlider( "[TTT] Timer For Death", "DeathNote_TTT_DeathTime", 0, 60,false )
		panel:NumSlider( "[TTT] Explosion Time", "DeathNote_TTT_Explode_Time", 0, 60,false )
		panel:CheckBox( "[TTT] Lose DN on fail", "DeathNote_TTT_LoseDNOnFail", 0, 1 )
		panel:NumSlider( "[TTT] Time until return", "DeathNote_TTT_DNLockOut", 0, 60,false )
		panel:CheckBox( "[TTT] Chance Bypass", "DeathNote_TTT_BypassChance", 0, 1 )
		panel:CheckBox( "[TTT] Show Killer", "DeathNote_TTT_ShowKiller", 0, 1 )
		panel:CheckBox( "[TTT] Message About Death", "DeathNote_TTT_MessageAboutDeath", 0, 1 )
		panel:CheckBox( "[TTT] Enable Explode", "DeathNote_TTT_Explode_Enable", 0, 1 )
		-- panel:CheckBox( "[TTT] Enable Dissolve", "DeathNote_TTT_DT_Dissolve_Enable", 0, 1 ) -- Does not work with TTT

	end )
end )