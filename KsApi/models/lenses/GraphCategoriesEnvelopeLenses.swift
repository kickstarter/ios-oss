import Prelude

extension RootCategoriesEnvelope {
  public enum lens {
    public static let categories = Lens<RootCategoriesEnvelope, [RootCategoriesEnvelope.Category]>(
      view: { $0.rootCategories },
      set: { part, _ in RootCategoriesEnvelope(rootCategories: part) }
    )
  }
}
