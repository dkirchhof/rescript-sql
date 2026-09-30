let param = params => {
  value => {
    Array.push(params, Obj.magic(value))

    `$${params->Array.length->Int.toString}`
  }
}
