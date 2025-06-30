extension GraphQLNullable {
  static func someOrNil(_ maybeValue: Wrapped?) -> GraphQLNullable {
    if let value = maybeValue {
      return .some(value)
    } else {
      return .none
    }
  }

  static func caseOrNil<T>(_ maybeValue: T?) -> GraphQLNullable<GraphQLEnum<T>> {
    if let value = maybeValue {
      return .some(.case(value))
    } else {
      return .none
    }
  }
}
