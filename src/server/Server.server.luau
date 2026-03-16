local CollectionService = game:GetService("CollectionService")

local removeTag = CollectionService:GetTagged("OnServerStart_Remove")

for _, tagged in pairs(removeTag) do
	tagged:Destroy()
end