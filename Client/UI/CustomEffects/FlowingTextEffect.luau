local FlowingTextEffect = {}

-- // Services
local TS = game:GetService("TweenService")

-- // UI
local LetterPrefab = script.LetterPrefab


function ToggleLetter(letter: TextLabel, toggle: boolean)
	if toggle == true then
		TS:Create(letter, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		TS:Create(letter, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
		TS:Create(letter, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0, 0.5)}):Play()
	else
		TS:Create(letter, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		TS:Create(letter, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.7)}):Play()
		TS:Create(letter, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0, 0)}):Play()
	end
end

function FlowingTextEffect.ToggleMessage(toggle: boolean, parentFrame: Frame, message: string, timeBetweenCharacter: number, noBobble: boolean, letterPrefab: TextLabel)
	timeBetweenCharacter = timeBetweenCharacter or 0.05
	letterPrefab = letterPrefab or LetterPrefab
	
	if toggle == true then
		FlowingTextEffect.OngoingFlows[parentFrame] = message
		
		task.spawn(function()
			if noBobble then return end
			while FlowingTextEffect.OngoingFlows[parentFrame] ~= nil do
				TS:Create(parentFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = parentFrame:GetAttribute("DefaultPosition") - UDim2.fromScale(0, 0.02)}):Play()
				task.wait(2)
				TS:Create(parentFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = parentFrame:GetAttribute("DefaultPosition")}):Play()
				task.wait(2)
			end
		end)

		
		for i = 1, #message do
			local char = string.sub(message, i, i)
			local clone = letterPrefab:Clone()
			clone.Size = UDim2.fromScale(0, 0)
			clone.Text = char
			clone.Name = tostring(i)
			clone.LayoutOrder = i
			clone.Parent = parentFrame
			ToggleLetter(clone, true)
			task.wait(timeBetweenCharacter)
		end
		
	else
		message = FlowingTextEffect.OngoingFlows[parentFrame]
		FlowingTextEffect.OngoingFlows[parentFrame] = nil
		
		for i = #message, 1, -1 do
			local letter = parentFrame:FindFirstChild(tostring(i))
			ToggleLetter(letter, false)
			task.delay(0.5, function()
				letter:Destroy()
			end)
			task.wait(timeBetweenCharacter)
		end
		
	end
end

function FlowingTextEffect:Init()
	FlowingTextEffect.OngoingFlows = {} :: {[Frame]: boolean?}
end

return FlowingTextEffect
