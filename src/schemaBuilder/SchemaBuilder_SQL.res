let columnToSQL = (column: SchemaBuilder_Types.columnWithName) => {
  let sizeString = switch column.size {
  | Some(size) => `(${size->Belt.Int.toString})`
  | None => ""
  }

  let notNull = switch column.nullable {
  | Some(true) => ""
  | _ => " NOT NULL"
  }

  let autoIncrement = switch column.autoIncrement {
  | Some(true) => " AUTOINCREMENT"
  | _ => ""
  }

  `${column.name} ${column.dbType}${sizeString}${notNull}${autoIncrement}`
}

let constraintToSQL = (name: string, constraint_: SchemaBuilder_Types.tableConstraint) =>
  switch constraint_ {
  | Unique(unique) => {
      let columns = unique.columns->Array.map(column => column.name)->Array.joinWith(", ")

      `CONSTRAINT ${name} UNIQUE (${columns})`
    }
  | PrimaryKey(primaryKey) => {
      let columns = primaryKey.columns->Array.map(column => column.name)->Array.joinWith(", ")

      `CONSTRAINT ${name} PRIMARY KEY (${columns})`
    }
  | ForeignKey(foreignKey) => {
      let columns = foreignKey.columns->Array.map(column => column.name)->Array.joinWith(", ")

      let fcolumns =
        foreignKey.foreignColumns->Array.map(column => column.name)->Array.joinWith(", ")

      `CONSTRAINT ${name} FOREIGN KEY (${columns}) REFERENCES ${foreignKey.foreignTableName} (${fcolumns})`
    }
  }

let toSQL = (schema: SchemaBuilder_Types.table<_>) => {
  open StringBuilder

  let columns = schema.columns->Obj.magic->Dict.valuesToArray->Array.map(columnToSQL)

  let constraints =
    schema.columns
    ->schema.constraints
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((name, options)) => constraintToSQL(name, options))

  let body = make()->addM(2, columns)->addM(2, constraints)->build(",\n")

  make()
  ->addS(0, `CREATE TABLE ${schema.tableName} (`)
  ->addS(0, body)
  ->addS(0, `);`)
  ->addS(0, "")
  ->build("\n")
}
