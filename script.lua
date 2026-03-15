-- KEEK DUEL HUB (Improved UI + All Features)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- STATE
local State = {
    SpeedEnabled = false,
    AutoPlayEnabled = false,
    AimbotEnabled = false,
    FloatEnabled = false,

    SpeedBoost = 57,
    FloatHeight = 5,

    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

-- REMOVE OLD GUI
local old = PlayerGui:FindFirstChild("KeekDuel")
if old then old:Destroy() end

-- GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeekDuel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(0,220,0,40)
Header.Position = UDim2.new(0.5,-110,0,40)
Header.BackgroundColor3 = Color3.fromRGB(20,20,20)
Header.Parent = ScreenGui

Instance.new("UICorner",Header).CornerRadius = UDim.new(0,10)

local headerStroke = Instance.new("UIStroke")
headerStroke.Color = Color3.fromRGB(255,0,0)
headerStroke.Thickness = 2
headerStroke.Parent = Header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "KEEK DUEL"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,70,70)
title.Parent = Header

-- MENU BUTTON
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0,55,0,55)
MenuBtn.Position = UDim2.new(0,16,0.5,-28)
MenuBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
MenuBtn.Text = "☰"
MenuBtn.TextSize = 28
MenuBtn.TextColor3 = Color3.fromRGB(255,70,70)
MenuBtn.Parent = ScreenGui

Instance.new("UICorner",MenuBtn).CornerRadius = UDim.new(0,12)

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(255,0,0)
menuStroke.Thickness = 2
menuStroke.Parent = MenuBtn

-- MAIN PANEL
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0,260,0,240)
MainPanel.Position = UDim2.new(0.5,-130,0.5,-120)
MainPanel.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainPanel.Visible = false
MainPanel.Parent = ScreenGui

Instance.new("UICorner",MainPanel).CornerRadius = UDim.new(0,14)

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255,0,0)
panelStroke.Thickness = 2
panelStroke.Parent = MainPanel

-- BUTTON CREATOR
local function createButton(text,order)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = UDim2.new(0,10,0,10 + order*38)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,70,70)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = MainPanel

    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255,0,0)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    return btn
end

-- BUTTONS
local SpeedBtn = createButton("Speed",0)
local AutoBtn = createButton("Auto Play",1)
local AimBtn = createButton("Aimbot",2)
local FloatBtn = createButton("Float",3)
local TpBtn = createButton("TP Ragdoll",4)
local DropBtn = createButton("Drop",5)

-- MENU TOGGLE
MenuBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

-- DRAG BUTTON
MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.Dragging = true
        State.DragStart = input.Position
        State.StartPos = MenuBtn.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if State.Dragging then

        local delta = input.Position - State.DragStart

        MenuBtn.Position = UDim2.new(
            State.StartPos.X.Scale,
            State.StartPos.X.Offset + delta.X,
            State.StartPos.Y.Scale,
            State.StartPos.Y.Offset + delta.Y
        )

    end
end)

-- SPEED
SpeedBtn.MouseButton1Click:Connect(function()
    State.SpeedEnabled = not State.SpeedEnabled
end)

RunService.RenderStepped:Connect(function()

    if State.SpeedEnabled then

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = State.SpeedBoost
            end
        end

    end

end)

-- AUTO PLAY
AutoBtn.MouseButton1Click:Connect(function()
    State.AutoPlayEnabled = not State.AutoPlayEnabled
end)

RunService.RenderStepped:Connect(function()

    if not State.AutoPlayEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:Move(Vector3.new(1,0,0),true)
    end

end)

-- AIMBOT
local function getNearest()

    local closest
    local dist = math.huge

    for _,p in pairs(Players:GetPlayers()) do

        if p ~= LocalPlayer and p.Character then

            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if root and my then

                local d = (root.Position - my.Position).Magnitude

                if d < dist then
                    dist = d
                    closest = root
                end

            end
        end
    end

    return closest
end

AimBtn.MouseButton1Click:Connect(function()
    State.AimbotEnabled = not State.AimbotEnabled
end)

RunService.RenderStepped:Connect(function()

    if not State.AimbotEnabled then return end

    local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local target = getNearest()

    if my and target then
        my.CFrame = CFrame.new(my.Position,target.Position)
    end

end)

-- FLOAT
FloatBtn.MouseButton1Click:Connect(function()
    State.FloatEnabled = not State.FloatEnabled
end)

RunService.RenderStepped:Connect(function()

    if not State.FloatEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")

    if root then
        root.Velocity = Vector3.new(0,State.FloatHeight,0)
    end

end)

-- TP RAGDOLL
TpBtn.MouseButton1Click:Connect(function()

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")

    for _,p in pairs(Players:GetPlayers()) do

        if p ~= LocalPlayer and p.Character then

            local target = p.Character:FindFirstChild("HumanoidRootPart")

            if target then
                root.CFrame = target.CFrame * CFrame.new(0,0,2)
                break
            end

        end
    end

end)

-- DROP
DropBtn.MouseButton1Click:Connect(function()

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")

    if root then
        root.Velocity = Vector3.new(0,200,0)
    end

end)
