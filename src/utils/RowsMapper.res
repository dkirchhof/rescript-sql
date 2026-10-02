type query<'t> = QueryBuilder_Select_Executable.t<'t>

let mapRow = (query: query<'row>, row): 'row => {
  let rec recMap = (projection: dict<Node.t>, path) => {
    let obj = Object.make()

    projection
    ->Dict.toArray
    ->Array.forEach(((key, value)) => {
      let fullKey = `${path}${key}`

      switch value {
      | Node.ProjectionGroup(nodes) => Object.set(obj, key, recMap(nodes, `${fullKey}.`))
      | Node.Column(_)
      | Node.Subquery(_)
      | Node.Aggregation(_, _)
      | Node.JsonExtract(_, _) =>
        Object.set(obj, key, Object.get(row, fullKey))
      | Node.Value(value) => Object.set(obj, key, value)
      | Node.Literal(value) => Object.set(obj, key, value)
      }
    })

    obj
  }

  recMap(query.ast.projection, "")->Obj.magic
}

let mapRows = (query: query<'row>, rows) => {
  Array.map(rows, row => mapRow(query, row))
}

let flatMapRow = (query: query<'row>, row, map: 'row => 'result): 'result => {
  mapRow(query, row)->map
}

let flatMapRows = (query: query<'row>, rows, map) => {
  Array.map(rows, row => flatMapRow(query, row, map))
}
