let toSQL = (node: Unknown.t) => {
  let node = Node.fromUnknown(node)

  switch node {
  | Column(column) =>
    switch column.tableAlias {
    | Some(tableAlias) => `${tableAlias}.${column.name}`
    | None => column.name
    }
  | StringLiteral(string) => `'${string}'` 
  | NumberLiteral(number) => Float.toString(number)
  | _ => "NOT IMPLEMENTED YET"
  }
}
