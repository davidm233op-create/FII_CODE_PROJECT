local Alerts = {}

--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


--Local Player
local LocalPlayer = Players.LocalPlayer

--UI
local PlayerGui = LocalPlayer.PlayerGui
local AlertsGui = PlayerGui.Alerts
local Configuration = AlertsGui.Configuration:GetAttributes()

--Prefabs
local Prefab_AlertLabel = script.AlertLabel

--Classes
local Tweens = require(script.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Sounds)

--Private Variables
local alertStack = {}
local alertStackN = 0
local labelOffset = UDim2.new(0, 0, 0.04, 0)

function updateLabels()
	for i = 1, alertStackN do
		local currentOffset = UDim2.new(labelOffset.X.Scale, 0, labelOffset.Y.Scale * (i - 1), 0)
		Tweens.Tween(alertStack[i], "Position", Configuration.DefaultPosition + currentOffset, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
end

function shiftStackUp()
	for i = alertStackN, 1, -1 do
		alertStack[i + 1] = alertStack[i]
	end
	
	alertStack[1] = nil
	alertStackN += 1
end

function shiftStackDown(fromIndex: number)
	for i = fromIndex or 1, alertStackN do
		alertStack[i] = alertStack[i + 1]
	end
	
	alertStack[alertStackN] = nil
	alertStackN -= 1
end

function addToStack(label: TextLabel)
	shiftStackUp()
	alertStack[1] = label
	
	updateLabels()
end

function removeFromStack(index: number)
	shiftStackDown(index)
	updateLabels()
end



function Alerts:SendAlert(alertText: string, cosmetics: {})
	if typeof(cosmetics) ~= "table" then cosmetics = {} end
	if typeof(alertText) ~= "string" then alertText = nil end
	
	cosmetics = cosmetics or {}
	local textColor = cosmetics.textColor or Color3.fromRGB(255, 255, 255)
	local strokeColor = cosmetics.strokeColor or Color3.fromRGB(0, 0, 0)
	local strokeThickness = cosmetics.strokeThickness or 2
	local timeToDisappear = cosmetics.timeToDisappear or 2
	local sound = cosmetics.sound
	local font = cosmetics.font or Font.new("Roboto Mono", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	
	local alertLabel = Prefab_AlertLabel:Clone()
	alertLabel.TextTransparency = 1
	alertLabel.TextColor3 = textColor
	alertLabel.UIStroke.Transparency = 1
	alertLabel.UIStroke.Color = strokeColor
	alertLabel.UIStroke.Thickness = strokeThickness
	alertLabel.Text = alertText or "Hmm.. did you mean to write something here?"
	alertLabel.Position = Configuration.DefaultPosition
	alertLabel.FontFace = font
	alertLabel.Parent = AlertsGui
	
	if typeof(sound) == "string" then
		Sounds:Play(sound)
	end
	
	Tweens.Tween(alertLabel, "TextTransparency", 0, 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	Tweens.Tween(alertLabel.UIStroke, "Transparency", 0, 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	
	addToStack(alertLabel)
	
	task.wait(timeToDisappear - 0.3)
	
	Tweens.Tween(alertLabel, "TextTransparency", 1, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	Tweens.Tween(alertLabel.UIStroke, "Transparency", 1, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	
	task.wait(0.3)
	
	local labelIndexInStack = table.find(alertStack, alertLabel)
	removeFromStack(labelIndexInStack)
	
	alertLabel:Destroy()
end

--[[

Example use:

Alerts:SendAlert(
	"Test text!",
	{
		timeToDisappear = nil,
		textColor = nil,
		strokeColor = nil,
		strokeThickness = nil,
		sound = nil
	}
)


]]
return Alerts
