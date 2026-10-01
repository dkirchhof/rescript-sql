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
  ...baseColumn,
  name: string,
  dbType: string,
  resType: string,
}

type fkConstraint = NoAction | SetNull | SetDefault | Cascade

type tableConstraint =
  | Unique({columns: array<column>})
  | PrimaryKey({columns: array<column>})
  | ForeignKey({
      columns: array<column>,
      foreignTableName: string,
      foreignColumns: array<column>,
      onUpdate: fkConstraint,
      onDelete: fkConstraint,
    })

type table<'columns, 'constraints> = {
  moduleName: string,
  tableName: string,
  columns: {..} as 'columns,
  constraints?: 'columns => ({..} as 'constraints),
}
