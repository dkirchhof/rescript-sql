let toSQL = (node: Node.t<_>, subqueryToSQL, params) => {
  open SQLBuilder_Params

  switch node {
  | Column(column) => {
      let columnName = switch column.tableAlias {
      | Some(tableAlias) => `${tableAlias}.${column.name}`
      | None => column.name
      }

      let columnName = switch column.aggregation {
      | Some(Avg) => `AVG(${columnName})`
      | Some(Count) => `COUNT(${columnName})`
      | Some(Max) => `MAX(${columnName})`
      | Some(Min) => `MIN(${columnName})`
      | Some(Sum) => `SUM(${columnName})`
      | None => columnName
      }

      switch column.jsonFunction {
      | Some(Extract(path)) => {
          let sanitizedPath = String.replaceAllRegExp(path, /[^\w\$\.\[\]]/g, "")

          `${columnName} ->> "${sanitizedPath}"`
        }
      | None => columnName
      }
    }
  // | StringLiteral(string) => param(params)(string)
  // | NumberLiteral(number) => param(params)(number)
  // | BooleanLiteral(bool) => param(params)(bool)
  | Value(value) => param(params)(value)
  | Subquery(subquery) => subqueryToSQL(subquery, params)
  | _ => "NOT IMPLEMENTED YET"
  }
}
