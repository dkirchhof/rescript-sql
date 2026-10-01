let aggregate = (node, aggregation) => {
  Node.Aggregate(aggregation, Node.normalize(node))->Obj.magic
}

let count = (node): int => aggregate(node, Count)
let sum = (node): null<float> => aggregate(node, Sum)
let avg = (node): null<float> => aggregate(node, Avg)
let min = (node: 'a): null<'a> => aggregate(node, Min)
let max = (node: 'a): null<'a> => aggregate(node, Max)
