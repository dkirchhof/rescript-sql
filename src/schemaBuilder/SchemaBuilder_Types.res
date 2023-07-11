type baseColumn = {
  size?: int,
  nullable?: bool,
  autoIncrement?: bool,
  skipInInsertQuery?: bool,
}

type baseColumnWithTypes = {
  ...baseColumn,
  dbType: string,
  resType: string,
}

type column = {
  ...baseColumnWithTypes,
  name: string,
}

type columnWithName = column

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
  constraints?: 'columns => ({..} as 'constraints),
}
