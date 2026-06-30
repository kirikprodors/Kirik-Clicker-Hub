-- [[ KIRIK CLICKER HUB V1.0 ]] --
-- Оптимизировано для Delta и Arceus X Neo. Безопасные потоки.

local Player = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Удаление старой версии, если она была запущена
if CoreGui:FindFirstChild("KirikClickerHub") then
    CoreGui.KirikClickerHub:Destroy()
end

-- Переменные кликера
_G.ClickerEnabled = false
_G.ClickDelay = 0.1
local SelectedTargets = {}

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikClickerHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Создание главной панели (MainFrame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UIDimensions or UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255) -- Дефолтный Неон
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Темы оформления
local Themes = {
    Neon = {Border = Color3.fromRGB(255, 0, 255), Text = Color3.fromRGB(255, 255, 255), BG = Color3.fromRGB(15, 15, 15)},
    Hacker = {Border = Color3.fromRGB(0, 255, 0), Text = Color3.fromRGB(0, 255, 0), BG = Color3.fromRGB(5, 15, 5)},
    BlackWhite = {Border = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(255, 255, 255), BG = Color3.fromRGB(20, 20, 20)}
}

local function ApplyTheme(theme)
    MainFrame.BorderColor3 = theme.Border
    MainFrame.BackgroundColor3 = theme.BG
end

-- Верхний бар (Заголовок)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 250, 0, 30)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KIRIK CLICKER HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Кнопка закрытия (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
CloseButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame
CloseButton.MouseButton1Click:Connect(function()
    _G.ClickerEnabled = false
    ScreenGui:Destroy()
end)

-- Иконка сворачивания (-)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -60, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MinimizeButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 0)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame

-- Создание маленькой кнопки открытия (+)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 140, 0, 30)
OpenButton.Position = UDim2.new(0.5, -70, 0, 10)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.BorderColor3 = Color3.fromRGB(255, 0, 255)
OpenButton.BorderSizePixel = 2
OpenButton.Text = "KIRIK HUB V50 +"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.TextSize = 14
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- Боковое меню вкладок (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -40)
Sidebar.Position = UDim2.new(0, 5, 0, 35)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = Sidebar

