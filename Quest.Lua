-- ================================================
-- QUEST TAB (AUTO COMPLETE + SEASON PASS CLAIM)
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
local SELL_AREA = Vector3.new(79, 9, -112)
local COIN_AREA = Vector3.new(36, 15971, 41)
local GEM_AREA = Vector3.new(2286, 3158, 842)

local EGG_LOCATIONS = {
    ["Magma Egg"] = Vector3.new(-137, 11, 3),
}

-- ======================================
-- SETTINGS
-- ======================================
local questRunning = false
local questThread = nil
local seasonRunning = false
local seasonThread = nil
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
        root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
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

local function getActiveQuests()
    local data = LocalData:Get()
    local quests = {}
    if data and data.Quests then
        for _, quest in pairs(data.Quests) do
            if not quest.Claimed then
                local name = quest.Id or ""
                if name:find("hourly") or name:find("daily") then
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

local function questLoop()
    while questRunning do
        local quests = getActiveQuests()
        
        if #quests == 0 then
            getgenv().questActive = false
            getgenv().questEgg = nil
            task.wait(10)
            continue
        end
        
        local quest = quests[1]
        print("[Quest] Working on: " .. quest.id .. " (" .. quest.type .. ")")
        
        getgenv().questActive = true
        
        if quest.type == "Bubbles" then
            getgenv().questEgg = nil
            local prevPos = savePosition()
            teleportTo(SELL_AREA)
            while questRunning do
                pcall(function() Remote:FireServer("BlowBubble") end)
                task.wait(0.01)
                local newQuests = getActiveQuests()
                local stillActive = false
                for _, q in ipairs(newQuests) do
                    if q.id == quest.id then stillActive = true; break end
                end
                if not stillActive then break end
            end
            restorePosition(prevPos)
            
        elseif quest.type == "Hatch" then
            local eggName = quest.egg
            local needsTeleport = false
            
            if quest.rarity then
                eggName = "Magma Egg"
                needsTeleport = true
            elseif quest.egg then
                eggName = quest.egg
                needsTeleport = true
            else
                eggName = fallbackEgg
            end
            
            getgenv().questEgg = eggName
            
            local prevPos = nil
            if needsTeleport then
                prevPos = savePosition()
                local pos = EGG_LOCATIONS[eggName]
                if pos then teleportTo(pos) end
            end
            
            while questRunning do
                pcall(function() Remote:FireServer("HatchEgg", eggName, HATCH_AMOUNT) end)
                task.wait(0.3)
                local newQuests = getActiveQuests()
                local stillActive = false
                for _, q in ipairs(newQuests) do
                    if q.id == quest.id then stillActive = true; break end
                end
                if not stillActive then break end
            end
            
            if needsTeleport then
                restorePosition(prevPos)
            end
            
        elseif quest.type == "Collect" then
            getgenv().questEgg = nil
            local prevPos = savePosition()
            if quest.currency and quest.currency:lower():find("gem") then
                teleportTo(GEM_AREA)
            else
                teleportTo(COIN_AREA)
            end
            while questRunning do
                task.wait(5)
                local newQuests = getActiveQuests()
                local stillActive = false
                for _, q in ipairs(newQuests) do
                    if q.id == quest.id then stillActive = true; break end
                end
                if not stillActive then break end
            end
            restorePosition(prevPos)
        end
    end
    
    getgenv().questActive = false
    getgenv().questEgg = nil
end

-- ======================================
-- UI
-- ======================================
QuestTab:CreateSection("Season Quests")

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
    Name = "Auto Complete Quests",
    CurrentValue = false,
    Callback = function(v)
        questRunning = v
        if v then
            questThread = task.spawn(questLoop)
            print("[Quest] Auto Complete started!")
        else
            if questThread then task.cancel(questThread) end
            getgenv().questActive = false
            getgenv().questEgg = nil
            print("[Quest] Auto Complete stopped!")
        end
    end
})

QuestTab:CreateSection("Season Pass")

QuestTab:CreateToggle({
    Name = "Auto Claim Season Pass",
    CurrentValue = false,
    Callback = function(v)
        seasonRunning = v
        if v then
            print("[Quest] Starting Season Pass thread...")
            seasonThread = task.spawn(function()
                while seasonRunning do
                    print("[Quest] Claiming Season Pass...")
                    pcall(function() Remote:FireServer("ClaimSeason") end)
                    print("[Quest] Season Pass claimed!")
                    task.wait(60)
                end
            end)
        else
            if seasonThread then task.cancel(seasonThread) end
            print("[Quest] Auto Claim stopped!")
        end
    end
})

print("[Quest] Loaded!")
