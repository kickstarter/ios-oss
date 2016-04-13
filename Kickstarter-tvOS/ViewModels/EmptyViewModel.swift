import protocol Library.ViewModelType

final class EmptyViewModel: ViewModelType {
  typealias Model = Void

  static let shared = EmptyViewModel()

  private init() {
  }
}
