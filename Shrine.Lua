repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local ShrineTab = Window:CreateTab("Shrine", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Safe require
local Remote
local success, result = pcall(function()
    return require(ReplicatedStorage.Shared.Framework.Network.Remote)
end)
if success then
    Remote = result
else
    warn("[Shrine] Failed to load Remote module!")
end

local bubbleEnabled = false
local dreamerEnabled = false

local bubbleThread = nil
local dreamerThread = nil

local BUBBLE = {
    Level = 1,
    Type = "Potion",
    Name = "Lucky",
    Amount = 500
}

local DREAMER_AMOUNT = 15
local INTERVAL = 43200

local function bubble()
    pcall(function()
        Remote:InvokeServer("DonateToShrine", BUBBLE)
    end)
end

local function dreamer()
    pcall(function()
        Remote:InvokeServer("DonateToDreamerShrine", DREAMER_AMOUNT)
    end)
end

-- ======================================
-- BUBBLE SHRINE
-- ======================================
ShrineTab:CreateSection("Bubble Shrine")

ShrineTab:CreateDropdown({
    Name = "Potion Type",
    CurrentOption = "Lucky",
    Options = {"Lucky", "Speed", "Coin", "Mythic"},
    Callback = function(v)
        BUBBLE.Name = v
    end
})

ShrineTab:CreateInput({
    Name = "Amount",
    CurrentValue = tostring(BUBBLE.Amount),
    PlaceholderText = "500",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BUBBLE.Amount = n
        end
    end
})

ShrineTab:CreateToggle({
    Name = "Auto Bubble",
    CurrentValue = false,
    Callback = function(v)
        bubbleEnabled = v

        if v then
            bubble()
            bubbleThread = task.spawn(function()
                while bubbleEnabled do
                    task.wait(INTERVAL)
                    bubble()
                end
            end)
        else
            if bubbleThread then
                task.cancel(bubbleThread)
                bubbleThread = nil
            end
        end
    end
})

-- ======================================
-- DREAMER SHRINE
-- ======================================
ShrineTab:CreateSection("Dreamer Shrine")

ShrineTab:CreateInput({
    Name = "Amount",
    CurrentValue = tostring(DREAMER_AMOUNT),
    PlaceholderText = "15",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then
            DREAMER_AMOUNT = n
        end
    end
})

ShrineTab:CreateToggle({
    Name = "Auto Dreamer",
    CurrentValue = false,
    Callback = function(v)
        dreamerEnabled = v

        if v then
            dreamer()
            dreamerThread = task.spawn(function()
                while dreamerEnabled do
                    task.wait(INTERVAL)
                    dreamer()
                end
            end)
        else
            if dreamerThread then
                task.cancel(dreamerThread)
                dreamerThread = nil
            end
        end
    end
})

print("[Shrine] Loaded! 🔥")
