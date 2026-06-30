-- Wait for LocalPlayer to safely initialize
local Players = game:GetService("Players") 
while not Players.LocalPlayer do 
    task.wait() 
end 
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

local UIS = game:GetService("UserInputService") 
local RunService = game:GetService("RunService") 
local TS = game:GetService("TweenService")

-- Safe VirtualUser fetch 
local VirtualUser = nil 
pcall(function() 
    VirtualUser = game:GetService("VirtualUser") 
end)

-- ==================== GLOBAL REGISTRY ==================== 
local ServiceConnections = {} 
local function AddServiceConn(conn) 
    table.insert(ServiceConnections, conn) 
    return conn 
end

-- ==================== OLD THREAD CLEANUP ==================== 
local function CleanOldInstances() 
    pcall(function() 
        local cg = game:GetService("CoreGui") 
        local old = cg:FindFirstChild("KirikClickerHub") 
        if old then old:Destroy() end 
    end) 
    pcall(function() 
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") 
        if pg then 
            local old = pg:FindFirstChild("KirikClickerHub") 
            if old then old:Destroy() end 
        end 
    end) 
end 
CleanOldInstances()

-- ==================== POLYMORPHIC CLIPBOARD WRAPPER ==================== 
local function setClipboardSafely(text) 
    local setclip = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set) 
    if setclip then 
        local success = pcall(function() setclip(text) end) 
        return success and "copied" or "failed" 
    else 
        print("\n=== [KIRIK HUB SAVE CODE] ===") 
        print(text) 
        print("==============================\n") 
        return "studio" 
    end 
end

-- ==================== INITIALIZE STATE VARIABLES ==================== 
local fpsActive, pingActive = false, false 
local antiAfkActive = false

-- Clicker State
local clickerActive = false
local clickTargets = {}
local waitingForTarget = false

-- ==================== FORWARD DECLARATIONS ==================== 
local ShrinkRow, ShrinkLbl, ShrinkBox, AfkRow, AfkLbl, AfkBox 
local AntiAfkBtn, FpsBtn, PingBtn, ThemeLblRow, ThemeLbl, NeonBtn, HackerBtn, BWBtn 
local SaveHeaderRow, SaveHeaderLbl, GenSaveBtn, ImportBoxRow, ImportBox, LoadSaveBtn 
local TabOrderLblRow, TabOrderLbl, ApplyOrderBtn 
local FpsLbl, PingLbl, StatsFrame, MainScaler
local MainFrame, Sidebar, TabContainer, SearchBox 
local DragHandle, Title, MinBtn, CloseBtn, WelcomeText, HomeTab
local ClickerTab, ClickerScroll, TargetListWrapper, TargetList
local ToggleClickerBtn, DelayBox, AddTargetBtn
local SettingsTab, SettingsScroll 

local OrderBoxes = {} 
local tabs, tabBtns = {}, {}

local SetAntiAfk, ApplyShrink, PerformSearch
local updateTargetList

-- ==================== BASE64 SYSTEM ==================== 
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' 
local function B64Encode(data) 
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte() 
        for i = 8, 1, -1 do 
            r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') 
        end 
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x) 
        if (#x < 6) then return '' end 
        local c = 0 
        for i = 1, 6 do 
            c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) 
        end 
        return b64chars:sub(c+1, c+1) 
    end)..({ '', '==', '=' })[#data%3+1]) 
end 

local function B64Decode(data) 
    data = string.gsub(data, '[^'..b64chars..'=]', '') 
    return (data:gsub('.', function(x) 
        if (x == '=') then return '' end 
        local r, f = '', (b64chars:find(x)-1) 
        for i = 6, 1, -1 do 
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') 
        end 
        return r 
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x) 
        if (#x ~= 8) then return '' end 
        local c = 0 
        for i = 1, 8 do 
            c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) 
        end 
        return string.char(c) 
    end)) 
end

-- ==================== THEME SYSTEM ==================== 
local currentTheme = "NEON" 
local ScreenGui = Instance.new("ScreenGui") 
ScreenGui.Name = "KirikClickerHub" 
ScreenGui.ResetOnSpawn = false

local function UpdateInstanceTheme(inst) 
    if not inst:GetAttribute("NeonStroke") then return end 
    local targetBg = inst:GetAttribute("NeonBg") 
    local targetStroke = inst:GetAttribute("NeonStroke") 
    local targetText = inst:GetAttribute("NeonText")

    if currentTheme == "HACKER" then
        targetBg = Color3.fromRGB(5, 10, 5)
        targetStroke = Color3.fromRGB(0, 255, 0)
        targetText = Color3.fromRGB(0, 255, 0)
    elseif currentTheme == "B&W" then
        targetBg = Color3.fromRGB(15, 15, 15)
        targetStroke = Color3.fromRGB(255, 255, 255)
        targetText = Color3.fromRGB(255, 255, 255)
    end

    TS:Create(inst, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundColor3 = targetBg}):Play()
    local stroke = inst:FindFirstChildWhichIsA("UIStroke")
    if stroke then 
        TS:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Color = targetStroke}):Play() 
    end
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        TS:Create(inst, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {TextColor3 = targetText}):Play()
    end
