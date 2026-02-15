--[[
    FrozHub UI Library
    Modern, sleek UI library inspired by premium game interfaces
    
    Features:
    - Clean dark theme with purple/blue accents
    - Modern checkboxes and toggles
    - Smooth sliders with value display
    - Dropdown menus
    - Tab system
    - Draggable window
    - Easy icon customization
]]

local FrozHub = {}
FrozHub.__index = FrozHub

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Theme Configuration
local Theme = {
    -- Main Colors
    Background = Color3.fromRGB(15, 15, 18),
    Secondary = Color3.fromRGB(20, 20, 24),
    Tertiary = Color3.fromRGB(25, 25, 30),
    
    -- Accent Colors
    Accent = Color3.fromRGB(139, 97, 255),      -- Purple accent
    AccentDark = Color3.fromRGB(100, 70, 200),
    AccentLight = Color3.fromRGB(160, 120, 255),
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextDark = Color3.fromRGB(130, 130, 140),
    
    -- UI Colors
    Border = Color3.fromRGB(35, 35, 42),
    Divider = Color3.fromRGB(40, 40, 48),
    Hover = Color3.fromRGB(30, 30, 36),
    
    -- Status Colors
    Success = Color3.fromRGB(100, 200, 150),
    Warning = Color3.fromRGB(255, 180, 100),
    Error = Color3.fromRGB(255, 100, 100),
}

-- Configuration
local Config = {
    BrandName = "FrozHub",
    IconEnabled = false, -- Set to true and provide IconImage to show icon
    IconImage = "", -- Set this to "rbxassetid://YOUR_ID" to add custom icon
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
}

-- Utility Functions
local function tween(instance, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
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
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.08, Enum.EasingStyle.Linear)
        end
    end)
end

-- Create Main Library
function FrozHub:Create(options)
    options = options or {}
    local hub = setmetatable({}, FrozHub)
    
    -- Override config if provided
    if options.BrandName then Config.BrandName = options.BrandName end
    if options.IconImage then 
        Config.IconImage = options.IconImage
        Config.IconEnabled = true
    end
    
    -- Create ScreenGui
    hub.ScreenGui = Instance.new("ScreenGui")
    hub.ScreenGui.Name = "FrozHub"
    hub.ScreenGui.ResetOnSpawn = false
    hub.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        hub.ScreenGui.Parent = CoreGui
    end)
    
    if hub.ScreenGui.Parent ~= CoreGui then
        hub.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    hub.Tabs = {}
    hub.CurrentTab = nil
    
    return hub
end

