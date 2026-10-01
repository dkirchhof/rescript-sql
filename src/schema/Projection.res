type t = dict<Node.t>

let normalize = (projection: 'a): t => {
  let fields: dict<unknown> = Obj.magic(projection)

  fields
  ->Dict.toArray
  ->Array.map(((key, value)) => (key, Node.normalize(value)))
  ->Dict.fromArray
}

// let fold = (~projection, ~mapGroup, ~mapLeaf) => {
//   let rec walk = (fields: t, path) => {
//     fields
//     ->Dict.toArray
//     ->Array.map(((key, value)) => {
//       let alias = `${path}${key}`
//       let value = switch value {
//       | ProjectionGroup(group) => walk(group, `${alias}.`)
//       | node => mapLeaf(alias, node)
//       }

//       (key, value)
//     })
//     ->mapGroup
//   }

//   walk(Obj.magic(projection), "")
// }
