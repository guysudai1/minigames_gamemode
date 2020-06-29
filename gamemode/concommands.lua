
concommand.Add("spawn", function(ply, cmd, args, argStr) 
	local itemName
	for _,v in pairs(args) do
		itemName = v
		break
	end
	if (CLIENT) then
		if (itemName == "") then
			print("In order to use spawn, type: spawn {item name}, the item name cannot be null!")
			return
		end
		net.Start("SpawnItem")
			net.WriteString(itemName)
		net.SendToServer()
		return
	end
	
end,  nil, "Syntax: spawn { className }\n - Info: Spawns entity with classname of { className } at the location player is looking at")

concommand.Add("bring", function ( ply, cmd, args, argStr )
	local steamID = ""
	local args = string.Split(argStr," ")
	for _,v in pairs(args) do
		if (_ == 1) then
			steamID = v
			break
		end
	end

	if CLIENT then
		if (steamID == "") then print("You need to add a steamID in order to use this command!") return end
		net.Start("bring")
			net.WriteString(steamID)	
		net.SendToServer()
	end
	
end,  nil, "Syntax: bring { steamID }\n - Info: Teleports player { steamID } to the person who use this command.")

concommand.Add("goto", function ( ply, cmd, args, argStr )
	local steamID = ""
	local args = string.Split(argStr," ")
	for _,v in pairs(args) do
		if (_ == 1) then
			steamID = v
			break
		end
	end

	if CLIENT then
		if (steamID == "") then print("You need to add a steamID in order to use this command!") return end
		net.Start("goto")
			net.WriteString(steamID)	
		net.SendToServer()
	end
	
end,  nil, "Syntax: goto { steamID }\n - Info: Teleports player to different player with steamID of { steamID }")

concommand.Add("tp", function ( ply, cmd, args, argStr )
	local newPos = Vector()
	local steamID
	local args = string.Split(argStr," ")
	for _,v in pairs(args) do
		if (_ > 4) then
			break
		end
		if (_ == 1) then 
			steamID = v
		elseif (_ == 2) then
			newPos:Add(Vector(v,0,0))
		elseif (_ == 3) then
			newPos:Add(Vector(0, v,0))
		elseif (_ == 4) then
			newPos:Add(Vector(0,0, v))
		end
	end

	if CLIENT then
		if (steamID == "") then print("You need to add a steamID in order to use this command!") return end
		net.Start("teleport")
			net.WriteString(steamID)
			net.WriteVector(newPos)	
		net.SendToServer()
	end
	
end,  nil, "Syntax: tp { steamID } { x } { y } { z }\n - Info: Teleports player with { steamID } to coordinate (x,y,z)")

concommand.Add("!noclip", function(ply, cmd, args, argStr)
	if CLIENT then
		net.Start("noclipPlayer")
        net.SendToServer()
	end  
end, nil, "Syntax: !noclip\n - Info: Noclips / Unnoclips player")

concommand.Add("changegame", function(ply, cmd, args, argStr)
	if CLIENT then
		if (ply and ply:IsValid()) then
			

			if (argStr == "") then print("You need to add a game's name after the changegame command!") return end
			local playerTrace = ply:GetEyeTrace()
			local ent = playerTrace.Entity
			if (ent:GetClass() and ent:GetClass() ~= "gate") then print("You need to look at a gateway in order to use this command!") return end
			local gameN
			for _,v in pairs(args) do
				gameN = v
				break
			end
			net.Start("changeGame")
				net.WriteEntity(ent)
				net.WriteString(gameN)
			net.SendToServer()
			return
		end
	end
end, nil, "Syntax: changegame { newGameLobbyName }\n - Info: Changes the game of the gate that the player is looking at to { newGameLobbyName }\n - Get all lobby names with \'listgames\'")

concommand.Add("changename", function(ply, cmd, args, argStr)
	if CLIENT then
		if (ply and ply:IsValid()) then
			

			if (argStr == "") then print("You need to add a game's name after the changename command!") return end
			local playerTrace = ply:GetEyeTrace()
			local ent = playerTrace.Entity
			if (ent:GetClass() and ent:GetClass() ~= "gate") then print("You need to look at a gateway in order to use this command!") return end
			local gameN
			for _,v in pairs(args) do
				gameN = v
				break
			end
			net.Start("changeName")
				net.WriteEntity(ent)
				net.WriteString(gameN)
			net.SendToServer()
			return
		end
	end
end, nil,"Syntax: changename { newName }\n - Info: for each gate that has the same lobby name as the one the player is looking at, changes name to { newName }")

concommand.Add("changeloc", function(ply, cmd, args, argStr)
	if CLIENT then
		if (ply and ply:IsValid()) then
			if (argStr == "") then print("You need to add a game's name after the changeloc command!") return end
			local gameN
			for _,v in pairs(args) do
				gameN = v
				break
			end
			net.Start("changeSpawnLoc")
				net.WriteString(gameN)
			net.SendToServer()
			return
		end
	end
end, nil, "Syntax: changeloc { gameLobbyName }\n - Info: for each gate that has lobby name {gamename}, changes spawn location to where the player is looking\n - Use \'listgames\' for list of all gate names")

concommand.Add("kickidplayer", function(ply, cmd, args, argStr)
	if CLIENT then
		if (ply and ply:IsValid()) then
			local arguements = string.Split( argStr, " " )
			local steamID
			local reason = ""
			for _,v in pairs(arguements) do
				if (_ == 1) then
					steamID = v
				else
					reason = reason .. v .. " "
				end
			end
			net.Start("kickWithID")
				net.WriteString(steamID)
				net.WriteString(reason)
			net.SendToServer()

		end
	end
end, nil, "Syntax: kickidplayer { steamID(not 64) } { reason }\n - Info: Kicks a player by his ID and logs it to the console")

concommand.Add("banidplayer",function(ply, cmd, args, argStr)
	if CLIENT then
		if (ply and ply:IsValid()) then
			local arguements = string.Split( argStr, " ")
			local steamID, banTime, playerName = ""
			local reason = ""
			for _,v in pairs(arguements) do
				if (_ == 1) then 
					playerName = v
				elseif (_ == 2) then
					steamID = v
				elseif (_ == 3) then 
					banTime = v
				else
					reason = reason .. v .. " " 
				end
			end
			net.Start("logToFile")
				net.WriteString("[BAN] " .. ply:Name() .. "[" .. ply:SteamID() .. "]" .. " has banned player \'" .. playerName .. "[" .. steamID .. "] for " .. tostring(banTime) .. " minutes, for reason: " .. reason)
				net.WriteInt(TYPE_ADM_LOG, 16)
			net.SendToServer()
			ply:ConCommand("ulx banid " .. steamID .. " " .. banTime .. " " ..  reason)
		end
	end
end, nil, "Syntax: banidPlayer { steamID(not 64) } { time(min) } { reason }\n - Info: Bans a player by his ID and logs it to the console")