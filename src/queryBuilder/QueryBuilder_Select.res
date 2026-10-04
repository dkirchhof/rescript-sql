type t<'a, 'b> = {
  ...AST.selectQuery,
  _projectables: 'a,
  _selectables: 'b,
}

let from = (source: Source.t<'columns, _, _, _>): t<'columns, 'columns> => {
  from: {name: source.name, alias: None},
  joins: [],
  where: None,
  groupBy: [],
  having: None,
  orderBy: [],
  limit: None,
  offset: None,
  _projectables: source.columns,
  _selectables: source.columns,
}

let _join1 = (q, source: Source.t<_, _, _, _>, alias, getOn, joinType) => {
  let alias1 = Option.getOr(q.from.alias, q.from.name)

  let columns = (
    QueryBuilder_Utils.getColumnsWithTableAlias(q._projectables, alias1),
    QueryBuilder_Utils.getColumnsWithTableAlias(source.columns, alias),
  )

  {
    ...q,
    from: {
      ...q.from,
      alias: Some(alias1),
    },
    joins: [
      {
        table: {
          name: source.name,
          alias: Some(alias),
        },
        joinType,
        on: getOn(columns),
      },
    ],
    _projectables: Obj.magic(columns),
    _selectables: columns,
  }
}

let _join2 = (q, source: Source.t<_, _, _, _>, alias, getOn, joinType) => {
  let (c1, c2) = q._projectables

  let columns = (c1, c2, QueryBuilder_Utils.getColumnsWithTableAlias(source.columns, alias))

  {
    ...q,
    joins: [
      ...q.joins,
      {
        table: {
          name: source.name,
          alias: Some(alias),
        },
        joinType,
        on: getOn(columns),
      },
    ],
    _projectables: Obj.magic(columns),
    _selectables: columns,
  }
}

let innerJoin1 = (q: t<'p1, 's1>, source: Source.t<'columns, _, _, _>, alias, getOn): t<
  ('p1, 'columns),
  ('s1, 'columns),
> => _join1(q, source, alias, getOn, INNER)

let innerJoin2 = (
  q: t<('p1, 'p2), ('s1, 's2)>,
  source: Source.t<'columns, _, _, _>,
  alias,
  getOn,
): t<('p1, 'p2, 'columns), ('s1, 's2, 'columns)> => _join2(q, source, alias, getOn, INNER)

let leftJoin1 = (q: t<'p1, 's1>, source: Source.t<'columns, 'nullColumns, _, _>, alias, getOn): t<
  ('p1, 'nullColumns),
  ('s1, 'columns),
> => _join1(q, source, alias, getOn, LEFT)

let leftJoin2 = (
  q: t<('p1, 'p2), ('s1, 's2)>,
  source: Source.t<'columns, 'nullColumns, _, _>,
  alias,
  getOn,
): t<('p1, 'p2, 'nullColumns), ('s1, 's2, 'columns)> => _join2(q, source, alias, getOn, LEFT)

let where = (q, getWhere) => {
  ...q,
  where: q._selectables->getWhere->Some,
}

let groupBy = (q, getGroupBy) => {
  ...q,
  groupBy: getGroupBy(q._selectables),
}

let having = (q, getHaving) => {
  ...q,
  having: q._selectables->getHaving->Some,
}

let orderBy = (q, getOrderBy) => {
  ...q,
  orderBy: getOrderBy(q._selectables),
}

let limit = (q, limit: int) => {
  ...q,
  limit: Some(Node.normalize(limit)),
}

let offset = (q, offset: int) => {
  ...q,
  offset: Some(Node.normalize(offset)),
}

let finalize = (q, projection: 'projection): QueryBuilder_Select_Executable.t<'projection> => {
  ast: {
    selectQuery: {
      from: q.from,
      joins: q.joins,
      where: q.where,
      groupBy: q.groupBy,
      having: q.having,
      orderBy: q.orderBy,
      limit: q.limit,
      offset: q.offset,
    },
    projection: Projection.normalize(projection),
  },
}

let selectAll = q => {
  finalize(q, q._projectables)
}

let select = (q, getProjection) => {
  finalize(q, getProjection(q._projectables))
}

let selectAsSubquery = (q, getProjection: _ => {"value": 'value}): 'value => {
  finalize(q, getProjection(q._projectables))->Node.makeSubquery
}