-- Контейнеры для содержимого вкладок
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -45)
ContentFrame.Position = UDim2.new(0, 120, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local HomeTab = Instance.new("ScrollingFrame")
HomeTab.Size = UDim2.new(1, 0, 1, 0)
HomeTab.BackgroundTransparency = 1
HomeTab.CanvasSize = UDim2.new(0, 0, 1.5, 0)
HomeTab.ScrollBarThickness = 4
HomeTab.Visible = true
HomeTab.Parent = ContentFrame

local SettingsTab = Instance.new("ScrollingFrame")
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.CanvasSize = UDim2.new(0, 0, 1, 0)
SettingsTab.ScrollBarThickness = 4
SettingsTab.Visible = false
SettingsTab.Parent = ContentFrame

-- Функция создания кнопок переключения вкладок
local function CreateTabButton(name, tabObject)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Button.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 16
    Button.Parent = Sidebar
    
    Button.MouseButton1Click:Connect(function()
        HomeTab.Visible = false
        SettingsTab.Visible = false
        tabObject.Visible = true
    end)
end

CreateTabButton("HOME", HomeTab)
CreateTabButton("SETTINGS", SettingsTab)

----------------------------------------------------
-- [[ ВКЛАДКА HOME: ПРОДВИНУТЫЙ АВТОКЛИКЕР ]] --
----------------------------------------------------

local HomeLayout = Instance.new("UIListLayout")
HomeLayout.Padding = UDim.new(0, 8)
HomeLayout.Parent = HomeTab

-- Переключатель ВКЛ/ВЫКЛ кликера
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -10, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Text = "AUTO CLICKER: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = HomeTab

ToggleButton.MouseButton1Click:Connect(function()
    _G.ClickerEnabled = not _G.ClickerEnabled
    if _G.ClickerEnabled then
        ToggleButton.Text = "AUTO CLICKER: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        ToggleButton.Text = "AUTO CLICKER: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        ToggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Поле ввода задержки (TextBox)
local DelayFrame = Instance.new("Frame")
DelayFrame.Size = UDim2.new(1, -10, 0, 35)
DelayFrame.BackgroundTransparency = 1
DelayFrame.Parent = HomeTab

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 180, 1, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "DELAY (SECONDS):"
DelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayLabel.Font = Enum.Font.SourceSansBold
DelayLabel.TextSize = 14
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = DelayFrame

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(1, -190, 1, 0)
DelayInput.Position = UDim2.new(0, 190, 0, 0)
DelayInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DelayInput.BorderColor3 = Color3.fromRGB(100, 100, 100)
DelayInput.Text = "0.1"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.Font = Enum.Font.SourceSans
DelayInput.TextSize = 14
DelayInput.Parent = DelayFrame

DelayInput.FocusLost:Connect(function()
    local val = tonumber(DelayInput.Text)
    if val then
        _G.ClickDelay = math.max(val, 0.01) -- Защита от 0 (краша)
    else
        DelayInput.Text = tostring(_G.ClickDelay)
    end
end)

-- Список выбранных GUI объектов
local TargetListFrame = Instance.new("Frame")
TargetListFrame.Size = UDim2.new(1, -10, 0, 100)
TargetListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TargetListFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
TargetListFrame.Parent = HomeTab

local TargetListScroll = Instance.new("ScrollingFrame")
TargetListScroll.Size = UDim2.new(1, -4, 1, -4)
TargetListScroll.Position = UDim2.new(0, 2, 0, 2)
TargetListScroll.BackgroundTransparency = 1
TargetListScroll.CanvasSize = UDim2.new(0, 0, 2, 0)
TargetListScroll.ScrollBarThickness = 2
TargetListScroll.Parent = TargetListFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 3)
ListLayout.Parent = TargetListScroll

-- Обновление UI списка целей
local function UpdateTargetListUI()
    for _, child in ipairs(TargetListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for index, obj in ipairs(SelectedTargets) do
        if obj and obj.Parent then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, -5, 0, 24)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = TargetListScroll

            local ItemLabel = Instance.new("TextLabel")
            ItemLabel.Size = UDim2.new(1, -30, 1, 0)
            ItemLabel.BackgroundTransparency = 1
            ItemLabel.Text = " " .. obj.Name .. " [" .. obj.ClassName .. "]"
            ItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            ItemLabel.Font = Enum.Font.SourceSans
            ItemLabel.TextSize = 12
            ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
            ItemLabel.Parent = ItemFrame

            local RemoveBtn = Instance.new("TextButton")
            RemoveBtn.Size = UDim2.new(0, 20, 0, 20)
            RemoveBtn.Position = UDim2.new(1, -22, 0, 2)
            RemoveBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            RemoveBtn.Text = "X"
            RemoveBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            RemoveBtn.TextSize = 12
            RemoveBtn.Font = Enum.Font.SourceSansBold
            RemoveBtn.Parent = ItemFrame

            RemoveBtn.MouseButton1Click:Connect(function()
                table.remove(SelectedTargets, index)
                UpdateTargetListUI()
            end)
        end
    end
end

-- Кнопка: Выбрать экранную кнопку (Screen GUI)
local SelectScreenBtn = Instance.new("TextButton")
SelectScreenBtn.Size = UDim2.new(1, -10, 0, 30)
SelectScreenBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
SelectScreenBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
SelectScreenBtn.Text = "SELECT SCREEN GUI BUTTON"
SelectScreenBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
SelectScreenBtn.Font = Enum.Font.SourceSansBold
SelectScreenBtn.TextSize = 14
SelectScreenBtn.Parent = HomeTab

SelectScreenBtn.MouseButton1Click:Connect(function()
    SelectScreenBtn.Text = "CLICK ANY GUI ON SCREEN..."
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local x, y = input.Position.X, input.Position.Y
            local guiObjects = Player.PlayerGui:GetGuiObjectsAtPosition(x, y)
            for _, gui in ipairs(guiObjects) do
                if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                    if not table.find(SelectedTargets, gui) then
                        table.insert(SelectedTargets, gui)
                        UpdateTargetListUI()
                    end
                    break
                end
            end
            connection:Disconnect()
            SelectScreenBtn.Text = "SELECT SCREEN GUI BUTTON"
        end
    end)
end)

-- Кнопка: Выбрать кликер на парте (ClickDetector / SurfaceGui / ProximityPrompt)
local SelectPartBtn = Instance.new("TextButton")
SelectPartBtn.Size = UDim2.new(1, -10, 0, 30)
SelectPartBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 45)
SelectPartBtn.BorderColor3 = Color3.fromRGB(150, 0, 255)
SelectPartBtn.Text = "SELECT OBJECT IN WORLD (PART)"
SelectPartBtn.TextColor3 = Color3.fromRGB(200, 100, 255)
SelectPartBtn.Font = Enum.Font.SourceSansBold
SelectPartBtn.TextSize = 14
SelectPartBtn.Parent = HomeTab

SelectPartBtn.MouseButton1Click:Connect(function()
    SelectPartBtn.Text = "TAP ON A PART IN THE WORLD..."
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y)
            local hitPart = workspace:FindPartOnRay(ray, Player.Character)
            if hitPart then
                -- Ищем триггеры внутри парта
                local target = hitPart:FindFirstChildOfClass("ClickDetector") 
                    or hitPart:FindFirstChildOfClass("ProximityPrompt") 
                    or hitPart:FindFirstChildOfClass("SurfaceGui")
                    or hitPart
                
                if not table.find(SelectedTargets, target) then
                    table.insert(SelectedTargets, target)
                    UpdateTargetListUI()
                end
            end
            connection:Disconnect()
            SelectPartBtn.Text = "SELECT OBJECT IN WORLD (PART)"
        end
    end)
