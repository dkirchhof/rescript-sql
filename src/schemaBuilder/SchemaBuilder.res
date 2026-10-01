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

let table = options => {
  let table = {
    ...options,
    columns: options.columns
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((columnName, columnConfig: column)) => (
      columnName,
      {...columnConfig, name: columnName},
    ))
    ->Dict.fromArray
    ->Obj.magic,
  }

  switch process.argv[2] {
  | Some("generate:res") => table->SchemaBuilder_Res.toRescript->Console.log
  | Some("generate:sql") => table->SchemaBuilder_SQL.toSQL->Console.log
  | _ => ()
  }

  table
}

let tableWithoutConstraints: table<'columns, _> => table<'columns, {.}> = table

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
