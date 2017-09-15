import Argo
import Curry
import Runes

public struct CategoriesEnvelope {
  public private(set) var categories: [Category]
}

extension CategoriesEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<CategoriesEnvelope> {
    return curry(CategoriesEnvelope.init)
      <^> json <|| "categories"
  }
}
