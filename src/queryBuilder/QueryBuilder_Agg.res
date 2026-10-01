module Private = {
  let aggregate = (node, aggregation) => {
    Node.Aggregation(aggregation, Node.normalize(node))->Obj.magic
  }
}

let count = (node): int => Private.aggregate(node, Count)
let sum = (node): null<float> => Private.aggregate(node, Sum)
let avg = (node): null<float> => Private.aggregate(node, Avg)
let min = (node: 'a): null<'a> => Private.aggregate(node, Min)
let max = (node: 'a): null<'a> => Private.aggregate(node, Max)
