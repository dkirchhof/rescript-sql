let toSQL = (expr: QueryBuilder_Expr.t) => {
  switch expr {
  | EQUAL(left, right) => `${SQLBuilder_Unknown.toSQL(left)} = ${SQLBuilder_Unknown.toSQL(right)}`
  }
}
