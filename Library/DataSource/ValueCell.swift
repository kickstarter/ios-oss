/// A type that represents a cell that can be reused and configured with a value.
public protocol ValueCell: AnyObject {
  associatedtype Value
  static var defaultReusableId: String { get }
  func configureWith(value: Value)
}
