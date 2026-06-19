-- ================================================
-- QUEST TAB (SEASON + GLOBAL + CLAIM)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local QuestTab = Window:CreateTab("Quest", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

-- ======================================
-- TELEPORT LOCATIONS
-- ======================================
local COIN_AREA = Vector3.new(36, 15971, 41)
local GEM_AREA = Vector3.new(2286, 3158, 842)

local EGG_LOCATIONS = {
    ["Magma Egg"] = Vector3.new(-137, 11, 3),
}

-- ======================================
-- SETTINGS
-- ======================================
local seasonRunning = false
local seasonThread = nil
local globalRunning = false
local globalThread = nil
local claimRunning = false
local claimThread = nil
local HATCH_AMOUNT = 12
local fallbackEgg = "Common Egg"

-- ======================================
-- FUNCTIONS
-- ======================================
local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function teleportTo(pos)
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function savePosition()
    local root = getRoot()
    return root and root.Position or nil
end

local function restorePosition(pos)
    if pos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(pos)
        end
    end
end

local function getSellPosition()
    local overworld = workspace.Worlds["The Overworld"]
    if overworld then
        local sell = overworld:FindFirstChild("Sell")
        if sell then
            local ring = sell:FindFirstChild("Ring")
            if ring then
                return ring.Position
            end
        end
    end
    return Vector3.new(77, 6, -113)
end

local function getActiveQuests(filter)
    local data = LocalData:Get()
    local quests = {}
    if data and data.Quests then
        for _, quest in pairs(data.Quests) do
            if not quest.Claimed then
                local name = quest.Id or ""
                if name:find(filter) then
                    local task = quest.Tasks and quest.Tasks[1]
                    if task then
                        table.insert(quests, {
                            id = quest.Id,
                            type = task.Type,
                            amount = task.Amount or 0,
                            rarity = task.Rarity,
                            egg = task.Egg,
                        })
                    end
                end
            end
        end
    end
    return quests
end

local function completeQuest(quest)
    print("[Quest] Working on: " .. quest.id .. " (" .. quest.type .. ")")
    
    getgenv().questActive = true
    
    if quest.type == "Bubbles" then
        getgenv().questEgg = nil
        local prevPos = savePosition()
        local sellPos = getSellPosition()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(sellPos)
        end
        task.wait(0.5)
        while true do
            pcall(function() Remote:FireServer("BlowBubble") end)
            task.wait(0.01)
            local newQuests = getActiveQuests(quest.id:match("^(.-)%d+$") or "")
            local stillActive = false
            for _, q in ipairs(newQuests) do
                if q.id == quest.id then stillActive = true; break end
            end
            if not stillActive then break end
        end
        restorePosition(prevPos)
        
    elseif quest.type == "Hatch" then
        local eggName = quest.egg
        
        if quest.rarity then
            eggName = "Magma Egg"
        elseif quest.egg then
            eggName = quest.egg
        else
            eggName = fallbackEgg
        end
        
        getgenv().questEgg = eggName
        
        local prevPos = savePosition()
        local pos = EGG_LOCATIONS[eggName] or EGG_LOCATIONS["Magma Egg"]
        if pos then teleportTo(pos) end
        task.wait(0.5)
        
        while true do
            pcall(function() Remote:InvokeServer("HatchEgg", eggName, HATCH_AMOUNT) end)
            task.wait(0.3)
            local newQuests = getActiveQuests(quest.id:match("^(.-)%d+$") or "")
            local stillActive = false
            for _, q in ipairs(newQuests) do
                if q.id == quest.id then stillActive = true; break end
            end
            if not stillActive then break end
        end
        
        restorePosition(prevPos)
        
    elseif quest.type == "Collect" then
        getgenv().questEgg = nil
        local prevPos = savePosition()
        if quest.currency and quest.currency:lower():find("gem") then
            teleportTo(GEM_AREA)
        else
            teleportTo(COIN_AREA)
        end
        while true do
            task.wait(5)
            local newQuests = getActiveQuests(quest.id:match("^(.-)%d+$") or "")
            local stillActive = false
            for _, q in ipairs(newQuests) do
                if q.id == quest.id then stillActive = true; break end
            end
            if not stillActive then break end
        end
        restorePosition(prevPos)
    end
    
    getgenv().questActive = false
    getgenv().questEgg = nil
end

local function questLoop(filter)
    return function()
        while true do
            local quests = getActiveQuests(filter)
            
            if #quests == 0 then
                getgenv().questActive = false
                getgenv().questEgg = nil
                task.wait(10)
                continue
            end
            
            completeQuest(quests[1])
        end
    end
end

-- ======================================
-- UI
-- ======================================
QuestTab:CreateSection("Season Pass")

QuestTab:CreateInput({
    Name = "Fallback Egg (for 'any egg' quests)",
    CurrentValue = fallbackEgg,
    PlaceholderText = "Common Egg",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        fallbackEgg = v
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
    Name = "Auto Season Quests",
    CurrentValue = false,
    Callback = function(v)
        seasonRunning = v
        if v then
            seasonThread = task.spawn(questLoop("challenge"))
            print("[Quest] Season started!")
        else
            if seasonThread then task.cancel(seasonThread) end
            getgenv().questActive = false
            getgenv().questEgg = nil
            print("[Quest] Season stopped!")
        end
    end
})

QuestTab:CreateToggle({
    Name = "Auto Claim Season Pass",
    CurrentValue = false,
    Callback = function(v)
        claimRunning = v
        if v then
            claimThread = task.spawn(function()
                while claimRunning do
                    pcall(function() Remote:FireServer("ClaimSeason") end)
                    print("[Quest] Season Pass claimed!")
                    task.wait(5)
                end
            end)
            print("[Quest] Auto Claim started!")
        else
            if claimThread then task.cancel(claimThread) end
            print("[Quest] Auto Claim stopped!")
        end
    end
})

QuestTab:CreateSection("Global Incentive")

QuestTab:CreateToggle({
    Name = "Auto Global Incentive",
    CurrentValue = false,
    Callback = function(v)
        globalRunning = v
        if v then
            globalThread = task.spawn(function()
                while globalRunning do
                    local quests = getActiveQuests("global")
                    
                    if #quests == 0 then
                        pcall(function() Remote:FireServer("ClaimGlobalIncentiveQuest") end)
                        print("[Quest] Global Incentive claimed!")
                        getgenv().questActive = false
                        getgenv().questEgg = nil
                        task.wait(60)
                    else
                        completeQuest(quests[1])
                    end
                end
            end)
            print("[Quest] Global Incentive started!")
        else
            if globalThread then task.cancel(globalThread) end
            getgenv().questActive = false
            getgenv().questEgg = nil
            print("[Quest] Global Incentive stopped!")
        end
    end
})

print("[Quest] Loaded!")
