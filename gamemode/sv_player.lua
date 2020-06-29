local meta = FindMetaTable("Player")

function meta:adminCheck() 
	return self:GetUserGroup() == "admin" or self:GetUserGroup() == "superadmin"
end

function GM:PlayerSpawn( ply )
	ply:SetNWBool("inGame",false)
	self:LogFile(TYPE_USR_LOG, "[SPAWN] " .. ply:GetName() .. " has just spawned in!")
	ply:Give("weapon_physgun")
	ply:Give("gmod_tool")
	ply:isGagged()
	ply:SetModel("models/player/group02/male_02.mdl")
end

function bringPlayer(len, ply)
	local steamID = net.ReadString()
	if (IsValid(ply) and ply:adminCheck()) then
		for _,ent in pairs(ents.GetAll()) do
			if ((IsValid(ent) and ent:IsPlayer() ) and ent:SteamID() == steamID) then
				GAMEMODE:LogFile(TYPE_ADM_LOG, "[BRING] " .. ply:NameWithSteamID() .. " has brought " .. ent:NameWithSteamID() .. " from " .. tostring(ent:GetPos()) .. " to  (" ..tostring(ply:GetPos()) .. ")")
				ent:SetPos(ply:GetPos())
				break
			end
		end
	end
end

net.Receive("bring", bringPlayer)

function gotoPlayer(len, ply)
	local steamID = net.ReadString()
	if (IsValid(ply) and ply:adminCheck()) then
		for _,ent in pairs(ents.GetAll()) do
			if ((IsValid(ent) and ent:IsPlayer() ) and ent:SteamID() == steamID) then
				GAMEMODE:LogFile(TYPE_ADM_LOG, "[GOTO] " .. ply:NameWithSteamID() .. " has teleported themselves from " .. tostring(ply:GetPos()) .. " to " .. ent:NameWithSteamID() .. " (" ..tostring(ent:GetPos()) .. ")")
				ply:SetPos(ent:GetPos())
				break
			end
		end
	end
end

net.Receive("goto",gotoPlayer)
function Teleport(len, ply) 
	local steamID = net.ReadString()
	local playertotp
	for _,v in pairs(ents.GetAll()) do
		if (v:IsPlayer() and v:SteamID() == steamID) then
			playertotp = v
			break
		end
	end
	if (ply and ply:IsPlayer()) then
		if (not ply:adminCheck()) then return end
		local newPos = net.ReadVector()
		GAMEMODE:LogFile(TYPE_ADM_LOG, "[TELEPORT] " .. playertotp:NameWithSteamID() .. " has teleported " .. playertotp:NameWithSteamID() .. " from " .. tostring(playertotp:GetPos()) .. " to " .. tostring(newPos))
		playertotp:SetPos(newPos)
	end
	
end

net.Receive("teleport",Teleport)

function noclipPlayer(len, ply) 
	if (ply and ply:IsPlayer()) then
		if (ply:GetMoveType() == MOVETYPE_NOCLIP) then
			GAMEMODE:LogFile(TYPE_ADM_LOG, "[NOCLIP OFF] " .. ply:NameWithSteamID())
			ply:SetMoveType(MOVETYPE_WALK)
			return
		end
		if (ply:adminCheck()) then
			GAMEMODE:LogFile(TYPE_ADM_LOG, "[NOCLIP ON] " .. ply:NameWithSteamID())
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end

net.Receive("noclipPlayer",noclipPlayer)

function meta:GetLookingPoint() 
	return self:GetEyeTrace().HitPos
end

function meta:NameWithSteamID()
	return  self:Name() .. "[" .. self:SteamID() .. "]"
end

function kickPlayerByID(len, ply)
	local steamID = net.ReadString()
	local reason = net.ReadString()
	if (ply:adminCheck()) then
		for _,v in pairs(ents.GetAll()) do
			if (v and v:IsPlayer()) then
				if (v:SteamID() == steamID) then
					GAMEMODE:LogFile(TYPE_ADM_LOG, "[KICK] " .. ply:NameWithSteamID() .. " has kicked player \'" .. v:NameWithSteamID() .. " for reason: " .. reason) 
					v:Kick(reason)
				end
			end
		end
	end
end

net.Receive("kickWithID",kickPlayerByID)

function freezePlayer(len, freezer)
	local setFrozenState = net.ReadBool()
	local steamID = net.ReadString()
	local ply
	for _,v in pairs(ents.GetAll()) do
		if (IsValid(v) and v:IsPlayer()) then
			if (v:SteamID() == steamID) then
				ply = v
				break
			end
		end
	end
	if ((IsValid(ply) and ply:IsPlayer()) and (IsValid(freezer) and freezer:adminCheck())) then

		ply:Freeze(setFrozenState)
		GAMEMODE:LogFile(TYPE_ADM_LOG, "[FREEZE] " .. freezer:NameWithSteamID() .. " has frozen " .. ply:NameWithSteamID())
	end
end

net.Receive("FreezePlayer",freezePlayer)

function meta:isGagged()
	local gagList = GAMEMODE:getGagList()
	if (gagList) then
		for _,v in pairs(gagList) do
			if (self:SteamID() == v.id) then
				return true
			end
		end
	end
	return false
end

function isGagged(len, ply)
	local playerToCheckID = net.ReadString()
	local playerToCheck
	for _,v in pairs(ents.GetAll()) do
		if (v:IsPlayer() and v:SteamID() == playerToCheckID) then
			playerToCheck = v
		end
	end

	if ((ply:IsPlayer() and ply:adminCheck()) and playerToCheck:IsPlayer()) then
		net.Start("checkGagged") 
			net.WriteBool(playerToCheck:isGagged())
		net.Send(playerToCheck)
	end
end

net.Receive("checkGagged",isGagged)

hook.Add("PlayerCanHearPlayersVoice","PlayerSpeaking", function ( speaker, listener)
	if (speaker:IsPlayer() and not speaker:isGagged()) then
		if (speaker:GetPos():Distance(listener:GetPos()) < 600) then
			return true
		end
	end
	return false
end)

hook.Add("PlayerSay", "WhenSpeaksInChat", function(ply, text, team)
	GAMEMODE:LogFile(TYPE_CHT_LOG , ply:NameWithSteamID() .. text)
	return text
end)