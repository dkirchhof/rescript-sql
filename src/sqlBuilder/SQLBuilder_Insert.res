let toSQL = (q: QueryBuilder_Insert.tx<_>): SQLBuilder_SQL.t => {
  open SQLBuilder_Params
  open StringBuilder

  let params = []

  let columns = q.values[0]->Option.getOrThrow->Obj.magic->Dict.keysToArray->Array.join(", ")

  let rows = q.values->Array.map(row => {
    // let converted = SQL_Common.convertRecordToStringDict(~record=row, ~columns)
    // let rowString = converted->Js.Dict.values->Js.Array2.join(", ")

    let columns = row->Obj.magic->Dict.valuesToArray->Array.map(param(params))->Array.join(", ")

    `(${columns})`
  })

  let values = make()->addM(2, rows)->build(",\n")

  let sql =
    make()
    ->addS(0, `INSERT INTO ${q.tableName}(${columns}) VALUES`)
    ->addS(0, values)
    ->build("\n")

  {sql, params}
}
