--!strict

local types = require(script.Parent.Parent.types)

local contextMenu = {}
contextMenu.__index = contextMenu

function contextMenu.new(Position: UDim2, ContextMenuGui: GuiObject, OptionTemplate: GuiObject)
    local self = setmetatable({}, contextMenu)

    self.ContextMenu = ContextMenuGui
    self.ContextMenu.Visible = false
    self.ContextMenu.Position = Position
    self.OptionGui = OptionTemplate
    self.Options = {}
    self.SelectedNode = nil

    return self
end

function contextMenu:AddOption(option: types.contextOption)
    table.insert(self.Options, option)
end

function contextMenu:ClearOptions()
    self.Options = {}
end

function contextMenu:Open()
    self.ContextMenu.Visible = true
end

function contextMenu:Close()
    self.ContextMenu.Visible = false
end

function contextMenu:Render(input: InputObject)
    for _, v in ipairs(self.ContextMenu:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end

    for _, option in ipairs(self.Options) do
        local optionGui = self.OptionGui:Clone()
        optionGui.Name = option.name
        optionGui.Text = option.name
        optionGui.Parent = self.ContextMenu
        optionGui.Visible = true
        optionGui.MouseButton1Click:Connect(function()
            self:Close()
            option.callback(input)
        end)
    end
end

function contextMenu:SelectNode(node : types.Node)
    self.SelectedNode = node
    print("Node selected: ", node.id)
end

function contextMenu:GetSelectedNode() : types.Node
    return self.SelectedNode
end

return contextMenu