local compile = require("../catlib")()

local count_button = Button(12)
local counter_label = Text(34)

count = 0

count_button.OnClick(function()
	count += 1
	
	counter_label.Text = count
end)

compile()