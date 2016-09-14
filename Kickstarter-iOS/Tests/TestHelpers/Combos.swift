internal func combos<A, B>(xs: [A], _ ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in
    return ys.map { y in
      return (x, y)
    }
  }
}
