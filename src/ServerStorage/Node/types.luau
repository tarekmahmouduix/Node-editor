--!strict

export type Node = {
    id: string,
    type: string,
    connections: {Node},
    data: {},
    execute: (self: Node) -> (),
    connect: (self: Node, other: Node) -> (),
    disconnect: (self: Node, other: Node) -> (),
    clearConnections: (self: Node) -> (),
}

export type LogNode = Node

export type PrintNode = Node & {
    message: string,
}

export type contextOption = {
    name: string,
    callback: (input: InputObject) -> (),
}

return nil