import Foundation
import Prelude

// TODO: This should be reconciled with the global-scope Category
struct GraphCategory: Decodable {
  var id: String
  var name: String
  var parentCategory: ParentCategory?

  struct ParentCategory: Decodable {
    var id: String
    var name: String
  }
}
