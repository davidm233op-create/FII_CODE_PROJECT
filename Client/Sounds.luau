local Sounds = {}

-- // Services
local SoundService = game:GetService("SoundService")

-- // Storages
local Music = SoundService:WaitForChild("Music")
local PlayingSounds = SoundService:WaitForChild("PlayingSounds")
local MusicTable = {}
local MusicTableIndeces = {}

-- // Classes
local Tweens = require(script.Parent.Tweens)

function Sounds:SetMusicVolume(volume: number)
	for _, sound: Sound in ipairs(MusicTableIndeces) do
		Tweens.Tween(sound, "Volume", volume or sound:GetAttribute("DefaultVolume"), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
end

local hasBegunMusicLoop = false

function Sounds:BeginMusicLoop()
	if hasBegunMusicLoop == true then return end
	hasBegunMusicLoop = true

	task.spawn(function()
		while true do

			for soundName, sound: Sound in pairs(MusicTableIndeces) do
				sound:Stop()
			end

			for soundName, sound: Sound in pairs(MusicTableIndeces) do
				sound:Play()
				task.wait(sound.TimeLength + 1)
			end

			task.wait(1)
		end
	end)
end

function Sounds:MuteAllSongs(tweenTime, easingStyle, easingDirection)
	-- Set defaults if arguments are missing
	tweenTime = tweenTime or 1
	easingStyle = easingStyle or Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.Out

	for _, sound: Sound in ipairs(MusicTableIndeces) do
		-- Tween volume to 0
		Tweens.Tween(sound, "Volume", 0, tweenTime, easingStyle, easingDirection)
	end 
end

function Sounds:UnmuteAllSongs(tweenTime, easingStyle, easingDirection)
	-- Set defaults if arguments are missing
	tweenTime = tweenTime or 1
	easingStyle = easingStyle or Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.Out

	for _, sound: Sound in ipairs(MusicTableIndeces) do
		-- Retrieve the original volume we saved in Init()
		local goalVolume = sound:GetAttribute("DefaultVolume") or 0.5

		-- Tween back to original volume
		Tweens.Tween(sound, "Volume", goalVolume, tweenTime, easingStyle, easingDirection)
	end
end

local function shuffleTable(t)
	for i = #t, 2, -1 do
		local j = math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end

	return t
end

function Sounds:Init()
	for _, sound: Sound in ipairs(SoundService:GetDescendants()) do
		if not sound:IsA("Sound") then continue end
		sound:SetAttribute("DefaultVolume", sound.Volume)
		Sounds[sound.Name] = sound
	end

	for _, sound: Sound in ipairs(Music:GetChildren()) do
		if not sound:IsA("Sound") then continue end
		sound:SetAttribute("DefaultVolume", sound.Volume)
		MusicTable[sound.Name] = sound
	end

	for i, sound: Sound in ipairs(Music:GetChildren()) do
		if not sound:IsA("Sound") then continue end
		MusicTableIndeces[i] = sound
	end


	MusicTableIndeces = shuffleTable(MusicTableIndeces)
	

end

function Sounds:PlayUnderInstance(soundName: string, instance: Instance, destroy, randomPitch: {})
	task.spawn(function()
		if Sounds[soundName] == nil then return end
		local soundClone = Sounds[soundName]:Clone()
		soundClone.Parent = instance

		if randomPitch then
			soundClone.PitchShiftSoundEffect.Octave = math.random(randomPitch[1], randomPitch[2]) / randomPitch[3]
		end

		soundClone:Play()

		if destroy then
			task.wait(soundClone.TimeLength)
			soundClone:Destroy()
		end
	end)
end

function Sounds:Play(soundName: string, randomPitch: {})
	local originalSound: Sound = Sounds[soundName]
	if not originalSound then return end

	-- Clone the sound to allow overlapping playback
	local sound = originalSound:Clone()
	sound.Parent = PlayingSounds  -- Or wherever you want the sound to play from

	-- Apply random pitch if needed
	if randomPitch then
		local pitchEffect = sound:FindFirstChildWhichIsA("PitchShiftSoundEffect")
		if pitchEffect then
			pitchEffect.Octave = math.random(randomPitch[1], randomPitch[2]) / randomPitch[3]
		else
			-- Or fallback to PlaybackSpeed if there's no effect
			sound.PlaybackSpeed = math.random(randomPitch[1], randomPitch[2]) / randomPitch[3]
		end
	end

	sound:Play()

	-- Auto-destroy after playback
	game.Debris:AddItem(sound, sound.TimeLength + 1)

	return sound
end


return Sounds




