open AST

type t = orderBy

let asc = node => {node: Node.normalize(node), direction: ASC}
let desc = node => {node: Node.normalize(node), direction: DESC}
