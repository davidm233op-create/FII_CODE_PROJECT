local BombPuzzle = {}

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
	["BombPuzzle"] = function(player: Player, action: string, puzzle)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("PannelComplete", puzzle.Interactable, true)
		puzzle.Interactable:SetAttribute("Visible", false)
		Communicator.BindableEvents.StoryAction:Fire(player, "BombDefused", puzzle)
	end,
}

function BombPuzzle.OnPuzzleAction(player: Player, action: string, ...)
	local puzzle = ...
	if action == "CompletedWires" then
		Sounds:PlayUnderInstance("PannelComplete", puzzle.Interactable, true)
		
	elseif action == "CompletedSymbols" then
		Sounds:PlayUnderInstance("PannelComplete", puzzle.Interactable, true)
		
	elseif action == "Failed" then
		Sounds:PlayUnderInstance("BombFailed", puzzle.Bomb.PrimaryPart, true)
		BombPuzzle.StartPuzzle(puzzle)
	end

	if CustomActions[puzzle.Name] then
		CustomActions[puzzle.Name](player, action, ...)
	end
end


function BombPuzzle.StartPuzzle(puzzle: Model)
	local configuration = puzzle.Configuration
	local bomb = puzzle.Bomb
	local wireScreen = bomb.WireScreen.SurfaceGui
	local wire_prefabs = wireScreen.Prefabs
	
	local numberToColor = {
		["1"] = Color3.fromRGB(156, 51, 51),
		["2"] = Color3.fromRGB(162, 162, 27),
		["3"] = Color3.fromRGB(36, 121, 158),
	}
	
	configuration:SetAttribute("WireCount", math.random(3, 4))
	local randomColorString = ""
	
	for _, v in wireScreen.Wires:GetChildren() do
		if not v:IsA("Frame") then continue end
		v:Destroy()
	end
	
	for _, v in wireScreen.Top:GetChildren() do
		if not v:IsA("Frame") then continue end
		v:Destroy()
	end
	
	for _, v in wireScreen.Bottom:GetChildren() do
		if not v:IsA("Frame") then continue end
		v:Destroy()
	end
	
	for i = 1, configuration:GetAttribute("WireCount") do
		randomColorString = randomColorString .. tostring(math.random(1, 3))
		local wire = wire_prefabs.Wire:Clone()
		wire.LayoutOrder = i
		wire.Name = tostring(i)
		wire.BackgroundColor3 = numberToColor[string.sub(randomColorString, i, i)]
		wire.Parent = wireScreen.Wires
		
		local edge1 = wire_prefabs.Edge:Clone()
		edge1.Parent = wireScreen.Top
		
		local edge2 = wire_prefabs.Edge:Clone()
		edge2.Parent = wireScreen.Bottom
	end
	
	configuration:SetAttribute("WireString", randomColorString)
	
	local buttonScreen = bomb.ButtonScreen.SurfaceGui
	local possibleSymbols = {"★", "●", "▲", "■", "◆"}
	local pool = table.clone(possibleSymbols)
	local symbol_sequence = ""
	for i = 1, 4 do
		local index = math.random(1, #pool)
		local symbol = pool[index]
		symbol_sequence = symbol_sequence .. symbol

		local symbolIndex = table.find(possibleSymbols, symbol)
		buttonScreen[tostring(i)].TextLabel.Text = symbol
		buttonScreen[tostring(i)].Name = tostring(i)
		buttonScreen[tostring(i)].UIStroke.Color = Color3.fromRGB(0, 0, 0)
		table.remove(pool, index)
	end
	configuration:SetAttribute("SymbolString", symbol_sequence)
	
end


function BombPuzzle:Init()
	BombPuzzle.StartPuzzle(workspace.Puzzles.BombPuzzles.BombPuzzle)
end

return BombPuzzle
