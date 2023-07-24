let toSQL = (q: QueryBuilder_Insert.tx<_>) => {
  open StringBuilder

  let columns = q.values[0]->Option.getExn->Obj.magic->Dict.keysToArray->Array.joinWith(", ")

  let rows = q.values->Array.map(row => {
    // let converted = SQL_Common.convertRecordToStringDict(~record=row, ~columns)
    // let rowString = converted->Js.Dict.values->Js.Array2.joinWith(", ")

    let columns =
      row->Obj.magic->Dict.valuesToArray->Array.map(EscapeValues.escape)->Array.joinWith(", ")

    `(${columns})`
  })

  let values = make()->addM(2, rows)->build(",\n")

  make()->addS(0, `INSERT INTO ${q.tableName}(${columns}) VALUES`)->addS(0, values)->build("\n")
}
