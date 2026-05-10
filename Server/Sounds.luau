local Sounds = {}

-- // Services
local SoundService = game:GetService("SoundService")

-- // Storages
local PlayingSounds = SoundService:WaitForChild("PlayingSounds")

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)

function Sounds:Init()
	for _, sound: Sound in ipairs(SoundService:GetDescendants()) do
		if not sound:IsA("Sound") then continue end
		sound:SetAttribute("DefaultVolume", sound.Volume)
		Sounds[sound.Name] = sound
	end
end

function Sounds:PlayUnderInstance(soundName: string, instance: Instance, destroyAfterPlay: boolean, randomPitch: {})
	if Sounds[soundName] == nil then return end
	local soundClone = Sounds[soundName]:Clone()
	soundClone.Parent = instance
	
	task.spawn(function()

		if randomPitch then
			soundClone.PitchShiftSoundEffect.Octave = math.random(randomPitch[1], randomPitch[2]) / randomPitch[3]
		end

		soundClone:Play()

		if destroyAfterPlay then
			task.wait(soundClone.TimeLength / soundClone.PlaybackSpeed)
			soundClone:Destroy()
		end
	end)
	
	return soundClone
end

function Sounds:Play(soundName: string, randomPitch: {})
	local originalSound: Sound = Sounds[soundName]
	if not originalSound then return end

	local sound = originalSound:Clone()
	sound.Parent = PlayingSounds

	if randomPitch then
		local pitchEffect = sound:FindFirstChildWhichIsA("PitchShiftSoundEffect")
		if pitchEffect then
			pitchEffect.Octave = math.random(randomPitch[1], randomPitch[2]) / randomPitch[3]
		else
			sound.PlaybackSpeed = math.random(randomPitch[1], randomPitch[2]) / randomPitch[3]
		end
	end

	sound:Play()
	game.Debris:AddItem(sound, sound.TimeLength + 1)

	return sound
end

return Sounds