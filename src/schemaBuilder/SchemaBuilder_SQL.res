let columnToSQL = (column: SchemaBuilder_Types.column) => {
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
      let columns = unique.columns->Array.map(column => column.name)->Array.join(", ")

      `CONSTRAINT ${name} UNIQUE (${columns})`
    }
  | PrimaryKey(primaryKey) => {
      let columns = primaryKey.columns->Array.map(column => column.name)->Array.join(", ")

      `CONSTRAINT ${name} PRIMARY KEY (${columns})`
    }
  | ForeignKey(foreignKey) => {
      let columns = foreignKey.columns->Array.map(column => column.name)->Array.join(", ")

      let fcolumns =
        foreignKey.foreignColumns->Array.map(column => column.name)->Array.join(", ")

      `CONSTRAINT ${name} FOREIGN KEY (${columns}) REFERENCES ${foreignKey.foreignTableName} (${fcolumns})`
    }
  }

let tableToSQL = (schema: SchemaBuilder_Types.table<_>) => {
  open StringBuilder

  let columns = schema.columns->Obj.magic->Dict.valuesToArray->Array.map(columnToSQL)

  let constraints = Option.map(schema.constraints, constraints => {
    schema.columns
    ->constraints
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((name, options)) => constraintToSQL(name, options))
  })

  let body = make()->addM(2, columns)->addMO(2, constraints)->build(",\n")

  make()
  ->addS(0, `CREATE TABLE ${schema.tableName} (`)
  ->addS(0, body)
  ->addS(0, `);`)
  ->addS(0, "")
  ->build("\n")
}

let viewToSQL = (schema: SchemaBuilder_Types.view<_>) => {
  open StringBuilder

  make()
  ->addS(0, `CREATE VIEW ${schema.viewName} AS`)
  ->addS(2, `${schema.sql};`)
  ->addE
  ->build("\n")
}
