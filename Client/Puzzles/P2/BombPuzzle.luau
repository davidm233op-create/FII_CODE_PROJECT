local BombPuzzle = {}

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
local PuzzleFrame = PuzzlesGui.BombPuzzle
local ExitPuzzleButton = PuzzleFrame.Exit
local FlipPuzzleButton = PuzzleFrame.Flip
local Hud = PlayerGui.Hud
local BombManual = Hud.BombManual

-- // Workspace
local Puzzles = workspace:WaitForChild("Puzzles")
local BombPuzzles = Puzzles:WaitForChild("BombPuzzles")
local CurrentCamera = workspace.CurrentCamera
local Misc = workspace:WaitForChild("Misc")

-- // Classes
local Interactables = require(script.Parent.Parent.Parent.UI.Interactables)
local UI = require(script.Parent.Parent.Parent.UI)
local Tweens = require(script.Parent.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Parent.Sounds)
local Alerts = require(script.Parent.Parent.Parent.UI.Alerts)


function getTypeOfPlayer()
	return LocalPlayer:GetAttribute("PlayerIndex")
end


function lerp(a, b, c)
	return a + (b - a) * c
end


function CompletePuzzle(puzzle: Model)
	task.spawn(function()
		Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "Completed", puzzle)
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
end


function cutGoodWire(puzzle: Model, cutWirePosition: number): boolean
	local configuration = puzzle.Configuration
	local wireCount = configuration:GetAttribute("WireCount")
	local wireString = configuration:GetAttribute("WireString")

	local RED = "1"
	local YELLOW = "2"
	local BLUE = "3"

	local function countColor(color: string): number
		local count = 0
		for c in wireString:gmatch(".") do
			if c == color then count += 1 end
		end
		return count
	end

	local lastWire = string.sub(wireString, -1)
	local correctPosition: number

	if wireCount == 3 then
		if countColor(RED) == 0 then
			correctPosition = 2
		elseif lastWire == BLUE then
			correctPosition = wireCount
		else
			correctPosition = 1
		end
	elseif wireCount == 4 then
		local firstRed = string.find(wireString, RED)
		if countColor(RED) == 1 and firstRed == 2 then
			correctPosition = 3
		elseif lastWire == YELLOW then
			correctPosition = 1
		elseif countColor(BLUE) == 0 then
			correctPosition = 2
		else
			correctPosition = wireCount
		end
	end

	return cutWirePosition == correctPosition
end

local SYMBOLS = {"★", "●", "▲", "■", "◆"}

local SEQUENCES = {
	["★"] = {"●", "▲", "■", "◆"},
	["●"] = {"▲", "■", "◆", "★"},
	["▲"] = {"■", "◆", "★", "●"},
	["■"] = {"◆", "★", "●", "▲"},
	["◆"] = {"★", "●", "▲", "■"},
}

function clickedRightSymbol(puzzle: Model, clickedSymbol: string, currentSymbolCount: number): boolean
	local configuration = puzzle.Configuration
	local symbolString = configuration:GetAttribute("SymbolString")

	local missingSymbol = nil
	for _, symbol in SYMBOLS do
		if not string.find(symbolString, symbol, 1, true) then
			missingSymbol = symbol
			break
		end
	end

	if not missingSymbol then return false end

	local correctSequence = SEQUENCES[missingSymbol]
	local nextExpected = correctSequence[currentSymbolCount + 1]

	return clickedSymbol == nextExpected
end


