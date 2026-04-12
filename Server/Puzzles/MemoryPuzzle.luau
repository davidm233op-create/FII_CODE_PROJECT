local MemoryPuzzle = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(game.ServerScriptService.Server.Sounds)


local CustomActions = {
	["KitchenMemoryPuzzle"] = function(player: Player, action: string, puzzle)
		if action ~= "Completed" then return end
		Communicator.BindableEvents.StoryAction:Fire(player, "ConferenceRoomUnlocked", puzzle)
	end,
}

function MemoryPuzzle.OnPuzzleAction(player: Player, action: string, ...)
	local puzzle = ...
	if action == "Completed" then
		
		Sounds:PlayUnderInstance("PannelComplete", puzzle.Interactable, true)
		for _, v in puzzle.Details.Lights:GetChildren() do
			Tweens.Tween(v, "Color", Color3.fromRGB(255, 102, 42), 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
		for i = 1, 5 do

			local frame = puzzle.LeftCounter.SurfaceGui.Frame:FindFirstChild(tostring(i))
			Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(9, 135, 20), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
	end
	
	if CustomActions[puzzle.Name] then
		CustomActions[puzzle.Name](player, action, ...)
	end
end


function MemoryPuzzle.StartPuzzle(puzzle: Model)

	
end


function MemoryPuzzle:Init()
	MemoryPuzzle.StartPuzzle(workspace.Puzzles.MemoryPuzzles.MemoryPuzzle)
end

return MemoryPuzzle
