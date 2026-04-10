local Communicator = {} :: communicatorType

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Callers = ReplicatedStorage.Callers

-- // Types
type communicatorType = {
	RemoteEvents: {[string]: RemoteEvent},
	RemoteFunctions: {[string]: RemoteFunction},
	BindableEvents: {[string]: BindableEvent},
	BindableFunctions: {[string]: BindableFunction},
}


function Communicator:Init()
	for _, callerStorage in Callers:GetChildren() do
		Communicator[callerStorage.Name] = {}
		
		for _, callerObject in callerStorage:GetChildren() do
			Communicator[callerStorage.Name][callerObject.Name] = callerObject
		end
	end
end

return Communicator
