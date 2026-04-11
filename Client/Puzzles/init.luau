local Puzzles = {}

function InitAllPuzzles()
	for _, puzzleClass: ModuleScript in script.P1:GetChildren() do
		if not puzzleClass:IsA("ModuleScript") then continue end
		puzzleClass = require(puzzleClass)
		puzzleClass:Init()
	end
	
	for _, puzzleClass: ModuleScript in script.P2:GetChildren() do
		if not puzzleClass:IsA("ModuleScript") then continue end
		puzzleClass = require(puzzleClass)
		puzzleClass:Init()
	end
end

function Puzzles:Init()
	InitAllPuzzles()
end

return Puzzles
