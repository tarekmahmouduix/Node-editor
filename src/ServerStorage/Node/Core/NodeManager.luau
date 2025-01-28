--!strict

local types = require(script.Parent.Parent.types)

local NodeManager = {}
NodeManager.__index = NodeManager

function NodeManager.new()
    local self = setmetatable({}, NodeManager)
    self.nodes = {}
    return self
end

function NodeManager:registerNode(node: types.Node)
    self.nodes[node.id] = node
    print("Node registered:", node.id)
end

function NodeManager:removeNode(node: types.Node)
    self.nodes[node.id] = nil
end

function NodeManager:findNode(id: string): types.Node?
    return self.nodes[id]
end

function NodeManager:findNodeByType(type: string): types.Node?
    for _, node in pairs(self.nodes) do
        if node.type == type then
            return node
        end
    end
    return nil
end

function NodeManager:GetAllNodes()
    return self.nodes
end

function NodeManager:connectNodes(node1: types.Node, node2: types.Node)
    if self:ValidateConnection(node1, node2) then
        node1:connect(node2)
        print("Connected nodes:", node1.id, "->", node2.id)
        return true
    else
        warn("Connection failed:", node1.id, "->", node2.id)
        return false
    end
end

function NodeManager:ValidateConnection(node1: types.Node, node2: types.Node): boolean
    if node1 == node2 then
        return false
    end
    for _, node in ipairs(node1.connections) do
        if node == node2 then
            return false
        end
    end
    return true
end

function NodeManager:executeAll(...)
    local baseNode = self:findNodeByType("LogNode")
    if baseNode then
        baseNode:execute()
    else
        warn("LogNode not found with ID:", baseNode)
    end
end

return NodeManager