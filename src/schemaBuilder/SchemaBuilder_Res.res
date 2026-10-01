let mapColumns = (columns, fn: SchemaBuilder_Types.column => string) => {
  columns->Obj.magic->Dict.valuesToArray->Array.map(fn)
}

let skipToString = (column: SchemaBuilder_Types.column) => {
  switch column.skipInInsertQuery {
  | Some(true) => "?"
  | _ => ""
  }
}

let makeType = (name, columns) => {
  open StringBuilder

  let fields = mapColumns(columns, column => {
    let resType = switch column.nullable {
      | Some(true) => `null<${column.resType}>`
      | _ => column.resType
    }

    switch name {
    | "columns" => `${column.name}: ${resType},`
    | "nullColumns" => `${column.name}: null<${column.resType}>,`
    | "insert" => `${column.name}${skipToString(column)}: ${resType},`
    | "update" => `${column.name}?: ${resType},`
    | _ => panic("unhandled type name")
    }
  })

  let body = make()->addM(4, fields)->build("\n")

  make()->addS(2, `type ${name} = {`)->addS(0, body)->addS(2, "}")->build("\n")
}

let makeSource = (sourceType, sourceName, columns) => {
  open StringBuilder

  let columns = mapColumns(columns, column => {
    `"${column.name}": Node.Column({name: "${column.name}"}),`
  })

  make()
  ->addS(2, `let ${sourceType}: t = {`)
  ->addS(4, `name: "${sourceName}",`)
  ->addS(4, `columns: Obj.magic({`)
  ->addM(6, columns)
  ->addS(4, `}),`)
  ->addS(2, `}`)
  ->build("\n")
}

let makeTable = (schema: SchemaBuilder_Types.table<_>) => {
  makeSource("table", schema.tableName, schema.columns)
}

let tableToRescript = (schema: SchemaBuilder_Types.table<_>) => {
  open StringBuilder

  let columnsType = makeType("columns", schema.columns)
  let nullColumnsType = makeType("nullColumns", schema.columns)
  let insertType = makeType("insert", schema.columns)
  let updateType = makeType("update", schema.columns)

  let table = makeTable(schema)

  make()
  ->addS(0, `module ${schema.moduleName} = {`)
  ->addS(0, columnsType)
  ->addE
  ->addS(0, nullColumnsType)
  ->addE
  ->addS(0, insertType)
  ->addE
  ->addS(0, updateType)
  ->addE
  ->addS(2, "type t = Table.t<columns, nullColumns, insert, update>")
  ->addE
  ->addS(0, table)
  ->addS(0, `}`)
  ->addE
  ->build("\n")
}

let viewToRescript = (schema: SchemaBuilder_Types.view<_>) => {
  open StringBuilder

  let columnsType = makeType("columns", schema.columns)
  let nullColumnsType = makeType("nullColumns", schema.columns)
  let view = makeSource("view", schema.viewName, schema.columns)

  make()
  ->addS(0, `module ${schema.moduleName} = {`)
  ->addS(0, columnsType)
  ->addE
  ->addS(0, nullColumnsType)
  ->addE
  ->addS(2, "type t = View.t<columns, nullColumns>")
  ->addE
  ->addS(0, view)
  ->addS(0, "}")
  ->addE
  ->build("\n")
}
