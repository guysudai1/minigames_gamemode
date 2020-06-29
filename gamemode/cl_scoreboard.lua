scoreboard = scoreboard or {}

function scoreboard:show()
	-- MAIN WINDOW -- 
	scoreboard.frame = vgui.Create("DPanel", nil, "Scoreboard")
	scoreboard.frame:SetSize(ScrW() / 3,ScrH()/ 2)
	scoreboard.frame:Center()
	scoreboard.frame:MakePopup()
	scoreboard.frame.Paint = function( w , h)
		surface.SetDrawColor(105, 105, 105,255)
		surface.DrawRect(0,0,ScrW() / 3,ScrH()/ 2)
	end
	local width, height = scoreboard.frame:GetSize()

	-- BACKGROUND IMAGE -- 
	local backgroundImage = vgui.Create("DImage", scoreboard.frame)
	backgroundImage:SetPos(0,0)
	local picHeight, picWidth = math.Clamp(800,0,height), math.Clamp(485,0,width)
	backgroundImage:SetSize(picWidth,picHeight)
	local imgPath = "assets/scoreboard_background.png"
	backgroundImage:SetImage(imgPath)
	backgroundImage:SetImageColor(Color(105, 105, 105,150))
	backgroundImage:Center()
	-- SCOREBOARD TEXT --
	local label = vgui.Create("DLabel", scoreboard.frame,"ScoreboardName")
	label:SetPos(width / 2 - 80,20)
	label:SetText("SCOREBOARD")
	label:SetColor(Color(0,0,0,255))
	label:SetFont("scoreboardFont")
	label:SetSize(100,100)
	label:SizeToContents()
    -- SCOREBOARD TEXT'S BACKGROUND --
	local background = vgui.Create("DPanel", scoreboard.frame, "Scoreboard text's background")
	local backHeight, backgroundPosy = 40, 13
	background:SetSize(width,backHeight)
	background:SetPos(0,backgroundPosy)
	background:SetBackgroundColor(Color(0,0,0,100))

	-- GETTING PLAYER LIST ACCORDING TO THE USER -- 
	net.Start("playerView")
		net.WriteEntity(LocalPlayer())
	net.SendToServer()
	net.Receive("playerView", function(len)
		if (scoreboard.frame) then
			local players = net.ReadTable()
			local isAdmin = net.ReadBool()
			-- SCROLL PANEL WITH PLAYERS -- 
			local playerSpot = vgui.Create("DScrollPanel", scoreboard.frame, "Player's position in the scoreboard")
			local scrollPanelPosY = backgroundPosy + backHeight
			local scrollPanelHeight = height - backgroundPosy - backHeight
			playerSpot:SetSize(width, scrollPanelHeight)
			playerSpot:SetPos(0, scrollPanelPosY)
			playerSpot:SetBackgroundColor(Color(0,0,0,255))
			local height = 0

			-- CREATING PLAYERS -- 
			for _,v in pairs(players) do

				-- CREATING THE PLAYER LINE -- 

				local playerGuy = vgui.Create("DButton", playerSpot)
				local playerGuyHeight = 40
				playerGuy:SetSize(width,playerGuyHeight )
				playerGuy:SetText("")
				playerGuy:SetPos(0,height)
				height = height + playerGuyHeight
				
				-- CREATING THE PANEL AFTER CLICKING THE PLAYER LINE -- 
				local clicked = false
				local playerInfo = vgui.Create("DPanel", playerSpot)
				playerInfo:SetSize(0,0)
				playerInfo:SetPos(0,height)
				playerInfo:SetBackgroundColor(Color(255,255,255,255))
				local boxHeight = 120
				playerGuy.DoClick = function()
					-- CHECKING IF THE PANEL IS ALREADY OUT -- 
					if (not clicked) then
						playerInfo:SetSize(width,boxHeight)
						for o,v in pairs(playerSpot:GetChildren()) do
							for l, panel in pairs(v:GetChildren()) do
								if (l > _ * 2) then
									local currentPosX,currentPosY = panel:GetPos()
									currentPosY = currentPosY + boxHeight
									panel:SetPos( currentPosX, currentPosY)
								end
							end
							break
						end
						-- SETTING THE MODEL PANEL IN THE PLAYER PANEL --
						local playerModel = vgui.Create("DModelPanel", playerInfo)
						playerModel:SetModel(v:GetModel())
						playerModel:Dock(LEFT)
						local playerInfoWidth, playerInfoHeight = playerInfo:GetSize() 
						playerModel:SetSize(80,playerInfoHeight)
						playerModel:DockMargin(5,0,0,0)
						function playerModel:LayoutEntity(ply) end
						-- SETTING THE CAMERA VIEW TO FACE THE EYES -- 
						playerModel:SetCamPos(Vector(15,0,65))
						playerModel:SetLookAt(playerModel:GetCamPos() - Vector(15,0,0))
						
						local playerName = vgui.Create("DLabel",playerInfo)
						playerName:SetColor(Color(106,106,106,255))
						playerName:SetFont("playerInfo")
						playerName:SetText(v:Name() .. "[" .. v:SteamID() .. "]")
						playerName:SizeToContents()
						playerName:SetPos((playerInfoWidth - select(1,playerName:GetSize())) / 2)
						playerName:SetMouseInputEnabled( true )
						function playerName:DoRightClick()
							local selectMenu = vgui.Create("DMenu")
							selectMenu:SetPos(gui.MousePos())
							selectMenu:AddOption("Copy name", function() SetClipboardText(v:Name()) end)
							selectMenu:AddOption("Copy steamID", function() SetClipboardText(v:SteamID()) end)
							selectMenu:MakePopup()
						end

						local playerSteamProfile = vgui.Create("DButton", playerInfo)
						playerSteamProfile:SetColor(Color(0,0,0,255))
						local defaultW, randomVariableDoesntMatter = playerSteamProfile:GetSize()
						playerSteamProfile:SetText("Profile")
						playerSteamProfile:SizeToContents()
						playerSteamProfile:SetSize(defaultW,playerInfoHeight / 6)
						playerSteamProfile:SetPos(width / 4,boxHeight / 3)
						function playerSteamProfile:Paint(w,h)
							if (self:IsHovered()) then
								draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
							else
								draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
							end
						end
						function playerSteamProfile:DoClick()
							v:ShowProfile()
						end

						local muteButton = vgui.Create("DButton", playerInfo)
						muteButton:SetColor(Color(0,0,0,255))
						local defaultW, randomVariableDoesntMatter = muteButton:GetSize()
						muteButton:SetSize(defaultW,playerInfoHeight / 6)
						muteButton:SetPos(width / 1.8,boxHeight / 3)
						function muteButton:Paint(w,h)
							if (self:IsHovered()) then
								draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
							else
								draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
							end
						end
						function muteButton:DoClick()
							if (v:IsMuted()) then
								v:SetMuted(false)
							else
								v:SetMuted(true)
							end
						end

						function muteButton:Think()
							if (v:IsMuted()) then
								self:SetText("Unmute")
							else
								self:SetText("Mute")
							end
						end

						if (isAdmin and LocalPlayer():IsAdmin()) then
							local kickButton = vgui.Create("DButton", playerInfo)
							kickButton:SetPos(width / 2.5, boxHeight / 3)
							self:adminButton(kickButton, "Kick", v)

							local banButton = vgui.Create("DButton", playerInfo)
							banButton:SetPos(width / 4, boxHeight / 1.5)

							self:adminButton(banButton, "Ban", v)

							local freezeButton = vgui.Create("DButton", playerInfo)
							freezeButton:SetPos(width / 2.5, boxHeight / 1.5)
							freezeButton:SetColor(Color(0,0,0,255))
							freezeButton:SetSize(defaultW,playerInfoHeight / 6)
							function freezeButton:Paint(w,h)
								if (self:IsHovered()) then
									draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
								else
									draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
								end
							end

							function freezeButton:Think()
								if (v:IsFrozen()) then
									self:SetText("Unfreeze")
								else
									self:SetText("Freeze")
								end
							end

							function freezeButton:DoClick()
								net.Start("FreezePlayer")
									net.WriteBool(not v:IsFrozen())
									net.WriteString(v:SteamID())
								net.SendToServer()
							end

							local gagButton = vgui.Create("DButton", playerInfo)
							gagButton:SetPos(width / 1.8, boxHeight / 1.5)
							gagButton:SetColor(Color(0,0,0,255))
							gagButton:SetSize(defaultW,playerInfoHeight / 6)
							function gagButton:Paint(w,h)
								if (self:IsHovered()) then
									draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
								else
									draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
								end
							end
							net.Start("checkGagged")
								net.WriteString(v:SteamID())
							net.SendToServer()

							net.Receive("checkGagged",function() 
								if (gagButton) then
									if (net.ReadBool()) then
								   		gagButton:SetText("Ungag")
								   	else
								   		gagButton:SetText("Gag")	
								   	end
								end
							end)

							function gagButton:DoClick()
								if (gagButton:GetText() == "Gag") then
									net.Start("addToGagList")
										net.WriteString(v:SteamID())
									net.SendToServer()
								elseif (gagButton:GetText() == "Ungag") then 
									net.Start("removeFromGagList")
										net.WriteString(v:SteamID())
									net.SendToServer()
								end
								net.Start("checkGagged")
									net.WriteString(v:SteamID())
								net.SendToServer()
							end

							local gotoButton = vgui.Create("DButton", playerInfo)
							gotoButton:SetPos(width / 1.4, boxHeight / 1.5)
							gotoButton:SetColor(Color(0,0,0,255))
							gotoButton:SetSize(defaultW,playerInfoHeight / 6)
							gotoButton:SetText("Goto")
							function gotoButton:Paint(w,h)
								if (self:IsHovered()) then
									draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
								else
									draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
								end
							end

							function gotoButton:DoClick()
								LocalPlayer():ConCommand("goto " .. v:SteamID())
							end

							local bringButton = vgui.Create("DButton", playerInfo)
							bringButton:SetPos(width / 1.4, boxHeight / 3)
							bringButton:SetColor(Color(0,0,0,255))
							bringButton:SetSize(defaultW,playerInfoHeight / 6)
							bringButton:SetText("Bring")
							function bringButton:Paint(w,h)
								if (self:IsHovered()) then
									draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
								else
									draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
								end
							end

							function bringButton:DoClick()
								LocalPlayer():ConCommand("bring " .. v:SteamID())
							end

							local tpButton = vgui.Create("DButton", playerInfo)
							tpButton:SetPos(width / 1.16, boxHeight / 1.5)

							self:adminButton(tpButton, "Teleport", v)

						end
						height = height + boxHeight
						clicked = true
					else 
						for o,v in pairs(playerSpot:GetChildren()) do
							for l, panel in pairs(v:GetChildren()) do
								if (l > _ * 2) then
									local currentPosX,currentPosY = panel:GetPos()
									currentPosY = currentPosY - boxHeight
									panel:SetPos( currentPosX, currentPosY)
								end
							end
							break
						end
						playerInfo:SetSize(width,0)
						playerInfo:Clear()
						height = height - boxHeight
						clicked = false
					end	
				end
				local beginTime = nil -- the beginning time since hovering over the button
				local startBackTime = nil -- the beginning time since not putting mouse on the button
				buttonColorx, buttonColory, buttonColorz = 106, 106, 106 -- beginning color
				buttonTransColorEndx, buttonTransColorEndy, buttonTransColorEndz = 56, 56, 56  -- color to transition to
				currentColorx, currentColory, currentColorz = buttonColorx, buttonColory, buttonColorz -- actual box colors
				currentColorBackx, currentColorBacky, currentColorBackz = buttonTransColorEndx, buttonTransColorEndy, buttonTransColorEndz -- actual box color
				playerGuy.Paint = function()
					if (playerGuy:IsHovered()) then
						startBackTime = RealTime()
						local colorx,colory,colorz
						if (beginTime) then
							local transitionTime = 0.7 -- seconds
							-- scaling color for each color
							if (currentColorBackx > buttonTransColorEndx) then
								colorx = Lerp((RealTime() - beginTime ) / transitionTime, -currentColorBackx,-buttonTransColorEndx)
								colorx = -colorx	
							else
								colorx = Lerp((RealTime() - beginTime ) / transitionTime,currentColorBackx,buttonTransColorEndx)			
							end

							if (currentColorBacky > buttonTransColorEndy) then
								colory = Lerp((RealTime() - beginTime ) / transitionTime, -currentColorBacky,-buttonTransColorEndy)
								colory = -colory	
							else
								colory = Lerp((RealTime() - beginTime ) / transitionTime,currentColorBacky,buttonTransColorEndy)			
							end

							if (currentColorBackz > buttonTransColorEndz) then
								colorz = Lerp((RealTime() - beginTime ) / transitionTime, -currentColorBackz,-buttonTransColorEndz)
								colorz = -colorz	
							else
								colorz = Lerp((RealTime() - beginTime ) / transitionTime,currentColorBackz,buttonTransColorEndz)			
							end
							-- end scaling color for each color (X , Y , Z)
						else
							-- default color values
							colorx, colory, colorz = buttonTransColorEndx, buttonTransColorEndy, buttonTransColorEndz

						end
						-- getting current color
						currentColorx, currentColory, currentColorz = colorx, colory, colorz
						-- setting the DButton's color to apprementioned color
						surface.SetDrawColor(Color(colorx, colory, colorz,200))
						surface.DrawRect(0,0,width,playerGuyHeight)
					else
						beginTime = RealTime()
						if (startBackTime) then
							local transitionTime = 0.7 -- seconds
							-- scaling color for each color
							if (currentColorx > buttonColorx) then
								colorx = Lerp((RealTime() - startBackTime ) / transitionTime,-currentColorx,-buttonColorx)
								colorx = -colorx
							else
								colorx = Lerp((RealTime() - startBackTime ) / transitionTime,currentColorx,buttonColorx)
							end
							if (currentColory > buttonColory) then
								colory = Lerp((RealTime() - startBackTime ) / transitionTime,-currentColory,-buttonColory)
								colory = -colory
							else
								colory = Lerp((RealTime() - startBackTime ) / transitionTime,currentColory,buttonColory)
							end
							if (currentColorz > buttonColorz) then
								colorz = Lerp((RealTime() - startBackTime ) / transitionTime,-currentColorz,-buttonColorz)
								colorz = -colorz
							else
								-- default color values
								colorz = Lerp((RealTime() - startBackTime ) / transitionTime,currentColorz,buttonColorz)
							end
							-- end scaling color for each color (X , Y , Z)
						else
							colorx, colory, colorz = buttonColorx, buttonColory, buttonColorz
						end
						-- getting current color
						currentColorBackx, currentColorBacky, currentColorBackz = colorx, colory, colorz
						-- setting the DButton's color to apprementioned color
						draw.RoundedBox(0,0,0,width,playerGuyHeight,Color(colorx, colory, colorz,200))
					end
					-- DRAWING THE USERNAME -- 
					draw.SimpleText(v:Name(),"DermaDefault",5,playerGuyHeight / 2 - 8 ,Color(255,255,255,255))
				end
			end
			playerSpot:PerformLayout()
		end
	end)
	

