type t<'columns, 'insert, 'update> = {
  name: string,
  columns: 'columns,
  constraints: array<Constraint.t>,
}
