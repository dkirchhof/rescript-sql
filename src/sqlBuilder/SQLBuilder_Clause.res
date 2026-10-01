let toSQL = (keyword, expression, subqueryToSQL, params) => {
  expression->Option.map(expr =>
    `${keyword} ${SQLBuilder_Expr.toSQL(expr, subqueryToSQL, params)}`
  )
}
