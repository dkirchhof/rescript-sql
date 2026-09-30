let rec toSQL = (expr: QueryBuilder_Expr.t, subqueryToSQL, params) => {
  let unknownToSQL = SQLBuilder_Unknown.toSQL(subqueryToSQL, params)

  let groupToSQL = (expr, operator) => {
    let array = expr->Array.map(toSQL(_, subqueryToSQL, params))->Array.join(` ${operator} `)

    `(${array})`
  }

  let simpleExprToSQL = (left, right, operator) => {
    let left = unknownToSQL(left)
    let right = unknownToSQL(right)

    `${left} ${operator} ${right}`
  }

  let betweenExprToSQL = (left, min, max, operator) => {
    let left = unknownToSQL(left)
    let min = unknownToSQL(min)
    let max = unknownToSQL(max)

    `${left} ${operator} ${min} AND ${max}`
  }

  let inExprToSQL = (left, array, operator) => {
    let left = unknownToSQL(left)
    let array = array->Array.map(unknownToSQL)->Array.join(", ")

    `${left} ${operator} (${array})`
  }

  let likeExprToSQL = (left, right, operator) => {
    open SQLBuilder_Params

    let left = unknownToSQL(left)

    `${left} ${operator} ${param(params)(right)}`
  }

  switch expr {
  | And(expressions) => groupToSQL(expressions, "AND")
  | Or(expressions) => groupToSQL(expressions, "OR")
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
