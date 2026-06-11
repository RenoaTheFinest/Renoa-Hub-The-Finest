return function(Window, getSetting, setSetting)

local RiftTab = Window:CreateTab("Rift", nil)

local WORLD_EGGS = {
    ["The Overworld"] = {"Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"},
    ["Minigame Paradise"] = {"Mining Egg","Cyber Egg","Neon Egg"},
}

local WORLD_CHESTS = {
    ["The Overworld"] = {"Golden Chest","Royal Chest","Super Chest"},
    ["Minigame Paradise"] = {"Dice Chest"},
}

local WORLDS = {"The Overworld","Minigame Paradise"}

local selectedEggWorld = getSetting("EggRiftWorld","The Overworld")
local selectedEggName = getSetting("EggRiftName","Spikey Egg")
local selectedChestWorld = getSetting("ChestRiftWorld","The Overworld")
local selectedChestName = getSetting("ChestRiftName","Golden Chest")

-- EGG
RiftTab:CreateSection("Egg Rift")

RiftTab:CreateDropdown({
    Name = "World",
    Options = WORLDS,
    CurrentOption = {selectedEggWorld},
    Callback = function(V)
        selectedEggWorld = V[1]
        setSetting("EggRiftWorld", selectedEggWorld)
        selectedEggName = WORLD_EGGS[selectedEggWorld][1]
        setSetting("EggRiftName", selectedEggName)
    end,
})

RiftTab:CreateDropdown({
    Name = "Egg",
    Options = WORLD_EGGS[selectedEggWorld],
    CurrentOption = {selectedEggName},
    Callback = function(V)
        selectedEggName = V[1]
        setSetting("EggRiftName", selectedEggName)
    end,
})

RiftTab:CreateButton({
    Name = "Start Auto Egg Rift",
    Callback = function()
        task.spawn(function()
            while true do
                game:GetService("ReplicatedStorage")
                .Shared.Framework.Network.Remote.RemoteFunction:InvokeServer(
                    "SummonRift",
                    {
                        Type="Egg",
                        Name=selectedEggName,
                        Time=5,
                        Luck=5,
                        World=selectedEggWorld
                    }
                )
                task.wait(1860)
            end
        end)
    end,
})

-- CHEST
RiftTab:CreateSection("Chest Rift")

RiftTab:CreateDropdown({
    Name = "World",
    Options = WORLDS,
    CurrentOption = {selectedChestWorld},
    Callback = function(V)
        selectedChestWorld = V[1]
        setSetting("ChestRiftWorld", selectedChestWorld)
        selectedChestName = WORLD_CHESTS[selectedChestWorld][1]
        setSetting("ChestRiftName", selectedChestName)
    end,
})

RiftTab:CreateDropdown({
    Name = "Chest",
    Options = WORLD_CHESTS[selectedChestWorld],
    CurrentOption = {selectedChestName},
    Callback = function(V)
        selectedChestName = V[1]
        setSetting("ChestRiftName", selectedChestName)
    end,
})

RiftTab:CreateButton({
    Name = "Start Auto Chest Rift",
    Callback = function()
        task.spawn(function()
            while true do
                game:GetService("ReplicatedStorage")
                .Shared.Framework.Network.Remote.RemoteFunction:InvokeServer(
                    "SummonRift",
                    {
                        Type="Chest",
                        Name=selectedChestName,
                        Time=5,
                        World=selectedChestWorld
                    }
                )
                task.wait(1860)
            end
        end)
    end,
})

end
