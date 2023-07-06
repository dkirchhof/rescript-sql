type column = {
  type_: Column.columnType,
  size?: int,
  notNull?: bool,
  autoIncrement?: bool,
  skipInInsertQuery?: bool,
}

type columnWithName = {
  ...column,
  name: string,
}

type fkConstraint = NoAction | SetNull | SetDefault | Cascade

type tableConstraint =
  | Unique({columns: array<columnWithName>})
  | PrimaryKey({columns: array<columnWithName>})
  | ForeignKey({
      columns: array<columnWithName>,
      foreignTableName: string,
      foreignColumns: array<columnWithName>,
      onUpdate: fkConstraint,
      onDelete: fkConstraint,
    })

type table<'columns, 'constraints> = {
  moduleName: string,
  tableName: string,
  columns: {..} as 'columns,
  constraints: 'columns => ({..} as 'constraints),
}