end

function scoreboard:adminButton(item, itemPrintName, ply)
	local defaultW, randomVariableDoesntMatter = item:GetSize()
	local backgroundWidth, backgroundHeight = item:GetParent():GetSize()
	item:SetSize(defaultW,backgroundHeight / 6)
	item:SetColor(Color(0,0,0,255))
	item:SetText(itemPrintName)
	function item:Paint(w,h)
		if (self:IsHovered()) then
			draw.RoundedBox(2,0,0,w,h,Color(96,96,96,255))
		else
			draw.RoundedBox(2,0,0,w,h,Color(116,116,116,255))
		end
	end
	function item:DoClick()
		local itemPanel = vgui.Create("DFrame")
		itemPanel:ShowCloseButton(false)
		itemPanel:SetTitle("Confirm " .. itemPrintName)
		itemPanel:SetSizable(false)
		itemPanel:SetSize(250,100)
		itemPanel:SetDraggable(true)
		itemPanel:Center()
		itemPanel:MakePopup()
		function itemPanel:Paint(w,h) 
			draw.RoundedBox(3,0,0,w,h,Color(128,128,128,255))
		end
		local itemPanelSizeW,itemPanelSizeH = itemPanel:GetSize()
		local itemX,itemY,itemZ
		if (string.lower(itemPrintName) == "ban" or string.lower(itemPrintName) == "kick") then
			local itemConfirm = vgui.Create("DTextEntry", itemPanel)
			itemConfirm:SetSize(3*itemPanelSizeW / 4,20)
			itemConfirm:SetFont("smallFont")
			itemConfirm:SetPlaceholderText("Reason...")
			itemConfirm:AllowInput(true)
			itemConfirm:SetPos(itemPanelSizeW/ 8, itemPanelSizeH / 4)
		elseif (string.lower(itemPrintName) == "teleport") then 
			itemX = vgui.Create("DTextEntry", itemPanel)
			itemX:SetSize(3*itemPanelSizeW / 12,20)
			itemX:SetFont("smallFont")
			itemX:SetPlaceholderText("X")
			itemX:AllowInput(true)
			itemX:SetPos(itemPanelSizeW/ 8, itemPanelSizeH / 4)

			itemY = vgui.Create("DTextEntry", itemPanel)
			itemY:SetSize(3*itemPanelSizeW / 12,20)
			itemY:SetFont("smallFont")
			itemY:SetPlaceholderText("Y")
			itemY:AllowInput(true)
			itemY:SetPos(itemPanelSizeW/ 8 + 3*itemPanelSizeW / 12 + 2, itemPanelSizeH / 4)

			itemZ = vgui.Create("DTextEntry", itemPanel)
			itemZ:SetSize(3*itemPanelSizeW / 12,20)
			itemZ:SetFont("smallFont")
			itemZ:SetPlaceholderText("Z")
			itemZ:AllowInput(true)
			itemZ:SetPos(itemPanelSizeW/ 8 + itemPanelSizeW / 2 + 2, itemPanelSizeH / 4)

			itemX:SetUpdateOnType(true)
			itemX:SetNumeric(true)

			function itemX:OnValueChange(newValue)
				if (not tonumber(newValue)) then
					self:SetText(string.sub(newValue, 0, string.len(newValue) -1 ))
				end
			end

			itemY:SetUpdateOnType(true)
			itemY:SetNumeric(true)

			function itemY:OnValueChange(newValue)
				if (not tonumber(newValue)) then
					self:SetText(string.sub(newValue, 0, string.len(newValue) -1 ))
				end
			end

			itemZ:SetUpdateOnType(true)
			itemZ:SetNumeric(true)

			function itemZ:OnValueChange(newValue)
				if (not tonumber(newValue)) then
					self:SetText(string.sub(newValue, 0, string.len(newValue) -1 ))
				end
			end
		end
		
		local timeBan
		if (string.lower(itemPrintName) == "ban") then
			itemConfirm:SetSize(3 * itemPanelSizeW / 8,20)
			timeBan = vgui.Create("DTextEntry", itemPanel)
			timeBan:SetFont("smallFont")
			timeBan:SetPlaceholderText("Time (minutes)")
			timeBan:SetSize(3 * itemPanelSizeW / 8,20)
			timeBan:AllowInput(true)
			timeBan:SetPos(1+ itemPanelSizeW / 2, itemPanelSizeH / 4)
			timeBan:SetUpdateOnType(true)
			timeBan:SetNumeric(true)

			function timeBan:OnValueChange(newValue)
				if (not tonumber(newValue)) then
					self:SetText(string.sub(newValue, 0, string.len(newValue) -1 ))
				end
			end
		end

		local confirmItemButton = vgui.Create("DButton", itemPanel)
		confirmItemButton:SetSize(3*itemPanelSizeW / 8 - 3,itemPanelSizeH / 4)
		confirmItemButton:SetPos(itemPanelSizeW/ 8, itemPanelSizeH / 2)
		confirmItemButton:SetText(itemPrintName)
		confirmItemButton:SetColor(Color(0,0,0,255))
		function confirmItemButton:Paint(w,h)
			if (self:IsHovered()) then
				surface.SetDrawColor(240,240,240,255)
			else 
				surface.SetDrawColor(255,255,255,255)
			end
			surface.DrawRect(0,0,w,h)
		end

		function confirmItemButton:DoClick()
			if (string.lower(itemPrintName) == "ban") then
				if (timeBan and itemConfirm) then
					if (timeBan:GetText() == "") then return end
					LocalPlayer():ConCommand("banidplayer " .. ply:Name() .. " " .. ply:SteamID() .. " " .. timeBan:GetText() .. " " .. itemConfirm:GetText() )
				end
			elseif (string.lower(itemPrintName) == "kick") then
				if (itemConfirm) then
					LocalPlayer():ConCommand("kickidplayer " .. ply:SteamID() .. " " .. itemConfirm:GetText() )
				end
			elseif (string.find(string.lower(itemPrintName) , "teleport")) then 
				if (itemX:GetText() == "") then itemX:SetText("0") end
				if (itemY:GetText() == "") then itemY:SetText("0") end
				if (itemZ:GetText() == "") then itemZ:SetText("0") end
				LocalPlayer():ConCommand("tp " .. ply:SteamID() .. " " .. itemX:GetText() .. " " .. itemY:GetText() .. " " .. itemZ:GetText())
			end
			self:GetParent():Remove()
		end

		local cancelItemButton = vgui.Create("DButton", itemPanel)
		cancelItemButton:SetSize(3*itemPanelSizeW / 8 - 3,itemPanelSizeH / 4)
		cancelItemButton:SetPos(3 + itemPanelSizeW / 2, itemPanelSizeH / 2)
		cancelItemButton:SetText("Cancel")
		cancelItemButton:SetColor(Color(0,0,0,255))

		function cancelItemButton:Paint(w,h)
			if (self:IsHovered()) then
				surface.SetDrawColor(240,240,240,255)
			else 
				surface.SetDrawColor(255,255,255,255)
			end
			surface.DrawRect(0,0,w,h)
		end

		function cancelItemButton:DoClick()
			self:GetParent():Remove()
		end
	end
end
function scoreboard:hide()
	if (scoreboard.frame) then
		scoreboard.frame:Remove()
	end
	scoreboard.frame = nil
end

function GM:ScoreboardShow()
	scoreboard:show()
end
function GM:ScoreboardHide()
	scoreboard:hide()
end
