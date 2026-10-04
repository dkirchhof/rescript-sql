type connection
type statement

type mutationResult = {changes: int, lastInsertRowId: int}

@module("bun") @new external createConnection: string => connection = "SQL"

@send external close: connection => unit = "close"
@send external exec: (connection, string, array<unknown>) => promise<_> = "unsafe"
