-- ================================================
-- EVENT TAB
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local EventTab = Window:CreateTab("Event", nil)

EventTab:CreateSection("Coming Soon")
EventTab:CreateLabel("In Progress, please wait for the update")

print("[Event] Loaded!")
