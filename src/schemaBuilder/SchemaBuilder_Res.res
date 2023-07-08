let dbTypeToResType = (dbType: Column.columnType) =>
  switch dbType {
  | INTEGER => "int"
  | TEXT => "string"
  }

let mapColumns = (columns, fn: SchemaBuilder_Types.columnWithName => string) => {
  columns->Obj.magic->Dict.valuesToArray->Array.map(fn)
}

let skipToString = (column: SchemaBuilder_Types.columnWithName) => {
  switch column.skipInInsertQuery {
  | Some(true) => "?"
  | _ => ""
  }
}

let notNullToString = notNull =>
  switch notNull {
  | Some(false) => "false"
  | _ => "true"
  }

let makeType = (name, columns) => {
  open StringBuilder

  let fields = mapColumns(columns, column => {
    switch name {
    | "columns" => `${column.name}: ${dbTypeToResType(column.type_)},`
    | "insert" => `${column.name}${skipToString(column)}: ${dbTypeToResType(column.type_)},`
    | "update" => `${column.name}?: ${dbTypeToResType(column.type_)},`
    | _ => panic("unhandled type name")
    }
  })

  let body = make()->addM(4, fields)->build("\n")

  make()->addS(2, `type ${name} = {`)->addS(0, body)->addS(2, "}")->build("\n")
}

let makeTable = (schema: SchemaBuilder_Types.table<_>) => {
  open StringBuilder

  let columns = mapColumns(schema.columns, column => {
    let fields =
      make()
      ->addS(8, `name: "${column.name}",`)
      ->addS(8, `type_: ${(column.type_ :> string)},`)
      ->addS(8, `notNull: ${notNullToString(column.notNull)},`)
      ->build("\n")

      make()
      ->addS(6, `"${column.name}": Node.Column({`)
      ->addS(0, fields)
      ->addS(6, `}),`)
      ->build("\n")
  })

  make()
  ->addS(2, `let table: t = {`)
  ->addS(4, `name: "${schema.tableName}",`)
  ->addS(4, `columns: Obj.magic({`)
  ->addM(0, columns)
  ->addS(4, `}),`)
  ->addS(2, `}`)
  ->build("\n")
}

let toRescript = (schema: SchemaBuilder_Types.table<_>) => {
  open StringBuilder

  let columnsType = makeType("columns", schema.columns)
  let insertType = makeType("insert", schema.columns)
  let updateType = makeType("update", schema.columns)

  let table = makeTable(schema)

  make()
  ->addS(0, `module ${schema.moduleName} = {`)
  ->addS(0, columnsType)
  ->addE
  ->addS(0, insertType)
  ->addE
  ->addS(0, updateType)
  ->addE
  ->addS(2, "type t = Table.t<columns, insert, update>")
  ->addE
  ->addS(0, table)
  ->addS(0, `}`)
  ->addE
  ->build("\n")
}