end

local function ApplyStyle(inst, strokeColor, bgColor, textColor) 
    inst:SetAttribute("NeonStroke", strokeColor or Color3.fromRGB(0, 255, 255)) 
    inst:SetAttribute("NeonBg", bgColor or Color3.fromRGB(15, 15, 20)) 
    inst:SetAttribute("NeonText", textColor or Color3.new(1, 1, 1))

    inst.BorderSizePixel = 0
    if inst:IsA("TextButton") or inst:IsA("TextBox") or inst:IsA("TextLabel") then
        inst.Font = Enum.Font.GothamBold
        inst.TextScaled = true
        if inst:IsA("TextBox") then
            if inst.Text == "TextBox" or inst.Text == "" then inst.Text = "" end
        end
    end

    local corner = inst:FindFirstChild("UICorner") or Instance.new("UICorner", inst)
    corner.CornerRadius = UDim.new(0, 4)
    local stroke = inst:FindFirstChild("UIStroke") or Instance.new("UIStroke", inst)
    stroke.Thickness = inst:IsA("TextLabel") and 1 or 1.5 
    stroke.ApplyStrokeMode = inst:IsA("TextLabel") and Enum.ApplyStrokeMode.Contextual or Enum.ApplyStrokeMode.Border

    if inst:IsA("TextButton") and not inst:GetAttribute("HoverHooked") then
        inst:SetAttribute("HoverHooked", true)
        inst.MouseEnter:Connect(function()
            TS:Create(inst, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
            TS:Create(stroke, TweenInfo.new(0.2), {Thickness = 2.5}):Play()
        end)
        inst.MouseLeave:Connect(function()
            TS:Create(inst, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TS:Create(stroke, TweenInfo.new(0.2), {Thickness = 1.5}):Play()
        end)
    end
    UpdateInstanceTheme(inst)
end

local function SetTheme(themeName) 
    currentTheme = themeName 
    for _, inst in pairs(ScreenGui:GetDescendants()) do 
        UpdateInstanceTheme(inst) 
    end 
    UpdateInstanceTheme(ScreenGui) 
end

local function ApplyToggleStyle(btn, state, defColor) 
    if not btn then return end 
    btn:SetAttribute("NeonStroke", state and Color3.fromRGB(0, 255, 0) or defColor) 
    UpdateInstanceTheme(btn) 
end

-- ==================== UI HELPERS ==================== 
local function MakeRow(parent, height) 
    local row = Instance.new("Frame", parent) 
    row.Size = UDim2.new(1, -5, 0, height or 25) 
    row.BackgroundTransparency = 1 
    return row 
end

local function MakeScrollArea(parent) 
    local scroll = Instance.new("ScrollingFrame", parent) 
    scroll.Size = UDim2.new(1, 0, 1, 0) 
    scroll.BackgroundTransparency = 1 
    scroll.ScrollBarThickness = 3 
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    local layout = Instance.new("UIListLayout", scroll) 
    layout.Padding = UDim.new(0, 5) 
    layout.SortOrder = Enum.SortOrder.LayoutOrder 
    return scroll, layout 
end

local function MakeTab(name, isDefault) 
    local btn = Instance.new("TextButton", Sidebar) 
    btn.Size = UDim2.new(1, 0, 0, 25) 
    btn.Text = name 
    btn.LayoutOrder = #tabBtns + 1 
    ApplyStyle(btn, Color3.fromRGB(0, 150, 255), Color3.fromRGB(15, 15, 20)) 
    
    local page = Instance.new("Frame", TabContainer) 
    page.Size = UDim2.new(1, 0, 1, 0) 
    page.BackgroundTransparency = 1 
    page.Visible = isDefault 
    table.insert(tabs, page) 
    table.insert(tabBtns, btn)

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do t.Visible = false end
        for _, b in ipairs(tabBtns) do 
            b:SetAttribute("NeonStroke", Color3.fromRGB(0, 150, 255))
            b:SetAttribute("NeonBg", Color3.fromRGB(15, 15, 20))
            UpdateInstanceTheme(b)
        end
        page.Visible = true
        btn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
        btn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
        UpdateInstanceTheme(btn)
    end)

    if isDefault then 
        btn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
        btn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
        UpdateInstanceTheme(btn)
    end
    return page
end

-- ==================== MAIN GUI CONSTRUCTION ==================== 
MainFrame = Instance.new("Frame") 
MainFrame.Parent = ScreenGui 
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150) 
MainFrame.Size = UDim2.new(0, 450, 0, 300) 
MainFrame.Active = true 
MainFrame.ClipsDescendants = true 
ApplyStyle(MainFrame, Color3.fromRGB(255, 0, 255), Color3.fromRGB(10, 5, 15))

