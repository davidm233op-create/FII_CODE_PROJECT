local TextFilter = {}

-- // Services
local TextService = game:GetService("TextService")

function TextFilter.filterForBroadcast(message, fromUserId)
	if message == "" then return "" end

	local success, filterResult = pcall(function()
		return TextService:FilterStringAsync(message, fromUserId)
	end)
	
	if success then
		local filteredString = ""
		local getSuccess, err = pcall(function()
			filteredString = filterResult:GetNonChatStringForBroadcastAsync()
		end)

		if getSuccess then
			return filteredString
		end
	end

	return string.rep("#", #message)
end


return TextFilter