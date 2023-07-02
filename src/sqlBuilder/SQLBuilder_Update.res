let whereToSQL = where => {
  where->Option.map(expr => `WHERE ${SQLBuilder_Expr.toSQL(expr)}`)
}

let toSQL = (q: QueryBuilder_Update.tx<_>) => {
  open StringBuilder

  let patch =
    q.patch
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((columnName, value)) => `${columnName} = ${EscapeValues.escape(value)}`)
    ->Array.joinWith(", ")

  make()
  ->addS(0, `UPDATE ${q.tableName}`)
  ->addS(0, `SET ${patch}`)
  ->addSO(0, whereToSQL(q.where))
  ->build("\n")
}
