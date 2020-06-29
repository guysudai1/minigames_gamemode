include( "shared.lua" )
include("cl_scoreboard.lua")
include("cl_adminmenu.lua")
include("cl_chat.lua")
include("cl_player.lua")
-- function GM:Move(ply, moveData) 
-- 	if (moveData:KeyPressed(IN_GRENADE1)) then
-- 		print(moveData:GetButtons())
-- 	end

-- end

hook.Add("PlayerBindPress","bindHook", function(ply, bind, pressed)
	if (string.find(bind, "gm_showteam") and IsValid(ply)) then
		if (AMenu.DTabSheet) then 
			AMenu.DTabSheet:Remove()
			AMenu.DTabSheet = nil
			gui.EnableScreenClicker(false)
			timer.Remove("refreshLogs")
		else
			if (ply:IsAdmin()) then
				AMenu:InitMenu()
			end
		end
	elseif (string.find(bind, "messagemode")) then
		customChat:OpenChat()
		return true
	end

end)

surface.CreateFont("scoreboardFont",	
	{
		antialias 	= 		true,
		blursize	= 		0,
		font 		=		"Verdana Bold",
		size 		=		26,
		weight 		= 		900,
	}
)

surface.CreateFont("playerInfo",	
	{
		antialias 	= 		false,
		blursize	= 		0,
		font 		=		"Arial",
		size 		=		19,
		weight 		= 		500,
	}
)


surface.CreateFont("smallFont",
	{
		font 		= 		"Arial",
		blursize 	= 		0,
		size 		= 		14,
		weight 		= 		300,
		antialias 	= 		false,
	}
)
surface.CreateFont("verySmallFont",
	{
		font 		= 		"Arial",
		blursize 	= 		0,
		size 		= 		12,
		weight 		= 		400,
		antialias 	= 		true,
	}
)