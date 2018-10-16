import Prelude

protocol Queryable {
  var query: NonEmptySet<Query> { get }
}
