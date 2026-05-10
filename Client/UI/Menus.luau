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
local ChapterSelectionGui = PlayerGui:WaitForChild("ChapterSelection")

-- // Classes
local UI = require(script.Parent) :: any
local Tweens = require(script.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Sounds)
local FlowingTextEffect = require(script.Parent.CustomEffects.FlowingTextEffect)
local Alerts = require(script.Parent.Parent.UI.Alerts)

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
	Communicator.RemoteEvents.PlayerSelectionAction.OnClientEvent:Connect(function(action: "choose" | "roleChosen", params: {})
		if action == "choose" then
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


function HandleChapterSelection()
	ChapterSelectionGui.SelectionArea.Size = UDim2.fromScale(0, 0)
	task.spawn(function()
		task.wait(2)
		FlowingTextEffect.ToggleMessage(true, ChapterSelectionGui.Header, "Waiting for players...")
		task.wait(2)
		Communicator.RemoteEvents.ChapterSelectionAction:FireServer("ScreenLoaded")
	end)
	
	local function ApplyUIAnimations()
		local function disconnectConnections(connections: {})
			for _, v in connections do
				v:Disconnect()
			end
			connections = {}
		end
		
		local connections = {}
		for _, chapterButton: Frame in ChapterSelectionGui.SelectionArea:GetChildren() do
			if not chapterButton:IsA("Frame") then continue end
			
			UI.ApplyButtonTweens(chapterButton.Hitbox, chapterButton, 0.01, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			table.insert(connections, chapterButton.Hitbox.MouseEnter:Connect(function()
				chapterButton.Description.Position = UDim2.fromScale(0.55, 0.561)
				Tweens.Tween(chapterButton.ImageLabel, "ImageTransparency", 0.7, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(chapterButton.Description, "TextTransparency", 0, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(chapterButton.Description, "Position", UDim2.fromScale(0.5, 0.561), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Tweens.Tween(chapterButton.UIStroke, "Color", Color3.fromRGB(212, 212, 212), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			end))
			
			table.insert(connections, chapterButton.Hitbox.MouseLeave:Connect(function()
				Tweens.Tween(chapterButton.ImageLabel, "ImageTransparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(chapterButton.Description, "TextTransparency", 1, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(chapterButton.UIStroke, "Color", Color3.fromRGB(0, 0, 0), 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			end))
			
			table.insert(connections, chapterButton.Hitbox.MouseButton1Click:Connect(function()
				disconnectConnections(connections)
				Communicator.RemoteEvents.ChapterSelectionAction:FireServer("VotedChapter", chapterButton.Name)
			end))
		end
	end
	
	local function ShowSelectableChapters()
		FlowingTextEffect.ToggleMessage(false, ChapterSelectionGui.Header)
		task.wait(1.5)
		FlowingTextEffect.ToggleMessage(true, ChapterSelectionGui.Header, "Vote for a chapter..")
		task.wait(1)
		Tweens.Tween(ChapterSelectionGui.SelectionArea, "Size", UDim2.fromScale(0.5, 0.5), 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		task.wait(1.5)
		ApplyUIAnimations()
	end
	
	local totalVoted = 0
	local function PlayerVoted(voterUserId: number, chapterName: string)
		totalVoted += 1
		local thumbnailId = Players:GetUserThumbnailAsync(voterUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		local button = ChapterSelectionGui.SelectionArea:FindFirstChild(chapterName)
		local voterImageLabel = button.Voters:FindFirstChild("Voter" .. tostring(totalVoted))
		voterImageLabel.Image = thumbnailId
		voterImageLabel.Size = UDim2.fromScale(0, 0)
		voterImageLabel.Visible = true
		Tweens.Tween(voterImageLabel, "Size", UDim2.fromScale(0.6, 0.6), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		
	end
	
	
	local function toggleChosenChapter(toggle: boolean, votedChapter: number)
		local button = ChapterSelectionGui.SelectionArea:FindFirstChild("Chapter" .. tostring(votedChapter))
		if toggle == true then
			Tweens.Tween(button.Header, "TextColor3", Color3.fromRGB(109, 255, 41), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		else
			Tweens.Tween(button.Header, "TextColor3", Color3.fromRGB(255, 255, 255), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
	end
	

	local function shuffleChosenChapter(votedChapter: number)
		task.spawn(function()
			Alerts:SendAlert("Voting tied! Picking random chapter!",
				{
					textColor = Color3.fromRGB(255, 198, 66),
					timeToDisappear = 4
				})
		end)
		
		task.wait(1.5)
		local startTime = 0.5
		local endTime = 0.05
		local chapterNr = 2
		local tickCount = 17
		for i = 1, tickCount do
			Sounds:Play("RandomTick")
			toggleChosenChapter(true, chapterNr)

			local t = (i - 1) / (tickCount - 1)
			local timeBetween = startTime * (endTime / startTime) ^ t
			task.wait(timeBetween)

			if i < tickCount then
				toggleChosenChapter(false, chapterNr)
			end

			if chapterNr == 1 then
				chapterNr = 2
			else
				chapterNr = 1
			end
		end
	end
	
	Communicator.RemoteEvents.ChapterSelectionAction.OnClientEvent:Connect(function(action: string, ...)
		if action == "Start" then
			ShowSelectableChapters()
			
		elseif action == "Voted" then
			PlayerVoted(...)
			
		elseif action == "VotingFinished" then
			local votedChapter, tie = ...
			task.wait(1)
			if tie then
				shuffleChosenChapter(votedChapter)
			else
				Sounds:Play("RandomTick")
				toggleChosenChapter(true, votedChapter)
			end
			
			task.wait(2)
			
			Tweens.Tween(ChapterSelectionGui.SelectionArea, "Size", UDim2.fromScale(0, 0), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			FlowingTextEffect.ToggleMessage(false, ChapterSelectionGui.Header)
			
			task.wait(0.5)
			PlayerSelectionGui.Enabled = true
			ChapterSelectionGui.Enabled = false
			HandlePlayerSelection()
		end
	end)
end


function Menus:Init()
	
	if ChapterSelectionGui.Enabled == true then
		HandleChapterSelection()
	end
	
end

return Menus
