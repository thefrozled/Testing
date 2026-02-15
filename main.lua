-- FrozHub UI Library for Roblox
-- Toggle with DELETE key
-- Created with a clean, modern dark UI design

local FrozHub = {}
FrozHub.__index = FrozHub

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- UI State
local ScreenGui = nil
local CurrentWindow = nil
local IsVisible = true

-- Colors
local Colors = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(100, 120, 255),
    Text = Color3.fromRGB(200, 200, 210),
    TextDim = Color3.fromRGB(140, 140, 150),
    Border = Color3.fromRGB(45, 45, 55),
    Hover = Color3.fromRGB(40, 40, 48),
    Enabled = Color3.fromRGB(100, 120, 255),
    Disabled = Color3.fromRGB(60, 60, 70)
}

-- Helper Functions
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

local function Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Initialize Library
function FrozHub:Init()
    -- Create ScreenGui
    ScreenGui = CreateElement("ScreenGui", {
        Name = "FrozHub",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Protection
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    -- Toggle with DELETE key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Delete then
            self:Toggle()
        end
    end)
    
    return self
end

-- Toggle UI visibility
function FrozHub:Toggle()
    IsVisible = not IsVisible
    if ScreenGui then
        ScreenGui.Enabled = IsVisible
    end
end

-- Create Window
function FrozHub:CreateWindow(title)
    local Window = {
        Title = title,
        Tabs = {},
        TabButtons = {},
        CurrentTab = nil
    }
    
    -- Main Frame
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true
    })
    
    CreateElement("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Make draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mousePos
            MainFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Top Bar
    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
    })
    
    CreateElement("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Title
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab Container (Horizontal tabs)
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 220, 0, 0),
        Size = UDim2.new(1, -220, 1, 0)
    })
    
    local TabLayout = CreateElement("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 1, -45)
    })
    
    -- Create Tab
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Sections = {},
            Elements = {}
        }
        
        -- Tab Button
        local TabButton = CreateElement("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = Colors.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 100, 0, 35),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = Colors.TextDim,
            TextSize = 13,
            AutoButtonColor = false
        })
        
        CreateElement("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 4)
        })
        
        -- Tab Content Frame
        local TabFrame = CreateElement("ScrollingFrame", {
            Name = tabName .. "Tab",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Accent,
            Visible = false
        })
        
        local ContentLayout = CreateElement("UIListLayout", {
            Parent = TabFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        CreateElement("UIPadding", {
            Parent = TabFrame,
            PaddingTop = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Update canvas size
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab Button Click
        TabButton.MouseButton1Click:Connect(function()
            for _, btn in pairs(Window.TabButtons) do
                Tween(btn, {BackgroundColor3 = Colors.Background, TextColor3 = Colors.TextDim})
            end
            for _, frame in pairs(Window.Tabs) do
                frame.Visible = false
            end
            
            Tween(TabButton, {BackgroundColor3 = Colors.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)})
            TabFrame.Visible = true
            Window.CurrentTab = Tab
        end)
        
        -- Hover effect
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Colors.Hover})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Colors.Background})
            end
        end)
        
        table.insert(Window.TabButtons, TabButton)
        Window.Tabs[tabName] = TabFrame
        
        -- Auto-select first tab
        if #Window.TabButtons == 1 then
            Tween(TabButton, {BackgroundColor3 = Colors.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)})
            TabFrame.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- Create Section
        function Tab:CreateSection(sectionName)
            local Section = {
                Name = sectionName,
                Elements = {}
            }
            
            local SectionFrame = CreateElement("Frame", {
                Name = sectionName,
                Parent = TabFrame,
                BackgroundColor3 = Colors.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            CreateElement("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local SectionLayout = CreateElement("UIListLayout", {
                Parent = SectionFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            CreateElement("UIPadding", {
                Parent = SectionFrame,
                PaddingTop = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
            
            -- Section Title
            local SectionTitle = CreateElement("TextLabel", {
                Name = "SectionTitle",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Toggle
            function Section:CreateToggle(name, default, callback)
                callback = callback or function() end
                local toggled = default or false
                
                local ToggleFrame = CreateElement("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local ToggleLabel = CreateElement("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = CreateElement("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggled and Colors.Enabled or Colors.Disabled,
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                    BorderSizePixel = 0
                })
                
                CreateElement("UICorner", {
                    Parent = ToggleButton,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local ToggleCircle = CreateElement("Frame", {
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0
                })
                
                CreateElement("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local ToggleClick = CreateElement("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                ToggleClick.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(ToggleButton, {BackgroundColor3 = toggled and Colors.Enabled or Colors.Disabled})
                    Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    callback(toggled)
                end)
                
                return {
                    Set = function(value)
                        toggled = value
                        Tween(ToggleButton, {BackgroundColor3 = toggled and Colors.Enabled or Colors.Disabled})
                        Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    end
                }
            end
            
            -- Slider
            function Section:CreateSlider(name, min, max, default, callback)
                callback = callback or function() end
                local value = default or min
                
                local SliderFrame = CreateElement("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local SliderLabel = CreateElement("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValue = CreateElement("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -55, 0, 0),
                    Size = UDim2.new(0, 55, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(value),
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderTrack = CreateElement("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Colors.Disabled,
                    Position = UDim2.new(0, 0, 0, 30),
                    Size = UDim2.new(1, 0, 0, 6),
                    BorderSizePixel = 0
                })
                
                CreateElement("UICorner", {
                    Parent = SliderTrack,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderFill = CreateElement("Frame", {
                    Parent = SliderTrack,
                    BackgroundColor3 = Colors.Accent,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BorderSizePixel = 0
                })
                
                CreateElement("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderButton = CreateElement("TextButton", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 27),
                    Size = UDim2.new(1, 0, 0, 12),
                    Text = ""
                })
                
                local dragging = false
                
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                SliderButton.MouseMoved:Connect(function(x)
                    if dragging then
                        local percentage = math.clamp((x - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (max - min) * percentage)
                        SliderValue.Text = tostring(value)
                        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                        callback(value)
                    end
                end)
                
                return {
                    Set = function(val)
                        value = math.clamp(val, min, max)
                        SliderValue.Text = tostring(value)
                        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    end
                }
            end
            
            -- Button
            function Section:CreateButton(name, callback)
                callback = callback or function() end
                
                local ButtonFrame = CreateElement("TextButton", {
                    Parent = SectionFrame,
                    BackgroundColor3 = Colors.Accent,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    AutoButtonColor = false,
                    BorderSizePixel = 0
                })
                
                CreateElement("UICorner", {
                    Parent = ButtonFrame,
                    CornerRadius = UDim.new(0, 4)
                })
                
                ButtonFrame.MouseButton1Click:Connect(callback)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(120, 140, 255)})
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.Accent})
                end)
            end
            
            -- Dropdown
            function Section:CreateDropdown(name, options, default, callback)
                callback = callback or function() end
                local selected = default or options[1] or ""
                local opened = false
                
                local DropdownFrame = CreateElement("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClipsDescendants = true
                })
                
                local DropdownLabel = CreateElement("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Colors.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = CreateElement("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Colors.Disabled,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = selected,
                    TextColor3 = Colors.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    BorderSizePixel = 0
                })
                
                CreateElement("UICorner", {
                    Parent = DropdownButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local Arrow = CreateElement("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 25, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Colors.Text,
                    TextSize = 10
                })
                
                local OptionsList = CreateElement("Frame", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Colors.Background,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    Visible = false
                })
                
                CreateElement("UICorner", {
                    Parent = OptionsList,
                    CornerRadius = UDim.new(0, 4)
                })
                
                local OptionsLayout = CreateElement("UIListLayout", {
                    Parent = OptionsList,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                for _, option in ipairs(options) do
                    local OptionButton = CreateElement("TextButton", {
                        Parent = OptionsList,
                        BackgroundColor3 = Colors.Secondary,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Colors.Text,
                        TextSize = 12,
                        AutoButtonColor = false,
                        BorderSizePixel = 0
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = option
                        opened = false
                        OptionsList.Visible = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 60)})
                        Tween(Arrow, {Rotation = 0})
                        callback(option)
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Colors.Hover})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Colors.Secondary})
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    OptionsList.Visible = opened
                    
                    if opened then
                        local optionsHeight = #options * 28
                        OptionsList.Size = UDim2.new(1, 0, 0, optionsHeight)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 60 + optionsHeight + 5)})
                        Tween(Arrow, {Rotation = 180})
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 60)})
                        Tween(Arrow, {Rotation = 0})
                    end
                end)
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

return FrozHub:Init()
