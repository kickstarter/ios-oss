import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase

public struct FirebaseRefConfig: Equatable {
  let orderBy: String?
  let ref: String
  let startingAtChildKey: String?
  let startingAtValue: Any?

  public init(ref: String, orderBy: String? = nil, startingAtChildKey: String? = nil,
              startingAtValue: Any? = nil) {
    self.orderBy = orderBy
    self.ref = ref
    self.startingAtChildKey = startingAtChildKey
    self.startingAtValue = startingAtValue
  }
}

public func == (lhs: FirebaseRefConfig, rhs: FirebaseRefConfig) -> Bool {
  return lhs.ref == rhs.ref &&
    lhs.orderBy == rhs.orderBy
}

public protocol FirebaseAppType {}
extension FIRApp: FirebaseAppType {}

public protocol FirebaseAuthType {}
extension FIRAuth: FirebaseAuthType {}

public protocol FirebaseDatabaseReferenceType {}
extension FIRDatabaseReference: FirebaseDatabaseReferenceType {}

public protocol FirebaseServerValueType {
  static func timestamp() -> [AnyHashable: Any]
}
extension FIRServerValue: FirebaseServerValueType {}

public protocol FirebaseDataSnapshotType {
  var key: String { get }
  var value: Any? { get }
}
extension FIRDataSnapshot: FirebaseDataSnapshotType {}
