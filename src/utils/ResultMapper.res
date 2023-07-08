let map = (projection, row) => {
  let rec recMap = (projection, path) => {
    let obj = Object.empty()

    projection
    ->Obj.magic
    ->Dict.toArray
    ->Array.forEach(((key, value)) => {
      let fullKey = `${path}${key}`

      switch value {
      | Node.ProjectionGroup(nodes) => Object.set(obj, key, recMap(Obj.magic(nodes), `${fullKey}.`))
      | Node.Column(_) => Object.set(obj, key, Object.get(row, fullKey))
      | Node.BooleanLiteral(bool) => Object.set(obj, key, bool)
      | Node.NumberLiteral(number) => Object.set(obj, key, number)
      | Node.StringLiteral(string) => Object.set(obj, key, string)
      | _ => ignore()
      }
    })

    obj
  }

  recMap(projection, "")
}
