type t = {
  name: string,
  type_: string,
  tableAlias?: string,
  columnAlias?: string,
}

external make: t => 'a = "%identity"
