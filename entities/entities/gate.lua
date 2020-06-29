AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Gateway"
ENT.Author = "Guysudai1"
ENT.Instructions = "Collide with the gate, and confirm a derma menu in order to enter a game lobby"
ENT.Purpose = "Enter player into game"
ENT.ClassName = "gate"	
ENT.PrintName = "Default Gate Name"
ENT.Spawnable = true
if (SERVER) then
	ENT.started = false
	ENT.LOBBY = { }
	ENT.Location = Vector(0,0,0)
	ENT.GamePosition = Vector(0,0,0)
	function ENT:FuncModel()  
		return "models/props_c17/door01_left.mdl"
	end

	function ENT:ChangeLocation( newLocation )
		self.Location = newLocation
	end
	
	net.Receive("changeSpawnLoc",function(len, ply) 
		if (ply and (ply:IsPlayer() and ply:IsValid())) then
			if (ply:adminCheck()) then
				local gameName = net.ReadString()
				local newLocation = ply:GetLookingPoint()
				for _,gate in pairs(GAMEMODE.Gates) do
					if (string.lower(gate.LobbyName) == string.lower(gameName)) then
						GAMEMODE:LogFile(TYPE_GAME_LOG, "[GATE LOCATION #" .. _ .. " ] Changed gate[" .. self:GetPos() .. "]\'s spawn location from " .. self.Location .. " to " .. newLocation)
						ent:ChangeLocation(newLocation)
					end
				end
				
				
			end
		end

	end)

	function ENT:Initialize()
		GAMEMODE:LogFile(TYPE_GAME_LOG, "[GATE INIT] Initialized gate")
		self:SetModel(self:FuncModel())
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetTrigger(true);
	end

	function ENT:ChangeName( newName )
		self.Name = newName
	end

	net.Receive("changeName",function(len, ply) 
		if (ply and (ply:IsPlayer() and ply:IsValid())) then
			if (ply:adminCheck()) then
				local ent = net.ReadEntity()
				if (ent:GetClass() ~= "gate") then return end
				local newName = net.ReadString()
				for _,gate in pairs(GAMEMODE.Gates) do
					if (gate.LobbyName == ent.LobbyName) then
						GAMEMODE:LogFile(TYPE_GAME_LOG, "[GATE NAME #" .. _ .. " ] Changed gate[" .. gate:GetPos() .. "]\'s name from " .. gate.Name .. " to " .. newName)
						gate:ChangeName(newName)
					end
				end
			end
		end

	end)

	function ENT:ChangeGame( newGame ) 
		local lowGame = string.lower(newGame) -- the game name in lower case
		for _,lob in pairs(GAMEMODE.Lobbies) do
			if (string.lower(lob.LobbyName) == lowGame) then
				self.LOBBY = lob
				self.Name = lob.Name
				self.PrintName = "Gateway for game: " .. lob.Name
				return true
			end
		end
		GAMEMODE:LogFile(TYPE_GAME_LOG, "[ERROR CHANGING GAME] No minigame exists with name of: " .. lowGame)
		return false
	end
	function ENT:StartGame()
		local lobbyName = self.LOBBY.LobbyName
		for _,lob in pairs(GAMEMODE.Lobbies) do
			if (string.lower(lob.LobbyName) == lobbyName) then
				GAMEMODE:LogFile(TYPE_GAME_LOG, "[GAME STARTED] " .. lobbyName .. " has started playing with " .. #self.LOBBY.Players .. " players!")
				self.started = true
				for i,j in pairs(self.LOBBY.Players) do
					if (IsValid(j) and j:IsPlayer()) then
						GAMEMODE:LogFile(TYPE_GAME_LOG, "[TELEPORTING TO GAME] " .. j:NameWithSteamID() .. " has been teleported from the lobby to: " .. tostring(self.GamePosition))
						j:SetPos(self.GamePosition)
						
					end
				end

				break
			end
		end
	end
	function ENT:StartTouch( ent ) 

		if (ent:IsPlayer() and ent:IsValid()) then
			if (self.started) then return end
			if (ent:GetNWBool("inGame")) then return end
			if (self.LOBBY.Name and (#self.LOBBY.Players + 1) <= self.LOBBY.MaxPlayers) then
				ent:SetNWBool("inGame",true)
				ent:SetNWString("gameName",self.LOBBY.LobbyName)
				GAMEMODE:LogFile(TYPE_GAME_LOG, "[LOBBY " .. self.LOBBY.Name .. "] has added " .. ent:Name())
				self.LOBBY:AddPlayer(ent)	
				ent:SetPos(self.Location)
				if (#self.LOBBY.Players >= self.LOBBY.MinPlayers) then
					if (not timer.Exists("countdowntimer" .. self.Name ) and #self.LOBBY.Players < self.LOBBY.MaxPlayers) then
						timer.Create("countdowntimer" .. self.Name, 2, 30, function()  
							for _,v in pairs(self.LOBBY.Players) do
								net.Start("lobbyTimer")
									net.WriteString(tostring(2 * timer.RepsLeft("countdowntimer" .. self.Name)) .. " seconds until game " .. self.PrintName .. " is begun!")
								net.Send(v)
							end
						end)
						timer.Simple(2 * timer.RepsLeft("countdowntimer" .. self.Name), function() 
						if ((not timer.Exists("countdowntimer" .. self.Name) or timer.RepsLeft("countdowntimer" .. self.Name) <= 2) and #self.LOBBY.Players >= self.LOBBY.MinPlayers) then
						 	for _,v in pairs(self.LOBBY.Players) do
						 		if (v:IsPlayer()) then
						 			net.Start("lobbyTimer")
						 				net.WriteString("The game will now commence!")
						 			net.Send(v)
						 			self:StartGame()
						 		end
						 	end
						end end)
					elseif (#self.LOBBY.Players == self.LOBBY.MaxPlayers) then
						if (timer.Exists("countdowntimer" .. self.Name )) then
							timer.Adjust("countdowntimer" .. self.Name, 2, 10)
						else
							timer.Create("countdowntimer" .. self.Name, 2, 5, function()  
								for _,v in pairs(self.LOBBY.Players) do
									net.Start("lobbyTimer")
										net.WriteString(tostring(2 * timer.RepsLeft("countdowntimer" .. self.Name)) .. " seconds until game " .. self.PrintName .. " is begun!")
									net.Send(v)
								end
							end)
							timer.Simple(2 * timer.RepsLeft("countdowntimer" .. self.Name), function() 
							if ((not timer.Exists("countdowntimer" .. self.Name) or timer.RepsLeft("countdowntimer" .. self.Name) <= 2) and #self.LOBBY.Players >= self.LOBBY.MinPlayers) then
							 	for _,v in pairs(self.LOBBY.Players) do
							 		if (v:IsPlayer()) then
							 			net.Start("lobbyTimer")
							 				net.WriteString("The game will now commence!")
							 			net.Send(v)
							 			self:StartGame()
							 		end
							 	end
							end end)
						end
					end
				end
			end 
		else 
			return
		end

	end

	net.Receive("changeGame",function(len, ply) 
		if (ply and (ply:IsPlayer() and ply:IsValid())) then
			if (ply:adminCheck()) then
				local ent = net.ReadEntity()
				if (ent:GetClass() ~= "gate") then return end
				local newGame = net.ReadString()
				if (ent:ChangeGame(newGame)) then
					GAMEMODE:LogFile(TYPE_GAME_LOG, "[GAME CHANGE] " .. ply:Name() .. " has changed the gate\'s lobby to " .. newGame .. " - " .. ent:GetName())
				end
			end
		end

	end)

	hook.Add("PlayerDeath" , "gateDeath", function(ply) 
			if (ply:GetNWBool("inGame") == false) then return end
			for _,lobby in pairs(GAMEMODE.Lobbies) do
				if (lobby.LobbyName == ply:GetNWBool("gameName")) then
					lobby:RemovePlayer(ply)
					break
				end
			end
			ply:SetNWBool("inGame",false)
			ply:SetNWString("gameName","")
			
		end)
else 
	function ENT:Draw() 

		self:DrawModel()

	end
end

