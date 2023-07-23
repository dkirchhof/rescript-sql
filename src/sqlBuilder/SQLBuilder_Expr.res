let simpleExprToSQL = (left, right, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left)
  let right = SQLBuilder_Unknown.toSQL(right)

  `${left} ${operator} ${right}`
}

let betweenExprToSQL = (left, min, max, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left)
  let min = SQLBuilder_Unknown.toSQL(min)
  let max = SQLBuilder_Unknown.toSQL(max)

  `${left} ${operator} ${min} AND ${max}`
}

let inExprToSQL = (left, array, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left)
  let array = array->Array.map(SQLBuilder_Unknown.toSQL)->Array.joinWith(", ")

  `${left} ${operator} (${array})`
}

let likeExprToSQL = (left, right, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left)

  `${left} ${operator} '${right}'`
}

let rec group = (expr, operator) => {
  let array = expr->Array.map(toSQL)->Array.joinWith(` ${operator} `)

  `(${array})`
}
and toSQL = (expr: QueryBuilder_Expr.t) => {
  switch expr {
  | And(expressions) => group(expressions, "AND")
  | Or(expressions) => group(expressions, "OR")
  | Equal(left, right) => simpleExprToSQL(left, right, "=")
  | NotEqual(left, right) => simpleExprToSQL(left, right, "!=")
  | GreaterThan(left, right) => simpleExprToSQL(left, right, ">")
  | GreaterThanEqual(left, right) => simpleExprToSQL(left, right, ">=")
  | LessThan(left, right) => simpleExprToSQL(left, right, "<")
  | LessThanEqual(left, right) => simpleExprToSQL(left, right, "<=")
  | Between(left, min, max) => betweenExprToSQL(left, min, max, "BETWEEN")
  | NotBetween(left, min, max) => betweenExprToSQL(left, min, max, "NOT BETWEEN")
  | In(left, array) => inExprToSQL(left, array, "IN")
  | NotIn(left, array) => inExprToSQL(left, array, "NOT IN")
  | Like(left, right) => likeExprToSQL(left, right, "LIKE")
  | NotLike(left, right) => likeExprToSQL(left, right, "NOT LIKE")
  | ILike(left, right) => likeExprToSQL(left, right, "ILIKE")
  | NotILike(left, right) => likeExprToSQL(left, right, "NOT ILIKE")
  }
}
