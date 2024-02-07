// Combine two arrays by creating an array consisting of each pairwise combo.
// Result consists of `A.count * B.count` pairs.
internal func combos<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in
    ys.map { y in
      (x, y)
    }
  }
}

// Combine three arrays by creating an array consisting of all possible tuples.
// Result consists of `A.count * B.count * C.count` tuples.
internal func combos<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return xs.flatMap { x in
    ys.flatMap { y in
      zs.map { z in
        (x, y, z)
      }
    }
  }
}

// Combine two arrays by creating an array where each element is represented at least once.
// Result consists of `max(A.count, B.count)` pairs.
internal func orthogonalCombos<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  if xs.count >= ys.count {
    return xs.enumerated().map { index, x in
      (x, ys[index % ys.count])
    }
  } else {
    return ys.enumerated().map { index, y in
      (xs[index % xs.count], y)
    }
  }
}

// Combine three arrays by creating an array where each element is represented at least once.
// Result consists of `max(A.count, B.count, C.count)` tuples.
internal func orthogonalCombos<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  if xs.count >= ys.count, xs.count >= zs.count {
    return xs.enumerated().map { index, x in
      (x, ys[index % ys.count], zs[index % zs.count])
    }
  } else if ys.count >= xs.count, ys.count >= zs.count {
    return ys.enumerated().map { index, y in
      (xs[index % xs.count], y, zs[index % zs.count])
    }
  } else {
    return zs.enumerated().map { index, z in
      (xs[index % xs.count], ys[index % ys.count], z)
    }
  }
}