MainScaler = Instance.new("UIScale", MainFrame) 
MainScaler.Scale = 1

StatsFrame = Instance.new("Frame", ScreenGui) 
StatsFrame.Position = UDim2.new(1, -120, 0, 10) 
StatsFrame.Size = UDim2.new(0, 110, 0, 50) 
StatsFrame.Visible = false 
ApplyStyle(StatsFrame, Color3.fromRGB(0, 255, 255), Color3.fromRGB(10, 5, 15))

local StatsLayout = Instance.new("UIListLayout", StatsFrame) 
StatsLayout.Padding = UDim.new(0, 4) 
StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

PingLbl = Instance.new("TextLabel", StatsFrame) 
PingLbl.Size = UDim2.new(1, -10, 0.45, 0) 
PingLbl.Text = "PING: 0 ms" 
PingLbl.BackgroundTransparency = 1 
PingLbl.Visible = false 
ApplyStyle(PingLbl, Color3.fromRGB(255, 150, 0))

FpsLbl = Instance.new("TextLabel", StatsFrame) 
FpsLbl.Size = UDim2.new(1, -10, 0.45, 0) 
FpsLbl.Text = "FPS: 0" 
FpsLbl.BackgroundTransparency = 1 
FpsLbl.Visible = false 
ApplyStyle(FpsLbl, Color3.fromRGB(0, 255, 100))

-- Dragging Logic 
DragHandle = Instance.new("Frame") 
DragHandle.Size = UDim2.new(1, -50, 0, 25) 
DragHandle.BackgroundTransparency = 1 
DragHandle.Parent = MainFrame

local dragging, dragInput, dragStart, startPos 
AddServiceConn(DragHandle.InputBegan:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = true 
        dragStart = input.Position 
        startPos = MainFrame.Position 
        input.Changed:Connect(function() 
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end 
        end) 
    end 
end)) 

AddServiceConn(DragHandle.InputChanged:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
        dragInput = input 
    end 
end)) 

AddServiceConn(UIS.InputChanged:Connect(function(input) 
    if input == dragInput and dragging then 
        local delta = input.Position - dragStart 
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + (delta.X / MainScaler.Scale), 
            startPos.Y.Scale, startPos.Y.Offset + (delta.Y / MainScaler.Scale)
        ) 
    end 
end))

Title = Instance.new("TextLabel") 
Title.Text = "KIRIK CLICKER HUB" 
Title.Size = UDim2.new(1, -60, 0, 25) 
Title.Position = UDim2.new(0, 10, 0, 0) 
Title.TextXAlignment = Enum.TextXAlignment.Left 
ApplyStyle(Title, Color3.fromRGB(255, 0, 255)) 
Title.BackgroundTransparency = 1 
Title.Parent = MainFrame

MinBtn = Instance.new("TextButton") 
MinBtn.Text = "-" 
MinBtn.Size = UDim2.new(0, 20, 0, 20) 
MinBtn.Position = UDim2.new(1, -50, 0, 3) 
ApplyStyle(MinBtn, Color3.fromRGB(255, 255, 0)) 
MinBtn.Parent = MainFrame

CloseBtn = Instance.new("TextButton") 
CloseBtn.Text = "X" 
CloseBtn.Size = UDim2.new(0, 20, 0, 20) 
CloseBtn.Position = UDim2.new(1, -25, 0, 3) 
ApplyStyle(CloseBtn, Color3.fromRGB(255, 0, 0)) 
CloseBtn.Parent = MainFrame

Sidebar = Instance.new("Frame", MainFrame) 
Sidebar.Size = UDim2.new(0, 110, 1, -35) 
Sidebar.Position = UDim2.new(0, 5, 0, 30) 
Sidebar.BackgroundTransparency = 1 

local SideLayout = Instance.new("UIListLayout", Sidebar) 
SideLayout.Padding = UDim.new(0, 5) 
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

SearchBox = Instance.new("TextBox", Sidebar) 
SearchBox.Size = UDim2.new(1, 0, 0, 25) 
SearchBox.PlaceholderText = "SEARCH..." 
SearchBox.Text = "" 
SearchBox.LayoutOrder = -1 
ApplyStyle(SearchBox, Color3.fromRGB(255, 255, 255), Color3.fromRGB(20, 20, 30))

TabContainer = Instance.new("Frame", MainFrame) 
TabContainer.Size = UDim2.new(1, -125, 1, -35) 
TabContainer.Position = UDim2.new(0, 120, 0, 30) 
TabContainer.BackgroundTransparency = 1

local minimized = false 
local isAnimating = false 