end)

----------------------------------------------------
-- [[ ВКЛАДКА SETTINGS: НАСТРОЙКИ ]] --
----------------------------------------------------

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 8)
SettingsLayout.Parent = SettingsTab

-- Кастомный масштаб (Shrink UI)
local ShrinkFrame = Instance.new("Frame")
ShrinkFrame.Size = UDim2.new(1, -10, 0, 35)
ShrinkFrame.BackgroundTransparency = 1
ShrinkFrame.Parent = SettingsTab

local ShrinkLabel = Instance.new("TextLabel")
ShrinkLabel.Size = UDim2.new(0, 180, 1, 0)
ShrinkLabel.BackgroundTransparency = 1
ShrinkLabel.Text = "SHRINK UI (Ex: 1.5 = smaller):"
ShrinkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ShrinkLabel.Font = Enum.Font.SourceSansBold
ShrinkLabel.TextSize = 14
ShrinkLabel.TextXAlignment = Enum.TextXAlignment.Left
ShrinkLabel.Parent = ShrinkFrame

local ShrinkInput = Instance.new("TextBox")
ShrinkInput.Size = UDim2.new(1, -190, 1, 0)
ShrinkInput.Position = UDim2.new(0, 190, 0, 0)
ShrinkInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ShrinkInput.BorderColor3 = Color3.fromRGB(100, 100, 100)
ShrinkInput.Text = "1"
ShrinkInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ShrinkInput.Font = Enum.Font.SourceSans
ShrinkInput.TextSize = 14
ShrinkInput.Parent = ShrinkFrame

ShrinkInput.FocusLost:Connect(function()
    local scale = tonumber(ShrinkInput.Text)
    if scale and scale >= 0.5 and scale <= 3 then
        MainFrame.Size = UDim2.new(0, 450 / scale, 0, 300 / scale)
    else
        ShrinkInput.Text = "1"
        MainFrame.Size = UDim2.new(0, 450, 0, 300)
    end
end)

-- Функции тем (Кнопки переключения)
local function CreateThemeButton(name, themeData)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.BorderColor3 = themeData.Border
    Btn.Text = name
    Btn.TextColor3 = themeData.Text
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = SettingsTab
    Btn.MouseButton1Click:Connect(function()
        ApplyTheme(themeData)
    end)
end

CreateThemeButton("THEME: NEON (PURPLE)", Themes.Neon)
CreateThemeButton("THEME: HACKER (GREEN)", Themes.Hacker)
CreateThemeButton("THEME: BLACK & WHITE", Themes.BlackWhite)

-- Anti-AFK
local AntiAFKBtn = Instance.new("TextButton")
AntiAFKBtn.Size = UDim2.new(1, -10, 0, 35)
AntiAFKBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
AntiAFKBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
AntiAFKBtn.Text = "ROBLOX ANTI-AFK: ON"
AntiAFKBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
AntiAFKBtn.Font = Enum.Font.SourceSansBold
AntiAFKBtn.TextSize = 14
AntiAFKBtn.Parent = SettingsTab

local afkConnection = Player.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
end)

----------------------------------------------------
-- [[ ИЗОЛИРОВАННЫЙ ЦИКЛ КЛИКЕРА (БЕЗОПАСНЫЙ) ]] --
----------------------------------------------------

task.spawn(function()
    while true do
        if _G.ClickerEnabled and #SelectedTargets > 0 then
            for _, target in ipairs(SelectedTargets) do
                if not _G.ClickerEnabled then break end
                if target and target.Parent then
                    pcall(function()
                        if target:IsA("TextButton") or target:IsA("ImageButton") then
                            -- Клик по Screen GUI кнопке на экране
                            local x = target.AbsolutePosition.X + (target.AbsoluteSize.X / 2)
                            local y = target.AbsolutePosition.Y + (target.AbsoluteSize.Y / 2) + 40
                            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
                        elseif target:IsA("ClickDetector") then
                            -- Клик по ClickDetector внутри парта
                            fireclickdetector(target)
                        elseif target:IsA("ProximityPrompt") then
                            -- Активация ProximityPrompt
                            fireproximityprompt(target)
                        elseif target:IsA("SurfaceGui") or target:IsA("BillboardGui") then
                            -- Если выбрали контейнер, пробуем кликнуть по кнопкам внутри него
                            local btn = target:FindFirstChildOfClass("TextButton") or target:FindFirstChildOfClass("ImageButton")
                            if btn then
                                local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2)
                                local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2) + 40
                                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
                            end
                        end
                    end)
                end
            end
        end
        -- Динамическая задержка с защитой от зависания телефона
        task.wait(math.max(_G.ClickDelay, 0.01))
    end
end)
