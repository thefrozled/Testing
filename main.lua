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
    Background = Color3.fromRGB(15, 15, 18),
    Secondary = Color3.fromRGB(20, 20, 24),
    Tertiary = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(67, 181, 129),
    AccentHover = Color3.fromRGB(77, 191, 139),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(150, 150, 160),
    Border = Color3.fromRGB(35, 35, 40),
    Hover = Color3.fromRGB(30, 30, 36),
    Enabled = Color3.fromRGB(67, 181, 129),
    Disabled = Color3.fromRGB(50, 50, 55),
    Shadow = Color3.fromRGB(0, 0, 0)
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
        CurrentTab = nil,
        SidebarOpen = true
    }
    
    -- Shadow Background
    local ShadowBackground = CreateElement("Frame", {
        Name = "ShadowBackground",
        Parent = ScreenGui,
        BackgroundColor3 = Colors.Shadow,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -360, 0.5, -260),
        Size = UDim2.new(0, 720, 0, 520)
    })
    
    CreateElement("UICorner", {
        Parent = ShadowBackground,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Main Frame
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = false
    })
    
    CreateElement("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 6)
    })
    
    CreateElement("UIStroke", {
        Parent = MainFrame,
        Color = Colors.Border,
        Thickness = 1,
        Transparency = 0.5
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
            ShadowBackground.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X - 10,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y - 10
            )
        end
    end)
    
    -- Left Sidebar
    local Sidebar = CreateElement("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 1, 0)
    })
    
    CreateElement("UICorner", {
        Parent = Sidebar,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Top Bar (for title and collapse button)
    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -180, 0, 50)
    })
    
    CreateElement("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Title in top bar
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Sidebar Title
    local SidebarTitle = CreateElement("TextLabel", {
        Name = "SidebarTitle",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Collapse Button
    local CollapseButton = CreateElement("TextButton", {
        Name = "CollapseButton",
        Parent = TopBar,
        BackgroundColor3 = Colors.Secondary,
        Position = UDim2.new(1, -45, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "☰",
        TextColor3 = Colors.Text,
        TextSize = 16,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    
    CreateElement("UICorner", {
        Parent = CollapseButton,
        CornerRadius = UDim.new(0, 4)
    })
    
    CreateElement("UIStroke", {
        Parent = CollapseButton,
        Color = Colors.Border,
        Thickness = 1,
        Transparency = 0.5
    })
    
    -- Collapse functionality
    CollapseButton.MouseButton1Click:Connect(function()
        Window.SidebarOpen = not Window.SidebarOpen
        
        if Window.SidebarOpen then
            Tween(Sidebar, {Size = UDim2.new(0, 180, 1, 0)}, 0.3)
            Tween(TopBar, {Position = UDim2.new(0, 180, 0, 0), Size = UDim2.new(1, -180, 0, 50)}, 0.3)
            Tween(CollapseButton, {Rotation = 0}, 0.3)
            for _, frame in pairs(Window.Tabs) do
                Tween(frame, {Position = UDim2.new(0, 180, 0, 50), Size = UDim2.new(1, -180, 1, -50)}, 0.3)
            end
        else
            Tween(Sidebar, {Size = UDim2.new(0, 0, 1, 0)}, 0.3)
            Tween(TopBar, {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 50)}, 0.3)
            Tween(CollapseButton, {Rotation = 180}, 0.3)
            for _, frame in pairs(Window.Tabs) do
                Tween(frame, {Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -50)}, 0.3)
            end
        end
    end)
    
    -- Hover effects for collapse button
    CollapseButton.MouseEnter:Connect(function()
        Tween(CollapseButton, {BackgroundColor3 = Colors.Hover})
    end)
    
    CollapseButton.MouseLeave:Connect(function()
        Tween(CollapseButton, {BackgroundColor3 = Colors.Secondary})
    end)
    
    -- Tab Container (Vertical sidebar tabs)
    local TabContainer = CreateElement("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -55),
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local TabLayout = CreateElement("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    CreateElement("UIPadding", {
        Parent = TabContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5)
    })
    
    -- Update canvas size
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 50),
        Size = UDim2.new(1, -180, 1, -50)
    })
    
    -- Create Tab
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Sections = {},
            Elements = {}
        }
        
        -- Tab Button (Vertical sidebar style)
        local TabButton = CreateElement("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = Colors.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 45),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Colors.TextDim,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        CreateElement("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 6)
        })
        
        CreateElement("UIStroke", {
            Parent = TabButton,
            Color = Colors.Border,
            Thickness = 1,
            Transparency = 0.8
        })
        
        -- Tab Icon (emoji/symbol)
        local icons = {
            Player = "👤",
            Aiming = "🎯",
            Settings = "⚙️",
            Combat = "⚔️",
            Visuals = "👁️",
            Misc = "🔧",
            World = "🌍"
        }
        
        local TabIcon = CreateElement("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = icons[tabName] or "📋",
            TextColor3 = Colors.TextDim,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Tab Label
        local TabLabel = CreateElement("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 45, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = tabName,
            TextColor3 = Colors.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Active indicator
        local ActiveIndicator = CreateElement("Frame", {
            Parent = TabButton,
            BackgroundColor3 = Colors.Accent,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 3, 1, 0),
            BorderSizePixel = 0,
            Visible = false
        })
        
        CreateElement("UICorner", {
            Parent = ActiveIndicator,
            CornerRadius = UDim.new(0, 2)
        })
        
        -- Tab Content Frame
        local TabFrame = CreateElement("ScrollingFrame", {
            Name = tabName .. "Tab",
            Parent = ContentContainer,
            BackgroundColor3 = Colors.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 6,
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
                local btnIcon = btn:FindFirstChild("TextLabel")
                local btnLabel = btn:FindFirstChildWhichIsA("TextLabel", true)
                local btnIndicator = btn:FindFirstChild("Frame")
                
                Tween(btn, {BackgroundColor3 = Colors.Background})
                if btnIcon then Tween(btnIcon, {TextColor3 = Colors.TextDim}) end
                if btnLabel and btnLabel.Name ~= "TextLabel" then 
                    Tween(btnLabel, {TextColor3 = Colors.TextDim}) 
                end
                if btnIndicator then btnIndicator.Visible = false end
            end
            for _, frame in pairs(Window.Tabs) do
                frame.Visible = false
            end
            
            Tween(TabButton, {BackgroundColor3 = Colors.Tertiary})
            Tween(TabIcon, {TextColor3 = Colors.Accent})
            Tween(TabLabel, {TextColor3 = Colors.Text})
            ActiveIndicator.Visible = true
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
            Tween(TabButton, {BackgroundColor3 = Colors.Tertiary})
            Tween(TabIcon, {TextColor3 = Colors.Accent})
            Tween(TabLabel, {TextColor3 = Colors.Text})
            ActiveIndicator.Visible = true
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
                BackgroundColor3 = Colors.Tertiary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            CreateElement("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 8)
            })
            
            CreateElement("UIStroke", {
                Parent = SectionFrame,
                Color = Colors.Border,
                Thickness = 1,
                Transparency = 0.6
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
                    CornerRadius = UDim.new(0, 6)
                })
                
                CreateElement("UIStroke", {
                    Parent = ButtonFrame,
                    Color = Colors.Accent,
                    Thickness = 1,
                    Transparency = 0.3
                })
                
                ButtonFrame.MouseButton1Click:Connect(callback)
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.AccentHover})
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
                    BackgroundColor3 = Colors.Secondary,
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
                    CornerRadius = UDim.new(0, 6)
                })
                
                CreateElement("UIStroke", {
                    Parent = DropdownButton,
                    Color = Colors.Border,
                    Thickness = 1,
                    Transparency = 0.6
                })
                
                local Arrow = CreateElement("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 25, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Colors.Accent,
                    TextSize = 10
                })
                
                local OptionsList = CreateElement("Frame", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Colors.Secondary,
                    Position = UDim2.new(0, 0, 0, 60),
                    Size = UDim2.new(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    Visible = false
                })
                
                CreateElement("UICorner", {
                    Parent = OptionsList,
                    CornerRadius = UDim.new(0, 6)
                })
                
                CreateElement("UIStroke", {
                    Parent = OptionsList,
                    Color = Colors.Border,
                    Thickness = 1,
                    Transparency = 0.6
                })
                
                local OptionsLayout = CreateElement("UIListLayout", {
                    Parent = OptionsList,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                for _, option in ipairs(options) do
                    local OptionButton = CreateElement("TextButton", {
                        Parent = OptionsList,
                        BackgroundColor3 = Colors.Tertiary,
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
                        Tween(OptionButton, {BackgroundColor3 = Colors.Tertiary})
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
