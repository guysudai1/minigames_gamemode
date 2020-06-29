AMenu = AMenu or {}

function AMenu:InitMenu()


	gui.EnableScreenClicker(true)
	self.DTabSheet = vgui.Create("DPropertySheet")
	self.DTabSheet:SetSize(ScrW() / 2,ScrH() / 2)
	self.DTabSheet:Center()
	function self.DTabSheet:Paint(w,h) 
		surface.SetDrawColor(100, 100, 100,255)
		surface.DrawRect(0,0,w,h)
	end
	function self.DTabSheet:Think()
		
	end
	local plyPanel = vgui.Create("DPanel")
	self:CreatePage(plyPanel, "Players")

	local logPanel = vgui.Create("DPanel")
	self:CreatePage(logPanel, "Logs")
	
	local plyPanelx,plyPanely = plyPanel:GetPos()
	for _,item in pairs(self.DTabSheet.Items) do
		function item.Tab:Paint(w,h) 
			surface.SetDrawColor(100, 100, 100,255)
			surface.DrawRect(0,0,w,h)
		end

		local curPosX, curPosY = item.Tab:GetPos()
		function item.Tab:Think() 
			item.Tab:SetPos(curPosX, curPosY + 3)
		end
	end
end

function AMenu:CreatePage(dPanel,pageName)
	function dPanel:Paint(w,h) 
		surface.SetDrawColor(90, 90, 90,255)
		surface.DrawRect(0,0,w,h)
	end
	local width, height = self.DTabSheet:GetSize()
	dPanel:SetPos(10, 60)
	dPanel:SetSize(width - 10, height - 50)
	dPanel:Dock(FILL)
	local title = vgui.Create("DLabel", dPanel)
	title:SetText(pageName)
	title:SizeToContents()
	local textW, tY = title:GetSize()
	title:SetPos((width - textW) / 2, 0)
	if (string.lower(pageName) == "players") then
		local playerList = ents.GetAll()

		local playerListView = vgui.Create("DListView", dPanel)
		playerListView:SetSize(width / 1.5,height - tY - 2)
		playerListView:SetPos(width / 2 - width / 3, tY + 2)

		local nameCol = playerListView:AddColumn("Name")
		nameCol:SetMinWidth(10)
		nameCol:SetSize( width / 3,nameCol:GetTall())

		local steamIDCol = playerListView:AddColumn("SteamID")
		steamIDCol:SetMinWidth(10)
		steamIDCol:SetSize( width / 4.5,steamIDCol:GetTall())

		local steamID64Col = playerListView:AddColumn("SteamID64")
		steamID64Col:SetMinWidth(10)
		steamID64Col:SetSize( width / 4.5,steamID64Col:GetTall())

		for _,v in pairs(playerList) do
			if (IsValid(v) and v:IsPlayer()) then
				local line1 = playerListView:AddLine(v:Name(), v:SteamID(), v:SteamID64())
				for _,v in pairs(line1.Columns) do
					v:SetFont("verySmallFont")
					v:SizeToContents()
				end
			end
		end

		function playerListView:OnRowRightClick(lineId, linePanel)
			local selectMenu = vgui.Create("DMenu")
			selectMenu:SetPos(gui.MousePos())
			for _,v in pairs(linePanel.Columns) do
				if (_ == 1) then
					selectMenu:AddOption("Copy name",function() SetClipboardText(linePanel:GetColumnText(_)) end)
				elseif (_ == 2) then 
					selectMenu:AddOption("Copy steamID",function() SetClipboardText(linePanel:GetColumnText(_)) end)
				else 
					selectMenu:AddOption("Copy steamID64",function() SetClipboardText(linePanel:GetColumnText(_)) end)
					break	
				end
			end
			selectMenu:AddSpacer()
			local ban = selectMenu:AddOption("Ban " .. linePanel:GetColumnText(1))
			function ban:DoClick() 
				AMenu:adminButtonClicked(self, self:GetText(), linePanel:GetColumnText(1), linePanel:GetColumnText(2))
			end

			local kick = selectMenu:AddOption("Kick " .. linePanel:GetColumnText(1))
			function kick:DoClick() 
				AMenu:adminButtonClicked(self, self:GetText(), linePanel:GetColumnText(1), linePanel:GetColumnText(2))
			end
			selectMenu:AddSpacer()
			local goTo = selectMenu:AddOption("Goto " .. linePanel:GetColumnText(1), function() LocalPlayer():ConCommand("goto " .. linePanel:GetColumnText(2)) end)
			local bring = selectMenu:AddOption("Bring " .. linePanel:GetColumnText(1), function() LocalPlayer():ConCommand("bring " .. linePanel:GetColumnText(2)) end)
			selectMenu:AddSpacer()
			local tp = selectMenu:AddOption("Teleport " .. linePanel:GetColumnText(1))
			function tp:DoClick() 
				AMenu:adminButtonClicked(self, self:GetText(), linePanel:GetColumnText(1), linePanel:GetColumnText(2))
			end
		end

	elseif (string.lower(pageName) == "logs") then 
		net.Start("getFolders")
		net.SendToServer()
		net.Receive("getFolders",function() 
			local enums = {
				[TYPE_USR_LOG] = "Users",
				[TYPE_DMG_LOG] = "Damage",
				[TYPE_ADM_LOG] = "Admins",
				[TYPE_GAME_LOG] = "Games",
				[TYPE_SPWN_LOG] = "Spawn",
				[TYPE_SVR_LOG] = "Server",
				[TYPE_CHT_LOG] = "Chat",
			}
			local txt = {
				[TYPE_USR_LOG] = "",
				[TYPE_DMG_LOG] = "",
				[TYPE_ADM_LOG] = "",
				[TYPE_GAME_LOG] = "",
				[TYPE_SPWN_LOG] = "",
				[TYPE_SVR_LOG] = "",
				[TYPE_CHT_LOG] = "",
			}
			local allLogs = {}
			local wordToFind
			if (dPanel) then
				local textPanel = vgui.Create("DPropertySheet", dPanel)
				textPanel:SetSize(width,height)
				textPanel:Dock(FILL)
				textPanel:DockMargin(0,15,0,0)

				local wordFind = vgui.Create("DButton", dPanel)
				wordFind:SetPos(width - 150 ,0)
				wordFind:SetSize(50,15)
				wordFind:SetText("Find")

				

				function wordFind:DoClick() 
					local frame = vgui.Create("DFrame")
					frame:SetSize(120,40)
					frame:MakePopup()	
					frame:Center()
					frame.btnMaxim:Hide()
					frame.btnMinim:Hide()
					function frame.btnClose:Paint(w,h)
						if (self:IsHovered()) then
							surface.SetDrawColor(110,110,110,255)
						else
							surface.SetDrawColor(100,100,100,255)
						end
						
						surface.DrawRect(0,2,w,h - 10)
						surface.SetDrawColor(0,0,0,105)
						surface.DrawRect(0,2,w + 4,h - 9)
					end
					frame:SetTitle("Find")
					local dEntry = vgui.Create("DTextEntry", frame)
					dEntry:SetSize(120,20)
					dEntry:Center()
					dEntry:SetPos(select(1,dEntry:GetPos()), dEntry:GetTall() )
					function dEntry:OnEnter()
						for _,v in pairs(enums) do
							local oldTxt = txt[_]
							allLogs[_]:SetText("")
							oldText = string.Split(oldTxt, "\n")
							for l,j in pairs(oldText) do
								if ((oldText and string.find(string.lower(j), string.lower(self:GetText()))) and self:GetText() ~= "" ) then
									allLogs[_]:InsertColorChange(225, 102, 68, 255)
									allLogs[_]:AppendText(j .. "\n")
								else
									allLogs[_]:InsertColorChange(0,0,0,255)
									allLogs[_]:AppendText(j .. "\n")
								end
							end
						end
						wordToFind = self:GetText()
					end
				end
				local selectBox = vgui.Create("DComboBox", dPanel)
				selectBox:SetPos(width - 100 ,0)
				selectBox:SetSize(100,15)
				local dirs = net.ReadTable()
				for _,v in pairs(dirs) do
					if (v == os.date("%d-%m-%Y")) then
						selectBox:AddChoice(v, nil, true)
					else
						selectBox:AddChoice(v)	
					end	
					
				end
				

				function selectBox:OnSelect(index, value, data)
					net.Start("logFile")
						net.WriteInt(table.KeyFromValue(enums, textPanel:GetActiveTab():GetText()),16)
						net.WriteString(select(1,selectBox:GetSelected()))
					net.SendToServer()
				end

				function textPanel:Paint(w,h)

					surface.SetDrawColor(157, 161, 165,255)
					surface.DrawRect(0,0,w,h)
				end

				for _,v in pairs(enums) do
					local logs = vgui.Create("RichText", textPanel)
					logs:Dock(FILL)
					logs:SetSize(width,height)
					logs:SetVerticalScrollbarEnabled(true)
					textPanel:AddSheet(v,logs)
					net.Start("logFile")
						net.WriteInt(_,16)
						net.WriteString(select(1,selectBox:GetSelected()))
					net.SendToServer()
					allLogs[_] = logs
				end

				timer.Create("refreshLogs", 3,0, function()
					for _,v in pairs(enums) do
						net.Start("logFile")
							net.WriteInt(_,16)
							net.WriteString(select(1,selectBox:GetSelected()))
						net.SendToServer()
					end
				end)
				
				
				net.Receive("logFile",function()
					
					local text = net.ReadString() 
					local typeLog = net.ReadInt(16)
					if (allLogs[typeLog] and txt[typeLog]) then
						txt[typeLog] = text
						text = string.Split(text, "\n")
						allLogs[typeLog]:SetText("")
						for _,v in pairs(text) do
							if (wordToFind and (string.find(string.lower(v), string.lower(wordToFind))) and wordToFind ~= "") then
								allLogs[typeLog]:InsertColorChange(225, 102, 68, 255)
								allLogs[typeLog]:AppendText(v .. "\n")
							else
								allLogs[typeLog]:InsertColorChange(0, 0, 0, 255)
								allLogs[typeLog]:AppendText(v .. "\n")
							end
						end
					end
				end)
						

				for _,item in pairs(textPanel.Items) do
					function item.Tab:Paint(w,h) 
						surface.SetDrawColor(157, 161, 165,255)
						surface.DrawRect(0,0,w,h)
					end

					local curPosX, curPosY = item.Tab:GetPos()
					function item.Tab:Think() 
						item.Tab:SetPos(curPosX, curPosY + 3)
					end
				end
			end
		end)
		
	end
	self.DTabSheet:AddSheet(pageName,dPanel, nil, true,true, nil)
