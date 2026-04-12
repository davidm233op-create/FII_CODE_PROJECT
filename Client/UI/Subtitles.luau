local Subtitles = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local Hud = PlayerGui.Hud
local SubtitleFrame = Hud.SubtitleFrame

-- // Classes
local FlowingTextEffectModule = script.Parent.CustomEffects.FlowingTextEffect
local FlowingTextEffect = require(FlowingTextEffectModule)

function Subtitles.On(text: string, timeBetweenCharacters: number)
	timeBetweenCharacters = timeBetweenCharacters or 0.03
	FlowingTextEffect.ToggleMessage(true, SubtitleFrame, text, timeBetweenCharacters, false, FlowingTextEffectModule.SubtitleLetterPrefab)
end

function Subtitles.Off(timeBetweenCharacterDeletion: number)
	FlowingTextEffect.ToggleMessage(false, SubtitleFrame, nil, timeBetweenCharacterDeletion)
end

function Subtitles:Init()
	Communicator.RemoteEvents.ToggleSubtitles.OnClientEvent:Connect(function(toggle: boolean, text: string, timeBetweenCharacters: number)
		if toggle == true then
			Subtitles.On(text, timeBetweenCharacters)
		else
			Subtitles.Off(timeBetweenCharacters)
		end
	end)
end

return Subtitles
