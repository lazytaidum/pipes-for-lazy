return {
	Name = "pipespeed",
	Description = "Set live pipe growth delay",
	Group = "Pipes",
	Args = {
		{
			Type = "number",
			Name = "delay",
			Description = "Delay in seconds between pipe growth steps",
		},
	},
}