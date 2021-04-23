import Foundation

public extension Optional where Wrapped == Int {
  // Unwraps the optional and returns a zero if self is nil.
  var orZero: Int {
    return self ?? 0
  }
}

public extension Optional where Wrapped == Float {
  // Unwraps the optional and returns a zero if self is nil.
  var orZero: Float {
    return self ?? 0
  }
}

public extension Optional where Wrapped == Double {
  // Unwraps the optional and returns a zero if self is nil.
  var orZero: Double {
    return self ?? 0
  }
}
