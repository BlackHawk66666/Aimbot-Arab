-- الإعدادات
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local FOV = 100
local aimPart = "Head"
local aimbotOn = false
local espOn = false
local silentAimOn = false
local hitChanceOn = false
local teamCheckOn = false

-- واجهة المستخدم
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "MadaraCombatUI"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 250, 0, 360)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚔️ Aimbot Arab ⚔️"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local function createToggleButton(parent, text, yPos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = text .. ": OFF"
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(state)
    end)
end

createToggleButton(mainFrame, "Aimbot", 50, function(state) aimbotOn = state end)
createToggleButton(mainFrame, "ESP", 90, function(state) espOn = state end)
createToggleButton(mainFrame, "Silent Aim", 130, function(state) silentAimOn = state end)
createToggleButton(mainFrame, "Hit Chance", 170, function(state) hitChanceOn = state end)
createToggleButton(mainFrame, "Team Check", 210, function(state) teamCheckOn = state end)

local parts = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}
local partIndex = 1
local partBtn = Instance.new("TextButton", mainFrame)
partBtn.Size = UDim2.new(0.9, 0, 0, 30)
partBtn.Position = UDim2.new(0.05, 0, 0, 250)
partBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
partBtn.Text = "AimPart: " .. aimPart
partBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
partBtn.Font = Enum.Font.Gotham
partBtn.TextSize = 16
Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 6)

partBtn.MouseButton1Click:Connect(function()
    partIndex = partIndex % #parts + 1
    aimPart = parts[partIndex]
    partBtn.Text = "AimPart: " .. aimPart
end)

local hideBtn = Instance.new("TextButton", mainFrame)
hideBtn.Size = UDim2.new(0, 30, 0, 30)
hideBtn.Position = UDim2.new(1, -35, 0, 5)
hideBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
hideBtn.Text = "×"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 18
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(1, 0)

local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.new(0, 40, 0, 40)
showBtn.Position = UDim2.new(0, 10, 0, 10)
showBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
showBtn.Text = "☁️"
showBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
showBtn.Font = Enum.Font.GothamBold
showBtn.TextSize = 22
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(1, 0)
showBtn.Visible = false

hideBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    showBtn.Visible = false
end)

local dragging = false
local dragStart, startPos
showBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = showBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - showBtn.AbsoluteSize.X)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - showBtn.AbsoluteSize.Y)
        showBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
fovCircle.Radius = FOV
fovCircle.Color = Color3.fromRGB(0, 170, 255)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Transparency = 1

local espObjects = {}
local function createESPBox(player)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1.5
    tracer.Color = Color3.fromRGB(255, 0, 0)
    espObjects[player] = {Box = box, Tracer = tracer}
end

local function removeESPBox(player)
    if espObjects[player] then
        espObjects[player].Box:Remove()
        espObjects[player].Tracer:Remove()
        espObjects[player] = nil
    end
end

local function isEnemy(player)
    if teamCheckOn then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[player] then
                createESPBox(player)
            end
            local esp = espObjects[player]
            local hrp = player.Character.HumanoidRootPart
            local cf = hrp.CFrame
            local pos, visible = Camera:WorldToViewportPoint(cf.Position)
            if visible and espOn then
                local topLeft = Camera:WorldToViewportPoint((cf * CFrame.new(-2, 3, 0)).Position)
                local bottomRight = Camera:WorldToViewportPoint((cf * CFrame.new(2, -3, 0)).Position)
                esp.Box.Position = Vector2.new(topLeft.X, topLeft.Y)
                esp.Box.Size = Vector2.new(bottomRight.X - topLeft.X, bottomRight.Y - topLeft.Y)
                esp.Box.Visible = true
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                esp.Tracer.Visible = true
            else
                esp.Box.Visible = false
                esp.Tracer.Visible = false
            end
        else
            removeESPBox(player)
        end
    end
end

local function getClosestEnemy()
    local closest, shortest = nil, FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) and p.Character and p.Character:FindFirstChild(aimPart) then
            local part = p.Character[aimPart]
            local pos, visible = Camera:WorldToViewportPoint(part.Position)
            if visible then
                local dist = (Vector2.new(pos.X, pos.Y) - Camera.ViewportSize / 2).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

getgenv().SilentTarget = function()
    if not silentAimOn then return nil end
    if hitChanceOn and math.random() > 0.75 then return nil end
    local target = getClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild(aimPart) then
        return target.Character[aimPart]
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Camera.ViewportSize / 2
    fovCircle.Radius = FOV
    updateESP()
    if aimbotOn then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[aimPart].Position)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftBracket then
        FOV = math.max(20, FOV - 10)
    elseif input.KeyCode == Enum.KeyCode.RightBracket then
        FOV = math.min(300, FOV + 10)
    elseif input.KeyCode == Enum.KeyCode.Semicolon then
        fovCircle.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
    end
end)
