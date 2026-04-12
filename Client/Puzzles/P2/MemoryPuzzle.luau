local MemoryPuzzle = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local PuzzlesGui = PlayerGui.Puzzles
local PuzzleFrame = PuzzlesGui.MemoryPuzzle
local ExitPuzzleButton = PuzzleFrame.Exit

-- // Workspace
local Puzzles = workspace:WaitForChild("Puzzles")
local MemoryPuzzles = Puzzles:WaitForChild("MemoryPuzzles")
local CurrentCamera = workspace.CurrentCamera

-- // Classes
local Interactables = require(script.Parent.Parent.Parent.UI.Interactables)
local UI = require(script.Parent.Parent.Parent.UI)
local Tweens = require(script.Parent.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Parent.Sounds)


function getTypeOfPlayer()
	return LocalPlayer:GetAttribute("PlayerIndex")
end


function lerp(a, b, c)
	return a + (b - a) * c
end


function getRandomSequence(numbers, len)
	local t = {}
	for i = 1, len do
		t[i] = numbers[math.random(1, #numbers)]
	end

	return t
end

function getRandomPitchOctaveSequence(len, pitchTable: {number})
	local t = {}

	for i = 1, len do
		t[i] = math.random(pitchTable[1], pitchTable[2]) / pitchTable[3]
	end
	
	return t
end


function CompletePuzzle(puzzle: Model)
	task.spawn(function()
		Communicator.RemoteEvents.PuzzleAction:FireServer("MemoryPuzzle", "Completed", puzzle)
		task.wait(2)
		LocalPlayer:SetAttribute("inPuzzle", false)
		PuzzleFrame.Visible = false
		CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end


function ExitPuzzle(puzzle: Model)
	LocalPlayer:SetAttribute("inPuzzle", false)
	PuzzleFrame.Visible = false
	CurrentCamera.CameraType = Enum.CameraType.Custom
	puzzle.Interactable:SetAttribute("Visible", true)
	for _, thisFrame: Frame in puzzle.LeftCounter.SurfaceGui.Frame:GetChildren() do
		if not thisFrame:IsA("Frame") then continue end
		Tweens.Tween(thisFrame, "BackgroundColor3", Color3.fromRGB(106, 106, 106), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
	
	for _, thisFrame: Frame in puzzle.RightCounter.SurfaceGui.Frame:GetChildren() do
		if not thisFrame:IsA("Frame") then continue end
		Tweens.Tween(thisFrame, "BackgroundColor3", Color3.fromRGB(106, 106, 106), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
end


function AccessPuzzle(puzzle: Model)
	PuzzleFrame.Visible = true
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Tweens.Tween(CurrentCamera, "CFrame", puzzle.CameraPart.CFrame, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	puzzle.Interactable:SetAttribute("Visible", false)
	
	local exited = false
	local buttonConnection
	local animationsConnections = {}
	
	local bigOrderIndex = 1
	local smallOrderIndex = 0
	local generatedOrder = getRandomSequence({1, 2, 3, 4, 5, 6, 7, 8, 9}, 5)
	local generatedPitchOctaves = {1, 1.2, 1.4, 1.6, 1.8}
	
	local function updateCounters()
		for _, frame: Frame in puzzle.LeftCounter.SurfaceGui.Frame:GetChildren() do
			if not frame:IsA("Frame") then continue end
			if tonumber(frame.Name) <= bigOrderIndex then
				Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(9, 135, 20), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			else
				Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(106, 106, 106), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end
		
		for _, frame: Frame in puzzle.RightCounter.SurfaceGui.Frame:GetChildren() do
			if not frame:IsA("Frame") then continue end
			if tonumber(frame.Name) <= smallOrderIndex then
				Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(9, 135, 20), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			else
				Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(106, 106, 106), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end
	end
	
	local displayingSequence = false
	local function displayIndicatorSequence()
		task.spawn(function()
			displayingSequence = true
			task.wait(1)
			for i = 1, bigOrderIndex do
				if exited == true then return end

				local frame = puzzle.Indicators:FindFirstChild(tostring(generatedOrder[i])).SurfaceGui.Frame
				Sounds:PlayWithPitch("MemoryIndicator", generatedPitchOctaves[i])
				Tweens.Tween(frame, "BackgroundTransparency", 0, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.wait(0.3)
				Tweens.Tween(frame, "BackgroundTransparency", 1, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.wait(0.3)
			end
			displayingSequence = false
		end)
	end
	
	updateCounters()
	displayIndicatorSequence()
	
	local function complete()
		exited = true
		buttonConnection:Disconnect()
		for _, connection: RBXScriptConnection in animationsConnections do
			connection:Disconnect()
		end
		CompletePuzzle(puzzle)
	end
	
	local function flashButton(frame, color: Color3)
		task.spawn(function()
			color = color or Color3.fromRGB(63, 158, 217)
			Tweens.Tween(frame, "BackgroundColor3", color, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.wait(0.3)
			Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(94, 94, 94), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end)
	end
	
	for _, part: Part in puzzle.Buttons:GetChildren() do
		local buttonIndex = tonumber(part.Name)
		local frame = part.SurfaceGui.Frame
		local animations = UI.ApplyButtonTweens(frame.Hitbox, frame, 0.05, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		
		for _, connection in animations do
			table.insert(animationsConnections, connection)
		end
		
		table.insert(animationsConnections,
			frame.Hitbox.MouseButton1Click:Connect(function()
				if displayingSequence then return end
				local correctIndex = generatedOrder[smallOrderIndex + 1]
				
				if buttonIndex == correctIndex then
					flashButton(frame)
					Sounds:PlayWithPitch("MemoryButton", generatedPitchOctaves[smallOrderIndex + 1])
				else
					flashButton(frame, Color3.fromRGB(255, 58, 58))
				end
				
				if buttonIndex == correctIndex then
					smallOrderIndex += 1
					updateCounters()
					
					task.wait(0.3)
					
					if smallOrderIndex == bigOrderIndex then
						smallOrderIndex = 0
						bigOrderIndex += 1
						
						if bigOrderIndex > 5 then
							complete()
							return
						end
						
						displayIndicatorSequence()
					end
				else
					generatedOrder = getRandomSequence({1, 2, 3, 4, 5, 6, 7, 8, 9}, 5)
					Sounds:Play("MemoryButtonError")
					smallOrderIndex = 0
					bigOrderIndex = 1
					displayIndicatorSequence()
				end
				
				updateCounters()
				
			end)
		)
	end
	
	buttonConnection = ExitPuzzleButton.Hitbox.MouseButton1Click:Connect(function()
		exited = true
		buttonConnection:Disconnect()
		for _, connection: RBXScriptConnection in animationsConnections do
			connection:Disconnect()
		end
		
		ExitPuzzle(puzzle)
	end)
end


function MemoryPuzzle:Init()
	for _, puzzle in MemoryPuzzles:GetChildren() do
		if not puzzle:IsA("Model") then continue end
		Interactables.OnInteractablePressed(puzzle:WaitForChild("Interactable"), Enum.KeyCode.E):Connect(function()
			if getTypeOfPlayer() == "P1" then
				UI.alertPlayerTypeIncompatible()
				return
			end
			if LocalPlayer:GetAttribute("inPuzzle") then return end
			LocalPlayer:SetAttribute("inPuzzle", true)
			AccessPuzzle(puzzle)
		end)
	end
	UI.ApplyButtonTweens(ExitPuzzleButton.Hitbox, ExitPuzzleButton, 0.005, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
end

return MemoryPuzzle
