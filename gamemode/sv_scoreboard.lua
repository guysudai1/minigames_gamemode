function playerAccess() 
	local ply = net.ReadEntity()
	local allPlayers = player.GetAll()
	for _,v in pairs(allPlayers) do
		if (v:IsBot()) then
			table.remove(allPlayers, _)
		end
	end
	if (ply:adminCheck()) then
		net.Start("playerView")
			net.WriteTable(allPlayers)
			net.WriteBool(true)
		net.Send(ply)
		return
	
	elseif (not ply:GetNWBool("inGame")) then
		for _,v in pairs(allPlayers) do
			if (v:GetNWBool("inGame")) then
				table.remove(allPlayers, _)
			end
		end
		net.Start("playerView")
			net.WriteTable(allPlayers)
			net.WriteBool(false)
		net.Send(ply)
		return
	
	else
		for _,v in pairs(allPlayers) do
			if (not v:GetNWBool("inGame") or v:GetNWString("gameName") ~= ply:GetNWString("gameName")) then
				table.remove(allPlayers,_)
			end
		end
		net.Start("playerView")
			net.WriteTable(allPlayers)
			net.WriteBool(false)
		net.Send(ply)
		return
	end
end
net.Receive("playerView", playerAccess)