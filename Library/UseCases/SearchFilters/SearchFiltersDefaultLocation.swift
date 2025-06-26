import KsApi

public enum SearchFiltersDefaultLocation: Identifiable, Equatable {
  case anywhere
  case some(KsApi.Location)

  public var id: Int {
    switch self {
    case .anywhere:
      -1
    case let .some(location):
      location.id
    }
  }

  public var title: String {
    switch self {
    case .anywhere:
      // FIXME: MBL-2343 Add translations
      "FPO: Anywhere"
    case let .some(location):
      location.displayableName
    }
  }
}

public func == (lhs: SearchFiltersDefaultLocation, rhs: SearchFiltersDefaultLocation) -> Bool {
  switch (lhs, rhs) {
  case (.anywhere, .anywhere):
    true
  case let (.some(lhsLocation), .some(rhsLocation)):
    lhsLocation.id == rhsLocation.id
  default:
    false
  }
}
