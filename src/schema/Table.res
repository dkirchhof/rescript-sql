type t<'select, 'insert, 'update> = {
  name: string,
  select: 'select,
  insert: 'insert,
  update: 'update,
}

let make = (name, columns: array<Column.t>) => {
  let columns =
    columns
    ->Array.map(config => (config.name, Node.Column(config)))
    ->Dict.fromArray

  {
    name,
    select: Obj.magic(columns),
    insert: Obj.magic(columns),
    update: Obj.magic(columns),
  }
}
