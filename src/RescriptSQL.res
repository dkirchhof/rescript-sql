module Expr = QueryBuilder_Expr
module Literal = QueryBuilder_Literal
module GroupBy = QueryBuilder_GroupBy
module OrderBy = QueryBuilder_OrderBy
module Agg = QueryBuilder_Agg
module JSON = QueryBuilder_JSON

module Insert = {
  include QueryBuilder_Insert
  include QueryBuilder_Literal
  include SQLBuilder_Insert
}

module Update = {
  include QueryBuilder_Update
  include QueryBuilder_Expr
  include QueryBuilder_Literal
  include SQLBuilder_Update
}

module Delete = {
  include QueryBuilder_Delete
  include QueryBuilder_Expr
  include QueryBuilder_Literal
  include SQLBuilder_Delete
}

module Select = {
  include QueryBuilder_Select
  include QueryBuilder_Expr
  include QueryBuilder_Literal
  include QueryBuilder_GroupBy
  include QueryBuilder_OrderBy
  include QueryBuilder_Agg
  include QueryBuilder_JSON
  include SQLBuilder_Select
}
