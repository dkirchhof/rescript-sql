type t = Dict.t<Unknown.t>

let normalize = (projection: 'a): 'a => {
  let fields: Dict.t<_> = Obj.magic(projection)

  fields
  ->Dict.toArray
  ->Array.map(((key, value)) => (key, Unknown.make(value)))
  ->Dict.fromArray
  ->Obj.magic
}

// let fold = (~projection, ~mapGroup, ~mapLeaf) => {
//   let rec walk = (fields: t, path) => {
//     fields
//     ->Dict.toArray
//     ->Array.map(((key, value)) => {
//       let alias = `${path}${key}`
//       let value = switch Node.fromUnknown(value) {
//       | ProjectionGroup(group) => walk(group, `${alias}.`)
//       | node => mapLeaf(alias, node)
//       }

//       (key, value)
//     })
//     ->mapGroup
//   }

//   walk(Obj.magic(projection), "")
// }
