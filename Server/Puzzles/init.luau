local Puzzles = {}

function InitAllPuzzles()
	for _, puzzleClass: ModuleScript in script:GetChildren() do
		if not puzzleClass:IsA("ModuleScript") then continue end
		puzzleClass = require(puzzleClass)
		puzzleClass:Init()
	end
end

function Puzzles:Init()
	InitAllPuzzles()
end

return Puzzles
