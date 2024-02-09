

function dn_module_ignite(ply,target)
	local TerrorTownCheck = gmod.GetGamemode().FolderName == "terrortown" -- Let's make a terror town check
	DeathNoteDeathInUse("ignite",true) -- let's add it from the use list
	if target:Health() >= target:GetMaxHealth() then
		target:SetHealth(target:GetMaxHealth())
	end
	target:Ignite( 5000000 )
	if target:IsPlayer() then
		target:PrintMessage(HUD_PRINTTALK,"Death Note: Ignited via the Death-Note.")
		if not TerrorTownCheck then
			DeathNoteDeathInUse("ignite",false) -- let's remove it from the use list
			return
		end
	else -- Some NPC Immune to fire damage this just outrights kills them after a while
		timer.Simple( 10, 
			function()
				DeathNoteDeathInUse("ignite",false) -- let's remove it from the use list
				if IsValid( target ) then
					local d = DamageInfo()
					d:SetDamage( target:Health() )
					d:SetAttacker( ply or target )
					d:SetDamageType( DMG_GENERIC ) 
					target:TakeDamageInfo(d)
					DeathNote_RemoveEntity(ply,target)
					return
				end
				return
			end)
		end
	if TerrorTownCheck then
		timer.Create( "InstaIngniteDeathCheck", 5, 0, function()
			if not target:Alive() then
				timer.Remove("InstaIngniteDeathCheck")
				local tttmessage = "Death Note: "..target:Nick().." has been burned alive!"
				dn_messages(ply,target,tttmessage)
				DeathNoteDeathInUse("ignite",false) -- let's remove it from the use list
				return
			else
				if not target:IsOnFire() then
					if target:Health() >= 50 then
						target:SetHealth(50)
					end
					target:Ignite( 5000000 )
				end
			end						
		end)
		if GetConVar("DeathNote_TTT_MessageAboutDeath"):GetBool() then
			for k,v in pairs(player.GetAll()) do
				v:PrintMessage(HUD_PRINTTALK,"Death Note: "..target:Nick()..", Ignited via the Death-Note.")
			end
		end
	end
end
hook.Add( "dn_module_ignite" , "DN Iginite Death", dn_module_ignite )