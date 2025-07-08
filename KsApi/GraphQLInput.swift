/// When we move to Apollo 1.x, this should be ported to an extension on `GraphQLNullable`.
public struct GraphQLNullable {
  /// Apollo 1.0 adds a type `GraphQLNullable`, which wraps all optional inputs to queries and mutations.
  /// When we move to Apollo 1.x, this helper will be used to create a value which is either `.some(Wrapped)` or `.none`, as necessary.
  /// For now, with Apollo 0.44,  it does nothing - but it means it will be a smoother transition to 1.x.
  public static func someOrNil<Wrapped>(_ maybeValue: Wrapped?) -> Wrapped? {
    return maybeValue
  }

  /// Apollo 1.0 adds a type `GraphQLNullable`, which wraps all optional inputs to queries and mutations.
  /// When we move to Apollo 1.x, this helper will be used to create a value which is either `.some(.case(Case))` or `.none`, as necessary.
  /// For now, with Apollo 0.44,  it does nothing - but it means it will be a smoother transition to 1.x.
  public static func caseOrNil<Case>(_ maybeValue: Case?) -> Case? {
    return maybeValue
  }
}

/// When we move to Apollo 1.x, this should be deleted.
public struct GraphQLEnum<Case> {
  /// Apollo 1.0 adds a type GraphQLEnum, which wraps all `enum` types to queries and mutations.
  /// When we move to Apollo 1.x, this helper can be find-and-replaced with `GraphQLEnum.case(_)`.
  /// For now, with Apollo 0.44,  it does nothing - but it means it will be a smoother transition to 1.x.
  public static func someCase(_ someCase: Case) -> Case {
    return someCase
  }
}
