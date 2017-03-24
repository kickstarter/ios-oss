import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase

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
