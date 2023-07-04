type columnType = INTEGER | TEXT

type t = {
  name: string,
  type_: columnType,
  notNull: bool,
  autoIncrement?: bool,
  tableAlias?: string,
  columnAlias?: string,
}
