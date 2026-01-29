import Foundation

extension Equatable {
  func isAny(of elements: Self...) -> Bool {
    return elements.contains(self)
  }
}
