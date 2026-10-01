type aggregation = Count | Sum | Avg | Min | Max
type joinType = INNER | LEFT
type direction = ASC | DESC

type source = {
  name: string,
  alias: option<string>,
}

type rec node =
  | ProjectionGroup(Dict.t<node>)
  | Column(Column.t)
  | Subquery(selectEx)
  | Value(unknown)
  | Literal(EscapeValues.t)
  | Aggregate(aggregation, node)
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
and select = {
  from: source,
  joins: array<join>,
  where: option<predicate>,
  groupBy: array<node>,
  having: option<predicate>,
  orderBy: array<orderBy>,
  limit: option<node>,
  offset: option<node>,
}
and selectEx = {
  select: select,
  projection: Dict.t<node>,
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
