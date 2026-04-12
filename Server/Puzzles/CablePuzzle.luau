local CablePuzzle = {}

-- // Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(game.ServerScriptService.Server.Sounds)


local CustomActions = {

	["ServerCablePuzzle"] = function(player: Player, action: string, object: Model)
		if action == "Accessed" then
			Communicator.BindableEvents.StoryAction:Fire(player, "AccessedServerCables", object)
			
		elseif action == "Completed" then
			Communicator.BindableEvents.StoryAction:Fire(player, "CompletedServerCables", object)
			
		end
	end,
}


function CablePuzzle.OnPuzzleAction(player: Player, action: string, ...)
	local puzzle: Model = ...
	if action == "Completed" then
		
		local _, cablesToReplicate: {{CFrame: CFrame, Color: Color3, Size: Vector3}} = ...
		Sounds:PlayUnderInstance("PannelComplete", puzzle.Interactable, true)
		
		Tweens.Tween(puzzle.BackgroundPart.SurfaceGui.ImageLabel, "ImageColor3", Color3.fromRGB(255, 255, 255), 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		Tweens.Tween(puzzle.BackgroundPart.SurfaceGui.ImageLabel, "ImageTransparency", 0, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		for _, v in puzzle.Details.Lights:GetChildren() do
			Tweens.Tween(v, "Color", Color3.fromRGB(255, 102, 42), 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end

		for _, cableData in cablesToReplicate do
			local currentCable = Instance.new("Part")
			currentCable.Shape = Enum.PartType.Cylinder
			currentCable.Material = Enum.Material.Fabric
			currentCable.Color = cableData.Color
			currentCable.CFrame = cableData.CFrame
			currentCable.Size = cableData.Size
			currentCable.Anchored = true
			currentCable.CanQuery = false
			currentCable.CanCollide = false
			currentCable.CanTouch = false
			currentCable.Parent = puzzle.CableHolder
		end
	end

	if CustomActions[puzzle.Name] then
		CustomActions[puzzle.Name](player, action, ...)
	end
end

function CablePuzzle:Init()
	
end

return CablePuzzle
