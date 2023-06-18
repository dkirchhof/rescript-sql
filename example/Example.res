/* start of generated code */

module ArtistsTable = {
  let _table = Table.make(
    "artists",
    [{name: "id", type_: "INTEGER"}, {name: "name", type_: "TEXT"}],
  )

  module Select = {
    type t = {
      id: int,
      name: string,
    }

    let table: Table.t<t> = _table
  }

  module Insert = {
    type t = {
      id?: int,
      name: string,
    }

    let table: Table.t<t> = _table
  }

  module Update = {
    type t = {
      id?: int,
      name?: string,
    }

    let table: Table.t<t> = _table
  }
}

module SongsTable = {
  let _table = Table.make(
    "songs",
    [
      {name: "id", type_: "INTEGER"},
      {name: "artistId", type_: "INTEGER"},
      {name: "name", type_: "TEXT"},
    ],
  )

  module Select = {
    type t = {
      id: int,
      artistId: int,
      name: string,
    }

    let table: Table.t<t> = _table
  }

  module Insert = {
    type t = {
      id?: int,
      artistId: int,
      name: string,
    }

    let table: Table.t<t> = _table
  }

  module Update = {
    type t = {
      id?: int,
      artistId?: int,
      name?: string,
    }

    let table: Table.t<t> = _table
  }
}

/* end of generated code */

// open CreateTable

// createTable(ArtistsTable.Select.table)->SQL_CreateTable.toSQL->Utils.log

open Select
open Expr
open OrderBy
open GroupBy

from(ArtistsTable.Select.table)->selectAll->SQL_Select.toSQL->Utils.log

from(ArtistsTable.Select.table)
->where(c => eq(c.id, 1))
->select(c => {"name": c.name, "someNumber": 1, "someString": "hello world", "someBoolean": true})
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->innerJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->selectAll
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->innerJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artistName": c.t1.name, "songName": c.t2.name})
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->innerJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artist": {"name": c.t1.name}, "song": {"name": c.t2.name}})
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->leftJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->selectAll
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->leftJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artistName": c.t1.name, "songName": Option.map(c.t2, t2 => t2.name)})
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->leftJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artist": {"name": c.t1.name}, "song": Option.map(c.t2, t2 => {"name": t2.name})})
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->where(c => eq(c.id, 1))
->groupBy(c => [group(c.id), group(c.name)])
->having(c => eq(c.id, 1))
->orderBy(c => [asc(c.id), desc(c.name)])
->limit(1)
->offset(1)
->selectAll
->SQL_Select.toSQL
->Utils.log

from(ArtistsTable.Select.table)
->innerJoin1(SongsTable.Select.table, c => eq(c.t2.artistId, c.t1.id))
->where(c => eq(c.t1.id, 1))
->groupBy(c => [group(c.t1.id), group(c.t2.name)])
->having(c => eq(c.t1.id, 1))
->orderBy(c => [asc(c.t1.id), desc(c.t2.name)])
->limit(1)
->offset(1)
->selectAll
->SQL_Select.toSQL
->Utils.log

// from(ArtistsTable.Select.table)
// ->S1.where(c => eq(c.id, from(ArtistsTable.Select.table)->S1.toSubquery(c => c.id)))
// ->S1.select(c =>
//   {
//     "id": c.id,
//     "name": c.name,
//   }
// )
// ->SQL_Select.toSQL
// ->log
