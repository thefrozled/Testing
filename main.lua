--[[
    Modern UI Library for Roblox
    A clean, lightweight UI library with smooth animations and modern design
    
    Features:
    - Window creation with draggable functionality
    - Tabs system
    - Buttons, Toggles, Sliders, Dropdowns, TextBoxes, Labels
    - Color pickers
    - Keybinds
    - Smooth animations
    - Modern design with customizable themes
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Utility Functions
local function tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            tween(frame, {Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )}, 0.1)
        end
    end)
end

-- Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(100, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(40, 40, 45),
    Success = Color3.fromRGB(50, 200, 100),
    Error = Color3.fromRGB(255, 75, 75),
}

-- Create Main Library
function UILibrary:Create(options)
    options = options or {}
    local library = setmetatable({}, UILibrary)
    
    -- Create ScreenGui
    library.ScreenGui = Instance.new("ScreenGui")
    library.ScreenGui.Name = options.Name or "UILibrary"
    library.ScreenGui.ResetOnSpawn = false
    library.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success = pcall(function()
        library.ScreenGui.Parent = CoreGui
    end)
    
    if not success then
        library.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    library.Tabs = {}
    library.CurrentTab = nil
    
    return library
end

-- Create Window
function UILibrary:CreateWindow(options)
    options = options or {}
    local windowWidth = options.Width or 550
    local windowHeight = options.Height or 400
    
    -- Main Window Frame
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    Window.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    Window.BackgroundColor3 = Theme.Background
    Window.BorderSizePixel = 0
    Window.Parent = self.ScreenGui
    
    -- Corner
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 8)
    WindowCorner.Parent = Window
    
    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 0
    Shadow.Parent = Window
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar
    
    -- Title Bar Bottom Cover
    local TitleBarCover = Instance.new("Frame")
    TitleBarCover.Size = UDim2.new(1, 0, 0, 8)
    TitleBarCover.Position = UDim2.new(0, 0, 1, -8)
    TitleBarCover.BackgroundColor3 = Theme.Secondary
    TitleBarCover.BorderSizePixel = 0
    TitleBarCover.Parent = TitleBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = options.Title or "UI Library"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Theme.Error
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.Text
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        tween(Window, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
        wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Window
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -175, 1, -50)
    ContentContainer.Position = UDim2.new(0, 165, 0, 45)
    ContentContainer.BackgroundColor3 = Theme.Secondary
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = Window
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentContainer
    
    -- Make window draggable
    makeDraggable(Window, TitleBar)
    
    -- Entrance animation
    Window.Size = UDim2.new(0, 0, 0, 0)
    tween(Window, {Size = UDim2.new(0, windowWidth, 0, windowHeight)}, 0.5, Enum.EasingStyle.Back)
    
    self.Window = Window
    self.TabContainer = TabContainer
    self.ContentContainer = ContentContainer
    
    return self
end

-- Create Tab
function UILibrary:CreateTab(options)
    options = options or {}
    
    -- Tab Button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = options.Name or "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Theme.Border
    TabButton.Text = options.Name or "Tab"
    TabButton.TextColor3 = Theme.TextDark
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.BorderSizePixel = 0
    TabButton.Parent = self.TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    -- Tab Content
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = options.Name or "Tab"
    TabContent.Size = UDim2.new(1, -20, 1, -20)
    TabContent.Position = UDim2.new(0, 10, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Theme.Accent
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = TabContent
    
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab switching
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button.BackgroundColor3 = Theme.Border
            tab.Button.TextColor3 = Theme.TextDark
            tab.Content.Visible = false
        end
        
        TabButton.BackgroundColor3 = Theme.Accent
        TabButton.TextColor3 = Theme.Text
        TabContent.Visible = true
        self.CurrentTab = TabContent
    end)
    
    local tab = {
        Button = TabButton,
        Content = TabContent,
    }
    
    table.insert(self.Tabs, tab)
    
    -- Activate first tab
    if #self.Tabs == 1 then
        TabButton.BackgroundColor3 = Theme.Accent
        TabButton.TextColor3 = Theme.Text
        TabContent.Visible = true
        self.CurrentTab = TabContent
    end
    
    return setmetatable({
        TabContent = TabContent,
        Library = self
    }, {__index = UILibrary})
