local CablePuzzle = {}

-- // Services
local HttpService = game:GetService("HttpService")

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)

function CablePuzzle.OnPuzzleAction(player: Player, action: string, ...)
	if action == "Completed" then
		local puzzle: Model, cablesToReplicate: {{CFrame: CFrame, Color: Color3, Size: Vector3}} = ...
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

end

function CablePuzzle:Init()
	
end

return CablePuzzle
