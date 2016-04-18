import Library

final class EmptyViewModel {
  typealias Model = Void

  static let shared = EmptyViewModel()

  private init() {
  }
}
