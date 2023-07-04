external columnTypeToSQL: Column.columnType => string = "%identity"

let columnToSQL = (column: Column.t) => {
  //     let sizeString = switch column.size {
  //     | Some(size) => `(${size->Belt.Int.toString})`
  //     | None => ""
  //     }

  let type_ = columnTypeToSQL(column.type_)

  let notNull = column.notNull ? " NOT NULL" : ""

  let autoIncrement = switch column.autoIncrement {
  | Some(true) => " AUTOINCREMENT"
  | _ => ""
  }

  `${column.name} ${type_}${notNull}${autoIncrement}`
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
