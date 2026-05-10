local CustomChat = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- // Storages
local Modules = ReplicatedStorage.Modules
local Objects = ReplicatedStorage.Objects
local UIPrefabs = Objects.UI

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local HudGui = PlayerGui.Hud
local PhoneFrame = HudGui.Phone
local TextBox = PhoneFrame.TextBoxFrame.TextBox :: TextBox
local Messages = PhoneFrame.Messages
local ToggleButton = PhoneFrame.ToggleButton
local Notification = PhoneFrame.Notification

-- // Classes
local UI = require(script.Parent) :: any
local Tweens = require(script.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Sounds)

-- // Constants
local MAX_MESSAGES_ON_SCREEN = 8
local MAX_CHARACTER_CAP = 34


function CreateMessage(message: string)
	if CustomChat.CurrentMessageIndex == MAX_MESSAGES_ON_SCREEN then
		local deletedLabel = Messages:FindFirstChild("1")
		deletedLabel:Destroy()
		
		for i = 2, 8 do
			local label = Messages:FindFirstChild(tostring(i))
			label.Name = tostring(i - 1)
			label.LayoutOrder = i - 1
		end
	end
	
	CustomChat.CurrentMessageIndex = math.min(MAX_MESSAGES_ON_SCREEN, CustomChat.CurrentMessageIndex + 1)
	
	local TextLabel = UIPrefabs.ChatMessage:Clone()
	TextLabel.Text = message
	TextLabel.Name = tostring(CustomChat.CurrentMessageIndex)
	TextLabel.LayoutOrder = CustomChat.CurrentMessageIndex
	TextLabel.Parent = Messages
	
end


function ToggleChat(toggle: boolean, startTyping: boolean?)
	if toggle == true then
		Tweens.Tween(PhoneFrame, "Position", PhoneFrame:GetAttribute("OutPosition"), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		Tweens.Tween(ToggleButton, "BackgroundColor3", Color3.fromRGB(63, 22, 22), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		Tweens.Tween(Notification, "Size", UDim2.fromScale(0, 0), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		ToggleButton.TextLabel.Text = "<"
	else
		Tweens.Tween(PhoneFrame, "Position", PhoneFrame:GetAttribute("InPosition"), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		Tweens.Tween(ToggleButton, "BackgroundColor3", Color3.fromRGB(89, 72, 20), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		ToggleButton.TextLabel.Text = ">"
	end
end


function HandleTextBox()
	
	-- // Clear text box in case any message is still there before runtime.
	for _, possibleLabel in Messages:GetChildren() do
		if not possibleLabel:IsA("TextLabel") then continue end
		possibleLabel:Destroy()
	end
	
	local typing = false
	TextBox.Focused:Connect(function()
		typing = true
	end)
	
	TextBox.FocusLost:Connect(function(enterPressed: boolean)
		if not enterPressed or TextBox.Text == "" then typing = false return end
		
		Communicator.RemoteEvents.CustomChatMessage:FireServer(TextBox.Text)
		TextBox:CaptureFocus()
		task.wait(0.01)
		TextBox.Text = ""
	end)
	
	local chatToggled = false
	Communicator.RemoteEvents.CustomChatMessage.OnClientEvent:Connect(function(senderName: "P1" | "P2", message: string)
		if senderName == "P1" then
			CreateMessage('<font color="rgb(255,67,67)">&lt;P1&gt;</font> ' .. message)
		elseif senderName == "P2" then
			CreateMessage('<font color="rgb(67,205,255)">&lt;P2&gt;</font> ' .. message)
		end
		
		if chatToggled == false then
			Tweens.Tween(Notification, "Size", UDim2.fromScale(0.063, 0.098), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(ToggleButton.UIStroke, "Color", Color3.fromRGB(255, 34, 34), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			task.delay(0.2, function()
				Tweens.Tween(ToggleButton.UIStroke, "Color", Color3.fromRGB(171, 117, 56), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			end)
		end
	end)
	
	UserInputService.InputBegan:Connect(function(inputObject: InputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then return end
		
		if inputObject.KeyCode == Enum.KeyCode.Slash and not typing then
			if chatToggled == false then
				chatToggled = true
				ToggleChat(chatToggled)
			end
			TextBox:CaptureFocus()
			task.wait(0.01)
			TextBox.Text = ""
		elseif typing and string.len(TextBox.Text) < MAX_CHARACTER_CAP then
			Sounds:Play("Key" .. tostring(math.random(1, 21)))
		end
		
	end)
	
	TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if string.len(TextBox.Text) > MAX_CHARACTER_CAP then
			TextBox.Text = string.sub(TextBox.Text, 1, MAX_CHARACTER_CAP)
		end
	end)
	
	UI.ApplyButtonTweens(ToggleButton.Hitbox, ToggleButton, 0.03, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	ToggleButton.Hitbox.MouseButton1Click:Connect(function()
		chatToggled = not chatToggled
		ToggleChat(chatToggled)
	end)
end


function CustomChat:Init()
	-- // Disable default chat.
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	
	-- // Handle custom chat.
	CustomChat.CurrentMessageIndex = 0
	HandleTextBox()
end


return CustomChat
