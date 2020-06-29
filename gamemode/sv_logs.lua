function GM:LogFile(typeLog, text)
	if (not file.Exists("minigame/", "")) then
		file.CreateDir("minigame")
	end 
	if (not file.Exists("minigame/minigameLogs/", "")) then
		file.CreateDir("minigame/minigameLogs")
	end 
	local currentDate = tostring(os.date("%d-%m-%Y"))
	if (not file.Exists(currentDate, "minigame/minigameLogs/")) then
		file.CreateDir("minigame/minigameLogs/" .. currentDate )
	end
	local textToType = os.date("%H:%M:%S") .. ": " .. text
	
	local fileName = self:GetLogFileName(typeLog)
	if (file.Exists("minigame/minigameLogs/" .. currentDate .. "/" .. fileName, "DATA")) then
		textToType = "\n" .. textToType
		file.Append("minigame/minigameLogs/" .. currentDate.. "/" .. fileName,textToType)
	else
		file.Write("minigame/minigameLogs/" .. currentDate .. "/" .. fileName, textToType)
	end

end

function GetLogFile(len, ply) 
	if (IsValid(ply) and ply:IsAdmin()) then
		local logType = net.ReadInt(16)
		local currentDate = net.ReadString()
		local f = file.Open("minigame/minigameLogs/" .. currentDate .. "/" .. GAMEMODE:GetLogFileName(logType) , "r", "DATA")
		local fileRead
		if (not f) then 
			fileRead = "" 
		else 
			fileRead = f:Read( f:Size() )
			f:Close()
		end
		net.Start("logFile")
			net.WriteString(fileRead)
			net.WriteInt(logType,16)
		net.Send(ply)
	end	
end

net.Receive("logFile",GetLogFile)

function GetLogDateFolders(len, ply)
	if (IsValid(ply) and ply:IsAdmin()) then
		local filePath = "minigame/minigameLogs/*"
		local files, directories = file.Find(filePath, "DATA", "nameasc")
		net.Start("getFolders")
			net.WriteTable(directories)
		net.Send(ply)
	end
end

net.Receive("getFolders",GetLogDateFolders)

function GM:GetLogFileName(typeLog)
	local fileName = "generalLog.txt"
	if (typeLog == TYPE_USR_LOG) then
		fileName = "usersLog.txt"
	elseif (typeLog == TYPE_DMG_LOG) then
		fileName = "damageLog.txt"
	elseif (typeLog == TYPE_ADM_LOG) then
		fileName = "adminLog.txt"
	elseif (typeLog == TYPE_GAME_LOG) then
		fileName = "gameLog.txt"
	elseif (typeLog == TYPE_SPWN_LOG) then
		fileName = "spawnLog.txt"
	elseif (typeLog == TYPE_SVR_LOG) then
		fileName = "serverLog.txt"
	elseif (typeLog == TYPE_CHT_LOG) then 
		fileName = "chatLog.txt"
	end

	return fileName
end

function logToFileNet(len, ply)
	local logMessage = net.ReadString()
	local logType = net.ReadInt(16)

	if (ply:adminCheck()) then
		GAMEMODE:LogFile(logType, logMessage)
	end
end

net.Receive("logToFile",logToFileNet)

function GM:getGagList()
	
	if (not file.Exists("minigame/gags.txt","DATA")) then file.Write("minigame/gags.txt", "") end
	if (string.Trim(file.Read("minigame/gags.txt")) == "") then return {} end
	return util.JSONToTable(file.Read("minigame/gags.txt", "DATA"))
end

function removeFromGagList(len, ply)
	local playerToUnGagID = net.ReadString()
	local playerToUnGag
	for _,v in pairs(ents.GetAll()) do
		if (v:IsPlayer() and v:SteamID() == playerToUnGagID) then
			playerToUnGag = v
		end
	end
	if ((ply:IsPlayer() and ply:adminCheck()) and (playerToUnGag:IsPlayer() and playerToUnGag:isGagged())) then
		local gagList = GAMEMODE:getGagList()
		for _,v in pairs(gagList) do
			if (v.id == playerToUnGag:SteamID()) then
				table.remove(gagList, _)
				break
			end
		end
		local gagListString = util.TableToJSON(gagList)
		file.Write("minigame/gags.txt", gagListString)
		GAMEMODE:LogFile(TYPE_ADM_LOG, "[UNGAGGED] " .. ply:NameWithSteamID() .. " has ungagged " .. playerToUnGag:NameWithSteamID())
	end
end

net.Receive("removeFromGagList",removeFromGagList)

function addToGagList(len, ply)
	local playerToGagID = net.ReadString()
	local playerToGag
	for _,v in pairs(ents.GetAll()) do
		if (v:IsPlayer() and v:SteamID() == playerToGagID) then
			playerToGag = v
		end
	end
	if (not playerToGag:IsPlayer() or playerToGag:isGagged()) then return end
	if ((ply:IsPlayer() and ply:adminCheck()) and playerToGag:IsPlayer()) then
		local gagList = GAMEMODE:getGagList()
		table.insert(gagList, {name = playerToGag:Name(), id = playerToGag:SteamID()})
		local msg = util.TableToJSON(gagList, true)
		file.Write("minigame/gags.txt", msg)
		GAMEMODE:LogFile(TYPE_ADM_LOG, "[GAG] " .. ply:NameWithSteamID() .. " has gagged " .. playerToGag:NameWithSteamID())
	end
	
end

net.Receive("addToGagList",addToGagList)