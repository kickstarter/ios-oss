extension GraphQLNullable {
  public static func someOrNil(_ maybeValue: Wrapped?) -> GraphQLNullable {
    if let value = maybeValue {
      return .some(value)
    } else {
      return .none
    }
  }

  public static func caseOrNil<T>(_ maybeValue: T?) -> GraphQLNullable<GraphQLEnum<T>> {
    if let value = maybeValue {
      return .some(.case(value))
    } else {
      return .none
    }
  }
}
