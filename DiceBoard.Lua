-- ================================================
-- DICE BOARD TAB
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

-- ======================================
-- VARIABLES
-- ======================================
local boardEnabled = false
local boardThread = nil
local useGoldenDice = false
local targetTile = "Chance"

-- ======================================
-- FUNCTIONS
-- ======================================
local function rollDice(diceName)
    pcall(function()
        Remote:InvokeServer("RollDice", diceName)
    end)
end

-- ======================================
-- UI
-- ======================================
DiceBoardTab:CreateSection("🎲 Settings")

DiceBoardTab:CreateDropdown({
    Name = "Target Tile",
    CurrentOption = {"Chance"},
    Options = {
        "Chance",
        "Dice-Key",
        "Dice",
        "Giant-Dice",
        "Golden-Dice",
        "Infinity-Elixir",
        "Random-Dice",
        "Special-Egg",
        "Super-Ticket",
        "Ticket"
    },
    Callback = function(v)
        targetTile = v
        print("[DiceBoard] Target tile: " .. v)
    end
})

DiceBoardTab:CreateToggle({
    Name = "Use Golden Dice",
    CurrentValue = false,
    Callback = function(v)
        useGoldenDice = v
    end
})

DiceBoardTab:CreateButton({
    Name = "Teleport to Board Game",
    Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(9912, 29, 172)
            print("[DiceBoard] Teleported!")
        end
    end
})

DiceBoardTab:CreateSection("🎮 Auto Roll")

DiceBoardTab:CreateToggle({
    Name = "Auto Roll Dice",
    CurrentValue = false,
    Callback = function(v)
        boardEnabled = v
        if v then
            boardThread = task.spawn(function()
                while boardEnabled do
                    if useGoldenDice then
                        rollDice("Golden Dice")
                        print("[DiceBoard] Rolled Golden Dice")
                    else
                        rollDice("Dice")
                        print("[DiceBoard] Rolled Dice")
                    end
                    task.wait(3)
                end
            end)
            print("[DiceBoard] Auto Roll started!")
        else
            if boardThread then task.cancel(boardThread) end
            print("[DiceBoard] Auto Roll stopped!")
        end
    end
})

print("[DiceBoard] Loaded! 🎲")
