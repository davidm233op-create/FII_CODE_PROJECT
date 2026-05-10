local CodePuzzle = {}

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
	["CodePuzzle"] = function(player: Player, action: string, puzzle)
		if action ~= "Completed" then return end
		Communicator.BindableEvents.StoryAction:Fire(player, "BigLobbyRoomUnlocked", puzzle)
	end,
}

function CodePuzzle.OnPuzzleAction(player: Player, action: string, ...)
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


function CodePuzzle.StartPuzzle(puzzle: Model)
	local configuration = puzzle.Configuration :: Configuration

	local generatedCode = ""
	for i = 1, configuration:GetAttribute("CodeLength") do
		local number = tostring(math.random(0, 9))
		generatedCode = generatedCode .. number
	end

	configuration:SetAttribute("GeneratedCode", generatedCode)

	local numbersFolder = puzzle.Numbers :: Folder

	local buttons = {}
	for _, button in numbersFolder:GetChildren() do
		if button.Name == "Number" then
			table.insert(buttons, button)
		end
	end

	table.sort(buttons, function(a, b)
		local posA = a.Position
		local posB = b.Position
		if math.abs(posA.Y - posB.Y) > 0.1 then
			return posA.Y > posB.Y
		end
		return posA.X < posB.X
	end)

	for i, button in buttons do
		button.Name = tostring(i)
		button.SurfaceGui.Frame.TextLabel.Text = tostring(i)
	end
	
	local frame = puzzle.Numbers.Code.SurfaceGui.Frame
	Tweens.Tween(frame, "BackgroundColor3", Color3.fromRGB(255, 205, 119),
		0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	frame.TextLabel.Text = "_"
	for i = 1, puzzle.Configuration:GetAttribute("CodeLength") - 1 do
		frame.TextLabel.Text = frame.TextLabel.Text .. " _"
	end
end


function CodePuzzle:Init()
	CodePuzzle.StartPuzzle(workspace.Puzzles.CodePuzzles.CodePuzzle)
end

return CodePuzzle
