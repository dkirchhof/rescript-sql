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

open QueryBuilder.CreateTable
open SQLBuilder.CreateTable

createTable(ArtistsTable.table)->toSQL->Logger.log
createTable(SongsTable.table)->toSQL->Logger.log

// open Select
// open Expr
// open OrderBy
// open GroupBy

// from(ArtistsTable.table)->selectAll->SQL_Select.toSQL->Logger.log

// from(ArtistsTable.table)
// ->where(c => eq(c.id, 1))
// ->select(c => {"name": c.name, "someNumber": 1, "someString": "hello world", "someBoolean": true})
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->selectAll
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->select(c => {"artistName": c.t1.name, "songName": c.t2.name})
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->select(c => {"artist": {"name": c.t1.name}, "song": {"name": c.t2.name}})
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->selectAll
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->select(c => {"artistName": c.t1.name, "songName": Option.map(c.t2, t2 => t2.name)})
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->select(c => {"artist": {"name": c.t1.name}, "song": Option.map(c.t2, t2 => {"name": t2.name})})
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->where(c => eq(c.id, 1))
// ->groupBy(c => [group(c.id), group(c.name)])
// ->having(c => eq(c.id, 1))
// ->orderBy(c => [asc(c.id), desc(c.name)])
// ->limit(1)
// ->offset(1)
// ->selectAll
// ->SQL_Select.toSQL
// ->Logger.log

// from(ArtistsTable.table)
// ->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
// ->where(c => eq(c.t1.id, 1))
// ->groupBy(c => [group(c.t1.id), group(c.t2.name)])
// ->having(c => eq(c.t1.id, 1))
// ->orderBy(c => [asc(c.t1.id), desc(c.t2.name)])
// ->limit(1)
// ->offset(1)
// ->selectAll
// ->SQL_Select.toSQL
// ->Logger.log

// // from(ArtistsTable.table)
// // ->S1.where(c => eq(c.id, from(ArtistsTable.table)->S1.toSubquery(c => c.id)))
// // ->S1.select(c =>
// //   {
// //     "id": c.id,
// //     "name": c.name,
// //   }
// // )
// // ->log
