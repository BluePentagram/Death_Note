

function dn_module_fall(ply,target)
	DeathNoteDeathInUse("fall",true) -- let's add it from the use list
	if target:IsPlayer() then -- Kicking the player out of Vehicle To Kill THem
		if target:InVehicle() then
			target:ExitVehicle()
		end
		if target:Health() >= target:GetMaxHealth() then
			target:SetHealth(target:GetMaxHealth())
		end
	end
	target:SetVelocity(Vector(0,0,1000))
	timer.Simple( 1, function() 
		if target:IsPlayer() then
			if target:Health() >= 1 and !GetConVar("mp_falldamage"):GetBool() and gmod.GetGamemode().FolderName != "terrortown" then
				target:SetHealth(1)
			end
		else
			timer.Simple( 1, function() 
				local d = DamageInfo()
				d:SetDamage( target:Health() )
				d:SetAttacker( ply or target )
				d:SetDamageType( DMG_GENERIC ) 
				target:TakeDamageInfo(d)
				DeathNote_RemoveEntity(ply,target)
				DeathNoteDeathInUse("fall",false) -- It's not TTT and this death can loop if people respawn to quickly so it ends here for non TTT
			end)
		end 
		target:SetVelocity(Vector(0,0,-1000))
		timer.Simple( 2, function() -- To try and kill the one that stay's withing a safe spot (Change this to Terror Town)
			if target:IsPlayer() then
				if gmod.GetGamemode().FolderName == "terrortown" then
					if target:Alive() then -- If they are alive and it's TerrorTown then let's try to kill them again, 
						timer.Create( "FallDeath", 3, 0, function()							 -- Sandbox is not needed even if they can noclip as if they repeat because they respawn before the alive check
							if target:Alive() and GetRoundState() == ROUND_ACTIVE then   -- If they are alive and the round is active try to kill them again
								Rand1 = math.random(1, 1000)
								Rand2 = math.random(1, 1000)
								target:SetVelocity(Vector(Rand1,Rand2,1000))
								timer.Simple( 1, function() target:SetVelocity(Vector(0,0,-1000)) end )
							else
								DeathNoteDeathInUse("fall",false) -- If there nolonger alive or it's the end on the round it's no longer in use (There another in use method of clearing in use deathtypes in TTT)
								if GetRoundState() != ROUND_ACTIVE then
									target:PrintMessage(HUD_PRINTTALK,"Death Note: Round not active stopping fall death.")
									timer.Remove("FallDeath")
									return
								end
								local tttmessage = "Death Note: "..target:Nick()..", Has been flung via the Death-Note."
								dn_messages(ply,target,tttmessage) -- Lets Do the fundion i made for the TTT Messages (this was in the code multiple times)
								timer.Remove("FallDeath")
							end
						end )
					else
						DeathNoteDeathInUse("fall",false)
						local tttmessage = "Death Note: "..target:Nick()..", Has been flung via the Death-Note."
						dn_messages(ply,target,tttmessage) -- Lets Do the fundion i made for the TTT Messages (this was in the code multiple times)
						timer.Remove("FallDeath")
					end
				else -- SANDBOX MESSAGES
					DeathNoteDeathInUse("fall",false) -- It's not TTT and this death can loop if people respawn to quickly so it ends here for non TTT
					if target:Alive() then
						target:PrintMessage(HUD_PRINTTALK,"Death Note: You Survived the Fall Damage Death")
						ply:PrintMessage(HUD_PRINTTALK,"Death Note: "..target:Nick().." Failed to die from the Fall Death.")
					else
						target:PrintMessage(HUD_PRINTTALK,"Death Note: Died via the Death-Note killed by '"..ply:Nick().."'")
					end
					timer.Remove("FallDeath")
				end
			end
		end )
	end )
	
end
hook.Add( "dn_module_fall", "DN fall Death", dn_module_fall )