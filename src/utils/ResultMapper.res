let map = (query: QueryBuilder_Select_Executable.t<'result>, row): 'result => {
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
      | Node.JsonExtract(_, _) => Object.set(obj, key, Object.get(row, fullKey))
      | Node.Value(value) => Object.set(obj, key, value)
      | Node.Literal(value) => Object.set(obj, key, value)
      }
    })

    obj
  }

  recMap(query.ast.projection, "")->Obj.magic
}
