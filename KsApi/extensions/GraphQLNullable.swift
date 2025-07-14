import ApolloAPI

public extension GraphQLNullable {
  static func someOrNil(_ maybeValue: Wrapped?) -> GraphQLNullable<Wrapped> {
    if let value = maybeValue {
      return .some(value)
    } else {
      return .none
    }
  }
}

public extension GraphQLEnum {
  static func caseOrNil(_ maybeValue: T?) -> GraphQLNullable<GraphQLEnum<T>> {
    if let value = maybeValue {
      return .some(GraphQLEnum.case(value))
    } else {
      return .none
    }
  }
}