MinBtn.MouseButton1Click:Connect(function() 
    if isAnimating then return end 
    isAnimating = true 
    minimized = not minimized 
    MinBtn.Text = minimized and "+" or "-" 
    local targetSize = minimized and UDim2.new(0, 150, 0, 25) or UDim2.new(0, 450, 0, 300)

    if minimized then
        Sidebar.Visible = false
        TabContainer.Visible = false
    end

    local tw = TS:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize})
    tw:Play()
    tw.Completed:Connect(function()
        if not minimized then
            Sidebar.Visible = true
            TabContainer.Visible = true
        end
        isAnimating = false
    end)
end)

-- ==================== UI CONSTRUCTION (TABS) ==================== 
HomeTab = MakeTab("HOME", true) 
WelcomeText = Instance.new("TextLabel", HomeTab) 
WelcomeText.Size = UDim2.new(1, 0, 1, 0) 
WelcomeText.Text = "KIRIK CLICKER HUB\n\n[ FEATURES ]\n- Auto Clicker for Any GUI/Part\n- List Manager (Add/Remove)\n- Customizable Delay\n- Anti-AFK & Optimization" 
WelcomeText.TextWrapped = true 
WelcomeText.TextYAlignment = Enum.TextYAlignment.Top 
ApplyStyle(WelcomeText, Color3.fromRGB(0, 255, 255), Color3.fromRGB(15, 15, 20))

-- ==================== CLICKER TAB ==================== 
ClickerTab = MakeTab("CLICKER", false)
local CTopLayout = Instance.new("UIListLayout", ClickerTab)
CTopLayout.Padding = UDim.new(0, 5)

ToggleClickerBtn = Instance.new("TextButton", MakeRow(ClickerTab))
ToggleClickerBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleClickerBtn.Text = "CLICKER: OFF"
ApplyStyle(ToggleClickerBtn, Color3.fromRGB(255, 50, 50))

local DelayRow = MakeRow(ClickerTab)
local DelayLbl = Instance.new("TextLabel", DelayRow)
DelayLbl.Size = UDim2.new(0.65, 0, 1, 0)
DelayLbl.Text = "DELAY (SEC)"
ApplyStyle(DelayLbl, Color3.fromRGB(255, 255, 0))
DelayBox = Instance.new("TextBox", DelayRow)
DelayBox.Size = UDim2.new(0.33, 0, 1, 0)
DelayBox.Position = UDim2.new(0.67, 0, 0, 0)
DelayBox.Text = "0.1"
ApplyStyle(DelayBox, Color3.fromRGB(255, 255, 0))

AddTargetBtn = Instance.new("TextButton", MakeRow(ClickerTab))
AddTargetBtn.Size = UDim2.new(1, 0, 1, 0)
AddTargetBtn.Text = "CLICK TO ADD PART/GUI"
ApplyStyle(AddTargetBtn, Color3.fromRGB(0, 150, 255))

TargetListWrapper = Instance.new("Frame", ClickerTab)
TargetListWrapper.Size = UDim2.new(1, 0, 1, -95)
TargetListWrapper.BackgroundTransparency = 1
TargetList, _ = MakeScrollArea(TargetListWrapper)


-- ==================== SETTINGS TAB ==================== 
SettingsTab = MakeTab("SETTINGS", false) 
SettingsScroll, _ = MakeScrollArea(SettingsTab)

ShrinkRow = MakeRow(SettingsScroll) 
ShrinkRow.LayoutOrder = 1 
ShrinkLbl = Instance.new("TextLabel", ShrinkRow) 
ShrinkLbl.Size = UDim2.new(0.65, 0, 1, 0) 
ShrinkLbl.Text = "SHRINK UI (Ex: 2 = 2x smaller)" 
ApplyStyle(ShrinkLbl, Color3.fromRGB(255, 255, 0)) 
ShrinkBox = Instance.new("TextBox", ShrinkRow) 
ShrinkBox.Size = UDim2.new(0.33, 0, 1, 0) 
ShrinkBox.Position = UDim2.new(0.67, 0, 0, 0) 
ShrinkBox.Text = "1" 
ApplyStyle(ShrinkBox, Color3.fromRGB(255, 255, 0))

AfkRow = MakeRow(SettingsScroll) 
AfkRow.LayoutOrder = 2 
AfkLbl = Instance.new("TextLabel", AfkRow) 
AfkLbl.Size = UDim2.new(0.65, 0, 1, 0) 
AfkLbl.Text = "UI AUTOCLOSE (SEC)" 
ApplyStyle(AfkLbl, Color3.fromRGB(150, 150, 150)) 
AfkBox = Instance.new("TextBox", AfkRow) 
AfkBox.Size = UDim2.new(0.33, 0, 1, 0) 
AfkBox.Position = UDim2.new(0.67, 0, 0, 0) 
AfkBox.Text = "9999" 
ApplyStyle(AfkBox, Color3.fromRGB(150, 150, 150))

AntiAfkBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
AntiAfkBtn.Parent.LayoutOrder = 3 
AntiAfkBtn.Size = UDim2.new(1, 0, 1, 0) 
AntiAfkBtn.Text = "ROBLOX ANTI-AFK: OFF" 
ApplyStyle(AntiAfkBtn, Color3.fromRGB(0, 200, 255)) 

FpsBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
FpsBtn.Parent.LayoutOrder = 4 
FpsBtn.Size = UDim2.new(1, 0, 1, 0) 
FpsBtn.Text = "FPS HUD: OFF" 
ApplyStyle(FpsBtn, Color3.fromRGB(0, 255, 100)) 

PingBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
PingBtn.Parent.LayoutOrder = 5 
PingBtn.Size = UDim2.new(1, 0, 1, 0) 
PingBtn.Text = "PING HUD: OFF" 
ApplyStyle(PingBtn, Color3.fromRGB(255, 150, 0))

ThemeLblRow = MakeRow(SettingsScroll) 
ThemeLblRow.LayoutOrder = 6 
ThemeLbl = Instance.new("TextLabel", ThemeLblRow) 
ThemeLbl.Size = UDim2.new(1, 0, 1, 0) 
ThemeLbl.Text = "--- THEMES ---" 
ApplyStyle(ThemeLbl, Color3.fromRGB(0, 255, 255)) 

NeonBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
NeonBtn.Parent.LayoutOrder = 7 
NeonBtn.Size = UDim2.new(1, 0, 1, 0) 
NeonBtn.Text = "NEON (DEFAULT)" 
ApplyStyle(NeonBtn, Color3.fromRGB(255, 0, 255)) 

HackerBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
HackerBtn.Parent.LayoutOrder = 8 
HackerBtn.Size = UDim2.new(1, 0, 1, 0) 
HackerBtn.Text = "HACKER (GREEN)" 
ApplyStyle(HackerBtn, Color3.fromRGB(0, 255, 0)) 

BWBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
BWBtn.Parent.LayoutOrder = 9 
BWBtn.Size = UDim2.new(1, 0, 1, 0) 
BWBtn.Text = "BLACK & WHITE" 
ApplyStyle(BWBtn, Color3.fromRGB(255, 255, 255))

SaveHeaderRow = MakeRow(SettingsScroll) 
SaveHeaderRow.LayoutOrder = 10 
SaveHeaderLbl = Instance.new("TextLabel", SaveHeaderRow) 
SaveHeaderLbl.Size = UDim2.new(1, 0, 1, 0) 
SaveHeaderLbl.Text = "--- SAVE SYSTEM ---" 
ApplyStyle(SaveHeaderLbl, Color3.fromRGB(0, 255, 150)) 

GenSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
GenSaveBtn.Parent.LayoutOrder = 11 
GenSaveBtn.Size = UDim2.new(1, 0, 1, 0) 
GenSaveBtn.Text = "GENERATE SAVE CODE" 
ApplyStyle(GenSaveBtn, Color3.fromRGB(0, 255, 0)) 

ImportBoxRow = MakeRow(SettingsScroll) 
ImportBoxRow.LayoutOrder = 12 
ImportBox = Instance.new("TextBox", ImportBoxRow) 
ImportBox.Size = UDim2.new(1, 0, 1, 0) 
ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" 
ImportBox.Text = "" 
ImportBox.ClearTextOnFocus = false 
ApplyStyle(ImportBox, Color3.fromRGB(255, 150, 0)) 

LoadSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
LoadSaveBtn.Parent.LayoutOrder = 13 
LoadSaveBtn.Size = UDim2.new(1, 0, 1, 0) 
LoadSaveBtn.Text = "LOAD SAVE CODE" 
ApplyStyle(LoadSaveBtn, Color3.fromRGB(255, 0, 0))

TabOrderLblRow = MakeRow(SettingsScroll) 
TabOrderLblRow.LayoutOrder = 14 
TabOrderLbl = Instance.new("TextLabel", TabOrderLblRow) 
TabOrderLbl.Size = UDim2.new(1, 0, 1, 0) 
TabOrderLbl.Text = "--- TAB ORDER ---" 
ApplyStyle(TabOrderLbl, Color3.fromRGB(0, 255, 255))

for i, tBtn in ipairs(tabBtns) do 
    local row = MakeRow(SettingsScroll) 
    row.LayoutOrder = 20 + i 
    local lbl = Instance.new("TextLabel", row) 
    lbl.Size = UDim2.new(0.65, 0, 1, 0) 
    lbl.Text = "TAB: " .. tBtn.Text 
    ApplyStyle(lbl, Color3.fromRGB(255, 100, 0)) 
    local box = Instance.new("TextBox", row) 
    box.Size = UDim2.new(0.33, 0, 1, 0) 
    box.Position = UDim2.new(0.67, 0, 0, 0) 
    box.Text = tostring(tBtn.LayoutOrder) 
    ApplyStyle(box, Color3.fromRGB(255, 100, 0)) 
    table.insert(OrderBoxes, {btn = tBtn, box = box, row = row}) 
