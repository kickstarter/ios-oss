import FirebaseAnalytics
import FirebaseDatabase

public struct FirebaseRefConfig {
  let orderBy: String
  let ref: String

  public init(ref: String, orderBy: String) {
    self.orderBy = orderBy
    self.ref = ref
  }
}

internal protocol FirebaseAppType {}
extension FIRApp: FirebaseAppType {}

internal protocol FirebaseDatabaseReferenceType {}
extension FIRDatabaseReference: FirebaseDatabaseReferenceType {}
