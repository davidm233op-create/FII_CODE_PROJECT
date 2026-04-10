local Menus = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Storages
local Modules = ReplicatedStorage.Modules
local Objects = ReplicatedStorage.Objects

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local PlayerSelectionGui = PlayerGui.PlayerSelection

-- // Classes
local UI = require(script.Parent) :: any
local Tweens = require(script.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Sounds)
local FlowingTextEffect = require(script.Parent.CustomEffects.FlowingTextEffect)


function GetPlayerIndex()
	return LocalPlayer:GetAttribute("PlayerIndex")
end


function HandlePlayerSelection()
	
	
	local selectionArea = PlayerSelectionGui.SelectionArea
	
	local function toggleBigDescription(toggle: boolean, button: Frame, tweenTime: number)
		tweenTime = tweenTime or 0.2
		if toggle == true then
			local bigDescription = PlayerSelectionGui[button.Name .. "Description"] :: TextLabel
			bigDescription.TextTransparency = 1
			bigDescription.Position = UDim2.fromScale(0.5, 0.85)
			bigDescription.Rotation = 5
			
			Tweens.Tween(bigDescription, "TextTransparency", 0, tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(bigDescription, "Position", UDim2.fromScale(0.5, 0.82), tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(bigDescription, "Rotation", 0, tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		else
			local bigDescription = PlayerSelectionGui[button.Name .. "Description"] :: TextLabel
			Tweens.Tween(bigDescription, "TextTransparency", 1, tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(bigDescription, "Position", UDim2.fromScale(0.5, 0.85), tweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		end
	end
	
	local function toggleRoleDescription(toggle: boolean, button: Frame)
		if toggle == true then
			button.Description.TextTransparency = 1
			button.Description.Position = UDim2.fromScale(0.5, 1.1)
			button.Description.Rotation = 15

			Tweens.Tween(button.Description, "TextTransparency", 0, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button.Description, "Position", UDim2.fromScale(0.5, 1.222), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button.Description, "Rotation", 0, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			
			toggleBigDescription(true, button)
		else
			Tweens.Tween(button.Description, "TextTransparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button.Description, "Position", UDim2.fromScale(0.5, 1.1), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			
			toggleBigDescription(false, button)
		end
	end

	local function applySelectionButtonTweens(button: Frame)
		UI.ApplyButtonTweens(button.Hitbox, button, 0.05, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local connections = {}
		connections[1] = button.Hitbox.MouseEnter:Connect(function()
			Tweens.Tween(button.InnerStroke, "Transparency", 0.8, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

			if button.Name == "P1" then
				Tweens.Tween(button, "BackgroundColor3", Color3.fromRGB(49, 21, 21), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			elseif button.Name == "P2" then
				Tweens.Tween(button, "BackgroundColor3", Color3.fromRGB(16, 52, 80), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			end

			toggleRoleDescription(true, button)
		end)

		connections[2] = button.Hitbox.MouseLeave:Connect(function()
			Tweens.Tween(button.InnerStroke, "Transparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button, "BackgroundColor3", Color3.fromRGB(26, 26, 26), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			toggleRoleDescription(false, button)
		end)
		
		return connections
	end

	
	local p1SelectConnection, p2SelectConnection, p1AnimationConnections, p2AnimationConnections
	local function cleanConnections()
		p1SelectConnection:Disconnect()
		p2SelectConnection:Disconnect()
		for _, connection: RBXScriptConnection in p1AnimationConnections do
			connection:Disconnect()
		end
		for _, connection: RBXScriptConnection in p2AnimationConnections do
			connection:Disconnect()
		end
	end
	
	local togglingFlowingText = false
	local waitingForOtherPlayer = false
	Communicator.RemoteEvents.PlayerSelectionAction.OnClientEvent:Connect(function(action: "wait" | "choose" | "roleChosen", params: {})
		if action == "wait" then
			waitingForOtherPlayer = true
			togglingFlowingText = true
			FlowingTextEffect.ToggleMessage(true, PlayerSelectionGui.Header, "Waiting for another player...")
			togglingFlowingText = false
			
		elseif action == "choose" then
			if togglingFlowingText == true then
				while togglingFlowingText do
					task.wait(0.1)
				end
				
				task.wait(2)
			end
			
			if waitingForOtherPlayer then
				waitingForOtherPlayer = false
				FlowingTextEffect.ToggleMessage(false, PlayerSelectionGui.Header)
				task.wait(1)
			end
			
			FlowingTextEffect.ToggleMessage(true, PlayerSelectionGui.Header, "Choose your player")
			
			for _, frame in selectionArea:GetChildren() do
				if not frame:IsA("Frame") then continue end
				Tweens.Tween(frame, "BackgroundTransparency", 0.5, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.UIStroke, "Transparency", 0, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.TextLabel, "TextTransparency", 0, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame, "Size", UDim2.fromScale(0.285, 0.751), 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				task.wait(0.3)
			end
			
			task.wait(1)
			p1AnimationConnections = applySelectionButtonTweens(selectionArea.P1)
			p2AnimationConnections = applySelectionButtonTweens(selectionArea.P2)
			
			local function cleanConnections()
				p1SelectConnection:Disconnect()
				p2SelectConnection:Disconnect()
				for _, connection: RBXScriptConnection in p1AnimationConnections do
					connection:Disconnect()
				end
				for _, connection: RBXScriptConnection in p2AnimationConnections do
					connection:Disconnect()
				end
			end
			
			p1SelectConnection = selectionArea.P1.Hitbox.MouseButton1Click:Connect(function()
				cleanConnections()
				Communicator.RemoteEvents.PlayerSelectionAction:FireServer("choseP1")
				
				local button = selectionArea.P1
				Tweens.Tween(button.InnerStroke, "Transparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(button, "BackgroundColor3", Color3.fromRGB(26, 26, 26), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(button.Lock, "ImageTransparency", 0, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(button.TextLabel, "TextTransparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				
				Tweens.Tween(button.FlashFrame, "BackgroundTransparency", 0.8, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Tweens.Tween(button.FlashFrame, "Size", UDim2.fromScale(1.5, 1.5), 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.2, function()
					Tweens.Tween(button.FlashFrame, "BackgroundTransparency", 1, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)
			end)
			
			p2SelectConnection = selectionArea.P2.Hitbox.MouseButton1Click:Connect(function()
				cleanConnections()
				Communicator.RemoteEvents.PlayerSelectionAction:FireServer("choseP2")
				
				local button = selectionArea.P2
				Tweens.Tween(button.InnerStroke, "Transparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(button, "BackgroundColor3", Color3.fromRGB(26, 26, 26), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(button.Lock, "ImageTransparency", 0, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(button.TextLabel, "TextTransparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				
				Tweens.Tween(button.FlashFrame, "BackgroundTransparency", 0.8, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Tweens.Tween(button.FlashFrame, "Size", UDim2.fromScale(1.5, 1.5), 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.2, function()
					Tweens.Tween(button.FlashFrame, "BackgroundTransparency", 1, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)
			end)
			
		elseif action == "otherPlayerChose" then
			if params.player == LocalPlayer then return end

			if params.role == "P1" then
				p1SelectConnection:Disconnect()
				for _, connection: RBXScriptConnection in p1AnimationConnections do
					connection:Disconnect()
				end
			elseif params.role == "P2" then
				p2SelectConnection:Disconnect()
				for _, connection: RBXScriptConnection in p2AnimationConnections do
					connection:Disconnect()
				end
			end
			
			local button = selectionArea[params.role] :: Frame
			Tweens.Tween(button.InnerStroke, "Transparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button, "BackgroundColor3", Color3.fromRGB(26, 26, 26), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button.Lock, "ImageTransparency", 0, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(button.TextLabel, "TextTransparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			
			Tweens.Tween(button.FlashFrame, "BackgroundTransparency", 0.8, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			Tweens.Tween(button.FlashFrame, "Size", UDim2.fromScale(1.5, 1.5), 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.delay(0.2, function()
				Tweens.Tween(button.FlashFrame, "BackgroundTransparency", 1, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)
			toggleBigDescription(false, button)
			
			
		elseif action == "bothPlayersChose" then
			
			task.wait(3)
			
			if GetPlayerIndex() == "P1" then
				toggleBigDescription(false, selectionArea.P1, 1)
			elseif GetPlayerIndex() == "P2" then
				toggleBigDescription(false, selectionArea.P2, 1)
			end
			
			task.wait(0.5)
			
			for _, frame in selectionArea:GetChildren() do
				if not frame:IsA("Frame") then continue end
				Tweens.Tween(frame, "BackgroundTransparency", 1, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.UIStroke, "Transparency", 1, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.TextLabel, "TextTransparency", 1, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame, "Size", UDim2.fromScale(0.285, 0.489), 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.Description, "TextTransparency", 1, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.Lock, "ImageTransparency", 1, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				task.wait(0.3)
			end
			
			FlowingTextEffect.ToggleMessage(false, PlayerSelectionGui.Header)
			task.wait(1)
			PlayerSelectionGui.Header:SetAttribute("DefaultPosition", UDim2.fromScale(0.5, 0.5))
			PlayerSelectionGui.Header.Position = UDim2.fromScale(0.5, 0.5)
			
			FlowingTextEffect.ToggleMessage(true, PlayerSelectionGui.Header, "Good luck!")
			
			task.wait(2)
			FlowingTextEffect.ToggleMessage(false, PlayerSelectionGui.Header)
			
			Tweens.Tween(PlayerSelectionGui.Background, "BackgroundTransparency", 1, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			
		end
	end)
	

end


function Menus:Init()
	
	if PlayerSelectionGui.Enabled == true then
		HandlePlayerSelection()
	end
	
end

return Menus