function AccessPuzzle(puzzle: Model)

	PuzzleFrame.Visible = true
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Tweens.Tween(CurrentCamera, "CFrame", puzzle.CameraPart.CFrame, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	puzzle.Interactable:SetAttribute("Visible", false)

	local buttonConnection
	local animationsConnections = {}
	local wireAnimationsConnections = {}
	local symbolAnimationsConnections = {}

	local wiresCompleted = false
	local symbolsCompleted = false

	local function checkBothCompleted()
		if wiresCompleted and symbolsCompleted then
			Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "Completed", puzzle)
			buttonConnection:Disconnect()
			for _, connection: RBXScriptConnection in animationsConnections do connection:Disconnect() end
			for _, connection: RBXScriptConnection in wireAnimationsConnections do connection:Disconnect() end
			for _, connection: RBXScriptConnection in symbolAnimationsConnections do connection:Disconnect() end
			ExitPuzzle(puzzle)
		end
	end

	local wireScreen = puzzle.Bomb.WireScreen.SurfaceGui
	local buttonScreen = puzzle.Bomb.ButtonScreen.SurfaceGui

	for _, wire in wireScreen.Wires:GetChildren() do
		if not wire:IsA("Frame") then continue end

		table.insert(wireAnimationsConnections, wire.Hitbox.MouseEnter:Connect(function()
			Tweens.Tween(wire.UIStroke, "Color", Color3.fromRGB(255, 57, 57), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			Tweens.Tween(wire.Cut, "BackgroundTransparency", 0, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end))

		table.insert(wireAnimationsConnections, wire.Hitbox.MouseLeave:Connect(function()
			Tweens.Tween(wire.UIStroke, "Color", Color3.fromRGB(93, 162, 89), 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			Tweens.Tween(wire.Cut, "BackgroundTransparency", 1, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end))

		table.insert(wireAnimationsConnections, wire.Hitbox.MouseButton1Click:Connect(function()
			local wireName = wire.Name
			Tweens.Tween(wire, "BackgroundTransparency", 1, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

			if cutGoodWire(puzzle, tonumber(wireName)) == true then
				wiresCompleted = true
				Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "CompletedWires", puzzle)
				for _, connection: RBXScriptConnection in wireAnimationsConnections do
					connection:Disconnect()
				end
				checkBothCompleted()
			else
				Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "Failed", puzzle)
				buttonConnection:Disconnect()
				for _, connection: RBXScriptConnection in animationsConnections do connection:Disconnect() end
				for _, connection: RBXScriptConnection in wireAnimationsConnections do connection:Disconnect() end
				for _, connection: RBXScriptConnection in symbolAnimationsConnections do connection:Disconnect() end
				ExitPuzzle(puzzle)
				task.wait(0.5)
				Alerts:SendAlert("Wires failed! Try again!", {textColor = Color3.fromRGB(255, 92, 92)})
			end
		end))
	end

	local currentSymbolString = ""
	local currentSymbolCount = 0

	for _, symbolButton in buttonScreen:GetChildren() do
		if not symbolButton:IsA("Frame") then continue end

		local anims = UI.ApplyButtonTweens(symbolButton.Hitbox, symbolButton, 0.02, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		for _, x in anims do
			table.insert(symbolAnimationsConnections, x)
		end

		table.insert(symbolAnimationsConnections, symbolButton.Hitbox.MouseButton1Click:Connect(function()
			local clickedSymbol = symbolButton.TextLabel.Text

			if clickedRightSymbol(puzzle, clickedSymbol, currentSymbolCount) == true then
				currentSymbolString = currentSymbolString .. clickedSymbol
				currentSymbolCount += 1
				Tweens.Tween(symbolButton.UIStroke, "Color", Color3.fromRGB(103, 255, 57), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

				if currentSymbolCount == 4 then
					symbolsCompleted = true
					Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "CompletedSymbols", puzzle)
					for _, connection: RBXScriptConnection in symbolAnimationsConnections do
						connection:Disconnect()
					end
					checkBothCompleted()
				end
			else
				for _, btn in buttonScreen:GetChildren() do
					if not btn:IsA("Frame") then continue end
					Tweens.Tween(btn.UIStroke, "Color", Color3.fromRGB(0, 0, 0), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end
				currentSymbolString = ""
				currentSymbolCount = 0

				Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "Failed", puzzle)
				buttonConnection:Disconnect()
				for _, connection: RBXScriptConnection in animationsConnections do connection:Disconnect() end
				for _, connection: RBXScriptConnection in wireAnimationsConnections do connection:Disconnect() end
				for _, connection: RBXScriptConnection in symbolAnimationsConnections do connection:Disconnect() end
				ExitPuzzle(puzzle)
				task.wait(0.5)
				Alerts:SendAlert("Symbols failed! Try again!", {textColor = Color3.fromRGB(255, 92, 92)})
			end
		end))
	end

	local defaultCFrame = puzzle.Bomb.PrimaryPart.CFrame
	local flipToggle = false
	table.insert(animationsConnections, FlipPuzzleButton.Hitbox.MouseButton1Click:Connect(function()
		if flipToggle == false then
			flipToggle = true
			Tweens.Tween(puzzle.Bomb.PrimaryPart, "CFrame", defaultCFrame * CFrame.fromOrientation(math.rad(180), 0, 0),
				0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			flipToggle = false
			Tweens.Tween(puzzle.Bomb.PrimaryPart, "CFrame", defaultCFrame,
				0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end))

	buttonConnection = ExitPuzzleButton.Hitbox.MouseButton1Click:Connect(function()
		Communicator.RemoteEvents.PuzzleAction:FireServer("BombPuzzle", "Failed", puzzle)
		buttonConnection:Disconnect()
		for _, connection: RBXScriptConnection in animationsConnections do connection:Disconnect() end
		for _, connection: RBXScriptConnection in wireAnimationsConnections do connection:Disconnect() end
		for _, connection: RBXScriptConnection in symbolAnimationsConnections do connection:Disconnect() end
		ExitPuzzle(puzzle)
	end)
end


function BombPuzzle:Init()
	for _, puzzle in BombPuzzles:GetChildren() do
		if not puzzle:IsA("Model") then continue end
		Interactables.OnInteractablePressed(puzzle:WaitForChild("Interactable"), Enum.KeyCode.E):Connect(function()
			if getTypeOfPlayer() == "P2" then
				UI.alertPlayerTypeIncompatible()
				return
			end
			if LocalPlayer:GetAttribute("inPuzzle") then return end
			LocalPlayer:SetAttribute("inPuzzle", true)
			AccessPuzzle(puzzle)
		end)
	end
	UI.ApplyButtonTweens(ExitPuzzleButton.Hitbox, ExitPuzzleButton, 0.005, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	UI.ApplyButtonTweens(FlipPuzzleButton.Hitbox, FlipPuzzleButton, 0.005, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	
	-- // HUD UI
	UI.ApplyButtonTweens(BombManual.Exit.Hitbox, BombManual.Exit, 0.01, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	UI.ApplyButtonTweens(BombManual.Right.Hitbox, BombManual.Right, 0.01, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	UI.ApplyButtonTweens(BombManual.Left.Hitbox, BombManual.Left, 0.01, 0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	
	Interactables.OnInteractablePressed(Misc.BombManual.Interactable, Enum.KeyCode.E):Connect(function()
		if getTypeOfPlayer() == "P1" then
			UI.alertPlayerTypeIncompatible()
			return
		end
		
		Misc.BombManual.Interactable:SetAttribute("Visible", false)
		BombManual.Position = UDim2.fromScale(0.5, 0.55)
		BombManual.Visible = true
		Tweens.Tween(BombManual, "Position", UDim2.fromScale(0.5, 0.5), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end)
	
	local currentPage = 1
	local totalPages = #BombManual.Pages:GetChildren()

	local function showPage(page: number)
		for _, pageFrame in BombManual.Pages:GetChildren() do
			pageFrame.Visible = pageFrame.Name == tostring(page)
			if pageFrame.Name == tostring(page) then
				pageFrame.Position = UDim2.fromScale(0.5, 0.38)
				Tweens.Tween(pageFrame, "Position", UDim2.fromScale(0.5, 0.435), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end
	end

	showPage(currentPage)

	BombManual.Right.Hitbox.MouseButton1Click:Connect(function()
		currentPage = (currentPage % totalPages) + 1
		showPage(currentPage)
	end)

	BombManual.Left.Hitbox.MouseButton1Click:Connect(function()
		currentPage = ((currentPage - 2) % totalPages) + 1
		showPage(currentPage)
	end)

	BombManual.Exit.Hitbox.MouseButton1Click:Connect(function()
		BombManual.Visible = false
		Misc.BombManual.Interactable:SetAttribute("Visible", true)
	end)
end

return BombPuzzle