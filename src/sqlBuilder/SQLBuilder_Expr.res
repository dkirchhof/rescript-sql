let simpleExprToSQL = subqueryToSQL => (left, right, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left, subqueryToSQL)
  let right = SQLBuilder_Unknown.toSQL(right, subqueryToSQL)

  `${left} ${operator} ${right}`
}

let betweenExprToSQL = subqueryToSQL => (left, min, max, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left, subqueryToSQL)
  let min = SQLBuilder_Unknown.toSQL(min, subqueryToSQL)
  let max = SQLBuilder_Unknown.toSQL(max, subqueryToSQL)

  `${left} ${operator} ${min} AND ${max}`
}

let inExprToSQL = subqueryToSQL => (left, array, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left, subqueryToSQL)
  let array = array->Array.map(SQLBuilder_Unknown.toSQL(_, subqueryToSQL))->Array.joinWith(", ")

  `${left} ${operator} (${array})`
}

let likeExprToSQL = subqueryToSQL => (left, right, operator) => {
  let left = SQLBuilder_Unknown.toSQL(left, subqueryToSQL)

  `${left} ${operator} '${right}'`
}

let rec group = subqueryToSQL => (expr, operator) => {
  let array = expr->Array.map(toSQL(_, subqueryToSQL))->Array.joinWith(` ${operator} `)

  `(${array})`
}
and toSQL = (expr: QueryBuilder_Expr.t, subqueryToSQL) => {
  let group = group(subqueryToSQL)
  let simpleExprToSQL = simpleExprToSQL(subqueryToSQL)
  let betweenExprToSQL = betweenExprToSQL(subqueryToSQL)
  let inExprToSQL = inExprToSQL(subqueryToSQL)
  let likeExprToSQL = likeExprToSQL(subqueryToSQL)

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
