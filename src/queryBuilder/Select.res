type joinType = INNER | LEFT
type direction = ASC | DESC

type source<'projectable, 'selectable> = {
  name: string,
  alias: option<string>,
  columns: 'selectable,
}

type join<'projectable, 'selectable> = {
  table: source<'projectable, 'selectable>,
  joinType: joinType,
  on: Expr.t,
}

module Executable = {
  type source = {
    name: string,
    alias: option<string>,
  }

  type join = {
    table: source,
    joinType: joinType,
    on: Expr.t,
  }

  type t<'projection> = {
    from: source,
    joins: array<join>,
    where: option<Expr.t>,
    projection: 'projection,
  }
}

module S2 = {
  type columns<'s1, 's2> = {
    t1: 's1,
    t2: 's2,
  }

  type t<'p1, 's1, 'p2, 's2> = {
    from: source<'p1, 's1>,
    join: join<'p2, 's2>,
    where: option<Expr.t>,
  }

  let where = (q, getWhere) => {
    ...q,
    where: Some(
      getWhere({
        t1: q.from.columns,
        t2: q.join.table.columns,
      }),
    ),
  }

  let select = (q: t<'p1, _, 'p2, _>, getProjection: columns<'p1, 'p2> => 'p): Executable.t<'p> => {
    Executable.from: {name: q.from.name, alias: q.from.alias},
    joins: [
      {
        table: {
          name: q.join.table.name,
          alias: q.join.table.alias,
        },
        joinType: q.join.joinType,
        on: q.join.on,
      },
    ],
    where: q.where,
    projection: Obj.magic({
      t1: q.from.columns,
      t2: q.join.table.columns,
    })->getProjection,
  }
}

module S1 = {
  type t<'p1, 's1> = {
    from: source<'p1, 's1>,
    where: option<Expr.t>,
  }

  type joinedColumns<'s1, 's2> = {
    t1: 's1,
    t2: 's2,
  }

  let _join = (q, t2: Table.t<_>, getOn, joinType) => {
    let from = {
      name: q.from.name,
      alias: Some("t1"),
      columns: Utils.mapColumns(q.from.columns, column => {...column, tableAlias: "t1"}),
    }

    let joinedTable = {
      name: t2.name,
      alias: Some("t2"),
      columns: Utils.mapColumns(t2.columns, column => {...column, tableAlias: "t2"}),
    }

    {
      S2.from,
      join: {
        table: joinedTable,
        joinType,
        on: getOn({
          t1: from.columns,
          t2: joinedTable.columns,
        })
      },
      where: q.where,
    }
  }

  let innerJoin = (q: t<'p1, 's1>, t2: Table.t<'full, 'partial, 'optional>, getOn): S2.t<'p1, 's1, 'full, 'full> => 
    _join(q, t2, getOn, INNER)

  let leftJoin = (q: t<'p1, 's1>, t2: Table.t<'full, 'partial, 'optional>, getOn): S2.t<'p1, 's1, 'optional, 'full> =>
    _join(q, t2, getOn, LEFT)

  let where = (q, getWhere) => {
    ...q,
    where: Some(getWhere(q.from.columns)),
  }

  let select = (q: t<'p1, _>, getProjection: 'p1 => 'p): Executable.t<'p> => {
    Executable.from: {name: q.from.name, alias: q.from.alias},
    joins: [],
    where: q.where,
    projection: q.from.columns->getProjection,
  }
}

let from = (t1: Table.t<'full, 'partial, 'optional>): S1.t<'full, 'full> => {
  S1.from: {name: t1.name, alias: None, columns: t1.columns},
  where: None,
}
