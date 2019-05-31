internal func combos<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in
    ys.map { y in
      (x, y)
    }
  }
}

internal func combos<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return xs.flatMap { x in
    ys.flatMap { y in
      zs.map { z in
        (x, y, z)
      }
    }
  }
}
