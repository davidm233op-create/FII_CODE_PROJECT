local Puzzles = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Constants
local puzzleClasses = {}

function InitAllPuzzles()
	for _, puzzleClass: ModuleScript in script:GetChildren() do
		if not puzzleClass:IsA("ModuleScript") then continue end
		
		local className = puzzleClass.Name
		puzzleClass = require(puzzleClass)
		
		puzzleClasses[className] = puzzleClass
		puzzleClass:Init()
	end
end

function OnPuzzleAction(player: Player, puzzleName: string, puzzleAction: string, ...)
	if not puzzleClasses[puzzleName] then return end
	puzzleClasses[puzzleName].OnPuzzleAction(player, puzzleAction, ...)
end

function Puzzles:Init()
	Communicator.RemoteEvents.PuzzleAction.OnServerEvent:Connect(OnPuzzleAction)
	InitAllPuzzles()
end

return Puzzles
