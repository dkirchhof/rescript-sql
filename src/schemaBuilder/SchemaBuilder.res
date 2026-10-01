open SchemaBuilder_Types

type process = {argv: array<string>}

@val external process: process = "process"


let makeColumn = (options: baseColumn, dbType, resType): column => {
  name: "",
  size: ?options.size,
  nullable: ?options.nullable,
  autoIncrement: ?options.autoIncrement,
  skipInInsertQuery: ?options.skipInInsertQuery,
  dbType,
  resType,
}

let integerColumn = options => makeColumn(options, "INTEGER", "int")
let textColumn = options => makeColumn(options, "TEXT", "string")

let nameColumns = (columns: 'columns): 'columns => {
  columns
  ->Obj.magic
  ->Dict.toArray
  ->Array.map(((columnName, columnConfig: column)) => (
    columnName,
    {...columnConfig, name: columnName},
  ))
  ->Dict.fromArray
  ->Obj.magic
}

let table = (options: table<'columns, 'constraints>): table<'columns, 'constraints> => {
  let table = {
    ...options,
    columns: nameColumns(options.columns),
  }

  switch process.argv[2] {
  | Some("generate:res") => table->SchemaBuilder_Res.tableToRescript->Console.log
  | Some("generate:sql") => table->SchemaBuilder_SQL.tableToSQL->Console.log
  | _ => ()
  }

  table
}

let tableWithoutConstraints: table<'columns, _> => table<'columns, {.}> = table

let view = (options: view<'columns>): view<'columns> => {
  let view = {
    ...options,
    columns: nameColumns(options.columns),
  }

  switch process.argv[2] {
  | Some("generate:res") => view->SchemaBuilder_Res.viewToRescript->Console.log
  | Some("generate:sql") => view->SchemaBuilder_SQL.viewToSQL->Console.log
  | _ => ()
  }

  view
}

type uniqueOptions = {columns: array<column>}

let unique = (options: uniqueOptions) => Unique({columns: options.columns})

type primaryKeyOptions = {columns: array<column>}

let primaryKey = (options: primaryKeyOptions) => PrimaryKey({columns: options.columns})

type foreignKeyOptions<'fcolumns, 'fconstraints> = {
  columns: array<column>,
  foreignTable: table<'fcolumns, 'fconstraints>,
  foreignColumns: 'fcolumns => array<column>,
  onUpdate: fkConstraint,
  onDelete: fkConstraint,
}

let foreignKey = (options: foreignKeyOptions<_>) => ForeignKey({
  columns: options.columns,
  foreignTableName: options.foreignTable.tableName,
  foreignColumns: options.foreignColumns(options.foreignTable.columns),
  onUpdate: options.onUpdate,
  onDelete: options.onDelete,
})
