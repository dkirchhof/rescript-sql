let whereToSQL = (where, params) => {
  where->Option.map(expr =>
    `WHERE ${SQLBuilder_Expr.toSQL(expr, SQLBuilder_Select.subqueryToSQL, params)}`
  )
}

let toSQL = (q: QueryBuilder_Update.tx<_>): SQLBuilder_SQL.t => {
  open SQLBuilder_Params
  open StringBuilder

  let params = []

  let patch =
    q.patch
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((columnName, value)) => `${columnName} = ${param(params)(value)}`)
    ->Array.join(", ")

  let sql =
    make()
    ->addS(0, `UPDATE ${q.tableName}`)
    ->addS(0, `SET ${patch}`)
    ->addSO(0, whereToSQL(q.where, params))
    ->build("\n")

  {sql, params}
}