end

ApplyOrderBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) 
ApplyOrderBtn.Parent.LayoutOrder = 100 
ApplyOrderBtn.Size = UDim2.new(1, 0, 1, 0) 
ApplyOrderBtn.Text = "APPLY TAB ORDER" 
ApplyStyle(ApplyOrderBtn, Color3.fromRGB(0, 255, 0))

-- ==================== STATE SETTERS & LOGIC ====================
SetAntiAfk = function(state) 
    antiAfkActive = state 
    ApplyToggleStyle(AntiAfkBtn, antiAfkActive, Color3.fromRGB(0, 200, 255)) 
    if AntiAfkBtn then AntiAfkBtn.Text = "ROBLOX ANTI-AFK: " .. (antiAfkActive and "ON" or "OFF") end 
end

local function SetFPS(state) 
    fpsActive = state 
    ApplyToggleStyle(FpsBtn, fpsActive, Color3.fromRGB(0, 255, 100)) 
    if FpsBtn then FpsBtn.Text = "FPS HUD: " .. (fpsActive and "ON" or "OFF") end 
    if FpsLbl then FpsLbl.Visible = fpsActive end 
    if StatsFrame then StatsFrame.Visible = fpsActive or pingActive end 
end

local function SetPing(state) 
    pingActive = state 
    ApplyToggleStyle(PingBtn, pingActive, Color3.fromRGB(255, 150, 0)) 
    if PingBtn then PingBtn.Text = "PING HUD: " .. (pingActive and "ON" or "OFF") end 
    if PingLbl then PingLbl.Visible = pingActive end 
    if StatsFrame then StatsFrame.Visible = fpsActive or pingActive end 
end

ApplyShrink = function() 
    if not ShrinkBox or not MainScaler then return end 
    local factor = tonumber(ShrinkBox.Text) 
    if factor and factor > 0 then 
        MainScaler.Scale = 1/factor 
    else 
        ShrinkBox.Text = "1" 
        MainScaler.Scale = 1 
    end 
end

PerformSearch = function() 
    if not SearchBox then return end 
    local q = string.lower(SearchBox.Text) 
    local firstVisibleTab = nil 
    local anyTabVisible = false

    for i, tBtn in ipairs(tabBtns) do
        local tabObj = tabs[i]
        local tabMatches = string.find(string.lower(tBtn.Text), q) ~= nil
        local hasVisibleRow = false

        local scroll = tabObj:FindFirstChildOfClass("ScrollingFrame")
        if not scroll then
            local wrapper = tabObj:FindFirstChildOfClass("Frame")
            if wrapper then scroll = wrapper:FindFirstChildOfClass("ScrollingFrame") end
        end

        if scroll then
            for _, row in ipairs(scroll:GetChildren()) do
                if row:IsA("Frame") then
                    if q == "" or tabMatches then
                        row.Visible = true hasVisibleRow = true
                    else
                        local rowMatches = false
                        for _, el in ipairs(row:GetDescendants()) do
                            if (el:IsA("TextLabel") or el:IsA("TextButton") or el:IsA("TextBox")) and el.Text ~= "" then
                                if string.find(string.lower(el.Text), q) then rowMatches = true break end
                            end
                        end
                        row.Visible = rowMatches
                        if rowMatches then hasVisibleRow = true end
                    end
                end
            end
        else hasVisibleRow = true end

        if q == "" or tabMatches or hasVisibleRow then
            tBtn.Visible = true anyTabVisible = true
            if not firstVisibleTab then firstVisibleTab = i end
        else tBtn.Visible = false end
    end

    if anyTabVisible then
        local currentIsVisible = false
        for i, t in ipairs(tabs) do if t.Visible and tabBtns[i].Visible then currentIsVisible = true break end end
        if not currentIsVisible and firstVisibleTab then
            for _, t in ipairs(tabs) do t.Visible = false end
            for _, b in ipairs(tabBtns) do 
                b:SetAttribute("NeonStroke", Color3.fromRGB(0, 150, 255))
                b:SetAttribute("NeonBg", Color3.fromRGB(15, 15, 20))
                UpdateInstanceTheme(b)
            end
            tabs[firstVisibleTab].Visible = true
            local fBtn = tabBtns[firstVisibleTab]
            fBtn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
            fBtn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
            UpdateInstanceTheme(fBtn)
        end
    end
end

-- ==================== CENTRAL EVENT BINDINGS ==================== 
AddServiceConn(SearchBox:GetPropertyChangedSignal("Text"):Connect(function() PerformSearch() end)) 
ShrinkBox.FocusLost:Connect(function() ApplyShrink() end)

