import FirebaseAnalytics
import FirebaseDatabase

public struct FirebaseRefConfig {
  let ref: String
  let orderBy: String

  public init(ref: String, orderBy: String) {
    self.ref = ref
    self.orderBy = orderBy
  }
}

internal protocol FirebaseAppType {}
extension FIRApp: FirebaseAppType {}

internal protocol FirebaseDatabaseRefType {}
extension FIRDatabaseReference: FirebaseDatabaseRefType {}
