type t<'a> = {
  tableName: string,
  columns: 'a,
  constraints: array<Constraint.t>,
}

let createTable = (table: Table.t<_>) => {
  tableName: table.name, 
  columns: table.columns,
  constraints: table.constraints,
}
