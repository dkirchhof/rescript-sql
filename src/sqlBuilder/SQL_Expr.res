let toSQL = (expr: Expr.t) => {
  switch expr {
  | EQUAL(left, right) => `${SQL_Unknown.toSQL(left)} = ${SQL_Unknown.toSQL(right)}`
  }
}
