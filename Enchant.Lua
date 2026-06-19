repeat task.wait() until getgenv().Window
local Window = getgenv().Window

local EnchantTab = Window:CreateTab("Enchant", nil)

local function RunEnchant(primary, secondary, item1, item2, targetLevel)
    getgenv().Settings = {
        Enchanting = {
            Enabled = true,
            PRIMARY_ENCHANTS = primary,
            SECONDARY_ENCHANTS = secondary,
            FIRST_SLOT_ITEM_TO_USE = item1,
            SECOND_SLOT_ITEM_TO_USE = item2,
            AUTO_SWITCH_TO_ORBS = true,
            PRIORITIZE_PRIMARY = true,
            TARGET_LEVEL = targetLevel or 5
        }
    }

    loadstring(game:HttpGet("https://raw.githubusercontent.com/issascripts/bgsi/refs/heads/main/coolestautoenchantintown.lua"))()
end

-- ======================================
-- AUTO ENCHANT
-- ======================================
EnchantTab:CreateSection("Auto Enchant")

EnchantTab:CreateButton({
    Name = "Secret Hunter + Ultra Roller",
    Callback = function()
        RunEnchant(
            {"Secret Hunter","Ultra Roller"},
            {"Secret Hunter","Ultra Roller"},
            "Shadow Crystal",
            "Shadow Crystal",
            5
        )
    end
})

EnchantTab:CreateButton({
    Name = "Ultra Roller + High Roller",
    Callback = function()
        RunEnchant(
            {"High Roller","Ultra Roller"},
            {"High Roller","Ultra Roller"},
            "Shadow Crystal",
            "Gems",
            5
        )
    end
})

EnchantTab:CreateButton({
    Name = "Shiny Seeker + Ultra Roller",
    Callback = function()
        RunEnchant(
            {"Shiny Seeker","Ultra Roller"},
            {"Shiny Seeker","Ultra Roller"},
            "Shadow Crystal",
            "Shadow Crystal",
            5
        )
    end
})

-- ======================================
-- BUBBLER ENCHANTER
-- ======================================
EnchantTab:CreateSection("Bubbler Enchanter")

EnchantTab:CreateButton({
    Name = "Team Up V + Bubbler V",
    Callback = function()
        RunEnchant(
            {"team-up","bubbler"},
            {"team-up","bubbler"},
            "Gems",
            "Gems",
            5
        )
    end
})

EnchantTab:CreateButton({
    Name = "Determination + Bubbler V",
    Callback = function()
        RunEnchant(
            {"determination","bubbler"},
            {"determination","bubbler"},
            "Shadow Crystal",
            "Gems",
            5
        )
    end
})

-- ======================================
-- CURRENCY ENCHANTER
-- ======================================
EnchantTab:CreateSection("Currency Enchanter")

EnchantTab:CreateButton({
    Name = "Team Up V + Looter V",
    Callback = function()
        RunEnchant(
            {"team-up","looter"},
            {"team-up","looter"},
            "Gems",
            "Gems",
            5
        )
    end
})

EnchantTab:CreateButton({
    Name = "Determination + Looter V",
    Callback = function()
        RunEnchant(
            {"determination","looter"},
            {"determination","looter"},
            "Shadow Crystal",
            "Gems",
            5
        )
    end
})
