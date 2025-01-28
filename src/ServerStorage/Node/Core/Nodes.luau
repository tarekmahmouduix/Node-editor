--!strict

local types = require(script.Parent.Parent.types)

local nodes = {}
nodes.__index = nodes

function nodes.createNode(nodeType: string, id: string, position: UDim2, parent: Instance): types.Node?
    local nodeTemplate = script.Parent.Parent.Nodes:FindFirstChild(nodeType)
    if nodeTemplate then
        local nodeClone = nodeTemplate:Clone()
        nodeClone.Parent = parent
        nodeClone.Position = position
        nodeClone.Name = id
        nodeClone.Visible = true
        print("Node created:", nodeType, nodeClone.Name)

        local node: types.Node
        if nodeType == "PrintNode" then
            node = {
                id = id,
                type = "PrintNode",
                connections = {},
                data = {},
                message = "Hello, World!",
                execute = function(self)
                    print("Executing PrintNode:", self.message)
                end,
                connect = function(self, other)
                    table.insert(self.connections, other)
                    table.insert(other.connections, self)
                    print("Connected PrintNode to", other.id)
                end,
                disconnect = function(self, other)
                    for i, v in ipairs(self.connections) do
                        if v.id == other.id then
                            table.remove(self.connections, i)
                            break
                        end
                    end
                    for i, v in ipairs(other.connections) do
                        if v.id == self.id then
                            table.remove(other.connections, i)
                            break
                        end
                    end
                end,
                clearConnections = function(self)
                    for _, connectedNode in ipairs(self.connections) do
                        for i, conn in ipairs(connectedNode.connections) do
                            if conn.id == self.id then
                                table.remove(connectedNode.connections, i)
                                break
                            end
                        end
                    end
                    self.connections = {}
                end,
            }
        elseif nodeType == "LogNode" then
            node = {
                id = id,
                type = "LogNode",
                connections = {},
                data = {},
                execute = function(self)
                    print("Executing LogNode")
                    for _, connection in ipairs(self.connections) do
                        connection:execute()
                    end
                end,
                connect = function(self, other)
                    table.insert(self.connections, other)
                    table.insert(other.connections, self)
                    print("Connected LogNode to", other.id)
                end,
                disconnect = function(self, other)
                    for i, v in ipairs(self.connections) do
                        if v.id == other.id then
                            table.remove(self.connections, i)
                            break
                        end
                    end
                    for i, v in ipairs(other.connections) do
                        if v.id == self.id then
                            table.remove(other.connections, i)
                            break
                        end
                    end
                end,
                clearConnections = function(self)
                    for _, connectedNode in ipairs(self.connections) do
                        for i, conn in ipairs(connectedNode.connections) do
                            if conn.id == self.id then
                                table.remove(connectedNode.connections, i)
                                break
                            end
                        end
                    end
                    self.connections = {}
                end,
            }
        else
            warn("Unknown node type:", nodeType)
            return nil
        end

        return node
    else
        warn("Node template not found:", nodeType)
        return nil
    end
end

return nodes