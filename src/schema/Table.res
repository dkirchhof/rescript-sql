type t<'full, 'partial, 'optional> = {
  name: string,
  full: 'full,
  partial: 'partial,
  optional: 'optional,
}

let make = (name, columns: array<Column.t>) => {
  let columns =
    columns
    ->Array.map(config => (config.name, Node.Column(config)))
    ->Dict.fromArray

  {
    name,
    full: Obj.magic(columns),
    partial: Obj.magic(columns),
    optional: Obj.magic(columns),
  }
}
