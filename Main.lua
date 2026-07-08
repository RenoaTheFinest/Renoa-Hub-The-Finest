-- ======================================
-- RENOA HUB | THE FINEST HUB
-- ======================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Renoa Hub | The Finest Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By Renoa The Finest"
})

getgenv().Window = Window

local function loadTab(url, name)
    task.spawn(function()
        local success = false
        local attempts = 0
        while not success and attempts < 3 do
            attempts = attempts + 1
            local ok, err = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
            if ok then
                success = true
                print("[Renoa] Loaded: " .. name)
            else
                warn("[Renoa] Failed (" .. attempts .. "): " .. name)
                task.wait(3)
            end
        end
    end)
end

-- Load all tabs simultaneously
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Webhook.Lua", "Webhook")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Auto.Lua", "Auto")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Eggs.Lua", "Eggs")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Rift.Lua", "Rift")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Event.Lua", "Event")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Enchant.Lua", "Enchant")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Pets.Lua", "Pets")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Shrine.Lua", "Shrine")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Quest.Lua", "Quest")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Diceboard.Lua", "Diceboard")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Other.Lua", "Other")

print("[Renoa] Hub initialized - all tabs loading in background")
