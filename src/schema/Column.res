type aggregation = Count | Sum | Avg | Min | Max
type jsonFunction = Extract(string)

type t = {
  name: string,
  tableAlias?: string,
  columnAlias?: string,
  aggregation?: aggregation,
  jsonFunction?: jsonFunction,
}