-- Create Window
function FrozHub:CreateWindow(options)
    options = options or {}
    local width = options.Width or 584
    local height = options.Height or 784
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, width, 0, height)
    Container.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    Container.BackgroundColor3 = Theme.Background
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Parent = self.ScreenGui
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.Secondary
    Header.BorderSizePixel = 0
    Header.Parent = Container
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header
    
    -- Header bottom cover
    local HeaderCover = Instance.new("Frame")
    HeaderCover.Size = UDim2.new(1, 0, 0, 6)
    HeaderCover.Position = UDim2.new(0, 0, 1, -6)
    HeaderCover.BackgroundColor3 = Theme.Secondary
    HeaderCover.BorderSizePixel = 0
    HeaderCover.Parent = Header
    
    -- Icon (optional)
    local iconOffset = 15
    if Config.IconEnabled and Config.IconImage ~= "" then
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 24, 0, 24)
        Icon.Position = UDim2.new(0, 15, 0.5, -12)
        Icon.BackgroundTransparency = 1
        Icon.Image = Config.IconImage
        Icon.ImageColor3 = Theme.Accent
        Icon.Parent = Header
        iconOffset = 48
    end
    
    -- Brand Name
    local BrandName = Instance.new("TextLabel")
    BrandName.Name = "BrandName"
    BrandName.Size = UDim2.new(0, 200, 1, 0)
    BrandName.Position = UDim2.new(0, iconOffset, 0, 0)
    BrandName.BackgroundTransparency = 1
    BrandName.Text = Config.BrandName
    BrandName.TextColor3 = Theme.TextPrimary
    BrandName.TextSize = 18
    BrandName.Font = Config.FontBold
    BrandName.TextXAlignment = Enum.TextXAlignment.Left
    BrandName.Parent = Header
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -45, 0, 5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.TextSecondary
    CloseButton.TextSize = 24
    CloseButton.Font = Config.Font
    CloseButton.Parent = Header
    
    CloseButton.MouseEnter:Connect(function()
        tween(CloseButton, {TextColor3 = Theme.Error})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        tween(CloseButton, {TextColor3 = Theme.TextSecondary})
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        tween(Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.Position = UDim2.new(0, 0, 0, 50)
    TabBar.BackgroundColor3 = Theme.Secondary
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Container
    
    local TabBarList = Instance.new("UIListLayout")
    TabBarList.FillDirection = Enum.FillDirection.Horizontal
    TabBarList.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarList.Padding = UDim.new(0, 0)
    TabBarList.Parent = TabBar
    
    -- Content Container
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -90)
    ContentFrame.Position = UDim2.new(0, 0, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = Container
    
    -- Make draggable
    makeDraggable(Container, Header)
    
    -- Entrance Animation
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(Container, {
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    self.Container = Container
    self.TabBar = TabBar
    self.ContentFrame = ContentFrame
    
    return self
end

-- Create Tab
function FrozHub:CreateTab(options)
    options = options or {}
    local tabName = options.Name or "Tab"
    
    -- Tab Button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName
    TabButton.Size = UDim2.new(0, 120, 1, 0)
    TabButton.BackgroundColor3 = Theme.Secondary
    TabButton.BorderSizePixel = 0
    TabButton.Text = tabName
    TabButton.TextColor3 = Theme.TextSecondary
    TabButton.TextSize = 14
    TabButton.Font = Config.Font
    TabButton.Parent = self.TabBar
    
    -- Tab Indicator
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Name = "Indicator"
    TabIndicator.Size = UDim2.new(1, 0, 0, 2)
    TabIndicator.Position = UDim2.new(0, 0, 1, -2)
    TabIndicator.BackgroundColor3 = Theme.Accent
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = false
    TabIndicator.Parent = TabButton
    
    -- Tab Content
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = tabName
    TabContent.Size = UDim2.new(1, -40, 1, -20)
    TabContent.Position = UDim2.new(0, 20, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = Theme.Accent
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.Parent = TabContent
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Switching
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button.TextColor3 = Theme.TextSecondary
            tab.Indicator.Visible = false
            tab.Content.Visible = false
        end
        
        TabButton.TextColor3 = Theme.TextPrimary
        TabIndicator.Visible = true
        TabContent.Visible = true
        self.CurrentTab = TabContent
    end)
    
    TabButton.MouseEnter:Connect(function()
        if TabContent.Visible == false then
            tween(TabButton, {BackgroundColor3 = Theme.Hover})
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if TabContent.Visible == false then
            tween(TabButton, {BackgroundColor3 = Theme.Secondary})
        end
    end)
    
    local tab = {
        Button = TabButton,
        Indicator = TabIndicator,
        Content = TabContent,
    }
    
    table.insert(self.Tabs, tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        TabButton.TextColor3 = Theme.TextPrimary
        TabIndicator.Visible = true
        TabContent.Visible = true
        self.CurrentTab = TabContent
    end
    
    return setmetatable({
        TabContent = TabContent,
        Library = self
    }, {__index = FrozHub})
end

-- Create Section
function FrozHub:CreateSection(title)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundTransparency = 1
    Section.Parent = self.TabContent or self.CurrentTab
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, 0, 1, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Theme.TextPrimary
    SectionTitle.TextSize = 16
    SectionTitle.Font = Config.FontBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Section
    
    return Section
end

-- Create Checkbox (Toggle)
function FrozHub:CreateCheckbox(options)
    options = options or {}
    local checked = options.Default or false
    
    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Name = "Checkbox"
    CheckboxFrame.Size = UDim2.new(1, 0, 0, 30)
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.Parent = self.TabContent or self.CurrentTab
    
    -- Checkbox Box
    local CheckboxBox = Instance.new("Frame")
    CheckboxBox.Size = UDim2.new(0, 18, 0, 18)
    CheckboxBox.Position = UDim2.new(0, 0, 0.5, -9)
    CheckboxBox.BackgroundColor3 = checked and Theme.Accent or Theme.Tertiary
    CheckboxBox.BorderSizePixel = 0
    CheckboxBox.Parent = CheckboxFrame
    
    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(0, 3)
    CheckboxCorner.Parent = CheckboxBox
    
    -- Checkmark
    local Checkmark = Instance.new("ImageLabel")
    Checkmark.Size = UDim2.new(0, 12, 0, 12)
    Checkmark.Position = UDim2.new(0.5, -6, 0.5, -6)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Image = "rbxassetid://3926305904"
    Checkmark.ImageRectOffset = Vector2.new(312, 4)
    Checkmark.ImageRectSize = Vector2.new(24, 24)
    Checkmark.ImageColor3 = Theme.TextPrimary
    Checkmark.Visible = checked
    Checkmark.Parent = CheckboxBox
    
    -- Label
    local CheckboxLabel = Instance.new("TextLabel")
    CheckboxLabel.Size = UDim2.new(1, -30, 1, 0)
    CheckboxLabel.Position = UDim2.new(0, 30, 0, 0)
    CheckboxLabel.BackgroundTransparency = 1
    CheckboxLabel.Text = options.Text or "Checkbox"
    CheckboxLabel.TextColor3 = Theme.TextSecondary
    CheckboxLabel.TextSize = 14
    CheckboxLabel.Font = Config.Font
    CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    CheckboxLabel.Parent = CheckboxFrame
    
    -- Button
    local CheckboxButton = Instance.new("TextButton")
    CheckboxButton.Size = UDim2.new(1, 0, 1, 0)
    CheckboxButton.BackgroundTransparency = 1
    CheckboxButton.Text = ""
    CheckboxButton.Parent = CheckboxFrame
    
    local function toggle()
        checked = not checked
        
        tween(CheckboxBox, {BackgroundColor3 = checked and Theme.Accent or Theme.Tertiary})
        Checkmark.Visible = checked
        
        if options.Callback then
            options.Callback(checked)
        end
    end
    
    CheckboxButton.MouseButton1Click:Connect(toggle)
    
    CheckboxButton.MouseEnter:Connect(function()
        tween(CheckboxLabel, {TextColor3 = Theme.TextPrimary})
    end)
    
    CheckboxButton.MouseLeave:Connect(function()
        tween(CheckboxLabel, {TextColor3 = Theme.TextSecondary})
    end)
    
    return {
        Toggle = toggle,
        GetState = function() return checked end,
        SetState = function(state)
            checked = state
            CheckboxBox.BackgroundColor3 = checked and Theme.Accent or Theme.Tertiary
            Checkmark.Visible = checked
        end
    }
end

-- Create Slider
function FrozHub:CreateSlider(options)
    options = options or {}
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local increment = options.Increment or 1
    local currentValue = default
    local suffix = options.Suffix or ""
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = self.TabContent or self.CurrentTab
    
    -- Label
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -60, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = options.Text or "Slider"
    SliderLabel.TextColor3 = Theme.TextSecondary
    SliderLabel.TextSize = 14
    SliderLabel.Font = Config.Font
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    -- Value Display
    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Size = UDim2.new(0, 55, 0, 20)
    ValueDisplay.Position = UDim2.new(1, -55, 0, 0)
    ValueDisplay.BackgroundTransparency = 1
    ValueDisplay.Text = tostring(currentValue) .. suffix
    ValueDisplay.TextColor3 = Theme.TextPrimary
    ValueDisplay.TextSize = 14
    ValueDisplay.Font = Config.FontBold
    ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    ValueDisplay.Parent = SliderFrame
    
    -- Slider Track
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 4)
    SliderTrack.Position = UDim2.new(0, 0, 1, -10)
    SliderTrack.BackgroundColor3 = Theme.Tertiary
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack
    
    -- Slider Fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    -- Slider Button
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 20)
    SliderButton.Position = UDim2.new(0, 0, 0, -10)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        currentValue = math.floor((min + (max - min) * relativeX) / increment + 0.5) * increment
        currentValue = math.clamp(currentValue, min, max)
        
        ValueDisplay.Text = tostring(currentValue) .. suffix
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
    
    SliderButton.MouseButton1Click:Connect(function()
        updateSlider(UserInputService:GetMouseLocation())
    end)
    
    return {
        SetValue = function(value)
            currentValue = math.clamp(value, min, max)
            ValueDisplay.Text = tostring(currentValue) .. suffix
            tween(SliderFill, {Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)}, 0.1)
        end,
        GetValue = function() return currentValue end
    }
end

-- Create Dropdown
function FrozHub:CreateDropdown(options)
    options = options or {}
    local items = options.Items or {}
    local selected = options.Default or (items[1] or "None")
    local expanded = false
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = Theme.Tertiary
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = self.TabContent or self.CurrentTab
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 4)
    DropdownCorner.Parent = DropdownFrame
    
    -- Header
    local DropdownHeader = Instance.new("TextButton")
    DropdownHeader.Size = UDim2.new(1, 0, 0, 35)
    DropdownHeader.BackgroundTransparency = 1
    DropdownHeader.Text = ""
    DropdownHeader.Parent = DropdownFrame
    
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -40, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 15, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = options.Text or "Dropdown"
    HeaderLabel.TextColor3 = Theme.TextSecondary
    HeaderLabel.TextSize = 14
    HeaderLabel.Font = Config.Font
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = DropdownHeader
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(0, 150, 1, 0)
    SelectedLabel.Position = UDim2.new(1, -165, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = selected
    SelectedLabel.TextColor3 = Theme.TextPrimary
    SelectedLabel.TextSize = 14
    SelectedLabel.Font = Config.Font
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    SelectedLabel.Parent = DropdownHeader
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.TextSecondary
    Arrow.TextSize = 10
    Arrow.Font = Config.Font
    Arrow.Parent = DropdownHeader
    
    -- Items Container
    local ItemsContainer = Instance.new("Frame")
    ItemsContainer.Size = UDim2.new(1, 0, 0, 0)
    ItemsContainer.Position = UDim2.new(0, 0, 0, 35)
    ItemsContainer.BackgroundTransparency = 1
    ItemsContainer.Parent = DropdownFrame
    
    local ItemsList = Instance.new("UIListLayout")
    ItemsList.SortOrder = Enum.SortOrder.LayoutOrder
    ItemsList.Parent = ItemsContainer
    
    local function updateDropdown()
        if expanded then
            Arrow.Text = "▲"
            local totalHeight = 35 + (#items * 30) + 5
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.2)
        else
            Arrow.Text = "▼"
            tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
        end
    end
    
    for _, item in ipairs(items) do
        local ItemButton = Instance.new("TextButton")
        ItemButton.Size = UDim2.new(1, -10, 0, 28)
        ItemButton.Position = UDim2.new(0, 5, 0, 0)
        ItemButton.BackgroundColor3 = item == selected and Theme.Hover or Theme.Tertiary
        ItemButton.BorderSizePixel = 0
        ItemButton.Text = item
        ItemButton.TextColor3 = item == selected and Theme.Accent or Theme.TextSecondary
        ItemButton.TextSize = 13
        ItemButton.Font = Config.Font
        ItemButton.Parent = ItemsContainer
        
        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 3)
        ItemCorner.Parent = ItemButton
        
        ItemButton.MouseEnter:Connect(function()
            if item ~= selected then
                tween(ItemButton, {BackgroundColor3 = Theme.Hover})
                tween(ItemButton, {TextColor3 = Theme.TextPrimary})
            end
        end)
        
        ItemButton.MouseLeave:Connect(function()
            if item ~= selected then
                tween(ItemButton, {BackgroundColor3 = Theme.Tertiary})
                tween(ItemButton, {TextColor3 = Theme.TextSecondary})
            end
        end)
        
        ItemButton.MouseButton1Click:Connect(function()
            selected = item
            SelectedLabel.Text = selected
            
            for _, child in ipairs(ItemsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    tween(child, {BackgroundColor3 = Theme.Tertiary})
                    tween(child, {TextColor3 = Theme.TextSecondary})
                end
            end
            
            tween(ItemButton, {BackgroundColor3 = Theme.Hover})
            tween(ItemButton, {TextColor3 = Theme.Accent})
            
            expanded = false
            updateDropdown()
            
            if options.Callback then
                options.Callback(selected)
            end
        end)
    end
    
    DropdownHeader.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateDropdown()
    end)
    
    DropdownHeader.MouseEnter:Connect(function()
        tween(DropdownFrame, {BackgroundColor3 = Theme.Hover})
    end)
    
    DropdownHeader.MouseLeave:Connect(function()
        tween(DropdownFrame, {BackgroundColor3 = Theme.Tertiary})
    end)
    
    return {
        GetSelected = function() return selected end,
        SetSelected = function(item)
            if table.find(items, item) then
                selected = item
                SelectedLabel.Text = selected
            end
        end
    }
end

-- Create Button
function FrozHub:CreateButton(options)
    options = options or {}
    
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Theme.Tertiary
    Button.BorderSizePixel = 0
    Button.Text = options.Text or "Button"
    Button.TextColor3 = Theme.TextPrimary
    Button.TextSize = 14
    Button.Font = Config.Font
    Button.Parent = self.TabContent or self.CurrentTab
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        tween(Button, {BackgroundColor3 = Theme.Hover})
    end)
    
    Button.MouseLeave:Connect(function()
        tween(Button, {BackgroundColor3 = Theme.Tertiary})
    end)
    
    Button.MouseButton1Click:Connect(function()
        tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
        wait(0.1)
        tween(Button, {BackgroundColor3 = Theme.Hover}, 0.1)
        
        if options.Callback then
            options.Callback()
        end
    end)
    
    return Button