NeonBtn.MouseButton1Click:Connect(function() SetTheme("NEON") end) 
HackerBtn.MouseButton1Click:Connect(function() SetTheme("HACKER") end) 
BWBtn.MouseButton1Click:Connect(function() SetTheme("B&W") end)

AntiAfkBtn.MouseButton1Click:Connect(function() SetAntiAfk(not antiAfkActive) end) 
FpsBtn.MouseButton1Click:Connect(function() SetFPS(not fpsActive) end) 
PingBtn.MouseButton1Click:Connect(function() SetPing(not pingActive) end) 

-- ==================== CLICKER LOGIC ====================
updateTargetList = function()
    for _, child in pairs(TargetList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for i, target in ipairs(clickTargets) do
        local row = MakeRow(TargetList) 
        
        local infoBtn = Instance.new("TextButton", row) 
        infoBtn.Size = UDim2.new(0.75, 0, 1, 0)
        local tName = (typeof(target) == "Instance" and target.Name) or "Unknown Target"
        local tType = (typeof(target) == "Instance" and target.ClassName) or "Object"
        infoBtn.Text = "["..i.."] "..tName.." ("..tType..")"
        ApplyStyle(infoBtn, Color3.fromRGB(0, 255, 100)) 
        
        local delBtn = Instance.new("TextButton", row) 
        delBtn.Size = UDim2.new(0.2, 0, 1, 0) 
        delBtn.Position = UDim2.new(0.8, 0, 0, 0) 
        delBtn.Text = "X" 
        ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0)) 
        
        delBtn.MouseButton1Click:Connect(function() 
            table.remove(clickTargets, i) 
            updateTargetList() 
        end)
    end
end

AddTargetBtn.MouseButton1Click:Connect(function()
    waitingForTarget = true
    AddTargetBtn.Text = "WAITING... CLICK TARGET (GUI/PART)"
end)

AddServiceConn(UIS.InputBegan:Connect(function(input, gpe)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        if waitingForTarget then
            waitingForTarget = false
            local targetFound = nil
            
            -- Сначала ищем GUI элементы
            local guis = LocalPlayer:FindFirstChild("PlayerGui")
            if guis then
                local elements = guis:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
                for _, element in ipairs(elements) do
                    if element:IsA("GuiButton") and element.Active then
                        targetFound = element
                        break
                    end
                end
            end
            
            -- Если GUI не найден, ищем BasePart в Workspace
            if not targetFound and mouse.Target then
                targetFound = mouse.Target
            end
            
            if targetFound then
                table.insert(clickTargets, targetFound)
                updateTargetList()
            end
            
            AddTargetBtn.Text = "CLICK TO ADD PART/GUI"
        end
    end
end))

ToggleClickerBtn.MouseButton1Click:Connect(function()
    clickerActive = not clickerActive
    ApplyToggleStyle(ToggleClickerBtn, clickerActive, Color3.fromRGB(255, 50, 50))
    ToggleClickerBtn.Text = "CLICKER: " .. (clickerActive and "ON" or "OFF")
end)

-- Clicker Loop
task.spawn(function()
    while task.wait() do
        if clickerActive and #clickTargets > 0 then
            local delayTime = tonumber(DelayBox.Text) or 0.1
            for _, t in ipairs(clickTargets) do
                if typeof(t) == "Instance" and t.Parent then
                    if t:IsA("BasePart") then
                        local clickDet = t:FindFirstChildOfClass("ClickDetector")
                        if clickDet then 
                            fireclickdetector(clickDet) 
                        end
                        local prox = t:FindFirstChildOfClass("ProximityPrompt")
                        if prox then
                            fireproximityprompt(prox)
                        end
                    elseif t:IsA("GuiButton") then
                        if firesignal then
                            pcall(function() firesignal(t.MouseButton1Click) end)
                            pcall(function() firesignal(t.Activated) end)
                        end
                    end
                end
            end
            task.wait(delayTime)
        end
    end
end)

-- ==================== TAB & SAVE SYSTEM LOGIC ====================
local function ApplyTabOrders() 
    local temp = {} 
    for i, ob in ipairs(OrderBoxes) do 
        local lo = tonumber(ob.box.Text) or ob.btn.LayoutOrder 
        table.insert(temp, {index = i, val = lo}) 
    end 
    table.sort(temp, function(a, b) return a.val < b.val end) 
    for newPos, data in ipairs(temp) do 
        local ob = OrderBoxes[data.index] 
        ob.btn.LayoutOrder = newPos 
        ob.row.LayoutOrder = 20 + newPos 
        ob.box.Text = tostring(newPos) 
    end 
end 
ApplyOrderBtn.MouseButton1Click:Connect(ApplyTabOrders)

