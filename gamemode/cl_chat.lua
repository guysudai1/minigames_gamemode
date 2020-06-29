customChat = {}

customChat.Frame = vgui.Create("DFrame")
customChat.Frame:SetTitle("")
customChat.input = vgui.Create("DTextEntry", customChat.Frame)
customChat.richText = vgui.Create("RichText", customChat.Frame)
customChat.richText:SetVerticalScrollbarEnabled(true)
customChat.Frame:ShowCloseButton(false)
customChat.Frame:SetDraggable(false)
customChat.Frame:Hide()
customChat.input:Hide()
customChat.richText:Hide()
customChat.antiSpam = CurTime()
customChat.startLeft = {}
customChat.startLeft.X, customChat.startLeft.Y = nil, nil
function customChat.Frame:Think()
	if (input.IsMouseDown(MOUSE_LEFT) and (customChat.startLeft.X and customChat.startLeft.Y)) then
		
		local beginPosX, beginPosY = self:GetPos()
		local mouseX, mouseY = customChat.startLeft.X, customChat.startLeft.Y
		local frameWidth, frameHeight = self:GetSize()
		if (not (mouseX >= beginPosX and mouseX <= (beginPosX + frameWidth)) or not (mouseY >= beginPosY and mouseY <= (beginPosY + frameHeight))) then
			customChat:CloseChat()	
		end
	else
		customChat.startLeft.X, customChat.startLeft.Y = gui.MousePos()
	end
	if (self:IsActive()) then
		if (input.IsKeyDown(KEY_ESCAPE)) then
			customChat:CloseChat()
			gui.HideGameUI()
		end
	end
end

function customChat:CloseChat()
	self.Frame:Hide()
	self.input:Hide()
	self.richText:Hide()

	self.Frame:SetMouseInputEnabled(false)
	self.Frame:SetKeyboardInputEnabled(false)
	self.input:KillFocus()
	gui.EnableScreenClicker(false)
	gamemode.Call( "FinishChat" )

	self.input:SetText("")
	gamemode.Call( "ChatTextChanged", "" )
	if (AMenu.DTabSheet) then
		gui.EnableScreenClicker(true)
	end

end


function GM:StartChat()
	return true
end

function GM:FinishChat()
	return true
end

function customChat:OpenChat()

	self.Frame:Show()
	self.input:Show()
	self.richText:Show()

	self.Frame:SetSize(400,500)
	self.Frame:SetPos(2,ScrH() - 500)
	self.richText:Dock(FILL)
	self.input:Dock(BOTTOM)

	
	self.Frame:MakePopup()
	self.input:RequestFocus()
	gamemode.Call( "StartChat" )

end

function customChat.input:OnKeyCodeTyped(code)
	if (code == KEY_ESCAPE) then
		customChat:CloseChat()
		gui.HideGameUI()
	elseif (code == KEY_ENTER) then 
		if (CurTime() - customChat.antiSpam > 1.5) then
			customChat.antiSpam = CurTime()
			if (string.Trim(self:GetValue()) ~= "") then
				LocalPlayer():ConCommand("say " .. self:GetValue())
			end
			gamemode.Call( "ChatTextChanged", "" )
		end
		
	end
end


function chat.AddText( ... )
	local args = { ... }

	for _, arg in pairs(args) do
		if (type(arg) == "table") then
			customChat.richText:InsertColorChange(arg.r, arg.g, arg.b, 255)
		elseif (type(arg) == "string") then 
			customChat.richText:AppendText(arg)
		elseif (arg:IsPlayer()) then
			customChat.richText:InsertColorChange(0,0,0,255)
			customChat.richText:AppendText(arg:Name() .. "[" .. arg:SteamID() .. "]")
		end
	end

	customChat.richText:AppendText("\n")

end

hook.Add("ChatTextChanged", "changeText", function(newText)
	customChat.input:SetText(newText)
end)