local CablePuzzle = {}

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
local PuzzleFrame = PuzzlesGui.CablePuzzle
local ExitPuzzleButton = PuzzleFrame.Exit

-- // Workspace
local Puzzles = workspace:WaitForChild("Puzzles")
local CablePuzzles = Puzzles:WaitForChild("CablePuzzles")
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
		local cablesToReplicate = {}
		for _, v in puzzle.CableHolder:GetChildren() do
			table.insert(cablesToReplicate,
				{
					CFrame = v.CFrame,
					Size = v.Size,
					Color = v.Color
				}
			)
		end
		Communicator.RemoteEvents.PuzzleAction:FireServer("CablePuzzle", "Completed", puzzle, cablesToReplicate)
		cablesToReplicate = puzzle.CableHolder:GetChildren()
		
		Sounds:Play("PannelComplete")
		task.wait(2)
		PuzzleFrame.Visible = false
		CurrentCamera.CameraType = Enum.CameraType.Custom
		for _, v in cablesToReplicate do
			v:Destroy()
		end
	end)
end


function ExitPuzzle(puzzle: Model)
	PuzzleFrame.Visible = false
	CurrentCamera.CameraType = Enum.CameraType.Custom
	puzzle.Interactable:SetAttribute("Visible", true)
end


function AccessPuzzle(puzzle: Model)
	local cableHolder = puzzle.CableHolder

	PuzzleFrame.Visible = true
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Tweens.Tween(CurrentCamera, "CFrame", puzzle.CameraPart.CFrame, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	puzzle.Interactable:SetAttribute("Visible", false)

	local holdConnection
	local inputConnection1
	local buttonConnection
	
	local cables = {} :: {[BasePart]: BasePart}
	local function getTotalCompleted()
		local k = 0
		for _, cable in cables do
			k += 1
		end
		return k
	end
	
	local currentCable: BasePart
	local currentLeftPart: BasePart
	inputConnection1 = UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if Mouse.Target == nil or Mouse.Target.Parent ~= puzzle.Left then return end
		if holdConnection then holdConnection:Disconnect() end

		currentLeftPart = Mouse.Target
		if cables[currentLeftPart] then cables[currentLeftPart]:Destroy() cables[currentLeftPart] = nil  end

		currentCable = Instance.new("Part")
		currentCable.Shape = Enum.PartType.Cylinder
		currentCable.Material = Enum.Material.Fabric
		currentCable.Color = Mouse.Target.Color
		currentCable.Anchored = true
		currentCable.CanQuery = false
		currentCable.CanCollide = false
		currentCable.CanTouch = false
		currentCable.Parent = cableHolder
		
		Sounds:Play("PannelClick")

		local function move()
			local targetPosition
			if Mouse.Target == nil then return end
			if Mouse.Target.Parent == puzzle.Right then
				targetPosition = Mouse.Target.Position
			elseif Mouse.Target == puzzle.BackgroundPart then
				targetPosition = Mouse.Hit.Position
			else
				return
			end
			local length = (currentLeftPart.Position - targetPosition).Magnitude
			currentCable.CFrame = CFrame.new(currentLeftPart.Position:Lerp(targetPosition, 0.5), targetPosition) * CFrame.fromOrientation(0, math.rad(90), 0)
			currentCable.Size = Vector3.new(length, 0.25, 0.25)
		end

		holdConnection = Mouse.Move:Connect(move)
	end)

	local inputConnection2
	inputConnection2 = UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if currentLeftPart == nil then return end

		if holdConnection then holdConnection:Disconnect() holdConnection = nil end

		if Mouse.Target == nil or Mouse.Target.Parent ~= puzzle.Right then
			if currentCable then currentCable:Destroy() Sounds:Play("PannelClick") end
			currentCable = nil
			currentLeftPart = nil
			return
		end

		if currentLeftPart.Color == Mouse.Target.Color then
			cables[currentLeftPart] = currentCable
			if getTotalCompleted() == 4 then
				buttonConnection:Disconnect()
				inputConnection1:Disconnect()
				inputConnection2:Disconnect()
				if holdConnection then holdConnection:Disconnect() end
				CompletePuzzle(puzzle)
			else
				Sounds:Play("PannelConnect")
			end
		else
			if currentCable then currentCable:Destroy() end
		end

		currentCable = nil
		currentLeftPart = nil
	end)

	buttonConnection = ExitPuzzleButton.Hitbox.MouseButton1Click:Connect(function()
		buttonConnection:Disconnect()
		inputConnection1:Disconnect()
		inputConnection2:Disconnect()
		if holdConnection then holdConnection:Disconnect() end
		for _, cable in puzzle.CableHolder:GetChildren() do
			cable:Destroy()
		end
		ExitPuzzle(puzzle)
	end)
end


function CablePuzzle:Init()
	for _, puzzle in CablePuzzles:GetChildren() do
		if not puzzle:IsA("Model") then continue end
		Interactables.OnInteractablePressed(puzzle:WaitForChild("Interactable"), Enum.KeyCode.E):Connect(function()
			if getTypeOfPlayer() == "P1" then
				UI.alertPlayerTypeIncompatible()
				return
			end
			AccessPuzzle(puzzle)
		end)
	end
	UI.ApplyButtonTweens(ExitPuzzleButton.Hitbox, ExitPuzzleButton, 0.005, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
end

return CablePuzzle