GenSaveBtn.MouseButton1Click:Connect(function() 
    local tgs = string.format("%d%d%d", fpsActive and 1 or 0, pingActive and 1 or 0, antiAfkActive and 1 or 0) 
        
    local orderData = {} 
    for i, ob in ipairs(OrderBoxes) do 
        table.insert(orderData, tostring(ob.btn.LayoutOrder)) 
    end 
    local tabsOrderStr = table.concat(orderData, ",") 
    
    local rawStr = string.format("%s|%s|%s|%s|%s|%s", 
        currentTheme, ShrinkBox.Text, AfkBox.Text, DelayBox.Text, tgs, tabsOrderStr) 
        
    local saveCode = "HUB-Save-" .. B64Encode(rawStr) 
    local success = setClipboardSafely(saveCode) 
    
    if success == "studio" then 
        GenSaveBtn.Text = "PRINTED TO OUTPUT!" 
    elseif success == "copied" then 
        GenSaveBtn.Text = "COPIED TO CLIPBOARD!" 
    else 
        GenSaveBtn.Text = "ERROR: NO CLIPBOARD" 
    end 
    task.delay(2.5, function() GenSaveBtn.Text = "GENERATE SAVE CODE" end) 
end)

LoadSaveBtn.MouseButton1Click:Connect(function() 
    local str = ImportBox.Text 
    if not str:match("^HUB%-Save%-") then return end 
    local pcallSuccess = pcall(function() 
        local decoded = B64Decode(str:sub(10)) 
        local p = string.split(decoded, "|") 
        if #p >= 6 then 
            SetTheme(p[1]) 
            ShrinkBox.Text = p[2] ApplyShrink() 
            AfkBox.Text = p[3] 
            DelayBox.Text = p[4]
            local t = p[5] 
            SetFPS(t:sub(1,1)=="1") 
            SetPing(t:sub(2,2)=="1") 
            SetAntiAfk(t:sub(3,3)=="1") 
            
            local tOrd = string.split(p[6], ",") 
            for i, v in ipairs(tOrd) do 
                if OrderBoxes[i] then OrderBoxes[i].box.Text = v end 
            end 
            ApplyTabOrders() 
            
            ImportBox.Text = "" 
            ImportBox.PlaceholderText = "SUCCESSFULLY LOADED!" 
            task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end) 
        end 
    end) 
    
    if not pcallSuccess then 
        ImportBox.Text = "" 
        ImportBox.PlaceholderText = "ERROR PARSING DATA!" 
        task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end) 
    end 
end)

-- ==================== CENTRALIZED LOOPS ==================== 
AddServiceConn(LocalPlayer.Idled:Connect(function() 
    if antiAfkActive and VirtualUser then 
        pcall(function() 
            VirtualUser:CaptureController() 
            VirtualUser:ClickButton2(Vector2.new(0, 0)) 
        end) 
    end 
end))

local fpsTimer, frames = 0, 0 
AddServiceConn(RunService.Heartbeat:Connect(function(dt) 
    frames = frames + 1 
    fpsTimer = fpsTimer + dt 
    if fpsTimer >= 1 then 
        if fpsActive and FpsLbl then FpsLbl.Text = "FPS: " .. frames end 
        frames, fpsTimer = 0, 0 
    end 
    
    if pingActive and PingLbl then 
        PingLbl.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms" 
    end
end))

local lastActive = tick() 
local function checkUIInteraction(input) 
    local pos = input.Position 
    if MainFrame and MainFrame.Visible then 
        local ax, ay = MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y
        local sx, sy = MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y 
        if pos.X >= ax and pos.X <= ax + sx and pos.Y >= ay and pos.Y <= ay + sy then 
            lastActive = tick() 
        end 
    end 
end 

AddServiceConn(UIS.InputBegan:Connect(checkUIInteraction)) 
AddServiceConn(UIS.InputChanged:Connect(function(input) 
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
        checkUIInteraction(input) 
    end 
end))

local function ForceCleanup() 
    SetAntiAfk(false) 
    clickerActive = false
    clickTargets = {}

    for _, conn in ipairs(ServiceConnections) do 
        if conn.Connected then conn:Disconnect() end 
    end
end

task.spawn(function() 
    while task.wait(1) do 
        if not ScreenGui.Parent then break end 
        local tbox = AfkBox and tonumber(AfkBox.Text) or 9999 
        if tick() - lastActive > tbox then 
            ForceCleanup() 
            ScreenGui:Destroy() 
            break 
        end 
    end 
end)

CloseBtn.MouseButton1Click:Connect(function() 
    ForceCleanup() 
    ScreenGui:Destroy() 
end)

-- Initial UI Setup & Parenting 
local function AssignParent() 
    local coreGui 
    pcall(function() coreGui = game:GetService("CoreGui") end) 
    if coreGui then 
        local ok = pcall(function() ScreenGui.Parent = coreGui end) 
        if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 15) end 
    else 
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 15) 
    end 
end 

AssignParent()
