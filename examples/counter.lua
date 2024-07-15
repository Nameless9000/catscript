--!strict
local CatScript = require("catlib")
local script = CatScript.new()

script:KeyPressed("F", function(script)
    local count = script:CreateVariable("count")
    count:Increase("1")
    
	-- replace 65 with the global id of your text
    script:SetObjectText(65, "Counter: "..count:Get())
end)

print(script:Export())