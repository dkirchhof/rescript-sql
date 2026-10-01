type aggregation = Count | Sum | Avg | Min | Max
type joinType = INNER | LEFT
type direction = ASC | DESC

@unboxed
type literal =
  | String(string)
  | Number(float)
  | @as(true) True
  | @as(false) False
  | @as(null) Null

type source = {
  name: string,
  alias: option<string>,
}

type rec node =
  | ProjectionGroup(dict<node>)
  | Column(Column.t)
  | Subquery(selectExQuery)
  | Value(unknown)
  | Literal(literal)
  | Aggregation(aggregation, node)
  | JsonExtract(node, node)

and predicate =
  | And(array<predicate>)
  | Or(array<predicate>)
  | Equal(node, node)
  | NotEqual(node, node)
  | GreaterThan(node, node)
  | GreaterThanEqual(node, node)
  | LessThan(node, node)
  | LessThanEqual(node, node)
  | Between(node, node, node)
  | NotBetween(node, node, node)
  | In(node, array<node>)
  | NotIn(node, array<node>)
  | Like(node, node)
  | NotLike(node, node)
  | ILike(node, node)
  | NotILike(node, node)

and selectQuery = {
  from: source,
  joins: array<join>,
  where: option<predicate>,
  groupBy: array<groupBy>,
  having: option<predicate>,
  orderBy: array<orderBy>,
  limit: option<limit>,
  offset: option<offset>,
}

and selectExQuery = {
  selectQuery: selectQuery,
  projection: dict<node>,
}

and join = {
  table: source,
  joinType: joinType,
  on: predicate,
}

and orderBy = {
  node: node,
  direction: direction,
}

and groupBy = node
and limit = node
and offset = node
