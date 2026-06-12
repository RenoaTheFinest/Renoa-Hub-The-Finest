-- ================================================
-- DICE BOARD (FINAL FIX - UI SYNC)
-- ================================================
repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local DiceBoardTab = Window:CreateTab("Dice Board", nil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remote = require(ReplicatedStorage.Shared.Framework.Network.Remote)

local gui = player:WaitForChild("PlayerGui")
local boardHUD = gui:WaitForChild("ScreenGui"):WaitForChild("BoardHUD")

local boardEnabled = false
local boardThread = nil

local function rollDice()
    pcall(function()
        Remote:InvokeServer("RollDice", "Dice")
    end)
end

local function isRolling()
    local diceUI = boardHUD:FindFirstChild("Dice")
    if not diceUI then return false end

    -- cek visible / state UI
    return diceUI.Visible
end

local function autoRoll()
    while boardEnabled do
        if not isRolling() then
            rollDice()
            task.wait(0.2)
        else
            -- tunggu anim selesai
            repeat task.wait(0.2) until not isRolling() or not boardEnabled
        end

        task.wait(0.5)
    end
end

-- UI
DiceBoardTab:CreateToggle({
    Name = "Auto Dice Board (Fixed)",
    CurrentValue = false,
    Callback = function(v)
        boardEnabled = v
        if v then
            boardThread = task.spawn(autoRoll)
            print("[DiceBoard] Started legit loop")
        else
            if boardThread then task.cancel(boardThread) end
            print("[DiceBoard] Stopped")
        end
    end
})
