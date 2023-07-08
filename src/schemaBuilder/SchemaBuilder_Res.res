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
    | "columns" => `${column.name}: ${column.resType},`
    | "insert" => `${column.name}${skipToString(column)}: ${column.resType},`
    | "update" => `${column.name}?: ${column.resType},`
    | _ => panic("unhandled type name")
    }
  })

  let body = make()->addM(4, fields)->build("\n")

  make()->addS(2, `type ${name} = {`)->addS(0, body)->addS(2, "}")->build("\n")
}

let makeTable = (schema: SchemaBuilder_Types.table<_>) => {
  open StringBuilder

  let columns = mapColumns(schema.columns, column => {
    `"${column.name}": Node.Column({name: "${column.name}"}),`
  })

  make()
  ->addS(2, `let table: t = {`)
  ->addS(4, `name: "${schema.tableName}",`)
  ->addS(4, `columns: Obj.magic({`)
  ->addM(6, columns)
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