end

-- Create Button
function UILibrary:CreateButton(options)
    options = options or {}
    
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Theme.Border
    Button.Text = options.Text or "Button"
    Button.TextColor3 = Theme.Text
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.BorderSizePixel = 0
    Button.Parent = self.TabContent or self.CurrentTab
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        tween(Button, {BackgroundColor3 = Theme.Accent})
    end)
    
    Button.MouseLeave:Connect(function()
        tween(Button, {BackgroundColor3 = Theme.Border})
    end)
    
    Button.MouseButton1Click:Connect(function()
        tween(Button, {BackgroundColor3 = Theme.Success}, 0.1)
        wait(0.1)
        tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
        
        if options.Callback then
            options.Callback()
        end
    end)
    
    return Button
end

-- Create Toggle
function UILibrary:CreateToggle(options)
    options = options or {}
    local toggled = options.Default or false
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Theme.Border
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = self.TabContent or self.CurrentTab
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = options.Text or "Toggle"
    ToggleLabel.TextColor3 = Theme.Text
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleButton.BackgroundColor3 = toggled and Theme.Success or Theme.Secondary
    ToggleButton.Text = ""
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ToggleFrame
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.BackgroundColor3 = Theme.Text
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    local function toggle()
        toggled = not toggled
        
        tween(ToggleButton, {BackgroundColor3 = toggled and Theme.Success or Theme.Secondary})
        tween(ToggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
        
        if options.Callback then
            options.Callback(toggled)
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(toggle)
    
    return {
        Toggle = toggle,
        GetState = function() return toggled end
    }
end

-- Create Slider
function UILibrary:CreateSlider(options)
    options = options or {}
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local increment = options.Increment or 1
    local currentValue = default
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Theme.Border
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = self.TabContent or self.CurrentTab
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = options.Text or "Slider"
    SliderLabel.TextColor3 = Theme.Text
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(currentValue)
    ValueLabel.TextColor3 = Theme.Accent
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 1, -15)
    SliderBar.BackgroundColor3 = Theme.Secondary
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local SliderBarCorner = Instance.new("UICorner")
    SliderBarCorner.CornerRadius = UDim.new(1, 0)
    SliderBarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        currentValue = math.floor((min + (max - min) * relativeX) / increment + 0.5) * increment
        currentValue = math.clamp(currentValue, min, max)
        
        ValueLabel.Text = tostring(currentValue)
        tween(SliderFill, {Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)}, 0.1)
        
        if options.Callback then
            options.Callback(currentValue)
        end
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    SliderButton.MouseButton1Click:Connect(function(input)
        updateSlider(input)
    end)
    
    return {
        SetValue = function(value)
            currentValue = math.clamp(value, min, max)
            ValueLabel.Text = tostring(currentValue)
            tween(SliderFill, {Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)}, 0.1)
        end,
        GetValue = function() return currentValue end
    }
end

