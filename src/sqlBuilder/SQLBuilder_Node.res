let toSQL = (node: Node.t<_>, subqueryToSQL) => {
  switch node {
  | Column(column) => {
      let columnName = switch column.tableAlias {
      | Some(tableAlias) => `${tableAlias}.${column.name}`
      | None => column.name
      }

      switch column.aggregation {
      | Some(Avg) => `AVG(${columnName})`
      | Some(Count) => `COUNT(${columnName})`
      | Some(Max) => `MAX(${columnName})`
      | Some(Min) => `MIN(${columnName})`
      | Some(Sum) => `SUM(${columnName})`
      | None => columnName
      }
    }
  | StringLiteral(string) => `'${string}'`
  | NumberLiteral(number) => Float.toString(number)
  | BooleanLiteral(bool) => bool ? "TRUE" : "FALSE"
  | Subquery(subquery) => subqueryToSQL(subquery)
  | _ => "NOT IMPLEMENTED YET"
  }
}
