import Prelude

extension CategoriesEnvelope {
  public enum lens {
    public static let categories = Lens<CategoriesEnvelope, [Category]>(
      view: { $0.categories },
      set: { part, _ in CategoriesEnvelope(categories: part) }
    )
  }
}
