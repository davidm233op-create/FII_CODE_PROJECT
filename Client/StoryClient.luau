local StoryClient = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // Classes
local Interactables = require(script.Parent.UI.Interactables)
local Objective = require(script.Parent.UI.Objective)
local Alerts = require(script.Parent.UI.Alerts)
local UI = require(script.Parent.UI)

-- // Workspace
local LightPuzzleFolder = workspace:WaitForChild("Puzzles"):WaitForChild("LightPuzzles"):WaitForChild("LightPuzzle")

function getTypeOfPlayer()
	return LocalPlayer:GetAttribute("PlayerIndex")
end



local StoryFunctions = {
	StartStory = {
		func = function()
			local mirrorObjects = LightPuzzleFolder:WaitForChild("MirrorObjects")
			local wallObjects = LightPuzzleFolder:WaitForChild("Walls")
			
			for _, mirror in mirrorObjects:GetChildren() do
				
				for _, clicker in mirror:WaitForChild("Interactables"):GetChildren() do
					if not clicker:HasTag("Interactable") then continue end
					
					Interactables.OnInteractablePressed(clicker, Enum.KeyCode.E):Connect(function()
						if getTypeOfPlayer() == "P2" then
							UI.alertPlayerTypeIncompatible()
							return
						end
						
						Communicator.RemoteEvents.StoryAction:FireServer("RotateMirror", mirror, clicker)
					end)
				end
				
			end
			
			for _, wall in wallObjects:GetChildren() do

				for _, clicker in wall:WaitForChild("Interactables"):GetChildren() do
					if not clicker:HasTag("Interactable") then continue end

					Interactables.OnInteractablePressed(clicker, Enum.KeyCode.E):Connect(function()
						if getTypeOfPlayer() == "P2" then
							UI.alertPlayerTypeIncompatible()
							return
						end
						
						Communicator.RemoteEvents.StoryAction:FireServer("MoveWall", wall, clicker)
					end)
				end

			end
		end
	},
}

function OnStoryAction(action: string, ...)
	if typeof(action) ~= "string" then return end
	if StoryFunctions[action] then
		StoryFunctions[action].func(...)
	end
end

function StoryClient:Init()
	Communicator.RemoteEvents.StoryAction.OnClientEvent:Connect(OnStoryAction)

	task.spawn(function()
		task.wait(2)

		local obj1 = Objective.new("hello!")
		local obj2 = Objective.new("hello!")
		local obj3 = Objective.new("hello!")
		obj1.Start()
		task.wait(1)
		obj2.Start()
		obj1.Complete()
		task.wait(1)
		obj3.Start()
		task.wait(1)
		obj1.End()
		task.wait(1)
		obj2.End()
		task.wait(1)
		obj3.End()
	end)
end

return StoryClient
