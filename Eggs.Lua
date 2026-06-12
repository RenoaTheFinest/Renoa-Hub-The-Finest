-- =========================
-- EGGS TAB (FIXED)
-- =========================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window
local EggTab = Window:CreateTab("Eggs", nil)

local autoSpamEActive = false
local autoSpamEThread = nil

EggTab:CreateToggle({
    Name = "Auto Spam E",
    CurrentValue = false,
    Callback = function(V)
        if V then
            autoSpamEActive = true
            autoSpamEThread = task.spawn(function()
                local vim = game:GetService("VirtualInputManager")
                while autoSpamEActive do
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                end
            end)
        else
            autoSpamEActive = false
            if autoSpamEThread then
                task.cancel(autoSpamEThread)
                autoSpamEThread = nil
            end
        end
    end,
})

EggTab:CreateToggle({
    Name = "Hide Hatch Animation",
    CurrentValue = false,
    Callback = function(V)
        getgenv().animationHidden = V
        if V then
            print("Animation hidden ✅")
        else
            print("Animation restored ✅")
        end
    end,
})
