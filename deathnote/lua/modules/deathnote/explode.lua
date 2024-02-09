

function dn_module_explode(ply,target)
	DeathNoteDeathInUse("explode",true) -- let's add it from the use list
	local TerrorTownCheck = gmod.GetGamemode().FolderName == "terrortown" -- Let's make a terror town check
	DN_ExplodeTimer = GetConVar("DeathNote_ExplodeTimer"):GetInt() -- Lets Grab the explsion Time need to before terror town so terror town can replace it
	if TerrorTownCheck then -- Let's See if it's Terror Town
		if not GetConVar("DeathNote_TTT_DT_Explode_Enable"):GetBool() then -- Let's check if Explode been disabled in terror town
			ply:PrintMessage(HUD_PRINTTALK,"Death Note: Explode not enabled in TTT Going to Heart Attack.") -- Let's tell the person it's disabled and going to heart attack
			hook.Run( "dn_module_heartattack", ply,target ) -- lets call the heart attack function
			return -- Where done here lets stop the code here
		end
		DN_ExplodeTimer = GetConVar("DeathNote_TTT_Explode_Time"):GetInt() -- Let overide the explsion time from the sandbox one to the terror town one
	end
	DN_Explode_DoCountDown = GetConVar("DeathNote_ExplodeCountDown"):GetBool() -- Lets Grab the explsion Time need to before terror town so terror town can replace it
	DN_Explode_CountDownTime = GetConVar("DeathNote_ExplodeCountDownFrom"):GetInt() -- Lets Grab the explsion Time need to before terror town so terror town can replace it

	for k,v in pairs(player.GetAll()) do -- lets grabe everyone and tell them how long the victim is gonna last for
		if target:IsPlayer() then
			v:PrintMessage(HUD_PRINTTALK,"Deathnote: "..target:Nick().." Has been set to explode in "..DN_ExplodeTimer.." seconds.")
		else
			v:PrintMessage(HUD_PRINTTALK,"Deathnote: "..target:GetClass().." Has been set to explode in "..DN_ExplodeTimer.." seconds.")
		end
	end
	-- DN_ExplodeTimer = DN_ExplodeTimer -- should see if it works my useing normal explode timer
	timer.Create( "Expolde_Countdown", 1, 0, function()
		if DN_Explode_DoCountDown then
			if DN_ExplodeTimer <= DN_Explode_CountDownTime then
				for k,v in pairs(player.GetAll()) do
					if target:IsPlayer() then
						v:PrintMessage(HUD_PRINTTALK,"Death Note: "..target:Nick().." Will explode in "..DN_ExplodeTimer.." seconds!!!!")
					else
						v:PrintMessage(HUD_PRINTTALK,"Death Note: "..target:GetClass().." Will explode in "..DN_ExplodeTimer.." seconds!!!!")
					end
				end
			end
		end
		if target:IsPlayer() then -- Player Check / alive
			if !target:Alive() then
				for k,v in pairs(player.GetAll()) do
					v:PrintMessage(HUD_PRINTTALK,"Death Note: "..target:Nick().." has died before he exploded.")
				end
				if TerrorTownCheck and ply:Alive() then -- Return the Death Note if target didn't die from the explosion
					ply:Give( "death_note_ttt" )
					ply:PrintMessage(HUD_PRINTTALK,"Death Note: The Death Note has returned to your red bloody hands.")
				end 
				DeathNoteDeathInUse("explode",false) -- let's remove it from the use list
				timer.Remove("Expolde_Countdown")
				return
			end
		end
		
		if !IsValid( target ) then -- Valid check for NPC's incased removed
			for k,v in pairs(player.GetAll()) do
				v:PrintMessage(HUD_PRINTTALK,"Death Note: A NPC has died or has been removed before he exploded.")
			end
			DeathNoteDeathInUse("explode",false) -- let's remove it from the use list
			timer.Remove("Expolde_Countdown")
			return
		end
		
		if DN_ExplodeTimer <= 0 then
			timer.Remove("Expolde_Countdown")
			local d = DamageInfo()
			d:SetDamage( target:Health()-1 )
			d:SetAttacker( target )
			d:SetDamageType( DMG_BLAST ) 
			target:TakeDamageInfo(d)
			local DN_Explosion = ents.Create("env_explosion")
			DN_Explosion:SetPos(target:GetPos())
	
			DN_Explosion:SetKeyValue("iMagnitude", 100)
			DN_Explosion:Fire("Explode", 0, 0)
			DN_Explosion:EmitSound("BaseGrenade.Explode", 100, 100)
			DN_Explosion:Spawn()
			d:SetDamage( target:Health())
			d:SetDamageType( DMG_GENERIC ) 
			target:TakeDamageInfo(d)
			DeathNote_RemoveEntity(ply,target)
			DeathNoteDeathInUse("explode",false)
			if target:IsPlayer() then 
				local tttmessage = "Death Note: "..target:Nick().." has died via the Death Note."
			end
			dn_messages(ply,target,tttmessage)
			return
		end
		DN_ExplodeTimer = DN_ExplodeTimer - 1
	end)
end
hook.Add( "dn_module_explode", "DN Explode Death", dn_module_explode )