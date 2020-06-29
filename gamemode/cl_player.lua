function notifyPlayer()
	local notifMsg = net.ReadString()
	if (notifMsg) then
		notification.AddLegacy(notifMsg , NOTIFY_GENERIC, 2)
	end
	
end

net.Receive("lobbyTimer",notifyPlayer)
	