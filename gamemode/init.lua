AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_adminmenu.lua" )
AddCSLuaFile( "cl_chat.lua" )
AddCSLuaFile( "cl_player.lua" )
resource.AddFile("assets/scoreboard_background.png")

include( "shared.lua" )
include("sv_player.lua")
include("sv_lobby_manager.lua")
include("network.lua")
include("concommands.lua")
include("sv_scoreboard.lua")
include("sv_logs.lua")


timer.Create("Gates", 3, 0, function() 
	if (SERVER) then
		GAMEMODE.Gates = { }
		local entities = ents.GetAll()
		for _, ent in pairs(entities) do
			if (not ent:IsPlayer()) then
				if (ent:GetClass() == "gate") then
					table.insert(GAMEMODE.Gates, ent)
				end
			end
		end

	end
end)


function GM:Initialize() 
	self:LogFile(TYPE_SVR_LOG, "[LOADING] Loading lobby files")
	self:LoadLobbies()
	
end

function SpawnEntity(len, ply)
	local className = net.ReadString()
	if (className and (ply and ply:IsValid())) then
		if (not ply:adminCheck()) then return end
		local entity = ents.Create( className )
		if (not entity:IsValid()) then return end
		entity:SetPos(ply:GetLookingPoint())
		entity:Spawn()
		GAMEMODE:LogFile(TYPE_SPWN_LOG, "[SPAWN] " .. ply:NameWithSteamID() .. " has spawned in \'" .. className .. "\' at ".. tostring(ply:GetLookingPoint()) )
	end
end

net.Receive("SpawnItem",SpawnEntity)


GM.a_crszkv30LastNameCol = "Crazy variable name" -- Garry's Mod Development Discord