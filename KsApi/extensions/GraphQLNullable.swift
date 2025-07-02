public struct GraphQLInput {
  public static func someOrNil<Wrapped>(_ maybeValue: Wrapped?) -> GraphQLNullable<Wrapped> {
    if let value = maybeValue {
      return .some(value)
    } else {
      return .none
    }
  }

  public static func caseOrNil<Case>(_ maybeValue: Case?) -> GraphQLNullable<GraphQLEnum<Case>> {
    if let value = maybeValue {
      return .some(.case(value))
    } else {
      return .none
    }
  }

  public static func someCase<Case>(_ someCase: Case) -> GraphQLEnum<Case> {
    return .case(someCase)
  }
}
