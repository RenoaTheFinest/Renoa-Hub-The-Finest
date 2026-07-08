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

local function loadTab(url)
    local success = false
    while not success do
        local ok, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if ok then
            success = true
        else
            warn("FAILED:", url)
            task.wait(1)
        end
    end
end

loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Webhook.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Auto.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Eggs.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Rift.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Event.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Enchant.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Pets.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Shrine.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Quest.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Diceboard.Lua")
loadTab("https://raw.githubusercontent.com/AlucardSavage28/Alucardsavage28/refs/heads/main/Other.Lua")
