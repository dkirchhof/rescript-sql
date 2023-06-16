let toSQL = (expr: Expr.t) => {
  switch expr {
  | EQUAL(left, right) => `${SQL_Node.toSQL(left)} = ${SQL_Node.toSQL(right)}`
  }
}
