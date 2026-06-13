-- ================================================
-- QUEST TAB (GEM GENIE AUTO - SIMPLE)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local QuestTab = Window:CreateTab("Quest", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)

-- ======================================
-- SETTINGS
-- ======================================
local targetItem = "Green Fragment"
local running = false
local thread = nil

-- ======================================
-- FUNCTIONS
-- ======================================
local function getGemGenieData()
    local data = LocalData:Get()
    if data and data.Quests then
        for _, quest in pairs(data.Quests) do
            if quest.Id == "gem-genie" and not quest.Claimed then
                return quest
            end
        end
    end
    return nil
end

local function checkRewardsForTarget(rewards)
    if not rewards then return false end
    for _, reward in ipairs(rewards) do
        local name = ""
        if reward.Type == "Powerup" then
            name = reward.Name or ""
        elseif reward.Type == "Potion" then
            name = reward.Name or ""
        elseif reward.Type == "Currency" then
            name = reward.Currency or ""
        end
        
        if name:lower():find(targetItem:lower()) then
            print("[Quest] ✅ Found target: " .. name)
            return true
        end
    end
    return false
end

local function completeQuest(quest)
    if not quest or not quest.Tasks then return end
    
    for _, task in ipairs(quest.Tasks) do
        local taskType = task.Type
        
        if taskType == "Bubbles" then
            local amount = task.Amount or 1000000
            print("[Quest] Blowing bubbles...")
            for i = 1, 100 do
                if not running then break end
                pcall(function() Remote:FireServer("BlowBubble") end)
                task.wait(0.05)
            end
            
        elseif taskType == "Hatch" then
            print("[Quest] Hatching eggs...")
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(-106, 17, -28) -- Infinity Egg
            end
            for i = 1, 20 do
                if not running then break end
                pcall(function() Remote:FireServer("HatchEgg", "Infinity Egg", 12) end)
                task.wait(0.3)
            end
            
        elseif taskType == "Collect" then
            print("[Quest] Collecting... (auto)")
            task.wait(5)
        end
    end
    
    print("[Quest] ✅ Quest done!")
end

local function loop()
    while running do
        local quest = getGemGenieData()
        
        if quest then
            if checkRewardsForTarget(quest.Rewards) then
                print("[Quest] 🎯 Target found! Completing...")
                completeQuest(quest)
            else
                print("[Quest] ❌ Target not found. Waiting for cooldown...")
            end
            task.wait(60)
        else
            print("[Quest] 🎲 Rerolling and picking card 1...")
            pcall(function() Remote:FireServer("RerollGenie") end)
            task.wait(2)
            pcall(function() Remote:FireServer("StartGenieQuest", 1) end)
            task.wait(3)
        end
        
        task.wait(5)
    end
end

-- ======================================
-- UI
-- ======================================
QuestTab:CreateSection("🧞‍♂️ Gem Genie")

QuestTab:CreateDropdown({
    Name = "Target Item",
    CurrentOption = {"Green Fragment"},
    Options = {
        "Green Fragment",
        "Shadow Crystal",
        "Fire Elixir",
        "Ice Elixir",
        "Egg Elixir",
        "Secret Elixir",
        "Ultra Infinity Elixir"
    },
    Callback = function(v)
        targetItem = v
    end
})

QuestTab:CreateToggle({
    Name = "Auto Gem Genie",
    CurrentValue = false,
    Callback = function(v)
        running = v
        if v then
            thread = task.spawn(loop)
            print("[Quest] Started!")
        else
            if thread then task.cancel(thread) end
            print("[Quest] Stopped!")
        end
    end
})

print("[Quest] Loaded! 🧞‍♂️")
