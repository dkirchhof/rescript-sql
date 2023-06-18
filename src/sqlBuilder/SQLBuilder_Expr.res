let toSQL = (expr: Expr.t) => {
  switch expr {
  | EQUAL(left, right) => `${SQLBuilder_Unknown.toSQL(left)} = ${SQLBuilder_Unknown.toSQL(right)}`
  }
}
