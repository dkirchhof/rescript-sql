let setAggregation = (node, aggregation) =>
  switch Obj.magic(node) {
  | Node.Column(column) => Node.Column({...column, aggregation})->Obj.magic
  | _ => panic("only available for columns")
  }

let count = (node): int => setAggregation(node, Count)
let sum = (node): NULL.t<float> => setAggregation(node, Sum)
let avg = (node): NULL.t<float> => setAggregation(node, Avg)
let min = (node: 'a): NULL.t<'a> => setAggregation(node, Min)
let max = (node: 'a): NULL.t<'a> => setAggregation(node, Max)
