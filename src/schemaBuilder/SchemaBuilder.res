type column = {
  type_: Column.columnType,
  size?: int,
  notNull?: bool,
  autoIncrement?: bool,
  skipInInsertQuery?: bool,
}

external column: column => column = "%identity"

type columnWithName = {
  ...column,
  name: string,
}

type table<'columns, 'constraints> = {
  moduleName: string,
  tableName: string,
  columns: {..} as 'columns,
  constraints: 'columns => ({..} as 'constraints),
}

let table = options => {
  ...options,
  columns: options.columns
  ->Obj.magic
  ->Dict.toArray
  ->Array.map(((columnName, columnConfig)) => (columnName, {...columnConfig, name: columnName}))
  ->Dict.fromArray
  ->Obj.magic,
}

type fkConstraint = NoAction | SetNull | SetDefault | Cascade

type t =
  | Unique({columns: array<column>})
  | PrimaryKey({columns: array<column>})
  | ForeignKey({
      columns: array<column>,
      foreignTableName: string,
      foreignColumns: array<column>,
      onUpdate: fkConstraint,
      onDelete: fkConstraint,
    })

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

let artistsTable = table({
  moduleName: "Artists",
  tableName: "artists",
  columns: {
    "id": column({type_: INTEGER, skipInInsertQuery: true}),
    "name": column({type_: TEXT, size: 100}),
  },
  constraints: c =>
    {
      "pk": primaryKey({columns: [c["id"]]}),
      "unique": unique({columns: [c["name"]]}),
    },
})

let songsTable = table({
  moduleName: "Songs",
  tableName: "songs",
  columns: {
    "id": column({type_: INTEGER, skipInInsertQuery: true}),
    "artistId": column({type_: INTEGER}),
    "name": column({type_: TEXT, size: 100}),
  },
  constraints: c =>
    {
      "pk": primaryKey({columns: [c["id"]]}),
      "fkArtist": foreignKey({
        columns: [c["artistId"]],
        foreignTable: artistsTable,
        foreignColumns: c2 => [c2["id"]],
        onUpdate: NoAction,
        onDelete: Cascade,
      }),
    },
})

Logger.log(songsTable)
