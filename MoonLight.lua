local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "MoonLight Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})
local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Section = Tab:AddSection({
	Name = "Esp & Toggles"
})
Tab:AddToggle({
    Name = "ESP MURDER",
    Default = false,
    Callback = function(Value)
        if Value then
            EnableMurderESP()
        else
            DisableMurderESP()
        end
    end    
})

Tab:AddToggle({
    Name = "ESP SHERIFF",
    Default = false,
    Callback = function(Value)
        if Value then
            EnableSheriffESP()
        else
            DisableSheriffESP()
        end
    end    
})

Tab:AddToggle({
    Name = "ESP SHERIFF GUN",
    Default = false,
    Callback = function(Value)
        if Value then
            EnableWeaponESP()
        else
            DisableWeaponESP()
        end
    end    
})
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function removeCooldown()
    local CombatFramework = --[[ Referência ao CombatFramework ]]
    
    local function interceptAttack()
        local activeController = getupvalues(CombatFramework)[2]['activeController']
        if activeController and activeController.timeToNextAttack then
            activeController.timeToNextAttack = 0
            activeController.hitboxMagnitude = 50
            activeController:attack()
        end
    end

    local function onMouseClick()
        interceptAttack()
    end

    return RunService.Stepped:Connect(interceptAttack), UserInputService.InputBegan:Connect(onMouseClick)
end

local function SuperHitBox()
    local function increaseHitBox(character)
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.HipWidth = 50 -- Ajuste conforme necessário
            character.Humanoid.HipHeight = 50 -- Ajuste conforme necessário
            -- Adicione outras propriedades que você deseja ajustar para aumentar a Hitbox aqui
        end
    end

    local function onCharacterAdded(character)
        local player = Players:GetPlayerFromCharacter(character)
        if player and (player.Team.Name == "Sheriff" or player.Team.Name == "Murderer") then
            increaseHitBox(character)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(character)
        end)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            onCharacterAdded(player.Character)
        end
    end
end

local function enableSuperHitBox()
    SuperHitBox()
end

enableSuperHitBox()
local function SuperKnifeHitBox()
    local function increaseKnifeHitBox()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Knife") then
                local knife = player.Character.Knife
                knife.Hitbox.Size = Vector3.new(10, 10, 10) -- Ajuste conforme necessário
                -- Adicione outras propriedades que você deseja ajustar para aumentar a Hitbox da faca aqui
            end
        end
    end

    increaseKnifeHitBox()
end
local function enableSuperKnifeHitBox()
    return RunService.Stepped:Connect(SuperKnifeHitBox)
end
local stepConnection, clickConnection = removeCooldown()
local hitboxConnection = enableSuperHitBox()
local knifeHitboxConnection = enableSuperKnifeHitBox()
local autoCoinConnection = enableAutoCoin()
local espConnection = enableESP()
local sheriffGunEspConnection = enableESPForSheriffGun()
local AutoCoinEnabled = false
local NoClipEnabled = false
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Tab:AddToggle({
    Name = "Auto Coin",
    Default = false,
    Callback = function(Value)
        AutoCoinEnabled = Value
    end    
})

Tab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(Value)
        NoClipEnabled = Value
        if Value then
            game:GetService("RunService"):BindToRenderStep("NoClip", Enum.RenderPriority.Camera.Value + 1, function()
                lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end)
        else
            game:GetService("RunService"):UnbindFromRenderStep("NoClip")
        end
    end    
})

local function AutoCollectCoins()
    while AutoCoinEnabled do
        if nameMap ~= "" and wp[nameMap] ~= nil then
            local cashBag = lplr.PlayerGui.MainGUI.Game.CashBag
            if cashBag then
                local coinsText = cashBag:FindFirstChild("Coins")
                if coinsText then
                    local currentCoins = tonumber(coinsText.Text) or 0
                    local targetCoins = 15
                    if cashBag:FindFirstChild("Elite") then
                        targetCoins = 10
                    end
                    if currentCoins < targetCoins then
                        local coinContainer = wp[nameMap]:FindFirstChild("CoinContainer")
                        local lowerTorso = lplr.Character:FindFirstChild("LowerTorso")
                        if coinContainer and lowerTorso then
                            for _, coin in ipairs(coinContainer:GetChildren()) do
                                lplr.Character.HumanoidRootPart.CFrame = coin.CFrame
                                wait(0.5) -- Wait para evitar detecção de velocidade de movimento anormal
                            end
                        end
                    end
                end
            end
        end
        wait(1) -- Ajustado para um segundo
    end
end

spawn(AutoCollectCoins)

-- Fazer o personagem invisível para outros jogadores
for _, part in ipairs(lplr.Character:GetDescendants()) do
    if part:IsA("BasePart") then
        part.Transparency = 1
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if NoClipEnabled then
        lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end)
local function CreateESP(object, color)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = object
    billboardGui.Size = UDim2.new(0, 100, 0, 20)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Name = "ESP"
    billboardGui.Parent = object

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = "ESP"
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
end

local function EnableMurderESP()
    local function OnCharacterAdded(character)
        CreateESP(character.Parent.Head, Color3.new(1, 0, 0))
    end

    local function OnPlayerAdded(player)
        player.CharacterAdded:Connect(OnCharacterAdded)
        if player.Character then
            OnCharacterAdded(player.Character)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        OnPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(OnPlayerAdded)
end

local function DisableMurderESP()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local esp = character:FindFirstChild("ESP")
            if esp then
                esp:Destroy()
            end
        end
    end
end

local function EnableSheriffESP()
    local function OnCharacterAdded(character)
        if character.Parent:IsA("Player") then
            local sheriff = character:WaitForChild("Sheriff")
            if sheriff then
                CreateESP(sheriff, Color3.new(0, 0, 1))
            end
        end
    end

    local function OnPlayerAdded(player)
        player.CharacterAdded:Connect(OnCharacterAdded)
        if player.Character then
            OnCharacterAdded(player.Character)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        OnPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(OnPlayerAdded)
end

local function DisableSheriffESP()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local sheriffESP = character:FindFirstChild("ESP")
            if sheriffESP and sheriffESP:IsA("Model") and sheriffESP:FindFirstChild("Sheriff") then
                sheriffESP:Destroy()
            end
        end
    end
end

local function EnableWeaponESP()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "GunDrop" then
            CreateESP(child, Color3.new(1, 0.5, 0))
            workspace.GunDrop.CFrame = CFrame.new(game.Players.LocalPlayer.Character.Head.Position)
        end
    end)
end

local function DisableWeaponESP()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "GunDrop" then
            local esp = child:FindFirstChild("ESP")
            if esp then
                esp:Destroy()
            end
        end
    end
end

OrionLib:Init()
