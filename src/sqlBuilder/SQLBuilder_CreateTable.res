// let fromCreateTableQuery = (q: QueryBuilder.CreateTable.t<_>) => {
//   let innerString =
//     make()
//     ->addM(
//       2,
//       q.table.columns
//       ->Schema.Column.dictFromRecord
//       ->Js.Dict.entries
//       ->Js.Array2.map(((name, column)) => {
//         let sizeString = switch column.size {
//         | Some(size) => `(${size->Belt.Int.toString})`
//         | None => ""
//         }

//         let notNullString = column.nullable ? "" : " NOT NULL"

//         `${name} ${(column.dbType :> string)}${sizeString}${notNullString}`
//       }),
//     )
//     ->addM(
//       2,
//       q.table.constraints
//       ->Obj.magic
//       ->Js.Dict.entries
//       ->Js.Array2.map(((name, cnstraint: Schema.Constraint.t)) => constraintToSQL(name, cnstraint)),
//     )
//     ->build(",\n")

//   make()->addS(0, `CREATE TABLE ${q.table.name} (`)->addS(0, innerString)->addS(0, `)`)->build("\n")
// }

let toSQL = (q: QueryBuilder_CreateTable.t<_>) => {
  open StringBuilder

  let columns =
    q.columns
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((name, node)) => {
      switch node {
      | Node.Column(column) => {
          //     let sizeString = switch column.size {
          //     | Some(size) => `(${size->Belt.Int.toString})`
          //     | None => ""
          //     }

          let notNull = column.notNull ? " NOT NULL" : ""

          `${name} ${column.type_}${notNull}`
        }
      | _ => panic("only available for columns")
      }
    })

  let body =
    make()
    ->addM(2, columns)
    // ->addM(
    //   2,
    //   q.table.constraints
    //   ->Obj.magic
    //   ->Js.Dict.entries
    //   ->Js.Array2.map(((name, cnstraint: Schema.Constraint.t)) => constraintToSQL(name, cnstraint)),
    // )
    ->build(",\n")

  make()
  ->addS(0, `CREATE TABLE ${q.tableName} (`)
  ->addS(0, body)
  ->addS(0, `)`)
  ->build("\n")
}
