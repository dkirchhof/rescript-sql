type t = array<string>

let make = () => []

let addS = (builder, indentation, line) => {
  let spaces = String.repeat(" ", indentation)

  Array.push(builder, spaces ++ line)

  builder
}

let addSO = (builder, indentation, optionalLine) => {
  switch optionalLine {
  | Some(line) => addS(builder, indentation, line)
  | None => builder
  }
}

let addM = (builder, indentation, lines) => {
  lines->Array.forEach(line => addS(builder, indentation, line)->ignore)

  builder
}

let addMO = (builder, indentation, optionalLines) => {
  switch optionalLines {
  | Some(lines) => addM(builder, indentation, lines)
  | None => builder
  }
}

let addE = builder => {
  Array.push(builder, "")

  builder
}

let build = Array.joinWith
