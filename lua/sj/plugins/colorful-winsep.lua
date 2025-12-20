-- highlight color which nvim pane is focused/ like tmux active pane indicator
return {
	"nvim-zh/colorful-winsep.nvim",
	config = true,
	event = { "WinLeave" },
}
