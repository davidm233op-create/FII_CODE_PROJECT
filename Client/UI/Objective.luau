local Objective = {}

-- // Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Storages
local Objects = ReplicatedStorage.Objects
local UIPrefabs = Objects.UI

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local HudGui = PlayerGui.Hud
local ObjectivesFrame = HudGui.Objectives
local ObjectivesHolder = ObjectivesFrame.Holder

-- // Classes
local Tweens = require(script.Parent.Parent.Tweens)

function Objective.new(text: string?)
	local frame: Frame?
	
	return {
		Start = function()
			local totalObjectives = #ObjectivesHolder:GetChildren() - 1
			if totalObjectives == 0 then
				Tweens.Tween(ObjectivesFrame, "Position", UDim2.fromScale(0.146, 0.087), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
			frame = UIPrefabs.Objective:Clone()
			frame.LayoutOrder = totalObjectives + 1
			frame.Frame.TextLabel.Text = text
			frame.Size = UDim2.fromScale(1.221, 0)
			frame.Parent = ObjectivesHolder
			
			Tweens.Tween(frame, "Size", UDim2.fromScale(1.221, 0.181), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.delay(0.5, function()
				Tweens.Tween(frame.Frame, "Position", UDim2.fromScale(0.433, 0.448), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)
		end,
		
		End = function()
			if not frame then warn("Frame doesn't exist. Didn't start?") return end
			
			task.spawn(function()
				Tweens.Tween(frame.Frame, "Position", UDim2.fromScale(-0.433, 0.448), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.wait(0.5)
				Tweens.Tween(frame, "Size", UDim2.fromScale(1.221, 0), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.wait(0.5)
				frame:Destroy()

				local totalObjectives = #ObjectivesHolder:GetChildren() - 1
				if totalObjectives == 0 then
					Tweens.Tween(ObjectivesFrame, "Position", UDim2.fromScale(-0.146, 0.087), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end
			end)
		end,
		
		Complete = function()
			if not frame then warn("Frame doesn't exist. Didn't start?") return end
			
			task.spawn(function()
				Tweens.Tween(frame.Frame.Checkbox, "BackgroundTransparency", 0.5, 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				Tweens.Tween(frame.Frame.UIStroke, "Color", Color3.fromRGB(255, 255, 255), 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.wait(0.4)
				Tweens.Tween(frame.Frame.UIStroke, "Color", Color3.fromRGB(0, 0, 0), 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)
		end,
		
		Uncomplete = function()
			if not frame then warn("Frame doesn't exist. Didn't start?") return end
			Tweens.Tween(frame.Frame.Checkbox, "BackgroundTransparency", 1, 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		end,
	}
	
end



return Objective
