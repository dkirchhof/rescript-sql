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

let columnToSQL = (column: Column.t) => {
  //     let sizeString = switch column.size {
  //     | Some(size) => `(${size->Belt.Int.toString})`
  //     | None => ""
  //     }

  let notNull = column.notNull ? " NOT NULL" : ""

  let autoIncrement = switch column.autoIncrement {
  | Some(true) => " AUTOINCREMENT"
  | _ => ""
  }

  `${column.name} ${column.type_}${notNull}${autoIncrement}`
}

let constraintToSQL = (constraint_: Constraint.t) =>
  switch constraint_ {
  | Unique(unique) => `CONSTRAINT ${unique.name} UNIQUE (${Array.joinWith(unique.columns, ", ")})`
  | PrimaryKey(primaryKey) => {
      let columns = Array.joinWith(primaryKey.columns, ", ")

      `CONSTRAINT ${primaryKey.name} PRIMARY KEY (${columns})`
    }
  | ForeignKey(foreignKey) => {
      let columns = Array.joinWith(foreignKey.columns, ", ")
      let fcolumns = Array.joinWith(foreignKey.foreignColumns, ", ")

      `CONSTRAINT ${foreignKey.name} FOREIGN KEY (${columns}) REFERENCES ${foreignKey.foreignTableName} (${fcolumns})`
    }
  }

let toSQL = (q: QueryBuilder_CreateTable.t<_>) => {
  open StringBuilder

  let columns =
    q.columns
    ->Obj.magic
    ->Dict.valuesToArray
    ->Array.map(node => {
      switch node {
      | Node.Column(column) => columnToSQL(column)
      | _ => panic("only available for columns")
      }
    })

  let constraints = q.constraints->Array.map(constraintToSQL)

  let body = make()->addM(2, columns)->addM(2, constraints)->build(",\n")

  make()->addS(0, `CREATE TABLE ${q.tableName} (`)->addS(0, body)->addS(0, `)`)->build("\n")
}