end

function AMenu:adminButtonClicked(pnl, itemPrintName, name, sID)
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
	local itemX, itemY, itemZ
	if (string.find(string.lower(itemPrintName), "ban") or string.find(string.lower(itemPrintName), "kick")) then
		local itemConfirm = vgui.Create("DTextEntry", itemPanel)
		itemConfirm:SetSize(3*itemPanelSizeW / 4,20)
		itemConfirm:SetFont("smallFont")
		itemConfirm:SetPlaceholderText("Reason...")
		itemConfirm:AllowInput(true)
		itemConfirm:SetPos(itemPanelSizeW/ 8, itemPanelSizeH / 4)
	elseif (string.find(string.lower(itemPrintName), "teleport")) then 

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
	if (string.find(string.lower(itemPrintName), "ban")) then
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
		if (string.find(string.lower(itemPrintName),"ban")) then
			if (timeBan and itemConfirm) then
				if (timeBan:GetText() == "") then return end
				
				LocalPlayer():ConCommand("banidplayer " .. name .. " " .. sID.. " " .. timeBan:GetText() .. " " .. itemConfirm:GetText() )
			end
		elseif (string.find(string.lower(itemPrintName), "kick")) then
			if (itemConfirm) then
				LocalPlayer():ConCommand("kickidplayer " .. sID .. " " .. itemConfirm:GetText() )
			end
		elseif (string.find(string.lower(itemPrintName) , "teleport")) then 
			if (itemX:GetText() == "") then itemX:SetText("0") end
			if (itemY:GetText() == "") then itemY:SetText("0") end
			if (itemZ:GetText() == "") then itemZ:SetText("0") end
			LocalPlayer():ConCommand("tp " .. sID .. " " .. itemX:GetText() .. " " .. itemY:GetText() .. " " .. itemZ:GetText())
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