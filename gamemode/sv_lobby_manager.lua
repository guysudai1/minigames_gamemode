GM.Lobbies = { }

function GM:LoadLobbies() 
	if (SERVER) then
		print("\n/**********************/")
		print("\n    LOADING LOBBIES     ")
		print("\n/**********************/\n")
	end


	local filePath = "/gamemode/lobbies/*.lua"
	local files, directories = file.Find(GAMEMODE.FolderName .. filePath, "LUA", "nameasc")
	if (#files > 0) then
		for _,l in pairs(files) do
			local i = 0
			local endLobbyCount = 2
			while i < endLobbyCount do 
				LOBBY = { }
				LOBBY.LobbyCount = 2
				LOBBY.MaxPlayers = 10
				LOBBY.Name = "No Name"
				LOBBY.Players = {}
				LOBBY.LobbyName = "noname"
				LOBBY.MinPlayers = 2
				function LOBBY:AddPlayer( ply ) 
					if (#self.Players >= self.MaxPlayers) then
						return false
					end
					for _,v in pairs(self.Players) do
						if (ply:SteamID() == v:SteamID()) then
							return false
						end
					end
					table.insert(self.Players, ply)
					return true
				end
				 

				function LOBBY:RemovePlayer( ply ) 
					if (#self.Players > 0) then
						for _,v in pairs(self.Players) do 
							if (not IsValid(ply) or not ply:IsPlayer()) then 
								table.remove(self.Players, _)
							elseif (ply:SteamID() == v:SteamID()) then
								table.remove(self.Players, _)
							end
						end
					end
					
				end

				

				include(GAMEMODE.FolderName .. "/gamemode/lobbies/" .. l)
				if (LOBBY.LobbyCount) then endLobbyCount = LOBBY.LobbyCount end
				LOBBY.LobbyName = LOBBY.LobbyName .. tostring(i)
				table.insert(self.Lobbies, LOBBY)
				timer.Create(LOBBY.LobbyName, 0.1, 0,function() 
					for _,v in pairs(LOBBY.Players) do
						if (not IsValid(v) or not v:IsPlayer()) then
							LOBBY:RemovePlayer(v)
						end
					end
				end)
				self:LogFile(TYPE_SVR_LOG, "[LOADED] Finished loading lobby: \'" .. LOBBY.LobbyName .. "\'")
				i = i + 1
			end
		end

	else 
		if (SERVER) then
			self:LogFile(TYPE_SVR_LOG, "[FAILED] Loading lobby files failed!")
		end
	end
end