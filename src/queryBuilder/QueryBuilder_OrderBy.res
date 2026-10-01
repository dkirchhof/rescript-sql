let asc = (node): AST.orderBy => {node: Node.normalize(node), direction: ASC}
let desc = (node): AST.orderBy => {node: Node.normalize(node), direction: DESC}
