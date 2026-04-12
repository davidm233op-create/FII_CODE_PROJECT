local NumberOrderPuzzle = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(game.ServerScriptService.Server.Sounds)

local function shuffleTable(t)
	for i = #t, 2, -1 do
		local j = math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end

	return t
end

local CustomActions = {
	["Start"] = function(player: Player, action: string, puzzle)
		if action ~= "Completed" then return end
		Communicator.BindableEvents.StoryAction:Fire(player, "ServerRoomUnlocked", puzzle)
	end,
	
	["Conference"] = function(player: Player, action: string, puzzle)
		if action ~= "Completed" then return end
		Communicator.BindableEvents.StoryAction:Fire(player, "ConferencePuzzleDone", puzzle)
	end,
}

function NumberOrderPuzzle.OnPuzzleAction(player: Player, action: string, ...)
	local puzzle = ...
	if action == "Completed" then
		Sounds:PlayUnderInstance("PannelComplete", puzzle.Interactable, true)
		
		for _, v in puzzle.Details.Lights:GetChildren() do
			Tweens.Tween(v, "Color", Color3.fromRGB(255, 102, 42), 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
	end
	
	if CustomActions[puzzle.Name] then
		CustomActions[puzzle.Name](player, action, ...)
	end
end


function NumberOrderPuzzle.StartPuzzle(puzzle: Model)
	local numbers = shuffleTable({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12})
	local numbersFolder = puzzle.Numbers :: Folder
	
	for i, button in numbersFolder:GetChildren() do
		button.Name = tostring(numbers[i])
		button.SurfaceGui.Frame.TextLabel.Text = tostring(numbers[i])
	end
	
end


function NumberOrderPuzzle:Init()
	NumberOrderPuzzle.StartPuzzle(workspace.Puzzles.NumberOrderPuzzles.NumberOrderPuzzle)
end

return NumberOrderPuzzle
