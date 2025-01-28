local types = require(script.Parent.Parent.types)

local PrintNode = {}
PrintNode.__index = PrintNode

setmetatable(PrintNode, {
    __index = PrintNode,
    __call = function(cls, ...)
        return cls.new(...)
    end
})

function PrintNode.new(id: string, message: string) : types.PrintNode
    local self = setmetatable()
end

return PrintNode