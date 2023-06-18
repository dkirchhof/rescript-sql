let toSQL = (node: Node.t<_>) => {
  switch node {
  | Column(column) =>
    switch column.tableAlias {
    | Some(tableAlias) => `${tableAlias}.${column.name}`
    | None => column.name
    }
  | StringLiteral(string) => `'${string}'`
  | NumberLiteral(number) => Float.toString(number)
  | BooleanLiteral(bool) => bool ? "TRUE" : "FALSE"
  | _ => "NOT IMPLEMENTED YET"
  }
}
