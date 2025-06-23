extension GraphQLNullable {
  static func someOrNil(_ maybeValue: Wrapped?) -> GraphQLNullable {
    if let value = maybeValue {
      return .some(value)
    } else {
      return .none
    }
  }
}
