

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

-- function dn_module_heartattack(ply,target)
	-- if target:IsPlayer() then
		-- if target:InVehicle() then
			-- target:ExitVehicle()
		-- end 
		-- local tttmessage = "Death Note: "..target:Nick().." has died via the Death 
		-- dn_messages(ply,target,tttmessage)
		-- if target:Health() >= target:GetMaxHealth() then
			-- target:SetHealth(target:GetMaxHealth())
		-- end
	-- end 
	-- local dmgInfo = DamageInfo() 
	-- dmgInfo:SetDamage( 1e8 )
	-- dmgInfo:SetAttacker( ply or target )
	-- dmgInfo:SetDamageForce( Vector(0,0,0) )
	-- target:TakeDamageInfo(dmgInfo)
	-- DeathNote_RemoveEntity(ply,target)
	-- if not IsValid( target ) then return end 
	-- if target:IsNPC() or target:IsNextBot() or not target:Alive() then return end 
	-- target:Kill()
-- end
-- hook.Add( "dn_module_heartattack", "DN Heart Attack Death", dn_module_heartattack )