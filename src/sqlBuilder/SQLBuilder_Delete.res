let whereToSQL = (where, params) => {
  SQLBuilder_Clause.toSQL("WHERE", where, SQLBuilder_Select.subqueryToSQL, params)
}

let toSQL = (q: QueryBuilder_Delete.t<_>): SQLBuilder_SQL.t => {
  open StringBuilder

  let params = []

  let sql =
    make()
    ->addS(0, `DELETE FROM ${q.tableName}`)
    ->addSO(0, whereToSQL(q.where, params))
    ->build("\n")

  {sql, params}
}
