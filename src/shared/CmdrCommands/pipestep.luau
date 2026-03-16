return {
	Name = "pipestep",
	Description = "Advance pipe generation by one or more steps while paused",
	Group = "Pipes",
	Args = {
		{
			Type = "number",
			Name = "amount",
			Description = "How many growth steps to queue",
			Optional = true,
		},
	},
}