-- Create Dropdown
function UILibrary:CreateDropdown(options)
    options = options or {}
    local items = options.Items or {}
    local selected = options.Default or (items[1] or "None")
    local expanded = false
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = Theme.Border
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = self.TabContent or self.CurrentTab
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 35)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = ""
    DropdownButton.Parent = DropdownFrame
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(1, -30, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = (options.Text or "Dropdown") .. ": " .. selected
    DropdownLabel.TextColor3 = Theme.Text
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownIcon = Instance.new("TextLabel")
    DropdownIcon.Size = UDim2.new(0, 20, 0, 35)
    DropdownIcon.Position = UDim2.new(1, -25, 0, 0)
    DropdownIcon.BackgroundTransparency = 1
    DropdownIcon.Text = "▼"
    DropdownIcon.TextColor3 = Theme.Text
    DropdownIcon.TextSize = 12
    DropdownIcon.Font = Enum.Font.Gotham
    DropdownIcon.Parent = DropdownFrame
    
    local ItemList = Instance.new("Frame")
    ItemList.Size = UDim2.new(1, 0, 0, 0)
    ItemList.Position = UDim2.new(0, 0, 0, 35)
    ItemList.BackgroundTransparency = 1
    ItemList.Parent = DropdownFrame
    
    local ItemListLayout = Instance.new("UIListLayout")
    ItemListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ItemListLayout.Parent = ItemList
    
    local function updateDropdown()
        if expanded then
            DropdownIcon.Text = "▲"
            local totalHeight = 35 + (#items * 30)
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.2)
        else
            DropdownIcon.Text = "▼"
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
        end
    end
    
    for _, item in ipairs(items) do
        local ItemButton = Instance.new("TextButton")
        ItemButton.Size = UDim2.new(1, 0, 0, 30)
        ItemButton.BackgroundColor3 = item == selected and Theme.Accent or Theme.Secondary
        ItemButton.Text = item
        ItemButton.TextColor3 = Theme.Text
        ItemButton.TextSize = 13
        ItemButton.Font = Enum.Font.Gotham
        ItemButton.BorderSizePixel = 0
        ItemButton.Parent = ItemList
        
        ItemButton.MouseEnter:Connect(function()
            if item ~= selected then
                tween(ItemButton, {BackgroundColor3 = Theme.Border})
            end
        end)
        
        ItemButton.MouseLeave:Connect(function()
            if item ~= selected then
                tween(ItemButton, {BackgroundColor3 = Theme.Secondary})
            end
        end)
        
        ItemButton.MouseButton1Click:Connect(function()
            selected = item
            DropdownLabel.Text = (options.Text or "Dropdown") .. ": " .. selected
            
            for _, child in ipairs(ItemList:GetChildren()) do
                if child:IsA("TextButton") then
                    tween(child, {BackgroundColor3 = Theme.Secondary})
                end
            end
            
            tween(ItemButton, {BackgroundColor3 = Theme.Accent})
            
            expanded = false
            updateDropdown()
            
            if options.Callback then
                options.Callback(selected)
            end
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateDropdown()
    end)
    
    return {
        GetSelected = function() return selected end,
        SetSelected = function(item)
            if table.find(items, item) then
                selected = item
                DropdownLabel.Text = (options.Text or "Dropdown") .. ": " .. selected
            end
        end
    }
end

-- Create TextBox
function UILibrary:CreateTextBox(options)
    options = options or {}
    
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Name = "TextBox"
    TextBoxFrame.Size = UDim2.new(1, 0, 0, 35)
    TextBoxFrame.BackgroundColor3 = Theme.Border
    TextBoxFrame.BorderSizePixel = 0
    TextBoxFrame.Parent = self.TabContent or self.CurrentTab
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 6)
    TextBoxCorner.Parent = TextBoxFrame
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 1, 0)
    TextBox.Position = UDim2.new(0, 10, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = options.Default or ""
    TextBox.PlaceholderText = options.Placeholder or "Enter text..."
    TextBox.TextColor3 = Theme.Text
    TextBox.PlaceholderColor3 = Theme.TextDark
    TextBox.TextSize = 14
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = TextBoxFrame
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and options.Callback then
            options.Callback(TextBox.Text)
        end
    end)
    
    return {
        GetText = function() return TextBox.Text end,
        SetText = function(text) TextBox.Text = text end
    }
end

-- Create Label
function UILibrary:CreateLabel(options)
    options = options or {}
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.BackgroundColor3 = Theme.Border
    Label.Text = options.Text or "Label"
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BorderSizePixel = 0
    Label.Parent = self.TabContent or self.CurrentTab
    
    local LabelPadding = Instance.new("UIPadding")
    LabelPadding.PaddingLeft = UDim.new(0, 10)
    LabelPadding.Parent = Label
    
    local LabelCorner = Instance.new("UICorner")
    LabelCorner.CornerRadius = UDim.new(0, 6)
    LabelCorner.Parent = Label
    
    return {
        SetText = function(text) Label.Text = text end
    }
end

return UILibrary
