let whereToSQL = where => {
  where->Option.map(expr => `WHERE ${SQLBuilder_Expr.toSQL(expr, SQLBuilder_Select.subqueryToSQL)}`)
}

let toSQL = (q: QueryBuilder_Delete.t<_>) => {
  open StringBuilder

  make()
  ->addS(0, `DELETE FROM ${q.tableName}`)
  ->addSO(0, whereToSQL(q.where))
  ->build("\n")
}
