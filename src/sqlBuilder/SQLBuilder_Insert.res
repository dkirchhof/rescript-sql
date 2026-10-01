let toSQL = query => {
  let renderer = SQLBuilder_Renderer.makeRenderer()
  let sql = renderer.renderInsert(query)

  {SQLBuilder_SQL.sql, params: renderer.params}
}
