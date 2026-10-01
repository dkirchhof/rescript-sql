type kind<'insert, 'update>

type t<'columns, 'nullColumns, 'insert, 'update> = Source.t<
  'columns,
  'nullColumns,
  kind<'insert, 'update>,
>
