let toSQL = (query: Query.t<_>) => {
  switch query {
    | Select(query) => SQL_Select.toSQL(query)
  }
}
