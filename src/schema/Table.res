type t<'columns> = {
  name: string,
  columns: 'columns,
}

let make = (name, columns: array<Column.t>) => {
  let columns =
    columns
    ->Array.map(config => (config.name, Node.Column(config)))
    ->Dict.fromArray

  {
    name,
    columns: Obj.magic(columns),
  }
}
