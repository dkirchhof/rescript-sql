let setJSONfunction = (node: string, jsonFunction) =>
  switch Obj.magic(node) {
  | Node.Column(column) => Node.Column({...column, jsonFunction})->Obj.magic
  | _ => panic("only available for columns")
  }

let jsonExtract = (node, path): JSON.t => setJSONfunction(node, Extract(path))
