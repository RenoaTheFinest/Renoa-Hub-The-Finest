-- ================================================
-- QUEST TAB (GEM GENIE AUTO)
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
-- EGG LOCATIONS (for hatch quests)
-- ======================================
local EGG_LOCATIONS = {
    ["Common Egg"] = Vector3.new(-80, 7, 5),
    ["Infinity Egg"] = Vector3.new(-106, 12, -28),
    ["Lunar Egg"] = Vector3.new(-148, 11, -15),
}

-- ======================================
-- SETTINGS
-- ======================================
local targetItem = "Green Fragment"
local running = false
local thread = nil
local pickCard = 1 -- Which card to pick (1, 2, or 3)
local HATCH_AMOUNT = 12

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
            if reward.Level then
                name = name .. " (Level " .. reward.Level .. ")"
            end
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

local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function teleportToEgg(eggName)
    local pos = EGG_LOCATIONS[eggName]
    if pos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
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
            -- Blow bubbles
            local amount = task.Amount or 1000000
            local bubbleCount = 0
            print("[Quest] Blowing " .. amount .. " bubbles...")
            while bubbleCount < amount and running do
                pcall(function()
                    Remote:FireServer("BlowBubble")
                end)
                bubbleCount = bubbleCount + 100000
                task.wait(0.1)
            end
            
        elseif taskType == "Hatch" then
            -- Hatch eggs (use Infinity Egg for best odds)
            local amount = task.Amount or 10
            print("[Quest] Hatching " .. amount .. " pets...")
            for i = 1, math.ceil(amount / HATCH_AMOUNT) do
                if not running then break end
                teleportToEgg("Infinity Egg")
                task.wait(0.3)
                pcall(function()
                    Remote:FireServer("HatchEgg", "Infinity Egg", HATCH_AMOUNT)
                end)
                task.wait(0.5)
            end
            
        elseif taskType == "Collect" then
            -- Collect coins/gems - just wait, they auto-collect
            print("[Quest] Collecting items... (auto)")
            task.wait(5)
        end
        
        task.wait(1)
    end
    
    print("[Quest] ✅ Quest completed!")
end

local function isOnCooldown()
    local quest = getGemGenieData()
    if not quest then return true end
    return quest.Claimed == true
end

local function loop()
    while running do
        -- Check if we have an active quest
        local quest = getGemGenieData()
        
        if quest and not quest.Claimed then
            -- We have an active quest, check rewards
            if checkRewardsForTarget(quest.Rewards) then
                print("[Quest] 🎯 Target found! Completing quest...")
                completeQuest(quest)
            else
                print("[Quest] ❌ Target not found in this card. Waiting for cooldown...")
            end
            -- Wait for cooldown
            task.wait(60)
            
        elseif isOnCooldown() then
            print("[Quest] ⏳ On cooldown, waiting...")
            task.wait(30)
            
        else
            -- Reroll and pick a card
            print("[Quest] 🎲 Rerolling Genie...")
            pcall(function() Remote:FireServer("RerollGenie") end)
            task.wait(2)
            
            print("[Quest] 🃏 Picking card " .. pickCard .. "...")
            pcall(function() Remote:FireServer("StartGenieQuest", pickCard) end)
            task.wait(2)
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

QuestTab:CreateDropdown({
    Name = "Pick Card",
    CurrentOption = {"1"},
    Options = {"1", "2", "3"},
    Callback = function(v)
        pickCard = tonumber(v)
    end
})

QuestTab:CreateInput({
    Name = "Hatch Amount",
    CurrentValue = tostring(HATCH_AMOUNT),
    PlaceholderText = "12",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        local n = tonumber(v)
        if n then HATCH_AMOUNT = n end
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
