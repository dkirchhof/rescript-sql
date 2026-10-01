let toSQL = query => {
  let renderer = SQLBuilder_Renderer.makeRenderer()
  let sql = renderer.renderSelect(query, 0)

  {SQLBuilder_SQL.sql, params: renderer.params}
}
