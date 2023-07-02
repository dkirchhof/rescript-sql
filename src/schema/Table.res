type t<'columns, 'insert, 'update> = {
  name: string,
  columns: 'columns,
  constraints: array<Constraint.t>,
}

let make = (name, columns: array<Column.t>, constraints: array<Constraint.t>) => {
  let columns =
    columns
    ->Array.map(config => (config.name, Node.Column(config)))
    ->Dict.fromArray

  {
    name,
    columns: Obj.magic(columns),
    constraints,
  }
}
