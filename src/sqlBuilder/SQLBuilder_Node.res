let rec toSQL = (node: Node.t<_>, subqueryToSQL, params) => {
  open SQLBuilder_Params

  switch node {
  | Column(column) => {
      switch column.tableAlias {
      | Some(tableAlias) => `${tableAlias}.${column.name}`
      | None => column.name
      }
    }
  | Aggregate(aggregation, operand) => {
      let operand = toSQL(Node.fromUnknown(operand), subqueryToSQL, params)
      let functionName = switch aggregation {
      | Avg => "AVG"
      | Count => "COUNT"
      | Max => "MAX"
      | Min => "MIN"
      | Sum => "SUM"
      }

      `${functionName}(${operand})`
    }
  | JsonExtract(operand, path) => {
      let operand = toSQL(Node.fromUnknown(operand), subqueryToSQL, params)
      let path = toSQL(Node.fromUnknown(path), subqueryToSQL, params)

      `(${operand} ->> ${path})`
    }
  | Value(value) => param(params)(value)
  | Literal(value) => EscapeValues.escape(value)
  | Subquery(subquery) => subqueryToSQL(subquery, params)
  | ProjectionGroup(_) => panic("projection groups must be rendered as fields")
  }
}
