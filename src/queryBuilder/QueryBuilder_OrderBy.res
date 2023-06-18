type direction = ASC | DESC

type t = {node: Unknown.t, direction: direction}

let asc = node => {node: Unknown.make(node), direction: ASC}
let desc = node => {node: Unknown.make(node), direction: DESC}
