repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local PetTab = Window:CreateTab("Pets", nil)

-- ================================================
-- REBIRTH MACHINE
-- ================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local NetworkRemote = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteFunction")

local LocalDataService = ReplicatedStorage:WaitForChild("Client")
    :WaitForChild("Framework")
    :WaitForChild("Services")
    :WaitForChild("LocalData")

local fuserActive = false
local targetPetNamesString = ""
local selectedVariant = "Normal"
local loopThread = nil

local function fetchLiveInventory()
    local success, dataModule = pcall(require, LocalDataService)
    if success and dataModule and dataModule.Get then
        local profile = dataModule:Get() or dataModule:Get(player)
        if profile and type(profile) == "table" then
            return profile.Pets or profile.Inventory or profile
        end
    end
    return nil
end

local function isCorrectVariant(petInfo)
    if selectedVariant == "Shiny Mythic" then
        return (petInfo.Shiny and petInfo.Mythic)
    elseif selectedVariant == "Shiny" then
        return petInfo.Shiny
    elseif selectedVariant == "Mythic" then
        return petInfo.Mythic
    else
        return not (petInfo.Shiny or petInfo.Mythic)
    end
end

local function fusionLoop()
    while fuserActive do
        task.wait(2.5)

        if targetPetNamesString == "" then continue end

        local targetNames = {}
        for chunk in string.gmatch(targetPetNamesString, "[^,]+") do
            local clean = string.lower(string.gsub(chunk, "^%s*(.-)%s*$", "%1"))
            if clean ~= "" then table.insert(targetNames, clean) end
        end

        local inventory = fetchLiveInventory()
        if not inventory then continue end

        local matching = {}

        for _, pet in pairs(inventory) do
            if type(pet) == "table" and pet.Id and pet.Name then
                if isCorrectVariant(pet) then
                    local name = string.lower(pet.Name)
                    for _, t in ipairs(targetNames) do
                        if name:find(t) then
                            table.insert(matching, tostring(pet.Id))
                            break
                        end
                    end
                end
            end
        end

        if #matching >= 5 then
            local payload = {
                matching[1],
                matching[2],
                matching[3],
                matching[4],
                matching[5]
            }

            pcall(function()
                NetworkRemote:InvokeServer("UseRebirthMachine", payload)
            end)

            task.wait(1.5)
        end
    end
end

-- UI
PetTab:CreateSection("Rebirth Machine")

PetTab:CreateInput({
    Name = "Pet Names (comma)",
    PlaceholderText = "doggy, cat, ufo",
    CurrentValue = "",
    Callback = function(V)
        targetPetNamesString = V
    end,
})

PetTab:CreateDropdown({
    Name = "Variant",
    Options = {"Normal","Shiny","Mythic","Shiny Mythic"},
    CurrentOption = {"Normal"},
    Callback = function(V)
        selectedVariant = V[1]
    end,
})

PetTab:CreateToggle({
    Name = "Auto Rebirth Machine",
    CurrentValue = false,
    Callback = function(V)
        fuserActive = V
        if V then
            loopThread = task.spawn(fusionLoop)
        else
            fuserActive = false
            if loopThread then
                task.cancel(loopThread)
                loopThread = nil
            end
        end
    end,
})
