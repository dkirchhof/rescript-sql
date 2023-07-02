type fkConstraint = NoAction | SetNull | SetDefault | Cascade

type t =
  | Unique({name: string, columns: array<string>})
  | PrimaryKey({name: string, columns: array<string>})
  | ForeignKey({
      name: string,
      columns: array<string>,
      foreignTableName: string,
      foreignColumns: array<string>,
      onUpdate: fkConstraint,
      onDelete: fkConstraint,
    })
