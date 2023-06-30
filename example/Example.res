/* start of generated code */

module ArtistsTable = {
  type select = {
    id: int,
    name: string,
  }

  type insert = {
    id?: int,
    name: string,
  }

  type update = {
    id?: int,
    name?: string,
  }

  type t = Table.t<select, insert, update>

  let table: t = Table.make(
    "artists",
    [{name: "id", type_: "INTEGER", notNull: true}, {name: "name", type_: "TEXT", notNull: true}],
  )
}

module SongsTable = {
  type select = {
    id: int,
    artistId: int,
    name: string,
  }

  type insert = {
    id?: int,
    artistId: int,
    name: string,
  }

  type update = {
    id?: int,
    artistId?: int,
    name?: string,
  }

  type t = Table.t<select, insert, update>

  let table: t = Table.make(
    "songs",
    [
      {name: "id", type_: "INTEGER", notNull: true},
      {name: "artistId", type_: "INTEGER", notNull: true},
      {name: "name", type_: "TEXT", notNull: true},
    ],
  )
}

/* end of generated code */

module DB = RescriptSQL.MakeSync({
  type connection = BetterSQLite3.connection

  let execute = BetterSQLite3.exec
  let getRows = (connection, sql) => BetterSQLite3.prepare(connection, sql)->BetterSQLite3.all
})

let connection = BetterSQLite3.createConnection(":memory:")

let ddl = () => {
  open DB.CreateTable

  let logAndExecute = query => {
    query->toSQL->Logger.log
    query->execute(connection)->Logger.log
  }

  createTable(ArtistsTable.table)->logAndExecute
  createTable(SongsTable.table)->logAndExecute
}

let dml = () => {
  BetterSQLite3.exec(connection, `INSERT INTO artists VALUES(1, 'Artist 1')`)
  BetterSQLite3.exec(connection, `INSERT INTO artists VALUES(2, 'Artist 2')`)
  BetterSQLite3.exec(connection, `INSERT INTO artists VALUES(3, 'Artist 3')`)

  BetterSQLite3.exec(connection, `INSERT INTO songs VALUES(11, 1, 'Song 1_1')`)
  BetterSQLite3.exec(connection, `INSERT INTO songs VALUES(12, 1, 'Song 1_2')`)
  BetterSQLite3.exec(connection, `INSERT INTO songs VALUES(13, 1, 'Song 1_3')`)
  BetterSQLite3.exec(connection, `INSERT INTO songs VALUES(21, 2, 'Song 2_1')`)
}

let dql = () => {
  open DB.Select
  open DB.Expr
  open DB.GroupBy
  open DB.OrderBy

  let logAndExecute = query => {
    query->toSQL->Logger.log
    query->execute(connection)->Logger.log
  }

  from(ArtistsTable.table)->selectAll->logAndExecute

  from(ArtistsTable.table)
  ->where(c => eq(c.id, 1))
  ->select(c =>
    {
      "name": c.name,
      "someNumber": 1,
      "someString": "hello world",
      "someBoolean": true,
    }
  )
  ->logAndExecute

  from(ArtistsTable.table)
  ->select(c => {"a": {"c": c.name, "d": 1, "e": {"someBoolean": true}}})
  ->logAndExecute

  from(ArtistsTable.table)
  ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->selectAll
  ->logAndExecute

  from(ArtistsTable.table)
  ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->select(c => {"artistName": c.t1.name, "songName": c.t2.name})
  ->logAndExecute

  from(ArtistsTable.table)
  ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->select(c => {"artist": {"name": c.t1.name}, "song": {"name": c.t2.name}})
  ->logAndExecute

  from(ArtistsTable.table)
  ->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->selectAll
  ->logAndExecute

  from(ArtistsTable.table)
  ->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->select(c => {"artistName": c.t1.name, "songName": Option.map(c.t2, t2 => t2.name)})
  ->logAndExecute

  from(ArtistsTable.table)
  ->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->select(c => {"artist": {"name": c.t1.name}, "song": Option.map(c.t2, t2 => {"name": t2.name})})
  ->logAndExecute

  from(ArtistsTable.table)
  ->where(c => eq(c.id, 1))
  ->groupBy(c => [group(c.id), group(c.name)])
  ->having(c => eq(c.id, 1))
  ->orderBy(c => [asc(c.id), desc(c.name)])
  ->limit(1)
  ->offset(1)
  ->selectAll
  ->logAndExecute

  from(ArtistsTable.table)
  ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
  ->where(c => eq(c.t1.id, 1))
  ->groupBy(c => [group(c.t1.id), group(c.t2.name)])
  ->having(c => eq(c.t1.id, 1))
  ->orderBy(c => [asc(c.t1.id), desc(c.t2.name)])
  ->limit(1)
  ->offset(1)
  ->selectAll
  ->logAndExecute

  // from(ArtistsTable.table)
  // ->S1.where(c => eq(c.id, from(ArtistsTable.table)->S1.toSubquery(c => c.id)))
  // ->S1.select(c =>
  //   {
  //     "id": c.id,
  //     "name": c.name,
  //   }
  // )
  // ->log
}

ddl()
dml()
dql()
