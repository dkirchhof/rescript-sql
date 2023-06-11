type direction = ASC | DESC

type source<'projectable, 'selectable> = {
  name: string,
  alias: option<string>,
  columns: 'selectable,
}

type join<'projectable, 'selectable> = {
  table: source<'projectable, 'selectable>,
  joinType: JoinType.t,
  on: Expr.t,
}

type singleColumnProjection<'a> = {
  value: 'a,
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

  let select = (q: t<'p1, _, 'p2, _>, getProjection: columns<'p1, 'p2> => 'p) => Query.Select({
    from: {name: q.from.name, alias: q.from.alias},
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
    projection: {
      t1: Obj.magic(q.from.columns),
      t2: Obj.magic(q.join.table.columns),
    }->getProjection,
  })

  let toSubquery = (q: t<'p1, _, 'p2, _>, getProjection: columns<'p1, 'p2> => 'p): 'p => Node.makeSubquery({
    from: {name: q.from.name, alias: q.from.alias},
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
    projection: {
      value: {
        t1: Obj.magic(q.from.columns),
        t2: Obj.magic(q.join.table.columns),
      }->getProjection,
    },
  })
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
      columns: Utils.getColumnsWithTableAlias(q.from.columns, "t1"),
    }

    let joinedTable = {
      name: t2.name,
      alias: Some("t2"),
      columns: Utils.getColumnsWithTableAlias(t2.columns, "t2"),
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

  let select = (q: t<'p1, _>, getProjection: 'p1 => {..} as 'p) => Query.Select({
    from: {name: q.from.name, alias: q.from.alias},
    joins: [],
    where: q.where,
    projection: q.from.columns->getProjection,
  })

  let toSubquery = (q: t<'p1, _>, getProjection: 'p1 => 'p): 'p => Node.makeSubquery({
    from: {name: q.from.name, alias: q.from.alias},
    joins: [],
    where: q.where,
    projection: {
      value: q.from.columns->getProjection
    },
  })
}

let from = (t1: Table.t<'full, 'partial, 'optional>): S1.t<'full, 'full> => {
  S1.from: {name: t1.name, alias: None, columns: t1.columns},
  where: None,
}
