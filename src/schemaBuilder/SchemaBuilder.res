open SchemaBuilder_Types

type process = {argv: array<string>}

@val external process: process = "process"

external column: column => columnWithName = "%identity"

let table = options => {
  let table = {
    ...options,
    columns: options.columns
    ->Obj.magic
    ->Dict.toArray
    ->Array.map(((columnName, columnConfig)) => (columnName, {...columnConfig, name: columnName}))
    ->Dict.fromArray
    ->Obj.magic,
  }

  switch Array.get(process.argv, 2) {
    | Some("generate:res") => table->SchemaBuilder_SQL.toSQL->Console.log
    | Some("generate:sql") => table->SchemaBuilder_SQL.toSQL->Console.log
    | _ => ()
  }

  table
}

type uniqueOptions = {columns: array<columnWithName>}

let unique = (options: uniqueOptions) => Unique({columns: options.columns})

type primaryKeyOptions = {columns: array<columnWithName>}

let primaryKey = (options: primaryKeyOptions) => PrimaryKey({columns: options.columns})

type foreignKeyOptions<'fcolumns, 'fconstraints> = {
  columns: array<columnWithName>,
  foreignTable: table<'fcolumns, 'fconstraints>,
  foreignColumns: 'fcolumns => array<columnWithName>,
  onUpdate: fkConstraint,
  onDelete: fkConstraint,
}

let foreignKey = (options: foreignKeyOptions<_>) => ForeignKey({
  columns: Obj.magic(options.columns),
  foreignTableName: options.foreignTable.tableName,
  foreignColumns: Obj.magic(options.foreignColumns(options.foreignTable.columns)),
  onUpdate: options.onUpdate,
  onDelete: options.onDelete,
})
