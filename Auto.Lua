-- ================================================
-- AUTO TAB (PRESENT RAIN + BUBBLE + SELL + ORB + PICKUP + BOX)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local AutoTab = Window:CreateTab("Auto", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local constants = require(ReplicatedStorage.Shared.Constants)
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)

local RE = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent

local function fire(action, ...)
    if RE then RE:FireServer(action, ...) end
end

-- ======================================
-- SETTINGS
-- ======================================
local presentEnabled = false
local bubbleEnabled = false
local sellEnabled = false
local orbEnabled = false
local pickupEnabled = false
local boxEnabled = false
local presentThread = nil
local bubbleThread = nil
local sellThread = nil
local orbThread = nil
local boxThread = nil

local originalRadius = constants.DefaultPickupRadius

-- ======================================
-- GET BOXES FROM INVENTORY
-- ======================================
local function getBoxes()
    local boxes = {}
    local data = LocalData:Get()
    if data and data.Powerups then
        for name, amount in pairs(data.Powerups) do
            if (name:find("Box") or name:find("Crate") or name:find("Giftbox") or name:find("Present")) and amount > 0 then
                table.insert(boxes, name)
            end
        end
    end
    if #boxes == 0 then
        boxes = {"Mystery Box", "Golden Crate", "Wooden Crate"}
    end
    table.sort(boxes)
    return boxes
end

local boxList = getBoxes()
local selectedBox = boxList[1] or "Mystery Box"

-- ======================================
-- FUNCTIONS
-- ======================================
local function getRoot()
    local char = player.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function collectAllPresents()
    local rendered = workspace:FindFirstChild("Rendered")
    if not rendered then return 0 end
    
    local presentRain = rendered:FindFirstChild("PresentRain")
    if not presentRain then return 0 end
    
    local root = getRoot()
    local previousPos = root and root.Position or nil
    
    local collected = 0
    for _, model in ipairs(presentRain:GetChildren()) do
        if model:IsA("Model") then
            for _, part in ipairs(model:GetChildren()) do
                if part:IsA("BasePart") then
                    local root = getRoot()
                    if root then
                        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
                        collected = collected + 1
                        task.wait(0.02)
                    end
                    break
                end
            end
        end
    end
    
    if previousPos then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(previousPos)
        end
    end
    
    return collected
end

-- ======================================
-- UI - PRESENT RAIN
-- ======================================
AutoTab:CreateSection("Present Rain")

AutoTab:CreateToggle({
    Name = "Auto Collect Presents",
    CurrentValue = false,
    Callback = function(v)
        presentEnabled = v
        if v then
            presentThread = task.spawn(function()
                while presentEnabled do
                    local count = collectAllPresents()
                    if count > 0 then
                        print("[Auto] Collected " .. count .. " presents!")
                    end
                    task.wait(0.5)
                end
            end)
        else
            if presentThread then task.cancel(presentThread) end
        end
    end
})

-- ======================================
-- UI - AUTO
-- ======================================
AutoTab:CreateSection("Auto")

AutoTab:CreateToggle({
    Name = "Auto Blow Bubble",
    CurrentValue = false,
    Callback = function(v)
        bubbleEnabled = v
        if v then
            bubbleThread = task.spawn(function()
                while bubbleEnabled do
                    pcall(function() fire("BlowBubble") end)
                    task.wait(0.01)
                end
            end)
        else
            if bubbleThread then task.cancel(bubbleThread) end
        end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Sell Bubble",
    CurrentValue = false,
    Callback = function(v)
        sellEnabled = v
        if v then
            local sellRoot = nil
            local originalPos = nil
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Root" and obj.Parent and obj.Parent.Name == "Sell" then
                    sellRoot = obj
                    originalPos = obj.Position
                    break
                end
            end
            
            if not sellRoot then
                print("[Auto] No sell area found!")
                sellEnabled = false
                return
            end
            
            sellThread = task.spawn(function()
                while sellEnabled do
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        sellRoot.Position = root.Position + Vector3.new(0, -3, 0)
                    end
                    pcall(function() fire("SellBubble") end)
                    task.wait(1)
                end
                if originalPos then
                    sellRoot.Position = originalPos
                end
            end)
        else
            if sellThread then task.cancel(sellThread) end
        end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Use Golden Orb",
    CurrentValue = false,
    Callback = function(v)
        orbEnabled = v
        if v then
            orbThread = task.spawn(function()
                while orbEnabled do
                    pcall(function() fire("UseGoldenOrb") end)
                    task.wait(1)
                end
            end)
        else
            if orbThread then task.cancel(orbThread) end
        end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Collect Pickup (Re equip a pet)",
    CurrentValue = false,
    Callback = function(v)
        pickupEnabled = v
        if v then
            constants.DefaultPickupRadius = math.huge
        else
            constants.DefaultPickupRadius = originalRadius
        end
    end
})

-- ======================================
-- AUTO OPEN BOX
-- ======================================
AutoTab:CreateSection("Auto Open Box")

AutoTab:CreateDropdown({
    Name = "Select Box",
    CurrentOption = {selectedBox},
    Options = boxList,
    Callback = function(v)
        selectedBox = v[1] or v
    end
})

AutoTab:CreateToggle({
    Name = "Auto Open Box (don't use near egg)",
    CurrentValue = false,
    Callback = function(v)
        boxEnabled = v
        if v then
            boxThread = task.spawn(function()
                local VIM = game:GetService("VirtualInputManager")
                while boxEnabled do
                    local data = LocalData:Get()
                    local amount = data and data.Powerups and data.Powerups[selectedBox] or 0
                    if amount > 0 then
                        local openAmount = math.min(amount, 25)
                        pcall(function() fire("UseGift", selectedBox, openAmount) end)
                        for i = 1, openAmount do
                            if not boxEnabled then break end
                            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                        task.wait(0.1)
                    else
                        task.wait(5)
                    end
                end
            end)
        else
            if boxThread then task.cancel(boxThread) end
        end
    end
})

print("[Auto] Loaded!")