end

-- Create TextBox
function FrozHub:CreateTextBox(options)
    options = options or {}
    
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Name = "TextBox"
    TextBoxFrame.Size = UDim2.new(1, 0, 0, 35)
    TextBoxFrame.BackgroundColor3 = Theme.Tertiary
    TextBoxFrame.BorderSizePixel = 0
    TextBoxFrame.Parent = self.TabContent or self.CurrentTab
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 4)
    TextBoxCorner.Parent = TextBoxFrame
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 1, 0)
    TextBox.Position = UDim2.new(0, 10, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = options.Default or ""
    TextBox.PlaceholderText = options.Placeholder or "Enter text..."
    TextBox.TextColor3 = Theme.TextPrimary
    TextBox.PlaceholderColor3 = Theme.TextDark
    TextBox.TextSize = 14
    TextBox.Font = Config.Font
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = TextBoxFrame
    
    TextBox.Focused:Connect(function()
        tween(TextBoxFrame, {BackgroundColor3 = Theme.Hover})
    end)
    
    TextBox.FocusLost:Connect(function(enterPressed)
        tween(TextBoxFrame, {BackgroundColor3 = Theme.Tertiary})
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
function FrozHub:CreateLabel(options)
    options = options or {}
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = options.Text or "Label"
    Label.TextColor3 = Theme.TextSecondary
    Label.TextSize = 14
    Label.Font = Config.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = self.TabContent or self.CurrentTab
    
    return {
        SetText = function(text) Label.Text = text end
    }
end

return FrozHub
