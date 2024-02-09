

function dn_module_prematureburial(ply,target) 
	if target:IsPlayer() then -- Kicking the player out of Vehicle To Kill THem
		if target:InVehicle() then
			target:ExitVehicle()
		end
	end
	local Pos = target:GetPos()
	DeathNoteDeathInUse("prematureburial",true) -- let's add it from the use list
	local DN_Burial_Count = 0
		if target:Health() >= target:GetMaxHealth() then
			target:SetHealth(target:GetMaxHealth())
		end
	if target:IsPlayer() then 
		target:Freeze( true ) -- Move freeze up to see if they can be buried while frozen
	end
	timer.Create( "BuryTime", 1, 16, function()
		DN_Burial_Count = DN_Burial_Count + 1
		if not IsValid(target) then 
			DeathNoteDeathInUse("prematureburial",false) 
			timer.Remove("BuryTime") 
			return 
		end -- If victim no longer exiscts stop the timer and function
		if DN_Burial_Count <= 4 then -- Count To Bury the victim
			target:SetPos(target:GetPos() + Vector(0,0,-20))
			if DN_Burial_Count == 4 then
				target:SetPos(target:GetPos() + Vector(0,0,-1500)) -- LET REALLY MOVE THEM DOWN (no more proplems with multiple floors and what not	
				PreBuryGrave(Pos,target) 
			end
		elseif DN_Burial_Count == 16 then -- Outright Kill the victim and kill the npc after a while
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage( 1e8 )
			dmgInfo:SetAttacker( ply or target )
			-- dmgInfo:SetDamageType( DMG_GENERIC ) 
			dmgInfo:SetDamageForce( Vector(0,0,0) ) 
			target:TakeDamageInfo(dmgInfo)
			dn_bury_end(ply,target)
			if IsValid(target) then -- Sorry people "RemoveEntity" is not used in the death to prevent NPC from getting stuck underground and will always be removed
				target:Remove()
			end
			return
		end
		if DN_Burial_Count >= 5 then -- Deal damage while underground
			if target:IsPlayer()then
				if target:Alive() then
					if target:Health() <= 10 then
						target:Kill()
						dn_bury_end(ply,target)
						return
					else
						target:SetHealth(target:Health() - 10)
					end
				else
					dn_bury_end(ply,target)
				end		
			end
		end
	end)
end
hook.Add( "dn_module_prematureburial", "DN Premature Bury Death", dn_module_prematureburial )

function dn_bury_end(ply,target)
	if target:IsPlayer() then 
		target:Freeze( false ) 
		local tttmessage = "Death Note: "..target:Nick().." has been buried alive!"
		dn_messages(ply,target,tttmessage)
	end -- Unfreeze the person
	DeathNoteDeathInUse("prematureburial",false) -- let's remove it from the use list
	timer.Remove("BuryTime")
end

function PreBuryGrave(Pos,target)-- Will have to fix the text with the npcs
	if gmod.GetGamemode().FolderName == "terrortown" then return end -- The Entity does noe work as it calls from base gmod entity that not loaded within terror town
	Grave_Model = "models/props_c17/gravestone004a.mdl"
	Shovel_Model = "models/props_junk/shovel01a.mdl"
	local Ang = target:GetAngles()
	local Grave = ents.Create( "ent_death_mark" )
	if ( !IsValid( Grave ) ) then return end 
	Grave:SetPos( Pos + Ang:Up() * 17 )
	Grave:SetAngles( Ang )
	Grave:SetOwner(target)
	Grave:SetModel(Grave_Model)
	Grave:Spawn()
	local Shovel = ents.Create( "ent_death_mark" )
	if ( !IsValid( Shovel ) ) then return end
	Shovel:SetPos( Pos + Ang:Up() * 23 + Ang:Forward() * -8 )
	Ang:RotateAroundAxis(Ang:Right(), -20)
	Ang:RotateAroundAxis(Ang:Forward(), 8)
	Ang:RotateAroundAxis(Ang:Up(), 180)
	Shovel:SetAngles( Ang )
	Shovel:SetOwner(target)
	Shovel:SetModel(Shovel_Model)
	Shovel:Spawn()
end