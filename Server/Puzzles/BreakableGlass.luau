local MemoryPuzzle = {}

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(game.ServerScriptService.Server.Sounds)



function MemoryPuzzle.OnPuzzleAction(player: Player, action: string, ...)
	if action == "Completed" then
		local puzzle = ...
		
		Sounds:PlayUnderInstance("GlassBreaking", puzzle.Interactable, true)
		puzzle.Glass:Destroy()
		
		for _, v: BasePart in puzzle.BreakableParts:GetChildren() do
			v.Transparency = 0.6
			v.Anchored = false
			v.AssemblyLinearVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		end
	end
end


function MemoryPuzzle.StartPuzzle(puzzle: Model)

	
end


function MemoryPuzzle:Init()
	MemoryPuzzle.StartPuzzle(workspace.Puzzles.MemoryPuzzles.MemoryPuzzle)
end

return MemoryPuzzle
