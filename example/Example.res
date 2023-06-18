/* start of generated code */

module ArtistsTable = {
  type full = {
    id: int,
    name: string,
  }

  type partial = {
    id?: int,
    name: string,
  }

  type optional = {
    id?: int,
    name?: string,
  }

  type t = Table.t<full, partial, optional>

  let table: t = Table.make(
    "artists",
    [{name: "id", type_: "INTEGER"}, {name: "name", type_: "TEXT"}],
  )
}

module SongsTable = {
  type full = {
    id: int,
    artistId: int,
    name: string,
  }

  type partial = {
    id?: int,
    artistId: int,
    name: string,
  }

  type optional = {
    id?: int,
    artistId?: int,
    name?: string,
  }

  type t = Table.t<full, partial, optional>

  let table: t = Table.make(
    "songs",
    [
      {name: "id", type_: "INTEGER"},
      {name: "artistId", type_: "INTEGER"},
      {name: "name", type_: "TEXT"},
    ],
  )
}

/* end of generated code */

open Select
open Expr
open OrderBy

from(ArtistsTable.table)->selectAll->SQL.toSQL->Utils.log

from(ArtistsTable.table)
->where(c => eq(c.id, 1))
->select(c => {"name": c.name, "someNumber": 1, "someString": "hello world", "someBoolean": true})
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->selectAll
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artistName": c.t1.name, "songName": c.t2.name})
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artist": {"name": c.t1.name}, "song": {"name": c.t2.name}})
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->selectAll
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artistName": c.t1.name, "songName": Option.map(c.t2, t2 => t2.name)})
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->leftJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artist": {"name": c.t1.name}, "song": Option.map(c.t2, t2 => {"name": t2.name})})
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->where(c => eq(c.id, 1))
->orderBy(c => [asc(c.name)])
->limit(1)
->offset(1)
->selectAll
->SQL.toSQL
->Utils.log

from(ArtistsTable.table)
->innerJoin1(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->where(c => eq(c.t1.id, 1))
->orderBy(c => [asc(c.t1.name)])
->limit(1)
->offset(1)
->selectAll
->SQL.toSQL
->Utils.log

// from(ArtistsTable.table)
// ->S1.where(c => eq(c.id, from(ArtistsTable.table)->S1.toSubquery(c => c.id)))
// ->S1.select(c =>
//   {
//     "id": c.id,
//     "name": c.name,
//   }
// )
// ->SQL.toSQL
// ->log
