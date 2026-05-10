local CodePuzzle = {}

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
local PuzzleFrame = PuzzlesGui.CodePuzzle
local ExitPuzzleButton = PuzzleFrame.Exit

-- // Workspace
local Puzzles = workspace:WaitForChild("Puzzles")
local CodePuzzles = Puzzles:WaitForChild("CodePuzzles")
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
		Communicator.RemoteEvents.PuzzleAction:FireServer("CodePuzzle", "Completed", puzzle)
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

	local frame = puzzle.Numbers.Code.SurfaceGui.Frame
	Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(255, 205, 119),
		0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	frame.TextLabel.Text = "_"
	for i = 1, puzzle.Configuration:GetAttribute("CodeLength") - 1 do
		frame.TextLabel.Text = frame.TextLabel.Text .. " _"
	end
end


function AccessPuzzle(puzzle: Model)
	PuzzleFrame.Visible = true
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Tweens.Tween(CurrentCamera, "CFrame", puzzle.CameraPart.CFrame, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	puzzle.Interactable:SetAttribute("Visible", false)

	local buttonConnection
	local animationsConnections = {}

	local codeFrame = puzzle.Numbers.Code.SurfaceGui.Frame
	local configuration = puzzle.Configuration
	local writtenCode = ""

	local function showFormattedCode()
		codeFrame.TextLabel.Text = ""
		for i = 1, configuration:GetAttribute("CodeLength") do
			local char = string.sub(writtenCode, i, i)
			if char ~= "" then
				codeFrame.TextLabel.Text = codeFrame.TextLabel.Text .. char .. " "
			else
				codeFrame.TextLabel.Text = codeFrame.TextLabel.Text .. "_ "
			end
		end
		local len = #codeFrame.TextLabel.Text
		codeFrame.TextLabel.Text = string.sub(codeFrame.TextLabel.Text, 1, len - 1)
	end

	local keyToDigit = {
		[Enum.KeyCode.One] = "1",       [Enum.KeyCode.Two] = "2",
		[Enum.KeyCode.Three] = "3",     [Enum.KeyCode.Four] = "4",
		[Enum.KeyCode.Five] = "5",      [Enum.KeyCode.Six] = "6",
		[Enum.KeyCode.Seven] = "7",     [Enum.KeyCode.Eight] = "8",
		[Enum.KeyCode.Nine] = "9",      [Enum.KeyCode.Zero] = "0",
		[Enum.KeyCode.KeypadOne] = "1", [Enum.KeyCode.KeypadTwo] = "2",
		[Enum.KeyCode.KeypadThree] = "3", [Enum.KeyCode.KeypadFour] = "4",
		[Enum.KeyCode.KeypadFive] = "5",  [Enum.KeyCode.KeypadSix] = "6",
		[Enum.KeyCode.KeypadSeven] = "7", [Enum.KeyCode.KeypadEight] = "8",
		[Enum.KeyCode.KeypadNine] = "9",  [Enum.KeyCode.KeypadZero] = "0",
	}

	table.insert(animationsConnections,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end

			local digit = keyToDigit[input.KeyCode]
			if digit then
				Sounds:Play("ButtonPressed")
				if #writtenCode < configuration:GetAttribute("CodeLength") then
					writtenCode = writtenCode .. digit
					showFormattedCode()
				end
				return
			end

			if input.KeyCode == Enum.KeyCode.Backspace then
				Sounds:Play("ButtonPressed")
				writtenCode = string.sub(writtenCode, 1, -2)
				showFormattedCode()
				return
			end

			if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
				Sounds:Play("ButtonPressed")
				if writtenCode == configuration:GetAttribute("GeneratedCode") then
					Tweens.Tween(puzzle.Numbers.Code.SurfaceGui.Frame, "BackgroundColor3",
						Color3.fromRGB(32, 255, 32), 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					CompletePuzzle(puzzle)
				else
					Tweens.Tween(puzzle.Numbers.Code.SurfaceGui.Frame, "BackgroundColor3",
						Color3.fromRGB(255, 76, 76), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
					task.wait(0.1)
					Sounds:Play("Error1")
					writtenCode = ""
					showFormattedCode()
					Tweens.Tween(puzzle.Numbers.Code.SurfaceGui.Frame, "BackgroundColor3",
						Color3.fromRGB(255, 205, 119), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end
				return
			end
		end)
	)

	for _, part: Part in puzzle.Numbers:GetChildren() do
		if part.Name == "Reset" or part.Name == "Enter" or part.Name == "Code" then continue end
		local frame = part.SurfaceGui.Frame
		local animations = UI.ApplyButtonTweens(frame.Hitbox, frame, 0.05, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		for _, connection in animations do
			table.insert(animationsConnections, connection)
		end

		table.insert(animationsConnections,
			frame.Hitbox.MouseButton1Click:Connect(function()
				Sounds:Play("ButtonPressed")
				local pressedNumber = part.Name
				if #writtenCode == configuration:GetAttribute("CodeLength") then
					return
				end
				writtenCode = writtenCode .. pressedNumber
				showFormattedCode()
			end)
		)
	end

	table.insert(animationsConnections,
		puzzle.Numbers.Reset.SurfaceGui.Frame.Hitbox.MouseButton1Click:Connect(function()
			Sounds:Play("ButtonPressed")
			writtenCode = ""
			showFormattedCode()
		end)
	)

	table.insert(animationsConnections,
		puzzle.Numbers.Enter.SurfaceGui.Frame.Hitbox.MouseButton1Click:Connect(function()
			Sounds:Play("ButtonPressed")

			if writtenCode == configuration:GetAttribute("GeneratedCode") then
				Tweens.Tween(puzzle.Numbers.Code.SurfaceGui.Frame, "BackgroundColor3",
					Color3.fromRGB(32, 255, 32), 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				CompletePuzzle(puzzle)
			else
				Tweens.Tween(puzzle.Numbers.Code.SurfaceGui.Frame, "BackgroundColor3",
					Color3.fromRGB(255, 76, 76), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.wait(0.1)
				Sounds:Play("Error1")
				writtenCode = ""
				showFormattedCode()
				Tweens.Tween(puzzle.Numbers.Code.SurfaceGui.Frame, "BackgroundColor3",
					Color3.fromRGB(255, 205, 119), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end)
	)

	buttonConnection = ExitPuzzleButton.Hitbox.MouseButton1Click:Connect(function()
		buttonConnection:Disconnect()
		for _, connection: RBXScriptConnection in animationsConnections do
			connection:Disconnect()
		end

		ExitPuzzle(puzzle)
	end)
end


function CodePuzzle:Init()
	for _, puzzle in CodePuzzles:GetChildren() do
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

return CodePuzzle