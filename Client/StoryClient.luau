local StoryClient = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local Interactables = require(script.Parent.UI.Interactables)
local Objective = require(script.Parent.UI.Objective)

-- // Workspace
local LightPuzzleFolder = workspace:WaitForChild("LightPuzzle")

local StoryFunctions = {
	StartStory = {
		func = function()
			local mirrorObjects = LightPuzzleFolder:WaitForChild("MirrorObjects")
			local wallObjects = LightPuzzleFolder:WaitForChild("Walls")
			
			for _, mirror in mirrorObjects:GetChildren() do
				
				for _, clicker in mirror:WaitForChild("Interactables"):GetChildren() do
					if not clicker:HasTag("Interactable") then continue end
					
					Interactables.OnInteractablePressed(clicker, Enum.KeyCode.E):Connect(function()
						Communicator.RemoteEvents.StoryAction:FireServer("RotateMirror", mirror, clicker)
					end)
				end
				
			end
			
			for _, wall in wallObjects:GetChildren() do

				for _, clicker in wall:WaitForChild("Interactables"):GetChildren() do
					if not clicker:HasTag("Interactable") then continue end

					Interactables.OnInteractablePressed(clicker, Enum.KeyCode.E):Connect(function()
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
