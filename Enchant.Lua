-- ================================================
-- ENCHANT TAB
-- ================================================
local EnchantTab = Window:CreateTab("Enchant", nil)

local function RunEnchant(primary, secondary, item1, item2)
    getgenv().Settings = {
        Enchanting = {
            Enabled = true,
            PRIMARY_ENCHANTS = primary,
            SECONDARY_ENCHANTS = secondary,
            FIRST_SLOT_ITEM_TO_USE = item1,
            SECOND_SLOT_ITEM_TO_USE = item2,
            AUTO_SWITCH_TO_ORBS = true,
            PRIORITIZE_PRIMARY = true
        }
    }

    loadstring(game:HttpGet("https://raw.githubusercontent.com/issascripts/bgsi/refs/heads/main/coolestautoenchantintown.lua"))()
end

EnchantTab:CreateSection("Auto Enchant")

EnchantTab:CreateButton({
    Name = "Secret Hunter + Ultra Roller",
    Callback = function()
        RunEnchant(
            {"Secret Hunter","Ultra Roller"},
            {"Secret Hunter","Ultra Roller"},
            "Shadow Crystal",
            "Shadow Crystal"
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
            "Gems"
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
            "Shadow Crystal"
        )
    end
})
