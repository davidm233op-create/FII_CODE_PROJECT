local MovableObjects = {}

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


-- // Workspace
local Puzzles = workspace:WaitForChild("Puzzles")
local MovableObjectss = Puzzles:WaitForChild("MovableObjects")
local CurrentCamera = workspace.CurrentCamera

-- // Classes
local Interactables = require(script.Parent.Parent.Parent.UI.Interactables)
local UI = require(script.Parent.Parent.Parent.UI)
local Tweens = require(script.Parent.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Parent.Sounds)


function getTypeOfPlayer()
	return LocalPlayer:GetAttribute("PlayerIndex")
end



function MovableObjects:Init()
	for _, puzzle in MovableObjectss:GetChildren() do
		if not puzzle:IsA("Model") then continue end
		Interactables.OnInteractablePressed(puzzle:WaitForChild("Interactable"), Enum.KeyCode.E):Connect(function()
			if getTypeOfPlayer() == "P2" then
				UI.alertPlayerTypeIncompatible()
				return
			end
			if LocalPlayer:GetAttribute("inPuzzle") then return end
			Communicator.RemoteEvents.PuzzleAction:FireServer("MovableObjects", "Completed", puzzle)
		end)
	end
end

return MovableObjects
