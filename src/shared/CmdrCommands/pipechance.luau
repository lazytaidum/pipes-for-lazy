return {
	Name = "pipechance",
	Description = "Set an archetype's selection weight",
	Group = "Pipes",
	Args = {
		{
			Type = "text",
			Name = "archetype",
			Description = "Archetype name: LongRunner, WallHugger, or Squirmy",
		},
		{
			Type = "number",
			Name = "weight",
			Description = "Relative selection weight",
		},
	},
}