-- Services & Plugin setup
local toolbar = plugin:CreateToolbar("Node Editor")
local newScriptButton = toolbar:CreateButton("Node Editor", "Open the node editor", "rbxassetid://14978048121")
local types = require(script.Parent.types)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Bottom,
    false,
    false,
    600, 300,
    300, 150
)

local editor = plugin:CreateDockWidgetPluginGui("NodeEditorWidget", widgetInfo)
editor.Title = "Node Editor"

-- GUI & Logic

local NodeManager = require(script.Parent.Core.NodeManager).new()
local NodeFactory = require(script.Parent.Core.Nodes)
local contextMenu = require(script.Parent.Nodegui.contextMenu).new(UDim2.new(0, 0, 0, 0), script.Parent.UI.ContextMenu, script.Parent.UI.OptionTemplate)
local Background = script.Parent.UI.Background
local ContextMenuGui = script.Parent.UI.ContextMenu

local BASE_NODE_ID = "BaseNode"

local selectedNode: types.Node? = nil

local function QuadraticBezier(p0, p1, p2, t)
    local u = 1 - t
    local tt = t * t
    local uu = u * u

    local x = (uu * p0.X) + (2 * u * t * p1.X) + (tt * p2.X)
    local y = (uu * p0.Y) + (2 * u * t * p1.Y) + (tt * p2.Y)
    
    return Vector2.new(x, y)
end

local function DrawCurve(Frame1: GuiObject, Frame2: GuiObject, Parent: Instance)
    local Segments = 20
    local Lines = {}

    for i = 1, Segments do
        local Line = Instance.new("Frame")
        Line.AnchorPoint = Vector2.new(0.5, 0.5)
        Line.BackgroundColor3 = Color3.new(1, 1, 1)
        Line.BackgroundTransparency = 0.2
        Line.BorderSizePixel = 0
        Line.Parent = Parent
        table.insert(Lines, Line)
    end

    local function updateCurve()
        local p0 = Frame1.AbsolutePosition
        local p2 = Frame2.AbsolutePosition
        local midPoint = (p0 + p2) / 2 + Vector2.new(0, 50)

        for i = 1, Segments do
            local t1 = (i - 1) / Segments
            local t2 = i / Segments

            local point1 = QuadraticBezier(p0, midPoint, p2, t1)
            local point2 = QuadraticBezier(p0, midPoint, p2, t2)

            local Line = Lines[i]
            local Mag = (point2 - point1).Magnitude
            Line.Position = UDim2.fromOffset((point1.X + point2.X) / 2, (point1.Y + point2.Y) / 2)
            Line.Size = UDim2.fromOffset(Mag, 2)
            Line.Rotation = math.deg(math.atan2(point2.Y - point1.Y, point2.X - point1.X))
        end
    end

    updateCurve()
    RunService.RenderStepped:Connect(updateCurve)
end

local function createNode(nodeType: string, id: string, position: UDim2)
    local node = NodeFactory.createNode(nodeType, id, position, Background)
    if node then
        NodeManager:registerNode(node)
        local nodeGui = Background:FindFirstChild(id)
        if nodeGui then
            local connectionPoint = nodeGui:FindFirstChild("ConnectionPoint")
            if connectionPoint and connectionPoint:IsA("TextButton") then
                connectionPoint.MouseButton1Click:Connect(function()
                    if selectedNode then
                        local connection = NodeManager:connectNodes(selectedNode, node)

                        if connection then
                            print("Connected nodes:", selectedNode.id, "->", node.id)
                            local selectedNodeGui = Background:FindFirstChild(selectedNode.id)
                            if selectedNodeGui then
                                local selectedConnectionPoint = selectedNodeGui:FindFirstChild("ConnectionPoint")
                                if selectedConnectionPoint and selectedConnectionPoint:IsA("TextButton") then
                                    selectedConnectionPoint.BackgroundTransparency = 0
                                end
                            end
                            connectionPoint.BackgroundTransparency = 0
                            
							DrawCurve(selectedNodeGui.ConnectionPoint, nodeGui.ConnectionPoint, Background)
							
							selectedNode = nil
                        else
                            print("Connection failed:", selectedNode.id, "->", node.id)
                            selectedNode = nil
                        end
                    else
                        selectedNode = node
                        print("Node selected:", selectedNode.id)
                    end
                end)
            else
                print("Connection point not found for node:", id)
            end
        end
    end
end

local function addNodeOption(name: string, nodeType: string)
    contextMenu:AddOption({
        name = name,
        callback = function(input)
            local position = UDim2.new(0, input.Position.X, 0, input.Position.Y)
            local nodeId = nodeType .. tostring(math.random(1000, 9999))
            print(nodeId)
			createNode(nodeType, nodeId, position)
        end
    })
end

addNodeOption("Print", "PrintNode")
addNodeOption("Log", "LogNode")

ContextMenuGui.Visible = false

Background.Parent = editor
ContextMenuGui.Parent = editor

Background.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        contextMenu:Close()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        contextMenu:Open()
        contextMenu.ContextMenu.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y)
        contextMenu:Render(input)
    end
end)

newScriptButton.Click:Connect(function()
    editor.Enabled = not editor.Enabled
end)

-- Test

if game:GetService("RunService"):IsRunning() then
    NodeManager:executeAll()
end