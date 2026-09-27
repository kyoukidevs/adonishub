local Players = game:GetService("Players")
local Replicated = game:GetService("ReplicatedStorage")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Client = Players.LocalPlayer
local leaderstats = Client:WaitForChild("leaderstats")
local Rebirths = leaderstats.Rebirths
local Muscle = leaderstats.Strength
local MuscleEvent = Client:WaitForChild("muscleEvent")

local RebirthController = require(Replicated.client.controllers.RebirthController)
local Globals = require(Replicated.shared.modules.GlobalFunctions);
local SkipRebirthAnimationConfig = require(ReplicatedStorage.shared.config.SkipRebirthAnimationConfig)

local RequiredMuscle = 0
local CalculateRebirthPrice = function()
    RequiredMuscle = Globals.calculateNextRebirthMultiplier(Rebirths.Value) * 1000
    print(RequiredMuscle * 1000)
end

local AutoLift = function(Value)
    Client:SetAttribute("AutoLiftEnabled", Value)
end

local AutoReb = false 
local AutoRebirth = function(Value)
    AutoReb = Value
end
local DoRebirth = function()
    if Muscle.Value < RequiredMuscle then 
        return 
    end
    RebirthController:RequestRebirth()
    CalculateRebirthPrice()
end

do 
    local Window = Library:CreateWindow({
        Title = "adonishub",
        Footer = "Muscle Legends"
    })

    task.spawn(function()
        while task.wait() do 
            if Client:GetAttribute("AutoLiftEnabled") == true and Client.Character then 
                if Client.Backpack:FindFirstChild"Weight" then 
                    Client.Backpack.Weight.Parent = Client.Character
                end
            end
        end
    end)

    task.spawn(function()
        while task.wait() do 
            if AutoReb then 
                DoRebirth()
            end
        end
    end)

    local Tab = Window:AddTab("Main", "user") -- Title, Image
    local Section = Tab:AddGroupbox({
        Side = "Left",
        Name = "Auto"
    })

    Section:AddToggle("1",{Text = "Auto Lift", Default = false, Callback = AutoLift})
    Section:AddToggle("2",{Text = "Auto Rebirth", Default = AutoReb, Callback = AutoRebirth})
    Section:AddToggle("3", {Text = "Skip Rebirth Animation", Default = false, Callback = function(Val)
        Client:SetAttribute("SkipRebirthAnimation", Value)
        setreadonly(SkipRebirthAnimationConfig, false)
        SkipRebirthAnimationConfig.SettingEnabled = Value
        setreadonly(SkipRebirthAnimationConfig, true)
    end})
end
