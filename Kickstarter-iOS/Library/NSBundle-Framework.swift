extension Bundle {
  /// Returns an NSBundle pinned to the framework target. We could choose anything for the `forClass`
  /// parameter as long as it is in the framework target.
  internal static var framework: Bundle {
    return Bundle(for: RootViewModel.self)
  }
}
