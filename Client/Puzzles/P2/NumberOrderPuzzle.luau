local NumberOrderPuzzle = {}

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
local PuzzleFrame = PuzzlesGui.NumberOrderPuzzle
local ExitPuzzleButton = PuzzleFrame.Exit

-- // Workspace
local Puzzles = workspace:WaitForChild("Puzzles")
local NumberOrderPuzzles = Puzzles:WaitForChild("NumberOrderPuzzles")
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


function CompletePuzzle(puzzle: Model)
	task.spawn(function()
		Communicator.RemoteEvents.PuzzleAction:FireServer("NumberOrderPuzzle", "Completed", puzzle)
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
	for _, part: Part in puzzle.Numbers:GetChildren() do
		local thisFrame = part.SurfaceGui.Frame
		Tweens.Tween(thisFrame, "BackgroundColor3", Color3.fromRGB(255, 97, 97), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
end


function AccessPuzzle(puzzle: Model)
	PuzzleFrame.Visible = true
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Tweens.Tween(CurrentCamera, "CFrame", puzzle.CameraPart.CFrame, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	puzzle.Interactable:SetAttribute("Visible", false)
	
	local orderIndex = 0
	local buttonConnection
	local animationsConnections = {}
	
	for _, part: Part in puzzle.Numbers:GetChildren() do
		local frame = part.SurfaceGui.Frame
		local animations = UI.ApplyButtonTweens(frame.Hitbox, frame, 0.05, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		
		for _, connection in animations do
			table.insert(animationsConnections, connection)
		end
		
		table.insert(animationsConnections,
			frame.Hitbox.MouseButton1Click:Connect(function()
				if orderIndex + 1 == tonumber(part.Name) then
					orderIndex += 1
					frame.BackgroundColor3 = Color3.fromRGB(98, 255, 55)
					
					if orderIndex == 12 then
						Sounds:Play("ButtonPressed")
						buttonConnection:Disconnect()
						for _, connection: RBXScriptConnection in animationsConnections do
							connection:Disconnect()
						end
						CompletePuzzle(puzzle)
					else
						task.spawn(function()
							Sounds:Play("ButtonPressed")
							task.wait(0.2)
							Sounds["NumberOrderBeep"].PitchShiftSoundEffect.Octave = 0.7 + orderIndex * 0.04
							Sounds:Play("NumberOrderBeep")
						end)
					end

				else
					Sounds:Play("Error1")
					orderIndex = 0
					for _, part: Part in puzzle.Numbers:GetChildren() do
						local thisFrame = part.SurfaceGui.Frame
						Tweens.Tween(thisFrame, "BackgroundColor3", Color3.fromRGB(255, 97, 97), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					end
				end
			end)
		)
	end
	
	buttonConnection = ExitPuzzleButton.Hitbox.MouseButton1Click:Connect(function()
		buttonConnection:Disconnect()
		for _, connection: RBXScriptConnection in animationsConnections do
			connection:Disconnect()
		end
		
		ExitPuzzle(puzzle)
	end)
end


function NumberOrderPuzzle:Init()
	for _, puzzle in NumberOrderPuzzles:GetChildren() do
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

return NumberOrderPuzzle
