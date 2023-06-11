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

  let table: t = {
    name: "artists",
    columns: {
      id: Node.makeColumn({name: "id", type_: "INTEGER"}),
      name: Node.makeColumn({name: "name", type_: "TEXT"}),
    },
  }
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

  let table: t = {
    name: "songs",
    columns: {
      id: Node.makeColumn({name: "id", type_: "INTEGER"}),
      artistId: Node.makeColumn({name: "artistId", type_: "INTEGER"}),
      name: Node.makeColumn({name: "name", type_: "TEXT"}),
    },
  }
}

/* end of generated code */

%%raw(`
  import { inspect } from "util";
`)

let log: 'a => unit = %raw(`
  function log(message) {
    if (typeof message === "string") {
      console.log(message);
    } else {
      console.log(inspect(message, false, 5, true));
    }
  }
`)

open Select
open Expr

from(ArtistsTable.table)->S1.where(c => eq(c.id, 1))->S1.selectAll->log

from(ArtistsTable.table)
->S1.where(c => eq(c.id, 1))
->S1.select(c =>
  {
    "id": c.id,
    "name": c.name,
  }
)
->log

from(ArtistsTable.table)
->S1.innerJoin(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->S2.where(c => eq(c.t2.artistId, c.t1.id))
->S2.select(c =>
  {
    "id": c.t1.id,
    "name": c.t2.name,
  }
)
->log

from(ArtistsTable.table)
->S1.leftJoin(SongsTable.table, c => eq(c.t2.artistId, c.t1.id))
->S2.where(c => eq(c.t2.artistId, c.t1.id))
->S2.select(c =>
  {
    "id": c.t1.id,
    "name": c.t2.name,
  }
)
->log

from(ArtistsTable.table)
->S1.where(c => eq(c.id, from(ArtistsTable.table)->S1.toSubquery(c => c.id)))
->S1.select(c =>
  {
    "id": c.id,
    "name": c.name,
  }
)
->log
