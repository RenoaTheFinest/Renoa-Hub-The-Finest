local ShrineTab = Window:CreateTab("Shrine", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local bubbleEnabled = false
local dreamerEnabled = false

local bubbleThread = nil
local dreamerThread = nil

local BUBBLE = {
    Name = getSetting("BubbleName","Lucky"),
    Amount = getSetting("BubbleAmount",500)
}

local DREAMER_AMOUNT = getSetting("DreamerAmount",15)

local INTERVAL = 43200

local function bubble()
    pcall(function()
        Remote:InvokeServer("DonateToShrine",{
            Level = 1,
            Type = "Potion",
            Name = BUBBLE.Name,
            Amount = BUBBLE.Amount
        })
    end)
end

local function dreamer()
    pcall(function()
        Remote:InvokeServer("DonateToDreamerShrine",DREAMER_AMOUNT)
    end)
end

ShrineTab:CreateSection("Bubble Shrine")

ShrineTab:CreateInput({
    Name = "Potion Name",
    CurrentValue = BUBBLE.Name,
    Callback = function(v)
        BUBBLE.Name = v
        setSetting("BubbleName",v)
    end
})

ShrineTab:CreateInput({
    Name = "Amount",
    CurrentValue = tostring(BUBBLE.Amount),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            BUBBLE.Amount = n
            setSetting("BubbleAmount",n)
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
            if bubbleThread then task.cancel(bubbleThread) end
        end
    end
})

ShrineTab:CreateSection("Dreamer Shrine")

ShrineTab:CreateInput({
    Name = "Amount",
    CurrentValue = tostring(DREAMER_AMOUNT),
    Callback = function(v)
        local n = tonumber(v)
        if n then
            DREAMER_AMOUNT = n
            setSetting("DreamerAmount",n)
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
            if dreamerThread then task.cancel(dreamerThread) end
        end
    end
})
