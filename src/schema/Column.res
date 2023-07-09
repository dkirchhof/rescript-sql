type aggregation = Count | Sum | Avg | Min | Max

type t = {
  name: string,
  tableAlias?: string,
  columnAlias?: string,
  aggregation?: aggregation, 
}
