let toSQL = (query: QueryBuilder_Select_Executable.t<_>) => {
  let renderer = SQLBuilder_Renderer.makeRenderer()
  let sql = renderer.renderSelect(query.ast, 0)

  {SQLBuilder_SQL.sql, params: renderer.params}
}
