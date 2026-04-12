--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

--Modules
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)

--Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")


--Workspace
local CurrentCamera = workspace.CurrentCamera

local CutsceneModule = {}


local function CheckCameraPartFormat(part)
	if part:GetAttribute("TweenTime") == nil then return false end
	if part:GetAttribute("EasingStyle") == nil then return false end
	if part:GetAttribute("EasingDirection") == nil then return false end
	if part:GetAttribute("WaitTime") == nil then return false end

	return true
end

local easingStyles = {
	Linear = Enum.EasingStyle.Linear,
	Sine = Enum.EasingStyle.Sine,
	Quad = Enum.EasingStyle.Quad,
	Quint = Enum.EasingStyle.Quint,
	Quart = Enum.EasingStyle.Quart,
	Cubic = Enum.EasingStyle.Cubic,
	Expo = Enum.EasingStyle.Exponential,
	Circ = Enum.EasingStyle.Circular,
	Back = Enum.EasingStyle.Back,
	Elastic = Enum.EasingStyle.Elastic,
	Bounce = Enum.EasingStyle.Bounce,
}

local easingDirections = {
	In = Enum.EasingDirection.In,
	Out = Enum.EasingDirection.Out,
	InOut = Enum.EasingDirection.InOut,
}

local function FormCameraPartsTable(CutsceneFolder)
	local CameraParts = {}

	for _, part in ipairs(CutsceneFolder:GetChildren()) do
		local convertedKey = tonumber(part.Name)

		if convertedKey == nil or CheckCameraPartFormat(part) == false then
			warn("Wrong part format!")
			return
		end

		CameraParts[convertedKey] = {["CameraPart"] = part}
		CameraParts[convertedKey]["WaitTime"] = part:GetAttribute("WaitTime")
		CameraParts[convertedKey]["TweenTime"] = part:GetAttribute("TweenTime")
		CameraParts[convertedKey]["EasingStyle"] = easingStyles[part:GetAttribute("EasingStyle")]
		CameraParts[convertedKey]["EasingDirection"] = easingDirections[part:GetAttribute("EasingDirection")]
	end

	return CameraParts
end

_G.CutscenePlaying = false

function CutsceneModule.InitiateCutscene(CutsceneFolder)
	local FormedCameraParts = FormCameraPartsTable(CutsceneFolder)
	if FormedCameraParts == nil then warn("Wrong cutscene format!") return end

	_G.CutscenePlaying = true

	CurrentCamera.CameraType = Enum.CameraType.Scriptable

	for i, cameraObject in ipairs(FormedCameraParts) do
		local CameraPart = cameraObject["CameraPart"]
		local WaitTime = cameraObject["WaitTime"]
		local TweenTime = cameraObject["TweenTime"]
		local EasingStyle = cameraObject["EasingStyle"]
		local EasingDirection = cameraObject["EasingDirection"]

		if i == 1 then
			CurrentCamera.CFrame = CameraPart.CFrame
			task.wait(TweenTime)
			task.wait(WaitTime)
			continue
		end

		Tweens.Tween(CurrentCamera, "CFrame", CameraPart.CFrame, TweenTime, EasingStyle, EasingDirection)
		task.wait(TweenTime)
		task.wait(WaitTime)
	end


	CurrentCamera.CameraType = Enum.CameraType.Custom

	_G.CutscenePlaying = false
end






return CutsceneModule
