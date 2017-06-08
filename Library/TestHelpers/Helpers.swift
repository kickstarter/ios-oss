import Foundation

internal func repeated<T>(_ count: Int) -> ([T]) -> [T] {
  return { array in
    return Array(repeating: array, count: count).flatMap { $0 }
  }
}
